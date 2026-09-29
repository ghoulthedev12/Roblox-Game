-- ShovelModels (ModuleScript in ReplicatedStorage)
-- Builds a detailed, individually styled model for every shovel.
-- World 1's shovels each have a hand-made cartoon design (see CUSTOM below); any other
-- shovel is built from its STYLES entry. The server uses it for the tools and the shop
-- displays, the client uses it to draw 3D shovel icons in the UI.

local SCALE = 0.62 -- overall size of the shovels
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
	newPart(tool, "BladeTip", Vector3.new(0.08, 1.3, 1.3), b * CFrame.new(0, 0, -1.25) * CFrame.Angles(0, 0, math.rad(90)), s.Blade, s.BladeMat, Enum.PartType.Cylinder) -- rounded end
	newPart(tool, "LipL", Vector3.new(0.26, 0.08, 1.25), b * CFrame.new(-0.72, 0.06, -0.62) * CFrame.Angles(0, 0, math.rad(-22)), s.Blade, s.BladeMat)
	newPart(tool, "LipR", Vector3.new(0.26, 0.08, 1.25), b * CFrame.new(0.72, 0.06, -0.62) * CFrame.Angles(0, 0, math.rad(22)), s.Blade, s.BladeMat)
	-- raised spine down the back of the blade
	newPart(tool, "Spine", Vector3.new(0.16, 0.07, 1.0), b * CFrame.new(0, 0.07, -0.5), s.Metal, s.MetalMat)
	-- rolled foot step on top
	newPart(tool, "FootStep", Vector3.new(1.45, 0.13, 0.13), b, s.Metal, s.MetalMat, Enum.PartType.Cylinder)
	if s.Edge then
		newPart(tool, "EdgeL", Vector3.new(0.05, 0.1, 1.2), b * CFrame.new(-0.86, 0.12, -0.62) * CFrame.Angles(0, 0, math.rad(-22)), s.Edge, "Neon")
		newPart(tool, "EdgeR", Vector3.new(0.05, 0.1, 1.2), b * CFrame.new(0.86, 0.12, -0.62) * CFrame.Angles(0, 0, math.rad(22)), s.Edge, "Neon")
		newPart(tool, "EdgeTip", Vector3.new(0.7, 0.1, 0.05), b * CFrame.new(0, 0.02, -1.88), s.Edge, "Neon")
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
	newPart(tool, "BladeTip", Vector3.new(0.07, 1.0, 1.0), b * CFrame.new(0, 0, -0.7) * CFrame.Angles(0, 0, math.rad(90)), s.Blade, s.BladeMat, Enum.PartType.Cylinder) -- rounded end
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
-- HAND-MADE CARTOON SHOVELS FOR WORLD 1
-- Tool space: the shaft runs along Z, the grip is at +Z, the blade at -Z.
-- `k.blade` is "blade space": 0 = top of the blade, -Z = toward the tip, +Y = the front face.
---------------------------------------------------------------------
local function kit(tool)
	local k = {}
	function k.part(name, size, cf, color, material, shape)
		return newPart(tool, name, size, cf, color, material or "SmoothPlastic", shape)
	end
	function k.ball(name, d, cf, color, material)
		return newPart(tool, name, Vector3.new(d, d, d), cf, color, material or "SmoothPlastic", Enum.PartType.Ball)
	end
	function k.blob(name, size, cf, color, material)
		return ellipsoid(tool, name, size, cf, color, material or "SmoothPlastic")
	end
	function k.rodZ(name, length, diameter, z, color, material) -- round bar on the shaft line
		return cylinderZ(tool, name, length, diameter, z, color, material or "SmoothPlastic")
	end
	function k.rodX(name, length, diameter, cf, color, material) -- round bar across (along X of cf)
		return newPart(tool, name, Vector3.new(length, diameter, diameter), cf, color, material or "SmoothPlastic", Enum.PartType.Cylinder)
	end
	function k.bar(name, a, b, thickness, color, material)
		return bar(tool, name, a, b, thickness, color, material or "SmoothPlastic")
	end
	k.blade = CFrame.new(0, -0.05, -2.7) * CFrame.Angles(math.rad(-14), 0, 0)
	return k
end

-- shared pieces ------------------------------------------------------
-- World 1 shovels are short and chunky: the shaft runs from the socket (-2.3) to TOP
local TOP = 1.6
local function shaft(k, color, material, diameter)
	k.rodZ("Shaft", TOP + 2.3, diameter or 0.3, (TOP - 2.3) / 2, color, material)
end

local function socket(k, color, material)
	k.rodZ("Socket", 0.9, 0.44, -2.35, color, material)
	k.rodZ("SocketLip", 0.14, 0.5, -1.95, color, material)
