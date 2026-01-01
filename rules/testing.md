# Testing Rules

Estas reglas se aplican a archivos de test (`*.test.ts`, `*.spec.ts`, `*.test.tsx`).

## Estructura Obligatoria: AAA Pattern

```typescript
it('should do something', () => {
  // Arrange - Setup
  const input = createTestData();

  // Act - Execute
  const result = functionUnderTest(input);

  // Assert - Verify
  expect(result).toBe(expected);
});
```

## Naming Conventions

### Test Files
```
ComponentName.test.tsx    # Component tests
service.test.ts           # Service tests
utils.test.ts             # Utility tests
api.e2e.test.ts          # E2E tests
```

### Test Descriptions
```typescript
// ✅ CORRECTO - Describe comportamiento
it('should return empty array when no items match filter')
it('should throw ValidationError when email is invalid')

// ❌ INCORRECTO - Muy vago
it('works')
it('test filter')
it('handles error')
```

## Mocking

### Usar vi.mock para módulos
```typescript
vi.mock('@/lib/prisma', () => ({
  prisma: {
    user: {
      findUnique: vi.fn(),
    },
  },
}));
```

### Limpiar mocks entre tests
```typescript
beforeEach(() => {
  vi.clearAllMocks();
});

afterEach(() => {
  vi.restoreAllMocks();
});
```

## Qué Testear

| Sí Testear | No Testear |
|------------|------------|
| Lógica de negocio | Implementation details |
| Edge cases | Third-party libraries |
| Error handling | Framework internals |
| User interactions | Getters/setters simples |
| API contracts | Static markup |

## React Testing Library

```typescript
// ✅ Queries recomendadas (por orden de preferencia)
screen.getByRole('button', { name: /submit/i })
screen.getByLabelText(/email/i)
screen.getByPlaceholderText(/search/i)
screen.getByText(/welcome/i)
screen.getByTestId('custom-element')  // Último recurso

// ❌ Evitar
container.querySelector('.my-class')
screen.getByClassName('button')
```

## Async Testing

```typescript
// ✅ CORRECTO
await waitFor(() => {
  expect(screen.getByText('Loaded')).toBeInTheDocument();
});

// ✅ CORRECTO - findBy ya incluye waitFor
const element = await screen.findByText('Loaded');

// ❌ INCORRECTO - No usar delays fijos
await new Promise(r => setTimeout(r, 1000));
```

## Coverage Goals

```
Statements: 80%+
Branches: 75%+
Functions: 85%+
Lines: 80%+
```
