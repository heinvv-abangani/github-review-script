# GitHub PR Review - Simplified Workflow

Automated GitHub Pull Request review system for Cursor Chat.

## 🚀 Quick Start (2 Minutes)

### 1. Setup Environment

```bash
# Set GitHub token
export GITHUB_TOKEN="ghp_your_token_here"

# Navigate to script directory
cd /Users/janvanvlastuin1981/Local\ Sites/elementor/app/public/wp-content/github-review-script
```

### 2. Review a PR

**In Cursor Chat:**
```
review https://github.com/elementor/elementor/pull/32958
```

**Or using script:**
```bash
./review.sh https://github.com/elementor/elementor/pull/32958
# Copy the generated prompt to Cursor Chat
```

### 3. Check the Output

```bash
# Review markdown
open ../pr-reviews/PR-32958-2025-10-06.md

# Check comments JSON
cat ../pr-reviews/PR-32958-comments.json
```

### 4. Post Comments

**In Cursor Chat:**
```
post comments
```

**Or using script:**
```bash
./post-comments.sh
# Automatically finds most recent PR comments JSON
```

## 📋 Simple Commands

| Command | What it does |
|---------|--------------|
| `./review.sh <PR_URL>` | Generate Cursor prompt for PR review |
| `./post-comments.sh` | Post most recent PR comments to GitHub |
| `./post-comments.sh 32958 file.json` | Post specific comments file |
| `./cleanup.sh` | Remove files older than 3 days |
| `./cleanup.sh 7` | Remove files older than 7 days |

## 📁 File Structure

```
github-review-script/              # This repository
├── review.sh                      # Generate review prompt
├── post-comments.sh              # Post comments to GitHub
├── cleanup.sh                    # Clean old files
├── rules/                        # 22 coding rules
│   ├── typescript-safety.md
│   ├── react-performance.md
│   ├── wordpress-security.md
│   └── ... (19 more)
├── README-SIMPLE.md              # This file
├── CURSOR-INTEGRATION.md         # Cursor Chat guide
└── scripts/                      # Original helper scripts

../pr-reviews/                    # Generated reviews (gitignored)
├── PR-32958-2025-10-06.md       # Markdown review
├── PR-32958-comments.json       # Comments for posting
└── data/                        # Raw PR data (optional)
```

## 🎯 Cursor Chat Integration

### Review Command

When you type in Cursor Chat:
```
review https://github.com/elementor/elementor/pull/32958
```

Cursor will:
1. Extract PR number: `32958`
2. Fetch PR diff and details
3. Apply all 22 coding rules from `rules/`
4. Generate:
   - `pr-reviews/PR-32958-2025-10-06.md` (markdown review)
   - `pr-reviews/PR-32958-comments.json` (comments for GitHub)

### Post Comments Command

When you type:
```
post comments
```

Cursor will:
1. Find most recent `PR-*-comments.json` file
2. Extract PR number from filename
3. Post all comments to GitHub
4. Run cleanup (remove files >3 days)

## 📄 Output Files

### Markdown Review (`PR-32958-2025-10-06.md`)

Complete review with:
- Executive summary
- Statistics (files changed, issues found)
- Critical issues with code examples
- High/Medium priority issues
- Positive observations
- Security assessment
- Performance analysis

### Comments JSON (`PR-32958-comments.json`)

GitHub-ready comments:
```json
[
  {
    "file": "path/to/file.js",
    "line": 42,
    "body": "TMZ Review MCP: 🚨 **Critical Issue**\n\n...",
    "severity": "CRITICAL"
  }
]
```

## 🔧 Configuration

### GitHub Token

Create at: https://github.com/settings/tokens

Required scopes:
- `repo` (full control of private repositories)
- `read:org` (read organization membership)

Set in environment:
```bash
echo 'export GITHUB_TOKEN="ghp_your_token_here"' >> ~/.zshrc
source ~/.zshrc
```

### File Locations

Default locations (relative to script directory):
- Reviews: `../pr-reviews/`
- Rules: `./rules/`

## 🧹 Cleanup

Automatic cleanup runs after posting comments.

Manual cleanup:
```bash
./cleanup.sh     # Remove files >3 days
./cleanup.sh 7   # Remove files >7 days
```

Files removed:
- `PR-*-*.md` (markdown reviews)
- `PR-*-comments.json` (comment files)
- Raw data in `data/` subdirectory

## 📊 Coding Rules

22 comprehensive rules in `rules/` directory:

**TypeScript/JavaScript:**
- typescript-safety.md
- react-performance.md
- react.md

**PHP/WordPress:**
- wordpress-security.md
- dependency-injection.md
- file-operations.md
- http-operations.md

**Code Quality:**
- clean-code.md
- descriptive-naming.md
- single-responsibility.md
- testability.md

**Testing:**
- playwright-best-practices.md
- general-quality.md

**Process:**
- git-commits-and-pr-guidelines.md
- general-pr-suggestions.md

**And more...**

## 🛠️ Troubleshooting

### "No comments JSON found"
Check file naming: `PR-[NUMBER]-comments.json`

### "GITHUB_TOKEN not set"
```bash
export GITHUB_TOKEN="ghp_your_token_here"
```

### "Failed to post comment"
- Verify file path and line number
- Check PR is still open
- Ensure token has correct permissions

### Comments not showing
- File paths must match PR diff exactly
- Line numbers must be in changed hunks
- Commit SHA must match latest commit

## 💡 Tips

1. **Review before posting:** Always check the JSON before posting
2. **Edit if needed:** Manually edit JSON to refine comments
3. **Start small:** Test with small PRs first
4. **Check rate limits:** GitHub API: 5000 requests/hour
5. **Keep token secure:** Never commit GITHUB_TOKEN

## 📚 Documentation

- [CURSOR-INTEGRATION.md](./CURSOR-INTEGRATION.md) - Cursor Chat integration
- [QUICK-START.md](./QUICK-START.md) - Detailed setup
- [MCP-SETUP-GUIDE.md](./MCP-SETUP-GUIDE.md) - GitHub MCP
- [POSTING-COMMENTS.md](./POSTING-COMMENTS.md) - Comment posting
- [TROUBLESHOOTING-GITHUB-MCP.md](./TROUBLESHOOTING-GITHUB-MCP.md) - Issues

## 🎉 Example Workflow

```bash
# 1. Review a PR
./review.sh https://github.com/elementor/elementor/pull/32958
# (Copy prompt to Cursor Chat)

# 2. Check the output
cat ../pr-reviews/PR-32958-comments.json

# 3. Post comments
./post-comments.sh

# Done! Comments posted and old files cleaned up.
```

## 🔗 GitHub Repository

This repository: [github-review-script](https://github.com/elementor/elementor/pull/32958/files)

## 📞 Support

Issues? Check:
1. [TROUBLESHOOTING-GITHUB-MCP.md](./TROUBLESHOOTING-GITHUB-MCP.md)
2. GitHub token permissions
3. Cursor logs (Help → Developer Tools)

---

**Version:** 2.0 (Simplified)  
**Last Updated:** October 6, 2025  
**Status:** Production Ready
