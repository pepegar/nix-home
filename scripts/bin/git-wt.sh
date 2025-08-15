#!/usr/bin/env bash

# Debug flag
DEBUG=0

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --debug)
            DEBUG=1
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--debug]"
            echo "Interactive git worktree switcher with fzf"
            echo ""
            echo "Key bindings:"
            echo "  Enter    - Switch to selected worktree"
            echo "  Ctrl-D   - Delete selected worktree"
            echo "  Esc      - Cancel"
            echo ""
            echo "Output: Prints target directory path to stdout"
            echo ""
            echo "Usage examples:"
            echo "  cd \$(git-wt)                    # Switch to selected worktree"
            echo "  alias gwt='cd \$(git-wt)'       # Create convenient alias"
            echo ""
            echo "Suggested shell function:"
            echo "  gwt() { cd \$(git-wt \"\$@\"); }  # Add to your shell config"
            exit 0
            ;;
        *)
            echo "Unknown parameter: $1"
            echo "Usage: $0 [--debug] [-h|--help]"
            exit 1
            ;;
    esac
done

# Debug echo function
debug_echo() {
    if [[ $DEBUG -eq 1 ]]; then
        echo "🤖 $1" >&2
    fi
}

# Command logging function
log_command() {
    if [[ $DEBUG -eq 1 ]]; then
        echo "🖥️ Command: $1" >&2
    fi
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not in a git repository" >&2
    exit 1
fi

# Get current worktree path
current_worktree=$(git rev-parse --show-toplevel)
debug_echo "Current worktree: $current_worktree"

# Function to get worktree list with formatting
get_worktree_list() {
    debug_echo "Getting worktree list"
    log_command "git worktree list --porcelain"
    
    git worktree list --porcelain | awk '
    BEGIN { 
        worktree = ""
        branch = ""
        current = ""
        # ANSI color codes
        GREEN = "\033[32m"
        BLUE = "\033[34m"
        YELLOW = "\033[33m"
        GRAY = "\033[90m"
        RESET = "\033[0m"
        BOLD = "\033[1m"
    }
    /^worktree / { 
        worktree = substr($0, 10)  # Remove "worktree "
    }
    /^branch / { 
        branch = substr($0, 8)     # Remove "branch "
        # Remove refs/heads/ prefix if present
        gsub(/^refs\/heads\//, "", branch)
    }
    /^HEAD / {
        branch = substr($0, 5)     # Remove "HEAD "
    }
    /^bare$/ {
        branch = "(bare)"
    }
    /^$/ { 
        if (worktree != "") {
            # Compress home directory for display only
            display_path = worktree
            gsub(/^\/Users\/[^\/]+/, "~", display_path)
            
            # Check if this is the current worktree
            is_current = (worktree == "'"$current_worktree"'")
            
            # Format the line with colors, but store original path in a hidden way
            if (is_current) {
                printf "📍 " BOLD YELLOW "%-30s" RESET " " GRAY "%s" RESET " " YELLOW "(current)" RESET "|%s\n", branch, display_path, worktree
            } else {
                printf "🌿 " BOLD GREEN "%-30s" RESET " " BLUE "%s" RESET "|%s\n", branch, display_path, worktree
            }
        }
        worktree = ""
        branch = ""
    }
    END {
        # Handle last entry if file doesn'\''t end with blank line
        if (worktree != "") {
            display_path = worktree
            gsub(/^\/Users\/[^\/]+/, "~", display_path)
            is_current = (worktree == "'"$current_worktree"'")
            if (is_current) {
                printf "📍 " BOLD YELLOW "%-30s" RESET " " GRAY "%s" RESET " " YELLOW "(current)" RESET "|%s\n", branch, display_path, worktree
            } else {
                printf "🌿 " BOLD GREEN "%-30s" RESET " " BLUE "%s" RESET "|%s\n", branch, display_path, worktree
            }
        }
    }'
}

# Function to get full worktree path from formatted line
get_worktree_path_from_line() {
    local line="$1"
    debug_echo "Extracting path from: $line"
    
    # Extract the original path stored after the | delimiter
    local path=$(echo "$line" | sed 's/.*|//')
    debug_echo "Extracted original path: $path"
    
    echo "$path"
}

# Function to get branch name from formatted line
get_branch_from_line() {
    local line="$1"
    # Strip ANSI color codes first, then extract branch name
    local clean_line=$(echo "$line" | sed 's/\x1b\[[0-9;]*m//g')
    echo "$clean_line" | sed -E 's/^[📍🌿] ([^ ]+).*/\1/'
}


# Function to safely delete worktree
delete_worktree() {
    local line="$1"
    local path=$(get_worktree_path_from_line "$line")
    local branch=$(get_branch_from_line "$line")
    
    debug_echo "Delete request for: $path (branch: $branch)"
    
    # Safety checks
    if [[ "$path" == "$current_worktree" ]]; then
        echo "❌ Cannot delete current worktree" >&2
        return 1
    fi
    
    if [[ "$branch" == "main" || "$branch" == "master" || "$branch" == "develop" ]]; then
        echo "❌ Cannot delete protected branch: $branch" >&2
        return 1
    fi
    
    # Confirmation
    echo "⚠️  About to delete:" >&2
    echo "   Branch: $branch" >&2
    echo "   Path: $path" >&2
    echo -n "   Are you sure? [y/N] " >&2
    
    local response
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        debug_echo "User confirmed deletion"
        log_command "git worktree remove \"$path\""
        
        if git worktree remove "$path" 2>/dev/null; then
            echo "✅ Deleted worktree: $branch" >&2
            return 0
        else
            echo "❌ Failed to delete worktree. You may need to force removal." >&2
            echo "   Try: git worktree remove --force \"$path\"" >&2
            return 1
        fi
    else
        echo "❌ Deletion cancelled" >&2
        return 1
    fi
}

# Create a delete script that fzf can execute
create_delete_script() {
    local script_path="/tmp/git-wt-delete-$$"
    cat > "$script_path" << EOF
#!/bin/bash

current_worktree="$current_worktree"

# Function to get full worktree path from formatted line
get_worktree_path_from_line() {
    local line="\$1"
    # Extract the original path stored after the | delimiter
    local path=\$(echo "\$line" | sed 's/.*|//')
    echo "\$path"
}

# Function to get branch name from formatted line
get_branch_from_line() {
    local line="\$1"
    # Strip ANSI color codes first, then extract branch name
    local clean_line=\$(echo "\$line" | sed 's/\x1b\[[0-9;]*m//g')
    echo "\$clean_line" | sed -E 's/^[📍🌿] ([^ ]+).*/\1/'
}

line="\$1"
path=\$(get_worktree_path_from_line "\$line")
branch=\$(get_branch_from_line "\$line")

# Safety checks
if [[ "\$path" == "\$current_worktree" ]]; then
    echo "❌ Cannot delete current worktree" >&2
    read -p "Press Enter to continue..."
    exit 1
fi

if [[ "\$branch" == "main" || "\$branch" == "master" || "\$branch" == "develop" ]]; then
    echo "❌ Cannot delete protected branch: \$branch" >&2
    read -p "Press Enter to continue..."
    exit 1
fi

# Confirmation
clear
echo "⚠️  About to delete:"
echo "   Branch: \$branch"
echo "   Path: \$path"
echo -n "   Are you sure? [y/N] "

read -r response

if [[ "\$response" =~ ^[Yy]\$ ]]; then
    if git worktree remove "\$path" 2>/dev/null; then
        echo "✅ Deleted worktree: \$branch"
    else
        echo "❌ Failed to delete worktree. You may need to force removal."
        echo "   Try: git worktree remove --force \"\$path\""
    fi
else
    echo "❌ Deletion cancelled"
fi

read -p "Press Enter to continue..."
EOF
    chmod +x "$script_path"
    echo "$script_path"
}

# Get worktree list
worktree_list=$(get_worktree_list)

if [[ -z "$worktree_list" ]]; then
    echo "No worktrees found" >&2
    exit 1
fi

debug_echo "Launching fzf selector"

# Create delete script
delete_script=$(create_delete_script)

# Cleanup function
cleanup() {
    rm -f "$delete_script" 2>/dev/null
}
trap cleanup EXIT

# Use fzf to select worktree with delete functionality
selected=$(echo "$worktree_list" | fzf \
    --ansi \
    --height=40% \
    --layout=reverse \
    --border=rounded \
    --header="🌿 Git Worktree Switcher | Enter: switch, Ctrl-D: delete, Esc: cancel" \
    --bind="ctrl-d:execute($delete_script {})+reload(git worktree list --porcelain | awk '
    BEGIN { 
        worktree = \"\"
        branch = \"\"
        current = \"\"
        # ANSI color codes
        GREEN = \"\\033[32m\"
        BLUE = \"\\033[34m\"
        YELLOW = \"\\033[33m\"
        GRAY = \"\\033[90m\"
        RESET = \"\\033[0m\"
        BOLD = \"\\033[1m\"
    }
    /^worktree / { 
        worktree = substr(\$0, 10)
    }
    /^branch / { 
        branch = substr(\$0, 8)
        gsub(/^refs\/heads\//, \"\", branch)
    }
    /^HEAD / {
        branch = substr(\$0, 5)
    }
    /^bare\$/ {
        branch = \"(bare)\"
    }
    /^\$/ { 
        if (worktree != \"\") {
            display_path = worktree
            gsub(/^\/Users\/[^\/]+/, \"~\", display_path)
            is_current = (worktree == \"'$current_worktree'\")
            if (is_current) {
                printf \"📍 \" BOLD YELLOW \"%-30s\" RESET \" \" GRAY \"%s\" RESET \" \" YELLOW \"(current)\" RESET \"|%s\\n\", branch, display_path, worktree
            } else {
                printf \"🌿 \" BOLD GREEN \"%-30s\" RESET \" \" BLUE \"%s\" RESET \"|%s\\n\", branch, display_path, worktree
            }
        }
        worktree = \"\"
        branch = \"\"
    }
    END {
        if (worktree != \"\") {
            display_path = worktree
            gsub(/^\/Users\/[^\/]+/, \"~\", display_path)
            is_current = (worktree == \"'$current_worktree'\")
            if (is_current) {
                printf \"📍 \" BOLD YELLOW \"%-30s\" RESET \" \" GRAY \"%s\" RESET \" \" YELLOW \"(current)\" RESET \"|%s\\n\", branch, display_path, worktree
            } else {
                printf \"🌿 \" BOLD GREEN \"%-30s\" RESET \" \" BLUE \"%s\" RESET \"|%s\\n\", branch, display_path, worktree
            }
        }
    }')")

# Handle selection
if [[ -z "$selected" ]]; then
    debug_echo "No selection made, returning current directory"
    echo "$current_worktree"
    exit 0
fi

target_path=$(get_worktree_path_from_line "$selected")

if [[ ! -d "$target_path" ]]; then
    echo "Error: Target worktree path does not exist: $target_path" >&2
    echo "$current_worktree"
    exit 1
fi

debug_echo "Selected worktree: $target_path"

# Output the target path for cd usage
echo "$target_path"