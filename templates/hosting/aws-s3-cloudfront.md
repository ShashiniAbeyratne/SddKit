# Frontend Hosting: AWS S3 + CloudFront

## SPA routing / 404 fallback
S3 does not support SPA routing natively. Configure CloudFront custom error responses:

**In AWS Console** → CloudFront → Distribution → Error pages → Create custom error response:
| HTTP error code | Response page path | HTTP response code |
|---|---|---|
| 403 | `/index.html` | 200 |
| 404 | `/index.html` | 200 |

403 is needed because S3 returns 403 (not 404) for missing objects when the bucket is private.

**In Terraform / IaC:**
```hcl
custom_error_response {
  error_code         = 403
  response_code      = 200
  response_page_path = "/index.html"
}
custom_error_response {
  error_code         = 404
  response_code      = 200
  response_page_path = "/index.html"
}
```

---

## S3 bucket config
- Bucket should be **private** — no public access
- Use **CloudFront Origin Access Control (OAC)** to allow CloudFront to read from S3
- Do not enable S3 static website hosting (unnecessary and less secure with OAC)

---

## CI/CD — GitHub Actions
```yaml
# .github/workflows/deploy-frontend.yml
name: Deploy Frontend to S3 + CloudFront

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

      - name: Install and build
        working-directory: client
        run: npm ci && npm run build
        env:
          VITE_API_BASE_URL: ${{ secrets.VITE_API_BASE_URL }}

      - name: Configure AWS credentials (OIDC — no long-lived keys)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/GitHubActionsDeployRole
          aws-region: us-east-1

      - name: Upload to S3
        run: aws s3 sync client/dist/ s3://${{ secrets.S3_BUCKET }} --delete

      - name: Invalidate CloudFront cache
        run: |
          aws cloudfront create-invalidation \
            --distribution-id ${{ secrets.CF_DISTRIBUTION_ID }} \
            --paths "/*"
```

**Prefer OIDC over long-lived access keys.** Set up a GitHub OIDC provider in IAM and a role with a trust policy scoped to your repo.

---

## Environment variables
No runtime env vars — all are inlined at build time. Pass via GitHub Actions secrets as `env:` in the build step (see above).

```
# .env.example
VITE_API_BASE_URL=https://api.myapp.com
```

---

## CORS origin to whitelist in your API
```
https://dxxxxxxxxxxxxxx.cloudfront.net    # CloudFront domain
https://myapp.com                         # custom domain (if configured via Route 53)
```
