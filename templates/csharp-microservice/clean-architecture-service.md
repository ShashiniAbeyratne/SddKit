# Clean Architecture — Per-Service Template

**Use for:** Services with complex business logic, rich domain models, multi-step workflows
**Examples:** LoanApplication, RiskScoring, OrderManagement, Payments

## Structure

```
[ServiceName].Service/
├── [ServiceName].Domain/
│   ├── Common/
│   │   ├── BaseEntity.cs
│   │   └── BaseAuditableEntity.cs
│   ├── Entities/
│   │   └── [EntityName].cs            ← rich domain entity with behaviour methods
│   ├── Events/
│   │   └── [Entity]CreatedEvent.cs    ← domain events
│   ├── ValueObjects/
│   │   └── Money.cs                   ← immutable value objects
│   ├── Enums/
│   └── Exceptions/
│       └── DomainException.cs
│
├── [ServiceName].Application/
│   ├── Common/
│   │   ├── Behaviours/
│   │   │   ├── ValidationBehaviour.cs
│   │   │   └── LoggingBehaviour.cs
│   │   └── Interfaces/
│   │       ├── IApplicationDbContext.cs
│   │       └── ICurrentUserService.cs
│   │
│   └── Features/
│       └── [FeatureName]/
│           ├── Commands/
│           │   └── [Action][Entity]/
│           │       ├── [Action][Entity]Command.cs
│           │       ├── [Action][Entity]CommandHandler.cs
│           │       └── [Action][Entity]CommandValidator.cs
│           ├── Queries/
│           │   └── Get[Entity]/
│           │       ├── Get[Entity]Query.cs
│           │       ├── Get[Entity]QueryHandler.cs
│           │       └── [Entity]Dto.cs
│           └── EventHandlers/
│               └── [ExternalEvent]Handler.cs  ← MassTransit consumer
│
├── [ServiceName].Infrastructure/
│   ├── Data/
│   │   ├── [ServiceName]DbContext.cs   ← service-owned DB — not shared
│   │   └── Migrations/
│   ├── Messaging/
│   │   ├── Consumers/
│   │   │   └── [ExternalEvent]Consumer.cs
│   │   └── MassTransitConfiguration.cs
│   └── Services/
│       └── [External]ServiceClient.cs
│
└── [ServiceName].API/
    ├── Endpoints/                      ← Minimal API preferred in .NET 8+
    │   └── [Resource]Endpoints.cs
    ├── Middleware/
    │   └── ExceptionHandlingMiddleware.cs
    ├── Program.cs
    └── appsettings.json

tests/
├── [ServiceName].UnitTests/
│   └── Features/
│       └── [FeatureName]/
│           └── Commands/
├── [ServiceName].IntegrationTests/    ← real DB via Testcontainers
└── [ServiceName].ArchitectureTests/   ← NetArchTest rules (enforce layer deps)
```

## Architecture Test (enforce dependency rule)

```csharp
[Fact]
public void Domain_Should_Not_HaveDependencyOn_Application()
{
    var result = Types.InAssembly(DomainAssembly)
        .Should().NotHaveDependencyOn(ApplicationNamespace)
        .GetResult();

    result.IsSuccessful.Should().BeTrue();
}
```

## Messaging Integration

**Consuming external events (MassTransit consumer → Application handler):**
```csharp
// Infrastructure/Messaging/Consumers/
public class PaymentProcessedConsumer : IConsumer<PaymentProcessedEvent>
{
    private readonly IMediator _mediator;
    public async Task Consume(ConsumeContext<PaymentProcessedEvent> context)
        => await _mediator.Send(new HandlePaymentProcessedCommand(context.Message.OrderId));
}
```

**Publishing domain events:**
```csharp
// After SaveChanges in DbContext — dispatch domain events via MediatR
var domainEvents = entities.SelectMany(e => e.DomainEvents).ToList();
foreach (var domainEvent in domainEvents)
    await _mediator.Publish(domainEvent, cancellationToken);
```
