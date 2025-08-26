--[[
	@fileoverview PlayerMovementService - Server-side service for managing player movement restrictions
	@author Generated
	@version 1.0.0
	@date 2024
]]

local MovementRestrictions = {}

local Players = game:GetService("Players")

-- Constants
local MOVEMENT_CONFIG = {
	JUMP_POWER = 0,
	JUMP_HEIGHT = 0,
	USE_JUMP_POWER = true,
	CLIMBING_ENABLED = false
}

-- Handle all players (existing and new)
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		
		-- Disable jumping
		humanoid.JumpPower = MOVEMENT_CONFIG.JUMP_POWER
		humanoid.UseJumpPower = MOVEMENT_CONFIG.USE_JUMP_POWER
		humanoid.JumpHeight = MOVEMENT_CONFIG.JUMP_HEIGHT
		
		-- Disable climbing
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, MOVEMENT_CONFIG.CLIMBING_ENABLED)
	end)
end)

-- Handle players already in the game
for _, player in pairs(Players:GetPlayers()) do
	if player.Character then
		local humanoid = player.Character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.JumpPower = MOVEMENT_CONFIG.JUMP_POWER
			humanoid.UseJumpPower = MOVEMENT_CONFIG.USE_JUMP_POWER
			humanoid.JumpHeight = MOVEMENT_CONFIG.JUMP_HEIGHT
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, MOVEMENT_CONFIG.CLIMBING_ENABLED)
		end
	end
	
	-- Connect to future character spawns for existing players
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		
		humanoid.JumpPower = MOVEMENT_CONFIG.JUMP_POWER
		humanoid.UseJumpPower = MOVEMENT_CONFIG.USE_JUMP_POWER
		humanoid.JumpHeight = MOVEMENT_CONFIG.JUMP_HEIGHT
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, MOVEMENT_CONFIG.CLIMBING_ENABLED)
	end)
end

return MovementRestrictions