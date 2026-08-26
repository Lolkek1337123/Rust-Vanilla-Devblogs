@echo off
chcp 65001 >nul
title Rust Vanilla Devblogs - Google Drive 1-Click Downloader
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0download_from_gdrive.ps1"
pause
