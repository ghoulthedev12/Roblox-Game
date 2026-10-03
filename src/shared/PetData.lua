-- PetData (ModuleScript in ReplicatedStorage)
-- The pets: every world has an egg stand (PetManager builds them) with one egg, and every egg
-- holds five pets, one of each rarity. Hatching costs cash; the pet you get is rolled by
-- rarity chance. Equipped pets follow you around and boost you:
--   Money      +% income from the memes in your museum
--   Luck       "dig boost": you find memes more often, and rarer ones
--   Speed      you swing your pickaxe faster
-- Rarer pets and pets from later worlds give bigger boosts. The meshes are made in Blender
-- (tools/blender/pets.py, ReplicatedStorage > PetModels); PetVisuals shows them.
-- One more egg is bought with Robux instead of cash: the Relic Egg (PetData.RelicEgg, sold by
-- StoreManager), with five exclusive pets that are only Rare or better and boost everything.

local GameConfig = require(script.Parent:WaitForChild("GameConfig"))

local rgb = Color3.fromRGB

local PetData = {}

PetData.MaxEquipped = 3  -- pets following you (and boosting you) at once
PetData.MaxOwned = 50    -- pets you can keep; delete some to hatch more
PetData.SpeedCap = 1.5   -- all your pets together make you swing at most 150% faster
PetData.FindCap = 2      -- ...and find memes at most 200% more often (luck itself has no cap)

-- Chance is out of 100. Power = the boost a pet of this rarity gives in World 1 (0.05 = +5%);
-- Height = how tall the pet is, in studs.
PetData.Rarities = {
	{Name = "Common", Chance = 60, Color = rgb(196, 202, 214), Power = 0.05, Height = 2.3},
	{Name = "Uncommon", Chance = 25, Color = rgb(90, 220, 110), Power = 0.10, Height = 2.5},
	{Name = "Rare", Chance = 10, Color = rgb(70, 160, 255), Power = 0.20, Height = 2.7},
	{Name = "Epic", Chance = 4, Color = rgb(185, 95, 255), Power = 0.40, Height = 3.0},
	{Name = "Legendary", Chance = 1, Color = rgb(255, 190, 40), Power = 0.80, Height = 3.4},
}

-- pets from later worlds are stronger: World 9's are 5.8x World 1's
function PetData.WorldFactor(worldId)
	return 1 + 0.6 * (worldId - 1)
end

PetData.Stats = {
	Money = {Name = "Money", Icon = "Cash", Color = rgb(110, 230, 90), Text = "income"},
	Luck = {Name = "Dig Luck", Icon = "Luck", Color = rgb(255, 205, 60), Text = "dig luck"},
	Speed = {Name = "Dig Speed", Icon = "Pickaxe", Color = rgb(90, 200, 255), Text = "dig speed"},
}

