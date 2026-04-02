# Portara Trading Box — Claude Onboarding Guide

> **What is this?** You (Claude) are helping manage a live crypto trading system running on a remote VPS. This file is everything you need to connect, authenticate, and operate. **Real money is at risk — read the safety rules before doing anything.**

> **CRITICAL: Stay in this repo.** This repo (`portaraDesktop`) is your workspace. **Never** browse other local repos (e.g. `portara-agent`, `claudeTrade`, etc.) for strategies or reference files. Everything you need comes from the **remote box** via SSH. All local files you create or edit belong in **this** repo.

---

## Step 1: Connect to the Box

The trading system runs on a remote VPS. You must SSH in for all operations.

- **User:** `root`
- **Auth:** Password-based (no SSH key)
- **Host IP:** Changes between sessions — **you must ask the user**

### First thing to do: Ask for connection details

You do not have the IP or password stored anywhere. On every fresh session, **ask the user for both** before attempting any SSH commands:

> "I need the IP address and SSH password for the trading box to get started. Can you provide them?"

### How to run remote commands: `ssh-cmd`

This repo has wrapper scripts that handle SSH + password auth + output cleanup. **Use them for ALL remote commands:**

**macOS/Linux:**
```bash
./ssh-cmd.sh <IP> '<PASSWORD>' "<REMOTE_COMMAND>"
```

**Windows (PowerShell):**
```powershell
.\ssh-cmd.ps1 <IP> '<PASSWORD>' '<REMOTE_COMMAND>'
```

- Output is clean (junk lines stripped automatically)
- On **both** platforms: wrap the password in **single quotes** to prevent `$` interpolation
- Special characters in passwords (`!`, `&`, `$`, etc.) are handled automatically by the script — **do not** manually escape them
- On macOS/Linux the remote command goes in **double quotes**; on Windows use **single quotes** (prevents PowerShell from expanding `$HOME`, `$NVM_DIR`, etc.)
- Windows requires [plink.exe](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) in PATH

### Why `source ~/.bashrc` doesn't work

Node/npm/pm2 are installed via **nvm**. The remote `.bashrc` has a guard that skips loading nvm in non-interactive SSH sessions. **You must source nvm directly:**

```
export NVM_DIR="\$HOME/.nvm" && . "\$NVM_DIR/nvm.sh"
```

Use this instead of `source ~/.bashrc` for all commands that need `node`, `npm`, or `pm2`. The `ssh-cmd.sh` script handles the escaping — just pass it as part of the command string.

### Test connectivity

```bash
./ssh-cmd.sh <IP> '<PASSWORD>' "echo connected"
```

If you see `connected` in the output, you're good.

---

## Step 2: Sync Remote Files Locally

After connecting, pull key reference files and strategies from the remote box into **this repo**. This keeps everything local so you never need to look elsewhere.

### Local repo structure

This repo should look like:
```
portaraDesktop/
├── claude.md                  # This file (onboarding guide)
├── ssh-cmd.sh                 # SSH wrapper — macOS/Linux (do not modify)
├── ssh-cmd.ps1                # SSH wrapper — Windows/PowerShell (do not modify)
├── system-prompt.txt                       # ⭐ Synced from remote — core trading API docs
├── system-prompt-prediction-markets.txt    # ⭐ Synced from remote — prediction market docs
├── backtest-prompt.md                      # ⭐ Synced from remote — backtest engine prompt
├── interface-prompt.txt                    # Synced from remote — Bloomberg-style UI prompt
├── code-sync-prompt.md                     # Synced from remote — sender.js tools docs
└── strategies/                             # ⭐ Local copies of all strategy files
    ├── MTF-oscellator.js
    ├── funding_farm_hl_ext.js
    └── ...
```

### On first connect: sync reference docs (if missing locally)

Check if the prompt files already exist locally. If not, pull them from the remote:

