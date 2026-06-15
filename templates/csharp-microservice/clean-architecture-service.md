# Clean Architecture — Per-Service Template

**Use for:** Services with complex business logic, rich domain models, multi-step workflows
**Examples:** LoanApplication, RiskScoring, OrderManagement, Payments

## Project Structure

Each Clean Architecture service is a **multi-project .NET solution**. Layers are separate `.csproj` files — not folders inside one project. This enforces dependency direction at **compile time**.

```
[service-name]/                        ← kebab-case service folder
├── [ServiceName].sln                  ← per-service solution (open this to work on one service)
│
├── [ServiceName].Domain/
│   ├── [ServiceName].Domain.csproj   ← class library, NO project references
│   ├── Common/
│   │   ├── BaseEntity.cs
│   │   └── BaseAuditableEntity.cs
│   ├── Entities/
│   │   └── [EntityName].cs            ← rich domain entity with behaviour methods
│   ├── Events/
│   │   └── [Entity]CreatedEvent.cs    ← domain events (MediatR INotification)
│   ├── ValueObjects/
│   │   └── Money.cs                   ← immutable value objects
│   ├── Enums/
│   └── Exceptions/
│       └── DomainException.cs
│
├── [ServiceName].Application/
│   ├── [ServiceName].Application.csproj   ← refs Domain only
│   ├── Common/
│   │   ├── Behaviours/
│   │   │   ├── ValidationBehaviour.cs
│   │   │   └── LoggingBehaviour.cs
│   │   └── Interfaces/
│   │       ├── IApplicationDbContext.cs
│   │       └── ICurrentUserService.cs
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
│               └── [ExternalEvent]Handler.cs
│
├── [ServiceName].Infrastructure/
│   ├── [ServiceName].Infrastructure.csproj   ← refs Application only
│   ├── Data/
│   │   ├── [ServiceName]DbContext.cs
│   │   └── Migrations/
│   ├── Messaging/
│   │   ├── Consumers/
│   │   │   └── [ExternalEvent]Consumer.cs
│   │   └── MassTransitConfiguration.cs
│   └── Services/
│       └── [External]ServiceClient.cs
│
├── [ServiceName].API/
│   ├── [ServiceName].API.csproj   ← refs Application + Infrastructure (NOT Domain directly)
│   ├── Endpoints/
│   │   └── [Resource]Endpoints.cs
│   ├── Middleware/
│   │   └── ExceptionHandlingMiddleware.cs
│   ├── Program.cs
│   └── appsettings.json
│
└── tests/
    ├── [ServiceName].UnitTests/
    │   └── [ServiceName].UnitTests.csproj   ← refs Domain, Application
    ├── [ServiceName].IntegrationTests/      ← real DB via Testcontainers
    │   └── [ServiceName].IntegrationTests.csproj   ← refs API
    └── [ServiceName].ArchitectureTests/     ← NetArchTest rules
        ├── [ServiceName].ArchitectureTests.csproj   ← refs all 4 layers
        └── LayerDependencyTests.cs
```

## Project File Contents

### [ServiceName].Domain.csproj
```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>[TargetFramework]</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
  </PropertyGroup>
  <!-- NO PackageReference or ProjectReference — Domain has zero dependencies -->
</Project>
```

### [ServiceName].Application.csproj
```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>[TargetFramework]</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
  </PropertyGroup>
  <ItemGroup>
    <ProjectReference Include="..\[ServiceName].Domain\[ServiceName].Domain.csproj" />
  </ItemGroup>
  <ItemGroup>
    <PackageReference Include="MediatR" Version="12.*" />
    <PackageReference Include="FluentValidation" Version="11.*" />
    <PackageReference Include="FluentValidation.DependencyInjectionExtensions" Version="11.*" />
    <PackageReference Include="Microsoft.Extensions.Logging.Abstractions" Version="[MajorVersion].*" />
  </ItemGroup>
</Project>
```

### [ServiceName].Infrastructure.csproj
```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>[TargetFramework]</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
  <ItemGroup>
    <ProjectReference Include="..\[ServiceName].Application\[ServiceName].Application.csproj" />
    <!-- NO Domain reference — Infrastructure talks to Application via interfaces -->
  </ItemGroup>
  <ItemGroup>
    <PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="[MajorVersion].*" />
    <PackageReference Include="Microsoft.EntityFrameworkCore.Tools" Version="[MajorVersion].*">
      <PrivateAssets>all</PrivateAssets>
      <IncludeAssets>runtime; build; native; contentfiles; analyzers</IncludeAssets>
    </PackageReference>
    <PackageReference Include="MassTransit.RabbitMQ" Version="8.*" />
  </ItemGroup>
</Project>
```

### [ServiceName].API.csproj
```xml
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <TargetFramework>[TargetFramework]</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
  <ItemGroup>
    <ProjectReference Include="..\[ServiceName].Application\[ServiceName].Application.csproj" />
    <ProjectReference Include="..\[ServiceName].Infrastructure\[ServiceName].Infrastructure.csproj" />
    <ProjectReference Include="..\..\..\..\app-host\[ProjectName].ServiceDefaults\[ProjectName].ServiceDefaults.csproj" />
    <!-- NO Domain reference — API only talks to Application -->
  </ItemGroup>
  <ItemGroup>
    <PackageReference Include="Microsoft.AspNetCore.OpenApi" Version="[MajorVersion].*" />
    <PackageReference Include="Scalar.AspNetCore" Version="1.*" />
  </ItemGroup>
</Project>
```

