# Angular Architecture Template

**Stack:** Angular CLI + TypeScript + Angular Material + NgRx Signals + Reactive Forms

## Canonical Folder Structure

```
src/
├── app/
│   ├── app.config.ts              ← application config (providers, router)
│   ├── app.routes.ts              ← root route definitions (lazy-loaded features)
│   ├── app.component.ts           ← root component (shell/layout only)
│   │
│   ├── features/                  ← one module/folder per domain feature (lazy loaded)
│   │   └── [feature-name]/
│   │       ├── [feature].routes.ts       ← feature route config
│   │       ├── components/
│   │       │   └── [feature-name].component.ts
│   │       ├── services/
│   │       │   └── [feature-name].service.ts   ← business logic + HTTP calls
│   │       ├── store/
│   │       │   └── [feature-name].store.ts     ← NgRx Signal Store
│   │       ├── models/
│   │       │   └── [feature-name].model.ts     ← interfaces and types
│   │       └── [feature-name].component.spec.ts
│   │
│   ├── shared/
│   │   ├── components/
│   │   │   ├── ui/                             ← generic UI (buttons, inputs, modals)
│   │   │   └── layout/                         ← shell components (nav, header, footer)
│   │   ├── services/
│   │   │   ├── api.service.ts                  ← HttpClient wrapper with interceptors
│   │   │   └── error-handler.service.ts
│   │   ├── guards/
│   │   │   └── auth.guard.ts
│   │   ├── interceptors/
│   │   │   ├── auth.interceptor.ts             ← attach JWT token
│   │   │   └── error.interceptor.ts            ← global error handling
│   │   ├── models/
│   │   │   └── api-response.model.ts
│   │   └── utils/
│   │       └── formatters.ts
│   │
│   └── core/
│       ├── auth/
│       │   ├── auth.service.ts                 ← login, logout, token management
│       │   └── auth.store.ts                   ← current user signal store
│       └── config/
│           └── app-config.ts                   ← environment-aware config

environments/
├── environment.ts
└── environment.prod.ts

tests/
├── unit/
└── e2e/                           ← Playwright or Cypress
```

## Key Principles

### Feature modules (lazy loaded)
- Every feature is lazy-loaded via `loadChildren` in `app.routes.ts`
- Features expose only their route config — no direct cross-feature imports
- Shared services go in `shared/`, core singleton services go in `core/`

### State management — NgRx Signal Store
- One signal store per feature (`[feature].store.ts`)
- Store holds: state interface, computed signals, and methods (no actions/reducers for simple features)
- For complex features with effects/side-effects, use full NgRx Store with feature state

```typescript
// Example signal store pattern
export const OrderStore = signalStore(
  { providedIn: 'root' },
  withState<OrderState>(initialState),
  withComputed(({ orders }) => ({
    activeOrders: computed(() => orders().filter(o => o.status === 'active')),
  })),
  withMethods((store, orderService = inject(OrderService)) => ({
    loadOrders: rxMethod<void>(pipe(
      switchMap(() => orderService.getOrders()),
      tapResponse({ next: (orders) => patchState(store, { orders }), error: console.error })
    ))
  }))
);
```

### HTTP and services
- `ApiService` in `shared/` wraps `HttpClient` with base URL and typed responses
- Feature services inject `ApiService` — never `HttpClient` directly
- Auth interceptor attaches Bearer token from `AuthStore`

### Component rules
- **Smart components:** inject stores, manage data flow — one per route
- **Dumb/presentational components:** `@Input()` / `@Output()` only, no store injection
- Use `OnPush` change detection on all components
- Prefer standalone components (Angular 17+)

## Scaffold Command

When generating this scaffold, create:
- `angular.json` with standard config
- `tsconfig.json` with strict mode + path aliases
- `environment.ts` / `environment.prod.ts`
- `shared/services/api.service.ts` with HttpClient skeleton
- `shared/interceptors/auth.interceptor.ts` skeleton
- `core/auth/auth.service.ts` skeleton

## Testing Standards

| Type | Tool | What to test |
|---|---|---|
| Unit | Jest + Angular Testing Library | Components, services, store methods |
| Integration | Jest + HttpClientTestingModule | Service + HTTP interaction |
| E2E | Playwright | Critical user journeys |