```bash
# Core trading agent docs
./ssh-cmd.sh <IP> '<PASSWORD>' "cat /root/.openclaw/workspace/portara-agent/v3/system-prompt.txt"
# → Save output to: <this-repo>/system-prompt.txt

# Prediction markets (Polymarket, Limitless, Opinion, Kalshi)
./ssh-cmd.sh <IP> '<PASSWORD>' "cat /root/.openclaw/workspace/portara-agent/v3/system-prompt-prediction-markets.txt"
# → Save output to: <this-repo>/system-prompt-prediction-markets.txt

# Backtest engine (self-contained HTML backtest generator)
./ssh-cmd.sh <IP> '<PASSWORD>' "cat /root/.openclaw/workspace/portara-agent/backtest/backtest-prompt.md"
# → Save output to: <this-repo>/backtest-prompt.md

# Bloomberg-style trading interface generation
./ssh-cmd.sh <IP> '<PASSWORD>' "cat /root/.openclaw/workspace/portara-agent/v3/interface-prompt.txt"
# → Save output to: <this-repo>/interface-prompt.txt

# Code-sync sender tools
./ssh-cmd.sh <IP> '<PASSWORD>' "cat /root/.openclaw/workspace/portara-agent/code-sync/system-prompt.md"
# → Save output to: <this-repo>/code-sync-prompt.md
```

### On first connect: sync strategies (if `strategies/` folder is empty or missing)

Pull all strategy files from the remote into the local `strategies/` folder:

```bash
# List remote strategies
./ssh-cmd.sh <IP> '<PASSWORD>' "ls /root/.openclaw/workspace/portara-agent/v3/strategies/"

# For each file, fetch and save locally:
./ssh-cmd.sh <IP> '<PASSWORD>' "cat /root/.openclaw/workspace/portara-agent/v3/strategies/<filename>.js"
# → Save output to: <this-repo>/strategies/<filename>.js
```

**When the user asks to work on a strategy:** read it from the local `strategies/` folder first. If it's not there, pull it from the remote and save it locally before editing.

**When deploying changes:** write the updated file to **both** the local `strategies/` folder and the remote box.

---

## Step 3: Orient Yourself

Once connected and synced, get a quick picture of what's running.

### Check what strategies are live
```bash
./ssh-cmd.sh <IP> '<PASSWORD>' "export NVM_DIR=\$HOME/.nvm && . \$NVM_DIR/nvm.sh && pm2 list"
```

### List available strategy files (remote)
```bash
./ssh-cmd.sh <IP> '<PASSWORD>' "ls /root/.openclaw/workspace/portara-agent/v3/strategies/"
```

### Read the trading system prompt
Read the local `system-prompt.txt` (synced in Step 2). If you need the latest version, pull it fresh from the remote:
```bash
./ssh-cmd.sh <IP> '<PASSWORD>' "cat /root/.openclaw/workspace/portara-agent/v3/system-prompt.txt"
```

> **Tip:** The system-prompt.txt is the most important file — it documents all available trading functions, exchange adapters, strategy templates, and safety rules. Read it early.

### Which prompt file to read

The remote box has multiple specialized system prompts. Read the one(s) relevant to what the user is asking:

| Prompt file | When to read |
|-------------|-------------|
| `system-prompt.txt` | **Default.** Writing, editing, or deploying any trading strategy. Core API docs, exchange list, safety rules. |
| `system-prompt-prediction-markets.txt` | User wants to trade prediction markets (Polymarket, Limitless, Opinion, Kalshi). Covers event/market search, outcome tokens, order placement, and position management for binary/multi-outcome markets. |
| `backtest-prompt.md` | User wants to backtest a strategy. Describes how to generate a self-contained HTML backtest dashboard from a strategy file — data sourcing, signal generation, trade simulation, and interactive visualization. |
| `interface-prompt.txt` | User wants a trading dashboard/UI. Describes generating Bloomberg-style mobile trading interfaces served from the box. |
| `code-sync-prompt.md` | Using sender.js tools (backtest linking, log fetching, status push). |

