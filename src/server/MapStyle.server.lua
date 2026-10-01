-- MapStyle (Script in ServerScriptService)
-- Gives the whole map the cartoony 2050 look when the server starts:
-- builds the compact main island and its skyline (MainIsland), restyles the dig site, brightens the ground and the sky, and sets
-- calm, clean lighting (soft shadows, very little bloom, glow only on small accents).

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local MainIsland = require(script.Parent:WaitForChild("MainIsland"))
local DigSiteStyle = require(script.Parent:WaitForChild("DigSiteStyle"))
local Architecture = require(script.Parent:WaitForChild("Architecture"))
local WorldOneDecor = require(script.Parent:WaitForChild("WorldOneDecor"))

-- Set to false to keep the place's own sky and time of day (the calm lighting still applies)
local SUNNY_SKY = true

---------------------------------------------------------------------
-- GROUND: World 1 is now a compact floating island (MainIsland) instead of the old sprawling
-- city on big baseplates, so those are removed and the island is built in their place.
---------------------------------------------------------------------
for _, part in ipairs(workspace:GetChildren()) do
	if part:IsA("BasePart") and part.Name:find("^Baseplate") then
		part:Destroy()
	end
end
local oldCity = workspace:FindFirstChild("City")
if oldCity then oldCity:Destroy() end
local spawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")
if spawnLocation then
	spawnLocation.Material = Enum.Material.SmoothPlastic
	spawnLocation.Color = Color3.fromRGB(178, 158, 255)
end

-- Terrain colors: bright cartoon grass on top, soft stone walls, warm dig layers, plus the
-- ground materials of worlds 2-9 (see WorldsData.TerrainColors)
local terrain = workspace.Terrain
for materialName, color in pairs(GameConfig.TerrainColors) do
	terrain:SetMaterialColor(Enum.Material[materialName], color)
end

---------------------------------------------------------------------
-- MAIN ISLAND + DIG SITE
---------------------------------------------------------------------
MainIsland.build()
WorldOneDecor.build() -- stone plaza details, gardens, the excavation work area, pit shoring
workspace:SetAttribute("MainIslandReady", true) -- DigManager fills the pit after this
local digSite = workspace:FindFirstChild("DigSite")
if digSite then
	DigSiteStyle(digSite, GameConfig.Worlds[1])
end

---------------------------------------------------------------------
-- SKY: clear afternoon with soft shadows and fluffy clouds
---------------------------------------------------------------------
if SUNNY_SKY then
	Lighting.ClockTime = 14.5
	Lighting.GeographicLatitude = 35

	-- the place's night skybox doesn't fit a sunny day; Roblox's default sky does
	local sky = Lighting:FindFirstChildOfClass("Sky")
	if sky then sky:Destroy() end

	local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds") or Instance.new("Clouds")
	clouds.Cover = 0.5
	clouds.Density = 0.6
	clouds.Color = Color3.fromRGB(250, 250, 255)
	clouds.Parent = workspace.Terrain
end

---------------------------------------------------------------------
-- CALM LIGHTING: clean daylight, real shadows, almost no bloom or haze
---------------------------------------------------------------------
Lighting.Brightness = 2
Lighting.ExposureCompensation = -0.1
Lighting.Ambient = Color3.fromRGB(92, 92, 108)          -- shade indoors / under roofs
Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 144) -- shade outdoors: keeps shadows readable
Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
Lighting.EnvironmentDiffuseScale = 0.4
Lighting.EnvironmentSpecularScale = 0.15 -- less mirror-like shine on everything
Lighting.GlobalShadows = true
Lighting.ShadowSoftness = 0.3

local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atmosphere.Density = 0.22
atmosphere.Offset = 0.1
atmosphere.Color = Color3.fromRGB(200, 210, 235)
atmosphere.Decay = Color3.fromRGB(120, 132, 170)
atmosphere.Glare = 0
atmosphere.Haze = 0.4
atmosphere.Parent = Lighting

-- one gentle bloom only (the place had two stacked on top of each other)
local keptBloom = false
for _, effect in ipairs(Lighting:GetChildren()) do
	if effect:IsA("BloomEffect") then
		if keptBloom then
			effect:Destroy()
		else
			keptBloom = true
			effect.Enabled = true
			effect.Intensity = 0.12
			effect.Size = 16
			effect.Threshold = 2.4 -- only the brightest pixels bloom
		end
	elseif effect:IsA("SunRaysEffect") then
		effect.Intensity = 0.02
		effect.Spread = 0.3
	elseif effect:IsA("DepthOfFieldEffect") then
		effect.Enabled = false -- keeps the cartoon look crisp
	end
end
local grade = Lighting:FindFirstChild("Cartoon2050Grade") or Instance.new("ColorCorrectionEffect")
grade.Name = "Cartoon2050Grade"
grade.Saturation = 0.05
grade.Contrast = 0.06
grade.Brightness = 0
grade.TintColor = Color3.fromRGB(255, 255, 255)
grade.Parent = Lighting

-- Tone down glowing parts and lights everywhere. Runs again after a few seconds so it
-- also catches the Shovel Shops and World Gates that DigManager builds on start.
local function calmWorld()
	for _, child in ipairs(workspace:GetChildren()) do
		local isCharacter = child:IsA("Model") and game:GetService("Players"):GetPlayerFromCharacter(child)
		if not isCharacter and not child:GetAttribute("NoCalm") then
			Architecture.calm(child)
		end
	end
end
calmWorld()
task.delay(5, calmWorld)

print("MapStyle: cartoony 2050 skyline, dig site and sky ready")
