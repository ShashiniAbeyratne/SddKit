# Review Checklist

Used by /sdd-review and the spec-analyst agent.

## Coverage Assessment

For each acceptance criterion:
1. Search the implemented files listed in tasks.md
2. Find the code that satisfies the criterion
3. Quote the relevant file and line number as evidence
4. If not found, mark as FAIL — do not infer or assume

## Scope Creep Detection

Flag as potential scope creep if:
- A file was created that is not in tasks.md
- A file contains logic unrelated to any acceptance criterion
- An endpoint or function exists with no spec requirement

Do not flag as scope creep:
- Test files (these are always expected)
- Configuration files required by the framework
- Logging or error handling that is a coding standard in the constitution

## Constitution Compliance Checks

- Naming conventions: check class names, file names, method names against stated standards
- Test coverage: if constitution requires X% coverage or "tests alongside implementation", verify test files exist
- Auth: every endpoint the plan marked as "auth required" must have auth middleware or attribute applied
- No hard constraints violated: e.g. if constitution says "no MongoDB", check no MongoDB driver was introduced

## Partial Credit Rules

Mark as PARTIAL (not FAIL) if:
- The happy path is implemented but error/edge case handling is missing
- The feature works but is missing a non-critical AC (document what's missing)

Mark as FAIL if:
- A primary user story has no implementation at all
- A BLOCKING acceptance criterion is not implemented
- A hard constraint from the constitution is violated
