# Fixing GitHub Comment Formatting

## Problem

Comments posted to GitHub show `nn` instead of line breaks because JSON escaping isn't working correctly.

**What you see:**
```
[Hein Cursor review] 🚨 Critical: IssuennImpact: Descriptionnn
```

**What you want:**
```
[Hein Cursor review] 🚨 Critical: Issue

Impact: Description
```

## Solutions

### Solution 1: Use Double Backslash (Recommended)

In JSON, use `\\n` instead of `\n`:

```json
{
  "body": "[Hein Cursor review] 🚨 **Critical: Title**\\n\\n**Issue:** Description\\n\\n**Impact:** Why it matters"
}
```

### Solution 2: Use GitHub's Markdown API

Instead of plain text, use GitHub's markdown rendering by ensuring proper formatting:

```json
{
  "body": "[Hein Cursor review] 🚨 **Critical: Title**\n\n**Issue:** Description\n\n**Impact:** Why it matters\n\n**Recommendation:**\n```javascript\ncode here\n```"
}
```

GitHub API expects literal `\n` characters in the string, but they need to be properly JSON-escaped.

### Solution 3: Create Multi-line Strings in Script

Modify the posting script to handle formatting better. The issue is that the JSON is being read and the `\n` is already interpreted as a string character before being sent to GitHub.

## Testing the Fix

### Test with curl

```bash
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/elementor/elementor/pulls/32958/comments" \
  -d '{
    "body": "[Hein Cursor review] Test\n\nThis should be on a new line",
    "commit_id": "8e0e2a5",
    "path": "app/modules/kit-library/assets/js/hooks/use-kit-library-tracking.js",
    "line": 24,
    "side": "RIGHT"
  }'
```

## Current Issue Analysis

The problem is in how Python/shell reads the JSON:

```python
# When Python reads JSON:
"body": "[Hein] \n\n Issue"

# It becomes this string:
"[Hein] \n\n Issue"

# But GitHub API needs:
"[Hein] 

 Issue"
```

## Quick Fix for Existing Comments

Since comments are already posted incorrectly, you can:

1. **Delete them on GitHub** and repost with correct formatting
2. **Edit them manually** on GitHub (click the three dots → Edit)
3. **Leave them** - they're still readable, just not pretty

## Recommended Approach Going Forward

When creating `comments-to-post.json`, ask Cursor to format like this:

```
Create JSON with proper line breaks for GitHub.

Use this format for the body field:
- Use actual line breaks (not \n)
- Or use \\n (double backslash)
- Make sure JSON is valid

Example:
{
  "body": "[Hein Cursor review] 🚨 **Critical**\n\n**Issue:** Problem description\n\n**Recommendation:** Fix"
}
```

The `\n` in JSON should remain as literal `\n` characters in the string, which GitHub API will interpret as line breaks.

