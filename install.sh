#!/usr/bin/env bash
# Run this from the cloned repo on the live ISO.
# Usage: bash install.sh [http-proxy]
# Example: bash install.sh http://192.168.122.1:3128
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# Enable flakes + short timeout for non-sudo nix commands
export NIX_CONFIG="experimental-features = nix-command flakes
connect-timeout = 5"

NIX_OPTS=(--option connect-timeout 5)
PROXY="${http_proxy:-${https_proxy:-}}"
[[ -n "$PROXY" ]] && NIX_OPTS+=(--option http-proxy "$PROXY")

# ── Step 1: confirm disk ──────────────────────────────────────────────────────
echo "Current block devices:"
lsblk
echo ""
echo "disko will WIPE the disk configured in hosts/nixos/disko.nix."
read -rp "Continue? [y/N] " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }

# ── Step 2: partition and format ──────────────────────────────────────────────
echo ""
echo "==> Partitioning disk..."
sudo nix run \
  --extra-experimental-features "nix-command flakes" \
  "${NIX_OPTS[@]}" \
  github:nix-community/disko/latest -- \
  --mode disko \
  "$REPO_DIR/hosts/nixos/disko.nix"

echo ""
echo "Mounts:"
mount | grep /mnt

# ── Step 3: hardware config ───────────────────────────────────────────────────
echo ""
echo "==> Generating hardware configuration..."
sudo nixos-generate-config --no-filesystems --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix \
  "$REPO_DIR/hosts/nixos/hardware-configuration.nix"
echo "    Saved to hosts/nixos/hardware-configuration.nix"

# ── Step 4: install NixOS ────────────────────────────────────────────────────
echo ""
echo "==> Installing NixOS..."
sudo nixos-install --flake "$REPO_DIR#nixos" --no-root-passwd "${NIX_OPTS[@]}"


# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "Done. Set your password, then reboot:"
echo ""
echo "  sudo nixos-enter --root /mnt -c 'passwd $(whoami)'"
echo "  reboot"
echo ""
