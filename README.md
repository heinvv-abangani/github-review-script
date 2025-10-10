# 📝 GitHub PR Review Scripts

Automated GitHub PR review and comment posting tools with intelligent repository detection.

## 🚀 Quick Start

```bash
# 1. Install requirements
brew install gh jq

# 2. Set up authentication
export GITHUB_TOKEN="your_github_token_here"

# 3. Complete workflow
./review-workflow.sh https://github.com/owner/repo/pull/123
```

## 📁 Scripts

- **`review-workflow.sh`** - Complete workflow (fetch → review → validate → post)
- **`fetch-pr.sh`** - Fetch PR content and diff
- **`review.sh`** - Generate review prompt for Cursor Chat
- **`post-comments.sh`** - Post comments to GitHub PR
- **`validate-comments.sh`** - Validate and fix comment JSON

## 🎯 Key Features

- **Universal Repository Support** - Works with any GitHub repository
- **Smart Suggestion Formatting** - Prefers single-line suggestions for focused fixes
- **Intelligent Auto-Detection** - Repository, PR number, and file detection
- **Robust Error Handling** - Comprehensive validation and troubleshooting
- **Flexible Authentication** - GITHUB_TOKEN or GitHub CLI

## 📚 Documentation

- **[Complete Guide](docs/README.md)** - Comprehensive documentation
- **[Suggestions Guide](docs/SUGGESTIONS-GUIDE.md)** - GitHub suggestion best practices
- **[Recent Improvements](docs/SUGGESTION-IMPROVEMENTS.md)** - Latest enhancements

## 🔧 Usage Examples

```bash
# Review a PR
./review.sh https://github.com/elementor/platform-kit-publisher/pull/88

# Post comments (auto-detects latest)
./post-comments.sh

# Validate comments
./validate-comments.sh PR-88-comments.json
```

## 🌍 Repository Support

Works with any GitHub repository:
- `elementor/elementor`
- `elementor/platform-kit-publisher` 
- `elementor/elementor-pro`
- Any public/private repository you have access to

## 🔐 Authentication

**Recommended:** Use GITHUB_TOKEN environment variable
```bash
export GITHUB_TOKEN="ghp_your_token_here"
```

**Alternative:** GitHub CLI authentication
```bash
gh auth login
```

For detailed setup instructions, see [docs/README.md](docs/README.md).