---
description: "Deploy application to production with safety checks and validations"
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
---

# Deploy Command

Ejecuta un deploy seguro a producción con validaciones previas.

## Pre-Deploy Checklist

Antes de proceder con el deploy, validar:

1. **Tests** - Ejecutar suite completa de tests
2. **Build** - Verificar que el build compila sin errores
3. **Type Check** - Verificar tipos TypeScript
4. **Lint** - Sin errores de linting
5. **Security** - Escaneo de vulnerabilidades
6. **Environment** - Variables de entorno configuradas

## Flujo de Ejecución

```bash
# 1. Verificar branch actual
git branch --show-current

# 2. Verificar que no hay cambios uncommitted
git status --porcelain

# 3. Pull últimos cambios
git pull origin main

# 4. Instalar dependencias
pnpm install --frozen-lockfile

# 5. Type check
pnpm typecheck

# 6. Lint
pnpm lint

# 7. Tests
pnpm test

# 8. Build
pnpm build

# 9. Security audit
pnpm audit --audit-level=high

# 10. Deploy (según plataforma)
# Vercel: vercel --prod
# Docker: docker build && docker push
# K8s: kubectl apply -f k8s/
```

## Validaciones de Seguridad

- No hay secrets hardcodeados
- Variables de entorno de producción configuradas
- SSL/TLS habilitado
- Headers de seguridad configurados

## Rollback Plan

Si el deploy falla:

```bash
# Revertir al último deploy exitoso
vercel rollback

# O para K8s
kubectl rollout undo deployment/app
```

## Post-Deploy

1. Smoke tests en producción
2. Verificar métricas
3. Monitorear errores en Sentry
4. Notificar al equipo
