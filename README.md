# SDD-Kit

**Spec-Driven Development for Claude Code.** Stop vibe-coding. Start shipping reviewable, auditable software.

SDD-Kit is a suite of 17 Claude Code skills that enforce a structured SDLC: requirements first, planning second, code last. Every feature produces versioned artifacts in `.sdd/` that a human reviews and approves before the next phase starts. The agent never writes implementation code until `tasks.md` is signed off.

---

## Why

Claude Code can write code fast. That's the problem. Without guardrails:

- Features get built before requirements are understood
- Architecture decisions happen on the fly, inside a single prompt
- There's no record of what was agreed — or what changed
- Security and standards reviews are skipped under time pressure

SDD-Kit imposes the phases a senior engineer would enforce anyway: specify, clarify, plan, analyze, then implement. Each phase is a distinct skill. Each produces a file you can read, reject, and iterate on.

---

## How it works

Every feature follows one of four workflows based on complexity:

```
Trivial    specify → implement → standards → commit

Feature    specify → clarify → plan → analyze → tasks
                  → implement → standards → security → review → commit → push

Epic       specify → clarify → plan → analyze → test → tasks (sprint grouping)
                  → implement (parallel agent teams) → standards → security → review → commit → push

Bug        /sdd-fix (Report → Analyze → Fix → Verify) → commit
```

Complexity is declared in `spec.md`. The skills guide you to the right workflow automatically.

### Artifacts produced

Each phase writes a file into `.sdd/specs/<NNN>-<slug>/`:

| Phase | File | Contents |
|---|---|---|
| Specify | `spec.md` | User stories, acceptance criteria, out-of-scope |
| Clarify | `clarifications.md` | Resolved ambiguities, updated assumptions |
| Plan | `plan.md` | Architecture decisions, API contracts, data model |
| Plan | `research.md` | Version-specific findings from parallel research agent |
| Analyze | `analysis.md` | Contradictions and gaps between spec, plan, research |
| Test | `test-strategy.md` | Test plan and coverage targets (Epics only) |
| Tasks | `tasks.md` | Dependency-ordered tasks with sizing and sprint grouping |
| Standards | `standards-review.md` | Constitution compliance audit |
| Security | `security-review.md` | OWASP Top 10 findings |
| Review | `review.md` | AC coverage check and scope creep detection |

