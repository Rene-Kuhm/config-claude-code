---
description: "Crear commit con Conventional Commits automáticamente"
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
---

# Commit Command

Analiza los cambios en el repositorio y crea un commit siguiendo Conventional Commits.

## Instrucciones

1. Ejecuta `git status` para ver los cambios
2. Ejecuta `git diff` para entender qué cambió
3. Ejecuta `git log --oneline -5` para ver el estilo de commits recientes
4. Analiza los cambios y determina:
   - **type**: feat, fix, docs, style, refactor, perf, test, build, ci, chore
   - **scope**: área del código afectada
   - **description**: resumen en imperativo
5. Ejecuta `git add .` (o archivos específicos)
6. Crea el commit con el mensaje generado

## Formato del Commit

```bash
git commit -m "$(cat <<'EOF'
type(scope): description

- Bullet point 1
- Bullet point 2

🤖 Generated with [Claude Code](https://claude.com/code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

## Reglas

- Subject line máximo 72 caracteres
- Usar imperativo: "add" no "added"
- No terminar con punto
- Body opcional pero recomendado para cambios significativos
- Incluir `Closes #123` si aplica

¡Analiza los cambios y crea el commit!
