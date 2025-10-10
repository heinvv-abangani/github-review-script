# 📝 GitHub PR Review Scripts

Automated GitHub PR review and comment posting tools with intelligent repository detection and robust error handling.

## 🚀 Quick Start

```bash
# 1. Install requirements
brew install gh jq

# 2. Set up authentication (RECOMMENDED: use GITHUB_TOKEN)
export GITHUB_TOKEN="your_github_token_here"
# Alternative: gh auth login

# 3. Complete workflow (fetch → review → validate → post)
./review-workflow.sh https://github.com/elementor/platform-kit-publisher/pull/88

# Or individual steps:
./fetch-pr.sh https://github.com/elementor/platform-kit-publisher/pull/88
./review.sh https://github.com/elementor/platform-kit-publisher/pull/88
./post-comments.sh https://github.com/elementor/platform-kit-publisher/pull/88
```

## 📋 Scripts Overview

### 🚀 `review-workflow.sh` - Complete Workflow (RECOMMENDED)
Handles the complete review process: fetch → review → validate → post.

```bash
# Complete workflow
./review-workflow.sh https://github.com/elementor/platform-kit-publisher/pull/88

# Individual steps
./review-workflow.sh <PR_URL> --fetch-only
./review-workflow.sh <PR_URL> --review-only
./review-workflow.sh <PR_URL> --post-only
```

### 📥 `fetch-pr.sh` - Fetch PR Content
Downloads complete PR data for easier review.

```bash
# Fetch PR content (diff, files, metadata)
./fetch-pr.sh https://github.com/elementor/platform-kit-publisher/pull/88
```

### 🔍 `review.sh` - Generate PR Reviews
Generates comprehensive markdown reviews and JSON comment files.

```bash
# Basic usage
./review.sh <PR_URL>

# Examples
./review.sh https://github.com/elementor/platform-kit-publisher/pull/88
./review.sh https://github.com/elementor/elementor/pull/12345
```

### 📤 `post-comments.sh` - Post Comments to GitHub
Posts line-specific review comments with universal repository support.

```bash
# Using PR URL (works with ANY GitHub repository)
./post-comments.sh https://github.com/elementor/platform-kit-publisher/pull/88

# Auto-detect everything
./post-comments.sh

# Specify PR number (auto-detect file and repo)
./post-comments.sh 88

# Specify PR and file (auto-detect repo)
./post-comments.sh 88 PR-88-comments.json

# Full specification
./post-comments.sh 88 PR-88-comments.json elementor/platform-kit-publisher

# Using repository aliases
./post-comments.sh 88 PR-88-comments.json pkp
```

### ✅ `validate-comments.sh` - Validate JSON Files
Validates and fixes common issues in comment JSON files.

```bash
# Validate only
./validate-comments.sh PR-88-comments.json

# Validate and auto-fix
./validate-comments.sh PR-88-comments.json --fix
```

## 🎯 Key Features

### 🤖 **Universal Repository Support**
- **PR URL Parsing**: Extracts repository from any GitHub PR URL automatically
- **Git Remote Detection**: Automatically detects repository from git remote or directory structure
- **File Detection**: Finds the right comments file based on PR number
- **PR Number Extraction**: Extracts PR numbers from filenames automatically

### 🔒 **Robust Error Handling**
- **Repository Validation**: Checks if repository exists and is accessible
- **JSON Validation**: Validates comment structure and formatting
- **Permission Checks**: Verifies GitHub CLI authentication and permissions
- **Detailed Error Messages**: Provides specific hints for common issues

### 🛠️ **Flexible Configuration**
- **Repository Aliases**: Use short names like `pkp` for `elementor/platform-kit-publisher`
- **Multiple Input Formats**: Supports various ways to specify PR and files
- **Fallback Detection**: Multiple strategies for auto-detection