---

## Step 4: Understand the Remote Directory Layout

All paths are on the remote box under `/root/.openclaw/workspace/portara-agent`.

```
portara-agent/
├── backtest/                      # Backtest engine
│   └── backtest-prompt.md         # ⭐ Backtest HTML generator prompt
├── code-sync/                     # Agent tooling (backtest, logs, status)
│   ├── sender.js                  # Main tool script
│   ├── sender-daemon.js           # Auto status push daemon
│   ├── system-prompt.md           # Docs for code-sync tools
│   ├── generate-token.js          # Token generation
│   ├── portara-sender.service     # Systemd service file
│   └── .env                       # Sync config
├── v3/                            # Trading engine v3
│   ├── index.js                   # Main entry point
│   ├── system-prompt.txt          # ⭐ Full trading agent docs
│   ├── system-prompt-prediction-markets.txt  # ⭐ Prediction market docs
│   ├── interface-prompt.txt       # Bloomberg-style UI generation prompt
│   ├── .env                       # Exchange API keys & config
│   ├── libs/                      # Trading libraries
│   │   ├── trading-interface.js   # Core trading interface
│   │   ├── config.js              # Config loader
│   │   ├── telegram.js            # Telegram notifications
│   │   ├── trade.js               # Hyperliquid adapter
│   │   ├── ccxtTrade.js           # CCXT exchange adapter
│   │   ├── extendedTrade.js       # Extended exchange adapter
│   │   ├── riseTrade.js           # Rise exchange adapter
│   │   ├── drManhattanTrade.js    # DrManhattan adapter
│   │   ├── predictfunTrade.js     # PredictFun adapter
│   │   ├── setup-websocket.js     # WebSocket setup
│   │   └── *-markets.json         # Market data per exchange
│   ├── strategies/                # ⭐ All strategy files live here
│   ├── scripts/                   # Backtesting & utility scripts
│   ├── tests/                     # Test suite (vitest)
│   └── backtests/                 # Backtest output data
├── node_modules/
├── package.json
└── README.md
```

---

## Step 5: Common Operations

All remote commands go through `./ssh-cmd.sh`. The commands below show the **remote command string** (the third argument).

### NVM prefix

For any command that needs `node`, `npm`, or `pm2`, prefix with:
```
export NVM_DIR=\$HOME/.nvm && . \$NVM_DIR/nvm.sh
```

### PM2 Process Management

| Action | Remote command |
|--------|---------|
| List processes | `export NVM_DIR=\$HOME/.nvm && . \$NVM_DIR/nvm.sh && pm2 list` |
| Start a strategy | `export NVM_DIR=\$HOME/.nvm && . \$NVM_DIR/nvm.sh && cd /root/.openclaw/workspace/portara-agent/v3 && pm2 start strategies/<file>.js --name 'strategy:multi:<name>' --interpreter node` |
| Stop | `export NVM_DIR=\$HOME/.nvm && . \$NVM_DIR/nvm.sh && pm2 stop <name-or-id>` |
| Restart | `export NVM_DIR=\$HOME/.nvm && . \$NVM_DIR/nvm.sh && pm2 restart <name-or-id>` |
| Delete | `export NVM_DIR=\$HOME/.nvm && . \$NVM_DIR/nvm.sh && pm2 delete <name-or-id>` |
| Logs (last 50) | `export NVM_DIR=\$HOME/.nvm && . \$NVM_DIR/nvm.sh && pm2 logs <name-or-id> --lines 50` |
| Process details | `export NVM_DIR=\$HOME/.nvm && . \$NVM_DIR/nvm.sh && pm2 show <name-or-id>` |
| Save (persist across reboots) | `export NVM_DIR=\$HOME/.nvm && . \$NVM_DIR/nvm.sh && pm2 save` |

