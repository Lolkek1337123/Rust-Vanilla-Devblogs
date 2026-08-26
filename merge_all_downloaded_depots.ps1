
param(
    [string]$TargetBase = $PSScriptRoot
)

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " RustPilot Vanilla Devblogs Auto-Merger & Transfer Tool" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

$manifestFile = Join-Path $TargetBase "devblogs_manifests.json"
if (-not (Test-Path $manifestFile)) {
    Write-Host "[!] Файл манифестов devblogs_manifests.json не найден!" -ForegroundColor Red
    exit 1
}

$devblogs = Get-Content $manifestFile -Raw -Encoding UTF8 | ConvertFrom-Json

$steamCandidates = @(
    "C:\Program Files (x86)\Steam\steamapps\content\app_258550",
    "C:\Steam\steamapps\content\app_258550",
    "D:\SteamLibrary\steamapps\content\app_258550",
    "D:\Steam\steamapps\content\app_258550",
    "E:\SteamLibrary\steamapps\content\app_258550",
    "E:\Steam\steamapps\content\app_258550",
    "Y:\SteamLibrary\steamapps\content\app_258550",
    "D:\ai\apps\RustPilot\_tools\steamcmd\steamapps\content\app_258550"
)

function Merge-Folder($src, $dest) {
    if (-not (Test-Path $src)) { return 0 }
    if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Force -Path $dest | Out-Null }
    
    $count = 0
    Get-ChildItem -Path $src -Recurse | ForEach-Object {
        $rel = $_.FullName.Substring($src.Length).TrimStart('\')
        $targetPath = Join-Path $dest $rel
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

foreach ($db in $devblogs) {
    $dbFolder = Join-Path $TargetBase "Rust_Devblog_$($db.id)"
    $serverFolder = Join-Path $dbFolder "server"
    $clientFolder = Join-Path $dbFolder "client"

    Write-Host ""
    Write-Host ">>> Проверка [$($db.title)] ($($db.version))..." -ForegroundColor Yellow

    # Check for server depots in candidate folders
    foreach ($depot in $db.serverWindows) {
        $depotId = $depot.depotId
        $manifestId = $depot.manifestId

        foreach ($cand in $steamCandidates) {
            $depotFolder = Join-Path $cand "depot_$depotId"
            if (Test-Path $depotFolder) {
                Write-Host "  -> Найден депот $depotId ($($depot.label)) в $depotFolder" -ForegroundColor Green
                $copied = Merge-Folder $depotFolder $serverFolder
                Write-Host "     Скопировано $copied файлов в $serverFolder" -ForegroundColor Gray
            }
        }
    }

    # Check if RustDedicated.exe is present
    $serverExe = Join-Path $serverFolder "RustDedicated.exe"
    if (Test-Path $serverExe) {
        Write-Host "  [OK] Ванильный сервер $($db.title) готов!" -ForegroundColor Green
    } else {
        Write-Host "  [!] Сервер $($db.title) пока не собран (депоты еще не скачаны)." -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " Процесс проверки и переноса завершен!" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

