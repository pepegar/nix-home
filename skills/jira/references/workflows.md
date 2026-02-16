# Project-Specific Workflows

## GSC Project (Platform - GNC, Sync & Collab)

The GSC project requires transitioning through intermediate statuses. You cannot skip steps.

**Statuses** (in order):
1. Backlog
2. Ready for Development
3. In Development
4. Ready for Review (peer review)
5. Done

**To transition to peer review from Backlog:**

```bash
acli jira workitem transition --key "GSC-123" --status "Ready for Development"
acli jira workitem transition --key "GSC-123" --status "In Development"
acli jira workitem transition --key "GSC-123" --status "Ready for Review"
```

**Note**: If a direct transition fails with "No allowed transitions found", transition through intermediate statuses.
