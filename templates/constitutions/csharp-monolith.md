# Base Constitution — C# Monolith (Clean Architecture)

## Coding Standards

### C# style
- C# 12 / .NET 8 — use latest language features where they improve clarity
- Nullable reference types enabled (`<Nullable>enable</Nullable>`) — no `!` suppression without a comment
- `record` types for DTOs, commands, queries, and value objects
- `sealed` on classes that are not designed for inheritance
- File-scoped namespaces throughout
- No `var` when the type is not obvious from the right-hand side

### Naming
- Commands: `[Verb][Entity]Command` (`CreateOrderCommand`)
- Queries: `Get[Entity][Qualifier]Query` (`GetOrdersByCustomerQuery`)
- Handlers: `[CommandOrQuery]Handler` (same file as the command/query)
- DTOs: `[Entity]Dto` — immutable records
- Interfaces: `I[Name]` prefix
- Constants: `PascalCase` in a `static class`, not `SCREAMING_SNAKE_CASE`

### Architecture rules (Clean Architecture)
- **Dependency direction is law:** Domain ← Application ← Infrastructure / Web
- Domain must have **zero** external package references (except nullable annotations)
- Application references only Domain — no EF Core, no HTTP clients, no infrastructure
- Infrastructure references Application for interfaces — never the reverse
- Web/API layer is composition root only — no business logic in controllers or endpoints

### CQRS (MediatR)
- Every write operation is a `IRequest<T>` command with a handler
- Every read operation is a `IRequest<T>` query with a handler
- No handler does both reading and writing
- Validators (`AbstractValidator<T>`) live in the same file as their command/query
- Pipeline behaviours are the only place for cross-cutting concerns (logging, validation, perf)

### Domain entities
- No public setters — state changes via behaviour methods (`Order.AddLine(...)`)
- Domain events raised inside entity methods, dispatched after `SaveChanges`
- Value objects are immutable records with validation in the constructor
- No domain logic in handlers — handlers orchestrate, entities encapsulate

### EF Core
- Configurations in `Data/Configurations/` using `IEntityTypeConfiguration<T>` — no data annotations on entities
- Migrations committed to repo — never auto-applied in production without review
- No lazy loading — explicit `Include()` in queries
- `IApplicationDbContext` interface used in Application layer — not `DbContext` directly

### Testing
- Unit tests: handlers, validators, domain logic — mock only at the `IApplicationDbContext` interface boundary
- Integration tests: full command/query pipeline against a real database (Testcontainers or LocalDB)
- Architecture tests: NetArchTest rules enforcing layer dependencies (committed, run in CI)
- Test coverage target: 80% on Application layer; 100% on Domain logic

### Error handling
- `NotFoundException` for missing resources — returns HTTP 404
- `ValidationException` from FluentValidation pipeline — returns HTTP 400
- `ForbiddenAccessException` for authorisation failures — returns HTTP 403
- No `try/catch` in handlers unless recovering from a specific expected exception
- All unhandled exceptions caught by `ApiExceptionFilterAttribute` — never expose stack traces

## Hard Constraints
- No business logic in controllers, endpoints, or Program.cs
- No `DbContext` referenced in Application or Domain projects
- No `static` mutable state
- No `Thread.Sleep` or blocking `.Result` / `.Wait()` — async all the way
- No raw SQL unless EF Core cannot express the query and it is reviewed and documented

## Human Approval Required For
- New EF Core migration (schema change)
- Adding a new NuGet package to Domain or Application projects
- Changing the MediatR pipeline behaviour order
- Introducing a new external service integration (HTTP client, SDK)
- Any change to auth/authorisation logic

## Non-Functional Defaults
- All endpoints require authorisation unless explicitly decorated with `[AllowAnonymous]`
- All commands and queries are logged via `LoggingBehaviour` (request name + duration)
- Requests taking > 500ms are flagged by `PerformanceBehaviour` as a warning
- Structured logging with Serilog — no `Console.WriteLine` in production code
- Health check endpoint at `/health` wired up in Program.cs