end

local function dGrip(k, frameColor, frameMat, barColor, barMat)
	k.bar("GripSideL", Vector3.new(0, 0, TOP - 0.15), Vector3.new(-0.5, 0, TOP + 0.5), 0.2, frameColor, frameMat)
	k.bar("GripSideR", Vector3.new(0, 0, TOP - 0.15), Vector3.new(0.5, 0, TOP + 0.5), 0.2, frameColor, frameMat)
	k.rodX("GripBar", 1.15, 0.28, CFrame.new(0, 0, TOP + 0.52), barColor, barMat)
	k.hold = TOP + 0.5 -- the right hand holds the D bar
end

local function tGrip(k, barColor, barMat, capColor, capMat)
	k.rodX("TBar", 1.2, 0.3, CFrame.new(0, 0, TOP), barColor, barMat)
	k.ball("TCapL", 0.4, CFrame.new(-0.62, 0, TOP), capColor, capMat)
	k.ball("TCapR", 0.4, CFrame.new(0.62, 0, TOP), capColor, capMat)
	k.hold = TOP -- the right hand holds the T bar
end

-- a chunky cartoon spade blade: wide plate, rounded end, curled-up sides, a foot step
local function spade(k, color, material, width, stepColor)
	width = width or 1.7
	local b = k.blade
	local plate = k.part("Blade", Vector3.new(width, 0.12, 1.5), b * CFrame.new(0, 0, -0.75), color, material)
	k.part("BladeTip", Vector3.new(0.12, width, width), b * CFrame.new(0, 0, -1.5) * CFrame.Angles(0, 0, math.rad(90)), color, material, Enum.PartType.Cylinder) -- rounded end
	k.part("LipL", Vector3.new(0.32, 0.12, 1.5), b * CFrame.new(-width / 2 - 0.1, 0.08, -0.75) * CFrame.Angles(0, 0, math.rad(-25)), color, material)
	k.part("LipR", Vector3.new(0.32, 0.12, 1.5), b * CFrame.new(width / 2 + 0.1, 0.08, -0.75) * CFrame.Angles(0, 0, math.rad(25)), color, material)
	k.rodX("FootStep", width + 0.3, 0.2, b, stepColor or color, material)
	return plate
end

local function light(part, color, range)
	local l = Instance.new("PointLight")
	l.Color = color
	l.Range = range or 6
	l.Brightness = 0.6
	l.Parent = part
end

local CUSTOM = {}

-- Rusty Shovel: taped-up wooden shaft, chipped rusty blade with a bolted-on patch
CUSTOM.RustyShovel = function(k)
	local wood, tape, rust = rgb(128, 88, 58), rgb(170, 170, 176), rgb(168, 92, 52)
	shaft(k, wood, "Wood")
	dGrip(k, wood, "Wood", rgb(80, 80, 86), "Fabric")
	k.rodZ("Tape", 0.5, 0.35, 0.4, tape, "Fabric")
	k.rodZ("Tape", 0.35, 0.35, -1.2, tape, "Fabric")
	socket(k, rgb(112, 72, 48), "CorrodedMetal")
	local b = k.blade
	spade(k, rust, "CorrodedMetal")
	for i, pos in ipairs({Vector3.new(-0.4, 0.07, -0.5), Vector3.new(0.45, 0.07, -1.05), Vector3.new(-0.15, 0.07, -1.45)}) do
		k.blob("RustSpot", Vector3.new(0.34 + i * 0.05, 0.03, 0.26), b * CFrame.new(pos), rgb(110, 58, 34))
	end
	k.part("Patch", Vector3.new(0.62, 0.05, 0.5), b * CFrame.new(0.35, 0.08, -0.55), rgb(150, 152, 158), "Metal")
	for _, o in ipairs({Vector3.new(-0.22, 0, -0.18), Vector3.new(0.22, 0, -0.18), Vector3.new(-0.22, 0, 0.18), Vector3.new(0.22, 0, 0.18)}) do
		k.ball("PatchBolt", 0.1, b * CFrame.new(Vector3.new(0.35, 0.12, -0.55) + o), rgb(200, 200, 205), "Metal")
	end
	k.part("Chip", Vector3.new(0.34, 0.14, 0.34), b * CFrame.new(-0.72, 0, -1.28) * CFrame.Angles(0, math.rad(45), 0), rgb(46, 36, 30))
end

