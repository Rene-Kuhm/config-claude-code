#!/bin/bash
# Hook: Ejecutar linting con Biome y auto-fix
# Trigger: PostToolUse (Edit|Write)

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Solo para archivos TS/JS/JSX/TSX
if [[ ! "$file_path" =~ \.(ts|tsx|js|jsx)$ ]]; then
  exit 0
fi

# Verificar que el archivo existe
if [[ ! -f "$file_path" ]]; then
  exit 0
fi

# Buscar biome.json en el proyecto
project_dir=$(dirname "$file_path")
while [[ "$project_dir" != "/" ]]; do
  if [[ -f "$project_dir/biome.json" ]] || [[ -f "$project_dir/biome.jsonc" ]]; then
    break
  fi
  project_dir=$(dirname "$project_dir")
done

# Ejecutar Biome lint con auto-fix
cd "$project_dir" 2>/dev/null || cd "$(dirname "$file_path")"

if command -v biome &> /dev/null; then
  result=$(biome lint --write "$file_path" 2>&1)
  if echo "$result" | grep -q "error"; then
    echo "⚠ Biome lint issues en $file_path:"
    echo "$result" | grep -E "(error|warning)" | head -5
  else
    echo "✓ Biome lint: $file_path OK"
  fi
elif command -v npx &> /dev/null; then
  result=$(npx @biomejs/biome lint --write "$file_path" 2>&1)
  if echo "$result" | grep -q "error"; then
    echo "⚠ Biome lint issues en $file_path:"
    echo "$result" | grep -E "(error|warning)" | head -5
  else
    echo "✓ Biome lint: $file_path OK"
  fi
fi

exit 0
