---
name: sdd-analyze
description: Cross-artifact consistency check before task breakdown. Use when the user says "analyze", "check consistency", "validate plan", or after /sdd-plan.
group: sdlc
disable-model-invocation: true
---

Read all artifacts for the current feature:
- `.sdd/memory/constitution.md`
- `.sdd/memory/project.md`
- `.sdd/specs/<current-feature>/spec.md`
- `.sdd/specs/<current-feature>/clarifications.md` (if exists)
- `.sdd/specs/<current-feature>/plan.md`
- `.sdd/specs/<current-feature>/research.md` (if exists)
- `consistency-rules.md` in this skill's directory

If `spec.md` or `plan.md` is missing, stop and name which is missing and which skill to run.

## Step 1 — Spawn spec-analyst subagent

Spawn the `spec-analyst` agent (`.claude/agents/spec-analyst.md`) in analyze mode with:
- All artifact content above
- The consistency rules from `consistency-rules.md`
- Instruction to identify: contradictions, coverage gaps, orphaned plan items, constitution violations

## Step 2 — Write analysis

Write `.sdd/specs/<current-feature>/analysis.md`:

```markdown
# Analysis: [Feature Name]

## Contradictions
| ID | Location | Description | Severity |
|---|---|---|---|
| C1 | spec.md ↔ plan.md | [what conflicts] | BLOCKING / WARNING / INFO |

## Coverage gaps (spec → plan)
| Acceptance Criterion | Plan Coverage | Gap |
|---|---|---|
| AC from spec | Addressed in plan / Missing | [what's missing] |

## Orphaned plan components (plan → spec)
| Plan Component | Spec Requirement | Status |
|---|---|---|
| [component] | [requirement it serves] | Justified / No spec requirement |

## Constitution violations
| Principle | Violation | Severity |
|---|---|---|
| [principle from constitution] | [how plan violates it] | BLOCKING / WARNING |

## Research conflicts
[Any findings from research.md that contradict plan.md]

## Recommended actions
- [ ] [Action needed before proceeding]
- [ ] [Action needed before proceeding]

## Verdict
CLEAN — proceed to /sdd-tasks
WARNINGS — review items above, then proceed
BLOCKING — fix listed issues before proceeding
```

## Step 3 — Update changelog

Append to `.sdd/specs/<current-feature>/changelog.md` (create if it doesn't exist):

```markdown
## [analyze] <date>
**Verdict:** CLEAN / WARNINGS / BLOCKING
**Issues found:** [count] blocking, [count] warnings
**Spec changes triggered:** [list any updates to spec.md or plan.md as a result, or "none"]
```

## Step 4 — Wrap up
- Present the verdict clearly
- If BLOCKING: list exactly what must be resolved and which skill to re-run
- If CLEAN or WARNINGS: remind me to run `/sdd-tasks` (or `/sdd-test` first if complexity is Epic)
