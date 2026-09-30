-- TutorialClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The first-join walkthrough (TutorialManager runs the steps on the server):
--   a "WELCOME, ARCHAEOLOGIST!" splash, then a step card on the left of the screen
--   (1 Equip Pickaxe -> 2 Jump into Pit -> 3 Dig Up Framed Artifacts -> 4 Display in Museum),
--   a glowing guide beam from your character to where you need to go, and a bouncing arrow
--   over the target. A Skip button ends it for good.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local skipRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TutorialSkip")
local player = Players.LocalPlayer

local STEPS = {
	{Icon = "⛏", Title = "Equip your pickaxe", Text = "Press 1, or click the pickaxe in your hotbar at the bottom of the screen."},
	{Icon = "🕳", Title = "Jump into the pit", Text = "Follow the glowing trail to the dig site and hop down into the dirt!"},
	{Icon = "🖼", Title = "Dig up a framed artifact", Text = "Click the ground to swing. Keep digging until an artifact appears, then hold E to pull it out!"},
	{Icon = "🏛", Title = "Display it in your museum", Text = "Follow the trail home and press E at a glowing pedestal to put your meme on show."},
}
local STEP_COLORS = {C.Sun, C.Mint, C.Coral, C.Violet}

local gui = UIKit.screen(player, "TutorialGui", 6)

---------------------------------------------------------------------
-- WELCOME SPLASH
---------------------------------------------------------------------
local splash = UIKit.panel(gui, {Size = UDim2.fromOffset(520, 150), Position = UDim2.fromScale(0.5, 0.36), AnchorPoint = Vector2.new(0.5, 0.5),
	Color = C.Ink, Radius = 30, Stroke = 4, StrokeColor = C.Sun, ShadeAmount = 0.2})
splash.BackgroundTransparency = 0.06
splash.Visible = false
UIKit.label(splash, "WELCOME, ARCHAEOLOGIST!", {Size = UDim2.new(1, -40, 0, 46), Position = UDim2.new(0.5, 0, 0, 22), AnchorPoint = Vector2.new(0.5, 0),
	Color = C.Sun, Stroke = 3, MaxText = 38})
UIKit.label(splash, "It's 2050. The old internet is buried under your feet.\nLet's dig up your first meme!", {Size = UDim2.new(1, -50, 0, 52),
	Position = UDim2.new(0.5, 0, 0, 78), AnchorPoint = Vector2.new(0.5, 0), Color = C.White, Stroke = 0, Font = UIKit.BodyFont, MaxText = 20})

---------------------------------------------------------------------
-- STEP CARD
---------------------------------------------------------------------
local card = UIKit.panel(gui, {Size = UDim2.fromOffset(330, 178), Position = UDim2.fromOffset(100, 96), Color = C.Ink, Radius = 22, Stroke = 3, StrokeColor = C.Sky, ShadeAmount = 0.2})
card.BackgroundTransparency = 0.08
card.Visible = false
local cardStroke = card:FindFirstChildOfClass("UIStroke")
local stepTag = UIKit.label(card, "", {Size = UDim2.new(1, -110, 0, 18), Position = UDim2.fromOffset(16, 12), Align = "Left", Color = C.Sky, Stroke = 0, MaxText = 15})
local badge = UIKit.badge(card, "", C.Sun, {Diameter = 50, Position = UDim2.fromOffset(14, 38)})
local badgeLabel = badge:FindFirstChildWhichIsA("TextLabel", true)
local title = UIKit.label(card, "", {Size = UDim2.new(1, -90, 0, 28), Position = UDim2.fromOffset(74, 38), Align = "Left", Color = C.White, Stroke = 2, MaxText = 22})
local body = UIKit.label(card, "", {Size = UDim2.new(1, -90, 0, 58), Position = UDim2.fromOffset(74, 68), Align = "Left", VAlign = "Top",
	Color = C.PanelTint, Stroke = 0, Font = UIKit.BodyFont, TextSize = 15})
local dots = {}
for i = 1, #STEPS do
	dots[i] = UIKit.panel(card, {Size = UDim2.fromOffset(40, 8), Position = UDim2.new(0, 16 + (i - 1) * 48, 1, -22), Color = C.Grey, Radius = 4, Stroke = false, Shade = false})
end
local skipButton = UIKit.button(card, "SKIP", {Size = UDim2.fromOffset(70, 30), Position = UDim2.new(1, -12, 0, 8), AnchorPoint = Vector2.new(1, 0), Color = C.Grey, Radius = 12, MaxText = 14})
skipButton.MouseButton1Click:Connect(function()
	skipRemote:FireServer()
end)

-- step 1: a bouncing arrow pointing down at the hotbar
local hotbarArrow = UIKit.label(gui, "⬇", {Size = UDim2.fromOffset(60, 60), Position = UDim2.new(0.5, 0, 1, -140), AnchorPoint = Vector2.new(0.5, 1),
	Color = C.Sun, Stroke = 3, MaxText = 56})
hotbarArrow.Visible = false

-- the "done!" toast
local toast = UIKit.panel(gui, {Size = UDim2.fromOffset(460, 70), Position = UDim2.fromScale(0.5, 0.3), AnchorPoint = Vector2.new(0.5, 0.5),
	Color = C.Mint, Radius = 35, Stroke = 4, StrokeColor = C.Ink})
toast.Visible = false
UIKit.label(toast, "🎉 TUTORIAL COMPLETE! Your meme is earning money!", {Size = UDim2.new(1, -40, 0.6, 0), Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = Vector2.new(0.5, 0.5), Color = C.White, Stroke = 2.5, MaxText = 22})

