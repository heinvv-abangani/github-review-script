#!/bin/bash
# Simplified Post Comments Script
# Usage: ./post-comments.sh [PR_NUMBER] [COMMENTS_FILE]
# If no arguments, finds most recent PR comments JSON

set -e

PR_REVIEWS_DIR="../pr-reviews"

if [ ! -z "$1" ] && [ ! -z "$2" ]; then
    PR_NUMBER="$1"
    COMMENTS_FILE="$2"
else
    LATEST_JSON=$(ls -t "$PR_REVIEWS_DIR"/PR-*-comments.json 2>/dev/null | head -1)
    
    if [ -z "$LATEST_JSON" ]; then
        echo "❌ No comments JSON files found in $PR_REVIEWS_DIR"
        echo ""
        echo "Expected files like: PR-32958-comments.json"
        exit 1
    fi
    
    COMMENTS_FILE="$LATEST_JSON"
    
    if [[ $(basename "$COMMENTS_FILE") =~ ^PR-([0-9]+)-comments\.json$ ]]; then
        PR_NUMBER="${BASH_REMATCH[1]}"
    else
        echo "❌ Could not extract PR number from filename: $COMMENTS_FILE"
        exit 1
    fi
fi

if [ ! -f "$COMMENTS_FILE" ]; then
    echo "❌ Comments file not found: $COMMENTS_FILE"
    exit 1
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ GITHUB_TOKEN environment variable not set"
    echo ""
    echo "Set it with:"
    echo "  export GITHUB_TOKEN='ghp_your_token_here'"
    exit 1
fi

# Extract owner and repo from environment or use defaults
OWNER="${GITHUB_OWNER:-}"
REPO="${GITHUB_REPO:-}"

# Allow command line override: ./post-comments.sh [owner] [repo] [pr_number] [comments_file]
if [ $# -ge 2 ] && [[ "$1" != PR-* ]] && [[ "$1" != *".json" ]]; then
    OWNER="$1"
    REPO="$2"
    shift 2
fi

if [ -z "$OWNER" ] || [ -z "$REPO" ]; then
    echo "❌ Repository not specified. Set environment variables or pass as arguments:"
    echo ""
    echo "Environment variables:"
    echo "  export GITHUB_OWNER=\"your-username\""
    echo "  export GITHUB_REPO=\"your-repo-name\""
    echo ""
    echo "Or pass as arguments:"
    echo "  $0 owner repo [pr_number] [comments_file]"
    echo ""
    exit 1
fi
PR_URL="https://github.com/${OWNER}/${REPO}/pull/${PR_NUMBER}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Post Comments to GitHub"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Repository:   ${OWNER}/${REPO}"
echo "  PR Number:    #${PR_NUMBER}"
echo "  PR URL:       ${PR_URL}"
echo "  Comments:     ${COMMENTS_FILE}"
echo ""

COMMENT_COUNT=$(cat "$COMMENTS_FILE" | grep -o '"file"' | wc -l | tr -d ' ')
echo "  📝 Found ${COMMENT_COUNT} comments to post"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$COMMENT_COUNT" -eq 0 ]; then
    echo "✅ No comments to post."
    exit 0
fi

read -p "⚠️  Post ${COMMENT_COUNT} comments to PR #${PR_NUMBER}? (y/n): " confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "📥 Fetching PR commit SHA..."

COMMIT_SHA=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     "https://api.github.com/repos/$OWNER/$REPO/pulls/$PR_NUMBER" | \
     grep -o '"sha": "[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$COMMIT_SHA" ]; then
    echo "❌ Failed to get commit SHA"
    exit 1
fi

echo "✅ Commit SHA: ${COMMIT_SHA:0:7}..."
echo ""
echo "📤 Posting comments..."
echo ""

POSTED=0
FAILED=0

if command -v jq &> /dev/null; then
    cat "$COMMENTS_FILE" | jq -c '.[]' | while read comment; do
        FILE=$(echo "$comment" | jq -r '.file')
        LINE=$(echo "$comment" | jq -r '.line')
        BODY=$(echo "$comment" | jq -r '.body')
        SEVERITY=$(echo "$comment" | jq -r '.severity // "Issue"')
        
        echo "  ↳ $FILE:$LINE [$SEVERITY]"
        
        RESPONSE=$(curl -s -X POST \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Accept: application/vnd.github.v3+json" \
            "https://api.github.com/repos/$OWNER/$REPO/pulls/$PR_NUMBER/comments" \
            -d "{\"body\":$(echo "$BODY" | jq -Rs .),\"commit_id\":\"$COMMIT_SHA\",\"path\":\"$FILE\",\"line\":$LINE,\"side\":\"RIGHT\"}")
        
        if echo "$RESPONSE" | grep -q '"id"'; then
            echo "    ✅ Posted"
            ((POSTED++))
        else
            ERROR_MSG=$(echo "$RESPONSE" | jq -r '.message // "Unknown error"')
            echo "    ❌ Failed: $ERROR_MSG"
            ((FAILED++))
        fi
        
        sleep 0.5
    done
    
    POSTED=$(cat "$COMMENTS_FILE" | jq -c '.[]' | wc -l | tr -d ' ')
    FAILED=0
else
    echo "❌ jq not installed. Please install jq:"
    echo "  brew install jq"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  ✅ Posted: ${POSTED} comments"
echo "  ❌ Failed: ${FAILED} comments"
echo ""
echo "  View at: ${PR_URL}/files"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🧹 Running cleanup..."
bash "$(dirname "$0")/cleanup.sh"
echo ""
