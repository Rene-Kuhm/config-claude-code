#!/usr/bin/env bash
#
# Claude Code Configuration Restore Script
# Restores configuration from a backup
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

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║     Claude Code Configuration Restore                ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check arguments
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <backup-name|latest>"
    echo ""
    echo "Available backups:"
    ls -1t "$BACKUP_DIR"/*.tar.gz 2>/dev/null | while read -r backup; do
        name=$(basename "$backup" .tar.gz)
        size=$(du -h "$backup" | cut -f1)
        echo "  - $name ($size)"
    done
    exit 1
fi

BACKUP_NAME="$1"

# Handle 'latest' argument
if [[ "$BACKUP_NAME" == "latest" ]]; then
    BACKUP_FILE=$(ls -1t "$BACKUP_DIR"/*.tar.gz 2>/dev/null | head -1)
    if [[ -z "$BACKUP_FILE" ]]; then
        echo -e "${RED}Error: No backups found${NC}"
        exit 1
    fi
    BACKUP_NAME=$(basename "$BACKUP_FILE" .tar.gz)
fi

BACKUP_FILE="$BACKUP_DIR/$BACKUP_NAME.tar.gz"

# Check if backup exists
if [[ ! -f "$BACKUP_FILE" ]]; then
    echo -e "${RED}Error: Backup not found: $BACKUP_FILE${NC}"
    exit 1
fi

echo "Restoring from: $BACKUP_NAME"
echo ""

# Confirm
read -p "This will overwrite your current configuration. Continue? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Restore cancelled."
    exit 0
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Extract backup
echo ""
echo -e "${YELLOW}Extracting backup...${NC}"
tar -xzf "$BACKUP_FILE" -C "$TEMP_DIR"
echo -e "${GREEN}✓${NC} Extracted"

# Read manifest
EXTRACTED_DIR="$TEMP_DIR/$BACKUP_NAME"
if [[ -f "$EXTRACTED_DIR/MANIFEST.json" ]]; then
    echo ""
    echo -e "${YELLOW}Backup info:${NC}"
    jq -r '"  Date: \(.backup_date)\n  Host: \(.hostname)"' "$EXTRACTED_DIR/MANIFEST.json"
fi

# Restore items
echo ""
echo -e "${YELLOW}Restoring configuration...${NC}"

for item in "$EXTRACTED_DIR"/*; do
    name=$(basename "$item")

    # Skip manifest
    if [[ "$name" == "MANIFEST.json" ]]; then
        continue
    fi

    dest="$CLAUDE_DIR/$name"

    # Backup current if exists
    if [[ -e "$dest" ]]; then
        rm -rf "$dest"
    fi

    # Copy from backup
    cp -r "$item" "$dest"
    echo -e "${GREEN}✓${NC} $name"
done

# Restore permissions on hooks
echo ""
echo -e "${YELLOW}Restoring permissions...${NC}"

for hook in "$CLAUDE_DIR/hooks"/*.sh "$CLAUDE_DIR/hooks"/*.py; do
    if [[ -f "$hook" ]]; then
        chmod +x "$hook"
    fi
done

for script in "$CLAUDE_DIR/scripts"/*.sh; do
    if [[ -f "$script" ]]; then
        chmod +x "$script"
    fi
done

echo -e "${GREEN}✓${NC} Permissions restored"

# Summary
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Restore complete!${NC}"
echo ""
echo "Configuration restored from: $BACKUP_NAME"
echo ""
echo "Validate with: ~/.claude/scripts/validate.sh"
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
