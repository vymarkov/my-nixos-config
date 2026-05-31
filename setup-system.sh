#!/usr/bin/env bash
set -euo pipefail

# Run with: sudo HOST=nixos ./setup-system.sh
# Requires root to symlink /etc/nixos and activate the new configuration.

HOST="${HOST:-nixos}"
REPO="$(cd "$(dirname "$0")" && pwd)"

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  echo "Run as root: sudo HOST=$HOST bash $REPO/setup-system.sh" >&2
  exit 1
fi

if [[ -e /etc/nixos && ! -L /etc/nixos ]]; then
  echo "Backing up /etc/nixos -> /etc/nixos.old"
  mv /etc/nixos /etc/nixos.old
fi

if [[ ! -L /etc/nixos ]]; then
  echo "Linking /etc/nixos -> $REPO"
  ln -s "$REPO" /etc/nixos
fi

echo "Building system for host: $HOST"
nixos-rebuild build --flake "$REPO#$HOST"

echo "Switching to new configuration..."
nixos-rebuild switch --flake "$REPO#$HOST"

echo "Done. /etc/nixos -> $REPO (host: $HOST)"
