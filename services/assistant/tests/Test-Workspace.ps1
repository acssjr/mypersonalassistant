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
  'services\assistant\upstream\openclaw-release.json',
  'scripts\Initialize-LocalRuntime.ps1',
  'scripts\Test-SkillPrecedence.ps1'
)

$missing = $required | Where-Object { -not (Test-Path -LiteralPath (Join-Path $root $_) -PathType Leaf) }
if ($missing) { throw "Missing required files: $($missing -join ', ')" }

$skill = Get-Content -Raw (Join-Path $root 'services\assistant\workspace\skills\personal-assistant-smoke\SKILL.md')
if ($skill -notmatch '(?m)^name:\s*personal-assistant-smoke\s*$') { throw 'Smoke skill name is invalid' }
if ($skill -notmatch '(?m)^description:\s*\S') { throw 'Smoke skill description is missing' }

$compose = Get-Content -Raw (Join-Path $root 'docker-compose.yml')
if ($compose -match 'openclaw:latest') { throw 'OpenClaw image must be pinned' }
if ($compose -notmatch '127\.0\.0\.1:\$\{OPENCLAW_GATEWAY_PORT') { throw 'Gateway port must bind to loopback' }

$trackedCandidates = Get-ChildItem -LiteralPath $root -File -Recurse | Where-Object {
  $_.FullName -notmatch '[\\/]\.git[\\/]' -and
  $_.FullName -notmatch '[\\/]work[\\/]'
}
$secretPattern = '(?i)(sk-[A-Za-z0-9]{20,}|BEGIN (RSA |OPENSSH )?PRIVATE KEY|OPENCLAW_GATEWAY_TOKEN\s*=\s*[a-f0-9]{64})'
foreach ($file in $trackedCandidates) {
  $content = Get-Content -Raw -LiteralPath $file.FullName -ErrorAction SilentlyContinue
  if ($content -match $secretPattern) { throw "Possible secret in $($file.FullName)" }
}

docker compose --project-directory $root config --quiet
if ($LASTEXITCODE -ne 0) { throw 'Docker Compose configuration is invalid' }
Write-Output 'WORKSPACE_VERIFICATION_OK'
