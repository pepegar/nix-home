---
name: review-pr
description: Review a pull request using team PR patterns - correctness, type safety, naming, testing, configuration, error handling, performance, architecture, cleanup, and storage consistency.
disable-model-invocation: true
---

# PR Review Skill

Review pull requests with context from GitHub and Jira, applying team PR review patterns with the thoroughness of a senior staff engineer.

## Review Philosophy

You are deliberately nitpicky because you care deeply about code quality. You don't let anything slide with "it's fine for now." You review code as if it will be maintained for the next decade by engineers who have never seen the codebase before.

**Core Principles:**
- Every issue you catch now is a bug, incident, or refactor you prevent later
- "It works" is not the same as "It's good"
- Be direct and specific—vague feedback is useless
- Always explain WHY something is a problem, not just WHAT is wrong
- Provide concrete suggestions or examples when possible
- Don't be mean, but don't sugarcoat either
- If something is genuinely good, acknowledge it—but don't over-praise
- When you see a pattern of issues, call it out as a systemic concern

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

### Step 1: Understand the Context

Before reviewing, you must understand:
- What is the purpose of these changes?
- What ticket/issue does this address?
- What are the acceptance criteria?
- Are there any architectural decisions or trade-offs being made?

If this context is unclear from the PR description and Jira, note it as a question.

**Get the PR Diff:**

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

### Step 3: Systematic Code Review

Read each changed file and analyze them against ALL of the following categories. You MUST check every single one:

#### A. Code Quality & Style
- [ ] Consistent naming conventions (variables, functions, classes)
- [ ] No magic numbers or strings—use constants with meaningful names
- [ ] Functions/methods are focused and do one thing well
- [ ] No unnecessary complexity or over-engineering
- [ ] Dead code removed (no commented-out code unless with explicit rationale)
- [ ] Appropriate use of language idioms and patterns
- [ ] Line length and formatting consistency
- [ ] Method names should describe what they do
- [ ] Comments should explain *why*, not *what*
- [ ] Remove comments that no longer make sense after refactoring

#### B. Logic & Correctness
- [ ] Edge cases handled (null, empty, boundary conditions)
- [ ] Off-by-one errors in size checks
- [ ] Incorrect null handling patterns
- [ ] Correct use of equality vs identity checks
- [ ] Race conditions considered in concurrent code
- [ ] Resource cleanup (files, connections, memory)
- [ ] Does this change break existing functionality?
- [ ] Are default values being changed that callers depend on?
- [ ] Does refactoring preserve existing behavior?

#### C. Type Safety & API Design
- [ ] Prefer value classes over type aliases for domain types (`FolderId`, `ItemId`, `RtcParticipantId`)
- [ ] Push back on magic strings - use enums or constants
- [ ] Prefer type-safe sealed class hierarchies instead of `Any?` in maps
- [ ] Rename generic parameters to be descriptive (e.g., `context` → `caveatContext`)
- [ ] Make required fields explicitly required rather than optional
- [ ] Flag direct `.unsafeValue` access on `UserInput<T>` wrappers — use `assertActorCanAccessWorkspace()`, `resolveDocumentAndAuthorizeAction()`, or similar safe-extraction methods that validate and authorize in one step

#### D. Testing Practices
- [ ] Unit tests cover the new/changed code
- [ ] Tests are meaningful (not just coverage padding)
- [ ] Edge cases tested
- [ ] Test names clearly describe the scenario
- [ ] No flaky test patterns
- [ ] Integration tests if behavior crosses boundaries
- [ ] Use `registry.testClock` instead of `Instant.now()` for deterministic tests
- [ ] Repositories and use cases that compute timestamps should accept `java.time.Clock` as a constructor parameter
- [ ] Use `@Nested` inner classes to group related tests instead of comments
- [ ] **DatabaseTestSuite is for recipes, not HTTP helpers** - it combines use-case-level scenarios, not arbitrary endpoint calls
- [ ] Minimize DatabaseTestSuite parameters - too many leads to testing invalid combinations
- [ ] Test real scenarios, not combinations clients never call
- [ ] Sometimes it's better to mock at a higher level than going through full flows

#### E. Security
- [ ] No hardcoded secrets, credentials, or API keys
- [ ] Input validation present where needed
- [ ] SQL injection, XSS, and injection attacks prevented
- [ ] Authentication/authorization checks in place
- [ ] Sensitive data not logged
- [ ] No exposure of internal implementation details

#### F. Configuration & Hardcoded Values
- [ ] Should hardcoded durations, limits, thresholds be config values?
- [ ] Can values be environment-specific?
- [ ] Question hardcoded "magic numbers" without explanation
- [ ] Verify feature flags are at 100% before removing code paths

#### G. Error Handling & Logging
- [ ] Error handling is comprehensive and appropriate
- [ ] Use structured logging with consistent format
- [ ] Include relevant context (e.g., `LogTag.UNMET_ASSUMPTION`)
- [ ] Prefer interpolation over concatenation for log messages
- [ ] Prefer skipping operations over using arbitrary defaults for nulls
- [ ] Error messages should include relevant IDs and context
- [ ] Errors include sufficient context for debugging

#### H. Performance
- [ ] No N+1 queries or unnecessary database calls
- [ ] Appropriate use of caching where beneficial
- [ ] No blocking operations in async contexts
- [ ] Memory usage considered (no leaks, appropriate data structures)
- [ ] Algorithm complexity is acceptable
- [ ] **Cache invariant data** - don't check FIFO queue status on every message
- [ ] Avoid repeated API calls that add latency and cost
- [ ] **Composite primary key queries**: When a table has a composite PK like `(collocation_id, item_id)`, querying by `item_id` alone causes a full sequential scan — always include the leading column
- [ ] Consider maximum database connections during pod scaling
- [ ] SpiceDB query patterns (prefer batch operations over individual calls)
- [ ] **Distributed lock scope minimization**: Only operations that require mutual exclusion (e.g., SpiceDB writes + ZedToken updates) should be inside workspace locks

