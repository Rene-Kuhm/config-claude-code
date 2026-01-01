# Global Development Standards - Claude Code

**Configuración Global Enterprise** para todos los proyectos

---

## Idioma: Español Argentino

**SIEMPRE respondé en español argentino usando voseo.**

- Usá "vos" en lugar de "tú": "vos tenés", "vos podés", "hacé", "fijate"
- Sé directo y conciso
- Expresiones permitidas: "Dale", "Mirá", "Listo", "Anda joya"
- Mantené el profesionalismo técnico
- Código y variables en inglés (estándar internacional)

---

## Stack Tecnológico Preferido

### Frontend
- **Next.js**: ÚLTIMA VERSIÓN (siempre verificar con Context7)
- **React**: ÚLTIMA VERSIÓN (siempre verificar con Context7)
- **TypeScript**: Modo estricto, zero tolerance para `any`
- **Package Manager**: pnpm (bun para velocidad)
- **Formatter**: Biome (NO Prettier)
- **Testing**: Vitest + React Testing Library
- **Animaciones**: Framer Motion, GSAP + ScrollTrigger, Lenis

### Backend
- **Runtime**: Node.js LTS / Bun
- **Framework**: Express / Fastify / Hono
- **ORM**: Prisma / Drizzle
- **Validation**: Zod
- **Testing**: Vitest

### Tools
- **Package Manager Detection**: Auto-detect (pnpm-lock.yaml / bun.lockb / package-lock.json)
- **Formatter**: Biome con organización de imports
- **Linter**: Biome + ESLint cuando sea necesario

---

## CLI Tools Modernos (Usar siempre)

| Legacy | Moderno | Instalación |
|--------|---------|-------------|
| cat | bat | `brew install bat` |
| grep | rg (ripgrep) | `brew install ripgrep` |
| find | fd | `brew install fd` |
| sed | sd | `brew install sd` |
| ls | eza | `brew install eza` |

---

## Sistema de Orquestación Inteligente (2026-Ready)

El sistema detecta automáticamente qué agente usar según tu pedido:

```
TU PEDIDO → AUTO-ORCHESTRATOR → AGENTE CORRECTO → RESULTADO
```

### Routing Automático

| Si mencionás... | Se activa... |
|-----------------|--------------|
| error, bug, falla, crash | `debugger` |
| crear, componente, feature | `builder` |
| arquitectura, diseño, sistema | `architect` |
| seguridad, OWASP, vulnerabilidad | `security-auditor` |
| test, coverage, vitest | `test-engineer` |
| documentar, README, docs | `docs-writer` |
| Next.js, React, GSAP, animación | `general-architect` |
| explorar, buscar, encontrar | `Explore` |
| planificar, ADR | `Plan` |
| deploy, docker, k8s | `devops` |

---

## Agents Disponibles

Invocar con `@agent-name` en el prompt (o dejar que el orquestador elija):

| Agent | Uso | Herramientas |
|-------|-----|--------------|
| `orchestrator` | **META** - Detecta y delega al agente correcto | Task, Read |
| `general-architect` | Arquitectura Next.js/React, animaciones, diseño de sistemas | Read, Write, Edit, Bash, Web |
| `architect` | Análisis SOLID, patrones de diseño, ADRs | Solo lectura |
| `builder` | Implementación Full Stack, código production-ready | Todas |
| `security-auditor` | Auditoría OWASP, análisis de vulnerabilidades | Solo lectura + Bash |
| `debugger` | Resolución de errores, stack traces, debugging | Read, Write, Edit, Bash |
| `devops` | CI/CD, Docker, Kubernetes, Terraform, IaC | Read, Write, Bash, Web |
| `docs-writer` | Documentación técnica, READMEs, API docs | Read, Write, Edit |
| `test-engineer` | Estrategia de testing, cobertura, TDD | Todas |

---

## Skills Disponibles

Invocar con `/skill-name` en el prompt:

### Desarrollo
| Skill | Comando | Descripción |
|-------|---------|-------------|
| Scaffold | `/scaffold <type> <name>` | Crear component, page, hook, service, api |
| Test | `/test generate <file>` | Generar tests con Vitest/Playwright |
| Refactor | `/refactor <file>` | Refactoring SOLID automático |
| Code Review | `/code-review <file>` | Review automático de código |

### Git & Release
| Skill | Comando | Descripción |
|-------|---------|-------------|
| Commit | `/commit` | Conventional commit automático |
| PR | `/pr` | Crear Pull Request con template |
| Changelog | `/changelog generate <version>` | Generar changelog semántico |
| Release | `/release <version>` | Release con tags y notas |

