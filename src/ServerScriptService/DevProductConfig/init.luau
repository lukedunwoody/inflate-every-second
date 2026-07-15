-- Config
local DevProductConfig = {
	-- Stackable Boosts
	[3349515108] = {Persistant = true, Type = "2x Rebirth (Stackable)"},
	[3349515503] = {Persistant = true, Type = "2x Wins (Stackable)"},
	[3349516191] = {Persistant = true, Type = "Double Jump"},
	[3349515660] = {Persistant = true, Type = "Half Rebirth Price (Stackable)"},
	-- Permanent Mult Boosts
	[3349558752] = {Persistant = true, Type = "Multiplier", Tier = 1},
	[3349559828] = {Persistant = true, Type = "Multiplier", Tier = 2},
	[3349560050] = {Persistant = true, Type = "Multiplier", Tier = 3},
	[3349561961] = {Persistant = true, Type = "Multiplier", Tier = 4},
	[3349562156] = {Persistant = true, Type = "Multiplier", Tier = 5},
	[3349562490] = {Persistant = true, Type = "Multiplier", Tier = 6},
	[3349562996] = {Persistant = true, Type = "Multiplier", Tier = 7},
	[3349563151] = {Persistant = true, Type = "Multiplier", Tier = 8},
	[3349563506] = {Persistant = true, Type = "Multiplier", Tier = 9},
	[3349563594] = {Persistant = true, Type = "Multiplier", Tier = 10},
	-- Instant Effects (don’t need to be stored directly)
	[3349515890] = {Persistant = false, Type = "Double Current Infation"},
	[3349516013] = {Persistant = false, Type = "Steal Inflation"},
	[3349564064] = {Persistant = false, Type = "Inflation Boost", Tier = 1},
	[3349564398] = {Persistant = false, Type = "Inflation Boost", Tier = 2},
	[3349564501] = {Persistant = false, Type = "Inflation Boost", Tier = 3},
	[3349564700] = {Persistant = false, Type = "Inflation Boost", Tier = 4},
	[3349564922] = {Persistant = false, Type = "Inflation Boost", Tier = 5}
}

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PopFeedback = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PopFeedback")
local popTargets = require(ServerScriptService:WaitForChild("PopTargetsModule"))
local DevProductHandler = {}

local function publishResults(player, productId)
	local success, err = pcall(function()
		MessagingService:PublishAsync("ProductPurchase", {
			PlayerName = player.Name,
			ProductId = productId
		})
	end)
	if not success then
		warn("Failed to publish product purchase message:", err)
	end
end

function DevProductHandler.HandlePurchase(player, productId)
	local config = DevProductConfig[productId]
	if not config then
		warn("Unknown Developer Product:", productId)
		return false
	end

	local devProducts = player:FindFirstChild("DevProducts")
	if not devProducts then
		warn("DevProducts folder not found on", player.Name)
		return false
	end
	
	local moneySpent = player:FindFirstChild("MoneySpent")
	if moneySpent then
		moneySpent.Value += game:GetService("MarketplaceService"):GetProductInfoAsync(productId, Enum.InfoType.Product).PriceInRobux
	else
		warn("MoneySpent value does not exist in ", player.Name)
	end

	-- Handle persistent products
	if config.Persistant then
		if config.Type == "Multiplier" then
			local stat = devProducts:FindFirstChild("MultiplierTier")
			if stat and config.Tier == stat.Value + 1 then
				stat.Value = config.Tier
			end
		elseif config.Type == "2x Rebirth (Stackable)" then
			local stat = devProducts:FindFirstChild("Rebirth2x")
			if stat then stat.Value += 1 end
		elseif config.Type == "2x Wins (Stackable)" then
			local stat = devProducts:FindFirstChild("Wins2x")
			if stat then stat.Value += 1 end
		elseif config.Type == "Double Jump" then
			local stat = devProducts:FindFirstChild("DoubleJump")
			if stat then stat.Value = true end
		elseif config.Type == "Half Rebirth Price (Stackable)" then
			local stat = devProducts:FindFirstChild("HalfRebirth")
			if stat then stat.Value += 1 end
		end

		publishResults(player, productId)
		return true
	end

	-- Handle instant effects
	if config.Type == "Double Current Infation" then
		local inflation = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Inflation")
		if inflation then
			inflation.Value *= 2
		end
		return true

	elseif config.Type == "Inflation Boost" and config.Tier then
		local inflation = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Inflation")
		local inflationAmounts = {
			[1] = 2000,
			[2] = 10000,
			[3] = 100000,
			[4] = 1000000,
			[5] = 10000000,
		}
		if inflation and inflationAmounts[config.Tier] then
			inflation.Value += inflationAmounts[config.Tier]
		end
		publishResults(player, productId)
		return true

	elseif config.Type == "Steal Inflation" then
		local targetPlayer = popTargets[player]
		local targetInflation = Players:FindFirstChild(tostring(targetPlayer)):FindFirstChild("leaderstats"):FindFirstChild("Inflation")
		local stealerInflation = player:FindFirstChild("leaderstats"):FindFirstChild("Inflation")
		if targetInflation and stealerInflation then
			stealerInflation.Value += targetInflation.Value
			targetInflation.Value = 0
			popTargets[player.UserId] = nil
			PopFeedback:FireClient(targetPlayer, player)
		end

		publishResults(player, productId)
		return true
	end

	return false
end

return DevProductHandler