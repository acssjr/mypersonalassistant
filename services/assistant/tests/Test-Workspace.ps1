$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$required = @(
  '.gitignore',
  '.env.example',
  'docker-compose.yml',
  'README.md',
  'services\assistant\workspace\AGENTS.md',
  'services\assistant\workspace\SOUL.md',
  'services\assistant\workspace\TOOLS.md',
  'services\assistant\workspace\skills\personal-assistant-smoke\SKILL.md',
  'services\assistant\workspace\skills\personal-productivity-orchestrator\SKILL.md',
  'services\assistant\workspace\memory\README.md',
  'services\assistant\workspace\memory\current-task.md',
  'services\assistant\workspace\context\active\.gitkeep',
  'services\assistant\skills.lock.json',
  'services\assistant\upstream\openclaw-release.json',
  'scripts\Initialize-LocalRuntime.ps1',
  'scripts\Install-VpsProductivitySkills.sh',
  'scripts\Test-SkillPrecedence.ps1'
)

$missing = $required | Where-Object { -not (Test-Path -LiteralPath (Join-Path $root $_) -PathType Leaf) }
if ($missing) { throw "Missing required files: $($missing -join ', ')" }

$skill = Get-Content -Raw (Join-Path $root 'services\assistant\workspace\skills\personal-assistant-smoke\SKILL.md')
if ($skill -notmatch '(?m)^name:\s*personal-assistant-smoke\s*$') { throw 'Smoke skill name is invalid' }
if ($skill -notmatch '(?m)^description:\s*\S') { throw 'Smoke skill description is missing' }

$tools = Get-Content -Raw (Join-Path $root 'services\assistant\workspace\TOOLS.md')
if ($tools -match 'No account integration is enabled') {
  throw 'Tool inventory must not claim that account integrations are disabled'
}
if ($tools -notmatch '(?i)Google Workspace.*gog' -or $tools -notmatch 'gog calendar') {
  throw 'Tool inventory must route Google Workspace requests through gog'
}

$orchestrator = Get-Content -Raw (Join-Path $root 'services\assistant\workspace\skills\personal-productivity-orchestrator\SKILL.md')
foreach ($requiredText in @(
  'adhd-daily-planner',
  'daily-review-ritual',
  'meeting-to-action',
  'context-anchor',
  'adhd-body-doubling',
  'gog calendar',
  'gog tasks',
  'America/Bahia',
  'explicit confirmation',
  'WhatsApp'
)) {
  if ($orchestrator -notmatch [regex]::Escape($requiredText)) {
    throw "Productivity orchestrator is missing contract text: $requiredText"
  }
}
if ($orchestrator -notmatch '`daily-review` \(installed from package `daily-review-ritual`\)') {
  throw 'Productivity orchestrator must distinguish the daily-review skill name from its package slug'
}

$skillLock = Get-Content -Raw (Join-Path $root 'services\assistant\skills.lock.json') | ConvertFrom-Json
$expectedSkills = @{
  'adhd-daily-planner' = '1.0.0'
  'daily-review-ritual' = '1.0.0'
  'meeting-to-action' = '1.0.0'
  'context-anchor' = '1.0.0'
  'adhd-body-doubling' = '2.1.1'
}
foreach ($entry in $expectedSkills.GetEnumerator()) {
  if ($skillLock.skills.$($entry.Key).version -ne $entry.Value) {
    throw "Pinned version mismatch for $($entry.Key)"
  }
}

$installer = Get-Content -Raw (Join-Path $root 'scripts\Install-VpsProductivitySkills.sh')
if ($installer -notmatch 'personal-assistant-morning-plan' -or $installer -notmatch 'personal-assistant-daily-review') {
  throw 'VPS installer must declare both personal productivity schedules'
}
if ($installer -notmatch "sed -n 's/\^PERSONAL_ASSISTANT_WHATSAPP_TO=") {
  throw 'VPS installer must read the WhatsApp destination from the project .env when it is not exported'
}
if ($installer -notmatch 'chown -R 1000:1000') {
  throw 'VPS installer must preserve write access for the node user in the mounted workspace'
}
if ($installer -notmatch 'context-anchor/scripts/anchor\.sh' -or $installer -notmatch 'adhd-body-doubling/scripts/start-session\.sh') {
  throw 'VPS installer must make both installed runtime scripts executable'
}
if ($installer -notmatch '0 8 \* \* \*' -or $installer -notmatch '0 21 \* \* \*' -or $installer -notmatch 'America/Bahia') {
  throw 'VPS installer must use the approved schedule and timezone'
}
if ($installer -match '\+5575\d{8,9}') {
  throw 'VPS installer must not contain a committed personal WhatsApp number'
}

$compose = Get-Content -Raw (Join-Path $root 'docker-compose.yml')
if ($compose -match 'openclaw:latest') { throw 'OpenClaw image must be pinned' }
if ($compose -notmatch '\$\{OPENCLAW_CODEX_HOME_DIR[^}]*\}:/home/node/\.codex') {
  throw 'Dedicated Codex auth directory must be mounted'
}
if ($compose -notmatch '127\.0\.0\.1:\$\{OPENCLAW_GATEWAY_PORT') { throw 'Gateway port must bind to loopback' }

$trackedCandidates = git -C $root ls-files | ForEach-Object { Get-Item -LiteralPath (Join-Path $root $_) }
$secretPattern = '(?i)(sk-[A-Za-z0-9]{20,}|BEGIN (RSA |OPENSSH )?PRIVATE KEY|OPENCLAW_GATEWAY_TOKEN\s*=\s*[a-f0-9]{64})'
foreach ($file in $trackedCandidates) {
  $content = Get-Content -Raw -LiteralPath $file.FullName -ErrorAction SilentlyContinue
  if ($content -match $secretPattern) { throw "Possible secret in $($file.FullName)" }
}

docker compose --project-directory $root config --quiet
if ($LASTEXITCODE -ne 0) { throw 'Docker Compose configuration is invalid' }
Write-Output 'WORKSPACE_VERIFICATION_OK'
