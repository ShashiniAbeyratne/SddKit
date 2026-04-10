---
name: sdd-tasks
description: Generate a dependency-ordered, sized task breakdown. Use when the user says "tasks", "break it down", or after /sdd-analyze passes.
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

## Step 2 — Summary

After writing tasks.md, report:
- Total task count
- Size breakdown: X small, Y medium, Z large
- Critical path (the longest dependency chain)
- Any tasks that can be parallelised

## Step 3 — Wrap up
- Ask me to review and approve `tasks.md` before we proceed
- Do not write any implementation code
- After approval, remind me to run `/sdd-implement`
