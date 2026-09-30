-- WorldClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The World Map opened at any World Gate: a card per world showing whether it's unlocked,
-- its price, and a button to unlock it or travel there.
-- Also changes the sky and lighting to each world's mood when you travel there.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local WorldGimmicks = require(ReplicatedStorage:WaitForChild("WorldGimmicks"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local openWorldMapRemote = remotes:WaitForChild("OpenWorldMap")
local buyWorldRemote = remotes:WaitForChild("BuyWorld")
local travelRemote = remotes:WaitForChild("TravelToWorld")

local player = Players.LocalPlayer
local gui = UIKit.screen(player, "WorldMapGui", 3)

local window, content = UIKit.window(gui, "WORLD MAP", UDim2.fromOffset(680, 560), C.Sky, "🌍")

local moneyTag = UIKit.panel(content, {Size = UDim2.fromOffset(180, 38), Position = UDim2.new(1, 0, 0, 0), AnchorPoint = Vector2.new(1, 0), Color = C.Money, Radius = 19})
local moneyLabel = UIKit.label(moneyTag, "", {Size = UDim2.new(1, -24, 0.72, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2.5, StrokeColor = UIKit.shadeColor(C.Money, 0.6), MaxText = 24})
UIKit.label(content, "Unlock new dig sites with cash!", {Size = UDim2.new(1, -210, 0, 28), Position = UDim2.fromOffset(4, 5), Align = "Left", Color = C.Violet, Stroke = 0, MaxText = 22})

local listHolder = Instance.new("Frame")
listHolder.BackgroundTransparency = 1
listHolder.Size = UDim2.new(1, 0, 1, -48)
listHolder.Position = UDim2.fromOffset(0, 46)
listHolder.Parent = content
local list = UIKit.list(listHolder, 10)

local PLANET_COLORS = {C.Mint, C.Sun, C.Coral, C.Sky, C.Lilac, C.Violet, C.Money, C.Coral, C.Sky}
local buttons = {} -- [worldId] = button

for _, world in ipairs(GameConfig.Worlds) do
	local planetColor = world.Look and world.Look.Main or PLANET_COLORS[world.Id] or C.Lilac
	local card = UIKit.panel(list, {Size = UDim2.new(1, -6, 0, 108), Color = world.Enabled and C.White or C.PanelTint, Radius = 20, Stroke = 3, StrokeColor = planetColor, ShadeAmount = 0.06})
	-- a soft wash of the world's color across the card (a little preview of its look)
	local wash = Instance.new("UIGradient")
	wash.Color = ColorSequence.new(planetColor:Lerp(Color3.new(1, 1, 1), 0.55), Color3.new(1, 1, 1))
	wash.Transparency = NumberSequence.new(0, 0)
	wash.Parent = card
	card.LayoutOrder = world.Id
	-- little planet badge with the world number
	local planet = UIKit.panel(card, {Size = UDim2.fromOffset(62, 62), Position = UDim2.new(0, 12, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Color = planetColor, Radius = 31, ShadeAmount = 0.25})
	UIKit.label(planet, tostring(world.Id), {Size = UDim2.fromScale(0.56, 0.56), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 3, StrokeColor = UIKit.shadeColor(planetColor, 0.6), MaxText = 30})
	UIKit.label(card, world.Name, {Size = UDim2.new(0.62, -90, 0, 28), Position = UDim2.fromOffset(88, 10), Align = "Left", Color = C.Ink, Stroke = 0, MaxText = 24})
	-- the world's unique mechanic, as a tag
	local info = WorldGimmicks[world.Id]
	if info then
		local tag = UIKit.panel(card, {Size = UDim2.fromOffset(170, 24), Position = UDim2.fromOffset(88, 40), Color = C.Ink, Radius = 12, Stroke = 2, StrokeColor = planetColor, Shade = false})
		UIKit.label(tag, info.Icon .. " " .. string.upper(info.Tag), {Size = UDim2.new(1, -14, 0.72, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.White, Stroke = 0, MaxText = 14})
	end
	local sub = world.Enabled and (world.Tagline or (#world.Shovels .. " pickaxes  •  digs down to " .. -world.Zones[#world.Zones].Bottom .. "m  •  your museum is here"))
		or "Still being excavated... coming soon!"
	UIKit.label(card, sub, {Size = UDim2.new(0.62, -90, 0, 34), Position = UDim2.fromOffset(88, 70), Align = "Left", VAlign = "Top", Color = C.Grey, Stroke = 0, Font = UIKit.BodyFont, TextSize = 13})

	local b = UIKit.button(card, "", {Size = UDim2.new(0.3, 0, 0, 54), Position = UDim2.new(1, -14, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), MaxText = 20})
	buttons[world.Id] = b
	b.MouseButton1Click:Connect(function()
		local unlocked = table.find(string.split(player:GetAttribute("UnlockedWorlds") or "1", ","), tostring(world.Id))
		if not world.Enabled then
			return
		elseif unlocked then
			if player:GetAttribute("CurrentWorld") ~= world.Id then
				travelRemote:FireServer(world.Id)
				window.Visible = false
			end
		else
			buyWorldRemote:FireServer(world.Id)
		end
	end)
end

local function refresh()
	local money = player:GetAttribute("Money") or 0
	local unlocked = string.split(player:GetAttribute("UnlockedWorlds") or "1", ",")
	local current = player:GetAttribute("CurrentWorld") or 1
	moneyLabel.Text = ArtifactData.FormatMoney(money)
	for _, world in ipairs(GameConfig.Worlds) do
		local b = buttons[world.Id]
		if not world.Enabled then
			UIKit.setButton(b, "SOON • " .. ArtifactData.FormatMoney(world.Price), C.Grey)
		elseif world.Id == current then
			UIKit.setButton(b, "📍 YOU ARE HERE", C.Lilac)
		elseif table.find(unlocked, tostring(world.Id)) then
			UIKit.setButton(b, "TRAVEL", C.Sky)
		else
			UIKit.setButton(b, "🔒 " .. ArtifactData.FormatMoney(world.Price), money >= world.Price and C.Mint or C.Coral)
		end
	end
end

for _, attribute in ipairs({"Money", "UnlockedWorlds", "CurrentWorld"}) do
	player:GetAttributeChangedSignal(attribute):Connect(function()
		if window.Visible then refresh() end
	end)
end

openWorldMapRemote.OnClientEvent:Connect(function()
	refresh()
	UIKit.open(window)
end)
-- the WORLDS button on the HUD opens the map from anywhere
require(ReplicatedStorage:WaitForChild("UIBus")).On("Teleport", function()
	if window.Visible then
		window.Visible = false
	else
		refresh()
		UIKit.open(window)
	end
end)

---------------------------------------------------------------------
-- WORLD SKIES: each world has its own time of day, haze and color grade (WorldsData.Sky).
-- World 1's look (set by MapStyle on the server) is remembered and restored when you return.
---------------------------------------------------------------------
local home -- World 1's lighting, captured the first time you leave it

-- the one bloom and sun rays effect the lighting uses (made here if the place has none)
local function effect(className)
	local found = Lighting:FindFirstChildOfClass(className)
	if not found then
		found = Instance.new(className)
		found.Intensity = 0
		found.Parent = Lighting
	end
	return found
end

local function capture()
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	local grade = Lighting:FindFirstChild("Cartoon2050Grade")
	local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds")
	local bloom, rays = effect("BloomEffect"), effect("SunRaysEffect")
	return {
		ClockTime = Lighting.ClockTime, Latitude = Lighting.GeographicLatitude, Brightness = Lighting.Brightness,
		Exposure = Lighting.ExposureCompensation, Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
		DiffuseScale = Lighting.EnvironmentDiffuseScale, SpecularScale = Lighting.EnvironmentSpecularScale,
		ShadowSoftness = Lighting.ShadowSoftness,
		Tint = grade and grade.TintColor or Color3.new(1, 1, 1),
		Saturation = grade and grade.Saturation or 0, Contrast = grade and grade.Contrast or 0,
		Fog = atmosphere and atmosphere.Color, Decay = atmosphere and atmosphere.Decay, Density = atmosphere and atmosphere.Density,
		Offset = atmosphere and atmosphere.Offset, Haze = atmosphere and atmosphere.Haze, Glare = atmosphere and atmosphere.Glare,
		Bloom = {bloom.Intensity, bloom.Size, bloom.Threshold}, SunRays = {rays.Intensity, rays.Spread},
		Clouds = clouds and clouds.Cover,
	}
end

-- Realistic defaults for worlds 2-9 (each world's Sky overrides what it needs):
-- stronger sun, full environment lighting and reflections, crisp shadows
local REALISM = {Brightness = 3, Exposure = 0, Latitude = 35, DiffuseScale = 1, SpecularScale = 1, ShadowSoftness = 0.15,
	Offset = 0.25, Haze = 1.5, Glare = 0.4, Saturation = 0.1, Contrast = 0.1, Bloom = {0.35, 24, 1.9}, SunRays = {0.1, 0.25}}

local function applySky(sky)
	local function get(key)
		if sky[key] ~= nil then return sky[key] end
		return REALISM[key]
	end
	local info = TweenInfo.new(1.2, Enum.EasingStyle.Sine)
	-- ClockTime and the sun angle jump (tweening would spin the sun through the whole day)
	Lighting.ClockTime = sky.ClockTime
	Lighting.GeographicLatitude = get("Latitude")
	Lighting.ShadowSoftness = get("ShadowSoftness")
	TweenService:Create(Lighting, info, {
		Ambient = sky.Ambient, OutdoorAmbient = sky.OutdoorAmbient, Brightness = get("Brightness"),
		ExposureCompensation = get("Exposure"), EnvironmentDiffuseScale = get("DiffuseScale"),
		EnvironmentSpecularScale = get("SpecularScale"),
	}):Play()
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere and sky.Fog then
		TweenService:Create(atmosphere, info, {Color = sky.Fog, Decay = sky.Decay, Density = sky.Density,
			Offset = get("Offset"), Haze = get("Haze"), Glare = get("Glare")}):Play()
	end
	local grade = Lighting:FindFirstChild("Cartoon2050Grade")
	if grade then
		TweenService:Create(grade, info, {TintColor = sky.Tint, Saturation = get("Saturation"), Contrast = get("Contrast")}):Play()
	end
	local bloom, rays = effect("BloomEffect"), effect("SunRaysEffect")
	local b, r = get("Bloom"), get("SunRays")
	TweenService:Create(bloom, info, {Intensity = b[1], Size = b[2], Threshold = b[3]}):Play()
	TweenService:Create(rays, info, {Intensity = r[1], Spread = r[2]}):Play()
	local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds")
	if clouds and sky.Clouds then
		clouds.Cover = sky.Clouds
	end
end

-- Only the island you're on is drawn: the other worlds' buildings and decorations are
-- taken out on this screen only (they're also ~9000 studs away, lost in the haze).
local worldsFolder = workspace:WaitForChild("Worlds", 30)
local worldModels = {} -- [model name] = model, even while it's hidden
local function showOnlyWorld(worldId)
	if not worldsFolder then return end
	for _, model in ipairs(worldsFolder:GetChildren()) do
		worldModels[model.Name] = model
	end
	for name, model in pairs(worldModels) do
		model.Parent = (name == "World" .. worldId) and worldsFolder or nil
	end
end
if worldsFolder then
	worldsFolder.ChildAdded:Connect(function(model)
		worldModels[model.Name] = model
		if model.Name ~= "World" .. (player:GetAttribute("CurrentWorld") or 1) then
			task.defer(function() model.Parent = nil end)
		end
	end)
end

local function onWorldChanged()
	showOnlyWorld(player:GetAttribute("CurrentWorld") or 1)
	local world = GameConfig.GetWorld(player:GetAttribute("CurrentWorld") or 1)
	if world and world.Sky then
		home = home or capture()
		applySky(world.Sky)
	elseif home then
		applySky(home)
	end
end
player:GetAttributeChangedSignal("CurrentWorld"):Connect(onWorldChanged)
onWorldChanged()
