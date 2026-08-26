@echo off
chcp 65001 >nul
title Rust Dedicated Server Depots Downloader
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0download_servers.ps1"
pause