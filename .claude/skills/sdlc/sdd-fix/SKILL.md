---
name: sdd-fix
description: Lightweight bug fix workflow — Report, Analyze, Fix, Verify. Use when the user says "fix bug", "there's an issue", "something is broken", or describes a defect rather than a new feature.
disable-model-invocation: true
---

Use this skill for **bugs, defects, and regressions** — not new features. It is intentionally lighter than the full spec→plan→tasks path.

Read `.sdd/memory/constitution.md` and `.sdd/memory/project.md` before starting.

## Step 1 — Report

Ask the user to describe the bug with these four prompts (accept partial answers, fill gaps from context):

```
1. What is happening? (observed behaviour)
2. What should happen? (expected behaviour)
3. How to reproduce it? (steps / environment)
4. Severity: Critical / High / Medium / Low
```

Create `.sdd/fixes/<NNN>-<slug>/report.md`:

```markdown
# Bug Report: <short title>

## Observed behaviour
[what is happening]

## Expected behaviour
[what should happen]

## Reproduction steps
[steps / environment / logs]

## Severity
[Critical / High / Medium / Low]

## Reported
[date]
```

Use the next available `NNN` (count existing folders under `.sdd/fixes/`).

## Step 2 — Analyze

Read the relevant source files. Use Grep/Glob to find code related to the reported behaviour.

Produce `.sdd/fixes/<NNN>-<slug>/analysis.md`:

```markdown
# Root Cause Analysis

## Root cause
[the actual bug — be specific, reference file:line]

## Affected files
| File | Why affected |
|---|---|
| ... | ... |

## Risk surface
[what else could break if we touch this? any related fragile areas?]

## Proposed fix
[one paragraph — what change, where, why this approach]

## Out of scope
[anything the user mentioned that is NOT part of this fix]
```

Show the analysis to the user. Ask: "Does this root cause and fix approach look right? Approve to proceed."

**Do not write any fix code until approved.**

## Step 3 — Fix

Implement only what is in the approved `analysis.md` proposed fix.

Rules:
- Do not refactor surrounding code
- Do not add features
- Do not improve formatting of untouched lines
- If you discover a second bug while fixing, note it in `analysis.md` under `## Discovered issues` — do not fix it now

After implementing, run relevant tests if a test command is known from `project.md` or `constitution.md`.

## Step 4 — Verify

Produce `.sdd/fixes/<NNN>-<slug>/verify.md`:

```markdown
# Verification

## Fix applied
[file:line — what changed, one sentence]

## Reproduction check
[Did the fix resolve the reported behaviour? Yes/No + evidence]

## Regression check
[Any tests run? Pass/Fail. Any related areas manually checked?]

## Discovered issues (if any)
[New bugs found during fixing — create separate /sdd-fix runs for these]

## Verdict
✅ FIXED | ⚠️ PARTIAL | ❌ NOT FIXED
```

## Step 5 — Wrap up

If verdict is ✅ FIXED:
- Tell the user the fix is ready
- Remind them to run `/sdd-commit` with the fix reference: `fix(<scope>): <short title> [fixes #NNN]`

If verdict is ⚠️ PARTIAL or ❌ NOT FIXED:
- Explain what is still broken
- Ask if they want to extend the analysis or escalate to a full `/sdd-specify` feature
