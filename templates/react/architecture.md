# React Architecture Template

**Stack:** React + Vite + TypeScript + TailwindCSS + React Router + Zustand

## Canonical Folder Structure

```
src/
├── app/
│   ├── App.tsx                    ← root component, router setup
│   ├── router.tsx                 ← route definitions
│   └── providers.tsx              ← global providers (query, store, theme)
│
├── features/                      ← feature-sliced — one folder per domain feature
│   └── [feature-name]/
│       ├── api/
│       │   └── [feature].api.ts   ← API calls for this feature (TanStack Query hooks)
│       ├── components/
│       │   └── [Feature].tsx      ← feature-specific components
│       ├── hooks/
│       │   └── use[Feature].ts    ← feature-specific hooks
│       ├── store/
│       │   └── [feature].store.ts ← Zustand slice for this feature
│       ├── types/
│       │   └── [feature].types.ts ← TypeScript types/interfaces
│       └── index.ts               ← public API — export only what other features need
│
├── shared/
│   ├── components/
│   │   ├── ui/                    ← generic UI components (Button, Input, Modal)
│   │   └── layout/                ← layout components (Sidebar, Header, PageWrapper)
│   ├── hooks/
│   │   └── useDebounce.ts         ← reusable hooks
│   ├── lib/
│   │   ├── api-client.ts          ← axios/fetch instance with interceptors
│   │   └── query-client.ts        ← TanStack Query client config
│   ├── types/
│   │   └── api.types.ts           ← shared API response types
│   └── utils/
│       └── formatters.ts          ← pure utility functions
│
├── pages/                         ← thin route pages — compose features, no logic
│   ├── DashboardPage.tsx
│   └── [FeatureName]Page.tsx
│
└── main.tsx                       ← entry point

public/
tests/
├── unit/                          ← Vitest + Testing Library
├── integration/
└── e2e/                           ← Playwright (optional)

index.html
vite.config.ts
tailwind.config.ts
tsconfig.json
```

## Key Principles

### Feature isolation
- Features communicate only through their `index.ts` public API
- No direct imports between feature internals (`features/auth/components/X` from `features/orders/`)
- Shared code lives in `shared/` — if two features need it, it's shared

### State management
- **Server state:** TanStack Query (caching, background refetch, optimistic updates)
- **Client/UI state:** Zustand slices per feature (modals open, filters, selections)
- **Form state:** React Hook Form + Zod validation
- No Redux unless team already uses it

### API layer
- All API calls go through `shared/lib/api-client.ts` (base URL, auth headers, error interceptors)
- Feature API files export TanStack Query `useQuery` / `useMutation` hooks — not raw fetch calls
- Types are generated from OpenAPI spec if backend provides one (use `openapi-typescript`)

### Component rules
- Pages are dumb — they compose feature components, handle routing, no business logic
- Feature components own their data fetching via Query hooks
- Shared UI components are purely presentational — no data fetching, no store access

## Scaffold Command

When generating this scaffold, create:
- `vite.config.ts` with path aliases (`@/` → `src/`)
- `tsconfig.json` with strict mode
- `tailwind.config.ts` with content paths set
- `.env.example` with `VITE_API_BASE_URL=`
- `shared/lib/api-client.ts` with axios instance skeleton
- `shared/lib/query-client.ts` with TanStack Query config

## Testing Standards

| Type | Tool | Location | What to test |
|---|---|---|---|
| Unit | Vitest + Testing Library | `tests/unit/` | Hooks, utils, store slices |
| Component | Vitest + Testing Library | `tests/unit/components/` | Render, interactions |
| Integration | Vitest + MSW | `tests/integration/` | Feature flows with mocked API |
| E2E | Playwright | `tests/e2e/` | Critical user journeys |
