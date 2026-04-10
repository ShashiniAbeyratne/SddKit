---
name: sdd-push
description: Push the current branch and open a pull request. Use when the user says "push", "open PR", or "create PR" after /sdd-commit.
disable-model-invocation: true
---

Read before doing anything:
- `.sdd/specs/<current-feature>/spec.md` — for PR title and description
- `.sdd/specs/<current-feature>/review.md` — for verdict and notes
- `.sdd/memory/project.md` — for project name and context

## Step 1 — Pre-flight checks

Run the following and report results:
```bash
git status
git log origin/HEAD..HEAD --oneline
```

Confirm:
- Working tree is clean (no uncommitted changes) — if not, stop and say to run `/sdd-commit` first
- There are commits ahead of origin — if not, nothing to push

## Step 2 — Check for security/standards reviews

Check if `.sdd/specs/<current-feature>/security-review.md` exists.
If it exists and shows ❌ CRITICAL or HIGH findings, stop and say these must be resolved before pushing.

Check if `.sdd/specs/<current-feature>/standards-review.md` exists.
If it exists and shows ❌ FAIL verdict, stop and say errors must be resolved before pushing.

## Step 3 — Push

```bash
git push -u origin HEAD
```

Report the push result.

## Step 4 — Open PR

Ask: "Would you like me to open a pull request now?"

If yes, gather:
- PR title from the spec's one-line summary (feat: <summary>)
- Base branch — ask if not obvious (default: `main` or `master`)
- PR body from `.sdd/specs/<current-feature>/review.md` acceptance criteria table and any notes

Generate the `gh pr create` command:

```bash
gh pr create \
  --title "feat(<scope>): <one-line summary>" \
  --base main \
  --body "$(cat <<'EOF'
## What
[Feature summary from spec]

## Why
[User value from user stories]

## Acceptance Criteria
- [ ] AC1
- [ ] AC2

## Implementation Notes
[Any deviations, scope discoveries, or PASS WITH NOTES items]

## Spec artifacts
- Spec: `.sdd/specs/<NNN>-<slug>/spec.md`
- Plan: `.sdd/specs/<NNN>-<slug>/plan.md`
- Review: `.sdd/specs/<NNN>-<slug>/review.md`
EOF
)"
```

Show the command and ask for approval before running it.

## Step 5 — Wrap up

After push (and optional PR):
- Report the branch URL
- Report the PR URL if created
- Remind me to update CLAUDE.md `## Active feature` section to reflect the completed feature