### 📊 **Enhanced Output**
- **Progress Tracking**: Shows detailed progress and status
- **Error Reporting**: Specific error messages with troubleshooting hints
- **Summary Statistics**: Comment counts, success/failure rates
- **Formatted Display**: Clean, professional output with emojis and formatting

## 📁 Repository Aliases

The scripts support convenient aliases for common repositories:

| Alias | Repository |
|-------|------------|
| `elementor` | `elementor/elementor` |
| `pkp` | `elementor/platform-kit-publisher` |
| `platform-kit` | `elementor/platform-kit-publisher` |
| `pro` | `elementor/elementor-pro` |

```bash
# These are equivalent
./post-comments.sh 88 PR-88-comments.json elementor/platform-kit-publisher
./post-comments.sh 88 PR-88-comments.json pkp
./post-comments.sh 88 PR-88-comments.json platform-kit
```

## 📝 Comment JSON Format

Comments should follow this structure:

```json
[
  {
    "file": "path/to/file.php",
    "line": 42,
    "body": "Cursor Review: 🚨 **Critical Issue**\\n\\n**Rule:** rule-name\\n\\n**Issue:** Description\\n\\n**Suggested Fix:**\\n```suggestion\\nfixed code here\\n```",
    "severity": "CRITICAL",
    "suggestion": {
      "original_code": "old code",
      "suggested_code": "new code"
    }
  }
]
```

### 📏 **Field Requirements**
- `file` (required): Path to file in the PR
- `line` (required): Line number (positive integer)
- `body` (required): Comment text with proper `\\n` escaping
- `severity` (optional): `CRITICAL`, `HIGH`, `MEDIUM`, `LOW`, `INFO`
- `suggestion` (optional): Original and suggested code

### 🔧 **JSON Formatting Rules**
- Use `\\n` for line breaks in JSON strings
- Escape quotes properly: `\"`
- Use ````suggestion` blocks for GitHub commit suggestions
- **Prefer single-line suggestions** for simple fixes (conditions, assignments, function calls)
- Use multi-line suggestions only when restructuring multiple related lines
- Validate with `./validate-comments.sh` before posting

## 🔐 Authentication Setup

### GITHUB_TOKEN (Recommended)

The scripts prioritize `GITHUB_TOKEN` environment variable for authentication, which is ideal for:
- **CI/CD pipelines** 
- **Automated workflows**
- **Consistent authentication** across different environments

```bash
# Set GITHUB_TOKEN (recommended)
export GITHUB_TOKEN="ghp_your_personal_access_token_here"

# Make it persistent
echo 'export GITHUB_TOKEN="ghp_your_token_here"' >> ~/.zshrc
source ~/.zshrc

# Verify it's set
echo $GITHUB_TOKEN
```

### Creating a GitHub Token

1. Go to GitHub → Settings → Developer settings → Personal access tokens
2. Generate new token (classic) with these scopes:
   - `repo` (Full control of private repositories)
   - `read:org` (Read org and team membership)
3. Copy the token and set it as `GITHUB_TOKEN`

### Alternative: GitHub CLI

```bash
# Alternative authentication method
gh auth login
```

**Note:** All scripts automatically detect and prefer `GITHUB_TOKEN` when available.

## 🛠️ Installation & Setup

### Prerequisites
```bash
# Install GitHub CLI
brew install gh
# or
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh

# Install jq
brew install jq
# or
sudo apt install jq
```

### Authentication
```bash
# Authenticate with GitHub
gh auth login

# Verify authentication
gh auth status
```

### Configuration
```bash
# Make scripts executable
chmod +x *.sh

