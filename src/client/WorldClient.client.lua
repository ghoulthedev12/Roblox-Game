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

local rgb = Color3.fromRGB
-- A grid of big world tiles (like the zone pickers in the top simulators): each tile is
-- painted in its world's color with a planet badge and number, the name in big outlined text,
-- the world's twist on a chip, and one big button (TRAVEL / price / YOU ARE HERE). Locked worlds
-- are dimmed with a padlock.
local window, content = UIKit.window(gui, "WORLD MAP", UDim2.fromOffset(820, 600), C.Sky, "World")

local moneyTag = UIKit.panel(content, {Size = UDim2.fromOffset(200, 40), Position = UDim2.new(1, 0, 0, 0), AnchorPoint = Vector2.new(1, 0), Color = C.Money, Radius = 12, Stroke = 3, StrokeColor = C.Outline})
UIKit.icon(moneyTag, "Cash", {Size = UDim2.fromOffset(46, 46), Position = UDim2.new(0, -10, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 2})
local moneyLabel = UIKit.label(moneyTag, "", {Size = UDim2.new(1, -46, 0.74, 0), Position = UDim2.new(0.5, 16, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 3, MaxText = 24})
local hintChip = UIKit.panel(content, {Size = UDim2.new(1, -224, 0, 40), Color = C.Ink, Radius = 12, Stroke = 3, StrokeColor = C.Outline})
UIKit.icon(hintChip, "Lock", {Size = UDim2.fromOffset(44, 44), Position = UDim2.new(0, -8, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 2})
UIKit.label(hintChip, "Unlock new dig sites with cash!", {Size = UDim2.new(1, -52, 0.68, 0), Position = UDim2.new(0, 44, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
	Align = "Left", Color = C.Sun, Stroke = 3, MaxText = 22})

local gridHolder = Instance.new("Frame")
gridHolder.BackgroundTransparency = 1
gridHolder.Size = UDim2.new(1, 0, 1, -52)
gridHolder.Position = UDim2.fromOffset(0, 52)
gridHolder.Parent = content
local list = Instance.new("ScrollingFrame")
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 8
list.ScrollBarImageColor3 = C.Lilac
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new()
list.Size = UDim2.fromScale(1, 1)
list.Parent = gridHolder
local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(1 / 3, -14, 0, 262) -- three across, whatever the window size
gridLayout.CellPadding = UDim2.fromOffset(12, 14)
local tileShape = Instance.new("UIAspectRatioConstraint")
tileShape.AspectRatio = 240 / 262
tileShape.Parent = gridLayout
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
gridLayout.Parent = list
local gridPad = Instance.new("UIPadding")
gridPad.PaddingTop = UDim.new(0, 8)
gridPad.PaddingBottom = UDim.new(0, 8)
gridPad.Parent = list

local PLANET_COLORS = {C.Mint, C.Sun, C.Coral, C.Sky, C.Lilac, C.Violet, C.Money, C.Coral, C.Sky}
local buttons = {} -- [worldId] = button
local tiles = {}   -- [worldId] = {Tile, Shade, Lock, Here}

for _, world in ipairs(GameConfig.Worlds) do
	local color = world.Look and world.Look.Main or PLANET_COLORS[world.Id] or C.Lilac
	local tile = UIKit.panel(list, {Color = color, Radius = 22, Stroke = 4, StrokeColor = C.Outline, ShadeAmount = 0.3})
	tile.LayoutOrder = world.Id
	-- a lighter band behind the planet
	local band = UIKit.panel(tile, {Size = UDim2.new(1, -16, 0.43, 0), Position = UDim2.new(0.5, 0, 0, 8), AnchorPoint = Vector2.new(0.5, 0),
		Color = color:Lerp(Color3.new(1, 1, 1), 0.5), Radius = 16, Stroke = false, ShadeAmount = 0.4})
	-- the planet: a glossy ball with a ring and the world's number
	local planet = UIKit.panel(band, {Size = UDim2.fromScale(0.8, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
		Color = color, Radius = 44, Stroke = 4, StrokeColor = C.Outline, ShadeAmount = 0.45})
	local ring = Instance.new("Frame")
	ring.BackgroundTransparency = 1
	ring.Size = UDim2.new(1.5, 0, 0.28, 0)
	ring.Position = UDim2.fromScale(0.5, 0.56)
	ring.AnchorPoint = Vector2.new(0.5, 0.5)
	ring.Rotation = -14
	ring.Parent = planet
	UIKit.corner(ring, 999)
	UIKit.outline(ring, 4, color:Lerp(Color3.new(1, 1, 1), 0.65))
	local number = UIKit.label(planet, tostring(world.Id), {Size = UDim2.fromScale(0.7, 0.7), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
		Stroke = 4, MaxText = 52})
	number.ZIndex = 3
	local planetShape = Instance.new("UIAspectRatioConstraint")
	planetShape.Parent = planet
	UIKit.label(tile, world.Name, {Size = UDim2.new(1, -20, 0.13, 0), Position = UDim2.new(0.5, 0, 0.47, 0), AnchorPoint = Vector2.new(0.5, 0), Stroke = 3.5, MaxText = 26})
	-- the world's twist on a dark chip
	local info = WorldGimmicks[world.Id]
	if info then
		local tag = UIKit.panel(tile, {Size = UDim2.new(1, -40, 0.115, 0), Position = UDim2.new(0.5, 10, 0.62, 0), AnchorPoint = Vector2.new(0.5, 0),
			Color = C.Ink, Radius = 15, Stroke = 2.5, StrokeColor = C.Outline})
		UIKit.icon(tag, info.Icon, {Size = UDim2.fromOffset(40, 40), Position = UDim2.new(0, -22, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 2})
		UIKit.label(tag, string.upper(info.Tag), {Size = UDim2.new(1, -36, 0.72, 0), Position = UDim2.new(0.5, 8, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
			Color = C.Sun, Stroke = 2.5, MaxText = 16})
	end
	local b = UIKit.button(tile, "", {Icon = "World", Size = UDim2.new(1, -20, 0.2, 0), Position = UDim2.new(0.5, 0, 1, -10), AnchorPoint = Vector2.new(0.5, 1), MaxText = 22})
	buttons[world.Id] = b
	-- locked: the planet is covered by a dark veil with a padlock
	local veil = UIKit.panel(band, {Size = UDim2.fromScale(1, 1), Color = C.Outline, Radius = 16, Stroke = false, Shade = false})
	veil.BackgroundTransparency = 0.45
	veil.ZIndex = 4
	local lock = UIKit.icon(veil, "Lock", {Size = UDim2.fromScale(0.6, 0.6), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 5})
	local lockShape = Instance.new("UIAspectRatioConstraint")
	lockShape.Parent = lock
	-- you are here: a pin on the planet
	local here = UIKit.icon(band, "Pin", {Size = UDim2.fromScale(0.45, 0.45), Position = UDim2.new(1, -6, 0, 4), AnchorPoint = Vector2.new(1, 0), ZIndex = 5})
	local hereShape = Instance.new("UIAspectRatioConstraint")
	hereShape.Parent = here
	tiles[world.Id] = {Tile = tile, Veil = veil, Here = here, Lock = lock}
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
		local t = tiles[world.Id]
		local isUnlocked = table.find(unlocked, tostring(world.Id)) ~= nil
		t.Veil.Visible = not isUnlocked
		t.Here.Visible = world.Id == current
		if not world.Enabled then
			UIKit.setButton(b, "SOON", C.Grey, "Lock")
		elseif world.Id == current then
			UIKit.setButton(b, "YOU ARE HERE", C.Lilac, "Pin")
		elseif isUnlocked then
			UIKit.setButton(b, "TRAVEL", C.Sky, "World")
		else
			UIKit.setButton(b, ArtifactData.FormatMoney(world.Price), money >= world.Price and C.Mint or C.Coral, money >= world.Price and "Cash" or "Lock")
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
