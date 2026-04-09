# C# Monolith — Clean Architecture Template

**Reference:** jasontaylordev/CleanArchitecture
**Stack:** ASP.NET Core + MediatR + FluentValidation + EF Core + xUnit

## Canonical Folder Structure

```
src/
├── [ProjectName].Domain/
│   ├── Common/
│   │   ├── BaseEntity.cs              ← Id, domain events list
│   │   ├── BaseAuditableEntity.cs     ← Created/Modified by/at
│   │   └── ValueObject.cs             ← base value object
│   ├── Entities/
│   │   └── [EntityName].cs
│   ├── Events/
│   │   └── [EntityName]CreatedEvent.cs
│   ├── Exceptions/
│   │   └── NotFoundException.cs
│   └── Enums/
│       └── [EnumName].cs
│
├── [ProjectName].Application/
│   ├── Common/
│   │   ├── Behaviours/
│   │   │   ├── AuthorisationBehaviour.cs
│   │   │   ├── LoggingBehaviour.cs
│   │   │   ├── PerformanceBehaviour.cs
│   │   │   └── ValidationBehaviour.cs
│   │   ├── Exceptions/
│   │   │   └── ValidationException.cs
│   │   ├── Interfaces/
│   │   │   ├── IApplicationDbContext.cs
│   │   │   └── ICurrentUserService.cs
│   │   ├── Mappings/
│   │   │   └── MappingProfile.cs      ← AutoMapper or manual mapping
│   │   └── Models/
│   │       └── PaginatedList.cs
│   │
│   └── [FeatureName]/                 ← one folder per feature/aggregate
│       ├── Commands/
│       │   └── Create[Entity]/
│       │       ├── Create[Entity]Command.cs
│       │       ├── Create[Entity]CommandHandler.cs
│       │       └── Create[Entity]CommandValidator.cs
│       ├── Queries/
│       │   └── Get[Entity]sWithPagination/
│       │       ├── Get[Entity]sWithPaginationQuery.cs
│       │       ├── Get[Entity]sWithPaginationQueryHandler.cs
│       │       └── [Entity]Dto.cs
│       └── EventHandlers/
│           └── [Entity]CreatedEventHandler.cs
│
├── [ProjectName].Infrastructure/
│   ├── Data/
│   │   ├── ApplicationDbContext.cs
│   │   ├── ApplicationDbContextInitialiser.cs
│   │   └── Migrations/
│   ├── Identity/
│   │   ├── ApplicationUser.cs
│   │   └── IdentityService.cs
│   ├── Repositories/                  ← only if not using DbContext directly
│   └── Services/
│       └── [ExternalService]Service.cs
│
└── [ProjectName].Web/                 ← or .API
    ├── Controllers/                   ← or Endpoints/ for Minimal API
    │   └── [Resource]Controller.cs
    ├── Filters/
    │   └── ApiExceptionFilterAttribute.cs
    ├── Middleware/
    │   └── RequestLoggingMiddleware.cs
    ├── Program.cs
    └── appsettings.json

tests/
├── [ProjectName].Application.UnitTests/
│   └── [FeatureName]/
│       └── Commands/
│           └── Create[Entity]CommandTests.cs
├── [ProjectName].Application.IntegrationTests/
│   └── [FeatureName]/
│       └── Commands/
│           └── Create[Entity]Tests.cs
└── [ProjectName].Web.AcceptanceTests/
    └── [Feature]/
        └── [Feature]Tests.cs
```

## Dependency Rule

```
Web → Application → Domain
Infrastructure → Application → Domain
Web → Infrastructure (DI wiring only)
```

Nothing in Domain or Application references Infrastructure or Web.

## Key Patterns

### Command/Query (CQRS via MediatR)

```csharp
// Command
public record CreateOrderCommand(string CustomerId, List<OrderLineDto> Lines) : IRequest<int>;

// Handler
public class CreateOrderCommandHandler : IRequestHandler<CreateOrderCommand, int>
{
    private readonly IApplicationDbContext _context;
    public CreateOrderCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task<int> Handle(CreateOrderCommand request, CancellationToken cancellationToken)
    {
        var order = Order.Create(request.CustomerId, request.Lines);
        _context.Orders.Add(order);
        await _context.SaveChangesAsync(cancellationToken);
        return order.Id;
    }
}

// Validator (auto-wired via ValidationBehaviour pipeline)
public class CreateOrderCommandValidator : AbstractValidator<CreateOrderCommand>
{
    public CreateOrderCommandValidator()
    {
        RuleFor(x => x.CustomerId).NotEmpty();
        RuleFor(x => x.Lines).NotEmpty();
    }
}
```

### MediatR Pipeline Behaviours (execution order)
1. `LoggingBehaviour` → logs request/response
2. `AuthorisationBehaviour` → checks user permissions
3. `ValidationBehaviour` → runs FluentValidation, throws if invalid
4. `PerformanceBehaviour` → logs slow requests

### Entity design
- Entities inherit from `BaseAuditableEntity`
- Domain events added to `DomainEvents` list, published after SaveChanges
- No public setters — use factory methods and behaviour methods

## EF Core conventions
- One `DbContext` (`IApplicationDbContext` interface for Application layer)
- Configurations in `Data/Configurations/` using `IEntityTypeConfiguration<T>`
- Code-first migrations committed to repo
- Seed data via `ApplicationDbContextInitialiser`

## Testing Standards

| Type | Tool | What |
|---|---|---|
| Unit | xUnit + FluentAssertions + NSubstitute | Handlers, validators, domain logic |
| Integration | xUnit + `WebApplicationFactory` + real DB | Full command/query pipeline |
| Acceptance | xUnit + HTTP client | API endpoints end-to-end |

Integration tests use a real database (SQL Server LocalDB or PostgreSQL via Testcontainers — not mocked).
