local Cmdr = require(game.ReplicatedStorage:WaitForChild("CmdrClient"))


local function Start()
	Cmdr:SetActivationKeys({ Enum.KeyCode.P })
end

Start()
return nil
