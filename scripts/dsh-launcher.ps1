# dsh-launch protocol handler: receives dsh-launch://start?dir=<urlencoded>
# Starts `node --import tsx/esm apps/cli/src/bin.ts web` in that directory
# (minimized window), skipping the start when the web server already listens.
param([string]$Url)
$ErrorActionPreference = 'Stop'
try {
  $uri = [System.Uri]$Url
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
  Start-Process -FilePath 'node.exe' -ArgumentList '--import','tsx/esm','apps/cli/src/bin.ts','web' -WorkingDirectory $dir -WindowStyle Minimized
  exit 0
} catch {
  exit 1
}
