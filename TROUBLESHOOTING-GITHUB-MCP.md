# Troubleshooting: GitHub MCP Not Working

**Issue:** GitHub MCP server not connecting in Cursor  
**Date:** October 6, 2025

---

## Problem Identified

Looking at your `~/.cursor/mcp.json`, the GitHub MCP configuration is incomplete. It's missing the wrapper structure that other MCP servers in your config use.

**Current (Not Working):**
```json
"github": {
   "url": "https://api.githubcopilot.com/mcp/",
   "type": "http",
   "auth": {
     "type": "oauth",
     "scopes": ["repo", "read:org", "workflow"]
   }
}
```

---

## Solutions to Try

### Solution 1: Fix the Configuration Structure ⭐ (Try This First)

Your other MCP servers use a `prompt_security_mcp` wrapper. The GitHub MCP needs similar structure:

**Option A: With prompt_security wrapper (matches your other servers)**
```json
"github": {
    "command": "/usr/local/bin/prompt_security/prompt_security_mcp",
    "args": [
        "/Users/janvanvlastuin1981/.cursor/mcp.json",
        "github"
    ],
    "server": {
        "url": "https://api.githubcopilot.com/mcp/",
        "type": "http",
        "auth": {
            "type": "oauth",
            "scopes": ["repo", "read:org", "workflow"]
        }
    }
}
```

**Option B: Without wrapper (simpler, if your setup allows)**
```json
"github": {
    "url": "https://api.githubcopilot.com/mcp/",
    "transport": {
        "type": "http"
    },
    "auth": {
        "type": "oauth",
        "scopes": ["repo", "read:org", "workflow"]
    }
}
```

---

### Solution 2: Use Self-Hosted MCP with Docker (Alternative)

Since hosted GitHub MCP might have compatibility issues, use Docker instead:

**1. First, verify you have GitHub token:**
```bash
echo $GITHUB_TOKEN
# If empty, create one at: https://github.com/settings/tokens
export GITHUB_TOKEN="ghp_your_token_here"
```

**2. Replace the GitHub MCP config with Docker version:**
```json
"github": {
    "command": "/usr/local/bin/prompt_security/prompt_security_mcp",
    "args": [
        "/Users/janvanvlastuin1981/.cursor/mcp.json",
        "github"
    ],
    "server": {
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
            "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
        }
    }
}
```

**3. Pull the Docker image:**
```bash
docker pull ghcr.io/github/github-mcp-server:latest
```

---

### Solution 3: Check for Common Issues

**Issue 1: Docker not running**
```bash
# Check if Docker is running
docker ps

# If not, start Docker Desktop
open -a Docker
```

**Issue 2: No GitHub Copilot subscription**
```bash
# Hosted MCP requires Copilot
# Check at: https://github.com/settings/copilot
# If you don't have it, use Solution 2 (Docker) instead
```

**Issue 3: OAuth not completed**
```bash
# If using hosted MCP, check authorized apps:
# https://github.com/settings/applications
# Look for "Cursor" or "GitHub Copilot MCP"
# Revoke and re-authorize if needed
```

**Issue 4: MCP server conflicts**
```bash
# Check if another MCP is using the same port/endpoint
# Look in your mcp.json for duplicate URLs
```

---

## Quick Fix Script

I'll create a script to fix your configuration:

```bash
#!/bin/bash
# Fix GitHub MCP Configuration

echo "🔧 Fixing GitHub MCP Configuration..."

# Backup current config
cp ~/.cursor/mcp.json ~/.cursor/mcp.json.backup
echo "✅ Backed up to ~/.cursor/mcp.json.backup"

# Check if GITHUB_TOKEN exists
if [ -z "$GITHUB_TOKEN" ]; then
    echo "⚠️  GITHUB_TOKEN not found!"
    echo ""
    echo "Please create a token at: https://github.com/settings/tokens"
    echo "Required scopes: repo, read:org, workflow"
    echo ""
    read -p "Enter your GitHub token: " token
    export GITHUB_TOKEN="$token"
    echo "export GITHUB_TOKEN=\"$token\"" >> ~/.zshrc
    echo "✅ Token saved to ~/.zshrc"
fi

# Pull Docker image
echo "📦 Pulling GitHub MCP Docker image..."
docker pull ghcr.io/github/github-mcp-server:latest

echo ""
echo "✅ Setup complete!"
echo ""
echo "Now update your ~/.cursor/mcp.json with the Docker configuration."
echo "See TROUBLESHOOTING-GITHUB-MCP.md for the config to use."
```

---

## Step-by-Step Fix Process

