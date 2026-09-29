-- MapStyle (Script in ServerScriptService)
-- Gives the whole map the cartoony 2050 look when the server starts:
-- rebuilds the skyline, restyles the dig site, brightens the ground and the sky.

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local CityBuilder = require(script.Parent:WaitForChild("CityBuilder"))
local DigSiteStyle = require(script.Parent:WaitForChild("DigSiteStyle"))

-- Set to false to keep the place's own Lighting settings (sky, time of day, effects)
local SUNNY_SKY = true

---------------------------------------------------------------------
-- GROUND
---------------------------------------------------------------------
for _, part in ipairs(workspace:GetChildren()) do
	if part:IsA("BasePart") and part.Name:find("^Baseplate") then
		part.Material = Enum.Material.SmoothPlastic
		part.Color = Color3.fromRGB(196, 202, 228)
	end
end
local spawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")
if spawnLocation then
	spawnLocation.Material = Enum.Material.SmoothPlastic
	spawnLocation.Color = Color3.fromRGB(178, 158, 255)
end

-- Terrain colors: bright cartoon grass on top, soft stone walls, warm dig layers
local terrain = workspace.Terrain
terrain:SetMaterialColor(Enum.Material.Grass, Color3.fromRGB(112, 204, 108))
terrain:SetMaterialColor(Enum.Material.Slate, Color3.fromRGB(150, 146, 172))
terrain:SetMaterialColor(Enum.Material.Ground, Color3.fromRGB(176, 124, 84))
terrain:SetMaterialColor(Enum.Material.Sandstone, Color3.fromRGB(222, 180, 120))
terrain:SetMaterialColor(Enum.Material.Glacier, Color3.fromRGB(150, 210, 240))
terrain:SetMaterialColor(Enum.Material.Basalt, Color3.fromRGB(70, 64, 96))

---------------------------------------------------------------------
-- CITY + DIG SITE
---------------------------------------------------------------------
local city = workspace:FindFirstChild("City")
if city then
	CityBuilder.build(city)
end
local digSite = workspace:FindFirstChild("DigSite")
if digSite then
	DigSiteStyle(digSite, GameConfig.Worlds[1])
end

---------------------------------------------------------------------
-- SKY: bright afternoon, soft haze, fluffy clouds
---------------------------------------------------------------------
if SUNNY_SKY then
	Lighting.ClockTime = 14.5
	Lighting.Brightness = 2.6
	Lighting.Ambient = Color3.fromRGB(120, 118, 140)
	Lighting.OutdoorAmbient = Color3.fromRGB(165, 165, 190)
	Lighting.EnvironmentDiffuseScale = 0.6
	Lighting.EnvironmentSpecularScale = 0.4
	Lighting.GlobalShadows = true

	-- the place's night skybox doesn't fit a sunny day; Roblox's default sky does
	local sky = Lighting:FindFirstChildOfClass("Sky")
	if sky then sky:Destroy() end

	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
	atmosphere.Density = 0.3
	atmosphere.Offset = 0.2
	atmosphere.Color = Color3.fromRGB(205, 214, 255)
	atmosphere.Decay = Color3.fromRGB(150, 160, 230)
	atmosphere.Glare = 0.2
	atmosphere.Haze = 1.2
	atmosphere.Parent = Lighting

	for _, effect in ipairs(Lighting:GetChildren()) do
		if effect:IsA("BloomEffect") then
			effect.Intensity = 0.5
			effect.Size = 24
			effect.Threshold = 1.4
		elseif effect:IsA("DepthOfFieldEffect") then
			effect.Enabled = false -- keeps the cartoon look crisp
		end
	end
	local grade = Lighting:FindFirstChild("Cartoon2050Grade") or Instance.new("ColorCorrectionEffect")
	grade.Name = "Cartoon2050Grade"
	grade.Saturation = 0.15
	grade.Contrast = 0.05
	grade.Brightness = 0.02
	grade.Parent = Lighting

	local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds") or Instance.new("Clouds")
	clouds.Cover = 0.55
	clouds.Density = 0.7
	clouds.Color = Color3.fromRGB(255, 250, 255)
	clouds.Parent = workspace.Terrain
end

print("MapStyle: cartoony 2050 skyline, dig site and sky ready")