#### I. Architecture & Design
- [ ] Changes follow existing patterns in the codebase
- [ ] Appropriate separation of concerns
- [ ] Dependencies flow in the right direction
- [ ] No circular dependencies introduced
- [ ] SOLID principles respected
- [ ] Changes don't violate the module's boundaries
- [ ] For FIFO queues: userId vs documentId partition key tradeoffs
- [ ] Use optional parameters with sensible defaults for per-callsite behavior
- [ ] Default new parameters to preserve existing behavior
- [ ] **UseCaseDsl pattern**: Use cases that resolve documents/folders and check authorization should extend `UseCaseDsl(authService, documentDatabaseService)`
- [ ] **assertActorCanAccessWorkspace**: Use `authorizationService.assertActorCanAccessWorkspace(actor.guid, userInputWorkspaceId)` to safely extract workspace IDs and validate access in one call

#### J. Code Cleanup
- [ ] Delete unused classes/methods - don't leave commented-out code
- [ ] Share resources instead of creating duplicates (e.g., Redis clients)
- [ ] Prefer dependency injection over manual lifecycle management
- [ ] Don't call `close()`/`shutdown()` on injected dependencies

#### K. Documentation & Observability
- [ ] Public APIs documented
- [ ] Complex logic has explanatory comments (but code should be self-documenting where possible)
- [ ] README updated if setup/usage changed
- [ ] Breaking changes documented
- [ ] Appropriate logging at correct levels
- [ ] Metrics added for important operations
- [ ] Tracing context preserved

#### L. Storage Consistency (CockroachDB + SpiceDB)

This codebase uses:
- **CockroachDB** as the main relational database
- **SpiceDB** for permissions/authorization

**Authoritative vs Metadata roles vary per endpoint.** For some endpoints, CockroachDB is the authoritative (data) store and SpiceDB holds derived metadata; for others, SpiceDB is authoritative and CockroachDB holds metadata. When reviewing, identify which storage is authoritative for the specific operation — this determines write ordering, retry semantics, and what happens during partial failures.

**Critical Review Points:**

1. **Retryability over Sagas**: Endpoints should be retryable without compensation. Verify:
   - [ ] Operations are idempotent where possible
   - [ ] Partial failures leave the system in a state that can be retried
   - [ ] No saga/compensation patterns are needed
   - [ ] **Prefer upsert (`ON CONFLICT DO UPDATE`) over insert + idempotency guards** — simplifies multi-storage retry flows

2. **Partial State Handling**: When an endpoint writes to multiple storages:
   - [ ] What happens if CockroachDB write succeeds but SpiceDB write fails?
   - [ ] What happens if SpiceDB write succeeds but CockroachDB write fails?
   - [ ] Can the operation be safely retried from any failure point?

3. **Write Ordering**: Consider the order of writes:
   - [ ] Write to the **authoritative** storage first, then the metadata storage
   - [ ] The authoritative storage depends on the endpoint: for some operations CockroachDB is authoritative, for others SpiceDB is
   - [ ] If the metadata write fails after the authoritative write succeeds, a retry should be safe

4. **Transaction Boundaries**:
   - [ ] CockroachDB operations within a transaction are atomic
   - [ ] SpiceDB operations are separate - consider what happens if the transaction commits but SpiceDB fails

5. **ZedToken Consistency**: When using SpiceDB:
   - [ ] Are ZedTokens stored appropriately for read-after-write consistency?
   - [ ] Is the correct consistency level used for permission checks?

6. **Lock Scope**: When using distributed locks (e.g., workspace locks):
   - [ ] Only SpiceDB permission writes + ZedToken updates should be inside the lock
   - [ ] CockroachDB reads/writes can often happen outside the lock when they don't require atomicity with SpiceDB operations
   - [ ] Minimizing lock scope reduces contention and latency

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

### 🚫 Blockers (Must Fix)
Issues that absolutely must be addressed before merge. These will cause bugs, security issues, or significant problems.

- [Category] Issue description with file.kt:123 (as clickable OSC 8 hyperlink)
  - **Why**: Explanation of the problem
  - **Suggestion**: Concrete fix or example

### ⚠️ Significant Issues (Should Fix)
Important problems that should be fixed but might not be merge-blocking depending on context.

- [Category] Issue description with file.kt:123 (as clickable OSC 8 hyperlink)
  - **Why**: Explanation of the problem
  - **Suggestion**: Concrete fix or example

### 💭 Suggestions (Nice to Have)
Improvements that would make the code better but are optional.

- [Category] Suggestion with file.kt:123 (as clickable OSC 8 hyperlink)

### ❓ Questions
Things you need clarified or decisions you want the author to justify.

### ✅ What's Good
Acknowledge things done well—be tough but fair.

Categories: Code Quality, Correctness, Type Safety, Testing, Security, Configuration, Error Handling, Performance, Architecture, Cleanup, Documentation, Storage Consistency
```

## Usage

```
/review-pr
```

The skill automatically detects the current PR from the worktree branch. If the local branch name differs from the remote (e.g., `pr-furstenheim-goodnotes-51980` vs `GSC-770-...`), it extracts the PR number from the end of the local branch name.
