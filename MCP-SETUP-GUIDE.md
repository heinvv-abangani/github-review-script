# GitHub MCP Setup Guide for Cursor AI
## Implementing Proposal A: GitHub MCP Server Integration

**Date:** October 6, 2025  
**Status:** Implementation Guide  
**Related:** PLAN.MD - Proposal A

---

## Overview

This guide provides step-by-step instructions for setting up GitHub's MCP (Model Context Protocol) server with Cursor AI to automate PR reviews for the Elementor project.

### Two Setup Options

1. **Option 1: GitHub Hosted MCP** (Recommended - Easiest)
   - Uses GitHub's official hosted MCP server
   - No local installation required
   - OAuth authentication
   - Automatic updates

2. **Option 2: Self-Hosted MCP with Docker** (More Control)
   - Run GitHub MCP server locally via Docker
   - Use Personal Access Token (PAT)
   - Full control over configuration

---

## Option 1: GitHub Hosted MCP (Recommended)

### Prerequisites

✅ **Requirements:**
- Cursor IDE installed (based on VS Code)
- GitHub account with access to Elementor repository
- GitHub Copilot subscription (required for hosted MCP)
- Network access to `https://api.githubcopilot.com`

### Step 1: Verify GitHub Copilot Access

1. Check if you have GitHub Copilot access:
   - Go to https://github.com/settings/copilot
   - Verify you have an active subscription

2. If you don't have Copilot:
   - Consider GitHub Copilot Individual ($10/month) or Business plan
   - OR use Option 2 (Self-Hosted) instead

### Step 2: Configure MCP in Cursor

Since Cursor is built on VS Code, it supports MCP configuration. Here's how to set it up:

#### Method A: Using Cursor Settings UI

1. **Open Cursor Settings:**
   - Press `Cmd+,` (Mac) or `Ctrl+,` (Windows/Linux)
   - Or: `Cursor` → `Settings` → `Settings`

2. **Access MCP Configuration:**
   - Search for "MCP" in settings search bar
   - Look for "MCP: Servers" or similar setting

3. **Add GitHub MCP Server:**
   - Click "Edit in settings.json" if available
   - Or manually edit settings file (see Method B)

#### Method B: Manual Configuration (settings.json)

1. **Open Cursor Settings JSON:**
   ```
   Mac: Cmd+Shift+P → "Preferences: Open User Settings (JSON)"
   Windows/Linux: Ctrl+Shift+P → "Preferences: Open User Settings (JSON)"
   ```

2. **Add GitHub MCP Configuration:**
   ```json
   {
     "mcp": {
       "servers": {
         "github": {
           "url": "https://api.githubcopilot.com/mcp/",
           "type": "http",
           "auth": {
             "type": "oauth",
             "scopes": [
               "repo",
               "read:org",
               "workflow"
             ]
           }
         }
       }
     }
   }
   ```

3. **Save the file** (`Cmd+S` or `Ctrl+S`)

### Step 3: Authenticate with GitHub

1. **Restart Cursor** to apply MCP configuration

2. **Trigger OAuth Flow:**
   - Open Cursor chat
   - Try to access GitHub MCP (it will prompt for authorization)
   - Or manually trigger: `Cmd+Shift+P` → "MCP: Connect to GitHub"

3. **Authorize Access:**
   - A browser window will open
   - Click "Authorize" to grant Cursor access to GitHub
   - Select your GitHub account (ensure it has access to Elementor repo)

4. **Verify Connection:**
   - Return to Cursor
   - You should see a confirmation message
   - MCP status indicator should show "Connected"

### Step 4: Test MCP Connection

1. **Open Cursor Chat**

2. **Test Basic Query:**
   ```
   Can you list the recent pull requests in the elementor/elementor repository?
   ```

3. **Expected Response:**
   - Cursor should use GitHub MCP to fetch PR data
   - You should see a list of recent PRs

4. **If it doesn't work:**
   - Check MCP status in status bar
   - Verify OAuth token in GitHub → Settings → Applications
   - Check Cursor logs: `Help` → `Toggle Developer Tools` → `Console`

---

## Option 2: Self-Hosted MCP with Docker

### Prerequisites

✅ **Requirements:**
- Docker installed and running
- GitHub Personal Access Token (PAT)
- Cursor IDE installed

### Step 1: Install Docker

