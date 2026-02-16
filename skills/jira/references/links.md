# Link Operations

## List Available Link Types

```bash
acli jira workitem link type
```

**Common types**: Blocks, Cloners, Duplicate, Relates

## List Links on a Work Item

```bash
acli jira workitem link list --key KEY-123
acli jira workitem link list --key KEY-123 --json
```

## Create Links

```bash
# KEY-1 blocks KEY-2
acli jira workitem link create --out KEY-1 --in KEY-2 --type Blocks --yes

# Relates link
acli jira workitem link create --out KEY-1 --in KEY-2 --type Relates --yes

# From JSON file (bulk)
acli jira workitem link create --from-json links.json

# Generate example JSON
acli jira workitem link create --generate-json
```

**Direction**:
- `--out` = outward/source (e.g., the blocker)
- `--in` = inward/target (e.g., the blocked item)
- `--yes` = skip confirmation

## Delete Links

```bash
acli jira workitem link delete --key KEY-123 --link-id 12345
```

## Bulk Link Creation

Run multiple link commands in parallel:

```bash
acli jira workitem link create --out GSC-945 --in GSC-946 --type Blocks --yes
acli jira workitem link create --out GSC-946 --in GSC-947 --type Blocks --yes
```
