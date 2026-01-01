#!/bin/bash
# Ralph Loop - Autonomous iteration until completion
# Inspired by Ralph Wiggum: "Me fail English? That's unpossible!"

# Configuración
RALPH_STATE_FILE="/tmp/ralph-loop-state"
RALPH_ENABLED_FILE="/tmp/ralph-loop-enabled"
SAFE_WORD="${RALPH_SAFE_WORD:-RALPH_COMPLETE}"
MAX_ITERATIONS="${RALPH_MAX_ITERATIONS:-50}"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Leer el transcript/output de Claude (viene por stdin en Stop hook)
CLAUDE_OUTPUT=$(cat)

# Función para logging
log_ralph() {
    echo -e "${PURPLE}[🍩 Ralph]${NC} $1" >&2
}

# Verificar si Ralph Loop está habilitado
if [[ ! -f "$RALPH_ENABLED_FILE" ]]; then
    # Ralph no está activo, dejar que termine normalmente
    exit 0
fi

# Leer estado actual
if [[ -f "$RALPH_STATE_FILE" ]]; then
    source "$RALPH_STATE_FILE"
else
    ITERATION=0
    ORIGINAL_PROMPT=""
fi

# Incrementar iteración
ITERATION=$((ITERATION + 1))

# Verificar límite de iteraciones
if [[ $ITERATION -gt $MAX_ITERATIONS ]]; then
    log_ralph "${RED}Máximo de iteraciones alcanzado ($MAX_ITERATIONS). Deteniendo.${NC}"
    rm -f "$RALPH_STATE_FILE" "$RALPH_ENABLED_FILE"
    exit 0
fi

# Buscar la palabra clave de completado
if echo "$CLAUDE_OUTPUT" | grep -q "$SAFE_WORD"; then
    log_ralph "${GREEN}✅ Tarea completada! Safe word detectada después de $ITERATION iteraciones.${NC}"
    rm -f "$RALPH_STATE_FILE" "$RALPH_ENABLED_FILE"
    exit 0
fi

# Verificar si hay errores críticos que deberían detener el loop
if echo "$CLAUDE_OUTPUT" | grep -qiE "(fatal error|critical failure|cannot continue|abort)"; then
    log_ralph "${RED}⚠️ Error crítico detectado. Deteniendo loop.${NC}"
    rm -f "$RALPH_STATE_FILE" "$RALPH_ENABLED_FILE"
    exit 0
fi

# La tarea no está completa - continuar el loop
log_ralph "${YELLOW}Iteración $ITERATION - Tarea no completada. Continuando...${NC}"

# Guardar estado
cat > "$RALPH_STATE_FILE" << EOF
ITERATION=$ITERATION
ORIGINAL_PROMPT="$ORIGINAL_PROMPT"
EOF

# Bloquear la salida y solicitar continuación
# El output JSON indica a Claude Code que debe continuar
cat << EOF
{
  "decision": "block",
  "reason": "Ralph Loop activo - iteración $ITERATION/$MAX_ITERATIONS. Continuá trabajando hasta completar la tarea. Cuando termines, incluí '$SAFE_WORD' en tu respuesta."
}
EOF

exit 0
