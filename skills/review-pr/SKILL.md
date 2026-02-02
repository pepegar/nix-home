---
name: review-pr
description: Review a pull request using team PR patterns - correctness, type safety, naming, testing, configuration, error handling, performance, architecture, cleanup, and storage consistency.
user-invocable: true
disable-model-invocation: true
---

# PR Review Skill

Review pull requests with context from GitHub and Jira, applying team PR review patterns (see pr-review-patterns.md).

## PR Context

### PR Details
!`gh pr view --json title,body,state,author,baseRefName,headRefName,url 2>/dev/null || { PR_NUM=$(git branch --show-current | grep -oE '[0-9]+$'); [ -n "$PR_NUM" ] && gh pr view "$PR_NUM" --json title,body,state,author,baseRefName,headRefName,url 2>/dev/null || echo "No PR found for current branch"; }`

### Changed Files
!`gh pr view --json files --jq '.files[].path' 2>/dev/null || { PR_NUM=$(git branch --show-current | grep -oE '[0-9]+$'); [ -n "$PR_NUM" ] && gh pr view "$PR_NUM" --json files --jq '.files[].path' 2>/dev/null || echo "No PR found"; }`

### Repository Info
!`gh repo view --json owner,name --jq '"\(.owner.login)/\(.name)"' 2>/dev/null || echo "Unknown repo"`

### Head Commit
!`git rev-parse HEAD 2>/dev/null || echo "Unknown commit"`

## Instructions

Follow these steps to review the PR:

### Step 0: Check for Existing Review

Before starting a full review, check if you (the current user) have already reviewed this PR and if there's any new activity since your last review.

1. **Get PR number, repo, and current user**:
```bash
PR_NUM=$(gh pr view --json number --jq '.number' 2>/dev/null || { git branch --show-current | grep -oE '[0-9]+$'; })
REPO=$(gh repo view --json owner,name --jq '"\(.owner.login)/\(.name)"')
CURRENT_USER=$(gh api user --jq '.login')
echo "PR: $PR_NUM, Repo: $REPO, User: $CURRENT_USER"
```

2. **Check for your existing reviews**:
```bash
gh api repos/$REPO/pulls/$PR_NUM/reviews --jq '.[] | select(.user.login == "'$CURRENT_USER'") | {submitted_at, state, id}' | tail -1
```

3. **If you have already reviewed, check for new activity since your last review**:

   a. **Get your last review timestamp**:
   ```bash
   LAST_REVIEW=$(gh api repos/$REPO/pulls/$PR_NUM/reviews --jq '[.[] | select(.user.login == "'$CURRENT_USER'")] | last | .submitted_at')
   echo "Last review: $LAST_REVIEW"
   ```

   b. **Check for new commits after your review**:
   ```bash
   gh api repos/$REPO/pulls/$PR_NUM/commits --jq '.[] | select(.commit.committer.date > "'$LAST_REVIEW'") | {sha: .sha[0:7], date: .commit.committer.date, message: .commit.message | split("\n")[0]}'
   ```

   c. **Check for new comments after your review** (code review comments):
   ```bash
   gh api repos/$REPO/pulls/$PR_NUM/comments --jq '.[] | select(.created_at > "'$LAST_REVIEW'" or .updated_at > "'$LAST_REVIEW'") | {user: .user.login, created: .created_at, body: .body[0:100]}'
   ```

   d. **Check for new issue comments (conversation) after your review**:
   ```bash
   gh api repos/$REPO/issues/$PR_NUM/comments --jq '.[] | select(.created_at > "'$LAST_REVIEW'") | {user: .user.login, created: .created_at, body: .body[0:100]}'
   ```

   e. **Check for replies to your review comments** (threads where you commented):
   ```bash
   gh api repos/$REPO/pulls/$PR_NUM/comments --jq '[.[] | select(.user.login == "'$CURRENT_USER'")] | .[].id' | while read comment_id; do
     gh api repos/$REPO/pulls/$PR_NUM/comments --jq '.[] | select(.in_reply_to_id == '$comment_id' and .created_at > "'$LAST_REVIEW'") | {user: .user.login, created: .created_at, body: .body[0:100]}'
   done
   ```

