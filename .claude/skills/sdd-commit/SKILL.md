---
name: sdd-commit
description: Generate a structured commit message and PR description, then commit. Use when the user says "commit", "PR", or after /sdd-review passes.
disable-model-invocation: true
---

Read before doing anything:
- `.sdd/specs/<current-feature>/spec.md`
- `.sdd/specs/<current-feature>/tasks.md`
- `.sdd/specs/<current-feature>/review.md`
- `.sdd/memory/project.md`

If `review.md` shows ❌ FAIL verdict, stop and say to fix review issues first.

## Step 1 — Generate commit message

Use Conventional Commits format:

```
feat(<scope>): <one-line summary from spec>

<task list>
T001: [task description]
T002: [task description]
...

Spec: .sdd/specs/<NNN>-<slug>/spec.md
Review: .sdd/specs/<NNN>-<slug>/review.md
```

- `<scope>` = feature slug (e.g. `user-auth`, `order-management`)
- Summary = the spec's one-line feature summary, in imperative mood
- Include all completed task IDs

## Step 2 — Generate PR description

```markdown
## What
[Feature summary from spec — what it does and why, not how. 2–3 sentences.]

## Why
[User value — from spec user stories. What problem does this solve for users?]

## Acceptance Criteria
[Each AC from the spec as a checkbox — copy verbatim]
- [ ] AC1
- [ ] AC2

## Implementation Notes
[Any scope discoveries or deviations from plan, with rationale]
[Any PASS WITH NOTES items from review.md]

## How to test
[Step-by-step instructions to verify the feature locally]
1. [Step]
2. [Step]

## Spec artifacts
- Spec: `.sdd/specs/<NNN>-<slug>/spec.md`
- Plan: `.sdd/specs/<NNN>-<slug>/plan.md`
- Review: `.sdd/specs/<NNN>-<slug>/review.md`
```

## Step 3 — Confirm and commit

Show me both the commit message and PR description.
Ask for my approval.

After I approve:
1. Stage all changed files: `git add .`
2. Commit with the generated message
3. Report success and the commit hash

Remind me to push and open a PR:
```
git push -u origin <branch-name>
```
