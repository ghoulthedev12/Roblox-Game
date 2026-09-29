-- VehicleModels (ModuleScript in ReplicatedStorage)
-- Cartoony 2050 flying vehicles: bubble cars, hover buses, delivery drones and ad blimps.
-- FlyingTraffic (client) builds them and moves them around the city.
-- Every builder returns a Model whose front is -Z and whose PrimaryPart is at its center.

local VehicleModels = {}

local rgb = Color3.fromRGB
local BODY_COLORS = {
	rgb(255, 122, 138), rgb(92, 186, 255), rgb(255, 206, 84), rgb(96, 226, 190),
	rgb(178, 158, 255), rgb(255, 160, 90), rgb(246, 247, 252),
}
local GLOW_COLORS = {rgb(96, 196, 222), rgb(214, 118, 188), rgb(222, 186, 96), rgb(96, 206, 168)}
local WHITE = rgb(246, 247, 252)
local INK = rgb(34, 36, 74)
local GLASS = rgb(168, 228, 255)
local ALONG_Z = CFrame.Angles(0, math.rad(90), 0) -- points a cylinder along Z
local UPRIGHT = CFrame.Angles(0, 0, math.rad(90)) -- stands a cylinder up

local function part(model, name, size, cframe, color, material, shape)
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

local function blob(model, name, size, cframe, color, material)
	local p = part(model, name, size, cframe, color, material)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = p
	return p
end

local function ball(model, name, d, cframe, color, material)
	return part(model, name, Vector3.new(d, d, d), cframe, color, material, Enum.PartType.Ball)
end

