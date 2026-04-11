---
name: sdd-init
description: Initialise a new project by selecting tech stack and generating a best-practice folder structure. Use when the user says "init", "scaffold", "new project", or "set up the project".
group: init
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

**Frontend hosting** (ask if frontend is NOT None):
```
1. Vercel          — best DX, instant previews, great for React/Next.js
2. Netlify         — similar to Vercel, strong form/function support
3. Azure Static Web Apps — best if API is on Azure; free tier, built-in auth proxy
4. AWS S3 + CloudFront   — most control, cheapest at scale, needs more config
5. GCP Cloud Storage + Cloud CDN — good if rest of stack is on GCP
```

**API / Backend hosting** (ask if backend is NOT None):
```
1. Azure App Service   — PaaS, easy deploy, best with Azure DB/identity
2. Azure Container Apps — container-based, auto-scale, good for microservices
3. AWS ECS (Fargate)   — container PaaS on AWS, pairs well with RDS/Aurora
4. AWS Lambda          — serverless, great for low-traffic or event-driven APIs
5. GCP Cloud Run       — serverless containers on GCP, pay-per-request
6. GCP GKE             — Kubernetes on GCP, for teams already running k8s
7. Railway             — simplest deploy experience, good for small/indie projects
8. Render              — Heroku alternative, easy Docker or native deploys
```

Skip the frontend hosting question if frontend is None.
Skip the API hosting question if backend is None.
For the .Host pattern, ask only the API hosting question (it hosts both).

## Step 2 — Read templates and spawn scaffold agent

Read the relevant architecture template files from `templates/` in the project root:
- Frontend choice → `templates/react/architecture.md` or `templates/angular/architecture.md`
- Backend choice → `templates/csharp-monolith/architecture.md` or `templates/csharp-microservice/architecture.md`
- If microservice, also read `templates/csharp-microservice/clean-architecture-service.md` and/or `templates/csharp-microservice/vertical-slice-service.md` based on per-service choices
- Deployment pattern → `templates/deployment/cdn-separate-api.md`, `templates/deployment/host-project.md`, or `templates/deployment/api-only.md`
- Frontend hosting provider → `templates/hosting/vercel.md`, `templates/hosting/netlify.md`, `templates/hosting/azure-static-web-apps.md`, `templates/hosting/aws-s3-cloudfront.md`, or `templates/hosting/gcp-cloud-storage-cdn.md`
- API hosting provider → `templates/hosting/azure-app-service.md`, `templates/hosting/azure-container-apps.md`, `templates/hosting/aws-ecs.md`, `templates/hosting/aws-lambda.md`, `templates/hosting/gcp-cloud-run.md`, `templates/hosting/gcp-gke.md`, `templates/hosting/railway.md`, or `templates/hosting/render.md`

Skip hosting templates that don't apply (e.g. no frontend hosting template if frontend is None; for .Host pattern only read the API hosting template).

Spawn the `scaffold-generator` agent (`.claude/agents/scaffold-generator.md`) with:
- All stack choices made (frontend, backend, database, auth, deployment pattern)
- Frontend hosting provider choice and content of the relevant frontend hosting template
- API hosting provider choice and content of the relevant API hosting template
- Content of relevant architecture template files
- Instruction to generate the folder structure and all hosting-specific files

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
[choice + brief description, e.g. "CDN + Separate API"]

## Hosting
- Frontend: [provider, e.g. Vercel / Azure Static Web Apps / Netlify]
- API: [provider, e.g. Azure App Service / AWS ECS / GCP Cloud Run]

## Architecture reference
[links to template files used]

## Initialised
[date]
```

## Step 4 — Run /sdd-constitution

Before installing, the project needs a constitution — this is what gets copied into the new project and governs all future implementation, standards checks, and security reviews.

Tell the user:
> "Before we install the workflow into your new project, let's set the constitution — the coding standards and principles that will govern this project. I'll ask you 5 questions."

Run the full `/sdd-constitution` skill now, in the context of the new project's stack.
The constitution will be written to `.sdd/memory/constitution.md` here in SDD-Kit — it will be copied into the new project in the next step.

## Step 5 — Install SDD-Kit skill suite

Spawn the `project-installer` agent (`.claude/agents/project-installer.md`) with:
- `target_path`: the project directory being initialised (current working directory or the path provided in $ARGUMENTS)
- `sddkit_path`: the directory where SDD-Kit lives (the parent of this `.claude/` folder)
- `stack`: the full stack choices made in Step 1
- `constitution_path`: `.sdd/memory/constitution.md` (the file written in Step 4)

This copies all skills, agents, relevant templates, **and the completed constitution** into the new project's `.claude/` and `.sdd/` so the project is fully self-contained from day one.

## Step 6 — Update CLAUDE.md

Update the `## Tech stack` section of `CLAUDE.md` in the target project with a one-line summary of the chosen stack.

After all steps:
- Report what was scaffolded, what skills were installed, and confirm the constitution was copied
- Remind me to commit: `git add . && git commit -m "chore: initialise project scaffold + install SDD-Kit workflow"`
- Tell me the project is ready: next step is `/sdd-specify` to start the first feature
