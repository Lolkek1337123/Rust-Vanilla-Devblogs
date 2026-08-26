@echo off
title Rust Dedicated Server - Devblog 287 (v2567)
echo ===================================================
echo   Rust Dedicated Server - Devblog 287 (v2567)
echo   Starting on port 28015...
echo ===================================================
RustDedicated.exe -batchmode -nographics +server.ip 0.0.0.0 +server.port 28015 +server.queryport 28017 +rcon.ip 0.0.0.0 +rcon.port 28016 +rcon.password "rustpilot" +server.hostname "Rust Devblog 287" +server.identity "devblog_287_server" +server.maxplayers 50 +server.worldsize 3000 +server.seed 1337 +server.eac 0
pause
