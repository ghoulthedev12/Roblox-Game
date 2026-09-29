-- GameConfig (ModuleScript in ReplicatedStorage)
-- All the numbers you might want to tweak, in one place.

local GameConfig = {}

-- Money you start with
GameConfig.StartingMoney = 0

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

---------------------------------------------------------------------
-- DIGGING
---------------------------------------------------------------------
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
	-- Standard 250-stud depth scale shared by every world
	local depths = {{0, 50}, {50, 130}, {130, 200}, {200, 250}}
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
		-- SHOVELS (shop order). MaxZone: 1 = Shallow, 2 = Mid, 3 = Deep, 4 = Abyss.
		-- DigRadius = hole size, FindChance = chance per swing to find something,
		-- Luck = rare find multiplier, Cooldown = seconds between swings
		Shovels = {
			{Id = "RustyShovel", Name = "Rusty Shovel", Price = 0, MaxZone = 1,
				DigRadius = 4, FindChance = 0.04, Luck = 1, Cooldown = 0.7,
				Color = Color3.fromRGB(150, 85, 50), Material = "CorrodedMetal",
				Description = "Found in a dumpster in 2049. Still works. Mostly."},
			{Id = "PlasticShovel", Name = "Plastic Beach Shovel", Price = 1000, MaxZone = 2,
				DigRadius = 4.5, FindChance = 0.045, Luck = 1.1, Cooldown = 0.67,
				Color = Color3.fromRGB(255, 200, 40), Material = "SmoothPlastic",
				Description = "Built for sandcastles. Somehow better than rust."},
			{Id = "GardenSpade", Name = "Garden Spade", Price = 7500, MaxZone = 2,
				DigRadius = 5, FindChance = 0.05, Luck = 1.2, Cooldown = 0.64,
				Color = Color3.fromRGB(90, 170, 80), Material = "Metal",
				Description = "Borrowed from a grandma. She wants it back."},
			{Id = "IronShovel", Name = "Iron Shovel", Price = 40000, MaxZone = 2,
				DigRadius = 5.5, FindChance = 0.055, Luck = 1.35, Cooldown = 0.6,
				Color = Color3.fromRGB(175, 180, 190), Material = "Metal",
				Description = "A real tool for a real archaeologist."},
			{Id = "SteelSpade", Name = "Steel Spade", Price = 200000, MaxZone = 3,
				DigRadius = 6, FindChance = 0.06, Luck = 1.5, Cooldown = 0.56,
				Color = Color3.fromRGB(120, 140, 170), Material = "Metal",
				Description = "Sharp enough to cut through ancient comment sections."},
			{Id = "GoldenShovel", Name = "Golden Shovel", Price = 500000, MaxZone = 3,
				DigRadius = 6.5, FindChance = 0.065, Luck = 1.7, Cooldown = 0.53,
				Color = Color3.fromRGB(255, 200, 60), Material = "Metal",
				Description = "Shiny. Heavy. Completely unnecessary. Perfect."},
			{Id = "GamerShovel", Name = "RGB Gamer Shovel", Price = 1000000, MaxZone = 3,
				DigRadius = 7, FindChance = 0.07, Luck = 2, Cooldown = 0.5,
				Color = Color3.fromRGB(255, 60, 200), Material = "Neon",
				Description = "The RGB lights add +200% digging power. Science."},
			{Id = "TectonicAuger", Name = "Tectonic Auger", Price = 10000000, MaxZone = 4,
				DigRadius = 7.5, FindChance = 0.075, Luck = 2.4, Cooldown = 0.47,
				Color = Color3.fromRGB(128, 132, 138), Material = "Foil",
				Description = "Legendary. Rated for bedrock, permafrost and 2049-era server racks."},
			{Id = "SingularitySpade", Name = "Singularity Spade", Price = 50000000, MaxZone = 4,
				DigRadius = 8, FindChance = 0.085, Luck = 3, Cooldown = 0.44,
				Color = Color3.fromRGB(62, 64, 70), Material = "Foil",
				Description = "Mythic. Folds the Abyss around the blade. Do not dig near pets."},
		},
	},
}

-- Worlds 2-9: placeholders. Each one sits far out on the map and is unlocked with money.
-- Give each one Zones + Shovels like World 1 above, then set Enabled = true.
local FUTURE_WORLD_PRICES = {1e9, 25e9, 500e9, 10e12, 250e12, 5e15, 100e15, 2.5e18}
for i, price in ipairs(FUTURE_WORLD_PRICES) do
	local id = i + 1
	table.insert(GameConfig.Worlds, {
		Id = id, Name = "World " .. id, Enabled = false, Price = price,
		Origin = Vector3.new(0, 0, 3000 * id), -- far away along +Z, clear of the city
		PitRadius = 41, CenterNoDigRadius = 0, HubPaths = false,
		Zones = zones({
			{Name = "Shallow Zone", Era = "Brainrot", Areas = {1}, Rarities = SHALLOW, Material = "Ground", Color = Color3.fromRGB(176, 138, 96)},
			{Name = "Mid Zone", Era = "GoldenAge", Areas = {8}, Rarities = MID, Material = "Sandstone", Color = Color3.fromRGB(214, 186, 128)},
			{Name = "Deep Zone", Era = "Paleolithic", Areas = {15}, Rarities = DEEP, Material = "CrackedLava", Color = Color3.fromRGB(214, 110, 70)},
			{Name = "The Abyss", Era = "Abyss", Areas = {21}, Rarities = ABYSS, Material = "Glacier", Color = Color3.fromRGB(150, 196, 214)},
		}),
		Shovels = {},
	})
end

GameConfig.BedrockThickness = 8

-- Every shovel from every world, in one list (ids must be unique across worlds)
GameConfig.Shovels = {}
local shovelById = {}
for _, world in ipairs(GameConfig.Worlds) do
	for _, shovel in ipairs(world.Shovels) do
		shovel.World = world.Id
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

-- Fills a world's dig site with terrain: stone ground around, the 4 zones in the pit, bedrock below.
-- Used on server start and every pit reset.
function GameConfig.FillDigTerrain(terrain, world)
	local origin = world.Origin
	local radius = world.PitRadius + 2
	local top = origin.Y
	local lastZone = world.Zones[#world.Zones]
	local bottom = top + lastZone.Bottom - GameConfig.BedrockThickness
	local depth = top - bottom
	-- clear anything above ground level (terrain works in 4-stud blocks)
	terrain:FillBlock(CFrame.new(origin + Vector3.new(0, 8, 0)), Vector3.new(200, 16, 200), Enum.Material.Air)
	-- stone ground around the pit (and under it), with a grassy top layer
	terrain:FillBlock(CFrame.new(origin + Vector3.new(0, -depth / 2, 0)), Vector3.new(200, depth, 200), Enum.Material.Slate)
	terrain:FillBlock(CFrame.new(origin + Vector3.new(0, -2, 0)), Vector3.new(200, 4, 200), Enum.Material.Grass)
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
	-- bedrock
	terrain:FillCylinder(CFrame.new(origin + Vector3.new(0, lastZone.Bottom - GameConfig.BedrockThickness / 2, 0)),
		GameConfig.BedrockThickness, radius, Enum.Material.Basalt)
end

return GameConfig
