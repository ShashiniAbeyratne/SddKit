# Frontend Hosting: Vercel

## SPA routing / 404 fallback — vercel.json
Place in the frontend project root (`client/` or repo root for frontend-only):
```json
{
  "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }]
}
```

For monorepos, also set **Root Directory** to `client/` in the Vercel project settings dashboard.

---

## CI/CD
Zero-config — connect the repo at vercel.com. No YAML required for most projects.

For monorepos or explicit control:
```yaml
# .github/workflows/deploy-frontend.yml
name: Deploy Frontend to Vercel

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          working-directory: ./client
          vercel-args: '--prod'
```

---

## Environment variables
Set in **Vercel dashboard → Project → Settings → Environment Variables**.
All vars are inlined at build time — prefix with `VITE_` (React/Vite) or `NG_APP_` (Angular with custom plugin).

```
# .env.example
VITE_API_BASE_URL=https://api.myapp.com
```

---

## CORS origin to whitelist in your API
```
https://myapp.vercel.app          # production
https://myapp.com                 # custom domain (if configured)
```

Preview deployments get dynamic URLs (`myapp-git-branch-org.vercel.app`). For dev purposes either skip CORS on preview or use a wildcard pattern on non-production API environments.
