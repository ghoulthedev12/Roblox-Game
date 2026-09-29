-- FlyingTraffic (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Hover cars and cargo ships flying around the city in traffic lanes.
-- Runs only on each player's screen, so it's smooth and doesn't load the server.

local RunService = game:GetService("RunService")

local folder = Instance.new("Folder")
folder.Name = "FlyingTraffic"
folder.Parent = workspace

local rng = Random.new()

-- Traffic lanes: circles around the map, placed between the rings of towers
-- Dir 1 = counter-clockwise, -1 = clockwise
local LANES = {
	{Radius = 305, Height = 48,  Speed = 70,  Count = 6, Dir = 1},   -- above the ring road
	{Radius = 305, Height = 62,  Speed = 60,  Count = 5, Dir = -1},
	{Radius = 410, Height = 90,  Speed = 85,  Count = 7, Dir = 1},   -- between tower rings 1 and 2
	{Radius = 410, Height = 110, Speed = 80,  Count = 5, Dir = -1},
	{Radius = 518, Height = 140, Speed = 95,  Count = 7, Dir = -1},  -- between tower rings 2 and 3
	{Radius = 518, Height = 165, Speed = 90,  Count = 5, Dir = 1},
	{Radius = 628, Height = 200, Speed = 100, Count = 6, Dir = 1},   -- in front of the edge wall
	{Radius = 450, Height = 400, Speed = 40,  Count = 3, Dir = -1, Ships = true},
	{Radius = 600, Height = 430, Speed = 35,  Count = 2, Dir = 1, Ships = true},
}

local CAR_COLORS = {
	Color3.fromRGB(240, 240, 245), Color3.fromRGB(30, 32, 40), Color3.fromRGB(255, 60, 90),
	Color3.fromRGB(0, 170, 255), Color3.fromRGB(255, 200, 60), Color3.fromRGB(150, 90, 255),
}
local GLOW_COLORS = {
	Color3.fromRGB(0, 225, 255), Color3.fromRGB(255, 60, 200), Color3.fromRGB(60, 255, 200), Color3.fromRGB(255, 160, 40),
}

---------------------------------------------------------------------
-- BUILDING VEHICLES (front of every vehicle = -Z)
---------------------------------------------------------------------
local function newPart(model, name, size, cframe, color, material, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	if shape then p.Shape = shape end
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = model
	return p
end

local function oval(model, name, size, cframe, color, material)
	local p = newPart(model, name, size, cframe, color, material)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = p
	return p
end

local ALONG_Z = CFrame.Angles(0, math.rad(90), 0)

local function buildCar()
	local model = Instance.new("Model")
	model.Name = "HoverCar"
	local color = CAR_COLORS[rng:NextInteger(1, #CAR_COLORS)]
	local glow = GLOW_COLORS[rng:NextInteger(1, #GLOW_COLORS)]

	local body = oval(model, "Body", Vector3.new(4.6, 1.7, 10), CFrame.new(), color)
	body.Reflectance = 0.2
	local cockpit = oval(model, "Cockpit", Vector3.new(3.2, 1.6, 4.6), CFrame.new(0, 0.8, -0.4), Color3.fromRGB(120, 200, 255), Enum.Material.Glass)
	cockpit.Transparency = 0.25
	newPart(model, "Underglow", Vector3.new(3.4, 0.2, 7.2), CFrame.new(0, -0.8, 0), glow, Enum.Material.Neon)
	newPart(model, "Headlights", Vector3.new(2.8, 0.3, 0.3), CFrame.new(0, 0.1, -4.8), Color3.fromRGB(230, 245, 255), Enum.Material.Neon)
	newPart(model, "TailLights", Vector3.new(3.4, 0.3, 0.3), CFrame.new(0, 0.2, 4.85), Color3.fromRGB(255, 40, 60), Enum.Material.Neon)
	for _, side in ipairs({-1, 1}) do
		newPart(model, "Thruster", Vector3.new(1.6, 1, 1), CFrame.new(side * 2.3, -0.1, 3.6) * ALONG_Z, Color3.fromRGB(60, 62, 72), Enum.Material.Metal, Enum.PartType.Cylinder)
		newPart(model, "ThrusterGlow", Vector3.new(0.2, 0.8, 0.8), CFrame.new(side * 2.3, -0.1, 4.45) * ALONG_Z, glow, Enum.Material.Neon, Enum.PartType.Cylinder)
	end
	model.PrimaryPart = body
	return model
end

local function buildShip()
	local model = Instance.new("Model")
	model.Name = "CargoShip"
	local hull = oval(model, "Hull", Vector3.new(14, 7, 38), CFrame.new(), Color3.fromRGB(220, 225, 235))
	hull.Reflectance = 0.15
	oval(model, "Bridge", Vector3.new(7, 3.5, 9), CFrame.new(0, 3.2, -10), Color3.fromRGB(110, 190, 255), Enum.Material.Glass).Transparency = 0.2
	newPart(model, "Wings", Vector3.new(40, 0.8, 10), CFrame.new(0, -0.5, 4), Color3.fromRGB(60, 64, 78), Enum.Material.Metal)
	newPart(model, "Stripe", Vector3.new(14.2, 0.6, 30), CFrame.new(0, 0, 0), Color3.fromRGB(255, 200, 60), Enum.Material.Neon)
	newPart(model, "Container", Vector3.new(9, 6, 14), CFrame.new(0, -5, 4), Color3.fromRGB(255, 120, 40), Enum.Material.DiamondPlate)
	for _, side in ipairs({-1, 1}) do
		newPart(model, "Engine", Vector3.new(8, 4, 4), CFrame.new(side * 16, -0.5, 8) * ALONG_Z, Color3.fromRGB(50, 52, 62), Enum.Material.Metal, Enum.PartType.Cylinder)
		local flame = newPart(model, "EngineGlow", Vector3.new(0.4, 3.4, 3.4), CFrame.new(side * 16, -0.5, 12.2) * ALONG_Z, Color3.fromRGB(0, 225, 255), Enum.Material.Neon, Enum.PartType.Cylinder)
		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(0, 225, 255)
		light.Range = 20
		light.Brightness = 1.5
		light.Parent = flame
		newPart(model, "WingLight", Vector3.new(0.8, 0.8, 0.8), CFrame.new(side * 20, -0.5, 4), side == 1 and Color3.fromRGB(60, 255, 90) or Color3.fromRGB(255, 50, 50), Enum.Material.Neon, Enum.PartType.Ball)
	end
	model.PrimaryPart = hull
	return model
end

---------------------------------------------------------------------
-- SPAWN VEHICLES ON THEIR LANES
---------------------------------------------------------------------
local vehicles = {}
for _, lane in ipairs(LANES) do
	for i = 1, lane.Count do
		local model = lane.Ships and buildShip() or buildCar()
		model.Parent = folder
		table.insert(vehicles, {
			Model = model,
			Lane = lane,
			Angle = (i / lane.Count) * math.pi * 2 + rng:NextNumber(-0.2, 0.2),
			Speed = lane.Speed * rng:NextNumber(0.85, 1.15),
			Phase = rng:NextNumber(0, math.pi * 2),
			HeightOffset = rng:NextNumber(-4, 4),
		})
	end
end

---------------------------------------------------------------------
-- MOVE EVERYTHING SMOOTHLY EVERY FRAME
---------------------------------------------------------------------
RunService.Heartbeat:Connect(function(dt)
	local t = os.clock()
	for _, v in ipairs(vehicles) do
		local lane = v.Lane
		v.Angle += lane.Dir * (v.Speed / lane.Radius) * dt
		local a = v.Angle
		local bob = math.sin(t * 0.9 + v.Phase) * (lane.Ships and 3 or 1.2)
		local position = Vector3.new(math.cos(a) * lane.Radius, lane.Height + v.HeightOffset + bob, math.sin(a) * lane.Radius)
		local forward = Vector3.new(-math.sin(a), 0, math.cos(a)) * lane.Dir
		-- lean slightly into the curve, like a real turning vehicle
		local lean = CFrame.Angles(0, 0, lane.Dir * (lane.Ships and 0.05 or 0.14))
		v.Model:PivotTo(CFrame.lookAt(position, position + forward) * lean)
	end
end)