# Optional: Add to PATH
export PATH="$PATH:/path/to/github-review-script"
```

## 🔍 Auto-Detection Logic

### Repository Detection
1. **Git Remote**: Extracts from `git remote get-url origin`
2. **Directory Structure**: Analyzes current directory path
3. **Manual Override**: Uses provided repository parameter
4. **Validation**: Confirms repository exists and is accessible

### File Detection
1. **Exact Match**: `PR-{number}-comments.json`
2. **Latest File**: Most recent `PR-*-comments.json`
3. **Manual Specification**: Uses provided file path

### PR Number Extraction
1. **Filename Pattern**: `PR-(\d+)-comments.json`
2. **URL Pattern**: GitHub PR URLs
3. **Manual Specification**: Direct PR number parameter

## 🚨 Common Issues & Solutions

### ❌ "Cannot access repository"
- Check repository name spelling
- Verify you have access to the repository
- Ensure GitHub CLI is authenticated: `gh auth login`

### ❌ "Invalid JSON format"
- Run `./validate-comments.sh file.json --fix`
- Check for unescaped quotes or newlines
- Validate JSON syntax with online tools

### ❌ "Failed to post comment"
- **File not in PR diff**: Comment file must exist in the PR changes
- **Line out of range**: Line number must be within the diff
- **PR closed**: Comments can't be posted to closed/merged PRs
- **Permissions**: Ensure you have write access to the repository

### ❌ "Could not auto-detect repository"
- Specify repository manually: `./post-comments.sh 88 file.json owner/repo`
- Use repository aliases: `./post-comments.sh 88 file.json pkp`
- Check if you're in a git repository with proper remote

## 📊 Usage Examples

### Universal Repository Support
```bash
# Works with ANY GitHub repository your token has access to
./post-comments.sh https://github.com/elementor/platform-kit-publisher/pull/88
./post-comments.sh https://github.com/elementor/elementor/pull/12345
./post-comments.sh https://github.com/facebook/react/pull/67890
./post-comments.sh https://github.com/microsoft/vscode/pull/54321

# Repository is automatically extracted from the PR URL
# No need to specify it separately!
```

### Complete Workflow
```bash
# 1. Generate review
./review.sh https://github.com/elementor/platform-kit-publisher/pull/88

# 2. Validate comments
./validate-comments.sh ../pr-reviews/PR-88-comments.json --fix

# 3. Post comments (auto-detects everything)
./post-comments.sh

# 4. View results
open https://github.com/elementor/platform-kit-publisher/pull/88
```

### Different Repository Scenarios
```bash
# Elementor main repository
./post-comments.sh 12345 PR-12345-comments.json elementor

# Platform Kit Publisher
./post-comments.sh 88 PR-88-comments.json pkp

# Elementor Pro
./post-comments.sh 456 PR-456-comments.json pro

# Custom repository
./post-comments.sh 789 PR-789-comments.json myorg/myrepo
```

### Troubleshooting Mode
```bash
# Validate before posting
./validate-comments.sh PR-88-comments.json

# Fix issues automatically
./validate-comments.sh PR-88-comments.json --fix

# Post with verbose output
bash -x ./post-comments.sh 88 PR-88-comments.json
```

## 🔗 Integration

### CI/CD Integration
```yaml
# GitHub Actions example
- name: Post PR Comments
  run: |
    cd github-review-script
    ./post-comments.sh ${{ github.event.number }} PR-${{ github.event.number }}-comments.json
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### IDE Integration
```bash
# VS Code task
{
  "label": "Post PR Comments",
  "type": "shell",
  "command": "./github-review-script/post-comments.sh",
  "group": "build"
}
```

## 📈 Advanced Features

### Batch Processing
```bash
# Process multiple PRs
for pr in 88 89 90; do
  ./post-comments.sh $pr PR-$pr-comments.json
done
```

### Custom Validation
```bash
# Add custom validation rules
./validate-comments.sh PR-88-comments.json | grep "CRITICAL" | wc -l
```

### Repository Management
```bash
# List available aliases
source config.sh && list_repo_aliases

# Add new alias
# Edit config.sh and add to REPO_ALIASES array
```

---

## 🎯 **Simple, Reliable, and Effective PR Comment Automation** 

Built for the Elementor ecosystem with intelligent defaults and robust error handling.
