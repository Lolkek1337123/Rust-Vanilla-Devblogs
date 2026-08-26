
param(
    [string]$TargetBase = $PSScriptRoot
)

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " RustPilot Vanilla Client Depots Auto-Merger" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

$manifestFile = Join-Path $TargetBase "devblogs_manifests.json"
$devblogs = Get-Content $manifestFile -Raw -Encoding UTF8 | ConvertFrom-Json

$steamCandidates = @(
    "Y:\SteamLibrary\steamapps\content\app_252490",
    "C:\Program Files (x86)\Steam\steamapps\content\app_252490",
    "C:\Steam\steamapps\content\app_252490",
    "D:\SteamLibrary\steamapps\content\app_252490",
    "D:\Steam\steamapps\content\app_252490",
    "E:\SteamLibrary\steamapps\content\app_252490",
    "E:\Steam\steamapps\content\app_252490"
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
    $clientFolder = Join-Path $dbFolder "client"

    Write-Host ""
    Write-Host ">>> Проверка клиента [$($db.title)] ($($db.version))..." -ForegroundColor Yellow

    # Check for client depots in candidate folders
    foreach ($depot in $db.client) {
        $depotId = $depot.depotId

        foreach ($cand in $steamCandidates) {
            $depotFolder = Join-Path $cand "depot_$depotId"
            if (Test-Path $depotFolder) {
                Write-Host "  -> Найден клиентский депот $depotId ($($depot.label)) в $depotFolder" -ForegroundColor Green
                $copied = Merge-Folder $depotFolder $clientFolder
                Write-Host "     Скопировано $copied файлов в $clientFolder" -ForegroundColor Gray
            }
        }
    }

    # Check if RustClient.exe / Rust.exe is present
    $clientExe1 = Join-Path $clientFolder "RustClient.exe"
    $clientExe2 = Join-Path $clientFolder "Rust.exe"
    if ((Test-Path $clientExe1) -or (Test-Path $clientExe2)) {
        Write-Host "  [OK] Клиент $($db.title) собран и готов!" -ForegroundColor Green
    } else {
        Write-Host "  [!] Клиент $($db.title) пока не собран (депоты еще не скачаны)." -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " Процесс проверки и переноса клиентов завершен!" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

