# Base Constitution — React (Vite + TypeScript + TailwindCSS)

## Coding Standards

### TypeScript
- Strict mode enabled — no `any`, no implicit `any`, no `ts-ignore` without a comment explaining why
- Prefer `type` over `interface` unless declaration merging is needed
- All props must be explicitly typed — no inferred component prop types
- Use `unknown` instead of `any` for untyped external data; narrow with Zod

### Naming
- Components: PascalCase (`UserProfileCard.tsx`)
- Hooks: camelCase prefixed with `use` (`useOrderHistory.ts`)
- Stores: camelCase suffixed with `Store` (`orderStore.ts`)
- Files: match the primary export name exactly
- Event handlers: prefix with `handle` (`handleSubmit`, `handleClose`)

### Component rules
- Max one default export per file — the component
- No business logic in page components — compose feature components only
- No direct `fetch` or `axios` calls in components — use Query hooks from `features/*/api/`
- Prefer named exports for everything except pages and route components
- Co-locate test file with component: `Component.tsx` + `Component.test.tsx`

### State
- Server state: TanStack Query — no `useEffect` + `useState` for data fetching
- UI/client state: Zustand — no prop drilling beyond 2 levels
- Form state: React Hook Form + Zod — no uncontrolled inputs for forms with validation
- Never store server data in Zustand — that's TanStack Query's job

### Styling
- TailwindCSS utility classes only — no inline `style={}` for layout
- No custom CSS files unless for third-party library overrides
- Use `clsx` or `cn` helper for conditional class names

### Testing
- Every feature must have at least one integration test (component + mocked API via MSW)
- Unit tests for all utility functions and custom hooks
- No snapshot tests — they break too easily and test the wrong thing
- Test behaviour, not implementation: test what the user sees, not internal state

### Accessibility
- All interactive elements must be keyboard accessible
- Images must have descriptive `alt` text (empty string only for decorative images)
- Form inputs must have associated labels

## Hard Constraints
- No `useEffect` for data fetching — use TanStack Query
- No Redux — Zustand is the approved state solution
- No class components — functional components only
- Do not commit `.env` files — use `.env.example` as the template
- `VITE_` prefix required on all environment variables exposed to the client

## Human Approval Required For
- Adding a new third-party library (discuss alternatives first)
- Changing the folder structure convention
- Introducing a new global provider or context
- Any change to the Vite config or build pipeline

## Non-Functional Defaults
- Lighthouse performance score target: ≥ 90
- Bundle size: flag if a single chunk exceeds 250KB uncompressed
- All API errors must show a user-facing error state — no silent failures
- Loading states required for all async operations visible to the user
