# Deployment Pattern: .Host Project (Microsoft SPA Pattern)

**When to choose:** Enterprise internal tools, single team with single deploy pipeline, Microsoft shop, existing codebase using this pattern.

---

## Architecture

```
Development:
  ng serve → localhost:4200  (Angular dev server)
  dotnet run / IIS → localhost:44300  (API + future host)
  CORS: 44300 allows 4200

Production:
  ng build → dist/ → copied into .Host/wwwroot/
  dotnet publish → one artifact
  Browser hits .Host → gets Angular static files + calls API on same origin
  No CORS needed in production
```

---

## Repo Structure

```
[SolutionName]/
├── src/
│   ├── [Project].Domain/
│   ├── [Project].Application/
│   ├── [Project].Infrastructure/
│   │
│   └── [Project].Host/               ← serves both Angular + API
│       ├── ClientApp/                ← Angular project lives here
│       │   ├── src/
│       │   │   └── app/
│       │   ├── angular.json
│       │   ├── package.json
│       │   └── proxy.conf.js         ← dev proxy: /api → localhost:44300
│       │
│       ├── Controllers/              ← API endpoints
│       ├── wwwroot/                  ← ng build output (gitignored)
│       ├── Program.cs
│       └── appsettings.json
│
├── tests/
└── [SolutionName].sln
```

---

## Dev Setup

```bash
# Terminal 1 — Angular dev server
cd src/[Project].Host/ClientApp
npm start   # or ng serve — runs on :4200

# Terminal 2 — API (IIS Express or dotnet run)
dotnet run --project src/[Project].Host
# or open in Visual Studio → F5 → IIS Express
```

Angular dev proxy (`proxy.conf.js`) forwards API calls to avoid CORS in dev:
```js
const PROXY_CONFIG = [{
  context: ['/api'],
  target: 'https://localhost:44300',
  secure: false
}]
```

Angular `angular.json` — serve config:
```json
"serve": {
  "options": {
    "proxyConfig": "proxy.conf.js"
  }
}
```

With the proxy, Angular makes calls to `localhost:4200/api/...` which are forwarded to `:44300` — **no CORS needed in dev either** with this setup.

---

## Program.cs — Host configuration

```csharp
// Development: API only, Angular runs separately via ng serve
// Production: serve Angular static files + API on same port

if (!app.Environment.IsDevelopment())
{
    app.UseHsts();
}

app.UseStaticFiles();       // serves wwwroot (ng build output)

app.MapControllers();       // API routes

// SPA fallback — Angular handles its own routing
app.MapFallbackToFile("index.html");
```

CORS (dev only — production is same-origin so CORS is not needed):
```csharp
if (app.Environment.IsDevelopment())
{
    app.UseCors(policy =>
        policy.WithOrigins("http://localhost:4200")
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials());
}
```

---

## Build & Deploy

```bash
# Step 1 — build Angular into wwwroot
cd src/[Project].Host/ClientApp
ng build --configuration production
# output goes to src/[Project].Host/wwwroot/

# Step 2 — publish the .NET app (includes wwwroot)
dotnet publish src/[Project].Host -c Release -o publish/

# Step 3 — deploy publish/ to server (IIS, App Service, etc.)
```

One artifact. One deployment. One process serves everything.

### Azure DevOps / GitHub Actions:
```yaml
steps:
  - name: Build Angular
    run: cd src/Project.Host/ClientApp && npm ci && ng build --configuration production

  - name: Build and publish .NET
    run: dotnet publish src/Project.Host -c Release -o publish

  - name: Deploy
    # upload publish/ to IIS / Azure App Service
```

---

## Auth pattern with this setup

- Same origin in production = `httpOnly` cookies work perfectly (no cross-domain issues)
- ASP.NET Core Identity cookie auth is the natural fit
- JWT also works — stored in memory or `httpOnly` cookie

---

## Trade-offs

| Pro | Con |
|---|---|
| One pipeline, one deploy, one process | Can't put Angular on a CDN |
| No CORS in production | Frontend and backend must deploy together |
| `httpOnly` cookies work simply | Need Node + .NET tooling on build agent |
| Familiar pattern in enterprise .NET shops | Hard to scale frontend independently |
| Less infrastructure to configure | Slower global delivery vs CDN |
