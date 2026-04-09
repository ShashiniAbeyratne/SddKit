# Vertical Slice Architecture — Per-Service Template

**Use for:** CRUD-heavy services, simple event-driven services, notification pipelines
**Examples:** DocumentManagement, Notifications, AuditLog, EmailService

## Core Idea

Instead of separating code by technical layer (Domain / Application / Infrastructure), organise by **feature**. All code for one feature (endpoint, handler, validator, DB access) lives together.

```
[ServiceName].Service/
├── Features/
│   └── [FeatureName]/
│       ├── [Action][Resource].cs      ← everything for one request/response in one file
│       └── [Action][Resource]Tests.cs
│
├── Domain/                            ← shared domain model only (if needed)
│   └── [SharedEntity].cs
│
├── Infrastructure/                    ← shared infra only
│   ├── [ServiceName]DbContext.cs
│   └── Migrations/
│
├── Common/
│   ├── Behaviours/
│   │   └── ValidationBehaviour.cs    ← shared MediatR pipeline
│   └── Middleware/
│       └── ExceptionHandlingMiddleware.cs
│
└── Program.cs                         ← wire everything up, register endpoints

tests/
├── [ServiceName].UnitTests/
│   └── Features/
└── [ServiceName].IntegrationTests/
```

## Feature File Pattern

Each feature is a single file containing the complete request/response cycle:

```csharp
// Features/Documents/UploadDocument.cs
namespace DocumentManagement.Features.Documents;

// 1. Request (command/query)
public record UploadDocumentCommand(string FileName, byte[] Content, string UploadedBy) : IRequest<UploadDocumentResult>;

// 2. Result
public record UploadDocumentResult(Guid DocumentId, string StoragePath);

// 3. Validator
public class UploadDocumentCommandValidator : AbstractValidator<UploadDocumentCommand>
{
    public UploadDocumentCommandValidator()
    {
        RuleFor(x => x.FileName).NotEmpty().MaximumLength(255);
        RuleFor(x => x.Content).NotEmpty().Must(c => c.Length <= 10_485_760).WithMessage("Max 10MB");
    }
}

// 4. Handler (all DB/infra access here — no repository abstraction needed for simple services)
public class UploadDocumentCommandHandler : IRequestHandler<UploadDocumentCommand, UploadDocumentResult>
{
    private readonly DocumentDbContext _context;
    private readonly IBlobStorageService _blobStorage;

    public UploadDocumentCommandHandler(DocumentDbContext context, IBlobStorageService blobStorage)
    {
        _context = context;
        _blobStorage = blobStorage;
    }

    public async Task<UploadDocumentResult> Handle(UploadDocumentCommand request, CancellationToken cancellationToken)
    {
        var path = await _blobStorage.UploadAsync(request.FileName, request.Content, cancellationToken);

        var document = new Document { FileName = request.FileName, StoragePath = path, UploadedBy = request.UploadedBy };
        _context.Documents.Add(document);
        await _context.SaveChangesAsync(cancellationToken);

        return new UploadDocumentResult(document.Id, path);
    }
}

// 5. Endpoint registration (Minimal API)
public static class UploadDocumentEndpoint
{
    public static void MapUploadDocument(this IEndpointRouteBuilder app)
    {
        app.MapPost("/api/documents", async (UploadDocumentCommand command, IMediator mediator) =>
            Results.Ok(await mediator.Send(command)))
            .RequireAuthorization()
            .WithName("UploadDocument");
    }
}
```

## Program.cs — Endpoint registration

```csharp
var builder = WebApplication.CreateBuilder(args);
builder.AddServiceDefaults();

builder.Services.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(typeof(Program).Assembly));
builder.Services.AddValidatorsFromAssembly(typeof(Program).Assembly);
builder.Services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehaviour<,>));

var app = builder.Build();
app.MapDefaultEndpoints();

// Register all feature endpoints
app.MapUploadDocument();
app.MapGetDocument();
app.MapDeleteDocument();

app.Run();
```

## When to extract shared Domain

Extract to `Domain/` only when:
- Multiple features reference the same entity and share business rules
- A value object is reused across features
- A domain event is published/consumed by multiple handlers

Keep in the feature file when:
- The entity is simple (few fields, no behaviour)
- Only one feature uses it

## Messaging (MassTransit consumer as a feature)

```csharp
// Features/Notifications/SendWelcomeEmail.cs
public class UserRegisteredConsumer : IConsumer<UserRegisteredEvent>
{
    private readonly IEmailService _email;

    public async Task Consume(ConsumeContext<UserRegisteredEvent> context)
    {
        await _email.SendWelcomeAsync(context.Message.UserEmail, context.Message.UserName);
    }
}
```

No MediatR needed for simple event consumers — the consumer IS the handler.

## Trade-offs vs Clean Architecture

| | Vertical Slice | Clean Architecture |
|---|---|---|
| File count | Low (one file per feature) | High (4+ files per feature) |
| Onboarding | Easy — find the feature, see everything | Harder — trace across layers |
| Testability | Good — test the handler directly | Better — mock at interface boundaries |
| Scale | Gets messy with complex domain logic | Handles complexity well |
| Best for | CRUD, events, notifications | Complex business rules, rich domains |