---------------------------------------------------------------------
-- GUIDE BEAM + ARROW IN THE WORLD
---------------------------------------------------------------------
local targetPart = Instance.new("Part")
targetPart.Name = "TutorialTarget"
targetPart.Anchored = true
targetPart.CanCollide = false
targetPart.CanQuery = false
targetPart.CanTouch = false
targetPart.Transparency = 1
targetPart.Size = Vector3.one
local targetAttachment = Instance.new("Attachment")
targetAttachment.Parent = targetPart
local arrowGui = Instance.new("BillboardGui")
arrowGui.Size = UDim2.fromOffset(90, 90)
arrowGui.AlwaysOnTop = true
arrowGui.LightInfluence = 0
arrowGui.Parent = targetPart
local worldArrow = UIKit.label(arrowGui, "⬇", {Size = UDim2.fromScale(1, 1), Color = C.Sun, Stroke = 3, MaxText = 80})

local beam = Instance.new("Beam")
beam.Attachment1 = targetAttachment
beam.FaceCamera = true
beam.Width0 = 1.2
beam.Width1 = 1.2
beam.Segments = 60
beam.LightEmission = 0.8
beam.LightInfluence = 0
beam.Color = ColorSequence.new(Color3.fromRGB(120, 240, 255), Color3.fromRGB(255, 230, 120))
beam.Parent = targetPart

local function myMuseumSlot()
	for _, museum in ipairs(workspace:WaitForChild("Museums"):GetChildren()) do
		if museum:GetAttribute("OwnerUserId") == player.UserId then
			local slots = museum:FindFirstChild("Slots")
			local slot = slots and slots:FindFirstChild("Slot1")
			local spot = slot and (slot:FindFirstChild("DisplaySpot") or slot:FindFirstChild("ViewSpot"))
			if spot then return spot.Position end
		end
	end
	return nil
end

local function myBuriedPainting()
	local finds = workspace:FindFirstChild("BuriedFinds")
	for _, model in ipairs(finds and finds:GetChildren() or {}) do
		if model:GetAttribute("Owner") == player.UserId and model.PrimaryPart then
			return model.PrimaryPart.Position
		end
	end
	return nil
end

-- where the trail leads for each step (nil = no trail)
local function targetFor(step, root)
	if step == 2 then
		local world = GameConfig.Worlds[1]
		local flat = (root.Position - world.Origin) * Vector3.new(1, 0, 1)
		local dir = flat.Magnitude > 1 and flat.Unit or Vector3.zAxis
		return world.Origin + dir * (world.PitRadius - 8) + Vector3.new(0, 3, 0)
	elseif step == 3 then
		return myBuriedPainting()
	elseif step == 4 then
		return myMuseumSlot()
	end
	return nil
end

---------------------------------------------------------------------
-- SHOWING THE STEPS
---------------------------------------------------------------------
local shownStep = 0
local welcomed = false
local fromAttachment

local function showStep(step)
	if step == shownStep then return end
	local finished = shownStep > 0 and step == 0
	shownStep = step
	card.Visible = step > 0
	if finished then
		toast.Visible = true
		UIKit.pop(toast, 0.4)
		task.delay(4, function() toast.Visible = false end)
	end
	if step == 0 then return end
	if not welcomed and step == 1 then
		welcomed = true
		splash.Visible = true
		UIKit.pop(splash, 0.5)
		task.delay(3.2, function() splash.Visible = false end)
	end
	local info = STEPS[step]
	local color = STEP_COLORS[step]
	stepTag.Text = "TUTORIAL  ·  STEP " .. step .. " OF " .. #STEPS
	title.Text = info.Title
	body.Text = info.Text
	if badgeLabel then badgeLabel.Text = info.Icon end
	badge.BackgroundColor3 = color
	cardStroke.Color = color
	for i, dot in ipairs(dots) do
		dot.BackgroundColor3 = i < step and C.Mint or (i == step and color or C.Grey)
	end
	UIKit.pop(card, 0.8)
end

local function onTutorialChanged()
	showStep(player:GetAttribute("Tutorial") or 0)
end
player:GetAttributeChangedSignal("Tutorial"):Connect(onTutorialChanged)
onTutorialChanged()

RunService.RenderStepped:Connect(function()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local clock = os.clock()
	hotbarArrow.Visible = shownStep == 1
	if hotbarArrow.Visible then
		hotbarArrow.Position = UDim2.new(0.5, 0, 1, -140 + math.sin(clock * 6) * 10)
	end
	local target = root and shownStep > 0 and targetFor(shownStep, root)
	if not target then
		targetPart.Parent = nil
		return
	end
	-- the trail starts at our character
	if not fromAttachment or fromAttachment.Parent ~= root then
		fromAttachment = Instance.new("Attachment")
		fromAttachment.Name = "TutorialTrailStart"
		fromAttachment.Position = Vector3.new(0, -1.5, 0)
		fromAttachment.Parent = root
		beam.Attachment0 = fromAttachment
	end
	targetPart.CFrame = CFrame.new(target)
	targetPart.Parent = workspace
	arrowGui.StudsOffset = Vector3.new(0, 4 + math.sin(clock * 5) * 0.8, 0)
	worldArrow.TextColor3 = STEP_COLORS[shownStep]
	-- glowing pulses run along the trail toward the target
	local keys = {}
	for i = 0, 17 do
		local x = i / 17
		local wave = 0.5 + 0.5 * math.sin((x * 8 - clock * 2.5) * math.pi * 2)
		table.insert(keys, NumberSequenceKeypoint.new(x, 0.15 + 0.6 * (1 - wave)))
	end
	beam.Transparency = NumberSequence.new(keys)
end)

