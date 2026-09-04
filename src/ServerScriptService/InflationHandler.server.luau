local Players = game:GetService("Players")
local TopArea = workspace:WaitForChild("Map"):WaitForChild("TopArea")
local Glow = TopArea:WaitForChild("Glow")
local Reward = TopArea:WaitForChild("Reward")
local KillBrick = TopArea:WaitForChild("KillBrick")

local ReplicatedStore = game:GetService("ReplicatedStorage")
local JumpRequest = ReplicatedStore:WaitForChild("Events"):WaitForChild("JumpRequest")

-- What Ys do you want at what Inflation (i)
local function solveCurve(i1, y1, i2, y2)
	local b = math.log(y2 / y1) / math.log(i2 / i1)
	local a = y1 / (i1 ^ b)
	return a, b
end
function getHeadScale(inflation)
	if inflation >= 1e12 then return 30 end
	local a, b = solveCurve(100, 0.5, 1e12, 30)
	return a * (inflation ^ b)
end
local function getJumpHeight(inflation)
	if inflation < 32 then return inflation end
	local a, b = solveCurve(100, 40, 1e18, 5000)
	return a * (inflation ^ b)
end

Players.PlayerAdded:Connect(function(player)
	local leaderstats = player:WaitForChild("leaderstats")
	local rebirth = leaderstats:WaitForChild("Rebirth")
	local wins = leaderstats:WaitForChild("Wins")
	local inflation = leaderstats:WaitForChild("Inflation")
	local devProducts = player:WaitForChild("DevProducts")
	local multTier = devProducts:WaitForChild("MultiplierTier")
	local wins2x = devProducts:WaitForChild("Wins2x")
	local doubleJump = devProducts:WaitForChild("DoubleJump")
	local timePlayed = player:WaitForChild("TimePlayed")

	local jumpCount = 0
	local atTopArea = false
	local humanoid: Humanoid

	local function onCharacterAdded(character)
		humanoid = character:WaitForChild("Humanoid")
		local head = character:WaitForChild("Head")
		head.Massless = true
		head.CanCollide = false

		Glow.Touched:Connect(function(otherPart)
			if atTopArea then return end
			if otherPart:IsDescendantOf(character) then
				local rootPart = character:FindFirstChild("HumanoidRootPart")
				humanoid.JumpHeight = 7.2
				humanoid.HeadScale.Value = 1
				if rootPart then
					rootPart.CFrame = CFrame.new(Vector3.new(0,10276.5,-75), Vector3.new(0))
					rootPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
					rootPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
				end
				task.wait(0.1)
				atTopArea = true
			end
		end)

		Reward.Touched:Connect(function(otherPart)
			if not atTopArea then return end
			if otherPart:IsDescendantOf(character) then
				wins.Value += 100000 * 2^wins2x.Value * 2^rebirth.Value
				atTopArea = false
				local rootPart = character:FindFirstChild("HumanoidRootPart")
				humanoid.Health = 0
			end
		end)

		KillBrick.Touched:Connect(function(hit)
			if not atTopArea then return end
			humanoid.Health = 0
		end)

		local debouncing = false
		local alreadyRunning = false

		JumpRequest.OnServerEvent:Connect(function(firingPlayer)

			if firingPlayer ~= player then return end
			if not doubleJump.Value then return end

			if not humanoid or humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then return end
			if jumpCount >= 1 then return end

			local jumpHeight = getJumpHeight(inflation.Value)
			local jumpPower = math.sqrt(2 * workspace.Gravity * jumpHeight)

			jumpCount += 1
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

			local jumpHeight = getJumpHeight(inflation.Value)
			local jumpPower = math.clamp(math.sqrt(2 * workspace.Gravity * jumpHeight), 50, 1400.7)

			local rootPart = humanoid.Parent:FindFirstChild("HumanoidRootPart")
			if rootPart then
				-- Apply upward force using BodyVelocity
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Velocity = Vector3.new(0, jumpPower, 0)
				bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
				bodyVelocity.P = 1250
				bodyVelocity.Name = "DoubleJumpForce"
				bodyVelocity.Parent = rootPart

				-- Cleanup after short time
				game.Debris:AddItem(bodyVelocity, 0.05)
			end
		end)

		humanoid.StateChanged:Connect(function(_, newState)
			if newState == Enum.HumanoidStateType.Landed or newState == Enum.HumanoidStateType.Running then
				jumpCount = 0
			end
		end)

		local neck = head:FindFirstChild("Neck")
			or character:WaitForChild("Torso"):WaitForChild("Neck")
		local originalNeckC0 = neck.C0

		while character.Parent and not atTopArea do
			local inflationRate = (1+wins.Value) * 2^multTier.Value
			inflation.Value += inflationRate
			humanoid.HeadScale.Value = getHeadScale(inflation.Value)
			humanoid.JumpHeight = getJumpHeight(inflation.Value)

			local yOffset = getHeadScale(inflation.Value) * 0.1
			--neck.C0 = originalNeckC0 * CFrame.new(0, yOffset, 0) -- Broken on new update

			task.wait(1)
			timePlayed.Value += 1
		end
	end

	player.CharacterAdded:Connect(onCharacterAdded)
	if player.Character then
		onCharacterAdded(player.Character)
	end
end)
