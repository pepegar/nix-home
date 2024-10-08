#!/bin/bash

# Debug flag
DEBUG=false

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
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

debug "Debug mode is enabled"

# Check if jira and fzf are installed
if ! command -v jira &> /dev/null || ! command -v fzf &> /dev/null
then
    echo "Error: This script requires jira and fzf to be installed."
    exit 1
fi

debug "jira and fzf are installed"

PROJECT_KEY="GNC"
debug "Project key: $PROJECT_KEY"

# Function to fetch epics
fetch_epics() {
    local start=$1
    debug "Fetching epics starting from $start"
    jira epic list --project $PROJECT_KEY --paginate "$start:100" --table --plain
}

# Initialize variables
all_epics=""
start=0
page_size=100

debug "Fetching all epics"

# Fetch all epics
while true; do
    debug "Fetching page starting from $start"
    epics=$(fetch_epics $start)

    latest_epic=$(echo "$epics" | tail -n 1)
    debug "Latest epic in this page: $latest_epic"   

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

debug "Total epics fetched: $(echo "$all_epics" | wc -l)"

# Remove trailing newline and pipe to fzf
debug "Prompting user to select an epic"
selected_epic=$(echo "$all_epics" | sed '$d' | fzf --height 40% --header "Select an Epic:")

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
read task_summary
debug "Task summary: $task_summary"

# Create the Jira task
debug "Creating Jira task"
new_task=$(jira issue create --no-input -tTask --parent $epic_key --summary "$task_summary" --project $PROJECT_KEY)

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

# Assign the task to yourself
echo "Assigning task to yourself..."
debug "Assigning task $new_task_key to $(jira me)"
jira issue assign "$new_task_key" "$(jira me)"

# Set the task to "In Progress"
echo "Putting task in progress..."
debug "Moving task $new_task_key to 'In Progress'"
jira issue move $new_task_key "In Progress"

echo "Task created and set to In Progress: $new_task_key"
debug "Script completed successfully"
