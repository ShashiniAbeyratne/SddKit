# Plan: [Feature Name]

**Feature ID:** [NNN]
**Spec:** `.sdd/specs/<NNN>-<slug>/spec.md`
**Status:** Draft
**Created:** [Date]

---

## Architecture Decisions

| Decision | Choice | Rationale |
|---|---|---|
| [Area] | [What we're doing] | [Why — reference constitution or constraints] |

---

## Component Breakdown

### [Component Name]
- **Responsibility:** [What it does]
- **Location:** `[file path]`
- **Interfaces with:** [other components]

### [Component Name]
- **Responsibility:** [What it does]
- **Location:** `[file path]`
- **Interfaces with:** [other components]

---

## Data Model

### [Entity Name]
```
[EntityName]
├── Id: [type]
├── [Field]: [type] — [description]
└── [Field]: [type] — [description]
```

**Relationships:**
- [Entity A] has many [Entity B]
- [Entity A] belongs to [Entity C]

**Migrations needed:** [yes/no — describe if yes]

---

## API Contracts

### [Endpoint group]

| Method | Route | Request | Response | Auth |
|---|---|---|---|---|
| POST | `/api/[resource]` | `{ field: type }` | `{ id, field }` | Required |
| GET | `/api/[resource]/:id` | — | `{ id, field }` | Required |

---

## Key Flows

### [Flow name — e.g. "User submits form"]
```
Client → API → [Service] → [Repository] → Database
         ↑
         Auth middleware checks token
```

---

## Integration Points

| System | How we integrate | Gotchas |
|---|---|---|
| [Existing service/table] | [How] | [Known issues] |

---

## Non-Functional Considerations

- **Error handling:** [approach]
- **Logging:** [what gets logged, at what level]
- **Caching:** [if applicable]
- **Auth:** [which endpoints require auth, what claims are checked]
- **Validation:** [where validation happens — client, API boundary, domain]
