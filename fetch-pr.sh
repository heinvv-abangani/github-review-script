#!/bin/bash
# GitHub PR Content Fetcher
# Usage: ./fetch-pr.sh <PR_URL> [OUTPUT_DIR]
# Fetches PR details, diff, and files for easy review

set -e

# Function to extract repository from PR URL
extract_repo_from_url() {
    local url="$1"
    
    if [[ "$url" =~ github\.com/([^/]+)/([^/]+)/pull/([0-9]+) ]]; then
        local owner="${BASH_REMATCH[1]}"
        local repo="${BASH_REMATCH[2]}"
        local pr_number="${BASH_REMATCH[3]}"
        
        echo "${owner}/${repo}:${pr_number}"
        return 0
    fi
    
    return 1
}

# Function to setup GitHub authentication
setup_github_auth() {
    # Prefer GITHUB_TOKEN over GitHub CLI
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
        return 1
    fi
}

# Function to fetch PR information
fetch_pr_info() {
    local repository="$1"
    local pr_number="$2"
    local output_file="$3"
    
    echo "📋 Fetching PR information..."
    
    local pr_info
    if ! pr_info=$(gh api "repos/$repository/pulls/$pr_number" 2>/dev/null); then
        echo "❌ Failed to fetch PR information"
        return 1
    fi
    
    # Save raw PR info
    echo "$pr_info" > "$output_file"
    
    # Extract key information
    local title=$(echo "$pr_info" | jq -r '.title')
    local state=$(echo "$pr_info" | jq -r '.state')
    local author=$(echo "$pr_info" | jq -r '.user.login')
    local created_at=$(echo "$pr_info" | jq -r '.created_at')
    local updated_at=$(echo "$pr_info" | jq -r '.updated_at')
    local additions=$(echo "$pr_info" | jq -r '.additions')
    local deletions=$(echo "$pr_info" | jq -r '.deletions')
    local changed_files=$(echo "$pr_info" | jq -r '.changed_files')
    
    echo "  Title: $title"
    echo "  State: $state"
    echo "  Author: $author"
    echo "  Created: $created_at"
    echo "  Updated: $updated_at"
    echo "  Changes: +$additions -$deletions ($changed_files files)"
    
    return 0
}

# Function to fetch PR diff
fetch_pr_diff() {
    local repository="$1"
    local pr_number="$2"
    local output_file="$3"
    
    echo "📄 Fetching PR diff..."
    
    # Fetch diff using GitHub API
    if gh api "repos/$repository/pulls/$pr_number" \
        --header "Accept: application/vnd.github.v3.diff" \
        > "$output_file" 2>/dev/null; then
        
        local diff_size=$(wc -l < "$output_file")
        echo "  Diff saved: $output_file ($diff_size lines)"
        return 0
    else
        echo "❌ Failed to fetch PR diff"
        return 1
    fi
}

# Function to fetch changed files list
fetch_pr_files() {
    local repository="$1"
    local pr_number="$2"
    local output_file="$3"
    
    echo "📁 Fetching changed files..."
    
    local files_info
    if ! files_info=$(gh api "repos/$repository/pulls/$pr_number/files" 2>/dev/null); then
        echo "❌ Failed to fetch changed files"
        return 1
    fi
    
    # Save raw files info
    echo "$files_info" > "$output_file"
    
    # Extract and display file list
    local file_list=$(echo "$files_info" | jq -r '.[] | "\(.status): \(.filename) (+\(.additions) -\(.deletions))"')
    echo "  Files changed:"
    echo "$file_list" | sed 's/^/    /'
    
    return 0
}

# Function to fetch specific file content
fetch_file_content() {
    local repository="$1"
    local pr_number="$2"
    local file_path="$3"
    local output_dir="$4"
    
    # Get the commit SHA from PR
    local commit_sha=$(gh api "repos/$repository/pulls/$pr_number" --jq '.head.sha' 2>/dev/null)
    if [[ -z "$commit_sha" ]]; then
        echo "❌ Could not get commit SHA"
        return 1
    fi
    
    # Create directory structure
    local file_dir="$output_dir/files/$(dirname "$file_path")"
    mkdir -p "$file_dir"
    
    # Fetch file content
    local output_file="$output_dir/files/$file_path"
    if gh api "repos/$repository/contents/$file_path" \
        --field ref="$commit_sha" \
        --jq '.content' 2>/dev/null | base64 -d > "$output_file"; then
        echo "  ✅ $file_path"
        return 0
    else
        echo "  ❌ Failed to fetch: $file_path"
        return 1
    fi
}

