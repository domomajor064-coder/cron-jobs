#!/bin/bash
# Auto-reindex qmd collections when markdown files change
# Run via heartbeat or cron

export PATH="$HOME/.bun/bin:$PATH"
cd ~/clawd

# Check if qmd is installed
if ! command -v qmd &> /dev/null; then
    echo "qmd not found in PATH"
    exit 1
fi

# Get last modification time of any .md file
LAST_MOD=$(find . -name "*.md" -type f -mtime -1 | wc -l)

if [ "$LAST_MOD" -gt 0 ]; then
    echo "Found $LAST_MOD recently modified .md files, reindexing..."
    qmd update 2>&1
    echo "Reindex complete at $(date)"
else
    echo "No recent changes, skipping reindex"
fi