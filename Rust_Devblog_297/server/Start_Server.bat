@echo off
title Rust Dedicated Server - Devblog 297 (v2592)
echo ===================================================
echo   Rust Dedicated Server - Devblog 297 (v2592)
echo   Starting on port 28015...
echo ===================================================
RustDedicated.exe -batchmode -nographics +server.ip 0.0.0.0 +server.port 28015 +server.queryport 28017 +rcon.ip 0.0.0.0 +rcon.port 28016 +rcon.password "rustpilot" +server.hostname "Rust Devblog 297" +server.identity "devblog_297_server" +server.maxplayers 50 +server.worldsize 3000 +server.seed 1337 +server.eac 0
pause
