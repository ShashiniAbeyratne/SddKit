# Tasks: [Feature Name]

**Feature ID:** [NNN]
**Spec:** `.sdd/specs/<NNN>-<slug>/spec.md`
**Plan:** `.sdd/specs/<NNN>-<slug>/plan.md`
**Status:** Pending approval
**Created:** [Date]

---

## Story 1: [Story title]

| ID | Description | Files | Depends on | Parallel | Size |
|---|---|---|---|---|---|
| T001 | [What to build] | `path/to/file.cs` | — | — | S |
| T002 | [What to build] | `path/to/file.cs` | T001 | — | M |
| T003 | [What to build] | `path/to/file.cs` | T001 | [P] | S |

--- CHECKPOINT: Verify [story 1 outcome] before continuing ---

---

## Story 2: [Story title]

| ID | Description | Files | Depends on | Parallel | Size |
|---|---|---|---|---|---|
| T004 | [What to build] | `path/to/file.cs` | T002 | — | M |
| T005 | [What to build] | `path/to/file.cs` | T004 | — | L |

--- CHECKPOINT: Verify [story 2 outcome] before continuing ---

---

## Progress

| ID | Status | Completed |
|---|---|---|
| T001 | pending | — |
| T002 | pending | — |
| T003 | pending | — |
| T004 | pending | — |
| T005 | pending | — |

---

## Summary
- **Total tasks:** [N]
- **Small:** [N] | **Medium:** [N] | **Large:** [N]
- **Critical path:** T001 → T002 → T004 → T005
- **Can parallelise:** T003 alongside T002
