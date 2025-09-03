--!strict

local Player = {}
Player.__index = Player

-- Enum for player roles
export type PlayerRole = "None" | "Survivor" | "Killer"
local PlayerRole = {
	None = "None",
	Survivor = "Survivor",
	Killer = "Killer",
}
-- Make the enum read-only
PlayerRole = setmetatable(PlayerRole, { __newindex = function()
	error("Attempt to modify a read-only table")
end })


Player.Role = PlayerRole

function Player.new(player: Player, role: PlayerRole)
	local self = setmetatable({}, Player)

	self.Player = player
	self.UserId = player.UserId
	self.Name = player.Name
	self.Role = role
	self.IsLoaded = false -- To track if the player has loaded into the game

	return self
end

return Player