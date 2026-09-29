-- ArtifactData (ModuleScript)
-- Put this in ReplicatedStorage and name it exactly: ArtifactData
-- This is the ONE list the whole game reads from.
-- To add a new artifact later: copy one line in the Artifacts list and change it.

local ArtifactData = {}

---------------------------------------------------------------------
-- RARITIES (order matters: worst to best)
-- Income = money per second in the starter era
-- Chance = percent chance to dig it up (all chances add up to 100)
---------------------------------------------------------------------
ArtifactData.Rarities = {
	{Name = "Common",       Income = 10,        Chance = 50,    Color = Color3.fromRGB(190, 190, 190)},
	{Name = "Uncommon",     Income = 100,       Chance = 28,    Color = Color3.fromRGB(85, 200, 85)},
	{Name = "Rare",         Income = 1000,      Chance = 13,    Color = Color3.fromRGB(60, 140, 255)},
	{Name = "Epic",         Income = 10000,     Chance = 6,     Color = Color3.fromRGB(170, 80, 255)},
	{Name = "Legendary",    Income = 100000,    Chance = 2,     Color = Color3.fromRGB(255, 170, 0)},
	{Name = "Mythic",       Income = 500000,    Chance = 0.7,   Color = Color3.fromRGB(255, 60, 90)},
	{Name = "Divine",       Income = 2500000,   Chance = 0.2,   Color = Color3.fromRGB(255, 240, 150)},
	{Name = "Celestial",    Income = 10000000,  Chance = 0.08,  Color = Color3.fromRGB(120, 255, 255)},
	{Name = "Transcendent", Income = 50000000,  Chance = 0.02,  Color = Color3.fromRGB(255, 255, 255)},
}

-- Sell value = income per second x this number
ArtifactData.SellMultiplier = 100

---------------------------------------------------------------------
-- ERAS (deeper = older = more valuable)
---------------------------------------------------------------------
ArtifactData.Eras = {
	Brainrot    = {DisplayName = "The Brainrot Epoch",  Years = "2016-2024", Multiplier = 1,  Order = 1},
	GoldenAge   = {DisplayName = "The Golden Age",      Years = "2005-2015", Multiplier = 3,  Order = 2},
	Paleolithic = {DisplayName = "The Paleolithic Web", Years = "1990-2004", Multiplier = 10, Order = 3},
}

---------------------------------------------------------------------
-- ARTIFACTS (add as many as you want, one per line)
---------------------------------------------------------------------
ArtifactData.Artifacts = {
	-- The Brainrot Epoch
	{Id = "RustedFidgetSpinner", Name = "Rusted Fidget Spinner", Era = "Brainrot", Rarity = "Common",
		Description = "Early humans spun these to ward off homework. Scientists still don't know if it worked."},
	{Id = "CrackedDancePhone", Name = "Cracked Phone (Dance Tutorial)", Era = "Brainrot", Rarity = "Common",
		Description = "Still plays the same 15 seconds on loop. Believed to be a prayer ritual."},
	{Id = "HalfFullBottle", Name = "Half-Full Water Bottle", Era = "Brainrot", Rarity = "Uncommon",
		Description = "Tossing it so it landed upright granted the thrower temporary social status."},
	{Id = "DeepFriedChip", Name = "Deep-Fried Image Chip", Era = "Brainrot", Rarity = "Uncommon",
		Description = "A picture cooked at such extreme temperatures it became radioactive with jokes."},
	{Id = "SingingThrone", Name = "Singing Porcelain Throne", Era = "Brainrot", Rarity = "Rare",
		Description = "A ceremonial seat with a tiny singing head. Its meaning is lost to history."},
	{Id = "GoldenRingLight", Name = "Golden Ring Light", Era = "Brainrot", Rarity = "Epic",
		Description = "Worshipped by ancient content creators. Its glow made every face flawless."},
	{Id = "RizzScroll", Name = "Scroll of Infinite Rizz", Era = "Brainrot", Rarity = "Legendary",
		Description = "A sacred text so powerful that no alien has been able to translate it."},
	{Id = "ScrollingThumb", Name = "Fossilized Scrolling Thumb", Era = "Brainrot", Rarity = "Mythic",
		Description = "Worn smooth by millions of hours of scrolling. It never reached the bottom."},
	{Id = "MainCharacterCrown", Name = "Crown of the Main Character", Era = "Brainrot", Rarity = "Divine",
		Description = "Whoever wore it believed the whole world was their movie."},
	{Id = "AlgorithmEye", Name = "The Algorithm's Eye", Era = "Brainrot", Rarity = "Celestial",
		Description = "It watched everything humans did, then showed them more of it."},
	{Id = "FinalBrainrot", Name = "The Final Brainrot", Era = "Brainrot", Rarity = "Transcendent",
		Description = "Contains every meme ever made, all at once. Do not look at it directly."},

	-- The Golden Age
	{Id = "FlipPhone", Name = "Flip Phone (One Bar)", Era = "GoldenAge", Rarity = "Common",
		Description = "Humans waved these at the sky, begging the gods for signal."},
	{Id = "AngryDoodle", Name = "Crumpled Angry Face Doodle", Era = "GoldenAge", Rarity = "Common",
		Description = "Early humans drew their feelings in four panels instead of talking about them."},
	{Id = "DentedAirhorn", Name = "Dented Airhorn", Era = "GoldenAge", Rarity = "Uncommon",
		Description = "Sounded whenever anything impressive happened. Or anything at all."},
	{Id = "PixelSunglasses", Name = "Pixelated Sunglasses", Era = "GoldenAge", Rarity = "Uncommon",
		Description = "Lowered slowly onto the face to show total victory in an argument."},
	{Id = "CatCassette", Name = "Ancient Cat Video Cassette", Era = "GoldenAge", Rarity = "Rare",
		Description = "Humanity's most-watched content. Aliens still can't explain why."},
	{Id = "SacredPlank", Name = "The Sacred Plank", Era = "GoldenAge", Rarity = "Epic",
		Description = "Humans lay flat on strange objects and photographed it. This board saw it all."},
	{Id = "TrickshotHeadset", Name = "Golden Trickshot Headset", Era = "GoldenAge", Rarity = "Legendary",
		Description = "Worn by the legendary warriors who spun in circles before every shot."},

	-- The Paleolithic Web (coming later)
}

