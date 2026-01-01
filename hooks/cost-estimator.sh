#!/usr/bin/env bash
# Cost Estimator Hook
# Estima y advierte sobre operaciones potencialmente costosas
# Enterprise Edition v1.0

set -euo pipefail

# Colores
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Leer input JSON
INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // {}')

# Costos estimados por operación (en tokens aproximados)
declare -A COST_WEIGHTS=(
    ["Read"]=100
    ["Glob"]=50
    ["Grep"]=200
    ["Bash"]=150
    ["Write"]=80
    ["Edit"]=60
    ["Task"]=500
    ["WebSearch"]=300
    ["WebFetch"]=400
)

# Obtener peso base de la operación
BASE_WEIGHT=${COST_WEIGHTS[$TOOL_NAME]:-100}

# Factores de multiplicación según parámetros
MULTIPLIER=1

case "$TOOL_NAME" in
    "Read")
        # Archivos grandes cuestan más
        FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')
        if [[ -n "$FILE_PATH" && -f "$FILE_PATH" ]]; then
            FILE_SIZE=$(wc -c < "$FILE_PATH" 2>/dev/null || echo 0)
            if [[ $FILE_SIZE -gt 100000 ]]; then
                MULTIPLIER=3
                echo -e "${YELLOW}Large file read (~$(($FILE_SIZE/1000))KB)${NC}" >&2
            fi
        fi
        ;;
    "Glob")
        # Patrones muy amplios
        PATTERN=$(echo "$TOOL_INPUT" | jq -r '.pattern // empty')
        if [[ "$PATTERN" == "**/*" || "$PATTERN" == "*" ]]; then
            MULTIPLIER=5
            echo -e "${YELLOW}Broad glob pattern - may return many files${NC}" >&2
        fi
        ;;
    "Grep")
        # Búsquedas sin filtro
        PATTERN=$(echo "$TOOL_INPUT" | jq -r '.pattern // empty')
        GLOB=$(echo "$TOOL_INPUT" | jq -r '.glob // empty')
        if [[ -z "$GLOB" && ${#PATTERN} -lt 3 ]]; then
            MULTIPLIER=4
            echo -e "${YELLOW}Broad grep search - consider adding filters${NC}" >&2
        fi
        ;;
    "Task")
        # Subagentes son costosos
        MULTIPLIER=3
        SUBAGENT_TYPE=$(echo "$TOOL_INPUT" | jq -r '.subagent_type // empty')
        if [[ "$SUBAGENT_TYPE" == "Explore" ]]; then
            MULTIPLIER=2
            echo -e "${CYAN}Using efficient Explore agent${NC}" >&2
        fi
        ;;
    "WebSearch"|"WebFetch")
        # Operaciones web son costosas
        echo -e "${YELLOW}Web operation - external API call${NC}" >&2
        ;;
esac

ESTIMATED_COST=$((BASE_WEIGHT * MULTIPLIER))

# Advertir si el costo es alto
if [[ $ESTIMATED_COST -gt 1000 ]]; then
    echo -e "${YELLOW}High cost operation (~$ESTIMATED_COST tokens estimated)${NC}" >&2
fi

# Siempre permitir, solo informar
exit 0
