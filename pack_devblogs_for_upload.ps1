param(
    [int]$DevblogId = 0,
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

function Pack-FolderToZip($sourceFolder, $outputZip) {
    if (-not (Test-Path $sourceFolder)) {
        Write-Host "  [!] Directory not found: $sourceFolder" -ForegroundColor Yellow
        return $false
    }
    
    Write-Host "  -> Creating archive: $outputZip..." -ForegroundColor Cyan
    if (Test-Path $outputZip) { Remove-Item -Path $outputZip -Force }

    if ($tar) {
        & $tar -a -cf "$outputZip" -C "$sourceFolder" .
    } else {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::CreateFromDirectory($sourceFolder, $outputZip, [System.IO.Compression.CompressionLevel]::Optimal, $false)
    }

    if (Test-Path $outputZip) {
        $sizeMb = [math]::Round((Get-Item $outputZip).Length / 1MB, 2)
        Write-Host "  [OK] Archive ready ($sizeMb MB): $outputZip" -ForegroundColor Green
        return $true
    }
    return $false
}

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " Rust Vanilla Devblogs: Google Drive Packager" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "Output directory: $OutputDir" -ForegroundColor White
Write-Host ""

$targets = @()
if ($DevblogId -gt 0) {
    $targets = $devblogs | Where-Object { $_.id -eq $DevblogId }
} else {
    Write-Host "Select packaging option:" -ForegroundColor Yellow
    Write-Host " [0] Pack ALL devblogs" -ForegroundColor White
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
    $serverFolder = Join-Path $dbFolder "server"
    $clientFolder = Join-Path $dbFolder "client"

    Write-Host ""
    Write-Host "=================================================================" -ForegroundColor Cyan
    Write-Host " [$current/$total] Packing $($db.title) ($($db.version))..." -ForegroundColor Green
    Write-Host "=================================================================" -ForegroundColor Cyan

    # Pack Server
    $serverZip = Join-Path $OutputDir "Rust_Devblog_${id}_Server.zip"
    if (Test-Path (Join-Path $serverFolder "RustDedicated.exe")) {
        Pack-FolderToZip $serverFolder $serverZip
    } else {
        Write-Host "  [-] Server files for Devblog $id not found in $serverFolder (skipping)." -ForegroundColor DarkGray
    }

    # Pack Client
    $clientZip = Join-Path $OutputDir "Rust_Devblog_${id}_Client.zip"
    if ((Test-Path (Join-Path $clientFolder "RustClient.exe")) -or (Test-Path (Join-Path $clientFolder "Rust.exe"))) {
        Pack-FolderToZip $clientFolder $clientZip
    } else {
        Write-Host "  [-] Client files for Devblog $id not found in $clientFolder (skipping)." -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Green
Write-Host " All archives created in: $OutputDir" -ForegroundColor Green
Write-Host " Upload these zip files to Google Drive and update gdrive_links.json!" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Green
