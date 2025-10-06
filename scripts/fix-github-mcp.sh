#!/bin/bash
# Fix GitHub MCP Configuration for Cursor
# This script helps troubleshoot and fix GitHub MCP connection issues

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  GitHub MCP Configuration Fixer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 1: Backup current config
echo "📋 Step 1: Backing up current configuration..."
if [ -f ~/.cursor/mcp.json ]; then
    cp ~/.cursor/mcp.json ~/.cursor/mcp.json.backup-$(date +%Y%m%d-%H%M%S)
    echo "✅ Backed up to: ~/.cursor/mcp.json.backup-$(date +%Y%m%d-%H%M%S)"
else
    echo "⚠️  No existing mcp.json found at ~/.cursor/mcp.json"
fi
echo ""

# Step 2: Check if Docker is available
echo "🐳 Step 2: Checking Docker..."
if command -v docker &> /dev/null; then
    if docker ps &> /dev/null; then
        echo "✅ Docker is installed and running"
        DOCKER_AVAILABLE=true
    else
        echo "⚠️  Docker is installed but not running"
        echo "   Please start Docker Desktop"
        DOCKER_AVAILABLE=false
    fi
else
    echo "⚠️  Docker is not installed"
    echo "   Install from: https://docs.docker.com/desktop/install/mac-install/"
    DOCKER_AVAILABLE=false
fi
echo ""

# Step 3: Check GitHub token
echo "🔑 Step 3: Checking GitHub token..."
if [ -z "$GITHUB_TOKEN" ]; then
    echo "⚠️  GITHUB_TOKEN not found in environment"
    echo ""
    echo "To create a GitHub token:"
    echo "1. Go to: https://github.com/settings/tokens"
    echo "2. Click: Generate new token (classic)"
    echo "3. Select scopes: repo, read:org, workflow"
    echo "4. Generate and copy the token"
    echo ""
    read -p "Enter your GitHub token (or press Enter to skip): " token
    
    if [ -n "$token" ]; then
        export GITHUB_TOKEN="$token"
        
        # Add to shell profile
        if [ -f ~/.zshrc ]; then
            echo "" >> ~/.zshrc
            echo "# GitHub Token for MCP" >> ~/.zshrc
            echo "export GITHUB_TOKEN=\"$token\"" >> ~/.zshrc
            echo "✅ Token saved to ~/.zshrc"
        elif [ -f ~/.bashrc ]; then
            echo "" >> ~/.bashrc
            echo "# GitHub Token for MCP" >> ~/.bashrc
            echo "export GITHUB_TOKEN=\"$token\"" >> ~/.bashrc
            echo "✅ Token saved to ~/.bashrc"
        fi
        
        GITHUB_TOKEN_SET=true
    else
        echo "⏭️  Skipping token setup"
        GITHUB_TOKEN_SET=false
    fi
else
    echo "✅ GITHUB_TOKEN is set"
    echo "   Token: ${GITHUB_TOKEN:0:10}..."
    GITHUB_TOKEN_SET=true
fi
echo ""

# Step 4: Pull Docker image if available
if [ "$DOCKER_AVAILABLE" = true ] && [ "$GITHUB_TOKEN_SET" = true ]; then
    echo "📦 Step 4: Pulling GitHub MCP Docker image..."
    docker pull ghcr.io/github/github-mcp-server:latest
    if [ $? -eq 0 ]; then
        echo "✅ Docker image pulled successfully"
    else
        echo "❌ Failed to pull Docker image"
    fi
else
    echo "⏭️  Step 4: Skipping Docker image pull"
fi
echo ""

# Step 5: Configuration recommendation
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Configuration Recommendation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$DOCKER_AVAILABLE" = true ] && [ "$GITHUB_TOKEN_SET" = true ]; then
    echo "✅ Recommended: Use Docker MCP (Self-Hosted)"
    echo ""
    echo "Replace the 'github' section in ~/.cursor/mcp.json with:"
    echo ""
    cat << 'EOF'
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
            "GITHUB_PERSONAL_ACCESS_TOKEN": "${env:GITHUB_TOKEN}"
        }
    }
}
EOF
else
    echo "📝 Recommended: Fix current configuration"
    echo ""
    echo "Your current GitHub MCP config is missing the wrapper structure."
    echo "Update the 'github' section in ~/.cursor/mcp.json to:"
    echo ""
    cat << 'EOF'
"github": {
    "command": "/usr/local/bin/prompt_security/prompt_security_mcp",
    "args": [
        "/Users/janvanvlastuin1981/.cursor/mcp.json",
        "github"
    ],
    "server": {
        "url": "https://api.githubcopilot.com/mcp/",
        "transport": {
            "type": "http"
        },
        "auth": {
            "type": "oauth",
            "scopes": ["repo", "read:org", "workflow"]
        }
    }
}
EOF
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Next Steps"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Edit ~/.cursor/mcp.json:"
echo "   cursor ~/.cursor/mcp.json"
echo ""
echo "2. Replace the 'github' section with the config above"
echo ""
echo "3. Save the file and completely restart Cursor"
echo ""
echo "4. Test the connection in Cursor chat:"
echo "   'List recent PRs in elementor/elementor'"
echo ""
echo "5. If still not working, see:"
echo "   cat 00-github-reviews/TROUBLESHOOTING-GITHUB-MCP.md"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Optional: Open the config file
echo ""
read -p "Would you like to open ~/.cursor/mcp.json now? (y/n): " open_file
if [ "$open_file" = "y" ] || [ "$open_file" = "Y" ]; then
    if command -v cursor &> /dev/null; then
        cursor ~/.cursor/mcp.json
    elif command -v code &> /dev/null; then
        code ~/.cursor/mcp.json
    else
        open -e ~/.cursor/mcp.json
    fi
fi

echo ""
echo "✅ Configuration check complete!"
echo ""




