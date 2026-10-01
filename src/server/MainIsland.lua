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
-- Every skyscraper is made from Instance.new("Part") in a cartoony 2050 style, like a toy
-- city: chunky rounded bodies in bold pastels with dark-blue ribbon windows and thick white
-- lips. Five styles (banded round towers, saucer towers, jellybean pod stacks, chunky
-- rounded blocks, twin/triple towers joined by sky tubes) plus six megatowers with a saucer
-- sky deck, tilted orbit rings and a glowing needle.
-- MapStyle calls MainIsland.build() once when the server starts.

local Architecture = require(script.Parent:WaitForChild("Architecture"))
local GameConfig = require(game:GetService("ReplicatedStorage"):WaitForChild("GameConfig"))
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
local neonNames = {}
for i, c in ipairs(GLASS_TINTS) do
	local name = "IslandGlass" .. i
	P[name] = {Color = c, Material = Enum.Material.Glass, Transparency = 0.05, Reflectance = 0.28}
	-- a deeper version of the same tint for set-back cores and shadows
	P[name .. "Core"] = {Color = c:Lerp(rgb(40, 44, 90), 0.45), Material = Enum.Material.SmoothPlastic}
end
for i, c in ipairs(NEON_TINTS) do
	local name = "IslandNeon" .. i
	P[name] = {Color = c, Material = Enum.Material.Neon}
	table.insert(neonNames, name)
end
-- skyscraper bodies: bold cartoon pastels, each tower gets two of them
local BODY_TINTS = {
	rgb(178, 158, 255), -- lilac
	rgb(112, 192, 255), -- sky
	rgb(104, 222, 190), -- mint
	rgb(255, 150, 196), -- bubblegum
	rgb(255, 224, 128), -- lemon
	rgb(140, 150, 255), -- periwinkle
	rgb(92, 214, 232),  -- aqua
	rgb(246, 247, 252), -- white
}
local bodyNames = {}
for i, color in ipairs(BODY_TINTS) do
	P["TowerBody" .. i] = {Color = color, Material = Enum.Material.SmoothPlastic}
	table.insert(bodyNames, "TowerBody" .. i)
end
-- cartoon window glass: deep blue with a little shine
P.TowerWindow1 = {Color = rgb(58, 78, 158), Material = Enum.Material.SmoothPlastic, Reflectance = 0.15}
P.TowerWindow2 = {Color = rgb(44, 104, 150), Material = Enum.Material.SmoothPlastic, Reflectance = 0.15}
P.TowerWindow3 = {Color = rgb(86, 64, 150), Material = Enum.Material.SmoothPlastic, Reflectance = 0.15}
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
	-- grass between the towers; inside the boulevard (and under it) a stone plaza, because
	-- Roblox grass grows tall blades that swallow everything low (scripts can't shorten them).
	-- WorldOneDecor adds the mosaic rings, inlay lines and flat garden lawns; the Dig Site
	-- refills its own square.
	terrain:FillCylinder(CFrame.new(0, -2, 0), 4, R, Enum.Material.Grass)
	terrain:FillCylinder(CFrame.new(0, -2, 0), 4, BOULEVARD.Radius + BOULEVARD.Width / 2 + 12, Enum.Material.Slate)
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
-- SKYSCRAPER STYLES: a cartoony 2050 skyline, like a toy city. Chunky rounded bodies in
-- bold pastels, dark-blue ribbon windows, thick white lips, bubble domes, saucers and
-- floating halos. b is a builder at the tower's footprint (ground = y 0, -Z faces the
-- island center), w = footprint width, h = height, rng = this tower's random numbers,
-- c = its colors {Body, Second, Window, Neon}.
---------------------------------------------------------------------
local RIBBON_GAP = 21 -- studs between window ribbons

-- round podium with a glowing rim and a glass lobby
local function podium(b, w, c)
	b:disc("Podium", w + 10, 5, CFrame.new(0, 2.5, 0), "IslandFrame")
	b:disc("PodiumGlow", w + 10.6, 0.6, CFrame.new(0, 5, 0), c.Neon)
	b:disc("Lobby", w + 3, 7, CFrame.new(0, 8.5, 0), "IslandGlass6")
	b:disc("LobbyRoof", w + 6, 1.4, CFrame.new(0, 12.6, 0), "IslandFrame")
	return 13 -- where the tower itself starts
