#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for script in "$root/hardware-check.sh" "$root/install.sh" "$root/scripts/download-model.sh"; do
  bash -n "$script"
done

bash -n "$root/image/build-iso.sh"
sh -n "$root/image/0100-build-llama.hook.chroot"
sh -n "$root/image/0200-enable-reviveai.hook.chroot"

grep -q -- '--host 127.0.0.1' "$root/systemd/reviveai.service"
grep -q 'ConditionPathExists=' "$root/systemd/reviveai.service"
echo "Smoke tests passed."
