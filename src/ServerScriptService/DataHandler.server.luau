local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ServerStorage = game:GetService("ServerStorage")

local DataStoreUpdate = ServerStorage:WaitForChild("DataStoreUpdate")
local playerDataStore = DataStoreService:GetDataStore("PlayerData")

-- Each stat has its own DataStore
local leaderboards = {
	Rebirth = DataStoreService:GetOrderedDataStore("RebirthStore"),
	Wins = DataStoreService:GetOrderedDataStore("WinsStore"),
	Inflation = DataStoreService:GetOrderedDataStore("InflationStore"),
	MoneySpent = DataStoreService:GetOrderedDataStore("MoneySpentStore"),
}

-- Gamepass/Product mappings
local trackedProducts = {
	["3349515108"] = "Rebirth2x",
	["3349515503"] = "Wins2x",
	["3349516191"] = "DoubleJump",
	["3349515660"] = "HalfRebirth",
	["MultiplierTier"] = "MultiplierTier"
}

local reverseMap = {
	Rebirth2x = 3349515108,
	Wins2x = 3349515503,
	DoubleJump = 3349516191,
	HalfRebirth = 3349515660
}
local function getProductIdForStatName(name)
	return reverseMap[name]
end

-- Safe load/save helpers
local function safeLoad(store, key, default)
	local success, data = pcall(function()
		return store:GetAsync(key)
	end)
	if success and data ~= nil then
		return data
	end
	return default
end

local function safeSave(store, key, value)
	pcall(function()
		store:SetAsync(key, value)
	end)
end

-- Create leaderstats & folders
local function makeLeaderstats(player, data)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local rebirth = Instance.new("IntValue")
	rebirth.Name = "Rebirth"
	rebirth.Value = data.Rebirth or 0
	rebirth.Parent = leaderstats

	local wins = Instance.new("IntValue")
	wins.Name = "Wins"
	wins.Value = data.Wins or 0
	wins.Parent = leaderstats

	local inflation = Instance.new("NumberValue")
	inflation.Name = "Inflation"
	inflation.Value = data.Inflation or 0
	inflation.Parent = leaderstats

	-- DevProduct tracking
	local devProductFolder = Instance.new("Folder")
	devProductFolder.Name = "DevProducts"
	devProductFolder.Parent = player

	for idOrKey, statName in pairs(trackedProducts) do
		local value
		if statName == "DoubleJump" then
			value = Instance.new("BoolValue")
			value.Value = data.DevProducts and (data.DevProducts[idOrKey] == true or data.DevProducts[idOrKey] == 1)
		else
			value = Instance.new("IntValue")
			value.Value = data.DevProducts and (data.DevProducts[idOrKey] or 0) or 0
		end
		value.Name = statName
		value.Parent = devProductFolder
	end

	local moneySpent = Instance.new("IntValue")
	moneySpent.Name = "MoneySpent"
	moneySpent.Value = data.MoneySpent or 0
	moneySpent.Parent = player
	
	local timePlayed = Instance.new("IntValue")
	timePlayed.Name = "TimePlayed"
	timePlayed.Value = 0
	timePlayed.Parent = player
end

-- Load player data
local function loadPlayerData(player)
	local success, data = pcall(function()
		return playerDataStore:GetAsync(player.UserId)
	end)
	if success and data then
		return data
	else
		return {
			Rebirth = 0,
			Wins = 0,
			Inflation = 0,
			MoneySpent = 0,
			DevProducts = {}
		}
	end
end

-- Save player data
local function savePlayerData(player)
	local dataToSave = {}
	
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end
	
	if leaderstats then
		dataToSave.Rebirth = leaderstats:FindFirstChild("Rebirth") and leaderstats.Rebirth.Value or 0
		dataToSave.Wins = leaderstats:FindFirstChild("Wins") and leaderstats.Wins.Value or 0
		dataToSave.Inflation = leaderstats:FindFirstChild("Inflation") and leaderstats.Inflation.Value or 0
		dataToSave.MoneySpent = player:FindFirstChild("MoneySpent") and player.MoneySpent.Value or 0
	end

	local devFolder = player:FindFirstChild("DevProducts")
	local devData = {}
	if devFolder then
		for _, statName in pairs({"Rebirth2x","Wins2x","DoubleJump","HalfRebirth","MultiplierTier"}) do
			local val = devFolder:FindFirstChild(statName)
			if val then
				local key = statName == "MultiplierTier" and "MultiplierTier" or tostring(getProductIdForStatName(statName))
				if statName == "DoubleJump" then
					devData[key] = val.Value == true or val.Value == 1
				else
					devData[key] = val.Value
				end
			end
		end
	end
	dataToSave.DevProducts = devData
	local success, err = pcall(function()
		playerDataStore:SetAsync(player.UserId, dataToSave)
	end)
	if not success then
		warn("Failed to save data for "..player.Name..": "..tostring(err))
	end

	safeSave(leaderboards.Rebirth, player.UserId, dataToSave.Rebirth)
	safeSave(leaderboards.Wins, player.UserId, dataToSave.Wins)
	safeSave(leaderboards.Inflation, player.UserId, dataToSave.Inflation)
	safeSave(leaderboards.MoneySpent, player.UserId, dataToSave.MoneySpent)
end

-- Player connections
Players.PlayerAdded:Connect(function(player)
	local data = loadPlayerData(player)
	makeLeaderstats(player, data)

	player.AncestryChanged:Connect(function(_, parent)
		if not parent then
			savePlayerData(player)
		end
	end)
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		savePlayerData(player)
	end
end)

task.defer(function()
	while true do
		for _, player in ipairs(Players:GetPlayers()) do
			savePlayerData(player)
		end
		DataStoreUpdate:Fire()
		task.wait(120)
	end
end)