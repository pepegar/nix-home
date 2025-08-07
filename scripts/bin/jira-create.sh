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

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
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
    acli jira epic list --project $PROJECT_KEY --limit 100 --offset "$start" --plain
}

# Function to fetch and cache all epics
fetch_and_cache_epics() {
    debug "Fetching all epics and caching them"
    
    # Initialize variables
    all_epics=""
    start=0
    page_size=100

    # Fetch all epics
    while true; do
        debug "Fetching page starting from $start"
        epics=$(fetch_epics $start)

        # Count the number of lines in the result (subtracting 1 for the header)
        line_count=$(($(echo "$epics" | wc -l) - 1))
        
        debug "Number of epics in this page: $line_count"
        
        # Break if we have fewer epics than the page size (indicating last page)
        if [ "$line_count" -lt "$page_size" ]; then
            debug "Reached the last page of epics (fewer than $page_size epics)"
            all_epics+="$epics"$'\n'
            break
        fi
        
        # Append to all_epics
        all_epics+="$epics"$'\n'
     
        # Increment start for next page
        start=$((start + page_size))
        debug "Next page will start from $start"
    done

    # Remove trailing newline and save to cache file
    echo "$all_epics" | sed '$d' > "$CACHE_FILE"
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
selected_epic=$(cat "$CACHE_FILE" | fzf --height 40% --header "Select an Epic:")

if [ -z "$selected_epic" ]; then
    echo "No epic selected. Exiting."
    exit 0
fi

# Extract the epic key from the selected epic
epic_key=$(echo $selected_epic | awk '{print $2}')
debug "Selected epic key: $epic_key"

echo $epic_key

# Prompt for the task summary
echo "Enter the task summary:"
read -e task_summary
debug "Task summary: $task_summary"

# Create the Jira task
debug "Creating Jira task"
new_task=$(acli jira issue create --project $PROJECT_KEY --type Task --parent $epic_key --summary "$task_summary" --labels gnc-aaa)

echo $new_task

if [ $? -ne 0 ]; then
    echo "Error creating the task. Exiting."
    exit 1
fi

# Extract the new task key from the URL (last segment of the path)
new_task_key=$(echo $new_task | grep -oP 'https://.*?/browse/\K[^/\s]+')

if [ -z "$new_task_key" ]; then
    echo "Error: Could not extract the new task key. Exiting."
    exit 1
fi

debug "New task key: $new_task_key"
echo "New Task Key: $new_task_key"

# Get current user for assignment
debug "Getting current user account ID"
current_user=$(acli jira user currentUser --field accountId)

# Assign the task to yourself
echo "Assigning task to yourself..."
debug "Assigning task $new_task_key to $current_user"
acli jira issue assign --issue "$new_task_key" --assignee "$current_user"

# Ask if user wants to create a branch
echo "Would you like to create a branch for this task? (y/n)"
read -e create_branch

if [[ $create_branch =~ ^[Yy]$ ]]; then
    debug "Creating branch using jira-branch script"
    jira-branch
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to create branch using jira-branch script"
    fi
fi

# Set the task to "In Progress"
echo "Putting task in progress..."
debug "Moving task $new_task_key to 'In Progress'"
acli jira issue transition --issue $new_task_key --transition "In Progress"

echo "Task created and set to In Progress: $new_task_key"
debug "Script completed successfully"
