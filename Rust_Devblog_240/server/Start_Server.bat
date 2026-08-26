@echo off
title Rust Dedicated Server - Devblog 240 (v2283)
echo ===================================================
echo   Rust Dedicated Server - Devblog 240 (v2283)
echo   Starting on port 28015...
echo ===================================================
RustDedicated.exe -batchmode -nographics +server.ip 0.0.0.0 +server.port 28015 +server.queryport 28017 +rcon.ip 0.0.0.0 +rcon.port 28016 +rcon.password "rustpilot" +server.hostname "Rust Devblog 240" +server.identity "devblog_240_server" +server.maxplayers 50 +server.worldsize 3000 +server.seed 1337 +server.eac 0
pause
