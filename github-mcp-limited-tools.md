# GitHub MCP - Limited Tools Configuration

**Problem:** GitHub MCP loads 101 tools by default, exceeding Cursor's tool limit.

**Solution:** Configure GitHub MCP to only expose tools needed for PR reviews.

---

## Tools Needed for PR Reviews

You only need these **15 tools** out of 101:

### Core PR Tools (Required)
1. `get_pull_request` - Get PR details
2. `list_pull_requests` - List PRs in repo
3. `get_pull_request_diff` - Get PR diff (the changes)
4. `get_pull_request_files` - List changed files
5. `get_file_contents` - Read file contents
6. `search_code` - Search in codebase

### Review Comment Tools (Optional - only if posting to GitHub)
7. `create_review_comment` - Post inline PR comments
8. `list_review_comments` - See existing comments
9. `create_review` - Create PR review
10. `list_reviews` - List PR reviews

### Repository Tools (Nice to have)
11. `get_repository` - Get repo info
12. `list_commits` - See commit history
13. `get_commit` - Get specific commit

### Issue Tools (Optional)
14. `get_issue` - Get issue details (if reviewing issue-related PRs)
15. `list_issues` - List issues

---

## Updated Configuration

### Option 1: Environment Variable Filter (Recommended)

Update your `~/.cursor/mcp.json` GitHub section to include tool filtering:

```json
"github": {
    "command": "/usr/local/bin/prompt_security/prompt_security_mcp",
    "args": [
        "/Users/janvanvlastuin1981/.cursor/mcp.json",
        "github"
    ],
    "server": {
        "command": "docker",
        "args": [
            "run",
            "-i",
            "--rm",
            "-e",
            "GITHUB_PERSONAL_ACCESS_TOKEN",
            "-e",
            "MCP_TOOLS_FILTER",
            "ghcr.io/github/github-mcp-server:latest"
        ],
        "env": {
            "GITHUB_PERSONAL_ACCESS_TOKEN": "${env:GITHUB_TOKEN}",
            "MCP_TOOLS_FILTER": "get_pull_request,list_pull_requests,get_pull_request_diff,get_pull_request_files,get_file_contents,search_code,create_review_comment,list_review_comments,create_review,list_reviews,get_repository,list_commits,get_commit"
        }
    }
}
```

### Option 2: Minimal (Only Read Operations)

If filtering doesn't work, use absolute minimum (read-only):

```json
"github": {
    "command": "/usr/local/bin/prompt_security/prompt_security_mcp",
    "args": [
        "/Users/janvanvlastuin1981/.cursor/mcp.json",
        "github"
    ],
    "server": {
        "command": "docker",
        "args": [
            "run",
            "-i",
            "--rm",
            "-e",
            "GITHUB_PERSONAL_ACCESS_TOKEN",
            "-e",
            "GITHUB_MCP_MODE=minimal",
            "ghcr.io/github/github-mcp-server:latest"
        ],
        "env": {
            "GITHUB_PERSONAL_ACCESS_TOKEN": "${env:GITHUB_TOKEN}",
            "GITHUB_MCP_MODE": "minimal"
        }
    }
}
```

---

## Alternative: Use GitHub API Directly (Bypasses MCP)

If tool filtering doesn't work, you can bypass MCP entirely and use GitHub API directly.

### Create: `scripts/fetch-pr-data.sh`

```bash
#!/bin/bash
# Fetch PR data directly from GitHub API (no MCP needed)

PR_URL=$1

# Extract PR info
if [[ $PR_URL =~ github\.com/([^/]+)/([^/]+)/pull/([0-9]+) ]]; then
    OWNER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
    PR_NUMBER="${BASH_REMATCH[3]}"
else
    echo "Error: Invalid PR URL"
    exit 1
fi

OUTPUT_DIR="pr-reviews/data"
mkdir -p "$OUTPUT_DIR"

echo "Fetching PR #${PR_NUMBER} from ${OWNER}/${REPO}..."

# Fetch PR details
curl -s -H "Authorization: token $GITHUB_TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     "https://api.github.com/repos/$OWNER/$REPO/pulls/$PR_NUMBER" \
     > "$OUTPUT_DIR/PR-${PR_NUMBER}-details.json"

# Fetch PR diff
curl -s -H "Authorization: token $GITHUB_TOKEN" \
     -H "Accept: application/vnd.github.v3.diff" \
     "https://api.github.com/repos/$OWNER/$REPO/pulls/$PR_NUMBER" \
     > "$OUTPUT_DIR/PR-${PR_NUMBER}.diff"

# Fetch changed files
curl -s -H "Authorization: token $GITHUB_TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     "https://api.github.com/repos/$OWNER/$REPO/pulls/$PR_NUMBER/files" \
     > "$OUTPUT_DIR/PR-${PR_NUMBER}-files.json"

echo "✅ Data saved to: $OUTPUT_DIR/"
echo ""
echo "Now paste this into Cursor chat:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat << PROMPT

Review this GitHub PR data:

**PR Details:** See pr-reviews/data/PR-${PR_NUMBER}-details.json
**PR Diff:** See pr-reviews/data/PR-${PR_NUMBER}.diff  
**Changed Files:** See pr-reviews/data/PR-${PR_NUMBER}-files.json

Tasks:
1. Read all three files above
2. Apply coding rules from elementor-cursor-review-mcp/rules/
3. Generate comprehensive review with:
   - Executive summary
   - Issues by severity (Critical/High/Medium/Low)
   - File:line references for each issue
   - Rule violations with examples
   - Recommended fixes with code
4. Save to: pr-reviews/PR-${PR_NUMBER}-$(date +%Y-%m-%d).md

PROMPT
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

---

## Quick Fix Script

```bash
#!/bin/bash
# Apply the filtered GitHub MCP config

echo "Backing up current config..."
cp ~/.cursor/mcp.json ~/.cursor/mcp.json.backup-before-filter

echo "Updating GitHub MCP configuration..."
# You'll need to manually edit the file with the config above

echo "Done! Restart Cursor to apply changes."
```

---

## Comparison

| Approach | Tools Count | Pros | Cons |
|----------|-------------|------|------|
| **All GitHub Tools** | 101 | Everything available | Exceeds limit |
| **Filtered Tools** | 15 | Focused, under limit | May need to add tools later |
| **Minimal Mode** | ~10 | Smallest footprint | Very limited |
| **Direct API (no MCP)** | 0 | No tool limit issues | Manual data fetching |

---

## Recommended Solution

**Use Option 1 (Filtered Tools)** - Strike the perfect balance:
- Only 15 tools (well under limit)
- All PR review capabilities
- Can still post comments
- Can add more tools if needed

---

## Implementation Steps

1. **Update mcp.json** with Option 1 config
2. **Restart Cursor** completely
3. **Check tool count** - should show ~15 instead of 101
4. **Test PR review** - should work normally

---

## Verification

After restart, check how many GitHub tools loaded:

1. Open Cursor Developer Tools: `Help` → `Toggle Developer Tools`
2. Console tab
3. Search for "github" or "mcp"
4. Should see something like: "Loaded 15 tools from github MCP"

---

## If Filtering Doesn't Work

Some versions of GitHub MCP might not support filtering. In that case:

**Fallback: Use Direct API Script**
- No MCP needed
- No tool limit issues
- Slightly more manual but works reliably

See the `fetch-pr-data.sh` script above.

---

**Last Updated:** October 6, 2025



