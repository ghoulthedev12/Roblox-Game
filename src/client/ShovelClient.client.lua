-- ShovelClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Shovel swing + dig animation, depth + zone meter, underground light,
-- Return to Surface button, and the Shovel Shop window (each world's shovels as cards
-- with 3D icons, stat bars and their depth rating).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local swingRemote = remotes:WaitForChild("DigSwing")
local digMessageRemote = remotes:WaitForChild("DigProgress")
local surfaceRemote = remotes:WaitForChild("ReturnToSurface")
local openShopRemote = remotes:WaitForChild("OpenShovelShop")
local buyShovelRemote = remotes:WaitForChild("BuyShovel")
local equipShovelRemote = remotes:WaitForChild("EquipShovel")
local shopMessageRemote = remotes:WaitForChild("ShopMessage")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local gui = UIKit.screen(player, "ShovelGui", 2)

---------------------------------------------------------------------
-- HINT MESSAGES (bubbly text above the hotbar)
---------------------------------------------------------------------
local hint = UIKit.panel(gui, {
	Size = UDim2.fromOffset(560, 46), Position = UDim2.new(0.5, 0, 1, -196), AnchorPoint = Vector2.new(0.5, 0),
	Color = C.Ink, Radius = 23, Stroke = 2.5, StrokeColor = C.Lilac, ShadeAmount = 0.2,
})
hint.BackgroundTransparency = 0.12
hint.Visible = false
local hintDot = UIKit.panel(hint, {Size = UDim2.fromOffset(14, 14), Position = UDim2.new(0, 16, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Color = C.Sun, Radius = 7, Stroke = false})
local hintText = UIKit.label(hint, "", {Size = UDim2.new(1, -56, 1, -14), Position = UDim2.new(0, 40, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
	Align = "Left", Color = C.White, Stroke = 0, MaxText = 22})

local hintToken = 0
local function showHint(text, color)
	hintToken += 1
	local myToken = hintToken
	hintText.Text = text
	hintDot.BackgroundColor3 = color or C.Sun
	hintText.TextColor3 = (color or C.Sun):Lerp(C.White, 0.55)
	hint.Visible = true
	UIKit.pop(hint, 0.7)
	task.delay(2.8, function()
		if hintToken == myToken then hint.Visible = false end
	end)
end

---------------------------------------------------------------------
-- "JUMP INTO THE PIT" PROMPT: shows while you hold a pickaxe outside the pit and vanishes the
-- instant your character enters the pit volume (GameConfig.IsInPit uses GetPartBoundsInBox)
---------------------------------------------------------------------
-- a small pill in the top-left corner, out of the way
local pitPrompt = UIKit.panel(gui, {
	Size = UDim2.fromOffset(250, 36), Position = UDim2.fromOffset(14, 12),
	Color = C.Ink, Radius = 18, Stroke = 2.5, StrokeColor = C.Sky, ShadeAmount = 0.2,
})
pitPrompt.BackgroundTransparency = 0.12
pitPrompt.Visible = false
UIKit.label(pitPrompt, "⛏  Jump into the pit to dig!", {Size = UDim2.new(1, -24, 1, -12), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
	Color = C.White, Stroke = 0, MaxText = 17})
local insidePit = false

digMessageRemote.OnClientEvent:Connect(function(message, color)
	if typeof(message) == "string" then
		showHint(message, typeof(color) == "Color3" and color or nil)
	end
end)

---------------------------------------------------------------------
-- DEPTH GAUGE (slim tube on the right edge) + RETURN TO SURFACE + UNDERGROUND LIGHT
---------------------------------------------------------------------
local GAUGE_H = 230 -- height of the tube in pixels

local depthPanel = Instance.new("Frame") -- whole gauge; shown while holding a shovel or underground
depthPanel.BackgroundTransparency = 1
depthPanel.Size = UDim2.fromOffset(104, 360)
depthPanel.Position = UDim2.new(1, -12, 0.5, 0)
depthPanel.AnchorPoint = Vector2.new(1, 0.5)
depthPanel.Visible = false
depthPanel.Parent = gui
local gaugeScale = Instance.new("UIScale")
gaugeScale.Parent = depthPanel
local function fitScreen()
	gaugeScale.Scale = math.clamp(camera.ViewportSize.Y / 720, 0.65, 1)
end
camera:GetPropertyChangedSignal("ViewportSize"):Connect(fitScreen)
fitScreen()

-- depth number bubble
local depthBubble = UIKit.panel(depthPanel, {Size = UDim2.fromOffset(96, 42), Position = UDim2.new(0.5, 0, 0, 0), AnchorPoint = Vector2.new(0.5, 0), Color = C.Ink, Radius = 21, StrokeColor = C.Lilac})
depthBubble.BackgroundTransparency = 0.1
local depthLabel = UIKit.label(depthBubble, "0m", {Size = UDim2.new(1, -16, 0.7, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.White, Stroke = 0, MaxText = 26})

-- the depth bonus (more luck the deeper you are, see GameConfig.DepthBonus) above the bubble
local bonusLabel = UIKit.label(depthPanel, "", {Size = UDim2.fromOffset(110, 18), Position = UDim2.new(0.5, 0, 0, -22), AnchorPoint = Vector2.new(0.5, 0),
	Color = C.Mint, Stroke = 2, MaxText = 15})

-- the tube, filled with one colored band per zone (thicker zones = taller bands)
local tube = UIKit.panel(depthPanel, {Size = UDim2.fromOffset(30, GAUGE_H), Position = UDim2.new(0.5, 0, 0, 50), AnchorPoint = Vector2.new(0.5, 0), Color = C.PanelTint, Radius = 15, Stroke = 3, StrokeColor = C.Ink, Shade = false})
-- the zone bands sit in a CanvasGroup, which clips them to the tube's rounded ends
-- (a plain frame clips square, so a band's corner used to poke out as a line at the bottom)
local bands = Instance.new("CanvasGroup")
bands.BackgroundTransparency = 1
bands.BorderSizePixel = 0
bands.Size = UDim2.fromScale(1, 1)
bands.Parent = tube
UIKit.corner(bands, 15)
local tubeGloss = UIKit.panel(tube, {Size = UDim2.new(0, 6, 1, -16), Position = UDim2.new(0, 5, 0, 8), Color = C.White, Radius = 3, Stroke = false, Shade = false})
tubeGloss.BackgroundTransparency = 0.55
tubeGloss.ZIndex = 3

-- your position: a bright bar across the tube
local marker = UIKit.panel(depthPanel, {Size = UDim2.fromOffset(42, 10), Position = UDim2.new(0.5, 0, 0, 50), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Sun, Radius = 5, Stroke = 2.5, Shade = false})
marker.ZIndex = 4

-- your shovel's limit: a red line across the tube with a small tag
local limitLine = UIKit.panel(depthPanel, {Size = UDim2.fromOffset(40, 6), Position = UDim2.new(0.5, 0, 0, 50), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Coral, Radius = 3, Stroke = 2, Shade = false})
limitLine.ZIndex = 4
local shovelLabel = UIKit.label(depthPanel, "", {Size = UDim2.fromOffset(34, 16), Position = UDim2.new(0.5, 22, 0, 50), AnchorPoint = Vector2.new(0, 0.5), Align = "Left", Color = C.Coral, Stroke = 2})
shovelLabel.ZIndex = 4

-- zone name pill under the tube: dark, with the zone's color as a dot and an outline
local zonePill = UIKit.panel(depthPanel, {Size = UDim2.fromOffset(104, 28), Position = UDim2.new(0.5, 0, 0, 50 + GAUGE_H + 12), AnchorPoint = Vector2.new(0.5, 0), Color = C.Ink, Radius = 14, Stroke = 2.5})
zonePill.BackgroundTransparency = 0.1
local zoneStroke = zonePill:FindFirstChildOfClass("UIStroke")
local zoneDot = UIKit.panel(zonePill, {Size = UDim2.fromOffset(12, 12), Position = UDim2.new(0, 8, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Color = C.Sun, Radius = 6, Stroke = false, Shade = false})
local zoneLabel = UIKit.label(zonePill, "", {Size = UDim2.new(1, -30, 0.64, 0), Position = UDim2.new(0, 24, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Color = C.White, Stroke = 0, MaxText = 14})

-- small "surface" button under everything, only while underground
local surfaceButton = UIKit.button(depthPanel, "SURFACE", {
	Size = UDim2.fromOffset(104, 40), Position = UDim2.new(0.5, 0, 0, 50 + GAUGE_H + 50), AnchorPoint = Vector2.new(0.5, 0), Color = C.Sky, Radius = 20,
})
surfaceButton.Visible = false
surfaceButton.MouseButton1Click:Connect(function()
	surfaceRemote:FireServer()
end)

local headlamp -- PointLight on our character when underground
local equippedDef -- the shovel currently in hand
local gaugeWorld -- world the bands were drawn for

---------------------------------------------------------------------
-- PIT AMBIENCE: the deeper you dig, the more the air inside the pit takes on the color of
-- the layer you're in (warm dust in the topsoil, orange clay, cold crystal blue, magma red):
-- a soft haze of drifting particles around you, a color grade, and your headlamp's tint
---------------------------------------------------------------------
local Lighting = game:GetService("Lighting")
local LAYER_AIR = { -- by zone index; worlds 2-9 mix in their own zone colors
	Color3.fromRGB(255, 226, 180), -- topsoil: warm dusty light
	Color3.fromRGB(255, 176, 120), -- dense clay: orange
	Color3.fromRGB(140, 220, 255), -- crystal substratum: cold blue
	Color3.fromRGB(255, 110, 60),  -- magma core: red-hot
}
local pitGrade = Instance.new("ColorCorrectionEffect")
pitGrade.Name = "PitDepthGrade"
pitGrade.Enabled = false
pitGrade.Parent = Lighting
local hazePart = Instance.new("Part")
hazePart.Name = "PitHaze"
hazePart.Anchored = true
hazePart.CanCollide = false
hazePart.CanQuery = false
hazePart.CanTouch = false
hazePart.Transparency = 1
hazePart.Size = Vector3.new(40, 20, 40)
local haze = Instance.new("ParticleEmitter")
haze.Shape = Enum.ParticleEmitterShape.Box
haze.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
haze.LightEmission = 0.3
haze.LightInfluence = 0.2
haze.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1.5), NumberSequenceKeypoint.new(1, 4)})
haze.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.4, 0.86), NumberSequenceKeypoint.new(1, 1)})
haze.Lifetime = NumberRange.new(4, 6)
haze.Speed = NumberRange.new(0.2, 0.6)
haze.RotSpeed = NumberRange.new(-15, 15)
haze.Rate = 0
haze.Parent = hazePart
local airColor = LAYER_AIR[1]

