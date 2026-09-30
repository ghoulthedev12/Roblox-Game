-- GameConfig (ModuleScript in ReplicatedStorage)
-- All the numbers you might want to tweak, in one place.

local GameConfig = {}

-- Money you start with
GameConfig.StartingMoney = 0

-- How fast players walk (Roblox default is 16, so 32 = 2x speed, 24 = 1.5x)
GameConfig.WalkSpeed = 32

-- Price of every slot, in order (slot 1 to 24). 0 = free from the start.
GameConfig.SlotPrices = {
	-- Floor 1 (slots 1-8)
	0, 0, 0, 0, 1000, 5000, 25000, 150000,
	-- Floor 2 (slots 9-16)
	350000, 750000, 1e6, 3e6, 7e6, 15e6, 30e6, 50e6,
	-- Floor 3 (slots 17-24)
	100e6, 250e6, 500e6, 800e6, 1e9, 3e9, 7e9, 15e9,
}
GameConfig.SlotsPerFloor = 8

-- Price to unlock each floor (floor 1 is free)
GameConfig.FloorPrices = {0, 250000, 75000000}

-- Offline earnings: max hours counted, and how much of your normal income you get (1 = 100%)
GameConfig.OfflineCapHours = 4
GameConfig.OfflineMultiplier = 1

function GameConfig.GetFloorOfSlot(slotIndex)
	return math.ceil(slotIndex / GameConfig.SlotsPerFloor)
end

