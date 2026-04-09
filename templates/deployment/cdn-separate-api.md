# Deployment Pattern: CDN + Separate API (Industry Standard)

**When to choose:** New projects, teams that deploy independently, public-facing apps, when you want CDN performance.

---

## Architecture

```
                    ┌─────────────────────────────┐
  Browser ─────────▶│   CDN (Edge)                │
                    │   Azure Static Web Apps      │
                    │   Vercel / Netlify / S3+CF   │
                    │                             │
                    │   Serves: index.html        │
                    │           main.js           │
                    │           styles.css        │
                    └─────────────────────────────┘
                                  │
                                  │ API calls (HTTPS + CORS)
                                  ▼
                    ┌─────────────────────────────┐
                    │   API Server                │
                    │   Azure App Service         │
                    │   AWS ECS / Lambda          │
                    │   Kubernetes pod            │
                    └─────────────────────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │   Database                │
                    │   Azure SQL / PostgreSQL  │
                    └───────────────────────────┘
```

---

## Repo Structure

```
/                               ← monorepo root (or two separate repos)
├── client/                     ← Angular / React project
│   ├── src/
│   ├── angular.json
│   ├── package.json
│   └── .env.production         ← VITE_API_URL or environment.prod.ts
│
└── src/                        ← C# solution (API only)
    ├── [Project].Domain/
    ├── [Project].Application/
    ├── [Project].Infrastructure/
    └── [Project].API/          ← no wwwroot, no SPA middleware
        ├── Program.cs
        └── appsettings.json
```

---

## Dev Setup

```bash
# Terminal 1 — API
dotnet run --project src/[Project].API

# Terminal 2 — Frontend
cd client && ng serve          # Angular: localhost:4200
# or
cd client && npm run dev       # React/Vite: localhost:5173
```

Frontend `.env` / `environment.ts`:
```typescript
// Angular
export const environment = {
  production: false,
  apiUrl: 'https://localhost:7001'
};

// React (Vite)
VITE_API_BASE_URL=https://localhost:7001
```

---

## CORS (always on — dev and prod)

```csharp
// Program.cs
builder.Services.AddCors(options =>
{
    options.AddPolicy("Frontend", policy =>
        policy.WithOrigins(
            "http://localhost:4200",           // Angular dev
            "http://localhost:5173",           // React/Vite dev
            "https://myapp.azurestaticapps.net" // prod CDN
        )
        .AllowAnyMethod()
        .AllowAnyHeader()
        .AllowCredentials());
});

app.UseCors("Frontend");
```

Production CORS origins come from `appsettings.Production.json` — never hardcoded.

---

## CI/CD Pipelines

### Frontend pipeline (GitHub Actions / Azure DevOps)
```
trigger: push to main
steps:
  1. npm install
  2. ng build --configuration production
  3. Deploy dist/ to Azure Static Web Apps / S3 / Vercel
```

### Backend pipeline
```
trigger: push to main
steps:
  1. dotnet restore
  2. dotnet build
  3. dotnet test
  4. dotnet publish
  5. Deploy to Azure App Service / ECS
```

Completely independent — a frontend deploy never touches the backend pipeline.

---

## Auth pattern with this setup

- API issues JWT tokens
- Frontend stores token in memory or `httpOnly` cookie
- If `httpOnly` cookie: same-site considerations — frontend and API need to be on same parent domain (e.g. `app.myco.com` and `api.myco.com`)
- If Bearer token in memory: simplest, works across any domain

---

## Trade-offs

| Pro | Con |
|---|---|
| CDN = fastest possible static delivery | CORS always required |
| Independent deploys | Two pipelines to maintain |
| Frontend on any CDN globally | Slightly more infra config |
| Scale API and frontend separately | Cookie auth needs domain alignment |
| Standard — every developer knows this | — |
