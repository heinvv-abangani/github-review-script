# GitHub PR Review Script

Simplified PR review workflow for Cursor Chat.

## 🚀 Quick Start

### For Cursor Chat Users

**Review a PR:**
```
review https://github.com/owner/repo/pull/123
```

**Post comments:**
```
post comments
```

### For Terminal Users

```bash
cd github-review-script

# Review
./review.sh https://github.com/owner/repo/pull/123

# Post
./post-comments.sh
```

## 📚 Documentation

- **[docs/WORKFLOW.md](./docs/WORKFLOW.md)** - Complete workflow guide (START HERE!)
- **[docs/README-SIMPLE.md](./docs/README-SIMPLE.md)** - Simple commands reference
- **[docs/CURSOR-INTEGRATION.md](./docs/CURSOR-INTEGRATION.md)** - Cursor Chat setup
- **[docs/SUGGESTIONS-GUIDE.md](./docs/SUGGESTIONS-GUIDE.md)** - GitHub commit suggestions guide

## 🎯 Features

✅ **Simple Commands** - Two commands: `review [URL]` and `post comments`  
✅ **Automatic Naming** - Files use PR number prefix: `PR-32958-comments.json`  
✅ **Auto Cleanup** - Removes files older than 3 days  
✅ **22 Coding Rules** - Comprehensive rule set in `rules/` directory  
✅ **Smart Output** - Markdown for humans, JSON for GitHub API  
✨ **Commit Suggestions** - Generate GitHub suggestions that authors can apply with one click  

## 📁 File Structure

```
github-review-script/
├── review.sh              # Generate review prompt
├── post-comments.sh      # Post comments to GitHub
├── cleanup.sh            # Clean old files
├── rules/                # 22 coding rules
├── docs/                 # Documentation
│   ├── WORKFLOW.md       # Complete workflow guide
│   ├── README-SIMPLE.md  # Simple commands
│   └── CURSOR-INTEGRATION.md # Cursor setup
└── README.md             # This file

../pr-reviews/            # Generated reviews (gitignored)
├── PR-123-2025-10-06.md
└── PR-123-comments.json
```

## ⚙️ Setup

```bash
# 1. Set GitHub token
export GITHUB_TOKEN="ghp_your_token_here"

# 2. Set repository (for post-comments.sh)
export GITHUB_OWNER="your-username"
export GITHUB_REPO="your-repo-name"

# 3. Done!
```

**Alternative:** Pass repository as arguments:
```bash
./post-comments.sh owner repo
```

## 🎯 Example Workflow

```bash
# 1. Review a PR
./review.sh https://github.com/owner/repo/pull/123
# Copy prompt to Cursor Chat

# 2. Check output
cat ../pr-reviews/PR-123-comments.json

# 3. Post comments
./post-comments.sh

# Done! ✅
```

## 📊 What Gets Generated

### Markdown Review (`PR-123-2025-10-06.md`)
- Executive summary
- Issue statistics  
- Critical/High/Medium issues with fixes
- Security assessment
- Performance analysis

### Comments JSON (`PR-123-comments.json`)
```json
[
  {
    "file": "path/to/file.js",
    "line": 42,
    "body": "Cursor Review: 🚨 **Critical Issue**\n\n...",
    "severity": "CRITICAL"
  }
]
```

## 🛠️ Troubleshooting

### "No comments JSON found"
Check file naming: `PR-[NUMBER]-comments.json`

### "GITHUB_TOKEN not set"
```bash
export GITHUB_TOKEN="ghp_your_token_here"
echo 'export GITHUB_TOKEN="ghp_your_token_here"' >> ~/.zshrc
```

### "Failed to post comment"
- Verify file paths match PR diff
- Check line numbers are in changed hunks
- Ensure PR is still open

---

**Version:** 2.0 (Simplified)  
**Last Updated:** October 6, 2025