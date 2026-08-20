#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run with sudo: sudo ./image/build-iso.sh" >&2
  exit 1
fi

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
work="${root}/.iso-work"

command -v lb >/dev/null 2>&1 || {
  apt-get update
  apt-get install -y live-build
}

mkdir -p "$work"
cd "$work"
lb clean --purge 2>/dev/null || true
lb config noauto \
  --mode debian \
  --distribution bookworm \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --debian-installer live \
  --security false \
  --archive-areas "main contrib non-free-firmware" \
  --bootappend-live "boot=live components persistence username=reviveai hostname=reviveai"

mkdir -p config/package-lists config/hooks/live config/includes.chroot/opt/reviveai/bin
mkdir -p config/includes.chroot/opt/reviveai/models config/includes.chroot/etc/systemd/system
mkdir -p config/includes.chroot/etc/xdg/autostart

cp "$root/systemd/reviveai.service" config/includes.chroot/etc/systemd/system/
cp "$root/scripts/download-model.sh" config/includes.chroot/opt/reviveai/bin/download-model
cp "$root/image/reviveai-firstboot.desktop" config/includes.chroot/etc/xdg/autostart/
cp "$root/image/packages.list.chroot" config/package-lists/reviveai.list.chroot
cp "$root/image/0100-build-llama.hook.chroot" config/hooks/live/
cp "$root/image/0200-enable-reviveai.hook.chroot" config/hooks/live/

lb build
cp live-image-amd64.hybrid.iso "$root/reviveai-amd64.iso"
echo "Created $root/reviveai-amd64.iso"
