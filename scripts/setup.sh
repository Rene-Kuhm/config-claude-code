#!/usr/bin/env bash
#
# Claude Code Enterprise Setup Script
# Installs and configures all enterprise features
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CLAUDE_DIR="$HOME/.claude"

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║     Claude Code Enterprise Setup                     ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if Claude Code is installed
if ! command -v claude &> /dev/null; then
    echo -e "${RED}Error: Claude Code is not installed${NC}"
    echo "Install from: https://claude.ai/code"
    exit 1
fi

echo -e "${GREEN}✓${NC} Claude Code found: $(claude --version 2>/dev/null || echo 'installed')"

# Check directories
echo ""
echo -e "${YELLOW}Checking directories...${NC}"

DIRS=(
    "agents"
    "skills"
    "rules"
    "commands"
    "hooks"
    "output-styles"
    "templates"
    "teams"
    "alerts"
    "scripts"
    "telemetry"
)

for dir in "${DIRS[@]}"; do
    if [[ -d "$CLAUDE_DIR/$dir" ]]; then
        echo -e "${GREEN}✓${NC} $dir/"
    else
        echo -e "${YELLOW}Creating${NC} $dir/"
        mkdir -p "$CLAUDE_DIR/$dir"
    fi
done

# Make hooks executable
echo ""
echo -e "${YELLOW}Setting hook permissions...${NC}"

for hook in "$CLAUDE_DIR/hooks"/*.sh "$CLAUDE_DIR/hooks"/*.py; do
    if [[ -f "$hook" ]]; then
        chmod +x "$hook"
        echo -e "${GREEN}✓${NC} $(basename "$hook")"
    fi
done

# Make scripts executable
for script in "$CLAUDE_DIR/scripts"/*.sh; do
    if [[ -f "$script" ]]; then
        chmod +x "$script"
    fi
done

# Check required files
echo ""
echo -e "${YELLOW}Checking configuration files...${NC}"

FILES=(
    "settings.json"
    "CLAUDE.md"
    "README.md"
)

for file in "${FILES[@]}"; do
    if [[ -f "$CLAUDE_DIR/$file" ]]; then
        echo -e "${GREEN}✓${NC} $file"
    else
        echo -e "${RED}✗${NC} $file (missing)"
    fi
done

# Check MCP servers
echo ""
echo -e "${YELLOW}Checking MCP server dependencies...${NC}"

if command -v npx &> /dev/null; then
    echo -e "${GREEN}✓${NC} npx available"
else
    echo -e "${RED}✗${NC} npx not found - install Node.js"
fi

if command -v uvx &> /dev/null; then
    echo -e "${GREEN}✓${NC} uvx available"
else
    echo -e "${YELLOW}!${NC} uvx not found - some MCP servers may not work"
fi

# Check environment variables
echo ""
echo -e "${YELLOW}Checking environment variables...${NC}"

ENV_VARS=(
    "CLAUDE_SLACK_WEBHOOK:Slack notifications"
    "SLACK_BOT_TOKEN:Slack MCP server"
    "LINEAR_API_KEY:Linear MCP server"
)

for entry in "${ENV_VARS[@]}"; do
    var="${entry%%:*}"
    desc="${entry#*:}"
    if [[ -n "${!var:-}" ]]; then
        echo -e "${GREEN}✓${NC} $var"
    else
        echo -e "${YELLOW}!${NC} $var not set ($desc)"
    fi
done

# Summary
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Setup complete!${NC}"
echo ""
echo "Quick commands:"
echo "  claude                    # Start Claude Code"
echo "  /help                     # Get help"
echo "  ~/.claude/scripts/validate.sh  # Validate config"
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
