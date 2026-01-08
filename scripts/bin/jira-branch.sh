#!/usr/bin/env bash
# Create a git branch from a Jira issue key

# Debug flag
DEBUG=0
ISSUE_KEY=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --debug)
            DEBUG=1
            shift
            ;;
        --issue-key)
            ISSUE_KEY="$2"
            shift 2
            ;;
        *)
            echo "Unknown parameter: $1"
            echo "Usage: $0 [--debug] [--issue-key ISSUE-KEY]"
            exit 1
            ;;
    esac
done

# Debug echo function
debug_echo() {
    if [[ $DEBUG -eq 1 ]]; then
        echo "🤖 $1"
    fi
}

# Command logging function
log_command() {
    if [[ $DEBUG -eq 1 ]]; then
        echo "🖥️ Command: $1"
    fi
}

# Function to sanitize the title for branch name
sanitize_title() {
    local title=$1
    # Convert to lowercase
    # Replace spaces and special chars with dashes
    # Remove any character that isn't lowercase letter, number, or dash
    # Collapse multiple dashes into single dash
    # Remove leading and trailing dashes
    echo "$title" | \
        tr '[:upper:]' '[:lower:]' | \
        tr ' ' '-' | \
        sed 's/[^a-z0-9-]//g' | \
        sed 's/-\+/-/g' | \
        sed 's/^-\|-$//g'
}

# Function to get the full SHA-1 for develop branch
get_develop_sha() {
    debug_echo "Getting full SHA-1 for develop branch"
    log_command "git rev-parse origin/develop"
    git rev-parse origin/develop 2>/dev/null
}

# Function to get the current branch name
get_current_branch() {
    debug_echo "Getting current branch name"
    log_command "git rev-parse --abbrev-ref HEAD"
    git rev-parse --abbrev-ref HEAD
}

# Function to check if a branch exists in origin
check_origin_branch() {
    local branch_name=$1
    debug_echo "Checking if branch exists in origin: $branch_name"
    log_command "git ls-remote --heads origin $branch_name"
    if git ls-remote --heads origin "$branch_name" | grep -q "refs/heads/$branch_name"; then
        return 0  # Branch exists
    else
        return 1  # Branch doesn't exist
    fi
}

# Function to set branch description
set_branch_description() {
    local branch=$1
    local description=$2
    debug_echo "Setting description for branch: $branch"
    log_command "git config branch.${branch}.description \"$description\""
    git config branch.${branch}.description "$description"
}

# Function to set Jira issue to In Progress
set_issue_in_progress() {
    local issue_key=$1
    debug_echo "Setting Jira issue $issue_key to In Progress"
    log_command " acli jira workitem transition --key $issue_key --status \"In Progress\""
    acli jira workitem transition --key $issue_key --status "In Progress"
}

# Function to rename Zellij tab to issue ID
rename_zellij_tab() {
    local issue_key=$1
    if [[ -n "$issue_key" ]] && command -v zellij &> /dev/null && [[ -n "$ZELLIJ" ]]; then
        debug_echo "Renaming Zellij tab to: $issue_key"
        zellij action rename-tab "$issue_key"
    fi
}

if [ -n "$ISSUE_KEY" ]; then
    # Issue key provided, get issue details directly
    debug_echo "Using provided issue key: $ISSUE_KEY"
    log_command "acli jira workitem view $ISSUE_KEY --json"
    issue_json=$(acli jira workitem view "$ISSUE_KEY" --json)
    
    if [ $? -ne 0 ] || [ -z "$issue_json" ]; then
        echo "Error: Could not retrieve issue $ISSUE_KEY"
        exit 1
    fi
    
    jira_key="$ISSUE_KEY"
    jira_summary=$(echo "$issue_json" | jq -r '.fields.summary')
    
    debug_echo "Jira key: $jira_key"
    debug_echo "Jira summary: $jira_summary"
