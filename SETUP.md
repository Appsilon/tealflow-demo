# Workshop Setup

This guide gets the **TealFlow MCP server** running in your AI assistant (Claude Desktop, VS Code, Cursor, …) before the workshop. Plan ~5 minutes.

If anything goes wrong, jump to [Troubleshooting](#troubleshooting) at the bottom.

---

## What you'll end up with

A single MCP server entry in your AI client called `tealflow`, powered by the `tealflow-mcp` Python package. It's launched on demand via [`uvx`](https://docs.astral.sh/uv/), so there's no venv to manage, no PATH to configure, and no Python version to fight with.

---

## Step 1 — Install `uv`

`uv` is a fast Python package manager. It always installs to a known location (`~/.local/bin` on Mac/Linux, `%USERPROFILE%\.local\bin` on Windows), which is the only reliable cross-machine way to give your AI client a path it can actually find.

### macOS / Linux

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Then **open a new terminal** (or `source ~/.zshenv`) so the new PATH takes effect. Verify:

```bash
which uvx
# → /Users/<you>/.local/bin/uvx
```

### Windows (PowerShell)

```powershell
irm https://astral.sh/uv/install.ps1 | iex
```

Open a new PowerShell window, then verify:

```powershell
Get-Command uvx
# → ...\.local\bin\uvx.exe
```

---

## Step 2 — Run the bootstrap script

This downloads `tealflow-mcp` into `uv`'s cache and prints the exact JSON snippet you'll paste into your MCP client.

### macOS / Linux

```bash
curl -LsSf https://raw.githubusercontent.com/Appsilon/tealflow-demo/main/setup.sh | bash
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/Appsilon/tealflow-demo/main/setup.ps1 | iex
```

The script prints something like:

```
✓ uvx found at: /Users/marcin/.local/bin/uvx
✓ tealflow-mcp responds correctly

Add this server to your MCP client config:

  "tealflow": {
    "type": "stdio",
    "command": "/Users/marcin/.local/bin/uvx",
    "args": ["tealflow-mcp"]
  }
```

**Copy that snippet.** You'll paste it in Step 3.

---

## Step 3 — Configure your MCP client

Open the config file for your client, paste the snippet from Step 2 inside the appropriate wrapper, then **fully restart the client** (quit, don't just close the window).

> **Don't have an MCP-capable client yet?** [Claude Desktop](https://claude.ai/download) is the most beginner-friendly. Install, sign in, then come back.

### Claude Desktop

**Config file:**

| OS | Path |
|----|------|
| macOS | `~/Library/Application Support/Claude/claude_desktop_config.json` |
| Windows | `%APPDATA%\Claude\claude_desktop_config.json` |
| Linux | `~/.config/Claude/claude_desktop_config.json` |

**Wrapper key:** `mcpServers`. Full file looks like:

```json
{
  "mcpServers": {
    "tealflow": {
      "type": "stdio",
      "command": "/Users/marcin/.local/bin/uvx",
      "args": ["tealflow-mcp"]
    }
  }
}
```

If you already have other servers, just add `tealflow` as another key inside `mcpServers`.

### VS Code (built-in MCP)

**Config file:**

| OS | Path |
|----|------|
| macOS | `~/Library/Application Support/Code/User/mcp.json` |
| Windows | `%APPDATA%\Code\User\mcp.json` |
| Linux | `~/.config/Code/User/mcp.json` |

**Wrapper key:** `servers`.

```json
{
  "servers": {
    "tealflow": {
      "type": "stdio",
      "command": "/Users/marcin/.local/bin/uvx",
      "args": ["tealflow-mcp"]
    }
  },
  "inputs": []
}
```

Reload the MCP server from the **MCP: List Servers** command palette entry, or restart VS Code.

### Cursor

**Config file:** `~/.cursor/mcp.json` (all OSes; Windows: `%USERPROFILE%\.cursor\mcp.json`).

**Wrapper key:** `mcpServers` (same shape as Claude Desktop).

```json
{
  "mcpServers": {
    "tealflow": {
      "type": "stdio",
      "command": "/Users/marcin/.local/bin/uvx",
      "args": ["tealflow-mcp"]
    }
  }
}
```

### Continue, Cline, Zed, others

These clients support MCP but use slightly different config schemas. Look in your client's docs for "MCP servers" or "mcpServers". The three values you need are:

- **command**: the absolute path to `uvx` from Step 1
- **args**: `["tealflow-mcp"]`
- **type / transport**: `stdio`

---

## Step 4 — Verify it's working

After restarting your MCP client, ask it:

> *"What tools do you have available from the tealflow server?"*

You should see at least a `tealflow_agent_guidance` tool listed. If you do, you're set.

---

## Troubleshooting

### `spawn uvx ENOENT` or "command not found" in the MCP client

Your client launched from the Dock/Start Menu doesn't see `uvx` on its PATH. **Use the absolute path** the bootstrap script printed, not just `"uvx"`. On macOS and Linux that's `~/.local/bin/uvx` expanded to its full form (`/Users/<you>/.local/bin/uvx`).

### Bootstrap script says "Could not verify"

Run the inner command manually to see the real error:

```bash
~/.local/bin/uvx tealflow-mcp
```

Press Ctrl-C after a few seconds. If it printed nothing and didn't error, it's actually fine — MCP servers wait silently on stdin. If it printed a Python traceback, copy it and ping the workshop chat.

### "Operation not permitted" reading files in `~/Documents` (macOS)

macOS blocks unfamiliar binaries from reading `~/Documents` until they're approved. Move your work to `~/Workshop` or similar, or grant your terminal Full Disk Access in **System Settings → Privacy & Security**.

### I'm behind a corporate proxy / firewall

`uvx` needs outbound HTTPS to `pypi.org` and `files.pythonhosted.org` to fetch the package the first time. After Step 2 it's cached locally and works offline. If your network blocks PyPI, run Step 2 from a personal hotspot, then go back on the work network.

### I want to pin a specific version

Replace `"args": ["tealflow-mcp"]` with `"args": ["tealflow-mcp==1.26.0"]` (or whatever version the workshop announces).

### I want to uninstall everything afterwards

```bash
uv cache clean
rm -rf ~/.local/bin/uv ~/.local/bin/uvx
# Then remove the "tealflow" entry from your MCP client config.
```

---

## Pre-workshop checklist

Before the session starts, confirm:

- [ ] `uvx --version` works in a fresh terminal
- [ ] Your MCP client lists `tealflow` as a connected server
- [ ] The client can call the `tealflow_agent_guidance` tool when asked

If all three are green, you're ready.