### [ServiceName].ArchitectureTests.csproj
```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>[TargetFramework]</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <IsPackable>false</IsPackable>
  </PropertyGroup>
  <ItemGroup>
    <ProjectReference Include="..\..\[ServiceName].Domain\[ServiceName].Domain.csproj" />
    <ProjectReference Include="..\..\[ServiceName].Application\[ServiceName].Application.csproj" />
    <ProjectReference Include="..\..\[ServiceName].Infrastructure\[ServiceName].Infrastructure.csproj" />
    <ProjectReference Include="..\..\[ServiceName].API\[ServiceName].API.csproj" />
  </ItemGroup>
  <ItemGroup>
    <PackageReference Include="xunit.v3" Version="3.*" />
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.*" />
    <PackageReference Include="NetArchTest.Rules" Version="1.*" />
  </ItemGroup>
</Project>
```

## Dependency Direction (enforced by project references)

```
API → Application → Domain
         ↓
  Infrastructure → Application
```

The compiler enforces this. If Domain accidentally imports Infrastructure, it **won't compile** because there is no project reference. NetArchTest is a second layer — not the first.

## Architecture Test (LayerDependencyTests.cs)

```csharp
using System.Reflection;
using NetArchTest.Rules;

namespace [ServiceName].ArchitectureTests;

public class LayerDependencyTests
{
    // Assembly.LoadFrom works because ProjectReference copies DLLs to output dir
    private static Assembly LoadAssembly(string name) =>
        Assembly.LoadFrom(Path.Combine(AppContext.BaseDirectory, $"{name}.dll"));

    private static readonly Assembly DomainAssembly = LoadAssembly("[ServiceName].Domain");
    private static readonly Assembly ApplicationAssembly = LoadAssembly("[ServiceName].Application");
    private static readonly Assembly InfrastructureAssembly = LoadAssembly("[ServiceName].Infrastructure");

    [Fact]
    public void Domain_Should_Not_Reference_Application() =>
        Assert.True(Types.InAssembly(DomainAssembly)
            .Should().NotHaveDependencyOn("[ServiceName].Application")
            .GetResult().IsSuccessful);

    [Fact]
    public void Domain_Should_Not_Reference_Infrastructure() =>
        Assert.True(Types.InAssembly(DomainAssembly)
            .Should().NotHaveDependencyOn("[ServiceName].Infrastructure")
            .GetResult().IsSuccessful);

    [Fact]
    public void Application_Should_Not_Reference_Infrastructure() =>
        Assert.True(Types.InAssembly(ApplicationAssembly)
            .Should().NotHaveDependencyOn("[ServiceName].Infrastructure")
            .GetResult().IsSuccessful);

    [Fact]
    public void Infrastructure_Should_Not_Reference_API() =>
        Assert.True(Types.InAssembly(InfrastructureAssembly)
            .Should().NotHaveDependencyOn("[ServiceName].API")
            .GetResult().IsSuccessful);
}
```

## Solution File ([ServiceName].sln)

```
Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio Version 17
VisualStudioVersion = 17.5.33516.290
MinimumVisualStudioVersion = 10.0.40219.1
Project("{9A19103F-16F7-4668-BE54-9A1E7A4F7556}") = "[ServiceName].Domain", "[ServiceName].Domain\[ServiceName].Domain.csproj", "{GUID-1}"
EndProject
Project("{9A19103F-16F7-4668-BE54-9A1E7A4F7556}") = "[ServiceName].Application", "[ServiceName].Application\[ServiceName].Application.csproj", "{GUID-2}"
EndProject
Project("{9A19103F-16F7-4668-BE54-9A1E7A4F7556}") = "[ServiceName].Infrastructure", "[ServiceName].Infrastructure\[ServiceName].Infrastructure.csproj", "{GUID-3}"
EndProject
Project("{9A19103F-16F7-4668-BE54-9A1E7A4F7556}") = "[ServiceName].API", "[ServiceName].API\[ServiceName].API.csproj", "{GUID-4}"
EndProject
Project("{2150E333-8FDC-42A3-9474-1A3956D46DE8}") = "tests", "tests", "{GUID-FOLDER}"
EndProject
Project("{9A19103F-16F7-4668-BE54-9A1E7A4F7556}") = "[ServiceName].UnitTests", "tests\[ServiceName].UnitTests\[ServiceName].UnitTests.csproj", "{GUID-5}"
EndProject
Project("{9A19103F-16F7-4668-BE54-9A1E7A4F7556}") = "[ServiceName].IntegrationTests", "tests\[ServiceName].IntegrationTests\[ServiceName].IntegrationTests.csproj", "{GUID-6}"
EndProject
Project("{9A19103F-16F7-4668-BE54-9A1E7A4F7556}") = "[ServiceName].ArchitectureTests", "tests\[ServiceName].ArchitectureTests\[ServiceName].ArchitectureTests.csproj", "{GUID-7}"
EndProject
Global
    GlobalSection(SolutionConfigurationPlatforms) = preSolution
        Debug|Any CPU = Debug|Any CPU
        Release|Any CPU = Release|Any CPU
    EndGlobalSection
    GlobalSection(NestedProjects) = preSolution
        {GUID-5} = {GUID-FOLDER}
        {GUID-6} = {GUID-FOLDER}
        {GUID-7} = {GUID-FOLDER}
    EndGlobalSection
EndGlobal
```

Generate unique GUIDs for each project. Use `[System.Guid]::NewGuid()` (PowerShell) or any GUID generator.

---

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
