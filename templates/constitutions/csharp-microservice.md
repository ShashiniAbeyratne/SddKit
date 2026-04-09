# Base Constitution — C# Microservice (.NET Aspire + YARP + MassTransit)

## Coding Standards

### C# style
- C# 12 / .NET 8 minimum — latest language features where they add clarity
- Nullable reference types enabled in every project
- `record` types for commands, queries, events, and DTOs
- File-scoped namespaces throughout
- Minimal API endpoints preferred over controllers in new services

### Naming
- Services: `[Domain]Service` as the folder/project name (e.g. `LoanApplication.Service`)
- Events (messages): past tense, `[Entity][Action]Event` (`OrderPlacedEvent`)
- Consumers: `[EventName]Consumer` (`OrderPlacedEventConsumer`)
- Internal architecture follows the per-service pattern (Clean Architecture or Vertical Slice)

### Service boundaries (non-negotiable)
- Each service owns its own database — **no shared tables, no cross-service DB queries, ever**
- No direct service-to-service HTTP calls for writes — use MassTransit events
- Synchronous HTTP (via Gateway) is acceptable for reads only
- A service must not import or reference another service's project — communicate via shared message contracts only

### Message contracts
- Shared events/messages live in a separate `[SolutionName].Contracts` project referenced by both producer and consumer
- Events are immutable records — no mutable properties
- Event names never change once published to production (versioning strategy required for breaking changes)
- All consumers are idempotent — processing the same message twice must be safe

### Per-service architecture
- Complex domain logic → Clean Architecture (see `csharp-monolith.md` standards, applied per-service)
- CRUD / event-driven → Vertical Slice (one file per feature)
- Choice is made at `/sdd-init` and recorded in `project.md` — do not mix within a single service

### API Gateway (YARP)
- All external traffic enters via the gateway — no service exposes a public port directly
- Route config in `appsettings.json` — not hardcoded in code
- Auth validation happens at the gateway — services trust the forwarded claims

### .NET Aspire
- All services registered in `AppHost/Program.cs`
- `ServiceDefaults` added to every service — no service opts out of observability
- Connection strings and service URLs come from Aspire resource references — no hardcoded URLs

### Testing
- Unit tests per service following the per-service architecture pattern
- Integration tests use Testcontainers for real DB + real RabbitMQ — no mocked messaging
- Contract tests for shared message types (verify producer and consumer agree on the schema)
- Architecture tests (NetArchTest) for Clean Architecture services

### Observability (mandatory for all services)
- `AddServiceDefaults()` called in every service's `Program.cs`
- OpenTelemetry traces exported — distributed trace must span gateway → service → DB
- Structured logging via Serilog — include `ServiceName`, `TraceId`, `UserId` in all log entries
- Health check at `/health` (liveness) and `/alive` (readiness) in every service

### Error handling
- Services return RFC 7807 Problem Details for all error responses
- MassTransit consumers: use retry + dead-letter queue policies — no silent message drops
- Circuit breaker on any outbound HTTP call from a service (Polly)

## Hard Constraints
- No shared database between services — this is the hardest rule in this architecture
- No direct project references between service projects
- No synchronous HTTP for commands that cross service boundaries
- No `Console.WriteLine` — structured logging only
- No hardcoded connection strings or service URLs — all via Aspire / environment config
- Do not disable OpenTelemetry — observability is non-negotiable in distributed systems

## Human Approval Required For
- Adding a new service (significant scope decision)
- Adding a new message contract (affects multiple services)
- Changing an existing event schema (breaking change — requires versioning strategy)
- Introducing a new external dependency (third-party API, new infrastructure)
- Schema migrations on any service database
- Changing YARP routing rules (affects all clients)

## Non-Functional Defaults
- All service endpoints require auth unless explicitly documented as public
- P99 response time target per service: < 300ms for reads, < 1s for commands
- All services handle graceful shutdown (respect `CancellationToken` everywhere)
- Retry policy on all MassTransit consumers: 3 retries with exponential backoff, then dead-letter
- RabbitMQ queues are durable — messages survive broker restart
