# Stack Options Reference

This file is read by /sdd-init to understand supported combinations and their constraints.

## Supported Frontend Stacks

### React (Option 1)
- **Tooling:** Vite + TypeScript
- **Styling:** TailwindCSS
- **Routing:** React Router v6
- **State:** Zustand (lightweight) or TanStack Query (server state)
- **Forms:** React Hook Form + Zod
- **Testing:** Vitest + React Testing Library
- **Template:** `templates/react/architecture.md`

### Angular (Option 2)
- **Tooling:** Angular CLI + TypeScript
- **Styling:** Angular Material + SCSS
- **State:** NgRx (signals or store)
- **Forms:** Reactive Forms
- **Testing:** Jest + Angular Testing Library
- **Template:** `templates/angular/architecture.md`

---

## Supported Backend Stacks

### C# Monolith — Clean Architecture (Option 1)
- **Pattern:** jasontaylordev/CleanArchitecture
- **Layers:** Domain → Application → Infrastructure → Web API
- **CQRS:** MediatR
- **Validation:** FluentValidation
- **ORM:** Entity Framework Core
- **Testing:** xUnit + FluentAssertions + NSubstitute
- **Template:** `templates/csharp-monolith/architecture.md`

### C# Microservice (Option 2)
- **Gateway:** YARP or Ocelot
- **Orchestration:** .NET Aspire (app-host)
- **Messaging:** MassTransit + RabbitMQ (async events)
- **Service discovery:** .NET Aspire service defaults
- **Per-service options:** Clean Architecture / Vertical Slice / Hybrid
- **Template:** `templates/csharp-microservice/architecture.md`

### Node.js (Option 3)
- **Framework:** Express + TypeScript
- **Validation:** Zod
- **ORM:** Prisma
- **Testing:** Vitest or Jest

---

## Supported Databases

| Option | Stack | ORM/Driver |
|---|---|---|
| PostgreSQL | .NET or Node | EF Core (Npgsql) or Prisma |
| SQL Server | .NET | EF Core (SqlServer) |
| MongoDB | .NET or Node | MongoDB.Driver or Mongoose |
| SQLite | Any | EF Core (dev only) |

---

## Supported Auth Options

| Option | Best For |
|---|---|
| ASP.NET Core Identity | Simple user management, no SSO needed |
| Duende IdentityServer | Full OAuth2/OIDC, multiple clients |
| Auth0 / Okta | Managed auth, fastest path to production |
| JWT only | Stateless APIs, mobile clients |

---

---

## Supported Deployment Patterns

### Option 1 — CDN + Separate API (Industry Standard)
- **Frontend deployed to:** Azure Static Web Apps / Vercel / Netlify / S3 + CloudFront
- **Backend deployed to:** Azure App Service / AWS ECS / Kubernetes
- **CORS:** Always on (dev and prod)
- **Pipelines:** Two independent pipelines — FE and BE deploy separately
- **Repo structure:** Monorepo with `client/` + `src/` folders, or two separate repos
- **Best for:** New projects, teams deploying independently, public-facing apps
- **Template:** `templates/deployment/cdn-separate-api.md`

### Option 2 — .Host Project (Microsoft SPA Pattern)
- **Frontend deployed as:** Static files inside `[Project].Host/wwwroot/` (output of `ng build`)
- **Backend deployed to:** IIS / Azure App Service (one process serves both)
- **CORS:** Dev only — production is same-origin
- **Pipelines:** One pipeline — build Angular first, then publish .NET
- **Repo structure:** `ClientApp/` folder inside the `.Host` project
- **Best for:** Enterprise .NET shops, single team, internal tools, existing projects using this pattern
- **Template:** `templates/deployment/host-project.md`

### Option 3 — API Only (No Frontend in This Repo)
- **Frontend:** Not included — separate repo or external team
- **Backend deployed to:** Azure App Service / ECS / AKS
- **CORS:** Always on, configured per allowed client origin
- **Extra:** OpenAPI / Scalar docs, API versioning scaffolded automatically
- **Best for:** APIs consumed by multiple clients, public APIs, backend-only projects
- **Template:** `templates/deployment/api-only.md`

---

## Compatibility Notes

- Duende IdentityServer → recommend separate `Identity` microservice if using microservice pattern
- React + C# API → enable CORS in API, use Vite proxy in dev (CDN pattern) or Angular proxy via `proxy.conf.js` (.Host pattern)
- Angular + C# API → same CORS setup; `.Host` pattern uses `proxy.conf.js` to avoid CORS in dev
- Multiple databases per service → valid in microservice pattern, document in project.md
- `.Host` pattern + Duende IdentityServer → IdentityServer must be a separate process; can't share the same host cleanly
- CDN pattern + cookie auth → frontend and API must share a parent domain (e.g. `app.co.com` + `api.co.com`) for `httpOnly` cookies to work cross-origin
