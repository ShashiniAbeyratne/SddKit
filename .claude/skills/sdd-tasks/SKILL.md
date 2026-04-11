---
name: sdd-tasks
description: Generate a dependency-ordered, sized task breakdown. Use when the user says "tasks", "break it down", or after /sdd-analyze passes.
group: sdlc
disable-model-invocation: true
---

Read before doing anything:
- `.sdd/memory/constitution.md`
- `.sdd/memory/project.md`
- `.sdd/specs/<current-feature>/spec.md`
- `.sdd/specs/<current-feature>/plan.md`
- `.sdd/specs/<current-feature>/analysis.md`
- `tasks-template.md` in this skill's directory

If `spec.md` or `plan.md` is missing, stop and say which to create first.
If `analysis.md` shows BLOCKING status, stop and say to resolve blocking issues first.

Also read `spec.md` for the **Complexity** field set by `/sdd-specify`:
- **Trivial** — should not reach sdd-tasks; redirect to `/sdd-implement` directly
- **Feature** — standard sequential task list
- **Epic** — group tasks into parallel sprints (see Step 1b)

## Step 1 — Generate tasks

Write `.sdd/specs/<current-feature>/tasks.md` using `tasks-template.md`.

**Ordering rules (strict):**
1. Database migrations and schema changes
2. Domain entities and value objects
3. Repository interfaces and implementations
4. Application services / command handlers / query handlers
5. API endpoints / controllers
6. Frontend components and pages
7. Integration / end-to-end tests

**For each task include:**
- `ID`: T001, T002, T003... (sequential, never reuse)
- `Story`: which user story this serves
- `Description`: what specifically to build
- `Files`: exact file paths to create or modify
- `Depends on`: comma-separated task IDs (empty if none)
- `Parallel`: [P] if can run concurrently with sibling tasks
- `Size`: S (< 1hr) / M (1–4hr) / L (4hr+)

**After each user story group**, add a checkpoint:
```
--- CHECKPOINT: Verify [story outcome] before continuing ---
```

## Step 1b — Epic: Sprint grouping (only if complexity = Epic)

If the spec is **Epic**, after generating all tasks, group them into sprints:

```markdown
## Sprint Plan

### Sprint 1 — Foundation (sequential, blocks all others)
| Task | Description | Size |
|---|---|---|
| T001 | DB schema + migrations | M |
| T002 | Domain entities | S |

### Sprint 2 — Parallel sprints (can run concurrently after Sprint 1)

#### Sprint 2A — Backend API
| Task | Description | Size |
|---|---|---|
| T003 | Repositories | M |
| T005 | Command handlers | M |
| T007 | API endpoints | M |

#### Sprint 2B — Frontend
| Task | Description | Size |
|---|---|---|
| T004 | API client types | S |
| T006 | Components | L |
| T008 | Pages + routing | M |

### Sprint 3 — Integration (sequential, after both Sprint 2 streams)
| Task | Description | Size |
|---|---|---|
| T009 | E2E tests | M |
| T010 | Security hardening | S |
```

**Locked API contracts**: Before Sprint 2 begins, list the API contracts that both 2A and 2B depend on (request/response shapes, event schemas). These must be agreed before parallel work starts.

```markdown
## Locked contracts for Sprint 2
- `POST /api/...` → `{ id: string, ... }`
- Event: `UserCreated` → `{ userId, email, timestamp }`
```

## Step 2 — Summary

After writing tasks.md, report:
- Total task count
- Size breakdown: X small, Y medium, Z large
- Critical path (the longest dependency chain)
- Any tasks that can be parallelised
- For epics: sprint count and locked contracts

## Step 3 — Wrap up
- Ask me to review and approve `tasks.md` before we proceed
- Do not write any implementation code
- After approval:
  - **Feature** → "Run `/sdd-implement` to start building."
  - **Epic** → "Run `/sdd-implement` — it will use parallel agents for Sprint 2 streams."
