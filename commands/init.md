---
description: "Inicializar proyecto con estructura enterprise"
allowed-tools:
  - Bash
  - Write
  - Edit
  - Read
  - Glob
---

# Init Command

Inicializa un nuevo proyecto con estructura enterprise y mejores prácticas.

## Estructura Base

```
project/
├── src/
│   ├── app/              # Next.js App Router
│   ├── components/
│   │   ├── ui/           # Componentes reutilizables
│   │   └── features/     # Componentes de features
│   ├── lib/              # Utilidades
│   ├── services/         # Lógica de negocio
│   ├── hooks/            # Custom hooks
│   ├── types/            # TypeScript types
│   └── config/           # Configuración
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── docs/
├── .github/
│   └── workflows/
├── CLAUDE.md             # Instrucciones para Claude
├── .env.example
├── biome.json
├── tsconfig.json
└── package.json
```

## Archivos a Crear

### biome.json
```json
{
  "$schema": "https://biomejs.dev/schemas/1.9.0/schema.json",
  "organizeImports": { "enabled": true },
  "linter": {
    "enabled": true,
    "rules": { "recommended": true }
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "indentWidth": 2
  }
}
```

### tsconfig.json
```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true
  }
}
```

### CLAUDE.md (proyecto)
```markdown
# Project Guidelines

## Stack
- Next.js 15+
- React 19+
- TypeScript (strict)
- Biome (formatter/linter)
- Vitest (testing)

## Commands
- `pnpm dev`: Development server
- `pnpm build`: Production build
- `pnpm test`: Run tests
- `pnpm lint`: Lint with Biome
```

## Instrucciones

Pregunta al usuario:
1. ¿Nombre del proyecto?
2. ¿Tipo de proyecto? (web app, api, full-stack)
3. ¿Base de datos? (none, postgres, mongodb)
4. ¿Autenticación? (none, next-auth, clerk)

Luego crea la estructura y archivos necesarios.