local function updatePitAir(world, depth, zoneIndex, zoneColor)
	local strength = math.clamp((depth - 6) / 40, 0, 1) -- fades in over the first 40 studs down
	if strength <= 0 then
		pitGrade.Enabled = false
		haze.Rate = 0
		return
	end
	local target = LAYER_AIR[zoneIndex or 1] or LAYER_AIR[1]
	if world.Id ~= 1 and zoneColor then target = target:Lerp(zoneColor, 0.6) end
	airColor = airColor:Lerp(target, 0.15) -- blend smoothly as you cross into a new layer
	pitGrade.Enabled = true
	pitGrade.TintColor = Color3.new(1, 1, 1):Lerp(airColor, 0.22 * strength)
	pitGrade.Contrast = 0.05 * strength
	pitGrade.Saturation = 0.08 * strength
	haze.Color = ColorSequence.new(airColor)
	haze.Rate = 22 * strength
	hazePart.CFrame = CFrame.new(camera.CFrame.Position)
	hazePart.Parent = camera
end

local function currentWorld()
	return GameConfig.GetWorld(player:GetAttribute("CurrentWorld") or 1) or GameConfig.Worlds[1]
end

local function drawBands(world)
	gaugeWorld = world
	bands:ClearAllChildren()
	local total = -world.Zones[#world.Zones].Bottom
	for i, zone in ipairs(world.Zones) do
		local top = -zone.Top / total
		local height = (zone.Top - zone.Bottom) / total
		local band = Instance.new("Frame")
		band.BorderSizePixel = 0
		band.BackgroundColor3 = zone.Color
		band.Position = UDim2.fromScale(0, top)
		band.Size = UDim2.fromScale(1, height)
		band.Parent = bands
		if i > 1 then
			local seam = Instance.new("Frame")
			seam.BorderSizePixel = 0
			seam.BackgroundColor3 = C.Ink
			seam.Size = UDim2.new(1, 0, 0, 2)
			seam.Parent = band
		end
	end
end

-- y position (in gauge pixels) of a depth
local function gaugeY(world, depth)
	local total = -world.Zones[#world.Zones].Bottom
	return 50 + math.clamp(depth / total, 0, 1) * GAUGE_H
end

RunService.Heartbeat:Connect(function()
	local character = player.Character
	local wasInside = insidePit
	insidePit = GameConfig.IsInPit(currentWorld(), character)
	if insidePit and not wasInside and hint.Visible and hintText.Text:find("pit") then
		hint.Visible = false -- the old "get in the pit" nag disappears the moment you're in
	end
	local show = equippedDef ~= nil and not insidePit and character ~= nil
	if show and not pitPrompt.Visible then UIKit.pop(pitPrompt, 0.7) end
	pitPrompt.Visible = show
end)

task.spawn(function()
	while true do
		task.wait(0.15)
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root then
			local world = currentWorld()
			if world ~= gaugeWorld then drawBands(world) end
			local feetY = root.Position.Y - 3
			local depth = math.max(0, math.floor(world.Origin.Y - feetY + 0.5))
			local inPit = insidePit

			local zoneIndex, zone = GameConfig.GetZoneAt(world, feetY)
			zone = zone or {Name = "Bedrock", Color = Color3.fromRGB(150, 150, 160)}
			updatePitAir(world, inPit and depth or 0, zoneIndex or #world.Zones, zone.Color)
			depthLabel.Text = depth .. "m"
			local bonus = GameConfig.DepthBonus(world, feetY)
			bonusLabel.Text = bonus >= 1.01 and string.format("🍀 x%.2f LUCK", bonus) or ""
			zoneLabel.Text = string.upper(zone.Name)
			zoneDot.BackgroundColor3 = zone.Color
			if zoneStroke then zoneStroke.Color = zone.Color end
			-- the marker stays inside the tube, even at the very bottom
			marker.Position = UDim2.new(0.5, 0, 0, math.clamp(gaugeY(world, depth), 50 + 6, 50 + GAUGE_H - 6))

			if equippedDef and equippedDef.World == world.Id then
				local maxDepth = -world.Zones[equippedDef.MaxZone].Bottom
				limitLine.Visible = equippedDef.MaxZone < #world.Zones
				shovelLabel.Visible = limitLine.Visible
				limitLine.Position = UDim2.new(0.5, 0, 0, gaugeY(world, maxDepth))
				shovelLabel.Position = UDim2.new(0.5, 22, 0, gaugeY(world, maxDepth))
				shovelLabel.Text = "MAX"
				-- marker turns red when you're right at your shovel's limit
				marker.BackgroundColor3 = (limitLine.Visible and maxDepth - depth <= 8) and C.Coral or C.Sun
			else
				limitLine.Visible = false
				shovelLabel.Visible = false
				marker.BackgroundColor3 = C.Sun
			end

			depthPanel.Visible = equippedDef ~= nil or (inPit and depth > 4)
			surfaceButton.Visible = inPit and depth > 4

			-- small light so you can see underground
			if depth > 4 then
				if not headlamp or headlamp.Parent ~= root then
					headlamp = Instance.new("PointLight")
					headlamp.Color = Color3.fromRGB(255, 235, 200)
					headlamp.Range = 22
					headlamp.Brightness = 1.3
					headlamp.Shadows = true
					headlamp.Parent = root
				end
				headlamp.Enabled = true
				headlamp.Color = Color3.fromRGB(255, 240, 220):Lerp(airColor, 0.35)
			elseif headlamp then
				headlamp.Enabled = false
			end
		end
	end
end)

---------------------------------------------------------------------
-- SHOVEL POSE + DIG ANIMATION (for every player's character on this screen)
-- The real tool is hidden on this screen. A copy of the shovel is placed exactly where the
-- pose wants it every frame, the right hand grips its shaft with IK (position AND rotation,
-- so the fist really wraps the handle like a normal Roblox tool), and the torso leans and
-- twists with the swing. The swing is short and snappy with a tiny freeze on impact.
-- The blade is never allowed to sink into the ground.
-- Other players' swings arrive through ShovelSwingFx, so everyone sees everyone dig.
---------------------------------------------------------------------
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local ShovelModels = require(ReplicatedStorage:WaitForChild("PickaxeModels"))
local swingFxRemote = remotes:WaitForChild("ShovelSwingFx")

-- TWO-HANDED PICKAXE POSE. Values are relative to the HumanoidRootPart (+X right, +Y up,
-- -Z forward). The right hand holds the bottom of the handle, the left hand holds it a bit
-- higher up (both by IK, so the grip always matches the pickaxe).
-- Hand  = where the right hand holds the handle (studs)
-- Tilt  = handle pitch, degrees: 0 = head pointing straight down, 90 = head pointing forward,
--         180 = head straight up, 225 = head up and back over the shoulder
-- Turn  = yaw (+ = to the left), Roll = sideways lean of the pickaxe (+ = head leans left)
-- Lean  = torso pitch (+ = bend forward), Twist = torso yaw (+ = turn left)
-- Bend  = torso side bend (+ = lean left), Look = head pitch (+ = look down)
local CHANNELS = {"Tilt", "Turn", "Roll", "Lean", "Twist", "Bend", "Look"}
-- ready stance: pickaxe held low and across the body, head out to the side (clear of the face)
local IDLE = {Hand = Vector3.new(0.35, -0.15, -0.8), Tilt = 105, Turn = 30, Roll = 15, Lean = 3, Twist = 0, Bend = 0, Look = 2}

-- easing curves: how each part of the swing speeds up and slows down
local function easeInOutSine(u) return -(math.cos(math.pi * u) - 1) / 2 end
local function easeOutCubic(u) return 1 - (1 - u) ^ 3 end
local function easeOutSine(u) return math.sin(u * math.pi / 2) end
local function easeInQuad(u) return u * u end
local function easeOutBack(u)
	local c1 = 1.9
	return 1 + (c1 + 1) * (u - 1) ^ 3 + c1 * (u - 1) ^ 2
end
local function easeInOutCubic(u) return u < 0.5 and 4 * u * u * u or 1 - (-2 * u + 2) ^ 3 / 2 end

-- The dig, key by key (a two-beat scoop, like digging with a spade): a quick wind-up, a stab
-- down into the dirt in front, a pry back, then a heave up over the right shoulder that
-- flings the dirt up and behind. Ease = how the motion INTO that key is timed.
local SWING = {
	{T = 0.00, Pose = IDLE},
	-- wind-up: the pickaxe comes up beside the right shoulder
	{T = 0.12, Ease = easeInOutSine, Pose = {Hand = Vector3.new(0.6, 0.55, -0.5), Tilt = 150, Turn = 0, Roll = -20, Lean = -2, Twist = -16, Bend = -2, Look = -4}},
	-- stab: driven down hard into the ground in front of the feet
	{T = 0.26, Ease = easeInQuad, Pose = {Hand = Vector3.new(0.15, -0.55, -1.25), Tilt = 40, Turn = 4, Roll = 0, Lean = 30, Twist = -6, Bend = 4, Look = 24}},
	-- pry: leans back on the handle, levering the dirt loose
	{T = 0.40, Ease = easeOutCubic, Pose = {Hand = Vector3.new(0.3, -0.25, -0.75), Tilt = 62, Turn = 8, Roll = 6, Lean = 24, Twist = -10, Bend = 3, Look = 18}},
	-- fling: heaved up over the right shoulder, throwing the dirt up and behind
	{T = 0.62, Ease = easeInOutSine, Pose = {Hand = Vector3.new(0.95, 1.4, 0.05), Tilt = 215, Turn = -14, Roll = -32, Lean = -8, Twist = -46, Bend = -6, Look = -12}},
	-- settle back into the ready stance
	{T = 1.00, Ease = easeInOutCubic, Pose = IDLE},
}
local STRIKE_TIME = 0.26 -- the blade bites the ground (the dig happens here)
local FLING_TIME = 0.54 -- the dirt leaves the blade on the way up
local HIT_STOP = 0.05 -- the pose freezes this long on impact, which makes hits feel heavy
local TRAILS = {{0.14, 0.28}, {0.44, 0.64}} -- swoosh trail during the stab and the fling
local WOBBLE = {Degrees = 7, Decay = 9, Speed = 38} -- the handle vibrates after the impact

-- tool axes when upright: grip end (+Z) points up (head down), pick arms (+Y) point forward
local UPRIGHT = CFrame.fromMatrix(Vector3.zero, Vector3.xAxis, -Vector3.zAxis, Vector3.yAxis)

-- smooth Catmull-Rom curve through the swing keyframes (never jerky)
local function catmull(p0, p1, p2, p3, u)
	local u2, u3 = u * u, u * u * u
	return (p1 * 2 + (p2 - p0) * u + (p0 * 2 - p1 * 5 + p2 * 4 - p3) * u2 + (p1 * 3 - p0 - p2 * 3 + p3) * u3) * 0.5
end

local function samplePose(t, keys)
	keys = keys or SWING
	t = math.clamp(t, 0, 1)
	local i = 1
	while i < #keys - 1 and t > keys[i + 1].T do i += 1 end
	local k0, k1, k2, k3 = keys[math.max(i - 1, 1)], keys[i], keys[i + 1], keys[math.min(i + 2, #keys)]
	local u = (t - k1.T) / (k2.T - k1.T)
	u = k2.Ease and k2.Ease(u) or u
	local pose = {Hand = catmull(k0.Pose.Hand, k1.Pose.Hand, k2.Pose.Hand, k3.Pose.Hand, u)}
	for _, c in ipairs(CHANNELS) do
		pose[c] = catmull(k0.Pose[c], k1.Pose[c], k2.Pose[c], k3.Pose[c], u)
	end
	return pose
end

-- the ready stance is never frozen: breathing, a slow weight shift, and a bob while walking
local function idlePose(clock, moving)
	local breathe = math.sin(clock * 2.2)
	local sway = math.sin(clock * 0.8)
	local step = math.sin(clock * 11) * moving
	return {
		Hand = IDLE.Hand + Vector3.new(sway * 0.05, breathe * 0.04 + math.abs(step) * 0.08, 0),
		Tilt = IDLE.Tilt + breathe * 2 + step * 4, Turn = IDLE.Turn + sway * 2,
		Roll = IDLE.Roll + sway * 3, Lean = IDLE.Lean + breathe * 0.6 + moving * 5,
		Twist = IDLE.Twist + sway * 2, Bend = sway * 1.5 + step * 1.2, Look = -breathe * 2,
	}
end

-- EQUIP: the pickaxe fades in at the side with a sparkle, gets flipped up into the air,
-- spins twice, is caught overhead with a flash, then swung down into the ready stance.
local EQUIP_LENGTH = 0.8
local EQUIP = {
	{T = 0.00, Pose = {Hand = Vector3.new(0.6, -0.35, -0.4), Tilt = 30, Turn = 10, Roll = 0, Lean = 0, Twist = 0, Bend = 0, Look = 4}},
	{T = 0.14, Ease = easeInOutSine, Pose = {Hand = Vector3.new(0.5, -0.3, -0.5), Tilt = 60, Turn = 10, Roll = 0, Lean = 4, Twist = 4, Bend = 0, Look = 0}},
	{T = 0.22, Ease = easeOutCubic, Pose = {Hand = Vector3.new(0.9, 1.0, -0.8), Tilt = 160, Turn = 0, Roll = -20, Lean = -4, Twist = -6, Bend = 0, Look = -20}},
	{T = 0.50, Ease = easeOutSine, Pose = {Hand = Vector3.new(1.0, 1.45, -0.7), Tilt = 180, Turn = 0, Roll = -20, Lean = -6, Twist = -10, Bend = -2, Look = -25}},
	{T = 0.64, Ease = easeInQuad, Pose = {Hand = Vector3.new(0.25, -0.05, -1.0), Tilt = 95, Turn = 20, Roll = 10, Lean = 10, Twist = -12, Bend = 2, Look = 8}},
	{T = 1.00, Ease = easeOutBack, Pose = IDLE},
}
local TOSS_FROM, TOSS_TO, TOSS_HEIGHT, TOSS_SPINS = 0.22, 0.5, 3.4, 2
local onEquipCatch -- camera jolt + sound for our own catch (set further down)

local rigs = {} -- [character] = rig
local puppetFolder = Instance.new("Folder")
puppetFolder.Name = "ShovelPuppets"
puppetFolder.Parent = workspace

local function newAttachment(parent, name)
	local a = Instance.new("Attachment")
	a.Name = name
	a.Parent = parent
	return a
end

local function newArmIK(humanoid, name, upper, hand, target, pole)
	local ik = Instance.new("IKControl")
	ik.Name = name
	ik.Type = Enum.IKControlType.Position
	ik.ChainRoot = upper
	ik.EndEffector = hand
	ik.Target = target
	ik.Pole = pole
	ik.Weight = 1
	ik.SmoothTime = 0
	ik.Parent = humanoid
	return ik
end

local function destroyRig(character)
	local rig = rigs[character]
	if not rig then return end
	rigs[character] = nil
	for _, thing in ipairs(rig.Cleanup) do
		thing:Destroy()
	end
	if rig.Waist and rig.Waist.Parent then rig.Waist.C0 = rig.WaistC0 end
	if rig.Neck and rig.Neck.Parent then rig.Neck.C0 = rig.NeckC0 end
	if rig.Hips and rig.Hips.Parent then rig.Hips.C0 = rig.HipsC0 end
	if rig.Tool then
		for _, d in ipairs(rig.Tool:GetDescendants()) do
			if d:IsA("BasePart") then d.LocalTransparencyModifier = 0 end
		end
	end
end

local function createRig(character, tool)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	local upperTorso = character:FindFirstChild("UpperTorso")
	local parts = {
		RU = character:FindFirstChild("RightUpperArm"), RH = character:FindFirstChild("RightHand"),
		LU = character:FindFirstChild("LeftUpperArm"), LH = character:FindFirstChild("LeftHand"),
	}
	-- the pose needs an R15 body; R6 characters keep Roblox's default hold
	if not (humanoid and root and upperTorso and parts.RU and parts.RH) then return nil end
	local def = GameConfig.GetShovel(tool:GetAttribute("ShovelId"))
	if not def then return nil end

	-- the copy of the shovel we pose every frame
	local model = ShovelModels(def)
	local handle = model:FindFirstChild("Handle")
	local puppet = {}
	local bladePart
	local tipZ = 0
	for _, piece in ipairs(model:GetChildren()) do
		if piece:IsA("BasePart") and piece ~= handle then
			for _, c in ipairs(piece:GetChildren()) do
				if c:IsA("WeldConstraint") then c:Destroy() end
			end
			piece.Anchored = true
			piece.CanCollide = false
			piece.CanQuery = false
			piece.CanTouch = false
			-- crystal shovels: orbit parts spin around OrbitCenter (along the shaft)
			table.insert(puppet, {Part = piece, Rel = handle.CFrame:ToObjectSpace(piece.CFrame),
				Center = piece:GetAttribute("OrbitCenter"), Speed = piece:GetAttribute("OrbitSpeed")})
			if piece.Name == "Blade" or piece.Name == "DrillTip" then bladePart = piece end
			-- lowest point of the shovel along its shaft (used to keep the blade out of the ground)
			local rel = handle.CFrame:ToObjectSpace(piece.CFrame)
			local h = piece.Size / 2
			for _, corner in ipairs({Vector3.new(h.X, h.Y, h.Z), Vector3.new(-h.X, h.Y, h.Z), Vector3.new(h.X, -h.Y, h.Z), Vector3.new(-h.X, -h.Y, h.Z),
				Vector3.new(h.X, h.Y, -h.Z), Vector3.new(-h.X, h.Y, -h.Z), Vector3.new(h.X, -h.Y, -h.Z), Vector3.new(-h.X, -h.Y, -h.Z)}) do
				tipZ = math.min(tipZ, (rel * corner).Z)
			end
		end
	end
	local holder = Instance.new("Model")
	holder.Name = character.Name .. "_Shovel"
	for _, p in ipairs(puppet) do p.Part.Parent = holder end
	holder.Parent = puppetFolder
	model:Destroy()

	-- hide the real tool on this screen (it still does the digging)
	for _, d in ipairs(tool:GetDescendants()) do
		if d:IsA("BasePart") then d.LocalTransparencyModifier = 1 end
	end

	local rightTarget = newAttachment(root, "ShovelRightHand")
	-- pole keeps the elbow bending down and out, like a relaxed arm
	local rightPole = newAttachment(root, "ShovelRightElbow")
	rightPole.Position = Vector3.new(2.4, -1.4, 0.8)
	local rightIK = newArmIK(humanoid, "ShovelRightArm", parts.RU, parts.RH, rightTarget, rightPole)
	-- match the hand's rotation too, so the fist closes around the shaft
	rightIK.Type = Enum.IKControlType.Transform
	local gripAttachment = parts.RH:FindFirstChild("RightGripAttachment")
	-- the left hand holds the handle higher up (two-handed grip)
	local leftTarget = newAttachment(root, "ShovelLeftHand")
	local leftPole = newAttachment(root, "ShovelLeftElbow")
	leftPole.Position = Vector3.new(-2.2, -1.2, 0.6)
	local leftIK = parts.LU and parts.LH and newArmIK(humanoid, "ShovelLeftArm", parts.LU, parts.LH, leftTarget, leftPole)

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.IgnoreWater = true
	local ignore = {puppetFolder}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character then table.insert(ignore, plr.Character) end
	end
	rayParams.FilterDescendantsInstances = ignore

	-- a swoosh trail from one arm tip of the head to the other (on during the down-swing)
	local trail
	if bladePart then
		local reach = bladePart.Size.Y * 1.7
		local a0 = Instance.new("Attachment")
		a0.Position = bladePart.CFrame:PointToObjectSpace(bladePart.Position + Vector3.new(0, reach, 0))
		a0.Parent = bladePart
		local a1 = Instance.new("Attachment")
		a1.Position = bladePart.CFrame:PointToObjectSpace(bladePart.Position - Vector3.new(0, reach, 0))
		a1.Parent = bladePart
		local gem = holder:FindFirstChild("HeadGem")
		local glow = gem and gem.Color or Color3.new(1, 1, 1)
		trail = Instance.new("Trail")
		trail.Attachment0 = a0
		trail.Attachment1 = a1
		trail.Lifetime = 0.16
		trail.MinLength = 0.05
		trail.FaceCamera = true
		trail.LightEmission = 0.5
		-- the swoosh matches the pickaxe's trail style (sparks, electricity, fire or galaxy)
		local colorA, colorB = tool:GetAttribute("TrailColorA"), tool:GetAttribute("TrailColorB")
		if typeof(colorA) == "Color3" and typeof(colorB) == "Color3" then
			trail.Color = ColorSequence.new(colorA, colorB)
		else
			trail.Color = ColorSequence.new(Color3.new(1, 1, 1), glow)
		end
		trail.Transparency = NumberSequence.new(0.35, 1)
		trail.WidthScale = NumberSequence.new(1, 0.3)
		trail.Enabled = false
		trail.Parent = bladePart
	end

	local waist = upperTorso:FindFirstChild("Waist")
	local head = character:FindFirstChild("Head")
	local neck = head and head:FindFirstChild("Neck")
	local lowerTorso = character:FindFirstChild("LowerTorso")
	local hips = lowerTorso and lowerTorso:FindFirstChild("Root")
	local rig = {
		Tool = tool, Root = root, Puppet = puppet, Blade = bladePart or (puppet[#puppet] and puppet[#puppet].Part),
		HoldZ = (tool:GetAttribute("RightHoldZ") or tool:GetAttribute("TopHoldZ") or 1.1) - 0.12, -- right hand near the end
		LeftHoldZ = tool:GetAttribute("LeftHoldZ") or 0.4, -- left hand higher up the handle
		TipZ = tipZ,
		RightTarget = rightTarget,
		LeftTarget = leftIK and leftTarget or nil,
		Waist = waist and waist:IsA("Motor6D") and waist or nil,
		WaistC0 = waist and waist:IsA("Motor6D") and waist.C0 or nil,
		Neck = neck and neck:IsA("Motor6D") and neck or nil,
		NeckC0 = neck and neck:IsA("Motor6D") and neck.C0 or nil,
		Hips = hips and hips:IsA("Motor6D") and hips or nil,
		HipsC0 = hips and hips:IsA("Motor6D") and hips.C0 or nil,
		Humanoid = humanoid, Trail = trail, ImpactAt = nil, Smooth = nil,
		SwingStart = nil, SwingLength = 0.4, Struck = true, Flung = true,
		EquipStart = os.clock(), Caught = false, Landed = false,
		GripOffset = gripAttachment and gripAttachment.CFrame or CFrame.new(0, -0.15, 0) * CFrame.Angles(math.rad(-90), 0, 0),
		RayParams = rayParams,
		Cleanup = {holder, rightTarget, rightPole, rightIK, leftTarget, leftPole, leftIK or nil},
	}
	rigs[character] = rig
	return rig
end

-- throws a few little dirt clumps off the blade
local function tossDirt(position, color)
	for i = 1, 7 do
		-- chunky little clods with random sizes and spins (stylized, not round balls)
		local clump = Instance.new("Part")
		clump.Size = Vector3.new(0.3 + math.random() * 0.35, 0.22 + math.random() * 0.25, 0.3 + math.random() * 0.3)
		clump.CFrame = CFrame.Angles(math.random() * 6, math.random() * 6, math.random() * 6)
		clump.Color = color
		clump.Material = Enum.Material.SmoothPlastic
		clump.CanCollide = false
		clump.CanQuery = false
		clump.CanTouch = false
		clump.CastShadow = false
		clump.CFrame = CFrame.new(position + Vector3.new(math.random() - 0.5, 0, math.random() - 0.5) * 0.6) * clump.CFrame.Rotation
		clump.AssemblyAngularVelocity = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 20
		clump.AssemblyLinearVelocity = Vector3.new(math.random() * 12 - 6, 12 + math.random() * 10, math.random() * 12 - 6)
		clump.Parent = puppetFolder
		Debris:AddItem(clump, 1.1 + i * 0.05)
	end
end

-- the scooped dirt flying off the blade: chunky cubes thrown up and back over the shoulder,
-- tumbling, then shrinking away
local function flingDirt(root, position, color, count)
	for _ = 1, count do
		local clod = Instance.new("Part")
		local size = 0.45 + math.random() * 0.4
		clod.Size = Vector3.new(size, size * (0.8 + math.random() * 0.3), size)
		clod.Color = color:Lerp(Color3.new(math.random(), math.random() * 0.8, 0.2), 0.08):Lerp(Color3.new(0, 0, 0), math.random() * 0.15)
		clod.Material = Enum.Material.SmoothPlastic
		clod.CanCollide = false
		clod.CanQuery = false
		clod.CanTouch = false
		clod.CastShadow = false
		clod.CFrame = CFrame.new(position + Vector3.new(math.random() - 0.5, math.random() * 0.4, math.random() - 0.5) * 0.7)
			* CFrame.Angles(math.random() * 6, math.random() * 6, math.random() * 6)
		-- up and backward (+Z behind the player), drifting to the right
		clod.AssemblyLinearVelocity = root.CFrame:VectorToWorldSpace(Vector3.new(math.random() * 9 - 3, 24 + math.random() * 9, 7 + math.random() * 7))
		clod.AssemblyAngularVelocity = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 24
		clod.Parent = puppetFolder
		local life = 0.9 + math.random() * 0.3
		task.delay(life - 0.25, function()
			if clod.Parent then
				TweenService:Create(clod, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = Vector3.one * 0.05}):Play()
			end
		end)
		Debris:AddItem(clod, life)
	end
end

-- a quick burst of glowing sparkles (the equip flash)
local function sparkle(position, colorA, colorB, count, speed)
	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.Transparency = 1
	anchor.Size = Vector3.one
	anchor.CFrame = CFrame.new(position)
	anchor.Parent = puppetFolder
	local e = Instance.new("ParticleEmitter")
	e.Enabled = false
	e.Color = ColorSequence.new(colorA, colorB)
	e.LightEmission = 1
	e.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.45), NumberSequenceKeypoint.new(1, 0)})
	e.Lifetime = NumberRange.new(0.25, 0.5)
	e.Speed = NumberRange.new(speed * 0.5, speed)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Drag = 5
	e.RotSpeed = NumberRange.new(-300, 300)
	e.Parent = anchor
	e:Emit(count)
	Debris:AddItem(anchor, 0.8)
end

-- the moment the pickaxe bites the ground: a burst of dirt chunks, a puff of dust and a
-- ring of dust rolling out across the ground (plus camera shake for our own swings)
local impactShake -- set further down, once the camera shake exists
-- extra impact particles in the tool's style (see PickaxeModels TRAILS), and glowing sparks
-- in the deep layers (crystal sparkles in the crystal layer, embers in the magma core)
local STYLE_IMPACT = {
	Sparks = {Colors = {Color3.new(1, 1, 1), Color3.fromRGB(90, 235, 255)}, Count = 14, Speed = 18, Size = 0.14, Life = 0.35, Gravity = -40},
	Electric = {Colors = {Color3.new(1, 1, 1), Color3.fromRGB(120, 200, 255)}, Count = 18, Speed = 26, Size = 0.12, Life = 0.2, Gravity = 0},
	Ice = {Colors = {Color3.new(1, 1, 1), Color3.fromRGB(150, 225, 255)}, Count = 16, Speed = 14, Size = 0.3, Life = 0.6, Gravity = -50},
	Fire = {Colors = {Color3.fromRGB(255, 240, 150), Color3.fromRGB(255, 90, 20)}, Count = 18, Speed = 10, Size = 0.4, Life = 0.5, Gravity = 12},
	Galaxy = {Colors = {Color3.fromRGB(255, 150, 240), Color3.fromRGB(90, 110, 255)}, Count = 20, Speed = 8, Size = 0.3, Life = 0.9, Gravity = 0},
	Glitch = {Colors = {Color3.fromRGB(255, 60, 200), Color3.fromRGB(60, 255, 230)}, Count = 22, Speed = 20, Size = 0.28, Life = 0.18, Gravity = 0},
}
local LAYER_SPARKS = { -- by depth zone index (3 = crystal layer, 4 = magma core)
	[3] = {Colors = {Color3.new(1, 1, 1), Color3.fromRGB(120, 230, 255)}, Count = 12, Speed = 9, Size = 0.18, Life = 0.7, Gravity = -6},
	[4] = {Colors = {Color3.fromRGB(255, 220, 120), Color3.fromRGB(255, 70, 20)}, Count = 16, Speed = 12, Size = 0.2, Life = 0.8, Gravity = 10},
}
local function sparkBurst(anchor, spec)
	local e = Instance.new("ParticleEmitter")
	e.Enabled = false
	e.Color = ColorSequence.new(spec.Colors[1], spec.Colors[2])
	e.LightEmission = 1
	e.Size = NumberSequence.new(spec.Size, 0)
	e.Lifetime = NumberRange.new(spec.Life * 0.6, spec.Life)
	e.Speed = NumberRange.new(spec.Speed * 0.5, spec.Speed)
	e.SpreadAngle = Vector2.new(70, 70)
	e.EmissionDirection = Enum.NormalId.Top
	e.Acceleration = Vector3.new(0, spec.Gravity, 0)
	e.RotSpeed = NumberRange.new(-200, 200)
	e.Parent = anchor
	e:Emit(spec.Count)
end

local function impactBurst(position, color, toolStyle, zoneIndex)
	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.Transparency = 1
	anchor.Size = Vector3.one
	anchor.CFrame = CFrame.new(position)
	anchor.Parent = puppetFolder
	local chunks = Instance.new("ParticleEmitter")
	chunks.Enabled = false
	chunks.Color = ColorSequence.new(color, color:Lerp(Color3.new(0, 0, 0), 0.3))
	chunks.Size = NumberSequence.new(0.32, 0.1)
	chunks.Lifetime = NumberRange.new(0.35, 0.7)
	chunks.Speed = NumberRange.new(10, 20)
	chunks.SpreadAngle = Vector2.new(55, 55)
	chunks.EmissionDirection = Enum.NormalId.Top
	chunks.Acceleration = Vector3.new(0, -60, 0)
	chunks.Rotation = NumberRange.new(0, 360)
	chunks.RotSpeed = NumberRange.new(-300, 300)
	chunks.Parent = anchor
	chunks:Emit(16)
	local puff = Instance.new("ParticleEmitter")
	puff.Enabled = false
	puff.Color = ColorSequence.new(color:Lerp(Color3.new(1, 1, 1), 0.35))
	puff.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 2.6)})
	puff.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 1)})
	puff.Lifetime = NumberRange.new(0.5, 0.8)
	puff.Speed = NumberRange.new(2, 5)
	puff.SpreadAngle = Vector2.new(80, 80)
	puff.EmissionDirection = Enum.NormalId.Top
	puff.Drag = 4
	puff.Parent = anchor
	puff:Emit(8)
	if toolStyle and STYLE_IMPACT[toolStyle] then sparkBurst(anchor, STYLE_IMPACT[toolStyle]) end
	if zoneIndex and LAYER_SPARKS[zoneIndex] then sparkBurst(anchor, LAYER_SPARKS[zoneIndex]) end
	Debris:AddItem(anchor, 1.2)

	local ring = Instance.new("Part")
	ring.Shape = Enum.PartType.Cylinder
	ring.Anchored = true
	ring.CanCollide = false
	ring.CanQuery = false
	ring.CanTouch = false
	ring.CastShadow = false
	ring.Material = Enum.Material.SmoothPlastic
	ring.Color = color:Lerp(Color3.new(1, 1, 1), 0.3)
	ring.Transparency = 0.45
	ring.Size = Vector3.new(0.15, 1, 1)
	ring.CFrame = CFrame.new(position + Vector3.new(0, 0.15, 0)) * CFrame.Angles(0, 0, math.rad(90))
	ring.Parent = puppetFolder
	TweenService:Create(ring, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Vector3.new(0.15, 7, 7), Transparency = 1}):Play()
	Debris:AddItem(ring, 0.4)
