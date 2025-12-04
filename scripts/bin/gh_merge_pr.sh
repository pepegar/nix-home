#!/usr/bin/env bash

# Configuration - use set -u but NOT set -e for resilience
set -u

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# Debug flag
DEBUG=0

# Track operation success states
merge_success=false
jira_success=false
worktree_success=false
deletion_cancelled=false

# Logging functions
log_error() {
    echo -e "${RED}❌ $1${RESET}" >&2
}

log_success() {
    echo -e "${GREEN}✅ $1${RESET}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${RESET}"
}

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

# Help function
show_help() {
    cat << EOF
Usage: $0 [--debug] [-h|--help]

Merge the current branch's PR in GitHub, update JIRA to 'Pending Release',
delete the current worktree, and navigate to the main worktree (develop).

This script must be run from within a feature branch worktree.

Options:
  --debug    Enable debug output
  -h, --help Show this help message

Operations performed:
  1. Find and merge PR for current branch (merge commit strategy)
  2. Update JIRA issue to "Pending Release" status
  3. Delete current worktree after confirmation
  4. Navigate to main worktree on develop branch

Note: Requires confirmation before merge and before worktree deletion.
      Script continues even if some operations fail (resilient mode).

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --debug)
            DEBUG=1
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown parameter: $1"
            echo "Usage: $0 [--debug] [-h|--help]"
            exit 1
            ;;
    esac
done

# ============================================================================
# ENVIRONMENT VALIDATION
# ============================================================================

debug_echo "Starting environment validation"

# Check if in git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    log_error "Not in a git repository"
    exit 1
fi

debug_echo "✓ In git repository"

# Get current worktree path and branch
worktree_path=$(git rev-parse --show-toplevel)
branch_name=$(git rev-parse --abbrev-ref HEAD)

debug_echo "Current worktree: $worktree_path"
debug_echo "Current branch: $branch_name"

# Get main worktree (first entry in worktree list)
main_worktree=$(git worktree list --porcelain | grep -m1 "^worktree" | sed 's/^worktree //')

debug_echo "Main worktree: $main_worktree"

# Check if we're in the main worktree (should not be)
if [[ "$worktree_path" == "$main_worktree" ]]; then
    log_error "Cannot run from main worktree. This script is for feature branch worktrees only."
    exit 1
fi

debug_echo "✓ Not in main worktree"

# Check if worktree path contains .worktrees/
if [[ ! "$worktree_path" =~ \.worktrees/ ]]; then
    log_error "This doesn't appear to be a feature worktree in .worktrees/"
    log_error "Current path: $worktree_path"
    exit 1
fi

debug_echo "✓ In .worktrees/ subdirectory"

# Check if on a protected branch
if [[ "$branch_name" == "main" || "$branch_name" == "master" || "$branch_name" == "develop" ]]; then
    log_error "Cannot run from protected branch: $branch_name"
    exit 1
fi

debug_echo "✓ Not on protected branch"

log_success "Environment validation passed"

# ============================================================================
# EXTRACT BRANCH NAME AND JIRA ISSUE
# ============================================================================

debug_echo "Extracting JIRA issue from branch name"

# Extract JIRA issue pattern (e.g., PROJ-123)
if [[ $branch_name =~ ([A-Z]+-[0-9]+) ]]; then
    jira_issue=${BASH_REMATCH[1]}
    debug_echo "Found JIRA issue: $jira_issue"
else
    jira_issue=""
    log_warning "No JIRA issue found in branch name"
fi

# ============================================================================
# FIND PR INFORMATION
# ============================================================================

echo ""
echo "Finding PR for branch: $branch_name"

debug_echo "Querying GitHub for PR information"
log_command "gh pr list --head \"$branch_name\" --state open --json number,title,baseRefName"

pr_data=$(gh pr list --head "$branch_name" --state open --json number,title,baseRefName 2>&1)

if [ $? -ne 0 ]; then
    log_error "Failed to fetch PR information from GitHub"
    echo "$pr_data"
    exit 1
fi

debug_echo "PR data received: $pr_data"

# Check if any PRs were found
pr_count=$(echo "$pr_data" | jq length 2>/dev/null)

# If no open PR found, check for closed/merged PRs
if [ -z "$pr_count" ] || [ "$pr_count" -eq 0 ]; then
    log_warning "No open PR found for branch: $branch_name"
    echo "Checking for closed/merged PRs..."

    debug_echo "Querying GitHub for closed PR information"
    log_command "gh pr list --head \"$branch_name\" --state merged --json number,title,baseRefName"

    pr_data=$(gh pr list --head "$branch_name" --state merged --json number,title,baseRefName 2>&1)

    if [ $? -eq 0 ]; then
        pr_count=$(echo "$pr_data" | jq length 2>/dev/null)

        if [ -n "$pr_count" ] && [ "$pr_count" -gt 0 ]; then
            pr_number=$(echo "$pr_data" | jq -r '.[0].number')
            pr_title=$(echo "$pr_data" | jq -r '.[0].title')
            pr_base=$(echo "$pr_data" | jq -r '.[0].baseRefName')

            log_success "Found merged PR: #$pr_number"
            debug_echo "PR number: $pr_number"
            debug_echo "PR title: $pr_title"
            debug_echo "PR base: $pr_base"

            # Mark merge as already done
            merge_success=true

            # Skip to JIRA update
            echo ""
            echo "PR already merged, skipping merge step..."
        else
            log_error "No PR found (open or merged) for branch: $branch_name"
            exit 1
        fi
    else
        log_error "Failed to fetch closed PR information from GitHub"
        exit 1
    fi
