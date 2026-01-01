#!/usr/bin/env bash
#
# Claude Code Configuration Validator
# Checks for issues in your enterprise setup
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CLAUDE_DIR="$HOME/.claude"
ERRORS=0
WARNINGS=0

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║     Claude Code Configuration Validator              ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Function to count items
count_items() {
    local pattern="$1"
    find "$CLAUDE_DIR" -path "$pattern" 2>/dev/null | wc -l | tr -d ' '
}

# Check settings.json
echo -e "${YELLOW}Checking settings.json...${NC}"

if [[ -f "$CLAUDE_DIR/settings.json" ]]; then
    if jq empty "$CLAUDE_DIR/settings.json" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Valid JSON"

        # Check for required keys
        if jq -e '.permissions' "$CLAUDE_DIR/settings.json" > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} Permissions configured"
        else
            echo -e "${YELLOW}!${NC} No permissions configured"
            ((WARNINGS++))
        fi

        if jq -e '.hooks' "$CLAUDE_DIR/settings.json" > /dev/null 2>&1; then
            HOOK_COUNT=$(jq '.hooks | keys | length' "$CLAUDE_DIR/settings.json")
            echo -e "${GREEN}✓${NC} Hooks configured ($HOOK_COUNT event types)"
        else
            echo -e "${YELLOW}!${NC} No hooks configured"
            ((WARNINGS++))
        fi

        if jq -e '.mcpServers' "$CLAUDE_DIR/settings.json" > /dev/null 2>&1; then
            MCP_COUNT=$(jq '.mcpServers | keys | length' "$CLAUDE_DIR/settings.json")
            echo -e "${GREEN}✓${NC} MCP servers configured ($MCP_COUNT servers)"
        else
            echo -e "${YELLOW}!${NC} No MCP servers configured"
            ((WARNINGS++))
        fi
    else
        echo -e "${RED}✗${NC} Invalid JSON in settings.json"
        ((ERRORS++))
    fi
else
    echo -e "${RED}✗${NC} settings.json not found"
    ((ERRORS++))
fi

# Check hooks
echo ""
echo -e "${YELLOW}Checking hooks...${NC}"

for hook in "$CLAUDE_DIR/hooks"/*.sh "$CLAUDE_DIR/hooks"/*.py; do
    if [[ -f "$hook" ]]; then
        name=$(basename "$hook")
        if [[ -x "$hook" ]]; then
            echo -e "${GREEN}✓${NC} $name (executable)"
        else
            echo -e "${YELLOW}!${NC} $name (not executable)"
            ((WARNINGS++))
        fi
    fi
done

# Check skills
echo ""
echo -e "${YELLOW}Checking skills...${NC}"

SKILL_COUNT=0
for skill_dir in "$CLAUDE_DIR/skills"/*/; do
    if [[ -d "$skill_dir" ]]; then
        name=$(basename "$skill_dir")
        if [[ -f "$skill_dir/SKILL.md" ]]; then
            echo -e "${GREEN}✓${NC} $name"
            ((SKILL_COUNT++))
        else
            echo -e "${RED}✗${NC} $name (missing SKILL.md)"
            ((ERRORS++))
        fi
    fi
done
echo "  Total: $SKILL_COUNT skills"

# Check agents
echo ""
echo -e "${YELLOW}Checking agents...${NC}"

AGENT_COUNT=0
for agent in "$CLAUDE_DIR/agents"/*.md; do
    if [[ -f "$agent" ]]; then
        name=$(basename "$agent" .md)
        echo -e "${GREEN}✓${NC} $name"
        ((AGENT_COUNT++))
    fi
done
echo "  Total: $AGENT_COUNT agents"

# Check rules
echo ""
echo -e "${YELLOW}Checking rules...${NC}"

RULE_COUNT=0
for rule in "$CLAUDE_DIR/rules"/*.md; do
    if [[ -f "$rule" ]]; then
        name=$(basename "$rule" .md)
        echo -e "${GREEN}✓${NC} $name"
        ((RULE_COUNT++))
    fi
done
echo "  Total: $RULE_COUNT rules"

# Check templates
echo ""
echo -e "${YELLOW}Checking templates...${NC}"

TEMPLATE_COUNT=$(find "$CLAUDE_DIR/templates" -type f 2>/dev/null | wc -l | tr -d ' ')
echo "  Total: $TEMPLATE_COUNT templates"

# Summary
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo "Configuration Summary:"
echo "  Agents: $AGENT_COUNT"
echo "  Skills: $SKILL_COUNT"
echo "  Rules: $RULE_COUNT"
echo "  Templates: $TEMPLATE_COUNT"
echo ""

if [[ $ERRORS -gt 0 ]]; then
    echo -e "${RED}✗ Validation failed with $ERRORS error(s)${NC}"
    exit 1
elif [[ $WARNINGS -gt 0 ]]; then
    echo -e "${YELLOW}! Validation passed with $WARNINGS warning(s)${NC}"
    exit 0
else
    echo -e "${GREEN}✓ Validation passed - all checks OK${NC}"
    exit 0
fi
