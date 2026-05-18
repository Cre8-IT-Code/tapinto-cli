# Examples

Drop-in snippets for the most common ways people wire Tapinto into their tools.

## What's here

| Folder                                              | What it is                                                                                  |
| --------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| [`mcp-clients/`](./mcp-clients)                     | Config snippets that wire `tapinto mcp` into an AI client so the assistant itself can open tunnels (Claude Desktop, Cursor, Windsurf, Zed). |
| [`claude-code-skill/`](./claude-code-skill)         | A Claude Code skill that opens a tunnel, uses it, and **stops it when done** — so the assistant doesn't quietly burn your free minutes.        |
| [`copilot-instructions/`](./copilot-instructions)   | A `copilot-instructions.md` file that teaches GitHub Copilot Chat the same start-then-stop pattern.                                              |

## How `tapinto mcp` fits in

The `tapinto mcp` subcommand speaks the Model Context Protocol on stdio. When
you wire it into an AI client's config, the assistant gets these tools:

- `create_tunnel` — open a public HTTPS URL onto a local server.
- `list_tunnels` — show your active tunnels.
- `get_tunnel` — fetch details for a specific tunnel.
- `stop_tunnel` — close a tunnel cleanly so the meter stops.
- `whoami` — confirm which Tapinto account the AI is acting as.

Each minute a tunnel is open counts toward your weekly quota
(60 min free), so always include a "stop when done" step in any skill or
instruction you write — otherwise an assistant that opens a tunnel for a
five-second test can keep it open all night.

## Try it

1. Install the CLI: `curl -fsSL https://raw.githubusercontent.com/Cre8-IT-Code/tapinto-cli/main/install.sh | bash`
2. Sign in and mint an API key at <https://tapinto.dev/settings/api-keys>
3. `tapinto login --key tk_…`
4. Copy the snippet that matches your client.
