# Cursor Chat Integration Guide

Simplified workflow for PR reviews using Cursor Chat commands.

## 🚀 Quick Commands

### 1. Review a PR

In Cursor Chat, type:
```
review https://github.com/owner/repo/pull/123
```

This will:
- Fetch PR diff and details
- Apply all coding rules from `github-review-script/rules/`
- Generate markdown review: `pr-reviews/PR-32958-2025-10-06.md`
- Generate comments JSON: `pr-reviews/PR-32958-comments.json`

### 2. Post Comments

After reviewing the generated JSON, type:
```
post comments
```

This will:
- Find the most recent `PR-*-comments.json` file
- Post all comments to GitHub PR
- Clean up files older than 3 days

## 📝 Detailed Usage

### Review Command Format

**Basic Review:**
```
review https://github.com/elementor/elementor/pull/[NUMBER]
```

**Alternative with script:**
```bash
cd /path/to/github-review-script
./review.sh https://github.com/owner/repo/pull/123
# Then copy the generated prompt to Cursor Chat
```

### Post Comments Command Format

**Automatic (uses most recent JSON):**
```
post comments
```

**Manual (specify PR and file):**
```bash
cd /path/to/github-review-script
./post-comments.sh 32958 ../pr-reviews/PR-32958-comments.json
```

## 🎯 Full Cursor Chat Prompt Template

When you type "review [PR_URL]", Cursor should expand it to:

```
Review GitHub PR: https://github.com/owner/repo/pull/123

**Tasks:**

1. **Fetch PR Data:**
   - Get PR details, diff, and changed files

2. **Apply Coding Rules:**
   - Load all rules from: github-review-script/rules/
   - Focus on TypeScript, React, PHP, WordPress, Security

3. **Generate Review:**
   - Save markdown review to: pr-reviews/PR-32958-2025-10-06.md
   - Save comments JSON to: pr-reviews/PR-32958-comments.json
   
   **Comments JSON Format:**
   ```json
   [
     {
       "file": "path/to/file.js",
       "line": 42,
       "body": "AI Review: 🚨 **Critical Issue**\n\n**Rule:** [rule-name]\n\n**Issue:** [description]\n\n**Fix:**\n```javascript\n// Recommended\n[code]\n```",
       "severity": "CRITICAL"
     }
   ]
   ```
   
   **Rules for JSON:**
   - Only include Critical and High severity issues
   - Start each body with "AI Review: " prefix
   - Use \n for newlines in body
   - Include file path and line number
   - Escape quotes properly
   - Make actionable and specific

4. **Summary:**
   - Display statistics
   - Highlight top 3 findings
   - Recommend approval status
```

## 📂 File Naming Convention

All generated files follow this pattern:

- **Review Markdown:** `PR-[NUMBER]-[DATE].md`
  - Example: `PR-32958-2025-10-06.md`

- **Comments JSON:** `PR-[NUMBER]-comments.json`
  - Example: `PR-32958-comments.json`

## 🔧 Configuration

### Environment Variables

Set in your shell profile (`~/.zshrc` or `~/.bashrc`):

```bash
export GITHUB_TOKEN="ghp_your_token_here"
```

### File Locations

```
/wp-content/
├── github-review-script/          # This repository
│   ├── review.sh                  # Generate review prompt
│   ├── post-comments.sh          # Post comments to GitHub
│   ├── cleanup.sh                # Clean old files
│   ├── rules/                    # 22 coding rules
│   └── CURSOR-INTEGRATION.md     # This file
│
└── pr-reviews/                   # Generated reviews (gitignored)
    ├── PR-32958-2025-10-06.md
    ├── PR-32958-comments.json
    └── data/                     # Raw PR data (optional)
```

## 🤖 Automating with Cursor Rules

You can create a Cursor rule to simplify the commands:

### Create `.cursorrules` file

In your workspace root, add:

```markdown
# GitHub PR Review

When user says "review [PR_URL]":
1. Extract PR number from URL
2. Fetch PR data via GitHub API or MCP
3. Apply coding rules from github-review-script/rules/
4. Generate markdown review: pr-reviews/PR-[NUMBER]-[DATE].md
5. Generate comments JSON: pr-reviews/PR-[NUMBER]-comments.json
6. Follow format from github-review-script/CURSOR-INTEGRATION.md

When user says "post comments":
1. Find most recent PR-*-comments.json in pr-reviews/
2. Extract PR number from filename
3. Post comments to GitHub via API
4. Run cleanup script to remove files >3 days old
```

## 📊 Output Format

### Markdown Review Structure

```markdown
# PR Review: #32958 - [Title]

**Date:** 2025-10-06 14:30:00
**Repository:** owner/repo
**Status:** [PASSED | NEEDS_WORK | BLOCKED]

## Executive Summary
[Overview]

## Statistics
- Files Changed: 21
- Critical Issues: 2
- High Priority: 5

## Critical Issues 🚨
### [Issue Title]
- **File:** `path/to/file.js:123`
- **Rule:** rule-name
- **Description:** [details]
- **Fix:** [recommended code]

[... more sections ...]
```

### Comments JSON Structure

```json
[
  {
    "file": "app/modules/kit-library/assets/js/context/tracking-context.js",
    "line": 15,
    "body": "AI Review: 🚨 **Critical: Missing PropTypes validation**\n\n**Rule:** react-performance\n\n**Issue:** TrackingProvider component is missing PropTypes validation for children prop.\n\n**Fix:**\n```javascript\nimport PropTypes from 'prop-types';\n\nTrackingProvider.propTypes = {\n  children: PropTypes.node.isRequired\n};\n```",
    "severity": "CRITICAL"
  }
]
```

## 🛠️ Troubleshooting

### "No comments JSON found"
- Ensure review completed successfully
- Check file naming: `PR-[NUMBER]-comments.json`
- Verify file exists in `pr-reviews/` directory

### "GITHUB_TOKEN not set"
```bash
export GITHUB_TOKEN="ghp_your_token_here"
echo $GITHUB_TOKEN  # Verify it's set
```

### "Failed to post comment"
- Check file path and line number are valid
- Verify commit SHA is latest
- Ensure PR is still open
- Check GitHub API rate limits

### Comments not showing on GitHub
- Verify file paths match PR diff
- Check line numbers are within changed hunks
- Ensure commit SHA matches latest PR commit

## 💡 Tips

1. **Review first, then post:** Always review the generated JSON before posting
2. **Edit JSON if needed:** You can manually edit the JSON file before posting
3. **Test with small PRs:** Start with small PRs to verify workflow
4. **Monitor rate limits:** GitHub API has rate limits (5000 requests/hour)
5. **Keep token secure:** Never commit GITHUB_TOKEN to repository

## 🔗 Related Documentation

- [QUICK-START.md](./QUICK-START.md) - Quick setup guide
- [MCP-SETUP-GUIDE.md](./MCP-SETUP-GUIDE.md) - GitHub MCP configuration
- [POSTING-COMMENTS.md](./POSTING-COMMENTS.md) - Detailed posting guide
- [rules/](./rules/) - All 22 coding rules

## 📞 Support

If you encounter issues:
1. Check [TROUBLESHOOTING-GITHUB-MCP.md](./TROUBLESHOOTING-GITHUB-MCP.md)
2. Verify GitHub token permissions
3. Test with a small PR first
4. Review Cursor logs (Help → Developer Tools)

---

**Version:** 1.0  
**Last Updated:** October 6, 2025  
**Status:** Production Ready
