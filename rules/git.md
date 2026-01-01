# Git Rules

Reglas para commits, branches y flujo de trabajo Git.

## Conventional Commits (Obligatorio)

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types Permitidos

| Type | Uso | Ejemplo |
|------|-----|---------|
| `feat` | Nueva funcionalidad | `feat(auth): add Google login` |
| `fix` | Bug fix | `fix(cart): resolve total calculation` |
| `docs` | Documentación | `docs(readme): update installation` |
| `style` | Formato (no lógica) | `style: format with Biome` |
| `refactor` | Refactoring | `refactor(api): extract validation` |
| `perf` | Performance | `perf(images): add lazy loading` |
| `test` | Tests | `test(auth): add login tests` |
| `build` | Build/deps | `build(deps): upgrade React` |
| `ci` | CI/CD | `ci: add deploy workflow` |
| `chore` | Mantenimiento | `chore: update scripts` |

### Reglas del Mensaje

```typescript
// ✅ CORRECTO
feat(products): add price filtering
fix(checkout): resolve payment timeout on slow networks

// ❌ INCORRECTO
added new feature          // No type, pasado
feat: stuff                // Muy vago
FEAT(AUTH): ADD LOGIN      // No usar mayúsculas
feat(auth): add login.     // No punto al final
```

## Branch Naming

```
feature/<ticket>-<description>
bugfix/<ticket>-<description>
hotfix/<ticket>-<description>
release/<version>

# Ejemplos
feature/PROJ-123-user-authentication
bugfix/PROJ-456-fix-login-timeout
hotfix/PROJ-789-security-patch
release/2.1.0
```

## Prohibiciones

### NUNCA Hacer

```bash
# ❌ PROHIBIDO - Force push a main/master
git push --force origin main
git push -f origin master

# ❌ PROHIBIDO - Commit directo a main
git commit  # (estando en main)

# ❌ PROHIBIDO - Secrets en commits
git add .env
git add credentials.json

# ❌ PROHIBIDO - Commits gigantes
git add .  # Sin revisar qué incluye
```

### Siempre Hacer

```bash
# ✅ Revisar antes de commit
git status
git diff --staged

# ✅ Commits atómicos (una cosa por commit)
git add src/components/Button.tsx
git commit -m "feat(ui): add Button component"

# ✅ Pull antes de push
git pull --rebase origin main
git push
```

## Pre-commit Checklist

- [ ] Tests pasan localmente
- [ ] No hay `console.log` / `debugger`
- [ ] No hay código comentado
- [ ] Lint sin errores
- [ ] Tipos de TypeScript correctos
- [ ] No hay secrets hardcodeados

## Git Hooks Recomendados

```bash
# .husky/pre-commit
pnpm lint-staged

# .husky/commit-msg
pnpm commitlint --edit $1

# .husky/pre-push
pnpm test
```

## Merge vs Rebase

| Situación | Usar |
|-----------|------|
| Feature → main | Squash merge |
| Actualizar feature branch | Rebase |
| Hotfix | Merge (mantener historia) |
| Release | Merge con tag |
