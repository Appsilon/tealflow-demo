#!/usr/bin/env bash
# tealflow-demo workshop bootstrap (macOS / Linux)
#
# Usage:  curl -LsSf https://raw.githubusercontent.com/Appsilon/tealflow-demo/main/setup.sh | bash
#
# What this script does:
#   1. Installs `uv` if missing (to ~/.local/bin)
#   2. Pre-warms the tealflow-mcp cache via `uvx`
#   3. Prints the JSON snippet to paste into your MCP client config
#
# It does NOT modify any MCP client config files. Pasting is your call.

set -euo pipefail

bold()  { printf '\033[1m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
yellow(){ printf '\033[33m%s\033[0m\n' "$*"; }
red()   { printf '\033[31m%s\033[0m\n' "$*"; }

bold "==> Step 1/3: Install or locate uv"

if ! command -v uv >/dev/null 2>&1; then
  echo "uv not found — installing..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  # The installer adds ~/.local/bin to PATH for future shells, but not this one.
  export PATH="$HOME/.local/bin:$PATH"
fi

UVX="$(command -v uvx || true)"
if [ -z "$UVX" ] && [ -x "$HOME/.local/bin/uvx" ]; then
  UVX="$HOME/.local/bin/uvx"
fi
if [ -z "$UVX" ]; then
  red "Could not locate uvx after install. Open a new terminal and re-run this script."
  exit 1
fi
green "✓ uvx: $UVX"

bold ""
bold "==> Step 2/3: Pre-warm tealflow-mcp"
echo "Downloading and caching the package (one-time)..."
INIT_REQ='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"workshop-setup","version":"1"}}}'
RESPONSE="$(printf '%s\n' "$INIT_REQ" | "$UVX" tealflow-mcp 2>/dev/null | head -1 || true)"

if echo "$RESPONSE" | grep -q '"result"'; then
  green "✓ tealflow-mcp launched and responded to MCP initialize"
else
  yellow "⚠ Could not verify tealflow-mcp."
  yellow "  Try running it manually:    $UVX tealflow-mcp"
  yellow "  (press Ctrl-C after a few seconds; silence with no error = healthy)"
fi

bold ""
bold "==> Step 3/3: Configure your MCP client"
cat <<EOF

Copy this block into your MCP client's config file:

  "tealflow": {
    "type": "stdio",
    "command": "$UVX",
    "args": ["tealflow-mcp"]
  }

Where to put it (wrap with the right top-level key — see SETUP.md):

EOF

case "$(uname)" in
  Darwin)
    echo "  Claude Desktop:  ~/Library/Application Support/Claude/claude_desktop_config.json"
    echo "                   (top-level key:  \"mcpServers\")"
    echo "  VS Code (user):  ~/Library/Application Support/Code/User/mcp.json"
    echo "                   (top-level key:  \"servers\")"
    echo "  Cursor:          ~/.cursor/mcp.json"
    echo "                   (top-level key:  \"mcpServers\")"
    ;;
  Linux)
    echo "  Claude Desktop:  ~/.config/Claude/claude_desktop_config.json"
    echo "                   (top-level key:  \"mcpServers\")"
    echo "  VS Code (user):  ~/.config/Code/User/mcp.json"
    echo "                   (top-level key:  \"servers\")"
    echo "  Cursor:          ~/.cursor/mcp.json"
    echo "                   (top-level key:  \"mcpServers\")"
    ;;
  *)
    echo "  See SETUP.md for your platform."
    ;;
esac

echo
echo "After saving, FULLY RESTART your MCP client (quit + reopen)."
echo "Full guide: https://github.com/Appsilon/tealflow-demo/blob/main/SETUP.md"
