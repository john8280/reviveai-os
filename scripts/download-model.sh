#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run with sudo: sudo /opt/reviveai/bin/download-model" >&2
  exit 1
fi

mem_kib="$(awk '/MemTotal:/ {print $2}' /proc/meminfo)"
mem_gib="$((mem_kib / 1024 / 1024))"

# Stable GGUF examples. Each model has its own license and terms. A URL can be
# overridden for a preferred model mirror without changing the installer.
if (( mem_gib < 7 )); then
  tier="tiny (1.7B Q4, about 1.1 GB)"
  default_url="https://huggingface.co/HuggingFaceTB/SmolLM2-1.7B-Instruct-GGUF/resolve/main/smollm2-1.7b-instruct-q4_k_m.gguf"
elif (( mem_gib < 14 )); then
  tier="small (3B Q4, about 2 GB)"
  default_url="https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF/resolve/main/qwen2.5-3b-instruct-q4_k_m.gguf"
else
  tier="standard (7B Q4, about 4.7 GB)"
  default_url="split"
fi

echo "Detected approximately ${mem_gib} GiB RAM."
echo "Recommended model: $tier"
read -r -p "Download the recommended model? [y/N] " answer
case "$answer" in
  y|Y|yes|YES) ;;
  *) echo "Cancelled without downloading."; exit 0 ;;
esac

destination="/opt/reviveai/models/assistant.gguf"
temporary="${destination}.partial"

if [[ "$default_url" == "split" && -z "${REVIVEAI_MODEL_URL:-}" ]]; then
  base="https://huggingface.co/Qwen/Qwen2.5-7B-Instruct-GGUF/resolve/main"
  first="/opt/reviveai/models/qwen2.5-7b-instruct-q4_k_m-00001-of-00002.gguf"
  second="/opt/reviveai/models/qwen2.5-7b-instruct-q4_k_m-00002-of-00002.gguf"
  curl --fail --location --continue-at - --output "${first}.partial" \
    "$base/qwen2.5-7b-instruct-q4_k_m-00001-of-00002.gguf"
  curl --fail --location --continue-at - --output "${second}.partial" \
    "$base/qwen2.5-7b-instruct-q4_k_m-00002-of-00002.gguf"
  mv "${first}.partial" "$first"
  mv "${second}.partial" "$second"
  ln -sfn "$(basename "$first")" "$destination"
  chown -h reviveai:reviveai "$destination"
  chown reviveai:reviveai "$first" "$second"
  chmod 0640 "$first" "$second"
else
  model_url="${REVIVEAI_MODEL_URL:-$default_url}"
  curl --fail --location --continue-at - --output "$temporary" "$model_url"
  mv "$temporary" "$destination"
  chown reviveai:reviveai "$destination"
  chmod 0640 "$destination"
fi
echo "Model installed at $destination"