-- {egg id, egg name, the five pets from Common to Legendary: {id, name, description}}
local EGGS = {
	{"ByteEgg", "Byte Egg", {
		{"PixelPup", "Pixel Pup", "A good boy rendered in 8 bits."},
		{"BufferSnail", "Buffer Snail", "Its shell never stops loading."},
		{"FloppyFrog", "Floppy Frog", "Carries 1.44 MB on its back."},
		{"WifiOwl", "Wi-Fi Owl", "Full bars, wherever it flies."},
		{"ServerDragon", "Server Dragon", "Guards the old internet's last server."},
	}},
	{"BlossomEgg", "Blossom Egg", {
		{"PetalBunny", "Petal Bunny", "Hops around with a blossom on its head."},
		{"LanternMoth", "Lantern Moth", "Its wings are paper lanterns."},
		{"KoiBot", "Koi Bot", "A robot koi that swims through the air."},
		{"BambooPanda", "Bamboo Panda", "Never lets go of its bamboo."},
		{"BlossomKitsune", "Blossom Kitsune", "Three tails, each tipped in blossom."},
	}},
	{"CosmicEgg", "Cosmic Egg", {
		{"StarBlob", "Star Blob", "A little star that fell off the sky."},
		{"CometPup", "Comet Pup", "Leaves a trail of stardust."},
		{"PlanetTurtle", "Planet Turtle", "Carries a whole planet on its back."},
		{"AstroAxolotl", "Astro Axolotl", "Always ready for a spacewalk."},
		{"NebulaWhale", "Nebula Whale", "Swims between galaxies."},
	}},
	{"FrostEgg", "Frost Egg", {
		{"SnowSeal", "Snow Seal", "Soft, round and a little cold."},
		{"PenguinBot", "Penguin Bot", "Waddles at 60 frames per second."},
		{"IceFox", "Ice Fox", "Its tail is made of ice crystals."},
		{"YetiCub", "Yeti Cub", "Fluffy. Very fluffy."},
		{"CrystalMammoth", "Crystal Mammoth", "Crystals grow from its back."},
	}},
	{"ChromeEgg", "Chrome Egg", {
		{"SandBeetle", "Sand Beetle", "Polished to a mirror shine."},
		{"CactusCat", "Cactus Cat", "Please don't pet it."},
		{"DroneCamel", "Drone Camel", "Its humps have propellers."},
		{"ChromeScorpion", "Chrome Scorpion", "Golden claws, chrome tail."},
		{"SunSphinx", "Sun Sphinx", "Asks riddles. Knows every answer."},
	}},
	{"CoralEgg", "Coral Egg", {
		{"BubbleFish", "Bubble Fish", "Puffs up when it's happy."},
		{"CrabBot", "Crab Bot", "Upgraded its claws."},
		{"JellyLamp", "Jelly Lamp", "Glows softly in the deep."},
		{"OctoHacker", "Octo Hacker", "Types with eight arms at once."},
		{"TideSeahorse", "Tide Seahorse", "Wears a crown of golden fins."},
	}},
	{"CandyEgg", "Candy Egg", {
		{"GummyCub", "Gummy Cub", "Squishy, sweet and a bit sticky."},
		{"DonutPup", "Donut Pup", "Never goes swimming without its donut."},
		{"LollipopSheep", "Lollipop Sheep", "Its wool is cotton candy."},
		{"CupcakeCat", "Cupcake Cat", "Lives in a cupcake. Wears the frosting."},
		{"SugarDragon", "Sugar Dragon", "Candy-cane horns, sprinkles everywhere."},
	}},
	{"MagmaEgg", "Magma Egg", {
		{"EmberSlime", "Ember Slime", "Warm to the touch. Very warm."},
		{"MagmaGecko", "Magma Gecko", "Lava runs down its back."},
		{"AnvilTurtle", "Anvil Turtle", "Its shell is an anvil."},
		{"LavaGolem", "Lava Golem", "A heart of molten rock."},
		{"Phoenix", "Phoenix", "Born again from every flame."},
	}},
	{"GlitchEgg", "Glitch Egg", {
		{"ErrorCube", "Error Cube", "Something went wrong. It's fine."},
		{"PixelGhost", "Pixel Ghost", "Haunts old video games."},
		{"GlitchCat", "Glitch Cat", "Partly loaded. Mostly cat."},
		{"CodeBug", "Code Bug", "The bug that every coder fears."},
		{"NullUnicorn", "Null Unicorn", "A unicorn from outside the code."},
	}},
}

-- which boosts each rarity gives; the stats take turns from world to world
local STAT_ORDER = {"Money", "Luck", "Speed"}
local function boostsFor(worldId, rarity)
	local function stat(k) return STAT_ORDER[(worldId + k - 2) % 3 + 1] end
	if rarity <= 3 then return {stat(rarity)} end
	if rarity == 4 then return {stat(1), stat(2)} end
	return {"Money", "Luck", "Speed"}
end

local EGG_PRICE_WORLD_1 = 5000
local EGG_PRICE_SHARE = 0.004 -- later worlds: an egg costs 0.4% of the world's price

PetData.Eggs = {}  -- [worldId] = egg
PetData.EggsById = {}
PetData.Pets = {}  -- [petId] = pet
PetData.Order = {} -- every pet id, by world then rarity
for worldId, entry in ipairs(EGGS) do
	local world = GameConfig.GetWorld(worldId)
	local price = worldId == 1 and EGG_PRICE_WORLD_1 or math.floor((world and world.Price or 1e6) * EGG_PRICE_SHARE)
	local egg = {Id = entry[1], Name = entry[2], World = worldId, Price = price, Pets = {}}
	for rarity, info in ipairs(entry[3]) do
		local pet = {Id = info[1], Name = info[2], Description = info[3], World = worldId, Egg = egg.Id, Rarity = rarity,
			Boosts = {}}
		local power = PetData.Rarities[rarity].Power * PetData.WorldFactor(worldId)
		for _, statName in ipairs(boostsFor(worldId, rarity)) do
			-- speed is worth more per percent, so it gets half
			pet.Boosts[statName] = statName == "Speed" and power * 0.5 or power
		end
		PetData.Pets[pet.Id] = pet
		table.insert(egg.Pets, pet.Id)
		table.insert(PetData.Order, pet.Id)
	end
	PetData.Eggs[worldId] = egg
	PetData.EggsById[egg.Id] = egg
