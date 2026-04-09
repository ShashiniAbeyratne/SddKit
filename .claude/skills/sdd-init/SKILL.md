---
name: sdd-init
description: Initialise a new project by selecting tech stack and generating a best-practice folder structure. Use when the user says "init", "scaffold", "new project", or "set up the project".
disable-model-invocation: true
---

Read `stack-options.md` in this skill's directory.
Read `.sdd/memory/constitution.md` if it exists.
Read `.sdd/memory/project.md` if it already exists — if so, ask if we're updating or starting fresh.

## Step 1 — Gather stack choices

Ask me the following, presenting numbered options each time. Wait for each answer.

**Frontend:**
```
0. None (API-only / backend project)
1. React — Vite + TypeScript + TailwindCSS + React Router + Zustand
2. Angular — Angular CLI + TypeScript + Angular Material + NgRx
```

**Backend:**
```
0. None (frontend-only / static site)
1. C# Monolith — Clean Architecture (jasontaylordev pattern)
2. C# Microservice — Multi-service with API Gateway
3. Node.js — Express + TypeScript
```

**If C# Microservice selected**, ask:
```
Which services do you need? List them (e.g. "UserService, OrderService, NotificationService")
For each service, choose internal architecture:
  A. Clean Architecture — complex business logic, rich domain model
  B. Vertical Slice — CRUD-heavy or simple event-driven
  C. Hybrid — Clean Architecture layers + Vertical Slice feature organisation
```

**Database:**
```
0. None
1. PostgreSQL (with EF Core for .NET, or Prisma for Node)
2. SQL Server (with EF Core)
3. MongoDB (with MongoDB.Driver or Mongoose)
4. SQLite (dev/testing only)
5. Multiple — specify per service
```

**Auth:**
```
0. None
1. ASP.NET Core Identity (built-in)
2. Duende IdentityServer (OAuth2/OIDC)
3. Auth0 / Okta (external provider)
4. JWT only (stateless)
```

**Deployment pattern** (only ask if both a frontend AND backend were selected):
```
1. CDN + Separate API (industry standard)
      You are building BOTH the frontend and the API in this project.
      They deploy to different places — FE to a CDN, API to a server.
      FE → Azure Static Web Apps / Vercel / Netlify
      API → Azure App Service / ECS
      CORS always on. Independent pipelines. Best for new projects.

2. .Host project (Microsoft SPA pattern)
      You are building BOTH the frontend and the API in this project.
      They deploy together as one artifact — FE is compiled into the API host.
      FE lives in ClientApp/ inside the .Host project.
      ng build → wwwroot → served by ASP.NET in production.
      CORS only in dev. One pipeline, one artifact. Common in enterprise .NET shops.
```

If frontend is None → no deployment question needed. The API is standalone.
      Auto-add: OpenAPI/Scalar docs, versioning, CORS config for external clients.
If backend is None → no deployment question. Note to deploy dist/ to a CDN.

## Step 2 — Read templates and spawn scaffold agent

Read the relevant architecture template files from `templates/` in the project root:
- Frontend choice → `templates/react/architecture.md` or `templates/angular/architecture.md`
- Backend choice → `templates/csharp-monolith/architecture.md` or `templates/csharp-microservice/architecture.md`
- If microservice, also read `templates/csharp-microservice/clean-architecture-service.md` and/or `templates/csharp-microservice/vertical-slice-service.md` based on per-service choices
- Deployment pattern → `templates/deployment/cdn-separate-api.md`, `templates/deployment/host-project.md`, or `templates/deployment/api-only.md`

Spawn the `scaffold-generator` agent (`.claude/agents/scaffold-generator.md`) with:
- All stack choices made
- Content of relevant architecture template files
- Instruction to generate the folder structure

## Step 3 — Write project memory

Write `.sdd/memory/project.md` with:
```markdown
# Project Stack

## Frontend
[choice + key libraries]

## Backend
[choice + pattern]

## Services (if microservice)
| Service | Internal Architecture | Reason |
|---|---|---|
| ... | ... | ... |

## Database
[choice + ORM/driver]

## Auth
[choice]

## Deployment pattern
[choice + brief description, e.g. "CDN + Separate API — FE on Azure Static Web Apps, API on App Service"]

## Architecture reference
[links to template files used]

## Initialised
[date]
```

## Step 4 — Update CLAUDE.md

Update the `## Tech stack` section of `CLAUDE.md` with a one-line summary of the chosen stack.

After all steps:
- Report what was scaffolded
- Remind me to run `/sdd-constitution` if not done yet
- Remind me to commit the scaffold: `git add . && git commit -m "chore: initialise project scaffold"`
