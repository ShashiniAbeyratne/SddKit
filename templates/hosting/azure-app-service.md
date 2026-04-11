# API Hosting: Azure App Service

## Health check
Required for App Service health monitoring and zero-downtime deployment slot swaps:
```csharp
// Program.cs
builder.Services.AddHealthChecks();
app.MapHealthChecks("/health");
```
Configure in **Azure portal → App Service → Health check → Path: `/health`**.

---

## Port binding
No changes needed. App Service sets the port via the `WEBSITES_PORT` setting if non-default. ASP.NET Core reads it automatically via the platform's environment configuration.

---

## Secrets / configuration
**Non-sensitive settings:** Azure portal → App Service → Configuration → Application settings.

**Secrets:** Use Key Vault references — no credentials in config files:
```json
// appsettings.Production.json — value is resolved from Key Vault at runtime
{
  "ConnectionStrings": {
    "DefaultConnection": "@Microsoft.KeyVault(SecretUri=https://myvault.vault.azure.net/secrets/DbConn/)"
  }
}
```
Enable **system-assigned managed identity** on the App Service and grant it the `Key Vault Secrets User` role — no credentials required anywhere.

---

## CI/CD — GitHub Actions
```yaml
# .github/workflows/deploy-api.yml
name: Deploy API to Azure App Service

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '9.x'

      - name: Build and publish
        run: dotnet publish src/[Project].API -c Release -o publish

      - name: Deploy to App Service
        uses: azure/webapps-deploy@v3
        with:
          app-name: ${{ secrets.AZURE_WEBAPP_NAME }}
          publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}
          package: publish
```

Prefer **federated identity (OIDC)** over publish profiles for production:
```yaml
      - name: Login to Azure (OIDC)
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Deploy to App Service
        uses: azure/webapps-deploy@v3
        with:
          app-name: ${{ secrets.AZURE_WEBAPP_NAME }}
          package: publish
```

---

## CORS config in Program.cs
```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("Frontend", policy =>
        policy.WithOrigins(
            builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>()!
        )
        .AllowAnyMethod()
        .AllowAnyHeader()
        .AllowCredentials());
});

app.UseCors("Frontend");
```

`appsettings.Production.json`:
```json
{
  "Cors": {
    "AllowedOrigins": [
      "https://myapp.vercel.app",
      "https://myapp.com"
    ]
  }
}
```