**Naming convention:**
- Single-exchange: `strategy:<exchange>:<strategy_name>`
- Multi-exchange: `strategy:multi:<strategy_name>`

### Code-Sync Sender Tools

| Action | Remote command |
|--------|---------|
| Run backtest | `export NVM_DIR=\$HOME/.nvm && . \$NVM_DIR/nvm.sh && cd /root/.openclaw/workspace/portara-agent/code-sync && node sender.js backtest <strategy>` |
| Fetch logs | `export NVM_DIR=\$HOME/.nvm && . \$NVM_DIR/nvm.sh && cd /root/.openclaw/workspace/portara-agent/code-sync && node sender.js logs <process-name>` |
| Fetch logs (summary) | `... && node sender.js logs <process-name> --summary` |
| Fetch logs (custom lines) | `... && node sender.js logs <process-name> --lines 500` |
| Check PM2 status | `export NVM_DIR=\$HOME/.nvm && . \$NVM_DIR/nvm.sh && cd /root/.openclaw/workspace/portara-agent/code-sync && node sender.js status` |

**Strategy path resolution** (for backtest command):
1. Absolute path
2. Name in strategies dir: `my_strategy.js` or `my_strategy` (auto-appends `.js`)
3. Directory (multi-file): reads all `.js` files in folder
4. Relative to cwd

### File Operations

| Action | Remote command |
|--------|---------|
| Read a file | `cat <path>` |
| Write/overwrite | Use heredoc: `cat > <path> << 'EOF' ... EOF` |
| Append | Use heredoc: `cat >> <path> << 'EOF' ... EOF` |
| Inline edit | `sed -i 's/old/new/g' <path>` |
| List strategies | `ls /root/.openclaw/workspace/portara-agent/v3/strategies/` |

---

## Step 6: Deploying or Updating a Strategy

Follow this workflow every time:

1. **Save the strategy locally** to `<this-repo>/strategies/<name>.js`
2. **Write the strategy to the remote** at `/root/.openclaw/workspace/portara-agent/v3/strategies/<name>.js`
3. **Start or restart** via PM2
4. **Run backtest immediately after** (this is **non-negotiable** — it links the process to the viewer):
   ```bash
   ./ssh-cmd.sh <IP> '<PASSWORD>' "export NVM_DIR=\$HOME/.nvm && . \$NVM_DIR/nvm.sh && cd /root/.openclaw/workspace/portara-agent/code-sync && node sender.js backtest <strategy-file>"
   ```
5. **Verify** with `pm2 list` and `pm2 logs <name> --lines 20`

---

## State Files

Each PM2 strategy maintains durable state at:
```
/root/.openclaw/workspace/state/<pm2_name>.json
```

State files track positions, open orders, and idempotency markers. **The exchange is always the source of truth** — state files are for coordination and restart recovery.

---

## Safety Rules (Non-Negotiable)

- **REAL MONEY** is at risk on this box
- **Never expose** API keys, `.env` contents, or credentials in conversation output
- **All trading functions are async** — always use `await`
- **Always call `getMarkets()`** to discover market names before trading
- **Always query exchange state** before acting (don't assume positions)
- **Prefer capital preservation** over aggressiveness
- **Ask before destructive actions** — deleting strategies, stopping processes, or modifying live positions

---

## Quick-Start Checklist for a Fresh Session

1. [ ] Ask the user for the **server IP** and **SSH password**
2. [ ] Test connectivity: `./ssh-cmd.sh <IP> '<PASS>' "echo connected"`
3. [ ] Sync prompt files locally (if missing or stale): `system-prompt.txt`, `system-prompt-prediction-markets.txt`, `backtest-prompt.md`, `interface-prompt.txt`
4. [ ] Sync remote strategies into local `strategies/` folder (if missing or stale)
5. [ ] Run `pm2 list` to see what's running
6. [ ] Read the relevant prompt file(s) for the task at hand (see "Which prompt file to read" table)
7. [ ] Ask the user what they need help with
