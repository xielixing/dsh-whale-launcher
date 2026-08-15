@echo off
rem One-time setup: registers the dsh-launch URL protocol for the current user.
rem Run this from the repository folder (double-click is fine). No admin needed.
reg add "HKCU\Software\Classes\dsh-launch" /ve /d "URL:DeepSeek Harness Launcher" /f >nul
reg add "HKCU\Software\Classes\dsh-launch" /v "URL Protocol" /d "" /f >nul
reg add "HKCU\Software\Classes\dsh-launch\shell\open\command" /ve /d "powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"%~dp0scripts\dsh-launcher.ps1\" \"%%1\"" /f >nul
echo Protocol dsh-launch registered successfully.
echo You can close this window now.
timeout /t 3 >nul