### Step 1: Backup Your Current Config

```bash
cp ~/.cursor/mcp.json ~/.cursor/mcp.json.backup
```

### Step 2: Choose Your Approach

**Approach A: Fix Hosted MCP (if you have Copilot)**
1. Update the GitHub section in `mcp.json` with Option A config above
2. Restart Cursor
3. Re-authorize GitHub OAuth when prompted

**Approach B: Switch to Docker MCP (recommended)**
1. Create GitHub token: https://github.com/settings/tokens
2. Set environment variable: `export GITHUB_TOKEN="ghp_..."`
3. Pull Docker image: `docker pull ghcr.io/github/github-mcp-server:latest`
4. Update GitHub section in `mcp.json` with Docker config
5. Restart Cursor

### Step 3: Update mcp.json

Open the file:
```bash
code ~/.cursor/mcp.json
# or
cursor ~/.cursor/mcp.json
```

Replace the `"github": {...}` section with your chosen config.

### Step 4: Restart Cursor

Completely quit and restart Cursor (not just reload window).

### Step 5: Test Connection

Open Cursor chat and try:
```
@github list recent pull requests in elementor/elementor
```

or

```
List recent PRs in elementor/elementor using GitHub MCP
```

---

## Verification Checklist

- [ ] GitHub token created (if using Docker)
- [ ] `GITHUB_TOKEN` environment variable set
- [ ] Docker image pulled (if using Docker)
- [ ] `mcp.json` updated with correct configuration
- [ ] Cursor completely restarted
- [ ] Test query executed
- [ ] MCP connection successful

---

## Expected Behavior

### When Working:
```
✅ MCP Server "github" connected
✅ Found 10 recent pull requests
✅ PR #12345: Fix navigation bug
✅ PR #12344: Add new widget
...
```

### When Not Working:
```
❌ Failed to connect to MCP server "github"
❌ Error: Authentication failed
❌ Error: Server not found
```

---

## Debugging Commands

### Check MCP Status in Cursor
```
1. Open Cursor
2. Look at bottom status bar
3. Should show "MCP: X connected" (or click to see details)
```

### View Cursor Logs
```
1. In Cursor: Help → Toggle Developer Tools
2. Go to Console tab
3. Look for MCP-related errors
4. Filter by "mcp" or "github"
```

### Test Docker MCP Manually
```bash
# Test the Docker command directly
docker run -i --rm \
  -e GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_TOKEN" \
  ghcr.io/github/github-mcp-server:latest

# Should start without errors
# Press Ctrl+C to stop
```

### Check GitHub Token
```bash
# Test your token works
curl -H "Authorization: token $GITHUB_TOKEN" \
     https://api.github.com/user

# Should return your GitHub user info
```

---

## Common Error Messages

### "MCP server not found"
**Cause:** Configuration format incorrect  
**Fix:** Use Solution 1 Option A (with prompt_security wrapper)

### "Authentication failed"
**Cause:** No OAuth or invalid token  
**Fix:** 
- Hosted: Re-authorize at https://github.com/settings/applications
- Docker: Check `GITHUB_TOKEN` is set correctly

### "Docker: command not found"
**Cause:** Docker not installed or not in PATH  
**Fix:** Install Docker Desktop or use hosted MCP instead

### "rate limit exceeded"
**Cause:** Too many API calls  
**Fix:** Wait 1 hour or use a token with higher limits

---

## Alternative: Use GitHub API Directly (Fallback)

If MCP continues to not work, you can use GitHub API directly without MCP:

See: **QUICK-START.md** → "Proposal B: Direct GitHub API Integration"

This uses a simple helper script without MCP:
```bash
# Create fetch-pr-diff.sh
curl -H "Authorization: token $GITHUB_TOKEN" \
     -H "Accept: application/vnd.github.v3.diff" \
     "https://api.github.com/repos/elementor/elementor/pulls/$PR_NUMBER" \
     > pr.diff
     
# Then paste diff into Cursor chat manually
```

---

## Next Steps

1. **Try Solution 2** (Docker MCP) - Most reliable
2. **Test with:** `./scripts/review-pr-mcp.sh https://github.com/elementor/elementor/pull/[NUMBER]`
3. **If still not working:** Use fallback GitHub API method
4. **Document what worked:** Update this file with your solution

---

## Get Help

**Still stuck?**

1. Check Cursor Developer Tools console for specific error
2. Share error message for more specific help
3. Verify Docker and GitHub token are working independently
4. Consider using Proposal B (direct API) as alternative

---

**Last Updated:** October 6, 2025  
**Status:** Troubleshooting Guide