end

local function dirtColorAt(position)
	local world = GameConfig.GetWorldAt(position)
	local _, zone = GameConfig.GetZoneAt(world, position.Y - 3)
	return zone and zone.Color or Color3.fromRGB(150, 110, 80)
end

local function startSwing(character, length)
	local rig = character and rigs[character]
	if not rig then return end
	rig.SwingStart = os.clock()
	rig.SwingLength = length
	rig.Struck = false
	rig.Flung = false
	if rig.EquipStart then -- digging cuts the equip flourish short
		rig.EquipStart = nil
		for _, p in ipairs(rig.Puppet) do p.Part.LocalTransparencyModifier = 0 end
	end
end

local function rigColors(rig)
	local a, b = rig.Tool:GetAttribute("TrailColorA"), rig.Tool:GetAttribute("TrailColorB")
	if typeof(a) == "Color3" and typeof(b) == "Color3" then return a, b end
	return Color3.new(1, 1, 1), Color3.fromRGB(255, 220, 110)
end

local function poseRig(character, rig, clock, dt)
	local moving = rig.Humanoid and math.clamp(rig.Humanoid.MoveDirection.Magnitude, 0, 1) or 0
	local target
	local trailOn = false
	local toss -- 0-1 while the pickaxe is in the air during the equip flip
	if rig.EquipStart and not rig.SwingStart then
		local t = (clock - rig.EquipStart) / EQUIP_LENGTH
		if t >= 1 then
			rig.EquipStart = nil
			target = idlePose(clock, moving)
		else
			target = samplePose(t, EQUIP)
			-- fade in at the start
			local fade = 1 - math.clamp(t / 0.12, 0, 1)
			for _, p in ipairs(rig.Puppet) do p.Part.LocalTransparencyModifier = fade end
			if t > TOSS_FROM and t < TOSS_TO then
				toss = (t - TOSS_FROM) / (TOSS_TO - TOSS_FROM)
				trailOn = true
			end
			if not rig.Caught and t >= TOSS_TO then
				rig.Caught = true
				if rig.Blade then
					local a, b = rigColors(rig)
					sparkle(rig.Blade.Position, a, b, 26, 14)
				end
				if character == player.Character and onEquipCatch then onEquipCatch() end
			end
			if not rig.Landed and t >= 0.66 then
				rig.Landed = true
				trailOn = true
				if rig.Blade then
					local a, b = rigColors(rig)
					sparkle(rig.Blade.Position, b, a, 12, 7)
				end
			end
			if t > 0.52 and t < 0.68 then trailOn = true end
		end
		if rig.EquipStart == nil then
			for _, p in ipairs(rig.Puppet) do p.Part.LocalTransparencyModifier = 0 end
		end
	elseif rig.SwingStart then
		-- hit-stop: time stands still for a moment right at the impact
		local elapsed = clock - rig.SwingStart
		local strikeAt = rig.SwingLength * STRIKE_TIME
		if elapsed > strikeAt then
			elapsed -= math.min(elapsed - strikeAt, HIT_STOP)
		end
		local t = elapsed / rig.SwingLength
		if t >= 1 then
			rig.SwingStart = nil
			target = idlePose(clock, moving)
		else
			target = samplePose(t)
			for _, window in ipairs(TRAILS) do
				if t > window[1] and t < window[2] then trailOn = true end
			end
			if not rig.Flung and t >= FLING_TIME then
				rig.Flung = true
				if rig.Blade then
					flingDirt(rig.Root, rig.Blade.Position, dirtColorAt(rig.Root.Position), character == player.Character and 6 or 3)
				end
			end
			if not rig.Struck and t >= STRIKE_TIME then
				rig.Struck = true
				rig.ImpactAt = clock
				if rig.Blade then
					local color = dirtColorAt(rig.Root.Position)
					local world = GameConfig.GetWorldAt(rig.Root.Position)
					local zoneIndex = GameConfig.GetZoneAt(world, rig.Root.Position.Y - 3)
					tossDirt(rig.Blade.Position, color)
					impactBurst(rig.Blade.Position, color, rig.Tool:GetAttribute("TrailStyle"), zoneIndex)
				end
				if character == player.Character and impactShake then
					impactShake()
				end
			end
		end
	else
		target = idlePose(clock, moving)
	end
	if rig.Trail then rig.Trail.Enabled = trailOn end

	-- impact wobble: the handle rings for a moment after the head bites the ground
	if rig.ImpactAt then
		local since = clock - rig.ImpactAt - HIT_STOP
		if since > 0 and since < 0.6 then
			local ring = math.exp(-WOBBLE.Decay * since) * math.sin(WOBBLE.Speed * since)
			target.Tilt += ring * WOBBLE.Degrees
			target.Hand += Vector3.new(0, ring * 0.06, 0)
		end
	end

	-- smoothing: every channel eases toward its target, so switching between idle and
	-- swinging (or starting a new swing mid-way) never snaps. Swings stay crisp.
	local smooth = rig.Smooth
	if not smooth then
		smooth = table.clone(target)
		rig.Smooth = smooth
	end
	local alpha = 1 - math.exp(-((rig.SwingStart or rig.EquipStart) and 45 or 12) * (dt or 1 / 60))
	smooth.Hand = smooth.Hand:Lerp(target.Hand, alpha)
	for _, c in ipairs(CHANNELS) do
		smooth[c] += ((target[c] or 0) - (smooth[c] or 0)) * alpha
	end
	local pose = smooth

	-- where the shovel goes (in root space): rotate the upright shovel by tilt and turn,
	-- then slide it along its shaft so the grip sits exactly in the hand
	local rotation = CFrame.Angles(0, math.rad(pose.Turn), 0) * CFrame.Angles(0, 0, math.rad(pose.Roll or 0))
		* CFrame.Angles(math.rad(pose.Tilt), 0, 0) * UPRIGHT
	local up = rotation.ZVector
	local hand = pose.Hand
	local origin = hand - up * rig.HoldZ
	local shovelCF = rig.Root.CFrame * CFrame.new(origin) * rotation

	-- keep the blade out of the ground: if its lowest point is below the surface under it,
	-- lift the shovel (and the hand holding it) just enough
	-- (the ray starts at hand height above the tip, which is always in open air, even in tunnels)
	local tip = (shovelCF * CFrame.new(0, 0, rig.TipZ)).Position
	local handY = (rig.Root.CFrame * hand).Y
	local startY = math.max(handY, tip.Y + 0.5)
	local hit = workspace:Raycast(Vector3.new(tip.X, startY, tip.Z), Vector3.new(0, -(startY - tip.Y) - 3, 0), rig.RayParams)
	if hit then
		local lift = (hit.Position.Y + 0.08) - tip.Y
		if lift > 0 then
			local liftLocal = rig.Root.CFrame:VectorToObjectSpace(Vector3.new(0, lift, 0))
			hand += liftLocal
			origin += liftLocal
			shovelCF = rig.Root.CFrame * CFrame.new(origin) * rotation
		end
	end

	-- the hand stays where the grip would be (reaching up to catch), the pickaxe flies:
	-- up in an arc above the hand, spinning end over end around the middle of its handle
	local handShovelCF = shovelCF
	if toss then
		local arc = 4 * TOSS_HEIGHT * toss * (1 - toss)
		local middle = rig.HoldZ * 0.5
		local spin = -easeOutSine(toss) * TOSS_SPINS * math.pi * 2
		shovelCF = CFrame.new(0, arc, 0) * shovelCF * CFrame.new(0, 0, middle) * CFrame.Angles(spin, 0, 0) * CFrame.new(0, 0, -middle)
	end

	local parts, cframes = {}, {}
	for i, p in ipairs(rig.Puppet) do
		parts[i] = p.Part
		local rel = p.Rel
		if p.Center and p.Speed then
			local pivot = CFrame.new(p.Center)
			rel = pivot * CFrame.Angles(0, 0, clock * p.Speed) * pivot:Inverse() * rel
		end
		cframes[i] = shovelCF * rel
	end
	workspace:BulkMoveTo(parts, cframes, Enum.BulkMoveMode.FireCFrameChanged)

	-- the hand goes exactly where a normal Roblox tool grip would put it on this shaft:
	-- handle = hand * gripAttachment * grip^-1, so hand = handle * grip * gripAttachment^-1
	local handCF = handShovelCF * CFrame.new(0, 0, rig.HoldZ) * rig.GripOffset:Inverse()
	rig.RightTarget.CFrame = rig.Root.CFrame:ToObjectSpace(handCF)
	if rig.LeftTarget then
		rig.LeftTarget.Position = rig.Root.CFrame:PointToObjectSpace((handShovelCF * CFrame.new(0, 0, rig.LeftHoldZ)).Position)
	end
	-- whole body: the torso bends and twists with the swing, the hips counter-turn a little,
	-- and the head follows the pickaxe (looks up at the top, down at the impact)
	if rig.Waist then
		rig.Waist.C0 = rig.WaistC0 * CFrame.Angles(math.rad(-pose.Lean), math.rad(pose.Twist), math.rad(pose.Bend))
	end
	if rig.Hips then
		rig.Hips.C0 = rig.HipsC0 * CFrame.Angles(0, math.rad(-pose.Twist * 0.35), 0)
	end
	if rig.Neck then
		rig.Neck.C0 = rig.NeckC0 * CFrame.Angles(math.rad(-pose.Look), math.rad(-pose.Twist * 0.4), 0)
	end
