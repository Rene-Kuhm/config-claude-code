# Security Rules

Estas reglas de seguridad se aplican **SIEMPRE** a todo el código.

## 🔴 NUNCA (Bloquear)

### Credentials en Código
```typescript
// ❌ PROHIBIDO - NUNCA hardcodear
const API_KEY = "sk-abc123";
const PASSWORD = "admin123";
const JWT_SECRET = "mysecret";
const DATABASE_URL = "postgres://user:pass@host/db";

// ✅ CORRECTO - Variables de entorno
const API_KEY = process.env.API_KEY;
const JWT_SECRET = process.env.JWT_SECRET;
```

### SQL Injection
```typescript
// ❌ PROHIBIDO - Interpolación directa
const query = `SELECT * FROM users WHERE id = ${userId}`;
const query = `SELECT * FROM users WHERE name = '${name}'`;

// ✅ CORRECTO - Queries parametrizadas
const query = `SELECT * FROM users WHERE id = $1`;
await db.query(query, [userId]);

// ✅ CORRECTO - ORM (Prisma)
await prisma.user.findUnique({ where: { id: userId } });
```

### XSS (Cross-Site Scripting)
```typescript
// ❌ PROHIBIDO - HTML sin sanitizar
element.innerHTML = userInput;
<div dangerouslySetInnerHTML={{ __html: userContent }} />

// ✅ CORRECTO - Sanitizar
import DOMPurify from 'dompurify';
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(content) }} />

// ✅ MEJOR - Usar texto plano
<div>{userContent}</div>
```

### Eval y Function Constructor
```typescript
// ❌ PROHIBIDO
eval(userInput);
new Function(userInput)();
setTimeout(userInput, 1000);

// Estas funciones NUNCA deben recibir input de usuario
```

## 🟠 Autenticación

### Passwords
```typescript
import bcrypt from 'bcrypt';

// ✅ Hash con bcrypt (cost factor 10-12)
const hashedPassword = await bcrypt.hash(password, 10);

// ✅ Comparar de forma segura
const isValid = await bcrypt.compare(inputPassword, hashedPassword);

// ❌ NUNCA
if (password === storedPassword) // Comparación timing-safe requerida
```

### JWT
```typescript
import jwt from 'jsonwebtoken';

// ✅ CORRECTO
const token = jwt.sign(
  { userId: user.id, role: user.role },
  process.env.JWT_SECRET!,
  {
    expiresIn: '15m',  // Corta expiración
    algorithm: 'HS256'
  }
);

// ✅ Refresh tokens para sesiones largas
const refreshToken = jwt.sign(
  { userId: user.id },
  process.env.JWT_REFRESH_SECRET!,
  { expiresIn: '7d' }
);

// ❌ NUNCA
jwt.sign(payload, secret); // Sin expiración
jwt.sign(payload, secret, { algorithm: 'none' }); // Sin algoritmo
```

### Cookies
```typescript
// ✅ CORRECTO
res.cookies.set('token', token, {
  httpOnly: true,     // No accesible desde JS
  secure: true,       // Solo HTTPS
  sameSite: 'strict', // CSRF protection
  maxAge: 60 * 15,    // 15 minutos
  path: '/',
});

// ❌ NUNCA almacenar tokens en localStorage
localStorage.setItem('token', token); // Vulnerable a XSS
```

## 🟡 Input Validation

### Siempre en el Servidor
```typescript
import { z } from 'zod';

const UserInputSchema = z.object({
  email: z.string().email().max(255),
  name: z.string().min(1).max(100).regex(/^[\w\s-]+$/),
  age: z.number().int().min(0).max(150),
  url: z.string().url().optional(),
});

// Validar ANTES de usar
const result = UserInputSchema.safeParse(input);
if (!result.success) {
  throw new ValidationError(result.error);
}
```

### Sanitización
```typescript
import xss from 'xss';

// Para HTML
const safeHtml = xss(userHtml);

// Para SQL (usar ORM/prepared statements)
// Para comandos (NUNCA ejecutar input de usuario directamente)
```

## 🟢 Headers de Seguridad

```typescript
// next.config.js
const securityHeaders = [
  {
    key: 'X-DNS-Prefetch-Control',
    value: 'on'
  },
  {
    key: 'Strict-Transport-Security',
    value: 'max-age=63072000; includeSubDomains; preload'
  },
  {
    key: 'X-Frame-Options',
    value: 'SAMEORIGIN'
  },
  {
    key: 'X-Content-Type-Options',
    value: 'nosniff'
  },
  {
    key: 'Referrer-Policy',
    value: 'strict-origin-when-cross-origin'
  },
  {
    key: 'Content-Security-Policy',
    value: "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline';"
  }
];
```

## 🔍 Logging Seguro

```typescript
// ❌ PROHIBIDO - Loguear datos sensibles
console.log('User login:', { email, password });
logger.info('Payment:', { cardNumber, cvv });

// ✅ CORRECTO - Redactar datos sensibles
console.log('User login:', { email, password: '[REDACTED]' });
logger.info('Payment:', { last4: cardNumber.slice(-4) });

// ✅ MEJOR - Usar logger con redaction automática
const logger = pino({
  redact: ['password', 'token', 'cardNumber', 'cvv', 'ssn']
});
```

## 🛡️ OWASP Top 10 Checklist

| Vulnerabilidad | Mitigación |
|----------------|------------|
| A01 Broken Access Control | Verificar permisos en cada request |
| A02 Cryptographic Failures | Usar bcrypt, TLS, cifrado AES-256 |
| A03 Injection | Prepared statements, ORM, validación |
| A04 Insecure Design | Threat modeling, security requirements |
| A05 Security Misconfiguration | Headers seguros, no defaults |
| A06 Vulnerable Components | `npm audit`, actualizaciones |
| A07 Auth Failures | MFA, rate limiting, secure sessions |
| A08 Data Integrity | Firmas digitales, CSP, SRI |
| A09 Logging Failures | Logs completos, sin datos sensibles |
| A10 SSRF | Validar URLs, whitelist de dominios |

## Auditoría Regular

```bash
# Verificar vulnerabilidades
pnpm audit
npm audit

# Snyk (más completo)
npx snyk test

# Dependencias desactualizadas
pnpm outdated
```
