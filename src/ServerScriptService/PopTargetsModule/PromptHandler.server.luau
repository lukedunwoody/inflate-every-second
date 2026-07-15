local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PopRequest = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PopRequest")

local popTargets = require(script.Parent)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

		-- create a prompt so others can interact
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Steal Inflation"
		prompt.ObjectText = player.Name
		prompt.RequiresLineOfSight = false
		prompt.MaxActivationDistance = 20
		prompt.Parent = humanoidRootPart
	end)	
end)

ProximityPromptService.PromptTriggered:Connect(function(prompt, triggeringPlayer)
	local targetChar = prompt.Parent and prompt.Parent.Parent
	local targetPlayer = targetChar and Players:GetPlayerFromCharacter(targetChar)
	if not targetPlayer or triggeringPlayer == targetPlayer then return end

	popTargets[triggeringPlayer] = targetPlayer
	PopRequest:FireClient(triggeringPlayer)
end)