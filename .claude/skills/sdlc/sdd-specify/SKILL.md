---
name: sdd-specify
description: Capture what to build as a structured specification. Use when the user describes a feature, says "specify", "new feature", "I want to build", or provides a feature idea.
disable-model-invocation: true
---

Read these files before doing anything:
- `.sdd/memory/constitution.md` — if missing, stop and say to run `/sdd-constitution` first
- `.sdd/memory/project.md` — for tech stack context
- `spec-template.md` in this skill's directory
- `quality-checklist.md` in this skill's directory

The user's feature description is: $ARGUMENTS

## Step 1 — Confirm understanding
Restate the feature back in one sentence. Ask if that's correct before continuing.

## Step 2 — Classify complexity

Ask: **"How would you size this? Pick one:"**

```
1. Fix     — a bug or defect (→ use /sdd-fix instead)
2. Trivial — a small change, single file, obvious implementation (< 2h)
3. Feature — standard new capability with user stories and AC (default)
4. Epic    — cross-cutting, multiple subsystems, requires parallel work
```

Based on the answer, adjust the workflow:

| Complexity | Phases that apply |
|---|---|
| Fix | Stop — redirect to `/sdd-fix` |
| Trivial | spec only → implement → commit (skip clarify/plan/analyze/tasks) |
| Feature | Full workflow (default) |
| Epic | Full workflow + `/sdd-test` required + parallel task agents in `/sdd-tasks` |

Record complexity in the spec header. Skip inapplicable phases automatically when prompting next steps in Step 6.

## Step 3 — Clarifying questions
Ask up to 5 clarifying questions — only questions where the answer materially changes **scope or user flows**.
- No tech questions (those are for /sdd-plan)
- No UI detail questions unless UI is the core of the feature
- Skip this step entirely for Trivial complexity
- Wait for all answers before proceeding

## Step 4 — Determine feature number
Check `.sdd/specs/` for existing directories. Count them. Next number = existing count + 1, zero-padded to 3 digits (e.g. `003`).

## Step 5 — Write spec
Write `.sdd/specs/<NNN>-<feature-slug>/spec.md` using the structure in `spec-template.md`.

The spec must contain:
- Feature name and one-line summary
- **Complexity: [Trivial / Feature / Epic]**
- User stories: `As a <user>, I want <action>, so that <value>`
- Acceptance criteria per story — testable, specific, technology-agnostic
- Out of scope — explicit list, not "TBD"
- Assumptions and dependencies
- Open questions — only if genuinely unresolved after clarification

**Do NOT include:** tech stack, implementation details, architecture, library names.

## Step 6 — Quality check
Self-evaluate against `quality-checklist.md`. Report the result. Flag any items that fail.
Skip quality check for Trivial complexity.

## Step 7 — Wrap up
- Suggest a branch name: `<NNN>-<feature-slug>`
- Ask if I want to create and checkout the branch

Based on complexity, tell me the next step:
- **Trivial** → "Run `/sdd-implement` directly — no planning needed."
- **Feature** → "Run `/sdd-clarify` if open questions remain, otherwise `/sdd-plan`."
- **Epic** → "Run `/sdd-clarify`, then `/sdd-plan`, then `/sdd-test` before tasks — this is an epic."
