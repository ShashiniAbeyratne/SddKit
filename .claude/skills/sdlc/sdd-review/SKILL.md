---
name: sdd-review
description: Post-implementation drift check — verify what was built matches what was specified. Use when the user says "review", "check drift", "validate implementation", or after /sdd-implement.
disable-model-invocation: true
---

Read before doing anything:
- `.sdd/specs/<current-feature>/spec.md`
- `.sdd/specs/<current-feature>/plan.md`
- `.sdd/specs/<current-feature>/tasks.md`
- `.sdd/memory/constitution.md`
- `review-checklist.md` in this skill's directory

## Step 1 — Spawn spec-analyst subagent

Spawn the `spec-analyst` agent (`.claude/agents/spec-analyst.md`) in review mode with:
- All spec acceptance criteria
- All file paths listed in `tasks.md`
- Instruction to read each implemented file and assess criterion coverage
- Instruction to flag any code with no corresponding spec requirement (scope creep)

## Step 2 — Write review report

Write `.sdd/specs/<current-feature>/review.md`:

```markdown
# Review: [Feature Name]

**Date:** [Date]
**Reviewer:** spec-analyst agent + human

## Acceptance Criteria Coverage

| Story | Criterion | Status | Evidence |
|---|---|---|---|
| Story 1 | AC1: [criterion text] | ✅ PASS / ⚠️ PARTIAL / ❌ FAIL | [file:line or "not found"] |
| Story 1 | AC2: [criterion text] | ✅ PASS | [file:line] |

## Scope Creep
<!-- Code that exists but has no spec requirement -->
| File | What it does | Spec requirement | Verdict |
|---|---|---|---|
| [file] | [description] | None found / [AC reference] | Remove / Accept / Defer |

## Missing Implementation
<!-- Spec requirements with no code -->
| Criterion | Expected in | Status |
|---|---|---|
| [AC text] | [expected file] | Not implemented |

## Constitution Compliance
- [ ] Naming conventions followed
- [ ] Test coverage meets standard (per constitution)
- [ ] No hard constraints violated
- [ ] Auth applied where required per plan

## Verdict
✅ PASS — ready for /sdd-commit
⚠️ PASS WITH NOTES — items flagged above, document decisions
❌ FAIL — must fix before committing
```

## Step 3 — Wrap up
- Present the verdict clearly
- If FAIL: list exactly what must be fixed (with task IDs if new tasks are needed)
- If PASS or PASS WITH NOTES: remind me to run `/sdd-commit`