end

-- a round body from y0 to y1: colored cylinder, window ribbons, a thick white lip on top
local function roundBody(b, d, y0, y1, body, window)
	b:disc("Body", d, y1 - y0, CFrame.new(0, (y0 + y1) / 2, 0), body)
	local y = y0 + RIBBON_GAP * 0.6
	while y < y1 - 5 do
		b:disc("WindowRibbon", d + 0.6, 5.4, CFrame.new(0, y, 0), window)
		y += RIBBON_GAP
	end
	b:disc("Lip", d + 2.4, 1.8, CFrame.new(0, y1, 0), "IslandFrame")
end

-- a glass bubble on top with a floating halo disc and an antenna ball
local function bubbleTop(b, d, y, c, rng)
	b:ellipsoid("BubbleDome", Vector3.new(d * 0.8, d * 0.62, d * 0.8), CFrame.new(0, y + 0.6, 0), "IslandGlass6")
	b:ellipsoid("BubbleCore", Vector3.new(d * 0.4, d * 0.42, d * 0.4), CFrame.new(0, y + 0.6, 0), c.Second)
	b:disc("Halo", d * 0.95, 0.5, CFrame.new(0, y + d * 0.42, 0), c.Neon, {Transparency = 0.25, CanCollide = false})
	local tip = y + d * 0.31 + rng:NextNumber(8, 16)
	b:pill("Antenna", Vector3.new(0, y + d * 0.28, 0), Vector3.new(0, tip, 0), 0.9, "IslandFrame")
	b:ball("AntennaBall", 3.2, CFrame.new(0, tip + 1.2, 0), c.Neon)
end

-- A: banded round tower that steps in two or three times, each section a little slimmer,
-- with a glowing collar where it narrows
local function bandTower(b, w, h, rng, c)
	local start = podium(b, w, c)
	local sections = rng:NextInteger(2, 3)
	local splits = sections == 2 and {0.6, 1} or {0.45, 0.75, 1}
	local top = h - w * 0.35
	local y, d = start, w
	for i = 1, sections do
		local y1 = start + (top - start) * splits[i]
		roundBody(b, d, y, y1, i % 2 == 1 and c.Body or c.Second, c.Window)
		if i < sections then
			b:disc("Collar", d * 0.78, 3.4, CFrame.new(0, y1 + 2.2, 0), c.Neon)
			d *= 0.78
		end
		y = y1 + (i < sections and 3.4 or 0)
	end
	bubbleTop(b, d, y, c, rng)
end

-- B: a slim core threaded through big flying saucers
local function saucerTower(b, w, h, rng, c)
	local y = podium(b, w, c)
	local core = w * 0.5
	local top = h - 10
	roundBody(b, core, y, top, c.Body, c.Window)
	local count = rng:NextInteger(2, 3)
	for k = 1, count do
		local sy = y + (top - y) * (0.35 + 0.55 * (k - 1) / math.max(count - 1, 1))
		local sd = w * (1.45 - 0.18 * (k - 1))
		b:ellipsoid("Saucer", Vector3.new(sd, 5.6, sd), CFrame.new(0, sy, 0), "IslandFrame")
		b:ellipsoid("SaucerBelly", Vector3.new(sd * 0.82, 4.6, sd * 0.82), CFrame.new(0, sy - 1.6, 0), c.Second)
		b:disc("SaucerWindows", sd * 0.62, 1.6, CFrame.new(0, sy + 2.2, 0), c.Window)
		b:disc("SaucerRim", sd * 0.9, 0.5, CFrame.new(0, sy - 0.2, 0), c.Neon)
	end
	b:ellipsoid("TopPod", Vector3.new(core * 1.3, core * 1.1, core * 1.3), CFrame.new(0, top + 1, 0), c.Second)
	b:disc("TopPodBand", core * 1.32, 1.2, CFrame.new(0, top + 1, 0), c.Window)
	local tip = top + core * 0.5 + rng:NextNumber(12, 22)
	b:pill("Spire", Vector3.new(0, top + core * 0.5, 0), Vector3.new(0, tip, 0), 1, "IslandFrame")
	b:ball("SpireBall", 3.4, CFrame.new(0, tip + 1.2, 0), c.Neon)
end

