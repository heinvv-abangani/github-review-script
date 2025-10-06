#!/bin/bash
# Fetch PR data directly from GitHub API (bypasses MCP tool limits)

PR_URL=$1

if [ -z "$PR_URL" ]; then
  echo "Usage: ./scripts/fetch-pr-data.sh <PR_URL>"
  echo ""
  echo "Example:"
  echo "  ./scripts/fetch-pr-data.sh https://github.com/elementor/elementor/pull/123"
  exit 1
fi

# Extract PR info
if [[ $PR_URL =~ github\.com/([^/]+)/([^/]+)/pull/([0-9]+) ]]; then
    OWNER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
    PR_NUMBER="${BASH_REMATCH[3]}"
else
    echo "Error: Invalid PR URL format"
    echo "Expected: https://github.com/OWNER/REPO/pull/NUMBER"
    exit 1
fi

# Create output directory
OUTPUT_DIR="pr-reviews/data"
mkdir -p "$OUTPUT_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Fetching PR Data (No MCP - Direct API)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Repository: ${OWNER}/${REPO}"
echo "  PR Number:  #${PR_NUMBER}"
echo "  Output Dir: ${OUTPUT_DIR}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GITHUB_TOKEN not set"
    echo ""
    echo "Please set your GitHub token:"
    echo "  export GITHUB_TOKEN='ghp_your_token_here'"
    exit 1
fi

echo "🔑 Using GITHUB_TOKEN: ${GITHUB_TOKEN:0:4}...${GITHUB_TOKEN: -4} (${#GITHUB_TOKEN} chars)"
echo ""
echo "📥 Fetching PR details..."
HTTP_CODE=$(curl -s -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     "https://api.github.com/repos/$OWNER/$REPO/pulls/$PR_NUMBER" \
     -o "$OUTPUT_DIR/PR-${PR_NUMBER}-details.json")

if [ "$HTTP_CODE" -eq 200 ]; then
    echo "✅ PR details saved (HTTP $HTTP_CODE)"
else
    echo "❌ Failed to fetch PR details (HTTP $HTTP_CODE)"
    echo "Response content:"
    cat "$OUTPUT_DIR/PR-${PR_NUMBER}-details.json"
    echo ""
fi

echo "📥 Fetching PR diff..."
HTTP_CODE=$(curl -s -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" \
     -H "Accept: application/vnd.github.v3.diff" \
     "https://api.github.com/repos/$OWNER/$REPO/pulls/$PR_NUMBER" \
     -o "$OUTPUT_DIR/PR-${PR_NUMBER}.diff")

if [ "$HTTP_CODE" -eq 200 ]; then
    DIFF_SIZE=$(wc -l < "$OUTPUT_DIR/PR-${PR_NUMBER}.diff")
    echo "✅ PR diff saved ($DIFF_SIZE lines, HTTP $HTTP_CODE)"
else
    echo "❌ Failed to fetch PR diff (HTTP $HTTP_CODE)"
    echo "Response content:"
    head -10 "$OUTPUT_DIR/PR-${PR_NUMBER}.diff"
    echo ""
fi

echo "📥 Fetching changed files..."
curl -s -H "Authorization: token $GITHUB_TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     "https://api.github.com/repos/$OWNER/$REPO/pulls/$PR_NUMBER/files" \
     > "$OUTPUT_DIR/PR-${PR_NUMBER}-files.json"

if [ $? -eq 0 ]; then
    FILES_COUNT=$(cat "$OUTPUT_DIR/PR-${PR_NUMBER}-files.json" | grep -o '"filename"' | wc -l)
    echo "✅ Changed files saved ($FILES_COUNT files)"
else
    echo "❌ Failed to fetch changed files"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Data Downloaded Successfully"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Files created:"
echo "  📄 ${OUTPUT_DIR}/PR-${PR_NUMBER}-details.json"
echo "  📄 ${OUTPUT_DIR}/PR-${PR_NUMBER}.diff"
echo "  📄 ${OUTPUT_DIR}/PR-${PR_NUMBER}-files.json"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Next: Copy & Paste This Into Cursor Chat"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
cat << PROMPT
Review GitHub PR #${PR_NUMBER} from ${OWNER}/${REPO}

**PR Data Files:**
- Details: pr-reviews/data/PR-${PR_NUMBER}-details.json
- Diff: pr-reviews/data/PR-${PR_NUMBER}.diff  
- Files: pr-reviews/data/PR-${PR_NUMBER}-files.json

**Tasks:**

1. Read all three data files above
2. Parse the PR diff to understand all changes
3. Apply coding rules from: elementor-cursor-review-mcp/rules/
4. Generate comprehensive review with:
   
   **Format:**
   - Executive summary with risk assessment
   - Statistics (files changed, lines added/removed)
   - Critical Issues (blockers) 🚨
   - High Priority Issues ⚠️
   - Medium Priority Issues 📋
   - Code Style Suggestions 💅
   - Positive Observations ✅
   - Overall Recommendations

5. **For each issue include:**
   - File path and line number: [\`path/to/file.ts:123\`]
   - Rule violated: [rule-name]
   - Description of the issue
   - Why it matters (impact)
   - Recommended fix with code example

6. Save the complete review to:
   pr-reviews/PR-${PR_NUMBER}-$(date +%Y-%m-%d).md

**Important:**
- Be specific, not generic
- Include file:line references for EVERY issue
- Show code examples for recommended fixes
- Reference specific coding rules
- Acknowledge good practices, not just problems
PROMPT
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""



