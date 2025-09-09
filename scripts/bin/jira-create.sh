#!/bin/bash

# Debug flag
DEBUG=false
REFRESH=false
CACHE_FILE="$HOME/.acli-epics"

# Debug function
debug() {
    if [ "$DEBUG" = true ]; then
        echo "[DEBUG] $1" >&2
    fi
}

# Show help function
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Interactive script to create a Jira task under an Epic in project GNC.

OPTIONS:
    --help      Show this help message and exit
    --debug     Enable debug mode for verbose output
    --refresh   Refresh the Epic cache instead of using cached data

DESCRIPTION:
    This script helps you create Jira tasks by:
    1. Fetching and caching all Epics from the GNC project
    2. Presenting an interactive fzf menu to select an Epic
    3. Prompting for a task summary
    4. Creating the task with label 'gnc-aaa'
    5. Assigning the task to yourself
    6. Optionally creating a git branch using jira-branch

DEPENDENCIES:
    - acli: Atlassian CLI tool
    - fzf: Command-line fuzzy finder

CACHE:
    Epic data is cached in ~/.acli-epics to improve performance.
    Use --refresh to update the cache with latest Epic data.

EOF
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --help) show_help; exit 0 ;;
        --debug) DEBUG=true ;;
        --refresh) REFRESH=true ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

debug "Debug mode is enabled"

# Check if acli and fzf are installed
if ! command -v acli &> /dev/null || ! command -v fzf &> /dev/null
then
    echo "Error: This script requires acli and fzf to be installed."
    exit 1
fi

debug "acli and fzf are installed"

PROJECT_KEY="GNC"
debug "Project key: $PROJECT_KEY"

# Function to fetch epics
fetch_epics() {
    local start=$1
    debug "Fetching epics starting from $start"
    acli jira workitem search --jql "project = $PROJECT_KEY AND type = Epic" --fields "key,summary,status" --limit 100
}

# Function to fetch and cache all epics
fetch_and_cache_epics() {
    debug "Fetching all epics and caching them"
    
    # Fetch all epics using CSV format to avoid headers in pagination
    epics=$(acli jira workitem search --jql "project = $PROJECT_KEY AND type = Epic" --fields "key,summary,status" --paginate --csv)
    
    # Skip the CSV header line and save to cache file
    echo "$epics" | tail -n +2 > "$CACHE_FILE"
    debug "Epics cached to $CACHE_FILE"
}

# Check if we need to refresh the cache or if the cache file doesn't exist
if [ "$REFRESH" = true ] || [ ! -f "$CACHE_FILE" ]; then
    debug "Refreshing epic cache"
    fetch_and_cache_epics
else
    debug "Using cached epics from $CACHE_FILE"
fi

# Read epics from cache and pipe to fzf
debug "Prompting user to select an epic"
selected_epic=$(cat "$CACHE_FILE" | fzf --height 40% --header "Select an Epic:" --delimiter "," --with-nth "{1} {2} {3}")

if [ -z "$selected_epic" ]; then
    echo "No epic selected. Exiting."
    exit 0
fi

# Extract the epic key from the selected epic (first column of CSV)
epic_key=$(echo "$selected_epic" | awk -F',' '{print $1}')
debug "Selected epic key: $epic_key"

# Prompt for the task summary
echo "Enter the task summary:"
read -e task_summary
debug "Task summary: $task_summary"

# Create the Jira task
debug "Creating Jira task"
new_task=$(acli jira workitem create --project $PROJECT_KEY --type Task --parent $epic_key --summary "$task_summary" --label gnc --json)

if [ $? -ne 0 ]; then
    echo "Error creating the task. Exiting."
    exit 1
fi

# Extract the new task key from the JSON response
new_task_key=$(echo $new_task | jq -r '.key')

if [ -z "$new_task_key" ]; then
    echo "Error: Could not extract the new task key. Exiting."
    exit 1
fi

debug "New task key: $new_task_key"
echo "New Task Key: $new_task_key"

# Assign the task to yourself
echo "Assigning task to yourself..."
debug "Assigning task $new_task_key to current user"
acli jira workitem assign --key "$new_task_key" --assignee "@me"

# Ask if user wants to create a branch using fzf
create_branch=$(echo -e "Yes\nNo" | fzf --height 15% --reverse --header="Create a branch for this task?")

if [[ "$create_branch" == "Yes" ]]; then
    debug "Creating branch using jira-branch script with issue key"
    ppg jira-branch --issue-key "$new_task_key"
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to create branch using jira-branch script"
    fi
fi

echo "Task created: $new_task_key"
debug "Script completed successfully"
