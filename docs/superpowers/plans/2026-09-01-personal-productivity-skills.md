# Personal Productivity Skills Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Integrate five pinned OpenClaw productivity skills with Google Workspace, persistent memory, cron, and WhatsApp.

**Architecture:** Preserve the upstream skills and add one project-owned orchestrator skill. A reproducible VPS script installs exact upstream versions and declares idempotent morning and evening cron jobs; contract tests validate safety and portability.

**Tech Stack:** OpenClaw 2026.7.1, AgentSkills Markdown, Bash, PowerShell tests, `gog`, OpenClaw cron, Docker Compose.

---

### Task 1: Workspace contract

**Files:**
- Modify: `services/assistant/tests/Test-Workspace.ps1`

- [ ] Add assertions for the orchestrator, memory skeleton, pinned-skill manifest, installer, timezone, confirmation gates, and absence of a committed WhatsApp number.
- [ ] Run `pwsh -File services/assistant/tests/Test-Workspace.ps1` and confirm it fails because the new files do not exist.

### Task 2: Orchestrator and persistent context

**Files:**
- Create: `services/assistant/workspace/skills/personal-productivity-orchestrator/SKILL.md`
- Create: `services/assistant/workspace/memory/current-task.md`
- Create: `services/assistant/workspace/memory/README.md`
- Create: `services/assistant/workspace/context/active/.gitkeep`
- Modify: `services/assistant/workspace/AGENTS.md`
- Modify: `services/assistant/workspace/TOOLS.md`

- [ ] Add minimal routing, Google safety boundaries, WhatsApp delivery rules, memory conventions, and body-doubling check-in behavior.
- [ ] Run the workspace test and confirm the skill contract now passes.

### Task 3: Reproducible installation and schedules

**Files:**
- Create: `services/assistant/skills.lock.json`
- Create: `scripts/Install-VpsProductivitySkills.sh`
- Modify: `.env.example`
- Modify: `README.md`

- [ ] Record the five exact skill versions.
- [ ] Add an idempotent installer that installs those versions and declares 08:00 planning and 21:00 review jobs for `America/Bahia` using the WhatsApp destination from the environment.
- [ ] Run Bash syntax validation and workspace tests.

### Task 4: VPS deployment and live verification

**Files:**
- Deploy the tracked workspace and script under `/opt/personal-assistant`.

- [ ] Run the installer on the VPS.
- [ ] Verify all five upstream skills and the orchestrator are ready.
- [ ] Verify `gog` can read Calendar and Tasks.
- [ ] Run the morning and evening cron jobs manually and inspect their run results.
- [ ] Probe WhatsApp and Gateway health.
- [ ] Run live agent smoke tests for all five workflows.

### Task 5: Publication

- [ ] Scan tracked files for secrets and personal destinations.
- [ ] Run `git diff --check`, workspace tests, Compose validation, and shell syntax validation.
- [ ] Commit and push the verified changes to `main`.
