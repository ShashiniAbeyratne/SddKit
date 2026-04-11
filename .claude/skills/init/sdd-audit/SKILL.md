---
name: sdd-audit
description: Brownfield bootstrap — analyse an existing codebase and generate project.md and a constitution draft. Use when the user says "audit this project", "I have an existing project", "add SDD to existing code", or after /sdd-install on a brownfield project.
disable-model-invocation: true
---

Use this skill to onboard an **existing project** into the SDD workflow. The goal is to understand what is already built and encode that understanding into `.sdd/memory/` so future `/sdd-specify` runs have full context.

## Step 1 — Orient

Read the following (skip gracefully if absent):
- `README.md` / `README.*.md`
- `CLAUDE.md`
- `package.json` / `*.csproj` / `*.sln` / `pyproject.toml` / `go.mod` (root level only)
- `.sdd/memory/project.md` (if already exists — ask if updating or starting fresh)

Use Glob to list the top-level folder structure. Do NOT recursively read every file — just orient from the root.

Ask the user: **"What is this project? One sentence on what it does and who uses it."**

## Step 2 — Detect stack

From the files read in Step 1, detect:

| Dimension | Evidence to look for |
|---|---|
| Frontend | `package.json` deps: react, angular, vue, svelte |
| Backend | `.csproj`, `express`, `fastapi`, `gin`, `rails` |
| Database | `prisma`, `ef core`, `mongoose`, `sequelize`, migrations folder |
| Auth | Identity, JWT, Auth0, Passport, Devise |
| Deployment | `Dockerfile`, `*.yml` CI, Azure/AWS config, `vercel.json` |
| Test framework | `jest`, `xunit`, `pytest`, `vitest`, `playwright` |

Present your detection summary to the user and ask them to confirm or correct it.

## Step 3 — Explore architecture

Based on the detected stack, read a representative sample of source files:

- For **C# projects**: read `src/` folder structure, one file per layer (Domain entity, Application command, Infrastructure repo, API controller)
- For **React/Angular**: read `src/` folder structure, one component, one store/service, one API call
- For **Node**: read entry point, one route handler, one service, one model

Use Glob to find:
```
src/**/*.ts   (or *.cs, *.py, *.go)
```

Read up to **10 files** — enough to understand patterns, not everything.

Produce an architecture summary (internal, not written yet):
- Folder structure pattern
- Naming conventions (PascalCase, camelCase, kebab-case)
- State management approach
- API style (REST, GraphQL, gRPC)
- Any obvious patterns (CQRS, repository, service layer)
- Anything that looks non-standard or worth flagging

## Step 4 — Write project.md

Write `.sdd/memory/project.md`:

```markdown
# Project Stack

## What it does
[one sentence from user in Step 1]

## Frontend
[detected framework + key libraries]

## Backend
[detected framework + pattern]

## Database
[detected DB + ORM/driver]

## Auth
[detected auth approach]

## Deployment
[detected: Docker / Azure / Vercel / etc.]

## Test framework
[detected: Jest / xUnit / Pytest / etc.]

## Architecture notes
[key patterns observed: folder structure, naming, CQRS/repository/etc.]

## Conventions observed
[naming style, file organisation, any project-specific patterns]

## Known tech debt / anomalies
[anything that looked non-standard or inconsistent]

## Audited
[date]
```

## Step 5 — Draft constitution

Tell the user:
> "Now I'll draft a constitution for this project based on what I found. You can refine it — this is just a starting point from the existing code."

Write `.sdd/memory/constitution.md` with the standard constitution template (from `templates/constitutions/<stack>.md` if available), but **override defaults** with what was actually observed:

- If the project uses tabs → set indentation to tabs
- If the project has no tests → flag it as a gap, don't pretend tests exist
- If naming is inconsistent → note it and set a preferred convention going forward
- If there are security concerns already visible (hardcoded secrets, SQL concat) → list them in `## Known violations`

Constitution sections to include:
```markdown
# Project Constitution

## Stack baseline
[Imported from templates/constitutions/<stack>.md if applicable]

## Observed conventions (from audit)
[Naming, folder structure, patterns — sourced from actual code]

## Standards going forward
[What new code must follow — may differ from legacy code]

## Known violations in existing code
[Flagged issues that pre-date SDD adoption — fix opportunistically, not urgently]

## Hard constraints
[Non-negotiables: security rules, API contracts, breaking change policy]

## Test strategy
[What exists, what is expected for new features]

## Audited from
[date + files sampled]
```

## Step 6 — Gap report

After writing both files, produce a short gap report:

```
## Audit complete

✅ project.md written
✅ constitution.md drafted (from observed patterns)

### Gaps found
| Gap | Severity | Recommendation |
|---|---|---|
| No tests detected | High | Add /sdd-test strategy before next feature |
| Hardcoded DB string in config.ts:42 | Critical | Move to env vars before next deploy |
| Mixed naming conventions | Medium | Standardise in new code only |

### Next steps
1. Review and edit .sdd/memory/constitution.md — adjust anything that doesn't match your intent
2. Run /sdd-constitution if you want to answer the 5 standard questions on top of this draft
3. Run /sdd-specify <feature> to start your first spec-driven feature
```