4. **Decision Logic**:
   - **If no existing review**: Proceed with full review (Steps 1-4)
   - **If existing review AND no new activity**: STOP HERE and output:
     ```
     ## PR Already Reviewed ✓

     You reviewed this PR on [timestamp]. No new commits, comments, or replies have been added since your review.

     **Your last review**: [APPROVED/CHANGES_REQUESTED/COMMENTED]

     No further action needed.
     ```
   - **If existing review AND new activity**: Proceed with review, but focus on:
     - Only the new commits (get diff since your last review)
     - Any replies or comments that need your attention
     - Note this is a **re-review** in your output

### Step 1: Get the PR Diff

Use the Bash tool to get the full diff. If `gh pr diff` fails (e.g., local branch name differs from remote), extract the PR number from the branch name:
```bash
gh pr diff 2>/dev/null || { PR_NUM=$(git branch --show-current | grep -oE '[0-9]+$'); [ -n "$PR_NUM" ] && gh pr diff "$PR_NUM"; }
```

**For re-reviews (when new commits exist since your last review)**: Focus your analysis on changes since your last review. Get the commits added since then and examine only those changes more closely, while keeping the full context in mind.

### Step 2: Extract and Fetch Jira Issues

1. Look for Jira issue references in:
   - PR title and body (shown above)
   - Branch name (shown above in headRefName)
   - Commit messages: `git log $(git merge-base HEAD develop)..HEAD --oneline`

2. Search for patterns like `[A-Z]+-[0-9]+` (e.g., GNC-123, GSC-456)

3. For each Jira issue found, fetch details:
```bash
acli jira workitem view <ISSUE-KEY> --fields '*all' --json
```

### Step 3: Read and Analyze Changed Files

Read each changed file listed above and analyze them against these review patterns (based on team PR review history):

#### A. Code Quality & Correctness
- Off-by-one errors in size checks
- Incorrect null handling patterns
- Does this change break existing functionality?
- Are default values being changed that callers depend on?
- Does refactoring preserve existing behavior?

#### B. Type Safety & API Design
- Prefer value classes over type aliases for domain types (`FolderId`, `ItemId`, `RtcParticipantId`)
- Push back on magic strings - use enums or constants
- Prefer type-safe sealed class hierarchies instead of `Any?` in maps
- Rename generic parameters to be descriptive (e.g., `context` → `caveatContext`)
- Make required fields explicitly required rather than optional

#### C. Naming & Readability
- Method names should describe what they do
- Test names should describe the scenario
- Use `@Nested` inner classes to group related tests instead of comments
- Comments should explain *why*, not *what*
- Remove comments that no longer make sense after refactoring

#### D. Testing Practices
- Use `registry.testClock` instead of `Instant.now()` for deterministic tests
- **DatabaseTestSuite is for recipes, not HTTP helpers** - it combines use-case-level scenarios, not arbitrary endpoint calls
- Minimize DatabaseTestSuite parameters - too many leads to testing invalid combinations
- Test real scenarios, not combinations clients never call
- Sometimes it's better to mock at a higher level than going through full flows

#### E. Configuration & Hardcoded Values
- Should hardcoded durations, limits, thresholds be config values?
- Can values be environment-specific?
- Question hardcoded "magic numbers" without explanation
- Verify feature flags are at 100% before removing code paths

#### F. Error Handling & Logging
- Use structured logging with consistent format
- Include relevant context (e.g., `LogTag.UNMET_ASSUMPTION`)
- Prefer interpolation over concatenation for log messages
- Prefer skipping operations over using arbitrary defaults for nulls
- Error messages should include relevant IDs and context

#### G. Performance Considerations
- **Cache invariant data** - don't check FIFO queue status on every message
- Avoid repeated API calls that add latency and cost
- Database query efficiency (N+1 queries, missing indexes, full table scans)
- Consider maximum database connections during pod scaling
- SpiceDB query patterns (prefer batch operations over individual calls)

#### H. Architecture Decisions
- For FIFO queues: userId vs documentId partition key tradeoffs
- Use optional parameters with sensible defaults for per-callsite behavior
- Default new parameters to preserve existing behavior

#### I. Code Cleanup
- Delete unused classes/methods - don't leave commented-out code
- Share resources instead of creating duplicates (e.g., Redis clients)
- Prefer dependency injection over manual lifecycle management
- Don't call `close()`/`shutdown()` on injected dependencies

