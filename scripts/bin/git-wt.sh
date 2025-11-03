#!/usr/bin/env bash

# Debug flag
DEBUG=0
CREATE_MODE=0

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --debug)
            DEBUG=1
            shift
            ;;
        --create)
            CREATE_MODE=1
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--debug] [--create]"
            echo "Interactive git worktree switcher and creator with fzf"
            echo ""
            echo "Default mode (no --create):"
            echo "  Key bindings:"
            echo "    Enter    - Switch to selected worktree"
            echo "    Ctrl-D   - Delete selected worktree"
            echo "    Esc      - Cancel"
            echo ""
            echo "Create mode (--create):"
            echo "  Interactive branch selection to create new worktree"
            echo "  Location: .worktrees/<branch_name>"
            echo "  Shows all local and remote branches"
            echo ""
            echo "Output: Prints target directory path to stdout"
            echo ""
            echo "Usage examples:"
            echo "  cd \$(git-wt)                    # Switch to selected worktree"
            echo "  cd \$(git-wt --create)          # Create worktree from branch"
            echo "  alias gwt='cd \$(git-wt)'       # Create convenient alias"
            echo ""
            echo "Suggested shell function:"
            echo "  gwt() { cd \$(git-wt \"\$@\"); }  # Add to your shell config"
            exit 0
            ;;
        *)
            echo "Unknown parameter: $1"
            echo "Usage: $0 [--debug] [--create] [-h|--help]"
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

# Function to check if branch exists (local or remote)
branch_exists() {
    local branch_name="$1"
    debug_echo "Checking if branch exists: $branch_name"
    
    # Check if branch exists locally
    if git show-ref --verify --quiet "refs/heads/$branch_name"; then
        debug_echo "Branch exists locally: $branch_name"
        return 0
    fi
    
    # Check if branch exists on remote
    if git show-ref --verify --quiet "refs/remotes/origin/$branch_name"; then
        debug_echo "Branch exists on remote: $branch_name"
        return 0
    fi
    
    debug_echo "Branch does not exist: $branch_name"
    return 1
}

# Function to get repository name
get_repo_name() {
    local repo_path=$(git rev-parse --show-toplevel)
    basename "$repo_path"
}

# Function to create worktree for branch
create_worktree() {
    local branch_name="$1"
    local git_root=$(git rev-parse --show-toplevel)
    local worktree_path="$git_root/.worktrees/${branch_name}"
    
    debug_echo "Creating worktree for branch: $branch_name"
    debug_echo "Repository name: $repo_name"
    debug_echo "Target path: $worktree_path"
    
    # Check if branch exists
    if ! branch_exists "$branch_name"; then
        echo "❌ Branch '$branch_name' does not exist locally or on remote" >&2
        echo "💡 Available branches:" >&2
        git branch -a | head -10 >&2
        return 1
    fi
    
    # Check if worktree path already exists
    if [[ -d "$worktree_path" ]]; then
        echo "❌ Worktree path already exists: $worktree_path" >&2
        return 1
    fi
    
    # Check if worktree for this branch already exists
    if git worktree list | grep -q "\\[$branch_name\\]"; then
        echo "❌ Worktree for branch '$branch_name' already exists" >&2
        git worktree list | grep "\\[$branch_name\\]" >&2
        return 1
    fi
    
    # Create the worktree
    log_command "git worktree add \"$worktree_path\" \"$branch_name\""
    
    if git worktree add "$worktree_path" "$branch_name" 2>/dev/null; then
        echo "✅ Created worktree for branch '$branch_name' at: $worktree_path" >&2
        # Convert to absolute path for output
        echo "$(cd "$worktree_path" && pwd)"
        return 0
    else
        echo "❌ Failed to create worktree for branch '$branch_name'" >&2
        
        # Try to create from remote branch if local doesn't exist
        if git show-ref --verify --quiet "refs/remotes/origin/$branch_name"; then
            echo "🔄 Trying to create from remote branch..." >&2
            log_command "git worktree add \"$worktree_path\" \"origin/$branch_name\" -b \"$branch_name\""
            
            if git worktree add "$worktree_path" "origin/$branch_name" -b "$branch_name" 2>/dev/null; then
                echo "✅ Created worktree for remote branch '$branch_name' at: $worktree_path" >&2
                echo "$(cd "$worktree_path" && pwd)"
                return 0
            fi
        fi
        
        return 1
    fi
}

# Function to get formatted branch list for creation
get_branch_list() {
    debug_echo "Getting branch list for creation"
    
    # Get all branches (local and remote) but exclude HEAD and current branch pointers
    git for-each-ref --format='%(refname:short)|%(authordate:relative)|%(subject)' refs/heads refs/remotes | \
    grep -v '^origin/HEAD' | \
    awk -F'|' '
    BEGIN { 
        # ANSI color codes
        GREEN = "\033[32m"
        BLUE = "\033[34m"  
        YELLOW = "\033[33m"
        GRAY = "\033[90m"
        RESET = "\033[0m"
        BOLD = "\033[1m"
    }
    {
        branch = $1
        date = $2
        subject = $3
        
        # Remove origin/ prefix for display but keep for identification
        display_branch = branch
        gsub(/^origin\//, "", display_branch)
        
        # Skip if this branch already has a worktree
        cmd = "git worktree list | grep -q \"\\[" display_branch "\\]\""
        has_worktree = (system(cmd) == 0)
        
        if (has_worktree) {
            printf "⏭️  " GRAY "%-30s" RESET " " GRAY "%s" RESET " " GRAY "(worktree exists)" RESET "|%s\n", display_branch, date, branch
        } else if (index(branch, "origin/") == 1) {
            # Remote branch
            printf "🌐 " BOLD BLUE "%-30s" RESET " " GRAY "%s" RESET "|%s\n", display_branch, date, branch
        } else {
            # Local branch  
            printf "🌿 " BOLD GREEN "%-30s" RESET " " GRAY "%s" RESET "|%s\n", display_branch, date, branch
        }
    }'
}

# Function to extract branch name from formatted line
get_branch_from_formatted_line() {
    local line="$1"
    echo "$line" | sed 's/.*|//'
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not in a git repository" >&2
    exit 1
fi

# Handle CREATE_MODE - interactive branch selection for worktree creation
if [[ $CREATE_MODE -eq 1 ]]; then
    debug_echo "CREATE_MODE: Interactive branch selection for worktree creation"
    
    # Get branch list
    branch_list=$(get_branch_list)
    
    if [[ -z "$branch_list" ]]; then
        echo "No branches found" >&2
        exit 1
    fi
    
    # Use fzf to select branch
    selected_branch_line=$(echo "$branch_list" | fzf \
        --ansi \
        --height=40% \
        --layout=reverse \
        --border=rounded \
        --header="🌿 Select Branch to Create Worktree | Enter: create, Esc: cancel")
    
    if [[ -z "$selected_branch_line" ]]; then
        debug_echo "No branch selected, exiting"
        exit 0
    fi
    
    # Extract branch name and create worktree
    branch_name=$(get_branch_from_formatted_line "$selected_branch_line")
    debug_echo "Selected branch: $branch_name"
    
    # Handle remote branches - extract just the branch name
    if [[ "$branch_name" == origin/* ]]; then
        branch_name="${branch_name#origin/}"
        debug_echo "Creating from remote branch: $branch_name"
    fi
    
    create_worktree "$branch_name"
    exit $?
fi

# Continue with interactive worktree switching mode
debug_echo "Interactive mode: Launching fzf worktree selector"

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