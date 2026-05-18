#!/usr/bin/env bash
#
# Tapinto CLI installer. One-shot script that detects OS+arch, fetches the
# latest GitHub Release archive, verifies the checksum, and drops the binary
# into $HOME/.local/bin (or $PREFIX/bin).
#
# Defaults to a user-local install so you don't need sudo. Set
# PREFIX=/usr/local (or any other writable prefix) for a system-wide install.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Cre8-IT-Code/tapinto-cli/main/install.sh | bash
#   # system-wide (uses sudo if needed):
#   curl -fsSL https://raw.githubusercontent.com/Cre8-IT-Code/tapinto-cli/main/install.sh | PREFIX=/usr/local bash
#   # pin a specific version:
#   curl -fsSL https://raw.githubusercontent.com/Cre8-IT-Code/tapinto-cli/main/install.sh | VERSION=v0.1.0 bash

set -euo pipefail

REPO="Cre8-IT-Code/tapinto-cli"
# Default to ~/.local — no sudo, works on every supported platform. Users who
# want a system install can override via PREFIX (and accept the sudo prompt).
PREFIX="${PREFIX:-${HOME}/.local}"
BINDIR="${PREFIX}/bin"
VERSION="${VERSION:-}"

err() { printf '\033[31merror\033[0m: %s\n' "$*" >&2; exit 1; }
info() { printf '\033[34minfo\033[0m: %s\n' "$*"; }
ok()   { printf '\033[32m✓\033[0m %s\n' "$*"; }

# --- detect OS + arch ---
os=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$os" in
  darwin|linux) ;;
  *) err "unsupported OS: $os (need darwin or linux)";;
esac

raw_arch=$(uname -m)
case "$raw_arch" in
  x86_64|amd64) arch="amd64";;
  arm64|aarch64) arch="arm64";;
  *) err "unsupported arch: $raw_arch (need x86_64 or arm64)";;
esac

# --- discover latest release if not pinned ---
if [ -z "$VERSION" ]; then
  info "looking up latest release of $REPO"
  VERSION=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
            | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1)
  [ -n "$VERSION" ] || err "couldn't determine latest version (rate-limited? pinned via VERSION= ?)"
fi

VERSION_NUM="${VERSION#v}"
ASSET="tapinto_${VERSION_NUM}_${os}_${arch}.tar.gz"
URL="https://github.com/${REPO}/releases/download/${VERSION}/${ASSET}"
CHECKSUMS_URL="https://github.com/${REPO}/releases/download/${VERSION}/checksums.txt"

info "downloading $ASSET"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

curl -fsSL -o "$tmp/$ASSET" "$URL" || err "download failed: $URL"
curl -fsSL -o "$tmp/checksums.txt" "$CHECKSUMS_URL" || err "checksum download failed"

# --- verify checksum ---
info "verifying sha256"
expected=$(grep -E "  $ASSET\$" "$tmp/checksums.txt" | awk '{print $1}')
[ -n "$expected" ] || err "no checksum entry for $ASSET in checksums.txt"
if command -v shasum >/dev/null 2>&1; then
  got=$(shasum -a 256 "$tmp/$ASSET" | awk '{print $1}')
else
  got=$(sha256sum "$tmp/$ASSET" | awk '{print $1}')
fi
[ "$got" = "$expected" ] || err "checksum mismatch: expected $expected, got $got"
ok "sha256 verified"

# --- extract + install ---
info "installing to $BINDIR (set PREFIX to change)"
tar -xzf "$tmp/$ASSET" -C "$tmp"
[ -f "$tmp/tapinto" ] || err "archive missing tapinto binary"
chmod +x "$tmp/tapinto"

# Create the dir if needed. mkdir might itself need sudo for system prefixes;
# do the same fallback dance as the install step.
if ! mkdir -p "$BINDIR" 2>/dev/null; then
  info "creating $BINDIR with sudo"
  sudo mkdir -p "$BINDIR"
fi
if [ -w "$BINDIR" ]; then
  install -m 0755 "$tmp/tapinto" "$BINDIR/tapinto"
else
  info "$BINDIR is not writable by your user — escalating with sudo"
  info "  (tip: re-run with PREFIX=\$HOME/.local to install without sudo)"
  sudo install -m 0755 "$tmp/tapinto" "$BINDIR/tapinto"
fi

ok "installed tapinto $VERSION to $BINDIR/tapinto"

# --- post-install ---
# Detect whether the install dir is already on the user's PATH. If not, print
# copy-pasteable rc lines for the common shells.
case ":$PATH:" in
  *":$BINDIR:"*) ;;
  *)
    info "$BINDIR is not on your PATH yet. Add this line to your shell rc:"
    printf '\n  export PATH="%s:$PATH"\n' "$BINDIR"
    printf '\nQuick add:\n'
    printf "  # bash:  echo 'export PATH=\"%s:\$PATH\"' >> ~/.bashrc\n"  "$BINDIR"
    printf "  # zsh:   echo 'export PATH=\"%s:\$PATH\"' >> ~/.zshrc\n"   "$BINDIR"
    printf "  # fish:  fish_add_path %s\n\n" "$BINDIR"
    ;;
esac

cat <<EOF

Next:
  tapinto login                            # authenticate
  tapinto https://localhost:8080 --inspect # expose a local server
  tapinto update                           # upgrade the CLI later

Want AI assistants (Claude Desktop, Cursor, Windsurf, Zed) to create
tunnels on your behalf? Wire 'tapinto mcp' into your MCP client config —
see https://tapinto.dev/docs/tunnel-vs-mcp-toolkit

First 60 minutes of tunnel time every week are FREE — no credit card.
After that: \$0.005/tunnel-minute, \$0.008/mcp-toolkit-minute, USD-billed.

Docs:    https://tapinto.dev/docs
Compare: https://tapinto.dev/compare
EOF
