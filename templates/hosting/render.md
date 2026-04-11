# API Hosting: Render

## Setup
Connect repo at render.com. Render can build .NET projects from:
- A `Dockerfile` (recommended — deterministic)
- Render's native build system (less predictable for .NET)

Use `render.yaml` (Blueprint) for infrastructure-as-code — commit it to the repo:
```yaml
# render.yaml
services:
  - type: web
    name: myapp-api
    runtime: docker
    dockerfilePath: ./Dockerfile
    plan: starter
    healthCheckPath: /health
    envVars:
      - key: ASPNETCORE_ENVIRONMENT
        value: Production
      - key: ConnectionStrings__DefaultConnection
        fromDatabase:
          name: myapp-db
          property: connectionString
    autoDeploy: true

databases:
  - name: myapp-db
    plan: starter
    databaseName: myapp
    user: myapp
```

---

## Port binding — REQUIRED CODE CHANGE
Render sets a `PORT` environment variable for Docker services:
```csharp
// Program.cs
var port = Environment.GetEnvironmentVariable("PORT") ?? "8080";
app.Run($"http://0.0.0.0:{port}");
```

---

## Health check
Render uses `healthCheckPath` from `render.yaml` to monitor the service and manage zero-downtime deploys:
```csharp
// Program.cs
builder.Services.AddHealthChecks();
app.MapHealthChecks("/health");
```

---

## Secrets / configuration
**Option A — render.yaml references:**
```yaml
envVars:
  - key: JwtSecret
    sync: false    # value entered manually in Render dashboard — not committed to repo
```

**Option B — Render dashboard:**
Set directly in **Render dashboard → Service → Environment**. Values are injected as environment variables.

For nested .NET config keys, use double underscores:
```
ConnectionStrings__DefaultConnection=Host=...;Database=...
Jwt__Secret=...
```

---

## CI/CD
Zero-config — Render deploys on every push to the linked branch when `autoDeploy: true` in `render.yaml`.

For triggering from GitHub Actions (e.g. after running tests):
```yaml
      - name: Deploy to Render
        run: |
          curl -X POST \
            -H "Authorization: Bearer ${{ secrets.RENDER_API_KEY }}" \
            https://api.render.com/v1/services/${{ secrets.RENDER_SERVICE_ID }}/deploys \
            -d '{}'
```

---

## Trade-offs
| Pro | Con |
|---|---|
| `render.yaml` is infra-as-code — no portal clicking | Free tier services spin down after 15 min inactivity |
| Heroku-level simplicity | Fewer regions than major clouds |
| Built-in managed databases | Not suitable for enterprise compliance workloads |
| Automatic SSL and custom domains | Spin-up latency after idle (~30s) |
| Preview environments per PR | — |
