@echo off
setlocal enabledelayedexpansion

REM Exit on any error
set "ERRORLEVEL=0"

REM If Packages aren't installed, install them.
if not exist "Packages" (
    echo Installing packages...
    call scripts\install-packages.bat
    if !ERRORLEVEL! neq 0 (
        echo Failed to install packages
        exit /b 1
    )
)

REM Generate sourcemap
echo Generating sourcemap...
rojo sourcemap default.project.json -o sourcemap.json
if !ERRORLEVEL! neq 0 (
    echo Failed to generate sourcemap
    exit /b 1
)

REM Process source files with Darklua
echo Processing source files...
set ROBLOX_DEV=false
darklua process --config .darklua.json src\ dist\
if !ERRORLEVEL! neq 0 (
    echo Failed to process source files with Darklua
    exit /b 1
)

REM Build the final project
echo Building project...
rojo build build.project.json -o RobloxProjectTemplate.rbxl
if !ERRORLEVEL! neq 0 (
    echo Failed to build project
    exit /b 1
)

echo Build completed successfully!