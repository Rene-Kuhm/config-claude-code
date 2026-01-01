# TypeScript Rules

Estas reglas se aplican automáticamente a archivos `.ts` y `.tsx`.

## Reglas Obligatorias

### Types
- **NUNCA** usar `any` - usar `unknown` si el tipo es desconocido
- **NUNCA** usar `@ts-ignore` - resolver el error correctamente
- **SIEMPRE** definir tipos de retorno explícitos en funciones exportadas
- **SIEMPRE** usar `strict: true` en tsconfig

### Type Assertions
```typescript
// ❌ PROHIBIDO
const data = response as User;

// ✅ CORRECTO - validar primero
const result = UserSchema.safeParse(response);
if (result.success) {
  const data: User = result.data;
}
```

### Null Safety
```typescript
// ❌ PROHIBIDO
const name = user!.name;

// ✅ CORRECTO
const name = user?.name ?? 'Unknown';

// O con guard
if (!user) throw new Error('User required');
const name = user.name;
```

### Generics
```typescript
// ✅ Usar generics para código reutilizable
function getFirst<T>(arr: T[]): T | undefined {
  return arr[0];
}

// ✅ Constraints cuando necesario
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}
```

## Naming Conventions

| Tipo | Convención | Ejemplo |
|------|------------|---------|
| Interfaces | PascalCase | `interface UserProfile` |
| Types | PascalCase | `type UserId = string` |
| Enums | PascalCase + UPPER_CASE values | `enum Status { ACTIVE, INACTIVE }` |
| Generics | T, U, V o descriptivo | `<TInput, TOutput>` |
| Constants | SCREAMING_SNAKE | `const MAX_RETRIES = 3` |

## Zod para Validación

```typescript
import { z } from 'zod';

// Definir schema
const UserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  age: z.number().min(0).max(150),
  role: z.enum(['admin', 'user', 'guest']),
});

// Inferir tipo
type User = z.infer<typeof UserSchema>;

// Validar en runtime
function processUser(input: unknown): User {
  return UserSchema.parse(input);
}
```

## Patterns Recomendados

### Result Pattern
```typescript
type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E };

async function fetchUser(id: string): Promise<Result<User>> {
  try {
    const user = await db.user.findUnique({ where: { id } });
    if (!user) return { success: false, error: new Error('Not found') };
    return { success: true, data: user };
  } catch (error) {
    return { success: false, error: error as Error };
  }
}
```

### Branded Types
```typescript
type UserId = string & { readonly brand: unique symbol };
type OrderId = string & { readonly brand: unique symbol };

function createUserId(id: string): UserId {
  return id as UserId;
}

// Previene mezclar IDs accidentalmente
function getUser(id: UserId) { /* ... */ }
getUser(orderId); // ❌ Error de tipo
```
