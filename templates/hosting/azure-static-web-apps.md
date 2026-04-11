# Frontend Hosting: Azure Static Web Apps

## SPA routing / 404 fallback — staticwebapp.config.json
Place in `client/public/` (Vite copies it to dist automatically) or `client/src/` (Angular — add to `assets` in `angular.json`):
```json
{
  "navigationFallback": {
    "rewrite": "/index.html",
    "exclude": ["/api/*", "/_framework/*", "/assets/*", "/*.{css,js,png,jpg,svg,ico}"]
  },
  "globalHeaders": {
    "X-Content-Type-Options": "nosniff",
    "X-Frame-Options": "DENY",
    "Referrer-Policy": "strict-origin-when-cross-origin"
  }
}
```

---

## CI/CD — GitHub Actions
Azure generates this file automatically when you link the repo in the portal:
```yaml
# .github/workflows/deploy-frontend.yml
name: Deploy Frontend to Azure Static Web Apps

on:
  push:
    branches: [main]
  pull_request:
    types: [opened, synchronize, reopened, closed]
    branches: [main]

jobs:
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: true

      - name: Deploy to Azure Static Web Apps
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: upload
          app_location: client       # path to FE source
          output_location: dist      # relative to app_location
```

---

## Environment variables
Set in **Azure portal → Static Web App → Configuration → Application settings**.
Prefix with `VITE_` for Vite. They are injected at build time during the GitHub Actions run.

```
# .env.example
VITE_API_BASE_URL=https://api.myapp.com
```

---

## Azure-specific: linked backend (no CORS needed)
If your API is also on Azure (App Service or Container Apps), you can link it to the SWA:
- Portal → Static Web App → APIs → Link an existing API
- Requests to `/api/*` are proxied to your backend — same origin, no CORS

This is the smoothest FE+BE integration if both are on Azure.

---

## CORS origin to whitelist in your API (if NOT using linked backend)
```
https://myapp.azurestaticapps.net    # production
https://myapp.com                    # custom domain (if configured)
```
