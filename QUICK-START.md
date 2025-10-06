# Quick Start Guide: PR Review with GitHub MCP

## 🚀 Fast Setup (5 Minutes)

### For Users with GitHub Copilot (Recommended)

1. **Configure MCP in Cursor:**
   - Open Cursor Settings: `Cmd+,` (Mac) or `Ctrl+,` (Windows)
   - Press `Cmd+Shift+P` → "Preferences: Open User Settings (JSON)"
   - Add this configuration:
   ```json
   {
     "mcp": {
       "servers": {
         "github": {
           "url": "https://api.githubcopilot.com/mcp/",
           "type": "http",
           "auth": {
             "type": "oauth",
             "scopes": ["repo", "read:org", "workflow"]
           }
         }
       }
     }
   }
   ```
   - Save and restart Cursor

2. **Authenticate:**
   - Cursor will prompt for GitHub authorization
   - Click "Authorize" and select your GitHub account

3. **Test Connection:**
   - Open Cursor chat
   - Type: "List recent PRs in elementor/elementor"
   - If successful, you're ready!

### For Users Without GitHub Copilot (Docker + PAT)

1. **Create GitHub Token:**
   - Go to: https://github.com/settings/tokens
   - Generate token with `repo`, `read:org`, `workflow` scopes
   - Copy token

2. **Set Environment Variable:**
   ```bash
   # Mac/Linux
   export GITHUB_TOKEN="ghp_your_token_here"
   
   # Add to ~/.zshrc for persistence:
   echo 'export GITHUB_TOKEN="ghp_your_token_here"' >> ~/.zshrc
   ```

3. **Configure MCP in Cursor:**
   - Open Cursor Settings: `Cmd+Shift+P` → "Open User Settings (JSON)"
   - Add:
   ```json
   {
     "mcp": {
       "servers": {
         "github": {
           "command": "docker",
           "args": [
             "run", "-i", "--rm", "-e", "GITHUB_PERSONAL_ACCESS_TOKEN",
             "ghcr.io/github/github-mcp-server:latest"
           ],
           "env": {
             "GITHUB_PERSONAL_ACCESS_TOKEN": "${env:GITHUB_TOKEN}"
           }
         }
       }
     }
   }
   ```

4. **Pull Docker Image:**
   ```bash
   docker pull ghcr.io/github/github-mcp-server:latest
   ```

---

## 📝 How to Review a PR

### Method 1: Simple Chat Review

1. **Open Cursor Chat** (in your workspace)

2. **Paste this prompt:**
   ```
   Please review this GitHub PR: https://github.com/elementor/elementor/pull/[NUMBER]
   
   Using GitHub MCP:
   1. Fetch the PR diff
   2. Apply coding rules from elementor-cursor-review-mcp/rules/
   3. Generate a structured review with:
      - Executive summary
      - Issues by severity (Critical/High/Medium/Low)
      - File:line references for each issue
      - Recommended fixes
   
   Save the review to: pr-reviews/PR-[NUMBER]-$(date +%Y-%m-%d).md
   ```

3. **Wait for Analysis:**
   - Cursor fetches PR via MCP
   - Applies 22 coding rules
   - Generates structured review

4. **Review Output:**
   - Open generated markdown file
   - Review findings
   - Share with team or post to GitHub

### Method 2: Using Helper Script

1. **Run the script:**
   ```bash
   cd "/Users/janvanvlastuin1981/Local Sites/elementor/app/public/wp-content"
   ./scripts/review-pr-mcp.sh https://github.com/elementor/elementor/pull/123
   ```

2. **Follow the instructions** displayed by the script

3. **Paste generated prompt** into Cursor chat

---

## 🎯 Common Review Commands

### List Recent PRs
```
List the 10 most recent open PRs in elementor/elementor
```

### Get PR Details
```
Show me details for PR #123 including description and changed files
```

