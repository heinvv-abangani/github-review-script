# Simplified PR Review Workflow

Quick reference for the new simplified workflow.

## 🎯 Two Simple Commands

### 1. Review PR
```
review https://github.com/elementor/elementor/pull/32958
```

### 2. Post Comments
```
post comments
```

That's it! 🎉

## 📝 What Happens Behind the Scenes

### When you run `review [PR_URL]`:

1. **Extracts PR info**
   - Owner: `elementor`
   - Repo: `elementor`
   - PR Number: `32958`

2. **Fetches PR data**
   - Title, description, author
   - Complete diff
   - Changed files list

3. **Applies 22 coding rules**
   - TypeScript safety
   - React performance
   - WordPress security
   - PHP best practices
   - And 18 more...

4. **Generates two files**
   - `pr-reviews/PR-32958-2025-10-06.md` (full review)
   - `pr-reviews/PR-32958-comments.json` (GitHub comments)

### When you run `post comments`:

1. **Finds latest JSON**
   - Looks for `PR-*-comments.json`
   - Extracts PR number from filename

2. **Posts to GitHub**
   - Gets latest commit SHA
   - Posts each comment as inline review
   - Shows progress for each comment

3. **Cleans up**
   - Removes files older than 3 days
   - Keeps workspace clean

## 📂 File Naming Convention

All files use PR number prefix:

```
pr-reviews/
├── PR-32958-2025-10-06.md          # Full review
├── PR-32958-comments.json          # Comments to post
└── data/
    ├── PR-32958-details.json       # Raw PR data (optional)
    ├── PR-32958-files.json         # Changed files (optional)
    └── PR-32958.diff               # Complete diff (optional)
```

## 🔄 Complete Workflow Example

```bash
# Terminal 1: Generate review prompt
cd github-review-script
./review.sh https://github.com/elementor/elementor/pull/32958

# Cursor Chat: Paste the prompt
# Wait for review to complete...

# Terminal 2: Check output
cat ../pr-reviews/PR-32958-comments.json

# Cursor Chat or Terminal: Post comments
post comments
# or
./post-comments.sh

# Done! ✅
```

## 🎨 Using Cursor Chat Commands

### Cursor recognizes these patterns:

**Pattern 1: Review**
```
review <URL>
review https://github.com/elementor/elementor/pull/32958
```

**Pattern 2: Post**
```
post comments
post PR comments
post github comments
```

**Pattern 3: Cleanup**
```
cleanup old files
cleanup pr-reviews
```

## ⚙️ Configuration

### One-time setup:

```bash
# 1. Set GitHub token
export GITHUB_TOKEN="ghp_your_token_here"

# 2. Add to profile for persistence
echo 'export GITHUB_TOKEN="ghp_your_token_here"' >> ~/.zshrc
source ~/.zshrc

# 3. Done!
```

### Verification:

```bash
# Test token
echo $GITHUB_TOKEN

# Test scripts
cd github-review-script
./review.sh https://github.com/elementor/elementor/pull/32958
```

## 🧹 Automatic Cleanup

Cleanup runs automatically after posting comments.

Files removed:
- Review markdown files (>3 days)
- Comments JSON files (>3 days)
- Raw data files (>3 days)

Manual cleanup:
```bash
./cleanup.sh     # 3 days (default)
./cleanup.sh 7   # 7 days
./cleanup.sh 1   # 1 day
```

## 📊 Output Examples

### Markdown Review

```markdown
# PR Review: #32958 - Internal: Update Kit Library event handling

**Date:** 2025-10-06 14:30:00
**Status:** NEEDS_WORK

## Executive Summary
This PR updates event handling in the Kit Library module...

## Statistics
- Files Changed: 21
- Critical Issues: 2
- High Priority: 5
- Medium Priority: 8

## Critical Issues 🚨
### Missing PropTypes validation
- **File:** `tracking-context.js:15`
- **Rule:** react-performance
...
```

### Comments JSON

```json
[
  {
    "file": "app/modules/kit-library/assets/js/context/tracking-context.js",
    "line": 15,
    "body": "TMZ Review MCP: 🚨 **Critical: Missing PropTypes validation**...",
    "severity": "CRITICAL"
  }
]
```

## 🚨 Important Notes

1. **File naming matters:** Always use `PR-[NUMBER]` prefix
2. **Line numbers must be accurate:** GitHub rejects invalid line numbers
3. **File paths must match:** Paths must exactly match PR diff
4. **Token security:** Never commit GITHUB_TOKEN
5. **Rate limits:** GitHub API: 5000 requests/hour

## 💡 Pro Tips

1. **Review before posting:** Always check JSON before posting
2. **Edit comments:** Manually edit JSON to improve clarity
3. **Batch reviews:** Review multiple PRs, post later
4. **Keep workspace clean:** Cleanup runs automatically
5. **Use descriptive comments:** Include rule name and fix

## 🔗 Quick Links

- [README-SIMPLE.md](./README-SIMPLE.md) - Simple guide
- [CURSOR-INTEGRATION.md](./CURSOR-INTEGRATION.md) - Cursor setup
- [rules/](./rules/) - All 22 coding rules
- [TROUBLESHOOTING-GITHUB-MCP.md](./TROUBLESHOOTING-GITHUB-MCP.md) - Help

## 🎯 Success Criteria

✅ Review generated in < 2 minutes  
✅ Comments posted successfully  
✅ Old files cleaned automatically  
✅ Workspace stays organized  
✅ No manual file management needed  

---

**Version:** 1.0  
**Last Updated:** October 6, 2025
