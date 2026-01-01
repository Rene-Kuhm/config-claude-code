#!/bin/bash
# Hook: Auto-format con Biome después de editar archivos
# Trigger: PostToolUse (Edit|Write)

set -e

# Leer input JSON de Claude
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
tool_name=$(echo "$input" | jq -r '.tool_name // empty')

# Solo aplicar a archivos TS/JS/JSON editados o escritos
if [[ ! "$file_path" =~ \.(ts|tsx|js|jsx|json)$ ]]; then
  exit 0
fi

# Verificar que el archivo existe
if [[ ! -f "$file_path" ]]; then
  exit 0
fi

# Formatear con Biome
if command -v biome &> /dev/null; then
  biome check --write "$file_path" 2>/dev/null || true
  echo "✓ Biome: $file_path formateado"
elif command -v npx &> /dev/null; then
  npx @biomejs/biome check --write "$file_path" 2>/dev/null || true
  echo "✓ Biome (npx): $file_path formateado"
fi

exit 0
