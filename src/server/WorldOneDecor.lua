-- WorldOneDecor (ModuleScript in ServerScriptService)
-- Dresses World 1 so it isn't one flat lawn:
--   * PLAZA: the island top is a light stone plaza (terrain Slate) with tiled mosaic rings
--     around the dig site and inside the boulevard, and glowing inlay lines running out
--     from the dig site between the museums
--   * GARDENS: raised flower-bed planters with trees, flowers and benches on the strips
--     between the museums
--   * EXCAVATION: the area around the pit looks like a real archaeology dig: dirt spoil
--     heaps with shovels stuck in them, canvas tents, crate stacks, wheelbarrows and sifting
--     screens between the walkways
--   * SHORING: wooden planks and beams set into the top of the pit walls, so digging near
--     the edge uncovers the dig's timber shoring
-- MapStyle calls WorldOneDecor.build() once on server start (after MainIsland).

local CollectionService = game:GetService("CollectionService")
local Architecture = require(script.Parent:WaitForChild("Architecture"))
local P = Architecture.Palette

local WorldOneDecor = {}
local rgb = Color3.fromRGB

P.PlazaTileA = {Color = rgb(236, 232, 246), Material = Enum.Material.Slate}
P.PlazaTileB = {Color = rgb(186, 172, 232), Material = Enum.Material.Slate}
P.PlazaTileC = {Color = rgb(150, 206, 236), Material = Enum.Material.Slate}
P.Dirt = {Color = rgb(164, 124, 86), Material = Enum.Material.Ground}
P.DirtDark = {Color = rgb(128, 92, 62), Material = Enum.Material.Ground}
P.Gravel = {Color = rgb(150, 144, 150), Material = Enum.Material.Pebble}
P.Flag = {Color = rgb(255, 92, 92), Material = Enum.Material.Fabric}
P.Timber = {Color = rgb(150, 104, 66), Material = Enum.Material.WoodPlanks}
P.TimberDark = {Color = rgb(110, 74, 46), Material = Enum.Material.Wood}
P.Canvas = {Color = rgb(232, 214, 170), Material = Enum.Material.Fabric}
P.CanvasStripe = {Color = rgb(236, 120, 90), Material = Enum.Material.Fabric}
P.PlanterGrass = {Color = rgb(104, 196, 104), Material = Enum.Material.Grass}
P.Lawn = {Color = rgb(112, 204, 108), Material = Enum.Material.Grass}
P.Leaf = {Color = rgb(96, 206, 150), Material = Enum.Material.SmoothPlastic}
P.Blossom = {Color = rgb(255, 176, 214), Material = Enum.Material.SmoothPlastic}
P.SteelDark = {Color = rgb(70, 72, 86), Material = Enum.Material.Metal}

local PIT_RADIUS = 41
local GAP_ANGLES = {30, 90, 150, 210, 270, 330}     -- the strips between them

local function at(deg, radius, y)
	local a = math.rad(deg)
	return Vector3.new(math.cos(a) * radius, y or 0, math.sin(a) * radius)
end
-- a CFrame on the circle, its -Z facing the island center
local function facing(deg, radius, y)
	local pos = at(deg, radius, y)
	return CFrame.lookAt(pos, Vector3.new(0, pos.Y, 0))
end

