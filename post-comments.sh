#!/bin/bash
# GitHub PR Comments Script
# Usage: ./post-comments.sh [PR_NUMBER|PR_URL] [COMMENTS_FILE] [REPO_OWNER/REPO_NAME]
# Posts single-line code suggestions to GitHub pull requests

set -e

PR_REVIEWS_DIR="../pr-reviews"

# Function to extract repository from PR URL
extract_repo_from_url() {
    local url="$1"
    
    if [[ "$url" =~ github\.com/([^/]+)/([^/]+)/pull/([0-9]+) ]]; then
        local owner="${BASH_REMATCH[1]}"
        local repo="${BASH_REMATCH[2]}"
        local pr_number="${BASH_REMATCH[3]}"
        
        echo "${owner}/${repo}"
        return 0
    fi
    
    return 1
}

# Function to auto-detect repository from git remote
detect_repository_from_git() {
    local git_remote
    
    # Try to get the repository from git remote
    if git_remote=$(git remote get-url origin 2>/dev/null); then
        # Extract owner/repo from various Git URL formats
        if [[ "$git_remote" =~ github\.com[:/]([^/]+)/([^/]+)(\.git)?$ ]]; then
            local owner="${BASH_REMATCH[1]}"
            local repo="${BASH_REMATCH[2]}"
            # Remove .git suffix if present
            repo="${repo%.git}"
            echo "${owner}/${repo}"
            return 0
        fi
    fi
    
    return 1
}

# Function to detect repository from comments file metadata
detect_repo_from_comments_file() {
    local comments_file="$1"
    
    # Check if the comments file has a repository field (future enhancement)
    if [[ -f "$comments_file" ]]; then
        local repo_from_file=$(jq -r '.repository // empty' "$comments_file" 2>/dev/null)
        if [[ -n "$repo_from_file" && "$repo_from_file" != "null" ]]; then
            echo "$repo_from_file"
            return 0
        fi
    fi
    
    return 1
}

# Function to resolve repository alias (load from config if available)
resolve_repo_alias() {
    local input="$1"
    
    # Source config if available
    if [[ -f "$(dirname "$0")/config.sh" ]]; then
        source "$(dirname "$0")/config.sh"
        
        # Try to resolve using config function
        if declare -f resolve_repo_alias >/dev/null 2>&1; then
            local resolved=$(resolve_repo_alias "$input" 2>/dev/null)
            if [[ -n "$resolved" ]]; then
                echo "$resolved"
                return 0
            fi
        fi
    fi
    
    # Fallback: basic alias resolution
    case "$input" in
        "elementor") echo "elementor/elementor" ;;
        "pkp"|"platform-kit") echo "elementor/platform-kit-publisher" ;;
        "pro") echo "elementor/elementor-pro" ;;
        *) 
            # Check if it's already a full repo name
            if [[ "$input" =~ ^[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+$ ]]; then
                echo "$input"
                return 0
            fi
            return 1
            ;;
    esac
    return 0
}

