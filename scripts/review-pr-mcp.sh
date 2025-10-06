#!/bin/bash
# PR Review via GitHub MCP
# Usage: ./scripts/review-pr-mcp.sh <PR_URL>

PR_URL=$1

if [ -z "$PR_URL" ]; then
  echo "Usage: ./scripts/review-pr-mcp.sh <PR_URL>"
  echo ""
  echo "Example:"
  echo "  ./scripts/review-pr-mcp.sh https://github.com/elementor/elementor/pull/123"
  exit 1
fi

# Extract PR number from URL
if [[ $PR_URL =~ github\.com/([^/]+)/([^/]+)/pull/([0-9]+) ]]; then
    OWNER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
    PR_NUMBER="${BASH_REMATCH[3]}"
else
    echo "Error: Invalid PR URL format"
    echo "Expected: https://github.com/OWNER/REPO/pull/NUMBER"
    exit 1
fi

# Create review output directory
mkdir -p pr-reviews

# Output file with timestamp
REVIEW_FILE="pr-reviews/PR-${PR_NUMBER}-$(date +%Y-%m-%d).md"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  GitHub PR Review via MCP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Repository: ${OWNER}/${REPO}"
echo "  PR Number:  #${PR_NUMBER}"
echo "  Review URL: ${PR_URL}"
echo "  Output:     ${REVIEW_FILE}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 INSTRUCTIONS:"
echo ""
echo "1. Open Cursor in this workspace"
echo "2. Open the AI Chat panel"
echo "3. Copy and paste the prompt below into Cursor chat"
echo "4. Wait for the review to complete"
echo "5. Review the generated markdown file: ${REVIEW_FILE}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 CURSOR CHAT PROMPT (copy everything between the lines):"
echo ""
echo "════════════════════════════════════════════════════════"
cat << PROMPT

Please review GitHub PR: ${PR_URL}

**Tasks:**

1. **Fetch PR Data via GitHub MCP:**
   - Get PR details (title, description, author)
   - Fetch complete diff
   - List all changed files

2. **Load Coding Rules:**
   - Apply all 22 rules from: elementor-cursor-review-mcp/rules/
   - Focus on: TypeScript, React, PHP, WordPress, Security, Testing

3. **Analyze Changes:**
   - Review each changed file against applicable rules
   - Identify violations, risks, and improvement opportunities
   - Note positive patterns and good practices

4. **Generate Structured Review:**
   
   Save review to: ${REVIEW_FILE}
   
   **Format:**
   \`\`\`markdown
   # PR Review: #${PR_NUMBER} - [PR_TITLE]
   
   **Date:** $(date +"%Y-%m-%d %H:%M:%S")
   **Repository:** ${OWNER}/${REPO}
   **PR URL:** ${PR_URL}
   **Reviewer:** Cursor AI via GitHub MCP
   **Status:** [PASSED | NEEDS_WORK | BLOCKED]
   
   ## Executive Summary
   
   [2-3 paragraph overview of changes, quality assessment, and risk level]
   
   ## Statistics
   
   - Files Changed: [count]
   - Lines Added: [count]
   - Lines Removed: [count]
   - Critical Issues: [count]
   - High Priority Issues: [count]
   - Medium Priority Issues: [count]
   - Positive Observations: [count]
   
   ## Critical Issues (Blockers) 🚨
   
   ### [Issue Title]
   - **File:** [\`path/to/file.ts:123\`](${PR_URL}/files#diff-...)
   - **Rule:** [rule-name] (elementor-cursor-review-mcp/rules/[rule-file].md)
   - **Severity:** Critical
   - **Description:** [Detailed issue description]
   - **Impact:** [Why this is critical]
   - **Recommended Fix:**
     \`\`\`typescript
     // Current (problematic)
     [current code]
     
     // Recommended
     [fixed code]
     \`\`\`
   
   ## High Priority Issues ⚠️
   
   [Same format as Critical]
   
   ## Medium Priority Issues 📋
   
   [Same format as Critical]
   
   ## Code Style Suggestions 💅
   
   [Same format, but less detailed]
   
   ## Positive Observations ✅
   
   - [\`file.ts\`] Great use of TypeScript generics
   - [\`component.tsx\`] Well-structured React component with proper hooks usage
   - [\`functions.php\`] Excellent WordPress security practices
   
   ## Security Assessment 🔒
   
   [Specific security analysis]
   
   ## Performance Considerations ⚡
   
   [Performance impact analysis]
   
   ## Testing Coverage 🧪
   
   [Testing assessment]
   
   ## Overall Recommendations
   
   1. [Priority 1 recommendation]
   2. [Priority 2 recommendation]
   3. [Priority 3 recommendation]
   
   ## Conclusion
   
   [Final assessment and merge recommendation]
   
   ---
   
   **Review Completed:** $(date +"%Y-%m-%d %H:%M:%S")
   **Next Steps:** [What should happen next]
   \`\`\`

5. **Summary:**
   - Provide quick stats (X files, Y issues found)
   - Highlight top 3 most important findings
   - Recommend whether to approve, request changes, or block

**Important:**
- Include file path AND line number for EVERY issue: [\`path/to/file.ext:123\`]
- Reference specific coding rule for each violation
- Provide code examples for recommended fixes
- Be specific, not generic
- Acknowledge good practices, not just problems

PROMPT
echo "════════════════════════════════════════════════════════"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⏳ After pasting the prompt:"
echo ""
echo "  1. Wait for Cursor to connect to GitHub MCP"
echo "  2. Monitor progress in chat"
echo "  3. Review will be saved automatically"
echo "  4. Open ${REVIEW_FILE} when complete"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📤 Optional: Post Comments to GitHub"
echo ""
echo "After reviewing the output, you can post inline comments:"
echo ""
echo "Cursor Chat Prompt:"
echo "════════════════════════════════════════════════════════"
echo "Please post the Critical and High priority issues from"
echo "${REVIEW_FILE}"
echo "to GitHub PR #${PR_NUMBER} as inline review comments."
echo ""
echo "Only post issues with clear file:line references."
echo "Ask for confirmation before posting each comment."
echo "════════════════════════════════════════════════════════"
echo ""




