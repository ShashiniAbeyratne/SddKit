---
name: sdd-security
description: Security review against OWASP Top 10 and stack-specific risks. Use when the user says "security review", "security check", or after /sdd-standards.
disable-model-invocation: true
---

Read before doing anything:
- `.sdd/memory/constitution.md` — hard security constraints
- `.sdd/memory/project.md` — tech stack (determines which vulnerability classes apply)
- `.sdd/specs/<current-feature>/tasks.md` — files modified
- `owasp-rules.md` in this skill's directory — the checklist to apply

## Step 1 — Determine scope

If `$ARGUMENTS` is provided, treat it as the file or folder to review.
Otherwise, read all files listed in the tasks.md progress table (✅ completed tasks).
If no tasks.md, ask which files to review.

Focus on:
- API endpoints and controllers
- Auth/authorisation logic
- Any code that handles user input
- Any code that touches the database
- Any code that calls external services

## Step 2 — Spawn spec-analyst agent

Spawn the `spec-analyst` agent (`.claude/agents/spec-analyst.md`) with:
- All files to review
- The OWASP rules from `owasp-rules.md`
- The tech stack from `project.md`
- The auth setup from `constitution.md`
- Instruction to check each file against each applicable OWASP category

## Step 3 — Write security report

Write `.sdd/specs/<current-feature>/security-review.md` (or `.sdd/security-review.md` if no active feature):

```markdown
# Security Review

**Date:** [date]
**Scope:** [files reviewed]
**OWASP reference:** Top 10 2021

## Findings

| ID | OWASP Category | File | Line | Severity | Finding | Recommendation |
|---|---|---|---|---|---|---|
| S001 | A03 Injection | [file] | [line] | CRITICAL / HIGH / MEDIUM / LOW | [description] | [fix] |

## Category Coverage

| OWASP Category | Status | Notes |
|---|---|---|
| A01 Broken Access Control | ✅ Clear / ⚠️ Risk / ❌ Vulnerable | [notes] |
| A02 Cryptographic Failures | ✅ Clear / ⚠️ Risk / ❌ Vulnerable | [notes] |
| A03 Injection | ✅ Clear / ⚠️ Risk / ❌ Vulnerable | [notes] |
| A04 Insecure Design | ✅ Clear / ⚠️ Risk / ❌ Vulnerable | [notes] |
| A05 Security Misconfiguration | ✅ Clear / ⚠️ Risk / ❌ Vulnerable | [notes] |
| A06 Vulnerable Components | ✅ Clear / ⚠️ Risk / ❌ Vulnerable | [notes] |
| A07 Auth Failures | ✅ Clear / ⚠️ Risk / ❌ Vulnerable | [notes] |
| A08 Integrity Failures | ✅ Clear / ⚠️ Risk / ❌ Vulnerable | [notes] |
| A09 Logging Failures | ✅ Clear / ⚠️ Risk / ❌ Vulnerable | [notes] |
| A10 SSRF | ✅ Clear / ⚠️ Risk / ❌ Vulnerable | [notes] |

## Summary
- **Critical** (fix immediately, do not ship): [N]
- **High** (fix before production): [N]
- **Medium** (fix in next sprint): [N]
- **Low** (track, fix when convenient): [N]

## Verdict
❌ CRITICAL/HIGH findings — must fix before committing
⚠️ MEDIUM/LOW findings only — document and proceed with caution
✅ PASS — no significant findings
```

## Step 4 — Wrap up
- Present the verdict clearly
- For CRITICAL or HIGH: show exactly what is vulnerable and the specific fix
- If PASS or LOW only: remind me to run `/sdd-commit`
- Note: this is a code review, not a penetration test — flag structural risks, not exhaustive exploit chains
