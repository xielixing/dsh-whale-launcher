# dsh-launch protocol handler.
#   dsh-launch://start?dir=<urlencoded>  starts the dsh web server in that
#                                        directory, hidden (no window), and
#                                        records its PID in dsh-web.pid.
#   dsh-launch://stop                    kills the recorded PID.
param([string]$Url)
$ErrorActionPreference = 'Stop'
$PidFile = Join-Path $PSScriptRoot 'dsh-web.pid'
try {
  $uri = [System.Uri]$Url
  $action = $uri.Host
  if ($action -eq 'stop') {
    if (Test-Path -LiteralPath $PidFile) {
      $recorded = (Get-Content -LiteralPath $PidFile -Raw).Trim()
      if ($recorded -ne '') {
        Stop-Process -Id ([int]$recorded) -Force -ErrorAction SilentlyContinue
      }
      Remove-Item -LiteralPath $PidFile -Force -ErrorAction SilentlyContinue
    }
    exit 0
  }
  if ($action -ne 'start') { exit 1 }
  $dir = ''
  foreach ($part in ($uri.Query.TrimStart('?') -split '&')) {
    if ($part -eq '') { continue }
    $kv = $part -split '=', 2
    if ($kv[0] -eq 'dir') { $dir = [System.Uri]::UnescapeDataString($kv[1]) }
  }
  if ($dir -eq '') { exit 1 }
  if (-not (Test-Path -LiteralPath (Join-Path $dir 'package.json'))) { exit 1 }
  try {
    $r = Invoke-WebRequest -Uri 'http://127.0.0.1:3080/' -UseBasicParsing -TimeoutSec 2
    if ($r.StatusCode -eq 200) { exit 0 }
  } catch {}
  $proc = Start-Process -FilePath 'node.exe' -ArgumentList '--import','tsx/esm','apps/cli/src/bin.ts','web' -WorkingDirectory $dir -WindowStyle Hidden -PassThru
  Set-Content -LiteralPath $PidFile -Value $proc.Id -Encoding ascii
  exit 0
} catch {
  exit 1
}
