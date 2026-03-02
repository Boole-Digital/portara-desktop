# Portara Desktop

**AI-managed crypto trading infrastructure.** This repo is the local control plane for a live trading system running on a remote VPS. Claude Code connects to the box, reads strategies, deploys updates, and monitors processes — all through a structured onboarding guide.

---

## Why This Exists

Managing a remote trading system involves SSH, PM2 process management, strategy deployment, backtesting, and log analysis. Instead of doing all of that manually, this repo turns Claude Code into an operator that can:

- Connect to your trading box and run commands
- Pull, edit, and deploy strategy files
- Start/stop/restart live trading processes
- Run backtests and review logs
- Sync everything locally for version control

Real money is on the line — the onboarding guide (`claude.md`) enforces safety rails so nothing gets destroyed by accident.

---

## How It Works

```
You (Claude Code) ──ssh-cmd.sh──▶ Remote VPS (trading box)
       │                                │
       │  strategies/          PM2 processes (live trading)
       │  system-prompt.txt    Exchange APIs (Hyperliquid, CCXT, etc.)
       │  backtests/           State files, logs, backtests
       ▼                                ▼
  Local repo (this)            Remote: /root/.openclaw/workspace/portara-agent/
```

- **`claude.md`** — The onboarding guide. Claude reads this to understand the system, connect to the box, and operate safely.
- **`ssh-cmd.sh`** / **`ssh-cmd.ps1`** — SSH wrappers that handle password auth and clean output. All remote commands go through these.
- **`strategies/`** — Local copies of strategy files synced from the remote box.
- **`backtests/`** — Backtest output data.
- **`system-prompt.txt`** — Full trading API documentation (synced from remote).

---

## Getting Started

### Prerequisites

- [Claude Code](https://claude.ai/claude-code) installed
- A running trading VPS with the Portara agent deployed
- Your server IP address and SSH password

### Usage

1. Open this repo in your editor with Claude Code
2. Select the **`claude.md`** file
3. Type **`start`**

Claude will ask for your server IP and password, connect, sync files, and orient itself. From there, just tell it what you need.

---

## Repo Structure

```
portaraDesktop/
├── README.md              ← You are here
├── claude.md              ← Onboarding guide for Claude (select this + say "start")
├── ssh-cmd.sh             ← SSH wrapper (macOS/Linux)
├── ssh-cmd.ps1            ← SSH wrapper (Windows/PowerShell)
├── system-prompt.txt      ← Trading API docs (synced from remote)
├── strategies/            ← Local copies of strategy files
└── backtests/             ← Backtest output data
```

---

## Safety

This system manages **real money**. The `claude.md` guide enforces:

- No exposed API keys or credentials in output
- Exchange state is always queried before acting
- Destructive actions require explicit confirmation
- Capital preservation over aggressiveness
