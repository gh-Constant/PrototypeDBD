local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local ReadyEvent = ReplicatedStorage.Common.Remotes.ReadyEvent

local PlayerModule = require(ReplicatedStorage.Common.Player)

-- An enum to manage the state of the game.
local GameState = {
	Intermission = 0, -- Waiting for a match
	WaitingForPlayers = 1, -- Waiting for players to join from matchmaking
	Lobby = 2, -- Players in pre-game lobby, waiting for ready-up
	GameInProgress = 3, -- Game has started
	PostGame = 4, -- Game has ended, showing results
}
-- Make the enum read-only
GameState = setmetatable(GameState, {
	__newindex = function()
		error("Attempt to modify a read-only table")
	end,
})

local Game = {}
Game.State = GameState.Intermission
Game.StateChanged = Instance.new("BindableEvent")
Game.Players = {}
Game.ReadyPlayers = {}

local expectedPlayers = {}
local matchTimeoutCoroutine = nil
local MATCH_TIMEOUT = 30 -- seconds

ReadyEvent.OnServerEvent:Connect(function(player, isReady)
	if isReady then
		Game:PlayerReady(player)
	else
		Game:PlayerUnready(player)
	end
end)

-- Helper to count items in a dictionary
local function countDictionary(t)
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

function Game:GetState()
	return self.State
end

function Game:SetState(newState)
	if self.State ~= newState then
		self.State = newState
		self.StateChanged:Fire(newState)
		print("Game state changed to: " .. newState) -- For debugging
	end
end

function Game:_cancelMatch(reason)
	print("Match cancelled: " .. reason)
	if matchTimeoutCoroutine then
		coroutine.close(matchTimeoutCoroutine)
		matchTimeoutCoroutine = nil
	end

	-- Kick all players
	for _, playerObj in pairs(self.Players) do
		-- In a real game, you'd teleport them back to a lobby server
		playerObj.Player:Kick("Match cancelled: " .. reason)
	end

	-- Reset state
	self.Players = {}
	self.ReadyPlayers = {}
	expectedPlayers = {}
	self:SetState(GameState.Intermission)
end

-- Called by this module itself on initialization
function Game:PrepareGame(matchData)
	if self.State ~= GameState.Intermission then
		return
	end

	expectedPlayers = matchData
	self:SetState(GameState.WaitingForPlayers)

	-- Start a timeout
	matchTimeoutCoroutine = coroutine.create(function()
		task.wait(MATCH_TIMEOUT)
		self:_cancelMatch("A player failed to connect in time.")
	end)
	coroutine.resume(matchTimeoutCoroutine)
end

Players.PlayerAdded:Connect(function(player)
	if Game:GetState() ~= GameState.WaitingForPlayers then
		return
	end

	local role = expectedPlayers[player.UserId]
	if role then
		print(`Expected player {player.Name} joined.`)
		Game.Players[player.UserId] = PlayerModule.new(player, role)

		-- Check if all players have joined
		if countDictionary(Game.Players) == countDictionary(expectedPlayers) then
			print("All players have joined.")
			if matchTimeoutCoroutine then
				coroutine.close(matchTimeoutCoroutine)
				matchTimeoutCoroutine = nil
			end
			Game:SetState(GameState.Lobby)
		end
	else
		-- This player was not expected
		player:Kick("You are not part of this match.")
	end
end)

Players.PlayerRemoving:Connect(function(player)
	local state = Game:GetState()
	-- Only cancel match on live servers, not in Studio, for easier testing.
	if (state == GameState.WaitingForPlayers or state == GameState.Lobby) and not RunService:IsStudio() then
		if expectedPlayers[player.UserId] then
			Game:_cancelMatch(`Player {player.Name} left before the game started.`)
		end
	end

	-- Also remove from our tables if they leave mid-game
	if Game.Players[player.UserId] then
		Game.Players[player.UserId] = nil
	end
	if Game.ReadyPlayers[player.UserId] then
		Game.ReadyPlayers[player.UserId] = nil
	end
end)

function Game:PlayerReady(player)
	if self.State ~= GameState.Lobby then
		return
	end
	if not self.Players[player.UserId] then
		return
	end

	self.ReadyPlayers[player.UserId] = true
	self:_checkAllPlayersReady()
end

function Game:PlayerUnready(player)
	if self.State ~= GameState.Lobby then
		return
	end
	if self.ReadyPlayers[player.UserId] then
		self.ReadyPlayers[player.UserId] = nil
	end
end

function Game:_checkAllPlayersReady()
	if self.State ~= GameState.Lobby then
		return
	end

	local totalPlayers
	if RunService:IsStudio() then
		totalPlayers = countDictionary(self.Players)
	else
		totalPlayers = countDictionary(expectedPlayers)
	end

	local readyPlayers = countDictionary(self.ReadyPlayers)

	if readyPlayers == totalPlayers and totalPlayers > 0 then
		self:SetState(GameState.GameInProgress)
	end
end

function Game:EndGame()
	self:SetState(GameState.PostGame)
	-- TODO: Show scores, etc.
	task.wait(15) -- Wait 15 seconds on post-game screen
	self:SetState(GameState.Intermission)
	-- TODO: Send players back to a main lobby/server
end

--[[
	Self-Initialization
	This code runs once when the module is first required.
]]
local function initialize()
	local success, matchData = pcall(function()
		return TeleportService:GetTeleportSetting("matchData")
	end)

	if success and matchData then
		-- This is a game server that was started for a match
		Game:PrepareGame(matchData)
	elseif RunService:IsStudio() then
		print("Studio mode detected. Bypassing matchmaking and starting lobby.")
		Game:SetState(GameState.Lobby)
	else
		-- This server was not started for a match, maybe it's a lobby server
		-- or it should shut down.
		print("No match data found. Server is idle.")
	end
end

initialize()

Players.PlayerAdded:Connect(function(player)
	local state = Game:GetState()

	if state == GameState.WaitingForPlayers then
		local role = expectedPlayers[player.UserId]
		if role then
			print(`Expected player {player.Name} joined.`)
			Game.Players[player.UserId] = PlayerModule.new(player, role)

			-- Check if all players have joined
			if countDictionary(Game.Players) == countDictionary(expectedPlayers) then
				print("All players have joined.")
				if matchTimeoutCoroutine then
					coroutine.close(matchTimeoutCoroutine)
					matchTimeoutCoroutine = nil
				end
				Game:SetState(GameState.Lobby)
			end
		else
			-- This player was not expected
			player:Kick("You are not part of this match.")
		end
	elseif RunService:IsStudio() and state == GameState.Lobby then
		print(`Studio mode: Player {player.Name} joined the lobby.`)
		-- Assign a default role. First player is killer.
		local isKiller = countDictionary(Game.Players) == 0
		local role = isKiller and PlayerModule.Role.Killer or PlayerModule.Role.Survivor
		Game.Players[player.UserId] = PlayerModule.new(player, role)
		print(`Assigned role {role} to {player.Name}`)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	local state = Game:GetState()
	-- Only cancel match on live servers, not in Studio, for easier testing.
	if (state == GameState.WaitingForPlayers or state == GameState.Lobby) and not RunService:IsStudio() then
		if expectedPlayers[player.UserId] then
			Game:_cancelMatch(`Player {player.Name} left before the game started.`)
		end
	end

	-- Also remove from our tables if they leave mid-game
	if Game.Players[player.UserId] then
		Game.Players[player.UserId] = nil
	end
	if Game.ReadyPlayers[player.UserId] then
		Game.ReadyPlayers[player.UserId] = nil
	end
end)

return Game
