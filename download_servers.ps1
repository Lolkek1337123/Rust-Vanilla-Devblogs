param(
    [int]$DevblogId = 0
)

$BaseDir = $PSScriptRoot
$ManifestFile = Join-Path $BaseDir "devblogs_manifests.json"

if (-not (Test-Path $ManifestFile)) {
    Write-Host "[!] Файл манифестов devblogs_manifests.json не найден!" -ForegroundColor Red
    exit 1
}

# Поиск или автоматическая установка SteamCMD
$SteamCmdCandidates = @(
    (Join-Path $BaseDir "steamcmd.exe"),
    (Join-Path $BaseDir "tools\steamcmd\steamcmd.exe"),
    (Join-Path $BaseDir "steamcmd\steamcmd.exe"),
    "Z:\ai\resources\tools\steamcmd\steamcmd.exe",
    (Get-Command "steamcmd.exe" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1)
)

$SteamCmd = $null
foreach ($cand in $SteamCmdCandidates) {
    if ($cand -and (Test-Path $cand)) {
        $SteamCmd = $cand
        break
    }
}

if (-not $SteamCmd) {
    Write-Host "SteamCMD не найден в системе." -ForegroundColor Yellow
    $ans = Read-Host "Скачать и настроить официальный SteamCMD автоматически в папку 'tools\steamcmd'? (Y/N) [Y]"
    if ([string]::IsNullOrWhiteSpace($ans) -or $ans.ToUpper() -eq "Y") {
        $toolsDir = Join-Path $BaseDir "tools\steamcmd"
        if (-not (Test-Path $toolsDir)) { New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null }
        $zipPath = Join-Path $toolsDir "steamcmd.zip"
        Write-Host "Загрузка SteamCMD с серверов Valve..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" -OutFile $zipPath
        Expand-Archive -Path $zipPath -DestinationPath $toolsDir -Force
        Remove-Item -Path $zipPath -Force -ErrorAction SilentlyContinue
        $SteamCmd = Join-Path $toolsDir "steamcmd.exe"
        Write-Host "[OK] SteamCMD успешно установлен: $SteamCmd" -ForegroundColor Green
    } else {
        Write-Host "[!] Загрузка отменена. Пожалуйста, укажите путь к steamcmd.exe вручную." -ForegroundColor Red
        exit 1
    }
}

$devblogs = Get-Content $ManifestFile -Raw -Encoding UTF8 | ConvertFrom-Json

Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "   Rust Vanilla Devblogs: Автоматический загрузчик серверов" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan

$targets = @()
if ($DevblogId -gt 0) {
    $targets = $devblogs | Where-Object { $_.id -eq $DevblogId }
} else {
    Write-Host ""
    Write-Host "Доступно девблогов: $($devblogs.Count)" -ForegroundColor White
    Write-Host "Выберите вариант загрузки:" -ForegroundColor Yellow
    Write-Host " [0] Скачать ВСЕ $($devblogs.Count) серверов по очереди" -ForegroundColor White
    Write-Host " [Или введите номер девблога, например: 65, 133, 240, 280, 301]" -ForegroundColor White
    Write-Host ""
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
    Write-Host "[!] Девблог не найден в базе манифестов." -ForegroundColor Red
    pause
    exit 0
}

$steamcmdDir = Split-Path $SteamCmd -Parent
$contentBase = Join-Path $steamcmdDir "steamapps\content\app_258550"

function Copy-DepotContent($srcDir, $destDir) {
    if (-not (Test-Path $srcDir)) { return 0 }
    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Force -Path $destDir | Out-Null }
    
    $count = 0
    Get-ChildItem -Path $srcDir -Recurse | ForEach-Object {
        $rel = $_.FullName.Substring($srcDir.Length).TrimStart('\')
        $targetPath = Join-Path $destDir $rel
        if ($_.PSIsContainer) {
            if (-not (Test-Path $targetPath)) { New-Item -ItemType Directory -Force -Path $targetPath | Out-Null }
        } else {
            $parent = Split-Path $targetPath -Parent
            if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
            Copy-Item -Path $_.FullName -Destination $targetPath -Force
            $count++
        }
    }
    return $count
}

$total = $targets.Count
$current = 0

foreach ($db in $targets) {
    $current++
    $targetServerDir = Join-Path $BaseDir "Rust_Devblog_$($db.id)\server"
    if (-not (Test-Path $targetServerDir)) { New-Item -ItemType Directory -Force -Path $targetServerDir | Out-Null }

    Write-Host ""
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host " [$current/$total] Загрузка: $($db.title) ($($db.version)) - Релиз: $($db.releaseDate)" -ForegroundColor Green
    Write-Host " Папка назначения: $targetServerDir" -ForegroundColor Gray
    Write-Host "=====================================================================" -ForegroundColor Cyan

    foreach ($depot in $db.serverWindows) {
        $depotId = $depot.depotId
        $manifestId = $depot.manifestId
        $label = $depot.label

        Write-Host " -> Загрузка $label (Depot: $depotId, Manifest: $manifestId)..." -ForegroundColor Yellow

        $argsList = @(
            "+login", "anonymous",
            "+download_depot", "258550", "$depotId", "$manifestId",
            "+quit"
        )

        & $SteamCmd $argsList

        # Копирование из steamapps/content/app_258550/depot_<id> в целевую папку
        $depotDownloadDir = Join-Path $contentBase "depot_$depotId"
        if (Test-Path $depotDownloadDir) {
            Write-Host " -> Перенос файлов депо $depotId в $targetServerDir..." -ForegroundColor DarkCyan
            $copied = Copy-DepotContent $depotDownloadDir $targetServerDir
            Write-Host " -> Скопировано файлов: $copied" -ForegroundColor Gray
            Remove-Item -Path $depotDownloadDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    # Создание скрипта запуска Start_Server.bat
    $startBat = Join-Path $targetServerDir "Start_Server.bat"
    $batContent = @"
@echo off
title Rust Dedicated Server - Devblog $($db.id) ($($db.version))
echo ===================================================
echo   Rust Dedicated Server - Devblog $($db.id) ($($db.version))
echo   Starting on port 28015...
echo ===================================================
RustDedicated.exe -batchmode -nographics +server.ip 0.0.0.0 +server.port 28015 +server.queryport 28017 +rcon.ip 0.0.0.0 +rcon.port 28016 +rcon.password "rustpilot" +server.hostname "Rust Devblog $($db.id)" +server.identity "devblog_$($db.id)_server" +server.maxplayers 50 +server.worldsize 3000 +server.seed 1337 +server.eac 0
pause
"@
    Set-Content -Path $startBat -Value $batContent -Encoding UTF8 -Force

    Write-Host "[OK] Сервер $($db.title) готов к запуску!" -ForegroundColor Green
}

Write-Host ""
Write-Host "=====================================================================" -ForegroundColor Green
Write-Host " Все выбранные серверы успешно загружены и настроены!" -ForegroundColor Green
Write-Host "=====================================================================" -ForegroundColor Green
