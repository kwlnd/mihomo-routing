#!/usr/bin/env python3
# Обновляет tun.exclude-package в конфиге по собранному списку российских приложений.
# Использование: sync-packages.py ru-big.yaml out/rules/ru-apps.yaml
import sys
import textwrap

config_path, apps_path = sys.argv[1], sys.argv[2]

with open(apps_path, encoding="utf-8") as f:
    packages = [line.split(",", 1)[1].strip() for line in f if "PROCESS-NAME," in line]
if len(packages) < 100:
    sys.exit(f"в списке приложений всего {len(packages)} строк, конфиг не трогаю")

with open(config_path, encoding="utf-8") as f:
    text = f.read()

start = text.index("  exclude-package:\n")
end = text.index("    ]\n", start) + len("    ]\n")
body = textwrap.fill(
    ", ".join(packages),
    width=116,
    initial_indent=" " * 6,
    subsequent_indent=" " * 6,
    break_long_words=False,
    break_on_hyphens=False,
)
block = "  exclude-package:\n    [\n" + body + ",\n    ]\n"

if text[start:end] != block:
    with open(config_path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text[:start] + block + text[end:])
    print(f"exclude-package обновлён: {len(packages)} пакетов")
