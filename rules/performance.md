# Performance Rules

Reglas de rendimiento para frontend y backend.

## React / Next.js

### Evitar Re-renders

```typescript
// ❌ PROHIBIDO - Objeto inline (nuevo cada render)
<Component style={{ color: 'red' }} />
<Component data={{ id: 1 }} />
<Component onClick={() => handleClick(id)} />

// ✅ CORRECTO - Referencias estables
const style = useMemo(() => ({ color: 'red' }), []);
const handleClick = useCallback(() => onClick(id), [id, onClick]);

<Component style={style} />
<Component onClick={handleClick} />
```

### Keys en Listas

```typescript
// ❌ PROHIBIDO - Index como key
{items.map((item, i) => <Item key={i} />)}

// ✅ CORRECTO - ID único y estable
{items.map(item => <Item key={item.id} />)}
```

### Lazy Loading

```typescript
// ✅ Componentes pesados
const HeavyChart = dynamic(() => import('./Chart'), {
  loading: () => <Skeleton />,
  ssr: false,
});

// ✅ Rutas
const Dashboard = lazy(() => import('./Dashboard'));
```

### Images

```typescript
import Image from 'next/image';

// ✅ CORRECTO
<Image
  src="/hero.jpg"
  alt="Description"
  width={1200}
  height={600}
  priority  // Solo above-the-fold
  placeholder="blur"
/>

// ❌ PROHIBIDO
<img src="/hero.jpg" />  // No optimizado
```

## Memoization

### Cuándo Usar

```typescript
// ✅ USAR - Cálculos costosos
const expensiveResult = useMemo(() => {
  return data.filter(x => x.active).map(x => transform(x));
}, [data]);

// ✅ USAR - Callbacks pasados a componentes memorizados
const handleSubmit = useCallback((data) => {
  submitForm(data);
}, [submitForm]);

// ❌ NO USAR - Operaciones simples
const doubled = useMemo(() => count * 2, [count]); // Overhead > beneficio
```

### React.memo

```typescript
// ✅ Para componentes que reciben mismas props frecuentemente
const ExpensiveList = memo(function ExpensiveList({ items }) {
  return items.map(item => <ExpensiveItem key={item.id} {...item} />);
});
```

## Database / Backend

### Evitar N+1 Queries

```typescript
// ❌ N+1 Problem
const users = await db.user.findMany();
for (const user of users) {
  user.posts = await db.post.findMany({ where: { authorId: user.id } });
}

// ✅ CORRECTO - Include/Join
const users = await db.user.findMany({
  include: { posts: true },
});

// ✅ CORRECTO - Batch loading
const userIds = users.map(u => u.id);
const posts = await db.post.findMany({
  where: { authorId: { in: userIds } },
});
```

### Paginación Obligatoria

```typescript
// ❌ PROHIBIDO - Sin límite
const allUsers = await db.user.findMany();

// ✅ CORRECTO - Con paginación
const users = await db.user.findMany({
  skip: (page - 1) * limit,
  take: limit,
});
```

### Caching

```typescript
// ✅ Cache con Redis
const cached = await redis.get(cacheKey);
if (cached) return JSON.parse(cached);

const data = await expensiveOperation();
await redis.set(cacheKey, JSON.stringify(data), 'EX', 3600);
return data;

// ✅ React Query / SWR
const { data } = useQuery({
  queryKey: ['users', id],
  queryFn: () => fetchUser(id),
  staleTime: 5 * 60 * 1000, // 5 min
});
```

## Bundle Size

### Imports

```typescript
// ❌ PROHIBIDO - Import completo
import _ from 'lodash';
import * as Icons from 'lucide-react';

// ✅ CORRECTO - Tree-shakeable
import debounce from 'lodash/debounce';
import { Search, Menu } from 'lucide-react';
```

### Análisis

```bash
# Analizar bundle
pnpm build
npx @next/bundle-analyzer
```

## Core Web Vitals

| Métrica | Objetivo | Qué afecta |
|---------|----------|------------|
| LCP | < 2.5s | Largest Contentful Paint |
| FID | < 100ms | First Input Delay |
| CLS | < 0.1 | Cumulative Layout Shift |
| TTFB | < 800ms | Time to First Byte |

### Herramientas

```bash
# Lighthouse
npx lighthouse https://mysite.com --view

# Web Vitals
import { onCLS, onFID, onLCP } from 'web-vitals';
```