-- Plastic Beach Shovel: chunky toy with a scoop, ball-ended T grip and a bucket charm
CUSTOM.PlasticShovel = function(k)
	local blue, red, yellow = rgb(70, 150, 255), rgb(255, 96, 96), rgb(255, 212, 70)
	shaft(k, blue, "SmoothPlastic", 0.38)
	tGrip(k, red, "SmoothPlastic", yellow, "SmoothPlastic")
	socket(k, red, "SmoothPlastic")
	local b = k.blade
	local bowl = k.blob("Blade", Vector3.new(2.1, 0.3, 2.3), b * CFrame.new(0, 0, -1.05), yellow)
	bowl.Reflectance = 0.1
	k.blob("ScoopRim", Vector3.new(2.25, 0.16, 2.45), b * CFrame.new(0, -0.06, -1.05), red)
	k.ball("Star", 0.3, b * CFrame.new(0.45, 0.16, -0.7), rgb(255, 255, 255))
	-- little bucket charm hanging off the shaft
	k.part("CharmString", Vector3.new(0.04, 0.56, 0.04), CFrame.new(0, -0.47, 0.6), rgb(255, 255, 255))
	k.part("Bucket", Vector3.new(0.4, 0.5, 0.5), CFrame.new(0, -0.95, 0.6) * CFrame.Angles(0, 0, math.rad(90)), rgb(96, 226, 190), "SmoothPlastic", Enum.PartType.Cylinder)
end

-- Garden Spade: green painted shaft, shiny pointed blade with little painted flowers
CUSTOM.GardenSpade = function(k)
	local green, dark = rgb(90, 176, 96), rgb(58, 128, 66)
	shaft(k, green, "SmoothPlastic")
	for z = -1.4, 0.9, 0.75 do
		k.rodZ("Stripe", 0.12, 0.32, z, rgb(246, 247, 252))
	end
	dGrip(k, dark, "SmoothPlastic", dark, "SmoothPlastic")
	socket(k, dark, "SmoothPlastic")
	local b = k.blade
	spade(k, rgb(200, 206, 216), "Metal", 1.55, dark).Reflectance = 0.15
	for _, spot in ipairs({Vector3.new(-0.35, 0.09, -0.55), Vector3.new(0.35, 0.09, -1.05)}) do
		k.ball("FlowerCore", 0.22, b * CFrame.new(spot), rgb(255, 212, 70))
		for i = 0, 4 do
			local a = math.rad(i * 72)
			k.ball("Petal", 0.2, b * CFrame.new(spot + Vector3.new(math.cos(a) * 0.19, -0.02, math.sin(a) * 0.19)), rgb(255, 140, 190))
		end
	end
	k.blob("Leaf", Vector3.new(0.55, 0.07, 0.28), CFrame.new(0.2, 0.12, -1.6) * CFrame.Angles(0, math.rad(30), math.rad(20)), rgb(110, 200, 110))
end

-- Iron Shovel: sturdy dark wood, leather wrap, iron bands, riveted heavy blade
CUSTOM.IronShovel = function(k)
	local wood, iron = rgb(98, 68, 46), rgb(76, 78, 86)
	shaft(k, wood, "Wood", 0.33)
	k.rodZ("LeatherWrap", 1.1, 0.38, 0.8, rgb(128, 84, 52), "Fabric")
	for _, z in ipairs({0.6, -0.9}) do
		k.rodZ("IronBand", 0.16, 0.4, z, iron, "Metal")
	end
	dGrip(k, iron, "Metal", wood, "Wood")
	socket(k, iron, "Metal")
	local b = k.blade
	k.part("BladeBacking", Vector3.new(1.95, 0.08, 1.7), b * CFrame.new(0, -0.05, -0.8), iron, "Metal")
	spade(k, rgb(128, 132, 142), "Metal", 1.75, iron).Reflectance = 0.1
	for i = -2, 2 do
		k.ball("Rivet", 0.14, b * CFrame.new(i * 0.34, 0.08, -0.18), rgb(190, 192, 198), "Metal")
	end
end

-- Steel Spade: sleek dark shaft, polished pointed blade with a sky-blue racing stripe
CUSTOM.SteelSpade = function(k)
	local dark, steel, sky = rgb(52, 58, 72), rgb(206, 214, 228), rgb(92, 186, 255)
	shaft(k, dark, "Metal", 0.28)
	k.rodZ("Grip", 1, 0.34, 0.95, rgb(30, 32, 40), "Fabric")
	tGrip(k, rgb(30, 32, 40), "Fabric", steel, "Metal")
	socket(k, steel, "Metal")
	local b = k.blade
	local plate = spade(k, steel, "Metal", 1.5)
	plate.Reflectance = 0.3
	k.part("RacingStripe", Vector3.new(0.2, 0.13, 1.7), b * CFrame.new(0, 0.02, -0.9), sky)
	k.part("TipGuard", Vector3.new(0.14, 0.6, 0.6), b * CFrame.new(0, 0.01, -1.95) * CFrame.Angles(0, 0, math.rad(90)), sky, "SmoothPlastic", Enum.PartType.Cylinder)
	k.ball("StatusLight", 0.16, CFrame.new(0, 0.22, -2.1), sky, "Neon")
