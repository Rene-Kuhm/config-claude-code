---
description: "Run complete security audit of codebase using OWASP Top 10"
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - mcp__semgrep__scan
---

# Security Audit Command

Ejecuta una auditoría completa de seguridad del codebase.

## Scope del Audit

1. **Dependency Vulnerabilities** - CVEs en dependencias
2. **Code Analysis** - Patrones inseguros en código
3. **Secrets Detection** - Credenciales expuestas
4. **Configuration Review** - Configs de seguridad
5. **OWASP Top 10** - Vulnerabilidades comunes

## Flujo de Ejecución

### 1. Dependency Audit

```bash
# NPM/PNPM audit
pnpm audit --json > audit-deps.json

# Snyk (si disponible)
snyk test --json > snyk-report.json
```

### 2. Static Analysis con Semgrep

```bash
# Usar MCP semgrep
mcp__semgrep__scan con reglas OWASP

# Reglas a aplicar:
# - p/owasp-top-ten
# - p/javascript
# - p/typescript
# - p/react
# - p/nodejs
```

### 3. Secrets Detection

```bash
# Buscar patrones de secrets
grep -rn "password\s*=" --include="*.ts" --include="*.js"
grep -rn "api.?key\s*=" --include="*.ts" --include="*.js"
grep -rn "secret\s*=" --include="*.ts" --include="*.js"

# Verificar .env files no commiteados
git ls-files | grep -E "\.env"
```

### 4. Configuration Review

Revisar archivos:
- `next.config.js` - Headers de seguridad
- `middleware.ts` - Auth middleware
- `.env.example` - No contiene valores reales
- `tsconfig.json` - strict mode

### 5. OWASP Top 10 Manual Review

Usar skill `/security-review` para análisis detallado de:

- A01: Broken Access Control
- A02: Cryptographic Failures
- A03: Injection
- A04: Insecure Design
- A05: Security Misconfiguration
- A06: Vulnerable Components
- A07: Authentication Failures
- A08: Data Integrity Failures
- A09: Logging Failures
- A10: SSRF

## Output

Generar reporte en formato:

```markdown
# Security Audit Report

**Date:** YYYY-MM-DD
**Auditor:** Claude Code
**Scope:** Full codebase

## Summary
- Critical: X
- High: X
- Medium: X
- Low: X

## Findings

### 🔴 Critical

#### [FINDING-001] SQL Injection in user endpoint
- **Location:** src/api/users.ts:45
- **Description:** ...
- **Remediation:** ...

### 🟡 High
...

## Recommendations
1. ...
2. ...

## Compliance
- [ ] OWASP Top 10
- [ ] PCI-DSS (if applicable)
- [ ] GDPR (if applicable)
```

## Frecuencia Recomendada

- **Pre-release:** Siempre antes de deploy a producción
- **Scheduled:** Semanalmente en CI/CD
- **On-demand:** Después de cambios significativos
