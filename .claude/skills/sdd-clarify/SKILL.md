---
name: sdd-clarify
description: Structured gap-filling for the current spec before planning. Use when the user says "clarify", "fill the gaps", or after /sdd-specify when open questions remain.
disable-model-invocation: true
---

Read the current feature spec:
- Determine the current feature by checking `.sdd/specs/` for the most recently modified directory, or ask me which feature if ambiguous
- Read `.sdd/specs/<current-feature>/spec.md`
- If it doesn't exist, stop and say to run `/sdd-specify` first

## Step 1 — Identify gaps

Review the spec for:
- Acceptance criteria that have multiple valid implementations with meaningfully different scope implications
- User flows that don't have a defined end state
- Missing error states or validation edge cases
- Assumptions that could be wrong and would change the spec if false
- Open questions listed in the spec

## Step 2 — Ask clarifying questions

Generate a numbered list of questions (max 8). For each question:
- State the question clearly
- In one sentence, explain why the answer affects scope or design

Present all questions at once. Wait for my answers.

## Step 3 — Record decisions

Write `.sdd/specs/<current-feature>/clarifications.md`:

```markdown
# Clarifications: [Feature Name]

## Q1: [Question]
**Answer:** [My answer]
**Decision:** [The concrete conclusion — what we will do based on this answer]

## Q2: [Question]
**Answer:** [My answer]
**Decision:** [The concrete conclusion]
```

## Step 4 — Update spec if needed

If any answers change the acceptance criteria or scope:
- Update `.sdd/specs/<current-feature>/spec.md` accordingly
- List what changed in a brief summary

## Step 5 — Wrap up
- Report what was clarified and what (if anything) changed in the spec
- Confirm no open questions remain
- Remind me to run `/sdd-plan` next
