# 📝 GitHub PR Comments Script

Automatically post line-specific code suggestions to GitHub pull requests using GitHub CLI.

## 🚀 Quick Start

```bash
# 1. Install requirements
brew install gh jq

# 2. Authenticate with GitHub
gh auth login

# 3. Create comments JSON file
cat > PR-12345-comments.json << 'EOF'
[
  {
    "file": "src/component.js",
    "line": 42,
    "body": "Issue description\\n\\n```suggestion\\nfixed code line\\n```",
    "severity": "CRITICAL"
  }
]
EOF

# 4. Post comments
./post-comments.sh 12345 PR-12345-comments.json
```

## 📋 Comment Format

```json
[
  {
    "file": "path/to/file.js",
    "line": 30,
    "body": "Cursor Review: 🚨 **Critical Issue**\\n\\n**Rule:** general-code-style\\n\\n**Issue:** Magic number detected\\n\\n**Suggested Fix:**\\n```suggestion\\nconst DELAY = 100;\\n```",
    "severity": "CRITICAL"
  }
]
```

**Important:** Use `\\n` for newlines in JSON strings, not actual line breaks.

## 🛠️ Requirements

- **GitHub CLI** (`gh`) - [Install here](https://cli.github.com/)
- **jq** - JSON processor (`brew install jq`)
- **Authentication** - Run `gh auth login`

## 📊 Usage

```bash
# Auto-detect latest PR comments file
./post-comments.sh

# Specify PR number and file
./post-comments.sh 12345 comments.json
```

The script will:
1. Validate inputs and requirements
2. Get the latest commit SHA for the PR
3. Post each comment as a line-specific review comment
4. Show success/failure for each comment

## ✅ Features

- **Single-line code suggestions** with proper GitHub formatting
- **Line-specific comments** that appear exactly where needed
- **Automatic commit SHA detection** for the PR
- **Simple JSON format** for easy comment creation
- **Clean output** with success/failure tracking

## 📝 Example Output

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📝 GitHub PR Comments
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  PR Number:    #12345
  Comments:     PR-12345-comments.json
  📝 Found 2 comments to post

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ↳ component.js:30 [CRITICAL] ✨
    ✅ Posted successfully

  ↳ component.js:55 [HIGH] ✨
    ✅ Posted successfully

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Summary:
  ✅ Posted: 2
  ❌ Failed: 0

🎉 All comments posted successfully!
```

---

**Simple, reliable, and effective PR comment automation.** 🎯