#!/bin/bash
# Post structured comments from JSON to GitHub PR (with proper line break handling)

COMMENTS_FILE=$1
PR_URL=$2

if [ -z "$COMMENTS_FILE" ] || [ -z "$PR_URL" ]; then
  echo "Usage: ./scripts/post-comments-fixed.sh <comments-json> <PR_URL>"
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
echo "  Posting Comments to GitHub PR (Fixed)"
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
echo "📤 Posting comments with proper formatting..."
echo ""

# Use Python for proper JSON handling and line break conversion
python3 << PYTHON_SCRIPT
import json
import sys
import requests
import os

comments_file = "$COMMENTS_FILE"
owner = "$OWNER"
repo = "$REPO"
pr_number = "$PR_NUMBER"
commit_sha = "$COMMIT_SHA"
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
    
    # Python will properly handle the \n in the JSON string
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
        error_msg = response.json().get('message', 'Unknown error')
        print(f"    ❌ Failed: {error_msg}")
        failed += 1

print(f"\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print(f"  Summary")
print(f"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print(f"\n  ✅ Posted: {posted} comments")
print(f"  ❌ Failed: {failed} comments")
print(f"\n  View at: https://github.com/{owner}/{repo}/pull/{pr_number}\n")
print(f"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
PYTHON_SCRIPT

echo "Done!"
