---
name: sdd-install
description: Install the SDD-Kit skill suite into an existing project. Use when the user says "install sdd", "add sdd-kit", or wants to add the workflow to an existing project.
group: init
disable-model-invocation: true
---

Use this skill to install the SDD-Kit workflow into an **existing** project that was not created with `/sdd-init`.

For new projects, use `/sdd-init` instead — it handles scaffolding and installation together.

## Step 1 — Determine the target path

If a path was passed as an argument (e.g. `/sdd-install C:\Users\you\Projects\MyApp`), use it directly.

Otherwise ask: "What is the absolute path to the project you want to install SDD-Kit into?"

## Step 2 — Read stack from project.md (if it exists)

Check if `<target_path>/.sdd/memory/project.md` exists.

- **If it does:** read it to extract Frontend, Backend, and Deployment pattern. Skip asking for the stack.
- **If it doesn't:** ask for the tech stack:
  - Frontend: React / Angular / None
  - Backend: C# Monolith / C# Microservice / Node.js / None
  - Deployment pattern (if FE + BE): CDN+API / .Host / API only

## Step 3 — Confirm

Show the user a summary:
```
Installing SDD-Kit into: <path>
Stack: <summary>
Will create: .claude/skills/, .claude/agents/, templates/, .sdd/memory/, CLAUDE.md

Existing files will NOT be overwritten.
```

Ask for confirmation before proceeding.

## Step 4 — Spawn project-installer agent

Spawn the `project-installer` agent (`.claude/agents/project-installer.md`) with:
- `target_path`: the resolved path
- `sddkit_path`: the directory where this skill lives (parent of `.claude/`)
- `stack`: the stack choices from Step 2

## Step 5 — Wrap up

After the agent completes:
- Report what was installed
- Remind the user to open the project in Claude Code
- Tell them to run `/sdd-constitution` first if they haven't already, or `/sdd-specify` if the constitution already exists
