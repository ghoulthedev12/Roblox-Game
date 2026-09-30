-- ArtifactData (ModuleScript in ReplicatedStorage)
-- The ONE place the whole game reads memes and rarities from.
-- The memes themselves live in MemeList (9 worlds x 20 memes, each with its master-list rarity).
--
-- RARITIES: six regular ones (Basic -> Legendary) and then the named SECRET rarities
-- (Exotic, Godly, Eternal, ...), each one found only in its world's Abyss.

local MemeList = require(script.Parent:WaitForChild("MemeList"))

local ArtifactData = {}

---------------------------------------------------------------------
-- RARITIES (worst to best). Income = money per second in WORLD 1; later worlds multiply
-- it by WorldMultipliers (below). Chance = how often it's rolled, compared to the others
-- allowed in the same depth zone.
---------------------------------------------------------------------
ArtifactData.Rarities = {
	{Name = "Basic",     Code = "B", Income = 10,   Chance = 60,  Color = Color3.fromRGB(165, 165, 170)},
	{Name = "Common",    Code = "C", Income = 20,   Chance = 30,  Color = Color3.fromRGB(235, 235, 240)},
	{Name = "Uncommon",  Code = "U", Income = 45,   Chance = 14,  Color = Color3.fromRGB(85, 200, 85)},
	{Name = "Rare",      Code = "R", Income = 120,  Chance = 6,   Color = Color3.fromRGB(60, 140, 255)},
	{Name = "Epic",      Code = "E", Income = 450,  Chance = 2.5, Color = Color3.fromRGB(170, 80, 255)},
	{Name = "Legendary", Code = "L", Income = 1500, Chance = 0.8, Color = Color3.fromRGB(255, 170, 0)},
}
-- the secret rarities follow, in the order they first appear on the list
ArtifactData.SecretTiers = {}
for _, tier in ipairs(MemeList.SecretTiers) do
	table.insert(ArtifactData.Rarities, {Name = tier.Name, Code = "S", Income = tier.Income, Chance = tier.Chance, Color = tier.Color, Secret = true})
	table.insert(ArtifactData.SecretTiers, tier.Name)
end

-- Sell value = income per second x this number
ArtifactData.SellMultiplier = 100

---------------------------------------------------------------------
-- AREAS: one per world (area 1 = world 1 ... area 9 = world 9). Each world's memes are
-- worth WorldMultipliers[k] times more than world 1's.
---------------------------------------------------------------------
ArtifactData.WorldMultipliers = {3, 10, 25, 60, 150, 400, 1000, 2500} -- worlds 2..9
ArtifactData.Areas = {}
for k, world in ipairs(MemeList.Worlds) do
	table.insert(ArtifactData.Areas, {Name = world.Name, Index = k, Multiplier = k == 1 and 1 or ArtifactData.WorldMultipliers[k - 1]})
end