#### J. Storage Consistency (CockroachDB + SpiceDB)

This codebase uses:
- **CockroachDB** as the main relational database
- **SpiceDB** for permissions/authorization

**Critical Review Points:**

1. **Retryability over Sagas**: Endpoints should be retryable without compensation. Verify:
   - Operations are idempotent where possible
   - Partial failures leave the system in a state that can be retried
   - No saga/compensation patterns are needed

2. **Partial State Handling**: When an endpoint writes to multiple storages:
   - What happens if CockroachDB write succeeds but SpiceDB write fails?
   - What happens if SpiceDB write succeeds but CockroachDB write fails?
   - Can the operation be safely retried from any failure point?

3. **Write Ordering**: Consider the order of writes:
   - Generally prefer writing to CockroachDB first (source of truth)
   - SpiceDB should reflect permissions based on CockroachDB state
   - If SpiceDB is written first, a retry after CockroachDB failure could leave orphaned permissions

4. **Transaction Boundaries**:
   - CockroachDB operations within a transaction are atomic
   - SpiceDB operations are separate - consider what happens if the transaction commits but SpiceDB fails

5. **ZedToken Consistency**: When using SpiceDB:
   - Are ZedTokens stored appropriately for read-after-write consistency?
   - Is the correct consistency level used for permission checks?

### Step 4: Format the Review

**Important: Terminal Hyperlinks for Code References (OSC 8)**

When referencing specific lines of code, create **clickable terminal hyperlinks** using OSC 8 escape sequences pointing to the PR diff view. This makes links clickable directly in the terminal and opens the exact line in the PR's "Files changed" tab.

**PR Diff URL Format:**
```
https://github.com/{owner}/{repo}/pull/{pr_number}/files#diff-{sha256(filepath)}R{line}
```

Where:
- `{sha256(filepath)}` is the SHA-256 hash of the file path (e.g., `Web/api/src/main/kotlin/WorkspaceApi.kt`)
- `R{line}` = line on the right side (new/current code)
- `L{line}` = line on the left side (old/removed code)

**To compute the hash**, use: `echo -n "path/to/file.kt" | sha256sum | cut -d' ' -f1`

**OSC 8 Format:**
```
\x1b]8;;URL\x1b\\VISIBLE_TEXT\x1b]8;;\x1b\\
```

**Example:**
- Repository: `GoodNotes/GoodNotes-5`
- PR: `51964`
- File: `Web/api/src/main/kotlin/WorkspaceApi.kt` line 76
- Hash: `echo -n "Web/api/src/main/kotlin/WorkspaceApi.kt" | sha256sum` → `a1b2c3d4...`

Would become:
```
\x1b]8;;https://github.com/GoodNotes/GoodNotes-5/pull/51964/files#diff-a1b2c3d4...R76\x1b\\WorkspaceApi.kt:76\x1b]8;;\x1b\\
```

Which renders as clickable text: `WorkspaceApi.kt:76` → opens PR diff at that exact line.

**In your output**, write the actual escape sequences so they render as clickable links. The `\x1b` is the escape character (hex 1B).

Structure your review as:

```
## PR Review: <PR Title>

### Summary
Brief overview of what the PR does and the associated Jira issue(s).

### Requirements Alignment
- [ ] Requirement 1 from Jira - Status
- [ ] Requirement 2 from Jira - Status

### Issues Found

#### Critical (Must Fix)
- [Category] Issue description with file.kt:123 (as clickable OSC 8 hyperlink)

#### Warnings (Should Consider)
- [Category] Issue description with file.kt:123 (as clickable OSC 8 hyperlink)

#### Suggestions (Nice to Have)
- [Category] Suggestion with file.kt:123 (as clickable OSC 8 hyperlink)

Categories: Correctness, Type Safety, Naming, Testing, Configuration, Error Handling, Performance, Architecture, Cleanup, Storage Consistency

### Questions
Any clarifying questions for the PR author.
```

**Note:** All file references like `file.kt:123` should be rendered as OSC 8 terminal hyperlinks pointing to the GitHub blob URL with line numbers.

## Usage

```
/review-pr
```

The skill automatically detects the current PR from the worktree branch. If the local branch name differs from the remote (e.g., `pr-furstenheim-goodnotes-51980` vs `GSC-770-...`), it extracts the PR number from the end of the local branch name.
