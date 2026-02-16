#!/usr/bin/env bash

set -euo pipefail

# Auto-commit changes using LLM-generated commit message
# Usage: autocommit.sh [--staged] [file]
#   --staged: Only commit staged changes
#   file: Only commit changes to specified file

# Get recent commit messages for style reference
RECENT_COMMITS=$(git log -3 --pretty=format:'%s' 2>/dev/null || echo "")

# Build the prompt with recent commits for style reference
DIFF_EXPLANATION="IMPORTANT: In the git diff format, lines starting with '-' (minus) are REMOVED/DELETED lines, and lines starting with '+' (plus) are ADDED/NEW lines. Pay careful attention to this when describing what changed."

if [[ -n "$RECENT_COMMITS" ]]; then
    PROMPT="Here are the last 3 commit messages from this branch for style reference:
$RECENT_COMMITS

$DIFF_EXPLANATION

Now analyze the following git diff and provide a concise commit message (50 chars or less) following conventional commit format (type: description). Use similar language, style, and tone as the recent commits above. Use types like feat, fix, chore, docs, refactor, style, test, perf. Be specific about what changed - if code was removed, say it was removed; if code was added, say it was added."
else
    PROMPT="$DIFF_EXPLANATION

Analyze the following git diff and provide a concise commit message (50 chars or less) following conventional commit format (type: description). Use types like feat, fix, chore, docs, refactor, style, test, perf. Be specific about what changed - if code was removed, say it was removed; if code was added, say it was added."
fi

# Parse arguments
STAGED=false
FILE=""

for arg in "$@"; do
    if [[ "$arg" == "--staged" ]]; then
        STAGED=true
    elif [[ -f "$arg" ]]; then
        FILE="$arg"
    fi
done

# Get the diff based on arguments
if [[ "$STAGED" == true ]]; then
    if [[ -n "$FILE" ]]; then
        DIFF=$(git diff --cached -- "$FILE")
    else
        DIFF=$(git diff --cached)
    fi

    if [[ -z "$DIFF" ]]; then
        echo "No staged changes to commit" >&2
        exit 1
    fi

    # Generate commit message and strip backticks
    COMMIT_MSG=$(echo "$DIFF" | llm --model haiku -s "$PROMPT" | tr -d '`')

    # Commit staged changes
    if [[ -n "$FILE" ]]; then
        git commit -m "$COMMIT_MSG" -- "$FILE"
    else
        git commit -m "$COMMIT_MSG"
    fi
else
    if [[ -n "$FILE" ]]; then
        DIFF=$(git diff HEAD -- "$FILE")
    else
        DIFF=$(git diff HEAD)
    fi

    if [[ -z "$DIFF" ]]; then
        echo "No changes to commit" >&2
        exit 1
    fi

    # Generate commit message and strip backticks
    COMMIT_MSG=$(echo "$DIFF" | llm --model haiku -s "$PROMPT" | tr -d '`')

    # Add and commit changes
    if [[ -n "$FILE" ]]; then
        git add "$FILE"
        git commit -m "$COMMIT_MSG" -- "$FILE"
    else
        git add -A
        git commit -m "$COMMIT_MSG"
    fi
fi

echo "Committed with message: $COMMIT_MSG"
