#!/usr/bin/env bash
# Compliance Check Hook
# Verifica cumplimiento SOC2, GDPR, HIPAA y otras regulaciones
# Enterprise Edition v1.0

set -euo pipefail

# Colores
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Leer input JSON
INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // {}')

# Patrones de datos sensibles (PII - Personally Identifiable Information)
PII_PATTERNS=(
    # SSN (Social Security Number)
    '\b[0-9]{3}-[0-9]{2}-[0-9]{4}\b'
    # Credit Card
    '\b[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}\b'
    # Email en comentarios con datos reales
    '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b.*password'
    # Teléfono US
    '\b\(?[0-9]{3}\)?[-. ]?[0-9]{3}[-. ]?[0-9]{4}\b'
    # IP Address (puede ser PII en contexto GDPR)
    '\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b'
)

# Patrones de credenciales hardcodeadas
CREDENTIAL_PATTERNS=(
    'password\s*=\s*["\x27][^"\x27]{4,}["\x27]'
    'api[_-]?key\s*=\s*["\x27][^"\x27]{8,}["\x27]'
    'secret\s*=\s*["\x27][^"\x27]{8,}["\x27]'
    'token\s*=\s*["\x27][^"\x27]{16,}["\x27]'
    'private[_-]?key\s*=\s*["\x27]'
    'AWS[_-]?ACCESS[_-]?KEY[_-]?ID\s*=\s*["\x27]?AKI'
    'AKIA[0-9A-Z]{16}'
)

# Patrones de logging inseguro
INSECURE_LOGGING=(
    'console\.log.*password'
    'console\.log.*token'
    'console\.log.*secret'
    'console\.log.*key'
    'print.*password'
    'logger\..*password'
)

check_content() {
    local content="$1"
    local violations=()

    # Verificar PII
    for pattern in "${PII_PATTERNS[@]}"; do
        if echo "$content" | grep -qE "$pattern" 2>/dev/null; then
            violations+=("Potential PII detected: $pattern")
        fi
    done

    # Verificar credenciales hardcodeadas
    for pattern in "${CREDENTIAL_PATTERNS[@]}"; do
        if echo "$content" | grep -qiE "$pattern" 2>/dev/null; then
            violations+=("Hardcoded credential detected")
        fi
    done

    # Verificar logging inseguro
    for pattern in "${INSECURE_LOGGING[@]}"; do
        if echo "$content" | grep -qiE "$pattern" 2>/dev/null; then
            violations+=("Insecure logging detected: sensitive data in logs")
        fi
    done

    if [[ ${#violations[@]} -gt 0 ]]; then
        echo "${violations[*]}"
        return 1
    fi

    return 0
}

case "$TOOL_NAME" in
    "Write"|"Edit")
        CONTENT=$(echo "$TOOL_INPUT" | jq -r '.content // .new_string // empty')
        FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')

        if [[ -n "$CONTENT" ]]; then
            VIOLATIONS=$(check_content "$CONTENT" 2>&1) || true

            if [[ -n "$VIOLATIONS" ]]; then
                echo -e "${RED}COMPLIANCE WARNING${NC}" >&2
                echo -e "${YELLOW}File: $FILE_PATH${NC}" >&2
                echo -e "${YELLOW}Issues found:${NC}" >&2
                echo "$VIOLATIONS" | tr '|' '\n' | while read -r v; do
                    echo -e "  - $v" >&2
                done
                echo "" >&2
                echo -e "${YELLOW}Please review before proceeding.${NC}" >&2
                echo -e "${YELLOW}For SOC2/GDPR compliance:${NC}" >&2
                echo "  - Remove hardcoded credentials" >&2
                echo "  - Use environment variables for secrets" >&2
                echo "  - Ensure PII is not logged or exposed" >&2
                echo "  - Use proper data encryption" >&2

                # Solo advertir, no bloquear (para permitir falsos positivos)
                # Para bloquear: exit 2
            fi
        fi
        ;;

    "Bash")
        COMMAND=$(echo "$TOOL_INPUT" | jq -r '.command // empty')

        # Verificar comandos que podrían exponer datos sensibles
        if [[ "$COMMAND" =~ (curl.*-d.*password|wget.*password) ]]; then
            echo -e "${YELLOW}WARNING: Potential credential exposure in HTTP request${NC}" >&2
        fi

        # Verificar exportación de datos sin cifrado
        if [[ "$COMMAND" =~ (mysqldump|pg_dump|mongodump) ]]; then
            if [[ ! "$COMMAND" =~ (--ssl|encryption|gpg) ]]; then
                echo -e "${YELLOW}WARNING: Database export without encryption detected${NC}" >&2
                echo "Consider encrypting sensitive data exports for compliance." >&2
            fi
        fi
        ;;
esac

# Siempre permitir (hook es advisory)
exit 0
