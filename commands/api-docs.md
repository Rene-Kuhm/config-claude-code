---
description: "Generate OpenAPI/Swagger documentation from codebase"
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - Write
  - Edit
---

# API Documentation Command

Genera documentación OpenAPI 3.0 automática desde el código.

## Flujo de Ejecución

### 1. Descubrimiento de Endpoints

```bash
# Next.js App Router
find app -name "route.ts" -o -name "route.js"

# Next.js Pages API
find pages/api -name "*.ts" -o -name "*.js"

# Express/Fastify routes
grep -rn "router\.(get|post|put|patch|delete)" src/
```

### 2. Análisis de Schemas

Buscar definiciones de tipos y schemas:

```bash
# Zod schemas
grep -rn "z\.object" src/

# TypeScript interfaces
grep -rn "interface.*Request" src/
grep -rn "interface.*Response" src/

# tRPC routers
grep -rn "\.query\|\.mutation" src/
```

### 3. Generación de OpenAPI

Usar skill `/api-docs` para generar:

1. **openapi.yaml** - Especificación completa
2. **openapi.json** - Versión JSON

### 4. Validación

```bash
# Validar especificación
npx @redocly/cli lint openapi.yaml

# O con swagger-cli
npx swagger-cli validate openapi.yaml
```

### 5. Generación de UI

```bash
# Swagger UI
npx swagger-ui-express

# Redoc
npx redoc-cli bundle openapi.yaml -o docs/api.html

# Scalar (moderno)
# Agregar a Next.js route
```

## Output Locations

```
docs/
├── openapi.yaml          # Especificación YAML
├── openapi.json          # Especificación JSON
├── api.html              # Documentación HTML (Redoc)
└── postman-collection.json  # Para Postman
```

## Integración con Next.js

```typescript
// app/api/docs/route.ts
import { NextResponse } from 'next/server';
import spec from '@/docs/openapi.json';

export async function GET() {
  return NextResponse.json(spec);
}

// app/docs/page.tsx
import SwaggerUI from 'swagger-ui-react';
import 'swagger-ui-react/swagger-ui.css';

export default function DocsPage() {
  return <SwaggerUI url="/api/docs" />;
}
```

## Mantenimiento

- Regenerar después de cambios en API
- Incluir en CI/CD pipeline
- Versionar junto con el código
- Publicar en portal de desarrolladores

## Formatos Adicionales

1. **Postman Collection** - Para testing manual
2. **Insomnia** - Alternativa a Postman
3. **Bruno** - Git-friendly API client
4. **TypeScript SDK** - Generar cliente tipado

```bash
# Generar cliente TypeScript
npx openapi-typescript openapi.yaml -o src/api/types.ts

# Generar SDK completo
npx @openapitools/openapi-generator-cli generate \
  -i openapi.yaml \
  -g typescript-fetch \
  -o src/api/client
```
