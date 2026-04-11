# API Hosting: AWS Lambda

## Approach
Wrap ASP.NET Core as a Lambda function using `Amazon.Lambda.AspNetCoreServer.Hosting`. API Gateway routes HTTP requests to the function.

Install the NuGet package:
```bash
dotnet add package Amazon.Lambda.AspNetCoreServer.Hosting
```

---

## Program.cs change
```csharp
var builder = WebApplication.CreateBuilder(args);

// Add Lambda hosting — detects Lambda environment automatically, falls back to Kestrel locally
builder.Services.AddAWSLambdaHosting(LambdaEventSource.HttpApi);

// ... rest of your normal setup
var app = builder.Build();
// ... middleware, routes, etc.
app.Run();
```

---

## Port binding
Not applicable — Lambda has no port concept. API Gateway translates HTTP requests into Lambda invocation events.

---

## Health check
API Gateway can ping any route. Add a lightweight endpoint:
```csharp
app.MapGet("/health", () => Results.Ok(new { status = "healthy" }));
```
No `AddHealthChecks()` overhead needed unless you have DB/dependency checks.

---

## Cold starts
Lambda has cold start latency (typically 200–800ms for .NET). Mitigations:
- **Provisioned Concurrency** — keeps instances warm (costs money)
- **Trim unused assemblies** — keep the Lambda package small
- **Native AOT** — reduces cold start significantly for .NET 8+, but requires AOT-compatible code

---

## Secrets / configuration
Reference from AWS Secrets Manager or Parameter Store via environment variables set in the Lambda function config. ECS and Lambda use the same approach — no SDK change in app code needed.

`template.yaml` (SAM) environment variables:
```yaml
Environment:
  Variables:
    ASPNETCORE_ENVIRONMENT: Production
    ConnectionStrings__DefaultConnection: !Sub
      '{{resolve:secretsmanager:myapp/db-connection}}'
```

---

## SAM template — template.yaml
Add to repo root:
```yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31

Globals:
  Function:
    Timeout: 30
    MemorySize: 512
    Runtime: dotnet8

Resources:
  MyAppApiFunction:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: src/[Project].API/
      Handler: [Project].API
      Events:
        ProxyResource:
          Type: HttpApi
          Properties:
            Path: /{proxy+}
            Method: ANY
        RootResource:
          Type: HttpApi
          Properties:
            Path: /
            Method: ANY
```

---

## CI/CD — GitHub Actions
```yaml
# .github/workflows/deploy-api.yml
name: Deploy API to AWS Lambda

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read

    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '9.x'

      - name: Install Lambda tools
        run: dotnet tool install -g Amazon.Lambda.Tools

      - name: Configure AWS credentials (OIDC)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/GitHubActionsDeployRole
          aws-region: us-east-1

      - name: Install SAM CLI
        uses: aws-actions/setup-sam@v2

      - name: SAM build and deploy
        run: |
          sam build
          sam deploy --no-confirm-changeset --no-fail-on-empty-changeset \
            --stack-name myapp-api \
            --capabilities CAPABILITY_IAM \
            --region us-east-1
```

---

## Trade-offs
| Pro | Con |
|---|---|
| Pay per request — near zero cost at low traffic | Cold starts (200–800ms) |
| Scales to zero automatically | Max 15 min execution per invocation |
| No server management | Stateless — no in-process caching |
| Great for event-driven / async workloads | EF Core migrations need a separate runner |
| Integrates with EventBridge, SQS, SNS natively | Extra complexity vs always-on server |
