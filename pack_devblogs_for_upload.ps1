param(
    [int]$DevblogId = 0,
    [switch]$All,
    [string]$OutputDir = ""
)

$BaseDir = $PSScriptRoot

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = Join-Path $BaseDir "_gdrive_uploads"
}

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
}

$manifestFile = Join-Path $BaseDir "devblogs_manifests.json"
$devblogs = Get-Content $manifestFile -Raw -Encoding UTF8 | ConvertFrom-Json

$tar = Get-Command "tar.exe" -ErrorAction SilentlyContinue

function Pack-DevblogFull($dbFolder, $outputZip) {
    if (-not (Test-Path $dbFolder)) {
        Write-Host "  [!] Directory not found: $dbFolder" -ForegroundColor Yellow
        return $false
    }
    
    # Check if archive already exists and is non-empty
    if (Test-Path $outputZip) {
        $existingSize = (Get-Item $outputZip).Length
        if ($existingSize -gt 104857600) { # > 100MB
            $sizeMb = [math]::Round($existingSize / 1MB, 2)
            Write-Host "  [SKIP] Archive already exists ($sizeMb MB): $outputZip" -ForegroundColor Yellow
            return $true
        }
        Remove-Item -Path $outputZip -Force
    }

    Write-Host "  -> Creating Full Archive (Server + Client): $outputZip..." -ForegroundColor Cyan

    if ($tar) {
        & $tar -a -cf "$outputZip" -C "$dbFolder" .
    } else {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::CreateFromDirectory($dbFolder, $outputZip, [System.IO.Compression.CompressionLevel]::Optimal, $false)
    }

    if (Test-Path $outputZip) {
        $sizeMb = [math]::Round((Get-Item $outputZip).Length / 1MB, 2)
        Write-Host "  [OK] Full Archive Ready ($sizeMb MB): $outputZip" -ForegroundColor Green
        return $true
    }
    return $false
}

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " Rust Vanilla Devblogs: Full Packager (Server + Client in 1 ZIP)" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "Output directory: $OutputDir" -ForegroundColor White
Write-Host ""

$targets = @()
if ($DevblogId -gt 0) {
    $targets = $devblogs | Where-Object { $_.id -eq $DevblogId }
} elseif ($All -or $DevblogId -eq -1) {
    $targets = $devblogs
} else {
    Write-Host "Select packaging option:" -ForegroundColor Yellow
    Write-Host " [0] Pack ALL devblogs (Client + Server in 1 ZIP)" -ForegroundColor White
    Write-Host " [Or enter devblog number, e.g. 65, 133, 280]" -ForegroundColor White
    $choice = Read-Host "Your choice [0]"
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
    Write-Host "[!] No devblogs selected for packaging." -ForegroundColor Red
    exit 0
}

$total = $targets.Count
$current = 0

foreach ($db in $targets) {
    $current++
    $id = $db.id
    $dbFolder = Join-Path $BaseDir "Rust_Devblog_$id"
    $outputZip = Join-Path $OutputDir "Rust_Devblog_${id}.zip"

    Write-Host ""
    Write-Host "=================================================================" -ForegroundColor Cyan
    Write-Host " [$current/$total] Packing $($db.title) ($($db.version)) [Full Build]..." -ForegroundColor Green
    Write-Host "=================================================================" -ForegroundColor Cyan

    Pack-DevblogFull $dbFolder $outputZip
}

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Green
Write-Host " All full devblog archives created in: $OutputDir" -ForegroundColor Green
Write-Host " Upload these zip files to Google Drive and update gdrive_links.json!" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Green
