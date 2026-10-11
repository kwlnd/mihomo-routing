#!/usr/bin/env bash
# Проверяет routing.yaml ядром mihomo.
# В шаблоне группа «Автовыбор» пустая (её заполняет Remnawave), поэтому в проверяемую копию подставляется заглушка.
set -euo pipefail

MIHOMO=${MIHOMO:-mihomo}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

sed 's/^  - name: Автовыбор$/&\n    proxies: [Без VPN]/' "$ROOT/routing.yaml" > "$TMP/config.yaml"
if ! grep -q '^    proxies: \[Без VPN\]$' "$TMP/config.yaml"; then
  echo "не нашёл группу «Автовыбор» в routing.yaml"
  exit 1
fi

"$MIHOMO" -t -d "$TMP" -f "$TMP/config.yaml"
