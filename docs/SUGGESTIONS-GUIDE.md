# GitHub Commit Suggestions Guide

This guide explains how to use the enhanced review script to create GitHub comments with commit suggestions that authors can apply with a single click.

## What are GitHub Suggestions?

GitHub suggestions allow reviewers to propose specific code changes that the PR author can commit directly by clicking "Commit suggestion" button. This streamlines the code review process and reduces back-and-forth communication.

## How to Create Suggestions

### 1. In Review Comments JSON

When creating review comments, include suggestions using this format:

```json
{
  "severity": "Critical",
  "file": "path/to/file.js", 
  "line": 42,
  "body": "TMZ Review MCP: 🚨 **Critical Issue**\\n\\n**Rule:** rule-name\\n\\n**Issue:** Description of the problem\\n\\n**Suggested Fix:**\\n```suggestion\\n// Your fixed code here\\nconst fixedCode = 'example';\\n```",
  "suggestion": {
    "original_code": "const brokenCode = 'example';",
    "suggested_code": "const fixedCode = 'example';"
  }
}
```

### 2. Key Components

- **```suggestion code block**: This is what GitHub renders as a commit suggestion
- **suggestion object**: Optional metadata for tracking (not sent to GitHub API)
- **Proper escaping**: Use `\\n` for newlines in JSON body

### 3. Best Practices for Suggestions

#### ✅ Good Suggestions:
- **Single responsibility**: Fix one specific issue per suggestion
- **Complete code**: Provide working, complete code replacements
- **Proper formatting**: Match the project's coding standards
- **Context-aware**: Consider surrounding code and dependencies

#### ❌ Avoid:
- **Partial fixes**: Don't suggest incomplete code
- **Multiple issues**: Don't try to fix multiple problems in one suggestion
- **Breaking changes**: Ensure suggestions don't break functionality
- **Style-only changes**: Focus on functional improvements

## Examples

### Example 1: Remove Debug Statement
```json
{
  "body": "TMZ Review MCP: 🚨 **Critical: Debug Statement in Production**\\n\\n**Issue:** Console.log should be removed\\n\\n**Suggested Fix:**\\n```suggestion\\n\\t\\t// Debug statement removed for production\\n```"
}
```

### Example 2: Fix Function Call
```json
{
  "body": "TMZ Review MCP: 🚨 **Critical: Function Invoked Instead of Passed**\\n\\n**Issue:** Handler is called immediately instead of passed as reference\\n\\n**Suggested Fix:**\\n```suggestion\\nonClick={ () => handleClick(data) }\\n```"
}
```

### Example 3: Add Missing Dependencies
```json
{
  "body": "TMZ Review MCP: ⚠️ **High: Missing useCallback Dependencies**\\n\\n**Issue:** Dependencies missing from dependency array\\n\\n**Suggested Fix:**\\n```suggestion\\n\\t], [ id, name, callback ] );\\n```"
}
```

## Using the Enhanced Scripts

### 1. Generate Review with Suggestions

```bash
./review.sh https://github.com/owner/repo/pull/123
```

The script now prompts you to include suggestions in your comments.

### 2. Post Comments with Suggestions

```bash
./post-comments.sh
```

The script will:
- Show ✨ indicator for comments with suggestions
- Display count of suggestions in summary
- Remind authors they can click "Commit suggestion"

### 3. Script Output

```
📤 Posting comments...

  ↳ file.js:42 [Critical] ✨
    ✅ Posted
  ↳ component.js:15 [High] ✨  
    ✅ Posted

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ✅ Posted: 2 comments
  ❌ Failed: 0 comments  
  ✨ With suggestions: 2 comments

  View at: https://github.com/owner/repo/pull/123/files

  💡 Authors can click 'Commit suggestion' to apply fixes directly!
```

## GitHub API Details

The GitHub API automatically recognizes `````suggestion` markdown blocks and renders them as interactive commit suggestions. No special API parameters are needed - just include the suggestion blocks in the comment body.

### API Request Format:
```json
{
  "body": "Comment text\\n\\n```suggestion\\nfixed code\\n```",
  "commit_id": "abc123",
  "path": "file.js", 
  "line": 42,
  "side": "RIGHT"
}
```

## Tips for Reviewers

1. **Be specific**: Target exact lines that need changes
2. **Test suggestions**: Ensure your suggested code actually works
3. **Follow standards**: Match the project's coding conventions
4. **Explain why**: Always include context about why the change is needed
5. **Keep it simple**: One logical change per suggestion

## Tips for Authors

1. **Review carefully**: Suggestions are commits - review before applying
2. **Test after applying**: Run tests after committing suggestions
3. **Batch apply**: You can apply multiple suggestions in one commit
4. **Customize commit message**: GitHub allows editing the commit message

## Troubleshooting

### Suggestions Not Showing
- Check that you're using `````suggestion` (not `````javascript` or other)
- Ensure proper JSON escaping with `\\n` for newlines
- Verify the suggestion block is properly closed

### Suggestions Not Applying
- Make sure suggested code is complete and syntactically correct
- Check that line numbers match the current PR state
- Ensure no merge conflicts exist

## Integration with Cursor

When using Cursor to generate reviews:

1. **Prompt for suggestions**: Always ask Cursor to include suggestions when possible
2. **Validate output**: Check that JSON format is correct
3. **Test locally**: Verify suggestions work before posting
4. **Follow patterns**: Use the examples in this guide as templates

This enhancement makes code reviews more actionable and efficient by allowing direct code application through GitHub's native suggestion feature.
