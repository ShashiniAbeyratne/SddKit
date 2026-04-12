# SDD-Kit

A spec-driven development workflow for Claude Code. Replaces vibe coding with a structured, reviewable process — requirements first, code last.

---

## What it is

SDD-Kit gives you a set of Claude Code skills that enforce a planning phase before any implementation happens. Every feature goes through the same sequence:

```
init → audit? → constitution → specify → clarify → plan → analyze → test? → tasks → implement → standards → security → review → commit → push
```

Complexity-aware: **Trivial** skips straight to implement. **Epic** adds test strategy and spawns parallel agent teams. Bugs use `/sdd-fix` — a dedicated lightweight track.

Each phase produces a versioned artifact in `.sdd/`. You review and approve before the next phase starts. The agent never writes implementation code until `tasks.md` is approved.

---

## Skills

### Initialisation (stay in SDD-Kit, not copied to projects)

| Skill | What it does |
|---|---|
| `/sdd-init` | Select your tech stack, scaffold the project, and install the skill suite |
| `/sdd-install` | Install SDD-Kit into an existing project |
| `/sdd-audit` | **Brownfield** — analyse existing codebase, generate project.md + constitution draft |
| `/sdd-constitution` | Set the governing principles, coding standards, and hard constraints |

### Planning

| Skill | What it does |
|---|---|
| `/sdd-specify <idea>` | Write a spec with complexity tiering (Trivial / Feature / Epic) |
| `/sdd-clarify` | Fill in gaps and resolve ambiguities before planning |
| `/sdd-plan` | Create the technical implementation plan (spawns parallel research agent) |
| `/sdd-analyze` | Cross-check spec, plan, and research for contradictions |
| `/sdd-test` | Define the test strategy before task breakdown (required for Epics) |
| `/sdd-tasks` | Break the plan into a dependency-ordered task list (sprint grouping for Epics) |

### Development

| Skill | What it does |
|---|---|
| `/sdd-implement` | Execute tasks with checkpoints; parallel agent teams for Epics |
| `/sdd-fix` | **Bug fix track** — Report → Analyze → Fix → Verify (lighter than full workflow) |
| `/sdd-standards` | Check implementation against coding standards in the constitution |
| `/sdd-security` | OWASP Top 10 security review of changed files |
| `/sdd-review` | Verify what was built matches what was specified |
| `/sdd-commit` | Generate a structured commit message and PR description |
| `/sdd-push` | Push branch, worktree-aware, open a pull request |

---

## Supported stacks

### Frontend
- **React** — Vite + TypeScript + TailwindCSS + React Router + Zustand + TanStack Query
- **Angular** — Angular CLI + TypeScript + Angular Material + NgRx Signals

### Backend
- **C# Monolith** — Clean Architecture (jasontaylordev pattern) + MediatR + FluentValidation + EF Core
- **C# Microservice** — .NET Aspire + YARP + MassTransit + RabbitMQ, with per-service Clean Architecture or Vertical Slice
- **Node.js** — Express + TypeScript + Prisma + Zod

### Database
PostgreSQL · SQL Server · MongoDB · SQLite

### Auth
ASP.NET Core Identity · Duende IdentityServer · Auth0/Okta · JWT

### Deployment patterns
- **CDN + Separate API** — FE and API deploy independently; CORS always on (industry standard)
- **.Host Project** — Angular/React compiled into ASP.NET wwwroot, one artifact (enterprise .NET pattern)
- **API Only** — No frontend in this repo; includes OpenAPI/Scalar and versioning

### Frontend hosting
Azure Static Web Apps · Vercel · Netlify · AWS S3 + CloudFront · GCP Cloud Storage + CDN

### API / Backend hosting
Azure App Service · Azure Container Apps · AWS ECS (Fargate) · AWS Lambda · GCP Cloud Run · GCP GKE · Railway · Render

---

## Getting started

### On a new project

Open Claude Code in the SDD-Kit directory and run:

```
/sdd-init
```

It will ask for the target project path, walk you through stack selection, generate a constitution, scaffold the folder structure, and install the full skill suite into your project automatically.

Then open the new project in Claude Code and start your first feature:

```
/sdd-specify <your feature idea>
```

### On an existing project

Run `/sdd-audit` first to analyse the codebase and generate a constitution draft, then install the workflow:

```
/sdd-audit
/sdd-install
```

Or just copy `.claude/` and `templates/` into your project root manually and run `/sdd-constitution` to set the governing principles.

---

## Project structure

```
.claude/
├── skills/
│   ├── sdd-init/             group: init  — not copied to projects
│   ├── sdd-install/          group: init
│   ├── sdd-audit/            group: init
│   ├── sdd-constitution/     group: init
│   ├── sdd-specify/          group: sdlc  — copied into every new project
│   ├── sdd-clarify/          group: sdlc
│   ├── sdd-plan/             group: sdlc
│   ├── sdd-analyze/          group: sdlc
│   ├── sdd-test/             group: sdlc
│   ├── sdd-tasks/            group: sdlc
│   ├── sdd-implement/        group: sdlc
│   ├── sdd-fix/              group: sdlc
│   ├── sdd-standards/        group: sdlc
│   ├── sdd-security/         group: sdlc
│   ├── sdd-review/           group: sdlc
│   ├── sdd-commit/           group: sdlc
│   └── sdd-push/             group: sdlc
└── agents/
    ├── tech-researcher.md    spawned by /sdd-plan
    ├── spec-analyst.md       spawned by /sdd-analyze, /sdd-review, /sdd-standards, /sdd-security
    ├── scaffold-generator.md spawned by /sdd-init
    └── project-installer.md  spawned by /sdd-init and /sdd-install

templates/
├── react/                    React architecture reference
├── angular/                  Angular architecture reference
├── csharp-monolith/          Clean Architecture reference
├── csharp-microservice/      Microservice + per-service patterns
├── deployment/               CDN, .Host, and API-only patterns
└── constitutions/            Base coding standards per stack

init-ui/
└── index.html                Legacy browser stack wizard (superseded by /sdd-init)

.sdd/                         Generated per project (gitignored or committed)
├── memory/
│   ├── constitution.md
│   └── project.md
└── specs/
    └── 001-feature-name/
        ├── spec.md
        ├── clarifications.md
        ├── plan.md
        ├── research.md
        ├── analysis.md
        ├── tasks.md
        └── review.md
```

---

## How it compares

| | SDD-Kit | spec-kit | AWS Kiro |
|---|---|---|---|
| Skills/commands | ✅ Claude Code skills | ✅ slash commands | ✅ built-in |
| Subagents | ✅ parallel research + analysis | ❌ | ✅ |
| Base architecture templates | ✅ per stack | ❌ | ❌ |
| Base constitutions per stack | ✅ | ❌ | ❌ |
| Drift review (spec vs code) | ✅ /sdd-review | ❌ | ✅ |
| Init UI | ✅ browser wizard | ❌ | ✅ IDE |
| Cost | Free | Free | $20–200/mo |
| IDE lock-in | None | None | VS Code fork |

---

## Inspired by

- [github/spec-kit](https://github.com/github/spec-kit)
- [jasontaylordev/CleanArchitecture](https://github.com/jasontaylordev/CleanArchitecture)
- [dotnet/eShop](https://github.com/dotnet/eShop)
- [dotnet/aspire](https://github.com/dotnet/aspire)
