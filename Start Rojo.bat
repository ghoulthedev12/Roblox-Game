@echo off
rem Double-click this to start the Rojo server (keep the window open while you work in Studio).
cd /d "%~dp0"
title Rojo server - keep this window open
"%USERPROFILE%\.aftman\bin\rojo.exe" serve
pause
