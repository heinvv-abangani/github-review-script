#!/bin/bash
# Complete GitHub PR Review Workflow
# Usage: ./review-workflow.sh <PR_URL> [--fetch-only|--review-only|--post-only]
# Handles the complete workflow: fetch → review → validate → post

set -e

# Function to setup GitHub authentication
setup_github_auth() {
    # Always prefer GITHUB_TOKEN
    if [[ -n "$GITHUB_TOKEN" ]]; then
        echo "🔐 Using GITHUB_TOKEN for authentication"
        export GH_TOKEN="$GITHUB_TOKEN"
        return 0
    elif gh auth status &> /dev/null 2>&1; then
        echo "🔐 Using GitHub CLI authentication"
        return 0
    else
        echo "❌ GitHub authentication required. Either:"
        echo "  1. Set GITHUB_TOKEN environment variable:"
        echo "     export GITHUB_TOKEN='your_token_here'"
        echo "  2. Or authenticate with GitHub CLI:"
        echo "     gh auth login"
        echo ""
        echo "💡 GITHUB_TOKEN is preferred for CI/CD and automation"
        return 1
    fi
}

# Function to extract PR info from URL
extract_pr_info() {
    local url="$1"
    
    if [[ "$url" =~ github\.com/([^/]+)/([^/]+)/pull/([0-9]+) ]]; then
        echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}:${BASH_REMATCH[3]}"
        return 0
    fi
    
    return 1
}

# Function to check if PR data exists
check_pr_data_exists() {
    local pr_number="$1"
    local pr_reviews_dir="../pr-reviews"
    
    # Check for existing PR data directory
    local pr_dirs=$(find "$pr_reviews_dir" -maxdepth 1 -name "PR-${pr_number}-*" -type d 2>/dev/null | head -1)
    if [[ -n "$pr_dirs" ]]; then
        echo "$pr_dirs"
        return 0
    fi
    
    return 1
}

# Function to run fetch step
run_fetch() {
    local pr_url="$1"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  📥 Step 1: Fetching PR Content"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if ! ./fetch-pr.sh "$pr_url"; then
        echo "❌ Failed to fetch PR content"
        return 1
    fi
    
    echo "✅ PR content fetched successfully"
    return 0
}

# Function to run review step
run_review() {
    local pr_url="$1"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  📝 Step 2: Generating Review"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if ! ./review.sh "$pr_url"; then
        echo "❌ Failed to generate review"
        return 1
    fi
    
    echo "✅ Review generated successfully"
    return 0
}

# Function to run validation step
run_validation() {
    local pr_number="$1"
    local comments_file="../pr-reviews/PR-${pr_number}-comments.json"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ✅ Step 3: Validating Comments"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if [[ ! -f "$comments_file" ]]; then
        echo "⚠️  No comments file found: $comments_file"
        echo "   This might be normal if no issues were found"
        return 0
    fi
    
    echo "🔍 Validating comments file..."
    if ! ./validate-comments.sh "$comments_file"; then
        echo "❌ Comments validation failed"
        echo ""
        echo "💡 Try auto-fixing:"
        echo "   ./validate-comments.sh $comments_file --fix"
        return 1
    fi
    
    echo "✅ Comments validated successfully"
    return 0
}

# Function to run posting step
run_posting() {
    local pr_url="$1"
    local pr_number="$2"
    local comments_file="../pr-reviews/PR-${pr_number}-comments.json"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  📤 Step 4: Posting Comments"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if [[ ! -f "$comments_file" ]]; then
        echo "ℹ️  No comments to post - no issues found!"
        echo "   This is good news! The PR looks clean."
        return 0
    fi
    
    local comment_count=$(jq length "$comments_file" 2>/dev/null || echo "0")
    if [[ "$comment_count" == "0" ]]; then
        echo "ℹ️  No comments to post - empty comments file"
        return 0
    fi
    
    echo "📝 Found $comment_count comments to post"
    echo ""
    
    # Ask for confirmation before posting
    read -p "🤔 Do you want to post these comments to the PR? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "⏸️  Posting cancelled by user"
        echo "   You can post later with: ./post-comments.sh $pr_url"
        return 0
    fi
    
    if ! ./post-comments.sh "$pr_url"; then
        echo "❌ Failed to post comments"
        return 1
    fi
    
    echo "✅ Comments posted successfully"
    return 0
}

