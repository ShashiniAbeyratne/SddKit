# Frontend Hosting: Netlify

## SPA routing / 404 fallback — netlify.toml
Place in the frontend project root (`client/` or repo root for frontend-only):
```toml
[build]
  base    = "client"        # path to FE root — omit if repo root is the FE
  publish = "client/dist"   # Vite output; use "client/dist/browser" for Angular SSR
  command = "npm run build"

[[redirects]]
  from   = "/*"
  to     = "/index.html"
  status = 200
```

---

## CI/CD
Zero-config — connect repo at netlify.com. `netlify.toml` drives the build automatically.

For explicit control via GitHub Actions:
```yaml
# .github/workflows/deploy-frontend.yml
name: Deploy Frontend to Netlify

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install and build
        working-directory: client
        run: npm ci && npm run build

      - name: Deploy to Netlify
        uses: nwtgck/actions-netlify@v3
        with:
          publish-dir: './client/dist'
          production-branch: main
          github-token: ${{ secrets.GITHUB_TOKEN }}
          deploy-message: "Deploy ${{ github.sha }}"
        env:
          NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
          NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
```

---

## Environment variables
Set in **Netlify dashboard → Site → Environment Variables**.
Prefix with `VITE_` for Vite (React). Angular reads `environment.ts` — inject values at build time via CI env vars if needed.

```
# .env.example
VITE_API_BASE_URL=https://api.myapp.com
```

---

## CORS origin to whitelist in your API
```
https://myapp.netlify.app     # production
https://myapp.com             # custom domain (if configured)
```
