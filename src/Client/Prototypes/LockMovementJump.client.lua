-- LocalScript inside StarterPlayerScripts

local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local camera = workspace.CurrentCamera

-- Disable default mouse behavior
uis.MouseBehavior = Enum.MouseBehavior.LockCenter
uis.MouseIconEnabled = false

-- Make sure camera is always in scriptable mode
camera.CameraType = Enum.CameraType.Custom

game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
	local humanoid = char:WaitForChild("Humanoid")
	humanoid.JumpPower = 0 -- disables jump (old property)
	humanoid.UseJumpPower = true
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
	humanoid.JumpHeight = 0 -- also make sure new property is disabled
end)