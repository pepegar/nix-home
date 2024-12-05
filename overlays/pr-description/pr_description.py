from pathlib import Path
import openai
import os
import sys
import argparse
from termcolor import colored

def debug_print(message, debug=False):
    """Print debug messages in yellow if debug mode is enabled"""
    if debug:
        print(colored(f"[DEBUG] {message}", 'yellow'), file=sys.stderr)

def find_parent_branch(debug=False):
    """Find the parent branch by looking at the git log"""
    # Get all branches that aren't the current one
    debug_print("Finding parent branch", debug)
    os.system("git branch | grep -v '^*' > /tmp/branches.txt")
    with open("/tmp/branches.txt", "r") as f:
        branches = [b.strip() for b in f.readlines()]
    
    # Find the merge-base with each branch and get the most recent one
    latest_commit = None
    parent_branch = None
    
    for branch in branches:
        os.system(f"git merge-base HEAD {branch} > /tmp/merge-base.txt")
        with open("/tmp/merge-base.txt", "r") as f:
            merge_base = f.read().strip()
            
        if not merge_base:
            continue
            
        # Get the commit timestamp
        os.system(f"git show -s --format=%ct {merge_base} > /tmp/commit_time.txt")
        with open("/tmp/commit_time.txt", "r") as f:
            commit_time = int(f.read().strip())
            
        if latest_commit is None or commit_time > latest_commit:
            latest_commit = commit_time
            parent_branch = branch

    debug_print(f"Found parent branch: {parent_branch}", debug)
    
    return parent_branch.strip() if parent_branch else "develop"

def get_commit_messages(parent_branch, debug=False):
    debug_print(f"Getting commit messages between HEAD and {parent_branch}", debug)
    cmd = f"git log --format=%B HEAD...$(git merge-base HEAD {parent_branch})"
    debug_print(f"Running command: {cmd}", debug)
    
    os.system(f"{cmd} > /tmp/commits.txt")
    with open("/tmp/commits.txt", "r") as f:
        commits = f.read()
    debug_print(f"Found {len(commits.splitlines())} commit messages", debug)
    return commits

def get_diff(parent_branch, debug=False):
    debug_print(f"Getting diff between HEAD and {parent_branch}", debug)
    cmd = f"git diff $(git merge-base HEAD {parent_branch})"
    debug_print(f"Running command: {cmd}", debug)
    
    os.system(f"{cmd} > /tmp/diff.txt")
    with open("/tmp/diff.txt", "r") as f:
        diff = f.read()
    debug_print(f"Diff size: {len(diff)} characters", debug)
    return diff

def get_pr_description(debug=False):
    parent_branch = find_parent_branch(debug)
    commits = get_commit_messages(parent_branch, debug)
    diff = get_diff(parent_branch, debug)

    client = openai.OpenAI(base_url="http://localhost:1234/v1", api_key="lm-studio")
    debug_print("Making API request to LM Studio", debug)

    prompt_template = f"""
Based on the provided commit messages and diff, create a pull request description in the following format:

```markdown
# [Concise Title Summarizing the Main Change]

[2-3 sentence overview of what this PR does and why]

[for area_modified in areas_modified]
## [Name of First Component/Area Modified]

[Detailed description of changes in this area]
[endfor]

## Considerations

- [List any gotchas, warnings, or things reviewers should pay special attention to]
- [Include any deployment considerations]
- [Note any potential side effects]
```

Only return the markdown description, with no additional text. Replace the bracketed placeholders with actual content based on these changes:

Commit Messages:
{commits}

Diff:
{diff}
    """
    
    try:
        response = client.chat.completions.create(
            model="llama-3.2-3b-instruct",
            messages=[
                {
                    "role": "system", 
                    "content": "You are a helpful assistant that writes pull request descriptions based on commit messages and diffs."
                },
                {
                    "role": "user",
                    "content": prompt_template
                }
            ]
        )
        debug_print("Successfully received response from API", debug)
        return response.choices[0].message.content
    except Exception as e:
        error_msg = f"Error generating PR description: {e}"
        debug_print(colored(error_msg, 'red'), debug)
        return commits

def main():
    parser = argparse.ArgumentParser(description='Generate PR descriptions from commit messages and diffs.')
    parser.add_argument('--debug', action='store_true', help='Enable debug output')
    args = parser.parse_args()
    
    print(get_pr_description(args.debug))

if __name__ == "__main__":
    main()
