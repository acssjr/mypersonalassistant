# Persistent operational memory

This directory stores factual, minimal context that must survive OpenClaw
restarts and context compaction.

- `current-task.md`: one current objective, status, blocker, and next action.
- `YYYY-MM-DD.md`: confirmed decisions, outcomes, and open loops for that date.

Never store credentials, OAuth material, private keys, complete message
histories, or unnecessary personal data here.
