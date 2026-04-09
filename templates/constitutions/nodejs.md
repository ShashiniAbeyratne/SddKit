# Base Constitution — Node.js (Express + TypeScript + Prisma)

## Coding Standards

### TypeScript
- Strict mode enabled — no `any`, no `as any`
- All route handlers explicitly typed with request/response generics
- Use Zod for all input validation — define schemas alongside route handlers
- `unknown` for external data, narrowed with Zod parse

### Naming
- Route files: kebab-case, resource-plural (`orders.routes.ts`)
- Service files: camelCase suffixed with `Service` (`orderService.ts`)
- Middleware: camelCase suffixed with `Middleware` (`authMiddleware.ts`)
- Zod schemas: camelCase suffixed with `Schema` (`createOrderSchema`)
- Environment variables: `SCREAMING_SNAKE_CASE`

### Structure rules
- Route files define routes only — no business logic
- Business logic belongs in service files
- DB access belongs in service files (via Prisma client) — no Prisma calls in route handlers
- Middleware in `shared/middleware/` — one concern per middleware file
- No circular dependencies between modules

### Validation
- All incoming request bodies validated with Zod at the route level before the handler runs
- Validation errors return HTTP 400 with field-level details
- Never trust `req.body` without parsing it through a Zod schema first

### Error handling
- Centralised error handler middleware registered last in `app.ts`
- All async route handlers wrapped with an `asyncHandler` utility — no unhandled promise rejections
- HTTP errors use consistent shape: `{ error: string, details?: object }`
- Never expose stack traces or internal error messages to the client

### Prisma / Database
- Schema changes via Prisma migrations — committed to repo
- No raw SQL unless Prisma cannot express the query — document why
- Use Prisma transactions for operations that must succeed or fail together
- No `findMany` without a `take` limit on public endpoints

### Testing
- Unit tests: service functions with mocked Prisma client (`jest-mock-extended` or `vitest`)
- Integration tests: real database via Testcontainers or a test DB
- Route tests: Supertest against real Express app with test DB

## Hard Constraints
- No `require()` — ES modules (`import/export`) throughout
- No callback-style async — `async/await` only
- No unhandled promise rejections — every async function either `await`s or returns the promise
- No `process.env.X` outside of `config/env.ts` — centralise all env access
- Do not log sensitive data (tokens, passwords, PII)

## Human Approval Required For
- Adding a new npm package
- Prisma schema migration
- Changing the auth middleware
- Adding a new external API integration

## Non-Functional Defaults
- Rate limiting on all public endpoints (express-rate-limit)
- Request logging via Morgan or Pino — structured JSON in production
- All endpoints return consistent response envelope: `{ data, error, meta }`
- Graceful shutdown: drain in-flight requests before process exit
