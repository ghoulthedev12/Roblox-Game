-- ShovelModels (ModuleScript in ServerScriptService)
-- Builds a detailed, individually styled model for every shovel.
-- DigManager uses this instead of its old simple shovel builder.

local SCALE = 0.65 -- overall size of the shovels
local ALONG_Z = CFrame.Angles(0, math.rad(90), 0) -- points a cylinder along the shaft

local function rgb(r, g, b)
	return Color3.fromRGB(r, g, b)
end

---------------------------------------------------------------------
-- LOOK OF EACH SHOVEL
-- Blade shapes: "Spade" (classic), "Scoop" (round toy), "Spoon", "Trowel"
-- Grip: "D" (D-shaped handle) or "T" (T-bar handle)
---------------------------------------------------------------------
local STYLES = {
	RustyShovel = {
		Shape = "Spade", Grip = "D",
		Shaft = rgb(92, 64, 42), ShaftMat = "Wood",
		Blade = rgb(150, 82, 45), BladeMat = "CorrodedMetal",
		Metal = rgb(105, 68, 45), MetalMat = "CorrodedMetal",
		GripColor = rgb(75, 75, 78), GripMat = "Fabric",
		Tape = true, Rust = true,
	},
	PlasticShovel = {
		Shape = "Scoop", Grip = "T",
		Shaft = rgb(40, 120, 255), ShaftMat = "SmoothPlastic",
		Blade = rgb(255, 205, 40), BladeMat = "SmoothPlastic", Shine = 0.12,
		Metal = rgb(255, 75, 75), MetalMat = "SmoothPlastic",
		GripColor = rgb(255, 75, 75), GripMat = "SmoothPlastic",
	},
	GardenSpade = {
		Shape = "Spade", Grip = "D",
		Shaft = rgb(70, 130, 60), ShaftMat = "SmoothPlastic",
		Blade = rgb(165, 170, 178), BladeMat = "Metal", Shine = 0.15,
		Metal = rgb(55, 110, 50), MetalMat = "SmoothPlastic",
		GripColor = rgb(45, 90, 40), GripMat = "SmoothPlastic",
		Rivets = true,
	},
	IronShovel = {
		Shape = "Spade", Grip = "D",
		Shaft = rgb(170, 125, 82), ShaftMat = "Wood",
		Blade = rgb(118, 122, 132), BladeMat = "Metal", Shine = 0.2,
		Metal = rgb(58, 60, 66), MetalMat = "Metal",
		GripColor = rgb(30, 30, 32), GripMat = "Fabric",
		Rivets = true,
	},
	SteelSpade = {
		Shape = "Spade", Grip = "T",
		Shaft = rgb(45, 50, 60), ShaftMat = "Metal",
		Blade = rgb(190, 200, 215), BladeMat = "Metal", Shine = 0.35,
		Metal = rgb(120, 140, 170), MetalMat = "Metal",
		GripColor = rgb(20, 20, 24), GripMat = "Fabric",
		Rivets = true,
	},
	GoldenShovel = {
		Shape = "Spade", Grip = "D",
		Shaft = rgb(35, 32, 30), ShaftMat = "Wood",
		Blade = rgb(255, 196, 55), BladeMat = "Metal", Shine = 0.4,
		Metal = rgb(255, 205, 80), MetalMat = "Metal",
		GripColor = rgb(130, 25, 35), GripMat = "Fabric",
		Rivets = true, Sparkles = rgb(255, 220, 120),
	},
	GamerShovel = {
		Shape = "Spade", Grip = "T",
		Shaft = rgb(24, 24, 30), ShaftMat = "Metal",
		Blade = rgb(30, 30, 40), BladeMat = "Metal", Shine = 0.25,
		Metal = rgb(40, 40, 50), MetalMat = "Metal",
		GripColor = rgb(15, 15, 18), GripMat = "Fabric",
		Edge = rgb(255, 60, 200), Glow = rgb(255, 60, 200),
		Strips = {rgb(255, 60, 200), rgb(0, 225, 255), rgb(90, 255, 120)},
	},
	PixelSpade = {
		Shape = "Spade", Grip = "T",
		Shaft = rgb(60, 60, 200), ShaftMat = "SmoothPlastic",
		Blade = rgb(80, 200, 255), BladeMat = "SmoothPlastic",
		Metal = rgb(255, 255, 255), MetalMat = "SmoothPlastic",
		GripColor = rgb(255, 80, 80), GripMat = "SmoothPlastic",
		Pixels = true,
	},
	RainbowShovel = {
		Shape = "Spade", Grip = "D",
		Shaft = rgb(245, 245, 250), ShaftMat = "SmoothPlastic",
		Blade = rgb(255, 120, 220), BladeMat = "Glass", Shine = 0.3,
		Metal = rgb(255, 255, 255), MetalMat = "Metal",
		GripColor = rgb(120, 90, 255), GripMat = "SmoothPlastic",
		Strips = {rgb(255, 60, 60), rgb(255, 200, 40), rgb(80, 220, 120), rgb(60, 140, 255)},
		Glow = rgb(255, 150, 230), Sparkles = rgb(255, 200, 255),
	},
	DiamondShovel = {
		Shape = "Spade", Grip = "D",
		Shaft = rgb(235, 238, 245), ShaftMat = "Metal",
		Blade = rgb(150, 240, 255), BladeMat = "Glass", Shine = 0.45, BladeTransparency = 0.2,
		Metal = rgb(205, 210, 225), MetalMat = "Metal",
		GripColor = rgb(60, 110, 160), GripMat = "Fabric",
		Core = rgb(120, 240, 255), Glow = rgb(120, 240, 255), Sparkles = rgb(200, 250, 255),
	},
	FidgetDrill = {
		Shape = "Trowel", Grip = "T",
		Shaft = rgb(40, 40, 45), ShaftMat = "Metal",
		Blade = rgb(255, 140, 40), BladeMat = "Metal", Shine = 0.3,
		Metal = rgb(255, 140, 40), MetalMat = "Metal",
		GripColor = rgb(20, 20, 20), GripMat = "Fabric",
		Rings = rgb(255, 140, 40),
	},
	LaserExcavator = {
		Shape = "Spade", Grip = "T",
		Shaft = rgb(240, 242, 248), ShaftMat = "SmoothPlastic",
		Blade = rgb(255, 50, 50), BladeMat = "Neon", BladeTransparency = 0.15,
		Metal = rgb(55, 58, 68), MetalMat = "Metal",
		GripColor = rgb(40, 40, 48), GripMat = "SmoothPlastic",
		Edge = rgb(255, 180, 180), Glow = rgb(255, 60, 60), Field = rgb(255, 60, 60),
	},
	PlasmaSpade = {
		Shape = "Spade", Grip = "T",
		Shaft = rgb(30, 34, 50), ShaftMat = "Metal",
		Blade = rgb(80, 140, 255), BladeMat = "Neon", BladeTransparency = 0.2,
		Metal = rgb(120, 180, 255), MetalMat = "Metal",
		GripColor = rgb(20, 22, 30), GripMat = "Fabric",
		Glow = rgb(80, 140, 255), Field = rgb(120, 180, 255), Sparkles = rgb(160, 200, 255),
	},
	HoverScoop = {
		Shape = "Scoop", Grip = "T",
		Shaft = rgb(235, 240, 245), ShaftMat = "SmoothPlastic",
		Blade = rgb(60, 255, 200), BladeMat = "Glass", Shine = 0.3, BladeTransparency = 0.15,
		Metal = rgb(60, 255, 200), MetalMat = "Neon",
		GripColor = rgb(40, 45, 55), GripMat = "SmoothPlastic",
		Glow = rgb(60, 255, 200), Rings = rgb(60, 255, 200),
	},
	QuantumSpoon = {
		Shape = "Spoon", Grip = "T",
		Shaft = rgb(30, 22, 50), ShaftMat = "Metal",
		Blade = rgb(170, 90, 255), BladeMat = "ForceField",
		Metal = rgb(200, 150, 255), MetalMat = "Neon",
		GripColor = rgb(25, 18, 40), GripMat = "Fabric",
		Core = rgb(200, 140, 255), Glow = rgb(170, 90, 255), Rings = rgb(200, 150, 255), Sparkles = rgb(220, 180, 255),
	},
	DialUpDigger = {
		Shape = "Spade", Grip = "D",
		Shaft = rgb(215, 205, 175), ShaftMat = "SmoothPlastic",
		Blade = rgb(200, 190, 160), BladeMat = "SmoothPlastic",
		Metal = rgb(120, 115, 100), MetalMat = "SmoothPlastic",
		GripColor = rgb(90, 85, 75), GripMat = "SmoothPlastic",
		Edge = rgb(90, 255, 120), Pixels = true,
	},
	BlackHoleShovel = {
		Shape = "Spoon", Grip = "D",
		Shaft = rgb(15, 12, 20), ShaftMat = "Metal",
		Blade = rgb(10, 5, 20), BladeMat = "Glass", Shine = 0.5,
		Metal = rgb(140, 60, 255), MetalMat = "Neon",
		GripColor = rgb(10, 10, 12), GripMat = "Fabric",
		Core = rgb(140, 60, 255), Glow = rgb(140, 60, 255), Rings = rgb(255, 150, 60),
	},
	CosmicTrowel = {
		Shape = "Trowel", Grip = "T",
		Shaft = rgb(20, 24, 50), ShaftMat = "Metal",
		Blade = rgb(120, 200, 255), BladeMat = "Glass", Shine = 0.35, BladeTransparency = 0.1,
		Metal = rgb(255, 220, 140), MetalMat = "Metal",
		GripColor = rgb(20, 24, 50), GripMat = "Fabric",
		Core = rgb(255, 255, 255), Glow = rgb(120, 200, 255), Sparkles = rgb(255, 255, 255),
	},
	VoidExcavator = {
		Shape = "Spade", Grip = "T",
		Shaft = rgb(20, 10, 30), ShaftMat = "Metal",
		Blade = rgb(110, 40, 160), BladeMat = "ForceField",
		Metal = rgb(110, 40, 160), MetalMat = "Neon",
		GripColor = rgb(15, 8, 22), GripMat = "Fabric",
		Core = rgb(60, 0, 90), Edge = rgb(200, 120, 255), Glow = rgb(150, 60, 220), Sparkles = rgb(180, 100, 255),
	},
	AlgorithmTrowel = {
		Shape = "Trowel", Grip = "D",
		Shaft = rgb(30, 26, 20), ShaftMat = "Metal",
		Blade = rgb(255, 205, 70), BladeMat = "Metal", Shine = 0.4,
		Metal = rgb(255, 225, 120), MetalMat = "Metal",
		GripColor = rgb(40, 30, 15), GripMat = "Fabric",
		Edge = rgb(255, 240, 150), Strips = {rgb(255, 230, 120), rgb(255, 230, 120)},
		Glow = rgb(255, 210, 80), Sparkles = rgb(255, 240, 170), Rivets = true,
	},
	-- World 1 Abyss shovels: industrial, desaturated, built for bedrock
	TectonicAuger = {
		Shape = "Trowel", Grip = "T",
		Shaft = rgb(58, 60, 64), ShaftMat = "CorrodedMetal",
		Blade = rgb(150, 154, 160), BladeMat = "Foil", Shine = 0.25,
		Metal = rgb(92, 95, 100), MetalMat = "Metal",
		GripColor = rgb(28, 28, 30), GripMat = "Fabric",
		Rings = rgb(170, 160, 140), Rivets = true,
	},
	SingularitySpade = {
		Shape = "Spade", Grip = "D",
		Shaft = rgb(30, 31, 34), ShaftMat = "Metal",
		Blade = rgb(52, 54, 60), BladeMat = "Foil", Shine = 0.45,
		Metal = rgb(140, 144, 150), MetalMat = "Foil",
		GripColor = rgb(18, 18, 20), GripMat = "Fabric",
		Edge = rgb(200, 205, 212), Core = rgb(150, 196, 214), Glow = rgb(150, 196, 214),
		Sparkles = rgb(190, 215, 225),
	},
}

