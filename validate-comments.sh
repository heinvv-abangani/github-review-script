#!/bin/bash
# GitHub Comments JSON Validator and Formatter
# Usage: ./validate-comments.sh [COMMENTS_FILE]

set -e

# Function to validate comment structure
validate_comment_structure() {
    local comment="$1"
    local index="$2"
    local errors=()
    
    # Check required fields
    local file=$(echo "$comment" | jq -r '.file // empty')
    local line=$(echo "$comment" | jq -r '.line // empty')
    local body=$(echo "$comment" | jq -r '.body // empty')
    
    if [[ -z "$file" ]]; then
        errors+=("Comment $index: Missing 'file' field")
    fi
    
    if [[ -z "$line" ]]; then
        errors+=("Comment $index: Missing 'line' field")
    elif ! [[ "$line" =~ ^[0-9]+$ ]] || [ "$line" -lt 1 ]; then
        errors+=("Comment $index: Invalid line number '$line' (must be positive integer)")
    fi
    
    if [[ -z "$body" ]]; then
        errors+=("Comment $index: Missing 'body' field")
    fi
    
    # Check body format
    if [[ -n "$body" ]]; then
        # Check for proper line breaks (should be \\n in JSON)
        if echo "$body" | grep -q '\n' && ! echo "$body" | grep -q '\\n'; then
            errors+=("Comment $index: Body contains unescaped newlines (use \\\\n in JSON)")
        fi
        
        # Check for suggestion format
        if echo "$body" | grep -q '```suggestion' && ! echo "$body" | grep -q '```suggestion\\n'; then
            errors+=("Comment $index: Suggestion block may have formatting issues")
        fi
        
        # Check if multi-line suggestion could be single-line
        if echo "$body" | grep -q '```suggestion'; then
            # Extract suggestion content, handling escaped newlines
            local suggestion_content=$(echo "$body" | sed 's/\\n/\n/g' | sed -n '/```suggestion/,/```/p' | sed '1d;$d')
            local suggestion_lines=$(echo "$suggestion_content" | wc -l)
            if [[ $suggestion_lines -gt 1 ]]; then
                # Check for common single-line patterns in the issue description
                if echo "$body" | grep -qE '(dependency.*check|missing.*check|condition|Plugin.*loads.*when|fatal.*error)'; then
                    # Check if it's primarily a condition change
                    if echo "$suggestion_content" | grep -qE '^if.*\(.*\).*{$'; then
                        errors+=("Comment $index: Multi-line suggestion for condition change - consider single-line fix adding dependency check")
                    else
                        errors+=("Comment $index: Consider single-line suggestion for simple fixes (condition/assignment/function call)")
                    fi
                fi
            fi
        fi
    fi
    
    # Check optional fields
    local severity=$(echo "$comment" | jq -r '.severity // empty')
    if [[ -n "$severity" ]]; then
        case "$severity" in
            CRITICAL|HIGH|MEDIUM|LOW|INFO) ;;
            *) errors+=("Comment $index: Invalid severity '$severity' (use: CRITICAL, HIGH, MEDIUM, LOW, INFO)") ;;
        esac
    fi
    
    # Print errors
    for error in "${errors[@]}"; do
        echo "❌ $error"
    done
    
    return ${#errors[@]}
}

# Function to fix common JSON issues
fix_json_formatting() {
    local input_file="$1"
    local output_file="$2"
    
    # Use jq to reformat and fix common issues
    jq '
        map(
            . as $comment |
            if .body then
                .body = (.body | 
                    # Fix unescaped newlines
                    gsub("\n"; "\\n") |
                    # Ensure proper suggestion formatting
                    gsub("```suggestion\n"; "```suggestion\\n") |
                    # Fix double escaping if present
                    gsub("\\\\n"; "\\n")
                )
            else . end |
            # Ensure line is a number
            if .line then .line = (.line | tonumber) else . end |
            # Add default severity if missing
            if .severity == null then .severity = "INFO" else . end
        )
    ' "$input_file" > "$output_file"
}

# Main script
COMMENTS_FILE="$1"

if [[ -z "$COMMENTS_FILE" ]]; then
    echo "Usage: $0 <comments-file.json>"
    echo ""
    echo "This script validates and optionally fixes GitHub PR comments JSON files."
    echo ""
    echo "Examples:"
    echo "  $0 PR-88-comments.json"
    echo "  $0 PR-88-comments.json --fix"
    exit 1
fi

if [[ ! -f "$COMMENTS_FILE" ]]; then
    echo "❌ File not found: $COMMENTS_FILE"
    exit 1
fi

echo "🔍 Validating: $COMMENTS_FILE"
echo ""

# Check if it's valid JSON
if ! jq empty "$COMMENTS_FILE" 2>/dev/null; then
    echo "❌ Invalid JSON format"
    echo "   Use a JSON validator to check syntax"
    exit 1
fi

# Check if it's an array
if [[ $(jq type "$COMMENTS_FILE") != '"array"' ]]; then
    echo "❌ JSON must contain an array of comments"
    exit 1
fi

# Get comment count
COMMENT_COUNT=$(jq length "$COMMENTS_FILE")
echo "📝 Found $COMMENT_COUNT comments"
echo ""

# Validate each comment
TOTAL_ERRORS=0
for i in $(seq 0 $((COMMENT_COUNT - 1))); do
    comment=$(jq ".[$i]" "$COMMENTS_FILE")
    validate_comment_structure "$comment" "$((i + 1))"
    TOTAL_ERRORS=$((TOTAL_ERRORS + $?))
done

echo ""

if [[ $TOTAL_ERRORS -eq 0 ]]; then
    echo "✅ All comments are valid!"
    
    # Show summary
    echo ""
    echo "📊 Summary:"
    jq -r '
        group_by(.severity // "INFO") | 
        map({
            severity: (.[0].severity // "INFO"),
            count: length
        }) |
        sort_by(.severity) |
        .[] |
        "  \(.severity): \(.count)"
    ' "$COMMENTS_FILE"
    
else
    echo "❌ Found $TOTAL_ERRORS validation errors"
    
    # Offer to fix if --fix flag is provided
    if [[ "$2" == "--fix" ]]; then
        echo ""
        echo "🔧 Attempting to fix common issues..."
        
        BACKUP_FILE="${COMMENTS_FILE}.backup.$(date +%s)"
        cp "$COMMENTS_FILE" "$BACKUP_FILE"
        echo "   Backup created: $BACKUP_FILE"
        
        fix_json_formatting "$COMMENTS_FILE" "${COMMENTS_FILE}.fixed"
        mv "${COMMENTS_FILE}.fixed" "$COMMENTS_FILE"
        
        echo "   Fixed file saved as: $COMMENTS_FILE"
        echo ""
        echo "🔍 Re-validating fixed file..."
        
        # Re-validate
        exec "$0" "$COMMENTS_FILE"
    else
        echo ""
        echo "💡 To automatically fix common issues, run:"
        echo "   $0 $COMMENTS_FILE --fix"
    fi
    
    exit 1
fi
