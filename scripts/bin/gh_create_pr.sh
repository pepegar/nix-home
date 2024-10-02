#!/bin/bash

branch_name=$(git rev-parse --abbrev-ref HEAD)
branch_desc=$(git config branch."$branch_name".description)

# Check for JIRA issue pattern (e.g., PROJ-123)
if [[ $branch_name =~ ([A-Z]+-[0-9]+) ]]; then
    jira_issue=${BASH_REMATCH[1]}
else
    jira_issue=""
fi

if [ -z "$branch_desc" ]; then
  echo "No branch description found."
  read -p "Enter a description for this branch: " user_desc
  if [ -z "$user_desc" ]; then
    echo "Description cannot be empty. Aborting PR creation."
    exit 1
  fi
  git config branch."$branch_name".description "$user_desc"
  branch_desc="$user_desc"
  echo "Description set and saved for future use."
fi

# Construct the title based on whether a JIRA issue was found
if [ -n "$jira_issue" ]; then
    pr_title="[$jira_issue] $branch_desc"
else
    pr_title="$branch_desc"
fi

gh pr create --title "$pr_title" --base develop --assignee "@me" --reviewer "GoodNotes/goodnotes-cloud" --label "digital-paper:backend-web" --fill