---------------------------------------------------------------------
-- BUILD THE ARTIFACT LIST (you don't need to edit anything below)
---------------------------------------------------------------------
local rng = Random.new()
local rarityByName, rarityIndexByName = {}, {}
for i, rarity in ipairs(ArtifactData.Rarities) do
	rarityByName[rarity.Name] = rarity
	rarityIndexByName[rarity.Name] = i
end

ArtifactData.Artifacts = {}
local artifactById = {}
local pools = {} -- [areaIndex][rarityName] = {artifacts}
for areaIndex, world in ipairs(MemeList.Worlds) do
	pools[areaIndex] = {}
	for _, entry in ipairs(world.Memes) do
		local rarity = rarityByName[entry[1]]
		if not rarity then
			warn("ArtifactData: unknown rarity " .. tostring(entry[1]) .. " for " .. tostring(entry[2]))
			rarity = ArtifactData.Rarities[1]
		end
		local artifact = {
			Id = entry[2], Name = entry[3], Form = entry[4], Description = entry[5],
			Rarity = rarity.Name, Area = areaIndex, World = areaIndex,
		}
		if artifactById[artifact.Id] then
			warn("ArtifactData: duplicate artifact id " .. artifact.Id)
		end
		artifactById[artifact.Id] = artifact
		table.insert(ArtifactData.Artifacts, artifact)
		pools[areaIndex][rarity.Name] = pools[areaIndex][rarity.Name] or {}
		table.insert(pools[areaIndex][rarity.Name], artifact)
	end
end

-- CORRUPTED MEMES: Glitch Nexus's data hacking minigame digs up glitched copies of that
-- world's memes. They're worth 2x on display and never come out of normal digging.
ArtifactData.CorruptedMultiplier = 2
do
	local glitchArea = #ArtifactData.Areas
	for _, base in ipairs(table.clone(ArtifactData.Artifacts)) do
		if base.Area == glitchArea then
			local corrupted = table.clone(base)
			corrupted.Id = "Corrupted" .. base.Id
			corrupted.Name = "Corrupted " .. base.Name
			corrupted.Description = "A glitched copy dug out of a Data Node. Earns 2x. " .. base.Description
			corrupted.BaseId = base.Id
			corrupted.Corrupted = true
			corrupted.IncomeMultiplier = ArtifactData.CorruptedMultiplier
			artifactById[corrupted.Id] = corrupted
			table.insert(ArtifactData.Artifacts, corrupted)
		end
	end
end

-- the corrupted copy of a meme (nil if it has none)
function ArtifactData.GetCorrupted(artifact)
	return artifact and artifactById["Corrupted" .. (artifact.BaseId or artifact.Id)]
end

-- which icon/picture an artifact uses (corrupted memes use the original's)
function ArtifactData.IconId(id)
	local artifact = artifactById[id]
	return artifact and artifact.BaseId or id
end

function ArtifactData.GetArtifact(id)
	return artifactById[id]
end

function ArtifactData.GetRarity(rarityName)
	return rarityByName[rarityName]
end

function ArtifactData.GetRarityIndex(rarityName)
	return rarityIndexByName[rarityName] or 1
end

-- true for the named secret rarities (Exotic, Godly, ...)
function ArtifactData.IsSecret(rarityName)
	local rarity = rarityByName[rarityName]
	return rarity ~= nil and rarity.Secret == true
end

function ArtifactData.GetArea(areaIndex)
	return ArtifactData.Areas[areaIndex]
end

-- Money per second this artifact makes on display
function ArtifactData.GetIncome(artifact)
	local rarity = rarityByName[artifact.Rarity]
	local area = ArtifactData.Areas[artifact.Area] or ArtifactData.Areas[1]
	return rarity.Income * area.Multiplier * (artifact.IncomeMultiplier or 1)
end

-- One-time money from selling it to the alien art dealer
function ArtifactData.GetSellValue(artifact)
	return ArtifactData.GetIncome(artifact) * ArtifactData.SellMultiplier
end

-- luck = 1 is normal. Higher luck makes everything above Common more likely.
local function rollRarityIndex(luck)
	luck = luck or 1
	local weights, total = {}, 0
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

-- Digs up a random artifact from an area (world number)
function ArtifactData.RollArtifact(areaIndex, luck)
	local pool = pools[areaIndex] or pools[1]
	local index = rollRarityIndex(luck)
	while index >= 1 do
		local list = pool[ArtifactData.Rarities[index].Name]
		if list and #list > 0 then
			return list[rng:NextInteger(1, #list)]
		end
		index -= 1
	end
	return nil
end

-- Digs up an artifact for a depth zone (see GameConfig.Worlds). ONLY the zone's rarities
-- can come out, from the zone's areas. Higher luck makes the rarer ones in the zone more likely.
function ArtifactData.RollForZone(zone, luck)
	luck = luck or 1
	-- which of the zone's rarities actually have artifacts in the zone's areas
	local options, total = {}, 0
	-- "Secret" in a zone's list means every secret rarity (each world only has its own)
	local names = {}
	for _, rarityName in ipairs(zone.Rarities) do
		if rarityName == "Secret" then
			for _, tier in ipairs(ArtifactData.SecretTiers) do table.insert(names, tier) end
		else
			table.insert(names, rarityName)
		end
	end
	for i, rarityName in ipairs(names) do
		local list = {}
		for _, areaIndex in ipairs(zone.Areas) do
			local pool = pools[areaIndex]
			for _, artifact in ipairs(pool and pool[rarityName] or {}) do
				table.insert(list, artifact)
			end
		end
		if #list > 0 then
			local rarity = rarityByName[rarityName]
			local weight = (i == 1) and rarity.Chance or rarity.Chance * luck
			table.insert(options, {Weight = weight, List = list})
			total += weight
		end
	end
	if #options == 0 then return nil end
	local roll = rng:NextNumber(0, total)
	local running = 0
	for _, option in ipairs(options) do
		running += option.Weight
		if roll <= running then
			return option.List[rng:NextInteger(1, #option.List)]
		end
	end
	local last = options[#options].List
	return last[rng:NextInteger(1, #last)]
end

-- Turns 1500000 into "$1.5M"
local suffixes = {"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"}
function ArtifactData.FormatMoney(amount)
	local negative = amount < 0
	amount = math.abs(amount)
	local i = 1
	while amount >= 1000 and i < #suffixes do
		amount = amount / 1000
		i += 1
	end
	local text
	if i == 1 then
		text = "$" .. math.floor(amount)
	else
		text = string.format("$%.1f%s", amount, suffixes[i])
		text = text:gsub("%.0(%a+)$", "%1")
	end
	return (negative and "-" or "") .. text
end

return ArtifactData