local function pick(rng, list)
	return list[rng:NextInteger(1, #list)]
end

local function glass(p)
	p.Transparency = 0.3
	p.Reflectance = 0.15
	return p
end

-- Little bubble car: round body, big glass dome, side pods with glowing thrusters
function VehicleModels.car(rng)
	local model = Instance.new("Model")
	model.Name = "BubbleCar"
	local color = pick(rng, BODY_COLORS)
	local glow = pick(rng, GLOW_COLORS)
	local body = blob(model, "Body", Vector3.new(5.4, 2.6, 9), CFrame.new(), color)
	blob(model, "Belly", Vector3.new(5, 1.4, 8.2), CFrame.new(0, -0.7, 0), WHITE)
	glass(blob(model, "Dome", Vector3.new(3.8, 3, 4.4), CFrame.new(0, 1.2, -0.3), GLASS, Enum.Material.Glass))
	part(model, "Seat", Vector3.new(2.6, 0.6, 1.4), CFrame.new(0, 0.6, 0.5), INK)
	for _, side in ipairs({-1, 1}) do
		part(model, "Pod", Vector3.new(4.6, 1.5, 1.5), CFrame.new(side * 2.9, -0.2, 1.4) * ALONG_Z, WHITE, nil, Enum.PartType.Cylinder)
		part(model, "PodGlow", Vector3.new(0.3, 1.2, 1.2), CFrame.new(side * 2.9, -0.2, 3.75) * ALONG_Z, glow, Enum.Material.Neon, Enum.PartType.Cylinder)
		ball(model, "Headlight", 0.8, CFrame.new(side * 1.3, 0, -4.3), rgb(214, 208, 180), Enum.Material.Neon)
	end
	part(model, "TailFin", Vector3.new(0.4, 1.6, 1.8), CFrame.new(0, 1.3, 3.6), color)
	ball(model, "FinTip", 0.6, CFrame.new(0, 2.1, 3.6), glow, Enum.Material.Neon)
	part(model, "Underglow", Vector3.new(3.6, 0.15, 6), CFrame.new(0, -1.35, 0), glow, Enum.Material.Neon)
	model.PrimaryPart = body
	return model
end

-- Hover bus: long capsule with porthole windows and a color stripe
function VehicleModels.bus(rng)
	local model = Instance.new("Model")
	model.Name = "HoverBus"
	local color = pick(rng, BODY_COLORS)
	local glow = pick(rng, GLOW_COLORS)
	local body = part(model, "Body", Vector3.new(16, 5, 5), CFrame.new() * ALONG_Z, WHITE, nil, Enum.PartType.Cylinder)
	ball(model, "Nose", 5, CFrame.new(0, 0, -8), WHITE)
	ball(model, "Tail", 5, CFrame.new(0, 0, 8), color)
	glass(blob(model, "Windshield", Vector3.new(3.8, 2.4, 2), CFrame.new(0, 0.6, -9.6), GLASS, Enum.Material.Glass))
	part(model, "Stripe", Vector3.new(16.2, 1.1, 5.15), CFrame.new(0, -1, 0) * ALONG_Z, color, nil, Enum.PartType.Cylinder)
	for _, side in ipairs({-1, 1}) do
		for k = -2, 2 do
			part(model, "Window", Vector3.new(0.3, 1.5, 1.5), CFrame.new(side * 2.45, 0.8, k * 3), GLASS, Enum.Material.Glass, Enum.PartType.Cylinder)
		end
		part(model, "Thruster", Vector3.new(3, 1.6, 1.6), CFrame.new(side * 2.2, -2.2, 6) * ALONG_Z, color, nil, Enum.PartType.Cylinder)
		part(model, "ThrusterGlow", Vector3.new(0.3, 1.3, 1.3), CFrame.new(side * 2.2, -2.2, 7.6) * ALONG_Z, glow, Enum.Material.Neon, Enum.PartType.Cylinder)
	end
	part(model, "RoofSign", Vector3.new(0.6, 1.2, 6), CFrame.new(0, 2.9, 0), color)
	model.PrimaryPart = body
	return model
end

-- Delivery drone: round body, four rotor rings, a dangling package
function VehicleModels.drone(rng)
	local model = Instance.new("Model")
	model.Name = "DeliveryDrone"
	local color = pick(rng, BODY_COLORS)
	local glow = pick(rng, GLOW_COLORS)
	local body = ball(model, "Body", 2.6, CFrame.new(), WHITE)
	ball(model, "Eye", 1, CFrame.new(0, 0.2, -1.05), INK)
	ball(model, "EyeGlint", 0.35, CFrame.new(0.15, 0.4, -1.5), glow, Enum.Material.Neon)
	for _, x in ipairs({-1, 1}) do
		for _, z in ipairs({-1, 1}) do
			local arm = CFrame.new(x * 2, 0.5, z * 2)
			part(model, "Arm", Vector3.new(0.3, 0.3, 2.4), CFrame.lookAt(Vector3.new(0, 0.5, 0), arm.Position) * CFrame.new(0, 0, -1.4), color)
			part(model, "Rotor", Vector3.new(0.2, 2.2, 2.2), arm * UPRIGHT, color, nil, Enum.PartType.Cylinder)
			part(model, "RotorGlow", Vector3.new(0.1, 2.4, 2.4), arm * CFrame.new(0, -0.1, 0) * UPRIGHT, glow, Enum.Material.Neon, Enum.PartType.Cylinder).Transparency = 0.5
		end
	end
	part(model, "Rope", Vector3.new(0.15, 1.6, 0.15), CFrame.new(0, -2, 0), INK)
	part(model, "Package", Vector3.new(1.8, 1.5, 1.8), CFrame.new(0, -3.4, 0), rgb(214, 160, 100))
	part(model, "PackageTape", Vector3.new(1.85, 0.3, 1.85), CFrame.new(0, -3.1, 0), pick(rng, BODY_COLORS))
	model.PrimaryPart = body
	return model
end

-- Advertising blimp: huge soft balloon with fins, a gondola and a glowing banner
local SLOGANS = {"DIG DEEPER!", "MEMES 4 SALE", "VISIT THE ABYSS", "RATE MY MUSEUM", "SHOVEL SALE 50% OFF", "NO BRAINROT ZONE"}
function VehicleModels.blimp(rng)
	local model = Instance.new("Model")
	model.Name = "AdBlimp"
	local color = pick(rng, BODY_COLORS)
	local body = blob(model, "Balloon", Vector3.new(16, 15, 42), CFrame.new(), color)
	blob(model, "BalloonShine", Vector3.new(7, 3, 20), CFrame.new(-3, 5.5, -3), WHITE).Transparency = 0.4
	for i, angle in ipairs({0, 90, 180, 270}) do
		local cf = CFrame.new(0, 0, 18) * CFrame.Angles(0, 0, math.rad(angle))
		part(model, "Fin", Vector3.new(0.8, 9, 7), cf * CFrame.new(0, 5.5, 0), i % 2 == 0 and WHITE or color)
	end
	part(model, "Gondola", Vector3.new(8, 3, 3.6), CFrame.new(0, -9, -2) * ALONG_Z, WHITE, nil, Enum.PartType.Cylinder)
	ball(model, "GondolaFront", 3.6, CFrame.new(0, -9, -6), WHITE)
	glass(blob(model, "GondolaWindows", Vector3.new(3.8, 1.4, 7), CFrame.new(0, -8.6, -2), GLASS, Enum.Material.Glass))
	for _, side in ipairs({-1, 1}) do
		local banner = part(model, "Banner", Vector3.new(0.4, 5, 22), CFrame.new(side * 8.1, 0, 0), INK)
		local gui = Instance.new("SurfaceGui")
		gui.Face = side == 1 and Enum.NormalId.Right or Enum.NormalId.Left
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 20
		gui.LightInfluence = 0
		gui.Parent = banner
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Text = pick(rng, SLOGANS)
		label.TextColor3 = rgb(255, 222, 110)
		label.Font = Enum.Font.FredokaOne
		label.TextScaled = true
		label.Parent = gui
		part(model, "BannerFrame", Vector3.new(0.3, 5.6, 22.6), CFrame.new(side * 7.9, 0, 0), pick(rng, GLOW_COLORS))
		part(model, "Propeller", Vector3.new(0.3, 4, 4), CFrame.new(side * 5, -8, 8) * ALONG_Z, WHITE, nil, Enum.PartType.Cylinder)
	end
	model.PrimaryPart = body
	return model
end

return VehicleModels
