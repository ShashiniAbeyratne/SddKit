# API Hosting: GCP Cloud Run

## Dockerfile
Standard multi-stage .NET Dockerfile — same pattern as [azure-container-apps.md](azure-container-apps.md). Replace `[Project].API` with your project name.

---

## Port binding — REQUIRED CODE CHANGE
Cloud Run sets a `PORT` environment variable and routes traffic to it. You must bind to this port:

```csharp
// Program.cs — read PORT env var (Cloud Run sets this; defaults to 8080 locally)
var port = Environment.GetEnvironmentVariable("PORT") ?? "8080";
app.Run($"http://0.0.0.0:{port}");
```

This is the **one mandatory code change** for Cloud Run. Without it, Cloud Run's health checks will fail and the deployment will roll back.

---

## Health check
```csharp
// Program.cs
builder.Services.AddHealthChecks();
app.MapHealthChecks("/health");
```
Configure in **GCP Console → Cloud Run → Edit & Deploy New Revision → Health checks**:
- Startup probe: path `/health`, port `8080`
- Liveness probe: path `/health`, port `8080`

---

## Secrets / configuration
**Option A — Secret Manager (recommended):**
```csharp
// Program.cs — reads secrets from GCP Secret Manager at startup
builder.Configuration.AddGoogleSecretManager(projectId: "my-gcp-project");
```
Install: `dotnet add package Google.Cloud.SecretManager.Client`

Grant the Cloud Run service account the `Secret Manager Secret Accessor` role.

**Option B — Environment variables from Secret Manager (no SDK):**
In Cloud Run service config, reference secrets as env vars:
```yaml
# service.yaml (for gcloud deploy)
env:
  - name: ConnectionStrings__DefaultConnection
    valueFrom:
      secretKeyRef:
        name: db-connection
        key: latest
```

---

## CI/CD — GitHub Actions
```yaml
# .github/workflows/deploy-api.yml
name: Deploy API to GCP Cloud Run

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

      - name: Authenticate to GCP (Workload Identity — no service account key file)
        uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: projects/${{ secrets.GCP_PROJECT_NUMBER }}/locations/global/workloadIdentityPools/github/providers/github
          service_account: github-actions@${{ secrets.GCP_PROJECT_ID }}.iam.gserviceaccount.com

      - name: Setup gcloud
        uses: google-github-actions/setup-gcloud@v2

      - name: Build and push to Artifact Registry
        run: |
          gcloud builds submit \
            --tag ${{ secrets.GCP_REGION }}-docker.pkg.dev/${{ secrets.GCP_PROJECT_ID }}/myapp/api:${{ github.sha }}

      - name: Deploy to Cloud Run
        run: |
          gcloud run deploy myapp-api \
            --image ${{ secrets.GCP_REGION }}-docker.pkg.dev/${{ secrets.GCP_PROJECT_ID }}/myapp/api:${{ github.sha }} \
            --region ${{ secrets.GCP_REGION }} \
            --platform managed \
            --allow-unauthenticated \
            --set-env-vars ASPNETCORE_ENVIRONMENT=Production
```

---

## CORS config
Same pattern — read allowed origins from configuration/environment variables, not hardcoded.
