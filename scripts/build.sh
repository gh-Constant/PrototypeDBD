#!/bin/sh

set -e

# If Packages aren't installed, install them.
if [ ! -d "Packages" ]; then
    sh scripts/install-packages.sh
fi


rojo sourcemap default.project.json -o sourcemap.json

ROBLOX_DEV=false darklua process --config .darklua.json src/ dist/

mkdir -p dist/Common/Remotes
cp -r src/Common/Remotes/* dist/Common/Remotes/


rojo build build.project.json -o RobloxProjectTemplate.rbxl
