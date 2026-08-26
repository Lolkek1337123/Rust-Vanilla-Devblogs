param(
    [string]$Username = "",
    [string]$Password = "",
    [int]$DevblogId = 0,
    [switch]$All
)

$BaseDir = $PSScriptRoot
$ManifestFile = Join-Path $BaseDir "devblogs_manifests.json"

if (-not (Test-Path $ManifestFile)) {
    Write-Host "[!] Файл манифестов devblogs_manifests.json не найден!" -ForegroundColor Red
    exit 1
}

# Поиск или предложение загрузки DepotDownloader
$DdCandidates = @(
    (Join-Path $BaseDir "DepotDownloader.exe"),
    (Join-Path $BaseDir "tools\DepotDownloader\DepotDownloader.exe"),
    "Z:\ai\resources\tools\DepotDownloader\DepotDownloader.exe",
    (Get-Command "DepotDownloader.exe" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1)
)

$DepotDownloader = $null
foreach ($cand in $DdCandidates) {
    if ($cand -and (Test-Path $cand)) {
        $DepotDownloader = $cand
        break
    }
}

if (-not $DepotDownloader) {
    Write-Host "[!] DepotDownloader не найден в системе." -ForegroundColor Yellow
    Write-Host "Для загрузки клиентов Rust необходим DepotDownloader (или .NET инструмент)." -ForegroundColor Gray
    Write-Host "Скачайте DepotDownloader с официального GitHub: https://github.com/SteamRE/DepotDownloader/releases" -ForegroundColor Cyan
    Write-Host "и поместите DepotDownloader.exe в папку 'tools\DepotDownloader\' или рядом со скриптом." -ForegroundColor Gray
    Write-Host ""
    $manualPath = Read-Host "Укажите путь к DepotDownloader.exe вручную (или нажмите Enter для выхода)"
    if (-not [string]::IsNullOrWhiteSpace($manualPath) -and (Test-Path $manualPath)) {
        $DepotDownloader = $manualPath
    } else {
        exit 1
    }
}

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "   Rust Vanilla Devblogs: Загрузчик клиентов игры (DepotDownloader)" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Внимание: Для загрузки клиентских файлов Rust (AppID: 252490)" -ForegroundColor Yellow
Write-Host "требуется аккаунт Steam с купленной копией игры Rust." -ForegroundColor Yellow
Write-Host ""

if ([string]::IsNullOrWhiteSpace($Username)) {
    if ($env:STEAM_USERNAME) {
        $Username = $env:STEAM_USERNAME
    } else {
        $Username = Read-Host "Введите ваш логин Steam"
    }
}

if ([string]::IsNullOrWhiteSpace($Password)) {
    if ($env:STEAM_PASSWORD) {
        $Password = $env:STEAM_PASSWORD
    } else {
        $Password = Read-Host "Введите ваш пароль Steam" -AsSecureString
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
        $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    }
}

if ([string]::IsNullOrWhiteSpace($Username) -or [string]::IsNullOrWhiteSpace($Password)) {
    Write-Host "[!] Логин и пароль Steam обязательны для загрузки клиентов!" -ForegroundColor Red
    exit 1
}

$devblogs = Get-Content $ManifestFile -Raw -Encoding UTF8 | ConvertFrom-Json

$targets = @()
if ($DevblogId -gt 0) {
    $targets = $devblogs | Where-Object { $_.id -eq $DevblogId }
} elseif ($All) {
    $targets = $devblogs
} else {
    Write-Host ""
    Write-Host "Доступно девблогов: $($devblogs.Count)" -ForegroundColor White
    Write-Host " [0] Скачать ВСЕ $($devblogs.Count) клиентов" -ForegroundColor White
    Write-Host " [Или введите номер девблога, например: 65, 133, 280]" -ForegroundColor White
    $choice = Read-Host "Ваш выбор [0]"
    if ([string]::IsNullOrWhiteSpace($choice) -or $choice -eq "0") {
        $targets = $devblogs
    } else {
        $parsedId = 0
        if ([int]::TryParse($choice, [ref]$parsedId)) {
            $targets = $devblogs | Where-Object { $_.id -eq $parsedId }
        }
    }
}

if ($targets.Count -eq 0) {
    Write-Host "[!] Не найдено девблогов для загрузки." -ForegroundColor Yellow
    exit 0
}

$total = $targets.Count
$current = 0

foreach ($db in $targets) {
    $current++
    $clientDir = Join-Path $BaseDir "Rust_Devblog_$($db.id)\client"
    if (-not (Test-Path $clientDir)) { New-Item -ItemType Directory -Force -Path $clientDir | Out-Null }

    Write-Host ""
    Write-Host "=================================================================" -ForegroundColor Cyan
    Write-Host " [$current/$total] Загрузка клиента: $($db.title) ($($db.version)) - Дата: $($db.releaseDate)" -ForegroundColor Green
    Write-Host " Папка: $clientDir" -ForegroundColor Gray
    Write-Host "=================================================================" -ForegroundColor Cyan

    foreach ($depot in $db.client) {
        Write-Host "  -> Depot $($depot.depotId) ($($depot.label)) [Manifest: $($depot.manifestId)]..." -ForegroundColor Yellow

        $dArgs = @(
            "-app", "252490",
            "-depot", "$($depot.depotId)",
            "-manifest", "$($depot.manifestId)",
            "-dir", "$clientDir",
            "-username", "$Username",
            "-password", "$Password",
            "-remember-password",
            "-max-downloads", "8"
        )

        & $DepotDownloader $dArgs
    }

    # Создание Start_Client.bat
    $startBat = Join-Path $clientDir "Start_Client.bat"
    $batContent = @"
@echo off
title Rust Devblog $($db.id) ($($db.version)) Client Launcher
echo ===================================================
echo   Rust Devblog $($db.id) ($($db.version)) Client
echo   Connecting to local server 127.0.0.1:28015...
echo ===================================================
start "" "RustClient.exe" -force-d3d11 +connect 127.0.0.1:28015
"@
    Set-Content -Path $startBat -Value $batContent -Encoding UTF8 -Force
    Write-Host "[OK] Клиент $($db.title) готов!" -ForegroundColor Green
}

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Green
Write-Host " Загрузка клиентов завершена!" -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Green
