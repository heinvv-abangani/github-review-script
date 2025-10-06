# Direct API Approach (No MCP - Recommended)

**Status:** ✅ GitHub MCP disabled (was loading 101 tools)  
**Solution:** Use Direct API - simpler, faster, zero tool limits

---

## Why Direct API?

- ✅ **Zero MCP tools used** - no limits
- ✅ **Simpler** - just fetch data, review, done
- ✅ **Faster** - no MCP overhead
- ✅ **More reliable** - no Docker/MCP dependencies during review
- ✅ **100% transparent** - see exactly what data you're reviewing

---

## How It Works

```
1. Run script → Downloads PR data from GitHub API
2. Script generates prompt → Copy it
3. Paste in Cursor → Reviews local files
4. Get review → Markdown file with findings
```

**No MCP. No tool limits. Just works.** ✨

---

## 🚀 Quick Start

### Review a PR in 3 Steps:

```bash
# Step 1: Fetch PR data
./scripts/fetch-pr-data.sh https://github.com/elementor/elementor/pull/27890

# Step 2: Copy the prompt the script shows

# Step 3: Paste in Cursor chat → Wait for review
```

That's it! Review generated at `pr-reviews/PR-27890-2025-10-06.md`

---

## 📋 Complete Example

### 1. Pick a PR to Review

Let's say you want to review: https://github.com/elementor/elementor/pull/27890

### 2. Fetch the Data

```bash
cd "/Users/janvanvlastuin1981/Local Sites/elementor/app/public/wp-content"

./scripts/fetch-pr-data.sh https://github.com/elementor/elementor/pull/27890
```

