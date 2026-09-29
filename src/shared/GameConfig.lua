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
-- Uses the museum's Floor1Arrival spot (in the middle of the back of the hall) as reference.
function GameConfig.GetMuseumFloor(museum, position)
	local arrivals = museum:FindFirstChild("Arrivals")
	local first = arrivals and arrivals:FindFirstChild("Floor1Arrival")
	if not first or not first:IsA("BasePart") then return nil end
	local p = first.CFrame:PointToObjectSpace(position)
	-- the hall is 96 studs wide and runs from the entrance (-107) to the back wall (+28)
	if math.abs(p.X) > 48 or p.Z < -108 or p.Z > 29 or p.Y < -6 or p.Y > 96 then
		return nil
	end
	return math.clamp(math.floor((p.Y + 6) / 32) + 1, 1, #GameConfig.FloorPrices)
end

---------------------------------------------------------------------
-- DIGGING
---------------------------------------------------------------------
-- Optional sound effects. Paste a sound's id from the Toolbox (e.g. "rbxassetid://123456")
-- and it plays; leave "" for silence.
GameConfig.Sounds = {
	Dig = "",    -- every time the shovel hits the dirt
	Clang = "",  -- shovel bounces off a zone that's too hard
	Find = "",   -- an artifact pops out of the ground
	Combo = "",  -- combo goes up
}

-- How shovels look: "Crystal" = the blocky/crystal design, upgraded procedurally by each
-- shovel's Power (size, crystal color, spinning orbiters, particles). "Classic" = the older
-- hand-made models (World 1 cartoon shovels + themed world shovels).
GameConfig.ShovelLook = "Crystal"

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
		-- SHOVELS (shop order). MaxZone: 1 = Shallow, 2 = Mid, 3 = Deep, 4 = Abyss.
		-- Power = how big a crater each swing carves (radius = GameConfig.DigRadiusForPower), FindChance = chance per swing to find something (0.02 = 1 in 50),
		-- Luck = rare find multiplier, Cooldown = seconds between swings
		Shovels = {
			{Id = "RustyShovel", Name = "Rusty Shovel", Price = 0, MaxZone = 1,
				Power = 1, FindChance = 0.012, Luck = 1, Cooldown = 0.5,
				Color = Color3.fromRGB(150, 85, 50), Material = "CorrodedMetal",
				Description = "Found in a dumpster in 2049. Still works. Mostly."},
			{Id = "PlasticShovel", Name = "Plastic Beach Shovel", Price = 500, MaxZone = 2,
				Power = 2, FindChance = 0.013, Luck = 1.1, Cooldown = 0.47,
				Color = Color3.fromRGB(255, 200, 40), Material = "SmoothPlastic",
				Description = "Built for sandcastles. Somehow better than rust."},
			{Id = "GardenSpade", Name = "Garden Spade", Price = 3000, MaxZone = 2,
				Power = 3, FindChance = 0.015, Luck = 1.2, Cooldown = 0.45,
				Color = Color3.fromRGB(90, 170, 80), Material = "Metal",
				Description = "Borrowed from a grandma. She wants it back."},
			{Id = "IronShovel", Name = "Iron Shovel", Price = 15000, MaxZone = 2,
				Power = 4, FindChance = 0.017, Luck = 1.35, Cooldown = 0.42,
				Color = Color3.fromRGB(175, 180, 190), Material = "Metal",
				Description = "A real tool for a real archaeologist."},
			{Id = "SteelSpade", Name = "Steel Spade", Price = 60000, MaxZone = 3,
				Power = 5, FindChance = 0.018, Luck = 1.5, Cooldown = 0.39,
				Color = Color3.fromRGB(120, 140, 170), Material = "Metal",
				Description = "Sharp enough to cut through ancient comment sections."},
			{Id = "GoldenShovel", Name = "Golden Shovel", Price = 200000, MaxZone = 3,
				Power = 6, FindChance = 0.02, Luck = 1.7, Cooldown = 0.37,
				Color = Color3.fromRGB(255, 200, 60), Material = "Metal",
				Description = "Shiny. Heavy. Completely unnecessary. Perfect."},
			{Id = "GamerShovel", Name = "RGB Gamer Shovel", Price = 750000, MaxZone = 3,
				Power = 7, FindChance = 0.022, Luck = 2, Cooldown = 0.35,
				Color = Color3.fromRGB(255, 60, 200), Material = "Neon",
				Description = "The RGB lights add +200% digging power. Science."},
			{Id = "TectonicAuger", Name = "Tectonic Auger", Price = 3000000, MaxZone = 4,
				Power = 8, FindChance = 0.024, Luck = 2.4, Cooldown = 0.33,
				Color = Color3.fromRGB(128, 132, 138), Material = "Foil",
				Description = "Legendary. Rated for bedrock, permafrost and 2049-era server racks."},
			{Id = "SingularitySpade", Name = "Singularity Spade", Price = 10000000, MaxZone = 4,
				Power = 9, FindChance = 0.027, Luck = 3, Cooldown = 0.31,
				Color = Color3.fromRGB(62, 64, 70), Material = "Foil",
				Description = "Mythic. Folds the Abyss around the blade. Do not dig near pets."},
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
			Id = (entry[1]:gsub("[^%w]", "")), Name = entry[1], Description = entry[2],
			Price = tier.PriceFactor * info.Price, MaxZone = tier.MaxZone,
			Power = tier.Power, FindChance = tier.FindChance, Luck = tier.Luck, Cooldown = tier.Cooldown,
			Color = t % 2 == 1 and info.Look.Main or info.Look.Second, Material = "SmoothPlastic",
			-- ShovelModels builds these from the world's colors (Theme decides the decorations)
			Look = {Theme = info.Theme, Tier = t, Blade = entry[3], Grip = entry[4], Colors = info.Look},
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
	-- bedrock
	terrain:FillCylinder(CFrame.new(origin + Vector3.new(0, lastZone.Bottom - GameConfig.BedrockThickness / 2, 0)),
		GameConfig.BedrockThickness, radius, Enum.Material.Basalt)
end

return GameConfig
