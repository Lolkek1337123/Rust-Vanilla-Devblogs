param(
    [int]$DevblogId = 0,
    [ValidateSet("server", "client", "both")]
    [string]$Type = "both"
)

$BaseDir = $PSScriptRoot
$ConfigFile = Join-Path $BaseDir "gdrive_links.json"

if (-not (Test-Path $ConfigFile)) {
    Write-Host "[!] Конфигурационный файл gdrive_links.json не найден!" -ForegroundColor Red
    exit 1
}

$gdriveData = Get-Content $ConfigFile -Raw -Encoding UTF8 | ConvertFrom-Json

function Extract-FileId([string]$inputStr) {
    if ([string]::IsNullOrWhiteSpace($inputStr)) { return $null }
    if ($inputStr -match "/file/d/([a-zA-Z0-9_-]+)") {
        return $matches[1]
    } elseif ($inputStr -match "id=([a-zA-Z0-9_-]+)") {
        return $matches[1]
    } elseif ($inputStr -match "^[a-zA-Z0-9_-]{20,}$") {
        return $inputStr.Trim()
    }
    return $null
}

function Download-FromGDrive($fileId, $destinationZip) {
    Write-Host "  -> Подключение к серверам Google Drive..." -ForegroundColor Yellow
    
    $cookieContainer = New-Object System.Net.CookieContainer
    $handler = New-Object System.Net.Http.HttpClientHandler
    $handler.CookieContainer = $cookieContainer
    $handler.AllowAutoRedirect = $true
    
    $client = New-Object System.Net.Http.HttpClient($handler)
    $client.Timeout = [System.TimeSpan]::FromHours(2)
    $client.DefaultRequestHeaders.UserAgent.ParseAdd("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")

    $url = "https://drive.google.com/uc?export=download&id=$fileId"
    $response = $client.GetAsync($url).GetAwaiter().GetResult()
    
    # Check if Google Drive asks for confirmation token (files > 100MB)
    $confirmToken = $null
    $contentStr = $response.Content.ReadAsStringAsync().GetAwaiter().GetResult()

    if ($contentStr -match "confirm=([0-9a-zA-Z_]+)") {
        $confirmToken = $matches[1]
    } elseif ($contentStr -match "name=`"confirm`"\s+value=`"([^`"]+)`"") {
        $confirmToken = $matches[1]
    }

    if ($confirmToken) {
        $confirmUrl = "https://drive.google.com/uc?export=download&confirm=$confirmToken&id=$fileId"
        $response = $client.GetAsync($confirmUrl, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).GetAwaiter().GetResult()
    }

    if (-not $response.IsSuccessStatusCode) {
        Write-Host "  [!] Ошибка ответа Google Drive: $($response.StatusCode)" -ForegroundColor Red
        return $false
    }

    $totalBytes = $response.Content.Headers.ContentLength
    $stream = $response.Content.ReadAsStreamAsync().GetAwaiter().GetResult()
    $fileStream = [System.IO.File]::Create($destinationZip)

    $buffer = New-Object byte[] 65536
    $downloaded = 0
    $lastReport = [System.DateTime]::Now

    Write-Host "  -> Загрузка архива..." -ForegroundColor Cyan

    while (($read = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
        $fileStream.Write($buffer, 0, $read)
        $downloaded += $read

        if (([System.DateTime]::Now - $lastReport).TotalMilliseconds -gt 500) {
            $lastReport = [System.DateTime]::Now
            $mb = [math]::Round($downloaded / 1MB, 2)
            if ($totalBytes -and $totalBytes -gt 0) {
                $totalMb = [math]::Round($totalBytes / 1MB, 2)
                $percent = [math]::Round(($downloaded / $totalBytes) * 100, 1)
                Write-Progress -Activity "Загрузка с Google Drive" -Status "$mb MB / $totalMb MB ($percent%)" -PercentComplete $percent
            } else {
                Write-Progress -Activity "Загрузка с Google Drive" -Status "$mb MB загружено..."
            }
        }
    }

    Write-Progress -Activity "Загрузка с Google Drive" -Completed
    $fileStream.Flush()
    $fileStream.Close()
    $stream.Close()
    $client.Dispose()

    return (Test-Path $destinationZip) -and ((Get-Item $destinationZip).Length -gt 1024)
}

function Extract-Archive($zipFile, $destDir) {
    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Force -Path $destDir | Out-Null }
    Write-Host "  -> Распаковка архива в: $destDir..." -ForegroundColor Cyan

    $tar = Get-Command "tar.exe" -ErrorAction SilentlyContinue
    if ($tar) {
        & $tar -xf "$zipFile" -C "$destDir"
    } else {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $destDir)
    }
}

Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "   Rust Vanilla Devblogs: Загрузчик с Google Drive (1-Click Ready)" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan

$availableIds = $gdriveData.devblogs.PSObject.Properties | Select-Object -ExpandProperty Name

if ($DevblogId -le 0) {
    Write-Host ""
    Write-Host "Доступные девблоги: $($availableIds -join ', ')" -ForegroundColor White
    Write-Host "Выберите номер девблога для скачивания (например: 65, 133, 240, 280):" -ForegroundColor Yellow
    $choice = Read-Host "Номер девблога"
    if (-not [string]::IsNullOrWhiteSpace($choice)) {
        $DevblogId = [int]$choice
    }
}

$idStr = "$DevblogId"
$dbInfo = $gdriveData.devblogs.$idStr

if (-not $dbInfo) {
    Write-Host "[!] Девблог $DevblogId не найден в базе ссылок." -ForegroundColor Red
    if (-not [string]::IsNullOrWhiteSpace($gdriveData.gdriveFolderUrl)) {
        Write-Host "Вы можете открыть общую папку на Google Drive вручную:" -ForegroundColor Yellow
        Write-Host "$($gdriveData.gdriveFolderUrl)" -ForegroundColor Cyan
    }
    pause
    exit 1
}

Write-Host ""
Write-Host "Выбран девблог: $($dbInfo.title)" -ForegroundColor Green

$targetDbDir = Join-Path $BaseDir "Rust_Devblog_$DevblogId"
$serverDir = Join-Path $targetDbDir "server"
$clientDir = Join-Path $targetDbDir "client"

# 1. Загрузка сервера
if ($Type -eq "server" -or $Type -eq "both") {
    $srvId = Extract-FileId $dbInfo.serverFileId
    if ($srvId) {
        Write-Host "`n[1/2] Загрузка готового сервера $($dbInfo.title)..." -ForegroundColor Green
        $tmpZip = Join-Path $BaseDir "temp_server_$DevblogId.zip"
        $ok = Download-FromGDrive $srvId $tmpZip
        if ($ok) {
            Extract-Archive $tmpZip $serverDir
            Remove-Item -Path $tmpZip -Force -ErrorAction SilentlyContinue
            Write-Host "  [OK] Сервер $($dbInfo.title) успешно установлен и готов!" -ForegroundColor Green
        } else {
            Write-Host "  [!] Не удалось загрузить архив сервера." -ForegroundColor Red
        }
    } else {
        Write-Host "[INFO] Прямой Google Drive File ID для сервера Devblog $DevblogId пока не заполнен в gdrive_links.json." -ForegroundColor DarkGray
        Write-Host "Используйте .\download_servers.ps1 для быстрой загрузки через официальный SteamCMD." -ForegroundColor Yellow
    }
}

