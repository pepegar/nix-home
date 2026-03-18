---
name: meaningful-commits
description: Create small, meaningful git commits from the current working tree. Use when the user asks to "commit", "add meaningful commits", "split commits", "commit my changes", "create commits", or wants to organize uncommitted changes into well-structured, atomic git commits.
allowed-tools: Bash
---

# Meaningful Commits

Create small, atomic git commits that each represent a single logical change. Every commit should be self-contained and pass tests independently.

## Workflow

1. **Read the current state** — run `git status` and `git diff` (both staged and unstaged) to understand all pending changes.

2. **Infer the commit message format** — run `git log --oneline -10` and match the style of recent commits (conventional commits, imperative mood, ticket prefixes, etc.). Do not assume a format.

3. **Group changes by logical unit** — identify distinct changes that belong together:
   - A new feature (new files + their imports/wiring)
   - A bug fix (the fix + any test updates)
   - A refactor (renamed/moved code)
   - Config/build changes
   - Test additions or fixes
   - Documentation updates

4. **Order commits logically** — dependencies first. For example: new utility before the feature that uses it, refactor before the feature that builds on it.

5. **Show the plan first** — before creating any commits, tell the user how you plan to split the changes and ask for confirmation.

6. **For each logical group**, stage only the relevant files and create a commit:
   ```bash
   git add <specific files>
   git commit -m "<message matching inferred format>"
   ```

7. **Verify** after all commits — run `git log --oneline` to show the user the result.

## Rules

- **Never use `git add .` or `git add -A`** — always stage specific files by name.
- **Never skip hooks** — no `--no-verify`.
- **Read before staging** — use `git diff <file>` if unsure what a file contains.
- **One concern per commit** — if a file has changes for two different purposes, consider whether it belongs in one commit or the other (stage it with the group it's most related to).
- **Don't create empty commits**.
- **Don't amend existing commits** — always create new ones.
