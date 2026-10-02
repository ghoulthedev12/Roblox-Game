-- WorldGimmickClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The player's side of the world gimmicks (see ReplicatedStorage.WorldGimmicks):
--   * a short intro line when you arrive in a world with a gimmick
--   * low gravity in Galaxy Drift (gravity is simulated on your own screen)
--   * the air meter in Coral Circuit (refill at the AirVent parts or near the surface)
--   * snow and fog during a Blizzard, screen flicker during a Glitch Surge
--   * a small timer pill for the current world event and your personal boost

local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local WorldGimmicks = require(ReplicatedStorage:WaitForChild("WorldGimmicks"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local surfaceRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ReturnToSurface")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local DEFAULT_GRAVITY = workspace.Gravity
local AIR_SECONDS = 70   -- how long a full air meter lasts in the fumes
local VENT_RANGE = 14    -- how close to a vent refills your air

local gui = UIKit.screen(player, "WorldGimmickGui", 4)

-- intro card (top right): the world's twist on a colored badge, a big outlined title, the
-- explanation in bold readable text, and a bar along the bottom that runs down while it shows
local INTRO_SECONDS = 9
local intro = UIKit.panel(gui, {Size = UDim2.fromOffset(400, 100), Position = UDim2.new(1, -14, 0, 12), AnchorPoint = Vector2.new(1, 0),
	Color = C.Ink, Radius = 18, Stroke = 4, StrokeColor = C.Outline, ShadeAmount = 0.25})
intro.Visible = false
local introBadge = UIKit.panel(intro, {Size = UDim2.fromOffset(78, 78), Position = UDim2.new(0, 10, 0.5, -3), AnchorPoint = Vector2.new(0, 0.5),
	Color = C.Violet, Radius = 16, Stroke = 3, StrokeColor = C.Outline, ShadeAmount = 0.35})
local introIcon = UIKit.icon(introBadge, nil, {Size = UDim2.fromScale(1.05, 1.05), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 2})
local introTitle = UIKit.label(intro, "", {Size = UDim2.new(1, -110, 0, 30), Position = UDim2.fromOffset(100, 8), Align = "Left", Color = C.Sun, Stroke = 3, MaxText = 24})
local introText = UIKit.label(intro, "", {Size = UDim2.new(1, -112, 0, 46), Position = UDim2.fromOffset(100, 40), Align = "Left", VAlign = "Top",
	Color = C.White, Stroke = 0, Font = Enum.Font.GothamBold, TextSize = 14})
local introTimer = UIKit.panel(intro, {Size = UDim2.new(1, -24, 0, 6), Position = UDim2.new(0.5, 0, 1, -8), AnchorPoint = Vector2.new(0.5, 1),
	Color = C.Sun, Radius = 3, Stroke = false, Shade = false})

-- event + boost timers (top right, small pills under the intro)
local function pill(y, color, icon)
	local p = UIKit.panel(gui, {Size = UDim2.fromOffset(260, 34), Position = UDim2.new(1, -14, 0, y), AnchorPoint = Vector2.new(1, 0), Color = color, Radius = 12, Stroke = 3, StrokeColor = C.Outline})
	p.Visible = false
	UIKit.icon(p, icon, {Size = UDim2.fromOffset(40, 40), Position = UDim2.new(0, -10, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 2})
	local l = UIKit.label(p, "", {Size = UDim2.new(1, -44, 1, -10), Position = UDim2.new(0.5, 14, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.White, Stroke = 2.5, MaxText = 17})
	return p, l
end
local eventPill, eventLabel = pill(120, C.Violet, "Star")
local boostPill, boostLabel = pill(160, C.Coral, "Candy")

-- air meter (bottom right, above the flare button's spot)
local airPanel = UIKit.panel(gui, {Size = UDim2.fromOffset(250, 40), Position = UDim2.new(1, -16, 1, -196), AnchorPoint = Vector2.new(1, 1), Color = C.Ink, Radius = 20, Stroke = 2.5, StrokeColor = C.Sky})
airPanel.Visible = false
UIKit.icon(airPanel, "Bubble", {Size = UDim2.fromOffset(40, 40), Position = UDim2.new(0, -6, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 2})
UIKit.label(airPanel, "AIR", {Size = UDim2.fromOffset(40, 22), Position = UDim2.new(0, 34, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Align = "Left", Color = C.White, Stroke = 0, MaxText = 16})
local airTrack = UIKit.panel(airPanel, {Size = UDim2.new(1, -90, 0, 14), Position = UDim2.new(0, 76, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Color = C.PanelTint, Radius = 7, Stroke = false, Shade = false})
local airFill = UIKit.panel(airTrack, {Size = UDim2.fromScale(1, 1), Color = C.Sky, Radius = 7, Stroke = false, Shade = false})

-- blizzard snow around the camera, and a colour grade for fog / glitches
local snowPart = Instance.new("Part")
snowPart.Name = "BlizzardSnow"
snowPart.Anchored = true
snowPart.CanCollide = false
snowPart.CanQuery = false
snowPart.CanTouch = false
snowPart.Transparency = 1
snowPart.Size = Vector3.new(80, 1, 80)
local snow = Instance.new("ParticleEmitter")
snow.Shape = Enum.ParticleEmitterShape.Box
snow.Color = ColorSequence.new(Color3.new(1, 1, 1))
snow.Size = NumberSequence.new(0.35, 0.2)
snow.Lifetime = NumberRange.new(2, 3)
snow.Rate = 0
snow.Speed = NumberRange.new(20, 30)
snow.EmissionDirection = Enum.NormalId.Bottom
snow.SpreadAngle = Vector2.new(25, 25)
snow.Acceleration = Vector3.new(14, 0, 6)
snow.Parent = snowPart
local grade = Instance.new("ColorCorrectionEffect")
grade.Name = "WorldGimmickGrade"
grade.Enabled = false
grade.Parent = Lighting

local function currentWorldId()
	return player:GetAttribute("CurrentWorld") or 1
end

local function container(worldId)
	local worlds = workspace:FindFirstChild("Worlds")
	return worlds and worlds:FindFirstChild("World" .. worldId)
end

-- INTRO on arrival
local introToken = 0
local function showIntro(worldId)
	local info = WorldGimmicks[worldId]
	introToken += 1
	if not info then
		intro.Visible = false
		return
	end
	local myToken = introToken
	introTitle.Text = info.Title
	UIKit.setIcon(introIcon, info.Icon)
	introText.Text = info.Text
	local world = GameConfig.GetWorld(worldId)
	introBadge.BackgroundColor3 = world and world.Look and world.Look.Main or C.Violet
	intro.Visible = true
	UIKit.pop(intro, 0.7)
	introTimer.Size = UDim2.new(1, -24, 0, 6)
	game:GetService("TweenService"):Create(introTimer, TweenInfo.new(INTRO_SECONDS, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 6)}):Play()
	task.delay(INTRO_SECONDS, function()
		if introToken == myToken then intro.Visible = false end
	end)
end
player:GetAttributeChangedSignal("CurrentWorld"):Connect(function()
	showIntro(currentWorldId())
end)

local air = 1
RunService.RenderStepped:Connect(function(dt)
	local worldId = currentWorldId()
	local world = GameConfig.GetWorld(worldId) or GameConfig.Worlds[1]
	local folder = container(worldId)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local clock = os.clock()

	-- gravity
	local gravity = folder and folder:GetAttribute("Gravity")
	-- a gravity shift (WorldMechanicsClient) overrides it for a few seconds
	workspace.Gravity = player:GetAttribute("GravityOverride") or gravity or DEFAULT_GRAVITY

	-- events
	local event = folder and folder:GetAttribute("Event") or ""
	local eventName = player:GetAttribute("WorldEvent") or ""
	local left = player:GetAttribute("WorldEventLeft") or 0
	eventPill.Visible = eventName ~= ""
	if eventPill.Visible then eventLabel.Text = eventName .. "  ·  " .. left .. "s" end
	local boostName = player:GetAttribute("PersonalBoost") or ""
	boostPill.Visible = boostName ~= ""
	if boostPill.Visible then boostLabel.Text = boostName .. "  ·  " .. (player:GetAttribute("PersonalBoostLeft") or 0) .. "s" end

	-- blizzard: snow falling around the camera and a cold, foggy tint
	local blizzard = event == "BLIZZARD"
	snow.Rate = blizzard and 500 or 0
	if blizzard then
		snowPart.CFrame = CFrame.new(camera.CFrame.Position + Vector3.new(0, 25, 0))
		snowPart.Parent = workspace
	elseif snowPart.Parent and snow.Rate == 0 then
		snowPart.Parent = nil
	end
	local glitch = event == "GLITCH SURGE"
	if blizzard then
		grade.Enabled = true
		grade.TintColor = Color3.fromRGB(215, 230, 255)
		grade.Brightness = 0.12
		grade.Contrast = -0.25
		grade.Saturation = -0.3
	elseif glitch then
		-- flicker: every few frames the colors jump
		grade.Enabled = true
		local on = math.sin(clock * 37) > 0.6
		grade.TintColor = on and Color3.fromRGB(200, 150, 255) or Color3.fromRGB(255, 255, 255)
		grade.Saturation = on and 0.6 or 0.1
		grade.Contrast = on and 0.3 or 0
		grade.Brightness = 0
	else
		grade.Enabled = false
	end

	-- air meter
	local oxygenDepth = folder and folder:GetAttribute("OxygenDepth")
	if oxygenDepth and root then
		local depth = world.Origin.Y - (root.Position.Y - 3)
		local refilling = depth < oxygenDepth * 0.5
		if not refilling then
			for _, vent in ipairs(CollectionService:GetTagged("AirVent")) do
				if (vent.Position - root.Position).Magnitude < VENT_RANGE then
					refilling = true
					break
				end
			end
		end
		if refilling then
			air = math.min(1, air + dt * 0.5)
		elseif depth > oxygenDepth then
			air = math.max(0, air - dt / AIR_SECONDS)
		end
		airPanel.Visible = depth > oxygenDepth * 0.5 or air < 1
		airFill.Size = UDim2.fromScale(air, 1)
		airFill.BackgroundColor3 = air < 0.25 and C.Coral or (air < 0.5 and C.Sun or C.Sky)
		if air <= 0 then
			air = 1
			surfaceRemote:FireServer() -- out of air: pulled back up to the surface
		end
	else
		airPanel.Visible = false
		air = 1
	end
end)
