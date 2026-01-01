#!/usr/bin/env bash
# Team Notification Hook
# Envía notificaciones a Slack/Teams sobre eventos importantes
# Enterprise Edition v1.0

set -euo pipefail

# Configuración - ajustar según tu setup
SLACK_WEBHOOK_URL="${CLAUDE_SLACK_WEBHOOK:-}"
TEAMS_WEBHOOK_URL="${CLAUDE_TEAMS_WEBHOOK:-}"
NOTIFY_ON_DEPLOY="${CLAUDE_NOTIFY_DEPLOY:-true}"
NOTIFY_ON_ERROR="${CLAUDE_NOTIFY_ERROR:-true}"

# Leer input JSON
INPUT=$(cat)

HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // empty')
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // {}')

# Función para enviar a Slack
send_slack() {
    local message="$1"
    local color="${2:-#36a64f}"

    if [[ -z "$SLACK_WEBHOOK_URL" ]]; then
        return 0
    fi

    curl -s -X POST "$SLACK_WEBHOOK_URL" \
        -H 'Content-Type: application/json' \
        -d "{
            \"attachments\": [{
                \"color\": \"$color\",
                \"text\": \"$message\",
                \"footer\": \"Claude Code Enterprise\",
                \"ts\": $(date +%s)
            }]
        }" > /dev/null 2>&1 || true
}

# Función para enviar a Teams
send_teams() {
    local message="$1"
    local color="${2:-Good}"

    if [[ -z "$TEAMS_WEBHOOK_URL" ]]; then
        return 0
    fi

    curl -s -X POST "$TEAMS_WEBHOOK_URL" \
        -H 'Content-Type: application/json' \
        -d "{
            \"@type\": \"MessageCard\",
            \"themeColor\": \"$color\",
            \"summary\": \"Claude Code Notification\",
            \"sections\": [{
                \"activityTitle\": \"Claude Code Enterprise\",
                \"text\": \"$message\"
            }]
        }" > /dev/null 2>&1 || true
}

# Detectar eventos importantes
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PROJECT_NAME=$(basename "$PROJECT_DIR")
USER_NAME="${USER:-unknown}"

case "$TOOL_NAME" in
    "Bash")
        COMMAND=$(echo "$TOOL_INPUT" | jq -r '.command // empty')

        # Notificar en deploys
        if [[ "$NOTIFY_ON_DEPLOY" == "true" ]]; then
            if [[ "$COMMAND" =~ (deploy|kubectl apply|terraform apply|docker push) ]]; then
                MESSAGE=":rocket: *Deploy initiated* by $USER_NAME in \`$PROJECT_NAME\`\n\`\`\`$COMMAND\`\`\`"
                send_slack "$MESSAGE" "#36a64f"
                send_teams "$MESSAGE" "0076D7"
            fi
        fi

        # Notificar en releases
        if [[ "$COMMAND" =~ (npm publish|pnpm publish|git tag|gh release) ]]; then
            MESSAGE=":package: *Release action* by $USER_NAME in \`$PROJECT_NAME\`"
            send_slack "$MESSAGE" "#7C3AED"
            send_teams "$MESSAGE" "7C3AED"
        fi
        ;;
esac

# Hook Stop - notificar si hay errores
if [[ "$HOOK_EVENT" == "Stop" || "$HOOK_EVENT" == "SubagentStop" ]]; then
    STOP_REASON=$(echo "$INPUT" | jq -r '.stop_reason // empty')

    if [[ "$NOTIFY_ON_ERROR" == "true" && "$STOP_REASON" == "error" ]]; then
        MESSAGE=":warning: *Claude Code error* in \`$PROJECT_NAME\` session"
        send_slack "$MESSAGE" "#FF0000"
        send_teams "$MESSAGE" "FF0000"
    fi
fi

# Siempre permitir
exit 0
