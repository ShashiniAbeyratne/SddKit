# OWASP Top 10 — 2021 Review Checklist

Used by /sdd-security and the spec-analyst agent.

---

## A01 — Broken Access Control

Check for:
- API endpoints missing authorisation attributes/middleware
- Authorisation based on user-supplied data without server-side verification (`if (request.IsAdmin)`)
- Direct object references using predictable IDs without ownership check (`/api/orders/123` — does this user own order 123?)
- CORS policy too permissive (`AllowAnyOrigin` in production)
- Missing role checks — endpoint accessible to any authenticated user when it should be admin-only
- Privilege escalation paths — can a regular user perform admin actions by manipulating the request?

**Stack specifics:**
- .NET: check `[Authorize]` / `[Authorize(Roles = "...")]` on all non-public endpoints
- Angular: route guards are UI only — verify the API enforces auth independently
- Node.js: check auth middleware is applied before route handlers, not after

---

## A02 — Cryptographic Failures

Check for:
- Sensitive data transmitted over HTTP (not HTTPS)
- Passwords stored as plain text or with weak hashing (MD5, SHA1)
- Secrets in source code, config files, or environment variable names logged
- Weak random number generation for security tokens (`Math.random()`, `Random` in C#)
- JWT secrets that are short, guessable, or hardcoded

**Stack specifics:**
- .NET: passwords should use `PasswordHasher<T>` or BCrypt — not `SHA256` directly
- JWT: `HS256` with a strong secret is acceptable; `none` algorithm must be rejected

---

## A03 — Injection

Check for:
- **SQL injection:** string concatenation to build queries — must use parameterised queries or ORM
- **Command injection:** user input passed to shell commands (`Process.Start`, `exec`, `child_process`)
- **LDAP injection:** user input in LDAP queries
- **NoSQL injection:** unvalidated input in MongoDB `$where` or filter objects
- **Log injection:** user input written directly to logs without sanitisation (can forge log entries)

**Stack specifics:**
- EF Core: raw SQL via `FromSqlRaw` must use parameters, not string interpolation
- Prisma: `queryRaw` must use tagged template literals, not string concatenation
- Any `$"SELECT ... {userInput}"` or `"SELECT ... " + userInput` is an instant CRITICAL

---

## A04 — Insecure Design

Check for:
- Business logic that can be bypassed by manipulating request order or timing
- No rate limiting on sensitive operations (login, password reset, OTP)
- No account lockout after repeated failed authentication attempts
- Sensitive operations (delete, transfer, payment) with no confirmation step or idempotency key
- Missing audit trail for sensitive operations

---

## A05 — Security Misconfiguration

Check for:
- Detailed error messages / stack traces exposed to the client in production
- Default credentials or demo accounts left in the codebase
- Unnecessary features enabled (debug endpoints, swagger in production without auth)
- Overly permissive file/directory permissions
- Missing security headers (CSP, X-Frame-Options, X-Content-Type-Options)

**Stack specifics:**
- .NET: `app.UseDeveloperExceptionPage()` must only run in Development, not Production
- Swagger/Scalar: must require auth in production or be disabled entirely

---

## A06 — Vulnerable and Outdated Components

Check for:
- Known vulnerable package versions (flag if you can identify them from imports)
- Packages that are abandoned / unmaintained (flag for human follow-up)
- Direct use of low-level crypto libraries instead of established ones

Note: full dependency scanning requires `npm audit` / `dotnet list package --vulnerable` — flag for the developer to run.

---

## A07 — Identification and Authentication Failures

Check for:
- Weak password policy (no minimum length, no complexity)
- No multi-factor authentication for admin accounts (flag as recommendation)
- Session tokens that don't expire or have excessively long expiry
- JWT not validating `exp`, `iss`, or `aud` claims
- Password reset tokens that are long-lived or reusable
- Tokens returned in URLs (appear in logs and browser history)

---

## A08 — Software and Data Integrity Failures

Check for:
- Deserialising untrusted data without type validation (JSON.parse of external input with no schema)
- Auto-update mechanisms without signature verification
- CI/CD pipeline that pulls from unverified external sources

**Stack specifics:**
- .NET: `BinaryFormatter` or `JavaScriptSerializer` on untrusted input is CRITICAL
- Node: `JSON.parse` of external data should be validated with Zod before use

---

## A09 — Security Logging and Monitoring Failures

Check for:
- Failed login attempts not logged
- No logging on privilege escalation or admin actions
- Sensitive data (passwords, tokens, PII) written to logs
- Log entries that can be forged via user input (log injection)
- No structured logging — plain string logs are harder to monitor and alert on

---

## A10 — Server-Side Request Forgery (SSRF)

Check for:
- User-supplied URLs fetched by the server without validation
- Internal service URLs constructed from user input
- Redirect endpoints that forward to arbitrary URLs (`?returnUrl=http://evil.com`)
- File upload paths that resolve to internal network locations

---

## Severity Definitions

| Severity | Meaning |
|---|---|
| CRITICAL | Exploitable now, direct data breach or account takeover risk — do not ship |
| HIGH | Significant risk, exploitable with some effort — fix before production |
| MEDIUM | Risk exists but requires specific conditions — fix in next sprint |
| LOW | Defence-in-depth improvement — track and fix when convenient |
