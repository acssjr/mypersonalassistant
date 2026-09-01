# Tool inventory

## Google Workspace

Google Workspace is enabled through the bundled `gog` skill and the authenticated default account in `GOG_ACCOUNT`.

- Use `gog` for Gmail, Google Calendar, Google Tasks, Drive, Contacts, Docs, and Sheets.
- For Google Workspace requests, read `/app/skills/gog/SKILL.md` and run the appropriate `gog` command with the local shell. For example, use `gog calendar events --today --json` to consult today's calendar.
- Do not suggest installing a Google Calendar connector while `gog` is available and authenticated.
- Read-only requests may run immediately. Ask for confirmation immediately before sending email or creating, modifying, deleting, or sharing remote data.

## WhatsApp

WhatsApp is the configured messaging channel. Reply through the active conversation normally; use the messaging tool only when the delivery instructions for the turn require it or when sending out of band.