end

RunService.RenderStepped:Connect(function(dt)
	local clock = os.clock()
	-- find every character holding a shovel; build or tear down rigs to match
	for _, plr in ipairs(Players:GetPlayers()) do
		local character = plr.Character
		if character then
			local tool = character:FindFirstChildOfClass("Tool")
			if tool and not tool:GetAttribute("ShovelId") then tool = nil end
			local rig = rigs[character]
			if rig and rig.Tool ~= tool then
				destroyRig(character)
				rig = nil
			end
			if tool and not rig then
				rig = createRig(character, tool)
			end
		end
	end
	for character, rig in pairs(rigs) do
		if not character.Parent or not rig.Root.Parent then
			destroyRig(character)
		else
			poseRig(character, rig, clock, dt)
		end
	end
end)

swingFxRemote.OnClientEvent:Connect(function(otherPlayer, length)
	if typeof(otherPlayer) == "Instance" and otherPlayer:IsA("Player") and otherPlayer ~= player and typeof(length) == "number" then
		startSwing((otherPlayer :: Player).Character, math.clamp(length, 0.3, 1))
	end
end)

---------------------------------------------------------------------
-- DIG JUICE: screen shake, combo counter, sounds, bounce feedback
---------------------------------------------------------------------
local digHitRemote = remotes:WaitForChild("DigHit")

