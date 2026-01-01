# API Rules

Estas reglas se aplican a endpoints API, routes y servicios backend.

## Next.js Route Handlers (App Router)

### Estructura
```typescript
// app/api/users/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';

const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2).max(100),
});

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const data = CreateUserSchema.parse(body);

    const user = await db.user.create({ data });

    return NextResponse.json(user, { status: 201 });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: 'Validation failed', details: error.errors },
        { status: 400 }
      );
    }
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
```

### Dynamic Routes
```typescript
// app/api/users/[id]/route.ts
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const user = await db.user.findUnique({
    where: { id: params.id },
  });

  if (!user) {
    return NextResponse.json(
      { error: 'User not found' },
      { status: 404 }
    );
  }

  return NextResponse.json(user);
}
```

## Validación Obligatoria

### Siempre validar input
```typescript
// ❌ PROHIBIDO
const { email, password } = await request.json();

// ✅ CORRECTO
const LoginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

const body = await request.json();
const result = LoginSchema.safeParse(body);

if (!result.success) {
  return NextResponse.json(
    { error: 'Invalid input', details: result.error.flatten() },
    { status: 400 }
  );
}

const { email, password } = result.data;
```

## Error Handling

### RFC 7807 Problem Details
```typescript
interface ProblemDetails {
  type: string;
  title: string;
  status: number;
  detail?: string;
  instance?: string;
}

function createError(
  status: number,
  title: string,
  detail?: string
): NextResponse<ProblemDetails> {
  return NextResponse.json(
    {
      type: `https://api.example.com/errors/${status}`,
      title,
      status,
      detail,
      instance: new Date().toISOString(),
    },
    { status }
  );
}

// Uso
return createError(404, 'User not found', `No user with ID ${id}`);
```

## Security

### Authentication
```typescript
import { getServerSession } from 'next-auth';
import { authOptions } from '@/lib/auth';

export async function GET(request: NextRequest) {
  const session = await getServerSession(authOptions);

  if (!session) {
    return NextResponse.json(
      { error: 'Unauthorized' },
      { status: 401 }
    );
  }

  // Usuario autenticado
  const userId = session.user.id;
  // ...
}
```

### Authorization
```typescript
export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const session = await getServerSession(authOptions);

  if (!session) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  // Verificar ownership o rol
  const resource = await db.resource.findUnique({
    where: { id: params.id },
  });

  if (resource?.ownerId !== session.user.id && session.user.role !== 'admin') {
    return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
  }

  // Proceder con eliminación
}
```

### Rate Limiting
```typescript
import { Ratelimit } from '@upstash/ratelimit';
import { Redis } from '@upstash/redis';

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, '10 s'),
});

export async function POST(request: NextRequest) {
  const ip = request.ip ?? '127.0.0.1';
  const { success, limit, reset, remaining } = await ratelimit.limit(ip);

  if (!success) {
    return NextResponse.json(
      { error: 'Too many requests' },
      {
        status: 429,
        headers: {
          'X-RateLimit-Limit': limit.toString(),
          'X-RateLimit-Remaining': remaining.toString(),
          'X-RateLimit-Reset': reset.toString(),
        },
      }
    );
  }

  // Procesar request
}
```

## Database Queries

### Evitar N+1
```typescript
// ❌ N+1 Problem
const users = await db.user.findMany();
for (const user of users) {
  const posts = await db.post.findMany({ where: { authorId: user.id } });
}

// ✅ CORRECTO - Include
const users = await db.user.findMany({
  include: { posts: true },
});
```

### Paginación
```typescript
const PaginationSchema = z.object({
  page: z.coerce.number().min(1).default(1),
  limit: z.coerce.number().min(1).max(100).default(20),
});

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const { page, limit } = PaginationSchema.parse({
    page: searchParams.get('page'),
    limit: searchParams.get('limit'),
  });

  const [items, total] = await Promise.all([
    db.item.findMany({
      skip: (page - 1) * limit,
      take: limit,
    }),
    db.item.count(),
  ]);

  return NextResponse.json({
    data: items,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  });
}
```

## Response Standards

### Success
```typescript
// Single item
{ data: { id: '1', name: 'Item' } }

// Collection
{
  data: [{ id: '1' }, { id: '2' }],
  pagination: { page: 1, limit: 20, total: 100 }
}

// Created
// Status: 201
{ data: { id: '1', ... } }

// No content
// Status: 204 (sin body)
```

### Errors
```typescript
// 400 Bad Request
{ error: 'Validation failed', details: [...] }

// 401 Unauthorized
{ error: 'Authentication required' }

// 403 Forbidden
{ error: 'Permission denied' }

// 404 Not Found
{ error: 'Resource not found' }

// 500 Internal Server Error
{ error: 'Internal server error' }
// NUNCA exponer stack traces en producción
```
