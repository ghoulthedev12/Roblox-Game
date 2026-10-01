-- WorldBuilder (ModuleScript in ServerScriptService)
-- Builds worlds 2-9: a floating terrain island around the pit (in the world's own ground
-- material), an invisible safety wall at the edge, the candy rim ring and zone rings, and a
-- themed set of decorations: a big landmark behind the pit, props around the island and
-- lamps near the rim. Everything stays clear of the Shovel Shop (30°) and World Gate (-30°).
-- DigManager calls it once per world when the server starts, after building the shop and gate.

local Architecture = require(script.Parent:WaitForChild("Architecture"))
local DigSiteStyle = require(script.Parent:WaitForChild("DigSiteStyle"))
local GameConfig = require(game:GetService("ReplicatedStorage"):WaitForChild("GameConfig"))

local terrain = workspace.Terrain
local rgb = Color3.fromRGB
local PLASTIC = Enum.Material.SmoothPlastic

-- Angles (degrees, around the pit) where the island props stand. 30 and -30 (330) are
-- the shop and the gate, so they're left out; 180 is the landmark behind the pit.
local PROP_ANGLES = {75, 110, 145, 215, 250, 285}
local LAMP_ANGLES = {90, 135, 180, 225, 270}
local PROP_DISTANCE = 104
local LAMP_DISTANCE = 58
local LANDMARK_DISTANCE = 96

-- Registers the world's colors as palette finishes ("W2Main", "W2Glow", ...)
local function finishes(world)
	local look = world.Look
	local key = "W" .. world.Id
	local P = Architecture.Palette
	P[key .. "Main"] = {Color = look.Main, Material = PLASTIC}
	P[key .. "Second"] = {Color = look.Second, Material = PLASTIC}
	P[key .. "Dark"] = {Color = look.Dark, Material = PLASTIC}
	P[key .. "Accent"] = {Color = look.Accent, Material = PLASTIC}
	P[key .. "Glow"] = {Color = look.Glow, Material = Enum.Material.Neon}
	P[key .. "Crystal"] = {Color = look.Main, Material = Enum.Material.Glass, Transparency = 0.25, Reflectance = 0.1}
	P[key .. "Metal"] = {Color = look.Second, Material = Enum.Material.Metal, Reflectance = 0.2}
	return {
		Main = key .. "Main", Second = key .. "Second", Dark = key .. "Dark", Accent = key .. "Accent",
		Glow = key .. "Glow", Crystal = key .. "Crystal", Metal = key .. "Metal",
	}
end

local function custom(name, color, material, extra)
	local finish = {Color = color, Material = material or PLASTIC}
	if extra then
		for k, v in pairs(extra) do finish[k] = v end
	end
	Architecture.Palette[name] = finish
	return name
end

-- CFrame on the ground at an angle/distance around the pit, facing the pit
local function spot(angle, distance, height)
	local a = math.rad(angle)
	local pos = Vector3.new(math.cos(a) * distance, height or 0, math.sin(a) * distance)
	return CFrame.lookAt(pos, Vector3.new(0, pos.Y, 0))
end

local function particles(part, color, props)
	local e = Instance.new("ParticleEmitter")
	e.Color = ColorSequence.new(color)
	e.LightEmission = 0.3
	for k, v in pairs(props) do e[k] = v end
	e.Parent = part
	return e
end