local Audio = require(ReplicatedStorage:WaitForChild("Audio"))


-- short, punchy camera shake (strength in studs)
local shakeUntil, shakeStrength = 0, 0
local function shake(strength, duration)
	shakeStrength = math.max(shakeStrength, strength)
	shakeUntil = math.max(shakeUntil, os.clock() + duration)
end
impactShake = function()
	shake(0.16, 0.1) -- a crisp little jolt right on the strike
end
onEquipCatch = function()
	shake(0.1, 0.08)
	Audio.sfx("Click")
end
RunService:BindToRenderStep("DigShake", Enum.RenderPriority.Camera.Value + 1, function()
	local left = shakeUntil - os.clock()
	if left <= 0 then
		shakeStrength = 0
		return
	end
	local s = shakeStrength * math.clamp(left / 0.15, 0, 1)
	camera.CFrame = camera.CFrame * CFrame.new((math.random() - 0.5) * s, (math.random() - 0.5) * s, 0)
		* CFrame.Angles(0, 0, math.rad((math.random() - 0.5) * s * 6))
end)

-- combo counter: pops up next to the hotbar while you keep digging
local comboLabel = UIKit.label(gui, "", {
	Size = UDim2.fromOffset(300, 44), Position = UDim2.new(0.5, 60, 1, -250), AnchorPoint = Vector2.new(0, 0),
	Align = "Left", Color = C.Sun, Stroke = 3.5, MaxText = 34,
})
comboLabel.Rotation = -6
comboLabel.Visible = false
local comboToken = 0
local COMBO_COLORS = {C.White, C.Sun, C.Sun, C.Mint, C.Mint, C.Sky, C.Sky, C.Lilac, C.Coral, C.Coral}