---------------------------------------------------------------------
-- HELPER FUNCTIONS (you don't need to edit anything below)
---------------------------------------------------------------------
local rng = Random.new()
local rarityByName = {}
local rarityIndexByName = {}
local artifactById = {}

for i, rarity in ipairs(ArtifactData.Rarities) do
	rarityByName[rarity.Name] = rarity
	rarityIndexByName[rarity.Name] = i
end
for _, artifact in ipairs(ArtifactData.Artifacts) do
	artifactById[artifact.Id] = artifact
end

function ArtifactData.GetArtifact(id)
	return artifactById[id]
end

function ArtifactData.GetRarity(rarityName)
	return rarityByName[rarityName]
end

-- Money per second this artifact makes on display
function ArtifactData.GetIncome(artifact)
	local rarity = rarityByName[artifact.Rarity]
	local era = ArtifactData.Eras[artifact.Era]
	return rarity.Income * era.Multiplier
end

-- One-time money from selling it to the alien art dealer
function ArtifactData.GetSellValue(artifact)
	return ArtifactData.GetIncome(artifact) * ArtifactData.SellMultiplier
end

-- Position of a rarity in the list (Common = 1, Transcendent = 9)
function ArtifactData.GetRarityIndex(rarityName)
	return rarityIndexByName[rarityName] or 1
end

-- Picks a random rarity using the chances above.
-- luck = 1 is normal. Higher luck makes everything above Common more likely.
local function rollRarityIndex(luck)
	luck = luck or 1
	local weights = {}
	local total = 0
	for i, rarity in ipairs(ArtifactData.Rarities) do
		local weight = (i == 1) and rarity.Chance or rarity.Chance * luck
		weights[i] = weight
		total += weight
	end
	local roll = rng:NextNumber(0, total)
	local running = 0
	for i, weight in ipairs(weights) do
		running += weight
		if roll <= running then
			return i
		end
	end
	return 1
end

-- Digs up a random artifact from an era.
-- If that era has no artifact of the rolled rarity yet, it drops to the next lower rarity.
function ArtifactData.RollArtifact(eraName, luck)
	local index = rollRarityIndex(luck)
	while index >= 1 do
		local rarityName = ArtifactData.Rarities[index].Name
		local pool = {}
		for _, artifact in ipairs(ArtifactData.Artifacts) do
			if artifact.Era == eraName and artifact.Rarity == rarityName then
				table.insert(pool, artifact)
			end
		end
		if #pool > 0 then
			return pool[rng:NextInteger(1, #pool)]
		end
		index -= 1
	end
	return nil -- this era has no artifacts at all yet
end

-- Turns 1500000 into "$1.5M"
local suffixes = {"", "K", "M", "B", "T", "Qa", "Qi"}
function ArtifactData.FormatMoney(amount)
	local i = 1
	while math.abs(amount) >= 1000 and i < #suffixes do
		amount = amount / 1000
		i += 1
	end
	if i == 1 then
		return "$" .. math.floor(amount)
	end
	local text = string.format("$%.1f%s", amount, suffixes[i])
	text = text:gsub("%.0(%a+)$", "%1") -- "$2.0M" becomes "$2M"
	return text
end

return ArtifactData
