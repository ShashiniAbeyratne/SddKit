# C# Microservice Architecture Template

**Pattern:** eShop / .NET Aspire + YARP + MassTransit + RabbitMQ
**Reference:** dotnet/eShop, dotnet/aspire-samples

## Solution-Level Structure

```
/
├── src/
│   ├── services/
│   │   ├── [service-name]/            ← one folder per microservice
│   │   │   └── [see service templates]
│   │   └── ...
│   │
│   ├── gateway/
│   │   ├── [ProjectName].Gateway/     ← YARP reverse proxy
│   │   │   ├── Program.cs
│   │   │   ├── appsettings.json       ← YARP route config
│   │   │   └── [ProjectName].Gateway.csproj
│   │
│   └── app-host/
│       ├── [ProjectName].AppHost/     ← .NET Aspire orchestration
│       │   ├── Program.cs             ← service registration, resource wiring
│       │   └── [ProjectName].AppHost.csproj
│       └── [ProjectName].ServiceDefaults/
│           ├── Extensions.cs          ← shared observability, health checks
│           └── [ProjectName].ServiceDefaults.csproj
│
├── tests/
│   ├── [ServiceName].UnitTests/
│   ├── [ServiceName].IntegrationTests/
│   └── [SolutionName].E2ETests/       ← cross-service tests via API Gateway
│
├── docker-compose.yml                 ← local dev: RabbitMQ, DBs, infrastructure
├── docker-compose.override.yml
└── [SolutionName].sln
```

## Macro Architecture — How Services Relate

```
                    ┌─────────────────┐
  Client ──────────▶│   API Gateway   │ (YARP)
                    └────────┬────────┘
                             │  HTTP routing
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
       ┌─────────┐    ┌─────────┐    ┌─────────┐
       │ Service │    │ Service │    │ Service │
       │    A    │    │    B    │    │    C    │
       └────┬────┘    └────┬────┘    └────┬────┘
            │              │              │
            │        ┌─────▼──────┐       │
            └───────▶│  RabbitMQ  │◀──────┘
                     │ (MassTransit)│
                     └────────────┘
```

**Communication rules:**
- **Queries (reads):** HTTP via API Gateway — synchronous, returns data immediately
- **Commands (writes that cross service boundaries):** async messages via RabbitMQ — fire and forget with eventual consistency
- **Each service owns its own database** — no shared tables, no cross-service DB queries
- **No direct service-to-service HTTP** (unless a synchronous read is unavoidable — document the coupling)

## Per-Service Architecture Choices

See separate template files for internal structure:
- `clean-architecture-service.md` — for services with complex domain logic (includes event sourcing pattern)
- `vertical-slice-service.md` — for CRUD-heavy or simple event-driven services
- `saga-pattern.md` — for multi-step cross-service workflows with compensation (orchestration-style)

### Which to choose:

| Service characteristic | Use |
|---|---|
| Complex business rules, rich domain model | Clean Architecture |
| Multiple workflow steps, long transactions | Clean Architecture |
| CRUD operations, simple state machine | Vertical Slice |
| Event-driven, notification-style | Vertical Slice |
| Auth service (custom token authority) | ASP.NET Core Identity (user store) + Duende IdentityServer (token issuance) — one dedicated service, no complex internal structure needed |

## API Gateway (YARP)

```json
// appsettings.json — YARP route config
{
  "ReverseProxy": {
    "Routes": {
      "orders-route": {
        "ClusterId": "orders-cluster",
        "Match": { "Path": "/api/orders/{**catch-all}" }
      }
    },
    "Clusters": {
      "orders-cluster": {
        "Destinations": {
          "orders-service": { "Address": "http://orders-service/" }
        }
      }
    }
  }
}
```

## .NET Aspire AppHost

```csharp
// Program.cs — AppHost
var builder = DistributedApplication.CreateBuilder(args);

var rabbit = builder.AddRabbitMQ("rabbitmq");
var ordersDb = builder.AddPostgres("postgres").AddDatabase("ordersdb");

var ordersService = builder.AddProject<Projects.Orders_Service>("orders-service")
    .WithReference(rabbit)
    .WithReference(ordersDb);

var gateway = builder.AddProject<Projects.Gateway>("gateway")
    .WithReference(ordersService);

builder.Build().Run();
```

## MassTransit messaging pattern

```csharp
// Publisher (in service A command handler)
await _publishEndpoint.Publish(new OrderPlacedEvent(order.Id, order.CustomerId));

// Consumer (in service B)
public class OrderPlacedEventConsumer : IConsumer<OrderPlacedEvent>
{
    public async Task Consume(ConsumeContext<OrderPlacedEvent> context)
    {
        // handle event in service B's bounded context
    }
}
```

## Observability (via ServiceDefaults)

All services add:
- OpenTelemetry traces (Jaeger / OTLP)
- Health checks (`/health`, `/alive`)
- Structured logging (Serilog → Seq)
- Metrics (Prometheus)

ServiceDefaults wires this up — each service just calls `builder.AddServiceDefaults()`.

## Local Development

```bash
# Start infrastructure only
docker-compose up rabbitmq postgres -d

# Run all services via Aspire
dotnet run --project src/app-host/[ProjectName].AppHost
```

Aspire dashboard available at `http://localhost:15888` — shows all services, traces, logs.
