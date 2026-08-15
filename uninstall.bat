@echo off
rem Removes the dsh-launch URL protocol registration. You can delete this
rem folder afterwards.
reg delete "HKCU\Software\Classes\dsh-launch" /f >nul 2>&1
echo Protocol dsh-launch unregistered.
echo You can delete this folder now.
timeout /t 3 >nul
