#!/usr/bin/env bash
set -euo pipefail

project_dir="${PERSONAL_ASSISTANT_PROJECT_DIR:-/opt/personal-assistant}"
whatsapp_to="${PERSONAL_ASSISTANT_WHATSAPP_TO:-}"

cd "$project_dir"

if [[ -z "$whatsapp_to" && -f .env ]]; then
  whatsapp_to="$(sed -n 's/^PERSONAL_ASSISTANT_WHATSAPP_TO=//p' .env | tail -n 1 | tr -d '\r')"
fi

if [[ -z "$whatsapp_to" ]]; then
  echo "PERSONAL_ASSISTANT_WHATSAPP_TO is required" >&2
  exit 2
fi

install_skill() {
  local skill_ref="$1"
  local skill_version="$2"
  docker compose run --rm openclaw-cli skills install "$skill_ref" \
    --version "$skill_version" \
    --force \
    --acknowledge-clawhub-risk
}

install_skill '@mikecourt/adhd-daily-planner' '1.0.0'
install_skill '@itsflow/daily-review-ritual' '1.0.0'
install_skill '@codedao12/meeting-to-action' '1.0.0'
install_skill '@boscoeuk/context-anchor' '1.0.0'
install_skill '@jankutschera/adhd-body-doubling' '2.1.1'

morning_message='Use personal-productivity-orchestrator and adhd-daily-planner. Read today calendar and open Google Tasks with gog. Preserve fixed events, select exactly three priority levels, include transition buffers, do not mutate Google data, and send a concise Brazilian Portuguese morning plan. If a source fails, name it and do not invent data.'
review_message='Use personal-productivity-orchestrator and daily-review-ritual. Read today calendar, Google Tasks, memory/current-task.md, and today local memory log when available. Send a concise Brazilian Portuguese review with confirmed accomplishments, blockers, open loops, and three proposed priorities for tomorrow. Do not mutate Google data.'

docker compose run --rm openclaw-cli cron add \
  --name 'personal-assistant-morning-plan' \
  --display-name 'Plano pessoal da manha' \
  --description 'Planejamento diario com Calendar, Tasks e ADHD Daily Planner' \
  --declaration-key 'personal-assistant-morning-plan' \
  --cron '0 8 * * *' \
  --tz 'America/Bahia' \
  --session isolated \
  --agent main \
  --message "$morning_message" \
  --channel whatsapp \
  --to "$whatsapp_to" \
  --announce \
  --best-effort-deliver \
  --expect-final

docker compose run --rm openclaw-cli cron add \
  --name 'personal-assistant-daily-review' \
  --display-name 'Revisao pessoal do dia' \
  --description 'Revisao noturna com Calendar, Tasks e memoria local' \
  --declaration-key 'personal-assistant-daily-review' \
  --cron '0 21 * * *' \
  --tz 'America/Bahia' \
  --session isolated \
  --agent main \
  --message "$review_message" \
  --channel whatsapp \
  --to "$whatsapp_to" \
  --announce \
  --best-effort-deliver \
  --expect-final
