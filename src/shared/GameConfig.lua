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
-- AUDIO. The game's own sounds and music are made by tools/make_audio.py and uploaded with
-- tools/upload_audio.py, which fills in AudioAssets. Until then, effects use sounds built
-- into Roblox and there's no music.
local AudioAssets = require(script.Parent:WaitForChild("AudioAssets"))
local function asset(name, fallback)
	local id = AudioAssets[name]
	return (id and id ~= "") and id or fallback
end

-- Sound effects. Mix = its level inside the SFX channel (the Settings slider sets the channel;
-- at the default 20% every effect plays at an effective 0.15-0.2 volume).
-- MinGap = seconds before the same sound can play again, MaxVoices = how many copies may ring
-- at once (so fast digging can't stack into noise), Jitter = random pitch +/- (organic, not robotic).
GameConfig.Sounds = {
	Dig = {Id = asset("sfx_dig", "rbxasset://sounds/collide.wav"), Mix = 0.95, MinGap = 0.25, MaxVoices = 2, Jitter = 0.05},
	Clang = {Id = asset("sfx_clang", "rbxasset://sounds/swordslash.wav"), Mix = 0.8, MinGap = 0.45, MaxVoices = 1, Jitter = 0.03},
	Find = {Id = asset("sfx_find", "rbxasset://sounds/electronicpingshort.wav"), Mix = 1, MinGap = 0.8, MaxVoices = 1, Jitter = 0},
	Combo = {Id = asset("sfx_combo", "rbxasset://sounds/clickfast.wav"), Mix = 0.6, MinGap = 0.5, MaxVoices = 1, Jitter = 0.02},
	Click = {Id = asset("sfx_click", "rbxasset://sounds/button.wav"), Mix = 0.8, MinGap = 0.06, MaxVoices = 2, Jitter = 0.03},
}

-- BACKGROUND MUSIC per world (AudioClient loops it and crossfades when you travel).
-- To use your own track instead, paste "rbxassetid://<id>" of any audio you can use.
GameConfig.Music = {
	Default = "",
	[1] = asset("music_world1", ""),  -- The Meme Dig Site: lo-fi chill beats
	[2] = asset("music_world2", ""),  -- Neon Sakura Grove: koto plucks over soft pads
	[3] = asset("music_world3", ""),  -- Galaxy Drift: dreamy space ambient
	[4] = asset("music_world4", ""),  -- Frostbyte Tundra: icy bells and wind
	[5] = asset("music_world5", ""),  -- Chrome Dunes: desert hand drums and oud
	[6] = asset("music_world6", ""),  -- Coral Circuit: muffled underwater chill
	[7] = asset("music_world7", ""),  -- Candy Mainframe: bubbly pop
	[8] = asset("music_world8", ""),  -- Volcano Forge: heavy drums
	[9] = asset("music_world9", ""),  -- Glitch Nexus: synthwave
}
GameConfig.MusicVolume = 1        -- track level inside the Music channel (the slider sets the channel)
GameConfig.MusicCrossfade = 1.5   -- seconds to fade between worlds' tracks
-- default settings for new players (and players from before the audio fix)
GameConfig.DefaultAudio = {MusicVolume = 0.3, SfxVolume = 0.2, MusicMuted = false, SfxMuted = false}
GameConfig.AudioSettingsVersion = 2 -- saved settings older than this are reset to DefaultAudio


-- REBIRTH: trade in your cash for a permanent boost. Cost = RebirthBaseCost x RebirthCostGrowth ^ rebirths.
-- Each rebirth adds RebirthIncomeBonus (0.25 = +25%) to all museum income forever and gives gems.
-- Gems buy the Lucky Charm upgrade: +GemLuckPerLevel luck per level (cost = level x GemLuckCost gems).
GameConfig.RebirthBaseCost = 10e6
GameConfig.RebirthCostGrowth = 5
GameConfig.RebirthIncomeBonus = 0.25
GameConfig.RebirthGems = 10       -- gems for rebirth #1; each later rebirth gives 5 more
GameConfig.GemLuckPerLevel = 0.1
GameConfig.GemLuckCost = 5
GameConfig.GemLuckMaxLevel = 20
function GameConfig.RebirthCost(rebirths)
	return GameConfig.RebirthBaseCost * GameConfig.RebirthCostGrowth ^ rebirths
end
function GameConfig.RebirthGemReward(rebirths)
	return GameConfig.RebirthGems + 5 * rebirths
end

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
-- in that zone ("Secret" = the world's secret rarities, only in the Abyss). Areas = which
-- world's memes the zone pulls from (ArtifactData area = world number).
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

local SHALLOW = {"Basic", "Common", "Uncommon"}
local MID = {"Uncommon", "Rare"}
local DEEP = {"Rare", "Epic"}
local ABYSS = {"Legendary", "Secret"}

GameConfig.Worlds = {
	{
		Id = 1, Name = "The Meme Dig Site", Enabled = true, Price = 0,
		Origin = Vector3.new(0, 0, 0),
		PitRadius = 41,          -- how far from the center you can dig
		CenterNoDigRadius = 9,   -- keeps the giant hard drive standing
		HubPaths = true,         -- world 1 has the 6 walkways around the pit
		WorkYard = {Radius = 124, Material = "Ground"}, -- the dirt work yard around the dig site
		Zones = zones({
			-- the layers you dig through: Topsoil -> Dense Clay -> (rocky crust bands) ->
			-- Crystal-Infused Substratum -> Magma Core (see also the rock strata in FillDigTerrain)
			{Name = "Shallow Zone", Areas = {1}, Rarities = SHALLOW,
				Material = "Ground", Color = Color3.fromRGB(150, 104, 70)},     -- topsoil
			{Name = "Mid Zone", Areas = {1}, Rarities = MID,
				Material = "Sandstone", Color = Color3.fromRGB(188, 112, 78)},  -- dense clay
			{Name = "Deep Zone", Areas = {1}, Rarities = DEEP,
				Material = "Glacier", Color = Color3.fromRGB(120, 200, 235)},   -- crystal-infused substratum
			{Name = "The Abyss", Areas = {1}, Rarities = ABYSS,
				Material = "CrackedLava", Color = Color3.fromRGB(235, 96, 50)}, -- magma core
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
			{Id = "GardenSpade", Name = "Bone Excavator", Price = 3000, MaxZone = 2,
				Power = 3, FindChance = 0.015, Luck = 1.2, Cooldown = 0.45,
				Color = Color3.fromRGB(90, 170, 80), Material = "Metal",
				Description = "Dinosaur bones with a skull for a socket. Surprisingly sharp."},
			{Id = "IronShovel", Name = "Iron Spikebreaker", Price = 15000, MaxZone = 2,
				Power = 4, FindChance = 0.017, Luck = 1.35, Cooldown = 0.42,
				Color = Color3.fromRGB(175, 180, 190), Material = "Metal",
				Description = "A spiky iron head. Cracks ancient comment sections."},
			{Id = "SteelSpade", Name = "Mechanical Drill", Price = 60000, MaxZone = 3,
				Power = 5, FindChance = 0.018, Luck = 1.5, Cooldown = 0.39,
				Color = Color3.fromRGB(120, 140, 170), Material = "Metal",
				Description = "Twin spiral drill bits and a spinning turbine. Bzzzzt."},
			{Id = "GoldenShovel", Name = "Golden Pick-Hammer", Price = 200000, MaxZone = 3,
				Power = 6, FindChance = 0.02, Luck = 1.7, Cooldown = 0.37,
				Color = Color3.fromRGB(255, 200, 60), Material = "Metal",
				Description = "A pick on one side, a hammer on the other. All gold."},
			{Id = "GamerShovel", Name = "Diamond Pickaxe", Price = 750000, MaxZone = 3,
				Power = 7, FindChance = 0.022, Luck = 2, Cooldown = 0.35,
				Color = Color3.fromRGB(255, 60, 200), Material = "Neon",
				Description = "Pure cyan crystal. The one everybody wants."},
			{Id = "TectonicAuger", Name = "Plasma Laser Pick", Price = 3000000, MaxZone = 4,
				Power = 8, FindChance = 0.024, Luck = 2.4, Cooldown = 0.33,
				Color = Color3.fromRGB(128, 132, 138), Material = "Foil",
				Description = "Legendary. Its blade is pure plasma, hot enough to melt the Abyss."},
			{Id = "SingularitySpade", Name = "Quantum Digger", Price = 10000000, MaxZone = 4,
				Power = 9, FindChance = 0.027, Luck = 3, Cooldown = 0.31,
				Color = Color3.fromRGB(62, 64, 70), Material = "Foil",
				Description = "Mythic. An anti-gravity head that floats free of the handle."},
		},
	},
}

-- Worlds 2-9: floating islands far out on the map, unlocked with money (see WorldsData).
-- Each one has its own dirt materials, memes (MemeList), shovels and sky.
local WorldsData = require(script.Parent:WaitForChild("WorldsData"))
GameConfig.TerrainColors = WorldsData.TerrainColors
local ZONE_INFO = {
	{Name = "Shallow Zone", Rarities = SHALLOW},
	{Name = "Mid Zone", Rarities = MID},
	{Name = "Deep Zone", Rarities = DEEP},
	{Name = "The Abyss", Rarities = ABYSS},
}
-- World prices after Neon Sakura Grove (world 2) follow a steep curve so nobody rushes
-- through every world: Cost = BaseCost x Multiplier ^ (world number - 3)
-- (world 3 = $500M, 4 = $2.5B, 5 = $12.5B, 6 = $62.5B, 7 = $312.5B, 8 = $1.56T, 9 = $7.8T)
GameConfig.WorldPriceCurve = {BaseCost = 500e6, Multiplier = 5, FromWorld = 3}
local function worldPrice(id, info)
	local curve = GameConfig.WorldPriceCurve
	if id < curve.FromWorld then return info.Price end
	return curve.BaseCost * curve.Multiplier ^ (id - curve.FromWorld)
end

for i, info in ipairs(WorldsData.Worlds) do
	local id = i + 1
	local price = worldPrice(id, info)
	local area = id -- this world's memes (ArtifactData area = world number)
	local zoneList = {}
	for z, material in ipairs(info.Zones) do
		table.insert(zoneList, {Name = ZONE_INFO[z].Name, Areas = {area}, Rarities = ZONE_INFO[z].Rarities,
			Material = material, Color = WorldsData.TerrainColors[material]})
	end
	local shovels = {}
	for t, entry in ipairs(info.Shovels) do
		local tier = WorldsData.ShovelTiers[t]
		table.insert(shovels, {
			Id = entry.Id or (entry[1]:gsub("[^%w]", "")), Name = entry[1], Description = entry[2],
			Price = tier.PriceFactor * price, MaxZone = tier.MaxZone,
			Power = tier.Power, FindChance = tier.FindChance, Luck = tier.Luck, Cooldown = tier.Cooldown,
			Color = t % 2 == 1 and info.Look.Main or info.Look.Second, Material = "SmoothPlastic",
			-- PickaxeModels builds these from the world's colors (the tier picks the head shape)
			Look = {Theme = info.Theme, Tier = t, Colors = info.Look},
		})
	end
	table.insert(GameConfig.Worlds, {
		Id = id, Name = info.Name, Enabled = true, Price = price, Theme = info.Theme, Tagline = info.Tagline,
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

GameConfig.BedrockThickness = 16 -- the indestructible floor under every pit
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

-- DEPTH BONUS: the deeper you dig, the luckier your finds: x1 at the surface up to x1.6 at
-- the very bottom of the Abyss (shown under the depth gauge)
function GameConfig.DepthBonus(world, y)
	local total = -world.Zones[#world.Zones].Bottom
	local depth = math.clamp(world.Origin.Y - y, 0, total)
	return 1 + 0.6 * depth / total
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

-- the island's paved slabs (MainIsland), set into beds dug out of the terrain
local SLABS = {Boulevard = true, SidewalkIn = true, SidewalkOut = true, Avenue = true, MuseumWalk = true}

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
	if world.WorkYard then
		-- under the plaza ring around the yard: stone, not grass (grass blades would poke up
		-- through the plaza tiles and the yard's curb). Wide enough to cover the corners of the
		-- 200-stud square of grass above (they reach out to 141 studs on the diagonals).
		terrain:FillCylinder(CFrame.new(origin + Vector3.new(0, -2, 0)), 4, world.WorkYard.Radius + 24, Enum.Material.Slate)
		-- a dirt work yard around the dig site, inside the plaza's mosaic ring
		terrain:FillCylinder(CFrame.new(origin + Vector3.new(0, -2, 0)), 4, world.WorkYard.Radius, Enum.Material[world.WorkYard.Material])
	end
	if world.HubPaths then
		-- keep the walkways clear (otherwise the stone pokes through them); only as far as the
		-- walkway goes (116 studs out): past that, the ramp sits on the ground, see DigSiteStyle
		for k = 0, 5 do
			local a = math.rad(k * 60)
			local dir = Vector3.new(math.cos(a), 0, math.sin(a))
			local mid = origin + dir * 81.5
			terrain:FillBlock(CFrame.lookAt(mid, mid + dir) * CFrame.new(0, 4, 0), Vector3.new(14, 16, 71), Enum.Material.Air)
		end
		-- the walkways sit 2.6 studs up: sloped banks of earth along both sides rise to meet
		-- them, so you can walk from the ground straight onto a walkway (no wall to jump)
		-- (the banks start past the stone shoulders beside each walkway, see DigSiteStyle, and stay
		-- a little lower: terrain on a slant is a sawtooth of 4-stud cubes that would bite into
		-- the walkway's edge; the shoulders hide where it meets them)
		local bank = Enum.Material[world.WorkYard and world.WorkYard.Material or world.TopMaterial or "Grass"]
		for k = 0, 5 do
			local a = math.rad(k * 60)
			local dir = Vector3.new(math.cos(a), 0, math.sin(a))
			local side = Vector3.new(-dir.Z, 0, dir.X)
			for _, s in ipairs({-1, 1}) do
				local toWalk = -side * s -- the bank's high side faces the walkway
				local pos = origin + dir * 81 + side * s * (12.5 + 4.5) + Vector3.new(0, 0.8, 0)
				terrain:FillWedge(CFrame.fromMatrix(pos, Vector3.yAxis:Cross(toWalk), Vector3.yAxis), Vector3.new(66, 1.6, 9), bank)
			end
			-- the terrain stays well under the walkway and its shoulders (their tops are at 2.6; a
			-- bumpy terrain surface right at that height pokes through in places)
			local mid = origin + dir * 81
			terrain:FillBlock(CFrame.lookAt(mid, mid + dir) * CFrame.new(0, 1.7 + 8, 0), Vector3.new(25, 16, 72), Enum.Material.Air)
		end
	end
	-- the 4 depth zones
	for _, zone in ipairs(world.Zones) do
		local height = zone.Top - zone.Bottom
		terrain:FillCylinder(CFrame.new(origin + Vector3.new(0, zone.Bottom + height / 2, 0)), height, radius, Enum.Material[zone.Material])
	end
	-- patchy floor: the next layer's material peeks through the top dirt in a few spots,
	-- so the pit floor isn't one flat color
	local patches = Random.new(world.Id * 31)
	local patchMaterial = Enum.Material[(world.Zones[2] or world.Zones[1]).Material]
	for _ = 1, 9 do
		local a = patches:NextNumber(0, math.pi * 2)
		local d = patches:NextNumber(world.CenterNoDigRadius and world.CenterNoDigRadius + 6 or 6, world.PitRadius - 6)
		local r = patches:NextNumber(3, 4.5)
		terrain:FillBall(origin + Vector3.new(math.cos(a) * d, -r - 0.2, math.sin(a) * d), r, patchMaterial)
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
	if world.IslandRadius then
		GameConfig.FlattenGround(terrain, origin, (world.PitRadius + 12) * 2)
	else
		-- (all the way out past the stone ring: a full top block left anywhere bulges up as a
		-- mound over the paths and the yard's curb)
		GameConfig.FlattenGround(terrain, origin, math.max(200, world.WorkYard and (world.WorkYard.Radius + 24) * 2 + 8 or 0))
	end
	if world.WorkYard then
		-- the stone ring refilled the beds the island's paved slabs sit in (MainIsland digs them
		-- out): dig them out again, or the bumpy ground at the slabs' own height flickers
		-- through their tops
		local ground = workspace:FindFirstChild("MainIsland") and workspace.MainIsland:FindFirstChild("Ground")
		local reach = world.WorkYard.Radius + 24 + 30
		for _, part in ipairs(ground and ground:GetChildren() or {}) do
			if SLABS[part.Name] and part:IsA("BasePart") then
				local pos = part.Position
				if Vector3.new(pos.X - origin.X, 0, pos.Z - origin.Z).Magnitude < reach then
					terrain:FillBlock(CFrame.new(pos.X, origin.Y - 2, pos.Z) * part.CFrame.Rotation, Vector3.new(part.Size.X, 4, part.Size.Z), Enum.Material.Air)
				end
			end
		end
	end
end

-- Terrain filled up to y = 0 shows its surface at y = 2 (a full top block rounds up), which
-- buries everything laid flat on the ground. Emptying the top 2 studs of that block (y -2 to
-- 0) leaves it half full, so the surface sits exactly at y = 0 and keeps its material.
function GameConfig.FlattenGround(terrain, center, size)
	terrain:FillBlock(CFrame.new(center + Vector3.new(0, -1, 0)), Vector3.new(size, 2, size), Enum.Material.Air)
end

return GameConfig
