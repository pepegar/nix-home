#!/usr/bin/env bash

# Debug flag
DEBUG=0

# Check for debug flag
if [[ "$1" == "--debug" ]]; then
    DEBUG=1
fi

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
    log_command " acli jira workitem transition --issue $issue_key --status \"In Progress\""
    acli jira workitem transition --issue $issue_key --status \"In Progress\"
}

# Run ACLI command, parse JSON, and pipe to fzf for selection
debug_echo "Running ACLI command, parsing JSON, and piping to fzf"
log_command "acli jira workitem search --jql 'assignee = currentuser() and status in ("To Do", "In Progress", "Peer Review", "Ready") ORDER BY updatedDate DESC' --json | jq -r '.[] | \"\\(.key) [\\(.fields.status.name)] \\(.fields.summary)\"' | fzf --ansi --height 40% --reverse"
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

# Create branch name with sanitized title
sanitized_summary=$(sanitize_title "$jira_summary")
branch_name="${jira_key}-${sanitized_summary}"
debug_echo "Branch name: $branch_name"

# Get the full SHA-1 for develop branch and current branch
develop_sha=$(get_develop_sha)
current_branch=$(get_current_branch)
debug_echo "Develop SHA: $develop_sha"
debug_echo "Current branch: $current_branch"

# Check if branch exists
debug_echo "Checking if branch exists: $branch_name"
log_command "git show-ref --quiet \"refs/heads/$branch_name\""
if git show-ref --quiet "refs/heads/$branch_name"; then
    # Branch exists, switch to it
    debug_echo "Branch exists, switching to it"
    log_command "git checkout \"$branch_name\""
    git checkout "$branch_name"
    echo "Switched to existing branch: $branch_name"
else
    # Branch doesn't exist, ask user for base branch
    echo "Choose base branch:"
    base_branch=$(echo -e "Current branch ($current_branch)\nDevelop branch (origin/develop)" | 
                  fzf --height 15% --reverse --header="Choose base branch:")

    if [[ "$base_branch" == *"Current"* ]]; then
        base_branch="$current_branch"
    else
        base_branch="$develop_sha"
    fi

    debug_echo "Creating new branch from $base_branch"
    log_command "git checkout -b \"$branch_name\" \"$base_branch\""
    if git checkout -b "$branch_name" "$base_branch"; then
        echo "Created and switched to new branch: $branch_name (based on $([ "$choice" = "1" ] && echo "$current_branch" || echo "origin/develop"))"
        
        # Set branch description
        set_branch_description "$branch_name" "$jira_summary"
        echo "Set branch description from Jira issue summary."
    else
        echo "Failed to create branch. Please check your Git repository state."
        exit 1
    fi
fi

# Set Jira issue to In Progress
set_issue_in_progress "$jira_key"
echo "Updated Jira issue $jira_key to In Progress status."
