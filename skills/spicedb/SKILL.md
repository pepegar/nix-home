---
name: spicedb
description: SpiceDB client documentation and API reference. Use when working with SpiceDB, Authzed, permissions, authorization, relationships, caveats, ZedTokens, or implementing ReBAC (Relationship-Based Access Control).
---

# SpiceDB Client Documentation

SpiceDB is an open-source, Google Zanzibar-inspired database for storing and querying fine-grained authorization data. It answers the question: "Can subject X perform action Y on resource Z?"

## Official Client Libraries

AuthZed maintains gRPC client libraries for:

| Language | Repository | Package |
|----------|------------|---------|
| Go | github.com/authzed/authzed-go | `go get github.com/authzed/authzed-go` |
| Python | github.com/authzed/authzed-py | `pip install authzed` |
| Node.js | github.com/authzed/authzed-node | `npm install @authzed/authzed-node` |
| Java | github.com/authzed/authzed-java | Maven: `com.authzed.api:authzed` |
| Ruby | github.com/authzed/authzed-rb | `gem install authzed` |
| .NET | github.com/authzed/authzed-dotnet | NuGet: `Authzed.Api` |

## API Methods

### Core Permission Operations

| Method | Purpose |
|--------|---------|
| `CheckPermission` | Check if subject has permission on resource |
| `BulkCheckPermission` | Batch multiple permission checks in one call |
| `LookupResources` | Find all resources a subject can access |
| `LookupSubjects` | Find all subjects with permission on a resource |
| `ExpandPermissionTree` | Get the permission tree for debugging |

### Relationship Operations

| Method | Purpose |
|--------|---------|
| `WriteRelationships` | Create/update relationships (TOUCH/CREATE/DELETE operations) |
| `DeleteRelationships` | Remove relationships matching a filter |
| `ReadRelationships` | Query existing relationships |
| `BulkImportRelationships` | Import large batches (ExperimentalService) |
| `BulkExportRelationships` | Export relationships for backup |

### Schema Operations

| Method | Purpose |
|--------|---------|
| `ReadSchema` | Get the current schema |
| `WriteSchema` | Update the schema |

### Streaming Operations

| Method | Purpose |
|--------|---------|
| `Watch` | Stream relationship changes in real-time |

## Consistency Modes

SpiceDB offers four consistency levels via the `Consistency` field in requests:

### 1. Minimize Latency (Default for reads)
```
Consistency { minimize_latency: true }
```
Uses cached data for speed. Risk of stale permissions (New Enemy Problem).

### 2. At Least As Fresh
```
Consistency { at_least_as_fresh: ZedToken { token: "..." } }
```
Data is at least as fresh as the provided ZedToken. Best for read-after-write consistency.

### 3. At Exact Snapshot
```
Consistency { at_exact_snapshot: ZedToken { token: "..." } }
```
Data from exact point-in-time. Can fail with "Snapshot Expired" if garbage collected.

### 4. Fully Consistent
```
Consistency { fully_consistent: true }
```
Bypasses all caching. Highest latency but guaranteed freshness.

### Default Consistency by API

| API | Default |
|-----|---------|
| WriteRelationships | fully_consistent |
| DeleteRelationships | fully_consistent |
| ReadSchema, WriteSchema | fully_consistent |
| All others | minimize_latency |

## ZedTokens

ZedTokens represent a point-in-time snapshot of the datastore. They protect against the "New Enemy Problem" where cached permissions become stale.

**Store ZedTokens when:**
- Resources are created/deleted
- Resource contents change
- Access permissions are modified

**Storage:** Use `text` or `varchar(1024)` in PostgreSQL.

**APIs returning ZedTokens:**
- CheckPermission
- BulkCheckPermission
- WriteRelationships
- DeleteRelationships

## Schema Language

### Basic Definition
```zed
definition user {}

definition document {
  relation owner: user
  relation reader: user | user:*
  relation writer: user

  permission read = reader + writer + owner
  permission write = writer + owner
  permission delete = owner
}
```

### Permission Operators
- `+` (Union): Combines sets
- `&` (Intersection): Requires both conditions
- `-` (Exclusion): Removes subjects
- `->` (Arrow): Traverses relationships

### Subject Relations
```zed
definition group {
  relation member: user
}

definition document {
  relation viewer: user | group#member
}
```

### Wildcards (Public Access)
```zed
relation viewer: user | user:*
```
Write as: `document:public#viewer@user:*`

## Caveats (Conditional Permissions)

Caveats enable ABAC-style conditional permissions evaluated at check time.

### Defining Caveats
```zed
caveat ip_allowlist(user_ip ipaddress, allowed_cidr string) {
  user_ip.in_cidr(allowed_cidr)
}

caveat time_window(current_time timestamp, expires_at timestamp) {
  current_time < expires_at
}
```

### Supported Types
`int`, `uint`, `bool`, `string`, `double`, `bytes`, `duration`, `timestamp`, `list<T>`, `map<T>`, `any`, `ipaddress`

### Using Caveats in Schema
```zed
definition document {
  relation viewer: user | user with ip_allowlist
  permission view = viewer
}
```

