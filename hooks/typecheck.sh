#!/bin/bash
# Hook: Verificar tipos TypeScript después de editar
# Trigger: PostToolUse (Edit|Write)

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Solo para archivos TypeScript
if [[ ! "$file_path" =~ \.(ts|tsx)$ ]]; then
  exit 0
fi

# Verificar que el archivo existe
if [[ ! -f "$file_path" ]]; then
  exit 0
fi

# Buscar tsconfig.json en el proyecto
project_dir=$(dirname "$file_path")
while [[ "$project_dir" != "/" ]]; do
  if [[ -f "$project_dir/tsconfig.json" ]]; then
    break
  fi
  project_dir=$(dirname "$project_dir")
done

# Si no hay tsconfig, salir
if [[ ! -f "$project_dir/tsconfig.json" ]]; then
  exit 0
fi

# Ejecutar type checking solo del archivo modificado
cd "$project_dir"

if command -v tsc &> /dev/null; then
  errors=$(tsc --noEmit --skipLibCheck 2>&1 | grep -E "^${file_path}" | head -5)
  if [[ -n "$errors" ]]; then
    echo "⚠ TypeScript errors en $file_path:"
    echo "$errors"
  else
    echo "✓ TypeScript: $file_path sin errores"
  fi
elif command -v npx &> /dev/null; then
  errors=$(npx tsc --noEmit --skipLibCheck 2>&1 | grep -E "^${file_path}" | head -5)
  if [[ -n "$errors" ]]; then
    echo "⚠ TypeScript errors en $file_path:"
    echo "$errors"
  else
    echo "✓ TypeScript: $file_path sin errores"
  fi
fi

exit 0
