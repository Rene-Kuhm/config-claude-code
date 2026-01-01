#!/usr/bin/env bash
#
# Claude Code Configuration Backup Script
# Creates timestamped backups of your enterprise configuration
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$HOME/.claude-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="claude-config-$TIMESTAMP"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║     Claude Code Configuration Backup                 ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Files and directories to backup
BACKUP_ITEMS=(
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
    "telemetry/config.json"
    "CLAUDE.md"
    "README.md"
    "ONBOARDING.md"
    "settings.json"
)

echo -e "${YELLOW}Creating backup...${NC}"
echo "  Destination: $BACKUP_PATH"
echo ""

mkdir -p "$BACKUP_PATH"

for item in "${BACKUP_ITEMS[@]}"; do
    src="$CLAUDE_DIR/$item"
    if [[ -e "$src" ]]; then
        # Create parent directory if needed
        parent=$(dirname "$BACKUP_PATH/$item")
        mkdir -p "$parent"

        # Copy item
        cp -r "$src" "$BACKUP_PATH/$item"
        echo -e "${GREEN}✓${NC} $item"
    else
        echo -e "${YELLOW}!${NC} $item (not found, skipping)"
    fi
done

# Create manifest
echo ""
echo -e "${YELLOW}Creating manifest...${NC}"

cat > "$BACKUP_PATH/MANIFEST.json" << EOF
{
  "backup_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "backup_name": "$BACKUP_NAME",
  "claude_version": "$(claude --version 2>/dev/null || echo 'unknown')",
  "hostname": "$(hostname)",
  "user": "$USER",
  "items": [
$(for item in "${BACKUP_ITEMS[@]}"; do
    if [[ -e "$CLAUDE_DIR/$item" ]]; then
        echo "    \"$item\","
    fi
done | sed '$ s/,$//')
  ]
}
EOF

echo -e "${GREEN}✓${NC} MANIFEST.json"

# Compress backup
echo ""
echo -e "${YELLOW}Compressing backup...${NC}"

cd "$BACKUP_DIR"
tar -czf "$BACKUP_NAME.tar.gz" "$BACKUP_NAME"
rm -rf "$BACKUP_NAME"

BACKUP_SIZE=$(du -h "$BACKUP_NAME.tar.gz" | cut -f1)
echo -e "${GREEN}✓${NC} $BACKUP_NAME.tar.gz ($BACKUP_SIZE)"

# Cleanup old backups (keep last 5)
echo ""
echo -e "${YELLOW}Cleaning old backups...${NC}"

BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null | wc -l)
if [[ $BACKUP_COUNT -gt 5 ]]; then
    ls -1t "$BACKUP_DIR"/*.tar.gz | tail -n +6 | while read -r old_backup; do
        rm -f "$old_backup"
        echo -e "${YELLOW}Removed:${NC} $(basename "$old_backup")"
    done
fi

# Summary
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Backup complete!${NC}"
echo ""
echo "Backup location: $BACKUP_DIR/$BACKUP_NAME.tar.gz"
echo "Size: $BACKUP_SIZE"
echo ""
echo "To restore:"
echo "  ~/.claude/scripts/restore.sh $BACKUP_NAME"
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
