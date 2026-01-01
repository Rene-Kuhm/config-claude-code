#!/usr/bin/env bash
# Pre-commit Validation Hook
# Ejecuta lint, format y tests antes de commits
# Enterprise Edition v1.1 - Fixed

set -euo pipefail

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Leer input JSON
INPUT=$(cat)

# Extraer información del tool
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Solo ejecutar para commits
if [[ "$TOOL_NAME" != "Bash" ]]; then
    exit 0
fi

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Verificar si es un commit
if [[ ! "$COMMAND" =~ "git commit" ]]; then
    exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

echo -e "${YELLOW}Running pre-commit validations...${NC}" >&2

ERRORS=0

# 1. Verificar archivos staged
STAGED_FILES=$(git -C "$PROJECT_DIR" diff --cached --name-only 2>/dev/null || echo "")

if [[ -z "$STAGED_FILES" ]]; then
    echo -e "${RED}No staged files found${NC}" >&2
    exit 0
fi

# 2. Verificar package.json para scripts disponibles
if [[ -f "$PROJECT_DIR/package.json" ]]; then
    HAS_LINT=$(jq -r '.scripts.lint // empty' "$PROJECT_DIR/package.json")
    HAS_TYPECHECK=$(jq -r '.scripts.typecheck // empty' "$PROJECT_DIR/package.json")

    # Detectar package manager
    if [[ -f "$PROJECT_DIR/pnpm-lock.yaml" ]]; then
        PM="pnpm"
    elif [[ -f "$PROJECT_DIR/bun.lockb" ]]; then
        PM="bun"
    else
        PM="npm"
    fi

    # Verificar TypeScript si existe
    if [[ -n "$HAS_TYPECHECK" ]]; then
        echo -e "${YELLOW}Checking TypeScript...${NC}" >&2
        if ! $PM run typecheck 2>&1 | tail -5 >&2; then
            echo -e "${RED}TypeScript errors found${NC}" >&2
            ERRORS=$((ERRORS + 1))
        else
            echo -e "${GREEN}TypeScript OK${NC}" >&2
        fi
    fi

    # Verificar Biome/ESLint (sin --no-fix, turbo no lo acepta)
    if [[ -n "$HAS_LINT" ]]; then
        echo -e "${YELLOW}Running linter...${NC}" >&2
        # Ejecutar lint sin flags extra - turbo/biome manejan sus propios flags
        if ! $PM run lint 2>&1 | tail -10 >&2; then
            echo -e "${RED}Lint errors found - run '$PM run lint' to fix${NC}" >&2
            ERRORS=$((ERRORS + 1))
        else
            echo -e "${GREEN}Lint OK${NC}" >&2
        fi
    fi
fi

# 3. Verificar archivos sensibles en staged (patterns corregidos)
# Usar grep con patterns literales escapados correctamente
check_sensitive_file() {
    local pattern="$1"
    local description="$2"
    if echo "$STAGED_FILES" | grep -q "$pattern"; then
        echo -e "${RED}WARNING: Potentially sensitive file staged: $description${NC}" >&2
        return 1
    fi
    return 0
}

# Archivos .env (exacto o con sufijo)
if echo "$STAGED_FILES" | grep -qE '^\.env$|^\.env\.' ; then
    echo -e "${RED}WARNING: .env file staged - remove it from commit${NC}" >&2
    ERRORS=$((ERRORS + 1))
fi

# Archivos de claves
if echo "$STAGED_FILES" | grep -qE '\.pem$|\.key$|\.p12$|\.pfx$'; then
    echo -e "${RED}WARNING: Key/certificate file staged${NC}" >&2
    ERRORS=$((ERRORS + 1))
fi

# Archivos de credenciales
if echo "$STAGED_FILES" | grep -qiE 'credentials|secrets?\.'; then
    echo -e "${RED}WARNING: Credentials file staged${NC}" >&2
    ERRORS=$((ERRORS + 1))
fi

# 4. Verificar tamaño de archivos grandes
while IFS= read -r file; do
    if [[ -n "$file" && -f "$PROJECT_DIR/$file" ]]; then
        SIZE=$(wc -c < "$PROJECT_DIR/$file")
        if [[ $SIZE -gt 1048576 ]]; then  # 1MB
            echo -e "${YELLOW}WARNING: Large file staged (>1MB): $file${NC}" >&2
        fi
    fi
done <<< "$STAGED_FILES"

if [[ $ERRORS -gt 0 ]]; then
    echo -e "${RED}Pre-commit validation failed with $ERRORS error(s)${NC}" >&2
    echo '{"decision": "block", "reason": "Pre-commit validation failed. Fix the issues above before committing."}'
    exit 2
fi

echo -e "${GREEN}Pre-commit validation passed${NC}" >&2
exit 0
