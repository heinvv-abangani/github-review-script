#!/bin/bash
# Post review comments to GitHub PR with [Hein Cursor review] prefix

REVIEW_FILE=$1
PR_URL=$2

if [ -z "$REVIEW_FILE" ] || [ -z "$PR_URL" ]; then
  echo "Usage: ./scripts/post-review-comments.sh <review-file> <PR_URL>"
  echo ""
  echo "Example:"
  echo "  ./scripts/post-review-comments.sh pr-reviews/PR-32958-2025-10-06.md https://github.com/elementor/elementor/pull/32958"
  exit 1
fi

# Check if review file exists
if [ ! -f "$REVIEW_FILE" ]; then
    echo "❌ Error: Review file not found: $REVIEW_FILE"
    exit 1
fi

# Extract PR info from URL
if [[ $PR_URL =~ github\.com/([^/]+)/([^/]+)/pull/([0-9]+) ]]; then
    OWNER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
    PR_NUMBER="${BASH_REMATCH[3]}"
else
    echo "❌ Error: Invalid PR URL format"
    exit 1
fi

# Check GitHub token
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GITHUB_TOKEN not set"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Post Review Comments to GitHub"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Review File: $REVIEW_FILE"
echo "  Repository:  ${OWNER}/${REPO}"
echo "  PR Number:   #${PR_NUMBER}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Parse review file for issues with file:line references
echo "📋 Parsing review file for issues..."
echo ""

# Extract Critical and High priority issues
echo "Found issues to post:"
echo ""

# This is a simplified version - ask Cursor to help extract structured comments
cat << 'PROMPT'
To post comments, we need to extract issues from the review in JSON format.

Please help by running this in Cursor chat:

─────────────────────────────────────────────────────────────
Read the review file: REVIEW_FILE_PLACEHOLDER

Extract all Critical and High priority issues into this JSON format:

```json
[
  {
    "severity": "Critical",
    "file": "path/to/file.tsx",
    "line": 123,
    "title": "Issue title",
    "body": "Detailed description with recommendation"
  }
]
```

Save to: pr-reviews/comments-to-post.json

Only include issues that have:
- Clear file path
- Specific line number
- Actionable description

Prefix each body with: [Hein Cursor review]
─────────────────────────────────────────────────────────────

Once you have comments-to-post.json, run:
  ./scripts/post-comments-from-json.sh pr-reviews/comments-to-post.json PR_URL_PLACEHOLDER

PROMPT

# Replace placeholders
sed "s|REVIEW_FILE_PLACEHOLDER|$REVIEW_FILE|g; s|PR_URL_PLACEHOLDER|$PR_URL|g" <<< "$PROMPT"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