-- Which floor of a museum a position is on (nil if it's not inside that museum).
-- MuseumBuilder puts an invisible "Interior" box around the floors, with the storey height
-- in its FloorHeight attribute.
function GameConfig.GetMuseumFloor(museum, position)
	local interior = museum:FindFirstChild("Interior")
	if not interior or not interior:IsA("BasePart") then return nil end
	local p = interior.CFrame:PointToObjectSpace(position)
	local half = interior.Size / 2
	if math.abs(p.X) > half.X or math.abs(p.Z) > half.Z or p.Y < -half.Y - 3 or p.Y > half.Y then
		return nil
	end
	local floorHeight = interior:GetAttribute("FloorHeight") or 22
	return math.clamp(math.floor((p.Y + half.Y) / floorHeight) + 1, 1, #GameConfig.FloorPrices)
end

---------------------------------------------------------------------
-- DIGGING
---------------------------------------------------------------------
-- Optional sound effects. Paste a sound's id from the Toolbox (e.g. "rbxassetid://123456")
-- and it plays; leave "" for silence.
GameConfig.Sounds = {
	Dig = "",    -- every time the pickaxe hits the dirt
	Clang = "",  -- pickaxe bounces off a zone that's too hard
	Find = "",   -- an artifact pops out of the ground
	Combo = "",  -- combo goes up
}


-- Chance that a find becomes a "Lucky Dig" with the bonus minigame (0.1 = 1 in 10)
GameConfig.MinigameChance = 0.1

-- The pit resets (refills with dirt) every this many minutes
GameConfig.PitResetMinutes = 15

---------------------------------------------------------------------
-- WORLDS
-- Every world has its own pit, its own 4 depth zones, its own shovels and its own memes.
-- To add a world: fill in its Zones (which artifact areas + rarities spawn where),
-- its Shovels (MaxZone = deepest zone that shovel can break into), then set Enabled = true.
--
-- Zone depths are in studs below the surface. Rarities = the ONLY rarities that can spawn
-- in that zone (so Mythic+ can only come from the Abyss). Areas = which artifact lists
-- from ArtifactData the zone pulls from.
---------------------------------------------------------------------
local function zones(list)
	-- Standard 560-stud depth scale shared by every world; each zone is thicker than the one above
	local depths = {{0, 80}, {80, 200}, {200, 360}, {360, 560}}
	for i, zone in ipairs(list) do
		zone.Index = i
		zone.Top = -depths[i][1]
		zone.Bottom = -depths[i][2]
	end
	return list
end

local SHALLOW = {"Common", "Uncommon", "Rare"}
local MID = {"Rare", "Epic"}
local DEEP = {"Epic", "Legendary"}
local ABYSS = {"Mythic", "Divine", "Celestial", "Transcendent"}

GameConfig.Worlds = {
	{
		Id = 1, Name = "The Meme Dig Site", Enabled = true, Price = 0,
		Origin = Vector3.new(0, 0, 0),
		PitRadius = 41,          -- how far from the center you can dig
		CenterNoDigRadius = 9,   -- keeps the giant hard drive standing
		HubPaths = true,         -- world 1 has the 6 walkways around the pit
		Zones = zones({
			{Name = "Shallow Zone", Era = "Brainrot", Areas = {1}, Rarities = SHALLOW,
				Material = "Ground", Color = Color3.fromRGB(176, 138, 96)},
			{Name = "Mid Zone", Era = "GoldenAge", Areas = {8}, Rarities = MID,
				Material = "Sandstone", Color = Color3.fromRGB(214, 186, 128)},
			{Name = "Deep Zone", Era = "Paleolithic", Areas = {15}, Rarities = DEEP,
				Material = "CrackedLava", Color = Color3.fromRGB(214, 110, 70)},
			{Name = "The Abyss", Era = "Abyss", Areas = {15, 21}, Rarities = ABYSS,
				Material = "Glacier", Color = Color3.fromRGB(150, 196, 214)},
		}),
		-- PICKAXES (shop order; the table is still called Shovels and the ids are the old save ids). MaxZone: 1 = Shallow, 2 = Mid, 3 = Deep, 4 = Abyss.
		-- Power = how big a crater each swing carves (radius = GameConfig.DigRadiusForPower), FindChance = chance per swing to find something (0.02 = 1 in 50),
		-- Luck = rare find multiplier, Cooldown = seconds between swings
		Shovels = {
			{Id = "RustyShovel", Name = "Rusty Pickaxe", Price = 0, MaxZone = 1,
				Power = 1, FindChance = 0.012, Luck = 1, Cooldown = 0.5,
				Color = Color3.fromRGB(150, 85, 50), Material = "CorrodedMetal",
				Description = "Found in a dumpster in 2049. Still swings. Mostly."},
			{Id = "PlasticShovel", Name = "Stone Pickaxe", Price = 500, MaxZone = 2,
				Power = 2, FindChance = 0.013, Luck = 1.1, Cooldown = 0.47,
				Color = Color3.fromRGB(255, 200, 40), Material = "SmoothPlastic",
				Description = "Two slabs of rock tied to a stick. A true classic."},
			{Id = "GardenSpade", Name = "Copper Pickaxe", Price = 3000, MaxZone = 2,
				Power = 3, FindChance = 0.015, Luck = 1.2, Cooldown = 0.45,
				Color = Color3.fromRGB(90, 170, 80), Material = "Metal",
				Description = "Shiny orange, and a little green around the edges."},
			{Id = "IronShovel", Name = "Iron Spikebreaker", Price = 15000, MaxZone = 2,
				Power = 4, FindChance = 0.017, Luck = 1.35, Cooldown = 0.42,
				Color = Color3.fromRGB(175, 180, 190), Material = "Metal",
				Description = "A spiky iron head. Cracks ancient comment sections."},
			{Id = "SteelSpade", Name = "Emerald Pickaxe", Price = 60000, MaxZone = 3,
				Power = 5, FindChance = 0.018, Luck = 1.5, Cooldown = 0.39,
				Color = Color3.fromRGB(120, 140, 170), Material = "Metal",
				Description = "Mossy stone with a glowing emerald heart."},
			{Id = "GoldenShovel", Name = "Golden Pick-Hammer", Price = 200000, MaxZone = 3,
				Power = 6, FindChance = 0.02, Luck = 1.7, Cooldown = 0.37,
				Color = Color3.fromRGB(255, 200, 60), Material = "Metal",
				Description = "A pick on one side, a hammer on the other. All gold."},
			{Id = "GamerShovel", Name = "Diamond Pickaxe", Price = 750000, MaxZone = 3,
				Power = 7, FindChance = 0.022, Luck = 2, Cooldown = 0.35,
				Color = Color3.fromRGB(255, 60, 200), Material = "Neon",
				Description = "Pure cyan crystal. The one everybody wants."},
			{Id = "TectonicAuger", Name = "Magma Pickaxe", Price = 3000000, MaxZone = 4,
				Power = 8, FindChance = 0.024, Luck = 2.4, Cooldown = 0.33,
				Color = Color3.fromRGB(128, 132, 138), Material = "Foil",
				Description = "Legendary. Forged in the Deep Zone and still glowing hot."},
			{Id = "SingularitySpade", Name = "Singularity Pickaxe", Price = 10000000, MaxZone = 4,
				Power = 9, FindChance = 0.027, Luck = 3, Cooldown = 0.31,
				Color = Color3.fromRGB(62, 64, 70), Material = "Foil",
				Description = "Mythic. Folds the Abyss around its crystals."},
		},
	},
}

-- Worlds 2-9: floating islands far out on the map, unlocked with money (see WorldsData).
-- Each one has its own dirt materials, memes (ArtifactsWorlds), shovels and sky.
local WorldsData = require(script.Parent:WaitForChild("WorldsData"))
GameConfig.TerrainColors = WorldsData.TerrainColors
local ZONE_INFO = {
	{Name = "Shallow Zone", Rarities = SHALLOW},
	{Name = "Mid Zone", Rarities = MID},
	{Name = "Deep Zone", Rarities = DEEP},
	{Name = "The Abyss", Rarities = ABYSS},
}
for i, info in ipairs(WorldsData.Worlds) do
	local id = i + 1
	local area = 21 + i -- this world's memes (ArtifactData areas 22-29)
	local zoneList = {}
	for z, material in ipairs(info.Zones) do
		table.insert(zoneList, {Name = ZONE_INFO[z].Name, Era = info.Theme, Areas = {area}, Rarities = ZONE_INFO[z].Rarities,
			Material = material, Color = WorldsData.TerrainColors[material]})
	end
	local shovels = {}
	for t, entry in ipairs(info.Shovels) do
		local tier = WorldsData.ShovelTiers[t]
		table.insert(shovels, {
			Id = entry.Id or (entry[1]:gsub("[^%w]", "")), Name = entry[1], Description = entry[2],
			Price = tier.PriceFactor * info.Price, MaxZone = tier.MaxZone,
			Power = tier.Power, FindChance = tier.FindChance, Luck = tier.Luck, Cooldown = tier.Cooldown,
			Color = t % 2 == 1 and info.Look.Main or info.Look.Second, Material = "SmoothPlastic",
			-- PickaxeModels builds these from the world's colors (the tier picks the head shape)
			Look = {Theme = info.Theme, Tier = t, Colors = info.Look},
		})
	end
	table.insert(GameConfig.Worlds, {
		Id = id, Name = info.Name, Enabled = true, Price = info.Price, Theme = info.Theme, Tagline = info.Tagline,
		-- on a huge ring far from World 1 and from each other (~9000 studs apart), so no
		-- island can see another one
		Origin = Vector3.new(math.cos(math.rad(i * 45)) * 12000, 0, math.sin(math.rad(i * 45)) * 12000),
		PitRadius = 41, CenterNoDigRadius = 0, HubPaths = false,
		IslandRadius = 125, -- floating island around the pit (built by WorldBuilder)
		TopMaterial = info.Top, WallMaterial = info.Wall,
		Look = info.Look, Sky = info.Sky,
		Zones = zones(zoneList),
		Shovels = shovels,
	})
end

GameConfig.BedrockThickness = 8
-- rock strata in the pit: a layer this thick every Gap studs, reaching this far into the walls
local STRATA = {First = 14, Gap = 18, Thickness = 4, IntoWall = 8}

-- Crater size: every point of Power adds half a stud to the radius of the hole a swing digs
function GameConfig.DigRadiusForPower(power)
	return 3.5 + 0.5 * power
end

-- Every shovel from every world, in one list (ids must be unique across worlds)
GameConfig.Shovels = {}
local shovelById = {}
for _, world in ipairs(GameConfig.Worlds) do
	for _, shovel in ipairs(world.Shovels) do
		shovel.World = world.Id
		shovel.DigRadius = GameConfig.DigRadiusForPower(shovel.Power)
		table.insert(GameConfig.Shovels, shovel)
		shovelById[shovel.Id] = shovel
	end
end

function GameConfig.GetShovel(shovelId)
	return shovelById[shovelId]
end

function GameConfig.GetWorld(worldId)
	return GameConfig.Worlds[worldId]
end

-- The starter (free) shovel of a world
function GameConfig.GetStarterShovel(world)
	return world.Shovels[1]
end

-- Which world is this position in? (the nearest world origin)
function GameConfig.GetWorldAt(position)
	local best, bestDistance = GameConfig.Worlds[1], math.huge
	for _, world in ipairs(GameConfig.Worlds) do
		local offset = position - world.Origin
		local distance = Vector3.new(offset.X, 0, offset.Z).Magnitude
		if distance < bestDistance then
			best, bestDistance = world, distance
		end
	end
	return best
end

-- Returns the zone index and zone at a height in a world, or nil if it's bedrock
function GameConfig.GetZoneAt(world, y)
	local depth = world.Origin.Y - y
	for i, zone in ipairs(world.Zones) do
		local top = (i == 1) and -math.huge or -zone.Top
		if depth >= top and depth < -zone.Bottom then
			return i, zone
		end
	end
	return nil, nil
end

-- The cheapest shovel in a world that can break into a zone
function GameConfig.GetFirstShovelForZone(world, zoneIndex)
	for _, shovel in ipairs(world.Shovels) do
		if shovel.MaxZone >= zoneIndex then
			return shovel
		end
	end
	return nil
end

-- THE PIT VOLUME: a box around a world's pit, from a little above the ground down to bedrock.
-- Scripts ask "is this character inside the pit?" with workspace:GetPartBoundsInBox, so the
-- answer is right the moment you step over the edge (no distance guessing).
function GameConfig.GetPitBox(world)
	local lastZone = world.Zones[#world.Zones]
	local top, bottom = world.Origin.Y + 6, world.Origin.Y + lastZone.Bottom - GameConfig.BedrockThickness
	local size = Vector3.new(world.PitRadius * 2 + 2, top - bottom, world.PitRadius * 2 + 2)
	return CFrame.new(world.Origin.X, (top + bottom) / 2, world.Origin.Z), size
end

-- Is this character standing in (or falling through) the pit of this world?
function GameConfig.IsInPit(world, character)
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return false end
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.MaxParts = 1
	params.FilterDescendantsInstances = {character} -- any body part inside the box counts
	local cf, size = GameConfig.GetPitBox(world)
	if #workspace:GetPartBoundsInBox(cf, size, params) == 0 then return false end
	-- the pit is round: trim the box's corners
	local offset = root.Position - world.Origin
	return Vector3.new(offset.X, 0, offset.Z).Magnitude <= world.PitRadius + 1
end

-- Fills a world's dig site with terrain: ground around, the 4 zones in the pit, bedrock below.
-- Used on server start and every pit reset.
function GameConfig.FillDigTerrain(terrain, world)
	local origin = world.Origin
	local radius = world.PitRadius + 2
	local top = origin.Y
	local lastZone = world.Zones[#world.Zones]
	local bottom = top + lastZone.Bottom - GameConfig.BedrockThickness
	local depth = top - bottom
	local wall = Enum.Material[world.WallMaterial or "Slate"]
	local surface = Enum.Material[world.TopMaterial or "Grass"]
	if world.IslandRadius then
		-- floating island worlds: only the column around the pit gets refilled
		-- (WorldBuilder shapes the rest of the island once)
		local column = world.PitRadius + 12
		terrain:FillCylinder(CFrame.new(origin + Vector3.new(0, 8, 0)), 16, column, Enum.Material.Air)
		terrain:FillCylinder(CFrame.new(origin + Vector3.new(0, -depth / 2, 0)), depth, column, wall)
		terrain:FillCylinder(CFrame.new(origin + Vector3.new(0, -2, 0)), 4, column, surface)
	else
		-- clear anything above ground level (terrain works in 4-stud blocks)
		terrain:FillBlock(CFrame.new(origin + Vector3.new(0, 8, 0)), Vector3.new(200, 16, 200), Enum.Material.Air)
		-- stone ground around the pit (and under it), with a grassy top layer
		terrain:FillBlock(CFrame.new(origin + Vector3.new(0, -depth / 2, 0)), Vector3.new(200, depth, 200), wall)
		terrain:FillBlock(CFrame.new(origin + Vector3.new(0, -2, 0)), Vector3.new(200, 4, 200), surface)
	end
	if world.HubPaths then
		-- keep the walkways clear (otherwise the stone pokes through them)
		for k = 0, 5 do
			local a = math.rad(k * 60)
			local dir = Vector3.new(math.cos(a), 0, math.sin(a))
			local mid = origin + dir * 88
			terrain:FillBlock(CFrame.lookAt(mid, mid + dir) * CFrame.new(0, 4, 0), Vector3.new(14, 16, 84), Enum.Material.Air)
		end
	end
	-- the 4 depth zones
	for _, zone in ipairs(world.Zones) do
		local height = zone.Top - zone.Bottom
		terrain:FillCylinder(CFrame.new(origin + Vector3.new(0, zone.Bottom + height / 2, 0)), height, radius, Enum.Material[zone.Material])
	end
	-- rock strata: thin layers of other rock run through the dirt and on into the pit walls,
	-- so every crater wall and the edge of the pit show stripes like a real dig site
	for i, zone in ipairs(world.Zones) do
		local nextZone = world.Zones[i + 1]
		local k = 0
		for d = -zone.Top + STRATA.First, -zone.Bottom - STRATA.Gap / 2, STRATA.Gap do
			k += 1
			local material = (k % 2 == 1 or not nextZone) and wall or Enum.Material[nextZone.Material]
			terrain:FillCylinder(CFrame.new(origin + Vector3.new(0, -d, 0)), STRATA.Thickness, radius + STRATA.IntoWall, material)
		end
	end
	-- bedrock
	terrain:FillCylinder(CFrame.new(origin + Vector3.new(0, lastZone.Bottom - GameConfig.BedrockThickness / 2, 0)),
		GameConfig.BedrockThickness, radius, Enum.Material.Basalt)
end

return GameConfig