### Operaciones
| Skill | Comando | Descripción |
|-------|---------|-------------|
| Audit | `/audit` | Auditoría completa (security, deps, perf) |
| Monitor | `/monitor <metric>` | Métricas en tiempo real |
| DB Migration | `/db-migration <action>` | Migraciones Prisma/Drizzle |
| Incident | `/incident-response` | Runbooks para incidentes |

### Documentación
| Skill | Comando | Descripción |
|-------|---------|-------------|
| Docs | `/docs <type>` | Generar README, API docs, guides |
| Preview | `/preview` | Preview visual del proyecto |

---

## Rules Activas

Las rules se aplican automáticamente según el contexto:

| Rule | Aplica a | Descripción |
|------|----------|-------------|
| `typescript` | `*.ts`, `*.tsx` | Strict mode, no `any`, Zod validation |
| `react` | `*.tsx`, `*.jsx` | Server/Client components, hooks rules |
| `api` | `app/api/**`, `pages/api/**` | Seguridad endpoints, rate limiting |
| `security` | **Todos los archivos** | OWASP, secrets, injection prevention |
| `testing` | `*.test.ts`, `*.spec.ts` | AAA pattern, mocking, coverage |
| `git` | Operaciones git | Conventional commits, branch naming |
| `performance` | `*.ts`, `*.tsx` | Bundle size, lazy loading, memoization |

---

## Hooks Automáticos

Se ejecutan automáticamente en cada operación:

### PreToolUse (Antes de ejecutar)
| Hook | Trigger | Acción |
|------|---------|--------|
| `bash-validator.sh` | Bash | Valida comandos peligrosos |
| `file-protection.py` | Edit, Write, Read | Protege archivos sensibles |
| `pre-commit-validation.sh` | Bash (git commit) | Lint, tests antes de commit |
| `cost-estimator.sh` | Todos | Estima costo de operación |
| `compliance-check.sh` | Edit, Write, Read | Detecta PII, secrets |
| `backup-before-edit.sh` | Edit, Write | Backup automático de archivos |

### PostToolUse (Después de ejecutar)
| Hook | Trigger | Acción |
|------|---------|--------|
| `team-notification.sh` | Bash | Notifica al equipo (Slack) |
| `audit-log.sh` | Todos | Log de auditoría |

### UserPromptSubmit (Al enviar prompt)
| Hook | Trigger | Acción |
|------|---------|--------|
| `security-validator.sh` | Siempre | Valida seguridad del prompt |

---

## Output Styles

Cambiar estilo de respuesta:

| Style | Uso | Características |
|-------|-----|-----------------|
| `argentino` | **Por defecto** | Español argentino, voseo, directo |
| `concise` | Respuestas rápidas | Mínimo, directo, solo código |
| `educational` | Aprendizaje | Explicaciones detalladas, ejemplos |
| `senior-dev` | Code review | Crítico, mejores prácticas, trade-offs |
| `debug` | Troubleshooting | Verbose, stack traces, data flow |

---

## MCP Servers Configurados

19 servidores MCP disponibles:

### Productividad
| Server | Función |
|--------|---------|
| `context7` | Documentación actualizada de librerías |
| `filesystem` | Acceso al sistema de archivos |
| `memory` | Memoria persistente entre sesiones |
| `sequential-thinking` | Razonamiento paso a paso |

### Desarrollo
| Server | Función |
|--------|---------|
| `github` | Issues, PRs, repositorios |
| `playwright` | Testing E2E, browser automation |
| `puppeteer` | Web scraping, screenshots |
| `semgrep` | Análisis estático de seguridad |

### Bases de Datos
| Server | Función |
|--------|---------|
| `supabase` | Backend as a Service |
| `postgres` | PostgreSQL directo |

### Integraciones
| Server | Función |
|--------|---------|
| `slack` | Mensajes, canales |
| `linear` | Issue tracking |
| `notion` | Documentación, wikis |
| `sentry` | Error tracking |

### Utilidades
| Server | Función |
|--------|---------|
| `fetch` | HTTP requests |
| `duckduckgo` | Búsquedas web |
| `brave-search` | Búsquedas web (alternativa) |
| `dockerhub` | Imágenes Docker |
| `magic` | UI components (21st.dev) |

---

## Scripts de Automatización