---

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- Git (for `/sdd-commit` and `/sdd-push`)
- [GitHub CLI](https://cli.github.com/) (`gh`) — only needed for `/sdd-push` to open PRs

---

## Getting started

### New project

Open Claude Code in the SDD-Kit directory and run:

```
/sdd-init
```

It will ask for your target project path, walk through stack selection, generate a constitution, scaffold the folder structure, and copy the SDLC skills into your project.

Then open your new project in Claude Code and start a feature:

```
/sdd-specify add user authentication
```

### Existing project (brownfield)

Audit the codebase first to generate a constitution draft, then install the workflow:

```
/sdd-audit
/sdd-install
```

Or manually copy `.claude/` and `templates/` into your project root and run `/sdd-constitution` to define your standards.

---

## Skills reference

### Initialisation

These skills live in SDD-Kit and are not copied into projects.

| Skill | What it does |
|---|---|
| `/sdd-init` | Stack wizard → scaffold → install skills into a new project |
| `/sdd-install` | Install the SDLC skill suite into an existing project |
| `/sdd-audit` | Analyse an existing codebase and generate `project.md` + constitution draft |
| `/sdd-constitution` | Define governing principles, coding standards, and hard constraints |

### Planning

| Skill | What it does |
|---|---|
| `/sdd-specify <idea>` | Write a spec with complexity tiering (Trivial / Feature / Epic) |
| `/sdd-clarify` | Fill in gaps and resolve ambiguities before planning |
| `/sdd-plan` | Create the implementation plan (spawns parallel research agent) |
| `/sdd-analyze` | Cross-check spec, plan, and research for contradictions |
| `/sdd-test` | Define test strategy before task breakdown (required for Epics) |
| `/sdd-tasks` | Break the plan into a dependency-ordered, sized task list |

### Development

| Skill | What it does |
|---|---|
| `/sdd-implement` | Execute tasks with checkpoints; parallel agent teams for Epics |
| `/sdd-fix` | Lightweight bug fix track: Report → Analyze → Fix → Verify |
| `/sdd-standards` | Check implementation against the constitution |
| `/sdd-security` | OWASP Top 10 security review of changed files |
| `/sdd-review` | Verify what was built matches what was specified |
| `/sdd-commit` | Generate a structured commit message and PR description |
| `/sdd-push` | Push branch and open a pull request (worktree-aware) |

---

## Supported stacks

### Frontend
- **React** — Vite + TypeScript + TailwindCSS + React Router + Zustand + TanStack Query
- **Angular** — Angular CLI + TypeScript + Angular Material + NgRx Signals

### Backend
- **C# Monolith** — Clean Architecture + MediatR + FluentValidation + EF Core
- **C# Microservice** — .NET Aspire + YARP + MassTransit + RabbitMQ, with per-service Clean Architecture or Vertical Slice
- **Node.js** — Express + TypeScript + Prisma + Zod

### Database
PostgreSQL · SQL Server · MongoDB · SQLite

### Auth
ASP.NET Core Identity · Duende IdentityServer · Auth0/Okta · JWT

### Deployment patterns

| Pattern | When to use |
|---|---|
| CDN + Separate API | FE and API deploy independently; CORS always on (industry standard) |
| .Host Project | Angular/React compiled into ASP.NET `wwwroot`, one deployment artifact |
| API Only | Backend only; includes OpenAPI/Scalar and versioning |

### Hosting providers

**Frontend:** Azure Static Web Apps · Vercel · Netlify · AWS S3 + CloudFront · GCP Cloud Storage + CDN

**Backend:** Azure App Service · Azure Container Apps · AWS ECS (Fargate) · AWS Lambda · GCP Cloud Run · GCP GKE · Railway · Render

---

## Project structure

```
.claude/
├── skills/
│   ├── sdd-init/             group: init  (not copied to projects)
│   ├── sdd-install/          group: init
│   ├── sdd-audit/            group: init
│   ├── sdd-constitution/     group: init
│   ├── sdd-specify/          group: sdlc  (copied into every project)
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
├── hosting/                  CI/CD configs for 12 providers
└── constitutions/            Base coding standards per stack

.sdd/                         Generated per project
├── memory/
│   ├── constitution.md       Project standards and non-negotiables
│   └── project.md            Tech stack summary
└── specs/
    └── 001-feature-name/
        ├── spec.md
        ├── clarifications.md
        ├── plan.md
        ├── research.md
        ├── analysis.md
        ├── test-strategy.md
        ├── tasks.md
        ├── standards-review.md
        ├── security-review.md
        └── review.md
```

---

## How it compares

| | SDD-Kit | spec-kit | AWS Kiro |
|---|---|---|---|
| Delivered as | Claude Code skills | slash commands | Built-in |
| Subagents (parallel research + analysis) | Yes | No | Yes |
| Architecture templates per stack | Yes | No | No |
| Constitutions per stack | Yes | No | No |
| Drift review (spec vs. code) | Yes | No | Yes |
| Brownfield onboarding | Yes | No | No |
| Bug fix track | Yes | No | No |
| Cost | Free | Free | $20–200/mo |
| IDE lock-in | None | None | VS Code fork |

---

## Inspired by

- [github/spec-kit](https://github.com/github/spec-kit)
- [jasontaylordev/CleanArchitecture](https://github.com/jasontaylordev/CleanArchitecture)
- [dotnet/eShop](https://github.com/dotnet/eShop)
- [dotnet/aspire](https://github.com/dotnet/aspire)
