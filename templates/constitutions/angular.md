# Base Constitution — Angular (CLI + TypeScript + Angular Material + NgRx)

## Coding Standards

### TypeScript
- Strict mode enabled — no `any`, no `as any`, no `@ts-ignore` without explanation
- All public service methods must have explicit return types
- Use `readonly` on injected dependencies in constructors
- Prefer `signal`-based state (Angular 17+) over `BehaviorSubject` for new code

### Naming
- Components: PascalCase, suffixed with `Component` (`UserProfileComponent`)
- Services: PascalCase, suffixed with `Service` (`OrderService`)
- Stores: PascalCase, suffixed with `Store` (`OrderStore`)
- Guards: camelCase, suffixed with `guard` (`authGuard`)
- Files: kebab-case matching selector (`user-profile.component.ts`)
- Selectors: prefix with app name (`app-user-profile`)

### Component rules
- All components use `OnPush` change detection — no exceptions
- All new components are standalone (Angular 17+) — no NgModules for feature code
- Smart components (route-level): inject stores, manage data flow
- Dumb/presentational components: `@Input()` / `@Output()` only, no store injection
- No direct `HttpClient` injection in components — use services only
- Co-locate spec file: `feature.component.ts` + `feature.component.spec.ts`

### State management
- NgRx Signal Store for feature state
- No component-level `BehaviorSubject` when a signal store would suffice
- Do not mix NgRx Signal Store and classic NgRx Store in the same feature
- Effects / async operations belong in store `withMethods` using `rxMethod`

### HTTP
- All HTTP calls go through a service — never directly from a component
- `ApiService` in `shared/services/` is the single HTTP wrapper
- Auth token is attached by the `AuthInterceptor` — not manually in services
- All HTTP errors are handled centrally by `ErrorInterceptor` — services don't catch unless feature-specific recovery is needed

### Testing
- Unit tests required for all services, stores, and non-trivial components
- Use `HttpClientTestingModule` for service tests — no real HTTP in unit tests
- Integration tests use `TestBed` with real service wiring
- Test file lives next to the source file

### Accessibility
- All interactive elements are keyboard accessible
- Angular Material components used where available — do not re-implement native controls
- ARIA attributes added only when semantic HTML + Material is insufficient

## Hard Constraints
- No NgModules for new feature code — standalone components only
- No `any` type
- No `HttpClient` directly in components
- Do not disable `OnPush` — fix the data flow instead
- Do not commit environment files with real secrets

## Human Approval Required For
- Adding a new third-party Angular library
- Changing the Angular Material theme
- Modifying `angular.json` build configuration
- Adding a new lazy-loaded route module
- Changing the auth strategy

## Non-Functional Defaults
- Initial bundle: flag if main chunk exceeds 200KB gzipped
- All async operations show a loading state
- All HTTP errors show a user-facing message — no silent failures
- Forms validate on submit AND on blur (not on every keystroke)
