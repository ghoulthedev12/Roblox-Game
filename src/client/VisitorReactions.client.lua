-- VisitorReactions (LocalScript in StarterPlayer > StarterPlayerScripts)
-- When a museum visitor looks at a meme, the server (VisitorManager) says which face it
-- makes; this pops a speech bubble with that 3D face over the visitor's head. It's built
-- here, in the PlayerGui, because a 3D face made on the server would sit in the Workspace,
-- where streaming never sends it to the players (the bubble showed up empty).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))

local player = Players.LocalPlayer
local reactionRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("VisitorReaction")

local bubbles = {} -- [head] = the bubble showing over it

reactionRemote.OnClientEvent:Connect(function(head, iconName, color)
	if typeof(head) ~= "Instance" or not head:IsA("BasePart") or not head.Parent then return end
	local old = bubbles[head]
	if old then old:Destroy() end

	local gui = Instance.new("BillboardGui")
	gui.Name = "VisitorReaction"
	gui.Adornee = head
	gui.Size = UDim2.fromScale(0, 0)
	gui.StudsOffset = Vector3.new(0, 2.6, 0)
	gui.AlwaysOnTop = false
	gui.MaxDistance = 90
	gui.LightInfluence = 0
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")
	bubbles[head] = gui

	local bubble = Instance.new("Frame")
	bubble.Size = UDim2.fromScale(1, 1)
	bubble.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	bubble.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.5, 0)
	corner.Parent = bubble
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = typeof(color) == "Color3" and color or Color3.fromRGB(40, 40, 60)
	stroke.Parent = bubble
	local face = UIKit.icon(bubble, iconName, {Size = UDim2.fromScale(0.9, 0.9), Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5)})

	-- pop in, hover, fade out
	TweenService:Create(gui, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.fromScale(2.6, 2.6)}):Play()
	TweenService:Create(gui, TweenInfo.new(2.4, Enum.EasingStyle.Sine), {StudsOffset = Vector3.new(0, 3.4, 0)}):Play()
	task.delay(2.2, function()
		if not gui.Parent then return end
		local fade = TweenInfo.new(0.4)
		TweenService:Create(bubble, fade, {BackgroundTransparency = 1}):Play()
		TweenService:Create(stroke, fade, {Transparency = 1}):Play()
		TweenService:Create(face, fade, {ImageTransparency = 1}):Play()
		local picture = face:FindFirstChild("IconImage")
		if picture then TweenService:Create(picture, fade, {ImageTransparency = 1}):Play() end
		task.delay(0.45, function()
			if bubbles[head] == gui then bubbles[head] = nil end
			gui:Destroy()
		end)
	end)
end)
