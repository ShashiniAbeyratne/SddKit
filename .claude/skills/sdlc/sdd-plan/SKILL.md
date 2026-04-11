---
name: sdd-plan
description: Create a technical implementation plan for the current feature. Use when the user says "plan", "how do we build this", or after /sdd-clarify.
disable-model-invocation: true
---

Read these files before doing anything:
- `.sdd/memory/constitution.md`
- `.sdd/memory/project.md` — for the selected tech stack and architecture
- `.sdd/specs/<current-feature>/spec.md` — if missing, stop and say to run `/sdd-specify` first
- `.sdd/specs/<current-feature>/clarifications.md` — if it exists
- `plan-template.md` in this skill's directory
- The relevant architecture template from `templates/` based on the project stack in `project.md`

Any additional notes or constraints from the user: $ARGUMENTS

## Step 1 — Spawn research subagent (parallel)

Spawn the `tech-researcher` agent (`.claude/agents/tech-researcher.md`) with:
- The project tech stack from `project.md`
- Key libraries relevant to this feature
- Any version-sensitive or integration-heavy areas from the spec
- Instruction to write findings to `.sdd/specs/<current-feature>/research.md`

## Step 2 — Write plan (while research runs)

Write `.sdd/specs/<current-feature>/plan.md` using `plan-template.md` structure:

- Architecture decisions with rationale (reference constitution principles)
- Component breakdown with responsibilities
- Data model — entities, relationships, key fields, migrations needed
- API contracts or interface definitions (request/response shapes, HTTP verbs, routes)
- Sequence diagrams in plain text for any non-trivial flows
- Integration points with existing system (based on `project.md` scaffold)
- Non-functional considerations: error handling, logging, caching, auth checks

## Step 3 — Review research

Once the research subagent completes, read `research.md`.
- Flag any conflicts between the research findings and your plan
- Update plan.md if research reveals a better approach or a gotcha

## Step 4 — Update changelog

Append to `.sdd/specs/<current-feature>/changelog.md` (create if it doesn't exist):

```markdown
## [plan] <date>
**Key decisions:**
- [Architecture choice + one-line rationale]
- [Data model decision + why]
- [Any spec assumption that was resolved during planning]
**Research findings that changed the plan:** [brief note, or "none"]
```

## Step 5 — Wrap up
- Present a summary of key decisions made
- Ask me to review `plan.md` and `research.md`
- Do not create `tasks.md` yet — wait for my approval
- Remind me to run `/sdd-analyze` then (if epic) `/sdd-test`, then `/sdd-tasks`
