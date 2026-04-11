# Consistency Rules

Used by /sdd-analyze and the spec-analyst agent to evaluate artifact coherence.

## Rule Set 1: Spec ↔ Plan Coverage

- Every acceptance criterion in the spec must have a corresponding component or step in the plan
- Every plan component must trace back to at least one spec requirement
- Plan components with no spec requirement are potential scope creep — flag as WARNING unless justified
- Missing plan coverage for a spec AC is BLOCKING

## Rule Set 2: Spec Internal Consistency

- User stories must not contradict each other
- Acceptance criteria must not contradict the "Out of Scope" section
- Assumptions must not contradict stated acceptance criteria
- Each acceptance criterion must be testable in isolation

## Rule Set 3: Plan Internal Consistency

- Data model must support all API contracts defined in the plan
- API contracts must cover all data flows described in sequence diagrams
- Component responsibilities must not overlap (one thing owns one concern)
- Auth requirements must be consistent across all endpoints in the same resource group

## Rule Set 4: Constitution Compliance

- Coding standards from the constitution must be reflected in the plan (e.g. if constitution requires tests, plan must include test components)
- Hard constraints from the constitution must not be violated (e.g. if "no third-party auth" is a constraint, plan must not include Auth0)
- Any decision requiring human approval (per constitution) must be flagged explicitly

## Rule Set 5: Research Conflicts

- If research.md contains a version-specific gotcha that contradicts the plan's approach, flag as BLOCKING
- If research.md recommends a different library version than what the plan assumes, flag as WARNING
- If research.md identifies a deprecated API being used in the plan, flag as BLOCKING

## Severity Definitions

| Severity | Meaning | Action |
|---|---|---|
| BLOCKING | Will cause implementation failure or violates a hard constraint | Must be resolved before /sdd-tasks |
| WARNING | May cause issues or represents a risk | Should be reviewed; document decision if keeping |
| INFO | Worth knowing but doesn't block progress | Note for awareness |
