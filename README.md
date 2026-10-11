<div align="center">

<p>
  <img src="https://cdn.jsdelivr.net/gh/kwlnd/mihomo-routing@assets/icons/flat/bypass.png" width="44" alt="">&nbsp;&nbsp;
  <img src="https://cdn.jsdelivr.net/gh/kwlnd/mihomo-routing@assets/icons/flat/youtube.png" width="44" alt="">&nbsp;&nbsp;
  <img src="https://cdn.jsdelivr.net/gh/kwlnd/mihomo-routing@assets/icons/flat/discord.png" width="44" alt="">&nbsp;&nbsp;
  <img src="https://cdn.jsdelivr.net/gh/kwlnd/mihomo-routing@assets/icons/flat/telegram-plane.png" width="44" alt="">&nbsp;&nbsp;
  <img src="https://cdn.jsdelivr.net/gh/kwlnd/mihomo-routing@assets/icons/flat/default.png" width="44" alt="">
</p>

# mihomo-routing

**Маршрутизация для [mihomo](https://github.com/MetaCubeX/mihomo) под Россию**<br>
заблокированное — через прокси, остальное — напрямую

[![build](https://github.com/kwlnd/mihomo-routing/actions/workflows/build.yml/badge.svg)](https://github.com/kwlnd/mihomo-routing/actions/workflows/build.yml)
![списки обновлены](https://img.shields.io/github/last-commit/kwlnd/mihomo-routing/release?label=%D1%81%D0%BF%D0%B8%D1%81%D0%BA%D0%B8%20%D0%BE%D0%B1%D0%BD%D0%BE%D0%B2%D0%BB%D0%B5%D0%BD%D1%8B&color=1FB89E)
![mihomo](https://img.shields.io/badge/mihomo-1.19.32-7C5CFF)

</div>

<br>

> [!NOTE]
> Сделано для себя и выложено как есть, без гарантий. Берите, правьте под себя.

## Как идёт трафик

```mermaid
flowchart LR
    T([Соединение]) --> R{Правила}
    R -->|реклама и трекеры| X[Блокировка]
    R -->|YouTube · Telegram · Discord| S[Своя группа<br>на каждый сервис]
    R -->|заблокированное в РФ<br>нейросети| P[Обход блокировок]
    R -->|российские сайты и приложения<br>торренты · локальная сеть| D[Без VPN]
    R -->|всё остальное| M[По умолчанию]
    S --> P
    M -.->|выбор пользователя| D
    M -.-> P
```

## Группы

| | Группа | Что туда попадает |
|:-:|---|---|
| <img src="https://cdn.jsdelivr.net/gh/kwlnd/mihomo-routing@assets/icons/flat/bypass.png" width="22" alt=""> | **Обход блокировок** | Re:filter, списки ITDog, нейросети, свои домены из `lists/proxy.txt` |
| <img src="https://cdn.jsdelivr.net/gh/kwlnd/mihomo-routing@assets/icons/flat/youtube.png" width="22" alt=""> | **YouTube** | домены и приложение YouTube |
| <img src="https://cdn.jsdelivr.net/gh/kwlnd/mihomo-routing@assets/icons/flat/discord.png" width="22" alt=""> | **Discord** | домены, голосовые серверы и приложение |
| <img src="https://cdn.jsdelivr.net/gh/kwlnd/mihomo-routing@assets/icons/flat/telegram-plane.png" width="22" alt=""> | **Telegram** | домены, подсети и клиенты Telegram |
| <img src="https://cdn.jsdelivr.net/gh/kwlnd/mihomo-routing@assets/icons/flat/default.png" width="22" alt=""> | **По умолчанию** | всё, что не попало в правила; из коробки идёт напрямую |

## Быстрый старт

1. Возьмите [`routing.yaml`](routing.yaml).
2. Это шаблон для **Remnawave**: серверы в группу «Автовыбор» подставляет панель. Без панели впишите свои прокси в `proxies` и в эту группу.
3. Замените пароль и загрузите конфиг в клиент.

> [!IMPORTANT]
> В конфиге стоит заглушка `user:CHANGE_ME` в `authentication`. Поменяйте её на свои логин и пароль: это доступ к прокси из локальной сети.

## Свои домены

Допишите строку в нужный файл и запушьте — список пересоберётся сам за минуту.

| Файл | Куда идёт |
|---|---|
| [`lists/proxy.txt`](lists/proxy.txt) | через прокси |
| [`lists/direct.txt`](lists/direct.txt) | напрямую |
| [`lists/telegram.txt`](lists/telegram.txt) | в группу Telegram |

```text
+.example.com    домен со всеми поддоменами
example.com      только точное совпадение
```

## Как это устроено

| Ветка | Содержимое |
|---|---|
| [`main`](https://github.com/kwlnd/mihomo-routing/tree/main) | конфиг, исходники своих списков, скрипты сборки |
| [`release`](https://github.com/kwlnd/mihomo-routing/tree/release) | собранные списки `.mrs`, перезаписывается раз в сутки |
| [`assets`](https://github.com/kwlnd/mihomo-routing/tree/assets) | иконки групп и фоны для FlClashX |

GitHub Actions раз в сутки скачивает списки из первоисточников, пакует их ядром mihomo и кладёт в `release`. Если источник недоступен или отдал мусор, остаётся прошлая версия файла, а сборка помечается упавшей.

<details>
<summary><b>Источники списков</b></summary>
<br>

| Список | Источник |
|---|---|
| Заблокированные домены | [Re:filter](https://github.com/1andrevich/Re-filter-lists), [itdoginfo/allow-domains](https://github.com/itdoginfo/allow-domains) |
| Реклама и трекеры | [OISD](https://oisd.nl) |
| Торрент-трекеры | [sakib-m/Pi-hole-Torrent-Blocklist](https://github.com/sakib-m/Pi-hole-Torrent-Blocklist) |
| Российские приложения, торрент-клиенты | [legiz-ru/sb-rule-sets](https://github.com/legiz-ru/sb-rule-sets) |
| Геосписки сервисов | [MetaCubeX/meta-rules-dat](https://github.com/MetaCubeX/meta-rules-dat) |
| Российские домены и адреса | [Davoyan/mihomo-rule-sets](https://github.com/Davoyan/mihomo-rule-sets) |

Последние два подключаются напрямую из их репозиториев, остальные пересобираются здесь.

</details>

<br>

<div align="center">
<sub>Конфиг вырос из шаблона сообщества Remnawave. Спасибо авторам списков.</sub>
</div>
