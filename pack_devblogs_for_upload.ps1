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
        Write-Host "  [!] Папка не найдена: $sourceFolder" -ForegroundColor Yellow
        return $false
    }
    
    Write-Host "  -> Создание архива: $outputZip..." -ForegroundColor Cyan
    if (Test-Path $outputZip) { Remove-Item -Path $outputZip -Force }

    if ($tar) {
        # Using built-in tar for fast multithreaded zip creation
        $parent = Split-Path $sourceFolder -Parent
        $leaf = Split-Path $sourceFolder -Leaf
        & $tar -a -cf "$outputZip" -C "$sourceFolder" .
    } else {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::CreateFromDirectory($sourceFolder, $outputZip, [System.IO.Compression.CompressionLevel]::Optimal, $false)
    }

    if (Test-Path $outputZip) {
        $sizeMb = [math]::Round((Get-Item $outputZip).Length / 1MB, 2)
        Write-Host "  [OK] Архив готов ($sizeMb MB): $outputZip" -ForegroundColor Green
        return $true
    }
    return $false
}

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " Rust Vanilla Devblogs: Утилита упаковки для Google Drive" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "Папка для сохранения архивов: $OutputDir" -ForegroundColor White
Write-Host ""

$targets = @()
if ($DevblogId -gt 0) {
    $targets = $devblogs | Where-Object { $_.id -eq $DevblogId }
} else {
    Write-Host "Выберите вариант упаковки:" -ForegroundColor Yellow
    Write-Host " [0] Упаковать ВСЕ доступные девблоги" -ForegroundColor White
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
    Write-Host "[!] Нет выбранных девблогов для упаковки." -ForegroundColor Red
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
    Write-Host " [$current/$total] Упаковка $($db.title) ($($db.version))..." -ForegroundColor Green
    Write-Host "=================================================================" -ForegroundColor Cyan

    # Pack Server
    $serverZip = Join-Path $OutputDir "Rust_Devblog_${id}_Server.zip"
    if (Test-Path (Join-Path $serverFolder "RustDedicated.exe")) {
        Pack-FolderToZip $serverFolder $serverZip
    } else {
        Write-Host "  [-] Серверные файлы для Devblog $id не найдены в $serverFolder (пропуск)." -ForegroundColor DarkGray
    }

    # Pack Client
    $clientZip = Join-Path $OutputDir "Rust_Devblog_${id}_Client.zip"
    if ((Test-Path (Join-Path $clientFolder "RustClient.exe")) -or (Test-Path (Join-Path $clientFolder "Rust.exe"))) {
        Pack-FolderToZip $clientFolder $clientZip
    } else {
        Write-Host "  [-] Клиентские файлы для Devblog $id не найдены в $clientFolder (пропуск)." -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Green
Write-Host " Все готовые архивы сохранены в: $OutputDir" -ForegroundColor Green
Write-Host " Теперь загрузите эти zip-файлы на ваш Google Drive," -ForegroundColor White
Write-Host " сделайте ссылку 'Доступ по ссылке (Читатель)' и вставьте ID в gdrive_links.json!" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Green
