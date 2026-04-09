# Deployment Pattern: API Only (No Frontend in This Repo)

**When to choose:** Backend-only project, API consumed by multiple clients (web + mobile), the frontend is a separate team/repo, or you're building a public API / platform.

---

## Architecture

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│ Angular app  │     │ Mobile app   │     │ Third-party  │
│ (own repo)   │     │ (own repo)   │     │ integrations │
└──────┬───────┘     └──────┬───────┘     └──────┬───────┘
       │                    │                    │
       └──────────────┬─────┘────────────────────┘
                      │  HTTPS + CORS / Auth
                      ▼
         ┌────────────────────────┐
         │    [Project].API       │
         │    (this repo)         │
         └────────────────────────┘
                      │
         ┌────────────┴────────────┐
         │      Database           │
         └─────────────────────────┘
```

---

## Repo Structure

```
[SolutionName]/
├── src/
│   ├── [Project].Domain/
│   ├── [Project].Application/
│   ├── [Project].Infrastructure/
│   └── [Project].API/
│       ├── Endpoints/           ← Minimal API (preferred) or Controllers/
│       ├── Middleware/
│       ├── OpenApi/             ← Swagger / Scalar config
│       ├── Program.cs
│       └── appsettings.json
│
├── tests/
└── [SolutionName].sln
```

No `ClientApp/`, no `wwwroot/`, no SPA middleware.

---

## Key additions for API-only projects

### OpenAPI / Swagger
```csharp
// Program.cs
builder.Services.AddOpenApi();
// or Scalar (modern alternative to Swagger UI)
builder.Services.AddOpenApiDocument();

app.MapOpenApi();
app.MapScalarApiReference(); // /scalar/v1
```

### CORS — configured per client
```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowedClients", policy =>
        policy.WithOrigins(
            builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>()!
        )
        .AllowAnyMethod()
        .AllowAnyHeader()
        .AllowCredentials());
});
```

`appsettings.json`:
```json
{
  "Cors": {
    "AllowedOrigins": [
      "https://app.mycompany.com",
      "https://admin.mycompany.com"
    ]
  }
}
```

### Versioning
```csharp
builder.Services.AddApiVersioning(options =>
{
    options.DefaultApiVersion = new ApiVersion(1);
    options.ReportApiVersions = true;
});
```

Routes: `/api/v1/orders`, `/api/v2/orders`

---

## Dev Setup

```bash
# Just the API
dotnet run --project src/[Project].API

# Swagger UI available at:
# https://localhost:7001/swagger
# or Scalar at:
# https://localhost:7001/scalar/v1
```

---

## CI/CD

```yaml
steps:
  - dotnet restore
  - dotnet build
  - dotnet test
  - dotnet publish -c Release -o publish
  - deploy to App Service / ECS / AKS
```

---

## Trade-offs

| Pro | Con |
|---|---|
| Clean, focused codebase | Frontend teams need to run their own repo |
| Can serve any number of clients | More repos to coordinate |
| Independent scaling | CORS always required for browser clients |
| Easy to version the API | — |
| Natural for platforms / public APIs | — |
