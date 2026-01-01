#!/bin/bash
# Bash Validator Hook - Bloquea comandos peligrosos
# Previene ejecución de comandos destructivos en producción

set -e

# Leer input desde stdin
input=$(cat)

# Extraer el comando del JSON
command=$(echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)

# Si no hay comando, permitir
if [ -z "$command" ]; then
    exit 0
fi

# Patrones de comandos peligrosos
DANGEROUS_PATTERNS=(
    'rm\s+-rf\s+/'
    'rm\s+-rf\s+\*'
    'rm\s+-rf\s+~'
    'rm\s+--no-preserve-root'
    'mkfs\.'
    'dd\s+if=.+of=/dev/'
    ':\(\)\s*{\s*:\|:\s*&\s*}\s*;'  # Fork bomb
    'chmod\s+-R\s+777\s+/'
    'chown\s+-R.+/'
    'DROP\s+DATABASE'
    'DROP\s+TABLE'
    'DELETE\s+FROM\s+\w+\s*;?\s*$'  # DELETE sin WHERE
    'TRUNCATE\s+TABLE'
    'git\s+push\s+--force\s+(origin\s+)?(main|master)'
    'git\s+push\s+-f\s+(origin\s+)?(main|master)'
    'terraform\s+destroy\s+-auto-approve'
    'kubectl\s+delete\s+(namespace|ns)\s+'
    'kubectl\s+delete\s+--all'
    'docker\s+system\s+prune\s+-a\s+-f'
    'curl.+\|\s*bash'
    'curl.+\|\s*sh'
    'wget.+-O\s*-\s*\|'
    'sudo\s+rm'
    'npm\s+publish'
    'pnpm\s+publish'
    'yarn\s+publish'
)

# Verificar cada patrón
for pattern in "${DANGEROUS_PATTERNS[@]}"; do
    if echo "$command" | grep -qiE "$pattern"; then
        echo "BLOCKED: Dangerous command pattern detected"
        echo "Command: $command"
        echo "Pattern matched: $pattern"
        exit 2  # Exit 2 = deny/block
    fi
done

# Verificar si está intentando ejecutar en directorio raíz
if echo "$command" | grep -qE '^\s*cd\s+/\s*[;&|]'; then
    echo "WARNING: Command changing to root directory"
fi

# Si no se detecta nada peligroso, permitir
exit 0
