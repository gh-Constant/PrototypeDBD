@echo off

REM Install packages if needed
if not exist "Packages" (
    call scripts\install-packages.bat
)

REM Set development environment
set ROBLOX_DEV=true

REM Start all three processes in separate windows
start "Rojo Server" cmd /k "rojo serve build.project.json"
start "Sourcemap Watcher" cmd /k "rojo sourcemap default.project.json -o sourcemap.json --watch"
start "Darklua Watcher" cmd /k "darklua process --config .darklua.json --watch src\\ dist\\"

echo Development environment started!
echo Three windows opened - close them to stop the processes.