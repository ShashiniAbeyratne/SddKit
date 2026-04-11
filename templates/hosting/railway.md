# API Hosting: Railway

## Setup
Zero-config for most projects — Railway detects .NET and builds via Nixpacks automatically. Add a `Dockerfile` if you need custom build steps or want deterministic builds.

---

## Port binding — REQUIRED CODE CHANGE
Railway sets a `PORT` environment variable and routes traffic to it:
```csharp
// Program.cs
var port = Environment.GetEnvironmentVariable("PORT") ?? "8080";
app.Run($"http://0.0.0.0:{port}");
```

---

## Health check
Railway monitors that the process stays up. Add a health endpoint for visibility in the Railway dashboard and for zero-downtime deploys:
```csharp
// Program.cs
builder.Services.AddHealthChecks();
app.MapHealthChecks("/health");
```
Optional — Railway doesn't require a specific path, but it's good practice.

---

## Secrets / configuration
Set in **Railway dashboard → Service → Variables**. They become environment variables at runtime — no secrets SDK needed.

For nested .NET config keys, use double underscores:
```
ConnectionStrings__DefaultConnection=Host=postgres.railway.internal;Database=myapp;...
ASPNETCORE_ENVIRONMENT=Production
```

Railway also offers managed PostgreSQL, Redis, and MySQL as add-on services. Connection strings for linked add-ons are injected automatically as environment variables.

---

## CI/CD
Zero-config — Railway deploys on every push to the linked branch.

For manual deploys or triggering from GitHub Actions:
```yaml
      - name: Deploy to Railway
        run: npx @railway/cli@latest up --service myapp-api --detach
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
```

---

## railway.toml (optional)
For custom build/deploy config:
```toml
[build]
builder = "DOCKERFILE"
dockerfilePath = "Dockerfile"

[deploy]
startCommand = "dotnet [Project].API.dll"
healthcheckPath = "/health"
healthcheckTimeout = 30
restartPolicyType = "ON_FAILURE"
restartPolicyMaxRetries = 3
```

---

## Trade-offs
| Pro | Con |
|---|---|
| Fastest to get running — minutes not hours | Not designed for high-scale production |
| No YAML, no cloud console required | Less control over networking/infra |
| Built-in PostgreSQL, Redis, MySQL add-ons | Vendor lock-in |
| Automatic SSL and custom domains | Limited regions |
| Pay-as-you-go with a free tier | Free tier has usage limits |
