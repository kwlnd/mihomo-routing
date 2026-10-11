# mihomo-routing

Конфиг маршрутизации для [mihomo](https://github.com/MetaCubeX/mihomo) под использование в России: заблокированное идёт через прокси, российское и всё остальное — напрямую. Сделан для себя, без гарантий.

## Что где

| Ветка | Содержимое |
|---|---|
| `main` | `routing.yaml` — сам конфиг, `lists/*.txt` — свои списки доменов, `scripts/` — сборка |
| `release` | собранные списки в формате `.mrs`, перезаписывается раз в сутки |
| `assets` | иконки групп и фоны для FlClashX |

## Как пользоваться

`routing.yaml` — шаблон для Remnawave: серверы в группу «Автовыбор» подставляет панель. Без панели впишите свои прокси в `proxies` и в эту группу.

Перед использованием замените `user:CHANGE_ME` в `authentication` на свои логин и пароль.

## Как устроена сборка

GitHub Actions раз в сутки скачивает списки из первоисточников, пакует их ядром mihomo и кладёт в ветку `release`. Если источник недоступен, остаётся прошлая версия файла.

Чтобы добавить свой домен, допишите строку в `lists/proxy.txt` (через прокси) или `lists/direct.txt` (напрямую) и запушьте — список пересоберётся сам. `+.example.com` означает домен со всеми поддоменами.

## Источники списков

- [Re:filter](https://github.com/1andrevich/Re-filter-lists) и [itdoginfo/allow-domains](https://github.com/itdoginfo/allow-domains) — заблокированные домены
- [OISD](https://oisd.nl) — реклама и трекеры
- [sakib-m/Pi-hole-Torrent-Blocklist](https://github.com/sakib-m/Pi-hole-Torrent-Blocklist) — торрент-трекеры
- [legiz-ru/sb-rule-sets](https://github.com/legiz-ru/sb-rule-sets) — российские приложения и торрент-клиенты
- [MetaCubeX/meta-rules-dat](https://github.com/MetaCubeX/meta-rules-dat) и [Davoyan/mihomo-rule-sets](https://github.com/Davoyan/mihomo-rule-sets) — подключаются напрямую из их репозиториев

Конфиг вырос из шаблона сообщества Remnawave, спасибо авторам списков.
