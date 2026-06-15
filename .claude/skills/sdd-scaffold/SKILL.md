---
name: sdd-scaffold
description: Generate the project folder structure and placeholder files for an already-initialised project. Use when the user says "scaffold", "generate the layout", "create the folder structure", or "set up the project files". Requires project.md to exist — run /sdd-init first if it doesn't.
group: sdlc
disable-model-invocation: true
---

Read these files before doing anything:
- `.sdd/memory/project.md` — if missing, stop and tell the user to run `/sdd-init` first
- `.sdd/memory/constitution.md` — if it exists, extract any hosting/deployment constraints

Any additional notes from the user: $ARGUMENTS

---

## Step 1 — Check project.md is complete

Confirm `project.md` contains:
- Frontend choice (or None)
- Backend choice (or None)
- Deployment pattern

If any of these are missing, stop and tell the user which fields need filling before scaffolding can continue.

---

## Step 2 — Hosting providers

Check if `project.md` already has a `## Hosting` section. If it does, use those values and skip the questions.

If not, ask (only for the sides that are not None):

**Frontend hosting** (if frontend is NOT None):
```
1. Vercel
2. Netlify
3. Azure Static Web Apps
4. AWS S3 + CloudFront
5. GCP Cloud Storage + CDN
6. Skip — no deployment config needed yet
```

**API hosting** (if backend is NOT None):
```
1. Render
2. Railway
3. Azure App Service
4. Azure Container Apps
5. AWS ECS
6. AWS Lambda
7. GCP Cloud Run
8. GCP GKE
9. Skip — no deployment config needed yet
```

After getting answers, append a `## Hosting` section to `.sdd/memory/project.md`:
```markdown
## Hosting
- Frontend: [provider or Skip]
- API: [provider or Skip]
```

---

## Step 2.5 — Target framework (.NET only)

Skip this step entirely if the backend is None or non-.NET.

Check if `project.md` already has a `## Target Framework` section. If it does, use that value and skip to Step 3.

If not:
1. State what you know about the current .NET release landscape based on today's date. Example: "Based on today's date (June 2026), the current .NET releases are: **net10.0** (LTS, current recommended) | net9.0 (STS) | net8.0 (LTS)"
2. Ask the user: "Which .NET target framework should the scaffold use? Press Enter to accept the latest LTS, or type a specific TFM (e.g. `net9.0`, `net8.0`)."
3. If the user presses Enter or says "default" / "latest" / "LTS", use the latest stable LTS you identified.

After getting the answer, append to `.sdd/memory/project.md`:
```markdown
## Target Framework
- .NET: [chosen TFM, e.g. net10.0]
```

Pass `TargetFramework: [chosen TFM]` to the scaffold-generator in Step 4.

---

## Step 3 — Read architecture and hosting templates

Read the following from the local `templates/` folder based on the stack in `project.md`:

**Architecture templates:**
| Stack | File |
|---|---|
| React | `templates/react/architecture.md` |
| Angular | `templates/angular/architecture.md` |
| C# Monolith | `templates/csharp-monolith/architecture.md` |
| C# Microservice | `templates/csharp-microservice/architecture.md` |
| Clean Architecture service | `templates/csharp-microservice/clean-architecture-service.md` |
| Vertical Slice service | `templates/csharp-microservice/vertical-slice-service.md` |

**Deployment template:**
| Pattern | File |
|---|---|
| CDN + Separate API | `templates/deployment/cdn-separate-api.md` |
| .Host | `templates/deployment/host-project.md` |
| API-only | `templates/deployment/api-only.md` |

**Hosting templates** (skip if provider is "Skip"):
| Provider | File |
|---|---|
| Vercel | `templates/hosting/vercel.md` |
| Netlify | `templates/hosting/netlify.md` |
| Azure Static Web Apps | `templates/hosting/azure-static-web-apps.md` |
| AWS S3 + CloudFront | `templates/hosting/aws-s3-cloudfront.md` |
| GCP Cloud Storage + CDN | `templates/hosting/gcp-cloud-storage-cdn.md` |
| Azure App Service | `templates/hosting/azure-app-service.md` |
| Azure Container Apps | `templates/hosting/azure-container-apps.md` |
| AWS ECS | `templates/hosting/aws-ecs.md` |
| AWS Lambda | `templates/hosting/aws-lambda.md` |
| GCP Cloud Run | `templates/hosting/gcp-cloud-run.md` |
| GCP GKE | `templates/hosting/gcp-gke.md` |
| Railway | `templates/hosting/railway.md` |
| Render | `templates/hosting/render.md` |

Read all that apply. Do not skip any that match.

---

## Step 4 — Spawn scaffold-generator

Spawn the `scaffold-generator` agent (`.claude/agents/scaffold-generator.md`) and pass it **all of the following**:

- Frontend choice (from project.md)
- Backend choice (from project.md)
- Full service list with internal architecture per service (from project.md — microservice only)
- Database choice (from project.md)
- Auth choice (from project.md)
- Deployment pattern (from project.md)
- Frontend hosting provider (from Step 2)
- API hosting provider (from Step 2)
- **Target framework** (from Step 2.5 — e.g. `net10.0`) — omit if non-.NET
- Full content of every architecture template read in Step 3
- Full content of every hosting template read in Step 3
- Project name (from project.md)

Tell the agent: generate the actual folder structure and placeholder files. Do not generate real implementation code.

---

## Step 5 — Wrap up

After the scaffold-generator reports:
- Echo its tree view to the user
- Tell the user to commit: `git add . && git commit -m "chore: scaffold project structure"`
- Next step: `/sdd-specify <feature idea>` to start the first feature