digHitRemote.OnClientEvent:Connect(function(info)
	if typeof(info) ~= "table" then return end
	if info.Bounced then
		shake(0.35, 0.18)
		Audio.sfx("Clang")
		comboLabel.Visible = false
		return
	end
	local combo = tonumber(info.Combo) or 1
	shake(0.05 + combo * 0.01, 0.1) -- the strike already shook; big combos shake a bit more
	Audio.sfx("Dig") -- rate-limited (max ~4 a second) with a random 0.95-1.05 pitch
	if typeof(info.Position) == "Vector3" and typeof(info.Color) == "Color3" then
		tossDirt(info.Position + Vector3.new(0, 1.5, 0), info.Color)
	end
	if combo >= 2 then
		comboToken += 1
		local myToken = comboToken
		comboLabel.Text = "COMBO x" .. combo .. "  +" .. (combo - 1) * 4 .. "% luck"
		comboLabel.TextColor3 = COMBO_COLORS[math.clamp(combo, 1, #COMBO_COLORS)]
		comboLabel.Visible = true
		UIKit.pop(comboLabel, 1.35)
		Audio.sfx("Combo", 0.9 + math.min(combo, 10) * 0.03)
		task.delay(1.5, function()
			if comboToken == myToken then comboLabel.Visible = false end
		end)
	end
end)

---------------------------------------------------------------------
-- SWINGING: click to dig, or hold the button to keep digging
---------------------------------------------------------------------
local lastSwing = 0
local holding = false

local function trySwing(def)
	local now = os.clock()
	-- world events and boosts (Gold Rush, Sugar Rush, Glitch Surge...) make swings faster
	local cooldown = def.Cooldown * (player:GetAttribute("DigSpeedMult") or 1)
	if now - lastSwing < cooldown then return end
	lastSwing = now

	local length = math.clamp(cooldown, 0.3, 0.5) -- overhead two-handed swing
	startSwing(player.Character, length)

	-- the dig happens exactly when the blade hits the ground
	local target = mouse.Hit and mouse.Hit.Position
	task.delay(length * STRIKE_TIME, function()
		swingRemote:FireServer(target, length)
	end)
end

local function onToolEquipped(tool)
	local def = GameConfig.GetShovel(tool:GetAttribute("ShovelId")) or GameConfig.Shovels[1]
	equippedDef = def
	depthPanel.Visible = true

	local activatedConn = tool.Activated:Connect(function()
		holding = true
		trySwing(def)
	end)
	local deactivatedConn = tool.Deactivated:Connect(function()
		holding = false
	end)
	-- while the button is held, dig again as soon as the shovel is ready
	local holdConn = RunService.Heartbeat:Connect(function()
		if holding and tool.Parent == player.Character then
			trySwing(def)
		end
	end)

	tool.Unequipped:Once(function()
		holding = false
		activatedConn:Disconnect()
		deactivatedConn:Disconnect()
		holdConn:Disconnect()
		if equippedDef == def then equippedDef = nil end
	end)
end

local function watchCharacter(character)
	character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") and child:GetAttribute("ShovelId") then
			onToolEquipped(child)
		end
	end)
end

player.CharacterAdded:Connect(watchCharacter)
if player.Character then
	watchCharacter(player.Character)
end

---------------------------------------------------------------------
-- SHOVEL SHOP WINDOW
---------------------------------------------------------------------
local window, content = UIKit.window(gui, "PICKAXE SHOP", UDim2.fromOffset(780, 580), C.Violet, "⛏️")

local moneyTag = UIKit.panel(content, {Size = UDim2.fromOffset(180, 38), Position = UDim2.new(1, 0, 0, 0), AnchorPoint = Vector2.new(1, 0), Color = C.Money, Radius = 19})
local moneyLabel = UIKit.label(moneyTag, "", {Size = UDim2.new(1, -24, 0.72, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2.5, StrokeColor = UIKit.shadeColor(C.Money, 0.6), MaxText = 24})
local worldLabel = UIKit.label(content, "", {Size = UDim2.new(1, -210, 0, 28), Position = UDim2.fromOffset(4, 5), Align = "Left", Color = C.Violet, Stroke = 0, MaxText = 24})

local listHolder = Instance.new("Frame")
listHolder.BackgroundTransparency = 1
listHolder.Size = UDim2.new(1, 0, 1, -48)
listHolder.Position = UDim2.fromOffset(0, 46)
listHolder.Parent = content
local list = UIKit.list(listHolder, 10)

local shopWorld = GameConfig.Worlds[1] -- which world's shop is open
local cards = {} -- [shovelId] = button

-- the best value of each stat in this world, so the bars fill relative to the top shovel
local function maxStat(world, key)
	local m = 0
	for _, def in ipairs(world.Shovels) do m = math.max(m, def[key]) end
	return m
end

local BUTTON_W = 116 -- the buy / equip button on each shop card

local function buildCards(world)
	for _, child in ipairs(list:GetChildren()) do
		if child:IsA("GuiObject") then child:Destroy() end
	end
	cards = {}
	worldLabel.Text = "🌍  " .. world.Name
	local maxFind, maxLuck, maxPower = maxStat(world, "FindChance"), maxStat(world, "Luck"), maxStat(world, "Power")
	local minCooldown = math.huge
	for _, def in ipairs(world.Shovels) do minCooldown = math.min(minCooldown, def.Cooldown) end
	local starterCooldown = world.Shovels[1].Cooldown
	local maxSpeed = starterCooldown / minCooldown

	for i, def in ipairs(world.Shovels) do
		local zone = world.Zones[def.MaxZone]
		local card = UIKit.panel(list, {Size = UDim2.new(1, -6, 0, 132), Color = C.White, Radius = 20, ShadeAmount = 0.06})
		card.LayoutOrder = i
		-- icon on a colored plate (plate color = the deepest zone it reaches)
		local plate = UIKit.panel(card, {Size = UDim2.fromOffset(108, 108), Position = UDim2.new(0, 12, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Color = zone.Color, Radius = 18, ShadeAmount = 0.2})
		UIKit.shovelIcon(plate, def, {Size = UDim2.fromScale(1, 1)})
		-- middle column: name, depth badge, description (sized to the column so nothing overlaps)
		UIKit.label(card, def.Name, {Size = UDim2.new(0.5, -140, 0, 26), Position = UDim2.fromOffset(134, 10), Align = "Left", Color = C.Ink, Stroke = 0, MaxText = 24})
		local zoneTag = UIKit.panel(card, {Size = UDim2.new(0.5, -140, 0, 24), Position = UDim2.fromOffset(134, 40), Color = zone.Color, Radius = 12})
		UIKit.label(zoneTag, "⬇ " .. -zone.Bottom .. "m  •  " .. string.upper(zone.Name), {Size = UDim2.new(1, -14, 0.72, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2, StrokeColor = C.Ink, MaxText = 15})
		UIKit.label(card, def.Description, {Size = UDim2.new(0.5, -140, 0, 52), Position = UDim2.fromOffset(134, 70), Align = "Left", VAlign = "Top", Color = C.Grey, Stroke = 0, Font = UIKit.BodyFont, TextSize = 13})

		-- right column: stat bars. Speed is shown as a multiplier of the starter pickaxe (1.5x = 50% faster swings)
		local statsBox = Instance.new("Frame")
		statsBox.BackgroundTransparency = 1
		-- fills the space between the middle column and the button, with a gap before the button
		statsBox.Size = UDim2.new(0.5, -(BUTTON_W + 44), 0, 90)
		statsBox.Position = UDim2.new(0.5, 0, 0.5, -45)
		statsBox.Parent = card
		local speed = starterCooldown / def.Cooldown
		UIKit.statBar(statsBox, "Power", def.Power / maxPower, tostring(def.Power), C.Coral, {Size = UDim2.new(1, 0, 0, 19), Position = UDim2.fromOffset(0, 0)})
		UIKit.statBar(statsBox, "Find", def.FindChance / maxFind, math.floor(def.FindChance * 1000 + 0.5) / 10 .. "%", C.Mint, {Size = UDim2.new(1, 0, 0, 19), Position = UDim2.fromOffset(0, 23)})
		UIKit.statBar(statsBox, "Luck", def.Luck / maxLuck, "x" .. def.Luck, C.Sun, {Size = UDim2.new(1, 0, 0, 19), Position = UDim2.fromOffset(0, 46)})
		UIKit.statBar(statsBox, "Speed", speed / maxSpeed, string.format("%.1fx", speed), C.Sky, {Size = UDim2.new(1, 0, 0, 19), Position = UDim2.fromOffset(0, 69)})

		local b = UIKit.button(card, "", {Size = UDim2.fromOffset(BUTTON_W, 54), Position = UDim2.new(1, -14, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5)})
		cards[def.Id] = b
		b.MouseButton1Click:Connect(function()
			local owned = string.split(player:GetAttribute("OwnedShovels") or "", ",")
			if table.find(owned, def.Id) then
				equipShovelRemote:FireServer(def.Id)
			else
				buyShovelRemote:FireServer(def.Id)
			end
		end)
	end
end

local function refreshShop()
	local money = player:GetAttribute("Money") or 0
	local owned = string.split(player:GetAttribute("OwnedShovels") or "", ",")
	local equipped = player:GetAttribute("EquippedShovel")
	moneyLabel.Text = ArtifactData.FormatMoney(money)
	for _, def in ipairs(shopWorld.Shovels) do
		local b = cards[def.Id]
		if b then
			if def.Id == equipped then
				UIKit.setButton(b, "EQUIPPED", C.Lilac)
			elseif table.find(owned, def.Id) then
				UIKit.setButton(b, "EQUIP", C.Sky)
			else
				UIKit.setButton(b, def.Price <= 0 and "FREE" or ArtifactData.FormatMoney(def.Price), money >= def.Price and C.Mint or C.Coral)
			end
		end
	end
end

for _, attribute in ipairs({"Money", "OwnedShovels", "EquippedShovel"}) do
	player:GetAttributeChangedSignal(attribute):Connect(function()
		if window.Visible then refreshShop() end
	end)
end

local function openShop(worldId)
	local world = GameConfig.GetWorld(worldId) or GameConfig.Worlds[1]
	if world ~= shopWorld or next(cards) == nil then
		shopWorld = world
		buildCards(world)
	end
	refreshShop()
	UIKit.open(window)
end
openShopRemote.OnClientEvent:Connect(openShop)
-- the SHOP button on the HUD opens the shop of the world you're in, from anywhere
require(ReplicatedStorage:WaitForChild("UIBus")).On("Shop", function()
	if window.Visible then
		window.Visible = false
	else
		openShop(player:GetAttribute("CurrentWorld") or 1)
	end
end)

shopMessageRemote.OnClientEvent:Connect(function(message, success)
	showHint(message, success and C.Mint or C.Coral)
end)