---------------------------------------------------------------------
-- THE ISLAND (terrain)
---------------------------------------------------------------------
local function buildIsland(world, rng)
	local origin = world.Origin
	local R = world.IslandRadius
	local wall = Enum.Material[world.WallMaterial]
	local top = Enum.Material[world.TopMaterial]
	-- thick top slab, then an underside that narrows into the pit column (a floating island)
	terrain:FillCylinder(CFrame.new(origin + Vector3.new(0, -14, 0)), 28, R, wall)
	local layers = {{0.82, -34, 14}, {0.64, -52, 22}, {0.48, -76, 28}}
	for _, layer in ipairs(layers) do
		terrain:FillCylinder(CFrame.new(origin + Vector3.new(0, layer[2], 0)), layer[3], R * layer[1], wall)
	end
	-- lumpy rocks hanging under the edge
	for i = 1, 14 do
		local a = rng:NextNumber(0, math.pi * 2)
		local d = rng:NextNumber(R * 0.45, R * 0.85)
		terrain:FillBall(origin + Vector3.new(math.cos(a) * d, rng:NextNumber(-60, -30), math.sin(a) * d), rng:NextNumber(10, 18), wall)
	end
	-- rounded tip under the pit column
	terrain:FillBall(origin + Vector3.new(0, world.Zones[#world.Zones].Bottom - 20, 0), 40, wall)
	-- the surface
	terrain:FillCylinder(CFrame.new(origin + Vector3.new(0, -2, 0)), 4, R, top)
	-- bring the surface down to y = 0, where the gate, shop and decorations stand
	GameConfig.FlattenGround(terrain, origin, R * 2 + 8)
	-- a few soft hills near the edge (away from the shop and gate)
	for _, angle in ipairs({95, 160, 200, 265}) do
		local a = math.rad(angle + rng:NextNumber(-8, 8))
		local d = R - 12
		terrain:FillBall(origin + Vector3.new(math.cos(a) * d, -4, math.sin(a) * d), rng:NextNumber(9, 13), top)
	end
end

-- invisible wall around the edge so nobody walks off the island
local function buildEdgeWall(parent, world)
	local R = world.IslandRadius - 3
	local segments = 48
	local folder = Instance.new("Folder")
	folder.Name = "EdgeWall"
	for i = 0, segments - 1 do
		local a = (i + 0.5) / segments * math.pi * 2
		local pos = world.Origin + Vector3.new(math.cos(a) * R, 20, math.sin(a) * R)
		local p = Instance.new("Part")
		p.Name = "EdgeWall"
		p.Anchored = true
		p.Transparency = 1
		p.CanQuery = false
		p.Size = Vector3.new(2 * math.pi * R / segments + 1, 44, 2)
		p.CFrame = CFrame.lookAt(pos, Vector3.new(world.Origin.X, pos.Y, world.Origin.Z))
		p.Parent = folder
	end
	folder.Parent = parent
end

---------------------------------------------------------------------
-- THEMES: each has Landmark (behind the pit), Props (around the island), Lamp (near the rim)
-- and optional Sky (things floating overhead). b builds relative to the world origin.
---------------------------------------------------------------------
local THEMES = {}

-- NEON SAKURA GROVE --------------------------------------------------
THEMES.Sakura = {
	Landmark = function(b, F, cf)
		local red = custom("SakuraTorii", rgb(236, 84, 96))
		for _, side in ipairs({-1, 1}) do
			b:disc("ToriiFoot", 4.4, 1.2, cf * CFrame.new(side * 11, 0.6, 0), F.Dark)
			b:disc("ToriiPillar", 3, 24, cf * CFrame.new(side * 11, 12.6, 0), red)
		end
		b:roundedBlock("ToriiBeam", Vector3.new(32, 2.2, 3), cf * CFrame.new(0, 25.5, 0), 1, F.Dark)
		b:roundedBlock("ToriiBeamTop", Vector3.new(36, 1.6, 4), cf * CFrame.new(0, 27.4, 0), 1.2, red)
		b:box("ToriiTie", Vector3.new(26, 1.4, 2), cf * CFrame.new(0, 20, 0), red)
		local plaque = b:roundedBlock("ToriiPlaque", Vector3.new(6, 4, 1), cf * CFrame.new(0, 22.8, -0.8), 0.5, F.Dark)
		Architecture.sign(plaque, "SAKURA", nil, Enum.NormalId.Front, rgb(255, 214, 120))
		for i = 0, 5 do
			b:bulb("ToriiLantern", 1.2, cf * CFrame.new(-12.5 + i * 5, 18, -1.2), F.Glow, 8)
		end
	end,
	Props = function(b, F, cf, i, rng)
		-- a round blossom tree; every third spot gets a stone lantern pair instead
		if i % 3 == 0 then
			for _, side in ipairs({-1, 1}) do
				local p = cf * CFrame.new(side * 5, 0, 0)
				b:disc("StoneBase", 3.4, 1, p * CFrame.new(0, 0.5, 0), F.Second)
				b:disc("StonePost", 1.4, 4, p * CFrame.new(0, 3, 0), F.Second)
				b:roundedBlock("LanternBox", Vector3.new(2.6, 2.2, 2.6), p * CFrame.new(0, 6.1, 0), 0.6, F.Accent)
				b:bulb("LanternLight", 1.4, p * CFrame.new(0, 6.1, 0), F.Glow, 12)
				b:disc("LanternRoof", 4, 0.8, p * CFrame.new(0, 7.6, 0), F.Dark)
			end
			return
		end
		local s = rng:NextNumber(1.4, 1.8)
		b:pill("Trunk", (cf * CFrame.new(0, 0, 0)).Position, (cf * CFrame.new(0.8, 10 * s, 0)).Position, 2.2 * s, F.Dark)
		b:pill("Branch", (cf * CFrame.new(0.6, 7 * s, 0)).Position, (cf * CFrame.new(-4 * s, 11 * s, 1)).Position, 1.1 * s, F.Dark)
		b:pill("Branch", (cf * CFrame.new(0.6, 8 * s, 0)).Position, (cf * CFrame.new(4.5 * s, 12 * s, -1)).Position, 1.1 * s, F.Dark)
		local crowns = {Vector3.new(0, 14, 0), Vector3.new(-4.5, 12.5, 1), Vector3.new(4.8, 13, -1), Vector3.new(0.5, 12, 4), Vector3.new(0, 12.5, -4)}
		for c, offset in ipairs(crowns) do
			local crown = b:ball("Blossom", (c == 1 and 9 or 7) * s, cf * CFrame.new(offset * s), c % 2 == 0 and F.Second or F.Main)
			if c == 1 then
				particles(crown, rgb(255, 190, 215), {
					Rate = 3, Lifetime = NumberRange.new(4, 6), Speed = NumberRange.new(1, 2),
					Acceleration = Vector3.new(0.5, -1.2, 0), SpreadAngle = Vector2.new(180, 180),
					Size = NumberSequence.new(0.35), Rotation = NumberRange.new(0, 360), RotSpeed = NumberRange.new(-90, 90),
				})
			end
		end
	end,
	Lamp = function(b, F, cf)
		b:disc("LampBase", 2.2, 0.6, cf * CFrame.new(0, 0.3, 0), F.Dark)
		b:disc("LampPole", 0.6, 6, cf * CFrame.new(0, 3.6, 0), F.Dark)
		b:ellipsoid("PaperLantern", Vector3.new(2, 2.6, 2), cf * CFrame.new(0, 7.6, 0), custom("SakuraPaper", rgb(255, 120, 130)))
		b:bulb("LanternGlow", 0.9, cf * CFrame.new(0, 7.6, 0), F.Glow, 10)
	end,
}

-- GALAXY DRIFT ------------------------------------------------------
THEMES.Galaxy = {
	Landmark = function(b, F, cf)
		-- a giant ringed planet floating over the island, on a beam of light
		local planet = cf * CFrame.new(0, 48, 0)
		b:ball("GiantPlanet", 30, planet, F.Main)
		b:ellipsoid("PlanetBand", Vector3.new(30.4, 6, 30.4), planet * CFrame.new(0, 4, 0), F.Accent)
		b:ring("PlanetRing", planet * CFrame.Angles(math.rad(75), 0, math.rad(15)), 24, 2.4, F.Second, 40)
		b:ring("PlanetRingGlow", planet * CFrame.Angles(math.rad(75), 0, math.rad(15)), 27, 0.8, F.Glow, 40)
		b:tiers("Observatory", cf, {{18, 1, F.Dark}, {15, 1.2, F.Second}, {10, 0.6, F.Glow}})
		local beam = b:disc("TractorBeam", 6, 30, cf * CFrame.new(0, 18, 0), F.Crystal, {CanCollide = false})
		beam.Transparency = 0.75
		for i = 1, 3 do
			local a = math.rad(i * 120)
			b:ball("Moon", 4, planet * CFrame.new(math.cos(a) * 22, math.sin(a) * 6, math.sin(a) * 22), "Cloud")
		end
	end,
	Props = function(b, F, cf, i, rng)
		if i % 2 == 0 then
			-- crystal cluster
			for c = 1, 6 do
				local h = rng:NextNumber(5, 12)
				local tilt = CFrame.Angles(rng:NextNumber(-0.4, 0.4), rng:NextNumber(0, 6), rng:NextNumber(-0.4, 0.4))
				b:box("SpaceCrystal", Vector3.new(1.8, h, 1.8), cf * CFrame.new(rng:NextNumber(-3, 3), h / 2 - 1, rng:NextNumber(-3, 3)) * tilt, c % 3 == 0 and F.Crystal or F.Main)
			end
			b:bulb("CrystalGlow", 1.2, cf * CFrame.new(0, 2, 0), F.Glow, 14)
		else
			-- little planet on a pedestal
			b:tiers("Pedestal", cf, {{6, 1, F.Dark}, {3, 5, F.Second}, {4.4, 0.6, F.Glow}})
			local p = cf * CFrame.new(0, 11, 0)
			b:ball("MiniPlanet", 6, p, i % 3 == 0 and F.Accent or "Coral")
			b:ring("MiniRing", p * CFrame.Angles(math.rad(70), 0, 0), 4.6, 0.5, F.Second, 20)
		end
	end,
	Lamp = function(b, F, cf)
		b:disc("LampBase", 2.2, 0.6, cf * CFrame.new(0, 0.3, 0), F.Dark)
		b:disc("LampPole", 0.5, 7, cf * CFrame.new(0, 4, 0), F.Second)
		b:bulb("StarLamp", 1.6, cf * CFrame.new(0, 8.2, 0), F.Glow, 14)
		b:ring("StarLampRing", cf * CFrame.new(0, 8.2, 0), 1.6, 0.25, F.Accent, 12)
	end,
	Sky = function(b, F, rng)
		for i = 1, 10 do
			local a = rng:NextNumber(0, math.pi * 2)
			local d = rng:NextNumber(150, 260)
			local rock = b:ellipsoid("Asteroid", Vector3.new(rng:NextNumber(8, 16), rng:NextNumber(5, 9), rng:NextNumber(8, 14)),
				CFrame.new(math.cos(a) * d, rng:NextNumber(30, 110), math.sin(a) * d) * CFrame.Angles(rng:NextNumber(0, 3), rng:NextNumber(0, 3), 0), F.Dark)
			rock.CanCollide = false
		end
	end,
}

-- FROSTBYTE TUNDRA --------------------------------------------------
THEMES.Frost = {
	Landmark = function(b, F, cf)
		-- a cluster of huge ice spires with a glowing core
		local spires = {{0, 44, 7}, {-8, 30, 5}, {8, 34, 5.5}, {-4, 22, 4}, {5, 20, 4}, {-12, 16, 3.5}, {12, 18, 3.5}}
		for i, s in ipairs(spires) do
			local lean = CFrame.Angles(0, math.rad(i * 40), math.rad(s[1] * 0.8))
			b:box("IceSpire", Vector3.new(s[3], s[2], s[3]), cf * CFrame.new(s[1], s[2] / 2 - 2, (i % 2) * 3) * lean * CFrame.Angles(0, math.rad(45), 0), i % 2 == 0 and F.Crystal or F.Main)
		end
		b:bulb("SpireCore", 4, cf * CFrame.new(0, 10, -2), F.Glow, 24)
		b:tiers("SnowMound", cf, {{30, 2, "White"}, {22, 1.5, "White"}})
	end,
	Props = function(b, F, cf, i, rng)
		if i % 3 == 0 then
			-- a friendly snowman
			b:ball("SnowBottom", 6, cf * CFrame.new(0, 2.6, 0), "White")
			b:ball("SnowMiddle", 4.4, cf * CFrame.new(0, 6.8, 0), "White")
			b:ball("SnowHead", 3.2, cf * CFrame.new(0, 9.9, 0), "White")
			b:disc("HatBrim", 3.4, 0.3, cf * CFrame.new(0, 11.4, 0), F.Dark)
			b:disc("Hat", 2.2, 2, cf * CFrame.new(0, 12.5, 0), F.Dark)
			b:rod("Nose", 1.4, 0.4, cf * CFrame.new(0, 9.9, -1.9) * CFrame.Angles(0, math.rad(90), 0), custom("Carrot", rgb(255, 150, 60)))
			for _, side in ipairs({-1, 1}) do
				b:ball("Eye", 0.4, cf * CFrame.new(side * 0.6, 10.4, -1.45), "Ink")
			end
			b:disc("Scarf", 3.8, 0.8, cf * CFrame.new(0, 8.5, 0), F.Accent)
			return
		end
		-- a round snowy pine
		local s = rng:NextNumber(1.3, 1.7)
		b:disc("PineTrunk", 1.6 * s, 4 * s, cf * CFrame.new(0, 2 * s, 0), custom("PineWood", rgb(120, 86, 80)))
		for t = 0, 3 do
			local y = (4 + t * 3.2) * s
			local d = (9 - t * 2) * s
			b:ellipsoid("PineLayer", Vector3.new(d, 3.4 * s, d), cf * CFrame.new(0, y, 0), custom("PineGreen", rgb(70, 150, 130)))
			b:ellipsoid("PineSnow", Vector3.new(d * 0.8, 1.6 * s, d * 0.8), cf * CFrame.new(0, y + 1.2 * s, 0), "White")
		end
	end,
	Lamp = function(b, F, cf)
		b:disc("LampBase", 2.2, 0.6, cf * CFrame.new(0, 0.3, 0), F.Dark)
		b:disc("LampPole", 0.6, 6, cf * CFrame.new(0, 3.6, 0), F.Second)
		b:box("IceLamp", Vector3.new(1.6, 2.6, 1.6), cf * CFrame.new(0, 7.8, 0) * CFrame.Angles(0, math.rad(45), 0), F.Crystal)
		b:bulb("IceGlow", 0.8, cf * CFrame.new(0, 7.8, 0), F.Glow, 10)
	end,
	Sky = function(b, F)
		-- aurora: thin glowing ribbons high above the far side of the island
		local colors = {F.Glow, custom("AuroraViolet", rgb(170, 130, 255), Enum.Material.Neon)}
		for i = 0, 11 do
			local ribbon = b:box("Aurora", Vector3.new(34, 2, 0.4),
				CFrame.new(-190 + i * 32, 120 + math.sin(i * 0.9) * 10, 170 + math.cos(i * 0.7) * 20) * CFrame.Angles(0, math.sin(i) * 0.4, math.rad(8)), colors[i % 2 + 1])
			ribbon.Transparency = 0.45
			ribbon.CanCollide = false
		end
	end,
}

-- CHROME DUNES ------------------------------------------------------
THEMES.Dunes = {
	Landmark = function(b, F, cf)
		-- stepped chrome pyramid with a golden cap and a glowing eye
		for t = 0, 6 do
			local w = 34 - t * 4.6
			b:box("PyramidStep", Vector3.new(w, 4, w), cf * CFrame.new(0, 2 + t * 4, 0), t % 2 == 0 and F.Metal or F.Main)
		end
		b:box("PyramidCap", Vector3.new(4, 4, 4), cf * CFrame.new(0, 30, 0) * CFrame.Angles(0, math.rad(45), 0), F.Accent)
		b:bulb("PyramidEye", 3, cf * CFrame.new(0, 18, -8.4), F.Glow, 18)
		b:ring("EyeRing", cf * CFrame.new(0, 18, -8.7), 2.6, 0.5, F.Accent, 16)
	end,
	Props = function(b, F, cf, i, rng)
		if i % 2 == 0 then
			-- solar tower
			b:disc("SolarBase", 5, 1, cf * CFrame.new(0, 0.5, 0), F.Dark)
			b:disc("SolarPole", 1, 10, cf * CFrame.new(0, 6, 0), F.Metal)
			b:box("SolarPanel", Vector3.new(9, 0.4, 6), cf * CFrame.new(0, 11.5, 0) * CFrame.Angles(math.rad(-30), 0, 0), custom("SolarGlass", rgb(60, 80, 160), Enum.Material.Glass, {Reflectance = 0.3}))
			b:box("SolarFrame", Vector3.new(9.4, 0.3, 0.4), cf * CFrame.new(0, 11.9, 2.6) * CFrame.Angles(math.rad(-30), 0, 0), F.Metal)
			return
		end
		-- cartoon cactus
		local green = custom("Cactus", rgb(96, 196, 120))
		local h = rng:NextNumber(11, 16)
		b:pill("CactusBody", (cf * CFrame.new(0, 0, 0)).Position, (cf * CFrame.new(0, h, 0)).Position, 3, green)
		b:pill("CactusArm", (cf * CFrame.new(0, h * 0.5, 0)).Position, (cf * CFrame.new(3, h * 0.5, 0)).Position, 1.8, green)
		b:pill("CactusArm", (cf * CFrame.new(3, h * 0.5, 0)).Position, (cf * CFrame.new(3, h * 0.8, 0)).Position, 1.8, green)
		b:pill("CactusArm", (cf * CFrame.new(0, h * 0.35, 0)).Position, (cf * CFrame.new(-2.6, h * 0.35, 0)).Position, 1.6, green)
		b:pill("CactusArm", (cf * CFrame.new(-2.6, h * 0.35, 0)).Position, (cf * CFrame.new(-2.6, h * 0.6, 0)).Position, 1.6, green)
		b:ball("CactusFlower", 1.2, cf * CFrame.new(0, h + 1.4, 0), "Coral")
	end,
	Lamp = function(b, F, cf)
		b:disc("LampBase", 2.2, 0.6, cf * CFrame.new(0, 0.3, 0), F.Dark)
		b:disc("LampPole", 0.6, 6, cf * CFrame.new(0, 3.6, 0), F.Metal)
		b:bulb("SunLamp", 1.6, cf * CFrame.new(0, 7.6, 0), F.Glow, 12)
		b:ring("SunLampRing", cf * CFrame.new(0, 7.6, 0), 1.5, 0.3, F.Accent, 12)
	end,
}

-- CORAL CIRCUIT -----------------------------------------------------
THEMES.Coral = {
	Landmark = function(b, F, cf)
		-- a giant open clam with a glowing pearl, and a coral arch over it
		b:ellipsoid("ClamBottom", Vector3.new(26, 7, 20), cf * CFrame.new(0, 3, 0), F.Main)
		b:ellipsoid("ClamTop", Vector3.new(26, 7, 20), cf * CFrame.new(0, 12, 6) * CFrame.Angles(math.rad(-60), 0, 0), F.Main)
		b:ball("GiantPearl", 8, cf * CFrame.new(0, 8, -1), custom("Pearl", rgb(250, 244, 255), PLASTIC, {Reflectance = 0.3}))
		b:bulb("PearlGlow", 1, cf * CFrame.new(0, 8, -5.2), F.Glow, 20)
		b:ring("CoralArch", cf * CFrame.new(0, 2, 4), 18, 2.6, F.Second, 28, 180, 0)
	end,
	Props = function(b, F, cf, i, rng)
		if i % 2 == 0 then
			-- branching coral
			local colors = {F.Main, F.Second, F.Accent}
			local base = cf.Position
			for c = 1, 5 do
				local a = c * 1.3
				local tip = base + (cf.RightVector * math.cos(a) * 3 + cf.LookVector * math.sin(a) * 3) + Vector3.new(0, rng:NextNumber(6, 11), 0)
				b:pill("Coral", base + Vector3.new(0, 1, 0), tip, 1.4, colors[c % 3 + 1])
				b:ball("CoralTip", 2.2, CFrame.new(tip), colors[c % 3 + 1])
			end
			return
		end
		-- kelp + bubbles
		local green = custom("Kelp", rgb(70, 190, 140))
		for k = -1, 1 do
			local prev = (cf * CFrame.new(k * 2.5, 0, 0)).Position
			for s = 1, 4 do
				local nextPos = (cf * CFrame.new(k * 2.5 + math.sin(s + k) * 1.2, s * 3.2, 0)).Position
				b:pill("Kelp", prev, nextPos, 1, green)
				prev = nextPos
			end
		end
		for s = 1, 5 do
			local bubble = b:ball("Bubble", rng:NextNumber(1, 2.4), cf * CFrame.new(rng:NextNumber(-3, 3), 6 + s * 3, rng:NextNumber(-2, 2)), "Glass")
			bubble.CanCollide = false
		end
	end,
	Lamp = function(b, F, cf)
		-- jellyfish lamp
		b:disc("LampBase", 2.2, 0.6, cf * CFrame.new(0, 0.3, 0), F.Dark)
		b:disc("LampPole", 0.5, 5, cf * CFrame.new(0, 3, 0), F.Second)
		b:ellipsoid("JellyDome", Vector3.new(3.6, 2.4, 3.6), cf * CFrame.new(0, 7.6, 0), F.Crystal)
		b:bulb("JellyGlow", 1, cf * CFrame.new(0, 7.4, 0), F.Glow, 12)
		for t = 0, 3 do
			local a = math.rad(t * 90 + 45)
			b:box("Tentacle", Vector3.new(0.25, 2.6, 0.25), cf * CFrame.new(math.cos(a), 5.4, math.sin(a)), F.Main, {CanCollide = false})
		end
	end,
	Sky = function(b, F, rng)
		for i = 1, 16 do
			local a = rng:NextNumber(0, math.pi * 2)
			local d = rng:NextNumber(20, 110)
			local bubble = b:ball("FloatingBubble", rng:NextNumber(2, 5), CFrame.new(math.cos(a) * d, rng:NextNumber(24, 60), math.sin(a) * d), "Glass")
			bubble.CanCollide = false
		end
	end,
}

-- CANDY MAINFRAME ---------------------------------------------------
THEMES.Candy = {
	Landmark = function(b, F, cf)
		-- a giant cupcake with a cherry, and two huge lollipops
		b:tiers("CupcakeCup", cf, {{24, 8, F.Second}, {25, 1, F.Accent}})
		b:ellipsoid("Frosting", Vector3.new(26, 10, 26), cf * CFrame.new(0, 12, 0), F.Main)
		b:ellipsoid("FrostingTop", Vector3.new(16, 8, 16), cf * CFrame.new(0, 17, 0), custom("Frosting", rgb(255, 238, 246)))
		b:ball("Cherry", 5, cf * CFrame.new(0, 22.5, 0), custom("Cherry", rgb(236, 60, 90)))
		for _, side in ipairs({-1, 1}) do
			local base = cf * CFrame.new(side * 18, 0, 2)
			b:disc("LollipopStick", 1, 24, base * CFrame.new(0, 12, 0), "White")
			local head = base * CFrame.new(0, 26, 0)
			b:rod("LollipopHead", 1.6, 12, head * CFrame.Angles(0, math.rad(90), 0), side < 0 and F.Main or F.Second)
			b:ring("LollipopSwirl", head * CFrame.new(0, 0, -0.9), 3.6, 1, "White", 20)
		end
	end,
	Props = function(b, F, cf, i, rng)
		if i % 3 == 0 then
			-- gumdrops
			for g = 1, 3 do
				local colors = {F.Main, F.Second, F.Accent}
				b:ellipsoid("Gumdrop", Vector3.new(5, 5, 5), cf * CFrame.new((g - 2) * 5, 1.2, (g % 2) * 3), colors[g])
			end
			return
		elseif i % 3 == 1 then
			-- candy cane: striped pole + hook
			local red = custom("CaneRed", rgb(236, 70, 90))
			for s = 0, 7 do
				b:disc("CaneStripe", 1.6, 1.5, cf * CFrame.new(0, 0.75 + s * 1.5, 0), s % 2 == 0 and red or "White")
			end
			b:ring("CaneHook", cf * CFrame.new(1.8, 12, 0), 1.8, 1.6, red, 12, 180, 0)
			return
		end
		-- giant donut
		b:ring("Donut", cf * CFrame.new(0, 5, 0), 3.4, 3.2, custom("Dough", rgb(236, 180, 110)), 20)
		b:ring("DonutIcing", cf * CFrame.new(0, 5, -0.8), 3.4, 2.4, F.Main, 20)
	end,
	Lamp = function(b, F, cf)
		b:disc("LampStick", 0.6, 7, cf * CFrame.new(0, 3.5, 0), "White")
		b:rod("LampCandy", 0.8, 3.4, cf * CFrame.new(0, 8.4, 0) * CFrame.Angles(0, math.rad(90), 0), F.Main)
		b:bulb("LampGlow", 0.8, cf * CFrame.new(0, 8.4, -0.5), F.Glow, 10)
	end,
	Sky = function(b, F, rng)
		for i = 1, 8 do
			local a = rng:NextNumber(0, math.pi * 2)
			local d = rng:NextNumber(60, 180)
			local center = CFrame.new(math.cos(a) * d, rng:NextNumber(50, 90), math.sin(a) * d)
			for c = 1, 3 do
				local puff = b:ball("CottonCandyCloud", rng:NextNumber(8, 12), center * CFrame.new((c - 2) * 6, rng:NextNumber(-1, 2), 0), c % 2 == 0 and F.Main or "Frosting")
				puff.CanCollide = false
			end
		end
	end,
}

-- VOLCANO FORGE -----------------------------------------------------
THEMES.Forge = {
	Landmark = function(b, F, cf, world)
		-- a terrain volcano with a lava crater, glowing lava streams and smoke
		local origin = world.Origin
		local base = origin + cf.Position
		local layers = {{24, 6}, {19, 12}, {14, 18}, {10, 24}}
		for _, layer in ipairs(layers) do
			terrain:FillCylinder(CFrame.new(base + Vector3.new(0, layer[2] / 2, 0)), layer[2], layer[1], Enum.Material.Basalt)
		end
		terrain:FillCylinder(CFrame.new(base + Vector3.new(0, 22, 0)), 4, 7, Enum.Material.CrackedLava)
		local lava = b:disc("LavaPool", 12, 0.6, cf * CFrame.new(0, 24.3, 0), F.Glow)
		lava.Material = Enum.Material.Neon
		b:bulb("LavaLight", 1, cf * CFrame.new(0, 26, 0), F.Glow, 30)
		particles(lava, rgb(70, 60, 70), {
			Rate = 6, Lifetime = NumberRange.new(5, 8), Speed = NumberRange.new(4, 7),
			SpreadAngle = Vector2.new(15, 15), Size = NumberSequence.new(4, 12), LightEmission = 0,
			Transparency = NumberSequence.new(0.4, 1), EmissionDirection = Enum.NormalId.Top,
		})
		for s = 0, 2 do
			local a = math.rad(-60 + s * 60)
			local from = Vector3.new(math.cos(a) * 6, 23, math.sin(a) * 6)
			local to = Vector3.new(math.cos(a) * 22, 2, math.sin(a) * 22)
			b:pill("LavaStream", (cf * CFrame.new(from)).Position, (cf * CFrame.new(to)).Position, 1.6, F.Glow)
		end
	end,
	Props = function(b, F, cf, i, rng)
		if i % 2 == 0 then
			-- obsidian spikes
			for s = 1, 5 do
				local h = rng:NextNumber(5, 11)
				b:box("ObsidianSpike", Vector3.new(2, h, 2), cf * CFrame.new(rng:NextNumber(-4, 4), h / 2 - 1, rng:NextNumber(-3, 3)) * CFrame.Angles(rng:NextNumber(-0.3, 0.3), rng:NextNumber(0, 3), rng:NextNumber(-0.3, 0.3)),
					custom("Obsidian", rgb(40, 30, 56), Enum.Material.Glass, {Reflectance = 0.2}))
			end
			return
		end
		-- the meme forge: an anvil next to a glowing furnace
		b:roundedBlock("AnvilBase", Vector3.new(3, 3, 3), cf * CFrame.new(-4, 1.5, 0), 0.6, F.Second)
		b:box("AnvilTop", Vector3.new(6, 1.6, 2.6), cf * CFrame.new(-4, 3.8, 0), F.Second)
		b:tiers("Furnace", cf * CFrame.new(4, 0, 0), {{6, 5, F.Dark}, {4.6, 3, F.Second}, {2.4, 3, F.Dark}})
		b:bulb("FurnaceFire", 2.4, cf * CFrame.new(4, 2.6, -2.2), F.Glow, 14)
	end,
	Lamp = function(b, F, cf)
		-- fire brazier
		b:disc("BrazierPole", 0.8, 4.5, cf * CFrame.new(0, 2.25, 0), F.Second)
		b:disc("BrazierBowl", 3, 1.2, cf * CFrame.new(0, 5, 0), F.Dark)
		local fire = b:bulb("BrazierFire", 1.4, cf * CFrame.new(0, 6, 0), F.Glow, 14)
		particles(fire, rgb(255, 150, 60), {
			Rate = 12, Lifetime = NumberRange.new(0.5, 1), Speed = NumberRange.new(2, 4), LightEmission = 1,
			SpreadAngle = Vector2.new(10, 10), Size = NumberSequence.new(1, 0), EmissionDirection = Enum.NormalId.Top,
		})
	end,
}

-- GLITCH NEXUS ------------------------------------------------------
THEMES.Glitch = {
	Landmark = function(b, F, cf, world, rng)
		-- a giant broken monolith with a missing-texture face, and fragments floating off it
		b:box("Monolith", Vector3.new(14, 36, 5), cf * CFrame.new(0, 18, 0), F.Dark)
		for x = 0, 3 do
			for y = 0, 7 do
				b:box("MissingTexture", Vector3.new(3.2, 3.2, 0.3), cf * CFrame.new(-4.8 + x * 3.2, 8 + y * 3.2, -2.6), (x + y) % 2 == 0 and F.Second or "Ink")
			end
		end
		for i = 1, 14 do
			local s = rng:NextNumber(1.5, 4)
			local cube = b:box("Fragment", Vector3.new(s, s, s), cf * CFrame.new(rng:NextNumber(-14, 14), rng:NextNumber(20, 48), rng:NextNumber(-6, 6)) * CFrame.Angles(rng:NextNumber(0, 3), rng:NextNumber(0, 3), 0), i % 3 == 0 and F.Glow or F.Dark)
			cube.CanCollide = false
		end
	end,
	Props = function(b, F, cf, i, rng)
		if i % 2 == 0 then
			-- wireframe cube (the texture never loaded)
			local s = 8
			local h = s / 2
			local corners = {}
			for x = -1, 1, 2 do for y = -1, 1, 2 do for z = -1, 1, 2 do
				table.insert(corners, Vector3.new(x * h, y * h + h + 2, z * h))
			end end end
			for a = 1, #corners do
				for c = a + 1, #corners do
					local d = corners[c] - corners[a]
					if d.Magnitude == s then
						b:rod("Wire", s + 0.4, 0.4, cf * CFrame.new((corners[a] + corners[c]) / 2) * Architecture.alongX(Vector3.zero, d), F.Glow)
					end
				end
			end
			return
		end
		-- stack of pixel cubes that don't line up
		for c = 0, 4 do
			b:box("PixelStack", Vector3.new(4, 4, 4), cf * CFrame.new(rng:NextNumber(-1.2, 1.2), 2 + c * 4, rng:NextNumber(-1.2, 1.2)), c % 2 == 0 and F.Main or F.Second)
		end
	end,
	Lamp = function(b, F, cf)
		b:disc("LampBase", 2.2, 0.6, cf * CFrame.new(0, 0.3, 0), F.Dark)
		b:box("LampPole", Vector3.new(0.6, 6, 0.6), cf * CFrame.new(0, 3.6, 0), F.Dark)
		b:box("PixelLamp", Vector3.new(1.8, 1.8, 1.8), cf * CFrame.new(0, 7.6, 0) * CFrame.Angles(math.rad(45), math.rad(45), 0), F.Glow)
	end,
	Sky = function(b, F, rng)
		for i = 1, 20 do
			local a = rng:NextNumber(0, math.pi * 2)
			local d = rng:NextNumber(70, 220)
			local s = rng:NextNumber(3, 9)
			local cube = b:box("SkyGlitch", Vector3.new(s, s, s), CFrame.new(math.cos(a) * d, rng:NextNumber(30, 120), math.sin(a) * d), i % 2 == 0 and F.Main or F.Second)
			cube.CanCollide = false
		end
	end,
}

---------------------------------------------------------------------
-- BUILD
---------------------------------------------------------------------
return function(container, world)
	local rng = Random.new(world.Id * 7919)
	buildIsland(world, rng)

	-- rim ring + zone rings, recolored to the world's colors
	DigSiteStyle(container, world)
	buildEdgeWall(container, world)
	local F = finishes(world)
	local rim = container:FindFirstChild("Cartoon2050")
	if rim then
		local i = 0
		for _, part in ipairs(rim:GetChildren()) do
			if part:IsA("BasePart") and part.Name == "RimStripe" then
				i += 1
				local f = Architecture.Palette[(i // 2) % 2 == 0 and F.Main or F.Second]
				part.Color = f.Color
			elseif part:IsA("BasePart") and part.Name == "RimBulb" then
				part.Color = world.Look.Glow
			end
		end
	end

	local theme = THEMES[world.Theme]
	if not theme then return end
	local decor = Instance.new("Model")
	decor.Name = "Decor"
	local b = Architecture.builder(decor, CFrame.new(world.Origin))
	theme.Landmark(b, F, spot(180, LANDMARK_DISTANCE), world, rng)
	for i, angle in ipairs(PROP_ANGLES) do
		theme.Props(b, F, spot(angle, PROP_DISTANCE + rng:NextNumber(-4, 6)), i, rng)
	end
	for _, angle in ipairs(LAMP_ANGLES) do
		theme.Lamp(b, F, spot(angle, LAMP_DISTANCE))
	end
	if theme.Sky then
		theme.Sky(b, F, rng)
	end
	decor.Parent = container
end
