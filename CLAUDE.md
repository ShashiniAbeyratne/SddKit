# Project Context

## What this is
[Filled by /sdd-constitution]

## Tech stack
[Filled by /sdd-init]

## Active feature
[Updated by /sdd-specify — current branch and spec path]

## Non-negotiables
[From constitution — key constraints always in context]

## SDD Workflow

Always follow this sequence. **Never write implementation code before tasks.md is approved.**

### Feature workflow (default)
```
specify → clarify → plan → analyze → tasks → implement → standards → security → review → commit → push
```

### Epic workflow (large, cross-cutting features)
```
specify → clarify → plan → analyze → test → tasks → implement (parallel agents) → standards → security → review → commit → push
```

### Trivial workflow (small single-file changes)
```
specify → implement → standards → commit
```

### Bug fix workflow
```
/sdd-fix (Report → Analyze → Fix → Verify) → commit
```

### Brownfield onboarding (existing projects)
```
/sdd-audit → /sdd-constitution → then feature workflow
```

| Phase | Skill | Output |
|---|---|---|
| 0a | `/sdd-init` | Project scaffold + `.sdd/memory/project.md` |
| 0b | `/sdd-audit` | Brownfield project.md + constitution draft |
| 1 | `/sdd-constitution` | `.sdd/memory/constitution.md` |
| 2 | `/sdd-specify <idea>` | `.sdd/specs/<NNN>-<slug>/spec.md` (with complexity) |
| 3 | `/sdd-clarify` | `.sdd/specs/<NNN>-<slug>/clarifications.md` + changelog |
| 4 | `/sdd-plan <notes>` | `.sdd/specs/<NNN>-<slug>/plan.md` + `research.md` |
| 5 | `/sdd-analyze` | `.sdd/specs/<NNN>-<slug>/analysis.md` |
| 6 | `/sdd-test` | `.sdd/specs/<NNN>-<slug>/test-strategy.md` (Epics) |
| 7 | `/sdd-tasks` | `.sdd/specs/<NNN>-<slug>/tasks.md` (sprint plan for Epics) |
| 8 | `/sdd-implement` | Implementation code (parallel agents for Epics) |
| 9 | `/sdd-fix` | `.sdd/fixes/<NNN>-<slug>/` (bug fix track) |
| 10 | `/sdd-standards` | `.sdd/specs/<NNN>-<slug>/standards-review.md` |
| 11 | `/sdd-security` | `.sdd/specs/<NNN>-<slug>/security-review.md` |
| 12 | `/sdd-review` | `.sdd/specs/<NNN>-<slug>/review.md` |
| 13 | `/sdd-commit` | Commit + PR description |
| 14 | `/sdd-push` | Branch push + PR (worktree-aware) |

## Current status
[Updated manually as you progress through phases]