-- C: a stack of rounded jellybean pods joined by slim glowing necks
local function podTower(b, w, h, rng, c)
	local y = podium(b, w, c)
	local pods = math.clamp(math.floor((h - y) / 55) + 1, 3, 6)
	local neck = 5
	local podH = (h - y - 14 - neck * (pods - 1)) / pods
	for i = 1, pods do
		local d = w * (1 - 0.1 * (i - 1))
		local finish = i % 2 == 1 and c.Body or c.Second
		-- a short cylinder with a dome on each end: a rounded jellybean
		local cap = math.min(d * 0.28, podH * 0.3)
		local bodyH = podH - cap * 2
		local mid = y + podH / 2
		b:disc("PodBody", d, bodyH, CFrame.new(0, mid, 0), finish)
		b:ellipsoid("PodCap", Vector3.new(d, cap * 2, d), CFrame.new(0, mid + bodyH / 2, 0), finish)
		b:ellipsoid("PodBase", Vector3.new(d, cap * 2, d), CFrame.new(0, mid - bodyH / 2, 0), finish)
		b:disc("PodLip", d + 1.6, 1.2, CFrame.new(0, mid + bodyH / 2, 0), "IslandFrame")
		for k = 1, math.max(1, math.floor(bodyH / RIBBON_GAP)) do
			b:disc("WindowRibbon", d + 0.6, 5, CFrame.new(0, mid - bodyH / 2 + bodyH * (k - 0.5) / math.max(1, math.floor(bodyH / RIBBON_GAP)), 0), c.Window)
		end
		y += podH
		if i < pods then
			b:disc("PodNeck", d * 0.36, neck + 2, CFrame.new(0, y + neck / 2, 0), c.Neon)
			y += neck
		end
	end
	local tip = y + rng:NextNumber(10, 18)
	b:pill("Antenna", Vector3.new(0, y - 2, 0), Vector3.new(0, tip, 0), 0.9, "IslandFrame")
	b:ball("AntennaBall", 3.4, CFrame.new(0, tip + 1.2, 0), c.Neon)
end

-- D: chunky set-back block tower: rounded white corner columns, a big dark window wall on
-- every side, a thick white cap on each tier and a ball on top
local function blockTower(b, w, h, rng, c)
	b:box("Podium", Vector3.new(w + 10, 5, w + 10), CFrame.new(0, 2.5, 0), "IslandFrame")
	b:box("PodiumGlow", Vector3.new(w + 10.6, 0.6, w + 10.6), CFrame.new(0, 5, 0), c.Neon)
	local y = 5
	local tiers = rng:NextInteger(2, 3)
	local remaining = h - y - w * 0.4
	for i = 1, tiers do
		local s = w * (1 - (i - 1) * 0.2)
		local th = remaining * (i == 1 and 0.5 or 0.5 / (tiers - 1))
		local cy = y + th / 2
		local r = math.max(2, s * 0.14)
		b:box("Tier", Vector3.new(s - r * 2, th, s), CFrame.new(0, cy, 0), i % 2 == 1 and c.Body or c.Second)
		b:box("TierSide", Vector3.new(s, th, s - r * 2), CFrame.new(0, cy, 0), i % 2 == 1 and c.Body or c.Second)
		for _, sx in ipairs({-1, 1}) do
			for _, sz in ipairs({-1, 1}) do
				b:disc("CornerColumn", r * 2 + 0.4, th, CFrame.new(sx * (s / 2 - r), cy, sz * (s / 2 - r)), "IslandFrame")
			end
		end
		-- window walls, cut into floors by thin white lines
		local panel = s - r * 2 - 2
		for _, face in ipairs({0, 90, 180, 270}) do
			local turn = CFrame.Angles(0, math.rad(face), 0)
			b:box("WindowWall", Vector3.new(panel, th - 6, 0.6), CFrame.new(0, cy, 0) * turn * CFrame.new(0, 0, -s / 2), c.Window)
		end
		for fy = y + 9, y + th - 6, 9 do
			b:box("FloorLine", Vector3.new(s - r * 2 - 1.4, 0.8, s + 0.9), CFrame.new(0, fy, 0), "IslandFrame")
			b:box("FloorLine", Vector3.new(s + 0.9, 0.8, s - r * 2 - 1.4), CFrame.new(0, fy, 0), "IslandFrame")
		end
		b:box("TierCap", Vector3.new(s + 2.4, 2.2, s + 2.4), CFrame.new(0, y + th + 1.1, 0), "IslandFrame")
		b:box("TierCapGlow", Vector3.new(s + 2.6, 0.5, s + 2.6), CFrame.new(0, y + th, 0), c.Neon)
		y += th + 2.2
	end
	local ball = w * 0.42
	b:disc("BallNeck", ball * 0.5, 4, CFrame.new(0, y + 2, 0), c.Second)
	b:ball("TopBall", ball, CFrame.new(0, y + 3 + ball / 2, 0), "IslandGlass6")
	b:ball("TopBallCore", ball * 0.55, CFrame.new(0, y + 3 + ball / 2, 0), c.Neon)
	b:disc("TopBallRing", ball * 1.35, 0.8, CFrame.new(0, y + 3 + ball / 2, 0) * CFrame.Angles(math.rad(18), 0, math.rad(12)), "IslandFrame")
	local tip = y + 3 + ball + rng:NextNumber(6, 12)
	b:pill("Antenna", Vector3.new(0, y + 3 + ball - 1, 0), Vector3.new(0, tip, 0), 0.8, "IslandFrame")