### Review Specific Files
```
Review the TypeScript files changed in PR #123 for type safety issues
```

### Check Security
```
Review PR #123 specifically for security vulnerabilities and WordPress security best practices
```

### Generate Review Report
```
Create a comprehensive review for PR #123 following our 22 coding rules. 
Include file:line references and save to pr-reviews/
```

---

## 📤 Posting Comments to GitHub (Optional)

After reviewing, you can post inline comments:

1. **Review your findings** in the generated markdown file

2. **Ask Cursor to post comments:**
   ```
   Please post the Critical and High priority issues from pr-reviews/PR-123-2025-10-06.md
   to GitHub PR #123 as inline review comments using MCP.
   
   Only post issues with clear file:line references.
   Group similar issues together.
   ```

3. **Confirm each comment** before posting

---

## 🔍 Verification Commands

### Check MCP Status
```
What MCP servers are currently connected?
```

### Test GitHub Access
```
Can you access the elementor/elementor repository via MCP?
```

### Verify Rules Loaded
```
List all coding rules available from elementor-cursor-review-mcp/rules/
```

---

## 🐛 Quick Troubleshooting

### "MCP not configured"
- Check settings.json has MCP configuration
- Restart Cursor

### "Authentication failed"
- Re-authorize in GitHub Settings → Applications
- Or regenerate GitHub token

### "Can't access repository"
- Verify GitHub account has repo access
- Check token/OAuth scopes include "repo"

### "Docker container won't start"
- Ensure Docker Desktop is running: `docker ps`
- Pull latest image: `docker pull ghcr.io/github/github-mcp-server:latest`

---

## 📚 Full Documentation

For detailed setup instructions, troubleshooting, and advanced configuration:

👉 **See:** [MCP-SETUP-GUIDE.md](./MCP-SETUP-GUIDE.md)

---

## 🎓 Example: Full Review Workflow

```bash
# 1. Identify PR to review
PR_URL="https://github.com/elementor/elementor/pull/27890"

# 2. Open Cursor in workspace
cd "/Users/janvanvlastuin1981/Local Sites/elementor/app/public/wp-content"
cursor .

# 3. Open chat and paste:
```

**Cursor Chat Prompt:**
```
Review PR: https://github.com/elementor/elementor/pull/27890

Tasks:
1. Fetch PR diff via GitHub MCP
2. Apply all 22 coding rules from elementor-cursor-review-mcp/rules/
3. Analyze for:
   - TypeScript type safety issues
   - React performance anti-patterns
   - WordPress security vulnerabilities
   - Code style violations
   - Missing tests
4. Generate review report with:
   - Executive summary with risk assessment
   - Critical issues (blockers)
   - High priority issues
   - Medium priority improvements
   - Code style suggestions
   - Positive observations
5. Save to: pr-reviews/PR-27890-2025-10-06.md

Format each issue as: [file:line] Issue description - Rule: [rule-name]
```

**Expected Output:**
```
✓ Connected to GitHub MCP
✓ Fetched PR #27890
✓ Loaded 22 coding rules
✓ Analyzed 23 changed files
✓ Found 3 critical, 7 high, 12 medium priority issues
✓ Generated review: pr-reviews/PR-27890-2025-10-06.md
```

---

## ⚡ Pro Tips

1. **Use Specific Queries:**
   - Instead of "review this PR"
   - Use "check PR #123 for TypeScript type safety violations"

2. **Review Incrementally:**
   - Review specific file types first
   - Then do comprehensive review

3. **Learn from Reviews:**
   - Track common issues
   - Update coding rules accordingly
   - Share learnings with team

4. **Combine with Manual Review:**
   - Use AI for first-pass automated checks
   - Human reviewers focus on architecture and logic
   - Best of both worlds

---

**Last Updated:** October 6, 2025  
**Status:** Ready to Use  
**Questions?** See MCP-SETUP-GUIDE.md or ask in Cursor chat!




