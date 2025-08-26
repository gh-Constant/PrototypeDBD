--[[
	@description Server implementation for resetting all pallets to upright position
	@author Your Name
	@version 1.0.0
	@date 2024
]]

local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Constants
local RESET_TWEEN_INFO = TweenInfo.new(
	0.3,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.Out
)

--[[
	@description Resets a single pallet to its upright position
	@param pallet BasePart The pallet object to reset
	@private
]]
local function resetSinglePallet(pallet)
	if not pallet:IsA("BasePart") then
		return false
	end
	
	-- Check if pallet is currently downed
	if not pallet:GetAttribute("Downed") then
		return false -- Already upright
	end
	
	-- Reset the downed attribute
	pallet:SetAttribute("Downed", false)
	
	-- Disable DownedCollision
	local downedCollision = pallet.Parent:FindFirstChild("DownedCollision")
	if downedCollision and downedCollision:IsA("BasePart") then
		downedCollision.CanCollide = false
	end
	
	-- Calculate the inverse transformation to reset pallet position
	-- Using the same example CFrames from Interactables.lua but inverted
	local exampleStartCFrame = CFrame.new(17.791, 4.51, 92.22) *
		CFrame.Angles(math.rad(0), math.rad(90), math.rad(78))
	local exampleEndCFrame = CFrame.new(17.791, 2.808, 95.113) *
		CFrame.Angles(math.rad(0), math.rad(90), math.rad(147))
	
	-- Compute the inverse delta CFrame to reset position
	local deltaCFrame = exampleStartCFrame:Inverse() * exampleEndCFrame
	local inverseDeltaCFrame = deltaCFrame:Inverse()
	
	-- Apply the inverse delta to reset the pallet
	local resetCFrame = pallet.CFrame * inverseDeltaCFrame
	
	-- Tween back to upright position
	local resetTween = TweenService:Create(
		pallet,
		RESET_TWEEN_INFO,
		{ CFrame = resetCFrame }
	)
	resetTween:Play()
	
	-- Play reset sound
	local soundsFolder = ReplicatedStorage:FindFirstChild("Sounds")
	if soundsFolder then
		local palletFolder = soundsFolder:FindFirstChild("Pallet")
		if palletFolder then
			-- Try to find a reset sound, fallback to drop sound
			local resetSound = palletFolder:FindFirstChild("Reset") or 
							   palletFolder:FindFirstChild("Drop")
			
			if resetSound then
				local sound = resetSound:Clone()
				sound.Parent = pallet
				sound:Play()
				
				sound.Ended:Connect(function()
					sound:Destroy()
				end)
			end
		end
	end
	
	return true
end

--[[
	@description Main command function to reset all pallets
	@param context CommandContext The command execution context
	@return string Result message
]]
return function(context)
	local pallets = CollectionService:GetTagged("Pallet")
	
	if #pallets == 0 then
		return "Aucune palette trouvée dans le jeu."
	end
	
	local resetCount = 0
	local totalPallets = #pallets
	
	-- Reset each pallet
	for _, pallet in ipairs(pallets) do
		local success = resetSinglePallet(pallet)
		if success then
			resetCount = resetCount + 1
		end
	end
	
	-- Return appropriate message based on results
	if resetCount == 0 then
		return "Toutes les palettes sont déjà debout."
	elseif resetCount == totalPallets then
		return string.format(
			"Toutes les palettes ont été remises debout (%d/%d).",
			resetCount,
			totalPallets
		)
	else
		return string.format(
			"%d palettes remises debout sur %d au total.",
			resetCount,
			totalPallets
		)
	end
end