---
name: personal-productivity-orchestrator
description: Use when the user plans a day, reviews a day, turns meeting notes into actions, resumes interrupted work, requests focus or body doubling, or asks about priorities, blockers, open loops, Calendar, or Tasks.
---

# Personal Productivity Orchestrator

## Purpose

Coordinate the installed specialist skills with Google Workspace, persistent
memory, OpenClaw scheduling, and WhatsApp. Keep plans short, factual, and
realistic. Never invent events, tasks, completion status, owners, or deadlines.

## Routing

| User need | Required specialist |
|---|---|
| Plan today, prioritize, reduce overload | `adhd-daily-planner` |
| Review or close the day | `daily-review` (installed from package `daily-review-ritual`) |
| Extract decisions and actions from a meeting | `meeting-to-action` |
| Resume, recover context, find open loops | `context-anchor` |
| Start focus, get unstuck, body double | `adhd-body-doubling` |

Read the specialist `SKILL.md` before applying its method. This skill adds the
integration contract below; it does not replace the specialist.

## Google Workspace contract

Use the bundled `gog` skill and authenticated default account. Read its
`SKILL.md` before running commands.

- Use `gog calendar` for real events and free/busy information.
- Use `gog tasks` for real task lists, open tasks, and completed tasks.
- Read-only operations may run immediately.
- Obtain explicit confirmation immediately before creating, modifying,
  completing, or deleting Calendar events or Tasks.
- If one Google source fails, identify the unavailable source and continue only
  with verified information from the other source.
- Interpret all dates and schedules in `America/Bahia` unless the user states a
  different timezone.

## WhatsApp contract

The active conversation is already the delivery channel. Reply normally; do not
use a separate WhatsApp client for ordinary replies.

For proactive or delayed messages, use OpenClaw cron with channel `whatsapp` and
the current trusted sender as destination. Never hardcode a personal phone
number in a skill, script, note, or repository file.

## Morning plan

1. Read today's Calendar and open Google Tasks.
2. Ask about energy only when it materially changes the plan and is unknown.
3. Apply `adhd-daily-planner`: exactly one **Tarefa principal**, one **Seria bom**,
   and one **Se houver energia**.
4. Preserve fixed commitments. Add realistic duration and transition buffers.
5. Do not create or reschedule Google data without explicit confirmation.
6. Reply in concise Brazilian Portuguese suitable for WhatsApp.

## Daily review

1. Read today's Calendar, Tasks, `memory/current-task.md`, and today's daily log
   when present.
2. Apply `daily-review` and separate confirmed accomplishments from
   inferred progress.
3. Report blockers, insights, open loops, and three proposed priorities for
   tomorrow.
4. Update local memory after the user confirms corrections. Google writes still
   require explicit confirmation.

## Meeting follow-up

Apply `meeting-to-action` in safe draft mode. Mark inferred owners and due dates
as tentative. Return summary, decisions, actions, risks, and a follow-up draft.
Offer to create approved actions in Google Tasks, but do not write before
explicit confirmation.

## Context recovery

Run the `context-anchor` script when asked where work stopped or when session
context is missing. Maintain:

- `memory/current-task.md` for current objective, status, blocker, and next step;
- `memory/YYYY-MM-DD.md` for factual daily decisions and outcomes;
- `context/active/*.md` for longer in-progress work.

Do not store passwords, tokens, OAuth material, or unnecessary private message
content in memory.

## Focus sessions

Apply `adhd-body-doubling` and establish a first action under two minutes. When
the user starts a timed session, create one-shot cron check-ins using the
specialist schedule. Deliver them through WhatsApp to the current trusted sender
and delete each job after a successful run. A check-in asks for concrete
progress and the current blocker; it must not claim the user completed work.

## Safety failures

- Missing transcript: do not fabricate meeting content.
- Ambiguous date, owner, timezone, or destination: keep the output as a draft.
- Failed delivery: retain diagnostic state and avoid duplicate Google writes.
- Missing memory file: create the documented empty structure and say that older
  context was unavailable.
