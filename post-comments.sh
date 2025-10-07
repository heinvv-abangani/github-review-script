#!/bin/bash
# GitHub PR Comments Script
# Usage: ./post-comments.sh [PR_NUMBER] [COMMENTS_FILE]
# Posts single-line code suggestions to GitHub pull requests

set -e

PR_REVIEWS_DIR="../pr-reviews"

# Parse arguments
if [ ! -z "$1" ] && [ ! -z "$2" ]; then
    PR_NUMBER="$1"
    COMMENTS_FILE="$2"
else
    # Auto-detect latest PR comments JSON
    LATEST_JSON=$(ls -t "$PR_REVIEWS_DIR"/PR-*-comments.json 2>/dev/null | head -1)
    
    if [ -z "$LATEST_JSON" ]; then
        echo "❌ No comments JSON files found in $PR_REVIEWS_DIR"
        echo ""
        echo "Expected files like: PR-32958-comments.json"
        exit 1
    fi
    
    COMMENTS_FILE="$LATEST_JSON"
    
    # Extract PR number from filename
    if [[ $(basename "$COMMENTS_FILE") =~ ^PR-([0-9]+)-comments\.json$ ]]; then
        PR_NUMBER="${BASH_REMATCH[1]}"
    else
        echo "❌ Could not extract PR number from filename: $COMMENTS_FILE"
        exit 1
    fi
fi

# Validate inputs
if [ ! -f "$COMMENTS_FILE" ]; then
    echo "❌ Comments file not found: $COMMENTS_FILE"
    exit 1
fi

# Check if GitHub CLI is available
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) not found. Please install it first:"
    echo "  https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ GitHub CLI not authenticated. Please run:"
    echo "  gh auth login"
    exit 1
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "❌ jq not found. Please install jq for JSON processing."
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📝 GitHub PR Comments"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  PR Number:    #${PR_NUMBER}"
echo "  Comments:     ${COMMENTS_FILE}"
echo ""

# Count comments
COMMENT_COUNT=$(cat "$COMMENTS_FILE" | jq length)
echo "  📝 Found $COMMENT_COUNT comments to post"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

POSTED=0
FAILED=0

# Get the latest commit SHA for the PR
COMMIT_SHA=$(gh api "repos/elementor/elementor/pulls/$PR_NUMBER" --jq '.head.sha')

if [ -z "$COMMIT_SHA" ]; then
    echo "❌ Could not get commit SHA for PR #$PR_NUMBER"
    exit 1
fi

echo "  Commit SHA:   $COMMIT_SHA"
echo ""

# Process each comment
cat "$COMMENTS_FILE" | jq -c '.[]' | while read comment; do
    FILE=$(echo "$comment" | jq -r '.file')
    LINE=$(echo "$comment" | jq -r '.line')
    BODY=$(echo "$comment" | jq -r '.body')
    SEVERITY=$(echo "$comment" | jq -r '.severity // "Issue"')
    
    # Check if it has a suggestion
    HAS_SUGGESTION=$(echo "$BODY" | grep -q '```suggestion' && echo "✨" || echo "")
    
    echo "  ↳ $(basename "$FILE"):$LINE [$SEVERITY] $HAS_SUGGESTION"
    
    # Create payload for line-specific review comment
    # Build payload directly from original JSON to preserve newlines
    PAYLOAD=$(echo "$comment" | jq \
        --arg commit_id "$COMMIT_SHA" \
        '{
            body: .body,
            commit_id: $commit_id,
            path: .file,
            line: .line,
            side: "RIGHT"
        }')
    
    # Post line-specific review comment using GitHub API
    if gh api "repos/elementor/elementor/pulls/$PR_NUMBER/comments" \
        --method POST \
        --input - <<< "$PAYLOAD" > /dev/null 2>&1; then
        POSTED=$((POSTED + 1))
        echo "    ✅ Posted successfully"
    else
        FAILED=$((FAILED + 1))
        echo "    ❌ Failed to post"
    fi
    
    echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Summary:"
echo "  ✅ Posted: $POSTED"
echo "  ❌ Failed: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "🎉 All comments posted successfully!"
else
    echo "⚠️  Some comments failed to post. Check your permissions and PR status."
fi

echo ""
echo "🔗 View PR: https://github.com/elementor/elementor/pull/$PR_NUMBER"
echo ""