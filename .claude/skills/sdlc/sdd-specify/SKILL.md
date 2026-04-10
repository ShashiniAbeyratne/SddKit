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

## Step 2 — Clarifying questions
Ask up to 5 clarifying questions — only questions where the answer materially changes **scope or user flows**.
- No tech questions (those are for /sdd-plan)
- No UI detail questions unless UI is the core of the feature
- Wait for all answers before proceeding

## Step 3 — Determine feature number
Check `.sdd/specs/` for existing directories. Count them. Next number = existing count + 1, zero-padded to 3 digits (e.g. `003`).

## Step 4 — Write spec
Write `.sdd/specs/<NNN>-<feature-slug>/spec.md` using the structure in `spec-template.md`.

The spec must contain:
- Feature name and one-line summary
- User stories: `As a <user>, I want <action>, so that <value>`
- Acceptance criteria per story — testable, specific, technology-agnostic
- Out of scope — explicit list, not "TBD"
- Assumptions and dependencies
- Open questions — only if genuinely unresolved after clarification

**Do NOT include:** tech stack, implementation details, architecture, library names.

## Step 5 — Quality check
Self-evaluate against `quality-checklist.md`. Report the result. Flag any items that fail.

## Step 6 — Wrap up
- Suggest a branch name: `<NNN>-<feature-slug>`
- Ask if I want to create and checkout the branch
- Remind me to run `/sdd-clarify` if open questions remain, or `/sdd-plan` if we're ready
