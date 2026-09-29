-- SkyPlanets (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The interconnected skybox: the other 8 worlds hang high in the sky as big faint planets,
-- each in its world's colors, so from any world you can see where else you could go.
-- Each planet is a softly transparent sphere inside a larger Neon glow shell (so it blends
-- into the haze like a distant moon); some get a ring. They sit far out and high up, spin
-- slowly, and move to surround whichever world you travel to. Local to this screen only.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local player = Players.LocalPlayer

local DISTANCE = 1900          -- studs from the world you're in
local HEIGHT = {750, 1150}     -- studs above it
local SIZE = {240, 420}        -- planet diameter
local BODY_TRANSPARENCY = 0.35 -- the planet itself
local GLOW_TRANSPARENCY = 0.86 -- the Neon halo around it
local HOME_COLOR = Color3.fromRGB(112, 204, 108) -- World 1 has no theme colors

local folder = Instance.new("Folder")
folder.Name = "SkyPlanets"
folder.Parent = workspace

local planets = {} -- [worldId] = {Model, Body, Glow, Ring, Offset, Spin}

local function part(name, shape, size, color, material, transparency)
	local p = Instance.new("Part")
	p.Name = name
	p.Shape = shape
	p.Size = size
	p.Color = color
	p.Material = material
	p.Transparency = transparency
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	return p
end

for _, world in ipairs(GameConfig.Worlds) do
	local main = world.Look and world.Look.Main or HOME_COLOR
	local glowColor = world.Look and world.Look.Glow or Color3.fromRGB(150, 230, 255)
	local rng = Random.new(world.Id * 131)
	local size = SIZE[1] + (SIZE[2] - SIZE[1]) * rng:NextNumber()
	local model = Instance.new("Model")
	model.Name = "Planet_" .. world.Name
	local body = part("Planet", Enum.PartType.Ball, Vector3.one * size, main, Enum.Material.SmoothPlastic, BODY_TRANSPARENCY)
	body.Parent = model
	local glow = part("Glow", Enum.PartType.Ball, Vector3.one * size * 1.18, glowColor, Enum.Material.Neon, GLOW_TRANSPARENCY)
	glow.Parent = model
	-- a darker band so it reads as a planet, not a ball
	local band = part("Band", Enum.PartType.Cylinder, Vector3.new(size * 0.16, size * 1.005, size * 1.005), main:Lerp(Color3.new(0, 0, 0), 0.25), Enum.Material.SmoothPlastic, BODY_TRANSPARENCY)
	band.Parent = model
	local ring
	if world.Id % 3 == 0 then
		ring = part("Ring", Enum.PartType.Cylinder, Vector3.new(size * 0.02, size * 2, size * 2), glowColor, Enum.Material.Neon, 0.7)
		ring.Parent = model
	end
	model.Parent = nil -- shown when its turn comes
	planets[world.Id] = {
		Model = model, Body = body, Glow = glow, Band = band, Ring = ring,
		Angle = (world.Id - 1) / #GameConfig.Worlds * math.pi * 2 + rng:NextNumber(-0.2, 0.2),
		Height = HEIGHT[1] + (HEIGHT[2] - HEIGHT[1]) * rng:NextNumber(),
		Tilt = CFrame.Angles(rng:NextNumber(-0.5, 0.5), 0, rng:NextNumber(0.2, 0.6)),
		Spin = rng:NextNumber(0.02, 0.06),
	}
end

local centers = {} -- [worldId] = CFrame of the planet around the current world
local function arrange()
	local current = GameConfig.GetWorld(player:GetAttribute("CurrentWorld") or 1) or GameConfig.Worlds[1]
	for id, planet in pairs(planets) do
		if id == current.Id then
			planet.Model.Parent = nil -- no planet for the world you're standing on
			centers[id] = nil
		else
			local offset = Vector3.new(math.cos(planet.Angle) * DISTANCE, planet.Height, math.sin(planet.Angle) * DISTANCE)
			centers[id] = CFrame.new(current.Origin + offset) * planet.Tilt
			planet.Model.Parent = folder
		end
	end
end
player:GetAttributeChangedSignal("CurrentWorld"):Connect(arrange)
arrange()

RunService.Heartbeat:Connect(function()
	local t = os.clock()
	local parts, cframes = {}, {}
	for id, center in pairs(centers) do
		local planet = planets[id]
		local spun = center * CFrame.Angles(0, t * planet.Spin, 0)
		table.insert(parts, planet.Body); table.insert(cframes, spun)
		table.insert(parts, planet.Glow); table.insert(cframes, spun)
		table.insert(parts, planet.Band); table.insert(cframes, spun * CFrame.Angles(0, 0, math.rad(90)))
		if planet.Ring then
			table.insert(parts, planet.Ring); table.insert(cframes, center * CFrame.Angles(0, 0, math.rad(90)))
		end
	end
	if #parts > 0 then
		workspace:BulkMoveTo(parts, cframes, Enum.BulkMoveMode.FireCFrameChanged)
	end
end)