end

-- Golden Shovel: gold everything, a jeweled socket, a little crown on the foot step
CUSTOM.GoldenShovel = function(k)
	local gold, deep = rgb(255, 202, 72), rgb(214, 156, 40)
	shaft(k, gold, "Metal", 0.3)
	for _, z in ipairs({1.0, 0.7}) do
		k.rodZ("Wrap", 0.2, 0.34, z, rgb(150, 30, 50), "Fabric")
	end
	dGrip(k, gold, "Metal", rgb(150, 30, 50), "Fabric")
	socket(k, deep, "Metal")
	local gems = {rgb(230, 50, 80), rgb(70, 130, 255), rgb(60, 205, 130)}
	for i, color in ipairs(gems) do
		local a = math.rad(i * 120)
		k.ball("Gem", 0.2, CFrame.new(math.cos(a) * 0.22, math.sin(a) * 0.22, -2.3), color, "Glass")
	end
	local b = k.blade
	spade(k, gold, "Metal", 1.7, deep).Reflectance = 0.35
	for i = -1, 1 do
		k.part("CrownSpike", Vector3.new(0.18, 0.12, 0.3), b * CFrame.new(i * 0.45, 0.05, 0.22) * CFrame.Angles(0, math.rad(45), 0), deep, "Metal")
		k.ball("CrownJewel", 0.12, b * CFrame.new(i * 0.45, 0.1, 0.35), gems[i + 2], "Glass")
	end
	local sparkles = Instance.new("ParticleEmitter")
	sparkles.Rate = 4
	sparkles.Lifetime = NumberRange.new(0.6, 1.2)
	sparkles.Speed = NumberRange.new(0.3, 0.8)
	sparkles.SpreadAngle = Vector2.new(180, 180)
	sparkles.LightEmission = 0.6
	sparkles.Color = ColorSequence.new(rgb(255, 230, 150))
	sparkles.Parent = k.ball("SparkleSource", 0.05, b * CFrame.new(0, 0.1, -0.8), gold)
end

-- RGB Gamer Shovel: black with RGB strips, a controller grip and WASD keycaps on the blade
CUSTOM.GamerShovel = function(k)
	local black = rgb(30, 30, 38)
	shaft(k, black, "Metal", 0.3)
	local strips = {rgb(230, 90, 200), rgb(80, 200, 230), rgb(110, 225, 130)}
	for i, color in ipairs(strips) do
		local a = math.rad(i * 120)
		k.part("RGBStrip", Vector3.new(0.05, 0.05, 2.8), CFrame.new(math.cos(a) * 0.15, math.sin(a) * 0.15, -0.4), color, "Neon")
	end
	-- controller-shaped grip with thumbsticks and buttons
	k.blob("Controller", Vector3.new(1.5, 0.4, 0.7), CFrame.new(0, 0, TOP + 0.15), rgb(44, 44, 54))
	k.hold = TOP + 0.15
	k.ball("StickL", 0.2, CFrame.new(-0.35, 0.2, TOP + 0.15), rgb(120, 122, 132))
	for i, color in ipairs({rgb(110, 225, 130), rgb(230, 90, 110), rgb(80, 160, 240), rgb(240, 200, 80)}) do
		local a = math.rad(i * 90)
		k.ball("Button", 0.11, CFrame.new(0.38 + math.cos(a) * 0.12, 0.2, TOP + 0.15 + math.sin(a) * 0.12), color)
	end
	socket(k, black, "Metal")
	local b = k.blade
	spade(k, rgb(40, 40, 52), "Metal", 1.7)
	k.part("EdgeL", Vector3.new(0.06, 0.14, 1.4), b * CFrame.new(-0.95, 0.14, -0.75) * CFrame.Angles(0, 0, math.rad(-25)), strips[1], "Neon")
	k.part("EdgeR", Vector3.new(0.06, 0.14, 1.4), b * CFrame.new(0.95, 0.14, -0.75) * CFrame.Angles(0, 0, math.rad(25)), strips[2], "Neon")
	for _, key in ipairs({Vector3.new(0, 0, -0.55), Vector3.new(-0.34, 0, -0.9), Vector3.new(0, 0, -0.9), Vector3.new(0.34, 0, -0.9)}) do
		k.part("Keycap", Vector3.new(0.28, 0.14, 0.28), b * CFrame.new(key + Vector3.new(0, 0.1, 0)), rgb(236, 236, 244))
	end