end

-- E: two or three round towers of different heights, joined by glass sky tubes
local function clusterTower(b, w, h, rng, c)
	local y = podium(b, w, c)
	local count = rng:NextInteger(2, 3)
	local d = w * (count == 2 and 0.52 or 0.46)
	local spots = count == 2 and {Vector3.new(-w * 0.24, 0, 0), Vector3.new(w * 0.24, 0, 0)}
		or {Vector3.new(-w * 0.26, 0, w * 0.14), Vector3.new(w * 0.26, 0, w * 0.14), Vector3.new(0, 0, -w * 0.24)}
	local tops = {}
	for i, at in ipairs(spots) do
		local top = y + (h - y - d * 0.5) * (i == 1 and 1 or rng:NextNumber(0.62, 0.86))
		tops[i] = top
		local sub = Architecture.builder(b.Parent, b.Base * CFrame.new(at))
		roundBody(sub, d, y, top, i % 2 == 1 and c.Body or c.Second, c.Window)
		sub:ellipsoid("Dome", Vector3.new(d, d * 0.7, d), CFrame.new(0, top + 0.6, 0), i % 2 == 1 and c.Second or c.Body)
		sub:ball("DomeLight", 2.6, CFrame.new(0, top + d * 0.35 + 1, 0), c.Neon)
	end
	local lowest = math.min(table.unpack(tops))
	for k = 1, 2 do
		local ty = y + (lowest - y) * (0.35 + 0.35 * k)
		for i = 2, count do
			local from, to = spots[1] + Vector3.new(0, ty, 0), spots[i] + Vector3.new(0, ty, 0)
			b:rod("SkyTube", (to - from).Magnitude, 5, Architecture.alongX((from + to) / 2, to - from), "IslandGlass6")
			b:rod("SkyTubeFloor", (to - from).Magnitude, 2.2, Architecture.alongX((from + to) / 2 - Vector3.new(0, 1.4, 0), to - from), c.Neon)
		end
	end
end

