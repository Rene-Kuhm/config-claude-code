# React Rules

Estas reglas se aplican a componentes React (`.tsx`, `.jsx`).

## Server vs Client Components (Next.js 15+)

### Server Components (default)
```typescript
// ✅ Server Component - NO 'use client'
export default async function ProductsPage() {
  const products = await db.product.findMany();
  return <ProductList products={products} />;
}
```

### Client Components (solo cuando necesario)
```typescript
// ✅ Client Component - CON 'use client'
'use client';

import { useState } from 'react';

export function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>;
}
```

**Usar Client Components SOLO para:**
- useState, useEffect, otros hooks
- Event handlers (onClick, onChange)
- Browser APIs (window, localStorage)
- Librerías client-only

## Reglas de Componentes

### Props
```typescript
// ✅ CORRECTO - Props tipadas
interface ButtonProps {
  variant: 'primary' | 'secondary';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  onClick?: () => void;
  children: React.ReactNode;
}

export function Button({
  variant,
  size = 'md',
  disabled = false,
  onClick,
  children
}: ButtonProps) {
  return (
    <button
      className={cn(variants[variant], sizes[size])}
      disabled={disabled}
      onClick={onClick}
    >
      {children}
    </button>
  );
}
```

### Keys
```typescript
// ❌ PROHIBIDO - index como key
{items.map((item, index) => <Item key={index} />)}

// ✅ CORRECTO - id único
{items.map(item => <Item key={item.id} />)}
```

### State Updates
```typescript
// ❌ PROHIBIDO - mutar estado
setItems(prev => {
  prev.push(newItem);
  return prev;
});

// ✅ CORRECTO - inmutable
setItems(prev => [...prev, newItem]);
```

### Memoization
```typescript
// ✅ useMemo para cálculos costosos
const expensiveResult = useMemo(() => {
  return items.filter(i => i.active).map(i => transform(i));
}, [items]);

// ✅ useCallback para funciones pasadas como props
const handleClick = useCallback(() => {
  doSomething(id);
}, [id]);

// ❌ NO usar para todo - solo cuando hay beneficio real
```

## Hooks Rules

### Custom Hooks
```typescript
// ✅ Nombre empieza con 'use'
function useProducts(categoryId: string) {
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    fetchProducts(categoryId)
      .then(setProducts)
      .catch(setError)
      .finally(() => setLoading(false));
  }, [categoryId]);

  return { products, loading, error };
}
```

### useEffect Dependencies
```typescript
// ❌ PROHIBIDO - deps vacías con variables usadas
useEffect(() => {
  fetchData(userId);  // userId no está en deps!
}, []);

// ✅ CORRECTO
useEffect(() => {
  fetchData(userId);
}, [userId]);

// ✅ O usar ref si no quieres re-ejecutar
const userIdRef = useRef(userId);
useEffect(() => {
  fetchData(userIdRef.current);
}, []);
```

## Performance

### Lazy Loading
```typescript
import dynamic from 'next/dynamic';

const HeavyComponent = dynamic(() => import('./HeavyComponent'), {
  loading: () => <Skeleton />,
  ssr: false,
});
```

### Images
```typescript
import Image from 'next/image';

// ✅ CORRECTO
<Image
  src="/hero.jpg"
  alt="Hero image"
  width={1200}
  height={600}
  priority // Solo para above-the-fold
/>
```

### Avoid Re-renders
```typescript
// ❌ PROHIBIDO - objeto inline (nuevo cada render)
<Component style={{ color: 'red' }} />

// ✅ CORRECTO - objeto estable
const style = { color: 'red' };
<Component style={style} />

// O con useMemo si es dinámico
const style = useMemo(() => ({ color: theme.primary }), [theme.primary]);
```

## Accessibility

```typescript
// ✅ Siempre incluir
<button aria-label="Close dialog">
  <XIcon />
</button>

<img src={src} alt="Descriptive text" />

<input
  id="email"
  aria-describedby="email-error"
/>
<span id="email-error" role="alert">
  {error}
</span>
```

## Testing Components

```typescript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

describe('Button', () => {
  it('should call onClick when clicked', async () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click me</Button>);

    await userEvent.click(screen.getByRole('button'));

    expect(handleClick).toHaveBeenCalledTimes(1);
  });
});
```
