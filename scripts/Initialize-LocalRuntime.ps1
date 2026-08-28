$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$envPath = Join-Path $root '.env'
$stateDir = Join-Path $root 'work\openclaw-state'
$authDir = Join-Path $root 'work\openclaw-auth'
$codexHomeDir = Join-Path $root 'work\openclaw-codex'
$workspaceDir = Join-Path $root 'services\assistant\workspace'

New-Item -ItemType Directory -Path $stateDir, $authDir, $codexHomeDir, $workspaceDir -Force | Out-Null

if (-not (Test-Path -LiteralPath $envPath)) {
  $token = [Convert]::ToHexString([Security.Cryptography.RandomNumberGenerator]::GetBytes(32)).ToLowerInvariant()
  $lines = @(
    'OPENCLAW_IMAGE=ghcr.io/openclaw/openclaw:2026.7.1-2',
    'OPENCLAW_CONFIG_DIR=./work/openclaw-state',
    'OPENCLAW_WORKSPACE_DIR=./services/assistant/workspace',
    'OPENCLAW_AUTH_PROFILE_SECRET_DIR=./work/openclaw-auth',
    'OPENCLAW_CODEX_HOME_DIR=./work/openclaw-codex',
    'OPENCLAW_GATEWAY_PORT=18789',
    'OPENCLAW_GATEWAY_BIND=lan',
    "OPENCLAW_GATEWAY_TOKEN=$token",
    'OPENCLAW_TZ=America/Bahia'
  )
  Set-Content -LiteralPath $envPath -Value $lines -Encoding utf8NoBOM
}

$configPath = Join-Path $stateDir 'openclaw.json'
if (-not (Test-Path -LiteralPath $configPath)) {
  $config = @{
    gateway = @{
      mode = 'local'
      auth = @{ mode = 'token'; token = '${OPENCLAW_GATEWAY_TOKEN}' }
    }
    agents = @{
      defaults = @{
        workspace = '/home/node/.openclaw/workspace'
        skipBootstrap = $true
      }
    }
  } | ConvertTo-Json -Depth 8
  Set-Content -LiteralPath $configPath -Value $config -Encoding utf8NoBOM
}

Write-Output 'LOCAL_RUNTIME_INITIALIZED'