end

-- Tectonic Auger: industrial drill with hazard bands, a motor and a spiral auger bit
CUSTOM.TectonicAuger = function(k)
	local steel, hazard, ink = rgb(172, 176, 186), rgb(240, 196, 60), rgb(44, 44, 54)
	shaft(k, rgb(78, 80, 88), "Metal", 0.34)
	for i = 0, 5 do
		k.rodZ("Hazard", 0.18, 0.38, 1.1 - i * 0.18, i % 2 == 0 and hazard or ink)
	end
	tGrip(k, rgb(36, 36, 42), "Fabric", hazard, "SmoothPlastic")
	local motor = k.part("Motor", Vector3.new(0.75, 0.65, 1), CFrame.new(0, 0, -1.35), hazard)
	k.part("MotorVent", Vector3.new(0.5, 0.04, 0.6), CFrame.new(0, 0.34, -1.35), rgb(230, 130, 70), "Neon")
	light(motor, rgb(230, 150, 90), 5)
	k.rodZ("Core", 2.6, 0.26, -2.95, steel, "Metal")
	-- spiral flights: shrinking discs, each turned a bit more
	for i = 0, 7 do
		local d = 1.4 - i * 0.14
		k.part("Flight", Vector3.new(0.1, d, d), CFrame.new(0, 0, -2.1 - i * 0.3) * CFrame.Angles(0, math.rad(90), 0) * CFrame.Angles(math.rad(i * 25), 0, math.rad(12)), steel, "Metal", Enum.PartType.Cylinder)
	end
	k.ball("DrillTip", 0.3, CFrame.new(0, 0, -4.35), hazard)
end

-- Singularity Spade: dark foil blade holding a tiny black hole with a glowing disk
CUSTOM.SingularitySpade = function(k)
	local dark, lilac, chrome = rgb(34, 35, 42), rgb(178, 158, 255), rgb(150, 154, 162)
	shaft(k, dark, "Metal", 0.3)
	for _, z in ipairs({1, 0, -1}) do
		k.rodZ("Ring", 0.12, 0.38, z, lilac)
	end
	dGrip(k, chrome, "Foil", dark, "Fabric")
	socket(k, chrome, "Foil")
	local b = k.blade
	spade(k, rgb(56, 58, 66), "Foil", 1.75, chrome).Reflectance = 0.3
	local hole = b * CFrame.new(0, 0.22, -0.85)
	k.ball("BlackHole", 0.7, hole, rgb(6, 6, 10))
	k.part("AccretionDisk", Vector3.new(0.04, 1.5, 1.5), hole * CFrame.Angles(math.rad(18), 0, math.rad(90)), rgb(220, 140, 100), "Neon", Enum.PartType.Cylinder)
	k.part("InnerDisk", Vector3.new(0.05, 1.05, 1.05), hole * CFrame.Angles(math.rad(18), 0, math.rad(90)), lilac, "Neon", Enum.PartType.Cylinder)
	for i = 0, 2 do
		local a = math.rad(i * 120 + 30)
		k.ball("Orbiter", 0.12, hole * CFrame.new(math.cos(a) * 0.95, 0.1, math.sin(a) * 0.95), lilac, "Neon")
	end
	light(k.ball("HoleGlow", 0.05, hole, dark), rgb(200, 170, 255), 6)
end

---------------------------------------------------------------------
-- THEMED SHOVELS FOR WORLDS 2-9
-- Built from the world's colors (def.Look, see WorldsData). The blade shape and grip come
-- from the shovel, the decorations from the world's theme, and higher tiers get fancier:
-- tier 3+ more decorations, 5+ a glowing rim, 6+ a light, 7 sparkles and a halo.
---------------------------------------------------------------------
local function sparkle(part, color, rate)
	local e = Instance.new("ParticleEmitter")
	e.Rate = rate or 5
	e.Lifetime = NumberRange.new(0.6, 1.2)
	e.Speed = NumberRange.new(0.3, 0.8)
	e.SpreadAngle = Vector2.new(180, 180)
	e.LightEmission = 0.6
	e.Color = ColorSequence.new(color)
	e.Parent = part
end

-- a disc lying flat on the blade's front face (radius r, at blade position x, z)
local function faceDisc(k, name, d, x, z, color, material, lift)
	return k.part(name, Vector3.new(0.05, d, d), k.blade * CFrame.new(x, lift or 0.09, z) * CFrame.Angles(0, 0, math.rad(90)), color, material, Enum.PartType.Cylinder)