else
    # Extract PR details
    pr_number=$(echo "$pr_data" | jq -r '.[0].number')
    pr_title=$(echo "$pr_data" | jq -r '.[0].title')
    pr_base=$(echo "$pr_data" | jq -r '.[0].baseRefName')

    debug_echo "PR number: $pr_number"
    debug_echo "PR title: $pr_title"
    debug_echo "PR base: $pr_base"
fi

# ============================================================================
# CONFIRM AND MERGE PR
# ============================================================================

# Only attempt merge if PR is not already merged
if [ "$merge_success" = false ]; then
    echo ""
    echo -e "${YELLOW}⚠️  About to merge:${RESET}"
    echo "   PR: #$pr_number"
    echo "   Title: $pr_title"
    echo "   Branch: $branch_name"
    echo "   Base: $pr_base"
    if [[ -n "$jira_issue" ]]; then
        echo "   JIRA: $jira_issue"
    fi
    echo -n "   Are you sure? [y/N] "

    read -r response

    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log_error "Merge cancelled by user"
        exit 0
    fi

    echo ""
    echo "Merging PR #$pr_number..."

    debug_echo "Executing PR merge"
    log_command "gh pr merge \"$pr_number\" --merge --delete-branch"

    if gh pr merge "$pr_number" --merge --delete-branch 2>&1; then
        log_success "PR #$pr_number merged successfully"
        merge_success=true
    else
        log_error "Failed to merge PR #$pr_number"
        merge_success=false
    fi
fi

# ============================================================================
# UPDATE JIRA STATUS
# ============================================================================

echo ""

if [[ -n "$jira_issue" ]]; then
    echo "Updating JIRA status for $jira_issue..."

    debug_echo "Transitioning JIRA issue"
    log_command "acli jira workitem transition --key \"$jira_issue\" --status \"Pending Release\""

    if acli jira workitem transition --key "$jira_issue" --status "Pending Release" 2>&1; then
        log_success "JIRA $jira_issue transitioned to 'Pending Release'"
        jira_success=true
    else
        log_error "Failed to update JIRA status for $jira_issue"
        jira_success=false
    fi
else
    echo "Skipping JIRA update (no issue found)"
    jira_success=true
fi

# ============================================================================
# NAVIGATE TO GIT ROOT
# ============================================================================

echo ""
debug_echo "Navigating to git root to exit worktree"

git_root=$(git rev-parse --show-toplevel 2>/dev/null)
cd "$git_root" 2>/dev/null || cd "$(dirname "$git_root")" 2>/dev/null

# Try to get the actual git root from parent directory
git_root=$(git rev-parse --show-toplevel 2>/dev/null)

if [ -z "$git_root" ]; then
    log_error "Could not determine git root directory"
    exit 1
fi

cd "$git_root"

debug_echo "Now in: $(pwd)"

# ============================================================================
# CONFIRM WORKTREE DELETION
# ============================================================================

echo ""
echo -e "${YELLOW}⚠️  About to delete worktree:${RESET}"
echo "   Path: $worktree_path"
echo "   Branch: $branch_name"
echo -n "   Are you sure? [y/N] "

read -r response

if [[ ! "$response" =~ ^[Yy]$ ]]; then
    log_warning "Worktree deletion cancelled by user"
    deletion_cancelled=true
else
    # ============================================================================
    # DELETE WORKTREE
    # ============================================================================

    echo ""
    echo "Deleting worktree..."

    debug_echo "Removing worktree"
    log_command "git worktree remove \"$worktree_path\""

    if git worktree remove "$worktree_path" 2>&1; then
        log_success "Worktree deleted: $worktree_path"
        worktree_success=true
    else
        log_error "Failed to delete worktree"
        log_error "You may need to run: git worktree remove --force \"$worktree_path\""
        worktree_success=false
    fi
fi

# ============================================================================
# NAVIGATE TO MAIN WORKTREE (DEVELOP BRANCH)
# ============================================================================

echo ""

if [ "$deletion_cancelled" = true ] || [ "$worktree_success" = true ]; then
    echo "Navigating to main worktree (develop branch)..."

    debug_echo "Finding main worktree on develop branch"
    log_command "git worktree list --porcelain"

    # Find worktree on develop branch
    main_develop_worktree=$(git worktree list --porcelain | awk '
        BEGIN { worktree = ""; branch = "" }
        /^worktree / { worktree = substr($0, 10) }
        /^branch / {
            branch = substr($0, 8)
            gsub(/^refs\/heads\//, "", branch)
            if (branch == "develop") {
                print worktree
                exit
            }
        }
    ')

    debug_echo "Main develop worktree: $main_develop_worktree"

    if [[ -n "$main_develop_worktree" ]] && [[ -d "$main_develop_worktree" ]]; then
        cd "$main_develop_worktree"
        log_success "Switched to main worktree: $main_develop_worktree"
    else
        log_error "Could not find main worktree on develop branch"
        log_warning "Staying in git root: $(pwd)"
    fi
fi

# ============================================================================
# DISPLAY SUMMARY REPORT
# ============================================================================

echo ""
echo "================================"
echo "Summary:"
echo "================================"

if [ "$merge_success" = true ]; then
    log_success "PR #$pr_number merged"
else
    log_error "PR merge failed"
fi

if [[ -n "$jira_issue" ]]; then
    if [ "$jira_success" = true ]; then
        log_success "JIRA $jira_issue updated to 'Pending Release'"
    else
        log_error "JIRA $jira_issue update failed"
    fi
fi

if [ "$deletion_cancelled" = true ]; then
    log_warning "Worktree deletion cancelled by user"
elif [ "$worktree_success" = true ]; then
    log_success "Worktree deleted: $worktree_path"
else
    log_error "Worktree deletion failed"
fi

echo ""
echo "Current directory: $(pwd)"
echo "================================"
