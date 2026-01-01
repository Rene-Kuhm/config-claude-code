#!/bin/bash
# Security Validator Hook - Detecta secretos en el input del usuario
# Bloquea si detecta patrones de secretos/credenciales

set -e

# Leer input desde stdin
input=$(cat)

# Extraer el user_input del JSON
user_input=$(echo "$input" | jq -r '.user_input // empty' 2>/dev/null)

# Patrones de secretos a detectar
PATTERNS=(
    'password\s*[=:]\s*["\047][^"\047]+'
    'secret\s*[=:]\s*["\047][^"\047]+'
    'api[_-]?key\s*[=:]\s*["\047][^"\047]+'
    'token\s*[=:]\s*["\047][^"\047]+'
    'private[_-]?key\s*[=:]\s*["\047][^"\047]+'
    'aws[_-]?secret'
    'AKIA[0-9A-Z]{16}'  # AWS Access Key
    'sk-[a-zA-Z0-9]{48}'  # OpenAI API Key
    'ghp_[a-zA-Z0-9]{36}'  # GitHub Personal Access Token
    'gho_[a-zA-Z0-9]{36}'  # GitHub OAuth Token
    'xox[baprs]-[0-9a-zA-Z]+'  # Slack Token
)

# Verificar cada patrón
for pattern in "${PATTERNS[@]}"; do
    if echo "$user_input" | grep -qiE "$pattern"; then
        echo "BLOCKED: Potential secret/credential detected in input"
        echo "Pattern matched: $pattern"
        exit 2  # Exit 2 = deny/block
    fi
done

# Si no se detecta nada, permitir
exit 0
