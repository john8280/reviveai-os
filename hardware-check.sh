#!/usr/bin/env bash
set -euo pipefail

arch="$(uname -m)"
mem_kib="$(awk '/MemTotal:/ {print $2}' /proc/meminfo)"
mem_gib="$((mem_kib / 1024 / 1024))"
cores="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"

case "$arch" in
  x86_64|aarch64) ;;
  *)
    echo "Unsupported CPU architecture: $arch"
    echo "ReviveAI requires a 64-bit x86_64 or ARM64 computer."
    exit 1
    ;;
esac

if (( mem_gib < 4 )); then
  tier="unsupported"
  verdict="Less than 4 GB RAM: modern local AI will be impractically constrained."
elif (( mem_gib < 7 )); then
  tier="tiny"
  verdict="Use a 1–2B Q4 GGUF model. Expect patient, short-answer use."
elif (( mem_gib < 14 )); then
  tier="small"
  verdict="Use a 3B Q4 GGUF model. This should be a practical basic assistant."
else
  tier="standard"
  verdict="Use a 7B Q4 GGUF model for stronger answers."
fi

cat <<EOF
ReviveAI hardware report
Architecture : $arch
CPU threads  : $cores
Memory       : approximately ${mem_gib} GiB
Model tier   : $tier
Assessment   : $verdict
EOF

if grep -qi hypervisor /proc/cpuinfo; then
  echo "Note         : virtualized CPU detected; performance may differ from bare metal."
fi
