local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local getRebirthCost = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RebirthConfig"))

local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local RebirthRequest = EventsFolder:WaitForChild("RebirthRequest")
local RebirthFeedback = EventsFolder:WaitForChild("RebirthFeedback")

local function onRebirthRequest(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end

	local wins = leaderstats:FindFirstChild("Wins")
	local inflation = leaderstats:FindFirstChild("Inflation")
	local rebirth = leaderstats:FindFirstChild("Rebirth")
	if not (wins and inflation and rebirth) then return end
	
	local devProducts = player:FindFirstChild("DevProducts")
	local doubleJump = devProducts:FindFirstChild("DoubleJump")
	local halfRebirth = devProducts:FindFirstChild("HalfRebirth")
	if not devProducts then return end

	local requiredWins = getRebirthCost(player)

	if wins.Value >= requiredWins then
		local rebirthMult = devProducts:WaitForChild("Rebirth2x")
		local rebirthGain = 2^rebirthMult.Value

		-- Reset stats and add rebirth(s)
		wins.Value = 0
		inflation.Value = 0
		rebirth.Value += rebirthGain

		-- Fire success feedback to client
		RebirthFeedback:FireClient(player, true, rebirth.Value, getRebirthCost(player))
		player.character.HumanoidRootPart.Position = Vector3.new(0, 5, 0)
		player.character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
		player.character:FindFirstChild("Humanoid").HeadScale.Value = 0
		if rebirth.Value >= 3 and doubleJump ~= nil and doubleJump.Value ~= true then
			doubleJump.Value = true
		end
	else
		-- Fire failure feedback to client
		RebirthFeedback:FireClient(player, false, requiredWins)
	end
end

RebirthRequest.OnServerEvent:Connect(onRebirthRequest)