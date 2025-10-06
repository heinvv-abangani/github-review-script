# Posting Review Comments to GitHub

**Your Prefix:** `[Hein Cursor review]`

All comments posted to GitHub will start with this prefix to identify them as AI-generated reviews.

---

## 🚀 Quick Guide: Post Comments to GitHub

### Step 1: Generate Review (Already Done)

You already have: `pr-reviews/PR-32958-2025-10-06.md`

### Step 2: Extract Comments for Posting

Open Cursor chat and paste this:

```
Read the review file: pr-reviews/PR-32958-2025-10-06.md

Extract all Critical and High priority issues that have:
- A specific file path
- A specific line number  
- Clear, actionable description

Convert to this JSON format and save to: pr-reviews/comments-to-post.json

JSON Structure:
```json
[
  {
    "severity": "Critical",
    "file": "path/to/file.tsx",
    "line": 123,
    "title": "Issue title",
    "body": "[Hein Cursor review] 🚨 **Critical: Issue Title**\n\n**Issue:** Detailed description of the problem.\n\n**Impact:** Why this matters.\n\n**Recommendation:**\n```suggestion\n// Suggested fix code here\n```\n\n**Rule:** rule-name"
  },
  {
    "severity": "High",  
    "file": "another/file.tsx",
    "line": 456,
    "title": "Another issue",
    "body": "[Hein Cursor review] ⚠️ **High Priority: Another Issue**\n\n**Issue:** Description...\n\n**Recommendation:** Fix details..."
  }
]
```

**Important formatting rules:**
1. Every body MUST start with: `[Hein Cursor review]`
2. Use emoji for severity: 🚨 for Critical, ⚠️ for High
3. Include file path and line number in the issue context
4. Keep descriptions concise but actionable
5. Include code suggestions where applicable
6. Only include issues with clear file:line references
```

### Step 3: Post to GitHub

Once you have `comments-to-post.json`:

```bash
./scripts/post-comments-from-json.sh pr-reviews/comments-to-post.json https://github.com/elementor/elementor/pull/32958
```

**What happens:**
1. Script confirms number of comments to post
2. You type `y` to confirm
3. Comments are posted as inline PR review comments
4. Each appears on the specific file:line in the PR

---

## 📋 Complete Example

### 1. You Have the Review
```bash
ls pr-reviews/PR-32958-2025-10-06.md
# ✅ Exists
```

### 2. Ask Cursor to Extract Comments

**Cursor Prompt:**
```
Read pr-reviews/PR-32958-2025-10-06.md

Extract Critical and High priority issues into JSON format.
Save to: pr-reviews/comments-to-post.json

Format each comment body as:
[Hein Cursor review] {emoji} **{Severity}: {Title}**

**Issue:** {description}

**Impact:** {why it matters}

**Recommendation:**
{how to fix}

**Rule:** {rule-name}

Only include issues with clear file paths and line numbers.
Use 🚨 for Critical, ⚠️ for High priority.
```

### 3. Cursor Creates JSON

Example output in `pr-reviews/comments-to-post.json`:
```json
[
  {
    "severity": "Critical",
    "file": "modules/ai/assets/js/editor/pages/form-text/components/prompt-error-message.js",
    "line": 45,
    "title": "Missing PropTypes validation",
    "body": "[Hein Cursor review] 🚨 **Critical: Missing PropTypes Validation**\n\n**Issue:** Component missing PropTypes definition for error prop.\n\n**Impact:** Runtime errors may occur without proper prop validation. Debugging becomes harder.\n\n**Recommendation:** Add PropTypes validation:\n```suggestion\nimport PropTypes from 'prop-types';\n\nPromptErrorMessage.propTypes = {\n  error: PropTypes.shape({\n    message: PropTypes.string.isRequired,\n    code: PropTypes.string\n  }).isRequired\n};\n```\n\n**Rule:** react.md - Always use PropTypes"
  }
]
```

### 4. Post Comments

```bash
./scripts/post-comments-from-json.sh pr-reviews/comments-to-post.json https://github.com/elementor/elementor/pull/32958

# Output:
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#   Posting Comments to GitHub PR
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 
#   Repository:  elementor/elementor
#   PR Number:   #32958
#   Comments:    pr-reviews/comments-to-post.json
# 
# 📥 Fetching PR commit SHA...
# ✅ Commit SHA: abc1234...
# 
# 📝 Found 3 comments to post
# 
# ⚠️  Post 3 comments to PR #32958? (y/n): y
# 
# 📤 Posting comments...
# 
#   ↳ modules/ai/assets/js/editor/pages/form-text/components/prompt-error-message.js:45 [Critical]
#     ✅ Posted
#   ↳ modules/ai/assets/js/editor/pages/form-layout.js:23 [High]
#     ✅ Posted
#   ↳ modules/ai/assets/js/editor/module.js:156 [High]
#     ✅ Posted
# 
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#   Summary
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 
#   ✅ Posted: 3 comments
#   ❌ Failed: 0 comments
# 
#   View at: https://github.com/elementor/elementor/pull/32958
```

