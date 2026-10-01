-- MainIsland (ModuleScript in ServerScriptService)
-- World 1 as a compact, densely packed floating island (radius 470 studs, about half the old
-- map) wrapped in a belt of towering 2050 skyscrapers.
--
-- Layout, from the middle out:
--   0-130   the Meme Dig Site with its six walkways          (DigSite, built by the place)
--   150-245 the six player museums on their plots            (MuseumBuilder / PlotManager)
--   258-280 a glowing ring boulevard with lamps and trees
--   290-450 three rings of skyscrapers, getting taller outward, split by six radial
--           avenues (between the museums) so every museum keeps a view out
--   470     the island edge: a glass railing, then the floating cliff underneath
--
-- Every skyscraper is made from Instance.new("Part") with exact Color3s, Glass and Neon
-- materials and CFrame math: floors that twist a few degrees each, stacks that shear
-- sideways along a sine curve, set-back tiers, glass cylinders ringed with neon, twin towers
-- joined by sky tubes, and a few megatowers with spiralling neon ribs and sky gardens.
-- MapStyle calls MainIsland.build() once when the server starts.

local Architecture = require(script.Parent:WaitForChild("Architecture"))
local P = Architecture.Palette

local MainIsland = {}

local rgb = Color3.fromRGB
local terrain = workspace.Terrain

local ISLAND_RADIUS = 470
local BOULEVARD = {Radius = 269, Width = 22}
local AVENUE_ANGLES = {30, 90, 150, 210, 270, 330} -- between the museums (plots sit at 0, 60, 120...)
local AVENUE_HALF_WIDTH = 20
-- tower rings: radius, footprint range, height range
local RINGS = {
	{Radius = 312, Width = {28, 36}, Height = {110, 210}},
	{Radius = 364, Width = {32, 42}, Height = {180, 320}},
	{Radius = 422, Width = {36, 48}, Height = {260, 480}},
}
local GAP = 12 -- studs between neighbouring towers
local MEGA_COUNT = 6

---------------------------------------------------------------------
-- MATERIALS (exact colors)
---------------------------------------------------------------------
local GLASS_TINTS = {
	rgb(120, 200, 255), -- sky
	rgb(176, 160, 255), -- lilac
	rgb(110, 232, 204), -- mint
	rgb(255, 168, 206), -- rose
	rgb(255, 214, 140), -- champagne
	rgb(196, 232, 255), -- ice
}
local NEON_TINTS = {
	rgb(84, 212, 240),  -- cyan
	rgb(236, 112, 190), -- pink
	rgb(236, 192, 92),  -- gold
	rgb(92, 226, 180),  -- mint
	rgb(168, 132, 250), -- violet
}
local glassNames, neonNames = {}, {}
for i, c in ipairs(GLASS_TINTS) do
	local name = "IslandGlass" .. i
	P[name] = {Color = c, Material = Enum.Material.Glass, Transparency = 0.05, Reflectance = 0.28}
	table.insert(glassNames, name)
	-- a deeper version of the same tint for set-back cores and shadows
	P[name .. "Core"] = {Color = c:Lerp(rgb(40, 44, 90), 0.45), Material = Enum.Material.SmoothPlastic}
end
for i, c in ipairs(NEON_TINTS) do
	local name = "IslandNeon" .. i
	P[name] = {Color = c, Material = Enum.Material.Neon}
	table.insert(neonNames, name)
end
P.IslandFrame = {Color = rgb(238, 241, 250), Material = Enum.Material.SmoothPlastic}
P.IslandSteel = {Color = rgb(206, 212, 228), Material = Enum.Material.Metal, Reflectance = 0.12}
P.IslandRoad = {Color = rgb(64, 60, 112), Material = Enum.Material.SmoothPlastic}
P.IslandWalk = {Color = rgb(226, 222, 246), Material = Enum.Material.SmoothPlastic}
P.IslandLeaf = {Color = rgb(96, 206, 150), Material = Enum.Material.SmoothPlastic}

