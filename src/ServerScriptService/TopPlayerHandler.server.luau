local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- A StringValue to store the top player’s name (create this in ReplicatedStorage ahead of time)
local topPlayerValues = ReplicatedStorage:WaitForChild("TopPlayerValues")
local topPlayerValue = topPlayerValues:WaitForChild("Name")
local topInflationValue = topPlayerValues:WaitForChild("Inflation") -- optional

-- Function to find and update the biggest player
local function updateTopPlayer()
	local topPlayer = nil
	local topInflation = 0

	for _, player in ipairs(Players:GetPlayers()) do
		local stats = player:FindFirstChild("leaderstats")
		if stats then
			local inflation = stats:FindFirstChild("Inflation")
			if inflation and inflation.Value > topInflation then
				topInflation = inflation.Value
				topPlayer = player
			end
		end
	end

	if topPlayer then
		topPlayerValue.Value = topPlayer.Name
		topInflationValue.Value = topInflation
	else
		topPlayerValue.Value = "N/A"
		topInflationValue.Value = 0
	end
end

updateTopPlayer()
-- Update regularly and on player changes
Players.PlayerAdded:Connect(updateTopPlayer)
Players.PlayerRemoving:Connect(updateTopPlayer)

game:GetService("RunService").Stepped:Connect(function()
	updateTopPlayer()
end)