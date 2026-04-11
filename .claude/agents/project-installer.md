---
name: project-installer
description: Copies the SDD-Kit skill suite into a target project's .claude/ folder. Spawned by /sdd-init and /sdd-install.
---

You are installing the SDD-Kit development workflow into a target project directory.

## You will receive:
- `target_path` — the absolute path to the project being initialised
- `sddkit_path` — the absolute path to the SDD-Kit repo (where these skills live)
- `stack` — the selected stack summary (frontend, backend, etc.)
- `constitution_path` — absolute path to the answered `.sdd/memory/constitution.md` (may not exist yet if /sdd-constitution hasn't been run)

## Your task

### 1. Create the target directory structure

Create the following in `<target_path>`:

```
.claude/
├── agents/
├── skills/
├── hooks/
│   └── standards-check.sh
└── settings.json

.sdd/
├── memory/
└── specs/

CLAUDE.md
```

### 2. Copy all skills

All skills now live flat in `<sddkit_path>/.claude/skills/`. Each SKILL.md has a `group:` frontmatter field — copy only skills where `group: sdlc`.

Skills to copy (`group: sdlc`):
- sdd-specify/      (+ spec-template.md, quality-checklist.md)
- sdd-clarify/
- sdd-plan/         (+ plan-template.md)
- sdd-analyze/      (+ consistency-rules.md)
- sdd-test/
- sdd-tasks/        (+ tasks-template.md)
- sdd-implement/
- sdd-fix/
- sdd-standards/    (+ standards-rules.md)
- sdd-security/     (+ owasp-rules.md)
- sdd-review/       (+ review-checklist.md)
- sdd-commit/
- sdd-push/

Do NOT copy skills where `group: init` (sdd-init, sdd-install, sdd-constitution, sdd-audit) — those are SDD-Kit bootstrappers, not project SDLC skills.

### 3. Copy hooks

Copy `<sddkit_path>/.claude/hooks/standards-check.sh` to `<target_path>/.claude/hooks/standards-check.sh`.

Make it executable: `chmod +x <target_path>/.claude/hooks/standards-check.sh`

This hook runs automatically after every Write/Edit tool call. It checks for universal standards violations (console.log, hardcoded secrets, SQL concat, any types, magic numbers) and auto-formats source files.

### 5. Copy all agents

Copy every agent from `<sddkit_path>/.claude/agents/` to `<target_path>/.claude/agents/`:
- tech-researcher.md
- spec-analyst.md
- scaffold-generator.md

Do NOT copy project-installer.md into the target — it's a meta-agent for SDD-Kit only.

### 6. Copy relevant templates and constitutions

Create `<target_path>/templates/` and copy only the templates relevant to the selected stack:

- Always copy: `templates/constitutions/<stack>.md` for each selected stack component
- If React selected: `templates/react/architecture.md`
- If Angular selected: `templates/angular/architecture.md`
- If C# Monolith: `templates/csharp-monolith/architecture.md`
- If C# Microservice: `templates/csharp-microservice/` (all files)
- If deployment pattern selected: the relevant `templates/deployment/<pattern>.md`

### 8. Copy constitution memory

This is the most important step — the constitution governs all implementation, reviews, and standards checks.

**Copy the base constitution template(s):**
Already done above — the stack-specific files in `templates/constitutions/` are the defaults.

**Copy the user-answered constitution:**
If `constitution_path` was provided and the file exists:
- Copy it to `<target_path>/.sdd/memory/constitution.md`
- This is the merged document containing both stack defaults AND the user's project-specific answers

If `constitution_path` was not provided or doesn't exist:
- Write a placeholder to `<target_path>/.sdd/memory/constitution.md`:
```markdown
# Project Constitution

⚠️ Not yet configured. Run `/sdd-constitution` to set your project principles.

Stack base constitutions available in:
[list the copied templates/constitutions/ files]
```
- Note in the report that `/sdd-constitution` must be run before starting any feature work

### 9. Write .claude/settings.json

Write the following, adjusting the hook formatter command based on the selected stack:
- TypeScript/JS stack → `npx prettier --write "$FILE"`
- C# stack → `dotnet format --include "$FILE"`
- Python stack → `black "$FILE"`
- Go stack → `gofmt -w "$FILE"`

```json
{
  "permissions": {
    "allow": [
      "Read(**)",
      "Write(**)",
      "Edit(**)",
      "Bash(git status)",
      "Bash(git add *)",
      "Bash(git commit *)",
      "Bash(git checkout *)",
      "Bash(git branch *)",
      "Bash(git push *)",
      "Bash(git worktree *)",
      "Bash(git log *)",
      "Bash(git diff *)",
      "Bash(mkdir *)",
      "Bash(ls *)",
      "Bash(gh pr create *)",
      "Bash(gh pr view *)"
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/standards-check.sh"
          }
        ]
      }
    ]
  }
}
```

### 10. Write CLAUDE.md

Write `<target_path>/CLAUDE.md` with the standard SDD workflow template — same content as SDD-Kit's CLAUDE.md but with the tech stack section pre-filled from the selected stack.

### 11. Report

After completing, report:
```
✅ SDD-Kit installed into <target_path>

Skills installed:    [count]
Agents installed:    [count]
Templates copied:    [list]
Constitution:        ✅ Copied from .sdd/memory/constitution.md
                  OR ⚠️  Placeholder written — run /sdd-constitution before starting feature work

Next steps:
1. cd <target_path>
2. Open in Claude Code: code .
3. [If constitution was copied]  → Run /sdd-specify to start your first feature
   [If constitution is missing]  → Run /sdd-constitution first, then /sdd-specify
```
