#!/bin/bash
# Post structured comments from JSON to GitHub PR

COMMENTS_FILE=$1
PR_URL=$2

if [ -z "$COMMENTS_FILE" ] || [ -z "$PR_URL" ]; then
  echo "Usage: ./scripts/post-comments-from-json.sh <comments-json> <PR_URL>"
  exit 1
fi

# Check file exists
if [ ! -f "$COMMENTS_FILE" ]; then
    echo "❌ Error: Comments file not found: $COMMENTS_FILE"
    exit 1
fi

# Extract PR info
if [[ $PR_URL =~ github\.com/([^/]+)/([^/]+)/pull/([0-9]+) ]]; then
    OWNER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
    PR_NUMBER="${BASH_REMATCH[3]}"
else
    echo "❌ Error: Invalid PR URL"
    exit 1
fi

# Check token
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GITHUB_TOKEN not set"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Posting Comments to GitHub PR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Repository:  ${OWNER}/${REPO}"
echo "  PR Number:   #${PR_NUMBER}"
echo "  Comments:    $COMMENTS_FILE"
echo ""

# Get the latest commit SHA
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

# Count comments
COMMENT_COUNT=$(cat "$COMMENTS_FILE" | grep -o '"file"' | wc -l | tr -d ' ')
echo "📝 Found $COMMENT_COUNT comments to post"
echo ""

# Confirm before posting
read -p "⚠️  Post $COMMENT_COUNT comments to PR #$PR_NUMBER? (y/n): " confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "📤 Posting comments..."
echo ""

# Post each comment
POSTED=0
FAILED=0

# Use jq if available, otherwise Python
if command -v jq &> /dev/null; then
    # Using jq
    cat "$COMMENTS_FILE" | jq -c '.[]' | while read comment; do
        FILE=$(echo "$comment" | jq -r '.file')
        LINE=$(echo "$comment" | jq -r '.line')
        BODY=$(echo "$comment" | jq -r '.body')
        SEVERITY=$(echo "$comment" | jq -r '.severity')
        
        echo "  ↳ $FILE:$LINE [$SEVERITY]"
        
        # Create comment
        RESPONSE=$(curl -s -X POST \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Accept: application/vnd.github.v3+json" \
            "https://api.github.com/repos/$OWNER/$REPO/pulls/$PR_NUMBER/comments" \
            -d @- << EOF
{
  "body": "$BODY",
  "commit_id": "$COMMIT_SHA",
  "path": "$FILE",
  "line": $LINE,
  "side": "RIGHT"
}
EOF
        )
        
        if echo "$RESPONSE" | grep -q '"id"'; then
            echo "    ✅ Posted"
            ((POSTED++))
        else
            echo "    ❌ Failed: $(echo "$RESPONSE" | grep -o '"message":"[^"]*"' | cut -d'"' -f4)"
            ((FAILED++))
        fi
    done
else
    # Using Python as fallback
    python3 << 'PYTHON_SCRIPT'
import json
import sys
import requests
import os

comments_file = sys.argv[1] if len(sys.argv) > 1 else os.environ.get('COMMENTS_FILE')
owner = os.environ.get('OWNER')
repo = os.environ.get('REPO')
pr_number = os.environ.get('PR_NUMBER')
commit_sha = os.environ.get('COMMIT_SHA')
token = os.environ.get('GITHUB_TOKEN')

with open(comments_file) as f:
    comments = json.load(f)

posted = 0
failed = 0

for comment in comments:
    file_path = comment['file']
    line = comment['line']
    body = comment['body']
    severity = comment.get('severity', 'Issue')
    
    print(f"  ↳ {file_path}:{line} [{severity}]")
    
    url = f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}/comments"
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github.v3+json'
    }
    data = {
        'body': body,
        'commit_id': commit_sha,
        'path': file_path,
        'line': line,
        'side': 'RIGHT'
    }
    
    response = requests.post(url, headers=headers, json=data)
    
    if response.status_code == 201:
        print("    ✅ Posted")
        posted += 1
    else:
        print(f"    ❌ Failed: {response.json().get('message', 'Unknown error')}")
        failed += 1

print(f"\n✅ Posted: {posted}")
print(f"❌ Failed: {failed}")
PYTHON_SCRIPT
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  ✅ Posted: $POSTED comments"
echo "  ❌ Failed: $FAILED comments"
echo ""
echo "  View at: $PR_URL"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
