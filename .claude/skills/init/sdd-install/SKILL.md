---
name: sdd-install
description: Install the SDD-Kit skill suite into an existing project. Use when the user says "install sdd", "add sdd-kit", or wants to add the workflow to an existing project.
disable-model-invocation: true
---

Use this skill to install the SDD-Kit workflow into an **existing** project that was not created with `/sdd-init`.

For new projects, use `/sdd-init` instead — it handles scaffolding and installation together.

## Step 1 — Gather info

Ask the following, one at a time:

1. What is the absolute path to the project you want to install SDD-Kit into?
   (e.g. `C:\Users\you\Projects\MyApp` or `/Users/you/Projects/MyApp`)

2. What is the tech stack? (so I can copy the right templates and constitution base)
   - Frontend: React / Angular / None
   - Backend: C# Monolith / C# Microservice / Node.js / None
   - Deployment pattern (if FE + BE): CDN+API / .Host / API only

## Step 2 — Confirm

Show the user a summary:
```
Installing SDD-Kit into: <path>
Stack: <summary>
Will create: .claude/skills/, .claude/agents/, templates/, .sdd/memory/, CLAUDE.md

Existing files will NOT be overwritten.
```

Ask for confirmation before proceeding.

## Step 3 — Spawn project-installer agent

Spawn the `project-installer` agent (`.claude/agents/project-installer.md`) with:
- `target_path`: the path the user provided
- `sddkit_path`: the directory where this skill lives (parent of `.claude/`)
- `stack`: the stack choices from Step 1

## Step 4 — Wrap up

After the agent completes:
- Report what was installed
- Remind the user to open the project in Claude Code
- Tell them to run `/sdd-constitution` first if they haven't already, or `/sdd-specify` if the constitution already exists
