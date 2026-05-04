# tealflow-demo

Repository for the R/Medicine 2026 Workshop/Demo.

## Workshop participants — start here

See **[SETUP.md](SETUP.md)** to install the TealFlow MCP server in your AI assistant (Claude Desktop, VS Code, Cursor, …) before the session.

Quick version:

```bash
# macOS / Linux
curl -LsSf https://astral.sh/uv/install.sh | sh
curl -LsSf https://raw.githubusercontent.com/Appsilon/tealflow-demo/main/setup.sh | bash
```

```powershell
# Windows (PowerShell)
irm https://astral.sh/uv/install.ps1 | iex
irm https://raw.githubusercontent.com/Appsilon/tealflow-demo/main/setup.ps1 | iex
```

Then paste the printed snippet into your MCP client's config — full instructions in [SETUP.md](SETUP.md).

## Demo data

SDTM-style CSVs used in the workshop:

- `sdtm_dm_*.csv` — demographics
- `sdtm_ae_*.csv` — adverse events
- `sdtm_lb_*.csv` — labs
- `sdtm_vs_*.csv` — vital signs
