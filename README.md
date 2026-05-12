# tapinto-cli

Public distribution channel for the **Tapinto CLI** — signed release binaries,
the `install.sh` curl-pipe installer, and the Homebrew formula.

This repository contains **no source code**. The CLI is built from a private
source repository and the release artifacts are published here so that anyone
can install Tapinto without a GitHub login.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/Cre8-IT-Code/tapinto-cli/main/install.sh | bash
```

Pin a specific version:

```sh
curl -fsSL https://raw.githubusercontent.com/Cre8-IT-Code/tapinto-cli/main/install.sh | VERSION=v0.1.0 bash
```

Install to a custom prefix (no sudo):

```sh
curl -fsSL https://raw.githubusercontent.com/Cre8-IT-Code/tapinto-cli/main/install.sh | PREFIX=~/.local bash
```

The installer detects your OS (darwin, linux) and architecture (amd64, arm64),
downloads the matching tarball from the latest GitHub Release on this repo,
and verifies its SHA-256 checksum against `checksums.txt` from the same release
before extracting `tapinto` into `$PREFIX/bin`.

## Releases

Release artifacts (`tapinto_<version>_<os>_<arch>.tar.gz` + `checksums.txt`) are
attached to every tagged release on this repo. See the
[Releases page](https://github.com/Cre8-IT-Code/tapinto-cli/releases) for the
latest version and changelog.

## Verifying a download by hand

```sh
VERSION=v0.1.0
ASSET=tapinto_${VERSION#v}_$(uname -s | tr '[:upper:]' '[:lower:]')_$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/').tar.gz
curl -LO https://github.com/Cre8-IT-Code/tapinto-cli/releases/download/${VERSION}/${ASSET}
curl -LO https://github.com/Cre8-IT-Code/tapinto-cli/releases/download/${VERSION}/checksums.txt
grep "  ${ASSET}$" checksums.txt | shasum -a 256 -c -
```

## Project

- Website & docs: <https://tapinto.dev>
- Pricing: <https://tapinto.dev/pricing>
- Issue tracker & support: <https://tapinto.dev> (contact link in the footer)