### Writing Caveated Relationships
```go
// Go example
client.WriteRelationships(ctx, &v1.WriteRelationshipsRequest{
  Updates: []*v1.RelationshipUpdate{{
    Operation: v1.RelationshipUpdate_OPERATION_TOUCH,
    Relationship: &v1.Relationship{
      Resource: &v1.ObjectReference{ObjectType: "document", ObjectId: "1"},
      Relation: "viewer",
      Subject: &v1.SubjectReference{Object: &v1.ObjectReference{ObjectType: "user", ObjectId: "alice"}},
      OptionalCaveat: &v1.ContextualizedCaveat{
        CaveatName: "ip_allowlist",
        Context: structpb.NewStruct(map[string]interface{}{"allowed_cidr": "10.0.0.0/8"}),
      },
    },
  }},
})
```

### Checking with Caveat Context
```go
resp, err := client.CheckPermission(ctx, &v1.CheckPermissionRequest{
  Resource:   &v1.ObjectReference{ObjectType: "document", ObjectId: "1"},
  Permission: "view",
  Subject:    &v1.SubjectReference{Object: &v1.ObjectReference{ObjectType: "user", ObjectId: "alice"}},
  Context:    structpb.NewStruct(map[string]interface{}{"user_ip": "10.1.2.3"}),
})
```

### CheckPermission Response States
- `PERMISSIONSHIP_HAS_PERMISSION` - Access granted
- `PERMISSIONSHIP_NO_PERMISSION` - Access denied
- `PERMISSIONSHIP_CONDITIONAL_PERMISSION` - Missing required context

## Client Configuration

### Without TLS (Local Development)

**Go:**
```go
client, err := authzed.NewClient(
  "localhost:50051",
  grpcutil.WithInsecureBearerToken("your-token"),
  grpc.WithTransportCredentials(insecure.NewCredentials()),
)
```

**Python:**
```python
from authzed.api.v1 import Client
from grpcutil import insecure_bearer_token_credentials

client = Client("localhost:50051", insecure_bearer_token_credentials("your-token"))
```

**Node.js:**
```javascript
const { v1 } = require("@authzed/authzed-node");
const client = v1.NewClient("your-token", "localhost:50051", v1.ClientSecurity.INSECURE_PLAINTEXT_CREDENTIALS);
```

**Java:**
```java
ManagedChannel channel = ManagedChannelBuilder.forTarget("localhost:50051").usePlaintext().build();
```

### With TLS (Production)
Use proper TLS credentials and certificate verification for production deployments.

## Watch API

Monitor relationship changes in real-time:

```go
stream, err := client.Watch(ctx, &v1.WatchRequest{
  OptionalObjectTypes: []string{"document"},
  OptionalStartCursor: lastZedToken, // Resume from last position
})

for {
  resp, err := stream.Recv()
  if err != nil {
    break
  }
  for _, update := range resp.Updates {
    // Process relationship change
  }
  lastZedToken = resp.ChangesThrough
}
```

**Events triggered by:** WriteRelationships, DeleteRelationships, ImportBulkRelationships

## Common Patterns

### Write Pattern with ZedToken Storage
```go
// 1. Write relationship
resp, err := client.WriteRelationships(ctx, request)
if err != nil {
  return err
}

// 2. Store ZedToken alongside resource in your database
db.Exec("UPDATE resources SET zed_token = $1 WHERE id = $2",
  resp.WrittenAt.Token, resourceID)
```

### Read-After-Write Consistency
```go
// Use stored ZedToken for consistency
checkResp, err := client.CheckPermission(ctx, &v1.CheckPermissionRequest{
  Consistency: &v1.Consistency{
    Requirement: &v1.Consistency_AtLeastAsFresh{
      AtLeastAsFresh: &v1.ZedToken{Token: storedToken},
    },
  },
  // ... rest of request
})
```

## HTTP API

Enable with `--http-enabled` flag:

```bash
spicedb serve --http-enabled --grpc-preshared-key foobar
```

Example CheckPermission request:
```bash
curl -X POST 'http://localhost:8443/v1/permissions/check' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer your-token' \
  -d '{
    "consistency": {"minimizeLatency": true},
    "resource": {"objectType": "document", "objectId": "1"},
    "permission": "view",
    "subject": {"object": {"objectType": "user", "objectId": "alice"}}
  }'
```

## CLI Tool (zed)

The `zed` CLI provides command-line access to SpiceDB:

```bash
# Check permission
zed permission check document:1 view user:alice

# Lookup resources
zed permission lookup-resources document view user:alice

# Lookup subjects
zed permission lookup-subjects document:1 view user

# With caveat context
zed permission check document:1 view user:alice \
  --caveat-context '{"user_ip": "10.1.2.3"}'

# Write relationship
zed relationship create document:1 reader user:alice

# Read schema
zed schema read
```

## Server Configuration

Key `spicedb serve` flags:

| Flag | Purpose | Default |
|------|---------|---------|
| `--grpc-preshared-key` | Authentication token | Required |
| `--grpc-addr` | gRPC listen address | `:50051` |
| `--http-addr` | HTTP proxy address | `:8443` |
| `--http-enabled` | Enable HTTP API | `false` |
| `--datastore-engine` | Database type | `memory` |
| `--datastore-conn-uri` | Database connection string | - |
| `--datastore-revision-quantization-interval` | Staleness window | `5s` |

## Resources

- [Official Documentation](https://authzed.com/docs)
- [API Reference (Buf Registry)](https://buf.build/authzed/api/docs)
- [Postman Collection](https://www.postman.com/authzed/spicedb)
- [GitHub Repository](https://github.com/authzed/spicedb)
- [Playground](https://play.authzed.com)
