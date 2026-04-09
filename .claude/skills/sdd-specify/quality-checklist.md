# Spec Quality Checklist

Run this against every spec before proceeding to /sdd-plan.

## Structure
- [ ] Feature has a one-line summary that a non-technical stakeholder could read
- [ ] Every user story follows the "As a / I want / So that" format
- [ ] Every story has at least 2 acceptance criteria
- [ ] Out of scope section exists and is not empty

## Acceptance Criteria Quality
- [ ] Each criterion is independently testable (a QA engineer could write a test for it)
- [ ] No criterion uses vague language ("fast", "easy", "user-friendly", "appropriate")
- [ ] No criterion mentions technology or implementation ("uses Redux", "calls the API")
- [ ] No criterion is a duplicate or subset of another
- [ ] Error states and edge cases are covered (empty states, validation failures, auth errors)

## Completeness
- [ ] Happy path is fully covered
- [ ] At least one unhappy path / error state per story
- [ ] All user roles mentioned in stories are real roles defined in the constitution
- [ ] Assumptions section acknowledges what the spec depends on being true

## Scope Hygiene
- [ ] Out of scope items are explicit, not implied
- [ ] Nothing in the spec bleeds into how it should be implemented
- [ ] Feature is achievable in one branch / one PR cycle (if not, it should be split)
