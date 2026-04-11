---
name: sdd-implement
description: Execute the approved task plan in dependency order. Use when the user says "implement", "build it", "go", or "start coding" after tasks are approved.
disable-model-invocation: true
---

Read before doing anything:
- `.sdd/specs/<current-feature>/tasks.md` — if missing, stop and say to run `/sdd-tasks` first
- `.sdd/specs/<current-feature>/plan.md`
- `.sdd/specs/<current-feature>/spec.md`
- `.sdd/memory/constitution.md`
- `.sdd/memory/project.md`

If `tasks.md` has no approved status (status is still "Pending approval"), confirm with me before starting.

Check `spec.md` for the **Complexity** field:
- **Trivial** — implement directly, no tasks.md needed, check constitution first
- **Feature** — standard sequential execution (default below)
- **Epic** — use parallel agent teams for Sprint 2+ streams (see Epic mode below)

## Epic mode (only if complexity = Epic)

For epics with a sprint plan in `tasks.md`:

**Sprint 1 (foundation)** — execute sequentially as normal. Confirm locked API contracts are written before proceeding.

**Sprint 2+ (parallel streams)** — spawn one subagent per stream. Each agent receives:
- The tasks for its stream (e.g. Sprint 2A: T003, T005, T007)
- The locked API contracts from tasks.md
- The spec.md and plan.md
- The constitution.md
- Instruction: "Implement only the tasks listed. Do not cross into the other stream's files. Flag scope discoveries."

After all Sprint 2 agents complete, consolidate their results:
- Run build/tests across the full codebase
- Flag any conflicts between streams
- Proceed to Sprint 3 sequentially

## Execution rules

Work through tasks in dependency order. Respect [P] markings — parallel tasks can be done in sequence if easier, but note they could have been concurrent.

**For each task:**
1. Announce: `Starting T001: [description]`
2. Implement it — stay strictly within the file paths listed for that task
3. Run build or tests if the task involves compilable or testable code
4. Mark complete in `tasks.md` progress table: ✅ [timestamp]
5. If you hit ambiguity not covered in plan.md → **STOP and ask** — do not assume

**At each CHECKPOINT:**
- Pause implementation
- Report what was completed in the preceding story group
- List what was built and where
- Ask me to verify the functionality works before continuing
- **Do not proceed past a checkpoint without my confirmation**

## Scope discipline

If a task reveals a requirement not in the plan:
- Flag it explicitly: `SCOPE DISCOVERY: [what was found and why it wasn't in the plan]`
- Do not implement it without my instruction
- I will decide: add to tasks.md, defer, or ignore

If a task is blocked by another system or dependency:
- Flag it: `BLOCKED: T00X waiting on [dependency]`
- Move to the next unblocked task
- Return to blocked task when unblocked

## Completion

When all tasks are ✅:
- Report: total tasks completed, any skipped, any scope discoveries made
- List all files created or modified
- Remind me to run `/sdd-review` before committing