local function pick(rng, list)
	return list[rng:NextInteger(1, #list)]
end

-- CFrame at a point on a circle, turned so its -Z faces the island center
local function facingCenter(angle, radius, y)
	local pos = Vector3.new(math.cos(angle) * radius, y or 0, math.sin(angle) * radius)
	-- yaw so LookVector points at the center: LookVector of Angles(0, t, 0) is (-sin t, 0, -cos t)
	return CFrame.new(pos) * CFrame.Angles(0, math.atan2(pos.X, pos.Z), 0)
end

local function angleDiff(a, b)
	local d = (a - b) % (math.pi * 2)
	return math.min(d, math.pi * 2 - d)
end

---------------------------------------------------------------------
-- TERRAIN: the floating island itself
---------------------------------------------------------------------
local function buildTerrain(rng)
	local R = ISLAND_RADIUS
	terrain:FillCylinder(CFrame.new(0, -16, 0), 32, R, Enum.Material.Slate)
	for _, layer in ipairs({{0.86, -40, 18}, {0.68, -62, 26}, {0.5, -90, 32}, {0.32, -124, 36}}) do
		terrain:FillCylinder(CFrame.new(0, layer[2], 0), layer[3], R * layer[1], Enum.Material.Slate)
	end
	for _ = 1, 22 do
		local a = rng:NextNumber(0, math.pi * 2)
		local d = rng:NextNumber(R * 0.4, R * 0.85)
		terrain:FillBall(Vector3.new(math.cos(a) * d, rng:NextNumber(-80, -36), math.sin(a) * d), rng:NextNumber(18, 34), Enum.Material.Slate)
	end
	-- short trimmed grass on top (MapStyle shortens the blades; WorldOneDecor adds the mosaic
	-- rings, inlay lines and garden planters; the Dig Site refills its own square)
	terrain:FillCylinder(CFrame.new(0, -2, 0), 4, R, Enum.Material.Grass)
end

---------------------------------------------------------------------
-- GROUND: boulevard, avenues, walkways to the museums, lamps, trees, the edge railing
---------------------------------------------------------------------
local function ringOfBoxes(b, name, radius, width, height, y, finish, segments)
	local length = 2 * math.pi * radius / segments + 0.8
	for i = 0, segments - 1 do
		local a = (i + 0.5) / segments * math.pi * 2
		local pos = Vector3.new(math.cos(a) * radius, y, math.sin(a) * radius)
		local tangent = Vector3.new(-math.sin(a), 0, math.cos(a))
		b:box(name, Vector3.new(length, height, width), Architecture.alongX(pos, tangent), finish)
	end
end

local function buildGround(b, rng)
	-- the ring boulevard with sidewalks, a glowing center line and lamps
	ringOfBoxes(b, "Boulevard", BOULEVARD.Radius, BOULEVARD.Width, 0.4, 0.2, "IslandRoad", 64)
	ringOfBoxes(b, "SidewalkIn", BOULEVARD.Radius - BOULEVARD.Width / 2 - 3, 6, 0.6, 0.3, "IslandWalk", 64)
	ringOfBoxes(b, "SidewalkOut", BOULEVARD.Radius + BOULEVARD.Width / 2 + 3, 6, 0.6, 0.3, "IslandWalk", 72)
	ringOfBoxes(b, "LaneGlow", BOULEVARD.Radius, 0.5, 0.45, 0.22, "IslandNeon1", 64)
	for i = 0, 35 do
		local a = i / 36 * math.pi * 2 + 0.05
		local cf = facingCenter(a, BOULEVARD.Radius - BOULEVARD.Width / 2 - 3)
		b:pill("LampPost", cf.Position + Vector3.new(0, 0.6, 0), cf.Position + Vector3.new(0, 14, 0), 0.6, "IslandFrame")
		b:ball("LampGlow", 2, CFrame.new(cf.Position + Vector3.new(0, 15, 0)), pick(rng, neonNames))
		-- a round tree between every pair of lamps
		local tree = facingCenter(a + math.pi / 36, BOULEVARD.Radius - BOULEVARD.Width / 2 - 4)
		b:pill("TreeTrunk", tree.Position, tree.Position + Vector3.new(0, 6, 0), 1.2, "IslandSteel")
		b:ball("TreeTop", rng:NextNumber(6, 8), CFrame.new(tree.Position + Vector3.new(0, 8.5, 0)), i % 3 == 0 and "Mint" or "IslandLeaf")
	end
	-- radial avenues between the museums, out to the island edge
	for _, deg in ipairs(AVENUE_ANGLES) do
		local a = math.rad(deg)
		local dir = Vector3.new(math.cos(a), 0, math.sin(a))
		local from, to = BOULEVARD.Radius + BOULEVARD.Width / 2, ISLAND_RADIUS - 14
		local mid = dir * ((from + to) / 2) + Vector3.new(0, 0.2, 0)
		b:box("Avenue", Vector3.new(to - from, 0.4, 26), Architecture.alongX(mid, dir), "IslandRoad")
		b:box("AvenueGlow", Vector3.new(to - from, 0.45, 0.5), Architecture.alongX(mid, dir), "IslandNeon2")
		-- a lookout at the end of each avenue
		local look = dir * (ISLAND_RADIUS - 20)
		b:disc("Lookout", 30, 0.8, CFrame.new(look + Vector3.new(0, 0.4, 0)), "IslandWalk")
		b:ring("LookoutGlow", CFrame.new(look + Vector3.new(0, 0.9, 0)) * CFrame.Angles(math.rad(90), 0, 0), 14.5, 0.5, "IslandNeon1", 24)
	end
	-- walkways from the Dig Site's paths to each museum's plaza
	for k = 0, 5 do
		local a = math.rad(k * 60)
		local dir = Vector3.new(math.cos(a), 0, math.sin(a))
		b:box("MuseumWalk", Vector3.new(40, 0.5, 14), Architecture.alongX(dir * 146 + Vector3.new(0, 0.25, 0), dir), "IslandWalk")
	end
	-- the edge: a glass railing with a glowing top, plus an invisible wall so nobody falls off
	ringOfBoxes(b, "EdgeCurb", ISLAND_RADIUS - 3, 4, 1.6, 0.8, "IslandFrame", 96)
	ringOfBoxes(b, "EdgeRail", ISLAND_RADIUS - 3, 0.6, 4, 3.6, "IslandGlass6", 96)
	ringOfBoxes(b, "EdgeRailGlow", ISLAND_RADIUS - 3, 0.8, 0.4, 5.7, "IslandNeon1", 96)
	ringOfBoxes(b, "EdgeBarrier", ISLAND_RADIUS - 1, 2, 80, 40, "IslandFrame", 64)
end

---------------------------------------------------------------------
-- SKYSCRAPER STYLES. b is a builder at the tower's footprint (ground = y 0, -Z faces the
-- island center), w = footprint width, h = height, rng = this tower's random numbers.
---------------------------------------------------------------------
local function podium(b, w, glass, neon)
	b:box("Podium", Vector3.new(w + 8, 6, w + 8), CFrame.new(0, 3, 0), "IslandFrame")
	b:box("PodiumGlow", Vector3.new(w + 8.4, 0.5, w + 8.4), CFrame.new(0, 6, 0), neon)
	b:box("Lobby", Vector3.new(w + 2, 8, w + 2), CFrame.new(0, 10, 0), glass)
	return 14 -- where the tower itself starts
end

local function antenna(b, y, height, neon)
	b:pill("Antenna", Vector3.new(0, y, 0), Vector3.new(0, y + height, 0), 1, "IslandSteel")
	b:ball("AntennaTip", 2.4, CFrame.new(0, y + height + 1, 0), neon)
end

-- A: set-back tiers, like a 2050 art-deco tower: each tier is narrower, with white corner
-- posts, a neon stripe up the front and a white crown ledge
local function setbackTower(b, w, h, rng, glass, neon)
	local y = podium(b, w, glass, neon)
	local tiers = rng:NextInteger(3, 4)
	local remaining = h - y - 16
	for i = 1, tiers do
		local size = w * (1 - (i - 1) * 0.17)
		local th = remaining * (i == 1 and 0.4 or (0.6 / (tiers - 1)))
		b:box("Tier", Vector3.new(size, th, size), CFrame.new(0, y + th / 2, 0), glass)
		for _, c in ipairs({{1, 1}, {-1, 1}, {1, -1}, {-1, -1}}) do
			b:box("CornerPost", Vector3.new(1.6, th, 1.6), CFrame.new(c[1] * size / 2, y + th / 2, c[2] * size / 2), "IslandFrame")
		end
		b:box("FrontStripe", Vector3.new(1, th - 4, 0.6), CFrame.new(0, y + th / 2, -size / 2 - 0.3), neon)
		b:box("Ledge", Vector3.new(size + 2, 1.4, size + 2), CFrame.new(0, y + th, 0), "IslandFrame")
		y += th
	end
	b:box("Crown", Vector3.new(w * 0.3, 10, w * 0.3), CFrame.new(0, y + 5, 0) * CFrame.Angles(0, math.rad(45), 0), glass)
	antenna(b, y + 10, rng:NextNumber(10, 22), neon)
end

-- B: twisting tower: stacked glass floors, each turned a few degrees more than the one below
local function twistTower(b, w, h, rng, glass, neon)
	local y = podium(b, w, glass, neon)
	local segH = 24
	local n = math.max(3, math.floor((h - y - 14) / segH))
	local twist = math.rad(rng:NextNumber(4, 7)) * (rng:NextNumber() < 0.5 and -1 or 1)
	for i = 0, n - 1 do
		local size = w * (1 - 0.25 * i / n)
		local turn = CFrame.Angles(0, i * twist, 0)
		b:box("TwistFloor", Vector3.new(size, segH - 1.2, size), CFrame.new(0, y + segH / 2, 0) * turn, glass)
		if i % 2 == 0 then
			b:box("TwistPlate", Vector3.new(size + 1.6, 1.2, size + 1.6), CFrame.new(0, y, 0) * turn, "IslandFrame")
		end
		y += segH
	end
	b:box("TwistCap", Vector3.new(w * 0.6, 3, w * 0.6), CFrame.new(0, y + 1.5, 0) * CFrame.Angles(0, n * twist, 0), neon)
	antenna(b, y + 3, rng:NextNumber(12, 24), neon)
end

-- C: glass cylinder banded with thin neon discs, a dome on top
local function cylinderTower(b, w, h, rng, glass, neon)
	local y = podium(b, w, glass, neon)
	local body = h - y - w * 0.4
	b:disc("Cylinder", w, body, CFrame.new(0, y + body / 2, 0), glass)
	b:disc("CylinderCore", w * 0.7, body, CFrame.new(0, y + body / 2, 0), glass .. "Core")
	local bands = math.floor(body / 30)
	for i = 1, bands do
		b:disc("NeonBand", w + 0.8, 0.8, CFrame.new(0, y + i * body / (bands + 1), 0), neon)
	end
	b:disc("CylinderLip", w + 2, 1.4, CFrame.new(0, y + body, 0), "IslandFrame")
	b:ellipsoid("CylinderDome", Vector3.new(w, w * 0.8, w), CFrame.new(0, y + body, 0), glass)
	antenna(b, y + body + w * 0.35, rng:NextNumber(8, 16), neon)
end

-- D: sheared tower: segments slide sideways along a sine curve and lean with it, so the
-- whole tower bends gracefully
local function shearTower(b, w, h, rng, glass, neon)
	local y = podium(b, w, glass, neon)
	local n = rng:NextInteger(5, 7)
	local segH = (h - y - 10) / n
	local sway = w * rng:NextNumber(0.25, 0.4) * (rng:NextNumber() < 0.5 and -1 or 1)
	for i = 0, n - 1 do
		local t0, t1 = i / n, (i + 1) / n
		local x0, x1 = math.sin(t0 * math.pi) * sway, math.sin(t1 * math.pi) * sway
		local lean = math.atan2(x1 - x0, segH)
		local cf = CFrame.new((x0 + x1) / 2, y + segH / 2, 0) * CFrame.Angles(0, 0, -lean)
		b:box("ShearFloor", Vector3.new(w * 0.9, segH - 1, w * 0.9), cf, glass)
		b:box("ShearEdge", Vector3.new(0.8, segH - 1, 0.8), cf * CFrame.new(w * 0.45, 0, -w * 0.45), neon)
		b:box("ShearEdge", Vector3.new(0.8, segH - 1, 0.8), cf * CFrame.new(-w * 0.45, 0, -w * 0.45), neon)
		b:box("ShearPlate", Vector3.new(w * 0.95, 1, w * 0.95), CFrame.new(x0, y, 0) * CFrame.Angles(0, 0, -lean), "IslandFrame")
		y += segH
	end
	b:box("ShearRoof", Vector3.new(w * 0.95, 1.6, w * 0.95), CFrame.new(math.sin(math.pi) * sway, y, 0), "IslandFrame")
	antenna(b, y + 1, rng:NextNumber(10, 18), neon)
end

-- E: twin towers joined by glass sky tubes
local function twinTower(b, w, h, rng, glass, neon)
	local y = podium(b, w, glass, neon)
	local tw = w * 0.42
	local heights = {h - y, (h - y) * rng:NextNumber(0.7, 0.85)}
	for i, side in ipairs({-1, 1}) do
		local th = heights[i]
		local x = side * w * 0.27
		b:box("TwinBody", Vector3.new(tw, th, tw), CFrame.new(x, y + th / 2, 0), glass)
		b:box("TwinFin", Vector3.new(1.2, th, tw + 2), CFrame.new(x + side * tw / 2, y + th / 2, 0), "IslandFrame")
		b:box("TwinGlow", Vector3.new(0.8, th - 6, 0.8), CFrame.new(x - side * tw / 2, y + th / 2, -tw / 2), neon)
		b:box("TwinTop", Vector3.new(tw + 1.4, 1.4, tw + 1.4), CFrame.new(x, y + th, 0), "IslandFrame")
		if i == 1 then antenna(b, y + th, rng:NextNumber(10, 20), neon) end
	end
	for k = 1, 3 do
		local by = y + heights[2] * (0.3 + 0.2 * k)
		b:rod("SkyTube", w * 0.25, 5, CFrame.new(0, by, 0), "IslandGlass6")
		b:rod("SkyTubeGlow", w * 0.25, 5.4, CFrame.new(0, by - 1.5, 0), neon, {Transparency = 0.6})
	end
end

-- F: megatower: twisting floors with neon ribs spiralling around the corners, two sky
-- gardens and a stepped crown with a halo and a spire
local function megaTower(b, w, h, rng, glass, neon)
	local y = podium(b, w, glass, neon)
	local segH = 20
	local n = math.floor((h - y - 40) / segH)
	local twist = math.rad(rng:NextNumber(3.5, 5.5)) * (rng:NextNumber() < 0.5 and -1 or 1)
	local prev
	for i = 0, n - 1 do
		local t = i / math.max(n - 1, 1)
		local size = w * (1 - 0.25 * math.sin(t * math.pi * 0.85)) * (1 - 0.12 * t)
		local turn = CFrame.Angles(0, i * twist, 0)
		b:box("MegaFloor", Vector3.new(size, segH - 1, size), CFrame.new(0, y + segH / 2, 0) * turn, glass)
		b:box("MegaPlate", Vector3.new(size + 1.6, 1, size + 1.6), CFrame.new(0, y, 0) * turn, "IslandFrame")
		if i % 2 == 0 then
			local corners = {}
			for k = 0, 3 do
				local a = math.rad(45 + k * 90)
				corners[k + 1] = (CFrame.new(0, y, 0) * turn * CFrame.new(math.cos(a) * size * 0.72, 0, math.sin(a) * size * 0.72)).Position
			end
			if prev then
				for k = 1, 4 do
					local p0, p1 = prev[k], corners[k]
					b:rod("MegaRib", (p1 - p0).Magnitude + 0.6, 1, Architecture.alongX((p0 + p1) / 2, p1 - p0), neon)
				end
			end
			prev = corners
		end
		if i == math.floor(n / 3) or i == math.floor(n * 2 / 3) then
			b:disc("SkyGarden", size * 1.45, 1.4, CFrame.new(0, y + 0.5, 0), "IslandFrame")
			for k = 1, 6 do
				local a = math.pi * 2 * k / 6
				b:ball("GardenTree", 4, CFrame.new(math.cos(a) * size * 0.6, y + 3.4, math.sin(a) * size * 0.6), "IslandLeaf")
			end
		end
		y += segH
	end
	local _, crownH = b:tiers("MegaCrown", CFrame.new(0, y, 0) * CFrame.Angles(0, n * twist, 0), {
		{w * 0.6, 4, "IslandFrame"}, {w * 0.46, 4, glass}, {w * 0.3, 8, glass .. "Core"},
	})
	b:ring("MegaHalo", CFrame.new(0, y + crownH + 5, 0) * CFrame.Angles(math.rad(90), 0, 0), w * 0.3, 1, neon, 24)
	antenna(b, y + crownH, 30, neon)
end

local STYLES = {setbackTower, twistTower, cylinderTower, shearTower, twinTower}

---------------------------------------------------------------------
-- PLACE THE TOWERS
---------------------------------------------------------------------
local function planTowers(rng)
	local plan = {}
	for ringIndex, ring in ipairs(RINGS) do
		local angle = rng:NextNumber(0, 0.1)
		while angle < math.pi * 2 - 0.05 do
			local w = rng:NextNumber(ring.Width[1], ring.Width[2])
			local center = angle + (w / 2) / ring.Radius
			-- keep the avenues clear
			local blocked = false
			for _, deg in ipairs(AVENUE_ANGLES) do
				if angleDiff(center, math.rad(deg)) * ring.Radius < AVENUE_HALF_WIDTH + w * 0.75 then
					blocked = true
					break
				end
			end
			if not blocked then
				-- a gentle skyline wave so the heights feel designed, not random
				local wave = 0.8 + 0.2 * (math.sin(center * 3 + ringIndex) + 1)
				local h = rng:NextNumber(ring.Height[1], ring.Height[2]) * wave
				table.insert(plan, {Angle = center, Radius = ring.Radius + rng:NextNumber(-5, 5), Width = w, Height = h, Ring = ringIndex})
				angle += (w + GAP) / ring.Radius
			else
				angle += 6 / ring.Radius
			end
		end
	end
	-- the tallest outer-ring spots become megatowers
	local outer = {}
	for _, t in ipairs(plan) do
		if t.Ring == #RINGS then table.insert(outer, t) end
	end
	table.sort(outer, function(a, c) return a.Height > c.Height end)
	for i = 1, math.min(MEGA_COUNT, #outer) do
		outer[i].Mega = true
		outer[i].Height = math.max(outer[i].Height, 420) + 60
	end
	return plan
end

function MainIsland.build(parent)
	local rng = Random.new(2050)
	local island = Instance.new("Model")
	island.Name = "MainIsland"
	island:SetAttribute("NoCalm", true) -- its glow is already tuned; MapStyle leaves it alone

	buildTerrain(rng)
	local ground = Instance.new("Model")
	ground.Name = "Ground"
	ground.Parent = island
	buildGround(Architecture.builder(ground, CFrame.new()), rng)
	-- pave the terrain under roads and walkways: grass blades would poke up through them
	local PAVED = {Boulevard = true, SidewalkIn = true, SidewalkOut = true, Avenue = true, MuseumWalk = true, EdgeCurb = true}
	for _, part in ipairs(ground:GetChildren()) do
		if PAVED[part.Name] then
			local pos = part.Position
			terrain:FillBlock(CFrame.new(pos.X, -2, pos.Z) * part.CFrame.Rotation, Vector3.new(part.Size.X + 2, 4, part.Size.Z + 2), Enum.Material.Slate)
		elseif part.Name == "Lookout" then
			terrain:FillCylinder(CFrame.new(part.Position.X, -2, part.Position.Z), 4, part.Size.Y / 2 + 1, Enum.Material.Slate)
		end
	end
	-- sink the roads, sidewalks and walkways so their tops sit flush with the ground: you
	-- walk straight onto them instead of bumping into a ledge
	local FLUSH_TOP = {Boulevard = 0.06, SidewalkIn = 0.1, SidewalkOut = 0.1, Avenue = 0.06, MuseumWalk = 0.1, Lookout = 0.1,
		LaneGlow = 0.12, AvenueGlow = 0.12, LookoutGlow = 0.3}
	for _, part in ipairs(ground:GetChildren()) do
		local top = FLUSH_TOP[part.Name]
		if top and part:IsA("BasePart") then
			-- the Lookout is a standing disc (its height runs along its X); everything else is flat (Y)
			local height = part.Name == "Lookout" and part.Size.X or part.Size.Y
			part.CFrame = part.CFrame + Vector3.new(0, top - (part.CFrame.Position.Y + height / 2), 0)
		end
	end
	for _, part in ipairs(ground:GetChildren()) do
		if part.Name == "EdgeBarrier" then
			part.Transparency = 1
			part.CanQuery = false
			part.CastShadow = false
		end
	end

	local towers = Instance.new("Model")
	towers.Name = "Skyscrapers"
	towers.Parent = island
	for i, t in ipairs(planTowers(rng)) do
		local model = Instance.new("Model")
		model.Name = t.Mega and "MegaTower" or "Skyscraper"
		local towerRng = Random.new(i * 7919)
		local b = Architecture.builder(model, facingCenter(t.Angle, t.Radius))
		local glass = pick(towerRng, glassNames)
		local neon = pick(towerRng, neonNames)
		if t.Mega then
			megaTower(b, t.Width, t.Height, towerRng, glass, neon)
		else
			STYLES[towerRng:NextInteger(1, #STYLES)](b, t.Width, t.Height, towerRng, glass, neon)
		end
		model.Parent = towers
	end

	island.Parent = parent or workspace
	return island
end

return MainIsland