1. **Download Docker Desktop:**
   - Mac: https://docs.docker.com/desktop/install/mac-install/
   - Windows: https://docs.docker.com/desktop/install/windows-install/
   - Linux: https://docs.docker.com/desktop/install/linux-install/

2. **Verify Installation:**
   ```bash
   docker --version
   docker ps
   ```

### Step 2: Create GitHub Personal Access Token

1. **Go to GitHub Settings:**
   - Navigate to: https://github.com/settings/tokens
   - Click "Generate new token" → "Generate new token (classic)"

2. **Configure Token:**
   - **Note:** "Elementor PR Review MCP"
   - **Expiration:** 90 days (or "No expiration" for convenience)
   - **Scopes:** Select:
     - ✅ `repo` (Full control of private repositories)
     - ✅ `read:org` (Read org and team membership)
     - ✅ `workflow` (Update GitHub Action workflows)
     - ✅ `write:discussion` (Read and write team discussions)

3. **Generate and Copy Token:**
   - Click "Generate token"
   - **IMPORTANT:** Copy the token immediately (you won't see it again!)
   - Save it securely (e.g., password manager)

4. **Add to Environment Variables:**
   ```bash
   # Mac/Linux: Add to ~/.zshrc or ~/.bashrc
   export GITHUB_TOKEN="ghp_your_token_here"
   
   # Windows: Add to system environment variables
   # Or use PowerShell:
   [Environment]::SetEnvironmentVariable("GITHUB_TOKEN", "ghp_your_token_here", "User")
   ```

5. **Reload Shell:**
   ```bash
   source ~/.zshrc  # Mac/Linux
   # Or restart terminal/Cursor
   ```

### Step 3: Configure MCP in Cursor

1. **Create Workspace MCP Config:**
   ```bash
   cd "/Users/janvanvlastuin1981/Local Sites/elementor/app/public/wp-content"
   mkdir -p .vscode
   ```

2. **Create `.vscode/mcp.json`:**
   ```json
   {
     "inputs": [
       {
         "type": "promptString",
         "id": "github_token",
         "description": "GitHub Personal Access Token",
         "password": true
       }
     ],
     "servers": {
       "github": {
         "command": "docker",
         "args": [
           "run",
           "-i",
           "--rm",
           "-e",
           "GITHUB_PERSONAL_ACCESS_TOKEN",
           "ghcr.io/github/github-mcp-server:latest"
         ],
         "env": {
           "GITHUB_PERSONAL_ACCESS_TOKEN": "${input:github_token}"
         }
       }
     }
   }
   ```

3. **Or Add to Cursor User Settings:**
   
   Open `settings.json` and add:
   ```json
   {
     "mcp": {
       "inputs": [
         {
           "type": "env",
           "id": "github_token",
           "name": "GITHUB_TOKEN"
         }
       ],
       "servers": {
         "github": {
           "command": "docker",
           "args": [
             "run",
             "-i",
             "--rm",
             "-e",
             "GITHUB_PERSONAL_ACCESS_TOKEN",
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

### Step 4: Pull MCP Docker Image

```bash
docker pull ghcr.io/github/github-mcp-server:latest
```

### Step 5: Test MCP Connection

1. **Restart Cursor**

2. **Verify Docker Container:**
   - When you use MCP in Cursor, it should start the Docker container
   - Check running containers:
   ```bash
   docker ps
   ```

3. **Test in Cursor Chat:**
   ```
   Can you access the elementor/elementor repository via MCP?
   ```

---

## MCP Configuration for PR Reviews

### Enhanced MCP Config with PR Review Capabilities

Once MCP is connected, enhance your configuration to optimize for PR reviews:

#### Update `.vscode/mcp.json` (or settings.json):

```json
{
  "mcp": {
    "servers": {
      "github": {
        "url": "https://api.githubcopilot.com/mcp/",
        "type": "http",
        "auth": {
          "type": "oauth"
        },
        "capabilities": {
          "tools": [
            "get_pull_request",
            "list_pull_requests",
            "get_pull_request_diff",
            "get_pull_request_files",
            "create_review_comment",
            "list_review_comments",
            "update_review_comment",
            "search_code",
            "get_file_contents"
          ]
        },
        "config": {
          "defaultOwner": "elementor",
          "defaultRepo": "elementor",
          "maxDiffSize": 100000,
          "commentMode": "inline"
        }
      }
    }
  }
}
```

---

## Integration with PR Review Workflow

### Step 1: Create Review Rules Context

1. **Create Cursor Workspace Rule:**
   ```bash
   cd "/Users/janvanvlastuin1981/Local Sites/elementor/app/public/wp-content"
   mkdir -p .cursor/rules
   ```

2. **Create `.cursor/rules/pr-review.md`:**
   ```markdown
   # PR Review Guidelines
   
   When reviewing PRs via MCP:
   
   1. Load all 22 coding rules from elementor-cursor-review-mcp/rules/
   2. Fetch PR diff using GitHub MCP
   3. Analyze each changed file against rules
   4. Generate structured feedback with file:line references
   5. Categorize issues by severity (Critical/High/Medium/Low)
   6. Include positive observations
   7. Provide actionable recommendations
   
   ## Output Format
   
   Generate markdown review in format:
   - Executive summary
   - Issues by severity with [file:line] references
   - Rule violations with specific examples
   - Recommended fixes with code snippets
   - Overall recommendations
   ```

### Step 2: Create PR Review Command

1. **Create Helper Script: `scripts/review-pr-mcp.sh`:**
   ```bash
   mkdir -p scripts
   cat > scripts/review-pr-mcp.sh << 'EOF'
   #!/bin/bash
   # PR Review via MCP
   
   PR_URL=$1
   
   if [ -z "$PR_URL" ]; then
     echo "Usage: ./scripts/review-pr-mcp.sh <PR_URL>"
     exit 1
   fi
   
   # Extract PR number from URL
   PR_NUMBER=$(echo "$PR_URL" | grep -oE '[0-9]+$')
   
   if [ -z "$PR_NUMBER" ]; then
     echo "Error: Could not extract PR number from URL"
     exit 1
   fi
   
   # Create review output directory
   mkdir -p pr-reviews
   
   # Output file
   REVIEW_FILE="pr-reviews/PR-${PR_NUMBER}-$(date +%Y-%m-%d).md"
   
   echo "Reviewing PR #${PR_NUMBER}..."
   echo "Review will be saved to: ${REVIEW_FILE}"
   echo ""
   echo "Please paste this prompt into Cursor chat:"
   echo ""
   echo "---"
   cat << PROMPT
   Please review GitHub PR: ${PR_URL}
   
   Using the GitHub MCP:
   1. Fetch the PR details and diff
   2. Apply all 22 coding rules from elementor-cursor-review-mcp/rules/
   3. Generate a comprehensive review with:
      - Executive summary
      - Critical/High/Medium/Low priority issues
      - Each issue with [file:line] reference
      - Rule violation details
      - Recommended fixes with code examples
      - Positive observations
   
   Save the review to: ${REVIEW_FILE}
   PROMPT
   echo "---"
   EOF
   
   chmod +x scripts/review-pr-mcp.sh
   ```

2. **Make it executable:**
   ```bash
   chmod +x scripts/review-pr-mcp.sh
   ```

### Step 3: Configure Cursor Chat for Reviews

1. **Create Cursor Prompt Template:**
   
   In Cursor, create a custom instruction/rule for PR reviews:
   
   ```markdown
   # PR Review Instructions
   
   When asked to review a PR:
   
   ## Step 1: Fetch PR Data via MCP
   - Use GitHub MCP to get PR details
   - Fetch diff and changed files
   - Get PR metadata (title, description, author)
   
   ## Step 2: Load Coding Rules
   - Load all rules from: elementor-cursor-review-mcp/rules/
   - Understand rule categories and severity
   
   ## Step 3: Analyze Changes
   - Review each changed file
   - Apply relevant coding rules
   - Identify violations, risks, and improvements
   - Note positive patterns
   
   ## Step 4: Generate Report
   - Create structured markdown review
   - Include file:line references for every issue
   - Categorize by severity
   - Provide actionable recommendations
   - Save to pr-reviews/ directory
   
   ## Step 5: Offer Comment Posting
   - Ask if user wants to post comments to GitHub
   - If yes, use MCP to create inline review comments
   - Confirm each comment before posting
   ```

---

## Usage Instructions

### Reviewing a PR with MCP

1. **Start Review:**
   ```bash
   ./scripts/review-pr-mcp.sh https://github.com/elementor/elementor/pull/123
   ```

2. **Copy the generated prompt** and paste into Cursor chat

3. **Cursor will:**
   - Connect to GitHub via MCP
   - Fetch PR #123 diff
   - Apply coding rules
   - Generate review in `pr-reviews/PR-123-2025-10-06.md`

4. **Review the Output:**
   - Open the generated markdown file
   - Review all findings
   - Verify accuracy

5. **Optional: Post Comments to GitHub:**
   
   In Cursor chat:
   ```
   Please post the review comments to GitHub PR #123 as inline comments using MCP.
   Group by severity and only post Critical and High priority issues.
   ```

---

## Troubleshooting

### Issue: MCP Server Not Connecting

**Solution:**
1. Check MCP status in Cursor status bar
2. Verify configuration in settings.json
3. Check logs: `Help` → `Toggle Developer Tools` → `Console`
4. Restart Cursor

### Issue: OAuth Authorization Failed

**Solution:**
1. Re-authorize: GitHub Settings → Applications
2. Revoke and re-grant access
3. Check GitHub Copilot subscription status

### Issue: Docker Container Won't Start

**Solution:**
1. Verify Docker is running: `docker ps`
2. Check Docker logs: `docker logs <container_id>`
3. Pull latest image: `docker pull ghcr.io/github/github-mcp-server:latest`
4. Verify GITHUB_TOKEN is set: `echo $GITHUB_TOKEN`

### Issue: Can't Access Private Repos

**Solution:**
1. Verify PAT scopes include `repo`
2. Check organization access permissions
3. Ensure GitHub account has repo access

### Issue: Rate Limiting

**Solution:**
1. GitHub MCP respects rate limits
2. Hosted MCP has higher limits with Copilot subscription
3. Self-hosted uses PAT rate limits (5000/hour)
4. Wait and retry if hitting limits

### Issue: MCP Can't Fetch PR Diff

**Solution:**
1. Verify PR number is correct
2. Check repo access permissions
3. Try fetching via web: `https://github.com/elementor/elementor/pull/123.diff`
4. Check MCP logs for specific error

---

## Verification Checklist

Before using MCP for reviews, verify:

- [ ] MCP server is configured in Cursor settings
- [ ] Authentication is successful (OAuth or PAT)
- [ ] Can list PRs: `List recent PRs in elementor/elementor`
- [ ] Can fetch diff: `Show diff for PR #123`
- [ ] Can access files: `Show me the files changed in PR #123`
- [ ] Coding rules are loaded in workspace
- [ ] pr-reviews/ directory exists (gitignored)
- [ ] Review script is executable

---

## Next Steps

Once MCP is configured and tested:

1. ✅ **Test with Sample PR:**
   - Pick a closed/merged PR to test
   - Run full review workflow
   - Validate output quality

2. ✅ **Refine Prompts:**
   - Adjust review prompt based on results
   - Fine-tune rule application
   - Optimize output format

3. ✅ **Create Shortcuts:**
   - Add Cursor keybindings for common tasks
   - Create command palette entries
   - Streamline workflow

4. ✅ **Document Team Usage:**
   - Share setup guide with team
   - Create usage examples
   - Establish review standards

5. ✅ **Monitor & Improve:**
   - Track false positives
   - Refine coding rules
   - Collect feedback

---

## Additional Resources

- **GitHub MCP Documentation:** https://docs.github.com/en/copilot/how-tos/provide-context/use-mcp/use-the-github-mcp-server
- **MCP Specification:** https://modelcontextprotocol.io/
- **GitHub API Reference:** https://docs.github.com/en/rest
- **Cursor Documentation:** https://docs.cursor.com/

---

## Security Notes

⚠️ **Important Security Considerations:**

1. **Never commit tokens:**
   - Add `.env` to `.gitignore`
   - Use environment variables
   - Rotate tokens regularly

2. **Minimize token scopes:**
   - Only grant necessary permissions
   - Review token usage periodically
   - Revoke unused tokens

3. **Audit MCP access:**
   - Review GitHub Settings → Applications regularly
   - Check authorized OAuth apps
   - Monitor API usage

4. **Keep reviews local:**
   - Add `pr-reviews/` to `.gitignore`
   - Don't commit sensitive review data
   - Archive old reviews securely

---

**Document Status:** Setup Guide - Ready for Implementation  
**Last Updated:** October 6, 2025  
**Related:** PLAN.MD (Proposal A)
