#!/usr/bin/env bash
# Browse and checkout open PRs from team members
#
# This script creates git worktrees for PRs, allowing you to work on multiple
# PRs simultaneously without switching branches in your main working directory.

set -euo pipefail

# Debug flag
DEBUG=0

# CLI arguments
ARG_USER=""
ARG_PR_NUMBER=""
ARG_BASE_BRANCH=""

show_help() {
    cat << 'EOF'
Usage: pr [OPTIONS] [USER] [PR_NUMBER]

Browse and checkout open PRs from team members by creating git worktrees.

ARGUMENTS:
  USER          GitHub username of the PR author (optional)
  PR_NUMBER     PR number to checkout (optional)

OPTIONS:
  -h, --help              Show this help message and exit
  -d, --debug             Enable debug output
  -b, --base BRANCH       Base branch for worktree (default: interactive selection)
                          Options: 'current', 'develop', 'pr' (existing PR branch)

EXAMPLES:
  pr                          Interactive mode: select user, then PR, then base branch
  pr pepegar                  Select from pepegar's open PRs interactively
  pr pepegar 1234             Checkout PR #1234 by pepegar (prompts for base branch)
  pr pepegar 1234 -b develop  Checkout PR #1234 using origin/develop as base
  pr pepegar 1234 -b current  Checkout PR #1234 using current branch as base
  pr pepegar 1234 -b pr       Checkout PR #1234 using the PR's branch from origin

BEHAVIOR:
  - If a worktree already exists for the PR, switches to it
  - Creates worktrees in <repo>/.worktrees/pr-<user>-<pr_number>
  - Sets branch description with PR title for reference

PREDEFINED USERS:
  pepegar, noells, sisca-goodnotes, gtukmachev, furstenheim-goodnotes,
  felixmhho, wcchoi, cucxabong, gn-kuba-s, gn-joel-d, gn-jose-h

EXIT CODES:
  0    Success
  1    Error (gh not installed, not in git repo, failed to fetch PR, etc.)
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -d|--debug)
            DEBUG=1
            shift
            ;;
        -b|--base)
            if [[ -z "${2:-}" ]]; then
                echo "Error: --base requires an argument (current, develop, or pr)"
                exit 1
            fi
            ARG_BASE_BRANCH="$2"
            shift 2
            ;;
        -*)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
        *)
            if [[ -z "$ARG_USER" ]]; then
                ARG_USER="$1"
            elif [[ -z "$ARG_PR_NUMBER" ]]; then
                ARG_PR_NUMBER="$1"
            else
                echo "Error: Too many arguments"
                echo "Use -h or --help for usage information"
                exit 1
            fi
            shift
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

# List of users to filter PRs by
USERS=(
    "pepegar"
    "noells" 
    "sisca-goodnotes"
    "gtukmachev"
    "furstenheim-goodnotes"
    "felixmhho"
    "wcchoi"
    "cucxabong"
    "gn-kuba-s"
    "gn-joel-d"
    "gn-jose-h"
)

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed or not in PATH"
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Select user from predefined list or use CLI argument
if [[ -n "$ARG_USER" ]]; then
    selected_user="$ARG_USER"
    debug_echo "Using user from CLI argument: $selected_user"
else
    debug_echo "Selecting user from predefined list"
    selected_user=$(printf '%s\n' "${USERS[@]}" | fzf --height 40% --reverse --header="Select user:") || true

    if [ -z "$selected_user" ]; then
        debug_echo "No user selected. Exiting."
        echo "No user selected. Exiting."
        exit 0
    fi
fi

debug_echo "Selected user: $selected_user"

# Get PR number from CLI argument or interactive selection
if [[ -n "$ARG_PR_NUMBER" ]]; then
    pr_number="$ARG_PR_NUMBER"
    debug_echo "Using PR number from CLI argument: $pr_number"
else
    # Get PRs for selected user
    debug_echo "Fetching PRs for user: $selected_user"
    log_command "gh pr list --author=$selected_user --state=open --json number,title,headRefName,author,createdAt"

    if ! pr_data=$(gh pr list --author="$selected_user" --state=open --json number,title,headRefName,author,createdAt); then
        echo "Error: Failed to fetch PRs from GitHub"
        exit 1
    fi

    # Check if any PRs were found
    if [ "$(echo "$pr_data" | jq length)" -eq 0 ]; then
        echo "No open PRs found for user: $selected_user"
        exit 0
    fi

    # Format PRs for fzf selection
    debug_echo "Formatting PRs for selection"
    formatted_prs=$(echo "$pr_data" | jq -r '.[] | "#\(.number) \(.title) (@\(.author.login))"')

    # Select PR using fzf
    selected_pr=$(echo "$formatted_prs" | fzf --height 40% --reverse --header="Select PR:") || true

    # Exit if no selection was made
    if [ -z "$selected_pr" ]; then
        debug_echo "No PR selected. Exiting."
        echo "No PR selected. Exiting."
        exit 0
    fi

    # Extract PR number from selection
    pr_number=$(echo "$selected_pr" | sed -E 's/^#([0-9]+).*/\1/')
