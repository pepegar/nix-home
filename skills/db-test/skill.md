---
name: db-test
description: Run DatabaseTestSuite-based tests in the GoodNotes codebase. Accepts a test class name, file path, or pattern.
argument-hint: "<test-class-or-pattern>"
user-invocable: true
allowed-tools: Bash, Glob, Grep, Read
---

# Run DatabaseTestSuite Tests

Run tests that use `DatabaseTestSuite` from the GoodNotes codebase. These are integration tests that extend `WebApiBaseDatabaseTest` and create real test data.

## Arguments

- `$ARGUMENTS` should contain one of:
  - **Test class name**: e.g., `CommentApiTestWebApi` or `CommentApiTestWebApi.kt`
  - **Fully qualified class**: e.g., `com.goodnotes.api.components.api.CommentApiTestWebApi`
  - **File path**: e.g., `Web/api/src/test/kotlin/com/goodnotes/api/components/api/CommentApiTestWebApi.kt`
  - **Test method**: e.g., `CommentApiTestWebApi.post comment thread api`
  - **Pattern**: e.g., `*Comment*` to run all matching tests
  - Empty: List recently modified test files using DatabaseTestSuite

## Instructions

### Step 1: Parse Arguments

If `$ARGUMENTS` is empty:
- List test files that use DatabaseTestSuite, sorted by modification time
- Show the user the top 10 and ask which one to run

If `$ARGUMENTS` is provided:
- If it's a file path, extract the class name from the file
- If it contains a `.` followed by text with spaces, it's a test method pattern
- Otherwise treat it as a class name or pattern

### Step 2: Locate the Test

Find the test file:

```bash
# If it's a file path, use it directly
# Otherwise search for the test class
fd -t f "$CLASS_NAME.kt" Web/api/src/test/
```

Or using glob:
```bash
# Pattern search
ls Web/api/src/test/**/*$PATTERN*.kt
```

### Step 3: Verify it Uses DatabaseTestSuite

Check the file imports or uses DatabaseTestSuite:

```bash
grep -l "DatabaseTestSuite" "$FILE_PATH"
```

If it doesn't use DatabaseTestSuite, warn the user but proceed anyway.

### Step 4: Run the Test

Run the test using gradle with the performance flags:

```bash
SKIP_SWIFT_COMPILATION=true REUSE_CONTAINERS_FOR_TESTS=true SKIP_SLOW_SSO_DB=true ./gradlew :Web:api:test --tests "$QUALIFIED_CLASS_NAME"
```

For a specific test method:
```bash
SKIP_SWIFT_COMPILATION=true REUSE_CONTAINERS_FOR_TESTS=true SKIP_SLOW_SSO_DB=true ./gradlew :Web:api:test --tests "$QUALIFIED_CLASS_NAME.$METHOD_PATTERN"
```

For patterns:
```bash
SKIP_SWIFT_COMPILATION=true REUSE_CONTAINERS_FOR_TESTS=true SKIP_SLOW_SSO_DB=true ./gradlew :Web:api:test --tests "*$PATTERN*"
```

### Step 5: Report Results

Display:
- Test class/pattern that was run
- Pass/fail status
- For failures, show the error message and relevant stack trace
- Link to the HTML test report if available

## Examples

```bash
/db-test CommentApiTestWebApi
# Runs all tests in CommentApiTestWebApi

/db-test CommentApiTestWebApi.post comment thread
# Runs tests matching "post comment thread" in CommentApiTestWebApi

/db-test *Tombstone*
# Runs all test classes with "Tombstone" in the name

/db-test Web/api/src/test/kotlin/com/goodnotes/api/components/api/CommentApiTestWebApi.kt
# Runs tests from the specified file

/db-test
# Lists recent DatabaseTestSuite test files to choose from
```

## Test Locations

DatabaseTestSuite tests are located in:
- `Web/api/src/test/kotlin/com/goodnotes/api/components/` - API tests
- `Web/api/src/test/kotlin/com/goodnotes/usecases/` - Use case tests
- `Web/api/src/test/kotlin/com/goodnotes/cold_storage/` - Cold storage tests

## Environment Variables

These environment variables speed up test execution by reusing containers:
- `SKIP_SWIFT_COMPILATION=true` - Skip Swift compilation
- `REUSE_CONTAINERS_FOR_TESTS=true` - Reuse test containers
- `SKIP_SLOW_SSO_DB=true` - Skip slow SSO database setup

## Notes

- Tests extend `WebApiBaseDatabaseTest` which provides the test infrastructure
- `DatabaseTestSuite` is used for creating test data (users, documents, etc.)
- First run may be slow (~30-50s) due to container startup; subsequent runs are faster
- To enable container reuse, ensure `~/.testcontainers.properties` contains `testcontainers.reuse.enable=true`

## Test Style Guide

When writing new tests, follow the patterns in existing `*WebApi.kt` test files:

### Class Structure

```kotlin
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class MyFeatureTestWebApi : WebApiBaseDatabaseTest() {

    @Test
    fun `descriptive test name with backticks`(): Unit = runBlocking {
        // test body
    }
}
```

### Creating Test Data

Use `DatabaseTestSuite` helper methods:

```kotlin
// Simple cases - use static helpers
val user = DatabaseTestSuite.userWithPrivateDoc(testApp)
val user = DatabaseTestSuite.userWithLegacyPrivateDocAndPage(testApp)
val user = DatabaseTestSuite.emptyUser(testApp)

// Complex cases - use the Helper builder
val testData = DatabaseTestSuite.Helper()
    .withUser()
    .withRootFolder()
    .withFolder()
    .withPrivateDocument()
    .withNewPage()
    .withPenStrokeNote()
    .build(testApp)
val user = testData.users[0]
```

### Making API Calls

Use extension methods from `TestAppApiExtensions` when available:

```kotlin
// Preferred - use typed extension methods
val response = testApp.notesApiGetNotes(user, document)
val listing = testApp.libraryApiGetSharingListing(user)

// For custom/error cases - use raw HTTP calls
testApp.apply {
    val response = handlePost("/v1/users/{userId}/documents/{documentId}") {
        path = mapOf(
            "userId" to user.uuid.toString(),
            "documentId" to document.documentId.toString()
        )
        queryParams = listOf("param" to "value")
        body = request.serialize()
        principal = user.accountInfo
    }
    assertEquals(HttpStatusCode.OK, response.status)
}
```

### Assertions

Use AssertJ's `assertThat` for rich assertions:

```kotlin
import org.assertj.core.api.Assertions.assertThat

assertThat(response.notes).hasSize(2)
assertThat(result).isInstanceOf(MyResponse::class.java)
assertThat(response.headers["X-Error-Type"]).contains("DocumentNotFound")
```

Use kotlin.test for simple equality:

```kotlin
assertEquals(HttpStatusCode.NotFound, response.status)
expect(expectedValue) { actualValue }
```

### Test Naming

Use descriptive names in backticks that describe the scenario:

```kotlin
@Test
fun `Uploading notes into an unshared document returns client error`() = ...

@Test
fun `get notes should return checksum of note groups`() = ...

@Test
fun `race condition should NOT happen when 2 ppl try to upload notes`() = ...
```

### Accessing Test Data

```kotlin
val user = testData.users[0]
val document = user.documents[0]
val page = document.testPages[0]
val groupId = page.getGroupId()
val (_, documentId, shareId) = document.documentShare
```
