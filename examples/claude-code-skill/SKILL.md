---
name: tunnel-local-server-via-tapinto
description: Use when the user asks to share, expose, or test a local server (an MCP server, a webhook receiver, a dev API, a local model) from outside their machine. Opens a Tapinto tunnel, uses it for the task, then closes it so the meter stops.
---

# Open a Tapinto tunnel, then close it when done

This skill assumes the `tapinto` MCP server is wired into the client config
(see `examples/mcp-clients/` in the tapinto-cli repo). When that's in place,
five tools are available: `create_tunnel`, `list_tunnels`, `get_tunnel`,
`stop_tunnel`, `whoami`.

## When to use this

The user wants something on their machine to be reachable from elsewhere:

- "Let me test my local MCP server from Claude Desktop"
- "Share my dev server with someone for 15 minutes"
- "Point a webhook at this localhost"
- "Run my local LLM behind a public URL"

If the user just wants the URL — without anything to do with it — skip the
"use the tunnel" middle step but **still close it** at the end.

## Steps

1. **Confirm the local URL.** Ask the user (or read it from context) — must
   be `http://...` or `https://...`. Common: `http://localhost:8080`.
2. **Open the tunnel.** Call `create_tunnel` with `local_url` set to the URL
   from step 1. Capture the returned `id` and `publicUrl` — you'll need them
   to clean up.
3. **Tell the user what they got.** Show them the `publicUrl` (single line,
   so they can copy it).
4. **Do the actual work.** Whatever the user asked for — test, share, hit
   the public URL with curl, paste it somewhere, etc.
5. **Close the tunnel as soon as the work is done.** Call `stop_tunnel`
   with the `id` captured in step 2. Tapinto bills per minute — leaving a
   tunnel open after you're done with it spends the user's free quota for
   nothing.

## Closing the loop

- If the user explicitly says "leave it open" or "keep it running", skip
  step 5 and tell them they'll need to stop it themselves with
  `tapinto stop <id>` from the CLI (or from the dashboard at
  https://tapinto.dev/tunnels).
- If `create_tunnel` returns an error mentioning "subdomain in use", an
  earlier tunnel with the same name is still active. Either pick a fresh
  name or call `stop_tunnel` on the existing one first
  (`list_tunnels` shows what's active).
- If you crash or get interrupted between step 2 and step 5, the user can
  always run `tapinto stop --all` from the CLI to close everything.

## Why "stop when done" matters

The free tier is 60 minutes / week. A skill that opens a tunnel for a
five-second test and forgets to close it eats those 60 minutes in an
overnight idle session. The whole point of the per-minute meter is that
your bill matches what you actually used — closing the tunnel is part of
that contract.
