# Team Standards - Enterprise Development

## Team Information

| Field | Value |
|-------|-------|
| Organization | My Organization |
| Team | Core Engineering |
| Updated | 2024-12-25 |

---

## Code Standards

### TypeScript

```typescript
// Configuración tsconfig.json requerida
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "exactOptionalPropertyTypes": true
  }
}
```

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Variables | camelCase | `userData`, `isLoading` |
| Constants | SCREAMING_SNAKE | `MAX_RETRIES`, `API_URL` |
| Functions | camelCase + verb | `getUserById`, `validateInput` |
| Classes | PascalCase | `UserService`, `ApiClient` |
| Interfaces | PascalCase + prefix I (opcional) | `User`, `IUserRepository` |
| Types | PascalCase | `UserRole`, `ApiResponse` |
| Files | kebab-case | `user-service.ts`, `api-client.ts` |
| React Components | PascalCase | `UserCard.tsx`, `LoginForm.tsx` |
| Hooks | use + PascalCase | `useAuth.ts`, `useProducts.ts` |

### File Structure

```
src/
├── app/                    # Next.js App Router
│   ├── (auth)/            # Route groups
│   ├── api/               # API routes
│   └── layout.tsx
├── components/
│   ├── ui/                # Reusable UI components
│   └── features/          # Feature-specific components
├── lib/                   # Utilities and helpers
├── services/              # Business logic
├── hooks/                 # Custom React hooks
├── types/                 # TypeScript types
└── config/                # Configuration files
```

---

## Git Workflow

### Branch Naming

```
feature/<ticket>-<description>
bugfix/<ticket>-<description>
hotfix/<ticket>-<description>
release/<version>

Examples:
feature/PROJ-123-user-authentication
bugfix/PROJ-456-fix-login-timeout
hotfix/PROJ-789-security-patch
release/2.1.0
```

### Commit Messages

Seguimos Conventional Commits:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

Types permitidos:
- `feat`: Nueva funcionalidad
- `fix`: Bug fix
- `docs`: Documentación
- `style`: Formato (sin cambio de lógica)
- `refactor`: Refactoring
- `perf`: Performance
- `test`: Tests
- `chore`: Mantenimiento

### Pull Request Template

Todo PR debe incluir:
- Descripción clara del cambio
- Link al ticket (si aplica)
- Checklist de verificación
- Screenshots (si hay cambios de UI)
- Test plan

---

## Security Requirements

### OWASP Top 10 Compliance

1. **Injection**: Usar queries parametrizadas
2. **Broken Auth**: JWT con expiración corta, refresh tokens
3. **Sensitive Data**: Cifrar en reposo y tránsito
4. **XXE**: Deshabilitar DTDs en XML parsers
5. **Broken Access**: Verificar permisos en cada request
6. **Misconfig**: No exponer stack traces, usar headers seguros
7. **XSS**: Sanitizar input, usar CSP headers
8. **Insecure Deserialization**: Validar tipos con Zod
9. **Components**: Mantener dependencias actualizadas
10. **Logging**: No loguear datos sensibles

### Secrets Management

```bash
# NUNCA en código
❌ const API_KEY = "sk-abc123";

# Siempre variables de entorno
✅ const API_KEY = process.env.API_KEY;

# Validación al inicio
if (!process.env.API_KEY) {
  throw new Error('API_KEY is required');
}
```

---

## Testing Requirements

### Coverage Mínimo

| Tipo | Mínimo |
|------|--------|
| Unit Tests | 80% |
| Integration | 60% |
| E2E | Critical paths |

### Estructura de Test

```typescript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create a user with valid data', async () => {
      // Arrange
      const input = { email: 'test@example.com' };

      // Act
      const result = await userService.createUser(input);

      // Assert
      expect(result).toMatchObject({ email: 'test@example.com' });
    });

    it('should throw error with invalid email', async () => {
      // Arrange
      const input = { email: 'invalid' };

      // Act & Assert
      await expect(userService.createUser(input))
        .rejects.toThrow('Invalid email');
    });
  });
});
```

---

## Code Review Guidelines

### Reviewer Checklist

- [ ] Código compila sin errores
- [ ] Tests pasan y cubren nuevas funcionalidades
- [ ] No hay código comentado
- [ ] No hay console.log/print statements
- [ ] Error handling adecuado
- [ ] No hay secrets hardcodeados
- [ ] Documentación actualizada (si aplica)
- [ ] Performance considerada
- [ ] Accessibility considerada (si UI)

### Response Time

| Type | Max Response |
|------|--------------|
| Critical/Hotfix | 2 hours |
| Regular PR | 24 hours |
| Large refactor | 48 hours |

---

## Deployment

### Environments

| Environment | Branch | Auto-deploy |
|-------------|--------|-------------|
| Development | develop | Yes |
| Staging | main | Yes |
| Production | main + tag | Manual |

### Pre-deploy Checklist

- [ ] All tests passing
- [ ] Build successful
- [ ] Security audit passed
- [ ] Database migrations reviewed
- [ ] Feature flags configured
- [ ] Rollback plan documented

---

## Communication

### Channels

- **Urgent Issues**: Slack #incidents
- **Code Questions**: Slack #engineering
- **PR Reviews**: GitHub notifications
- **Architecture Decisions**: ADR documents

### On-Call

- Rotation: Weekly
- Response time: 15 minutes for P1
- Escalation path documented in Confluence

---

## Tools & Versions

| Tool | Version | Notes |
|------|---------|-------|
| Node.js | 20 LTS | Required |
| pnpm | 8+ | Package manager |
| TypeScript | 5.3+ | Strict mode |
| Next.js | 15+ | App Router |
| React | 19+ | Server Components |
| Biome | 1.9+ | Linter & Formatter |
| Vitest | 2.0+ | Test runner |

---

*Este documento es mantenido por el equipo de Engineering y debe ser revisado trimestralmente.*
