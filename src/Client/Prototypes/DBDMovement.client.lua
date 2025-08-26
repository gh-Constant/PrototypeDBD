-- // Smooth Turn Inertia Script
-- Place this in StarterPlayerScripts as a LocalScript

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Configuration
local turnSpeed = 8 -- higher = snappier, lower = more inertia
local cameraRelative = true -- true = move relative to camera direction

-- Run every frame
game:GetService("RunService").RenderStepped:Connect(function(dt)
	if humanoid.MoveDirection.Magnitude > 0 then
		-- Get desired movement direction
		local moveDir = humanoid.MoveDirection
		if cameraRelative then
			-- Make movement relative to camera
			local cam = workspace.CurrentCamera
			local camCF = CFrame.new(Vector3.zero, Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z))
			moveDir = (camCF:VectorToWorldSpace(moveDir)).Unit
		end

		-- Current forward vector
		local currentLook = rootPart.CFrame.LookVector

		-- Interpolate smoothly toward target direction
		local targetCF = CFrame.new(rootPart.Position, rootPart.Position + moveDir)
		rootPart.CFrame = rootPart.CFrame:Lerp(targetCF, math.clamp(turnSpeed * dt, 0, 1))
	end
end)
