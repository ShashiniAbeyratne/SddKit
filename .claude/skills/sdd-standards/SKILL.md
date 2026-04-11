---
name: sdd-standards
description: Coding standards review — check implementation against the project constitution. Use when the user says "standards review", "check standards", "lint check", or after /sdd-implement.
group: sdlc
disable-model-invocation: true
---

Read before doing anything:
- `.sdd/memory/constitution.md` — the coding standards to enforce
- `.sdd/memory/project.md` — the tech stack (determines which rules apply)
- `.sdd/specs/<current-feature>/tasks.md` — the list of files that were modified
- `standards-rules.md` in this skill's directory — the universal rules

If `constitution.md` is missing, stop and say to run `/sdd-constitution` first.

## Step 1 — Determine scope

If `$ARGUMENTS` is provided, treat it as the file or folder to review.
Otherwise, read all files listed in the tasks.md progress table (✅ completed tasks).
If no tasks.md exists, ask the user which files to review.

## Step 2 — Spawn spec-analyst agent

Spawn the `spec-analyst` agent (`.claude/agents/spec-analyst.md`) with:
- The coding standards from `constitution.md`
- The universal rules from `standards-rules.md`
- The tech stack from `project.md`
- All files to review
- Instruction to check each file against the standards and report violations

## Step 3 — Write standards report

Write `.sdd/specs/<current-feature>/standards-review.md` (or `.sdd/standards-review.md` if no active feature):

```markdown
# Standards Review

**Date:** [date]
**Scope:** [files reviewed]

## Violations

| File | Line | Rule | Severity | Finding |
|---|---|---|---|---|
| [file] | [line] | [rule name] | ERROR / WARNING / INFO | [description] |

## Summary
- **Errors** (must fix before commit): [N]
- **Warnings** (should fix): [N]
- **Info** (worth knowing): [N]

## Verdict
❌ FAIL — fix errors before committing
⚠️ PASS WITH WARNINGS — warnings noted, errors resolved
✅ PASS — all standards met
```

## Step 4 — Wrap up
- Present the verdict
- For each ERROR, show the exact file and line and what needs to change
- If PASS: remind me to run `/sdd-security` next, or `/sdd-commit` if security was already done
