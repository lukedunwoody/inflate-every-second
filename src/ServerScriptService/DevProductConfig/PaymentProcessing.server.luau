local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DevProductHandler = require(script.Parent)
local PurchaseEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PurchaseSuccess")

MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local success = DevProductHandler.HandlePurchase(player, receiptInfo.ProductId)
	if success then
		PurchaseEvent:FireClient(player)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	else
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end