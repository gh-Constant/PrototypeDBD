local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Interactables = {}

local handlers = {
	Pallet = function(obj, player)
		if obj:GetAttribute("Downed") then
			print("Vaulting pallet")
			return
		end

		obj:SetAttribute("Downed", true)

		-- Make DownedCollision collidable
		local downedCollision = obj:FindFirstChild("DownedCollision")
		if downedCollision and downedCollision:IsA("BasePart") then
			downedCollision.CanCollide = true
		end

		-- New example start and end CFrames
		local exampleStartCFrame = CFrame.new(17.791, 4.51, 92.22) *
			CFrame.Angles(math.rad(0), math.rad(90), math.rad(78))
		local exampleEndCFrame = CFrame.new(17.791, 2.808, 95.113) *
			CFrame.Angles(math.rad(0), math.rad(90), math.rad(147))

		-- Compute the relative delta CFrame
		local deltaCFrame = exampleStartCFrame:Inverse() * exampleEndCFrame

		-- Apply the same delta to the current pallet
		local goalCFrame = obj.CFrame * deltaCFrame

		-- Tween to the goal CFrame
		local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService:Create(obj, tweenInfo, {CFrame = goalCFrame})
		tween:Play()

		-- Play drop sound
		local sound = ReplicatedStorage:WaitForChild("Sounds"):WaitForChild("Pallet"):WaitForChild("Drop"):Clone()
		sound.Parent = obj
		sound:Play()
		sound.Ended:Connect(function()
			sound:Destroy()
		end)

		print(player.Name .. " dropped pallet:", obj.Name)
	end,




	Vault = function(obj, player)
		print(player.Name .. " interacted with vault:", obj.Name)
		-- TODO: Vault animation / teleport
	end,

	Generator = function(obj, player)
		print(player.Name .. " started generator:", obj.Name)
		-- TODO: Generator repair minigame
	end,
}

local function setupInteractable(obj, tagName)
	if not obj:IsA("BasePart") then return end
	if obj:FindFirstChild("InteractPrompt") then return end

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "InteractPrompt"
	prompt.ActionText = "Use " .. tagName
	prompt.ObjectText = tagName
	prompt.MaxActivationDistance = 10
	prompt.Parent = obj
	prompt.KeyboardKeyCode = Enum.KeyCode.Space

	prompt.Triggered:Connect(function(player)
		if handlers[tagName] then
			handlers[tagName](obj, player)
		else
			warn("No handler defined for tag:", tagName)
		end
	end)
end

function Start()
	for tagName, _ in pairs(handlers) do
		for _, obj in ipairs(CollectionService:GetTagged(tagName)) do
			setupInteractable(obj, tagName)
		end

		CollectionService:GetInstanceAddedSignal(tagName):Connect(function(obj)
			setupInteractable(obj, tagName)
		end)
	end
end

Start()

return Interactables
