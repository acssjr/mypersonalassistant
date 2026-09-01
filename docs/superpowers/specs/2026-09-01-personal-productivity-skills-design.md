# Personal Productivity Skills Design

## Objective

Turn the installed OpenClaw skills `adhd-daily-planner`, `daily-review-ritual`,
`meeting-to-action`, `context-anchor`, and `adhd-body-doubling` into one coherent
personal-assistant workflow over WhatsApp.

## Architecture

Keep all five third-party skills unchanged and pinned to reviewed versions. Add
a project-owned `personal-productivity-orchestrator` skill that decides which
specialist to use and connects it to the already authenticated `gog` CLI,
OpenClaw cron, persistent Markdown memory, and the active WhatsApp channel.

The orchestrator must use the following boundaries:

- Read Google Calendar and Google Tasks without confirmation.
- Ask immediately before creating, modifying, completing, or deleting Google
  data.
- Treat meeting output as a draft until the user approves external writes.
- Create timed body-doubling check-ins only after a session is requested.
- Store operational context in workspace Markdown; do not store credentials,
  private message contents, or OAuth material.
- Use `America/Bahia` for all schedules and dates.

## Workflows

### Morning planning

At 08:00, an isolated agent job reads today's Calendar events and open Google
Tasks through `gog`, applies the ADHD planner's three-things system and
transition buffers, then sends a concise plan to the configured WhatsApp user.

### End-of-day review

At 21:00, an isolated agent job reads today's local daily note, Calendar, and
Tasks. It sends a review containing accomplishments, blockers, open loops, and
three proposed priorities for tomorrow. It does not mutate Google data.

### Meeting follow-up

When meeting notes or a transcript arrive, the agent uses
`meeting-to-action`, marks inferred owners or dates as tentative, and returns a
draft. Google Tasks are created only after explicit user approval.

### Context recovery

At session start or when asked where work stopped, `context-anchor` scans
`memory/current-task.md`, recent daily logs, and `context/active`. The
orchestrator maintains those locations consistently.

### Focus sessions

When the user requests focus or body doubling, the specialist chooses the first
two-minute action and schedules WhatsApp check-ins for the requested session.
One-shot check-ins delete themselves after successful execution. Session
history remains local.

## Failure handling

- If `gog` fails, report which source could not be read and continue with the
  available source rather than fabricating a schedule.
- If WhatsApp delivery fails, retain the cron run result for diagnosis and do
  not duplicate Google writes.
- If a memory file is missing, create the documented empty structure and report
  that historical context was unavailable.
- If ownership, deadline, timezone, or target is ambiguous, return a draft and
  request the missing fact before any external mutation.

## Verification

Verification requires workspace contract tests, skill discovery, successful
`gog` Calendar and Tasks reads, enabled cron jobs with correct timezone and
WhatsApp destination, a healthy WhatsApp channel probe, and live agent smoke
tests for planning, meeting extraction, context recovery, and focus-session
behavior.