-- A decent look for any shovel that has no style above (e.g. new shovels you add later)
local function defaultStyle(def)
	local fancy = def.Material == "Neon" or def.Material == "ForceField" or def.Material == "Glass"
	return {
		Shape = "Spade", Grip = "D",
		Shaft = fancy and rgb(28, 30, 42) or rgb(150, 108, 70), ShaftMat = fancy and "Metal" or "Wood",
		Blade = def.Color, BladeMat = def.Material or "Metal", Shine = 0.2,
		Metal = fancy and def.Color or rgb(80, 82, 90), MetalMat = fancy and "Neon" or "Metal",
		GripColor = rgb(30, 30, 34), GripMat = "Fabric",
		Glow = fancy and def.Color or nil, Rivets = not fancy,
	}
end

---------------------------------------------------------------------
-- BUILDING HELPERS
---------------------------------------------------------------------
local function mat(name)
	return Enum.Material[name] or Enum.Material.SmoothPlastic
end

local function newPart(tool, name, size, cframe, color, material, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Color = color
	p.Material = mat(material)
	if shape then p.Shape = shape end
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Massless = true
	p.CastShadow = p.Material ~= Enum.Material.Neon and p.Material ~= Enum.Material.ForceField
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = tool
	return p
end

local function ellipsoid(tool, name, size, cframe, color, material)
	local p = newPart(tool, name, size, cframe, color, material)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = p
	return p
end

local function cylinderZ(tool, name, length, diameter, z, color, material)
	return newPart(tool, name, Vector3.new(length, diameter, diameter), CFrame.new(0, 0, z) * ALONG_Z, color, material, Enum.PartType.Cylinder)
end

-- a round bar from point a to point b
local function bar(tool, name, a, b, thickness, color, material)
	local length = (b - a).Magnitude
	return newPart(tool, name, Vector3.new(thickness, thickness, length), CFrame.lookAt((a + b) / 2, b), color, material)
end

---------------------------------------------------------------------
-- BLADES (built in "blade space": 0 = top of the blade, -Z = toward the tip)
---------------------------------------------------------------------
local function buildSpade(tool, s, b)
	local plate = newPart(tool, "Blade", Vector3.new(1.3, 0.08, 1.25), b * CFrame.new(0, 0, -0.62), s.Blade, s.BladeMat)
	newPart(tool, "BladeTip", Vector3.new(0.92, 0.08, 0.92), b * CFrame.new(0, 0, -1.25) * CFrame.Angles(0, math.rad(45), 0), s.Blade, s.BladeMat)
	newPart(tool, "LipL", Vector3.new(0.26, 0.08, 1.25), b * CFrame.new(-0.72, 0.06, -0.62) * CFrame.Angles(0, 0, math.rad(-22)), s.Blade, s.BladeMat)
	newPart(tool, "LipR", Vector3.new(0.26, 0.08, 1.25), b * CFrame.new(0.72, 0.06, -0.62) * CFrame.Angles(0, 0, math.rad(22)), s.Blade, s.BladeMat)
	-- raised spine down the back of the blade
	newPart(tool, "Spine", Vector3.new(0.16, 0.07, 1.0), b * CFrame.new(0, 0.07, -0.5), s.Metal, s.MetalMat)
	-- rolled foot step on top
	newPart(tool, "FootStep", Vector3.new(1.45, 0.13, 0.13), b, s.Metal, s.MetalMat, Enum.PartType.Cylinder)
	if s.Edge then
		newPart(tool, "EdgeL", Vector3.new(0.05, 0.1, 1.2), b * CFrame.new(-0.86, 0.12, -0.62) * CFrame.Angles(0, 0, math.rad(-22)), s.Edge, "Neon")
		newPart(tool, "EdgeR", Vector3.new(0.05, 0.1, 1.2), b * CFrame.new(0.86, 0.12, -0.62) * CFrame.Angles(0, 0, math.rad(22)), s.Edge, "Neon")
		newPart(tool, "EdgeTip", Vector3.new(0.7, 0.1, 0.05), b * CFrame.new(0, 0, -1.85), s.Edge, "Neon")
	end
	return plate
end

local function buildScoop(tool, s, b)
	local bowl = ellipsoid(tool, "Blade", Vector3.new(1.6, 0.14, 1.75), b * CFrame.new(0, 0, -0.85), s.Blade, s.BladeMat)
	ellipsoid(tool, "BowlRim", Vector3.new(1.7, 0.2, 1.85), b * CFrame.new(0, 0.05, -0.85), s.Blade, s.BladeMat).Transparency = 0.6
	newPart(tool, "Spine", Vector3.new(0.18, 0.08, 1.1), b * CFrame.new(0, 0.08, -0.55), s.Metal, s.MetalMat)
	return bowl
end

local function buildSpoon(tool, s, b)
	local bowl = ellipsoid(tool, "Blade", Vector3.new(1.35, 0.4, 1.8), b * CFrame.new(0, 0.05, -0.95), s.Blade, s.BladeMat)
	ellipsoid(tool, "BowlShell", Vector3.new(1.45, 0.3, 1.9), b * CFrame.new(0, 0, -0.95), s.Metal, s.MetalMat).Transparency = 0.5
	return bowl
end

local function buildTrowel(tool, s, b)
	local plate = newPart(tool, "Blade", Vector3.new(1.0, 0.07, 0.7), b * CFrame.new(0, 0, -0.35), s.Blade, s.BladeMat)
	newPart(tool, "BladeTip", Vector3.new(1.05, 0.07, 1.05), b * CFrame.new(0, 0, -0.95) * CFrame.Angles(0, math.rad(45), 0), s.Blade, s.BladeMat)
	newPart(tool, "Spine", Vector3.new(0.14, 0.08, 1.4), b * CFrame.new(0, 0.07, -0.75), s.Metal, s.MetalMat)
	newPart(tool, "Guard", Vector3.new(1.1, 0.14, 0.14), b, s.Metal, s.MetalMat, Enum.PartType.Cylinder)
	if s.Edge then
		newPart(tool, "EdgeL", Vector3.new(0.05, 0.1, 1.1), b * CFrame.new(-0.4, 0.06, -1.0) * CFrame.Angles(0, math.rad(-45), 0), s.Edge, "Neon")
		newPart(tool, "EdgeR", Vector3.new(0.05, 0.1, 1.1), b * CFrame.new(0.4, 0.06, -1.0) * CFrame.Angles(0, math.rad(45), 0), s.Edge, "Neon")
	end
	return plate
end

local BLADES = {Spade = buildSpade, Scoop = buildScoop, Spoon = buildSpoon, Trowel = buildTrowel}

---------------------------------------------------------------------
-- BUILD A SHOVEL TOOL
---------------------------------------------------------------------
return function(def)
	local s = STYLES[def.Id] or defaultStyle(def)

	local tool = Instance.new("Tool")
	tool.Name = def.Name
	tool.ToolTip = def.Name
	tool.CanBeDropped = false
	tool.RequiresHandle = true
	tool:SetAttribute("ShovelId", def.Id)

	-- invisible handle the hand holds; everything else is welded to it
	local handle = newPart(tool, "Handle", Vector3.new(0.3, 0.3, 4.4), CFrame.new(), s.Shaft, s.ShaftMat)
	handle.Transparency = 1

	-- SHAFT with metal collars
	cylinderZ(tool, "Shaft", 4.4, 0.22, 0, s.Shaft, s.ShaftMat)
	cylinderZ(tool, "CollarTop", 0.14, 0.27, 0.95, s.Metal, s.MetalMat)
	cylinderZ(tool, "CollarMid", 0.14, 0.27, -1.0, s.Metal, s.MetalMat)
	cylinderZ(tool, "GripWrap", 0.9, 0.27, 1.45, s.GripColor, s.GripMat)
	if s.Tape then
		cylinderZ(tool, "DuctTape", 0.45, 0.25, -0.2, rgb(150, 150, 155), "Fabric")
	end

	-- accent strips along the shaft (RGB lights, rainbow, circuits...)
	if s.Strips then
		local offsets = {Vector3.new(0, 0.115, 0), Vector3.new(0.115, 0, 0), Vector3.new(0, -0.115, 0), Vector3.new(-0.115, 0, 0)}
		for i, color in ipairs(s.Strips) do
			local o = offsets[(i - 1) % 4 + 1]
			newPart(tool, "Strip", Vector3.new(0.04, 0.04, 2.6), CFrame.new(o + Vector3.new(0, 0, -0.45)), color, "Neon")
		end
	end

	-- HANDLE GRIP at the top
	if s.Grip == "T" then
		newPart(tool, "TBar", Vector3.new(0.95, 0.2, 0.2), CFrame.new(0, 0, 2.3), s.GripColor, s.GripMat, Enum.PartType.Cylinder)
		newPart(tool, "TCapL", Vector3.new(0.08, 0.24, 0.24), CFrame.new(-0.5, 0, 2.3), s.Metal, s.MetalMat, Enum.PartType.Cylinder)
		newPart(tool, "TCapR", Vector3.new(0.08, 0.24, 0.24), CFrame.new(0.5, 0, 2.3), s.Metal, s.MetalMat, Enum.PartType.Cylinder)
	else
		bar(tool, "GripSideL", Vector3.new(0, 0, 2.15), Vector3.new(-0.42, 0, 2.8), 0.15, s.Shaft, s.ShaftMat)
		bar(tool, "GripSideR", Vector3.new(0, 0, 2.15), Vector3.new(0.42, 0, 2.8), 0.15, s.Shaft, s.ShaftMat)
		newPart(tool, "GripBar", Vector3.new(0.95, 0.19, 0.19), CFrame.new(0, 0, 2.82), s.GripColor, s.GripMat, Enum.PartType.Cylinder)
	end

	-- SOCKET where the blade meets the shaft
	cylinderZ(tool, "Socket", 0.8, 0.3, -2.35, s.Metal, s.MetalMat)
	if s.Rivets then
		newPart(tool, "RivetL", Vector3.new(0.09, 0.09, 0.09), CFrame.new(-0.15, 0, -2.35), rgb(200, 200, 205), "Metal", Enum.PartType.Ball)
		newPart(tool, "RivetR", Vector3.new(0.09, 0.09, 0.09), CFrame.new(0.15, 0, -2.35), rgb(200, 200, 205), "Metal", Enum.PartType.Ball)
	end

	-- BLADE (slightly angled like a real spade)
	local bladeCF = CFrame.new(0, -0.05, -2.7) * CFrame.Angles(math.rad(-14), 0, 0)
	local blade = (BLADES[s.Shape] or buildSpade)(tool, s, bladeCF)
	for _, part in ipairs(tool:GetChildren()) do
		if part:IsA("BasePart") and (part.Name:find("Blade") or part.Name:find("Lip")) then
			part.Reflectance = s.Shine or 0
			part.Transparency = math.max(part.Transparency, s.BladeTransparency or 0)
		end
	end

	-- EXTRAS
	if s.Rust then
		local spots = {Vector3.new(-0.3, 0.05, -0.4), Vector3.new(0.35, 0.05, -0.85), Vector3.new(-0.1, 0.05, -1.1), Vector3.new(0.2, 0.05, -0.25)}
		for i, pos in ipairs(spots) do
			newPart(tool, "RustSpot", Vector3.new(0.18 + i * 0.03, 0.02, 0.16), bladeCF * CFrame.new(pos) * CFrame.Angles(0, i, 0), rgb(95, 52, 30), "CorrodedMetal")
		end
	end
	if s.Pixels then
		for i = 0, 3 do
			newPart(tool, "Pixel", Vector3.new(0.22, 0.1, 0.22), bladeCF * CFrame.new(-0.35 + (i % 2) * 0.7, 0.06, -0.35 - math.floor(i / 2) * 0.5), s.Edge or rgb(255, 255, 255), "SmoothPlastic")
		end
	end
	if s.Core then
		ellipsoid(tool, "Core", Vector3.new(0.5, 0.12, 0.7), bladeCF * CFrame.new(0, 0.05, -0.8), s.Core, "Neon")
	end
	if s.Field then
		local field = newPart(tool, "EnergyField", Vector3.new(1.5, 0.3, 2.1), bladeCF * CFrame.new(0, 0, -0.9), s.Field, "ForceField")
		field.Transparency = 0.2
	end
	if s.Rings then
		for i, z in ipairs({-1.4, -1.8}) do
			newPart(tool, "Ring", Vector3.new(0.05, 0.42 + i * 0.05, 0.42 + i * 0.05), CFrame.new(0, 0, z) * ALONG_Z, s.Rings, "Neon", Enum.PartType.Cylinder).Transparency = 0.3
		end
	end
	if s.Glow then
		local light = Instance.new("PointLight")
		light.Color = s.Glow
		light.Range = 8
		light.Brightness = 1.3
		light.Parent = blade
	end
	if s.Sparkles then
		local sparkles = Instance.new("ParticleEmitter")
		sparkles.Rate = 5
		sparkles.Lifetime = NumberRange.new(0.6, 1.2)
		sparkles.Speed = NumberRange.new(0.3, 0.8)
		sparkles.SpreadAngle = Vector2.new(180, 180)
		sparkles.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.12), NumberSequenceKeypoint.new(1, 0)})
		sparkles.LightEmission = 1
		sparkles.Color = ColorSequence.new(s.Sparkles)
		sparkles.Parent = blade
	end

	-- SIZE: shrink the whole shovel evenly
	for _, part in ipairs(tool:GetChildren()) do
		if part:IsA("BasePart") then
			local rotation = part.CFrame.Rotation
			part.Size = part.Size * SCALE
			part.CFrame = CFrame.new(part.Position * SCALE) * rotation
		end
	end
	for _, emitter in ipairs(tool:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.12 * SCALE), NumberSequenceKeypoint.new(1, 0)})
		end
	end

	-- how it sits in the hand (points forward and down)
	tool.Grip = CFrame.new(0, 0, 1.4 * SCALE) * CFrame.Angles(math.rad(50), 0, 0)

	-- weld everything to the handle
	for _, part in ipairs(tool:GetChildren()) do
		if part:IsA("BasePart") and part ~= handle then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = handle
			weld.Part1 = part
			weld.Parent = handle
		end
	end

	return tool
end
