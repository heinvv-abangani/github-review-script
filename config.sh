#!/bin/bash
# GitHub Review Script Configuration
# Source this file to set default repositories and options

# Default repositories for auto-detection fallback
DEFAULT_REPOSITORIES=(
    "elementor/elementor"
    "elementor/platform-kit-publisher"
    "elementor/elementor-pro"
)

# Repository aliases (compatible with older bash versions)
REPO_ALIASES_LIST="
elementor:elementor/elementor
pkp:elementor/platform-kit-publisher
pro:elementor/elementor-pro
platform-kit:elementor/platform-kit-publisher
"

# Default settings
DEFAULT_PR_REVIEWS_DIR="../pr-reviews"
DEFAULT_TIMEOUT=30
VERBOSE_MODE=false

# Function to resolve repository alias
resolve_repo_alias() {
    local input="$1"
    
    # Check if it's an alias using grep
    local resolved=$(echo "$REPO_ALIASES_LIST" | grep "^${input}:" | cut -d: -f2)
    if [[ -n "$resolved" ]]; then
        echo "$resolved"
        return 0
    fi
    
    # Check if it's already a full repo name
    if [[ "$input" =~ ^[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+$ ]]; then
        echo "$input"
        return 0
    fi
    
    # Not found
    return 1
}

# Function to list available aliases
list_repo_aliases() {
    echo "Available repository aliases:"
    echo "$REPO_ALIASES_LIST" | grep ":" | while IFS=: read -r alias repo; do
        if [[ -n "$alias" && -n "$repo" ]]; then
            echo "  $alias -> $repo"
        fi
    done
}

# Export functions for use in other scripts
export -f resolve_repo_alias
export -f list_repo_aliases
