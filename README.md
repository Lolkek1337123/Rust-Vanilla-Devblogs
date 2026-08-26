<div align="center">

# 🌲 Rust Vanilla Devblogs Toolchain & Archive
### Automated Legacy Devblogs Manager, Manifest Database & Server Launcher (Devblog 65 — 301)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)
[![Facepunch: Compliant](https://img.shields.io/badge/Facepunch-Fair%20Use%20Compliant-brightgreen?style=for-the-badge&logo=shield)](LEGAL_NOTICE.md)
[![Devblogs: 26 Versions](https://img.shields.io/badge/Devblogs-65%20to%20301-orange?style=for-the-badge&logo=rust)](devblogs_manifests.json)
[![SteamCMD: Integrated](https://img.shields.io/badge/SteamCMD-Automated-blue?style=for-the-badge&logo=steam)](https://developer.valvesoftware.com/wiki/SteamCMD)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows%20x64-informational?style=for-the-badge&logo=windows)](https://microsoft.com)

<p align="center">
  <b>Универсальный инструмент для автоматической загрузки, развёртывания и локального запуска 26 легендарных версий игры Rust (Devblog 65 – Devblog 301) напрямую из официальных депотов Steam.</b>
</p>

[📌 О проекте](#-о-проекте) • [🛡️ Юридический дисклеймер](#️-юридический-дисклеймер--legal-disclaimer) • [🚀 Быстрый старт](#-быстрый-старт) • [📊 База девблогов](#-полная-база-девблогов-65--301) • [⚙️ Конфигурация](#️-параметры-запуска-и-rcon) • [❓ FAQ](#-часто-задаваемые-вопросы-faq)

---

</div>

> [!IMPORTANT]
> **100% Legal & Safe**: Репозиторий **НЕ содержит** бинарных файлов игры (`.exe`, `.dll`) или ассетов Unity. Все файлы загружаются пользователем напрямую с официальных серверов Valve (Steam Content Delivery Network) с помощью легитимных инструментов (`SteamCMD`, `DepotDownloader`).

---

## 📌 О проекте

**Rust Vanilla Devblogs Toolchain** — это комплексный инструментарий и база данных манифестов для архивации, тестирования и запуска классических версий игры **Rust**. 

Проект охватывает ключевые вехи развития игры за 10+ лет:
- 🏛️ **Ранние версии (Devblog 65, 133)** — классическая эпоха чертежей (Blueprints) и системы опыта (XP System).
- ⚙️ **Средняя эпоха (Devblog 177 – 240)** — верстаки (Workbenches), компоненты, процедурные монументы и старый баланс PVP.
- ⚡ **Новейшая эпоха (Devblog 247 – 301)** — современный HDRP-рендеринг, подводные лаборатории, поезда, вертолеты и актуальный сетевой стек.

### ✨ Ключевые возможности:
- ⚡ **1-Click Downloader (`download_servers.ps1`)**: Интерактивный загрузчик серверов через SteamCMD с автоматической установкой SteamCMD при отсутствии.
- 🎮 **Client Downloader (`download_all_clients_powershell.ps1`)**: Безопасный загрузчик клиентских депотов через DepotDownloader без хранения паролей.
- 📦 **Полная база манифестов (`devblogs_manifests.json`)**: 26 верифицированных пар депотов (AppID 258550 для серверов, AppID 252490 для клиентов).
- 🚀 **Готовые скрипты запуска**: Индивидуальные `Start_Server.bat` и `Start_Client.bat` для каждого девблога с оптимальными портами, RCON и параметрами EAC.
- 🔄 **Автоматическое слияние (`fast_merge_servers.ps1`)**: Многопоточная сборка скачанных депотов через Robocopy.
- 📋 **Консольные команды (`all_devblogs_steam_commands.txt`)**: Полный список команд для загрузки через Steam Console.

---

## 🛡️ Юридический дисклеймер / Legal Disclaimer

<details open>
<summary><b>🇷🇺 Русский (Нажмите для деталей)</b></summary>

1. **Некоммерческое использование и цифровое сохранение**: Данный репозиторий является независимым проектом с открытым исходным кодом, созданным исключительно в образовательных и исследовательских целях, а также для сохранения истории разработки видеоигры Rust.
2. **Отсутствие проприетарных файлов**: В репозитории отсутствуют исполняемые файлы (`.exe`), библиотеки (`.dll`), ресурсы Unity (`.assets`, `.bundle`), карты и прочие материалы, принадлежащие Facepunch Studios Ltd.
3. **Официальные каналы загрузки**: Все игровые данные загружаются пользователем самостоятельно с серверов компании Valve Corporation через официальные протоколы Steam.
4. **Торговые марки**: «Rust», Facepunch Studios и соответствующие логотипы являются зарегистрированными товарными знаками **Facepunch Studios Ltd.** Проект никак не связан и не поддерживается компаниями Facepunch Studios или Valve Corporation.
</details>

<details>
<summary><b>🇬🇧 English (Click to expand)</b></summary>

1. **Research & Archival Intent**: This repository is an independent open-source toolchain created strictly for historical preservation, interoperability, and educational research.
2. **Zero Binary Hosting**: This repository **DOES NOT** host, store, crack, or redistribute any copyrighted game executables (`.exe`), engine libraries (`.dll`), Unity asset bundles, or proprietary data owned by Facepunch Studios Ltd. or Valve Corporation.
3. **Direct Steam CDN Delivery**: All content is retrieved by the end-user directly from Valve Corporation's official Steam content delivery servers via official SteamCMD / DepotDownloader tools.
4. **Trademark Notice**: "Rust" and Facepunch Studios are trademarks or registered trademarks of **Facepunch Studios Ltd.** This project is not affiliated with, endorsed by, or sponsored by Facepunch Studios Ltd. or Valve Corporation.
</details>

> Подробное юридическое уведомление доступно в файле [LEGAL_NOTICE.md](LEGAL_NOTICE.md).

---

## 🚀 Быстрый старт

### 1. Клонирование репозитория
```bash
git clone https://github.com/Lolkek1337123/Rust-Vanilla-Devblogs.git
cd Rust-Vanilla-Devblogs
```

### 2. Загрузка сервера любого девблога (Анонимно, без паролей)
Серверные депоты (AppID `258550`) доступны в Steam публично и скачиваются анонимно:

```powershell
# Запуск интерактивного загрузчика серверов
powershell -ExecutionPolicy Bypass -File .\download_servers.ps1
```
*Скрипт предложит выбрать номер девблога (например, `133` или `280`) или скачать все 26 серверов сразу.*

### 3. Загрузка клиента (Требуется лицензия Rust в Steam)
Для скачивания файлов клиента (AppID `252490`) необходим ваш личный Steam аккаунт с купленной игрой Rust:

```powershell
# Интерактивный запуск загрузчика клиентов
powershell -ExecutionPolicy Bypass -File .\download_all_clients_powershell.ps1 -DevblogId 133
```
*Данные авторизации запрашиваются безопасно в runtime или берутся из переменных среды `$env:STEAM_USERNAME` / `$env:STEAM_PASSWORD`.*

### 4. Запуск сервера и клиента
После завершения загрузки перейдите в папку нужного девблога:
1. Запустите сервер: `Rust_Devblog_133\server\Start_Server.bat`
2. Запустите клиент: `Rust_Devblog_133\client\Start_Client.bat`
3. В клиенте откройте консоль (`F1`) и введите: `client.connect 127.0.0.1:28015`

---

## 📊 Полная база девблогов (65 — 301)

В репозитории собраны манифесты для 26 ключевых релизов Rust:

| Девблог | Версия | Дата релиза | Эпоха / Ключевые особенности | Server Depots (App 258550) | Client Depots (App 252490) |
|:---:|:---:|:---:|---|:---:|:---:|
| **Devblog 65** | `v1288` | 25.06.2015 | Ранний Rust (Old Blueprints, Классический лук) | 258551 / 258554 | 252494 / 252495 |
| **Devblog 133** | `v1337` | 27.10.2016 | 🌟 **XP System & Weapon Balancing** | 258551 / 258554 | 252494 / 252495 |
| **Devblog 177** | `v1478` | 14.09.2017 | Верстаки 1-3 уровня (Workbenches era) | 258551 / 258554 | 252494 / 252495 |
| **Devblog 196** | `v1550` | 01.02.2018 | Выход из Early Access, новые деревья | 258551 / 258554 | 252494 / 252495 |
| **Devblog 199** | `v1563` | 22.02.2018 | Баланс радиации, Chinook CH-47 | 258551 / 258554 | 252494 / 252495 |
| **Devblog 210** | `v1617` | 05.07.2018 | Compound Monument, лодки, дайвинг | 258551 / 258554 | 252494 / 252495 |
| **Devblog 217** | `v1655` | 04.10.2018 | Cargo Ship (Корабль), новые головоломки | 258551 / 258554 | 252494 / 252495 |
| **Devblog 220** | `v1672` | 06.12.2018 | Электричество (Electricity update) | 258551 / 258554 | 252494 / 252495 |
| **Devblog 224** | `v1694` | 07.02.2019 | Миникоптер (Minicopter), нефтяные вышки | 258551 / 258554 | 252494 / 252495 |
| **Devblog 236** | `v1775` | 06.02.2020 | Кольцевые дороги, транспортная система | 258551 / 258554 | 252494 / 252495 |
| **Devblog 240** | `v1801` | 04.06.2020 | Строительство модульных автомобилей | 258551 / 258554 | 252494 / 252495 |
| **Devblog 247** | `v1850` | 07.01.2021 | Технологические деревья (Tech Trees) | 258551 / 258554 | 252494 / 252495 |
| **Devblog 248** | `v1858` | 04.02.2021 | Переработка звуков и дронов доставки | 258551 / 258554 | 252494 / 252495 |
| **Devblog 261** | `v2285` | 03.03.2022 | Арктическая база, снегоходы | 258551 / 258554 | 252494 / 252495 |
| **Devblog 264** | `v2302` | 02.06.2022 | Полная переработка отдачи и стрельбы (Recoil Overhaul) | 258551 / 258554 | 252494 / 252495 |
| **Devblog 265** | `v2310` | 07.07.2022 | Боевой вертолёт, новые локомотивы | 258551 / 258554 | 252494 / 252495 |
| **Devblog 266** | `v2318` | 04.08.2022 | Железнодорожная сеть по всей карте | 258551 / 258554 | 252494 / 252495 |
| **Devblog 277** | `v2392` | 01.06.2023 | Строительство: Стены из кирпича и контейнеров | 258551 / 258554 | 252494 / 252495 |
| **Devblog 280** | `v2398` | 06.07.2023 | Паромный терминал и Tugboat (Буксир) | 258551 / 258554 | 252494 / 252495 |
| **Devblog 287** | `v2567` | 07.11.2024 | Новый рендеринг океана и динамическая погода | 258551 / 258554 | 252494 / 252495 |
| **Devblog 290** | `v2570` | 05.12.2024 | Рюкзаки, обновленная радиационная система | 258551 / 258554 | 252494 / 252495 |
| **Devblog 292** | `v2574` | 23.01.2025 | Улучшения оптимизации и многопоточности | 258551 / 258554 | 252494 / 252495 |
| **Devblog 295** | `v2580` | 06.02.2025 | Улучшенная физика транспорта | 258551 / 258554 | 252494 / 252495 |
| **Devblog 297** | `v2592` | 03.07.2025 | Обновление монументов и баланса | 258551 / 258554 | 252494 / 252495 |
| **Devblog 299** | `v2594` | 07.08.2025 | Сетевые оптимизации | 258551 / 258554 | 252494 / 252495 |
| **Devblog 301** | `v2602` | 02.10.2025 | Актуальный стабильный архивный релиз | 258551 / 258554 | 252494 / 252495 |

---

## 📁 Структура репозитория

```
Vanilla_Devblogs/
├── devblogs_manifests.json                  # База данных всех манифестов (JSON)
├── download_servers.ps1                     # PowerShell-загрузчик серверов через SteamCMD
├── download_all_clients_powershell.ps1      # PowerShell-загрузчик клиентов игры
├── download_all_servers_steamcmd.bat        # Запуск загрузки серверов в 1 клик
├── download_all_servers_depotdownloader.bat # Загрузчик серверов через DepotDownloader
├── download_all_clients_depotdownloader.bat # Загрузчик клиентов через DepotDownloader
├── fast_merge_servers.ps1                   # Скрипт быстрого слияния депотов
├── merge_all_clients.ps1                    # Скрипт организации клиентских файлов
├── all_devblogs_steam_commands.txt          # Шпаргалка команд для консоли Steam
├── steam_console_server_depots.txt          # Список депотов серверов
├── steam_console_client_depots.txt          # Список депотов клиентов
├── LEGAL_NOTICE.md                          # Юридическое уведомление и политика Facepunch
├── LICENSE                                  # MIT лицензия проекта
├── README.md                                # Документация проекта
└── Rust_Devblog_*/                          # Папки для каждого девблога
    ├── server/
    │   └── Start_Server.bat                 # Шаблон запуска сервера с аргументами
    └── client/
        └── Start_Client.bat                 # Шаблон запуска клиента и автоподключения
```

---

## ⚙️ Параметры запуска и RCON

Каждый файл `Start_Server.bat` содержит стандартизированные параметры:

```bat
RustDedicated.exe -batchmode -nographics ^
  +server.ip 0.0.0.0 ^
  +server.port 28015 ^
  +server.queryport 28017 ^
  +rcon.ip 0.0.0.0 ^
  +rcon.port 28016 ^
  +rcon.password "rustpilot" ^
  +server.hostname "Rust Devblog 133" ^
  +server.identity "devblog_133_server" ^
  +server.maxplayers 50 ^
  +server.worldsize 3000 ^
  +server.seed 1337 ^
  +server.eac 0
```

### Основные аргументы:
- `+server.port 28015` — основной игровой UDP-порт.
- `+rcon.port 28016` / `+rcon.password` — порт и пароль для RCON-управления.
- `+server.eac 0` — отключение EasyAntiCheat на локальном сервере для совместимости со старыми клиентами.
- `+server.worldsize` и `+server.seed` — размер процедурной карты (рекомендуется от 2000 до 4000) и зерно генерации.

---

## ❓ Часто задаваемые вопросы (FAQ)

<details>
<summary><b>1. Почему серверы скачиваются без логина, а клиенты требуют аккаунт?</b></summary>
Valve разрешает анонимную загрузку серверных депотов Rust (AppID <code>258550</code>). Клиентские депоты (AppID <code>252490</code>) защищены Steam DRM и требуют лицензию Rust на аккаунте.
</details>

<details>
<summary><b>2. Что делать, если DepotDownloader запрашивает код 2FA (Steam Guard)?</b></summary>
Введите 5-значный код из вашего приложения Steam Mobile или email в консоль один раз. DepotDownloader автоматически сохранит токен сессии (<code>.depotDownloader/</code>), и повторный ввод не потребуется.
</details>

<details>
<summary><b>3. Как играть с друзьями по локальной сети или через Интернет?</b></summary>
Для игры по сети пробросьте UDP-порты <code>28015</code> и <code>28017</code> на вашем роутере или используйте локальные виртуальные сети (Radmin VPN, ZeroTier). Друзья подключаются через консоль <code>F1</code>: <code>client.connect YOUR_IP:28015</code>.
</details>

<details>
<summary><b>4. Можно ли устанавливать плагины (Oxide / Carbon)?</b></summary>
Да! Старые сборки Oxide/uMod для конкретных версий Rust (например, Oxide для Devblog 133 или 210) распаковываются в папку <code>Rust_Devblog_*/server/</code> поверх оригинальных файлов.
</details>

---

## 📄 Лицензия & Авторские права

- Исходный код скриптов и манифестов распространяется под лицензией **[MIT License](LICENSE)**.
- **Rust** и **Facepunch Studios** являются товарными знаками компании **Facepunch Studios Ltd.**
- Проект создан сообществом разработчиков **[TEAM RUST PLUGINS](https://github.com/Lolkek1337123)**.

---

<div align="center">
  <sub>Made with ❤️ by TEAM RUST PLUGINS • Preserving Rust Gaming History</sub>
</div>
