# API Hosting: AWS ECS (Fargate)

## Dockerfile
Standard multi-stage .NET Dockerfile — same pattern as [azure-container-apps.md](azure-container-apps.md). Replace `[Project].API` with your project name.

---

## Port binding
ECS routes traffic to the container port defined in the task definition. ASP.NET Core 8+ defaults to `8080` in containers — no code change needed. Match the task definition `containerPort` to `8080`.

---

## Health check
```csharp
// Program.cs
builder.Services.AddHealthChecks();
app.MapHealthChecks("/health");
```
Configure in **ECS → Target Group → Health check → Path: `/health`** (used by the Application Load Balancer).

---

## Secrets / configuration
Reference secrets from AWS Secrets Manager in the task definition — ECS injects them as environment variables at container start. No SDK change in app code:
```json
{
  "secrets": [
    {
      "name": "ConnectionStrings__DefaultConnection",
      "valueFrom": "arn:aws:secretsmanager:us-east-1:123456789:secret:myapp/db-connection"
    }
  ],
  "environment": [
    {
      "name": "ASPNETCORE_ENVIRONMENT",
      "value": "Production"
    }
  ]
}
```
Double underscore (`__`) maps to nested JSON in .NET configuration.

---

## CI/CD — GitHub Actions
```yaml
# .github/workflows/deploy-api.yml
name: Deploy API to AWS ECS

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write   # required for OIDC
      contents: read

    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials (OIDC — no long-lived keys)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/GitHubActionsDeployRole
          aws-region: us-east-1

      - name: Log in to ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: Build and push image
        id: build
        run: |
          IMAGE=${{ steps.login-ecr.outputs.registry }}/myapp-api:${{ github.sha }}
          docker build -t $IMAGE .
          docker push $IMAGE
          echo "image=$IMAGE" >> $GITHUB_OUTPUT

      - name: Render ECS task definition
        id: task-def
        uses: aws-actions/amazon-ecs-render-task-definition@v1
        with:
          task-definition: .aws/task-definition.json
          container-name: myapp-api
          image: ${{ steps.build.outputs.image }}

      - name: Deploy to ECS
        uses: aws-actions/amazon-ecs-deploy-task-definition@v1
        with:
          task-definition: ${{ steps.task-def.outputs.task-definition }}
          service: myapp-api-service
          cluster: myapp-cluster
          wait-for-service-stability: true
```

Add `.aws/task-definition.json` to the repo with your task definition (replace image placeholder — the action updates it at deploy time).

---

## CORS config
Same pattern — read allowed origins from environment/config, not hardcoded:
```json
{
  "environment": [
    { "name": "Cors__AllowedOrigins__0", "value": "https://myapp.vercel.app" }
  ]
}
```
