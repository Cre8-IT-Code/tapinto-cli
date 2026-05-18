<p align="center">
  <a href="https://tapinto.dev">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://tapinto.dev/logo-wordmark-light-text-1280x320.png">
      <img src="https://tapinto.dev/logo-wordmark-dark-text-1280x320.png" alt="Tapinto" width="320">
    </picture>
  </a>
</p>

<p align="center">
  <strong>The MCP development toolkit — public HTTPS URL onto a local server in one command.</strong>
</p>

<p align="center">
  <a href="https://github.com/Cre8-IT-Code/tapinto-cli/releases/latest"><img src="https://img.shields.io/github/v/release/Cre8-IT-Code/tapinto-cli?label=latest&color=6366f1" alt="latest release"></a>
  <img src="https://img.shields.io/badge/platforms-macOS%20%7C%20Linux-94a3b8" alt="platforms">
  <img src="https://img.shields.io/badge/arch-amd64%20%7C%20arm64-94a3b8" alt="arch">
  <a href="https://tapinto.dev/pricing"><img src="https://img.shields.io/badge/free%20tier-60%20min%20%2F%20week-10b981" alt="free tier"></a>
</p>

<p align="center">
  <a href="https://tapinto.dev">Website</a> ·
  <a href="https://tapinto.dev/docs">Docs</a> ·
  <a href="https://tapinto.dev/pricing">Pricing</a> ·
  <a href="https://tapinto.dev/login"><strong>Sign up free</strong></a>
</p>

---

## What you get

- A stable `https://<slug>.tapinto.dev` URL onto any local server — works from
  behind NAT and firewalls (single outbound WebSocket).
- Auto-detects MCP servers; tunnels to MCP servers unlock a **live inspector**
  that parses every JSON-RPC tool call, resource read, and prompt fetch.
- MCP **compliance linting** (`--strict`) — warns on protocol drift.
- **Record &amp; replay** an MCP session to a file for deterministic bug repros.
- Edge-injected **auth gate** (`--auth`, `--share`) — keep your tunnel
  private without touching your local app.
- `tapinto mcp` subcommand — wires Claude Desktop / Cursor / Windsurf / Zed
  so the AI itself can create and manage tunnels.
- USD per-minute billing via Stripe Meters. First **60 min / week free**, no
  credit card. `$0.005`/tunnel-minute, `$0.008`/mcp-toolkit-minute after.

## Install

One-liner — installs to `~/.local/bin`, no sudo needed:

```sh
curl -fsSL https://raw.githubusercontent.com/Cre8-IT-Code/tapinto-cli/main/install.sh | bash
```

Already installed? Upgrade in place:

```sh
tapinto update
```

<details>
<summary>System-wide / pinned-version variants</summary>

System-wide install (`/usr/local/bin`, uses sudo):

```sh
curl -fsSL https://raw.githubusercontent.com/Cre8-IT-Code/tapinto-cli/main/install.sh | PREFIX=/usr/local bash
```

Pin a specific version:

```sh
curl -fsSL https://raw.githubusercontent.com/Cre8-IT-Code/tapinto-cli/main/install.sh | VERSION=v0.1.2 bash
```

The installer verifies the SHA-256 of every download against `checksums.txt`
on the matching release before extracting `tapinto` into `$PREFIX/bin`.

</details>

## Getting started

### 1. Get an API key

Sign in to the dashboard with GitHub, then mint a key from
**[Settings → API keys](https://tapinto.dev/settings/api-keys)**. Keys
start with `tk_` and can be revoked any time.

### 2. Authenticate the CLI

```sh
tapinto login --key tk_xxxxxxxxxxxxxxxx
```

Or skip `login` and set the env var:

```sh
export TAPINTO_API_KEY=tk_xxxxxxxxxxxxxxxx
```

### 3. Open a tunnel

```sh
tapinto https://localhost:8080 --inspect
```

The CLI prints a stable `https://<slug>.tapinto.dev` URL and opens the live
MCP traffic inspector in your terminal. Paste the URL into Claude Desktop,
Cursor, Windsurf, or any other MCP client.

### 4. (Optional) Let an AI assistant manage tunnels

Add this to your MCP client config (Claude Desktop / Cursor / Windsurf / Zed):

```json
{
  "mcpServers": {
    "tapinto": {
      "command": "tapinto",
      "args": ["mcp"]
    }
  }
}
```

Then ask the assistant: *"create a tapinto tunnel for http://localhost:8080"* —
the `tapinto mcp` process speaks to your client directly.

## Commands

| Command                  | What it does                                           |
| ------------------------ | ------------------------------------------------------ |
| `tapinto [URL]`          | Open a tunnel onto a local URL                         |
| `tapinto login`          | Authenticate with an API key                           |
| `tapinto logout`         | Forget the saved API key                               |
| `tapinto status`         | Show active tunnels                                    |
| `tapinto stop [id]`      | Stop one or all tunnels                                |
| `tapinto logs`           | Show recent MCP traffic                                |
| `tapinto usage`          | Show current billing-period usage                      |
| `tapinto config`         | Get / set CLI configuration values                     |
| `tapinto update`         | Upgrade the CLI to the latest release                  |
| `tapinto mcp`            | Run as an MCP server on stdio (for AI clients)         |

## Flags

| Flag                  | What it does                                              |
| --------------------- | --------------------------------------------------------- |
| `--inspect`           | Open the live MCP traffic inspector                       |
| `--strict`            | Enable MCP compliance linting                             |
| `--record <file>`     | Record the MCP session to a file                          |
| `--replay <file>`     | Replay a recorded session                                 |
| `--auth token[=val]`  | Require an edge-side auth token on every request          |
| `--share <emails>`    | Comma-separated email allowlist for auth-gated tunnels    |
| `--name <slug>`       | Custom subdomain (subject to availability)                |
| `--static`            | Reuse your account's persistent random subdomain          |
| `--bearer <token>`    | API key for this invocation (defaults to `$TAPINTO_API_KEY`)|

## Verifying a download by hand

```sh
VERSION=v0.1.2
ASSET=tapinto_${VERSION#v}_$(uname -s | tr '[:upper:]' '[:lower:]')_$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/').tar.gz
curl -LO https://github.com/Cre8-IT-Code/tapinto-cli/releases/download/${VERSION}/${ASSET}
curl -LO https://github.com/Cre8-IT-Code/tapinto-cli/releases/download/${VERSION}/checksums.txt
grep "  ${ASSET}$" checksums.txt | shasum -a 256 -c -
```

## About this repository

This repo holds the public CLI distribution channel — signed release binaries
and the curl-pipe installer. **No source code lives here**; the CLI is built
from a private source repository and the artifacts are published here so
anyone can install Tapinto without a GitHub login.

For docs, the inspector, billing settings, and the API key console, head to
**[tapinto.dev](https://tapinto.dev)**.

<p align="center">
  <sub>
    <a href="https://tapinto.dev">tapinto.dev</a> ·
    <a href="https://tapinto.dev/docs">docs</a> ·
    <a href="https://tapinto.dev/pricing">pricing</a> ·
    <a href="https://tapinto.dev/compare">vs ngrok / cloudflared / localtunnel</a> ·
    <a href="https://tapinto.dev/privacy">privacy</a> ·
    <a href="https://tapinto.dev/terms">terms</a>
  </sub>
</p>