end

local DECO = {}

-- little five-petal blossoms, and a paper lantern charm on fancier ones
DECO.Sakura = function(k, c, tier)
	local b = k.blade
	local spots = {Vector3.new(-0.35, 0, -0.5), Vector3.new(0.4, 0, -1.05), Vector3.new(-0.2, 0, -1.4), Vector3.new(0.3, 0, -0.35)}
	for i = 1, math.min(#spots, 1 + tier // 2) do
		local spot = spots[i] + Vector3.new(0, 0.1, 0)
		k.ball("FlowerCore", 0.16, b * CFrame.new(spot), c.Accent)
		for p = 0, 4 do
			local a = math.rad(p * 72 + i * 20)
			k.ball("Petal", 0.2, b * CFrame.new(spot + Vector3.new(math.cos(a) * 0.17, -0.02, math.sin(a) * 0.17)), i % 2 == 0 and c.Second or c.Main)
		end
	end
	k.rodZ("Wrap", 0.5, 0.36, 0.9, c.Second, "Fabric")
	if tier >= 4 then
		k.part("LanternString", Vector3.new(0.04, 0.5, 0.04), CFrame.new(0, -0.45, 0.3), c.Dark)
		k.blob("Lantern", Vector3.new(0.5, 0.62, 0.5), CFrame.new(0, -0.95, 0.3), rgb(255, 110, 110))
		k.ball("LanternGlow", 0.3, CFrame.new(0, -0.95, 0.3), c.Accent, "Neon")
	end
end

-- stars on the blade, a ringed planet on the socket, an orbiting moon on fancy ones
DECO.Galaxy = function(k, c, tier)
	local b = k.blade
	for i = 1, 3 + tier do
		local x = math.sin(i * 2.4) * 0.6
		local z = -0.3 - (i * 0.37) % 1.3
		k.ball("Star", 0.1 + (i % 3) * 0.04, b * CFrame.new(x, 0.1, z), i % 2 == 0 and c.Accent or rgb(255, 255, 255), "Neon")
	end
	k.ball("Planet", 0.5, CFrame.new(0, 0.32, -1.7), c.Main)
	k.part("PlanetRing", Vector3.new(0.04, 0.95, 0.95), CFrame.new(0, 0.32, -1.7) * CFrame.Angles(0, 0, math.rad(90)) * CFrame.Angles(math.rad(20), 0, 0), c.Accent, "SmoothPlastic", Enum.PartType.Cylinder)
	if tier >= 3 then
		k.ball("Moon", 0.26, CFrame.new(0.55, 0.2, 0.3), rgb(220, 224, 240))
		for i = 0, 7 do
			local a = math.rad(i * 45)
			k.ball("OrbitDot", 0.06, CFrame.new(math.cos(a) * 0.55, math.sin(a) * 0.55, 0.3), c.Glow, "Neon")
		end
	end
end

-- ice shards sticking out of the blade and the socket
DECO.Frost = function(k, c, tier)
	local b = k.blade
	for i = 1, 2 + tier do
		local side = i % 2 == 0 and 1 or -1
		local z = -0.3 - (i * 0.29) % 1.2
		k.part("IceShard", Vector3.new(0.16, 0.16, 0.45 + (i % 3) * 0.12), b * CFrame.new(side * (0.35 + (i % 3) * 0.12), 0.18, z) * CFrame.Angles(math.rad(-55), side * math.rad(20), math.rad(45)), c.Main, "Glass").Transparency = 0.15
	end
	for i = 0, 2 do
		local a = math.rad(i * 120)
		k.part("SocketShard", Vector3.new(0.14, 0.14, 0.5), CFrame.new(math.cos(a) * 0.25, math.sin(a) * 0.25, -1.9) * CFrame.Angles(math.sin(a) * 0.6, -math.cos(a) * 0.6, 0), c.Second, "Glass")
	end
	k.rodZ("FurWrap", 0.6, 0.4, 0.85, c.Second, "Fabric")
end

-- a golden sun on the blade with rays; chrome bands on the shaft
DECO.Dunes = function(k, c, tier)
	local b = k.blade
	faceDisc(k, "Sun", 0.6, 0, -0.85, c.Main, "Metal", 0.1).Reflectance = 0.25
	for i = 0, 7 do
		local a = math.rad(i * 45)
		k.part("SunRay", Vector3.new(0.08, 0.06, 0.28), b * CFrame.new(math.cos(a) * 0.48, 0.1, -0.85 + math.sin(a) * 0.48) * CFrame.Angles(0, -a + math.pi / 2, 0), c.Accent)
	end
	for _, z in ipairs({0.9, -0.2, -1.2}) do
		k.rodZ("ChromeBand", 0.14, 0.38, z, c.Second, "Metal").Reflectance = 0.3
	end
	if tier >= 4 then
		k.part("Pyramid", Vector3.new(0.5, 0.4, 0.5), CFrame.new(0, 0, TOP + 0.8), c.Main, "Metal", Enum.PartType.Wedge)
	end
end

-- bubbles floating off the blade, a seashell, and a pearl
DECO.Coral = function(k, c, tier)
	local b = k.blade
	for i = 1, 3 + tier do
		local bubble = k.ball("Bubble", 0.12 + (i % 3) * 0.08, b * CFrame.new(math.sin(i * 1.7) * 0.7, 0.25 + (i % 4) * 0.12, -0.3 - (i * 0.31) % 1.3), rgb(220, 250, 255), "Glass")
		bubble.Transparency = 0.35
	end
	k.blob("Shell", Vector3.new(0.6, 0.18, 0.5), b * CFrame.new(0.35, 0.1, -0.5), c.Main)
	for i = -1, 1 do
		k.part("ShellRidge", Vector3.new(0.05, 0.08, 0.42), b * CFrame.new(0.35 + i * 0.14, 0.18, -0.52) * CFrame.Angles(0, i * 0.35, 0), c.Accent)
	end
	k.ball("Pearl", 0.26, b * CFrame.new(-0.3, 0.16, -1.05), rgb(250, 246, 255), "SmoothPlastic").Reflectance = 0.3
	k.rodZ("Seaweed", 0.6, 0.36, 0.85, c.Second, "Fabric")
end

-- candy stripes on the shaft, sprinkles on the blade, a lollipop on the grip
DECO.Candy = function(k, c, tier)
	local b = k.blade
	for z = -1.6, 1.3, 0.36 do
		k.rodZ("CandyStripe", 0.14, 0.34, z, c.Main)
	end
	local sprinkleColors = {c.Main, c.Second, c.Accent, rgb(120, 170, 255), rgb(255, 255, 255)}
	for i = 1, 6 + tier * 2 do
		local x = math.sin(i * 2.1) * 0.65
		local z = -0.2 - (i * 0.23) % 1.35
		k.part("Sprinkle", Vector3.new(0.06, 0.06, 0.2), b * CFrame.new(x, 0.09, z) * CFrame.Angles(0, i, 0), sprinkleColors[i % #sprinkleColors + 1])
	end
	if tier >= 3 then
		k.part("LollipopStick", Vector3.new(0.06, 0.06, 0.6), CFrame.new(0.62, 0, TOP + 0.3), rgb(255, 255, 255))
		k.part("Lollipop", Vector3.new(0.12, 0.6, 0.6), CFrame.new(0.62, 0, TOP + 0.7) * CFrame.Angles(0, math.rad(90), 0), c.Main, "SmoothPlastic", Enum.PartType.Cylinder)
		k.part("LollipopSwirl", Vector3.new(0.13, 0.32, 0.32), CFrame.new(0.62, 0, TOP + 0.7) * CFrame.Angles(0, math.rad(90), 0), c.Accent, "SmoothPlastic", Enum.PartType.Cylinder)
	end
end

-- glowing lava cracks across a dark blade, embers, and a molten core on fancy ones
DECO.Forge = function(k, c, tier)
	local b = k.blade
	local path = {Vector3.new(-0.5, 0, -0.2), Vector3.new(-0.2, 0, -0.6), Vector3.new(-0.45, 0, -1.0), Vector3.new(0, 0, -1.35), Vector3.new(0.3, 0, -0.9), Vector3.new(0.55, 0, -1.2)}
	for i = 1, #path - 1 do
		local p, q = path[i] + Vector3.new(0, 0.08, 0), path[i + 1] + Vector3.new(0, 0.08, 0)
		k.bar("LavaCrack", b * p, b * q, 0.07, c.Glow, "Neon")
	end
	for i = 0, 3 do
		k.rodZ("ObsidianBand", 0.14, 0.36, 0.9 - i * 0.7, c.Dark, "Glass")
	end
	if tier >= 3 then
		k.ball("MoltenCore", 0.36, CFrame.new(0, 0.28, -2.2), c.Glow, "Neon")
	end
	if tier >= 5 then
		for i = -1, 1, 2 do
			k.part("Horn", Vector3.new(0.14, 0.14, 0.55), CFrame.new(i * 0.32, 0.12, -2.15) * CFrame.Angles(math.rad(-30), i * math.rad(35), 0), c.Accent, "Metal")
		end
	end
end

-- a magenta/black "missing texture" checker, floating pixel cubes that don't line up
DECO.Glitch = function(k, c, tier)
	local b = k.blade
	for i = 0, 3 do
		local x, z = (i % 2) * 0.36 - 0.18, -0.55 - math.floor(i / 2) * 0.36
		k.part("MissingTexture", Vector3.new(0.34, 0.06, 0.34), b * CFrame.new(x, 0.08, z), (i == 0 or i == 3) and c.Second or c.Dark)
	end
	for i = 1, 2 + tier do
		local side = i % 2 == 0 and 1 or -1
		k.part("PixelCube", Vector3.new(0.2, 0.2, 0.2), CFrame.new(side * (0.35 + (i % 3) * 0.18), 0.1 + (i % 2) * 0.2, -0.4 - (i * 0.53) % 2.4), i % 3 == 0 and c.Second or c.Main, "Neon")
	end
	-- a ghost copy of the blade, slightly off, like a bad render
	local ghost = k.part("GhostBlade", Vector3.new(1.6, 0.05, 1.4), b * CFrame.new(0.14, 0.2, -0.8), c.Main, "ForceField")
	ghost.Transparency = 0.3
end

local function themed(k, def)
	local look = def.Look
	local c, tier = look.Colors, look.Tier
	local fancy = tier >= 5
	local shaftColor = (tier % 2 == 1) and c.Dark or c.Second
	local bladeColor = (tier % 2 == 1) and c.Main or c.Second
	if look.Theme == "Glitch" or look.Theme == "Forge" then
		shaftColor, bladeColor = c.Dark, (tier % 2 == 1) and c.Second or c.Dark
	end
	shaft(k, shaftColor, fancy and "Metal" or "SmoothPlastic", 0.3)
	if look.Grip == "T" then
		tGrip(k, c.Dark, "Fabric", c.Accent, "SmoothPlastic")
	else
		dGrip(k, shaftColor, "SmoothPlastic", c.Accent, "SmoothPlastic")
	end
	socket(k, c.Accent, fancy and "Metal" or "SmoothPlastic")

	local b = k.blade
	local plate
	if look.Blade == "Scoop" then
		plate = k.blob("Blade", Vector3.new(2.1, 0.3, 2.3), b * CFrame.new(0, 0, -1.05), bladeColor)
		k.blob("ScoopRim", Vector3.new(2.25, 0.16, 2.45), b * CFrame.new(0, -0.06, -1.05), c.Accent)
	elseif look.Blade == "Spoon" then
		plate = k.blob("Blade", Vector3.new(1.8, 0.4, 2.3), b * CFrame.new(0, 0, -1.1), bladeColor)
		k.blob("SpoonShell", Vector3.new(1.95, 0.3, 2.45), b * CFrame.new(0, -0.08, -1.1), c.Dark)
	else
		plate = spade(k, bladeColor, "SmoothPlastic", 1.7, c.Accent)
		if fancy then
			-- glowing rim peeking out around the round end
			k.part("GlowRim", Vector3.new(0.06, 1.85, 1.85), b * CFrame.new(0, -0.05, -1.5) * CFrame.Angles(0, 0, math.rad(90)), c.Glow, "Neon", Enum.PartType.Cylinder)
		end
	end
	plate.Reflectance = fancy and 0.15 or 0.05

	local deco = DECO[look.Theme]
	if deco then deco(k, c, tier) end

	if tier >= 6 then
		light(plate, c.Glow, 7)
	end
	if tier >= 7 then
		sparkle(plate, c.Glow, 6)
		for i = 0, 9 do
			local a = math.rad(i * 36)
			k.ball("Halo", 0.1, CFrame.new(math.cos(a) * 0.62, math.sin(a) * 0.62, TOP + 1.1), c.Accent, "Neon")
		end
	end
end

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

	local custom = CUSTOM[def.Id] or (def.Look and themed)
	local rightZ, leftZ -- where the right and left hands hold the shaft (before scaling)
	if custom then
		local k = kit(tool)
		custom(k, def)
		rightZ = k.hold or TOP
	else
		rightZ = s.Grip == "T" and 2.3 or 2.8
	end
	leftZ = rightZ - 1.3 -- the other hand holds the shaft a little lower
	if not custom then
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
	tool.Grip = CFrame.new(0, 0, rightZ * SCALE) * CFrame.Angles(math.rad(50), 0, 0)
	-- ShovelClient's two-handed pose reads these (distance along the shaft from the handle):
	-- one hand on top of the grip, the other a bit lower on the shaft
	tool:SetAttribute("TopHoldZ", rightZ * SCALE)
	tool:SetAttribute("LowHoldZ", leftZ * SCALE)

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
