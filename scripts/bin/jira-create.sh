#!/bin/bash

# Check if jira and fzf are installed
if ! command -v jira &> /dev/null || ! command -v fzf &> /dev/null
then
    echo "Error: This script requires jira and fzf to be installed."
    exit 1
fi

# Set your Jira project key
PROJECT_KEY="GNC"

# Query epics and select one using fzf
selected_epic=$(jira epic list --project $PROJECT_KEY | fzf --height 40% --header "Select an Epic:")

if [ -z "$selected_epic" ]; then
    echo "No epic selected. Exiting."
    exit 0
fi

# Extract the epic key from the selected epic
epic_key=$(echo $selected_epic | awk '{print $2}')

echo $epic_key

# Prompt for the task summary
echo "Enter the task summary:"
read task_summary

# Create the Jira task
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

echo "New Task Key: $new_task_key"

# Assign the task to yourself
echo "Assigning task to yourself..."
jira issue assign "$new_task_key" "$(jira me)"

# Set the task to "In Progress"
echo "Putting task in progress..."
jira issue move $new_task_key "In Progress"

echo "Task created and set to In Progress: $new_task_key"
