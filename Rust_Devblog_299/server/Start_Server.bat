@echo off
title Rust Dedicated Server - Devblog 299 (v2594)
echo ===================================================
echo   Rust Dedicated Server - Devblog 299 (v2594)
echo   Starting on port 28015...
echo ===================================================
RustDedicated.exe -batchmode -nographics +server.ip 0.0.0.0 +server.port 28015 +server.queryport 28017 +rcon.ip 0.0.0.0 +rcon.port 28016 +rcon.password "rustpilot" +server.hostname "Rust Devblog 299" +server.identity "devblog_299_server" +server.maxplayers 50 +server.worldsize 3000 +server.seed 1337 +server.eac 0
pause
