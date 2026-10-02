-- VisitorReactions (LocalScript in StarterPlayer > StarterPlayerScripts)
-- When a museum visitor looks at a meme, the server (VisitorManager) says which face it
-- makes; this pops a speech bubble with that emoji over the visitor's head (emoji here on
-- purpose: the owner asked for them, the 3D faces were hard to read that small).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local EMOJI = {
	FaceMeh = "\u{1F610}", FaceSick = "\u{1F922}", FaceHappy = "\u{1F60A}", FaceWow = "\u{1F62E}",
	FaceLaugh = "\u{1F602}", FaceCool = "\u{1F60E}", FaceLove = "\u{1F60D}", Heart = "\u{2764}\u{FE0F}",
	Fire = "\u{1F525}", Crown = "\u{1F451}", Star = "\u{2B50}",
}

local player = Players.LocalPlayer
local reactionRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("VisitorReaction")

local bubbles = {} -- [head] = the bubble showing over it

reactionRemote.OnClientEvent:Connect(function(head, reaction, color)
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
	local face = Instance.new("TextLabel")
	face.BackgroundTransparency = 1
	face.Size = UDim2.fromScale(0.78, 0.78)
	face.Position = UDim2.fromScale(0.5, 0.5)
	face.AnchorPoint = Vector2.new(0.5, 0.5)
	face.Text = EMOJI[reaction] or EMOJI.FaceHappy
	face.TextScaled = true
	face.Font = Enum.Font.GothamBold
	face.Parent = bubble

	-- pop in, hover, fade out
	TweenService:Create(gui, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.fromScale(2.6, 2.6)}):Play()
	TweenService:Create(gui, TweenInfo.new(2.4, Enum.EasingStyle.Sine), {StudsOffset = Vector3.new(0, 3.4, 0)}):Play()
	task.delay(2.2, function()
		if not gui.Parent then return end
		local fade = TweenInfo.new(0.4)
		TweenService:Create(bubble, fade, {BackgroundTransparency = 1}):Play()
		TweenService:Create(stroke, fade, {Transparency = 1}):Play()
		TweenService:Create(face, fade, {TextTransparency = 1}):Play()
		task.delay(0.45, function()
			if bubbles[head] == gui then bubbles[head] = nil end
			gui:Destroy()
		end)
	end)
end)