---------------------------------------------------------------------
-- PLAZA: mosaic rings and inlay lines on the stone ground
---------------------------------------------------------------------
-- Flat pieces on the ground are thick slabs set into a bed dug out of the terrain (tagged
-- TerrainBed, so the dig site's refill digs the bed out again, see GameConfig.FillDigTerrain):
-- a thin piece lying on the slightly bumpy terrain flickers wherever the two are level.
local BED_BOTTOM = -2.4
local function bedded(part)
	local cf, size = part.CFrame, part.Size
	workspace.Terrain:FillBlock(CFrame.new(cf.X, -2, cf.Z) * cf.Rotation, Vector3.new(size.X, 4, size.Z), Enum.Material.Air)
	CollectionService:AddTag(part, "TerrainBed")
	return part
end
local function slab(b, name, size, cf, top, finish)
	local height = top - BED_BOTTOM
	return bedded(b:box(name, Vector3.new(size.X, height, size.Z), cf - Vector3.new(0, cf.Y, 0) + Vector3.new(0, BED_BOTTOM + height / 2, 0), finish))
end

local function mosaicRing(b, radius, width, segments, finishes, top)
	local length = 2 * math.pi * radius / segments + 0.3
	for i = 0, segments - 1 do
		local deg = (i + 0.5) * 360 / segments
		local pos = at(deg, radius, 0)
		local tangent = Vector3.new(-math.sin(math.rad(deg)), 0, math.cos(math.rad(deg)))
		-- neighbors overlap a little: every other tile sits a hair higher, so they don't flicker
		slab(b, "PlazaTile", Vector3.new(length, 0, width), Architecture.alongX(pos, tangent), (top or 0.22) + (i % 2) * 0.02,
			finishes[i % #finishes + 1])
	end
end

local function plaza(b)
	-- around the dig site (just outside its ramps) and inside the boulevard
	mosaicRing(b, 128, 7, 96, {"PlazaTileA", "PlazaTileB", "PlazaTileA", "PlazaTileC"})
	-- the glow line sits in a band of tiles (a strip this thin can't get a clean bed in the
	-- terrain, which works in 4-stud blocks)
	mosaicRing(b, 133.5, 4, 96, {"PlazaTileA"}, 0.22)
	mosaicRing(b, 133, 1.2, 96, {"GlowCyan"}, 0.27)
	mosaicRing(b, 247, 6, 128, {"PlazaTileB", "PlazaTileA"})
	-- glowing inlay lines from the dig site out between the museums
	for _, deg in ipairs(GAP_ANGLES) do
		local from, to = at(deg, 136, 0.3), at(deg, 243, 0.3)
		-- one lilac band with the glow line down its middle (thin separate strips can't get a
		-- clean bed in the terrain, which works in 4-stud blocks)
		slab(b, "InlayEdge", Vector3.new(7.4, 0, (to - from).Magnitude), CFrame.lookAt((from + to) / 2, to), 0.36, "PlazaTileB")
		slab(b, "InlayLine", Vector3.new(0.7, 0, (to - from).Magnitude), CFrame.lookAt((from + to) / 2, to), 0.4, "GlowCyan")
	end
end

---------------------------------------------------------------------
-- GARDENS: planters with trees, flowers and a bench, between the museums
---------------------------------------------------------------------
local FLOWERS = {"Coral", "Sun", "Lilac", "Sky", "White", "Blossom"}
local function planter(b, rng, pos)
	local base = CFrame.new(pos)
	b:disc("PlanterCurb", 13, 1.4, base * CFrame.new(0, 0.7, 0), "White")
	b:disc("PlanterTrim", 13.4, 0.3, base * CFrame.new(0, 1.35, 0), "Lilac")
	b:disc("PlanterSoil", 11.6, 1.5, base * CFrame.new(0, 0.8, 0), "PlanterGrass")
	-- a round cartoon tree (green or blossom)
	local top = base * CFrame.new(0, 1.5, 0)
	b:pill("TreeTrunk", top.Position, top.Position + Vector3.new(0, 6.5, 0), 1.3, "TimberDark")
	local crown = rng:NextNumber() < 0.35 and "Blossom" or "Leaf"
	b:ball("TreeTop", rng:NextNumber(6.5, 8), top * CFrame.new(0, 8.5, 0), crown)
	b:ball("TreeTop", 4.5, top * CFrame.new(1.8, 7, 1.2), crown)
	b:ball("TreeTop", 4, top * CFrame.new(-1.8, 7.4, -1), crown)
	for k = 1, 10 do
		local a = k / 10 * math.pi * 2 + rng:NextNumber(-0.2, 0.2)
		local r = rng:NextNumber(3.4, 5)
		b:ball("Flower", rng:NextNumber(0.6, 0.9), top * CFrame.new(math.cos(a) * r, 0.3, math.sin(a) * r), FLOWERS[k % #FLOWERS + 1])
	end
end

local function bench(b, cf)
	b:box("BenchSeat", Vector3.new(5, 0.4, 1.6), cf * CFrame.new(0, 1.3, 0), "Timber")
	b:box("BenchBack", Vector3.new(5, 1.4, 0.3), cf * CFrame.new(0, 2.1, 0.75) * CFrame.Angles(math.rad(-10), 0, 0), "Timber")
	for _, x in ipairs({-2, 2}) do
		b:box("BenchLeg", Vector3.new(0.4, 1.2, 1.4), cf * CFrame.new(x, 0.6, 0), "SteelDark")
	end
end

-- a flat lawn (Parts, so no tall terrain grass blades) filling the strip between two
-- museums, edged with a white curb. The terrain under it is dug out and the lawn is a thick
-- slab, so the slightly bumpy ground can't poke through the grass.
local LAWN_HALF_ANGLE, LAWN_FROM, LAWN_TO = 14, 152, 240
local LAWN_TOP, LAWN_BOTTOM = 0.25, -2.5
local function lawn(b, deg)
	local length = LAWN_TO - LAWN_FROM
	for d = deg - LAWN_HALF_ANGLE + 0.5, deg + LAWN_HALF_ANGLE - 0.5, 1 do
		local dir = at(d, 1)
		-- the slices overlap (near the inner edge each one reaches two slices over); they take
		-- turns at three heights a hair apart, or the grass flickers where two tops at the same
		-- height fight over which one is drawn
		local top = LAWN_TOP + (math.floor(d - deg + LAWN_HALF_ANGLE) % 3) * 0.03
		local size = Vector3.new(length, top - LAWN_BOTTOM, 2 * math.pi * LAWN_TO / 360 + 1.2)
		local cf = Architecture.alongX(dir * ((LAWN_FROM + LAWN_TO) / 2) + Vector3.new(0, (top + LAWN_BOTTOM) / 2, 0), dir)
		bedded(b:box("Lawn", size, cf, "Lawn"))
	end
	for _, side in ipairs({-1, 1}) do
		local dir = at(deg + side * LAWN_HALF_ANGLE, 1)
		b:box("LawnCurb", Vector3.new(length, 0.7, 1.2), Architecture.alongX(dir * ((LAWN_FROM + LAWN_TO) / 2), dir), "White")
	end
	local segments = 14
	for _, r in ipairs({LAWN_FROM, LAWN_TO}) do
		for i = 0, segments - 1 do
			local d = deg - LAWN_HALF_ANGLE + (i + 0.5) * 2 * LAWN_HALF_ANGLE / segments
			local tangent = Vector3.new(-math.sin(math.rad(d)), 0, math.cos(math.rad(d)))
			b:box("LawnCurb", Vector3.new(2 * math.pi * r * 2 * LAWN_HALF_ANGLE / 360 / segments + 0.4, 0.7, 1.2),
				Architecture.alongX(at(d, r), tangent), "White")
		end
	end
end

local function gardens(b, rng)
	for _, deg in ipairs(GAP_ANGLES) do
		lawn(b, deg)
	end
	-- a ring of planters around the plaza, just outside the mosaic ring (skipping the walkways)
	for deg = 7.5, 360, 15 do
		local fromPath = math.abs(((deg + 30) % 60) - 30)
		if fromPath > 10 and math.abs(((deg) % 60) - 30) > 6 then
			planter(b, rng, at(deg, 143))
		end
	end
	for _, deg in ipairs(GAP_ANGLES) do
		for i, r in ipairs({165, 200, 232}) do
			planter(b, rng, at(deg, r))
			if i < 3 then
				-- benches facing the path between two planters
				local mid = facing(deg, r + 19)
				bench(b, mid * CFrame.new(6.5, 0, 0) * CFrame.Angles(0, math.rad(90), 0))
				bench(b, mid * CFrame.new(-6.5, 0, 0) * CFrame.Angles(0, math.rad(-90), 0))
			end
		end
	end
end

---------------------------------------------------------------------
-- EXCAVATION: the dig site's work area, between the walkways
---------------------------------------------------------------------
local function spoilHeap(b, rng, cf)
	-- a low, wide pile of dug-out earth, built from several overlapping mounds
	for k = 1, 7 do
		local a = k / 7 * math.pi * 2
		local r = k == 1 and 0 or rng:NextNumber(3, 6)
		local w = rng:NextNumber(6, 10)
		b:ellipsoid("SpoilHeap", Vector3.new(w, rng:NextNumber(2.2, 3.6), w * rng:NextNumber(0.7, 1)),
			cf * CFrame.new(math.cos(a) * r, 0.2, math.sin(a) * r * 0.7) * CFrame.Angles(0, rng:NextNumber(0, 6), 0), k % 3 == 0 and "DirtDark" or "Dirt")
	end
	b:ellipsoid("SpoilHeap", Vector3.new(9, 5, 7), cf * CFrame.new(0.5, 1, 0), "Dirt") -- the peak
	b:ellipsoid("GravelSkirt", Vector3.new(15, 0.5, 11), cf * CFrame.new(0, 0.05, 0), "DirtDark")
	for k = 1, 6 do -- rocks poking out
		b:ellipsoid("Rock", Vector3.new(1.4, 1, 1.2), cf * CFrame.new(rng:NextNumber(-6, 6), rng:NextNumber(0.8, 2.2), rng:NextNumber(-4, 4)), "SteelDark")
	end
	for k = 1, 3 do -- red survey flags marking the finds
		local pos = cf * CFrame.new(rng:NextNumber(-8, 8), 0, rng:NextNumber(-6, -4))
		b:box("FlagPole", Vector3.new(0.15, 3, 0.15), pos * CFrame.new(0, 1.5, 0), "White")
		b:box("Flag", Vector3.new(1.2, 0.7, 0.06), pos * CFrame.new(0.6, 2.6, 0), "Flag")
	end
	-- a shovel stuck in the top
	local tip = cf * CFrame.new(1, 3.4, 0) * CFrame.Angles(0, 0, math.rad(12))
	b:box("ShovelBlade", Vector3.new(1.2, 1.4, 0.15), tip, "Chrome")
	b:rod("ShovelHandle", 4.5, 0.25, tip * CFrame.new(0, 2.8, 0) * CFrame.Angles(0, 0, math.rad(90)), "Timber")
	b:box("ShovelGrip", Vector3.new(1, 0.25, 0.25), tip * CFrame.new(0, 5, 0), "Ink")
end

local function tent(b, cf)
	-- an A-frame canvas tent with striped edges
	for _, side in ipairs({-1, 1}) do
		b:box("TentCanvas", Vector3.new(0.2, 6.2, 9), cf * CFrame.new(side * 2.2, 2.6, 0) * CFrame.Angles(0, 0, side * math.rad(35)), "Canvas")
		b:box("TentStripe", Vector3.new(0.22, 0.8, 9.05), cf * CFrame.new(side * 3.85, 0.35, 0) * CFrame.Angles(0, 0, side * math.rad(35)), "CanvasStripe")
	end
	b:rod("TentRidge", 9.6, 0.3, cf * CFrame.new(0, 5.2, 0) * CFrame.Angles(0, math.rad(90), 0), "TimberDark")
	b:box("TentTable", Vector3.new(3, 0.3, 2), cf * CFrame.new(0, 1.4, 1), "Timber")
	b:box("TentLamp", Vector3.new(0.6, 0.6, 0.6), cf * CFrame.new(0, 4.4, 0), "GlowSun")
end

local function crates(b, cf)
	b:box("Crate", Vector3.new(3, 3, 3), cf * CFrame.new(0, 1.5, 0), "Timber")
	b:box("Crate", Vector3.new(3, 3, 3), cf * CFrame.new(3.2, 1.5, 0.4) * CFrame.Angles(0, math.rad(10), 0), "Timber")
	b:box("Crate", Vector3.new(2.6, 2.6, 2.6), cf * CFrame.new(1.5, 4.3, 0.2) * CFrame.Angles(0, math.rad(-12), 0), "TimberDark")
	for _, x in ipairs({0, 3.2}) do
		b:box("CrateBand", Vector3.new(3.05, 0.3, 3.05), cf * CFrame.new(x, 1.5, x == 0 and 0 or 0.4), "SteelDark")
	end
end

local function wheelbarrow(b, cf)
	b:box("BarrowTub", Vector3.new(3, 1.4, 2.2), cf * CFrame.new(0, 1.8, 0) * CFrame.Angles(0, 0, math.rad(-8)), "Sky")
	b:ellipsoid("BarrowDirt", Vector3.new(2.6, 1, 1.9), cf * CFrame.new(0, 2.5, 0), "Dirt")
	b:rod("BarrowWheel", 0.5, 1.6, cf * CFrame.new(1.9, 0.8, 0) * CFrame.Angles(0, math.rad(90), 0), "Ink")
	for _, z in ipairs({-0.8, 0.8}) do
		b:rod("BarrowHandle", 3, 0.25, cf * CFrame.new(-2.2, 1.6, z) * CFrame.Angles(0, 0, math.rad(15)), "TimberDark")
	end
end

local function sifter(b, cf)
	b:box("SiftScreen", Vector3.new(4, 0.2, 3), cf * CFrame.new(0, 2.6, 0) * CFrame.Angles(0, 0, math.rad(15)), "SteelDark",
		{Transparency = 0.35})
	b:box("SiftFrame", Vector3.new(4.2, 0.4, 0.3), cf * CFrame.new(0, 2.6, 1.5) * CFrame.Angles(0, 0, math.rad(15)), "Timber")
	b:box("SiftFrame", Vector3.new(4.2, 0.4, 0.3), cf * CFrame.new(0, 2.6, -1.5) * CFrame.Angles(0, 0, math.rad(15)), "Timber")
	for _, x in ipairs({-1.6, 1.6}) do
		b:box("SiftLeg", Vector3.new(0.3, 2.6, 0.3), cf * CFrame.new(x, 1.3 + x * 0.25, 1.4), "TimberDark")
		b:box("SiftLeg", Vector3.new(0.3, 2.6, 0.3), cf * CFrame.new(x, 1.3 + x * 0.25, -1.4), "TimberDark")
	end
	b:ellipsoid("SiftPile", Vector3.new(3, 1, 2.4), cf * CFrame.new(0.5, 0.4, 0), "Dirt")
end

local function excavation(b, rng)
	for i, deg in ipairs(GAP_ANGLES) do
		local cf = facing(deg, 100)
		spoilHeap(b, rng, cf * CFrame.new(0, 0, 0))
		if i % 2 == 1 then
			tent(b, facing(deg + 9, 108) * CFrame.Angles(0, math.rad(90), 0))
			wheelbarrow(b, facing(deg - 8, 92) * CFrame.Angles(0, math.rad(20), 0))
		else
			crates(b, facing(deg + 9, 106))
			sifter(b, facing(deg - 9, 94) * CFrame.Angles(0, math.rad(90), 0))
		end
	end
end

---------------------------------------------------------------------
-- SHORING: timber set into the top of the pit walls (seen once you dig near the edge)
---------------------------------------------------------------------
local function shoring(b)
	local PLANKS = 60
	for i = 0, PLANKS - 1 do
		local deg = (i + 0.5) * 360 / PLANKS
		b:box("ShoringPlank", Vector3.new(3.6, 12, 0.4), facing(deg, PIT_RADIUS + 0.6, -6.2), i % 2 == 0 and "Timber" or "TimberDark")
	end
	for _, y in ipairs({-2.5, -9}) do
		local segments = 60
		local length = 2 * math.pi * (PIT_RADIUS + 0.3) / segments + 0.2
		for i = 0, segments - 1 do
			local deg = (i + 0.5) * 360 / segments
			local tangent = Vector3.new(-math.sin(math.rad(deg)), 0, math.cos(math.rad(deg)))
			b:box("ShoringWaler", Vector3.new(length, 0.8, 0.5), Architecture.alongX(at(deg, PIT_RADIUS + 0.25, y), tangent), "TimberDark")
		end
	end
end

function WorldOneDecor.build(parent)
	parent = parent or workspace
	local old = parent:FindFirstChild("WorldOneDecor")
	if old then old:Destroy() end
	local folder = Instance.new("Model")
	folder.Name = "WorldOneDecor"
	local b = Architecture.builder(folder, CFrame.new())
	local rng = Random.new(2050)
	plaza(b)
	gardens(b, rng)
	excavation(b, rng)
	shoring(b)
	for _, p in ipairs(folder:GetDescendants()) do
		if p:IsA("BasePart") then
			-- flat plaza pieces and the shoring hidden in the walls never get in the way
			local flat = p.Name:find("Tile") or p.Name:find("Inlay") or p.Name:find("Shoring")
			if flat then
				p.CanCollide = p.Name:find("Shoring") ~= nil
				p.CanQuery = false
				p.CastShadow = false
			end
		end
	end
	folder.Parent = parent
	return folder
end

return WorldOneDecor
