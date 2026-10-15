#!/usr/bin/env bash
# Собирает все списки для конфига в каталог out/ (публикуется в ветку release):
#   lists/*.txt  -> out/lists/*.mrs   свои списки (*-ips.txt пакуются как ipcidr, остальные как domain)
#   out/rules/*                       внешние списки, скачанные из первоисточников
# Если источник недоступен или отдал мусор, старый файл остаётся как был, а скрипт завершается с ошибкой.
set -uo pipefail

MIHOMO=${MIHOMO:-mihomo}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
OUT=${OUT:-$ROOT/out}
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
failed=()

fetch() { curl -fsSL --retry 3 --retry-delay 5 --max-time 180 "$1" | tr -d '\r'; }

# publish <domain|ipcidr|classical> <файл назначения> <минимум строк> <команда, печатающая строки>
publish() {
  local kind=$1 dest=$2 min=$3 raw="$TMP/raw" out="$TMP/out" count
  shift 3
  if ! "$@" | sort -u > "$raw"; then
    echo "FAIL $dest: источник недоступен"; failed+=("$dest"); return
  fi
  count=$(wc -l < "$raw")
  if [ "$count" -lt "$min" ]; then
    echo "FAIL $dest: $count строк, ожидалось не меньше $min"; failed+=("$dest"); return
  fi
  if [ "$kind" = classical ]; then
    { echo "payload:"; sed 's/^/  - /' "$raw"; } > "$out"
  elif ! "$MIHOMO" convert-ruleset "$kind" text "$raw" "$out" || [ ! -s "$out" ]; then
    echo "FAIL $dest: mihomo не смог упаковать"; failed+=("$dest"); return
  fi
  mkdir -p "$(dirname "$OUT/$dest")"
  mv "$out" "$OUT/$dest"
  echo "ok   $dest: $count"
}

DOMAIN='^[A-Za-z0-9._-]+$'

# Сервисы Google и YouTube из списков блокировок не берём: Google работает напрямую,
# YouTube идёт своей группой, а нейросети Google — через список «нейросети» и lists/proxy.txt
GOOGLE='(^|\.)(google|google\.com|googleapis\.com|gstatic\.com|googleusercontent\.com|googlevideo\.com|ggpht\.com|gvt[0-9]\.com|googletagmanager\.com|googlesyndication\.com|google-analytics\.com|doubleclick\.net|withgoogle\.com|youtube\.com|youtu\.be|ytimg\.com|youtube-nocookie\.com|youtubekids\.com)$'

own_list() { tr -d '\r' < "$1" | sed 's/[[:space:]]*#.*$//' | grep -v '^[[:space:]]*$'; }

# Re:filter — заблокированные в РФ домены
refilter() {
  fetch https://raw.githubusercontent.com/1andrevich/Re-filter-lists/main/domains_all.lst |
    grep -E "$DOMAIN" | grep -vE '^[0-9.]+$' | grep -vE "$GOOGLE" | sed 's/^/+./'
}

# OISD big — реклама и трекеры
oisd_big() {
  fetch https://raw.githubusercontent.com/sjhgvr/oisd/main/domainswild2_big.txt |
    grep -E "$DOMAIN" | sed 's/^/+./'
}

# ITDog — домены, недоступные из РФ
ru_inside() {
  fetch https://raw.githubusercontent.com/itdoginfo/allow-domains/main/Russia/inside-clashx.lst |
    sed -n 's/^DOMAIN-SUFFIX,\.\{0,1\}//p' | grep -vE "$GOOGLE" | sed 's/^/+./'
}

# Торрент-трекеры
torrent_trackers() {
  fetch https://raw.githubusercontent.com/sakib-m/Pi-hole-Torrent-Blocklist/main/all-torrent-trackers.txt |
    grep -E "$DOMAIN"
}

# Торрент-клиенты (имена процессов и пакетов)
torrent_clients() {
  fetch https://raw.githubusercontent.com/legiz-ru/sb-rule-sets/main/torrent-clients.json |
    jq -r '.rules[].rules[] | (.process_name // [])[], (.package_name // [])[]' | sed 's/^/PROCESS-NAME,/'
}

# Российские android-приложения
ru_apps() {
  fetch https://raw.githubusercontent.com/legiz-ru/sb-rule-sets/main/ru-app-list.json |
    jq -r '.rules[].rules[] | (.package_name // [])[]' | sed 's/^/PROCESS-NAME,/'
}

# Дополнительные подсети Telegram: официальный список, AS44893 и вручную добавленные подсети
telegram_extra_ips() {
  {
    fetch https://core.telegram.org/resources/cidr.txt &&
      fetch https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/asn/AS44893.list &&
      printf '%s\n' 139.59.210.98/32 5.28.192.0/18 91.108.0.0/16 109.239.140.0/24 2001:b28:f23c::/47 2a0a:f280::/29
  } | grep -E '^[0-9A-Fa-f:.]+/[0-9]+$'
}

for src in "$ROOT"/lists/*.txt; do
  name=$(basename "$src" .txt)
  case $name in *-ips) kind=ipcidr ;; *) kind=domain ;; esac
  publish "$kind" "lists/$name.mrs" 1 own_list "$src"
done

publish domain    rules/blocked-refilter.mrs   10000 refilter
publish domain    rules/ads.mrs                50000 oisd_big
publish domain    rules/blocked-itdog.mrs      300   ru_inside
publish domain    rules/torrent-trackers.mrs   100   torrent_trackers
publish classical rules/torrent-clients.yaml   10    torrent_clients
publish classical rules/ru-apps.yaml           100   ru_apps
publish ipcidr    rules/telegram-extra-ips.mrs 15    telegram_extra_ips

if [ ${#failed[@]} -gt 0 ]; then
  echo "не собрано: ${failed[*]}"
  exit 1
fi
