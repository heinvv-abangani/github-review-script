#!/bin/bash
# Simplified PR Review Script
# Usage: ./review.sh <PR_URL>

set -e

PR_URL=$1

if [ -z "$PR_URL" ]; then
  echo "❌ Usage: ./review.sh <PR_URL>"
  echo ""
  echo "Example:"
  echo "  ./review.sh https://github.com/elementor/elementor/pull/32958"
  exit 1
fi

if [[ $PR_URL =~ github\.com/([^/]+)/([^/]+)/pull/([0-9]+) ]]; then
    OWNER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
    PR_NUMBER="${BASH_REMATCH[3]}"
else
    echo "❌ Invalid PR URL format"
    echo "Expected: https://github.com/OWNER/REPO/pull/NUMBER"
    exit 1
fi

PR_REVIEWS_DIR="../pr-reviews"
mkdir -p "$PR_REVIEWS_DIR"

REVIEW_FILE="${PR_REVIEWS_DIR}/PR-${PR_NUMBER}-$(date +%Y-%m-%d).md"
COMMENTS_FILE="${PR_REVIEWS_DIR}/PR-${PR_NUMBER}-comments.json"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  GitHub PR Review"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Repository:  ${OWNER}/${REPO}"
echo "  PR Number:   #${PR_NUMBER}"
echo "  PR URL:      ${PR_URL}"
echo ""
echo "  Output:"
echo "    Review:    ${REVIEW_FILE}"
echo "    Comments:  ${COMMENTS_FILE}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Copy this prompt to Cursor Chat:"
echo ""
echo "════════════════════════════════════════════════════════"
cat << PROMPT

Review GitHub PR: ${PR_URL}

**Tasks:**

1. **Fetch PR Data:**
   - Get PR details, diff, and changed files

2. **Apply Coding Rules:**
   - Load all rules from: github-review-script/rules/
   - Focus on TypeScript, React, PHP, WordPress, Security

3. **Generate Review:**
   - Save markdown review to: ${REVIEW_FILE}
   - Save comments JSON to: ${COMMENTS_FILE}
   
   **Comments JSON Format:**
   \`\`\`json
   [
     {
       "file": "path/to/file.js",
       "line": 42,
       "body": "TMZ Review MCP: 🚨 **Critical Issue**\\n\\n**Rule:** [rule-name]\\n\\n**Issue:** [description]\\n\\n**Fix:**\\n\`\`\`javascript\\n// Recommended\\n[code]\\n\`\`\`",
       "severity": "CRITICAL"
     }
   ]
   \`\`\`
   
   **Rules for JSON:**
   - Only include Critical and High severity issues
   - Start each body with "TMZ Review MCP: " prefix
   - Use \\n for newlines in body
   - Include file path and line number
   - Escape quotes properly
   - Make actionable and specific

4. **Summary:**
   - Display statistics
   - Highlight top 3 findings
   - Recommend approval status

PROMPT
echo "════════════════════════════════════════════════════════"
echo ""
echo "⏳ After review completes:"
echo ""
echo "  1. Review the markdown: ${REVIEW_FILE}"
echo "  2. Post comments: ./post-comments.sh"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
