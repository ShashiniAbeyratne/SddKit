---
name: sdd-test
description: Define the test strategy for a feature before implementation. Runs after /sdd-plan and before /sdd-tasks. Use when the user says "define tests", "test strategy", or after approving a plan.
disable-model-invocation: true
---

Run after `/sdd-plan` is approved, before `/sdd-tasks`.

Read:
- `.sdd/specs/<current-feature>/spec.md` — acceptance criteria
- `.sdd/specs/<current-feature>/plan.md` — components, API contracts, data model
- `.sdd/memory/constitution.md` — test framework and coverage rules
- `.sdd/memory/project.md` — stack (affects test tooling)

## Step 1 — Classify tests needed

For each acceptance criterion in the spec, classify the test type:

| Type | When to use |
|---|---|
| Unit | Pure functions, domain logic, validators, mappers |
| Integration | DB queries, external service calls, message handlers |
| E2E / Component | UI flows, user journeys, API contract tests |
| Contract | API response shape, message schema between services |

## Step 2 — Write test strategy

Write `.sdd/specs/<current-feature>/test-strategy.md`:

```markdown
# Test Strategy: <feature name>

## Test framework
[from constitution: Jest / Vitest / xUnit / Pytest / etc.]

## Coverage target
[from constitution, or default: 80% for new code]

## Unit tests
| What to test | File location | Key cases |
|---|---|---|
| <validator/function/handler> | src/... | happy path, null input, boundary |

## Integration tests
| What to test | File location | Key cases |
|---|---|---|
| <repo/service/queue handler> | tests/... | real DB / mock external |

## E2E / Component tests
| User journey | Tool | File location |
|---|---|---|
| <AC from spec> | Playwright / Cypress / Testing Library | e2e/... |

## Contract tests
| Contract | Schema location | Validated by |
|---|---|---|
| POST /api/... response | src/.../types.ts | Zod / FluentValidation |

## Mocking strategy
- External APIs: [mock / vcr / real sandbox]
- Database: [real test DB / in-memory / repository mock]
- Message queue: [in-memory bus / real broker]

## What is NOT tested here
[Explicitly excluded: infrastructure, third-party SDKs, existing untested legacy code]

## Definition of done
- [ ] All unit tests pass
- [ ] Integration tests pass against test DB
- [ ] E2E tests cover all acceptance criteria
- [ ] No new code below [X]% coverage
```

## Step 3 — Review

Show the test strategy to the user. Ask:

> "Does this test strategy cover the acceptance criteria? Any tests to add, remove, or change tooling for?"

Incorporate feedback, then confirm:

> "Test strategy approved. Run `/sdd-tasks` to generate the implementation task list — test tasks will be included."

## Step 4 — Note for sdd-tasks

When test strategy is approved, add a note to the spec folder so `/sdd-tasks` knows to include test tasks:

Append to `.sdd/specs/<current-feature>/plan.md` (bottom):

```markdown
---
## Test strategy
Defined in `test-strategy.md`. Tasks must include:
- Unit test files for each component in the plan
- Integration test setup if new DB models or external calls
- E2E test file for each acceptance criterion
```
