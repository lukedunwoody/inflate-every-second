local MessagingService = game:GetService("MessagingService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local globalPurchaseEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("GlobalPurchase")

local function onProductPurchaseReceived(message)
	local data = message.Data
	if typeof(data) ~= "table" or not data.PlayerName or not data.ProductId then
		warn("Received invalid product purchase data:", data)
		return
	end

	local username = data.PlayerName
	local productName = MarketplaceService:GetProductInfoAsync(data.ProductId, Enum.InfoType.Product).Name
	local productPrice = MarketplaceService:GetProductInfoAsync(data.ProductId, Enum.InfoType.Product).PriceInRobux

	local text = string.format(username.." has just bought "..productName.." for "..productPrice.." Robux!")
	globalPurchaseEvent:FireAllClients(text)
end

local success, err = pcall(function()
	MessagingService:SubscribeAsync("ProductPurchase", onProductPurchaseReceived)
end)

if not success then
	warn("Failed to subscribe to ProductPurchase messages:", err)
end