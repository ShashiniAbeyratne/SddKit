# API Hosting: Azure Container Apps

## Dockerfile
Container Apps requires a container image. Add to repo root:
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
COPY ["src/[Project].API/[Project].API.csproj", "src/[Project].API/"]
RUN dotnet restore "src/[Project].API/[Project].API.csproj"
COPY . .
RUN dotnet publish "src/[Project].API/[Project].API.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "[Project].API.dll"]
```

---

## Port binding
Container Apps routes to port `8080` by default. ASP.NET Core 8+ defaults to `8080` inside containers — no code change needed.

---

## Health check
```csharp
// Program.cs
builder.Services.AddHealthChecks();
app.MapHealthChecks("/health");
```
Configure in **Azure portal → Container App → Health probes → Liveness/Readiness → Path: `/health`**.

---

## Secrets / configuration
**Option A — Key Vault + managed identity (recommended):**
```csharp
// Program.cs
builder.Configuration.AddAzureKeyVault(
    new Uri($"https://{builder.Configuration["KeyVault:Name"]}.vault.azure.net/"),
    new DefaultAzureCredential());
```
Enable managed identity on the Container App and grant `Key Vault Secrets User`.

**Option B — Container Apps secrets:**
Set secrets in Azure portal → Container App → Secrets, then reference them as environment variables in the container configuration. No SDK change needed.

---

## CI/CD — GitHub Actions
```yaml
# .github/workflows/deploy-api.yml
name: Deploy API to Azure Container Apps

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Login to Azure (OIDC)
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Log in to Azure Container Registry
        run: az acr login --name ${{ secrets.ACR_NAME }}

      - name: Build and push image
        run: |
          docker build -t ${{ secrets.ACR_NAME }}.azurecr.io/myapp-api:${{ github.sha }} .
          docker push ${{ secrets.ACR_NAME }}.azurecr.io/myapp-api:${{ github.sha }}

      - name: Deploy to Container Apps
        uses: azure/container-apps-deploy-action@v2
        with:
          acrName: ${{ secrets.ACR_NAME }}
          containerAppName: myapp-api
          resourceGroup: myapp-rg
          imageToDeploy: ${{ secrets.ACR_NAME }}.azurecr.io/myapp-api:${{ github.sha }}
```

---

## CORS config
Same pattern as Azure App Service — read allowed origins from configuration, not hardcoded.
