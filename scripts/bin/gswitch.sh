#!/bin/bash

relative_time() {
    local diff=$(( $(date +%s) - $1 ))
    if [ $diff -lt 60 ]; then
        echo "${diff}s ago"
    elif [ $diff -lt 3600 ]; then
        echo "$((diff/60))m ago"
    elif [ $diff -lt 86400 ]; then
        echo "$((diff/3600))h ago"
    else
        echo "$((diff/86400))d ago"
    fi
}

branches=$(git branch | grep -v "^*")

menu_items=""
while IFS= read -r branch; do
    branch_name=$(echo "$branch" | xargs)
    description=$(git config branch."$branch_name".description)
    commit_hash=$(git rev-parse --short "$branch_name")
    commit_time=$(git show -s --format=%ct "$branch_name")
    commit_relative_time=$(relative_time "$commit_time")
    commit_message=$(git log -1 --pretty=%B "$branch_name")
    commit_author=$(git log -1 --pretty=%an "$branch_name")

    if [ -z "$description" ]; then
        description="${commit_message:0:50}"
        [ ${#commit_message} -gt 50 ] && description+="..."
    fi


    menu_items+="${branch_name}\t${description}\t${commit_hash}\t${commit_relative_time}\t${commit_author}\n"
done <<< "$branches"

selected=$(echo -e "$menu_items" | fzf --height=80% --reverse --info=inline \
    --delimiter='\t' \
    --with-nth=1 \
    --preview 'echo -e "\033[1;36mBranch:\033[0m {1}\n\033[1;33mDescription:\033[0m {2}\n\033[1;35mLast Commit:\033[0m {3} ({4}) by {5}\n\n\033[1;32mRecent Commits:\033[0m"; git log -n 5 --oneline --color {1}' \
    --preview-window=right:60%:wrap \
    --color=dark \
    --margin=1,2 \
    --padding=1 \
    --border=rounded \
    --prompt="Select a branch > ")

branch_to_checkout=$(echo "$selected" | cut -f1)

if [ -n "$branch_to_checkout" ]; then
    git checkout "$branch_to_checkout"
else
    echo "No branch selected. Exiting." >&2
    exit 1
fi
