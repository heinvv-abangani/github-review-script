#!/bin/bash
# Cleanup old PR review files (older than 3 days)
# Usage: ./cleanup.sh [days]

DAYS=${1:-3}
PR_REVIEWS_DIR="../pr-reviews"

if [ ! -d "$PR_REVIEWS_DIR" ]; then
    echo "📁 Directory not found: $PR_REVIEWS_DIR"
    exit 0
fi

echo "🧹 Cleaning up files older than $DAYS days in $PR_REVIEWS_DIR..."
echo ""

DELETED_COUNT=0

while IFS= read -r -d '' file; do
    echo "  🗑️  Deleting: $(basename "$file")"
    rm "$file"
    ((DELETED_COUNT++))
done < <(find "$PR_REVIEWS_DIR" -maxdepth 1 -type f -name "PR-*" -mtime +$DAYS -print0)

if [ $DELETED_COUNT -eq 0 ]; then
    echo "  ✅ No files to clean up"
else
    echo ""
    echo "  ✅ Deleted $DELETED_COUNT file(s)"
fi

echo ""
