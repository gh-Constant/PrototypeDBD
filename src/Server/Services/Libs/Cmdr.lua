local Cmdr = require("@Packages/cmdr")
local CommandsFolder = game.ServerScriptService.Server.Commands

local function Start()
	Cmdr:RegisterDefaultCommands()
    Cmdr:RegisterCommandsIn(CommandsFolder)
end

Start()
return nil