# 2. Загрузка клиента
if ($Type -eq "client" -or $Type -eq "both") {
    $cltId = Extract-FileId $dbInfo.clientFileId
    if ($cltId) {
        Write-Host "`n[2/2] Загрузка готового клиента $($dbInfo.title)..." -ForegroundColor Green
        $tmpZip = Join-Path $BaseDir "temp_client_$DevblogId.zip"
        $ok = Download-FromGDrive $cltId $tmpZip
        if ($ok) {
            Extract-Archive $tmpZip $clientDir
            Remove-Item -Path $tmpZip -Force -ErrorAction SilentlyContinue
            Write-Host "  [OK] Клиент $($dbInfo.title) успешно установлен и готов!" -ForegroundColor Green
        } else {
            Write-Host "  [!] Не удалось загрузить архив клиента." -ForegroundColor Red
        }
    } else {
        Write-Host "[INFO] Прямой Google Drive File ID для клиента Devblog $DevblogId пока не заполнен в gdrive_links.json." -ForegroundColor DarkGray
        Write-Host "Используйте .\download_all_clients_powershell.ps1 для загрузки через DepotDownloader." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=====================================================================" -ForegroundColor Green
Write-Host " Процесс завершен!" -ForegroundColor Green
Write-Host " Запуск сервера: Rust_Devblog_$DevblogId\server\Start_Server.bat" -ForegroundColor White
Write-Host " Запуск клиента: Rust_Devblog_$DevblogId\client\Start_Client.bat" -ForegroundColor White
Write-Host "=====================================================================" -ForegroundColor Green