# Function to create review summary
create_review_summary() {
    local pr_url="$1"
    local repository="$2"
    local pr_number="$3"
    local output_dir="$4"
    
    local summary_file="$output_dir/REVIEW-SUMMARY.md"
    
    cat > "$summary_file" << EOF
# PR Review Summary

## PR Information
- **URL**: $pr_url
- **Repository**: $repository
- **PR Number**: #$pr_number
- **Fetched**: $(date)

## Files Generated
- \`pr-info.json\` - Complete PR information from GitHub API
- \`pr-diff.patch\` - Full diff of all changes
- \`pr-files.json\` - Detailed information about changed files
- \`files/\` - Directory containing actual file contents from the PR
- \`REVIEW-SUMMARY.md\` - This summary file

## Quick Review Commands

### View PR Information
\`\`\`bash
jq . pr-info.json | less
\`\`\`

### View Diff
\`\`\`bash
less pr-diff.patch
# or with syntax highlighting
bat pr-diff.patch
\`\`\`

### List Changed Files
\`\`\`bash
jq -r '.[] | "\\(.status): \\(.filename) (+\\(.additions) -\\(.deletions))"' pr-files.json
\`\`\`

### Generate Review Comments
\`\`\`bash
# Go back to github-review-script directory
cd ../github-review-script

# Generate review using the fetched data
./review.sh $pr_url

# Post comments
./post-comments.sh $pr_url
\`\`\`

## Review Checklist
- [ ] Check PR description and purpose
- [ ] Review code changes for quality and standards
- [ ] Verify security implications
- [ ] Check for breaking changes
- [ ] Validate test coverage
- [ ] Review documentation updates
- [ ] Check for performance implications

EOF

    echo "📋 Review summary created: $summary_file"
}

# Main script
PR_URL="$1"
OUTPUT_DIR="${2:-../pr-reviews}"

if [[ -z "$PR_URL" ]]; then
    echo "Usage: $0 <PR_URL> [OUTPUT_DIR]"
    echo ""
    echo "Examples:"
    echo "  $0 https://github.com/elementor/platform-kit-publisher/pull/88"
    echo "  $0 https://github.com/elementor/elementor/pull/12345 ./review-data"
    echo ""
    echo "This script fetches complete PR information for easy review:"
    echo "  - PR metadata and information"
    echo "  - Complete diff of all changes"
    echo "  - List of changed files with details"
    echo "  - Actual file contents from the PR"
    echo "  - Review summary with helpful commands"
    exit 1
fi

# Extract repository and PR number from URL
if ! repo_info=$(extract_repo_from_url "$PR_URL"); then
    echo "❌ Invalid PR URL format"
    echo "Expected: https://github.com/OWNER/REPO/pull/NUMBER"
    exit 1
fi

IFS=':' read -r repository pr_number <<< "$repo_info"

# Setup authentication
if ! setup_github_auth; then
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

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📥 GitHub PR Content Fetcher"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  PR URL:       $PR_URL"
echo "  Repository:   $repository"
echo "  PR Number:    #$pr_number"
echo "  Output Dir:   $OUTPUT_DIR"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

# Create PR-specific directory
PR_DIR="PR-${pr_number}-$(date +%Y%m%d)"
mkdir -p "$PR_DIR"
cd "$PR_DIR"

echo "📁 Working in: $(pwd)"
echo ""

# Fetch PR information
if ! fetch_pr_info "$repository" "$pr_number" "pr-info.json"; then
    exit 1
fi
echo ""

# Fetch PR diff
if ! fetch_pr_diff "$repository" "$pr_number" "pr-diff.patch"; then
    exit 1
fi
echo ""

# Fetch changed files information
if ! fetch_pr_files "$repository" "$pr_number" "pr-files.json"; then
    exit 1
fi
echo ""

# Fetch individual file contents
echo "📥 Fetching file contents..."
mkdir -p "files"

# Get list of changed files
changed_files=$(jq -r '.[].filename' pr-files.json 2>/dev/null)
if [[ -n "$changed_files" ]]; then
    echo "$changed_files" | while read -r file_path; do
        if [[ -n "$file_path" ]]; then
            fetch_file_content "$repository" "$pr_number" "$file_path" "."
        fi
    done
else
    echo "  ⚠️  No files to fetch"
fi
echo ""

# Create review summary
create_review_summary "$PR_URL" "$repository" "$pr_number" "."
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🎉 PR content fetched successfully!"
echo ""
echo "📁 Review data saved to: $(pwd)"
echo ""
echo "📋 Next steps:"
echo "  1. Review the files and diff"
echo "  2. Run: ../../github-review-script/review.sh $PR_URL"
echo "  3. Run: ../../github-review-script/post-comments.sh $PR_URL"
echo ""
echo "🔗 View PR: $PR_URL"
echo ""
