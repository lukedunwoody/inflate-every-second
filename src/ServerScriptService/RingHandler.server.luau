local ringConfig = {
	MaxRingsPerTier = 50,
	SpawnQuadArea = 2,
	RingSpawnArea = 150,
	CollectionCheckInterval = 0.03,
	RingsFolderName = "Rings"
}
local ringTiers = {
	[1] = {Color = Color3.fromRGB(163, 162, 165),	Wins = 1,    MinHeight = 30,   MaxHeight = 100,		Radius = 15, RingCheckRadius = 0.48, MaxRings = 50},
	[2] = {Color = Color3.fromRGB(0, 255, 26),		Wins = 20,   MinHeight = 100,  MaxHeight = 500,		Radius = 25, RingCheckRadius = 0.48, MaxRings = 60},
	[3] = {Color = Color3.fromRGB(0, 170, 255),		Wins = 200,  MinHeight = 500,  MaxHeight = 1200,	Radius = 35, RingCheckRadius = 0.46, MaxRings = 50},
	[4] = {Color = Color3.fromRGB(170, 0, 255),		Wins = 1000, MinHeight = 1200, MaxHeight = 2200,	Radius = 50, RingCheckRadius = 0.44, MaxRings = 40},
	[5] = {Color = Color3.fromRGB(255, 26, 26),		Wins = 2500, MinHeight = 2200, MaxHeight = 4000,	Radius = 70, RingCheckRadius = 0.42, MaxRings = 30},
	[6] = {Color = Color3.fromRGB(255, 215, 0),		Wins = 5000, MinHeight = 4000, MaxHeight = 6000,	Radius = 90, RingCheckRadius = 0.42, MaxRings = 25}
}

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local RingTemplate = ServerStorage:WaitForChild("RingTemplate")
local RingSpawnArea = ringConfig.RingSpawnArea

-- Create a folder to hold all rings
local ringsFolder = Workspace:FindFirstChild(ringConfig.RingsFolderName)
if not ringsFolder then
	ringsFolder = Instance.new("Folder")
	ringsFolder.Name = ringConfig.RingsFolderName
	ringsFolder.Parent = Workspace
end
-- Clear existing rings on startup
for _, existingRing in ipairs(ringsFolder:GetChildren()) do
	if existingRing:IsA("MeshPart") then
		existingRing:Destroy()
	end
end

local function createRing(tier)
	local data = ringTiers[tier]
	if not data then return nil end

	local ring = RingTemplate:Clone()
	ring.Color = data.Color

	local meshSize = ring.MeshSize
	local yScale = data.Radius / meshSize.X
	ring.Size = Vector3.new(data.Radius, meshSize.Y * yScale, data.Radius)
	ring:SetAttribute("Tier", tier)

	local x = math.random(-RingSpawnArea, RingSpawnArea)
	local y = (math.random()^ringConfig.SpawnQuadArea * (data.MaxHeight-data.MinHeight)) + data.MinHeight
	local z = math.random(-RingSpawnArea, RingSpawnArea)
	ring.Position = Vector3.new(x, y, z)
	ring.Anchored = true
	ring.Parent = ringsFolder

	return ring
end

local function collectRing(player, ring, tier)
	local data = ringTiers[tier]
	if not data then return end

	local leaderstats = player:FindFirstChild("leaderstats")
	local devFolder  = player:FindFirstChild("DevProducts")
	if not leaderstats or not devFolder then return end

	local w2x = devFolder:FindFirstChild("Wins2x")
	local wins       = leaderstats:FindFirstChild("Wins")
	local inflation  = leaderstats:FindFirstChild("Inflation")
	local rebirth = leaderstats:FindFirstChild("Rebirth")
	if wins and inflation and rebirth and w2x then
		local eventMult = 1
		local mult = 2 ^ w2x.Value * 2 ^ rebirth.Value * eventMult

		local gained = data.Wins * mult
		wins.Value     = wins.Value + gained
		inflation.Value = 0
		player.Character:FindFirstChild("Humanoid").HeadScale.Value = 0
	end

	ring:Destroy()
	createRing(tier)
end

-- Spawn rings
for tier = 1, #ringTiers do
	for _ = 1, ringTiers[tier]["MaxRings"] do
		createRing(tier)
	end
end

-- Handle collection
local accumulator = 0
RunService.Heartbeat:Connect(function(dt)
	accumulator = accumulator + dt
	if accumulator < ringConfig.CollectionCheckInterval then return end
	accumulator = 0

	-- Loop players first (usually fewer), then rings
	for _, player in ipairs(Players:GetPlayers()) do
		local char = player.Character
		local head = char and char:FindFirstChild("Head")
		if head then
			local hx, hy, hz = head.Position.X, head.Position.Y, head.Position.Z

			for _, ring in ipairs(ringsFolder:GetChildren()) do
				local tier = ring:GetAttribute("Tier")
				local data = ringTiers[tier]
				if (head.Position - ring.Position).Magnitude <= data.Radius * data.RingCheckRadius then
					collectRing(player, ring, tier)
					break
				end
			end
		end
	end
end)