end

-- THE RELIC EGG (Robux): not in any world (World = 0) and no cash price. Its five pets have
-- their own rarities and chances, and boost all three stats, at World 9 strength and a bit more.
local RELIC_PETS = {
	-- {id, name, description, rarity, chance out of 100}
	{"FossilRex", "Fossil Rex", "Dug up from the oldest server rack.", 3, 42},
	{"MummyCat", "Mummy Cat", "Wrapped in ancient ethernet cable.", 3, 30},
	{"TotemOwl", "Totem Owl", "Carved by the first archaeologists.", 4, 16},
	{"IdolMonkey", "Idol Monkey", "A solid gold idol. Do not swap it for sand.", 4, 9},
	{"RelicDragon", "Relic Dragon", "Guardian of the buried internet.", 5, 3},
}
local RELIC_STRENGTH = PetData.WorldFactor(9) * 1.25
local relicEgg = {Id = "RelicEgg", Name = "Relic Egg", World = 0, Price = 0, Robux = true, Pets = {}, Chances = {}}
for _, info in ipairs(RELIC_PETS) do
	local power = PetData.Rarities[info[4]].Power * RELIC_STRENGTH
	local pet = {Id = info[1], Name = info[2], Description = info[3], World = 0, Egg = relicEgg.Id, Rarity = info[4], Exclusive = true,
		Boosts = {Money = power, Luck = power, Speed = power * 0.5}}
	PetData.Pets[pet.Id] = pet
	table.insert(relicEgg.Pets, pet.Id)
	table.insert(relicEgg.Chances, info[5])
	table.insert(PetData.Order, pet.Id)
end
PetData.RelicEgg = relicEgg
PetData.EggsById[relicEgg.Id] = relicEgg

-- the chance (out of 100) of each pet in an egg, in egg.Pets order
function PetData.Chances(egg)
	if egg.Chances then return egg.Chances end
	local list = {}
	for i in ipairs(egg.Pets) do list[i] = PetData.Rarities[i].Chance end
	return list
end

-- pets that fly (they hover beside you instead of hopping along the ground)
for _, id in ipairs({"WifiOwl", "ServerDragon", "LanternMoth", "KoiBot", "StarBlob", "NebulaWhale", "BubbleFish", "JellyLamp",
	"SugarDragon", "Phoenix", "PixelGhost", "ErrorCube", "TotemOwl", "RelicDragon"}) do
	PetData.Pets[id].Fly = true
end

function PetData.GetPet(id)
	return PetData.Pets[id]
end

function PetData.Rarity(pet)
	return PetData.Rarities[pet.Rarity]
end

-- picks a pet from an egg (rng: a Random)
function PetData.Roll(egg, rng)
	local chances = PetData.Chances(egg)
	local roll = rng:NextNumber() * 100
	for i = #egg.Pets, 1, -1 do
		if roll < chances[i] then return egg.Pets[i] end
		roll -= chances[i]
	end
	return egg.Pets[1]
end

-- one number to compare pets by (for Equip Best and sorting): all its boosts added up
function PetData.Score(pet)
	local total = 0
	for statName, value in pairs(pet.Boosts) do
		total += statName == "Speed" and value * 2 or value
	end
	return total
end

-- The boosts from a list of pet ids: {Money = 0.25, Luck = 0.1, Speed = 0.05} (fractions)
function PetData.Total(petIds)
	local total = {Money = 0, Luck = 0, Speed = 0}
	for _, id in ipairs(petIds) do
		local pet = PetData.Pets[id]
		if pet then
			for statName, value in pairs(pet.Boosts) do
				total[statName] += value
			end
		end
	end
	total.Speed = math.min(total.Speed, PetData.SpeedCap)
	return total
end

-- The boosts of a save's equipped pets (data.Pets = {[uid] = petId}, data.EquippedPets = {[uid] = true})
function PetData.Bonuses(data)
	local ids = {}
	for uid in pairs(data.EquippedPets or {}) do
		local id = data.Pets and data.Pets[uid]
		if id then table.insert(ids, id) end
	end
	return PetData.Total(ids)
end

-- "+25%" for a fraction
function PetData.Percent(value)
	local p = value * 100
	if p >= 100 then return "+" .. math.floor(p + 0.5) .. "%" end
	return "+" .. (math.floor(p * 10 + 0.5) / 10) .. "%"
end

return PetData
