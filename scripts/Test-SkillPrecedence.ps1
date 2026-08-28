$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$source = Join-Path $root 'services\assistant\tests\fixtures\weather'
$target = Join-Path $root 'services\assistant\workspace\skills\weather'
$backup = Join-Path $root 'work\precedence-weather-backup'

function Assert-WithinRoot {
  param([Parameter(Mandatory)][string]$Path)
  $rootPrefix = $root.TrimEnd('\') + '\'
  $fullPath = [IO.Path]::GetFullPath($Path)
  if (-not $fullPath.StartsWith($rootPrefix, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Path escapes the project worktree: $fullPath"
  }
}

Assert-WithinRoot -Path $source
Assert-WithinRoot -Path $target
Assert-WithinRoot -Path $backup

if (Test-Path -LiteralPath $backup) { throw "Stale precedence backup exists: $backup" }

try {
  if (Test-Path -LiteralPath $target) {
    Move-Item -LiteralPath $target -Destination $backup
  }
  Copy-Item -LiteralPath $source -Destination $target -Recurse
  docker compose --project-directory $root restart openclaw-gateway | Out-Null
  $json = docker compose --project-directory $root run --rm openclaw-cli skills info weather --json
  if ($LASTEXITCODE -ne 0) { throw 'OpenClaw could not inspect weather skill' }
  $skill = ($json -join [Environment]::NewLine) | ConvertFrom-Json
  if (
    $skill.source -ne 'openclaw-workspace' -or
    $skill.bundled -ne $false -or
    $skill.baseDir -ne '/home/node/.openclaw/workspace/skills/weather'
  ) {
    throw 'Workspace weather skill did not override the bundled skill'
  }
  Write-Output 'SKILL_PRECEDENCE_OK'
}
finally {
  if (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target -Recurse -Force }
  if (Test-Path -LiteralPath $backup) { Move-Item -LiteralPath $backup -Destination $target }
  docker compose --project-directory $root restart openclaw-gateway | Out-Null
}
