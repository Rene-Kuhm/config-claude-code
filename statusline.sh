#!/bin/bash
# ============================================================================
# Claude Code Status Line - Optimizado para Warp
# ============================================================================
# Diseñado para verse genial en Warp terminal
# Compatible con Nerd Fonts

# Parse JSON input
INPUT=$(cat)

# Extract values with defaults
MODEL=$(echo "$INPUT" | jq -r '.model.displayName // "Claude"')
GIT_BRANCH=$(echo "$INPUT" | jq -r '.gitBranch // ""')
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')
COST=$(echo "$INPUT" | jq -r '.costUsd // 0')
CONTEXT_PERCENT=$(echo "$INPUT" | jq -r '.contextWindowPercent // 0')

# ============================================================================
# COLORES - Anthropic Brand + GitHub Dark
# ============================================================================
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"
ITALIC="\033[3m"

# Colores Anthropic/Claude
ORANGE="\033[38;2;217;119;6m"      # #D97706 - Anthropic orange
CREAM="\033[38;2;255;237;213m"     # #FFEDD5 - Cream
BROWN="\033[38;2;146;64;14m"       # #92400E - Brown

# GitHub Dark palette
FG="\033[38;2;230;237;243m"        # #E6EDF3
FG_DIM="\033[38;2;125;133;144m"    # #7D8590
GREEN="\033[38;2;126;231;135m"     # #7EE787
RED="\033[38;2;255;123;114m"       # #FF7B72
YELLOW="\033[38;2;210;153;34m"     # #D29922
BLUE="\033[38;2;121;192;255m"      # #79C0FF
PURPLE="\033[38;2;210;168;255m"    # #D2A8FF
CYAN="\033[38;2;165;214;255m"      # #A5D6FF

# Backgrounds
BG_ORANGE="\033[48;2;217;119;6m"
BG_DARK="\033[48;2;22;27;34m"      # #161B22

# ============================================================================
# ICONOS - Nerd Font
# ============================================================================
ICON_CLAUDE="󰚩"      # Robot/AI icon
ICON_BRANCH=""       # Git branch
ICON_FOLDER=""       # Folder
ICON_COST="󰄘"        # Dollar
ICON_CONTEXT="󰍛"     # Memory/brain
ICON_TIME=""        # Clock
ICON_ARROW=""       # Separator arrow
ICON_CHECK="✓"       # Check
ICON_WARN="⚠"        # Warning

# ============================================================================
# FORMATEO
# ============================================================================

# Acortar path
SHORT_CWD=$(echo "$CWD" | sed "s|$HOME|~|")
if [[ ${#SHORT_CWD} -gt 30 ]]; then
    SHORT_CWD=$(echo "$SHORT_CWD" | awk -F'/' '{print $(NF-1)"/"$NF}')
fi

# Formatear costo
COST_NUM=$(printf "%.4f" "$COST" 2>/dev/null || echo "0.0000")

# Context como entero
CTX_INT=$(printf "%.0f" "$CONTEXT_PERCENT" 2>/dev/null || echo "0")

# Color del contexto según uso
if (( CTX_INT > 80 )); then
    CTX_COLOR="$RED"
    CTX_ICON="$ICON_WARN"
elif (( CTX_INT > 60 )); then
    CTX_COLOR="$YELLOW"
    CTX_ICON="$ICON_CONTEXT"
else
    CTX_COLOR="$GREEN"
    CTX_ICON="$ICON_CONTEXT"
fi

# Modelo corto
case "$MODEL" in
    *"Opus"*)   MODEL_SHORT="Opus 4" ;;
    *"Sonnet"*) MODEL_SHORT="Sonnet" ;;
    *"Haiku"*)  MODEL_SHORT="Haiku" ;;
    *)          MODEL_SHORT="$MODEL" ;;
esac

# ============================================================================
# BUILD STATUS LINE
# ============================================================================

# Estilo: Powerline segments
STATUS=""

# Segment 1: Claude Model (naranja)
STATUS+="${BG_ORANGE}${BOLD} ${ICON_CLAUDE} ${MODEL_SHORT} ${RESET}"
STATUS+="${ORANGE}${ICON_ARROW}${RESET} "

# Segment 2: Git Branch (si existe)
if [[ -n "$GIT_BRANCH" ]]; then
    STATUS+="${PURPLE}${ICON_BRANCH} ${GIT_BRANCH}${RESET} "
    STATUS+="${FG_DIM}│${RESET} "
fi

# Segment 3: Directorio
STATUS+="${BLUE}${ICON_FOLDER} ${SHORT_CWD}${RESET} "
STATUS+="${FG_DIM}│${RESET} "

# Segment 4: Context Usage
STATUS+="${CTX_COLOR}${CTX_ICON} ${CTX_INT}%${RESET} "
STATUS+="${FG_DIM}│${RESET} "

# Segment 5: Costo
if (( $(echo "$COST > 0.01" | bc -l 2>/dev/null || echo 0) )); then
    STATUS+="${GREEN}${ICON_COST} \$${COST_NUM}${RESET} "
else
    STATUS+="${FG_DIM}${ICON_COST} \$${COST_NUM}${RESET} "
fi
STATUS+="${FG_DIM}│${RESET} "

# Segment 6: Hora
STATUS+="${FG_DIM}${ICON_TIME} $(date '+%H:%M')${RESET}"

echo -e "$STATUS"
