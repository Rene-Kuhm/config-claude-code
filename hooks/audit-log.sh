#!/bin/bash
# Audit Log Hook - Registra todas las operaciones para compliance
# Genera un audit trail de todas las acciones de Claude Code

set -e

# Directorio de logs
LOG_DIR="$HOME/.claude/logs"
LOG_FILE="$LOG_DIR/audit.log"

# Crear directorio si no existe
mkdir -p "$LOG_DIR"

# Leer input desde stdin
input=$(cat)

# Extraer información del JSON
tool_name=$(echo "$input" | jq -r '.tool_name // "unknown"' 2>/dev/null)
session_id=$(echo "$input" | jq -r '.session_id // "unknown"' 2>/dev/null)

# Timestamp ISO 8601
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Extraer detalles según el tipo de herramienta
case "$tool_name" in
    "Bash")
        command=$(echo "$input" | jq -r '.tool_input.command // "N/A"' 2>/dev/null)
        details="command=$command"
        ;;
    "Read"|"Write"|"Edit")
        file_path=$(echo "$input" | jq -r '.tool_input.file_path // "N/A"' 2>/dev/null)
        details="file=$file_path"
        ;;
    "Glob"|"Grep")
        pattern=$(echo "$input" | jq -r '.tool_input.pattern // "N/A"' 2>/dev/null)
        details="pattern=$pattern"
        ;;
    "WebFetch")
        url=$(echo "$input" | jq -r '.tool_input.url // "N/A"' 2>/dev/null)
        details="url=$url"
        ;;
    *)
        details="input=$(echo "$input" | jq -c '.tool_input // {}' 2>/dev/null)"
        ;;
esac

# Escribir al log
echo "[$timestamp] [session:$session_id] [$tool_name] $details" >> "$LOG_FILE"

# Rotación de logs (mantener últimos 10MB)
if [ -f "$LOG_FILE" ]; then
    size=$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)
    if [ "$size" -gt 10485760 ]; then
        mv "$LOG_FILE" "$LOG_FILE.$(date +%Y%m%d%H%M%S).bak"
        # Mantener solo los últimos 5 backups
        ls -t "$LOG_DIR"/audit.log.*.bak 2>/dev/null | tail -n +6 | xargs -r rm
    fi
fi

# Siempre permitir (exit 0) - este hook es solo para logging
exit 0