```bash
# Validar configuración
~/.claude/scripts/validate.sh

# Setup inicial / verificar instalación
~/.claude/scripts/setup.sh

# Crear backup de configuración
~/.claude/scripts/backup.sh

# Restaurar desde backup
~/.claude/scripts/restore.sh <backup-name|latest>
```

---

## Templates Disponibles

### GitHub
- `github/ISSUE_TEMPLATE/bug_report.md`
- `github/ISSUE_TEMPLATE/feature_request.md`
- `github/pull_request_template.md`
- `github/workflows/ci.yml`
- `github/workflows/release.yml`
- `github/CODEOWNERS`

### Documentación
- `adr/template.md` - Architecture Decision Records
- `incident/template.md` - Incident reports
- `pr/template.md` - Pull request template

---

## Alerting

Configurado en `~/.claude/alerts/config.json`:

| Alerta | Trigger | Canales |
|--------|---------|---------|
| `high_cost_operation` | Costo > $0.50 | Slack, Log |
| `security_violation` | Intento de acceso a secrets | Slack, Log, Email |
| `build_failure` | Build/test falla | Slack, Log |
| `slow_operation` | Operación > 30s | Log |

---

## TypeScript - ESTRICTO

### NUNCA
```typescript
function process(data: any): any { }        // any
const user = data as User;                   // assertion sin validar
// @ts-ignore                                // ignorar errores
```

### SIEMPRE
```typescript
// Zod para validación runtime
const UserSchema = z.object({
  id: z.number(),
  email: z.string().email(),
  role: z.enum(['admin', 'user']),
});

type User = z.infer<typeof UserSchema>;

function isUser(data: unknown): data is User {
  return UserSchema.safeParse(data).success;
}
```

---

## Naming Conventions

```typescript
// Constants
const MAX_RETRY_ATTEMPTS = 3;

// Classes
class ProductRepository { }

// Functions
function getProductById() { }

// Files
product-repository.ts    // Services
ProductCard.tsx          // Components
use-products.ts          // Hooks
product.types.ts         // Types
```

---

## Next.js Best Practices

### Server Components (por defecto)
```typescript
export default async function ProductsPage() {
  const products = await fetch('...').then(r => r.json());
  return <ProductList products={products} />;
}
```

### Client Components (solo cuando necesario)
```typescript
'use client';
import { useState } from 'react';

export function InteractiveCard() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>;
}
```

**Cuándo usar Client Components:**
- Hooks (useState, useEffect, etc.)
- Event handlers
- Browser APIs

---

## Git - Conventional Commits

```bash
# Format
type(scope): description

# Types
feat:      Nueva feature
fix:       Bug fix
refactor:  Refactoring
perf:      Performance
test:      Tests
docs:      Documentación
chore:     Mantenimiento

# Ejemplos
feat(products): add price filter
fix(auth): resolve JWT expiration
```

---

## Testing - AAA Pattern

```typescript
describe('Service', () => {
  it('should do something', async () => {
    // Arrange
    const input = { id: 1 };

    // Act
    const result = await service.process(input);

    // Assert
    expect(result).toEqual(expected);
  });
});
```

**Target:** 80%+ coverage

---

## Checklist Pre-Commit

```bash
pnpm outdated              # 1. Verificar versiones
bun test                   # 2. Tests
pnpm biome check --write . # 3. Lint y format
pnpm typecheck             # 4. Type check
pnpm build                 # 5. Build
git commit -m "feat: ..."  # 6. Commit
```

---

## Prioridades

1. **Seguridad** > Features
2. **Type Safety** > Conveniencia
3. **Performance** > Complejidad
4. **Mantenibilidad** > Cleverness
5. **Tests** > Documentación

---

## Anti-Patterns

```
NUNCA:
- usar any
- mutar estado directamente
- hardcodear secrets
- fetch sin error handling
- SQL string concatenation
- passwords en plain text
- innerHTML con user input
- ignorar TypeScript errors
- commits genéricos
- usar Prettier (usar Biome)
- usar npm cuando hay pnpm/bun
```

---

## Quick Reference

```bash
# Agents
@architect, @builder, @debugger, @devops, @security-auditor, @docs-writer, @test-engineer

# Skills principales
/commit, /pr, /test, /scaffold, /audit, /refactor, /docs, /monitor

# Scripts
~/.claude/scripts/validate.sh
~/.claude/scripts/backup.sh
~/.claude/scripts/restore.sh latest
```

---

**Este archivo define estándares GLOBALES. Los proyectos individuales pueden tener su propio CLAUDE.md específico que complementa estas reglas.**
