#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this installer with sudo: sudo ./install.sh" >&2
  exit 1
fi

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
install_dir="/opt/reviveai"
service_user="reviveai"

"${project_dir}/hardware-check.sh"

if ! command -v apt-get >/dev/null 2>&1; then
  echo "This MVP supports antiX/Debian-family systems with apt." >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
  ca-certificates cmake curl g++ git libcurl4-openssl-dev make pkg-config

if ! id "$service_user" >/dev/null 2>&1; then
  useradd --system --home-dir "$install_dir" --shell /usr/sbin/nologin "$service_user"
fi

install -d -m 0755 "$install_dir/bin" "$install_dir/src"
install -d -o "$service_user" -g "$service_user" -m 0750 "$install_dir/models"

if [[ ! -d "$install_dir/src/llama.cpp/.git" ]]; then
  git clone --depth 1 https://github.com/ggml-org/llama.cpp.git "$install_dir/src/llama.cpp"
else
  git -C "$install_dir/src/llama.cpp" pull --ff-only
fi

cmake -S "$install_dir/src/llama.cpp" -B "$install_dir/src/llama.cpp/build" \
  -DGGML_NATIVE=OFF -DLLAMA_CURL=ON -DCMAKE_BUILD_TYPE=Release
cmake --build "$install_dir/src/llama.cpp/build" --config Release \
  --target llama-server -j "$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
install -m 0755 "$install_dir/src/llama.cpp/build/bin/llama-server" "$install_dir/bin/llama-server"
install -m 0755 "$project_dir/scripts/download-model.sh" "$install_dir/bin/download-model"
install -m 0644 "$project_dir/systemd/reviveai.service" /etc/systemd/system/reviveai.service

systemctl daemon-reload
systemctl enable reviveai.service

cat <<EOF

ReviveAI runtime installed.
Next, choose and download a model:
  sudo $install_dir/bin/download-model

Then start the assistant:
  sudo systemctl start reviveai

Open http://127.0.0.1:8080 in a browser.
EOF