-- F: megatower: a tall tapering spire of banded sections, two tilted orbit rings with little
-- moons, a big saucer sky deck near the top and a long glowing needle
local function megaTower(b, w, h, rng, c)
	local start = podium(b, w, c)
	local y = start
	local deck = h * 0.78
	local sections = 4
	local d = w
	for i = 1, sections do
		local y1 = y + (deck - y) / sections
		roundBody(b, d, y, y1, i % 2 == 1 and c.Body or c.Second, c.Window)
		y = y1 + 1
		d *= 0.86
	end
	-- the sky deck saucer with a glass observation ring
	b:ellipsoid("DeckSaucer", Vector3.new(w * 1.9, 10, w * 1.9), CFrame.new(0, deck + 3, 0), "IslandFrame")
	b:ellipsoid("DeckBelly", Vector3.new(w * 1.6, 8, w * 1.6), CFrame.new(0, deck, 0), c.Second)
	b:disc("DeckGlass", w * 1.25, 6, CFrame.new(0, deck + 8, 0), "IslandGlass6")
	b:disc("DeckRoof", w * 1.35, 1.6, CFrame.new(0, deck + 11.6, 0), "IslandFrame")
	b:disc("DeckRim", w * 1.75, 0.8, CFrame.new(0, deck + 1.6, 0), c.Neon)
	-- the upper spire and the needle
	local spireTop = h - 30
	roundBody(b, d * 0.8, deck + 12, spireTop, c.Body, c.Window)
	b:ellipsoid("SpireCap", Vector3.new(d * 0.8, d * 0.7, d * 0.8), CFrame.new(0, spireTop + 0.5, 0), c.Second)
	b:pill("Needle", Vector3.new(0, spireTop + d * 0.3, 0), Vector3.new(0, h + 20, 0), 1.6, "IslandFrame")
	b:ball("NeedleBall", 6, CFrame.new(0, h + 22, 0), c.Neon)
	b:disc("NeedleHalo", 14, 0.6, CFrame.new(0, h + 10, 0), c.Neon, {Transparency = 0.3, CanCollide = false})
	-- two orbit rings, tilted, each with a moon
	for k, tilt in ipairs({18, -24}) do
		local ry = start + (deck - start) * (0.3 + 0.25 * k)
		local ringCF = CFrame.new(0, ry, 0) * CFrame.Angles(math.rad(90 + tilt), math.rad(k * 50), 0)
		local radius = w * (0.95 + 0.15 * k)
		b:ring("OrbitRing", ringCF, radius, 1.6, k == 1 and c.Neon or "IslandFrame", 28)
		b:ball("Moon", 6, ringCF * CFrame.new(radius * math.cos(k * 2), radius * math.sin(k * 2), 0), k == 1 and c.Second or c.Neon)
	end
end

local STYLES = {bandTower, saucerTower, podTower, blockTower, clusterTower}

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
			-- a wide margin: blades from the grass next to a road lean in over its edge
			-- (not at the island's rim, where it would stick out past the cliff)
			local margin = part.Name == "EdgeCurb" and 2 or 10
			terrain:FillBlock(CFrame.new(pos.X, -2, pos.Z) * part.CFrame.Rotation, Vector3.new(part.Size.X + 2, 4, part.Size.Z + margin), Enum.Material.Slate)
		elseif part.Name == "Lookout" then
			terrain:FillCylinder(CFrame.new(part.Position.X, -2, part.Position.Z), 4, part.Size.Y / 2 + 1, Enum.Material.Slate)
		end
	end
	-- bring the ground surface down to y = 0, where the roads and decorations sit
	GameConfig.FlattenGround(terrain, Vector3.zero, ISLAND_RADIUS * 2 + 8)
	-- roads and walkways become thick slabs set into a dug-out bed, so the slightly bumpy
	-- terrain can't poke up through them
	local SLAB = {Boulevard = true, SidewalkIn = true, SidewalkOut = true, Avenue = true, MuseumWalk = true}
	for _, part in ipairs(ground:GetChildren()) do
		if SLAB[part.Name] then
			local pos = part.Position
			terrain:FillBlock(CFrame.new(pos.X, -2, pos.Z) * part.CFrame.Rotation, Vector3.new(part.Size.X, 4, part.Size.Z), Enum.Material.Air)
			part.Size = Vector3.new(part.Size.X, 2.6, part.Size.Z)
		end
	end
	-- sink the roads, sidewalks and walkways so their tops sit just above the ground (y = 0): you
	-- walk straight onto them instead of bumping into a ledge
	local FLUSH_TOP = {Boulevard = 0.2, SidewalkIn = 0.25, SidewalkOut = 0.25, Avenue = 0.2, MuseumWalk = 0.25, Lookout = 0.25,
		LaneGlow = 0.26, AvenueGlow = 0.26, LookoutGlow = 0.45}
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
		local body = towerRng:NextInteger(1, #bodyNames)
		local second = (body + towerRng:NextInteger(1, #bodyNames - 1) - 1) % #bodyNames + 1
		local colors = {
			Body = bodyNames[body], Second = bodyNames[second],
			Window = "TowerWindow" .. towerRng:NextInteger(1, 3), Neon = pick(towerRng, neonNames),
		}
		if t.Mega then
			megaTower(b, t.Width, t.Height, towerRng, colors)
		else
			STYLES[towerRng:NextInteger(1, #STYLES)](b, t.Width, t.Height, towerRng, colors)
		end
		model.Parent = towers
	end

	island.Parent = parent or workspace
	return island
end

return MainIsland