# Main script
PR_URL="$1"
MODE="${2:-full}"

if [[ -z "$PR_URL" ]]; then
    echo "Usage: $0 <PR_URL> [--fetch-only|--review-only|--post-only]"
    echo ""
    echo "Complete workflow (recommended):"
    echo "  $0 https://github.com/elementor/platform-kit-publisher/pull/88"
    echo ""
    echo "Individual steps:"
    echo "  $0 https://github.com/elementor/platform-kit-publisher/pull/88 --fetch-only"
    echo "  $0 https://github.com/elementor/platform-kit-publisher/pull/88 --review-only"
    echo "  $0 https://github.com/elementor/platform-kit-publisher/pull/88 --post-only"
    echo ""
    echo "This script handles the complete PR review workflow:"
    echo "  1. 📥 Fetch PR content (diff, files, metadata)"
    echo "  2. 📝 Generate review and comments"
    echo "  3. ✅ Validate comment format"
    echo "  4. 📤 Post comments to GitHub"
    exit 1
fi

# Extract PR information
if ! pr_info=$(extract_pr_info "$PR_URL"); then
    echo "❌ Invalid PR URL format"
    echo "Expected: https://github.com/OWNER/REPO/pull/NUMBER"
    exit 1
fi

IFS=':' read -r repository pr_number <<< "$pr_info"

# Setup authentication
if ! setup_github_auth; then
    exit 1
fi

# Check required tools
missing_tools=()
for tool in gh jq; do
    if ! command -v "$tool" &> /dev/null; then
        missing_tools+=("$tool")
    fi
done

if [[ ${#missing_tools[@]} -gt 0 ]]; then
    echo "❌ Missing required tools: ${missing_tools[*]}"
    echo ""
    for tool in "${missing_tools[@]}"; do
        case "$tool" in
            gh) echo "  Install GitHub CLI: https://cli.github.com/" ;;
            jq) echo "  Install jq: https://stedolan.github.io/jq/" ;;
        esac
    done
    exit 1
fi

echo "🚀 GitHub PR Review Workflow"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  PR URL:       $PR_URL"
echo "  Repository:   $repository"
echo "  PR Number:    #$pr_number"
echo "  Mode:         $MODE"
echo ""

# Execute based on mode
case "$MODE" in
    "--fetch-only")
        run_fetch "$PR_URL"
        ;;
    "--review-only")
        run_review "$PR_URL"
        ;;
    "--post-only")
        run_posting "$PR_URL" "$pr_number"
        ;;
    *)
        # Full workflow
        echo "🔄 Running complete review workflow..."
        echo ""
        
        # Step 1: Fetch (skip if data already exists)
        if existing_data=$(check_pr_data_exists "$pr_number"); then
            echo "ℹ️  PR data already exists: $existing_data"
            echo "   Skipping fetch step (use --fetch-only to re-fetch)"
        else
            if ! run_fetch "$PR_URL"; then
                exit 1
            fi
        fi
        echo ""
        
        # Step 2: Review
        if ! run_review "$PR_URL"; then
            exit 1
        fi
        echo ""
        
        # Step 3: Validate
        if ! run_validation "$pr_number"; then
            exit 1
        fi
        echo ""
        
        # Step 4: Post (with confirmation)
        if ! run_posting "$PR_URL" "$pr_number"; then
            exit 1
        fi
        ;;
esac

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🎉 Workflow completed successfully!"
echo ""
echo "📁 Review files location: ../pr-reviews/"
echo "🔗 View PR: $PR_URL"
echo ""
