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

-- Underground layers, top to bottom. Deeper = older = more valuable.
-- Top/Bottom are heights (Y). Price = Dig Permit cost (0 = free).
GameConfig.Layers = {
	{Name = "The Brainrot Epoch", Era = "Brainrot", Top = 0, Bottom = -16, Price = 0,
		Material = "Ground", Color = Color3.fromRGB(190, 140, 90)},
	{Name = "The Golden Age", Era = "GoldenAge", Top = -16, Bottom = -32, Price = 100000,
		Material = "Sandstone", Color = Color3.fromRGB(255, 210, 120)},
	{Name = "The Paleolithic Web", Era = "Paleolithic", Top = -32, Bottom = -48, Price = 250e6,
		Material = "CrackedLava", Color = Color3.fromRGB(255, 110, 60)},
}
GameConfig.BedrockTop = -48
GameConfig.BedrockBottom = -56

-- Returns the layer index and layer at a height, or nil if it's bedrock
function GameConfig.GetLayerAt(y)
	for i, layer in ipairs(GameConfig.Layers) do
		local top = (i == 1) and math.huge or layer.Top
		if y <= top and y > layer.Bottom then
			return i, layer
		end
	end
	return nil, nil
end

-- SHOVELS for the first world (in shop order). Buy the next one to dig faster and luckier.
-- DigRadius = hole size, FindChance = chance per swing to find something,
-- Luck = rare find multiplier, Cooldown = seconds between swings
GameConfig.Shovels = {
	{Id = "RustyShovel", Name = "Rusty Shovel", Price = 0,
		DigRadius = 4, FindChance = 0.04, Luck = 1, Cooldown = 0.7,
		Color = Color3.fromRGB(150, 85, 50), Material = "CorrodedMetal",
		Description = "Found in a dumpster in 2049. Still works. Mostly."},
	{Id = "PlasticShovel", Name = "Plastic Beach Shovel", Price = 1000,
		DigRadius = 4.5, FindChance = 0.045, Luck = 1.1, Cooldown = 0.67,
		Color = Color3.fromRGB(255, 200, 40), Material = "SmoothPlastic",
		Description = "Built for sandcastles. Somehow better than rust."},
	{Id = "GardenSpade", Name = "Garden Spade", Price = 7500,
		DigRadius = 5, FindChance = 0.05, Luck = 1.2, Cooldown = 0.64,
		Color = Color3.fromRGB(90, 170, 80), Material = "Metal",
		Description = "Borrowed from a grandma. She wants it back."},
	{Id = "IronShovel", Name = "Iron Shovel", Price = 40000,
		DigRadius = 5.5, FindChance = 0.055, Luck = 1.35, Cooldown = 0.6,
		Color = Color3.fromRGB(175, 180, 190), Material = "Metal",
		Description = "A real tool for a real archaeologist."},
	{Id = "SteelSpade", Name = "Steel Spade", Price = 200000,
		DigRadius = 6, FindChance = 0.06, Luck = 1.5, Cooldown = 0.56,
		Color = Color3.fromRGB(120, 140, 170), Material = "Metal",
		Description = "Sharp enough to cut through ancient comment sections."},
	{Id = "GoldenShovel", Name = "Golden Shovel", Price = 500000,
		DigRadius = 6.5, FindChance = 0.065, Luck = 1.7, Cooldown = 0.53,
		Color = Color3.fromRGB(255, 200, 60), Material = "Metal",
		Description = "Shiny. Heavy. Completely unnecessary. Perfect."},
	{Id = "GamerShovel", Name = "RGB Gamer Shovel", Price = 1000000,
		DigRadius = 7, FindChance = 0.07, Luck = 2, Cooldown = 0.5,
		Color = Color3.fromRGB(255, 60, 200), Material = "Neon",
		Description = "The RGB lights add +200% digging power. Science."},
}

function GameConfig.GetShovel(shovelId)
	for _, shovel in ipairs(GameConfig.Shovels) do
		if shovel.Id == shovelId then
			return shovel
		end
	end
	return nil
end

-- Fills the dig site with terrain: stone ground around, dirt layers in the pit, bedrock below.
-- Used by the build script and every pit reset.
function GameConfig.FillDigTerrain(terrain)
	local PIT_RADIUS = 43
	local top = GameConfig.Layers[1].Top
	local depth = top - GameConfig.BedrockBottom
	-- clear anything above ground level (terrain works in 4-stud blocks)
	terrain:FillBlock(CFrame.new(0, top + 8, 0), Vector3.new(200, 16, 200), Enum.Material.Air)
	-- stone ground around the pit (and under it)
	terrain:FillBlock(CFrame.new(0, top - depth / 2, 0), Vector3.new(200, depth, 200), Enum.Material.Slate)
	-- keep the walkways clear (otherwise the stone pokes through them)
	for k = 0, 5 do
		local a = math.rad(k * 60)
		local dir = Vector3.new(math.cos(a), 0, math.sin(a))
		local mid = dir * 88
		terrain:FillBlock(CFrame.lookAt(mid, mid + dir) * CFrame.new(0, 4, 0), Vector3.new(14, 16, 84), Enum.Material.Air)
	end
	-- the dig layers
	for _, layer in ipairs(GameConfig.Layers) do
		local height = layer.Top - layer.Bottom
		terrain:FillCylinder(CFrame.new(0, layer.Bottom + height / 2, 0), height, PIT_RADIUS, Enum.Material[layer.Material])
	end
	-- bedrock
	local bedHeight = GameConfig.BedrockTop - GameConfig.BedrockBottom
	terrain:FillCylinder(CFrame.new(0, GameConfig.BedrockBottom + bedHeight / 2, 0), bedHeight, PIT_RADIUS, Enum.Material.Basalt)
end

return GameConfig
