local FreeRewardEvent: RemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RewardRequest")
local Players = game:GetService("Players")

FreeRewardEvent.OnServerEvent:Connect(function(player)
	local timePlayed = player:FindFirstChild("TimePlayed")
	if not timePlayed then return end
	if timePlayed.Value >= 1800 then
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			leaderstats:FindFirstChild("Inflation").Value	+= 100000
			leaderstats:FindFirstChild("Wins").Value		+= 5000
			leaderstats:FindFirstChild("Rebirth").Value		+= 1
			timePlayed.Value = 0
		end
	end
end)