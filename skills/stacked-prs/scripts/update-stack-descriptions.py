#!/usr/bin/env python3
"""
Update PR descriptions for all PRs in a stacked PR chain.

Each PR gets a navigation table at the top of its description showing the full
stack, with the current PR highlighted. Uses git config metadata to discover
the stack and `gh` CLI to read/update PR bodies.

Usage:
    python3 update-stack-descriptions.py [--stack-name NAME] [--repo-url URL]

If --stack-name is omitted, it's inferred from the current branch's git config.
If --repo-url is omitted, it's inferred from `gh repo view`.
"""

import argparse
import json
import os
import re
import subprocess
import sys
import tempfile


def run(cmd, capture=True, check=True):
    result = subprocess.run(cmd, capture_output=capture, text=True, check=check)
    return result.stdout.strip() if capture else None


def get_current_branch():
    return run(["git", "branch", "--show-current"])


def get_stack_name(branch=None):
    if branch is None:
        branch = get_current_branch()
    try:
        return run(["git", "config", "--local", f"branch.{branch}.stack-name"])
    except subprocess.CalledProcessError:
        return None


def get_repo_url():
    result = run(["gh", "repo", "view", "--json", "url", "--jq", ".url"])
    return result


def get_stack_branches(stack_name):
    """Return list of (order, branch) tuples sorted by order."""
    output = run(["git", "config", "--local", "--get-regexp", r"branch\..*\.stack-name"])
    branches = []
    for line in output.splitlines():
        # line format: branch.<name>.stack-name <stack>
        match = re.match(r"branch\.(.+)\.stack-name (.+)", line)
        if match and match.group(2) == stack_name:
            branch = match.group(1)
            try:
                order = int(run(["git", "config", "--local", f"branch.{branch}.stack-order"]))
            except (subprocess.CalledProcessError, ValueError):
                order = 999
            branches.append((order, branch))
    return sorted(branches, key=lambda x: x[0])


def get_pr_info(branch):
    """Get PR number, state, reviewDecision, and url for a branch."""
    try:
        output = run([
            "gh", "pr", "list",
            "--head", branch,
            "--state", "all",
            "--json", "number,state,url,reviewDecision",
            "--jq", ".[0]",
        ])
        if not output:
            return None
        return json.loads(output)
    except (subprocess.CalledProcessError, json.JSONDecodeError):
        return None


def derive_status(pr_info):
    """Derive display status from PR state and reviewDecision."""
    if pr_info is None:
        return "No PR"
    state = pr_info.get("state", "")
    review = pr_info.get("reviewDecision", "")
    if state == "MERGED":
        return "Merged"
    if state == "OPEN":
        if review == "APPROVED":
            return "Approved"
        if review == "CHANGES_REQUESTED":
            return "Changes Requested"
        if review == "REVIEW_REQUIRED":
            return "Review Pending"
        return "Open"
    return "Unknown"


def build_table(stack_name, stack_data, highlight_idx):
    """Build the markdown stack table, highlighting the row at highlight_idx."""
    lines = [
        "<!-- stack:start -->",
        f"### Stack: {stack_name}",
        "| # | PR | Branch | Status |",
        "|---|-----|--------|--------|",
    ]
    for i, (order, branch, pr_info, status) in enumerate(stack_data):
        pr_num = pr_info["number"] if pr_info else None
        url = pr_info["url"] if pr_info else None
        if pr_num and url:
            pr_link = f"[#{pr_num}]({url})"
        else:
            pr_link = "--"

        if i == highlight_idx:
            lines.append(f"| {order} | **{pr_link}** | **{branch}** | **<-- This PR** |")
        else:
            lines.append(f"| {order} | {pr_link} | {branch} | {status} |")
    lines.append("<!-- stack:end -->")
    return "\n".join(lines)


def get_pr_body(pr_number):
    """Get the current body of a PR."""
    try:
        return run(["gh", "pr", "view", str(pr_number), "--json", "body", "--jq", ".body"])
    except subprocess.CalledProcessError:
        return ""


def update_body_with_table(existing_body, new_table):
    """Replace stack markers in body, or prepend if not found."""
    pattern = r"<!-- stack:start -->.*?<!-- stack:end -->"
    if re.search(pattern, existing_body, re.DOTALL):
        return re.sub(pattern, new_table, existing_body, flags=re.DOTALL)
    else:
        if existing_body:
            return new_table + "\n\n" + existing_body
        return new_table


def main():
    parser = argparse.ArgumentParser(description="Update stack PR descriptions")
    parser.add_argument("--stack-name", help="Stack name (inferred from current branch if omitted)")
    args = parser.parse_args()

    stack_name = args.stack_name or get_stack_name()
    if not stack_name:
        print("Error: Could not determine stack name. Use --stack-name or run from a stack branch.", file=sys.stderr)
        sys.exit(1)

    branches = get_stack_branches(stack_name)
    if not branches:
        print(f"Error: No branches found for stack '{stack_name}'.", file=sys.stderr)
        sys.exit(1)

    # Gather PR info for all branches
    stack_data = []
    for order, branch in branches:
        pr_info = get_pr_info(branch)
        status = derive_status(pr_info)
        stack_data.append((order, branch, pr_info, status))

    print(f"Stack: {stack_name} ({len(stack_data)} PRs)")

    # Update each PR's description
    for i, (order, branch, pr_info, status) in enumerate(stack_data):
        if pr_info is None:
            print(f"  ⏭  #{order} {branch} — no PR, skipping")
            continue

        pr_number = pr_info["number"]
        table = build_table(stack_name, stack_data, highlight_idx=i)

        existing_body = get_pr_body(pr_number)
        new_body = update_body_with_table(existing_body, table)

        # Write to temp file to avoid shell escaping issues
        with tempfile.NamedTemporaryFile(mode="w", suffix=".md", delete=False) as f:
            f.write(new_body)
            tmp_path = f.name

        try:
            run(["gh", "pr", "edit", str(pr_number), "--body-file", tmp_path])
            print(f"  ✅ #{pr_number} {branch} ({i + 1}/{len(stack_data)})")
        finally:
            os.unlink(tmp_path)

    print("Done.")


if __name__ == "__main__":
    main()
