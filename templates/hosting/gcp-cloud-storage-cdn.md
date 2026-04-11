# Frontend Hosting: GCP Cloud Storage + Cloud CDN

## SPA routing / 404 fallback

**Recommended: Firebase Hosting** (simpler, built-in SPA support, still on GCP)

Add `firebase.json` to the frontend project root:
```json
{
  "hosting": {
    "public": "dist",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      { "source": "**", "destination": "/index.html" }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css)",
        "headers": [{ "key": "Cache-Control", "value": "max-age=31536000" }]
      }
    ]
  }
}
```

**Alternative: Cloud Storage + Load Balancer URL Map**
Requires a URL map rule at the load balancer level to redirect all 404s to `/index.html`. Done in GCP Console or Terraform — no file in the repo.

---

## CI/CD — GitHub Actions (Firebase Hosting path)
```yaml
# .github/workflows/deploy-frontend.yml
name: Deploy Frontend to Firebase Hosting

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

      - name: Install and build
        working-directory: client
        run: npm ci && npm run build
        env:
          VITE_API_BASE_URL: ${{ secrets.VITE_API_BASE_URL }}

      - name: Deploy to Firebase Hosting
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: ${{ secrets.GITHUB_TOKEN }}
          firebaseServiceAccount: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          channelId: live
          projectId: my-gcp-project
          entryPoint: ./client
```

**CI/CD — GitHub Actions (Cloud Storage path)**
```yaml
      - name: Authenticate to GCP (Workload Identity)
        uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github/providers/github
          service_account: github-actions@my-project.iam.gserviceaccount.com

      - name: Upload to Cloud Storage
        run: gcloud storage cp -r client/dist/* gs://my-frontend-bucket/

      - name: Invalidate CDN cache
        run: gcloud compute url-maps invalidate-cdn-cache my-url-map --path "/*"
```

---

## Environment variables
Inlined at build time. Pass `VITE_API_BASE_URL` via GitHub Actions secrets in the build step.

```
# .env.example
VITE_API_BASE_URL=https://api.myapp.com
```

---

## CORS origin to whitelist in your API
```
https://my-project.web.app      # Firebase Hosting default domain
https://myapp.com               # custom domain (if configured)
```