# Function to validate repository exists and is accessible
validate_repository() {
    local repo="$1"
    
    if gh api "repos/$repo" --jq '.full_name' >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to validate and process JSON
validate_json() {
    local file="$1"
    
    # Check if file is valid JSON
    if ! jq empty "$file" 2>/dev/null; then
        echo "❌ Invalid JSON format in: $file"
        return 1
    fi
    
    # Check if it's an array
    if [[ $(jq type "$file") != '"array"' ]]; then
        echo "❌ JSON file must contain an array of comments"
        return 1
    fi
    
    # Check if array has required fields
    local missing_fields=$(jq -r '.[] | select(.file == null or .line == null or .body == null) | "Missing required fields"' "$file" | head -1)
    if [[ -n "$missing_fields" ]]; then
        echo "❌ Comments must have 'file', 'line', and 'body' fields"
        return 1
    fi
    
    return 0
}

# Parse arguments and determine repository
REPOSITORY=""
PR_NUMBER=""
COMMENTS_FILE=""
PR_URL=""

# Parse first argument - could be PR number, PR URL, or comments file
if [[ -n "$1" ]]; then
    if [[ "$1" =~ ^https://github\.com/([^/]+)/([^/]+)/pull/([0-9]+) ]]; then
        # It's a PR URL
        PR_URL="$1"
        REPOSITORY="${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
        PR_NUMBER="${BASH_REMATCH[3]}"
        COMMENTS_FILE="$2"  # Optional second parameter
        
    elif [[ "$1" =~ ^[0-9]+$ ]]; then
        # It's a PR number
        PR_NUMBER="$1"
        COMMENTS_FILE="$2"
        REPOSITORY="$3"  # Optional third parameter
        
    elif [[ -f "$1" ]]; then
        # It's a comments file
        COMMENTS_FILE="$1"
        # Try to extract PR number from filename
        if [[ $(basename "$COMMENTS_FILE") =~ ^PR-([0-9]+)-comments\.json$ ]]; then
            PR_NUMBER="${BASH_REMATCH[1]}"
        fi
        REPOSITORY="$2"  # Optional second parameter
        
    else
        echo "❌ Invalid first argument. Expected PR number, PR URL, or comments file path"
        echo ""
        echo "Usage: $0 [PR_NUMBER|PR_URL|COMMENTS_FILE] [COMMENTS_FILE] [REPOSITORY]"
        echo ""
        echo "Examples:"
        echo "  $0 https://github.com/elementor/platform-kit-publisher/pull/88"
        echo "  $0 88 PR-88-comments.json"
        echo "  $0 PR-88-comments.json elementor/platform-kit-publisher"
        echo "  $0 88  # Auto-detect file and repository"
        exit 1
    fi
else
    # No arguments - auto-detect everything
    LATEST_JSON=$(ls -t "$PR_REVIEWS_DIR"/PR-*-comments.json 2>/dev/null | head -1)
    
    if [[ -z "$LATEST_JSON" ]]; then
        echo "❌ No arguments provided and no comments JSON files found in $PR_REVIEWS_DIR"
        echo ""
        echo "Usage: $0 [PR_NUMBER|PR_URL|COMMENTS_FILE] [COMMENTS_FILE] [REPOSITORY]"
        exit 1
    fi
    
    COMMENTS_FILE="$LATEST_JSON"
    
    # Extract PR number from filename
    if [[ $(basename "$COMMENTS_FILE") =~ ^PR-([0-9]+)-comments\.json$ ]]; then
        PR_NUMBER="${BASH_REMATCH[1]}"
    else
        echo "❌ Could not extract PR number from filename: $COMMENTS_FILE"
        exit 1
    fi
fi

# Auto-detect comments file if not provided
if [[ -z "$COMMENTS_FILE" && -n "$PR_NUMBER" ]]; then
    # Try specific PR number first
    COMMENTS_FILE="$PR_REVIEWS_DIR/PR-${PR_NUMBER}-comments.json"
    if [[ ! -f "$COMMENTS_FILE" ]]; then
        # Try latest file
        COMMENTS_FILE=$(ls -t "$PR_REVIEWS_DIR"/PR-*-comments.json 2>/dev/null | head -1)
    fi
fi

# Validate required parameters
if [[ -z "$PR_NUMBER" ]]; then
    echo "❌ PR number not specified or could not be determined"
    exit 1
fi

if [[ -z "$COMMENTS_FILE" || ! -f "$COMMENTS_FILE" ]]; then
    echo "❌ Comments file not found: $COMMENTS_FILE"
    echo "   Expected location: $PR_REVIEWS_DIR/PR-${PR_NUMBER}-comments.json"
    exit 1
fi

# Validate JSON format
if ! validate_json "$COMMENTS_FILE"; then
    exit 1
fi

# Determine repository if not already set
if [[ -z "$REPOSITORY" ]]; then
    echo "🔍 Auto-detecting repository..."
    
    # Try multiple detection methods in order of preference
    
    # 1. Try to detect from comments file metadata
    if REPOSITORY=$(detect_repo_from_comments_file "$COMMENTS_FILE"); then
        echo "📍 Repository detected from comments file: $REPOSITORY"
        
    # 2. Try to detect from git remote
    elif REPOSITORY=$(detect_repository_from_git); then
        echo "📍 Repository detected from git remote: $REPOSITORY"
        
    else
        echo "❌ Could not auto-detect repository. Please specify it manually:"
        echo ""
        echo "Usage examples:"
        echo "  $0 $PR_NUMBER $COMMENTS_FILE elementor/elementor"
        echo "  $0 $PR_NUMBER $COMMENTS_FILE pkp"
        echo "  $0 https://github.com/elementor/platform-kit-publisher/pull/$PR_NUMBER"
        echo ""
        echo "Available aliases: elementor, pkp, platform-kit, pro"
        exit 1
    fi
else
    # Repository was provided, try to resolve alias
    echo "📍 Using specified repository: $REPOSITORY"
    if resolved=$(resolve_repo_alias "$REPOSITORY"); then
        if [[ "$resolved" != "$REPOSITORY" ]]; then
            echo "📍 Resolved alias '$REPOSITORY' to: $resolved"
            REPOSITORY="$resolved"
        fi
    fi
fi

# Validate repository format
if [[ ! "$REPOSITORY" =~ ^[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+$ ]]; then
    echo "❌ Invalid repository format: $REPOSITORY"
    echo "   Expected format: owner/repository"
    exit 1
fi

# Validate repository access
echo "🔐 Validating repository access..."
if ! validate_repository "$REPOSITORY"; then
    echo "❌ Cannot access repository: $REPOSITORY"
    echo "   Please check:"
    echo "   - Repository name is correct"
    echo "   - You have access to the repository"
    echo "   - GitHub CLI is authenticated (gh auth login)"
    exit 1
fi

# Check required tools
for tool in gh jq; do
    if ! command -v "$tool" &> /dev/null; then
        echo "❌ $tool not found. Please install it first."
        case "$tool" in
            gh) echo "  https://cli.github.com/" ;;
            jq) echo "  https://stedolan.github.io/jq/" ;;
        esac
        exit 1
    fi
done

# Check GitHub authentication (prefer GITHUB_TOKEN)
if [[ -n "$GITHUB_TOKEN" ]]; then
    echo "🔐 Using GITHUB_TOKEN for authentication"
    export GH_TOKEN="$GITHUB_TOKEN"
elif ! gh auth status &> /dev/null; then
    echo "❌ GitHub authentication required. Either:"
    echo "  1. Set GITHUB_TOKEN environment variable:"
    echo "     export GITHUB_TOKEN='your_token_here'"
    echo "  2. Or authenticate with GitHub CLI:"
    echo "     gh auth login"
    exit 1
else
    echo "🔐 Using GitHub CLI authentication"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📝 GitHub PR Comments"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Repository:   ${REPOSITORY}"
echo "  PR Number:    #${PR_NUMBER}"
echo "  Comments:     ${COMMENTS_FILE}"
if [[ -n "$PR_URL" ]]; then
    echo "  PR URL:       ${PR_URL}"
fi
echo ""

# Count comments
COMMENT_COUNT=$(jq length "$COMMENTS_FILE")
echo "  📝 Found $COMMENT_COUNT comments to post"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

POSTED=0
FAILED=0

# Get the latest commit SHA for the PR
echo "🔍 Getting PR information..."
PR_INFO=$(gh api "repos/$REPOSITORY/pulls/$PR_NUMBER" 2>/dev/null)
if [[ -z "$PR_INFO" ]]; then
    echo "❌ Could not get PR information for #$PR_NUMBER in $REPOSITORY"
    echo "   Please check:"
    echo "   - PR number is correct"
    echo "   - PR exists and is accessible"
    echo "   - Repository name is correct"
    exit 1
fi

COMMIT_SHA=$(echo "$PR_INFO" | jq -r '.head.sha')
PR_STATE=$(echo "$PR_INFO" | jq -r '.state')

if [[ -z "$COMMIT_SHA" || "$COMMIT_SHA" = "null" ]]; then
    echo "❌ Could not get commit SHA for PR #$PR_NUMBER"
    exit 1
fi

echo "  Commit SHA:   $COMMIT_SHA"
echo "  PR State:     $PR_STATE"

if [[ "$PR_STATE" != "open" ]]; then
    echo "⚠️  Warning: PR is not open (state: $PR_STATE)"
    echo "   Comments may still be posted but won't trigger notifications."
fi

echo ""

# Process each comment
jq -c '.[]' "$COMMENTS_FILE" | while read -r comment; do
    FILE=$(echo "$comment" | jq -r '.file')
    LINE=$(echo "$comment" | jq -r '.line')
    BODY=$(echo "$comment" | jq -r '.body')
    SEVERITY=$(echo "$comment" | jq -r '.severity // "INFO"')
    
    # Check if it has a suggestion and determine type
    if echo "$BODY" | grep -q '```suggestion'; then
        local suggestion_lines=$(echo "$BODY" | sed -n '/```suggestion/,/```/p' | wc -l)
        if [[ $suggestion_lines -le 3 ]]; then
            HAS_SUGGESTION="✨"  # Single-line suggestion
        else
            HAS_SUGGESTION="✨📝"  # Multi-line suggestion
        fi
    else
        HAS_SUGGESTION=""
    fi
    
    echo "  ↳ $(basename "$FILE"):$LINE [$SEVERITY] $HAS_SUGGESTION"
    
    # Validate line number
    if ! [[ "$LINE" =~ ^[0-9]+$ ]] || [[ "$LINE" -lt 1 ]]; then
        echo "    ❌ Invalid line number: $LINE"
        FAILED=$((FAILED + 1))
        echo ""
        continue
    fi
    
    # Create payload for line-specific review comment
    # Use jq to properly handle JSON escaping and newlines
    PAYLOAD=$(echo "$comment" | jq \
        --arg commit_id "$COMMIT_SHA" \
        '{
            body: .body,
            commit_id: $commit_id,
            path: .file,
            line: (.line | tonumber),
            side: "RIGHT"
        }')
    
    # Post line-specific review comment using GitHub API
    if echo "$PAYLOAD" | gh api "repos/$REPOSITORY/pulls/$PR_NUMBER/comments" \
        --method POST \
        --input - > /dev/null 2>&1; then
        POSTED=$((POSTED + 1))
        echo "    ✅ Posted successfully"
    else
        FAILED=$((FAILED + 1))
        echo "    ❌ Failed to post"
        
        # Try to get more specific error information
        ERROR_RESPONSE=$(echo "$PAYLOAD" | gh api "repos/$REPOSITORY/pulls/$PR_NUMBER/comments" \
            --method POST \
            --input - 2>&1 || true)
        
        if echo "$ERROR_RESPONSE" | grep -q "pull request review"; then
            echo "       Hint: File may not exist in the PR diff"
        elif echo "$ERROR_RESPONSE" | grep -q "line.*out of range"; then
            echo "       Hint: Line number may be outside the diff range"
        elif echo "$ERROR_RESPONSE" | grep -q "permission"; then
            echo "       Hint: Check repository permissions"
        fi
    fi
    
    echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Summary:"
echo "  ✅ Posted: $POSTED"
echo "  ❌ Failed: $FAILED"
echo ""

if [[ $FAILED -eq 0 ]]; then
    echo "🎉 All comments posted successfully!"
else
    echo "⚠️  Some comments failed to post."
    echo "   Common causes:"
    echo "   - File not in PR diff"
    echo "   - Line number outside diff range"
    echo "   - Permission issues"
    echo "   - PR is closed/merged"
fi

echo ""
echo "🔗 View PR: https://github.com/$REPOSITORY/pull/$PR_NUMBER"
echo ""
