# Universal Standards Rules

Applied by /sdd-standards regardless of stack. Stack-specific rules come from the constitution.

## Rule Set 1: General Code Quality

| Rule | Severity | Description |
|---|---|---|
| NO_TODO_IN_CODE | WARNING | `TODO`, `FIXME`, `HACK` comments left in committed code — file an issue or fix it |
| NO_DEAD_CODE | WARNING | Commented-out code blocks — delete or keep, never commit as comments |
| NO_MAGIC_NUMBERS | WARNING | Unexplained numeric literals inline — extract to a named constant |
| NO_CONSOLE_LOG | ERROR | `console.log`, `Console.WriteLine`, `print()` in production code paths |
| NO_HARDCODED_SECRETS | ERROR | API keys, passwords, connection strings, tokens hardcoded in source |
| NO_HARDCODED_URLS | WARNING | Hardcoded localhost or production URLs — use config/environment variables |

## Rule Set 2: Naming

| Rule | Severity | Description |
|---|---|---|
| CONSISTENT_NAMING | ERROR | Names that violate the conventions stated in the constitution |
| MEANINGFUL_NAMES | WARNING | Single-letter variable names outside of loop counters (`i`, `j`) |
| NO_ABBREVIATIONS | WARNING | Ambiguous abbreviations (`mgr`, `svc`, `tmp`) — spell it out |

## Rule Set 3: Functions and Methods

| Rule | Severity | Description |
|---|---|---|
| SINGLE_RESPONSIBILITY | WARNING | Method does more than one thing — flag if > ~30 lines or has multiple "and" in its name |
| NO_LONG_PARAM_LISTS | WARNING | More than 4 parameters — consider a parameter object |
| EARLY_RETURN | INFO | Deeply nested conditionals — consider early returns to reduce nesting |

## Rule Set 4: Error Handling

| Rule | Severity | Description |
|---|---|---|
| NO_EMPTY_CATCH | ERROR | Empty catch blocks that swallow exceptions silently |
| NO_BARE_THROW | WARNING | Re-throwing without context — add message or wrap in domain exception |
| HANDLE_NULLS | ERROR | Dereferencing without null check where null is a valid input |

## Rule Set 5: Tests

| Rule | Severity | Description |
|---|---|---|
| TEST_COVERAGE | ERROR | New feature code with no corresponding test file |
| TEST_NAMING | WARNING | Test names that don't describe the scenario (`Test1`, `TestMethod`) |
| NO_SLEEP_IN_TESTS | ERROR | `Thread.Sleep`, `setTimeout`, `await sleep()` in tests — use proper async/await or mocks |
| ARRANGE_ACT_ASSERT | INFO | Tests without clear AAA structure — add comments or restructure |

## Rule Set 6: Security (quick checks — full check is /sdd-security)

| Rule | Severity | Description |
|---|---|---|
| NO_SQL_CONCAT | ERROR | String concatenation used to build SQL queries — use parameterised queries |
| NO_HTML_CONCAT | ERROR | User input concatenated into HTML — use safe rendering APIs |
| AUTH_ON_ENDPOINTS | ERROR | API endpoint missing auth attribute/middleware when constitution requires it |

## Severity Definitions

| Severity | Meaning | Block commit? |
|---|---|---|
| ERROR | Violates a hard rule — bug risk, security risk, or breaks a hard constraint | Yes |
| WARNING | Should be fixed but won't block shipping | No |
| INFO | Style/readability suggestion | No |