fi
debug_echo "Selected PR number: $pr_number"

# Get detailed PR information
debug_echo "Getting detailed PR information"
log_command "gh pr view $pr_number --json number,title,headRefName"

if ! pr_details=$(gh pr view "$pr_number" --json number,title,headRefName); then
    echo "Error: Failed to get PR details"
    exit 1
fi

# Extract PR details
pr_title=$(echo "$pr_details" | jq -r '.title')
pr_branch=$(echo "$pr_details" | jq -r '.headRefName')

debug_echo "PR title: $pr_title"
debug_echo "PR branch: $pr_branch"

# Get the git repository root and worktree path
git_root=$(git rev-parse --show-toplevel)
worktree_path="$git_root/.worktrees/pr-${selected_user}-${pr_number}"

debug_echo "Worktree path: $worktree_path"

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

# Function to get the current branch name
get_current_branch() {
    debug_echo "Getting current branch name"
    log_command "git rev-parse --abbrev-ref HEAD"
    git rev-parse --abbrev-ref HEAD
}

# Check if worktree already exists
if [ -d "$worktree_path" ]; then
    # Worktree exists, switch to it
    debug_echo "Worktree exists, switching to it"
    echo "Switching to existing worktree: $worktree_path"
    cd "$worktree_path"
else
    # Worktree doesn't exist, determine base branch
    current_branch=$(get_current_branch)

    if [[ -n "$ARG_BASE_BRANCH" ]]; then
        # Use CLI argument for base branch
        case "$ARG_BASE_BRANCH" in
            current)
                base_branch="$current_branch"
                debug_echo "Using current branch as base: $base_branch"
                ;;
            develop)
                base_branch="origin/develop"
                debug_echo "Using develop as base: $base_branch"
                ;;
            pr)
                if check_origin_branch "$pr_branch"; then
                    base_branch="origin/$pr_branch"
                    debug_echo "Using PR branch as base: $base_branch"
                else
                    echo "Error: PR branch '$pr_branch' does not exist in origin"
                    exit 1
                fi
                ;;
            *)
                echo "Error: Invalid base branch option '$ARG_BASE_BRANCH'"
                echo "Valid options: current, develop, pr"
                exit 1
                ;;
        esac
    else
        # Interactive base branch selection
        echo "Choose base branch:"

        # Check if PR branch already exists in origin
        branch_options="Current branch ($current_branch)\\nDevelop branch (origin/develop)"
        if check_origin_branch "$pr_branch"; then
            debug_echo "Branch $pr_branch exists in origin, adding to options"
            branch_options="Existing PR branch (origin/$pr_branch)\\n$branch_options"
        fi

        base_branch=$(echo -e "$branch_options" |
                      fzf --height 15% --reverse --header="Choose base branch:") || true

        if [[ -z "$base_branch" ]]; then
            debug_echo "No base branch selected. Exiting."
            echo "No base branch selected. Exiting."
            exit 0
        fi

        if [[ "$base_branch" == *"Existing PR branch"* ]]; then
            base_branch="origin/$pr_branch"
        elif [[ "$base_branch" == *"Current"* ]]; then
            base_branch="$current_branch"
        else
            base_branch="origin/develop"
        fi
    fi

    debug_echo "Creating new worktree from $base_branch"
    log_command "git worktree add \"$worktree_path\" -b \"pr-$pr_number\" \"$base_branch\""
    if git worktree add "$worktree_path" -b "pr-${selected_user}-${pr_number}" "$base_branch"; then
        echo "Created worktree: $worktree_path (branch: pr-${selected_user}-${pr_number}, based on $base_branch)"
        
        # Change to the new worktree directory
        cd "$worktree_path"
        
        # Set branch description with PR info
        git config "branch.pr-${selected_user}-${pr_number}.description" "PR #$pr_number: $pr_title"
        echo "Set branch description from PR information."
        echo "Changed to worktree directory: $worktree_path"
    else
        echo "Failed to create worktree. Please check your Git repository state."
        exit 1
    fi
fi

echo "Ready to work on PR #$pr_number: $pr_title"