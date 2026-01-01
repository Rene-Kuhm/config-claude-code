---
description: "Crear Pull Request con descripción automática"
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
---

# Pull Request Command

Crea un Pull Request analizando todos los commits de la rama actual.

## Instrucciones

1. Verifica la rama actual: `git branch --show-current`
2. Verifica si hay cambios sin commit: `git status`
3. Push la rama si es necesario: `git push -u origin HEAD`
4. Analiza commits: `git log origin/main..HEAD --oneline`
5. Analiza cambios: `git diff origin/main --name-only`
6. Crea el PR con `gh pr create`

## Template de PR

```bash
gh pr create --title "type(scope): description" --body "$(cat <<'EOF'
## Summary

Brief description of what this PR does.

## Changes

- Change 1
- Change 2
- Change 3

## Type of Change

- [ ] 🐛 Bug fix
- [ ] ✨ New feature
- [ ] 💥 Breaking change
- [ ] 📝 Documentation
- [ ] ♻️ Refactoring

## Testing

Describe how to test the changes.

## Checklist

- [ ] Code follows project guidelines
- [ ] Self-review completed
- [ ] Tests added/updated
- [ ] Documentation updated

---
🤖 Generated with [Claude Code](https://claude.com/code)
EOF
)"
```

## Opciones

- `--draft`: Crear como draft PR
- `--base develop`: Cambiar rama base
- `--reviewer user1,user2`: Asignar reviewers

¡Analiza la rama y crea el PR!
