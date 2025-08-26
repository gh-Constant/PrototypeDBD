@echo off
setlocal enabledelayedexpansion

echo Installing Wally packages...
wally install
if !ERRORLEVEL! neq 0 (
    echo Failed to install Wally packages
    exit /b 1
)

echo Packages installed successfully!