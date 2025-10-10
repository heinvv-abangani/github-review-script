#!/bin/bash
# GitHub PR Review Script
# Usage: ./review.sh <PR_URL> [REPOSITORY]

set -e

PR_URL=$1

if [ -z "$PR_URL" ]; then
  echo "❌ Usage: ./review.sh <PR_URL>"
  echo ""
  echo "Example:"
  echo "  ./review.sh https://github.com/owner/repo/pull/123"
  echo ""
  echo "💡 Tip: Use ./fetch-pr.sh first to get complete PR data for easier review"
  exit 1
fi

# Setup GitHub authentication (prefer GITHUB_TOKEN)
if [[ -n "$GITHUB_TOKEN" ]]; then
    echo "🔐 Using GITHUB_TOKEN for authentication"
    export GH_TOKEN="$GITHUB_TOKEN"
elif ! gh auth status &> /dev/null 2>&1; then
    echo "❌ GitHub authentication required. Either:"
    echo "  1. Set GITHUB_TOKEN environment variable:"
    echo "     export GITHUB_TOKEN='your_token_here'"
    echo "  2. Or authenticate with GitHub CLI:"
    echo "     gh auth login"
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
       "body": "Cursor Review: 🚨 **Critical Issue**\\n\\n**Rule:** [rule-name]\\n\\n**Issue:** [description]\\n\\n**Suggested Fix:**\\n\`\`\`suggestion\\n// Fixed code here\\nconst fixedCode = 'example';\\n\`\`\`",
       "severity": "CRITICAL",
       "suggestion": {
         "original_code": "const brokenCode = 'example';",
         "suggested_code": "const fixedCode = 'example';"
       }
     }
   ]
   \`\`\`
   
   **Rules for JSON:**
   - Only include Critical and High severity issues
   - Start each body with "Cursor Review: " prefix
   - Use \\n for newlines in body
   - Include file path and line number
   - Escape quotes properly
   - Make actionable and specific
   - **ALWAYS include suggestions when possible:**
     - Use \`\`\`suggestion code blocks in body for GitHub commit suggestions
     - Add optional "suggestion" object with original_code and suggested_code
     - Suggestions should be complete, working code replacements
     - **PREFER single-line suggestions when possible:**
       * Primary issue is in one line (condition, assignment, function call)
       * Fix involves adding/removing/changing one logical element
       * Use multi-line ONLY when fix requires restructuring multiple lines
     - **Multi-line suggestions only when:**
       * Logic restructuring spans multiple lines
       * Adding new conditional blocks or try-catch blocks
       * Refactoring requires changing multiple related lines
     - Ensure suggested code follows project coding standards

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