---

## 🎨 Comment Format Template

Every GitHub comment will look like this:

```markdown
[Hein Cursor review] 🚨 **Critical: Missing PropTypes Validation**

**Issue:** Component missing PropTypes definition for error prop.

**Impact:** Runtime errors may occur without proper prop validation. 
Debugging becomes harder when unexpected prop types are passed.

**Recommendation:** Add PropTypes validation:
```suggestion
import PropTypes from 'prop-types';

PromptErrorMessage.propTypes = {
  error: PropTypes.shape({
    message: PropTypes.string.isRequired,
    code: PropTypes.string
  }).isRequired
};
```

**Rule:** react.md - Always use PropTypes for components
```

---

## 💡 Best Practices

### 1. Review Before Posting
```bash
# Always check what will be posted:
cat pr-reviews/comments-to-post.json | jq '.'

# Count comments:
cat pr-reviews/comments-to-post.json | jq 'length'
```

### 2. Start with Critical/High Only
```
First posting? Only extract Critical and High priority issues.
Save Medium/Low for follow-up if needed.
```

### 3. Be Selective
```
Not every issue needs a GitHub comment.
Focus on:
- Blockers (Critical)
- Important improvements (High)
- Issues with clear, actionable fixes
```

### 4. Group Similar Issues
```
If same issue appears in 5 files, consider:
- One general comment + list of files
- Or post to first occurrence only
```

---

## 🔍 Comment Selection Criteria

### ✅ Good Comments to Post:
- **Specific** - Clear file and line
- **Actionable** - Shows how to fix
- **Important** - Critical or High severity
- **Clear** - Easy to understand
- **Constructive** - Helps improve code

### ❌ Don't Post:
- **Generic** - "Code could be better"
- **Vague** - No specific recommendation
- **Opinion-based** - Style preferences
- **Low priority** - Minor nitpicks
- **Unclear location** - No file:line reference

---

## 🎯 Severity Guidelines

### 🚨 Critical (Always Post)
- Security vulnerabilities
- Breaking changes
- Data loss risks
- Type safety violations that cause errors

### ⚠️ High Priority (Usually Post)
- Performance issues
- Logic errors
- Missing error handling
- Accessibility problems

### 📋 Medium (Selective)
- Code style violations
- Minor optimizations
- Documentation gaps

### 💅 Low (Rarely Post)
- Formatting suggestions
- Personal preferences
- Nice-to-haves

---

## 🛠️ Troubleshooting

### "Failed to get commit SHA"
```bash
# Check your token has access:
curl -H "Authorization: token $GITHUB_TOKEN" \
     https://api.github.com/repos/elementor/elementor/pulls/32958

# Should return PR data
```

### "Comment failed: Validation failed"
```bash
# Common issues:
# 1. File path doesn't exist in PR
# 2. Line number out of range
# 3. File not actually changed in PR

# Check changed files:
cat pr-reviews/data/PR-32958-files.json | jq '.[].filename'
```

### "GITHUB_TOKEN not set"
```bash
echo $GITHUB_TOKEN
# If empty:
export GITHUB_TOKEN="ghp_your_token_here"
```

---

## 📚 Files Reference

| File | Purpose |
|------|---------|
| `pr-reviews/PR-{N}-{date}.md` | Generated review (all issues) |
| `pr-reviews/comments-to-post.json` | Filtered issues for GitHub |
| `scripts/post-comments-from-json.sh` | Posts comments to PR |
| `scripts/post-review-comments.sh` | Helper to guide you |

---

## 🎓 Advanced: Selective Posting

### Post Only Security Issues
```
Cursor prompt:
"Extract only security-related Critical issues from pr-reviews/PR-32958-2025-10-06.md
Save to: pr-reviews/security-comments.json"

Then:
./scripts/post-comments-from-json.sh pr-reviews/security-comments.json <PR_URL>
```

### Post to Specific Files
```
Cursor prompt:
"Extract issues only for files in modules/ai/ from the review.
Save to: pr-reviews/ai-module-comments.json"
```

---

## ✅ Workflow Summary

```bash
# 1. Generate review (you've done this)
./scripts/fetch-pr-data.sh <PR_URL>
# Paste prompt in Cursor → Get review

# 2. Extract comments for posting
# Paste in Cursor chat:
"Extract Critical/High issues from pr-reviews/PR-{N}-{date}.md
 Format with [Hein Cursor review] prefix
 Save to: pr-reviews/comments-to-post.json"

# 3. Review what will be posted
cat pr-reviews/comments-to-post.json | jq '.'

# 4. Post to GitHub
./scripts/post-comments-from-json.sh pr-reviews/comments-to-post.json <PR_URL>

# 5. Done! View comments in the PR
```

---

**Your Prefix:** `[Hein Cursor review]`  
**Status:** Ready to use  
**Last Updated:** October 6, 2025