**Output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Fetching PR Data (No MCP - Direct API)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Repository: elementor/elementor
  PR Number:  #27890
  Output Dir: pr-reviews/data

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📥 Fetching PR details...
✅ PR details saved
📥 Fetching PR diff...
✅ PR diff saved (234 lines)
📥 Fetching changed files...
✅ Changed files saved (5 files)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Data Downloaded Successfully
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Files created:
  📄 pr-reviews/data/PR-27890-details.json
  📄 pr-reviews/data/PR-27890.diff
  📄 pr-reviews/data/PR-27890-files.json

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Next: Copy & Paste This Into Cursor Chat
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[PROMPT SHOWN HERE]
```

### 3. Copy the Prompt

The script shows a ready-to-use prompt. Copy everything.

### 4. Paste in Cursor

Open Cursor chat (Cmd+L), paste the prompt, press Enter.

### 5. Wait for Review

Cursor will:
- ✅ Read the 3 data files
- ✅ Parse the diff
- ✅ Apply 22 coding rules
- ✅ Generate comprehensive review
- ✅ Save to `pr-reviews/PR-27890-2025-10-06.md`

### 6. Open the Review

```bash
open pr-reviews/PR-27890-2025-10-06.md
```

---

## 📁 What Gets Downloaded

For each PR, you get 3 files in `pr-reviews/data/`:

### 1. `PR-{NUMBER}-details.json`
```json
{
  "number": 27890,
  "title": "Fix: Navigation bug in mobile view",
  "state": "open",
  "user": { "login": "developer-name" },
  "body": "Description of changes...",
  "created_at": "2025-10-06T10:30:00Z",
  "additions": 45,
  "deletions": 12,
  "changed_files": 5
}
```

### 2. `PR-{NUMBER}.diff`
```diff
diff --git a/modules/nav/nav.tsx b/modules/nav/nav.tsx
index abc123..def456 100644
--- a/modules/nav/nav.tsx
+++ b/modules/nav/nav.tsx
@@ -10,7 +10,7 @@ export function Nav() {
-  const [isOpen, setIsOpen] = useState(false);
+  const [isOpen, setIsOpen] = useState<boolean>(false);
```

### 3. `PR-{NUMBER}-files.json`
```json
[
  {
    "filename": "modules/nav/nav.tsx",
    "status": "modified",
    "additions": 30,
    "deletions": 8,
    "changes": 38
  }
]
```

---

## 🎯 What Cursor Does

When you paste the prompt, Cursor:

1. **Reads** all 3 data files
2. **Parses** the diff line by line
3. **Applies** coding rules from `elementor-cursor-review-mcp/rules/`
4. **Identifies** issues (Critical/High/Medium/Low)
5. **Generates** review with:
   - Executive summary
   - Statistics
   - Issues by severity
   - File:line references
   - Code examples
   - Recommended fixes
   - Positive observations
6. **Saves** to `pr-reviews/PR-{NUMBER}-{date}.md`

---

## 📊 Review Output Example

```markdown
# PR Review: #27890 - Fix navigation bug in mobile view

**Date:** 2025-10-06 13:45:00
**Repository:** elementor/elementor
**Status:** NEEDS_WORK

## Executive Summary
This PR fixes a mobile navigation bug affecting 5 files...

## Statistics
- Files Changed: 5
- Lines Added: 45
- Lines Removed: 12
- Critical Issues: 1
- High Priority: 2
- Medium Priority: 5

## Critical Issues (Blockers) 🚨

### Missing TypeScript Type for useState
- **File:** [`modules/nav/nav.tsx:13`](https://github.com/elementor/elementor/pull/27890/files#...)
- **Rule:** typescript-safety
- **Severity:** Critical
- **Description:** useState missing explicit type parameter
- **Recommended Fix:**
  ```typescript
  // Current
  const [isOpen, setIsOpen] = useState(false);
  
  // Recommended
  const [isOpen, setIsOpen] = useState<boolean>(false);
  ```

[... more issues ...]

## Recommendations
1. Fix critical type safety issue before merge
2. Add unit tests for navigation component
3. Consider performance optimization for re-renders
```

---

## 🔄 Workflow Variations

### Review Multiple PRs

```bash
# PR 1
./scripts/fetch-pr-data.sh https://github.com/elementor/elementor/pull/100
# Copy prompt → Paste in Cursor

# PR 2
./scripts/fetch-pr-data.sh https://github.com/elementor/elementor/pull/101
# Copy prompt → Paste in Cursor

# Reviews: pr-reviews/PR-100-*.md and PR-101-*.md
```

### Focus on Specific Aspects

Modify the prompt to focus on specific concerns:

```
Review PR #27890 focusing on:
1. TypeScript type safety issues
2. React performance problems
3. Security vulnerabilities

[rest of prompt...]
```

### Quick Stats Only

```
Read pr-reviews/data/PR-27890-details.json and 
give me a quick summary: files changed, additions, 
deletions, and complexity assessment.
```

---

## 💡 Pro Tips

### 1. Review Before Requesting Human Review
```bash
# Your workflow:
1. Create PR
2. Run: ./scripts/fetch-pr-data.sh <YOUR_PR_URL>
3. Get AI review
4. Fix critical issues
5. Then request human review
```

### 2. Compare Multiple PRs
```bash
# Fetch data for competing approaches
./scripts/fetch-pr-data.sh <PR_1>
./scripts/fetch-pr-data.sh <PR_2>

# Then ask Cursor:
"Compare PR-100 and PR-101 approaches, which is better?"
```

### 3. Learn from Reviews
```bash
# After getting review, ask:
"Explain why the issue in nav.tsx:13 violates typescript-safety rule"
"Show me more examples of this pattern"
```

### 4. Archive Old Reviews
```bash
# Clean up old data
rm -rf pr-reviews/data/PR-*
# Reviews are in pr-reviews/PR-*.md (keep these)
```

---

## 🎓 Understanding the Data Files

### When to Look at Each File:

**PR Details (JSON):**
- See PR metadata
- Check who created it
- Review description
- See comment count

**PR Diff:**
- See exact code changes
- Understand what was modified
- Review additions/deletions line by line

**Changed Files (JSON):**
- Quick overview of impact
- See which files touched
- Assess PR size/complexity

---

## 🔧 Customization

### Adjust Script Output

Edit `scripts/fetch-pr-data.sh` to:
- Change output directory
- Add more API calls
- Customize prompt template
- Add pre-processing

### Create Specialized Prompts

```bash
# Security-focused review
./scripts/fetch-pr-data.sh <PR_URL>
# Then modify prompt to focus on security only
```

---

## ✅ Benefits Over MCP

| Feature | GitHub MCP | Direct API |
|---------|------------|------------|
| **Tool Limit** | 101 tools (exceeds limit) | 0 tools ✅ |
| **Setup** | Docker + config | Just GITHUB_TOKEN ✅ |
| **Speed** | MCP overhead | Direct & fast ✅ |
| **Reliability** | MCP dependencies | Just curl ✅ |
| **Debugging** | Opaque MCP layer | See exact API calls ✅ |
| **Transparency** | Black box | Full visibility ✅ |

---

## 🐛 Troubleshooting

### "GITHUB_TOKEN not set"
```bash
export GITHUB_TOKEN="ghp_your_token_here"
echo 'export GITHUB_TOKEN="ghp_..."' >> ~/.zshrc
```

### "curl: command not found"
```bash
# On Mac, curl is built-in. If missing:
brew install curl
```

### "Failed to fetch PR details"
```bash
# Test your token:
curl -H "Authorization: token $GITHUB_TOKEN" \
     https://api.github.com/user

# Should return your GitHub user info
```

### Files Not Created
```bash
# Check permissions:
ls -la pr-reviews/data/

# Recreate directory:
rm -rf pr-reviews/data && mkdir -p pr-reviews/data
```

---

## 📚 Next Steps

1. ✅ **Restart Cursor** (GitHub MCP is now disabled)
2. ✅ **Test the script:**
   ```bash
   ./scripts/fetch-pr-data.sh https://github.com/elementor/elementor/pull/[NUMBER]
   ```
3. ✅ **Review your first PR** using direct API
4. ✅ **Enjoy zero tool limit issues!**

---

## 🎉 You're All Set!

This approach is:
- ✅ Simpler than MCP
- ✅ More reliable
- ✅ Actually faster
- ✅ Zero tool limits
- ✅ More transparent

**Just run the script, copy the prompt, paste in Cursor. Done.** 🚀

---

**Last Updated:** October 6, 2025  
**Status:** Production Ready - Recommended Approach

