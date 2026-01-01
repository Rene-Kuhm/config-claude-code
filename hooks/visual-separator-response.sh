#!/bin/bash
# Visual separator - Notificación macOS
osascript -e 'display notification "✅ Claude terminó de responder" with title "Claude Code" sound name "Glass"' 2>/dev/null &
