#!/usr/bin/env bash
#
# Backup Before Edit Hook
# Creates automatic backups before large file modifications
#
# Event: PreToolUse (Edit, Write)
# Purpose: Protect against accidental data loss
#

set -euo pipefail

# Configuration
BACKUP_DIR="$HOME/.claude/backups"
MAX_BACKUPS=50
MIN_FILE_SIZE=1000  # Only backup files larger than 1KB
BACKUP_EXTENSIONS=("ts" "tsx" "js" "jsx" "json" "yaml" "yml" "md" "py" "sh")

# Parse input
INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

# Only process Edit and Write operations
if [[ "$TOOL" != "Edit" && "$TOOL" != "Write" ]]; then
    echo '{"status": "continue"}'
    exit 0
fi

# Check if file exists
if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
    echo '{"status": "continue"}'
    exit 0
fi

# Get file extension
EXTENSION="${FILE_PATH##*.}"

# Check if extension should be backed up
SHOULD_BACKUP=false
for ext in "${BACKUP_EXTENSIONS[@]}"; do
    if [[ "$EXTENSION" == "$ext" ]]; then
        SHOULD_BACKUP=true
        break
    fi
done

if [[ "$SHOULD_BACKUP" != "true" ]]; then
    echo '{"status": "continue"}'
    exit 0
fi

# Check file size
FILE_SIZE=$(stat -f%z "$FILE_PATH" 2>/dev/null || stat -c%s "$FILE_PATH" 2>/dev/null || echo "0")
if [[ "$FILE_SIZE" -lt "$MIN_FILE_SIZE" ]]; then
    echo '{"status": "continue"}'
    exit 0
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Generate backup filename
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SAFE_PATH=$(echo "$FILE_PATH" | tr '/' '_' | tr ' ' '_')
BACKUP_FILE="$BACKUP_DIR/${TIMESTAMP}_${SAFE_PATH}"

# Create backup
cp "$FILE_PATH" "$BACKUP_FILE"

# Create metadata
cat > "${BACKUP_FILE}.meta" << EOF
{
  "original_path": "$FILE_PATH",
  "backup_time": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "file_size": $FILE_SIZE,
  "tool": "$TOOL",
  "checksum": "$(shasum -a 256 "$FILE_PATH" | cut -d' ' -f1)"
}
EOF

# Cleanup old backups (keep last MAX_BACKUPS)
BACKUP_COUNT=$(find "$BACKUP_DIR" -name "*.meta" -type f | wc -l | tr -d ' ')
if [[ "$BACKUP_COUNT" -gt "$MAX_BACKUPS" ]]; then
    # Remove oldest backups
    find "$BACKUP_DIR" -name "*.meta" -type f -print0 | \
        xargs -0 ls -1t | \
        tail -n +$((MAX_BACKUPS + 1)) | \
        while read -r meta_file; do
            base_file="${meta_file%.meta}"
            rm -f "$meta_file" "$base_file"
        done
fi

# Log backup
echo "[$(date)] Backup: $FILE_PATH -> $BACKUP_FILE" >> "$BACKUP_DIR/backup.log"

# Continue with operation
echo '{"status": "continue"}'
