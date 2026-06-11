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

## Event Sourcing (selective — use only where audit trail is a business requirement)

**When to use:** Services with regulatory audit requirements or complex state machines where "what happened and when" must be queryable (e.g. LoanApplication). Do NOT use for CRUD-heavy services — unnecessary complexity.

### Events table (SQL Server)

```sql
CREATE TABLE LoanEvents (
    Id          BIGINT IDENTITY PRIMARY KEY,
    StreamId    UNIQUEIDENTIFIER NOT NULL,    -- aggregate ID (e.g. ApplicationId)
    EventType   NVARCHAR(100) NOT NULL,       -- 'ApplicationSubmittedEvent'
    EventData   NVARCHAR(MAX) NOT NULL,       -- JSON payload
    Version     INT NOT NULL,                -- sequence within this stream (starts at 1)
    OccurredAt  DATETIME2 NOT NULL,
    CONSTRAINT UQ_LoanEvents_StreamVersion UNIQUE (StreamId, Version)  -- prevents duplicates
)
```

### Aggregate root with event sourcing

```csharp
public class LoanApplication
{
    private readonly List<DomainEvent> _uncommittedEvents = new();
    public IReadOnlyList<DomainEvent> UncommittedEvents => _uncommittedEvents;

    public Guid Id { get; private set; }
    public LoanStatus Status { get; private set; }
    public decimal Amount { get; private set; }
    public int Version { get; private set; }

    private LoanApplication() { }

    // Rehydrate from stored events
    public static LoanApplication Rehydrate(IEnumerable<DomainEvent> history)
    {
        var loan = new LoanApplication();
        foreach (var e in history)
            loan.Apply(e, isNew: false);
        return loan;
    }

    // Business actions — raise event, never set state directly
    public void Submit(decimal amount, string applicantId)
    {
        if (Status != LoanStatus.None)
            throw new DomainException("Application already submitted");

        RaiseEvent(new ApplicationSubmittedEvent(Guid.NewGuid(), amount, applicantId, DateTime.UtcNow));
    }

    public void PassRiskCheck(Guid scoreId)
    {
        if (Status != LoanStatus.Submitted)
            throw new DomainException("Invalid state for risk check");

        RaiseEvent(new RiskCheckPassedEvent(Id, scoreId, DateTime.UtcNow));
    }

    private void RaiseEvent(DomainEvent e) => Apply(e, isNew: true);

    // Apply is the ONLY place state mutates — called for both new and replayed events
    private void Apply(DomainEvent e, bool isNew)
    {
        Version++;
        switch (e)
        {
            case ApplicationSubmittedEvent ev:
                Id = ev.ApplicationId;
                Amount = ev.Amount;
                Status = LoanStatus.Submitted;
                break;
            case RiskCheckPassedEvent:
                Status = LoanStatus.RiskApproved;
                break;
            case LoanApprovedEvent:
                Status = LoanStatus.Approved;
                break;
        }

        if (isNew) _uncommittedEvents.Add(e);
    }
}
```

### Event store repository

```csharp
public class LoanEventStoreRepository
{
    private readonly LoanDbContext _context;

    public async Task<LoanApplication> LoadAsync(Guid id, CancellationToken ct)
    {
        var rows = await _context.LoanEvents
            .Where(e => e.StreamId == id)
            .OrderBy(e => e.Version)
            .ToListAsync(ct);

        if (!rows.Any()) throw new NotFoundException(nameof(LoanApplication), id);

        var events = rows.Select(Deserialize);
        return LoanApplication.Rehydrate(events);
    }

    public async Task SaveAsync(LoanApplication loan, CancellationToken ct)
    {
        var rows = loan.UncommittedEvents.Select((e, i) => new LoanEventRow
        {
            StreamId  = loan.Id,
            EventType = e.GetType().Name,
            EventData = JsonSerializer.Serialize(e, e.GetType()),
            Version   = loan.Version - loan.UncommittedEvents.Count + i + 1,
            OccurredAt = DateTime.UtcNow
        });

        _context.LoanEvents.AddRange(rows);
        await _context.SaveChangesAsync(ct);
    }

    private static DomainEvent Deserialize(LoanEventRow row) =>
        JsonSerializer.Deserialize(row.EventData, Type.GetType(row.EventType)!) as DomainEvent
        ?? throw new InvalidOperationException($"Cannot deserialize event type {row.EventType}");
}
```

### Read model (projection)

Event sourcing has no queryable "current state" row — build a separate read model for queries:

```csharp
// A flat table kept up to date by handling domain events
public class LoanApplicationSummary
{
    public Guid Id { get; set; }
    public string ApplicantName { get; set; }
    public decimal Amount { get; set; }
    public string Status { get; set; }
    public DateTime SubmittedAt { get; set; }
    public DateTime? ApprovedAt { get; set; }
}

// Handler updates the read model whenever an event is saved
public class LoanApprovedEventHandler : INotificationHandler<LoanApprovedEvent>
{
    public async Task Handle(LoanApprovedEvent notification, CancellationToken ct)
    {
        var summary = await _context.LoanSummaries.FindAsync(notification.ApplicationId, ct);
        summary.Status = "Approved";
        summary.ApprovedAt = notification.OccurredAt;
        await _context.SaveChangesAsync(ct);
    }
}
```

**Rule:** Commands load from the event store and save events. Queries read from the projection table. Never mix the two.

---

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
