---
name: sdd-constitution
description: Establish or update the governing principles for this project. Use when the user says "constitution", "principles", starts a new project, or before the first feature.
group: sdlc
disable-model-invocation: true
---

Read `constitution-template.md` in this skill's directory.
Read `.sdd/memory/constitution.md` if it already exists — note what is already set.
Read `.sdd/memory/project.md` if it exists — extract the selected tech stack.

## Step 1 — Load base constitutions

Based on the stack found in `project.md`, read the relevant base constitution files from `templates/constitutions/`:

| Stack selected | Base constitution file(s) to load |
|---|---|
| React | `templates/constitutions/react.md` |
| Angular | `templates/constitutions/angular.md` |
| C# Monolith | `templates/constitutions/csharp-monolith.md` |
| C# Microservice | `templates/constitutions/csharp-microservice.md` |
| Node.js | `templates/constitutions/nodejs.md` |
| React + C# backend | `templates/constitutions/react.md` + relevant C# file |
| Angular + C# backend | `templates/constitutions/angular.md` + relevant C# file |

If no stack is set yet (project.md missing or empty), load all relevant options and tell the user to run `/sdd-init` first to get stack-specific defaults — but continue so they can still set the 5 core answers.

If multiple stacks are selected (e.g. React frontend + C# Monolith backend), merge both base constitutions — frontend standards apply to the frontend project, backend standards apply to the backend project. Make this clear in the written output.

## Step 2 — Present pre-filled defaults

Show the user the key defaults that will be pre-applied from the base constitution:
- Naming conventions
- Key hard constraints
- Testing standards
- What requires human approval

Ask: "These defaults come from the base constitution for your stack. Do you want to keep, change, or remove any of these before we continue?"

Wait for their response.

## Step 3 — Ask the 5 project-specific questions

Ask these **one at a time**, waiting for each answer. The base constitution covers stack-level standards — these questions capture project-specific context:

1. What is this project and what problem does it solve? (2–3 sentences max)
2. Who are the primary users and what do they care about most?
3. Are there any project-specific hard constraints beyond the stack defaults? (e.g. compliance requirements, performance SLAs, specific accessibility standards, budget limits, existing systems that can't change)
4. Are there any project-specific coding standards that override or extend the stack defaults?
5. Beyond the stack defaults, what decisions require your explicit approval before the agent proceeds?

## Step 4 — Write constitution

Write `.sdd/memory/constitution.md` using the structure in `constitution-template.md`:
- Merge the base constitution standards with the project-specific answers
- Clearly mark which sections come from the stack base vs project-specific input
- If updating an existing constitution, show a diff summary of what changed

## Step 5 — Wrap up

- Report what was written (new) or what changed (update)
- Tell me to commit: `git add .sdd/memory/constitution.md && git commit -m "chore: update project constitution"`
- Remind me to run `/sdd-specify` to start a feature
