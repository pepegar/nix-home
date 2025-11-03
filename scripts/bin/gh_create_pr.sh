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

# Generate PR description using AI
echo "Generating PR description..."

# Get commit messages and diff summary
commit_log=$(git log origin/develop..HEAD --pretty=format:"- %s" --no-merges)
diff_stat=$(git diff origin/develop...HEAD --stat)
diff_content=$(git diff origin/develop...HEAD)

# Create prompt for LLM to generate brief PR description
prompt="Generate a GitHub pull request description based on these changes.

COMMIT MESSAGES:
$commit_log

DIFF SUMMARY:
$diff_stat

KEY CHANGES:
$diff_content

Format the PR description with the following structure:

## Summary
[2-3 sentences explaining what changed and why]

## Key Changes
[3-5 bullet points of the most important modifications]

## Files to Review Carefully
[List 2-4 files that contain critical changes, complex logic, or require special attention. For each file, briefly explain why it needs careful review]

Keep it concise and focused on what reviewers need to know."

# Generate PR body using llm with haiku model
pr_body=$(echo "$prompt" | llm --model haiku 2>/dev/null)

if [ -z "$pr_body" ]; then
  echo "Failed to generate PR description, falling back to --fill"
  gh pr create --title "$pr_title" --base develop --assignee "@me" --reviewer "GoodNotes/goodnotes-cloud" --label "digital-paper:backend-web" --fill
else
  echo "Generated PR description:"
  echo "$pr_body"
  echo ""
  gh pr create --title "$pr_title" --body "$pr_body" --base develop --assignee "@me" --reviewer "GoodNotes/goodnotes-cloud" --label "digital-paper:backend-web"
fi

acli jira workitem transition --key "$jira_issue" --status "Peer Review"

