$srcRoot = "C:\Program Files (x86)\Steam\steamapps\content\app_258550"
$destRoot = $PSScriptRoot

$devblogs = @(65, 133, 177, 196, 199, 210, 217, 220, 224, 236, 240, 247, 248, 261, 264, 265, 266, 277, 280, 287, 290, 292, 295, 297, 299, 301)

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Starting Fast Multi-Threaded Robocopy Merge..." -ForegroundColor Cyan
Write-Host "=================================================="

$success = 0

foreach ($id in $devblogs) {
    $srcDir = Join-Path $srcRoot $id
    $targetDir = Join-Path $destRoot "Rust_Devblog_$id\server"

    if (-not (Test-Path $srcDir)) {
        Write-Host "[WARN] Devblog $id not found in Steam content: $srcDir" -ForegroundColor Yellow
        continue
    }

    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
    }

    Write-Host "`nProcessing Devblog $id..." -ForegroundColor Green

    # Copy depot_258551
    $d551 = Join-Path $srcDir "depot_258551"
    if (Test-Path $d551) {
        robocopy "$d551" "$targetDir" /E /MT:16 /NFL /NDL /NJH /NJS /nc /ns /np /r:1 /w:1 | Out-Null
    }

    # Copy depot_258554
    $d554 = Join-Path $srcDir "depot_258554"
    if (Test-Path $d554) {
        robocopy "$d554" "$targetDir" /E /MT:16 /NFL /NDL /NJH /NJS /nc /ns /np /r:1 /w:1 | Out-Null
    }

    # Create Start_Server.bat
    $batContent = @"
@echo off
title Rust Dedicated Server - Devblog $id
echo Starting Rust Devblog $id Server on port 28015...
RustDedicated.exe -batchmode -nographics +server.ip 0.0.0.0 +server.port 28015 +server.queryport 28017 +rcon.ip 0.0.0.0 +rcon.port 28016 +rcon.password "rustpilot" +server.hostname "RustPilot Devblog $id" +server.identity "devblog_${id}_server" +server.maxplayers 50 +server.worldsize 3000 +server.seed 1337 +server.eac 0
pause
"@
    Set-Content -Path (Join-Path $targetDir "Start_Server.bat") -Value $batContent -Encoding UTF8

    $exe = Test-Path (Join-Path $targetDir "RustDedicated.exe")
    $data = Test-Path (Join-Path $targetDir "RustDedicated_Data")
    $bundles = Test-Path (Join-Path $targetDir "Bundles")

    if ($exe -and $data -and $bundles) {
        $success++
        Write-Host "[OK] Devblog $id Server: 100% Ready!" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Devblog $id Server incomplete!" -ForegroundColor Red
    }
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "FAST MERGE FINISHED: $success / $($devblogs.Count) Servers Ready!" -ForegroundColor Cyan
Write-Host "=================================================="

