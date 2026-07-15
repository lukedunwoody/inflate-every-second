local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")

ReplicatedFirst:RemoveDefaultLoadingScreen()
repeat task.wait() until game:IsLoaded()

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local MainGui = playerGui:WaitForChild("MainGui")
MainGui.Enabled = false

local loadingGui = script:WaitForChild("LoadingGui"):Clone()
loadingGui.Parent = playerGui

local Background = loadingGui:WaitForChild("Background")
local ProgressLabel = Background:WaitForChild("ProgressLabel")
local ImageLabel: ImageLabel = Background:WaitForChild("ImageLabel")
local startScale = ImageLabel.Size
local ProgressGradient = ImageLabel:WaitForChild("UIGradient")

local assets = {}
local n = 0
for _, child in ipairs(game:GetChildren()) do
	n = n + 1; assets[n] = child
	for _, grandchild in ipairs(child:GetChildren()) do
		n = n + 1; assets[n] = grandchild
	end
end

local totalAssets = #assets

local camera = workspace.CurrentCamera
local function setImageOrientation()
	if camera.ViewportSize.X/camera.ViewportSize.Y < 16/9 then
		ImageLabel.SizeConstraint = Enum.SizeConstraint.RelativeXX
	else
		ImageLabel.SizeConstraint = Enum.SizeConstraint.RelativeYY
	end
end
setImageOrientation()
camera:GetPropertyChangedSignal("ViewportSize"):Connect(setImageOrientation)

task.wait(0.5)
for i, asset in assets do
	local progress = math.clamp(i/totalAssets, 0, 1)
	if math.random() > 0.3 then task.wait() end
	local ok, err = pcall(function()
		ContentProvider:PreloadAsync({asset})
	end)
	if not ok then
		warn("Preload failed for", asset, err)
	end
	
	ProgressGradient.Offset = Vector2.new(progress-0.5,0)
	ProgressLabel.Text = math.round(progress*100).."%"
	local progressQuad = progress^.5*.1
	ImageLabel.Size = UDim2.new(progressQuad,0,progressQuad,0) + startScale
end

ProgressLabel.Text = "100%"
ProgressGradient.Offset = Vector2.new(0.5,0)

task.wait(0.2)
TweenService:Create(Background, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Transparency = 1}):Play()
for _, child in Background:GetChildren() do
	if child:IsA("TextLabel") then
		TweenService:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
	elseif child:IsA("ImageLabel") then
		TweenService:Create(child, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {ImageTransparency = 1, Size = UDim2.new(0,0,0,0)}):Play()
	elseif child:IsA("CanvasGroup") then
		TweenService:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {GroupTransparency = 1}):Play()
	end
end
task.wait(0.5)
loadingGui:Destroy()
MainGui.Enabled = true
script:Destroy()