---
name: run-tests
description: Run the minimum set of gradle tests needed for changed files. Supports modes - staged (default), pr (all PR files), or a specific module path.
argument-hint: "[staged|pr|module-path]"
user-invocable: true
disable-model-invocation: true
---

# Run Tests Skill

Run only the gradle tests that are relevant to changed files. This skill analyzes which files have changed and maps them to their corresponding gradle modules.

**Mode:** `$ARGUMENTS`

## Modes

- **`/run-tests`** or **`/run-tests staged`** - Run tests for currently staged/uncommitted files only
- **`/run-tests pr`** - Run tests for all files changed in the PR
- **`/run-tests :Web:api`** - Run tests for a specific module directly

## Context for Each Mode

### Staged/Uncommitted Files (default)
!`git diff --name-only HEAD 2>/dev/null; git diff --name-only --cached 2>/dev/null`

### PR Files
!`gh pr view --json files --jq '.files[].path' 2>/dev/null || { PR_NUM=$(git branch --show-current | grep -oE '[0-9]+$'); [ -n "$PR_NUM" ] && gh pr view "$PR_NUM" --json files --jq '.files[].path' 2>/dev/null; } || echo "No PR found"`

### PR Number (for reference)
!`gh pr view --json number --jq '.number' 2>/dev/null || { git branch --show-current | grep -oE '[0-9]+$'; } || echo "No PR"`

## Instructions

### Step 0: Determine Mode from Arguments

Check the `$ARGUMENTS` value above:

1. **Empty or "staged"**: Use the "Staged/Uncommitted Files" list above
2. **"pr"**: Use the "PR Files" list above
3. **Starts with ":"** (e.g., `:Web:api`): Run that specific module's tests directly, skip to Step 3

### Step 1: Identify Affected Gradle Modules

Analyze the changed files from the appropriate list and extract gradle module paths:

1. **Extract module path**: Take the path before `/src/` directory
   - `Web/api/src/main/kotlin/Foo.kt` → `Web/api`
   - `WebCommons/permissions/src/test/kotlin/Bar.kt` → `WebCommons/permissions`
   - `Accounts/worker/src/main/kotlin/Baz.kt` → `Accounts/worker`

2. **Convert to gradle notation**: Replace `/` with `:` and prefix with `:`
   - `Web/api` → `:Web:api`
   - `WebCommons/permissions` → `:WebCommons:permissions`
   - `Web/cold_storage_worker/event_archiver` → `:Web:cold_storage_worker:event_archiver`

3. **Handle nested modules**: Some modules have deeper nesting
   - `Web/cold_storage_worker/event_archiver/src/...` → `:Web:cold_storage_worker:event_archiver`
   - `WebCommons/messaging/sqs/src/...` → `:WebCommons:messaging:sqs`

4. **Ignore non-gradle files**: Skip files that don't belong to gradle modules:
   - Root config files (`.github/`, `gradle/`, `*.md`, etc.)
   - iOS/Swift files (`CommonSwift/` unless they have java/kotlin submodules)
   - Files without `/src/` in their path that aren't build files

5. **Deduplicate modules**: Multiple files in the same module only need one test run

### Step 2: Verify Modules Have Tests

Check if each module has test sources:

```bash
ls -la <module-path>/src/test/ 2>/dev/null
```

Skip modules without tests.

### Step 3: Run Tests

Combine all test tasks into a single gradle invocation:

```bash
SKIP_SWIFT_COMPILATION=true REUSE_CONTAINERS_FOR_TESTS=true SKIP_SLOW_SSO_DB=true ./gradlew :Module1:test :Module2:test
```

**For a specific module (when argument starts with ":"):**
```bash
SKIP_SWIFT_COMPILATION=true REUSE_CONTAINERS_FOR_TESTS=true SKIP_SLOW_SSO_DB=true ./gradlew $ARGUMENTS:test
```

### Step 4: Report Results

```
## Test Results

### Mode
[staged|pr|specific-module]

### Modules Tested
- :Module1:test ✓
- :Module2:test ✗ (X failures)

### Failures (if any)
- TestClass.testMethod: Error message

### Summary
X modules tested, Y passed, Z failed
```

## Module Reference

| Folder | Gradle Prefix | Notes |
|--------|---------------|-------|
| `Accounts/` | `:Accounts:` | Account services |
| `DataConsistency/` | `:DataConsistency:` | Data consistency |
| `Invitations/` | `:Invitations:` | Invitation services |
| `Multiplatform/` | `:Multiplatform:` | Multiplatform code |
| `NotificationsService/` | `:NotificationsService:` | Notifications |
| `Organizations/` | `:Organizations:` | Organization services |
| `UserAttributes/` | `:UserAttributes:` | User attributes |
| `UserDiscovery/` | `:UserDiscovery:` | User discovery |
| `Web/` | `:Web:` | Web services (largest) |
| `WebCollaboration/` | `:WebCollaboration:` | Collaboration features |
| `WebCommons/` | `:WebCommons:` | Shared utilities |
| `WebShared/` | `:WebShared:` | Shared tools |
| `web-documents-import/` | `:web-documents-import:` | Document import |

## Usage Examples

```bash
/run-tests              # Test modules with staged/uncommitted changes
/run-tests staged       # Same as above (explicit)
/run-tests pr           # Test all modules changed in the PR
/run-tests :Web:api     # Test a specific module directly
```

## Notes

- Focuses on **gradle tests only** (Kotlin/Java modules)
- Swift/iOS tests are not included
- If no gradle modules are affected, reports "No gradle tests to run"
- Environment variables speed up execution by skipping unnecessary compilation
