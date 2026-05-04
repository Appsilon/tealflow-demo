# tealflow-demo workshop bootstrap (Windows PowerShell)
#
# Usage:  irm https://raw.githubusercontent.com/Appsilon/tealflow-demo/main/setup.ps1 | iex
#
# What this script does:
#   1. Installs `uv` if missing (to %USERPROFILE%\.local\bin)
#   2. Pre-warms the tealflow-mcp cache via `uvx`
#   3. Prints the JSON snippet to paste into your MCP client config
#
# It does NOT modify any MCP client config files.

$ErrorActionPreference = "Stop"

function Write-Step($msg)   { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-OK($msg)     { Write-Host "OK   $msg" -ForegroundColor Green }
function Write-Warn2($msg)  { Write-Host "WARN $msg" -ForegroundColor Yellow }

Write-Step "Step 1/3: Install or locate uv"

if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
  Write-Host "uv not found - installing..."
  irm https://astral.sh/uv/install.ps1 | iex
  $env:Path = "$env:USERPROFILE\.local\bin;$env:Path"
}

$Uvx = $null
$candidate = Join-Path $env:USERPROFILE ".local\bin\uvx.exe"
if (Test-Path $candidate) {
  $Uvx = $candidate
} elseif (Get-Command uvx -ErrorAction SilentlyContinue) {
  $Uvx = (Get-Command uvx).Source
}
if (-not $Uvx) {
  Write-Host "Could not locate uvx. Open a new PowerShell window and re-run." -ForegroundColor Red
  exit 1
}
Write-OK "uvx: $Uvx"

Write-Host ""
Write-Step "Step 2/3: Pre-warm tealflow-mcp"
Write-Host "Downloading and caching the package (one-time)..."

$req = '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"workshop-setup","version":"1"}}}'
try {
  $resp = $req | & $Uvx tealflow-mcp 2>$null | Select-Object -First 1
} catch {
  $resp = ""
}

if ($resp -match '"result"') {
  Write-OK "tealflow-mcp launched and responded to MCP initialize"
} else {
  Write-Warn2 "Could not verify tealflow-mcp."
  Write-Warn2 "Try manually:  & '$Uvx' tealflow-mcp"
  Write-Warn2 "(Ctrl-C after a few seconds; silence with no error = healthy)"
}

Write-Host ""
Write-Step "Step 3/3: Configure your MCP client"

$jsonPath = $Uvx -replace '\\','\\'
@"

Copy this block into your MCP client's config file:

  "tealflow": {
    "type": "stdio",
    "command": "$jsonPath",
    "args": ["tealflow-mcp"]
  }

Where to put it (wrap with the right top-level key - see SETUP.md):

  Claude Desktop:  %APPDATA%\Claude\claude_desktop_config.json
                   (top-level key:  "mcpServers")
  VS Code (user):  %APPDATA%\Code\User\mcp.json
                   (top-level key:  "servers")
  Cursor:          %USERPROFILE%\.cursor\mcp.json
                   (top-level key:  "mcpServers")

After saving, FULLY RESTART your MCP client (quit + reopen).
Full guide: https://github.com/Appsilon/tealflow-demo/blob/main/SETUP.md
"@
