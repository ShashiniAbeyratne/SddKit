# Saga Pattern — MassTransit Orchestration

**Use for:** Multi-step workflows that span multiple services, where a step failure requires compensating actions in prior steps.
**Style:** Orchestration (one central state machine owns the flow — easier to reason about than choreography).

## When you need a Saga

A Saga is needed when:
- A business operation touches more than one service's database
- Any step can fail and earlier steps need to be undone
- You need to query "what step is this workflow currently on?"

A Saga is NOT needed for:
- Single-service operations (use a normal DB transaction)
- Fire-and-forget notifications (use a plain MassTransit consumer)

## Loan Application Saga — Example

```
Submit → [RiskScoring] → [DocumentCheck] → Approve
                ↓               ↓
            Rejected      Compensate → ReleaseScoring → Reject
```

### State machine

```csharp
// In the service that owns the workflow (LoanApplication.Service)
public class LoanApplicationSaga : MassTransitStateMachine<LoanApplicationSagaState>
{
    public State Scoring { get; private set; }
    public State DocumentCheck { get; private set; }
    public State Approved { get; private set; }
    public State Rejected { get; private set; }
    public State Compensating { get; private set; }

    public Event<LoanApplicationSubmitted> ApplicationSubmitted { get; private set; }
    public Event<RiskScoreCompleted> ScoringCompleted { get; private set; }
    public Event<RiskScoreFailed> ScoringFailed { get; private set; }
    public Event<DocumentCheckCompleted> DocumentsVerified { get; private set; }
    public Event<DocumentCheckFailed> DocumentsFailed { get; private set; }
    public Event<ScoringReservationReleased> ScoringReleased { get; private set; }

    public LoanApplicationSaga()
    {
        InstanceState(x => x.CurrentState);

        Event(() => ApplicationSubmitted,   x => x.CorrelateById(m => m.Message.ApplicationId));
        Event(() => ScoringCompleted,       x => x.CorrelateById(m => m.Message.ApplicationId));
        Event(() => ScoringFailed,          x => x.CorrelateById(m => m.Message.ApplicationId));
        Event(() => DocumentsVerified,      x => x.CorrelateById(m => m.Message.ApplicationId));
        Event(() => DocumentsFailed,        x => x.CorrelateById(m => m.Message.ApplicationId));
        Event(() => ScoringReleased,        x => x.CorrelateById(m => m.Message.ApplicationId));

        Initially(
            When(ApplicationSubmitted)
                .Then(ctx =>
                {
                    ctx.Saga.ApplicationId = ctx.Message.ApplicationId;
                    ctx.Saga.Amount = ctx.Message.Amount;
                })
                .Publish(ctx => new ScoreApplicationCommand(ctx.Saga.ApplicationId, ctx.Saga.Amount))
                .TransitionTo(Scoring));

        During(Scoring,
            When(ScoringCompleted)
                .Then(ctx => ctx.Saga.ScoreId = ctx.Message.ScoreId)
                .Publish(ctx => new RequestDocumentCheckCommand(ctx.Saga.ApplicationId))
                .TransitionTo(DocumentCheck),
            When(ScoringFailed)
                .Publish(ctx => new RejectApplicationCommand(ctx.Saga.ApplicationId, "Risk score failed"))
                .TransitionTo(Rejected));

        During(DocumentCheck,
            When(DocumentsVerified)
                .Publish(ctx => new ApproveLoanCommand(ctx.Saga.ApplicationId))
                .TransitionTo(Approved),
            When(DocumentsFailed)
                // Compensation: undo the scoring reservation before rejecting
                .Publish(ctx => new ReleaseScoringReservationCommand(ctx.Saga.ApplicationId, ctx.Saga.ScoreId))
                .TransitionTo(Compensating));

        During(Compensating,
            When(ScoringReleased)
                .Publish(ctx => new RejectApplicationCommand(ctx.Saga.ApplicationId, "Document check failed"))
                .TransitionTo(Rejected));
    }
}
```

### Saga state (persisted to DB between steps)

```csharp
public class LoanApplicationSagaState : SagaStateMachineInstance
{
    public Guid CorrelationId { get; set; }    // required by MassTransit — maps to ApplicationId
    public string CurrentState { get; set; }
    public Guid ApplicationId { get; set; }
    public decimal Amount { get; set; }
    public Guid? ScoreId { get; set; }         // stored for compensation
}
```

### Persistence (EF Core → SQL Server)

```csharp
// In MassTransit configuration
services.AddMassTransit(x =>
{
    x.AddSagaStateMachine<LoanApplicationSaga, LoanApplicationSagaState>()
        .EntityFrameworkRepository(r =>
        {
            r.ConcurrencyMode = ConcurrencyMode.Pessimistic; // prevents duplicate processing
            r.AddDbContext<DbContext, SagaDbContext>((provider, builder) =>
                builder.UseSqlServer(connectionString));
        });

    x.UsingRabbitMq((ctx, cfg) => cfg.ConfigureEndpoints(ctx));
});
```

```csharp
// SagaDbContext — separate from the service's main DbContext
public class SagaDbContext : SagaDbContext<SagaDbContext>
{
    public SagaDbContext(DbContextOptions<SagaDbContext> options) : base(options) { }

    protected override IEnumerable<ISagaClassMap> Configurations
    {
        get { yield return new LoanApplicationSagaStateMap(); }
    }
}

public class LoanApplicationSagaStateMap : SagaClassMap<LoanApplicationSagaState>
{
    protected override void Configure(EntityTypeBuilder<LoanApplicationSagaState> entity, ModelBuilder model)
    {
        entity.Property(x => x.CurrentState).HasMaxLength(64);
        entity.Property(x => x.Amount).HasColumnType("decimal(18,2)");
    }
}
```

## Key rules

- **CorrelationId = the business entity ID** (ApplicationId, OrderId, etc.) — makes it queryable
- **Store IDs needed for compensation** in saga state (e.g. ScoreId) — you'll need them when rolling back
- **Each message is idempotent** — the state machine may receive the same event twice; MassTransit handles deduplication with pessimistic concurrency
- **Compensating transactions are business actions** — they don't roll back DB writes, they issue new commands to undo effects
- **Saga lives in the service that owns the business process** — for Loan Platform, that's LoanApplication.Service

## Choreography vs Orchestration

| | Orchestration (this template) | Choreography |
|---|---|---|
| Flow visibility | Central state machine — one place to see full flow | Distributed across consumers — hard to trace |
| Debugging | Query the saga state table | Reconstruct from distributed logs |
| Coupling | Saga knows about all services | Services only know their own events |
| Best for | Complex multi-step workflows | Simple reactive pipelines |

Use orchestration for anything with compensation logic. Use choreography only for simple "react to event" chains with no rollback.