else
    # Run ACLI command, parse JSON, and pipe to fzf for selection
    debug_echo "Running ACLI command, parsing JSON, and piping to fzf"
    log_command "acli jira workitem search --jql 'assignee = currentuser() and status in (\"To Do\", \"In Progress\", \"Peer Review\", \"Ready\") ORDER BY updatedDate DESC' --json | jq -r '.[] | \"\\(.key) [\\(.fields.status.name)] \\(.fields.summary)\"' | fzf --ansi --height 40% --reverse"
    selected=$(acli jira workitem search --jql 'assignee = currentuser() and status in ("To Do", "In Progress", "Peer Review", "Ready") ORDER BY updatedDate DESC' --json | jq -r '.[] | "\(.key) [\(.fields.status.name)] \(.fields.summary)"' | fzf --ansi --height 40% --reverse)

    # Exit if no selection was made
    if [ -z "$selected" ]; then
        debug_echo "No selection made. Exiting."
        echo "No selection made. Exiting."
        exit 0
    fi

    # Extract Jira key and summary from selection
    debug_echo "Extracting Jira key and summary from selection"
    jira_key=$(echo "$selected" | awk '{print $1}')
    # Extract summary by removing key and status (format: "KEY [STATUS] SUMMARY")
    jira_summary=$(echo "$selected" | sed -E 's/^[^ ]+ \[[^]]+\] //')
    debug_echo "Jira key: $jira_key"
    debug_echo "Jira summary: $jira_summary"
fi

# Create branch name with sanitized title
sanitized_summary=$(sanitize_title "$jira_summary")
branch_name="${jira_key}-${sanitized_summary}"
debug_echo "Branch name: $branch_name"

# Get the full SHA-1 for develop branch and current branch
develop_sha=$(get_develop_sha)
current_branch=$(get_current_branch)
debug_echo "Develop SHA: $develop_sha"
debug_echo "Current branch: $current_branch"

# Get the git repository root and worktree path
git_root=$(git rev-parse --show-toplevel)
worktree_path="$git_root/.worktrees/${branch_name}"

# Check if worktree already exists
debug_echo "Checking if worktree exists: $worktree_path"
if [ -d "$worktree_path" ]; then
    # Worktree exists, switch to it
    debug_echo "Worktree exists, switching to it"
    echo "Switching to existing worktree: $worktree_path"
    cd "$worktree_path"
else
    # Worktree doesn't exist, ask user for base branch
    echo "Choose base branch:"
    
    # Check if branch already exists in origin
    branch_options="Develop branch (origin/develop)\nDevelop Web Viewer branch (origin/develop-web-viewer)\nMaster Web Viewer branch (origin/master-web-viewer)\nCurrent branch ($current_branch)"
    if check_origin_branch "$branch_name"; then
        debug_echo "Branch $branch_name exists in origin, adding to options"
        branch_options="Existing branch (origin/$branch_name)\n$branch_options"
    fi
    
    base_branch=$(echo -e "$branch_options" | 
                  fzf --height 20% --reverse --header="Choose base branch:")

    if [[ "$base_branch" == *"Existing"* ]]; then
        base_branch="origin/$branch_name"
    elif [[ "$base_branch" == *"Current"* ]]; then
        base_branch="$current_branch"
    elif [[ "$base_branch" == *"Develop Web Viewer"* ]]; then
        base_branch="origin/develop-web-viewer"
    elif [[ "$base_branch" == *"Master Web Viewer"* ]]; then
        base_branch="origin/master-web-viewer"
    else
        base_branch="origin/develop"
    fi

    debug_echo "Creating new worktree from $base_branch"
    log_command "git worktree add \"$worktree_path\" -b \"$branch_name\" \"$base_branch\""
    if git worktree add "$worktree_path" -b "$branch_name" "$base_branch"; then
        echo "Created worktree: $worktree_path (branch: $branch_name, based on $base_branch)"
        
        # Change to the new worktree directory
        cd "$worktree_path"
        
        # Set branch description
        set_branch_description "$branch_name" "$jira_summary"
        echo "Set branch description from Jira issue summary."
        echo "Changed to worktree directory: $worktree_path"
    else
        echo "Failed to create worktree. Please check your Git repository state."
        exit 1
    fi
fi

# Rename Zellij tab to issue ID
rename_zellij_tab "$jira_key"

# Set Jira issue to In Progress
set_issue_in_progress "$jira_key"
echo "Updated Jira issue $jira_key to In Progress status."
