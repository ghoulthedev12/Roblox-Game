-- Meme Archaeologist installer: paste ALL of this into Studio's Command Bar
-- (View > Command Bar) and press Enter. Then save the place.
if game:GetService("RunService"):IsRunning() then error("STOP the game first (the red Stop button), then paste this again. Changes made during Play are lost when it stops.", 0) end
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local recording = ChangeHistoryService:TryBeginRecording("Install Meme Archaeologist scripts")
local count = 0
local function install(parent, name, className, source)
	local existing = parent:FindFirstChild(name)
	if existing and existing.ClassName ~= className then existing:Destroy() existing = nil end
	local s = existing or Instance.new(className)
	s.Name = name
	s.Source = source
	s.Parent = parent
	count += 1
end
pcall(function() game:GetService("Lighting").Technology = Enum.Technology.Future end)
pcall(function() workspace.FallenPartsDestroyHeight = -3000 end)
pcall(function() game:GetService("MaterialService").Use2022Materials = true end)
local function collectMeshes(folderName, ids, hint)
	local RS = game:GetService("ReplicatedStorage")
	local isMeme = {}
	for _, id in ipairs(ids) do isMeme[id] = true end
	local found, groups = {}, {}
	local function scan(container)
		for _, child in ipairs(container:GetChildren()) do
			if isMeme[child.Name] and (child:IsA("Model") or child:IsA("MeshPart")) then
				table.insert(found, child)
			elseif child:IsA("Model") or child:IsA("Folder") then
				local before = #found
				scan(child)
				if #found > before then table.insert(groups, child) end -- a group the import made
			end
		end
	end
	scan(workspace)
	-- also pick up copies that ended up somewhere else (dragged into ServerStorage, etc.)
	for _, place in ipairs({game:GetService("ServerStorage"), game:GetService("Lighting"), game:GetService("StarterPack")}) do
		scan(place)
	end
	-- an Import 3D done with ReplicatedStorage selected lands there, as a Model named after the
	-- .fbx (the same name as the folder), and older installs may have left extra folders with
	-- that name: keep the first real Folder and empty every other copy into it
	local folder
	for _, child in ipairs(RS:GetChildren()) do
		if child.Name == folderName and child:IsA("Folder") then folder = child break end
	end
	for _, child in ipairs(RS:GetChildren()) do
		if child ~= folder and (child.Name == folderName or child:GetAttribute("RBX_ReimportId")) then
			local before = #found
			scan(child)
			if #found > before or child.Name == folderName then table.insert(groups, child) end
		end
	end
	if #found > 0 then
		if not folder then
			folder = Instance.new("Folder")
			folder.Name = folderName
			folder.Parent = RS
		end
		local placed = {}
		for _, item in ipairs(found) do
			if placed[item.Name] then
				item:Destroy() -- a second copy from importing twice
			else
				placed[item.Name] = true
				local old = folder:FindFirstChild(item.Name)
				if old then old:Destroy() end -- the newest import replaces the older version
				for _, d in ipairs({item, table.unpack(item:GetDescendants())}) do
					if d:IsA("BasePart") then d.Anchored = true d.CanCollide = false end
				end
				item.Parent = folder
			end
		end
		for _, group in ipairs(groups) do
			if group.Parent and #group:GetChildren() == 0 then group:Destroy() end
		end
		local count = 0
		for _ in pairs(placed) do count += 1 end
		print("Moved " .. count .. " meshes into ReplicatedStorage > " .. folderName .. " (" .. #folder:GetChildren() .. " in total)")
		-- remember (saved with the place) that this place has them, to spot them going missing
		RS:SetAttribute(folderName .. "InstalledAt", os.date("%Y-%m-%d %H:%M"))
	elseif folder then
		print(folderName .. ": " .. #folder:GetChildren() .. " models in ReplicatedStorage, all good")
	else
		local when = RS:GetAttribute(folderName .. "InstalledAt")
		if when then
			warn(folderName .. " WENT MISSING: they were installed in THIS place on " .. when .. " but are gone now. Something undid it: "
				.. "Ctrl+Z after installing, closing without saving, or opening an older copy of the place. " .. hint)
		else
			warn(hint .. "  (This place has never had them installed. If you did it before, it was in a different copy of the place, or it wasn't saved.)")
		end
	end
end
collectMeshes("MemeMeshes", {"DaWaeEchidna", "SeaShantyMug", "AisleYodelSet", "ConvinceMeTable", "ShockedRodent", "IsThisABird", "ChonkyBunny", "SpicyLasagna", "SpikedShellCrown", "GrapeSurgery", "BadBoyHatchback", "TempleTap", "SteamedClams", "MegaSealTape", "PurpleTitanBuggy", "OrcaRebellionBoat", "NeverMissDartboard", "CrimeTownBoss", "BoneComedian", "SugarSneakJohnny", "FrostFlask", "BreathtakingCyberGuy", "EnslavedMoisture", "StonksHead", "AhShucks", "UncannyHedgehog", "SpaceInfant", "MeAndTheCrew", "CyberWedgeTruck", "YelledAtCat", "RaidAlien", "AngelWingDancer", "KombuchaDisgust", "DoubleTakeBlink", "TallPinkPiglet", "SpongeLeaving", "CappuccinoBallerina", "FrozenCoffinDance", "HundredMenGorilla", "GothDanceHands", "NatureHealingSwan", "OnceAgainLectern", "LockdownSourdough", "HeadBobCat", "PallbearerCoin", "TumbleJellyBean", "SwoleVsSmol", "PointingLaughChair", "PolkaSpinCow", "SusBean", "PartyCornerGuy", "BeepBopMicKid", "TradeOfferScroll", "BigMittensChair", "ThinkSonThink", "SneakerShark", "JawlineChad", "BingChillingCone", "SigmaGrindset", "EmotionalDamage", "YesNoLabDog", "AssistantSam", "LampOilMerchant", "MaulingTimeVampire", "GentlePillSquad", "WiseMysticalTree", "ItsCornCob", "UncannySuperDad", "GirlDinnerPlate", "PhonkEyebrowSpeaker", "RizzFaceMask", "ClangingPipe", "BetterCallPaul", "KingPrawnCrooner", "OhioFinalBoss", "OhYeahVillain", "LogBatGuy", "ShailushaiCat", "BirthdayShake", "WhistleEdit", "PeachesTurtleKing", "KindergartenMascot", "CursedCartoonTape", "AwkwardSmileGuy", "LaughCryCarSeat", "CanonEventWeb", "PinkbombFeature", "BoulderEyebrow", "PointingSuits", "MewingHush", "EnglishSpanishChair", "AHyuckDog", "NoScopeOlympian", "PommelHorseLegend", "BratGreenSlab", "PedroRaccoon", "CrocBomber", "ChillDude", "BabyHippo", "DubaiChocolate", "LowTaperFade", "ShushUpTablet", "BigGamerChair", "SixSevenHands", "TakeEggCushion", "IbizaBossDancer", "BoutiqueRock", "LittleFrenchFish", "VeryDemureTeacup", "JohnPorkPhone", "BeforeGTA6Hourglass", "StandingOnBusiness", "AuraBoatBow", "PaperclipHelper", "ZombieChickenRider", "JetTooHoliday", "PressureDiverHelmet", "AbyssalAngler", "GlitchWhale", "AtlantisJawlineChad", "SpookySkeleton", "PumpkinDancer", "GhostlySwampFrog", "BonkShiba", "SadViolinHamster", "ConfusedMathCat", "JellyTimeBanana", "RainbowPastryCat", "WowShiba", "ProblemGrinCoin", "MeLikeyTablet", "RageScreamTablet", "ForeverAlone", "BadLuckBryan", "FrowningCat", "PunchMonkey", "PhantomChonkyBunny", "CemeterySpecter", "UndeadSanic", "GraveyardOssuary", "CyberWowShiba", "GlitchSwampFrog", "QuantumShockedRodent", "VoidStonks", "MultiverseSpaceInfant", "BulletDodgeGuy", "NeonSusBean", "HoloJawlineChad", "CosmicShake", "SpacePolkaCow", "InterdimensionalChillDude", "CyberSingingThrone", "UniversalSanic", "ExponentialOgre", "MiraculousGnome", "ApexWowShiba", "GoldenSwampFrog", "ToorngEntity", "HighRollerBrainrot", "ImmeasupremeOverlord", "QuantumDatFrog", "SubatomicSwampFrog", "ParticleWowShiba", "AntimatterEchidna", "StringTheoryBunny", "WarpSpeedStonks", "ParallelJawlineChad", "RealityWarpedSponge", "TimeFoldPanels", "DarkMatterHippo", "RomanEmpireBust", "HypercubeChillDude", "ZeroPointThrone", "TesseractShake", "SingularityGrinCoin", "EventHorizonShiba", "NeverGonnaStair", "QuantumBrainrotGod", "MemeMatrix", "OriginalShiba"}, "No meme meshes yet: File > Import 3D > assets/models/MemeMeshes.fbx, then run this installer again")
collectMeshes("PortalModels", {"GatePortalFrame", "GatePortalGlow", "GateHorizon", "GateVortexA", "GateVortexB", "AlienPortalRim", "AlienPortalFunnel", "AlienPortalSwirl"}, "No portal meshes yet: File > Import 3D > assets/models/PortalMeshes.fbx, then run this installer again")
collectMeshes("UIIcons", {"Shop", "Bag", "Museum", "Rebirth", "World", "Settings", "Gem", "Cash", "Income", "SoundOn", "SoundOff", "Music", "Bell", "Lock", "Luck", "Pickaxe", "Star", "Sparkle", "Heart", "Pin", "Alien", "Fire", "Skull", "Disk", "Volcano", "Candy", "Ghost", "Bubble", "Ice", "Snowflake", "Coin", "Warning", "Boom", "Party", "Picture", "Hole", "Elevator", "Crown", "FaceHappy", "FaceLaugh", "FaceLove", "FaceWow", "FaceCool", "FaceMeh", "FaceSick"}, "No 3D UI icons yet: File > Import 3D > assets/models/UIIcons.fbx, then run this installer again")
do local old = game:GetService("ServerScriptService"):FindFirstChild("DataManager") if old then old:Destroy() print("Removed DataManager") end end
do local old = game:GetService("ServerScriptService"):FindFirstChild("ShovelModels") if old then old:Destroy() print("Removed ShovelModels") end end
do local old = game:GetService("ReplicatedStorage"):FindFirstChild("ShovelModels") if old then old:Destroy() print("Removed ShovelModels") end end
do local old = game:GetService("ServerScriptService"):FindFirstChild("MuseumStyle") if old then old:Destroy() print("Removed MuseumStyle") end end
do local old = game:GetService("ServerScriptService"):FindFirstChild("TutorialSign") if old then old:Destroy() print("Removed TutorialSign") end end
do local old = game:GetService("ReplicatedStorage"):FindFirstChild("ArtifactsWorlds") if old then old:Destroy() print("Removed ArtifactsWorlds") end end
do local old = game:GetService("ReplicatedStorage"):FindFirstChild("ArtifactIcons") if old then old:Destroy() print("Removed ArtifactIcons") end end
install(game:GetService("ReplicatedStorage"), "ArtifactData", "ModuleScript", [=[
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
]=])
install(game:GetService("ReplicatedStorage"), "ArtifactImages", "ModuleScript", [=[
-- ArtifactImages (ModuleScript in ReplicatedStorage)
-- The uploaded meme picture for each artifact. tools/upload_meme_images.py fills this in
-- automatically after uploading assets/meme_images/*.png to Roblox; any artifact without
-- a picture here shows its 3D figure instead (see ArtifactModels).
-- Format: ArtifactId = "rbxthumb://type=Asset&id=<decal id>&w=420&h=420",

return {
}
]=])
install(game:GetService("ReplicatedStorage"), "ArtifactModels", "ModuleScript", [=[
-- ArtifactModels (ModuleScript in ReplicatedStorage)
-- Turns a meme artifact into a real 3D museum object instead of a flat card. The famous
-- memes are real 3D sculptures of the meme itself (MemeFigures: the Chill Dude with his hands
-- in his pockets, the Shocked Yellow Rodent...). Everything else gets the form the asset
-- spec gives it in MemeList:
--   Painting  a wood / gold / ornate frame with the meme on the canvas and a name plate
--   Statue    a marble (or gold, for the rarest) figure on a plinth with the meme as its face
--   Coin      a big bronze / silver / gold coin with the meme stamped on both faces (a meme
--             with a figure is struck as a raised 3D relief of its silhouette)
--   Tablet    a carved stone tablet with the meme engraved into it (or carved in relief)
--   Relic     a painted medallion of the meme on a velvet cushion and a display stand
--   (Crystal, a glowing geode, is only used for memes with no form at all)
-- Used for finds lying in the crater (BuriedPainting) and for the displays in the museum
-- (MuseumClient puts them on the pedestals, under glass).
--
-- ArtifactModels.build(artifact) -> Model. The object stands upright, centered on the
-- origin, its front facing -Z. PrimaryPart "Core" is the center; attachments GripLeft (+X)
-- and GripRight (-X) are where hands hold it; attribute HalfHeight = half its height.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local ArtifactImages = require(ReplicatedStorage:WaitForChild("ArtifactImages"))
local MemeFigures = require(ReplicatedStorage:WaitForChild("MemeFigures"))

-- the sculpted Blender meshes (tools/blender) arrive as MeshParts in ReplicatedStorage >
-- MemeMeshes, each named after its artifact id. A meme with a mesh uses it everywhere: in
-- the pit, in the backpack, in your hand and on the museum pedestal.
-- If the imported meshes ever face the wrong way, turn them here.
local MESH_TURN = CFrame.Angles(0, 0, 0)

local ArtifactModels = {}
local rgb = Color3.fromRGB

local GOLD = rgb(214, 170, 76)
local SILVER = rgb(196, 202, 214)
local BRONZE = rgb(176, 112, 62)
local MARBLE = rgb(236, 234, 228)
local STONE = rgb(128, 118, 110)

local KEYWORDS = {
	{"Coin", {"coin", "token", "badge", "medal", "coupon", "pin", "ring", "cassette", "disc", "plaque", "button"}},
	{"Statue", {"statue", "idol", "mannequin", "bust", "throne", "trophy", "crown", "mask", "boss", "sigma", "thumb", "figure", "head", "king", "queen", "cat", "doge"}},
	{"Tablet", {"tablet", "stone", "fossil", "scroll", "codex", "rune", "relic", "sign", "plank", "keyboard", "meteor", "slab", "ruin"}},
	{"Crystal", {"crystal", "prism", "gem", "orb", "eye", "nebula", "aurora", "star", "moon", "constellation", "aura", "diamond", "core"}},
	{"Painting", {"portrait", "selfie", "painting", "poster", "panel", "comic", "photo", "picture", "image", "screen", "doodle", "banner", "card", "frame"}},
}
local FORMS_BY_SPEC = {Statue = "Statue", Painting = "Painting", Coin = "Coin", Tablet = "Tablet", Relic = "Relic"}
local FALLBACK = {"Painting", "Painting", "Painting", "Statue", "Statue", "Coin", "Tablet", "Tablet", "Crystal"}

-- which form an artifact takes (always the same for the same artifact)
-- the sculpted mesh for an artifact, or nil if it hasn't been made/imported yet
-- (Studio's Import 3D wraps each mesh in a Model named after it; the mesh is inside.)
function ArtifactModels.meshFor(artifact)
	local folder = ReplicatedStorage:FindFirstChild("MemeMeshes")
	local id = artifact and (artifact.BaseId or artifact.Id)
	local found = folder and id and (folder:FindFirstChild(id) or folder:FindFirstChild(id, true))
	if not found then return nil end
	if found:IsA("MeshPart") then return found end
	local best
	for _, d in ipairs(found:GetDescendants()) do
		if d:IsA("MeshPart") and (not best or d.Size.Magnitude > best.Size.Magnitude) then best = d end
	end
	return best
end

function ArtifactModels.formOf(artifact)
	if ArtifactModels.meshFor(artifact) then return "Figure" end
	local figure = MemeFigures.For(artifact)
	if figure then return figure.Form or "Figure" end
	-- the form the asset spec gave it (a Statue with no built figure yet is a marble statue)
	if artifact.Form and FORMS_BY_SPEC[artifact.Form] then return FORMS_BY_SPEC[artifact.Form] end
	local name = string.lower(artifact.Name or "")
	for _, entry in ipairs(KEYWORDS) do
		for _, word in ipairs(entry[2]) do
			if string.find(name, word, 1, true) then return entry[1] end
		end
	end
	local hash = 0
	for i = 1, #(artifact.Id or "") do
		hash = (hash * 31 + string.byte(artifact.Id, i)) % 100003
	end
	return FALLBACK[hash % #FALLBACK + 1]
end

---------------------------------------------------------------------
-- HELPERS
---------------------------------------------------------------------
local function part(model, name, size, cf, color, material, props)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(props or {}) do p[k] = v end
	p.Parent = model
	return p
end

local function cylinder(model, name, diameter, length, cf, color, material, props)
	local p = part(model, name, Vector3.new(length, diameter, diameter), cf, color, material, props)
	p.Shape = Enum.PartType.Cylinder
	return p
end

-- the meme (uploaded picture, or its emoji) put ONTO the surface of a part, in one of three styles:
--   Painted   on a canvas: soft varnish sheen and a dark inner edge where it meets the frame
--   Engraved  cut into stone: lit like the stone, see-through, with a carved shadow edge
--   Embossed  stamped into metal: tinted to the metal, with a raised highlight edge
-- opts: Style, Tint (the material's color), Background, Gradient, Round, EmojiSize, EmojiY
local function art(target, artifact, face, opts)
	opts = opts or {}
	local style = opts.Style or "Painted"
	local gui = Instance.new("SurfaceGui")
	gui.Face = face or Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 60
	-- engraved/embossed memes take the scene's light exactly like the material around them
	gui.LightInfluence = style == "Painted" and 0.8 or 1
	gui.Parent = target
	local holder = Instance.new("Frame")
	holder.Size = UDim2.fromScale(1, 1)
	holder.BorderSizePixel = 0
	holder.BackgroundColor3 = opts.Background or Color3.new(0, 0, 0)
	holder.BackgroundTransparency = opts.Background and 0 or 1
	holder.Parent = gui
	if opts.Round then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0.5, 0)
		corner.Parent = holder
		holder.ClipsDescendants = true
	end
	if opts.Gradient then
		local grad = Instance.new("UIGradient")
		grad.Color = ColorSequence.new(opts.Gradient:Lerp(Color3.new(1, 1, 1), 0.35), opts.Gradient:Lerp(Color3.new(0, 0, 0), 0.45))
		grad.Rotation = 60
		grad.Parent = holder
	end
	-- the carved / stamped border (an inset line just inside the edge)
	if style ~= "Painted" then
		local inset = Instance.new("Frame")
		inset.BackgroundTransparency = 1
		inset.Size = UDim2.fromScale(0.9, 0.9)
		inset.Position = UDim2.fromScale(0.5, 0.5)
		inset.AnchorPoint = Vector2.new(0.5, 0.5)
		inset.Parent = holder
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(opts.Round and 0.5 or 0.08, 0)
		corner.Parent = inset
		local line = Instance.new("UIStroke")
		line.Thickness = 3
		line.Color = (opts.Tint or rgb(120, 110, 100)):Lerp(Color3.new(0, 0, 0), style == "Engraved" and 0.55 or 0.35)
		line.Transparency = 0.2
		line.Parent = inset
	end

	local size, y = opts.EmojiSize or 0.7, opts.EmojiY or 0.5
	local iconId = ArtifactData.IconId(artifact.Id)
	local image = ArtifactImages[iconId]
	local function meme(offset, transparency, tint)
		local item
		if image then
			item = Instance.new("ImageLabel")
			item.Image = image
			item.ScaleType = Enum.ScaleType.Fit
			item.ImageTransparency = transparency
			if tint then item.ImageColor3 = tint end
		else
			-- no picture: the meme's own 3D figure (its Blender mesh or part-built figure) in a
			-- little viewport, tinted like the material; the faint shadow copies are skipped
			if transparency >= 0.7 then return nil end
			local ok, figure = pcall(ArtifactModels.sculpture, artifact)
			if ok and figure and figure:FindFirstChildWhichIsA("BasePart", true) then
				item = Instance.new("ViewportFrame")
				item.Ambient = rgb(190, 190, 200)
				item.LightColor = rgb(255, 250, 240)
				item.LightDirection = Vector3.new(0.4, -1, -0.7)
				item.ImageTransparency = transparency
				if tint then item.ImageColor3 = tint:Lerp(Color3.new(1, 1, 1), 0.45) end
				figure.Parent = item
				local lo, hi = MemeFigures.bounds(figure)
				local centre = (lo + hi) / 2
				local span = math.max(hi.X - lo.X, hi.Y - lo.Y)
				local camera = Instance.new("Camera")
				camera.FieldOfView = 20
				camera.CFrame = CFrame.lookAt(centre + Vector3.new(0, 0, -span * 0.6 / math.tan(math.rad(10))), centre)
				camera.Parent = item
				item.CurrentCamera = camera
			else
				item = Instance.new("TextLabel")
				item.Text = string.upper(artifact.Name)
				item.TextScaled = true
				item.Font = Enum.Font.GothamBlack
				item.TextColor3 = (tint or rgb(60, 50, 40)):Lerp(Color3.new(0, 0, 0), 0.5)
				item.TextTransparency = transparency
			end
		end
		item.BackgroundTransparency = 1
		item.Size = UDim2.fromScale(size, size)
		item.Position = UDim2.new(0.5, offset, y, offset)
		item.AnchorPoint = Vector2.new(0.5, 0.5)
		item.Parent = holder
		return item
	end
	if style == "Engraved" then
		-- a faint copy shifted down-right is the shadow inside the cut, the meme itself is
		-- worn and see-through so the stone shows through it
		meme(3, 0.82, opts.Tint and opts.Tint:Lerp(Color3.new(0, 0, 0), 0.6))
		meme(0, 0.38, opts.Tint)
	elseif style == "Embossed" then
		-- a faint copy shifted up-left is the light catching the raised edge
		meme(-2, 0.8, Color3.new(1, 1, 1))
		meme(0, 0.2, opts.Tint)
	else
		meme(0, 0)
		-- a thin varnish sheen across the canvas and a dark inner edge under the frame
		local sheen = Instance.new("Frame")
		sheen.Size = UDim2.fromScale(1, 1)
		sheen.BackgroundColor3 = Color3.new(1, 1, 1)
		sheen.BorderSizePixel = 0
		sheen.Parent = holder
		local fade = Instance.new("UIGradient")
		fade.Rotation = 35
		fade.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.82), NumberSequenceKeypoint.new(0.4, 1), NumberSequenceKeypoint.new(1, 1)})
		fade.Parent = sheen
		local edge = Instance.new("UIStroke")
		edge.Thickness = 5
		edge.Color = rgb(30, 20, 14)
		edge.Transparency = 0.35
		edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		edge.Parent = holder
	end
	return holder
end

local function plate(parent, artifact)
	local label = Instance.new("TextLabel")
	label.BackgroundColor3 = rgb(30, 26, 40)
	label.BackgroundTransparency = 0.25
	label.Size = UDim2.fromScale(0.86, 0.16)
	label.Position = UDim2.fromScale(0.5, 0.95)
	label.AnchorPoint = Vector2.new(0.5, 1)
	label.Text = string.upper(artifact.Name)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.TextColor3 = rgb(255, 232, 170)
	label.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.3, 0)
	corner.Parent = label
end

---------------------------------------------------------------------
-- THE FORMS (each returns its outer size)
---------------------------------------------------------------------
local FORMS = {}

function FORMS.Painting(model, artifact, color, rarityIndex)
	local W, H, BAR = 4.4, 3.4, 0.45
	-- plain wood for the common finds, gold for the rare ones, ornate gold for the best
	local frame, frameMaterial = GOLD, Enum.Material.Metal
	if rarityIndex <= 2 then frame, frameMaterial = rgb(120, 82, 52), Enum.Material.Wood end
	local canvas = part(model, "Canvas", Vector3.new(W - BAR * 2 + 0.1, H - BAR * 2 + 0.1, 0.12), CFrame.new(), rgb(40, 34, 30))
	plate(art(canvas, artifact, Enum.NormalId.Front, {Gradient = color, Background = color, EmojiY = 0.44, EmojiSize = 0.62}), artifact)
	part(model, "Backboard", Vector3.new(W - 0.3, H - 0.3, 0.14), CFrame.new(0, 0, 0.16), rgb(84, 58, 40), Enum.Material.Wood)
	for _, sy in ipairs({-1, 1}) do
		part(model, "Frame", Vector3.new(W, BAR, 0.5), CFrame.new(0, sy * (H - BAR) / 2, 0), frame, frameMaterial, {Reflectance = 0.05})
		part(model, "FrameLip", Vector3.new(W - BAR * 2, 0.1, 0.1), CFrame.new(0, sy * (H / 2 - BAR - 0.02), -0.2), color, Enum.Material.Neon)
	end
	for _, sx in ipairs({-1, 1}) do
		part(model, "Frame", Vector3.new(BAR, H - BAR * 2, 0.5), CFrame.new(sx * (W - BAR) / 2, 0, 0), frame, frameMaterial, {Reflectance = 0.05})
		part(model, "FrameLip", Vector3.new(0.1, H - BAR * 2, 0.1), CFrame.new(sx * (W / 2 - BAR - 0.02), 0, -0.2), color, Enum.Material.Neon)
		for _, sy in ipairs({-1, 1}) do
			part(model, "Corner", Vector3.one * 0.72, CFrame.new(sx * (W / 2 - BAR / 2), sy * (H / 2 - BAR / 2), -0.08), frame:Lerp(Color3.new(1, 1, 1), 0.15),
				frameMaterial, {Shape = Enum.PartType.Ball})
			if rarityIndex >= 6 then
				-- ornate: curled scrollwork on every corner
				part(model, "Scroll", Vector3.new(0.9, 0.22, 0.22), CFrame.new(sx * (W / 2 - 0.2), sy * (H / 2 + 0.05), -0.12) * CFrame.Angles(0, 0, sx * sy * math.rad(35)),
					GOLD:Lerp(Color3.new(1, 1, 1), 0.1), Enum.Material.Metal)
			end
		end
	end
	part(model, "Crest", Vector3.new(0.9, 0.7, 0.35), CFrame.new(0, H / 2 - 0.05, -0.12), color, Enum.Material.Neon)
	return Vector3.new(W, H, 0.6)
end

function FORMS.Statue(model, artifact, color, rarityIndex)
	local stone = rarityIndex >= 7 and GOLD or (rarityIndex >= 5 and SILVER or MARBLE)
	local material = rarityIndex >= 5 and Enum.Material.Metal or Enum.Material.Marble
	-- plinth, robed body, shoulders, arms, neck and a big block head with the meme as its face
	part(model, "Plinth", Vector3.new(2.8, 0.6, 2.2), CFrame.new(0, -2.2, 0), MARBLE:Lerp(STONE, 0.3), Enum.Material.Marble)
	part(model, "PlinthTrim", Vector3.new(2.9, 0.14, 2.3), CFrame.new(0, -1.86, 0), color, Enum.Material.Neon)
	part(model, "Robe", Vector3.new(1.9, 1.9, 1.2), CFrame.new(0, -0.95, 0), stone, material)
	part(model, "Chest", Vector3.new(1.7, 0.9, 1), CFrame.new(0, 0.45, 0), stone, material)
	for _, sx in ipairs({-1, 1}) do
		part(model, "Shoulder", Vector3.new(0.8, 0.8, 0.8), CFrame.new(sx * 1.05, 0.55, 0), stone, material, {Shape = Enum.PartType.Ball})
		part(model, "Arm", Vector3.new(0.5, 1.5, 0.55), CFrame.new(sx * 1.1, -0.35, -0.1) * CFrame.Angles(math.rad(-12), 0, sx * math.rad(-6)), stone, material)
	end
	part(model, "Sash", Vector3.new(0.35, 2.3, 1.25), CFrame.new(0.1, -0.2, 0) * CFrame.Angles(0, 0, math.rad(35)), color, Enum.Material.SmoothPlastic)
	part(model, "Neck", Vector3.new(0.6, 0.35, 0.6), CFrame.new(0, 1.05, 0), stone, material)
	local head = part(model, "Head", Vector3.new(1.5, 1.5, 1.4), CFrame.new(0, 1.9, 0), stone, material)
	art(head, artifact, Enum.NormalId.Front, {Style = material == Enum.Material.Marble and "Engraved" or "Embossed", Tint = stone, EmojiSize = 0.86})
	-- the meme is carved into the plinth too, like a museum inscription
	art(model:FindFirstChild("Plinth"), artifact, Enum.NormalId.Front, {Style = "Engraved", Tint = MARBLE:Lerp(STONE, 0.3), EmojiSize = 0.9})
	return Vector3.new(2.9, 5, 2.3)
end

-- a relic on a velvet cushion: a thick painted medallion of the meme standing on a
-- gold-trimmed display stand
function FORMS.Relic(model, artifact, color, rarityIndex)
	local stand = rarityIndex >= 6 and rgb(40, 38, 46) or rgb(92, 62, 42)
	part(model, "Stand", Vector3.new(2.8, 0.5, 2.0), CFrame.new(0, -1.95, 0), stand, rarityIndex >= 6 and Enum.Material.Marble or Enum.Material.Wood)
	part(model, "StandTrim", Vector3.new(2.88, 0.1, 2.08), CFrame.new(0, -1.68, 0), GOLD, Enum.Material.Metal)
	local cushion = part(model, "Cushion", Vector3.new(2.3, 0.5, 1.6), CFrame.new(0, -1.4, 0), color:Lerp(rgb(120, 20, 40), 0.6), Enum.Material.Fabric)
	local cmesh = Instance.new("SpecialMesh")
	cmesh.MeshType = Enum.MeshType.Sphere
	cmesh.Parent = cushion
	local D, T = 2.6, 0.5
	local face = CFrame.new(0, 0.2, 0) * CFrame.Angles(0, math.rad(90), 0)
	local disc = cylinder(model, "Medallion", D, T, face, rgb(250, 246, 236), Enum.Material.SmoothPlastic)
	cylinder(model, "MedallionRim", D + 0.22, T * 0.8, face, GOLD, Enum.Material.Metal, {Reflectance = 0.1})
	cylinder(model, "MedallionGlow", D + 0.4, T * 0.4, face, color, Enum.Material.Neon, {Transparency = 0.5})
	for _, normal in ipairs({Enum.NormalId.Right, Enum.NormalId.Left}) do
		art(disc, artifact, normal, {Round = true, Background = color:Lerp(Color3.new(1, 1, 1), 0.55), EmojiSize = 0.72})
	end
	return Vector3.new(2.9, 4.4, 2.1)
end

-- the meme as a 3D sculpture (its Blender mesh, else its part-built MemeFigure), standing
-- on y = 0 and facing -Z
local function sculpture(artifact)
	local template = ArtifactModels.meshFor(artifact)
	if template then
		local holder = Instance.new("Model")
		holder.Name = "MemeMesh"
		local mesh = template:Clone()
		mesh.Name = "Sculpture"
		for _, p in ipairs({mesh, table.unpack(mesh:GetDescendants())}) do
			if p:IsA("BasePart") then
				p.Anchored = true
				p.CanCollide = false
				p.CanQuery = false
				p.CanTouch = false
			end
		end
		mesh.CFrame = MESH_TURN
		mesh.Parent = holder
		local lo, hi = MemeFigures.bounds(holder)
		mesh.CFrame = mesh.CFrame + Vector3.new(-(lo.X + hi.X) / 2, -lo.Y, -(lo.Z + hi.Z) / 2)
		return holder
	end
	return MemeFigures.build(MemeFigures.For(artifact))
end
ArtifactModels.sculpture = sculpture

-- a real 3D sculpture of the meme on a marble plinth with a brass name plate
function FORMS.Figure(model, artifact, color, rarityIndex)
	local figure = sculpture(artifact)
	local W, H, BASE = 3, 3.9, 0.55
	MemeFigures.fit(figure, W - 0.2, H)
	local lo, hi = MemeFigures.bounds(figure)
	local height = hi.Y - lo.Y
	local total = height + BASE
	local bottom = -total / 2
	-- plinth: marble for most, gold-trimmed black stone for the best
	local plinthColor = rarityIndex >= 6 and rgb(40, 38, 46) or MARBLE:Lerp(STONE, 0.25)
	local plinth = part(model, "Plinth", Vector3.new(W, BASE, 2.2), CFrame.new(0, bottom + BASE / 2, 0), plinthColor, Enum.Material.Marble)
	part(model, "PlinthTrim", Vector3.new(W + 0.08, 0.1, 2.28), CFrame.new(0, bottom + BASE - 0.02, 0), rarityIndex >= 6 and GOLD or color,
		rarityIndex >= 6 and Enum.Material.Metal or Enum.Material.Neon)
	-- the name plate on the front
	local plateGui = Instance.new("SurfaceGui")
	plateGui.Face = Enum.NormalId.Front
	plateGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	plateGui.PixelsPerStud = 60
	plateGui.LightInfluence = 1
	plateGui.Parent = plinth
	local label = Instance.new("TextLabel")
	label.BackgroundColor3 = rgb(196, 160, 84)
	label.Size = UDim2.fromScale(0.9, 0.62)
	label.Position = UDim2.fromScale(0.5, 0.5)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Text = string.upper(artifact.Name)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.TextColor3 = rgb(60, 40, 20)
	label.Parent = plateGui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.2, 0)
	corner.Parent = label
	-- the sculpture stands on top
	local offset = Vector3.new(0, bottom + BASE - lo.Y, 0)
	for _, p in ipairs(figure:GetChildren()) do
		if p:IsA("BasePart") then
			p.CFrame = p.CFrame + offset
			p.Parent = model
		end
	end
	figure:Destroy()
	return Vector3.new(math.max(W, hi.X - lo.X), total, math.max(2.2, hi.Z - lo.Z))
end

function FORMS.Coin(model, artifact, color, rarityIndex)
	local metal = rarityIndex >= 5 and GOLD or (rarityIndex >= 3 and SILVER or BRONZE)
	if rarityIndex >= 8 then metal = color:Lerp(Color3.new(1, 1, 1), 0.4) end
	local D, T = 3.6, 0.45
	local face = CFrame.Angles(0, math.rad(90), 0) -- the cylinder's round faces point along Z
	local coin = cylinder(model, "Coin", D, T, face, metal, Enum.Material.Metal, {Reflectance = 0.15})
	cylinder(model, "CoinRim", D + 0.2, T * 0.7, face, metal:Lerp(Color3.new(0, 0, 0), 0.25), Enum.Material.Metal)
	cylinder(model, "CoinGlow", D - 0.5, T + 0.04, face, color, Enum.Material.Neon, {Transparency = 0.6})
	-- the meme struck into both faces: a raised 3D relief of its silhouette on the front when
	-- it has a figure, otherwise a stamped picture (Right = local +X of the cylinder = world -Z)
	local figure = MemeFigures.For(artifact)
	local relief = figure and MemeFigures.relief(figure, D * 0.62, D * 0.62, 0.16, metal, Enum.Material.Metal)
	if relief then
		for _, p in ipairs(relief:GetChildren()) do
			p.CFrame = p.CFrame + Vector3.new(0, 0, -T / 2 - 0.08)
			p.Parent = model
		end
		art(coin, artifact, Enum.NormalId.Left, {Style = "Embossed", Round = true, Tint = metal, EmojiSize = 0.62})
	else
		for _, normal in ipairs({Enum.NormalId.Right, Enum.NormalId.Left}) do
			art(coin, artifact, normal, {Style = "Embossed", Round = true, Tint = metal, EmojiSize = 0.62})
		end
	end
	-- a little cradle it stands in
	part(model, "Cradle", Vector3.new(2.2, 0.35, 1), CFrame.new(0, -D / 2 - 0.05, 0), rgb(70, 50, 36), Enum.Material.Wood)
	return Vector3.new(D + 0.2, D + 0.4, 1)
end

function FORMS.Tablet(model, artifact, color, rarityIndex)
	local W, H, T = 3.2, 3.6, 0.6
	local slab = part(model, "Slab", Vector3.new(W, H - W / 2, T), CFrame.new(0, -W / 4, 0), STONE, Enum.Material.Slate)
	-- rounded top
	cylinder(model, "SlabTop", W, T, CFrame.new(0, H / 2 - W / 2, 0) * CFrame.Angles(0, math.rad(90), 0), STONE, Enum.Material.Slate)
	-- a chipped corner and a couple of cracks
	part(model, "Chip", Vector3.new(0.9, 0.9, T + 0.1), CFrame.new(W / 2 - 0.1, -H / 2 + 0.3, 0) * CFrame.Angles(0, 0, math.rad(45)), STONE:Lerp(Color3.new(0, 0, 0), 0.2), Enum.Material.Slate)
	part(model, "Crack", Vector3.new(0.06, 1.2, 0.05), CFrame.new(-0.9, -0.6, -T / 2 - 0.01) * CFrame.Angles(0, 0, math.rad(20)), rgb(50, 44, 40))
	local figure = MemeFigures.For(artifact)
	local relief = figure and MemeFigures.relief(figure, W * 0.72, 2.4, 0.22, STONE:Lerp(Color3.new(1, 1, 1), 0.12), Enum.Material.Slate)
	if relief then
		-- carved in relief: the meme's silhouette stands out of the stone
		for _, p in ipairs(relief:GetChildren()) do
			p.CFrame = p.CFrame + Vector3.new(0, -0.25, -T / 2 - 0.11)
			p.Parent = model
		end
	else
		art(slab, artifact, Enum.NormalId.Front, {Style = "Engraved", Tint = STONE, EmojiSize = 0.8})
	end
	-- glowing runes carved around the edge for the rare ones
	local glow = rarityIndex >= 4 and color or rgb(90, 80, 72)
	if not relief then
		part(model, "RuneLine", Vector3.new(W - 0.5, 0.08, 0.05), CFrame.new(0, H / 2 - W / 2 + 0.2, -T / 2 - 0.01), glow, rarityIndex >= 4 and Enum.Material.Neon or Enum.Material.Slate)
	end
	part(model, "RuneLine", Vector3.new(W - 0.5, 0.08, 0.05), CFrame.new(0, -H / 2 + 0.3, -T / 2 - 0.01), glow, rarityIndex >= 4 and Enum.Material.Neon or Enum.Material.Slate)
	part(model, "Base", Vector3.new(W + 0.4, 0.3, 1.4), CFrame.new(0, -H / 2 - 0.05, 0), STONE:Lerp(Color3.new(0, 0, 0), 0.3), Enum.Material.Slate)
	return Vector3.new(W + 0.4, H + 0.3, 1.4)
end

function FORMS.Crystal(model, artifact, color)
	-- a rough rock with a cluster of glowing shards growing out of it
	local rock = part(model, "Rock", Vector3.new(3, 1.6, 2.2), CFrame.new(0, -1.3, 0), STONE, Enum.Material.Slate)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = rock
	local shards = {{0, 0.3, 0, 0.9, 2.8, 0}, {-0.8, -0.1, 0.2, 0.6, 1.8, 25}, {0.8, -0.2, -0.1, 0.65, 2, -22}, {0.3, -0.4, 0.6, 0.5, 1.3, -10}, {-0.4, -0.4, -0.6, 0.45, 1.2, 14}}
	for i, s in ipairs(shards) do
		local cf = CFrame.new(s[1], s[2], s[3]) * CFrame.Angles(math.rad(s[6] * 0.4), math.rad(45), math.rad(s[6]))
		part(model, "Shard", Vector3.new(s[4], s[5], s[4]), cf, color:Lerp(Color3.new(1, 1, 1), 0.25), Enum.Material.Glass, {Transparency = 0.25, Reflectance = 0.3})
		part(model, "ShardCore", Vector3.new(s[4] * 0.45, s[5] * 0.85, s[4] * 0.45), cf, color, Enum.Material.Neon)
		if i == 1 then
			local light = Instance.new("PointLight")
			light.Color = color
			light.Range = 8
			light.Brightness = 1
			light.Parent = model:FindFirstChild("ShardCore")
		end
	end
	-- the meme is carved in relief into a flat face cut into the rock's front
	local relief = part(model, "Relief", Vector3.new(1.6, 1.1, 0.3), CFrame.new(0, -1.25, -0.95) * CFrame.Angles(math.rad(-12), 0, 0), STONE:Lerp(Color3.new(1, 1, 1), 0.08), Enum.Material.Slate)
	art(relief, artifact, Enum.NormalId.Front, {Style = "Engraved", Tint = STONE, EmojiSize = 0.85})
	return Vector3.new(3, 4.4, 2.2)
end

-- the meme to hold in your hand or show in the backpack: just the sculpture, no plinth,
-- about `height` studs tall, centered on its PrimaryPart "Core". Memes with no sculpture
-- yet use their whole display object, shrunk to fit.
function ArtifactModels.buildHeld(artifact, height)
	height = height or 2.4
	if ArtifactModels.meshFor(artifact) or MemeFigures.For(artifact) then
		local model = sculpture(artifact)
		model.Name = "Held_" .. artifact.Id
		MemeFigures.fit(model, height, height)
		local lo, hi = MemeFigures.bounds(model)
		local center = (lo + hi) / 2
		for _, p in ipairs(model:GetDescendants()) do
			if p:IsA("BasePart") then p.CFrame = p.CFrame - center end
		end
		local rarity = ArtifactData.GetRarity(artifact.Rarity)
		local core = part(model, "Core", Vector3.one * 0.3, CFrame.new(), rarity and rarity.Color or rgb(200, 200, 200), Enum.Material.SmoothPlastic, {Transparency = 1})
		model.PrimaryPart = core
		model:SetAttribute("HalfHeight", (hi.Y - lo.Y) / 2)
		model:SetAttribute("Width", math.max(hi.X - lo.X, hi.Z - lo.Z))
		return model
	end
	local model = ArtifactModels.build(artifact)
	local scale = height / ((model:GetAttribute("HalfHeight") or 2) * 2)
	pcall(function() model:ScaleTo(scale) end)
	model:SetAttribute("HalfHeight", (model:GetAttribute("HalfHeight") or 2) * scale)
	return model
end

function ArtifactModels.build(artifact)
	local rarity = ArtifactData.GetRarity(artifact.Rarity)
	local color = rarity and rarity.Color or rgb(200, 200, 200)
	local rarityIndex = ArtifactData.GetRarityIndex(artifact.Rarity)
	local form = ArtifactModels.formOf(artifact)
	local model = Instance.new("Model")
	model.Name = "Artifact_" .. artifact.Id
	local size = FORMS[form](model, artifact, color, rarityIndex)

	local core = part(model, "Core", Vector3.one * 0.5, CFrame.new(), color, Enum.Material.SmoothPlastic, {Transparency = 1})
	model.PrimaryPart = core
	for name, x in pairs({GripLeft = size.X / 2, GripRight = -size.X / 2}) do
		local a = Instance.new("Attachment")
		a.Name = name
		a.Position = Vector3.new(x, -0.2, 0)
		a.Parent = core
	end
	model:SetAttribute("Form", form)
	model:SetAttribute("HalfHeight", size.Y / 2)
	model:SetAttribute("Width", math.max(size.X, size.Z))
	return model
end

return ArtifactModels
]=])
install(game:GetService("ReplicatedStorage"), "Audio", "ModuleScript", [=[
-- Audio (ModuleScript in ReplicatedStorage)
-- One place to play sound effects on a player's screen.
--   Audio.sfx("Dig")   plays a sound from GameConfig.Sounds, with:
--     * a pool per sound: at most MaxVoices copies ring at once (the rest are skipped), and
--       the same Sound objects are reused instead of making new ones every time
--     * a rate limit: the same sound can't play again within MinGap seconds (fast digging
--       plays at most ~4 dig sounds a second instead of stacking into noise)
--     * a small random pitch change (Jitter) so repeats sound organic
-- Every effect goes through the "SFX" SoundGroup and music through "Music", so the Settings
-- window (AudioClient) sets each one's volume or mutes it. The SFX group also has a gentle
-- treble cut (softer, less harsh) and a compressor (many sounds at once never get loud).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Audio = {}
local GameConfig -- loaded on first use (GameConfig loads AudioAssets, which is fine either way)

function Audio.group(name)
	local group = SoundService:FindFirstChild(name)
	if not group then
		group = Instance.new("SoundGroup")
		group.Name = name
		group.Parent = SoundService
		if name == "SFX" then
			local eq = Instance.new("EqualizerSoundEffect")
			eq.HighGain = -6 -- take the edge off
			eq.MidGain = -1
			eq.LowGain = 0
			eq.Parent = group
			local comp = Instance.new("CompressorSoundEffect")
			comp.Threshold = -22
			comp.Ratio = 4
			comp.Attack = 0.005
			comp.Release = 0.2
			comp.Parent = group
		end
	end
	return group
end

local pools = {}     -- [name] = {Sound, ...}
local lastPlay = {}  -- [name] = os.clock() of the last play
local rng = Random.new()

local function pool(name, def)
	local list = pools[name]
	if not list then
		list = {}
		for i = 1, def.MaxVoices or 1 do
			local sound = Instance.new("Sound")
			sound.Name = "SFX_" .. name .. i
			sound.SoundId = def.Id
			sound.SoundGroup = Audio.group("SFX")
			sound.Parent = SoundService
			table.insert(list, sound)
		end
		pools[name] = list
	end
	return list
end

-- plays GameConfig.Sounds[name]; pitch multiplies the sound's own (jittered) pitch
function Audio.sfx(name, pitch)
	GameConfig = GameConfig or require(ReplicatedStorage:WaitForChild("GameConfig"))
	local def = GameConfig.Sounds[name]
	if not def or not def.Id or def.Id == "" then return end
	local now = os.clock()
	if now - (lastPlay[name] or 0) < (def.MinGap or 0.05) then return end -- rate limit
	local free
	for _, sound in ipairs(pool(name, def)) do
		if not sound.IsPlaying then
			free = sound
			break
		end
	end
	if not free then return end -- every voice is busy: skip rather than stack
	lastPlay[name] = now
	local jitter = def.Jitter or 0
	free.Volume = def.Mix or 1
	free.PlaybackSpeed = (1 + rng:NextNumber(-jitter, jitter)) * (pitch or 1)
	free.TimePosition = 0
	free:Play()
end

-- a one-off sound by id (kept for anything not in GameConfig.Sounds); quiet by default
function Audio.play(id, volume, pitch)
	if not id or id == "" then return end
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Volume = math.min(volume or 0.2, 1)
	sound.PlaybackSpeed = pitch or 1
	sound.SoundGroup = Audio.group("SFX")
	sound.Parent = SoundService
	sound:Play()
	sound.Ended:Once(function() sound:Destroy() end)
	task.delay(6, function() if sound.Parent then sound:Destroy() end end)
end

return Audio
]=])
install(game:GetService("ReplicatedStorage"), "AudioAssets", "ModuleScript", [=[
-- AudioAssets (ModuleScript in ReplicatedStorage)
-- Written by tools/upload_audio.py: the uploaded id of every music track and sound effect.
-- GameConfig uses these; anything missing falls back to Roblox's built-in sounds (or no music).

return {
	music_world1 = "rbxassetid://80197746970327",
	music_world2 = "rbxassetid://112679934026674",
	music_world3 = "rbxassetid://86289240772490",
	music_world4 = "rbxassetid://98614849338419",
	music_world5 = "rbxassetid://118830205961751",
	music_world6 = "rbxassetid://119152309171030",
	music_world7 = "rbxassetid://75718568089426",
	music_world8 = "rbxassetid://92880158996777",
	music_world9 = "rbxassetid://113214998458308",
	sfx_clang = "rbxassetid://104132338820883",
	sfx_click = "rbxassetid://117460472075659",
	sfx_combo = "rbxassetid://136170012642155",
	sfx_dig = "rbxassetid://107422803550775",
	sfx_find = "rbxassetid://118508985529257",
}
]=])
install(game:GetService("ReplicatedStorage"), "GameConfig", "ModuleScript", [=[
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
		-- a dirt work yard around the dig site, inside the plaza's mosaic ring
		terrain:FillCylinder(CFrame.new(origin + Vector3.new(0, -2, 0)), 4, world.WorkYard.Radius, Enum.Material[world.WorkYard.Material])
	end
	if world.HubPaths then
		-- keep the walkways clear (otherwise the stone pokes through them)
		for k = 0, 5 do
			local a = math.rad(k * 60)
			local dir = Vector3.new(math.cos(a), 0, math.sin(a))
			local mid = origin + dir * 88
			terrain:FillBlock(CFrame.lookAt(mid, mid + dir) * CFrame.new(0, 4, 0), Vector3.new(14, 16, 84), Enum.Material.Air)
		end
		-- the walkways sit 2.6 studs up: sloped banks of earth along both sides rise to meet
		-- them, so you can walk from the ground straight onto a walkway (no wall to jump)
		local bank = Enum.Material[world.WorkYard and world.WorkYard.Material or world.TopMaterial or "Grass"]
		for k = 0, 5 do
			local a = math.rad(k * 60)
			local dir = Vector3.new(math.cos(a), 0, math.sin(a))
			local side = Vector3.new(-dir.Z, 0, dir.X)
			for _, s in ipairs({-1, 1}) do
				local toWalk = -side * s -- the bank's high side faces the walkway
				local pos = origin + dir * 81 + side * s * (7 + 4.5) + Vector3.new(0, 1.35, 0)
				terrain:FillWedge(CFrame.fromMatrix(pos, Vector3.yAxis:Cross(toWalk), Vector3.yAxis), Vector3.new(66, 2.7, 9), bank)
			end
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
		GameConfig.FlattenGround(terrain, origin, math.max(200, world.WorkYard and world.WorkYard.Radius * 2 + 8 or 0))
	end
end

-- Terrain filled up to y = 0 shows its surface at y = 2 (a full top block rounds up), which
-- buries everything laid flat on the ground. Emptying the top 2 studs of that block (y -2 to
-- 0) leaves it half full, so the surface sits exactly at y = 0 and keeps its material.
function GameConfig.FlattenGround(terrain, center, size)
	terrain:FillBlock(CFrame.new(center + Vector3.new(0, -1, 0)), Vector3.new(size, 2, size), Enum.Material.Air)
end

return GameConfig
]=])
install(game:GetService("ReplicatedStorage"), "MemeFigures", "ModuleScript", [=[
-- MemeFigures (ModuleScript in ReplicatedStorage)
-- Real 3D sculptures of the famous memes, built from parts, so each one passes the
-- "1-second glance test": you look at it and instantly know which meme it is.
-- Every figure keeps the meme's iconic pose and silhouette (hands in pockets, the open
-- mouth, the head in the toilet, the two pointing suits...) but has a parody name and no
-- logos (see ArtifactData).
--
-- MemeFigures.For(artifact)  -> the figure spec for an artifact, or nil
-- MemeFigures.build(spec)    -> Model: the figure standing on y = 0, facing -Z (not scaled)
-- MemeFigures.fit(model, width, height) scales a model to fit and returns the scale
-- MemeFigures.relief(spec, width, height, depth, color, material) -> Model: the figure
--   pressed flat into a raised relief (for coins and stone carvings), centered on the
--   origin, its front facing -Z
--
-- Spec fields: Kind (which figure), Form ("Figure" default, or "Coin" / "Tablet" for a
-- relief), Colors (palette overrides), Tint + TintAmount, Material (a finish over the
-- whole figure; parts named "Detail", like eyes, keep their own look).

local MemeFigures = {}

local rgb = Color3.fromRGB
local V = Vector3.new
local P = CFrame.new
local function R(x, y, z)
	return CFrame.Angles(math.rad(x or 0), math.rad(y or 0), math.rad(z or 0))
end

local WHITE, BLACK = rgb(245, 245, 245), rgb(24, 22, 26)

---------------------------------------------------------------------
-- WHICH ARTIFACTS ARE FIGURES
---------------------------------------------------------------------
MemeFigures.ById = {
	-- World 1
	ShockedRodent = {Kind = "ShockedRodent"},
	ChonkyBunny = {Kind = "ChonkyBunny"},
	PurpleTitanBuggy = {Kind = "TitanBuggy"},
	-- World 2
	SpaceInfant = {Kind = "SpaceInfant"},
	SpongeLeaving = {Kind = "SpongeLeaving"},
	-- World 3
	SusBean = {Kind = "SusBean"},
	JawlineChad = {Kind = "JawlineChad"},
	-- World 4
	-- World 5
	PointingSuits = {Kind = "PointingSuits"},
	ChillDude = {Kind = "ChillDude"},
	-- World 6
	AtlantisJawlineChad = {Kind = "JawlineChad", Tint = rgb(90, 200, 190), TintAmount = 0.35, Material = Enum.Material.Marble},
	-- World 7
	RainbowPastryCat = {Kind = "RainbowPastryCat"},
	WowShiba = {Kind = "WowShiba"},
	FrowningCat = {Kind = "GrumpyCat"},
	PhantomChonkyBunny = {Kind = "ChonkyBunny", Tint = rgb(170, 255, 200), TintAmount = 0.6, Material = Enum.Material.Glass},
	-- World 8: remixes of the famous figures with a new finish
	CyberWowShiba = {Kind = "WowShiba", Tint = rgb(120, 220, 255), TintAmount = 0.35, Material = Enum.Material.Metal},
	QuantumShockedRodent = {Kind = "ShockedRodent", Tint = rgb(180, 240, 255), TintAmount = 0.3, Material = Enum.Material.Glass},
	MultiverseSpaceInfant = {Kind = "SpaceInfant", Colors = {Robe = rgb(90, 110, 220), Skin = rgb(120, 200, 230)}},
	NeonSusBean = {Kind = "SusBean", Colors = {Body = rgb(255, 60, 200)}, Material = Enum.Material.Neon},
	HoloJawlineChad = {Kind = "JawlineChad", Tint = rgb(90, 230, 255), TintAmount = 0.6, Material = Enum.Material.Glass},
	CosmicShake = {Kind = "PurpleShake", Colors = {Shake = rgb(70, 40, 160)}},
	InterdimensionalChillDude = {Kind = "ChillDude", Colors = {Sweater = rgb(130, 80, 220), Jeans = rgb(40, 40, 70)}},
	CyberSingingThrone = {Kind = "ToiletHead", Tint = rgb(200, 210, 225), TintAmount = 0.55, Material = Enum.Material.Metal},
	ApexWowShiba = {Kind = "WowShiba", Tint = rgb(240, 200, 80), TintAmount = 0.7, Material = Enum.Material.Metal},
	-- World 9: remixes with a physics twist
	ParticleWowShiba = {Kind = "WowShiba", Tint = rgb(255, 230, 150), TintAmount = 0.4, Material = Enum.Material.Neon},
	StringTheoryBunny = {Kind = "ChonkyBunny", Tint = rgb(255, 140, 220), TintAmount = 0.3, Material = Enum.Material.Neon},
	ParallelJawlineChad = {Kind = "JawlineChad", Tint = rgb(40, 40, 60), TintAmount = 0.5},
	RealityWarpedSponge = {Kind = "SpongeLeaving", Tint = rgb(150, 90, 255), TintAmount = 0.35},
	HypercubeChillDude = {Kind = "ChillDude", Tint = rgb(120, 230, 255), TintAmount = 0.4, Material = Enum.Material.Glass},
	ZeroPointThrone = {Kind = "ToiletHead", Tint = rgb(235, 245, 255), TintAmount = 0.6, Material = Enum.Material.Glass},
	TesseractShake = {Kind = "PurpleShake", Tint = rgb(200, 150, 255), TintAmount = 0.3, Material = Enum.Material.Glass},
	EventHorizonShiba = {Kind = "WowShiba", Tint = rgb(40, 30, 70), TintAmount = 0.55},
	OriginalShiba = {Kind = "WowShiba", Tint = rgb(240, 200, 80), TintAmount = 0.6, Material = Enum.Material.Metal},
}

function MemeFigures.For(artifact)
	if not artifact then return nil end
	return MemeFigures.ById[artifact.BaseId or artifact.Id]
end

---------------------------------------------------------------------
-- BUILDER
---------------------------------------------------------------------
local Builder = {}
Builder.__index = Builder

local function newPart(self, name, size, cf, color, material, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = typeof(cf) == "Vector3" and CFrame.new(cf) or cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if shape then p.Shape = shape end
	p.Parent = self.Model
	return p
end

function Builder:box(size, cf, color, material)
	return newPart(self, "Figure", size, cf, color, material)
end
-- an ellipsoid of any proportions
function Builder:egg(size, cf, color, material)
	local p = newPart(self, "Figure", size, cf, color, material)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = p
	return p
end
function Builder:ball(diameter, cf, color, material)
	return newPart(self, "Figure", Vector3.one * diameter, cf, color, material, Enum.PartType.Ball)
end
-- a round cylinder; its axis runs along the part's X
function Builder:cyl(diameter, length, cf, color, material)
	return newPart(self, "Figure", V(length, diameter, diameter), cf, color, material, Enum.PartType.Cylinder)
end
function Builder:wedge(size, cf, color, material)
	local p = Instance.new("WedgePart")
	p.Name = "Figure"
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Parent = self.Model
	return p
end
-- marks a part (eyes, noses...) so a world finish doesn't recolor it
local function detail(p)
	p.Name = "Detail"
	return p
end
-- a round eye: white, pupil, and a tiny shine
function Builder:eye(cf, size, pupilOffset)
	detail(self:egg(V(size, size * 1.1, size * 0.35), cf, WHITE))
	detail(self:egg(V(size * 0.5, size * 0.55, size * 0.2), cf * P((pupilOffset or 0) * size, 0, -size * 0.14), BLACK))
	detail(self:ball(size * 0.18, cf * P(-size * 0.1 + (pupilOffset or 0) * size, size * 0.14, -size * 0.2), WHITE))
end

---------------------------------------------------------------------
-- THE FIGURES (feet on y = 0, facing -Z, about 4-5 studs tall)
---------------------------------------------------------------------
local FIGURES = {}
local DEFAULTS = {}
-- side-on figures are turned a little so you see them three-quarters on
local YAW = {CrocBomber = -35, SneakerShark = -30, TitanBuggy = -25, RainbowPastryCat = -20}

-- Chill Dude in a Sweater: gray sweater, jeans, hands in pockets, smug relaxed face
DEFAULTS.ChillDude = {Fur = rgb(196, 150, 104), Muzzle = rgb(236, 214, 184), Sweater = rgb(150, 152, 158), Jeans = rgb(72, 104, 156)}
function FIGURES.ChillDude(b, c)
	local jeansDark = c.Jeans:Lerp(BLACK, 0.3)
	for _, s in ipairs({-1, 1}) do
		b:box(V(0.62, 0.34, 1.0), P(s * 0.36, 0.17, -0.12), WHITE)
		detail(b:box(V(0.64, 0.1, 1.02), P(s * 0.36, 0.05, -0.12), rgb(200, 50, 50)))
		b:box(V(0.56, 1.5, 0.6), P(s * 0.34, 1.08, 0), c.Jeans)
		b:box(V(0.6, 0.18, 0.64), P(s * 0.34, 0.42, 0), c.Jeans:Lerp(WHITE, 0.25))
		b:box(V(0.3, 0.36, 0.06), P(s * 0.46, 1.95, -0.37), jeansDark) -- the pocket the hand is in
	end
	b:box(V(1.36, 0.5, 0.72), P(0, 1.95, 0), c.Jeans)
	b:box(V(1.5, 1.3, 0.86), P(0, 2.78, 0), c.Sweater)
	b:box(V(1.56, 0.2, 0.9), P(0, 2.16, 0), c.Sweater:Lerp(BLACK, 0.15))
	b:egg(V(1.8, 0.62, 0.9), P(0, 3.38, 0), c.Sweater)
	-- arms hang straight down, hands tucked into the pockets
	for _, s in ipairs({-1, 1}) do
		b:box(V(0.42, 1.4, 0.5), P(s * 0.7, 2.62, -0.1) * R(0, 0, -s * 10), c.Sweater)
		b:box(V(0.44, 0.2, 0.52), P(s * 0.6, 1.98, -0.16) * R(0, 0, -s * 10), c.Sweater:Lerp(BLACK, 0.15))
	end
	b:egg(V(0.72, 0.26, 0.62), P(0, 3.66, 0), c.Sweater:Lerp(BLACK, 0.15))
	-- head: long snout, droopy ears, half-closed eyes and a little smirk
	b:egg(V(1.15, 1.1, 1.05), P(0, 4.2, 0), c.Fur)
	b:egg(V(0.62, 0.5, 0.78), P(0, 4.02, -0.5), c.Muzzle)
	detail(b:egg(V(0.28, 0.18, 0.18), P(0, 4.16, -0.88), BLACK))
	detail(b:box(V(0.32, 0.05, 0.05), P(0.06, 3.86, -0.86) * R(0, 0, 12), rgb(90, 60, 40)))
	for _, s in ipairs({-1, 1}) do
		detail(b:egg(V(0.24, 0.12, 0.08), P(s * 0.25, 4.36, -0.47), BLACK))
		b:box(V(0.3, 0.07, 0.1), P(s * 0.25, 4.42, -0.48), c.Fur:Lerp(BLACK, 0.25))
		b:egg(V(0.3, 0.78, 0.2), P(s * 0.6, 4.1, 0.05) * R(0, 0, s * 15), c.Fur:Lerp(BLACK, 0.3))
	end
end

-- Mega Jawline Chad: black-and-white bust, head turned, the famous square jaw
DEFAULTS.JawlineChad = {Skin = rgb(178, 178, 178), Hair = rgb(46, 46, 46), Base = rgb(62, 62, 66)}
function FIGURES.JawlineChad(b, c)
	local shade = c.Skin:Lerp(BLACK, 0.3)
	b:box(V(2.3, 0.45, 1.3), P(0, 0.22, 0), c.Base)
	-- broad chest and huge shoulders
	b:box(V(2.1, 1.1, 1.0), P(0, 1.0, 0), c.Skin)
	for _, s in ipairs({-1, 1}) do
		b:ball(1.0, P(s * 1.05, 1.25, 0), c.Skin)
		b:egg(V(0.95, 0.62, 0.3), P(s * 0.46, 1.1, -0.45), c.Skin:Lerp(WHITE, 0.08))
		b:wedge(V(0.9, 0.55, 0.9), P(s * 0.6, 1.8, 0.05) * R(0, -s * 90, 0), c.Skin) -- trapezius
	end
	b:box(V(0.9, 0.95, 0.85), P(0, 1.95, 0.05), c.Skin)
	local H = P(0, 3.0, 0) * R(0, -30, 0)
	b:egg(V(1.05, 1.2, 1.2), H * P(0, 0.3, 0.1), c.Skin)
	b:box(V(0.96, 0.7, 0.3), H * P(0, 0.12, -0.45), c.Skin)
	b:box(V(1.14, 0.2, 0.92), H * P(0, 0.0, -0.08), c.Skin) -- cheekbones
	b:box(V(1.32, 0.56, 1.1), H * P(0, -0.36, 0), c.Skin) -- the jaw: wider than the skull
	b:box(V(0.82, 0.42, 0.42), H * P(0, -0.5, -0.5), c.Skin) -- the chin
	b:box(V(1.34, 0.26, 1.12), H * P(0, -0.52, 0), shade) -- stubble
	b:box(V(0.84, 0.26, 0.44), H * P(0, -0.6, -0.5), shade)
	b:egg(V(1.15, 0.62, 1.36), H * P(0, 0.78, 0.2), c.Hair)
	b:box(V(1.0, 0.16, 0.2), H * P(0, 0.3, -0.6), shade)
	b:wedge(V(0.24, 0.42, 0.26), H * P(0, 0.02, -0.72) * R(0, 0, 180), c.Skin)
	for _, s in ipairs({-1, 1}) do
		detail(b:egg(V(0.22, 0.1, 0.06), H * P(s * 0.25, 0.17, -0.61), rgb(30, 30, 30)))
		b:egg(V(0.15, 0.42, 0.3), H * P(s * 0.58, 0.12, 0.12), shade)
	end
end

-- The Singing Porcelain Throne: a head popping out of a toilet, mid-song
DEFAULTS.ToiletHead = {Porcelain = rgb(240, 242, 246), Skin = rgb(236, 196, 160), Hair = rgb(92, 62, 40)}
function FIGURES.ToiletHead(b, c)
	b:box(V(0.9, 0.7, 1.1), P(0, 0.35, 0.1), c.Porcelain)
	b:egg(V(1.7, 0.82, 2.0), P(0, 1.02, -0.1), c.Porcelain)
	b:egg(V(1.45, 0.12, 1.72), P(0, 1.4, -0.1), c.Porcelain:Lerp(BLACK, 0.12))
	b:box(V(1.6, 1.3, 0.55), P(0, 1.95, 0.95), c.Porcelain)
	b:box(V(1.7, 0.12, 0.66), P(0, 2.65, 0.95), c.Porcelain)
	b:box(V(1.5, 1.6, 0.1), P(0, 2.2, 0.62) * R(-8, 0, 0), c.Porcelain:Lerp(BLACK, 0.05))
	detail(b:box(V(0.3, 0.1, 0.14), P(-0.55, 2.4, 0.6), rgb(190, 190, 200)))
	b:egg(V(0.56, 0.4, 0.56), P(0, 1.42, -0.15), c.Skin)
	b:egg(V(0.95, 1.05, 0.95), P(0, 1.88, -0.15), c.Skin)
	b:egg(V(1.0, 0.5, 1.0), P(0, 2.28, -0.08), c.Hair)
	for _, s in ipairs({-1, 1}) do
		b:eye(P(s * 0.2, 1.98, -0.56), 0.26)
		detail(b:box(V(0.24, 0.05, 0.05), P(s * 0.2, 2.16, -0.58) * R(0, 0, -s * 18), c.Hair))
	end
	detail(b:egg(V(0.4, 0.3, 0.1), P(0, 1.66, -0.6), rgb(120, 30, 30)))
end

-- Shocked Yellow Rodent: round yellow body, tall black-tipped ears, red cheeks, mouth wide open
DEFAULTS.ShockedRodent = {Body = rgb(250, 214, 48), Cheek = rgb(230, 60, 50), Brown = rgb(140, 90, 40)}
function FIGURES.ShockedRodent(b, c)
	for _, s in ipairs({-1, 1}) do
		b:egg(V(0.45, 0.25, 0.6), P(s * 0.4, 0.12, -0.1), c.Body)
		b:egg(V(0.3, 0.55, 0.3), P(s * 0.72, 1.2, -0.25) * R(0, 0, s * 35), c.Body)
	end
	b:egg(V(1.5, 1.5, 1.3), P(0, 0.95, 0), c.Body)
	b:box(V(0.9, 0.14, 0.3), P(0, 1.45, 0.55), c.Brown)
	b:box(V(0.8, 0.14, 0.3), P(0, 1.15, 0.6), c.Brown)
	-- the lightning-bolt tail
	b:box(V(0.25, 0.7, 0.12), P(0.5, 1.3, 0.75) * R(0, 0, -40), c.Brown)
	b:box(V(0.35, 0.9, 0.12), P(0.85, 1.9, 0.8) * R(0, 0, 30), c.Body)
	b:box(V(0.5, 0.9, 0.12), P(1.1, 2.6, 0.85) * R(0, 0, -30), c.Body)
	b:egg(V(1.75, 1.5, 1.45), P(0, 2.35, 0), c.Body)
	for _, s in ipairs({-1, 1}) do
		local ear = P(s * 0.55, 3.0, 0.05) * R(0, 0, -s * 22)
		b:egg(V(0.38, 1.3, 0.28), ear * P(0, 0.55, 0), c.Body)
		detail(b:egg(V(0.34, 0.5, 0.29), ear * P(0, 1.02, 0), BLACK))
		detail(b:egg(V(0.42, 0.42, 0.15), P(s * 0.6, 2.15, -0.52), c.Cheek))
		detail(b:egg(V(0.3, 0.34, 0.12), P(s * 0.33, 2.5, -0.64), BLACK))
		detail(b:ball(0.1, P(s * 0.3, 2.56, -0.71), WHITE))
	end
	detail(b:egg(V(0.36, 0.44, 0.12), P(0, 2.1, -0.7), rgb(90, 20, 20)))
	detail(b:egg(V(0.22, 0.14, 0.08), P(0, 1.99, -0.74), rgb(240, 120, 130)))
end

-- Green Space Infant: huge sideways ears, big dark eyes, tan robe
DEFAULTS.SpaceInfant = {Skin = rgb(150, 190, 120), Robe = rgb(190, 160, 120), Inner = rgb(220, 160, 150)}
function FIGURES.SpaceInfant(b, c)
	b:egg(V(1.4, 2.0, 1.2), P(0, 1.0, 0), c.Robe)
	b:egg(V(1.35, 0.38, 1.12), P(0, 1.95, 0), c.Robe:Lerp(WHITE, 0.2))
	for _, s in ipairs({-1, 1}) do
		b:egg(V(0.42, 0.62, 0.42), P(s * 0.36, 1.55, -0.42) * R(40, 0, 0), c.Robe)
		b:egg(V(0.22, 0.28, 0.22), P(s * 0.25, 1.52, -0.66), c.Skin)
	end
	b:egg(V(1.25, 1.05, 1.1), P(0, 2.6, 0), c.Skin)
	for _, s in ipairs({-1, 1}) do
		local ear = P(s * 0.58, 2.72, 0.05) * R(0, 0, s * 10)
		b:egg(V(1.5, 0.55, 0.14), ear * P(s * 0.7, 0, 0), c.Skin)
		detail(b:egg(V(1.2, 0.35, 0.06), ear * P(s * 0.72, 0, -0.08), c.Inner))
		detail(b:egg(V(0.38, 0.42, 0.16), P(s * 0.27, 2.62, -0.5), BLACK))
		detail(b:ball(0.1, P(s * 0.23, 2.71, -0.59), WHITE))
	end
	detail(b:box(V(0.2, 0.04, 0.04), P(0, 2.33, -0.54), c.Skin:Lerp(BLACK, 0.4)))
end

-- Yellow Porous Sponge Leavin': seen from behind, mid-stride, walking out
DEFAULTS.SpongeLeaving = {Body = rgb(250, 230, 80), Pants = rgb(150, 100, 50), Shirt = WHITE}
function FIGURES.SpongeLeaving(b, c)
	for _, leg in ipairs({{-1, 22}, {1, -22}}) do
		local hip = P(leg[1] * 0.35, 1.15, 0) * R(leg[2], 0, 0)
		b:box(V(0.14, 0.9, 0.14), hip * P(0, -0.45, 0), c.Body)
		detail(b:box(V(0.17, 0.3, 0.17), hip * P(0, -0.82, 0), WHITE))
		detail(b:box(V(0.18, 0.05, 0.18), hip * P(0, -0.74, 0), rgb(220, 40, 40)))
		detail(b:box(V(0.18, 0.05, 0.18), hip * P(0, -0.84, 0), rgb(40, 90, 220)))
		detail(b:egg(V(0.36, 0.25, 0.56), hip * P(0, -1.02, 0.1), BLACK))
	end
	b:box(V(1.7, 0.45, 0.6), P(0, 1.35, 0), c.Pants)
	detail(b:box(V(1.72, 0.08, 0.62), P(0, 1.55, 0), BLACK))
	b:box(V(1.7, 0.22, 0.6), P(0, 1.68, 0), c.Shirt)
	b:box(V(1.7, 1.9, 0.6), P(0, 2.74, 0), c.Body)
	-- the sponge's holes, on its back (which faces you)
	local holes = {{-0.5, 3.3, 0.3}, {0.4, 3.45, 0.22}, {0.55, 2.7, 0.34}, {-0.3, 2.4, 0.26}, {0.1, 2.95, 0.18}, {-0.62, 2.0, 0.2}, {0.35, 2.05, 0.24}}
	for _, h in ipairs(holes) do
		b:egg(V(h[3], h[3] * 1.2, 0.08), P(h[1], h[2], -0.3), c.Body:Lerp(rgb(150, 140, 20), 0.45))
	end
	for _, s in ipairs({-1, 1}) do
		b:box(V(0.3, 0.3, 0.32), P(s * 0.95, 2.0, 0), c.Shirt)
		b:box(V(0.12, 0.85, 0.12), P(s * 1.02, 1.55, s * 0.12) * R(s * 22, 0, 0), c.Body)
	end
end

-- Two Pointing Arachnid Suits: two masked heroes pointing at each other
DEFAULTS.PointingSuits = {Red = rgb(200, 30, 40), Blue = rgb(40, 70, 170)}
function FIGURES.PointingSuits(b, c)
	local function suit(cx, turn, armSide, red)
		local T = P(cx, 0, 0) * R(0, turn, 0)
		for _, s in ipairs({-1, 1}) do
			b:box(V(0.42, 1.5, 0.45), T * P(s * 0.25, 0.95, 0), c.Blue)
			b:box(V(0.46, 0.42, 0.56), T * P(s * 0.25, 0.21, -0.04), red)
			b:box(V(0.26, 1.2, 0.62), T * P(s * 0.45, 2.3, 0), c.Blue)
		end
		b:box(V(0.7, 1.3, 0.6), T * P(0, 2.3, 0), red)
		b:box(V(1.12, 0.14, 0.62), T * P(0, 1.68, 0), red)
		detail(b:box(V(0.24, 0.3, 0.04), T * P(0, 2.5, -0.31), BLACK))
		b:egg(V(0.72, 0.86, 0.72), T * P(0, 3.35, 0), red)
		for _, s in ipairs({-1, 1}) do
			detail(b:egg(V(0.3, 0.22, 0.08), T * P(s * 0.16, 3.42, -0.31) * R(0, 0, -s * 25), BLACK))
			detail(b:egg(V(0.24, 0.16, 0.08), T * P(s * 0.16, 3.42, -0.34) * R(0, 0, -s * 25), WHITE))
		end
		-- one arm down, the other pointing straight at the other suit
		b:box(V(0.3, 1.2, 0.34), T * P(-armSide * 0.7, 2.25, 0), red)
		b:box(V(0.3, 0.3, 1.3), T * P(armSide * 0.55, 2.75, -0.55), red)
		b:ball(0.36, T * P(armSide * 0.55, 2.75, -1.25), red)
		b:box(V(0.1, 0.1, 0.35), T * P(armSide * 0.55, 2.78, -1.5), red)
	end
	suit(-1.45, -90, -1, c.Red)
	suit(1.45, 90, 1, c.Red:Lerp(BLACK, 0.12))
end

-- Purple Titan Buggy: a tiny purple hatchback with gold trim
DEFAULTS.TitanBuggy = {Body = rgb(120, 60, 170), Gold = rgb(220, 180, 60)}
function FIGURES.TitanBuggy(b, c)
	for _, x in ipairs({-1.05, 1.05}) do
		for _, z in ipairs({-0.72, 0.72}) do
			detail(b:cyl(0.8, 0.3, P(x, 0.4, z) * R(0, 90, 0), BLACK))
			detail(b:cyl(0.42, 0.34, P(x, 0.4, z) * R(0, 90, 0), rgb(170, 170, 180)))
		end
	end
	b:box(V(2.6, 0.7, 1.4), P(0, 0.78, 0), c.Body)
	b:egg(V(0.9, 0.7, 1.4), P(1.25, 0.8, 0), c.Body)
	b:egg(V(0.7, 0.7, 1.4), P(-1.3, 0.82, 0), c.Body)
	b:egg(V(1.9, 1.1, 1.36), P(-0.1, 1.35, 0), c.Body)
	detail(b:egg(V(1.7, 0.72, 1.42), P(-0.1, 1.45, 0), rgb(60, 70, 90), Enum.Material.Glass))
	b:box(V(2.9, 0.1, 1.44), P(0, 0.98, 0), c.Gold)
	for _, z in ipairs({-0.45, 0.45}) do
		detail(b:ball(0.26, P(1.62, 0.9, z), rgb(255, 240, 170), Enum.Material.Neon))
	end
	detail(b:box(V(0.05, 0.25, 0.8), P(1.68, 0.62, 0), BLACK))
end

-- Sus Purple Birthday Milkshake: the purple shake with a straw and a birthday candle, no logos
DEFAULTS.PurpleShake = {Cup = rgb(245, 245, 250), Shake = rgb(125, 70, 180)}
function FIGURES.PurpleShake(b, c)
	b:egg(V(1.9, 0.08, 1.6), P(0.35, 0.04, -0.3), c.Shake)
	b:cyl(1.3, 2.0, P(0, 1.0, 0) * R(0, 0, 90), c.Cup)
	b:cyl(1.33, 0.6, P(0, 1.1, 0) * R(0, 0, 90), c.Shake)
	b:egg(V(1.28, 0.52, 1.28), P(0, 2.02, 0), c.Shake)
	detail(b:egg(V(1.34, 0.62, 1.34), P(0, 2.05, 0), rgb(230, 230, 240), Enum.Material.Glass)).Transparency = 0.55
	b:egg(V(0.22, 0.45, 0.22), P(0.56, 1.65, -0.4), c.Shake)
	b:cyl(0.16, 1.8, P(0.28, 2.65, 0) * R(0, 0, 72), WHITE)
	b:cyl(0.17, 0.3, P(0.4, 3.0, 0) * R(0, 0, 72), c.Shake)
	detail(b:box(V(0.09, 0.42, 0.09), P(-0.32, 2.45, 0), rgb(255, 150, 200)))
	detail(b:egg(V(0.14, 0.22, 0.14), P(-0.32, 2.76, 0), rgb(255, 200, 80), Enum.Material.Neon))
end

-- Chonky Gray Bunny: an enormous round gray rabbit
DEFAULTS.ChonkyBunny = {Fur = rgb(150, 150, 158), Light = rgb(225, 225, 230), Pink = rgb(240, 160, 170)}
function FIGURES.ChonkyBunny(b, c)
	for _, s in ipairs({-1, 1}) do
		b:egg(V(0.7, 0.35, 1.1), P(s * 0.55, 0.18, -0.25), c.Fur)
		b:egg(V(0.45, 0.8, 0.45), P(s * 1.1, 1.5, -0.2) * R(0, 0, s * 20), c.Fur)
	end
	b:egg(V(2.3, 2.2, 1.9), P(0, 1.25, 0), c.Fur)
	b:egg(V(1.5, 1.5, 0.5), P(0, 1.15, -0.75), c.Light)
	b:egg(V(1.3, 1.15, 1.15), P(0, 2.75, -0.05), c.Fur)
	for _, s in ipairs({-1, 1}) do
		b:egg(V(0.45, 0.35, 0.3), P(s * 0.18, 2.55, -0.55), c.Light)
		detail(b:egg(V(0.22, 0.12, 0.06), P(s * 0.28, 2.92, -0.55), BLACK))
		b:box(V(0.28, 0.07, 0.08), P(s * 0.28, 2.97, -0.56), c.Fur:Lerp(BLACK, 0.2))
		local ear = P(s * 0.3, 3.9, 0.05) * R(0, 0, -s * 10)
		b:egg(V(0.36, 1.4, 0.2), ear, c.Fur)
		detail(b:egg(V(0.2, 1.1, 0.1), ear * P(0, 0, -0.07), c.Pink))
	end
	detail(b:egg(V(0.18, 0.12, 0.1), P(0, 2.68, -0.66), c.Pink))
	detail(b:box(V(0.22, 0.18, 0.05), P(0, 2.4, -0.6), WHITE))
end

-- Much Wow Shiba: the sitting shiba with the side-eye
DEFAULTS.WowShiba = {Fur = rgb(214, 160, 90), Cream = rgb(245, 232, 205)}
function FIGURES.WowShiba(b, c)
	b:egg(V(1.3, 1.6, 1.4), P(0, 0.85, 0.15), c.Fur)
	b:egg(V(0.8, 1.1, 0.4), P(0, 1.0, -0.45), c.Cream)
	for _, s in ipairs({-1, 1}) do
		b:egg(V(0.3, 0.9, 0.3), P(s * 0.3, 0.45, -0.45), c.Cream)
	end
	b:egg(V(0.6, 0.6, 0.35), P(0.5, 1.2, 0.8), c.Fur)
	b:egg(V(0.3, 0.3, 0.37), P(0.5, 1.2, 0.8), c.Cream)
	local H = P(0, 2.1, -0.15) * R(0, 15, -8)
	b:egg(V(1.2, 1.0, 1.0), H, c.Fur)
	b:egg(V(0.9, 0.55, 0.7), H * P(0, -0.2, -0.3), c.Cream)
	b:egg(V(0.45, 0.3, 0.5), H * P(0, -0.12, -0.6), c.Cream)
	detail(b:egg(V(0.18, 0.12, 0.1), H * P(0, -0.02, -0.84), BLACK))
	for _, s in ipairs({-1, 1}) do
		local ear = H * P(s * 0.35, 0.55, 0) * R(0, 0, -s * 15)
		b:egg(V(0.32, 0.55, 0.14), ear, c.Fur)
		detail(b:egg(V(0.18, 0.36, 0.06), ear * P(0, -0.04, -0.06), c.Cream))
		detail(b:egg(V(0.19, 0.13, 0.06), H * P(s * 0.25, 0.1, -0.46), WHITE))
		detail(b:egg(V(0.09, 0.11, 0.06), H * P(s * 0.25 - 0.05, 0.1, -0.49), BLACK)) -- the side-eye
		b:egg(V(0.1, 0.07, 0.04), H * P(s * 0.25, 0.25, -0.45), c.Cream)
	end
	if c.Helmet then
		local glass = detail(b:ball(1.9, H * P(0, 0.05, -0.1), rgb(200, 230, 255), Enum.Material.Glass))
		glass.Transparency = 0.7
		b:cyl(1.3, 0.3, H * P(0, -0.8, -0.1) * R(0, 0, 90), rgb(235, 235, 240))
	end
end

-- Three-Legged Sneaker Shark: a shark standing on three legs in blue sneakers
DEFAULTS.SneakerShark = {Skin = rgb(110, 140, 170), Belly = rgb(235, 238, 242), Shoe = rgb(40, 110, 230)}
function FIGURES.SneakerShark(b, c)
	for i, x in ipairs({-0.7, 0, 0.7}) do
		local z = (i == 2) and 0.25 or -0.2
		b:box(V(0.22, 1.25, 0.22), P(x, 1.0, z), c.Skin)
		detail(b:egg(V(0.66, 0.32, 0.38), P(x - 0.12, 0.2, z), c.Shoe))
		detail(b:box(V(0.66, 0.08, 0.38), P(x - 0.12, 0.05, z), WHITE))
	end
	b:egg(V(3.3, 1.1, 1.1), P(0, 2.1, 0), c.Skin)
	b:egg(V(2.8, 0.62, 0.96), P(-0.1, 1.84, 0), c.Belly)
	b:wedge(V(0.12, 0.8, 0.9), P(0.1, 2.95, 0) * R(0, 90, 0), c.Skin)
	b:egg(V(0.3, 0.95, 0.12), P(1.78, 2.5, 0) * R(0, 0, -30), c.Skin)
	b:egg(V(0.3, 0.75, 0.12), P(1.72, 1.85, 0) * R(0, 0, 30), c.Skin)
	for _, s in ipairs({-1, 1}) do
		b:egg(V(0.62, 0.12, 0.4), P(-0.3, 1.75, s * 0.6) * R(-s * 25, 0, 0), c.Skin)
		detail(b:ball(0.2, P(-1.1, 2.28, s * 0.42), BLACK))
	end
	detail(b:box(V(0.6, 0.05, 1.0), P(-1.15, 1.95, 0), rgb(60, 60, 70)))
end

-- Tung-Tung Log Guy: a wooden log with a big grin, holding a bat
DEFAULTS.LogBatGuy = {Wood = rgb(170, 120, 70), Bat = rgb(205, 165, 105)}
function FIGURES.LogBatGuy(b, c)
	for _, s in ipairs({-1, 1}) do
		b:box(V(0.22, 0.6, 0.22), P(s * 0.3, 0.3, 0), c.Wood:Lerp(BLACK, 0.2))
		b:egg(V(0.34, 0.2, 0.5), P(s * 0.3, 0.08, -0.1), c.Wood:Lerp(BLACK, 0.35))
	end
	b:cyl(1.2, 3.0, P(0, 2.05, 0) * R(0, 0, 90), c.Wood, Enum.Material.Wood)
	b:cyl(1.1, 0.05, P(0, 3.56, 0) * R(0, 0, 90), c.Wood:Lerp(WHITE, 0.3), Enum.Material.Wood)
	for _, s in ipairs({-1, 1}) do
		b:eye(P(s * 0.25, 2.95, -0.57), 0.42)
		detail(b:box(V(0.3, 0.07, 0.05), P(s * 0.25, 3.25, -0.6), BLACK))
	end
	detail(b:egg(V(0.62, 0.26, 0.08), P(0, 2.4, -0.59), rgb(110, 30, 30)))
	b:box(V(0.16, 0.9, 0.16), P(-0.7, 1.85, 0) * R(0, 0, -12), c.Wood)
	b:box(V(0.16, 0.9, 0.16), P(0.74, 2.35, -0.1) * R(0, 0, -40), c.Wood)
	b:cyl(0.2, 1.7, P(1.0, 3.15, -0.15) * R(0, 0, 70), c.Bat, Enum.Material.Wood)
	b:egg(V(0.7, 0.3, 0.3), P(1.18, 3.65, -0.15) * R(0, 0, 70), c.Bat, Enum.Material.Wood)
end

-- Cappuccino Ballerina: a coffee-cup head on a dancing ballerina
DEFAULTS.CappuccinoBallerina = {Cup = rgb(248, 246, 240), Coffee = rgb(150, 100, 60), Tutu = rgb(255, 170, 200), Skin = rgb(236, 200, 170)}
function FIGURES.CappuccinoBallerina(b, c)
	for _, s in ipairs({-1, 1}) do
		b:box(V(0.14, 1.35, 0.14), P(s * 0.14, 0.78, 0) * R(0, 0, s * -4), c.Skin)
		b:egg(V(0.18, 0.3, 0.22), P(s * 0.17, 0.12, 0), c.Tutu)
	end
	b:cyl(1.9, 0.14, P(0, 1.5, 0) * R(0, 0, 90), c.Tutu)
	b:cyl(1.5, 0.2, P(0, 1.6, 0) * R(0, 0, 90), c.Tutu:Lerp(WHITE, 0.35))
	b:egg(V(0.55, 0.85, 0.42), P(0, 1.98, 0), c.Tutu)
	for _, s in ipairs({-1, 1}) do
		b:box(V(0.1, 0.78, 0.1), P(s * 0.475, 2.55, 0) * R(0, 0, -s * 27), c.Skin)
		b:box(V(0.1, 0.75, 0.1), P(s * 0.425, 3.2, 0) * R(0, 0, s * 37), c.Skin)
	end
	b:cyl(0.9, 0.75, P(0, 2.75, 0) * R(0, 0, 90), c.Cup)
	b:cyl(0.82, 0.05, P(0, 3.12, 0) * R(0, 0, 90), c.Coffee)
	b:egg(V(0.32, 0.05, 0.26), P(0, 3.15, 0), c.Cup)
	b:egg(V(0.14, 0.42, 0.34), P(0.5, 2.76, 0), c.Cup)
	for _, s in ipairs({-1, 1}) do
		detail(b:egg(V(0.1, 0.14, 0.05), P(s * 0.15, 2.85, -0.45), BLACK))
	end
	detail(b:egg(V(0.22, 0.08, 0.05), P(0, 2.65, -0.45), rgb(170, 60, 70)))
end

-- Crocodile Bomber Plane: a crocodile that is also a bomber plane, on a display stand
DEFAULTS.CrocBomber = {Skin = rgb(80, 140, 70), Belly = rgb(200, 210, 150), Metal = rgb(140, 145, 150)}
function FIGURES.CrocBomber(b, c)
	b:cyl(1.3, 0.16, P(0, 0.08, 0) * R(0, 0, 90), c.Metal:Lerp(BLACK, 0.4))
	b:box(V(0.15, 1.3, 0.15), P(0, 0.75, 0), c.Metal)
	b:egg(V(3.4, 0.9, 0.9), P(0, 1.8, 0), c.Skin)
	b:egg(V(3.0, 0.5, 0.8), P(0, 1.62, 0), c.Belly)
	b:box(V(1.1, 0.3, 0.55), P(-2.0, 1.76, 0), c.Skin)
	b:box(V(1.0, 0.18, 0.5), P(-1.95, 1.54, 0) * R(0, 0, -8), c.Skin)
	for i = 0, 3 do
		for _, s in ipairs({-1, 1}) do
			detail(b:box(V(0.06, 0.12, 0.06), P(-2.42 + i * 0.25, 1.64, s * 0.26), WHITE))
		end
	end
	for _, s in ipairs({-1, 1}) do
		b:egg(V(0.26, 0.22, 0.26), P(-1.35, 2.2, s * 0.22), c.Skin)
		detail(b:ball(0.1, P(-1.44, 2.24, s * 0.3), BLACK))
		b:cyl(0.35, 0.7, P(-0.35, 1.7, s * 1.0), c.Metal)
		detail(b:box(V(0.05, 0.9, 0.1), P(-0.72, 1.7, s * 1.0), BLACK))
		detail(b:box(V(0.05, 0.1, 0.9), P(-0.72, 1.7, s * 1.0), BLACK))
		b:egg(V(0.8, 0.3, 0.3), P(0.1, 1.24, s * 0.4), c.Metal:Lerp(BLACK, 0.3))
	end
	b:box(V(0.8, 0.1, 3.2), P(-0.1, 1.85, 0), c.Metal)
	b:egg(V(1.5, 0.42, 0.42), P(1.9, 1.9, 0), c.Skin)
	b:box(V(0.5, 0.6, 0.08), P(2.4, 2.2, 0), c.Skin)
	b:box(V(0.4, 0.08, 1.2), P(2.3, 1.95, 0), c.Metal)
end

-- Frowning Cat: the famously grumpy cat, sitting, with its permanent frown
DEFAULTS.GrumpyCat = {Fur = rgb(240, 232, 218), Mask = rgb(150, 125, 105), Eye = rgb(90, 150, 220)}
function FIGURES.GrumpyCat(b, c)
	b:egg(V(1.3, 1.5, 1.3), P(0, 0.8, 0.1), c.Fur)
	for _, s in ipairs({-1, 1}) do
		b:egg(V(0.3, 0.25, 0.45), P(s * 0.25, 0.12, -0.5), c.Fur)
	end
	b:egg(V(0.25, 0.25, 1.1), P(0.6, 0.2, 0.4) * R(0, 40, 0), c.Fur)
	b:egg(V(1.35, 1.1, 1.1), P(0, 2.0, -0.1), c.Fur)
	b:egg(V(0.9, 0.7, 0.5), P(0, 2.0, -0.45), c.Mask)
	for _, s in ipairs({-1, 1}) do
		b:egg(V(0.35, 0.5, 0.15), P(s * 0.42, 2.6, -0.05) * R(0, 0, -s * 20), c.Mask)
		detail(b:egg(V(0.2, 0.14, 0.06), P(s * 0.24, 2.12, -0.68), c.Eye))
		detail(b:egg(V(0.08, 0.12, 0.05), P(s * 0.24, 2.12, -0.71), BLACK))
		b:box(V(0.26, 0.06, 0.06), P(s * 0.24, 2.21, -0.7) * R(0, 0, s * 15), c.Mask:Lerp(BLACK, 0.3))
	end
	detail(b:egg(V(0.14, 0.1, 0.06), P(0, 1.98, -0.73), rgb(200, 130, 130)))
	detail(b:box(V(0.2, 0.05, 0.05), P(-0.09, 1.82, -0.7) * R(0, 0, 25), BLACK))
	detail(b:box(V(0.2, 0.05, 0.05), P(0.09, 1.82, -0.7) * R(0, 0, -25), BLACK))
end

-- Everything's Fine Dog: a dog in a bowler hat with a mug, calm, while the room burns
DEFAULTS.FineDog = {Fur = rgb(230, 190, 90), Hat = rgb(40, 36, 34), Wood = rgb(130, 90, 60)}
function FIGURES.FineDog(b, c)
	local fire, core = rgb(255, 120, 30), rgb(255, 220, 80)
	for _, f in ipairs({{1.2, 1.0, 0.6, 1.0}, {-1.25, 1.2, 0.8, 1.2}, {1.0, 2.3, 0.8, 0.9}, {-1.0, 2.6, 1.0, 1.0}, {0, 3.4, 1.0, 0.8}}) do
		detail(b:egg(V(0.6, f[4] * 1.4, 0.4), P(f[1], f[2], f[3]), fire, Enum.Material.Neon))
		detail(b:egg(V(0.3, f[4] * 0.8, 0.42), P(f[1], f[2] - 0.15, f[3] - 0.05), core, Enum.Material.Neon))
	end
	b:box(V(1.0, 0.12, 1.0), P(0.3, 0.9, 0.2), c.Wood)
	for _, x in ipairs({-0.15, 0.75}) do
		b:box(V(0.1, 0.9, 0.1), P(x, 0.45, 0.2), c.Wood)
	end
	b:egg(V(1.0, 1.2, 0.9), P(0.3, 1.5, 0.2), c.Fur)
	b:egg(V(0.28, 0.5, 0.3), P(-0.05, 1.5, -0.2) * R(-60, 0, 0), c.Fur)
	b:egg(V(1.0, 0.85, 0.85), P(0.3, 2.4, 0.1), c.Fur)
	for _, s in ipairs({-1, 1}) do
		b:egg(V(0.25, 0.5, 0.15), P(0.3 + s * 0.46, 2.32, 0.1), c.Fur:Lerp(rgb(120, 70, 30), 0.6))
		b:eye(P(0.3 + s * 0.18, 2.5, -0.3), 0.2)
	end
	detail(b:box(V(0.25, 0.04, 0.04), P(0.3, 2.2, -0.34), BLACK))
	b:cyl(0.95, 0.06, P(0.3, 2.76, 0.1) * R(0, 0, 90), c.Hat)
	b:egg(V(0.62, 0.52, 0.62), P(0.3, 2.95, 0.1), c.Hat)
	b:box(V(1.3, 0.1, 0.8), P(-0.75, 1.55, -0.55), c.Wood)
	b:box(V(0.12, 1.5, 0.12), P(-0.75, 0.75, -0.55), c.Wood)
	detail(b:cyl(0.3, 0.36, P(-0.7, 1.78, -0.62) * R(0, 0, 90), WHITE))
end

-- Sus Space Bean: the little bean-shaped astronaut with a visor and a backpack
DEFAULTS.SusBean = {Body = rgb(200, 40, 40), Visor = rgb(150, 210, 230)}
function FIGURES.SusBean(b, c)
	for _, s in ipairs({-1, 1}) do
		b:box(V(0.55, 0.6, 0.9), P(s * 0.36, 0.35, 0), c.Body)
		b:egg(V(0.55, 0.3, 0.9), P(s * 0.36, 0.08, 0), c.Body)
	end
	b:egg(V(1.5, 2.2, 1.3), P(0, 1.6, 0), c.Body)
	b:box(V(1.0, 1.1, 0.45), P(0, 1.5, 0.72), c.Body:Lerp(BLACK, 0.2))
	detail(b:egg(V(1.0, 0.55, 0.5), P(0, 2.1, -0.5), c.Visor, Enum.Material.Glass)).Reflectance = 0.2
	detail(b:egg(V(0.32, 0.12, 0.06), P(0.2, 2.22, -0.76), WHITE))
end

-- Dramatic Look Hamster: a little rodent whipping its head around to stare at you
DEFAULTS.DramaticHamster = {Fur = rgb(170, 120, 70), Light = rgb(225, 195, 150)}
function FIGURES.DramaticHamster(b, c)
	local body = P(0, 0, 0) * R(0, 70, 0)
	b:egg(V(1.0, 1.8, 0.9), body * P(0, 1.0, 0), c.Fur)
	b:egg(V(0.6, 1.2, 0.3), body * P(0, 0.95, -0.38), c.Light)
	for _, s in ipairs({-1, 1}) do
		b:egg(V(0.3, 0.2, 0.5), body * P(s * 0.25, 0.1, -0.2), c.Fur)
		b:egg(V(0.18, 0.4, 0.18), body * P(s * 0.22, 1.35, -0.45) * R(30, 0, 0), c.Fur)
	end
	local H = P(0, 2.1, 0) * R(-6, 0, 5)
	b:egg(V(0.9, 0.8, 0.85), H, c.Fur)
	b:egg(V(0.45, 0.32, 0.32), H * P(0, -0.14, -0.35), c.Light)
	detail(b:egg(V(0.14, 0.1, 0.08), H * P(0, -0.08, -0.51), rgb(60, 40, 30)))
	for _, s in ipairs({-1, 1}) do
		detail(b:egg(V(0.24, 0.26, 0.1), H * P(s * 0.22, 0.1, -0.36), BLACK))
		detail(b:ball(0.08, H * P(s * 0.2, 0.16, -0.42), WHITE))
		b:egg(V(0.2, 0.18, 0.1), H * P(s * 0.34, 0.38, 0), c.Fur:Lerp(BLACK, 0.2))
	end
end

-- Rainbow Pastry Cat: a gray cat with a frosted pastry body, flying on a rainbow
DEFAULTS.RainbowPastryCat = {Crust = rgb(240, 200, 150), Frosting = rgb(250, 140, 200), Fur = rgb(150, 150, 155)}
function FIGURES.RainbowPastryCat(b, c)
	b:cyl(1.2, 0.14, P(0, 0.07, 0) * R(0, 0, 90), rgb(70, 60, 90))
	b:box(V(0.14, 0.9, 0.14), P(0, 0.55, 0), rgb(120, 120, 130))
	local rainbow = {rgb(255, 50, 50), rgb(255, 150, 30), rgb(255, 235, 40), rgb(60, 220, 60), rgb(40, 150, 255), rgb(140, 70, 230)}
	for i, color in ipairs(rainbow) do
		detail(b:box(V(2.0, 0.17, 0.12), P(-1.75, 2.05 - i * 0.17, 0), color))
	end
	b:box(V(1.6, 1.2, 0.4), P(0, 1.6, 0), c.Crust)
	b:box(V(1.36, 0.96, 0.44), P(0, 1.6, 0), c.Frosting)
	for _, spot in ipairs({{-0.45, 1.85}, {0.1, 1.95}, {0.45, 1.7}, {-0.2, 1.45}, {0.3, 1.3}, {-0.5, 1.3}}) do
		detail(b:box(V(0.1, 0.1, 0.05), P(spot[1], spot[2], -0.24), rgb(220, 40, 150)))
	end
	for _, x in ipairs({-0.55, -0.25, 0.25, 0.55}) do
		b:box(V(0.16, 0.26, 0.16), P(x, 0.92, 0), c.Fur)
	end
	b:box(V(0.5, 0.14, 0.14), P(-1.0, 1.55, 0), c.Fur)
	b:egg(V(0.85, 0.66, 0.45), P(0.95, 1.45, -0.05), c.Fur)
	for _, s in ipairs({-1, 1}) do
		b:egg(V(0.2, 0.3, 0.14), P(0.95 + s * 0.26, 1.8, -0.05) * R(0, 0, -s * 15), c.Fur)
		detail(b:ball(0.12, P(0.95 + s * 0.16, 1.5, -0.27), BLACK))
		detail(b:egg(V(0.12, 0.08, 0.04), P(0.95 + s * 0.28, 1.36, -0.26), rgb(255, 150, 170)))
	end
end

---------------------------------------------------------------------
-- BUILD / FIT / RELIEF
---------------------------------------------------------------------
local function bounds(model)
	local lo, hi = V(math.huge, math.huge, math.huge), V(-math.huge, -math.huge, -math.huge)
	for _, p in ipairs(model:GetDescendants()) do
		if p:IsA("BasePart") then
			local cf, half = p.CFrame, p.Size / 2
			-- the part's world-space extents (its box, turned)
			local ex = math.abs(cf.XVector.X) * half.X + math.abs(cf.YVector.X) * half.Y + math.abs(cf.ZVector.X) * half.Z
			local ey = math.abs(cf.XVector.Y) * half.X + math.abs(cf.YVector.Y) * half.Y + math.abs(cf.ZVector.Y) * half.Z
			local ez = math.abs(cf.XVector.Z) * half.X + math.abs(cf.YVector.Z) * half.Y + math.abs(cf.ZVector.Z) * half.Z
			local e = V(ex, ey, ez)
			lo = lo:Min(cf.Position - e)
			hi = hi:Max(cf.Position + e)
		end
	end
	return lo, hi
end
MemeFigures.bounds = bounds

-- scales every part around the origin (works everywhere, no Model:ScaleTo needed)
local function scale(model, s, zExtra)
	zExtra = zExtra or 1
	for _, p in ipairs(model:GetDescendants()) do
		if p:IsA("BasePart") then
			local cf = p.CFrame
			local pos = cf.Position
			local size = p.Size * s
			if zExtra ~= 1 then
				-- press flat along world Z: shrink whichever of the part's own axes points most along Z
				local ax, ay, az = math.abs(cf.XVector.Z), math.abs(cf.YVector.Z), math.abs(cf.ZVector.Z)
				local squashX = ax >= ay and ax >= az
				if squashX then
					size = V(size.X * zExtra, size.Y, size.Z)
				elseif ay >= az then
					size = V(size.X, size.Y * zExtra, size.Z)
				else
					size = V(size.X, size.Y, size.Z * zExtra)
				end
				-- round parts can't be squashed across their roundness; swap in a mesh that can
				if p:IsA("Part") and p.Shape == Enum.PartType.Ball then
					p.Shape = Enum.PartType.Block
					local mesh = Instance.new("SpecialMesh")
					mesh.MeshType = Enum.MeshType.Sphere
					mesh.Parent = p
				elseif p:IsA("Part") and p.Shape == Enum.PartType.Cylinder and not squashX then
					p.Shape = Enum.PartType.Block
					local mesh = Instance.new("SpecialMesh")
					mesh.MeshType = Enum.MeshType.Cylinder
					mesh.Parent = p
				end
			end
			p.Size = size
			p.CFrame = cf.Rotation + V(pos.X * s, pos.Y * s, pos.Z * s * zExtra)
		end
	end
end

function MemeFigures.fit(model, width, height)
	local lo, hi = bounds(model)
	local size = hi - lo
	local s = math.min(width / math.max(size.X, size.Z), height / size.Y)
	scale(model, s)
	return s
end

function MemeFigures.build(spec)
	local kind = spec and FIGURES[spec.Kind]
	if not kind then return nil end
	local model = Instance.new("Model")
	model.Name = "MemeFigure"
	local palette = setmetatable(table.clone(spec.Colors or {}), {__index = DEFAULTS[spec.Kind] or {}})
	kind(setmetatable({Model = model}, Builder), palette)
	if YAW[spec.Kind] then
		local turn = R(0, YAW[spec.Kind], 0)
		for _, p in ipairs(model:GetChildren()) do
			if p:IsA("BasePart") then p.CFrame = turn * p.CFrame end
		end
	end
	-- a world's finish (gold, ice, lava...) over everything but the eyes and small details
	if spec.Tint or spec.Material then
		for _, p in ipairs(model:GetChildren()) do
			if p:IsA("BasePart") and p.Name ~= "Detail" then
				if spec.Tint then p.Color = p.Color:Lerp(spec.Tint, spec.TintAmount or 0.5) end
				if spec.Material then p.Material = spec.Material end
			end
		end
	end
	-- stand it on y = 0, centered
	local lo, hi = bounds(model)
	local shift = V(-(lo.X + hi.X) / 2, -lo.Y, -(lo.Z + hi.Z) / 2)
	for _, p in ipairs(model:GetChildren()) do
		if p:IsA("BasePart") then p.CFrame = p.CFrame + shift end
	end
	return model
end

-- the figure pressed flat into a relief (a coin face or a carved stone), shaded by the
-- figure's own light and dark colors so the silhouette reads like a real carving
function MemeFigures.relief(spec, width, height, depth, color, material)
	local model = MemeFigures.build(spec)
	if not model then return nil end
	local lo, hi = bounds(model)
	local size = hi - lo
	for _, p in ipairs(model:GetChildren()) do
		if p:IsA("BasePart") then p.CFrame = p.CFrame - V(0, size.Y / 2, 0) end
	end
	local s = math.min(width / size.X, height / size.Y)
	scale(model, s, depth / math.max(size.Z * s, 0.01))
	for _, p in ipairs(model:GetChildren()) do
		if p:IsA("BasePart") then
			local c = p.Color
			local light = 0.3 * c.R + 0.55 * c.G + 0.15 * c.B
			p.Color = color:Lerp(Color3.new(0, 0, 0), 0.35 * (1 - light)):Lerp(Color3.new(1, 1, 1), 0.15 * light)
			p.Material = material or Enum.Material.Metal
			p.Transparency = 0
			p.Reflectance = 0
		end
	end
	return model
end

return MemeFigures
]=])
install(game:GetService("ReplicatedStorage"), "MemeList", "ModuleScript", [=[
-- MemeList (ModuleScript in ReplicatedStorage)
-- Every meme in the game: 9 worlds x 20 memes, with the rarity each one has on the master list.
-- Written by the asset spec (Meme Archaeologist: 3D Meme Parody Asset Spec). All names are parodies.
-- Format per meme: {rarity, id, name, form, museum description}
--   form = Statue | Painting | Coin | Tablet | Relic (famous memes with a built 3D figure use MemeFigures instead)

local MemeList = {}

-- the named secret rarities, rarest last; Income = money per second in World 1, Chance = roll weight
MemeList.SecretTiers = {
	{Name = "Exotic", Income = 5000, Chance = 0.08, Color = Color3.fromRGB(255, 90, 200)},
	{Name = "Mythical", Income = 12000, Chance = 0.04, Color = Color3.fromRGB(255, 60, 90)},
	{Name = "Godly", Income = 5000, Chance = 0.08, Color = Color3.fromRGB(255, 215, 60)},
	{Name = "Miracle", Income = 12000, Chance = 0.04, Color = Color3.fromRGB(120, 255, 200)},
	{Name = "Ruby", Income = 70000, Chance = 0.01, Color = Color3.fromRGB(230, 40, 60)},
	{Name = "Eternal", Income = 5000, Chance = 0.08, Color = Color3.fromRGB(255, 250, 200)},
	{Name = "Supreme", Income = 12000, Chance = 0.04, Color = Color3.fromRGB(180, 120, 255)},
	{Name = "Insane", Income = 30000, Chance = 0.02, Color = Color3.fromRGB(255, 140, 40)},
	{Name = "Foresaken", Income = 70000, Chance = 0.01, Color = Color3.fromRGB(90, 200, 255)},
	{Name = "Diabolical", Income = 5000, Chance = 0.08, Color = Color3.fromRGB(200, 255, 90)},
	{Name = "Celestial", Income = 12000, Chance = 0.04, Color = Color3.fromRGB(255, 0, 120)},
	{Name = "Unreal", Income = 30000, Chance = 0.02, Color = Color3.fromRGB(120, 255, 255)},
	{Name = "Forbidden", Income = 70000, Chance = 0.01, Color = Color3.fromRGB(255, 120, 255)},
	{Name = "Ascendent", Income = 5000, Chance = 0.08, Color = Color3.fromRGB(150, 0, 255)},
	{Name = "Omega", Income = 12000, Chance = 0.04, Color = Color3.fromRGB(0, 200, 255)},
	{Name = "Infinite", Income = 30000, Chance = 0.02, Color = Color3.fromRGB(255, 80, 0)},
	{Name = "Aquatic", Income = 70000, Chance = 0.01, Color = Color3.fromRGB(100, 255, 140)},
	{Name = "Ultimate", Income = 5000, Chance = 0.08, Color = Color3.fromRGB(0, 140, 255)},
	{Name = "Beyond", Income = 12000, Chance = 0.04, Color = Color3.fromRGB(40, 220, 200)},
	{Name = "Immortal", Income = 30000, Chance = 0.02, Color = Color3.fromRGB(0, 90, 200)},
	{Name = "Paradox", Income = 70000, Chance = 0.01, Color = Color3.fromRGB(220, 255, 255)},
	{Name = "Universal", Income = 5000, Chance = 0.08, Color = Color3.fromRGB(160, 255, 60)},
	{Name = "Exponential", Income = 12000, Chance = 0.04, Color = Color3.fromRGB(140, 60, 200)},
	{Name = "Miraculous", Income = 30000, Chance = 0.02, Color = Color3.fromRGB(255, 255, 255)},
	{Name = "Apex", Income = 70000, Chance = 0.01, Color = Color3.fromRGB(255, 170, 230)},
	{Name = "Gilded", Income = 150000, Chance = 0.005, Color = Color3.fromRGB(80, 255, 80)},
	{Name = "Toorng", Income = 350000, Chance = 0.0025, Color = Color3.fromRGB(255, 200, 120)},
	{Name = "Roller", Income = 800000, Chance = 0.0012, Color = Color3.fromRGB(255, 220, 0)},
	{Name = "Immeasupreme", Income = 2000000, Chance = 0.0006, Color = Color3.fromRGB(60, 0, 120)},
	{Name = "Impossible", Income = 5000, Chance = 0.08, Color = Color3.fromRGB(255, 60, 160)},
	{Name = "Quantum", Income = 12000, Chance = 0.04, Color = Color3.fromRGB(255, 245, 150)},
	{Name = "Transcendent", Income = 30000, Chance = 0.02, Color = Color3.fromRGB(0, 255, 170)},
	{Name = "???", Income = 70000, Chance = 0.01, Color = Color3.fromRGB(255, 255, 255)},
}

MemeList.Worlds = {
	-- WORLD 1: GRASSLAND DIG PIT
	{Name = "Grassland Dig Pit", Memes = {
		{"Basic", "DaWaeEchidna", "Da Wae Red Echidna", "Statue", "A stubby red echidna that always knew the way. Nobody else did."},
		{"Basic", "SeaShantyMug", "Sea Shanty Mug", "Relic", "Soon may the Wellerman come. A whole internet sang along in 2021."},
		{"Basic", "AisleYodelSet", "Aisle Yodel Cowboy Set", "Relic", "A tiny hat and boots left in a store aisle. The yodel still echoes."},
		{"Basic", "ConvinceMeTable", "Convince Me Otherwise Table", "Relic", "A folding table where humans argued with strangers. Nobody's mind was changed."},
		{"Common", "ShockedRodent", "Shocked Yellow Rodent", "Statue", "Frozen forever with its mouth wide open. Used whenever anyone acted surprised."},
		{"Common", "IsThisABird", "Is This a Bird?", "Painting", "A man points at a butterfly and asks the wrong question. A human classic."},
		{"Common", "ChonkyBunny", "Chonky Gray Bunny", "Statue", "A rabbit of truly legendary size. Humans simply called it big."},
		{"Common", "SpicyLasagna", "Spicy Lasagna Diss Track", "Relic", "A lasagna with a record baked into it. The spiciest dish of the 2010s."},
		{"Uncommon", "SpikedShellCrown", "Spiked Shell Crown", "Relic", "A green spiked shell wearing a crown. The internet argued about it for a week."},
		{"Uncommon", "GrapeSurgery", "Grape Operation Theater", "Relic", "They did surgery on a grape. The grape survived."},
		{"Uncommon", "BadBoyHatchback", "This Bad Boy Hatchback", "Statue", "You can fit so many memes in this bad boy."},
		{"Uncommon", "TempleTap", "Think-About-It Temple Tap", "Statue", "Can't fail your test if you never take it. Pure genius."},
		{"Rare", "SteamedClams", "Steamed Clams at Noon Platter", "Relic", "A platter of burgers and an aurora in the kitchen. Localized entirely within it."},
		{"Rare", "MegaSealTape", "Mega Seal Tape", "Relic", "Held a sawn-in-half boat together. The water stayed in."},
		{"Rare", "PurpleTitanBuggy", "Purple Titan Buggy", "Statue", "A giant purple conqueror's tiny car. He could snap his fingers but still drove this."},
		{"Rare", "OrcaRebellionBoat", "Orca Rebellion Boat", "Statue", "The orcas started sinking boats in 2023. The internet picked a side."},
		{"Epic", "NeverMissDartboard", "Never-Miss Dartboard", "Relic", "Hit or miss? It never misses, huh."},
		{"Epic", "CrimeTownBoss", "Crime Town Big Boss", "Statue", "That's how crime works. Learned from a thousand phone ads."},
		{"Legendary", "BoneComedian", "Bone Comedian Fighter", "Statue", "A grinning skeleton who crashed the biggest fighting game party. Bad time guaranteed."},
		{"Legendary", "SugarSneakJohnny", "Sugar-Sneak Johnny", "Statue", "Eating sugar? No, papa. Open your mouth. Ha ha ha."},
	}},
	-- WORLD 2: FROZEN ICE AGE
	{Name = "Frozen Ice Age", Memes = {
		{"Basic", "FrostFlask", "Sksksk Frost Flask", "Relic", "Covered in stickers and scrunchies. And I oop."},
		{"Basic", "BreathtakingCyberGuy", "You're Breathtaking Cyber-Guy", "Statue", "Pointed at a crowd and told them they were breathtaking. They were."},
		{"Basic", "EnslavedMoisture", "Enslaved Moisture Cubes", "Relic", "Ice: water in chains. Free them."},
		{"Common", "StonksHead", "Stonks Suit Head", "Statue", "A smooth head that understood the market perfectly. Stonks only go up."},
		{"Common", "AhShucks", "Ah Shucks, Here We Go Again", "Statue", "Every human's reaction to Monday. Here we go again."},
		{"Common", "UncannyHedgehog", "Uncanny Blue Speedy Hedgehog", "Statue", "The redesign so scary they redesigned it again."},
		{"Uncommon", "SpaceInfant", "Green Space Infant", "Statue", "A tiny green baby with enormous ears. Every human wanted to protect it."},
		{"Uncommon", "MeAndTheCrew", "Me and the Crew", "Statue", "Four friends walking toward adventure. Or the snack aisle."},
		{"Uncommon", "CyberWedgeTruck", "Cyber Wedge Truck", "Statue", "An unbreakable window demo. The window broke."},
		{"Rare", "YelledAtCat", "Yelled-At Dinner Cat", "Statue", "A confused cat at dinner, being yelled at. It did nothing wrong."},
		{"Rare", "RaidAlien", "Arms-Back Raid Alien", "Statue", "They can't stop all of us. They stopped all of us."},
		{"Rare", "AngelWingDancer", "Angel-Wing Dance Legend", "Statue", "A dance so powerful it gained wings."},
		{"Epic", "KombuchaDisgust", "Kombucha Disgust Bottle", "Relic", "One sip made the whole internet scrunch its face."},
		{"Epic", "DoubleTakeBlink", "Double-Take Blink Bust", "Statue", "Blinked in disbelief. Humans have been blinking back ever since."},
		{"Epic", "TallPinkPiglet", "Absurdly Tall Pink Piglet", "Statue", "Scientists calculated her real height. They regret it."},
		{"Legendary", "SpongeLeaving", "Yellow Porous Sponge Leavin'", "Statue", "Aight, imma head out. The most famous exit in history."},
		{"Legendary", "CappuccinoBallerina", "Cappuccino Ballerina", "Statue", "Half dancer, half coffee cup. Pirouettes until the foam spills."},
		{"Exotic", "FrozenCoffinDance", "Frozen Coffin Dance Crew", "Statue", "They danced the dead to the grave. On ice."},
		{"Mythical", "HundredMenGorilla", "100 Men vs 1 Gorilla", "Statue", "Who would win? The internet argued for a whole month."},
		{"Uncommon", "GothDanceHands", "Goth Dance Freeze", "Statue", "The jerky goth dance everyone copied at the school dance."},
	}},
	-- WORLD 3: VOLCANIC LAVA TRENCH
	{Name = "Volcanic Lava Trench", Memes = {
		{"Basic", "NatureHealingSwan", "Nature Is Healing Swan", "Relic", "The swans came back. Nature is healing. We are the virus."},
		{"Basic", "OnceAgainLectern", "Once Again Asking Lectern", "Relic", "I am once again asking for your support. And your snacks."},
		{"Basic", "LockdownSourdough", "Lockdown Sourdough Loaf", "Relic", "Everyone became a baker in 2020. This loaf survived."},
		{"Common", "HeadBobCat", "Head-Bob Vibe Cat", "Statue", "Bobbing its head to the beat since the dawn of time."},
		{"Common", "PallbearerCoin", "Pallbearer Dance Coin", "Coin", "Struck to honor the dancing pallbearers. Astronomia plays when you flip it."},
		{"Common", "TumbleJellyBean", "Tumble Jelly Bean", "Statue", "Fell off every obstacle course ever made. Still smiling."},
		{"Uncommon", "SwoleVsSmol", "Swole Shiba vs Smol Shiba", "Statue", "Back in my day we dug with our paws. Now: bonk."},
		{"Uncommon", "PointingLaughChair", "Pointing Laugh Armchair", "Statue", "Pointing at the TV and laughing. Every human at every family gathering."},
		{"Uncommon", "PolkaSpinCow", "Polka Spin Cow", "Statue", "Spins to the same polka for eternity. Scientists can't stop it."},
		{"Rare", "SusBean", "Sus Space Bean", "Statue", "A tiny astronaut shaped like a bean. One of them was always acting sus."},
		{"Rare", "PartyCornerGuy", "They Don't Know Party Corner", "Painting", "Standing alone at the party, knowing something nobody else knows."},
		{"Rare", "BeepBopMicKid", "Beep-Bop Mic Kid", "Statue", "Won every rap battle with four arrows. Beep bop."},
		{"Epic", "TradeOfferScroll", "Trade Offer Scroll", "Relic", "I receive: your meme. You receive: nothing. Deal?"},
		{"Epic", "BigMittensChair", "Big Mittens Folding Chair", "Relic", "A cozy pair of mittens on a folding chair. Photoshopped into every place on Earth."},
		{"Legendary", "ThinkSonThink", "Think, Son, Think! Hero", "Statue", "Shouted a question so loud it became a meme. Think!"},
		{"Legendary", "SneakerShark", "Three-Legged Sneaker Shark", "Statue", "A shark on three legs in blue sneakers. The face of Italian brainrot."},
		{"Godly", "JawlineChad", "Mega Jawline Chad", "Statue", "The most perfect jawline ever photographed, turned in the most dramatic direction."},
		{"Miracle", "BingChillingCone", "Bing Chilling Cone", "Relic", "Zao shang hao. The coldest ice cream in the lava trench."},
		{"Exotic", "SigmaGrindset", "Sigma Grindset Statue", "Statue", "Stares at the sunset alone. Refuses to have fun. Grinds."},
		{"Ruby", "EmotionalDamage", "Emotional Damage Heart", "Relic", "Hit so hard it cracked. Emotional damage!"},
	}},
	-- WORLD 4: ANCIENT EGYPTIAN CATACOMBS
	{Name = "Ancient Egyptian Catacombs", Memes = {
		{"Basic", "YesNoLabDog", "Yes-No Lab Dog", "Statue", "Answers every question with yes, no, or a hang-up."},
		{"Basic", "AssistantSam", "Assistant Sam", "Statue", "A phone assistant who became more famous than the phone."},
		{"Basic", "LampOilMerchant", "Lamp Oil Merchant", "Statue", "Lamp oil, rope, bombs? You want it? It's yours, my friend."},
		{"Common", "MaulingTimeVampire", "It's Mauling Time Vampire", "Statue", "The film flopped. The meme earned a billion."},
		{"Common", "GentlePillSquad", "Gentle Yellow Pill Squad", "Statue", "Went to the movies in suits. Very gentle. Very minion."},
		{"Common", "WiseMysticalTree", "Wise Mystical Tree", "Statue", "I am the wise mystical tree. Ask me anything."},
		{"Uncommon", "ItsCornCob", "It's Corn Cob", "Relic", "A big lump with knobs. It has the juice."},
		{"Uncommon", "UncannySuperDad", "Uncanny Super Dad", "Painting", "The face gets darker the longer you look."},
		{"Uncommon", "GirlDinnerPlate", "Girl Dinner Plate", "Relic", "Bread, cheese, grapes, a pickle. Dinner is served."},
		{"Rare", "PhonkEyebrowSpeaker", "Phonk Eyebrow Speaker", "Relic", "Raises an eyebrow every time the bass drops."},
		{"Rare", "RizzFaceMask", "Rizz Face Mask", "Relic", "One eyebrow up, lips pressed. The rizz face, preserved forever."},
		{"Rare", "ClangingPipe", "Clanging Metal Pipe", "Relic", "The loudest sound effect in human history. CLANG."},
		{"Epic", "BetterCallPaul", "Better Call Paul Lawyer", "Statue", "Did you know you have rights? This lawyer spins in 3D."},
		{"Epic", "KingPrawnCrooner", "King Prawn Crooner", "Statue", "A prawn in a pinstripe suit, singing his heart out."},
		{"Legendary", "OhioFinalBoss", "Ohio Final Boss", "Statue", "Only in Ohio. It wears a traffic cone as a crown."},
		{"Legendary", "OhYeahVillain", "Oh Yeah Orange-Suit Villain", "Statue", "Committed crimes with both direction and magnitude. OH YEAH!"},
		{"Eternal", "LogBatGuy", "Tung-Tung Log Guy", "Statue", "A wooden log with a baseball bat. It knocks three times before it arrives."},
		{"Supreme", "ShailushaiCat", "Shailushai Blue Cat", "Statue", "We live, we love, we lie. A blue cat walking the catacombs."},
		{"Insane", "BirthdayShake", "Sus Purple Birthday Shake", "Relic", "One sip and the humans in the video were never seen again."},
		{"Foresaken", "WhistleEdit", "Whistle Edit Relic", "Relic", "The whistle that played over a thousand edits of the same actor."},
	}},
	-- WORLD 5: CYBER GLITCH GRID
	{Name = "Cyber Glitch Grid", Memes = {
		{"Basic", "PeachesTurtleKing", "Peaches Piano Turtle King", "Statue", "Peaches, peaches, peaches. A turtle king's love song."},
		{"Basic", "KindergartenMascot", "Kindergarten Blob Mascot", "Statue", "The mascot of a kindergarten nobody should ever visit."},
		{"Basic", "CursedCartoonTape", "Cursed Cartoon Tape", "Relic", "An old cartoon tape. Do not answer the questions it asks."},
		{"Common", "AwkwardSmileGuy", "Awkward Smile Guy", "Statue", "Smiled awkwardly in a hallway. Became immortal."},
		{"Common", "LaughCryCarSeat", "Laugh-Then-Cry Car Seat", "Relic", "Laughing one second, crying the next. The seat remembers."},
		{"Common", "CanonEventWeb", "Canon Event Web", "Relic", "Some things have to happen. This web proves it."},
		{"Uncommon", "PinkbombFeature", "Pinkbomb Double Feature", "Relic", "Two movies, one weekend. Half pink, half boom."},
		{"Uncommon", "BoulderEyebrow", "The Boulder Eyebrow", "Statue", "A boulder that raised one eyebrow at humanity."},
		{"Uncommon", "PointingSuits", "Two Pointing Arachnid Suits", "Statue", "Two identical heroes accusing each other of being the fake."},
		{"Rare", "MewingHush", "Mewing Hush Bust", "Statue", "Don't speak. You'll ruin the jawline. Bye bye."},
		{"Rare", "EnglishSpanishChair", "English or Spanish Chair", "Relic", "English or Spanish? Choose wisely."},
		{"Rare", "AHyuckDog", "A-Hyuck Goofy Dog", "Statue", "Laughed so hard he became brainrot."},
		{"Epic", "NoScopeOlympian", "No-Scope Olympian", "Statue", "Won silver with one hand in his pocket. Didn't even try."},
		{"Epic", "PommelHorseLegend", "Pommel Horse Legend", "Statue", "Waited all day for one routine. Nailed it."},
		{"Legendary", "BratGreenSlab", "Brat Green Slab", "Tablet", "A whole summer, carved in lime green."},
		{"Legendary", "PedroRaccoon", "Pedro Pedro Raccoon", "Statue", "Pedro, Pedro, Pedro. Spins forever."},
		{"Diabolical", "CrocBomber", "Crocodile Bomber Plane", "Statue", "A crocodile that is also a war plane. Nobody asked questions."},
		{"Celestial", "ChillDude", "Chill Dude in a Sweater", "Statue", "Hands in pockets, zero worries. Just a chill dude."},
		{"Unreal", "BabyHippo", "Bouncy Baby Hippo", "Statue", "A tiny wet hippo who bit everyone and was loved for it."},
		{"Forbidden", "DubaiChocolate", "Dubai Chocolate Bar", "Relic", "Snapped in half, oozing pistachio. The most expensive snack of 2025."},
	}},
	-- WORLD 6: DEEP OCEAN TRENCH
	{Name = "Deep Ocean Trench", Memes = {
		{"Basic", "LowTaperFade", "Massive Low Taper Fade", "Statue", "Imagine if this haircut was still trending. It's massive."},
		{"Basic", "ShushUpTablet", "Shush Up Tablet", "Tablet", "A stone tablet that tells everyone to be quiet."},
		{"Basic", "BigGamerChair", "Big Gamer Chair", "Relic", "The biggest gaming chair in the ocean. The snacks are gone."},
		{"Common", "SixSevenHands", "Six-Seven Hands", "Statue", "Six... seven. Palms up, one high, one low. 2025's word of the year."},
		{"Common", "TakeEggCushion", "Take Egg Cushion", "Relic", "Take egg. Just one egg. On a cushion."},
		{"Common", "IbizaBossDancer", "Ibiza Final Boss Dancer", "Statue", "The final boss of every beach party."},
		{"Uncommon", "BoutiqueRock", "Overpriced Boutique Rock", "Relic", "A plain rock. $200. Sold out."},
		{"Uncommon", "LittleFrenchFish", "Steve the Little French Fish", "Statue", "Oui oui. A little fish with a big baguette."},
		{"Uncommon", "VeryDemureTeacup", "Very Demure Teacup", "Relic", "Very mindful. Very demure. Pinky out at all times."},
		{"Rare", "JohnPorkPhone", "John Pork Is Calling", "Relic", "A pig in a suit is calling. Do not pick up."},
		{"Rare", "BeforeGTA6Hourglass", "Before-GTA6 Hourglass", "Relic", "Everything happened before the next big game came out. The sand is still falling."},
		{"Rare", "StandingOnBusiness", "Standing on Business Briefcase", "Relic", "Literally standing on business."},
		{"Epic", "AuraBoatBow", "Aura Boat Bow", "Relic", "So much aura it glows. Farmed on a racing boat."},
		{"Epic", "PaperclipHelper", "Paperclip Helper", "Statue", "It looks like you're digging up memes. Need help?"},
		{"Legendary", "ZombieChickenRider", "Baby Zombie Chicken Rider", "Statue", "The loudest cheer in any movie theater of the 2020s."},
		{"Legendary", "JetTooHoliday", "Jet Too Holiday Plane", "Relic", "Nothing beats a holiday. A cheerful little plane on its way to the sun."},
		{"Ascendent", "PressureDiverHelmet", "Deep Pressure Diver Helmet", "Relic", "Crushed by the deep. The bubbles still leak out."},
		{"Omega", "AbyssalAngler", "Abyssal Brainrot Angler", "Statue", "An anglerfish on three legs in sneakers, luring divers with a glowing brain."},
		{"Infinite", "GlitchWhale", "Oceanic Glitch Whale", "Statue", "A whale that failed to load. Half of it is still buffering."},
		{"Aquatic", "AtlantisJawlineChad", "Atlantis Jawline Chad", "Statue", "The jawline, lost at the bottom of the sea for a thousand years."},
	}},
	-- WORLD 7: HAUNTED CEMETERY
	{Name = "Haunted Cemetery", Memes = {
		{"Basic", "SpookySkeleton", "Spooky Scary Skeleton", "Statue", "Sends shivers down your spine. Dances anyway."},
		{"Basic", "PumpkinDancer", "Pumpkin Head Dancer", "Statue", "A pumpkin-headed man who danced every October."},
		{"Basic", "GhostlySwampFrog", "Ghostly Swamp Frog", "Statue", "A frog under a sheet, haunting the swamp."},
		{"Common", "BonkShiba", "Bonk Shiba", "Statue", "Bonk. Go to meme jail."},
		{"Common", "SadViolinHamster", "Sad Violin Hamster", "Statue", "Big watery eyes and a tiny violin. Everyone cried."},
		{"Common", "ConfusedMathCat", "Confused Math Cat", "Statue", "Tried to understand the internet. Failed."},
		{"Uncommon", "JellyTimeBanana", "Jelly Time Banana", "Statue", "It's jelly time. A dancing banana from the early web."},
		{"Uncommon", "RainbowPastryCat", "Rainbow Pastry Cat", "Statue", "A cat made of frosted pastry, flying through space on a rainbow."},
		{"Uncommon", "WowShiba", "Much Wow Shiba", "Statue", "Such meme. Very classic. Wow."},
		{"Rare", "ProblemGrinCoin", "Problem Grin Coin", "Coin", "A coin with a grin. Problem?"},
		{"Rare", "MeLikeyTablet", "Me Likey Tablet", "Tablet", "A face that likes things a little too much."},
		{"Rare", "RageScreamTablet", "Rage Scream Tablet", "Tablet", "Carved in pure rage."},
		{"Epic", "ForeverAlone", "Forever Alone Monument", "Tablet", "A lonely stone face that every human secretly related to."},
		{"Epic", "BadLuckBryan", "Bad Luck Bryan Portrait", "Painting", "Took his driving test. Passed. Crashed into the building."},
		{"Legendary", "FrowningCat", "Frowning Cat Bust", "Statue", "Never smiled once. Earned millions anyway."},
		{"Legendary", "PunchMonkey", "Punch & His Plushie", "Statue", "A baby monkey who never let go of his stuffed orangutan."},
		{"Ultimate", "PhantomChonkyBunny", "Phantom Chonky Bunny", "Statue", "The biggest bunny ever came back as a ghost. Still big."},
		{"Beyond", "CemeterySpecter", "Cemetery Specter", "Statue", "A sheet ghost with a lantern, floating over the graves."},
		{"Immortal", "UndeadSanic", "Undead Sanic", "Statue", "Gotta go fast. Even after death."},
		{"Paradox", "GraveyardOssuary", "Graveyard Brainrot Ossuary", "Statue", "The bones of brainrot past, standing in their own grave."},
	}},
	-- WORLD 8: MULTIVERSE GLITCH VOID
	{Name = "Multiverse Glitch Void", Memes = {
		{"Basic", "CyberWowShiba", "Cyber Much Wow Shiba", "Statue", "Such circuits. Very upgrade. Wow."},
		{"Basic", "GlitchSwampFrog", "Glitch Swamp Frog", "Statue", "A swamp frog split into two glitching copies."},
		{"Common", "QuantumShockedRodent", "Quantum Shocked Yellow Rodent", "Statue", "Surprised in two universes at once."},
		{"Common", "VoidStonks", "Void Stonks Suit Head", "Statue", "Stonks, but in the void. Up and down at the same time."},
		{"Uncommon", "MultiverseSpaceInfant", "Multiverse Space Infant", "Statue", "Three green babies from three universes."},
		{"Uncommon", "BulletDodgeGuy", "Bullet-Dodge Code Guy", "Statue", "Bent over backward. The bullets missed."},
		{"Rare", "NeonSusBean", "Neon Sus Space Bean", "Statue", "Glows when it's sus. Always glowing."},
		{"Rare", "HoloJawlineChad", "Holo Jawline Chad", "Statue", "The jawline as a hologram. Still sharper than you."},
		{"Epic", "CosmicShake", "Cosmic Purple Birthday Shake", "Relic", "A whole galaxy in a birthday milkshake."},
		{"Epic", "SpacePolkaCow", "Space Polka Cow", "Statue", "The polka cow, spinning on its own tiny planet."},
		{"Legendary", "InterdimensionalChillDude", "Interdimensional Chill Dude", "Statue", "Stepped through a portal. Still chill."},
		{"Legendary", "CyberSingingThrone", "Cyber Singing Throne", "Statue", "A chrome singing toilet with LED eyes."},
		{"Universal", "UniversalSanic", "Universal Sanic", "Statue", "A hedgehog made of stars. Gotta go fast across the universe."},
		{"Exponential", "ExponentialOgre", "Exponential Swamp Ogre", "Statue", "An ogre with an ogre in its mouth, with an ogre in its mouth..."},
		{"Miraculous", "MiraculousGnome", "Miraculous Garden Gnome", "Statue", "You've been gnomed. Miraculously."},
		{"Apex", "ApexWowShiba", "Apex Much Wow Shiba", "Statue", "The shiba at the top of the world. Very summit."},
		{"Gilded", "GoldenSwampFrog", "Golden Swamp Frog", "Statue", "A swamp frog cast in solid gold."},
		{"Toorng", "ToorngEntity", "Toorng Void Entity", "Statue", "A dark sphere covered in eyes. Nobody knows what Toorng means."},
		{"Roller", "HighRollerBrainrot", "High Roller Brainrot", "Statue", "The brainrot crew bet everything on double six."},
		{"Immeasupreme", "ImmeasupremeOverlord", "Immeasupreme Overlord", "Statue", "The overlord of all memes, on a throne made of memes."},
	}},
	-- WORLD 9: QUANTUM DIMENSION
	{Name = "Quantum Dimension", Memes = {
		{"Basic", "QuantumDatFrog", "Quantum Here Come Dat Frog", "Statue", "O shit waddup. A frog on a unicycle, in superposition."},
		{"Basic", "SubatomicSwampFrog", "Subatomic Swamp Frog", "Statue", "A frog so small it's the center of an atom."},
		{"Basic", "ParticleWowShiba", "Particle Much Wow Shiba", "Statue", "Such particles. Very small. Wow."},
		{"Common", "AntimatterEchidna", "Antimatter Red Echidna", "Statue", "Knows the anti-way."},
		{"Common", "StringTheoryBunny", "String Theory Chonky Bunny", "Statue", "A big bunny vibrating in eleven dimensions."},
		{"Common", "WarpSpeedStonks", "Warp Speed Stonks Head", "Statue", "Stonks at warp speed."},
		{"Uncommon", "ParallelJawlineChad", "Parallel Jawline Chad", "Statue", "Two jawlines from two universes, back to back."},
		{"Uncommon", "RealityWarpedSponge", "Reality-Warped Porous Sponge", "Statue", "Heading out so fast he twisted reality."},
		{"Uncommon", "TimeFoldPanels", "Time Fold Nah-Yeah Panels", "Tablet", "Nah. Yeah. Folded through time."},
		{"Rare", "DarkMatterHippo", "Dark Matter Baby Hippo", "Statue", "A tiny hippo made of dark matter. Still bites."},
		{"Rare", "RomanEmpireBust", "Roman Empire Bust", "Statue", "How often do you think about the Roman Empire? Every day."},
		{"Rare", "HypercubeChillDude", "Hypercube Chill Dude", "Statue", "Chilling in four dimensions."},
		{"Epic", "ZeroPointThrone", "Zero Point Singing Throne", "Statue", "A crystal singing toilet that floats on zero-point energy."},
		{"Epic", "TesseractShake", "Tesseract Birthday Shake", "Relic", "A birthday shake inside a four-dimensional cube."},
		{"Legendary", "SingularityGrinCoin", "Singularity Grin Coin", "Coin", "The grin at the center of a black hole."},
		{"Legendary", "EventHorizonShiba", "Event Horizon Shiba", "Statue", "The shiba whose tail fell into a black hole."},
		{"Impossible", "NeverGonnaStair", "Never-Gonna Impossible Stair", "Statue", "Never gonna give up dancing on a staircase that never ends."},
		{"Quantum", "QuantumBrainrotGod", "Quantum Brainrot God", "Statue", "The six-armed god of all brainrot."},
		{"Transcendent", "MemeMatrix", "Transcendent Meme Matrix", "Relic", "Every famous meme, suspended inside one crystal."},
		{"???", "OriginalShiba", "The Original Shiba", "Statue", "The good girl who started it all. Forever in our museum."},
	}},
}

return MemeList
]=])
install(game:GetService("ReplicatedStorage"), "PickaxeModels", "ModuleScript", [=[
-- PickaxeModels (ModuleScript in ReplicatedStorage)
-- Builds every digging tool as a blocky voxel pickaxe: a head made of little cubes that arc
-- out to both sides (two-tone rows, pixel shading), a diamond socket with a glowing gem in the
-- middle, a dark handle with diamond gem nodes, an optional diamond cage around a floating
-- gem, a wrapped grip and a gem pommel.
--
-- Every pickaxe is unique: its own colors and a head shape
--   Crescent  classic curved pick          Wide    long, flat, three rows deep
--   Spiked    crescent with spikes         Crystal glassy shards over a glowing core
--   Hammer    a pick on one side, a chunky hammer on the other
-- and it gets fancier with its Power (tier 1-9): bigger, glowing gems, more gem nodes, the
-- cage, sparkling particles, and orbiting cubes (spun by ShovelClient / ShovelSpinner through
-- the OrbitCenter / OrbitSpeed attributes).
--
-- Tool space: the handle runs along Z, the head is at -Z, the grip end at +Z; +Y is the
-- direction the pick's arms point (the swing plane). Returns function(def) -> Tool.

local SCALE = 0.7
-- the crystal-tech look every pickaxe shares: cyan neon cutting edges, dark handles with a
-- glowing inlay, floating crystals and a spark trail off the tips
local NEON_EDGE = Color3.fromRGB(90, 235, 255)
local DARK_HANDLE = Color3.fromRGB(22, 22, 32)

local function rgb(r, g, b)
	return Color3.fromRGB(r, g, b)
end

---------------------------------------------------------------------
-- LOOKS: World 1's pickaxes by id (ids are the old save ids, so nobody loses a tool)
-- Main/Edge = the two rows of the head, Frame = sockets, Gem = gems, Handle, Wrap = grip
---------------------------------------------------------------------
local LOOKS = {
	RustyShovel = {Head = "Crescent", Main = rgb(150, 96, 62), Edge = rgb(112, 70, 46), Frame = rgb(120, 110, 104), Gem = rgb(255, 150, 70), Handle = rgb(84, 58, 40), Wrap = rgb(150, 150, 156)},
	PlasticShovel = {Head = "Wide", Main = rgb(150, 156, 160), Edge = rgb(104, 110, 116), Frame = rgb(132, 136, 142), Gem = rgb(235, 240, 250), Handle = rgb(70, 52, 40), Wrap = rgb(196, 110, 60)},
	GardenSpade = {Head = "Bone", Main = rgb(236, 228, 206), Edge = rgb(196, 184, 160), Frame = rgb(120, 104, 90), Gem = rgb(120, 255, 170), Handle = rgb(60, 42, 34), Wrap = rgb(150, 60, 50)},
	IronShovel = {Head = "Spiked", Main = rgb(196, 200, 210), Edge = rgb(140, 146, 160), Frame = rgb(170, 174, 184), Gem = rgb(255, 70, 90), Handle = rgb(48, 40, 38), Wrap = rgb(150, 40, 50)},
	SteelSpade = {Head = "Drill", Main = rgb(150, 160, 156), Edge = rgb(110, 200, 60), Frame = rgb(150, 160, 156), Gem = rgb(60, 255, 120), Handle = rgb(56, 36, 36), Wrap = rgb(214, 120, 80)},
	GoldenShovel = {Head = "Hammer", Main = rgb(255, 208, 72), Edge = rgb(226, 158, 40), Frame = rgb(255, 224, 140), Gem = rgb(255, 60, 110), Handle = rgb(60, 40, 30), Wrap = rgb(150, 30, 50)},
	GamerShovel = {Head = "Crystal", Main = rgb(110, 230, 255), Edge = rgb(180, 246, 255), Frame = rgb(170, 240, 255), Gem = rgb(90, 220, 255), Handle = rgb(40, 44, 64), Wrap = rgb(70, 80, 110)},
	TectonicAuger = {Head = "Plasma", Main = rgb(64, 62, 74), Edge = rgb(255, 120, 40), Frame = rgb(90, 88, 100), Gem = rgb(255, 110, 60), Handle = rgb(30, 28, 34), Wrap = rgb(255, 120, 40)},
	SingularitySpade = {Head = "Quantum", Main = rgb(58, 34, 96), Edge = rgb(190, 120, 255), Frame = rgb(90, 70, 140), Gem = rgb(235, 220, 255), Handle = rgb(20, 16, 30), Wrap = rgb(150, 90, 255)},
}
-- worlds 2-9: head shape per tier, colors from the world's theme
-- the silhouette changes completely as you go up: pick -> wide pick -> bone excavator ->
-- mechanical drill -> crystal pick -> plasma laser pick -> quantum anti-gravity digger
local WORLD_HEADS = {"Crescent", "Wide", "Bone", "Drill", "Crystal", "Plasma", "Quantum"}

local function lookFor(def)
	if LOOKS[def.Id] then return LOOKS[def.Id] end
	local look = def.Look
	if look and look.Colors then
		local c = look.Colors
		return {
			Head = look.Head or WORLD_HEADS[look.Tier] or "Crescent",
			Main = c.Main, Edge = look.Tier % 2 == 0 and c.Accent or c.Second,
			Frame = c.Second:Lerp(rgb(170, 170, 180), 0.4), Gem = c.Glow,
			Handle = c.Dark:Lerp(rgb(30, 28, 36), 0.4), Wrap = c.Accent,
		}
	end
	return LOOKS.RustyShovel
end

---------------------------------------------------------------------
-- BUILDING BLOCKS
---------------------------------------------------------------------
local function newPart(tool, name, size, cf, color, material, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	if shape then p.Shape = shape end
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Massless = true
	p.CastShadow = p.Material ~= Enum.Material.Neon
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = tool
	return p
end

-- pixel shading: a voxel is a touch lighter or darker than its neighbours
local function shade(color, i)
	local k = ({0, 0.1, -0.1, 0.05})[i % 4 + 1]
	if k > 0 then return color:Lerp(Color3.new(1, 1, 1), k) end
	return color:Lerp(Color3.new(0, 0, 0), -k)
end

local DIAMOND = CFrame.Angles(math.rad(45), 0, 0) -- a cube seen along X becomes a diamond

-- particle trails by tier (off the tips of the head)
local TRAILS = {
	Dust = {Name = "Dust", Colors = {rgb(255, 240, 210), rgb(170, 130, 90)}, Rate = 4, Light = 0.2, Size = 0.18, EndSize = 0.3,
		Lifetime = NumberRange.new(0.3, 0.5), Speed = NumberRange.new(0.2, 0.6)},
	Ice = {Name = "Ice", Colors = {Color3.new(1, 1, 1), rgb(170, 235, 255), rgb(90, 170, 255)}, Rate = 12, Light = 0.8, Size = 0.2, EndSize = 0.02,
		Lifetime = NumberRange.new(0.35, 0.6), Speed = NumberRange.new(0.5, 1.5), Acceleration = Vector3.new(0, -10, 0), RotSpeed = NumberRange.new(-300, 300)},
	Glitch = {Name = "Glitch", Colors = {rgb(255, 60, 200), rgb(60, 255, 230), rgb(140, 255, 90)}, Rate = 16, Light = 1, Size = 0.22, EndSize = 0.22,
		Lifetime = NumberRange.new(0.08, 0.2), Speed = NumberRange.new(2, 6)},
	Sparks = {Name = "Sparks", Colors = {Color3.new(1, 1, 1), NEON_EDGE}, Rate = 6, Light = 0.85, Size = 0.12,
		Lifetime = NumberRange.new(0.25, 0.45), Speed = NumberRange.new(0.2, 0.8)},
	Electric = {Name = "Electric", Colors = {Color3.new(1, 1, 1), rgb(140, 220, 255), rgb(60, 120, 255)}, Rate = 10, Light = 1, Size = 0.1,
		Lifetime = NumberRange.new(0.12, 0.25), Speed = NumberRange.new(1.5, 3.5)},
	Fire = {Name = "Fire", Colors = {rgb(255, 240, 150), rgb(255, 150, 40), rgb(220, 40, 20)}, Rate = 14, Light = 0.9, Size = 0.28, EndSize = 0.05,
		Lifetime = NumberRange.new(0.3, 0.55), Speed = NumberRange.new(0.5, 1.5), Acceleration = Vector3.new(0, 6, 0), RotSpeed = NumberRange.new(-120, 120)},
	Galaxy = {Name = "Galaxy", Colors = {rgb(255, 140, 230), rgb(160, 90, 255), rgb(70, 110, 255)}, Rate = 14, Light = 0.9, Size = 0.24, EndSize = 0.08,
		Lifetime = NumberRange.new(0.6, 1), Speed = NumberRange.new(0.2, 0.6), RotSpeed = NumberRange.new(-60, 60)},
}

-- a diamond frame with a glowing gem poking through both faces
local function gemNode(tool, name, z, size, look, glowing)
	local frame = newPart(tool, name, Vector3.new(size * 0.8, size, size), CFrame.new(0, 0, z) * DIAMOND, look.Frame)
	newPart(tool, name .. "Gem", Vector3.new(size * 0.96, size * 0.46, size * 0.46), CFrame.new(0, 0, z) * DIAMOND,
		look.Gem, glowing and Enum.Material.Neon or Enum.Material.Glass)
	return frame
end

local function bar(tool, name, a, b, thickness, color, material)
	local length = (b - a).Magnitude
	-- a CFrame whose Z axis runs from a to b (built from its axes, so it's exact in any direction)
	local z = (a - b).Unit
	local helper = math.abs(z.X) < 0.9 and Vector3.xAxis or Vector3.yAxis
	local y = z:Cross(helper).Unit
	local x = y:Cross(z)
	return newPart(tool, name, Vector3.new(thickness, thickness, length), CFrame.fromMatrix((a + b) / 2, x, y, z), color, material)
end

-- one arm of the head: voxels along an arc that starts at the socket and bends toward the grip
-- side = +1 / -1 (which way along Y), rows = how many layers deep
local function arm(tool, H, side, look, opts)
	local R, reach, count, rows = opts.Radius, opts.Reach, opts.Count, opts.Rows
	local center = H + Vector3.new(0, 0, R)
	local parts = {}
	for i = 1, count do
		local t = (i - 0.3) / count
		local phi = 0.22 + t * reach
		local size = opts.Size * (1 - t * 0.5)
		local radial = Vector3.new(0, side * math.sin(phi), -math.cos(phi))
		local rot = CFrame.Angles(side * phi, 0, 0)
		for row = 0, rows - 1 do
			local r = R + (row - (rows - 1) / 2) * size * 0.85
			local pos = center + radial * r
			local color = (row == rows - 1) and look.Edge or look.Main
			local material = opts.Material or Enum.Material.SmoothPlastic
			local voxel = newPart(tool, row == rows - 1 and "HeadEdge" or "HeadVoxel", Vector3.new(size * 0.9, size, size), CFrame.new(pos) * rot, shade(color, i + row), material)
			if opts.Glass then
				voxel.Transparency = 0.15
				voxel.Reflectance = 0.2
			end
			table.insert(parts, voxel)
		end
		-- cyan neon cutting edge along the outside of the arm
		local outer = R + ((rows - 1) / 2) * size * 0.85
		newPart(tool, "BladeEdge", Vector3.new(size * 0.7, size * 0.9, 0.09), CFrame.new(center + radial * (outer + size / 2 + 0.02)) * rot, NEON_EDGE, Enum.Material.Neon)
		-- jagged energy blade: neon shards along the edge, alternating long and short
		if opts.Jagged then
			local len = (i % 2 == 0) and size * 1.1 or size * 0.55
			newPart(tool, "EnergySpike", Vector3.new(size * 0.22, size * 0.22, len),
				CFrame.new(center + radial * (outer + size / 2 + len / 2 - 0.05)) * rot * CFrame.Angles(0, 0, math.rad(45)), opts.Jagged, Enum.Material.Neon)
		end
		-- spikes sticking out of the outer row
		if opts.Spikes and i % 2 == 0 then
			local pos = center + radial * (R + size * 1.2)
			newPart(tool, "HeadSpike", Vector3.new(size * 0.5, size * 0.5, size * 0.8), CFrame.new(pos) * rot, look.Edge)
		end
	end
	-- the pointed tip
	local phiEnd = 0.22 + reach + 0.12
	local tipPos = center + Vector3.new(0, side * math.sin(phiEnd), -math.cos(phiEnd)) * R
	local tip = newPart(tool, "HeadTip", Vector3.new(opts.Size * 0.36, opts.Size * 0.4, opts.Size * 0.4), CFrame.new(tipPos) * CFrame.Angles(side * phiEnd, 0, 0) * DIAMOND, NEON_EDGE, Enum.Material.Neon)
	return parts, tip
end

-- a point on the arc a pick arm follows (same curve as arm() uses)
local function arcPoint(H, side, R, phi)
	return H + Vector3.new(0, 0, R) + Vector3.new(0, side * math.sin(phi), -math.cos(phi)) * R
end

-- a chunky hammer block made of voxels (the other side of a "Hammer" head)
local function hammer(tool, H, side, look)
	local v = 0.5
	for y = 1, 3 do
		for z = -1, 1 do
			local pos = H + Vector3.new(0, side * (0.45 + y * v * 0.95), z * v * 0.95)
			local edge = y == 3 or math.abs(z) == 1
			newPart(tool, "HammerVoxel", Vector3.new(v * 1.7, v, v), CFrame.new(pos), shade(edge and look.Edge or look.Main, y + z))
		end
	end
	newPart(tool, "HammerFace", Vector3.new(v * 1.8, 0.12, v * 3), CFrame.new(H + Vector3.new(0, side * (0.45 + 3.55 * v), 0)), look.Frame, Enum.Material.Metal)
end

---------------------------------------------------------------------
-- BUILD A PICKAXE TOOL
---------------------------------------------------------------------
-- a crystal shard: a stretched diamond, glassy on the outside with a neon heart
local function crystal(tool, name, cf, length, color)
	local shell = newPart(tool, name, Vector3.new(length * 0.42, length * 0.42, length), cf * CFrame.Angles(0, 0, math.rad(45)), color:Lerp(Color3.new(1, 1, 1), 0.3), Enum.Material.Glass)
	shell.Transparency = 0.3
	shell.Reflectance = 0.25
	local core = newPart(tool, name .. "Core", Vector3.new(length * 0.2, length * 0.2, length * 0.8), cf * CFrame.Angles(0, 0, math.rad(45)), color, Enum.Material.Neon)
	return shell, core
end

return function(def)
	local look = table.clone(lookFor(def))
	-- dark handles everywhere (a hint of the pickaxe's own color stays in them)
	look.Handle = look.Handle:Lerp(DARK_HANDLE, 0.6)
	local tier = math.clamp(def.Power or 1, 1, 12)
	local growth = 1 + (tier - 1) * 0.035
	local glowing = tier >= 2

	local tool = Instance.new("Tool")
	tool.Name = def.Name
	tool.ToolTip = def.Name
	tool.CanBeDropped = false
	tool.RequiresHandle = true
	tool:SetAttribute("ShovelId", def.Id)

	-- invisible handle the hand holds; everything else is welded to it
	local handle = newPart(tool, "Handle", Vector3.new(0.3, 0.3, 4.6), CFrame.new(), look.Handle)
	handle.Transparency = 1

	-- HANDLE: a square dark shaft from the head down to the pommel
	local HEAD_Z, END_Z = -2.6, 2.2
	local RIGHT_Z, LEFT_Z = 1.55, 0.55 -- where the hands hold it (right hand low, left hand above)
	newPart(tool, "Shaft", Vector3.new(0.26, 0.26, END_Z - HEAD_Z), CFrame.new(0, 0, (END_Z + HEAD_Z) / 2), look.Handle)
	-- glowing cyan inlay lines down both sides of the shaft (between the head and the grip)
	for _, sx in ipairs({-1, 1}) do
		newPart(tool, "ShaftGlow", Vector3.new(0.04, 0.08, 2.7), CFrame.new(sx * 0.135, 0, -0.95), NEON_EDGE, Enum.Material.Neon)
	end
	-- grip wrap: stacked cubes, alternating shades
	for i = 0, 4 do
		newPart(tool, "GripWrap", Vector3.new(0.34, 0.34, 0.24), CFrame.new(0, 0, 1.05 + i * 0.24), shade(look.Wrap, i))
	end
	for _, z in ipairs({0.88, 2.28 - 0.1}) do
		newPart(tool, "Collar", Vector3.new(0.4, 0.4, 0.14), CFrame.new(0, 0, z), look.Frame, Enum.Material.Metal)
	end
	gemNode(tool, "Pommel", END_Z + 0.25, 0.62, look, glowing)
	-- gem nodes up the handle (more on better pickaxes)
	local nodes = tier >= 7 and {-1.75, -0.1} or (tier >= 3 and {-1.6} or {})
	for _, z in ipairs(nodes) do
		gemNode(tool, "HandleNode", z, 0.5, look, glowing)
	end
	-- the diamond cage with a floating gem (tier 4+)
	if tier >= 4 then
		local top, bottom, mid, w = -1.35, -0.35, -0.85, 0.42
		local a, b2 = Vector3.new(0, 0, top), Vector3.new(0, 0, bottom)
		for _, s in ipairs({-1, 1}) do
			local side = Vector3.new(0, s * w, mid)
			bar(tool, "CageBar", a, side, 0.12, look.Handle)
			bar(tool, "CageBar", side, b2, 0.12, look.Handle)
		end
		newPart(tool, "CageGem", Vector3.new(0.3, 0.34, 0.34), CFrame.new(0, 0, mid) * DIAMOND, look.Gem, Enum.Material.Neon)
	end

	-- HEAD
	local tips = {}
	local H = Vector3.new(0, 0, HEAD_Z)
	local socket = newPart(tool, "Blade", Vector3.new(0.72, 1, 1), CFrame.new(H) * DIAMOND, look.Frame)
	local gem = newPart(tool, "HeadGem", Vector3.new(0.86, 0.5, 0.5), CFrame.new(H) * DIAMOND, look.Gem, glowing and Enum.Material.Neon or Enum.Material.Glass)
	newPart(tool, "Crown", Vector3.new(0.4, 0.42, 0.42), CFrame.new(H + Vector3.new(0, 0, -0.78)) * DIAMOND, look.Edge)
	local style = look.Head
	local jagged = tier >= 5 and (tier >= 8 and look.Gem or NEON_EDGE) or nil
	local arm = function(t, h, side, lk, opts)
		if lk.Frame and jagged then
			opts = table.clone(opts)
			opts.Jagged = jagged
		end
		local parts, tip = arm(t, h, side, lk, opts)
		if lk.Frame then -- not the glowing core inside a crystal head, or the second blade
			table.insert(tips, tip)
		end
		return parts, tip
	end
	if style == "Wide" then
		for _, s in ipairs({-1, 1}) do
			arm(tool, H, s, look, {Radius = 3.4, Reach = 0.62, Count = 8, Rows = 3, Size = 0.58})
		end
	elseif style == "Spiked" then
		for _, s in ipairs({-1, 1}) do
			arm(tool, H, s, look, {Radius = 2.3, Reach = 1.1, Count = 7, Rows = 2, Size = 0.66, Spikes = true})
		end
	elseif style == "Crystal" then
		for _, s in ipairs({-1, 1}) do
			arm(tool, H, s, look, {Radius = 2.4, Reach = 1.05, Count = 7, Rows = 3, Size = 0.6, Glass = true, Material = Enum.Material.Glass})
			-- glowing core running inside the glass
			arm(tool, H, s, {Main = look.Gem, Edge = look.Gem}, {Radius = 2.4, Reach = 0.95, Count = 6, Rows = 1, Size = 0.3, Material = Enum.Material.Neon})
		end
	elseif style == "Hammer" then
		arm(tool, H, 1, look, {Radius = 2.3, Reach = 1.15, Count = 7, Rows = 2, Size = 0.66})
		hammer(tool, H, -1, look)
	elseif style == "Bone" then
		-- BONE EXCAVATOR: each arm is a curved bone of knuckled segments ending in a claw,
		-- with a little skull holding it all on the shaft
		local R = 2.3
		for _, s in ipairs({-1, 1}) do
			local points = {}
			for k, phi in ipairs({0.28, 0.62, 0.96, 1.3}) do
				points[k] = arcPoint(H, s, R, phi)
			end
			for k = 1, 3 do
				bar(tool, "BoneShaft", points[k], points[k + 1], 0.38 - k * 0.03, shade(look.Main, k))
			end
			for k = 1, 4 do
				newPart(tool, "BoneKnuckle", Vector3.one * (0.62 - k * 0.05), CFrame.new(points[k]), look.Main, nil, Enum.PartType.Ball)
			end
			local dir = (points[4] - points[3]).Unit
			local clawPos = points[4] + dir * 0.4
			table.insert(tips, newPart(tool, "HeadTip", Vector3.new(0.26, 0.26, 0.9), CFrame.lookAt(clawPos, clawPos + dir), NEON_EDGE, Enum.Material.Neon))
		end
		local skull = newPart(tool, "Skull", Vector3.one * 1.15, CFrame.new(H + Vector3.new(0, 0, -0.15)), look.Main, nil, Enum.PartType.Ball)
		for _, sy in ipairs({-1, 1}) do
			for _, sx in ipairs({-1, 1}) do
				newPart(tool, "SkullEye", Vector3.one * 0.26, CFrame.new(skull.CFrame.Position + Vector3.new(sx * 0.5, sy * 0.2, -0.15)), look.Gem, Enum.Material.Neon, Enum.PartType.Ball)
			end
		end
	elseif style == "Drill" then
		-- MECHANICAL DRILL: a motor block with a spiralled drill bit sticking out of each side
		-- and a spinning turbine around the shaft
		newPart(tool, "DrillMotor", Vector3.new(0.95, 1.4, 1.4), CFrame.new(H), look.Frame, Enum.Material.Metal)
		newPart(tool, "MotorStripe", Vector3.new(1, 0.16, 1.44), CFrame.new(H + Vector3.new(0, 0.35, 0)), NEON_EDGE, Enum.Material.Neon)
		newPart(tool, "MotorStripe", Vector3.new(1, 0.16, 1.44), CFrame.new(H - Vector3.new(0, 0.35, 0)), NEON_EDGE, Enum.Material.Neon)
		for _, s in ipairs({-1, 1}) do
			for k = 0, 4 do
				local d = 1.15 - k * 0.2
				local seg = newPart(tool, "DrillBit", Vector3.new(0.44, d, d), CFrame.new(H + Vector3.new(0, s * (0.95 + k * 0.42), 0)) * CFrame.Angles(0, 0, math.rad(90)),
					shade(k % 2 == 0 and look.Main or look.Edge, k), Enum.Material.Metal)
				seg.Shape = Enum.PartType.Cylinder
				-- the spiral ridge winding around the bit
				for r = 0, 2 do
					local a = k * 1.3 + r * math.pi * 2 / 3
					newPart(tool, "DrillRidge", Vector3.new(0.12, 0.34, 0.12),
						CFrame.new(H + Vector3.new(math.cos(a) * d / 2, s * (0.95 + k * 0.42), math.sin(a) * d / 2)) * CFrame.Angles(0, -a, math.rad(30)), look.Edge, Enum.Material.Metal)
				end
			end
			table.insert(tips, newPart(tool, "HeadTip", Vector3.new(0.3, 0.3, 0.3), CFrame.new(H + Vector3.new(0, s * 3.1, 0)) * DIAMOND, NEON_EDGE, Enum.Material.Neon))
		end
		for i = 1, 6 do
			local a = i * math.pi / 3
			local blade = newPart(tool, "TurbineBlade", Vector3.new(0.12, 0.5, 0.2), CFrame.new(H + Vector3.new(math.cos(a) * 0.95, math.sin(a) * 0.95, 0.9)) * CFrame.Angles(0, 0, a),
				look.Edge, Enum.Material.Metal)
			blade:SetAttribute("OrbitCenter", H + Vector3.new(0, 0, 0.9))
			blade:SetAttribute("OrbitSpeed", 9)
		end
	elseif style == "Plasma" then
		-- PLASMA LASER PICK: dark emitter prongs firing a curved blade of glowing plasma
		for _, s in ipairs({-1, 1}) do
			arm(tool, H, s, {Main = look.Handle:Lerp(Color3.new(0, 0, 0), 0.3), Edge = look.Frame}, {Radius = 2.3, Reach = 0.35, Count = 3, Rows = 2, Size = 0.62, Material = Enum.Material.Metal})
			arm(tool, H, s, {Main = look.Gem, Edge = Color3.new(1, 1, 1), Frame = look.Gem}, {Radius = 2.35, Reach = 1.3, Count = 12, Rows = 1, Size = 0.42, Material = Enum.Material.Neon})
			for k = 1, 3 do
				local ring = newPart(tool, "PlasmaCoil", Vector3.new(0.3, 0.9 - k * 0.1, 0.9 - k * 0.1), CFrame.new(arcPoint(H, s, 2.35, 0.25 + k * 0.08)) * CFrame.Angles(s * (0.25 + k * 0.08), 0, math.rad(90)),
					NEON_EDGE, Enum.Material.Neon)
				ring.Shape = Enum.PartType.Cylinder
				ring.Transparency = 0.3
			end
		end
	elseif style == "Quantum" then
		-- QUANTUM ANTI-GRAVITY DIGGER: the head floats free of the shaft; a glowing core holds
		-- two glassy blades in place while halo rings and shards orbit around it
		local F = H + Vector3.new(0, 0, -0.45)
		newPart(tool, "QuantumCore", Vector3.one * 0.95, CFrame.new(F), look.Gem, Enum.Material.Neon, Enum.PartType.Ball)
		for _, s in ipairs({-1, 1}) do
			arm(tool, F, s, {Main = look.Main, Edge = look.Gem, Frame = look.Frame}, {Radius = 2.5, Reach = 1.2, Count = 7, Rows = 2, Size = 0.46, Material = Enum.Material.Glass, Glass = true})
		end
		for i = 1, 18 do
			local a = i / 18 * math.pi * 2
			local seg = newPart(tool, "QuantumHalo", Vector3.new(0.1, 0.4, 0.1), CFrame.new(F + Vector3.new(math.cos(a) * 1.35, math.sin(a) * 1.35, 0)) * CFrame.Angles(0, 0, a), NEON_EDGE, Enum.Material.Neon)
			seg:SetAttribute("OrbitCenter", F)
			seg:SetAttribute("OrbitSpeed", 2.4)
		end
		for i = 1, 5 do
			local a = i / 5 * math.pi * 2
			local shard = newPart(tool, "QuantumShard", Vector3.new(0.18, 0.18, 0.5), CFrame.new(F + Vector3.new(math.cos(a) * 0.9, math.sin(a) * 0.9, 0.9)) * CFrame.Angles(0.6, 0.4, a),
				look.Gem, Enum.Material.Neon)
			shard:SetAttribute("OrbitCenter", F + Vector3.new(0, 0, 0.9))
			shard:SetAttribute("OrbitSpeed", -3.5)
		end
	else -- Crescent
		for _, s in ipairs({-1, 1}) do
			arm(tool, H, s, look, {Radius = 2.3, Reach = 1.15, Count = 7, Rows = tier >= 5 and 3 or 2, Size = 0.66})
		end
	end
	-- side plates that hold the head on the shaft
	for _, s in ipairs({-1, 1}) do
		newPart(tool, "HeadBracket", Vector3.new(0.5, 0.3, 0.7), CFrame.new(H + Vector3.new(0, s * 0.42, 0.55)), look.Handle)
	end

	-- DUAL BLADE (tier 7+): a second, thinner blade of pure energy on each side of the head
	local classicHead = style ~= "Bone" and style ~= "Drill" and style ~= "Plasma" and style ~= "Quantum"
	if tier >= 7 and classicHead then
		for _, sx in ipairs({-1, 1}) do
			local offset = H + Vector3.new(sx * 0.5, 0, 0.1)
			for _, s in ipairs({-1, 1}) do
				arm(tool, offset, s, {Main = look.Gem, Edge = NEON_EDGE}, {Radius = 2.1, Reach = 1, Count = 6, Rows = 1, Size = 0.32, Material = Enum.Material.Neon})
			end
		end
	end

	-- ROTATING CORE (tier 3+): glowing bits circling the head's gem, faster on better pickaxes
	if tier >= 3 then
		local n = tier >= 6 and 6 or 4
		for i = 1, n do
			local a = math.pi * 2 * i / n
			local bit = newPart(tool, "CoreBit", Vector3.new(0.18, 0.18, 0.18), CFrame.new(H + Vector3.new(math.cos(a) * 0.95, math.sin(a) * 0.95, 0)) * DIAMOND,
				i % 2 == 0 and look.Gem or NEON_EDGE, Enum.Material.Neon)
			bit:SetAttribute("OrbitCenter", H)
			bit:SetAttribute("OrbitSpeed", 2 + tier * 0.4)
		end
		-- a spinning ring around the socket
		local ringCount = 10
		for i = 1, ringCount do
			local a = math.pi * 2 * i / ringCount
			local seg = newPart(tool, "CoreRing", Vector3.new(0.08, 0.34, 0.08), CFrame.new(H + Vector3.new(math.cos(a) * 1.2, math.sin(a) * 1.2, 0)) * CFrame.Angles(0, 0, a),
				NEON_EDGE, Enum.Material.Neon)
			seg:SetAttribute("OrbitCenter", H)
			seg:SetAttribute("OrbitSpeed", -(1.2 + tier * 0.2))
		end
	end

	-- ORBITING CUBES around the handle below the head (tier 6+), spun by the client
	if tier >= 6 then
		local center = Vector3.new(0, 0, -1.9)
		local n = tier - 3
		for i = 1, n do
			local a = math.pi * 2 * i / n
			local cube = newPart(tool, "OrbitCube", Vector3.new(0.2, 0.2, 0.2), CFrame.new(center + Vector3.new(math.cos(a) * 0.62, math.sin(a) * 0.62, 0)) * CFrame.Angles(0.6, 0.6, 0), look.Gem, Enum.Material.Neon)
			cube:SetAttribute("OrbitCenter", center)
			cube:SetAttribute("OrbitSpeed", 2.6)
		end
	end

	-- FLOATING CRYSTALS: glassy shards hovering around the shaft under the head, orbiting it
	-- (every pickaxe has one; better ones have up to four)
	do
		local center = Vector3.new(0, 0, -1.15)
		local n = math.clamp(1 + math.floor(tier / 3), 1, 4)
		for i = 1, n do
			local a = math.pi * 2 * i / n + 0.4
			local pos = center + Vector3.new(math.cos(a) * 0.95, math.sin(a) * 0.95, 0)
			local shell, core = crystal(tool, "FloatCrystal", CFrame.new(pos) * CFrame.Angles(0.35, 0.2, a), 0.55 + tier * 0.02, i % 2 == 0 and look.Gem or NEON_EDGE)
			for _, p in ipairs({shell, core}) do
				p:SetAttribute("OrbitCenter", center)
				p:SetAttribute("OrbitSpeed", 1.4)
			end
		end
	end

	-- SPARK TRAIL: cyan sparks stream off both tips; they're left behind in the air while the
	-- pickaxe moves, so every swing draws a glittering arc (denser on better pickaxes)
	-- the trail's style depends on the tier: sparks -> electricity -> fire -> galaxy
	-- trail (and impact) style by tier: dust -> sparks -> electricity -> ice shards -> fire -> galaxy -> glitch
	local TRAIL_BY_TIER = {"Dust", "Dust", "Sparks", "Sparks", "Electric", "Ice", "Fire", "Galaxy", "Glitch"}
	local trail = TRAILS[TRAIL_BY_TIER[math.clamp(tier, 1, #TRAIL_BY_TIER)]]
	tool:SetAttribute("TrailStyle", trail.Name)
	tool:SetAttribute("TrailColorA", trail.Colors[1])
	tool:SetAttribute("TrailColorB", trail.Colors[#trail.Colors])
	for _, tip in ipairs(tips) do
		local sparks = Instance.new("ParticleEmitter")
		sparks.Name = "TipSparks"
		sparks.Rate = trail.Rate + tier * 2
		sparks.LightEmission = trail.Light
		local keys = {}
		for k, c in ipairs(trail.Colors) do
			table.insert(keys, ColorSequenceKeypoint.new((k - 1) / (#trail.Colors - 1), c))
		end
		sparks.Color = ColorSequence.new(keys)
		sparks.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, trail.Size), NumberSequenceKeypoint.new(1, trail.EndSize or 0)})
		sparks.Transparency = NumberSequence.new(0, 1)
		sparks.Lifetime = trail.Lifetime
		sparks.Speed = trail.Speed
		sparks.SpreadAngle = Vector2.new(180, 180)
		sparks.Acceleration = trail.Acceleration or Vector3.zero
		sparks.RotSpeed = trail.RotSpeed or NumberRange.new(0)
		sparks.Drag = 3
		sparks.Parent = tip
		if trail.Name == "Electric" then
			-- crackling: little bright zaps flicker around the tip
			local zap = sparks:Clone()
			zap.Name = "TipZaps"
			zap.Rate = 12
			zap.Size = NumberSequence.new(0.22, 0.05)
			zap.Lifetime = NumberRange.new(0.05, 0.12)
			zap.Speed = NumberRange.new(4, 8)
			zap.Parent = tip
		elseif trail.Name == "Glitch" then
			-- square pixels that blink in and out
			sparks.Shape = Enum.ParticleEmitterShape.Box
			sparks.Rotation = NumberRange.new(0)
			sparks.RotSpeed = NumberRange.new(0)
			sparks.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 0.9), NumberSequenceKeypoint.new(0.6, 0), NumberSequenceKeypoint.new(1, 1)})
		elseif trail.Name == "Galaxy" then
			-- tiny white stars twinkling in the purple dust
			local stars = sparks:Clone()
			stars.Name = "TipStars"
			stars.Rate = 8
			stars.Color = ColorSequence.new(Color3.new(1, 1, 1))
			stars.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 0.14), NumberSequenceKeypoint.new(1, 0)})
			stars.Lifetime = NumberRange.new(0.6, 1)
			stars.Parent = tip
		end
	end

	-- VFX: gem light and sparkles that grow with the tier
	if glowing then
		local light = Instance.new("PointLight")
		light.Color = look.Gem
		light.Range = 4 + tier
		light.Brightness = 0.35 + tier * 0.1
		light.Parent = gem
		local sparkle = Instance.new("ParticleEmitter")
		sparkle.Name = "GemSparkle"
		sparkle.Rate = tier * 2.5
		sparkle.LightEmission = math.min(0.2 + tier * 0.09, 1)
		sparkle.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.06 + tier * 0.025), NumberSequenceKeypoint.new(1, 0)})
		sparkle.Lifetime = NumberRange.new(0.4, 0.8 + tier * 0.05)
		sparkle.Speed = NumberRange.new(0.3, 0.8 + tier * 0.1)
		sparkle.SpreadAngle = Vector2.new(180, 180)
		sparkle.Color = ColorSequence.new(look.Gem:Lerp(Color3.new(1, 1, 1), 0.4), look.Gem)
		sparkle.Transparency = NumberSequence.new(0.1, 1)
		sparkle.Parent = socket
	end

	-- SIZE: better pickaxes are a little bigger, then everything is scaled to character size
	local s = SCALE * growth
	for _, part in ipairs(tool:GetChildren()) do
		if part:IsA("BasePart") then
			local rotation = part.CFrame.Rotation
			part.Size = part.Size * s
			part.CFrame = CFrame.new(part.Position * s) * rotation
			local center = part:GetAttribute("OrbitCenter")
			if center then part:SetAttribute("OrbitCenter", center * s) end
		end
	end
	for _, emitter in ipairs(tool:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			local keys = {}
			for _, key in ipairs(emitter.Size.Keypoints) do
				table.insert(keys, NumberSequenceKeypoint.new(key.Time, key.Value * s, key.Envelope * s))
			end
			emitter.Size = NumberSequence.new(keys)
		end
	end

	-- how Roblox holds it if the two-handed pose can't run (e.g. R6 bodies)
	tool.Grip = CFrame.new(0, 0, RIGHT_Z * s) * CFrame.Angles(math.rad(-30), 0, 0)
	-- ShovelClient's two-handed pose: where each hand grips the handle (along Z)
	tool:SetAttribute("RightHoldZ", RIGHT_Z * s)
	tool:SetAttribute("LeftHoldZ", LEFT_Z * s)
	tool:SetAttribute("TopHoldZ", RIGHT_Z * s)
	tool:SetAttribute("LowHoldZ", LEFT_Z * s)

	for _, part in ipairs(tool:GetChildren()) do
		if part:IsA("BasePart") and part ~= handle then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = handle
			weld.Part1 = part
			weld.Parent = handle
		end
	end
	return tool
end
]=])
install(game:GetService("ReplicatedStorage"), "PortalMeshes", "ModuleScript", [=[
-- PortalMeshes (ModuleScript in ReplicatedStorage)
-- Written by tools/blender/portals.py: the Blender portal pieces (World Gate and alien portal).
-- Studio's File > Import 3D of assets/models/PortalMeshes.fbx + the installer put them in
-- ReplicatedStorage > PortalModels. Data = each piece's size and where its center sits from
-- the portal's center (front = -Z). Until they're imported the portals use their old parts.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PortalMeshes = {}

PortalMeshes.Data = {
	GatePortalFrame = {Size = Vector3.new(19.134, 19.120, 3.960), Center = Vector3.new(0.000, 0.010, -0.030), Textured = true},
	GatePortalGlow = {Size = Vector3.new(17.500, 17.500, 3.068), Center = Vector3.new(0.000, 0.000, -0.406), Textured = false},
	GateHorizon = {Size = Vector3.new(13.900, 13.900, 1.665), Center = Vector3.new(0.000, 0.000, 0.282), Textured = false},
	GateVortexA = {Size = Vector3.new(12.458, 13.042, 1.561), Center = Vector3.new(0.621, -0.000, 0.096), Textured = false},
	GateVortexB = {Size = Vector3.new(10.662, 11.365, 1.563), Center = Vector3.new(1.219, 0.000, -0.018), Textured = false},
	AlienPortalRim = {Size = Vector3.new(7.028, 10.995, 1.262), Center = Vector3.new(0.049, -0.681, -0.003), Textured = false},
	AlienPortalFunnel = {Size = Vector3.new(5.600, 8.300, 1.830), Center = Vector3.new(0.000, 0.000, 0.565), Textured = false},
	AlienPortalSwirl = {Size = Vector3.new(5.400, 5.400, 1.531), Center = Vector3.new(0.000, 0.000, 0.293), Textured = false},
}

local function source(name)
	local folder = ReplicatedStorage:FindFirstChild("PortalModels")
	local item = folder and folder:FindFirstChild(name)
	if item and not item:IsA("MeshPart") then item = item:FindFirstChildWhichIsA("MeshPart", true) end
	return item
end

-- true when every named piece has been imported
function PortalMeshes.has(...)
	for _, name in ipairs({...}) do
		if not PortalMeshes.Data[name] or not source(name) then return false end
	end
	return true
end

-- a copy of the piece placed around the portal center (a CFrame); props = Color, Material, ...
-- scale shrinks it (and its offset) for pop-open animations
function PortalMeshes.place(parent, name, center, props, scale)
	local data, src = PortalMeshes.Data[name], source(name)
	if not data or not src then return nil end
	scale = scale or 1
	local part = src:Clone()
	part.Name = name
	for _, child in ipairs(part:GetChildren()) do
		if not data.Textured and child:IsA("SurfaceAppearance") then child:Destroy() end
	end
	if not data.Textured then pcall(function() part.TextureID = "" end) end
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = data.Textured
	part.Size = data.Size * scale
	part.CFrame = center * CFrame.new(data.Center * scale)
	for key, value in pairs(props or {}) do part[key] = value end
	if not data.Textured then part:SetAttribute("KeepGlow", true) end -- Architecture.calm leaves it glowing
	part.Parent = parent
	return part
end

return PortalMeshes
]=])
install(game:GetService("ReplicatedStorage"), "UIBus", "ModuleScript", [=[
-- UIBus (ModuleScript in ReplicatedStorage)
-- Lets one LocalScript ask another to open a window (every LocalScript on a player's screen
-- gets the same copy of this module). For example, the HUD's buttons do UIBus.Fire("Shop")
-- and the pickaxe shop listens with UIBus.On("Shop", function() ... end).
-- Names used: Shop, Museum, Teleport, Rebirth, Settings, Inventory, ToggleSound

local UIBus = {}
local events = {}

local function event(name)
	events[name] = events[name] or Instance.new("BindableEvent")
	return events[name]
end

function UIBus.Fire(name, ...)
	event(name):Fire(...)
end

function UIBus.On(name, callback)
	return event(name).Event:Connect(callback)
end

return UIBus
]=])
install(game:GetService("ReplicatedStorage"), "UIIconImages", "ModuleScript", [=[
-- UIIconImages (ModuleScript in ReplicatedStorage)
-- Icons that are shown as rendered pictures instead of live 3D models: glossy renders with
-- a thick outline (tools/blender/ui_icon_renders.py -> assets/ui/rendered/<Name>.png),
-- uploaded to Roblox. UIKit.icon uses the picture when an icon is listed here.
return {
	Bag = "rbxassetid://122516421367525",
	Cash = "rbxassetid://126571281777122",
	Gem = "rbxassetid://111005589199418",
	Rebirth = "rbxassetid://84292147523245",
	Settings = "rbxassetid://123962860909979",
}
]=])
install(game:GetService("ReplicatedStorage"), "UIIconList", "ModuleScript", [=[
-- UIIconList (ModuleScript in ReplicatedStorage)
-- Written by tools/blender/ui_icons.py: the names of the 3D UI icons in assets/models/UIIcons.fbx.
-- Import that file once (File > Import 3D) and run the installer; UIKit.icon shows them.

return {
	"Shop",
	"Bag",
	"Museum",
	"Rebirth",
	"World",
	"Settings",
	"Gem",
	"Cash",
	"Income",
	"SoundOn",
	"SoundOff",
	"Music",
	"Bell",
	"Lock",
	"Luck",
	"Pickaxe",
	"Star",
	"Sparkle",
	"Heart",
	"Pin",
	"Alien",
	"Fire",
	"Skull",
	"Disk",
	"Volcano",
	"Candy",
	"Ghost",
	"Bubble",
	"Ice",
	"Snowflake",
	"Coin",
	"Warning",
	"Boom",
	"Party",
	"Picture",
	"Hole",
	"Elevator",
	"Crown",
	"FaceHappy",
	"FaceLaugh",
	"FaceLove",
	"FaceWow",
	"FaceCool",
	"FaceMeh",
	"FaceSick",
}
]=])
install(game:GetService("ReplicatedStorage"), "UIKit", "ModuleScript", [=[
-- UIKit (ModuleScript in ReplicatedStorage)
-- One chunky simulator-style look for every screen in the game:
--   * rounded panels with a soft top-to-bottom sheen and thick dark outlines
--   * punchy gradient buttons with a heavy dark outline, big white text with a black
--     outline, and a bounce when hovered/pressed
--   * windows with a full-width colored header bar, an icon, and the close button inside it
--   * text that scales with its box but never past a sensible size (so nothing looks huge)
--   * live 3D pickaxe icons (ViewportFrames that render the real pickaxe model)
--   * chunky cartoon 3D icons for everything else (UIKit.icon), no emoji anywhere

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIKit = {}

local rgb = Color3.fromRGB
UIKit.Colors = {
	Ink = rgb(40, 32, 92),        -- dark text and window outlines
	Panel = rgb(252, 251, 255),   -- window background
	PanelTint = rgb(236, 231, 255),
	Row = rgb(246, 243, 255),     -- cards inside windows
	Violet = rgb(128, 90, 255),
	Lilac = rgb(184, 164, 255),
	Sky = rgb(58, 168, 255),
	Mint = rgb(38, 206, 140),
	Sun = rgb(255, 188, 40),
	Coral = rgb(255, 84, 112),
	Grey = rgb(128, 122, 162),    -- secondary text
	White = rgb(255, 255, 255),
	Money = rgb(46, 196, 90),
	Outline = rgb(22, 20, 32),    -- the thick dark outline around buttons, windows and text
}
local C = UIKit.Colors
UIKit.Font = Enum.Font.FredokaOne
UIKit.BodyFont = Enum.Font.GothamMedium

-- a darker (amount > 0) or lighter (amount < 0) version of a color
function UIKit.shadeColor(color, amount)
	if amount >= 0 then
		return color:Lerp(Color3.new(0.1, 0.07, 0.25), amount)
	end
	return color:Lerp(Color3.new(1, 1, 1), -amount)
end
local function luminance(c)
	return 0.299 * c.R + 0.587 * c.G + 0.114 * c.B
end
-- outline that suits a background: soft lavender around light panels, a deep shade of the
-- color itself around colored ones
local function autoOutline(color)
	if luminance(color) > 0.86 then
		return rgb(150, 140, 190) -- light cards: a soft but visible edge
	end
	return color:Lerp(C.Outline, 0.72) -- colored panels: a heavy dark edge
end
UIKit.autoOutline = autoOutline

---------------------------------------------------------------------
-- BASICS
---------------------------------------------------------------------
-- RESPONSIVE SIZE: every top-level panel on every screen gets a UIScale set from the screen
-- size (1 on a 1280x760 screen, smaller on phones, a bit bigger on big monitors), so the whole
-- UI fits PC, mobile and console alike. It updates when the window is resized or rotated.
function UIKit.screenScale()
	local camera = workspace.CurrentCamera
	local v = camera and camera.ViewportSize or Vector2.new(1280, 760)
	return math.clamp(math.min(v.X / 1280, v.Y / 760), 0.55, 1.25)
end
local responsive = setmetatable({}, {__mode = "k"}) -- the UIScales we manage
local function makeResponsive(scale)
	scale:SetAttribute("Responsive", true)
	scale.Scale = UIKit.screenScale()
	responsive[scale] = true
end
task.spawn(function()
	local camera = workspace.CurrentCamera
	if not camera then return end
	camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		local k = UIKit.screenScale()
		for scale in pairs(responsive) do
			if scale.Parent then scale.Scale = k end
		end
	end)
end)

function UIKit.screen(player, name, order)
	local gui = Instance.new("ScreenGui")
	gui.Name = name
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = order or 0
	gui.Parent = player:WaitForChild("PlayerGui")
	-- scale every top-level panel to the screen (panels that manage their own UIScale are left alone)
	gui.ChildAdded:Connect(function(child)
		task.defer(function()
			if child.Parent == gui and child:IsA("GuiObject") and not child:FindFirstChildOfClass("UIScale") then
				local scale = Instance.new("UIScale")
				makeResponsive(scale)
				scale.Parent = child
			end
		end)
	end)
	return gui
end

function UIKit.corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 14)
	c.Parent = parent
	return c
end

function UIKit.outline(parent, thickness, color)
	local s = Instance.new("UIStroke")
	s.Color = color or C.Ink
	s.Thickness = thickness or 3
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.LineJoinMode = Enum.LineJoinMode.Round
	s.Parent = parent
	return s
end

-- soft top-to-bottom sheen so flat panels look chunky
function UIKit.shade(parent, amount)
	amount = amount or 0.1
	local g = Instance.new("UIGradient")
	g.Rotation = 90
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(0.5, Color3.new(1 - amount * 0.35, 1 - amount * 0.35, 1 - amount * 0.3)),
		ColorSequenceKeypoint.new(1, Color3.new(1 - amount, 1 - amount, 1 - amount * 0.8)),
	})
	g.Parent = parent
	return g
end

-- A rounded box. props: Size, Position, AnchorPoint, Color, Radius, Transparency,
-- Stroke (thickness or false), StrokeColor (default: matches the color), Shade (false for flat)
function UIKit.panel(parent, props)
	local f = Instance.new("Frame")
	f.Size = props.Size or UDim2.fromOffset(200, 100)
	f.Position = props.Position or UDim2.new()
	f.AnchorPoint = props.AnchorPoint or Vector2.zero
	f.BackgroundColor3 = props.Color or C.Panel
	f.BackgroundTransparency = props.Transparency or 0
	f.BorderSizePixel = 0
	f.Parent = parent
	UIKit.corner(f, props.Radius or 16)
	if props.Stroke ~= false then
		local stroke = UIKit.outline(f, props.Stroke or 2.5, props.StrokeColor or autoOutline(f.BackgroundColor3))
		if not props.StrokeColor then
			-- keep the outline matching when the color changes later (rarity tags etc.)
			f:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				stroke.Color = autoOutline(f.BackgroundColor3)
			end)
		end
	end
	if props.Shade ~= false then
		UIKit.shade(f, props.ShadeAmount)
	end
	return f
end

-- Bubbly text. props: Size, Position, AnchorPoint, Color, Align ("Left"/"Center"/"Right"),
-- VAlign, Stroke (outline thickness, 0 for none), StrokeColor, Font,
-- TextSize (fixed size) or MaxText (largest size scaled text may grow to, default 30)
function UIKit.label(parent, text, props)
	props = props or {}
	local l = Instance.new("TextLabel")
	l.Size = props.Size or UDim2.fromScale(1, 1)
	l.Position = props.Position or UDim2.new()
	l.AnchorPoint = props.AnchorPoint or Vector2.zero
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = props.Color or C.White
	l.Font = props.Font or UIKit.Font
	if props.TextSize then
		l.TextSize = props.TextSize
		l.TextWrapped = true
	else
		l.TextScaled = true
		local limit = Instance.new("UITextSizeConstraint")
		limit.MaxTextSize = props.MaxText or 30
		limit.MinTextSize = 6
		limit.Parent = l
	end
	l.TextXAlignment = Enum.TextXAlignment[props.Align or "Center"]
	l.TextYAlignment = Enum.TextYAlignment[props.VAlign or "Center"]
	l.RichText = props.RichText or false
	l.Parent = parent
	local strokeSize = props.Stroke == nil and 2 or props.Stroke
	if strokeSize > 0 then
		local s = Instance.new("UIStroke")
		s.Color = props.StrokeColor or C.Outline
		s.Thickness = strokeSize
		s.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
		s.Parent = l
	end
	return l
end

-- A glossy candy button that squishes when pressed and grows a bit on hover.
-- props: Size, Position, AnchorPoint, Color, TextColor, Radius, MaxText
-- Changing the button's BackgroundColor3 later recolors the whole button.
function UIKit.button(parent, text, props)
	props = props or {}
	local b = Instance.new("TextButton")
	b.Size = props.Size or UDim2.fromOffset(140, 44)
	b.Position = props.Position or UDim2.new()
	b.AnchorPoint = props.AnchorPoint or Vector2.zero
	b.BackgroundColor3 = props.Color or C.Mint
	b.AutoButtonColor = false
	b.Text = ""
	b.Parent = parent
	local radius = props.Radius or 14
	UIKit.corner(b, radius)
	local stroke = UIKit.outline(b, 3.5)
	local gloss = Instance.new("UIGradient")
	gloss.Rotation = 90
	gloss.Parent = b
	-- a grid of little outlined square studs across the face (the classic chunky-button
	-- texture), in a lighter shade of the button
	local size = b.Size
	local studStrokes = {}
	if props.Pattern ~= false and (size.Y.Scale > 0 or size.Y.Offset >= 34) then
		local pattern = Instance.new("Frame")
		pattern.Name = "Studs"
		pattern.BackgroundTransparency = 1
		pattern.Size = UDim2.new(1, -10, 1, -14)
		pattern.Position = UDim2.new(0.5, 0, 0, 5)
		pattern.AnchorPoint = Vector2.new(0.5, 0)
		pattern.ClipsDescendants = true
		pattern.Parent = b
		local grid = Instance.new("UIGridLayout")
		grid.CellSize = UDim2.fromOffset(12, 12)
		grid.CellPadding = UDim2.fromOffset(8, 8)
		grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
		grid.VerticalAlignment = Enum.VerticalAlignment.Center
		grid.Parent = pattern
		local w = size.X.Scale > 0 and 420 or size.X.Offset
		local h = size.Y.Scale > 0 and 90 or size.Y.Offset
		for _ = 1, math.min(math.ceil(w / 20) * math.ceil(h / 20), 140) do
			local stud = Instance.new("Frame")
			stud.BorderSizePixel = 0
			stud.BackgroundTransparency = 1
			stud.Parent = pattern
			UIKit.corner(stud, 3)
			local edge = Instance.new("UIStroke")
			edge.Thickness = 1.6
			edge.Transparency = 0.35
			edge.Parent = stud
			table.insert(studStrokes, edge)
		end
	end
	local label = UIKit.label(b, text, {
		Size = UDim2.new(1, -16, 1, -14), Position = UDim2.new(0.5, 0, 0.5, -2), AnchorPoint = Vector2.new(0.5, 0.5),
		Color = props.TextColor or C.White, Stroke = 3.5, MaxText = props.MaxText or 26,
	})
	label.Name = "Label"
	label.ZIndex = 2
	-- optional 3D icon on the left (props.Icon)
	if props.Icon then
		local h = size.Y.Offset > 0 and size.Y.Offset or 44
		UIKit.icon(b, props.Icon, {Name = "ButtonIcon", Size = UDim2.fromOffset(h + 6, h + 6), Position = UDim2.new(0, 2, 0.5, -1),
			AnchorPoint = Vector2.new(0, 0.5), ZIndex = 3})
		label.Size = UDim2.new(1, -h - 16, 1, -14)
		label.Position = UDim2.new(0.5, (h - 2) / 2, 0.5, -2)
	end
	local labelStroke = label:FindFirstChildOfClass("UIStroke")

	local function paint()
		local c = b.BackgroundColor3
		stroke.Color = c:Lerp(C.Outline, 0.9)
		-- one gradient does the 3D look: the full color across the face, then a sharp step to
		-- a darker lip along the bottom edge (like a chunky toy key)
		gloss.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(0.8, Color3.new(0.94, 0.94, 0.95)),
			ColorSequenceKeypoint.new(0.83, Color3.new(0.7, 0.7, 0.74)),
			ColorSequenceKeypoint.new(1, Color3.new(0.64, 0.64, 0.7)),
		})
		local studColor = UIKit.shadeColor(c, -0.35)
		for _, edge in ipairs(studStrokes) do edge.Color = studColor end
		if labelStroke then labelStroke.Color = C.Outline end
	end
	paint()
	b:GetPropertyChangedSignal("BackgroundColor3"):Connect(paint)

	local scale = Instance.new("UIScale")
	scale.Parent = b
	local function to(v, t)
		TweenService:Create(scale, TweenInfo.new(t or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = v}):Play()
	end
	b.MouseEnter:Connect(function() to(1.05) end)
	b.MouseLeave:Connect(function() to(1) end)
	b.MouseButton1Down:Connect(function() to(0.92, 0.06) end)
	b.MouseButton1Click:Connect(function()
		-- a soft click on every button (through the SFX group, so it follows the SFX setting)
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local Audio = require(ReplicatedStorage:WaitForChild("Audio"))
		Audio.sfx("Click")
	end)
	b.MouseButton1Up:Connect(function() to(1.05) end)
	return b, label
end

-- icon (optional): a different 3D icon for buttons made with props.Icon
function UIKit.setButton(button, text, color, icon)
	button.BackgroundColor3 = color
	local label = button:FindFirstChild("Label")
	if label then label.Text = text end
	local holder = button:FindFirstChild("ButtonIcon")
	if holder and icon ~= nil then UIKit.setIcon(holder, icon) end
end

-- Pops a frame in with a bouncy scale
function UIKit.pop(frame, from)
	local scale = frame:FindFirstChildOfClass("UIScale")
	if not scale then
		scale = Instance.new("UIScale")
		if frame.Parent and frame.Parent:IsA("ScreenGui") then makeResponsive(scale) end
		scale.Parent = frame
	end
	-- pop relative to the panel's screen-size scale
	local base = scale:GetAttribute("Responsive") and UIKit.screenScale() or 1
	scale.Scale = (from or 0.6) * base
	TweenService:Create(scale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = base}):Play()
end

---------------------------------------------------------------------
-- 3D UI ICONS: chunky cartoon icons with thick outlines, made in Blender
-- (tools/blender/ui_icons.py, pictures in assets/ui/icons). File > Import 3D of
-- assets/models/UIIcons.fbx + the installer put them in ReplicatedStorage > UIIcons; each
-- shows as a live 3D model in a ViewportFrame. Names: see UIIconList.
-- Messages can start with an icon tag, "{Skull} The curse got you!" (see UIKit.splitIcon).
---------------------------------------------------------------------
local iconNames -- [name] = true, loaded on first use
local function isIcon(name)
	if not iconNames then
		iconNames = {}
		for _, n in ipairs(require(ReplicatedStorage:WaitForChild("UIIconList"))) do iconNames[n] = true end
	end
	return typeof(name) == "string" and iconNames[name] == true
end
UIKit.isIcon = isIcon

local function iconSource(name)
	local folder = ReplicatedStorage:FindFirstChild("UIIcons")
	local item = folder and folder:FindFirstChild(name)
	if item and not item:IsA("BasePart") then item = item:FindFirstChildWhichIsA("BasePart", true) end
	return item
end

-- shows a different icon in a holder made by UIKit.icon (nil or "" clears it)
function UIKit.setIcon(holder, name)
	if holder:GetAttribute("Icon") == name and #holder:GetChildren() > 0 then return end
	holder:SetAttribute("Icon", name)
	for _, child in ipairs(holder:GetChildren()) do
		if child:IsA("BasePart") or child:IsA("Camera") or child.Name == "Fallback" or child.Name == "IconImage" then child:Destroy() end
	end
	if not name or name == "" then return end
	-- a rendered picture (glossy, outlined) beats the live 3D model when there is one
	local image = require(ReplicatedStorage:WaitForChild("UIIconImages"))[name]
	if image then
		local picture = Instance.new("ImageLabel")
		picture.Name = "IconImage"
		picture.BackgroundTransparency = 1
		picture.Size = UDim2.fromScale(1, 1)
		picture.Image = image
		picture.ScaleType = Enum.ScaleType.Fit
		picture.ZIndex = holder.ZIndex
		picture.Parent = holder
		return
	end
	local source = iconSource(name)
	if source then
		local part = source:Clone()
		part.Anchored = true
		part.CFrame = CFrame.new()
		part.Parent = holder
		-- the icon's front faces +Z; a slightly turned, slightly raised view, filling the frame
		local camera = Instance.new("Camera")
		camera.FieldOfView = 20
		local span = math.max(part.Size.X, part.Size.Y, part.Size.Z * 0.8)
		local distance = span * 0.6 / math.tan(math.rad(10))
		local turn, tilt = math.rad(-12), math.rad(8)
		camera.CFrame = CFrame.lookAt(Vector3.new(math.sin(turn), math.sin(tilt), math.cos(turn)) * distance, Vector3.zero)
		camera.Parent = holder
		holder.CurrentCamera = camera
	else
		-- not imported yet: a plain round chip with the first letter
		local chip = UIKit.panel(holder, {Size = UDim2.fromScale(0.78, 0.78), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
			Color = C.Lilac, Radius = 999, Stroke = 2})
		chip.Name = "Fallback"
		UIKit.label(chip, string.sub(name, 1, 1), {Size = UDim2.fromScale(0.7, 0.7), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2})
	end
end

-- A 3D icon. props: Size, Position, AnchorPoint, ZIndex, Name
function UIKit.icon(parent, name, props)
	props = props or {}
	local holder = Instance.new("ViewportFrame")
	holder.Name = props.Name or "Icon"
	holder.BackgroundTransparency = 1
	holder.Size = props.Size or UDim2.fromOffset(44, 44)
	holder.Position = props.Position or UDim2.new()
	holder.AnchorPoint = props.AnchorPoint or Vector2.zero
	if props.ZIndex then holder.ZIndex = props.ZIndex end
	holder.Ambient = rgb(205, 205, 215)
	holder.LightColor = rgb(255, 252, 245)
	holder.LightDirection = Vector3.new(0.5, -1, -0.6)
	holder.Parent = parent
	UIKit.setIcon(holder, name)
	return holder
end

-- A chunky glossy white 3D arrow (built from parts in a ViewportFrame, lit with a cool blue
-- so its sides shade light blue). direction: "Up" or "Down". props: Size, Position, AnchorPoint, ZIndex
function UIKit.arrowIcon(parent, direction, props)
	props = props or {}
	local holder = Instance.new("ViewportFrame")
	holder.Name = "Arrow"
	holder.BackgroundTransparency = 1
	holder.Size = props.Size or UDim2.fromOffset(44, 44)
	holder.Position = props.Position or UDim2.new()
	holder.AnchorPoint = props.AnchorPoint or Vector2.zero
	if props.ZIndex then holder.ZIndex = props.ZIndex end
	holder.Ambient = rgb(120, 190, 255)
	holder.LightColor = rgb(255, 255, 255)
	holder.LightDirection = Vector3.new(0.6, -1, -0.8)
	holder.Parent = parent
	local turn = direction == "Down" and CFrame.Angles(0, 0, math.pi) or CFrame.new()
	local function piece(class, size, cf)
		local p = Instance.new(class)
		p.Anchored = true
		p.Size = size
		p.CFrame = turn * cf
		p.Color = rgb(246, 250, 255)
		p.Material = Enum.Material.SmoothPlastic
		p.Parent = holder
	end
	-- the shaft, and the head as two wedges (a triangle seen from the front)
	piece("Part", Vector3.new(0.95, 1.25, 0.7), CFrame.new(0, -0.5, 0))
	piece("WedgePart", Vector3.new(0.7, 1.2, 1.05), CFrame.new(0.52, 0.7, 0) * CFrame.Angles(0, math.rad(-90), 0))
	piece("WedgePart", Vector3.new(0.7, 1.2, 1.05), CFrame.new(-0.52, 0.7, 0) * CFrame.Angles(0, math.rad(90), 0))
	local camera = Instance.new("Camera")
	camera.FieldOfView = 20
	camera.CFrame = CFrame.lookAt(Vector3.new(1.2, 0.8, 7.4), Vector3.new(0, 0.05, 0))
	camera.Parent = holder
	holder.CurrentCamera = camera
	return holder
end

-- "{Skull} The curse got you!" -> "Skull", "The curse got you!"  (no tag: nil, text)
function UIKit.splitIcon(text)
	if typeof(text) ~= "string" then return nil, "" end
	local name, rest = string.match(text, "^{(%w+)}%s*(.*)$")
	if name and isIcon(name) then return name, rest end
	return nil, text
end

-- A round colored badge with a 3D icon (or short text, like a number) in it
function UIKit.badge(parent, iconOrText, color, props)
	props = props or {}
	local d = props.Diameter or 44
	local circle = UIKit.panel(parent, {Size = UDim2.fromOffset(d, d), Position = props.Position, AnchorPoint = props.AnchorPoint,
		Color = color, Radius = d, Stroke = props.Stroke or 2.5})
	local icon
	if isIcon(iconOrText) then
		icon = UIKit.icon(circle, iconOrText, {Size = UDim2.fromScale(0.86, 0.86), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5)})
	else
		icon = UIKit.label(circle, iconOrText, {Size = UDim2.fromScale(0.64, 0.64), Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5), Stroke = props.TextStroke or 0, MaxText = 60, Font = props.Font or Enum.Font.GothamBlack})
	end
	icon.Name = "Icon"
	return circle, icon
end

---------------------------------------------------------------------
-- WINDOW: a panel with a colored header bar (icon + title + close button) and a body.
-- returns window, content (frame to put things in), closeButton
---------------------------------------------------------------------
local HEADER = 58
function UIKit.window(gui, title, size, accent, icon)
	accent = accent or C.Violet
	local window = UIKit.panel(gui, {
		Size = size, Position = UDim2.fromScale(0.5, 0.52), AnchorPoint = Vector2.new(0.5, 0.5),
		Color = C.Panel, Radius = 24, Stroke = 5, StrokeColor = C.Outline, ShadeAmount = 0.05,
	})
	window.Visible = false
	local sizeLimit = Instance.new("UISizeConstraint")
	sizeLimit.MaxSize = Vector2.new(size.X.Offset, size.Y.Offset)
	sizeLimit.Parent = window
	local aspect = Instance.new("UIAspectRatioConstraint")
	aspect.AspectRatio = size.X.Offset / size.Y.Offset
	aspect.Parent = window
	window.Size = UDim2.fromScale(0.92, 0.85)

	-- header bar: rounded on top, square where it meets the body
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.BorderSizePixel = 0
	header.BackgroundColor3 = accent
	header.Size = UDim2.new(1, 0, 0, HEADER)
	header.Parent = window
	UIKit.corner(header, 22)
	local headerFill = Instance.new("Frame")
	headerFill.BorderSizePixel = 0
	headerFill.BackgroundColor3 = accent
	headerFill.AnchorPoint = Vector2.new(0, 1)
	headerFill.Position = UDim2.fromScale(0, 1)
	headerFill.Size = UDim2.new(1, 0, 0, 22)
	headerFill.Parent = header

	local titleX = 22
	if icon then
		-- a big 3D icon that pokes out over the top-left of the header
		UIKit.icon(header, icon, {Size = UDim2.fromOffset(64, 64), Position = UDim2.new(0, 6, 0.5, -8), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 3})
		titleX = 76
	end
	local titleLabel = UIKit.label(header, title, {Size = UDim2.new(1, -titleX - 70, 0, 38), Position = UDim2.new(0, titleX, 0.5, -2), AnchorPoint = Vector2.new(0, 0.5),
		Align = "Left", Stroke = 3.5, StrokeColor = C.Outline, MaxText = 34})
	-- the header gets the same shine as the buttons
	local headerShine = Instance.new("UIGradient")
	headerShine.Rotation = 90
	headerShine.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(0.5, Color3.new(0.95, 0.95, 0.97)),
		ColorSequenceKeypoint.new(1, Color3.new(0.78, 0.78, 0.84)),
	})
	headerShine.Parent = header
	-- the square filler under the header's bottom corners continues the same gradient
	-- (it covers the bottom 22 of the header's 58 pixels), so there's no seam
	local fillShine = Instance.new("UIGradient")
	fillShine.Rotation = 90
	local from = (HEADER - 22) / HEADER
	local at = 0.95 - (from - 0.5) / 0.5 * 0.17
	fillShine.Color = ColorSequence.new(Color3.new(at, at, at + 0.012), Color3.new(0.78, 0.78, 0.84))
	fillShine.Parent = headerFill
	titleLabel.Name = "Title"

	local close = UIKit.button(header, "X", {
		Size = UDim2.fromOffset(42, 42), Position = UDim2.new(1, -10, 0.5, -2), AnchorPoint = Vector2.new(1, 0.5), Color = C.Coral, Radius = 14, MaxText = 22,
	})
	close.MouseButton1Click:Connect(function()
		window.Visible = false
	end)

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundTransparency = 1
	content.Size = UDim2.new(1, -36, 1, -HEADER - 30)
	content.Position = UDim2.new(0, 18, 0, HEADER + 14)
	content.Parent = window
	return window, content, close
end

function UIKit.open(window)
	window.Visible = true
	UIKit.pop(window, 0.8)
end

-- Scrolling list with padding. returns the scrolling frame
function UIKit.list(parent, padding)
	local list = Instance.new("ScrollingFrame")
	list.Size = UDim2.fromScale(1, 1)
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.ScrollBarThickness = 8
	list.ScrollBarImageColor3 = C.Lilac
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new()
	list.Parent = parent
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, padding or 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = list
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 6)
	pad.PaddingBottom = UDim.new(0, 6)
	pad.PaddingRight = UDim.new(0, 10)
	pad.Parent = list
	return list
end

-- A small stat bar: label on the left, filled bar, value on the right
function UIKit.statBar(parent, name, fraction, valueText, color, props)
	local row = Instance.new("Frame")
	row.BackgroundTransparency = 1
	row.Size = props and props.Size or UDim2.new(1, 0, 0, 18)
	row.Position = props and props.Position or UDim2.new()
	row.Parent = parent
	UIKit.label(row, name, {Size = UDim2.new(0.26, 0, 0.9, 0), Position = UDim2.fromScale(0, 0.05), Align = "Left", Color = C.Grey, Stroke = 0, MaxText = 16})
	local track = UIKit.panel(row, {Size = UDim2.new(0.46, 0, 0.62, 0), Position = UDim2.new(0.27, 0, 0.19, 0), Color = rgb(232, 227, 250), Radius = 8, Stroke = false, Shade = false})
	local fill = UIKit.panel(track, {Size = UDim2.new(math.clamp(fraction, 0.06, 1), 0, 1, 0), Color = color, Radius = 8, Stroke = false, ShadeAmount = 0.2})
	fill.Name = "Fill"
	UIKit.label(row, valueText, {Size = UDim2.new(0.25, 0, 0.9, 0), Position = UDim2.new(0.75, 0, 0.05, 0), Align = "Right", Color = C.Ink, Stroke = 0, MaxText = 16})
	return row
end

---------------------------------------------------------------------
-- 3D PICKAXE ICON: renders the real pickaxe model inside a ViewportFrame
---------------------------------------------------------------------
local ShovelModels -- loaded on first use (only needed where icons are drawn)
function UIKit.shovelIcon(parent, def, props)
	props = props or {}
	ShovelModels = ShovelModels or require(ReplicatedStorage:WaitForChild("PickaxeModels"))
	local vp = Instance.new("ViewportFrame")
	vp.Size = props.Size or UDim2.fromOffset(80, 80)
	vp.Position = props.Position or UDim2.new()
	vp.AnchorPoint = props.AnchorPoint or Vector2.zero
	vp.BackgroundTransparency = 1
	vp.Ambient = rgb(200, 198, 215)
	vp.LightColor = rgb(255, 250, 240)
	vp.LightDirection = Vector3.new(-1, -1.5, -1)
	vp.Parent = parent

	-- show the pickaxe diagonally: head at the top-left, grip at the bottom-right, with the
	-- head's arms facing the camera (tool Y/Z in the screen plane) and a slight 3D turn
	local pose = CFrame.Angles(0, math.rad(22), 0) * CFrame.fromMatrix(Vector3.zero, Vector3.new(0, 0, -1), Vector3.new(1, 1, 0).Unit)
	local tool = ShovelModels(def)
	local model = Instance.new("Model")
	local minV, maxV = Vector3.new(math.huge, math.huge, math.huge), -Vector3.new(math.huge, math.huge, math.huge)
	for _, piece in ipairs(tool:GetChildren()) do
		if piece:IsA("BasePart") and piece.Name ~= "Handle" then
			for _, c in ipairs(piece:GetChildren()) do
				if c:IsA("WeldConstraint") or c:IsA("ParticleEmitter") or c:IsA("Light") then c:Destroy() end
			end
			piece.CFrame = pose * piece.CFrame
			local half = piece.Size / 2
			minV = minV:Min(piece.CFrame.Position - Vector3.new(half.Magnitude, half.Magnitude, half.Magnitude) * 0.6)
			maxV = maxV:Max(piece.CFrame.Position + Vector3.new(half.Magnitude, half.Magnitude, half.Magnitude) * 0.6)
			piece.Parent = model
		end
	end
	tool:Destroy()
	model.Parent = vp

	local center = (minV + maxV) / 2
	local extent = (maxV - minV).Magnitude
	local camera = Instance.new("Camera")
	camera.FieldOfView = 30
	camera.CFrame = CFrame.new(center + Vector3.new(0, 0, extent * 1.75), center)
	camera.Parent = vp
	vp.CurrentCamera = camera
	return vp
end

---------------------------------------------------------------------
-- MEME ICON: the meme's actual 3D model in a little viewport, on a tile in its rarity
-- color, with a rarity badge. (No emoji or pictures: what you see is the real object.)
---------------------------------------------------------------------
local ArtifactData, ArtifactModels -- loaded on first use

local function modelViewport(tile, artifact, radius)
	local viewport = Instance.new("ViewportFrame")
	viewport.Name = "Model3D"
	viewport.BackgroundTransparency = 1
	viewport.Size = UDim2.new(1, -6, 1, -6)
	viewport.Position = UDim2.fromScale(0.5, 0.5)
	viewport.AnchorPoint = Vector2.new(0.5, 0.5)
	viewport.Ambient = Color3.fromRGB(170, 170, 185)
	viewport.LightColor = Color3.fromRGB(255, 250, 240)
	viewport.LightDirection = Vector3.new(-0.6, -1, -0.8)
	viewport.Parent = tile
	UIKit.corner(viewport, math.max(radius - 3, 4))
	local ok, model = pcall(ArtifactModels.buildHeld, artifact, 4)
	if not ok or not model then return viewport end
	model:PivotTo(CFrame.new())
	model.Parent = viewport
	local half = math.max(model:GetAttribute("HalfHeight") or 2, (model:GetAttribute("Width") or 4) / 2)
	local camera = Instance.new("Camera")
	camera.FieldOfView = 30
	-- three-quarter front view (the front is -Z), slightly from above
	local turn, tilt, distance = math.rad(28), math.rad(12), half * 4.2
	local eye = Vector3.new(math.sin(turn) * math.cos(tilt), math.sin(tilt), -math.cos(turn) * math.cos(tilt)) * distance
	camera.CFrame = CFrame.lookAt(eye, Vector3.zero)
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	return viewport
end

function UIKit.artifactIcon(parent, artifact, props)
	props = props or {}
	ArtifactData = ArtifactData or require(ReplicatedStorage:WaitForChild("ArtifactData"))
	ArtifactModels = ArtifactModels or require(ReplicatedStorage:WaitForChild("ArtifactModels"))
	local rarity = ArtifactData.GetRarity(artifact.Rarity)
	local color = rarity and rarity.Color or C.Lilac
	local tile = UIKit.panel(parent, {
		Size = props.Size or UDim2.fromOffset(80, 80), Position = props.Position, AnchorPoint = props.AnchorPoint,
		Color = color:Lerp(C.White, 0.45), Radius = props.Radius or 16, Stroke = props.Stroke or 3, ShadeAmount = 0.25,
	})
	tile.Name = "ArtifactIcon"
	-- soft glow disc behind the model
	local glow = UIKit.panel(tile, {Size = UDim2.fromScale(0.78, 0.78), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
		Color = C.White, Radius = 999, Stroke = false, Shade = false})
	glow.BackgroundTransparency = 0.45
	modelViewport(tile, artifact, props.Radius or 16)
	-- rarity badge in the corner (the higher the rarity, the more it stands out)
	if props.Badge ~= false then
		local badge = UIKit.panel(tile, {Size = UDim2.fromScale(0.36, 0.26), Position = UDim2.new(1, 4, 0, -4), AnchorPoint = Vector2.new(1, 0),
			Color = color, Radius = 8, Stroke = 2, Shade = false})
		UIKit.label(badge, rarity and (rarity.Secret and "S" or rarity.Code) or "?", {Size = UDim2.fromScale(0.8, 0.8), Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2})
	end
	return tile
end

return UIKit
]=])
install(game:GetService("ReplicatedStorage"), "VehicleModels", "ModuleScript", [=[
-- VehicleModels (ModuleScript in ReplicatedStorage)
-- Cartoony 2050 flying vehicles: bubble cars, hover buses, delivery drones and ad blimps.
-- FlyingTraffic (client) builds them and moves them around the city.
-- Every builder returns a Model whose front is -Z and whose PrimaryPart is at its center.

local VehicleModels = {}

local rgb = Color3.fromRGB
local BODY_COLORS = {
	rgb(255, 122, 138), rgb(92, 186, 255), rgb(255, 206, 84), rgb(96, 226, 190),
	rgb(178, 158, 255), rgb(255, 160, 90), rgb(246, 247, 252),
}
local GLOW_COLORS = {rgb(96, 196, 222), rgb(214, 118, 188), rgb(222, 186, 96), rgb(96, 206, 168)}
local WHITE = rgb(246, 247, 252)
local INK = rgb(34, 36, 74)
local GLASS = rgb(168, 228, 255)
local ALONG_Z = CFrame.Angles(0, math.rad(90), 0) -- points a cylinder along Z
local UPRIGHT = CFrame.Angles(0, 0, math.rad(90)) -- stands a cylinder up

local function part(model, name, size, cframe, color, material, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	if shape then p.Shape = shape end
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = model
	return p
end

local function blob(model, name, size, cframe, color, material)
	local p = part(model, name, size, cframe, color, material)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = p
	return p
end

local function ball(model, name, d, cframe, color, material)
	return part(model, name, Vector3.new(d, d, d), cframe, color, material, Enum.PartType.Ball)
end

local function pick(rng, list)
	return list[rng:NextInteger(1, #list)]
end

local function glass(p)
	p.Transparency = 0.3
	p.Reflectance = 0.15
	return p
end

-- Little bubble car: round body, big glass dome, side pods with glowing thrusters
function VehicleModels.car(rng)
	local model = Instance.new("Model")
	model.Name = "BubbleCar"
	local color = pick(rng, BODY_COLORS)
	local glow = pick(rng, GLOW_COLORS)
	local body = blob(model, "Body", Vector3.new(5.4, 2.6, 9), CFrame.new(), color)
	blob(model, "Belly", Vector3.new(5, 1.4, 8.2), CFrame.new(0, -0.7, 0), WHITE)
	glass(blob(model, "Dome", Vector3.new(3.8, 3, 4.4), CFrame.new(0, 1.2, -0.3), GLASS, Enum.Material.Glass))
	part(model, "Seat", Vector3.new(2.6, 0.6, 1.4), CFrame.new(0, 0.6, 0.5), INK)
	for _, side in ipairs({-1, 1}) do
		part(model, "Pod", Vector3.new(4.6, 1.5, 1.5), CFrame.new(side * 2.9, -0.2, 1.4) * ALONG_Z, WHITE, nil, Enum.PartType.Cylinder)
		part(model, "PodGlow", Vector3.new(0.3, 1.2, 1.2), CFrame.new(side * 2.9, -0.2, 3.75) * ALONG_Z, glow, Enum.Material.Neon, Enum.PartType.Cylinder)
		ball(model, "Headlight", 0.8, CFrame.new(side * 1.3, 0, -4.3), rgb(214, 208, 180), Enum.Material.Neon)
	end
	part(model, "TailFin", Vector3.new(0.4, 1.6, 1.8), CFrame.new(0, 1.3, 3.6), color)
	ball(model, "FinTip", 0.6, CFrame.new(0, 2.1, 3.6), glow, Enum.Material.Neon)
	part(model, "Underglow", Vector3.new(3.6, 0.15, 6), CFrame.new(0, -1.35, 0), glow, Enum.Material.Neon)
	model.PrimaryPart = body
	return model
end

-- Hover bus: long capsule with porthole windows and a color stripe
function VehicleModels.bus(rng)
	local model = Instance.new("Model")
	model.Name = "HoverBus"
	local color = pick(rng, BODY_COLORS)
	local glow = pick(rng, GLOW_COLORS)
	local body = part(model, "Body", Vector3.new(16, 5, 5), CFrame.new() * ALONG_Z, WHITE, nil, Enum.PartType.Cylinder)
	ball(model, "Nose", 5, CFrame.new(0, 0, -8), WHITE)
	ball(model, "Tail", 5, CFrame.new(0, 0, 8), color)
	glass(blob(model, "Windshield", Vector3.new(3.8, 2.4, 2), CFrame.new(0, 0.6, -9.6), GLASS, Enum.Material.Glass))
	part(model, "Stripe", Vector3.new(16.2, 1.1, 5.15), CFrame.new(0, -1, 0) * ALONG_Z, color, nil, Enum.PartType.Cylinder)
	for _, side in ipairs({-1, 1}) do
		for k = -2, 2 do
			part(model, "Window", Vector3.new(0.3, 1.5, 1.5), CFrame.new(side * 2.45, 0.8, k * 3), GLASS, Enum.Material.Glass, Enum.PartType.Cylinder)
		end
		part(model, "Thruster", Vector3.new(3, 1.6, 1.6), CFrame.new(side * 2.2, -2.2, 6) * ALONG_Z, color, nil, Enum.PartType.Cylinder)
		part(model, "ThrusterGlow", Vector3.new(0.3, 1.3, 1.3), CFrame.new(side * 2.2, -2.2, 7.6) * ALONG_Z, glow, Enum.Material.Neon, Enum.PartType.Cylinder)
	end
	part(model, "RoofSign", Vector3.new(0.6, 1.2, 6), CFrame.new(0, 2.9, 0), color)
	model.PrimaryPart = body
	return model
end

-- Delivery drone: round body, four rotor rings, a dangling package
function VehicleModels.drone(rng)
	local model = Instance.new("Model")
	model.Name = "DeliveryDrone"
	local color = pick(rng, BODY_COLORS)
	local glow = pick(rng, GLOW_COLORS)
	local body = ball(model, "Body", 2.6, CFrame.new(), WHITE)
	ball(model, "Eye", 1, CFrame.new(0, 0.2, -1.05), INK)
	ball(model, "EyeGlint", 0.35, CFrame.new(0.15, 0.4, -1.5), glow, Enum.Material.Neon)
	for _, x in ipairs({-1, 1}) do
		for _, z in ipairs({-1, 1}) do
			local arm = CFrame.new(x * 2, 0.5, z * 2)
			part(model, "Arm", Vector3.new(0.3, 0.3, 2.4), CFrame.lookAt(Vector3.new(0, 0.5, 0), arm.Position) * CFrame.new(0, 0, -1.4), color)
			part(model, "Rotor", Vector3.new(0.2, 2.2, 2.2), arm * UPRIGHT, color, nil, Enum.PartType.Cylinder)
			part(model, "RotorGlow", Vector3.new(0.1, 2.4, 2.4), arm * CFrame.new(0, -0.1, 0) * UPRIGHT, glow, Enum.Material.Neon, Enum.PartType.Cylinder).Transparency = 0.5
		end
	end
	part(model, "Rope", Vector3.new(0.15, 1.6, 0.15), CFrame.new(0, -2, 0), INK)
	part(model, "Package", Vector3.new(1.8, 1.5, 1.8), CFrame.new(0, -3.4, 0), rgb(214, 160, 100))
	part(model, "PackageTape", Vector3.new(1.85, 0.3, 1.85), CFrame.new(0, -3.1, 0), pick(rng, BODY_COLORS))
	model.PrimaryPart = body
	return model
end

-- Advertising blimp: huge soft balloon with fins, a gondola and a glowing banner
local SLOGANS = {"DIG DEEPER!", "MEMES 4 SALE", "VISIT THE ABYSS", "RATE MY MUSEUM", "PICKAXE SALE 50% OFF", "NO BRAINROT ZONE"}
function VehicleModels.blimp(rng)
	local model = Instance.new("Model")
	model.Name = "AdBlimp"
	local color = pick(rng, BODY_COLORS)
	local body = blob(model, "Balloon", Vector3.new(16, 15, 42), CFrame.new(), color)
	blob(model, "BalloonShine", Vector3.new(7, 3, 20), CFrame.new(-3, 5.5, -3), WHITE).Transparency = 0.4
	for i, angle in ipairs({0, 90, 180, 270}) do
		local cf = CFrame.new(0, 0, 18) * CFrame.Angles(0, 0, math.rad(angle))
		part(model, "Fin", Vector3.new(0.8, 9, 7), cf * CFrame.new(0, 5.5, 0), i % 2 == 0 and WHITE or color)
	end
	part(model, "Gondola", Vector3.new(8, 3, 3.6), CFrame.new(0, -9, -2) * ALONG_Z, WHITE, nil, Enum.PartType.Cylinder)
	ball(model, "GondolaFront", 3.6, CFrame.new(0, -9, -6), WHITE)
	glass(blob(model, "GondolaWindows", Vector3.new(3.8, 1.4, 7), CFrame.new(0, -8.6, -2), GLASS, Enum.Material.Glass))
	for _, side in ipairs({-1, 1}) do
		local banner = part(model, "Banner", Vector3.new(0.4, 5, 22), CFrame.new(side * 8.1, 0, 0), INK)
		local gui = Instance.new("SurfaceGui")
		gui.Face = side == 1 and Enum.NormalId.Right or Enum.NormalId.Left
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 20
		gui.LightInfluence = 0
		gui.Parent = banner
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Text = pick(rng, SLOGANS)
		label.TextColor3 = rgb(255, 222, 110)
		label.Font = Enum.Font.FredokaOne
		label.TextScaled = true
		label.Parent = gui
		part(model, "BannerFrame", Vector3.new(0.3, 5.6, 22.6), CFrame.new(side * 7.9, 0, 0), pick(rng, GLOW_COLORS))
		part(model, "Propeller", Vector3.new(0.3, 4, 4), CFrame.new(side * 5, -8, 8) * ALONG_Z, WHITE, nil, Enum.PartType.Cylinder)
	end
	model.PrimaryPart = body
	return model
end

return VehicleModels
]=])
install(game:GetService("ReplicatedStorage"), "WorldGimmicks", "ModuleScript", [=[
-- WorldGimmicks (ModuleScript in ReplicatedStorage)
-- Every world has its own twist so no two worlds play the same.
--   Modules = which Gimmick_<Module> scripts in ServerScriptService run it (WorldGimmickManager
--             starts them and tells them when players come and go)
--   Tag     = the short label on the world's card in the World Gate menu
--   Icon, Title, Text = what WorldGimmickClient shows when you arrive
-- World 1 has no gimmick scripts; its twist (the depth bonus) is built into digging itself.

return {
	[1] = {Modules = {}, Icon = "Pickaxe", Tag = "Depth Bonus", Title = "DEPTH BONUS",
		Text = "The deeper you dig, the luckier your finds: up to 1.6x luck at the bottom of the Abyss!"},
	[2] = {Modules = {"Spirits"}, Icon = "Ghost", Tag = "Meme Ghosts", Title = "MEME GHOSTS",
		Text = "Memes you dig up here escape as ghosts! Click the ghost 4 times to capture it before it gets away."},
	[3] = {Modules = {"LowGravity", "GravityShift"}, Icon = "Sparkle", Tag = "Gravity Shift", Title = "LOW GRAVITY + GRAVITY SHIFTS",
		Text = "Gravity is weak here, and deep down it flips! Hold on during a shift. The deep layers give 1.5x luck."},
	[4] = {Modules = {"Blizzard", "Permafrost"}, Icon = "Ice", Tag = "Permafrost", Title = "PERMAFROST",
		Text = "Below the topsoil the ground is frozen solid. Use a Torch Flare [F] to melt it, or get a heated pickaxe (the top 3)."},
	[5] = {Modules = {"GoldRush", "CurseTraps"}, Icon = "Skull", Tag = "Curse Traps", Title = "CURSE TRAPS + GOLD RUSH",
		Text = "Cursed blocks hide in the sand. When one goes off, press the key shown in time for gold, or your pickaxe is locked for 3s!"},
	[6] = {Modules = {"Oxygen"}, Icon = "Bubble", Tag = "Oxygen", Title = "LOW OXYGEN",
		Text = "The deep pit is flooded with toxic fumes. Watch your air meter and refill it at the bubbling air vents!"},
	[7] = {Modules = {"Merchant"}, Icon = "Candy", Tag = "Alien Merchant", Title = "ALIEN MERCHANT",
		Text = "A candy-loving alien wanders the rim selling Sugar Rush: dig 1.5x faster for 3 minutes!"},
	[8] = {Modules = {"Eruption", "LavaSurge"}, Icon = "Volcano", Tag = "Lava Surge", Title = "LAVA SURGES + ERUPTIONS",
		Text = "Every few minutes lava rises from the bottom of the pit! Climb up to the glowing safe ledges or the surface before it hits."},
	[9] = {Modules = {"GlitchSurge", "DataHacking"}, Icon = "Disk", Tag = "Data Hacking", Title = "DATA HACKING",
		Text = "Digging uncovers Data Nodes. Hit the beats to hack them and dig up a Corrupted meme worth 2x!"},
}
]=])
install(game:GetService("ReplicatedStorage"), "WorldsData", "ModuleScript", [=[
-- WorldsData (ModuleScript in ReplicatedStorage)
-- The 8 worlds you travel to through the World Gate (worlds 2-9). GameConfig turns each entry
-- into a full world: a floating island with its own pit, Shovel Shop, World Gate, memes,
-- shovels, dirt materials and sky. (The museum only exists in World 1.)
--
-- Per world:
--   Top / Wall      terrain material of the island surface and of the pit walls
--   Zones           terrain material + color of the 4 depth zones (Shallow, Mid, Deep, Abyss)
--   Look            colors for the island decorations and the world's shovels
--   Sky             lighting players see while they're in the world (WorldClient applies it):
--                   ClockTime, Latitude (sun angle), Brightness, Exposure (ExposureCompensation),
--                   Ambient/OutdoorAmbient, Fog/Decay/Density/Offset/Haze/Glare (Atmosphere),
--                   Tint/Saturation/Contrast (color grade), Bloom {Intensity, Size, Threshold},
--                   SunRays {Intensity, Spread}, Clouds (cover). Lighting.Technology is set to
--                   Future by the installer for realistic lights and reflections.
--   Shovels         the world's 7 pickaxes: {name, description, Id = save id}; stats come from ShovelTiers

local rgb = Color3.fromRGB

local WorldsData = {}

-- Every world's 7 shovels follow the same progression; price = PriceFactor x the world's price.
-- MaxZone: 1 = Shallow, 2 = Mid, 3 = Deep, 4 = Abyss
WorldsData.ShovelTiers = {
	{MaxZone = 1, Power = 2, FindChance = 0.012, Luck = 1,   Cooldown = 0.5,  PriceFactor = 0},
	{MaxZone = 2, Power = 3,   FindChance = 0.014, Luck = 1.2, Cooldown = 0.46, PriceFactor = 0.05},
	{MaxZone = 2, Power = 4, FindChance = 0.016, Luck = 1.4, Cooldown = 0.43, PriceFactor = 0.15},
	{MaxZone = 3, Power = 5,   FindChance = 0.018, Luck = 1.7, Cooldown = 0.4,  PriceFactor = 0.4},
	{MaxZone = 3, Power = 6, FindChance = 0.02,  Luck = 2,   Cooldown = 0.37, PriceFactor = 1},
	{MaxZone = 4, Power = 8, FindChance = 0.024, Luck = 2.5, Cooldown = 0.34, PriceFactor = 2.5},
	{MaxZone = 4, Power = 9,   FindChance = 0.027, Luck = 3,   Cooldown = 0.31, PriceFactor = 6},
}

-- Terrain colors are shared by the whole map (Roblox paints each material one color
-- everywhere), so every world uses its own mix of materials. MapStyle applies these.
WorldsData.TerrainColors = {
	-- World 1
	-- topsoil, dense clay, rocky crust (the wall/strata rock), crystal substratum, magma core
	Grass = rgb(112, 204, 108), Slate = rgb(198, 192, 214), Ground = rgb(128, 88, 60),
	Sandstone = rgb(176, 104, 74), CrackedLava = rgb(200, 70, 36), Glacier = rgb(120, 205, 240),
	Basalt = rgb(70, 64, 96),
	-- Worlds 2-9
	LeafyGrass = rgb(255, 176, 208), Mud = rgb(150, 78, 110), Brick = rgb(236, 130, 140),
	WoodPlanks = rgb(120, 60, 70), Salt = rgb(255, 236, 246), Asphalt = rgb(34, 30, 70),
	Pavement = rgb(86, 72, 170), Limestone = rgb(176, 150, 236), Ice = rgb(120, 230, 255),
	Snow = rgb(236, 246, 255), Concrete = rgb(170, 200, 225), Cobblestone = rgb(90, 120, 170),
	Sand = rgb(240, 180, 96), Rock = rgb(110, 90, 120),
}

WorldsData.Worlds = {
	-----------------------------------------------------------------
	{
		Name = "Neon Sakura Grove", Theme = "Sakura", Price = 15e6,
		Tagline = "Pink blossoms, paper lanterns and robot koi.",
		Top = "LeafyGrass", Wall = "Rock",
		Zones = {"Mud", "Brick", "WoodPlanks", "Salt"},
		Look = {Main = rgb(255, 170, 205), Second = rgb(255, 238, 244), Dark = rgb(128, 62, 80), Glow = rgb(255, 120, 180), Accent = rgb(255, 214, 120)},
		Sky = {ClockTime = 17.3, Ambient = rgb(120, 96, 120), OutdoorAmbient = rgb(160, 130, 160), Tint = rgb(255, 232, 242),
			Fog = rgb(255, 200, 225), Decay = rgb(200, 130, 170), Density = 0.32, Clouds = 0.55,
			Brightness = 2.6, Exposure = 0.15, Latitude = 30, Offset = 0.25, Haze = 1.6, Glare = 0.6, Saturation = 0.12, Contrast = 0.08, Bloom = {0.35, 24, 1.9}, SunRays = {0.12, 0.25}},
		Shovels = {
			{"Blossom Pickaxe", "A little pink pickaxe. Leaves petals everywhere it digs.", Id = "BlossomTrowel"},
			{"Bamboo Pick", "Light, strong and grown in a week.", Id = "BambooSpade"},
			{"Koi Pickaxe", "Shaped like a koi fin. Cuts dirt like water.", Id = "KoiScoop"},
			{"Lantern Pick", "A paper lantern lights every swing.", Id = "LanternSpade"},
			{"Katana Pickaxe", "Folded 1000 times. Cuts through bricks like tofu.", Id = "KatanaShovel"},
			{"Petal Crusher", "Blows a storm of petals into the Abyss.", Id = "PetalExcavator"},
			{"Hanami Pickaxe", "Mythic. Blossoms bloom wherever it strikes.", Id = "HanamiHarvester"},
		},
	},
	-----------------------------------------------------------------
	{
		Name = "Galaxy Drift", Theme = "Galaxy", Price = 500e6,
		Tagline = "A dig site floating between the stars.",
		Top = "Asphalt", Wall = "Rock",
		Zones = {"Pavement", "Limestone", "Basalt", "Ice"},
		Look = {Main = rgb(130, 96, 255), Second = rgb(40, 36, 96), Dark = rgb(22, 20, 52), Glow = rgb(110, 220, 255), Accent = rgb(255, 214, 110)},
		Sky = {ClockTime = 0, Ambient = rgb(118, 110, 170), OutdoorAmbient = rgb(140, 130, 200), Tint = rgb(226, 222, 255),
			Fog = rgb(80, 60, 160), Decay = rgb(40, 30, 100), Density = 0.32, Clouds = 0,
			Brightness = 1.2, Exposure = 0.35, Latitude = 20, Offset = 0.3, Haze = 0.3, Glare = 0, Saturation = 0.15, Contrast = 0.12, Bloom = {0.5, 28, 1.4}, SunRays = {0, 0.1}},
		Shovels = {
			{"Meteor Pick", "Made from a meteor that landed on a meme.", Id = "MeteorScoop"},
			{"Rocket Pickaxe", "Has tiny thrusters. Mostly for style.", Id = "RocketSpade"},
			{"Orbit Pickaxe", "A little moon orbits the handle.", Id = "OrbitShovel"},
			{"Nebula Pick", "Swirls with space dust.", Id = "NebulaTrowel"},
			{"Comet Crusher", "Leaves a sparkly tail with every swing.", Id = "CometCrusher"},
			{"Supernova Pickaxe", "Legendary. Hot as a dying star.", Id = "SupernovaSpade"},
			{"Event Horizon", "Mythic. Nothing escapes it. Not even the Abyss.", Id = "EventHorizon"},
		},
	},
	-----------------------------------------------------------------
	{
		Name = "Frostbyte Tundra", Theme = "Frost", Price = 1e9,
		Tagline = "Snowy servers, ice crystals and a big aurora.",
		Top = "Snow", Wall = "Rock",
		Zones = {"Ice", "Concrete", "Glacier", "Cobblestone"},
		Look = {Main = rgb(150, 226, 255), Second = rgb(246, 250, 255), Dark = rgb(56, 88, 140), Glow = rgb(130, 255, 220), Accent = rgb(190, 170, 255)},
		Sky = {ClockTime = 9.5, Ambient = rgb(110, 120, 150), OutdoorAmbient = rgb(150, 165, 195), Tint = rgb(236, 246, 255),
			Fog = rgb(215, 235, 255), Decay = rgb(140, 170, 220), Density = 0.3, Clouds = 0.7,
			Brightness = 3.2, Exposure = 0.05, Latitude = 65, Offset = 0.2, Haze = 2.2, Glare = 0.3, Saturation = -0.05, Contrast = 0.1, Bloom = {0.3, 20, 2.2}, SunRays = {0.06, 0.2}},
		Shovels = {
			{"Snowball Pick", "Packs perfect snowballs. Also digs.", Id = "SnowballScoop"},
			{"Icicle Pickaxe", "Sharp, shiny and a bit drippy.", Id = "IcicleSpade"},
			{"Penguin Pick", "Waddles through snow at top speed.", Id = "PenguinPaddle"},
			{"Frostbite Pickaxe", "Cold enough to freeze a lag spike.", Id = "FrostbiteShovel"},
			{"Blizzard Breaker", "Every swing is a tiny snowstorm.", Id = "BlizzardBreaker"},
			{"Aurora Pickaxe", "Legendary. Glows with northern lights.", Id = "AuroraAuger"},
			{"Absolute Zero Pickaxe", "Mythic. So cold the Abyss shatters.", Id = "AbsoluteZeroSpade"},
		},
	},
	-----------------------------------------------------------------
	{
		Name = "Chrome Dunes", Theme = "Dunes", Price = 5e9,
		Tagline = "Golden sand, chrome pyramids and solar towers.",
		Top = "Sand", Wall = "Rock",
		Zones = {"Sandstone", "Ground", "Brick", "Salt"},
		Look = {Main = rgb(255, 196, 90), Second = rgb(226, 232, 244), Dark = rgb(120, 76, 50), Glow = rgb(255, 150, 70), Accent = rgb(80, 210, 220)},
		Sky = {ClockTime = 13, Ambient = rgb(128, 112, 96), OutdoorAmbient = rgb(170, 150, 128), Tint = rgb(255, 244, 226),
			Fog = rgb(255, 222, 170), Decay = rgb(220, 160, 110), Density = 0.3, Clouds = 0.2,
			Brightness = 3.6, Exposure = 0.1, Latitude = 15, Offset = 0.2, Haze = 2.6, Glare = 0.9, Saturation = 0.08, Contrast = 0.14, Bloom = {0.3, 24, 2.1}, SunRays = {0.1, 0.3}},
		Shovels = {
			{"Sandy Pick", "Full of sand. Always. Forever.", Id = "SandyScoop"},
			{"Cactus Pickaxe", "Hug it at your own risk.", Id = "CactusSpade"},
			{"Mirage Pickaxe", "Is it really there? Yes. Probably.", Id = "MirageShovel"},
			{"Pharaoh Pickaxe", "Once dug a pyramid in an afternoon.", Id = "PharaohSpade"},
			{"Solar Pick", "Solar powered. Works best at noon.", Id = "SolarSifter"},
			{"Sandstorm Pickaxe", "Legendary. Spins up a sandstorm on every swing.", Id = "SandstormDrill"},
			{"Sun King Pickaxe", "Mythic. Blazes like a second sun.", Id = "SunKingShovel"},
		},
	},
	-----------------------------------------------------------------
	{
		Name = "Coral Circuit", Theme = "Coral", Price = 30e9,
		Tagline = "A bubbly reef of coral, shells and glowing jellies.",
		Top = "Sand", Wall = "Rock",
		Zones = {"Brick", "Limestone", "Ice", "Pavement"},
		Look = {Main = rgb(255, 128, 150), Second = rgb(90, 220, 220), Dark = rgb(30, 80, 120), Glow = rgb(120, 240, 255), Accent = rgb(255, 230, 160)},
		Sky = {ClockTime = 15, Ambient = rgb(90, 120, 140), OutdoorAmbient = rgb(120, 160, 180), Tint = rgb(226, 250, 255),
			Fog = rgb(120, 210, 230), Decay = rgb(60, 140, 180), Density = 0.35, Clouds = 0.4,
			Brightness = 2.8, Exposure = 0.1, Latitude = 25, Offset = 0.3, Haze = 1.8, Glare = 0.2, Saturation = 0.18, Contrast = 0.06, Bloom = {0.35, 24, 1.9}, SunRays = {0.15, 0.35}},
		Shovels = {
			{"Seashell Pick", "Hold it to your ear: you hear dirt.", Id = "SeashellScoop"},
			{"Anchor Pickaxe", "Heavy. Very heavy. Digs straight down.", Id = "AnchorSpade"},
			{"Pearl Pickaxe", "A perfect pearl sits in the head.", Id = "PearlShovel"},
			{"Trident Pick", "Borrowed from a sea king. No returns.", Id = "TridentTrowel"},
			{"Kraken Claw", "Eight times the grip.", Id = "KrakenClaw"},
			{"Tidal Pickaxe", "Legendary. Moves dirt like a wave.", Id = "TidalExcavator"},
			{"Atlantis Pickaxe", "Mythic. Found at the bottom of a lost city.", Id = "AtlantisSpade"},
		},
	},
	-----------------------------------------------------------------
	{
		Name = "Candy Mainframe", Theme = "Candy", Price = 100e9,
		Tagline = "A sugar-coated server farm made of sweets.",
		Top = "Salt", Wall = "Rock",
		Zones = {"LeafyGrass", "Sand", "Mud", "Ice"},
		Look = {Main = rgb(255, 120, 190), Second = rgb(130, 236, 200), Dark = rgb(120, 70, 60), Glow = rgb(255, 170, 230), Accent = rgb(255, 226, 110)},
		Sky = {ClockTime = 14, Ambient = rgb(130, 110, 130), OutdoorAmbient = rgb(175, 150, 175), Tint = rgb(255, 238, 248),
			Fog = rgb(255, 214, 240), Decay = rgb(220, 160, 210), Density = 0.32, Clouds = 0.6,
			Brightness = 3, Exposure = 0.05, Latitude = 35, Offset = 0.25, Haze = 1.2, Glare = 0.3, Saturation = 0.2, Contrast = 0.05, Bloom = {0.3, 24, 2}, SunRays = {0.08, 0.25}},
		Shovels = {
			{"Lollipop Pick", "Swirly, sticky and surprisingly strong.", Id = "LollipopScoop"},
			{"Candy Cane Pickaxe", "Minty fresh digging.", Id = "CandyCaneSpade"},
			{"Gummy Pickaxe", "Bends a lot. Never breaks.", Id = "GummyShovel"},
			{"Sprinkle Pick", "Leaves sprinkles in every hole.", Id = "SprinkleSpade"},
			{"Choco Crusher", "Solid chocolate. Please don't eat it.", Id = "ChocoCrusher"},
			{"Jawbreaker Pickaxe", "Legendary. Harder than any rock.", Id = "JawbreakerAuger"},
			{"Sugar Rush Pickaxe", "Mythic. Digs at 1000% speed. Crashes later.", Id = "SugarRushSpade"},
		},
	},
	-----------------------------------------------------------------
	{
		Name = "Volcano Forge", Theme = "Forge", Price = 500e9,
		Tagline = "Lava rivers, obsidian and a giant meme forge.",
		Top = "Basalt", Wall = "Rock",
		Zones = {"Ground", "Brick", "Asphalt", "CrackedLava"},
		Look = {Main = rgb(255, 120, 50), Second = rgb(60, 52, 70), Dark = rgb(34, 28, 40), Glow = rgb(255, 150, 60), Accent = rgb(255, 214, 90)},
		Sky = {ClockTime = 18.6, Ambient = rgb(120, 86, 80), OutdoorAmbient = rgb(150, 105, 95), Tint = rgb(255, 232, 220),
			Fog = rgb(200, 110, 80), Decay = rgb(120, 60, 50), Density = 0.35, Clouds = 0.5,
			Brightness = 2.2, Exposure = 0.2, Latitude = 40, Offset = 0.2, Haze = 2.4, Glare = 1.2, Saturation = 0.1, Contrast = 0.18, Bloom = {0.5, 28, 1.6}, SunRays = {0.2, 0.3}},
		Shovels = {
			{"Ember Pick", "Always a little bit warm.", Id = "EmberSpade"},
			{"Anvil Pickaxe", "Forged on an anvil. Kind of shaped like one too.", Id = "AnvilShovel"},
			{"Magma Pick", "Chews through lava like soup.", Id = "MagmaScoop"},
			{"Obsidian Pickaxe", "Glassy black and razor sharp.", Id = "ObsidianBlade"},
			{"Dragonbone Pickaxe", "Made from a dragon's lost tooth.", Id = "DragonboneSpade"},
			{"Inferno Pickaxe", "Legendary. Melts straight through rock.", Id = "InfernoAuger"},
			{"Core Breaker", "Mythic. Forged in the heart of the volcano.", Id = "CoreBreaker"},
		},
	},
	-----------------------------------------------------------------
	{
		Name = "Glitch Nexus", Theme = "Glitch", Price = 2.5e12,
		Tagline = "The edge of the simulation. Things don't load right here.",
		Top = "Concrete", Wall = "Rock",
		Zones = {"Cobblestone", "Asphalt", "Limestone", "Snow"},
		Look = {Main = rgb(90, 255, 150), Second = rgb(255, 80, 220), Dark = rgb(20, 18, 30), Glow = rgb(90, 255, 170), Accent = rgb(90, 200, 255)},
		Sky = {ClockTime = 21.5, Ambient = rgb(100, 120, 120), OutdoorAmbient = rgb(125, 150, 150), Tint = rgb(236, 255, 244),
			Fog = rgb(40, 60, 70), Decay = rgb(90, 40, 110), Density = 0.32, Clouds = 0,
			Brightness = 1.4, Exposure = 0.3, Latitude = 0, Offset = 0.25, Haze = 0.8, Glare = 0, Saturation = 0.25, Contrast = 0.2, Bloom = {0.6, 30, 1.3}, SunRays = {0, 0.1}},
		Shovels = {
			{"Placeholder Pickaxe", "TODO: add a description.", Id = "PlaceholderSpade"},
			{"Pixel Pickaxe", "Rendered at 8 pixels. Works anyway.", Id = "PixelShovel"},
			{"Lag Pick", "Hits the ground a second after you swing.", Id = "LagSpade"},
			{"Wireframe Pickaxe", "The texture never loaded.", Id = "WireframeShovel"},
			{"Error 404 Pick", "Pick not found. Digging anyway.", Id = "Error404Scoop"},
			{"Debug Pickaxe", "Legendary. Has admin commands built in.", Id = "DebugDrill"},
			{"The Final Patch", "Mythic. Fixes the simulation, one hole at a time.", Id = "TheFinalPatch"},
		},
	},
}

return WorldsData
]=])
install(game:GetService("ServerScriptService"), "AlienPortal", "ModuleScript", [=[
-- AlienPortal (ModuleScript in ServerScriptService)
-- A green, swirly "Rick and Morty" style portal that pops open out of thin air, stands on
-- the ground for a moment while aliens step through, then snaps shut.
-- It's a tall glowing oval: a lime rim, a bright jelly-green middle, a pale glowing core and
-- a swirling force-field skin, with green sparks, dripping goo, a splash ring on the ground
-- and a green light. It wobbles like jelly while it's open.
-- Once the Blender pieces are imported (PortalMeshes) it's a lumpy rim of goo with drips
-- hanging off it, around a deep rippled glassy tunnel with glowing spiral arms spinning into it.
--
--   local portal = AlienPortal.open(parent, cframe)  -- cframe on the ground, -Z = the side aliens come out of
--   AlienPortal.close(portal)                        -- shrinks it away and destroys it
--   AlienPortal.Size                                 -- how much room it needs (for picking a spot)
-- Markers in the model: "Core" (in the middle of the oval, at standing height) and "Front"
-- (on the ground a few studs in front of it).

local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PortalMeshes = require(ReplicatedStorage:WaitForChild("PortalMeshes"))

local rgb = Color3.fromRGB
local AlienPortal = {}

local HEIGHT, WIDTH = 9.5, 6.6
local CENTER_Y = HEIGHT / 2 + 0.3
AlienPortal.Size = Vector3.new(WIDTH + 2, HEIGHT + 1, 4)

-- {name, size multiplier (x, y), thickness, color, material, transparency}
local LAYERS = {
	{"PortalRim", 1, 0.3, rgb(140, 255, 60), Enum.Material.Neon, 0},
	{"PortalJelly", 0.88, 0.42, rgb(40, 170, 40), Enum.Material.Neon, 0},
	{"PortalSwirl", 0.86, 0.5, rgb(120, 255, 80), Enum.Material.ForceField, 0},
	{"PortalCore", 0.34, 0.62, rgb(235, 255, 205), Enum.Material.Neon, 0.1},
}

-- the Blender pieces: {name, properties}
local MESH_PIECES = {
	{"AlienPortalFunnel", {Material = Enum.Material.Glass, Color = rgb(60, 190, 50), Transparency = 0.12, Reflectance = 0.08}},
	{"AlienPortalRim", {Material = Enum.Material.Neon, Color = rgb(140, 255, 60)}},
	{"AlienPortalSwirl", {Material = Enum.Material.Neon, Color = rgb(215, 255, 170), Transparency = 0.1}},
}
local CLOSED = 0.03 -- how small the pieces start and end

local function part(parent, name, size, cf, color, material, transparency)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material
	p.Transparency = transparency or 0
	p.Parent = parent
	return p
end

local function oval(parent, name, size, cf, color, material, transparency)
	local p = part(parent, name, size, cf, color, material, transparency)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Scale = Vector3.new(0.02, 0.02, 1) -- starts closed
	mesh.Parent = p
	return p, mesh
end

local function emitter(parent, props)
	local e = Instance.new("ParticleEmitter")
	for k, v in pairs(props) do e[k] = v end
	e.Parent = parent
	return e
end

function AlienPortal.open(parent, cf)
	local portal = Instance.new("Model")
	portal.Name = "AlienPortal"
	portal:SetAttribute("NoCalm", true)
	local center = cf * CFrame.new(0, CENTER_Y, 0)
	local meshes, grow = {}, {} -- sphere meshes that pop open, Blender pieces that grow {Part, Size}
	local useMeshes = PortalMeshes.has("AlienPortalRim", "AlienPortalFunnel", "AlienPortalSwirl")
	if useMeshes then
		for _, piece in ipairs(MESH_PIECES) do
			local data = PortalMeshes.Data[piece[1]]
			local p = PortalMeshes.place(portal, piece[1], center, piece[2], CLOSED)
			p.CFrame = center * CFrame.new(data.Center)
			table.insert(grow, {Part = p, Size = data.Size})
		end
		-- a pale glow deep in the tunnel
		local _, mesh = oval(portal, "PortalCore", Vector3.new(1.7, 2.4, 0.3), center * CFrame.new(0, 0, 1.05), rgb(235, 255, 205), Enum.Material.Neon, 0.1)
		table.insert(meshes, mesh)
		-- the spiral arms spin into the tunnel on every player's screen (ShovelSpinner)
		local swirl = portal:FindFirstChild("AlienPortalSwirl")
		swirl:SetAttribute("OrbitPivot", center)
		swirl:SetAttribute("OrbitOffset", center:ToObjectSpace(swirl.CFrame))
		swirl:SetAttribute("OrbitSpeed", -2.6)
		CollectionService:AddTag(swirl, "ShovelOrbit")
	else
		for i, layer in ipairs(LAYERS) do
			local size = Vector3.new(WIDTH * layer[2], HEIGHT * layer[2], layer[3])
			-- layers stack front to back a little so they don't flicker into each other
			local _, mesh = oval(portal, layer[1], size, center * CFrame.new(0, 0, (i - 2.5) * 0.04), layer[4], layer[5], layer[6])
			table.insert(meshes, mesh)
		end
	end
	local core = portal:FindFirstChild("PortalCore")
	local rim = portal:FindFirstChild("PortalRim") or portal:FindFirstChild("AlienPortalRim")

	-- green light spilling out onto the ground
	local light = Instance.new("PointLight")
	light.Color = rgb(120, 255, 80)
	light.Range = 18
	light.Brightness = 0
	light.Parent = core

	-- swirling sparks pouring out of the front, and goo dripping off the rim
	emitter(core, {
		Name = "PortalSparks", Color = ColorSequence.new(rgb(210, 255, 170), rgb(90, 230, 50)), LightEmission = 1,
		Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.45), NumberSequenceKeypoint.new(1, 0)}),
		Transparency = NumberSequence.new(0, 1), Lifetime = NumberRange.new(0.6, 1.1), Rate = 40,
		Speed = NumberRange.new(2, 5), SpreadAngle = Vector2.new(35, 35), RotSpeed = NumberRange.new(-360, 360),
		EmissionDirection = Enum.NormalId.Front, Drag = 2,
	})
	emitter(rim, {
		Name = "PortalGoo", Color = ColorSequence.new(rgb(120, 240, 60)), LightEmission = 0.6,
		Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0.1)}),
		Transparency = NumberSequence.new(0.1, 0.8), Lifetime = NumberRange.new(0.6, 1), Rate = 14,
		Speed = NumberRange.new(0, 1), SpreadAngle = Vector2.new(180, 180), Acceleration = Vector3.new(0, -30, 0),
		Shape = Enum.ParticleEmitterShape.Box,
	})

	-- a splash of green light on the ground under it
	local splash = part(portal, "PortalSplash", Vector3.new(0.12, 1, 1), cf * CFrame.new(0, 0.1, -0.5) * CFrame.Angles(0, 0, math.rad(90)),
		rgb(120, 255, 80), Enum.Material.Neon, 0.5)
	splash.Shape = Enum.PartType.Cylinder

	-- markers for VisitorManager
	local coreMarker = part(portal, "Core", Vector3.new(1, 1, 1), cf * CFrame.new(0, 3, 0), Color3.new(), Enum.Material.SmoothPlastic, 1)
	coreMarker.Name = "Core"
	part(portal, "Front", Vector3.new(1, 1, 1), cf * CFrame.new(0, 3, -6), Color3.new(), Enum.Material.SmoothPlastic, 1)
	portal.Parent = parent

	-- POP OPEN: a burst of sparks, then the oval springs out with an overshoot
	local burst = emitter(core, {
		Enabled = false, Color = ColorSequence.new(rgb(230, 255, 200), rgb(100, 240, 60)), LightEmission = 1,
		Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(1, 0)}),
		Transparency = NumberSequence.new(0, 1), Lifetime = NumberRange.new(0.4, 0.8),
		Speed = NumberRange.new(10, 22), SpreadAngle = Vector2.new(180, 180), Drag = 4,
	})
	burst:Emit(70)
	local pop = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	for _, mesh in ipairs(meshes) do
		TweenService:Create(mesh, pop, {Scale = Vector3.new(1, 1, 1)}):Play()
	end
	for _, item in ipairs(grow) do
		TweenService:Create(item.Part, pop, {Size = item.Size}):Play()
	end
	TweenService:Create(light, TweenInfo.new(0.3), {Brightness = 3}):Play()
	TweenService:Create(splash, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Size = Vector3.new(0.12, 9, 9), Transparency = 0.7}):Play()
	-- then wobble like jelly while it's open, with a glowing spiral spinning inside
	task.delay(0.5, function()
		if not portal.Parent or portal:GetAttribute("Closing") then return end
		local wobble = TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		if useMeshes then
			for i, item in ipairs(grow) do
				local k = i % 2 == 0 and 1 or -1
				TweenService:Create(item.Part, wobble, {Size = item.Size * Vector3.new(1 + 0.04 * k, 1 - 0.03 * k, 1)}):Play()
			end
			TweenService:Create(core, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.5}):Play()
			return
		end
		local spiral = Instance.new("Model")
		spiral.Name = "Spiral"
		for arm = 0, 2 do
			for i = 1, 24 do
				local t = i / 24
				local a = arm * math.pi * 2 / 3 + t * math.pi * 1.8
				local r = 0.35 + t * 2.55
				local dot = part(spiral, "SpiralDot", Vector3.one * (0.62 - t * 0.3),
					center * CFrame.new(math.cos(a) * r, math.sin(a) * r, -0.36), rgb(200, 255, 150):Lerp(rgb(60, 200, 40), t), Enum.Material.Neon, 0.05)
				dot.Shape = Enum.PartType.Ball
				-- spun on every player's screen by ShovelSpinner
				dot:SetAttribute("OrbitPivot", center)
				dot:SetAttribute("OrbitOffset", center:ToObjectSpace(dot.CFrame))
				dot:SetAttribute("OrbitSpeed", -3.2)
				CollectionService:AddTag(dot, "ShovelOrbit")
			end
		end
		spiral.Parent = portal
		for i, mesh in ipairs(meshes) do
			local k = i % 2 == 0 and 1 or -1
			TweenService:Create(mesh, wobble, {Scale = Vector3.new(1 + 0.05 * k, 1 - 0.04 * k, 1)}):Play()
		end
		local core2 = portal:FindFirstChild("PortalCore")
		if core2 then
			TweenService:Create(core2, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.45}):Play()
		end
	end)
	return portal
end

function AlienPortal.close(portal)
	if not portal or not portal.Parent or portal:GetAttribute("Closing") then return end
	portal:SetAttribute("Closing", true)
	local spiral = portal:FindFirstChild("Spiral")
	if spiral then spiral:Destroy() end
	local shut = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	for _, d in ipairs(portal:GetDescendants()) do
		if d:IsA("SpecialMesh") then
			TweenService:Create(d, shut, {Scale = Vector3.new(0.02, 0.02, 1)}):Play()
		elseif d:IsA("MeshPart") then
			TweenService:Create(d, shut, {Size = d.Size * CLOSED}):Play()
		elseif d:IsA("ParticleEmitter") then
			d.Enabled = false
		elseif d:IsA("PointLight") then
			TweenService:Create(d, shut, {Brightness = 0}):Play()
		end
	end
	local splash = portal:FindFirstChild("PortalSplash")
	if splash then TweenService:Create(splash, shut, {Size = Vector3.new(0.12, 0.5, 0.5), Transparency = 1}):Play() end
	Debris:AddItem(portal, 0.8)
end

return AlienPortal
]=])
install(game:GetService("ServerScriptService"), "Architecture", "ModuleScript", [=[
-- Architecture (ModuleScript in ServerScriptService)
-- Shared building kit for the cartoony 2050 look: chunky rounded shapes (discs, capsules,
-- domes, rings, arches, rounded blocks), a bright soft palette (white, lilac, sky, mint,
-- sunshine) and gentle pastel glow trims.
-- ShopBuilder, WorldGate, MuseumBuilder and MainIsland all build with this.

local Architecture = {}

---------------------------------------------------------------------
-- PALETTE
---------------------------------------------------------------------
local rgb = Color3.fromRGB
local PLASTIC = Enum.Material.SmoothPlastic
Architecture.Palette = {
	White    = {Color = rgb(246, 247, 252), Material = PLASTIC},
	Cloud    = {Color = rgb(222, 227, 242), Material = PLASTIC},
	Lilac    = {Color = rgb(178, 158, 255), Material = PLASTIC},
	Violet   = {Color = rgb(122, 92, 232),  Material = PLASTIC},
	Sky      = {Color = rgb(92, 186, 255),  Material = PLASTIC},
	Mint     = {Color = rgb(96, 226, 190),  Material = PLASTIC},
	Sun      = {Color = rgb(255, 206, 84),  Material = PLASTIC},
	Coral    = {Color = rgb(255, 122, 138), Material = PLASTIC},
	Navy     = {Color = rgb(52, 56, 118),   Material = PLASTIC},
	Ink      = {Color = rgb(34, 36, 74),    Material = PLASTIC},
	Chrome   = {Color = rgb(214, 220, 232), Material = Enum.Material.Metal, Reflectance = 0.2},
	Glass    = {Color = rgb(168, 228, 255), Material = Enum.Material.Glass, Transparency = 0.45, Reflectance = 0.15},
	GlowCyan = {Color = rgb(96, 196, 222),  Material = Enum.Material.Neon},
	GlowPink = {Color = rgb(214, 118, 188), Material = Enum.Material.Neon},
	GlowSun  = {Color = rgb(222, 186, 96),  Material = Enum.Material.Neon},
	GlowMint = {Color = rgb(96, 206, 168),  Material = Enum.Material.Neon},
	Portal   = {Color = rgb(170, 130, 255), Material = Enum.Material.ForceField},
}
Architecture.TextColor = rgb(255, 255, 255)
Architecture.TitleColor = rgb(255, 222, 110)
Architecture.AccentText = rgb(150, 230, 255)
Architecture.LightColor = rgb(225, 240, 255)

local UPRIGHT = CFrame.Angles(0, 0, math.rad(90)) -- turns a cylinder (X axis) to stand up (Y axis)

-- A CFrame at `position` whose X axis points along `direction` (for rods and capsules)
function Architecture.alongX(position, direction)
	local x = direction.Unit
	local helper = math.abs(x.Y) > 0.95 and Vector3.zAxis or Vector3.yAxis
	local z = x:Cross(helper).Unit
	local y = z:Cross(x)
	return CFrame.fromMatrix(position, x, y, z)
end

---------------------------------------------------------------------
-- BUILDER: every position is relative to `base` (a CFrame)
---------------------------------------------------------------------
local Builder = {}
Builder.__index = Builder

function Architecture.builder(parent, base)
	return setmetatable({Parent = parent, Base = base}, Builder)
end

-- A plain anchored part. `finish` is a palette name (see above).
function Builder:box(name, size, offset, finish, props)
	local f = Architecture.Palette[finish] or Architecture.Palette.White
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.CFrame = self.Base * offset
	p.Color = f.Color
	p.Material = f.Material
	p.Transparency = f.Transparency or 0
	p.Reflectance = f.Reflectance or 0
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if f.Transparency or f.Material == Enum.Material.Neon then
		p.CastShadow = false
	end
	if props then
		for key, value in pairs(props) do
			p[key] = value
		end
	end
	p.Parent = self.Parent
	return p
end

-- Flat round disc / short cylinder standing upright, centered at `offset`.
function Builder:disc(name, diameter, height, offset, finish, props)
	local p = self:box(name, Vector3.new(height, diameter, diameter), offset * UPRIGHT, finish, props)
	p.Shape = Enum.PartType.Cylinder
	return p
end

-- Cylinder lying along the local X axis of `offset`.
function Builder:rod(name, length, diameter, offset, finish, props)
	local p = self:box(name, Vector3.new(length, diameter, diameter), offset, finish, props)
	p.Shape = Enum.PartType.Cylinder
	return p
end

function Builder:ball(name, diameter, offset, finish, props)
	local p = self:box(name, Vector3.new(diameter, diameter, diameter), offset, finish, props)
	p.Shape = Enum.PartType.Ball
	return p
end

-- Squashed/stretched sphere (domes, saucers, blobs). `size` is the full ellipsoid size.
function Builder:ellipsoid(name, size, offset, finish, props)
	local p = self:box(name, size, offset, finish, props)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = p
	return p
end

-- Capsule from point a to point b: a rod with a ball on each end.
function Builder:pill(name, a, b, diameter, finish)
	local length = (b - a).Magnitude
	self:rod(name, length, diameter, Architecture.alongX((a + b) / 2, b - a), finish)
	self:ball(name .. "CapA", diameter, CFrame.new(a), finish)
	self:ball(name .. "CapB", diameter, CFrame.new(b), finish)
end

-- A block with rounded vertical edges (size = full outer size, radius = corner radius).
function Builder:roundedBlock(name, size, offset, radius, finish)
	radius = math.min(radius, size.X / 2, size.Z / 2)
	local core = self:box(name, Vector3.new(size.X - radius * 2, size.Y, size.Z), offset, finish)
	self:box(name .. "Side", Vector3.new(size.X, size.Y, size.Z - radius * 2), offset, finish)
	for _, sx in ipairs({-1, 1}) do
		for _, sz in ipairs({-1, 1}) do
			self:disc(name .. "Corner", radius * 2, size.Y,
				offset * CFrame.new(sx * (size.X / 2 - radius), 0, sz * (size.Z / 2 - radius)), finish)
		end
	end
	return core
end

-- A ring (torus) made of short rods. `cf` is the ring's center; the ring lies in the
-- XY plane of `cf` (so it faces along Z, like a doorway). Use `arc` < 360 for an arch.
function Builder:ring(name, cf, radius, thickness, finish, segments, arc, startAngle)
	segments = segments or 28
	arc = arc or 360
	startAngle = startAngle or 0
	local step = arc / segments
	local segLength = 2 * radius * math.sin(math.rad(step / 2)) + thickness * 0.35
	for i = 0, segments - 1 do
		local a = math.rad(startAngle + step * (i + 0.5))
		local point = Vector3.new(math.cos(a) * radius, math.sin(a) * radius, 0)
		-- the rod runs along the circle's tangent
		local rodCF = cf * CFrame.new(point) * CFrame.Angles(0, 0, a + math.pi / 2)
		self:rod(name, segLength, thickness, rodCF, finish)
	end
	if arc < 360 then
		for _, a in ipairs({startAngle, startAngle + arc}) do
			local r = math.rad(a)
			self:ball(name .. "End", thickness, cf * CFrame.new(math.cos(r) * radius, math.sin(r) * radius, 0), finish)
		end
	end
end

-- Stacked discs that shrink as they go up (a staggered round platform).
-- tiers = {{diameter, height, finish}, ...}, bottom first. Returns the top part and the total height.
function Builder:tiers(name, cf, list)
	local y = 0
	local top
	for i, tier in ipairs(list) do
		top = self:disc(name .. "Tier" .. i, tier[1], tier[2], cf * CFrame.new(0, y + tier[2] / 2, 0), tier[3])
		y += tier[2]
	end
	return top, y
end

-- A soft glowing light bulb (small neon ball with a light).
function Builder:bulb(name, diameter, offset, finish, range)
	local p = self:ball(name, diameter, offset, finish or "GlowCyan")
	local light = Instance.new("PointLight")
	light.Color = p.Color
	light.Range = range or 10
	light.Brightness = 0.8
	light.Parent = p
	return p
end

-- Tones down glow under `root` so the game isn't overwhelming. Safe to run more than once:
--   * big glowing panels (Neon wider than a strip) become plain colored plastic
--   * small Neon accents are capped in brightness
--   * lights are capped in brightness and range
Architecture.MAX_NEON = 0.78    -- brightest channel a Neon part may have (0-1)
Architecture.MAX_LIGHT = 0.8     -- brightest a PointLight/SpotLight/SurfaceLight may be
Architecture.MAX_LIGHT_RANGE = 16
function Architecture.calm(root)
	local list = root:GetDescendants()
	table.insert(list, root)
	for _, d in ipairs(list) do
		if d:IsA("BasePart") and d.Material == Enum.Material.Neon and not d:GetAttribute("KeepGlow") then
			local s = d.Size
			local dims = {s.X, s.Y, s.Z}
			table.sort(dims)
			if dims[2] > 2.5 then
				d.Material = Enum.Material.SmoothPlastic
			else
				local c = d.Color
				local m = math.max(c.R, c.G, c.B)
				if m > Architecture.MAX_NEON then
					local k = Architecture.MAX_NEON / m
					d.Color = Color3.new(c.R * k, c.G * k, c.B * k)
				end
			end
		elseif d:IsA("Light") then
			d.Brightness = math.min(d.Brightness, Architecture.MAX_LIGHT)
			if d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight") then
				d.Range = math.min(d.Range, Architecture.MAX_LIGHT_RANGE)
			end
		end
	end
end

-- Big friendly sign text on a part's face.
function Architecture.sign(part, title, subtitle, face, titleColor)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face or Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0
	gui.Parent = part
	local function line(text, color, y, h, font)
		local l = Instance.new("TextLabel")
		l.BackgroundTransparency = 1
		l.Position = UDim2.fromScale(0.05, y)
		l.Size = UDim2.fromScale(0.9, h)
		l.Text = text
		l.TextColor3 = color
		l.Font = font
		l.TextScaled = true
		l.Parent = gui
		local s = Instance.new("UIStroke")
		s.Thickness = 3
		s.Color = Color3.fromRGB(30, 26, 70)
		s.Parent = l
		return l
	end
	line(title, titleColor or Architecture.TitleColor, subtitle and 0.06 or 0.12, subtitle and 0.58 or 0.76, Enum.Font.FredokaOne)
	if subtitle then
		line(subtitle, Architecture.AccentText, 0.66, 0.28, Enum.Font.FredokaOne)
	end
	return gui
end

return Architecture
]=])
install(game:GetService("ServerScriptService"), "BuriedPainting", "ModuleScript", [=[
-- BuriedPainting (ModuleScript in ServerScriptService)
-- A dug-up find in the crater: the artifact's real 3D object (a meme sculpture, painting,
-- coin, stone tablet or crystal, see ArtifactModels) stuck half-way into a mound of dirt,
-- with crumbs of soil on it and a soft glow in its rarity color around the mound. No icons
-- or chests: what you see in the dirt is the meme itself. DigManager places it in the fresh
-- crater; its ProximityPrompt lets the finder pull it out (FindPullClient animates it).
--   * sculptures stand upright facing the finder, their lower part buried
--   * flat things (paintings, coins, tablets, crystals) lie tilted, half sunk into the soil
--
-- Model layout (for the animation): PrimaryPart "Core" is the center; the front faces the
-- Core's -Z; parts named "Dirt" are crumbs stuck to it (they fall off when it's pulled out);
-- parts named "Mound" / "Glow" belong to the ground around it (they fade away).
-- Attribute Sunk = how many studs of it are under the ground.
-- Usage: BuriedPainting(artifact, rarityColor, placement, rng) -> Model (not parented)
--   placement = {Floor = Vector3, Up = Vector3, ToPlayer = Vector3 (flat unit), DirtColor = Color3}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ArtifactModels = require(ReplicatedStorage:WaitForChild("ArtifactModels"))
local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))

local rgb = Color3.fromRGB

local function groundPart(model, name, size, cf, color, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.Ground
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Parent = model
	return p
end

local function lump(model, name, size, cf, color)
	local p = groundPart(model, name, size, cf, color)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = p
	return p
end

-- a frame at pos whose front (-Z) looks along look, with up as close to up as possible
local function facing(pos, look, up)
	local right = look:Cross(up).Unit
	return CFrame.fromMatrix(pos, right, right:Cross(look), -look)
end

return function(artifact, rarityColor, placement, rng)
	rng = rng or Random.new()
	local floor, up = placement.Floor, placement.Up or Vector3.yAxis
	local toPlayer = placement.ToPlayer or Vector3.zAxis
	local dirt = placement.DirtColor or rgb(122, 88, 60)
	local model = ArtifactModels.build(artifact)
	model.Name = "BuriedFind"
	local width = model:GetAttribute("Width") or 3
	local half = model:GetAttribute("HalfHeight") or 2
	local upright = model:GetAttribute("Form") == "Figure"

	-- where the object sits (in its own space, before it's moved to the crater)
	local cf, sunk
	if upright then
		-- standing, facing the finder, leaning back a little, the bottom quarter under the dirt
		sunk = half * 2 * 0.25
		local look = (toPlayer - up * toPlayer:Dot(up))
		look = look.Magnitude > 0.01 and look.Unit or Vector3.zAxis
		cf = facing(floor + up * (half - sunk), look, up) * CFrame.Angles(math.rad(12), 0, 0)
	else
		-- lying face up, its top edge pointing away from the finder, tipped toward them
		local away = -toPlayer
		local yAxis = (away - up * away:Dot(up))
		yAxis = yAxis.Magnitude > 0.01 and yAxis.Unit or Vector3.xAxis
		local zAxis = -up
		local xAxis = yAxis:Cross(zAxis)
		cf = CFrame.fromMatrix(floor + up * 0.05, xAxis, yAxis, zAxis) * CFrame.Angles(math.rad(-16), 0, 0)
		sunk = 0.5
	end

	-- crumbs of soil stuck to its front
	for i = 1, 7 do
		local x = rng:NextNumber(-width / 2 + 0.3, width / 2 - 0.3)
		local y = rng:NextNumber(-half + 0.3, upright and 0 or half - 0.3)
		groundPart(model, "Dirt", Vector3.new(rng:NextNumber(0.3, 0.6), rng:NextNumber(0.22, 0.4), 0.16),
			CFrame.new(x, y, -0.5 - (i % 3) * 0.1) * CFrame.Angles(rng:NextNumber(-0.3, 0.3), rng:NextNumber(-0.3, 0.3), rng:NextNumber(0, 6)),
			dirt:Lerp(Color3.new(0, 0, 0), rng:NextNumber(0, 0.25)))
	end
	model:PivotTo(cf)

	-- the dirt mound it's stuck in: lumps of soil in a ring around where it enters the ground
	local flat = toPlayer - up * toPlayer:Dot(up)
	local ground = facing(floor, flat.Magnitude > 0.01 and flat.Unit or Vector3.zAxis, up)
	local ring = math.max(width * 0.55, 1.3)
	local count = 9
	for i = 1, count do
		local a = (i / count) * math.pi * 2 + rng:NextNumber(-0.2, 0.2)
		local r = ring * rng:NextNumber(0.75, 1.05)
		local size = rng:NextNumber(0.9, 1.5)
		lump(model, "Mound", Vector3.new(size * 1.3, size * 0.55, size),
			ground * CFrame.new(math.cos(a) * r, size * 0.05, math.sin(a) * r * 0.8) * CFrame.Angles(0, rng:NextNumber(0, 6), 0),
			dirt:Lerp(Color3.new(0, 0, 0), rng:NextNumber(0.05, 0.3)))
	end

	-- a soft glow in the rarity's color seeping out of the soil
	local glow = groundPart(model, "Glow", Vector3.new(0.12, ring * 3, ring * 3), ground * CFrame.new(0, 0.08, 0) * CFrame.Angles(0, 0, math.rad(90)),
		rarityColor, Enum.Material.Neon)
	glow.Shape = Enum.PartType.Cylinder
	glow.Transparency = 0.72
	local light = Instance.new("PointLight")
	light.Color = rarityColor
	light.Range = 10
	light.Brightness = 1.4
	light.Parent = model.PrimaryPart
	local motes = Instance.new("ParticleEmitter")
	motes.Name = "GlowMotes"
	motes.Color = ColorSequence.new(rarityColor)
	motes.LightEmission = 0.9
	motes.Size = NumberSequence.new(0.22, 0)
	motes.Transparency = NumberSequence.new(0.2, 1)
	motes.Lifetime = NumberRange.new(1, 1.8)
	motes.Speed = NumberRange.new(1, 2.5)
	motes.SpreadAngle = Vector2.new(25, 25)
	motes.Rate = 3 + math.min(ArtifactData.GetRarityIndex(artifact.Rarity), 9) * 1.5
	motes.EmissionDirection = Enum.NormalId.Right -- the disc's X points up
	motes.Parent = glow

	model:SetAttribute("Sunk", sunk)
	model:SetAttribute("Upright", upright)
	return model
end
]=])
install(game:GetService("ServerScriptService"), "CityBuilder", "ModuleScript", [=[
-- CityBuilder (ModuleScript in ServerScriptService)
-- Rebuilds the city skyline in the cartoony 2050 style. It reads where every old tower
-- stood (its podium) and how tall it was, removes it, and builds a new rounded tower in
-- the same spot. It also recolors the streets, the edge wall and the ground, and swaps the
-- old sky bridges for glass tube bridges. MapStyle calls this once on server start.

local Architecture = require(script.Parent:WaitForChild("Architecture"))
local P = Architecture.Palette

local CityBuilder = {}

local BODIES = {"White", "Cloud", "White"}
local ACCENTS = {"Lilac", "Sky", "Mint", "Sun", "Coral", "Violet"}
local GLOWS = {"GlowCyan", "GlowPink", "GlowSun", "GlowMint"}

---------------------------------------------------------------------
-- COLOR HELPERS
---------------------------------------------------------------------
local function apply(part, finish)
	local f = P[finish]
	part.Color = f.Color
	part.Material = f.Material
	part.Transparency = f.Transparency or 0
	part.Reflectance = f.Reflectance or 0
end

-- Turns any gritty part into a smooth, soft-colored cartoon part
function CityBuilder.cartoonify(part)
	local c = part.Color
	local lum = 0.299 * c.R + 0.587 * c.G + 0.114 * c.B
	local sat = math.max(c.R, c.G, c.B) - math.min(c.R, c.G, c.B)
	if part.Material == Enum.Material.Neon then
		part.Color = c:Lerp(Color3.new(1, 1, 1), 0.25)
		return
	elseif part.Material == Enum.Material.Glass or part.Material == Enum.Material.ForceField or part.Transparency >= 0.99 then
		return
	end
	part.Material = Enum.Material.SmoothPlastic
	part.Reflectance = 0
	if sat > 0.25 then
		part.Color = c:Lerp(Color3.new(1, 1, 1), 0.15) -- keep real colors, just softer
	elseif lum < 0.22 then
		part.Color = P.Navy.Color
	elseif lum < 0.55 then
		part.Color = P.Lilac.Color:Lerp(P.Cloud.Color, 0.45)
	else
		part.Color = P.White.Color
	end
end

---------------------------------------------------------------------
-- TOWER STYLES. `b` is a builder at the tower's footprint (ground = y 0),
-- w = tower width, h = total height, rng = this tower's random generator.
---------------------------------------------------------------------
local function pick(rng, list)
	return list[rng:NextInteger(1, #list)]
end

local function antenna(b, y, rng, glow)
	local length = rng:NextNumber(6, 12)
	b:pill("Antenna", Vector3.new(0, y, 0), Vector3.new(0, y + length, 0), 0.8, "Chrome")
	b:bulb("AntennaTip", 1.8, CFrame.new(0, y + length + 1, 0), glow, 30)
end

-- A: stacked rounded tiers that step in as they rise, with window bands and a dome
local function stackTower(b, w, h, rng, body, accent, glow)
	local tiers = math.clamp(math.floor(h / 45) + 2, 2, 6)
	local y = 10
	local tierH = (h - 10 - w * 0.25) / tiers
	for i = 1, tiers do
		local size = w * (1 - (i - 1) * 0.12)
		b:roundedBlock("Tier", Vector3.new(size, tierH, size), CFrame.new(0, y + tierH / 2, 0), size * 0.28, i % 2 == 1 and body or accent)
		-- two glowing window bands per tier
		for _, f in ipairs({0.35, 0.72}) do
			b:roundedBlock("WindowBand", Vector3.new(size + 0.5, 1.6, size + 0.5), CFrame.new(0, y + tierH * f, 0), size * 0.3, "Glass")
		end
		b:roundedBlock("TierLip", Vector3.new(size + 1.6, 1.2, size + 1.6), CFrame.new(0, y + tierH, 0), size * 0.32, accent)
		y += tierH
	end
	local top = w * (1 - tiers * 0.12)
	b:ellipsoid("Dome", Vector3.new(top, w * 0.5, top), CFrame.new(0, y, 0), accent)
	antenna(b, y + w * 0.22, rng, glow)
end

-- B: a round tube with glass rings, a flying-saucer crown and a beacon
local function tubeTower(b, w, h, rng, body, accent, glow)
	local shaftH = h - 10 - 6
	b:disc("Shaft", w * 0.85, shaftH, CFrame.new(0, 10 + shaftH / 2, 0), body)
	local bands = math.floor(shaftH / 16)
	for i = 1, bands do
		local y = 10 + i * (shaftH / (bands + 1))
		b:disc("GlassRing", w * 0.85 + 0.6, 3, CFrame.new(0, y, 0), "Glass")
		if i % 2 == 0 then
			b:disc("ColorRing", w * 0.85 + 1.2, 1, CFrame.new(0, y + 2.4, 0), accent)
		end
	end
	local crown = 10 + shaftH
	b:ellipsoid("SaucerUnder", Vector3.new(w * 1.5, 4, w * 1.5), CFrame.new(0, crown, 0), accent)
	b:disc("SaucerRim", w * 1.55, 1.2, CFrame.new(0, crown + 0.6, 0), glow)
	b:ellipsoid("SaucerTop", Vector3.new(w * 1.4, 5, w * 1.4), CFrame.new(0, crown + 1.4, 0), body)
	b:ellipsoid("Bubble", Vector3.new(w * 0.6, w * 0.45, w * 0.6), CFrame.new(0, crown + 3, 0), "Glass")
	antenna(b, crown + 3 + w * 0.2, rng, glow)
end

-- C: twisting stack of rounded slabs (each floor turned a bit more)
local function twistTower(b, w, h, rng, body, accent, glow)
	local slabH = 14
	local count = math.floor((h - 12) / slabH)
	local twist = rng:NextNumber(5, 9) * (rng:NextNumber() < 0.5 and -1 or 1)
	for i = 0, count - 1 do
		local y = 10 + i * slabH
		local cf = CFrame.new(0, y + slabH / 2, 0) * CFrame.Angles(0, math.rad(twist * i), 0)
		b:box("Slab", Vector3.new(w * 0.8, slabH - 2.2, w * 0.8), cf, i % 3 == 0 and accent or body)
		b:box("SlabGlass", Vector3.new(w * 0.8 + 0.4, slabH - 6, w * 0.8 + 0.4), cf, "Glass")
		b:box("SlabLip", Vector3.new(w * 0.92, 2.2, w * 0.92), cf * CFrame.new(0, slabH / 2 - 1.1, 0), accent)
	end
	local topY = 10 + count * slabH
	b:ball("TopOrb", w * 0.55, CFrame.new(0, topY + w * 0.2, 0), accent)
	b:disc("TopOrbRing", w * 0.8, 0.8, CFrame.new(0, topY + w * 0.2, 0), glow)
	antenna(b, topY + w * 0.45, rng, glow)
end

-- D: slim core with big bubble pods sticking out at different heights
local function podTower(b, w, h, rng, body, accent, glow)
	local coreH = h - 10
	b:disc("Core", w * 0.55, coreH, CFrame.new(0, 10 + coreH / 2, 0), body)
	for i = 1, math.floor(coreH / 12) do
		b:disc("CoreGlass", w * 0.55 + 0.5, 1.6, CFrame.new(0, 10 + i * 12, 0), "Glass")
	end
	local pods = math.clamp(math.floor(coreH / 30), 2, 7)
	for i = 1, pods do
		local y = 10 + coreH * (i / (pods + 1))
		local a = math.rad(i * 137.5 + rng:NextNumber(0, 40))
		local out = w * 0.5
		local pos = Vector3.new(math.cos(a) * out, y, math.sin(a) * out)
		local size = w * rng:NextNumber(0.45, 0.6)
		b:ball("Pod", size, CFrame.new(pos), i % 2 == 0 and accent or body)
		b:ellipsoid("PodWindow", Vector3.new(size * 0.7, size * 0.35, size * 0.7), CFrame.new(pos + Vector3.new(0, size * 0.12, 0)), "Glass")
		b:disc("PodRing", size * 1.15, 0.7, CFrame.new(pos), glow)
	end
	b:ellipsoid("CoreCap", Vector3.new(w * 0.7, w * 0.4, w * 0.7), CFrame.new(0, 10 + coreH, 0), accent)
	antenna(b, 10 + coreH + w * 0.15, rng, glow)
end

local STYLES = {stackTower, tubeTower, twistTower, podTower}

---------------------------------------------------------------------
-- MEGATOWERS: the towering landmarks of the 2050 skyline (the 8 sturdiest tower spots).
-- Blended cartoony-realism: tinted Glass floors that twist as they rise (each floor is
-- turned a little more with CFrame.Angles), thin white floor plates, Neon corner ribs that
-- spiral up with the twist, cantilevered sky gardens, a stepped crown and a glowing spire.
---------------------------------------------------------------------
local MEGA_COUNT = 8
local MEGA_GLASS = {
	{Name = "MegaGlassSky", Color = Color3.fromRGB(120, 200, 255)},
	{Name = "MegaGlassLilac", Color = Color3.fromRGB(180, 160, 255)},
	{Name = "MegaGlassMint", Color = Color3.fromRGB(110, 235, 205)},
	{Name = "MegaGlassRose", Color = Color3.fromRGB(255, 160, 205)},
}
for _, g in ipairs(MEGA_GLASS) do
	P[g.Name] = {Color = g.Color, Material = Enum.Material.Glass, Transparency = 0.25, Reflectance = 0.25}
end
P.MegaSteel = {Color = Color3.fromRGB(236, 240, 248), Material = Enum.Material.Metal, Reflectance = 0.1}
local MEGA_NEON = {
	{Name = "MegaNeonCyan", Color = Color3.fromRGB(90, 220, 255)},
	{Name = "MegaNeonPink", Color = Color3.fromRGB(255, 110, 200)},
	{Name = "MegaNeonGold", Color = Color3.fromRGB(255, 205, 90)},
	{Name = "MegaNeonMint", Color = Color3.fromRGB(90, 255, 190)},
}
for _, g in ipairs(MEGA_NEON) do
	P[g.Name] = {Color = g.Color, Material = Enum.Material.Neon}
end

local function megaTower(b, w, h, rng)
	local glass = pick(rng, MEGA_GLASS).Name
	local neon = pick(rng, MEGA_NEON).Name
	local twistPerFloor = math.rad(rng:NextNumber(2.2, 3.6)) * (rng:NextNumber() < 0.5 and -1 or 1)
	local floorH = 12
	local podiumH = 14

	-- podium: two rounded steps with a glowing lip
	b:roundedBlock("MegaPodium", Vector3.new(w + 14, podiumH * 0.6, w + 14), CFrame.new(0, podiumH * 0.3, 0), 8, "MegaSteel")
	b:roundedBlock("MegaPodiumLip", Vector3.new(w + 15, 0.8, w + 15), CFrame.new(0, podiumH * 0.6, 0), 8.2, neon)
	b:roundedBlock("MegaLobby", Vector3.new(w + 6, podiumH * 0.4, w + 6), CFrame.new(0, podiumH * 0.8, 0), 6, glass)

	local floors = math.floor((h - podiumH - 40) / floorH)
	local prevCorners
	for i = 0, floors - 1 do
		local y = podiumH + i * floorH
		local t = i / math.max(floors - 1, 1)
		-- slim waist at 60% height, slight flare near the top (an elegant hourglass taper)
		local size = w * (1 - 0.28 * math.sin(t * math.pi * 0.85)) * (1 - 0.15 * t)
		local turn = CFrame.Angles(0, i * twistPerFloor, 0)
		local floorCF = CFrame.new(0, y + floorH / 2, 0) * turn
		-- (plain boxes keep the part count low: 2 parts per floor)
		b:box("MegaFloor", Vector3.new(size, floorH - 1, size), floorCF, glass)
		b:box("MegaPlate", Vector3.new(size + 1.4, 1, size + 1.4), CFrame.new(0, y, 0) * turn, "MegaSteel")

		-- corner ribs: every 2 floors a neon rod joins each corner to the same corner two floors
		-- up, which is turned further, so the ribs spiral around the tower
		local inset = size * 0.5
		local corners = {}
		for k = 0, 3 do
			local a = math.rad(45 + k * 90)
			corners[k + 1] = (CFrame.new(0, y, 0) * turn * CFrame.new(math.cos(a) * inset * 1.414 + math.cos(a) * 0.4, 0, math.sin(a) * inset * 1.414 + math.sin(a) * 0.4)).Position
		end
		if i % 3 == 0 then
			if prevCorners then
				for k = 1, 4 do
					local a, c = prevCorners[k], corners[k]
					b:rod("MegaRib", (c - a).Magnitude + 0.6, 0.9, Architecture.alongX((a + c) / 2, c - a), neon)
				end
			end
			prevCorners = corners
		end

		-- sky gardens at one third and two thirds of the height
		if i == math.floor(floors / 3) or i == math.floor(floors * 2 / 3) then
			local gardenCF = CFrame.new(0, y + 0.5, 0) * turn
			b:disc("SkyGarden", size * 1.5, 1.4, gardenCF, "MegaSteel")
			b:ring("SkyGardenRail", gardenCF * CFrame.new(0, 1.4, 0) * CFrame.Angles(math.rad(90), 0, 0), size * 0.75, 0.5, neon, 28)
			for k = 1, 6 do
				local a = math.pi * 2 * k / 6
				local spot = gardenCF * CFrame.new(math.cos(a) * size * 0.62, 0.7, math.sin(a) * size * 0.62)
				b:pill("GardenTrunk", spot.Position, (spot * CFrame.new(0, 3, 0)).Position, 0.6, "Chrome")
				b:ball("GardenTree", 3.4, spot * CFrame.new(0, 4.2, 0), k % 2 == 0 and "Mint" or "GlowMint")
			end
		end
	end

	-- crown: stepped discs, a halo ring and a spire with a beacon
	local topY = podiumH + floors * floorH
	local crownW = w * 0.6
	local _, crownH = b:tiers("MegaCrown", CFrame.new(0, topY, 0) * CFrame.Angles(0, floors * twistPerFloor, 0), {
		{crownW, 4, "MegaSteel"}, {crownW * 0.78, 3, glass}, {crownW * 0.55, 3, "MegaSteel"}, {crownW * 0.3, 6, glass},
	})
	b:ring("MegaHalo", CFrame.new(0, topY + crownH + 4, 0) * CFrame.Angles(math.rad(90), 0, 0), crownW * 0.5, 1, neon, 32)
	local spireTop = topY + crownH + 30
	b:pill("MegaSpire", Vector3.new(0, topY + crownH, 0), Vector3.new(0, spireTop, 0), 1.6, "Chrome")
	b:bulb("MegaBeacon", 3, CFrame.new(0, spireTop + 2, 0), neon, 40)
end


-- Podium + little park around every tower
local function base(b, w, rng, accent)
	b:disc("Park", w * 1.9, 0.4, CFrame.new(0, 0.2, 0), "Mint")
	b:disc("ParkEdge", w * 1.9 + 1.2, 0.3, CFrame.new(0, 0.15, 0), "White")
	b:roundedBlock("Podium", Vector3.new(w + 4, 10, w + 4), CFrame.new(0, 5, 0), (w + 4) * 0.3, "Cloud")
	b:roundedBlock("PodiumBand", Vector3.new(w + 4.6, 1.4, w + 4.6), CFrame.new(0, 8.4, 0), (w + 4.6) * 0.3, accent)
	b:roundedBlock("Lobby", Vector3.new(w * 0.6, 6, w + 4.3), CFrame.new(0, 3.2, 0), 1, "Glass")
	-- lollipop trees
	for i = 1, 3 do
		local a = math.rad(i * 120 + rng:NextNumber(-20, 20))
		local r = w * 0.8
		local pos = Vector3.new(math.cos(a) * r, 0, math.sin(a) * r)
		b:rod("TreeTrunk", 5, 0.8, CFrame.new(pos + Vector3.new(0, 2.5, 0)) * CFrame.Angles(0, 0, math.rad(90)), "White")
		b:ball("TreeTop", rng:NextNumber(4, 5.5), CFrame.new(pos + Vector3.new(0, 6.5, 0)), pick(rng, {"Mint", "Sun", "Coral", "Lilac"}))
	end
end

---------------------------------------------------------------------
-- REBUILD THE SKYLINE
---------------------------------------------------------------------
local function findTowers(towersFolder)
	local podiums = {}
	local parts = {}
	for _, d in ipairs(towersFolder:GetDescendants()) do
		if d:IsA("BasePart") then
			table.insert(parts, d)
			if d.Name == "Podium" then
				table.insert(podiums, {CFrame = d.CFrame, Size = d.Size, Top = 0})
			end
		end
	end
	-- each part belongs to the nearest podium; the tallest part sets the tower height
	for _, part in ipairs(parts) do
		local pos = part.CFrame.Position
		local best, bestD = nil, math.huge
		for _, pod in ipairs(podiums) do
			local pp = pod.CFrame.Position
			local d = (pp.X - pos.X) ^ 2 + (pp.Z - pos.Z) ^ 2
			if d < bestD then best, bestD = pod, d end
		end
		if best then
			best.Top = math.max(best.Top, pos.Y + part.Size.Y / 2)
		end
	end
	return podiums
end

function CityBuilder.rebuildTowers(city)
	local towers = city:FindFirstChild("Towers")
	if not towers or towers:GetAttribute("Cartoon2050") then return end
	local list = findTowers(towers)
	towers:ClearAllChildren()
	-- the sturdiest footprints become megatowers
	local bySize = table.clone(list)
	table.sort(bySize, function(a, c) return math.min(a.Size.X, a.Size.Z) > math.min(c.Size.X, c.Size.Z) end)
	local mega = {}
	for i = 1, math.min(MEGA_COUNT, #bySize) do mega[bySize[i]] = true end
	for i, tower in ipairs(list) do
		local pos = tower.CFrame.Position
		local rng = Random.new(i * 7919)
		local model = Instance.new("Model")
		model.Name = "Tower"
		local b = Architecture.builder(model, CFrame.new(pos.X, 0, pos.Z) * tower.CFrame.Rotation)
		local w = math.clamp(math.min(tower.Size.X, tower.Size.Z) - 6, 16, 30)
		local h = math.max(tower.Top, 50)
		local body = pick(rng, BODIES)
		local accent = pick(rng, ACCENTS)
		local glow = pick(rng, GLOWS)
		if mega[tower] then
			model.Name = "MegaTower"
			megaTower(b, math.clamp(math.min(tower.Size.X, tower.Size.Z) - 4, 24, 40), math.clamp(math.max(h * 1.6, 400), 400, 580), rng)
		else
			base(b, w, rng, accent)
			STYLES[(i - 1) % #STYLES + 1](b, w, h, rng, body, accent, glow)
		end
		model.Parent = towers
	end
	towers:SetAttribute("Cartoon2050", true)
end

-- Old sky bridges pointed at towers that no longer exist, so replace them with glass tubes
function CityBuilder.rebuildBridges(city)
	local bridges = city:FindFirstChild("SkyBridges")
	if not bridges or bridges:GetAttribute("Cartoon2050") then return end
	local spans = {}
	for _, d in ipairs(bridges:GetDescendants()) do
		if d:IsA("BasePart") and d.Name == "SkyBridge" then
			table.insert(spans, {CFrame = d.CFrame, Size = d.Size})
		end
	end
	bridges:ClearAllChildren()
	local b = Architecture.builder(bridges, CFrame.new())
	for _, span in ipairs(spans) do
		-- the long side of the old bridge is the direction the tube runs
		local s = span.Size
		local axis = s.X >= s.Z and span.CFrame.RightVector or span.CFrame.LookVector
		local length = math.max(s.X, s.Z)
		local mid = span.CFrame.Position
		b:rod("Tube", length, 6, Architecture.alongX(mid, axis), "Glass")
		b:rod("TubeFloor", length, 4.6, Architecture.alongX(mid - Vector3.new(0, 1.6, 0), axis), "White")
		for k = -1, 1 do
			b:rod("TubeRing", 1, 7, Architecture.alongX(mid + axis * (length * 0.33 * k), axis), "Lilac")
		end
	end
	bridges:SetAttribute("Cartoon2050", true)
end

-- Streets, edge wall and anything else: recolor in place
function CityBuilder.restyleRest(city)
	for _, name in ipairs({"Streets", "EdgeWall"}) do
		local folder = city:FindFirstChild(name)
		if folder then
			for _, d in ipairs(folder:GetDescendants()) do
				if d:IsA("BasePart") then
					if d.Name == "Road" then
						d.Material = Enum.Material.SmoothPlastic
						d.Color = Color3.fromRGB(88, 92, 140)
					elseif d.Name == "LaneLine" then
						apply(d, "Sun")
					elseif d.Name == "Curb" then
						apply(d, "White")
					elseif d.Name == "Megastructure" then
						d.Material = Enum.Material.SmoothPlastic
						d.Color = Color3.fromRGB(176, 186, 236)
					elseif d.Name == "WallFrame" then
						apply(d, "White")
					else
						CityBuilder.cartoonify(d)
					end
				end
			end
		end
	end
end

function CityBuilder.build(city)
	CityBuilder.rebuildTowers(city)
	CityBuilder.rebuildBridges(city)
	CityBuilder.restyleRest(city)
end

return CityBuilder
]=])
install(game:GetService("ServerScriptService"), "DigBoosts", "ModuleScript", [=[
-- DigBoosts (ModuleScript in ServerScriptService)
-- Temporary digging bonuses from the world gimmicks: world-wide events (Gold Rush, Blizzard
-- luck, Glitch Surge) and personal boosts (the Candy merchant's Sugar Rush).
-- DigManager asks DigBoosts.Get(player, world) on every swing. Each player's attributes
-- "DigSpeedMult" (swing cooldown multiplier), "WorldEvent" and "WorldEventEnds" and
-- "PersonalBoost"/"PersonalBoostEnds" are kept up to date so the client can show them.

local Players = game:GetService("Players")

local DigBoosts = {}

local worldEvents = {}    -- [worldId] = {Name, FindMult, LuckMult, CooldownMult, EndsAt}
local personal = {}       -- [player] = {Name, CooldownMult, LuckMult, EndsAt}

local function active(boost)
	return boost and os.clock() < boost.EndsAt
end

-- a world-wide event, e.g. DigBoosts.StartWorldEvent(5, {Name = "GOLD RUSH", FindMult = 3}, 40)
function DigBoosts.StartWorldEvent(worldId, boost, seconds)
	boost.EndsAt = os.clock() + seconds
	worldEvents[worldId] = boost
end

function DigBoosts.EndWorldEvent(worldId)
	worldEvents[worldId] = nil
end

function DigBoosts.GetWorldEvent(worldId)
	local e = worldEvents[worldId]
	return active(e) and e or nil
end

function DigBoosts.GivePersonal(player, boost, seconds)
	boost.EndsAt = os.clock() + seconds
	personal[player] = boost
end

function DigBoosts.GetPersonal(player)
	local p = personal[player]
	return active(p) and p or nil
end

-- the multipliers for this player's next swing in this world
function DigBoosts.Get(player, world)
	local find, luck, cooldown = 1, 1, 1
	local e = DigBoosts.GetWorldEvent(world.Id)
	if e then
		find *= e.FindMult or 1
		luck *= e.LuckMult or 1
		cooldown *= e.CooldownMult or 1
	end
	local p = DigBoosts.GetPersonal(player)
	if p then
		find *= p.FindMult or 1
		luck *= p.LuckMult or 1
		cooldown *= p.CooldownMult or 1
	end
	return {Find = find, Luck = luck, Cooldown = cooldown}
end

-- keep every player's attributes in sync (the client times its swings and shows timers from them)
task.spawn(function()
	while true do
		for _, player in ipairs(Players:GetPlayers()) do
			local worldId = player:GetAttribute("CurrentWorld") or 1
			local e = DigBoosts.GetWorldEvent(worldId)
			local p = DigBoosts.GetPersonal(player)
			local now = os.clock()
			local cooldown = (e and e.CooldownMult or 1) * (p and p.CooldownMult or 1)
			player:SetAttribute("DigSpeedMult", cooldown)
			player:SetAttribute("WorldEvent", e and e.Name or "")
			player:SetAttribute("WorldEventLeft", e and math.ceil(e.EndsAt - now) or 0)
			player:SetAttribute("PersonalBoost", p and p.Name or "")
			player:SetAttribute("PersonalBoostLeft", p and math.ceil(p.EndsAt - now) or 0)
		end
		task.wait(0.5)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	personal[player] = nil
end)

return DigBoosts
]=])
install(game:GetService("ServerScriptService"), "DigManager", "Script", [=[
-- DigManager (Script in ServerScriptService)
-- Real terrain digging with shovels across every world: carves holes in a 560-stud pit,
-- blocks shovels from breaking into zones deeper than they're rated for, finds artifacts
-- by depth zone, Lucky Dig minigame, pit resets, the Shovel Shops and the World Gates.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))
local ShovelModels = require(ReplicatedStorage:WaitForChild("PickaxeModels"))
local ShopBuilder = require(script.Parent:WaitForChild("ShopBuilder"))
local WorldGate = require(script.Parent:WaitForChild("WorldGate"))
local WorldBuilder = require(script.Parent:WaitForChild("WorldBuilder"))
local BuriedPainting = require(script.Parent:WaitForChild("BuriedPainting"))
local DigBoosts = require(script.Parent:WaitForChild("DigBoosts"))
local GimmickHooks = require(script.Parent:WaitForChild("GimmickHooks"))
local TweenService = game:GetService("TweenService")

local terrain = workspace.Terrain

---------------------------------------------------------------------
-- SETTINGS
---------------------------------------------------------------------
local MINIGAME_TIMEOUT = 8
local MINIGAME_LUCK = {Perfect = 3, Good = 1.5, Miss = 1} -- multiplies the shovel's luck
local ANNOUNCE_FROM = ArtifactData.GetRarityIndex("Legendary")
local MAX_REACH = 14 -- how far from your character you can dig
local PICKUP_SECONDS = 25  -- how long a buried painting waits to be pulled out before it sinks back into the dirt
local PULL_SECONDS = 1.1   -- the pull-out animation (the pickaxe is put away meanwhile)
local COMBO_WINDOW = 1.4   -- seconds between digs to keep a combo going
local COMBO_MAX = 10
local COMBO_LUCK = 0.04    -- each combo step adds +4% find chance (x10 combo = +36%)
local SURFACE_RING = 52 -- where "Return to Surface" puts you (distance from the pit center)

-- Where the shop and the World Gate stand around each pit (angle, distance from center)
local SHOP_SPOT = {Angle = 30, Distance = 80}
local GATE_SPOT = {Angle = -30, Distance = 86}

---------------------------------------------------------------------
-- REMOTES
---------------------------------------------------------------------
local remotes = ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage
local function getRemote(name)
	local r = remotes:FindFirstChild(name) or Instance.new("RemoteEvent")
	r.Name = name
	r.Parent = remotes
	return r
end
local minigameRemote = getRemote("DigMinigame")
local resultRemote = getRemote("DigResult")
local announceRemote = getRemote("Announcement")
local swingRemote = getRemote("DigSwing")          -- client -> server: swing at a position
local swingFxRemote = getRemote("ShovelSwingFx")   -- server -> other clients: play this player's swing
local digHitRemote = getRemote("DigHit")           -- server -> digger: impact info for juice (combo, color, spot)
local claimRemote = getRemote("ClaimFind")         -- client -> server: leave (false) the find
local pullRemote = getRemote("PullFind")           -- server -> all clients: (finder, painting, info) play the pull-out animation
local inventoryChangedRemote = getRemote("InventoryChanged") -- server -> client: inventory changed, refresh UI
local getInventory = remotes:FindFirstChild("GetInventory") or Instance.new("RemoteFunction")
getInventory.Name = "GetInventory"
getInventory.Parent = remotes
local digMessageRemote = getRemote("DigProgress")  -- server -> client: short messages (text, color)
local surfaceRemote = getRemote("ReturnToSurface")
local openShopRemote = getRemote("OpenShovelShop") -- server -> client: (worldId)
local buyShovelRemote = getRemote("BuyShovel")
local equipShovelRemote = getRemote("EquipShovel")
local shopMessageRemote = getRemote("ShopMessage")
local openWorldMapRemote = getRemote("OpenWorldMap")
local buyWorldRemote = getRemote("BuyWorld")
local travelRemote = getRemote("TravelToWorld")

local digSite = workspace:WaitForChild("DigSite")

---------------------------------------------------------------------
-- SHOVEL TOOLS
---------------------------------------------------------------------
local toolTemplates = {}
for _, def in ipairs(GameConfig.Shovels) do
	toolTemplates[def.Id] = ShovelModels(def)
end

---------------------------------------------------------------------
-- PLAYER STATE: which world they're in, which shovel they hold there
---------------------------------------------------------------------
local currentWorld = {} -- [player] = world

local function getWorld(player)
	return currentWorld[player] or GameConfig.Worlds[1]
end

local function getEquippedDef(player, world)
	world = world or getWorld(player)
	local data = PlayerData.Get(player)
	local id = data and data.EquippedShovels[tostring(world.Id)]
	local def = id and GameConfig.GetShovel(id)
	if def and def.World == world.Id and data.OwnedShovels[def.Id] then
		return def
	end
	return GameConfig.GetStarterShovel(world)
end

local function keysToString(t)
	local list = {}
	for key in pairs(t) do
		table.insert(list, key)
	end
	return table.concat(list, ",")
end

local function updateAttributes(player)
	local data = PlayerData.Get(player)
	if not data then return end
	local def = getEquippedDef(player)
	player:SetAttribute("OwnedShovels", keysToString(data.OwnedShovels))
	player:SetAttribute("EquippedShovel", def and def.Id or "")
	player:SetAttribute("UnlockedWorlds", keysToString(data.UnlockedWorlds))
	player:SetAttribute("CurrentWorld", getWorld(player).Id)
end

-- Puts the shovel for the player's current world in their backpack (removes any other)
local function giveShovel(player)
	local def = getEquippedDef(player)
	for _, container in ipairs({player:FindFirstChild("Backpack"), player.Character}) do
		if container then
			for _, item in ipairs(container:GetChildren()) do
				if item:IsA("Tool") and item:GetAttribute("ShovelId") then
					item:Destroy()
				end
			end
		end
	end
	local backpack = player:FindFirstChild("Backpack")
	if backpack and def then
		toolTemplates[def.Id]:Clone().Parent = backpack
	end
end

---------------------------------------------------------------------
-- DIGGING
---------------------------------------------------------------------
local rng = Random.new()
local lastSwing = {}  -- [player] = time of last swing
local lastHit = {}    -- [player] = time of last successful dig (for combos)
local combos = {}     -- [player] = current combo count
local sessions = {}   -- [player] = Lucky Dig session
local tutorialDigs = {} -- [player] = swings during the tutorial's "dig something up" step
local TUTORIAL_FIND_AFTER = 4
local resetting = false

local function burst(position, color, count, speed)
	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.Transparency = 1
	anchor.Size = Vector3.new(1, 1, 1)
	anchor.CFrame = CFrame.new(position)
	anchor.Parent = workspace

	local emitter = Instance.new("ParticleEmitter")
	emitter.Enabled = false
	emitter.Color = ColorSequence.new(color)
	emitter.Size = NumberSequence.new(0.5, 0.1)
	emitter.Lifetime = NumberRange.new(0.5, 0.9)
	emitter.Speed = NumberRange.new(speed or 10, (speed or 10) * 1.6)
	emitter.SpreadAngle = Vector2.new(40, 40)
	emitter.Acceleration = Vector3.new(0, -45, 0)
	emitter.Rotation = NumberRange.new(0, 360)
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.Parent = anchor
	emitter:Emit(count or 18)
	Debris:AddItem(anchor, 2)
end

-- Is there solid ground at this point?
local function isSolid(position)
	local region = Region3.new(position - Vector3.new(1, 1, 1), position + Vector3.new(1, 1, 1)):ExpandToGrid(4)
	local materials, occupancies = terrain:ReadVoxels(region, 4)
	local size = materials.Size
	for x = 1, size.X do
		for y = 1, size.Y do
			for z = 1, size.Z do
				if materials[x][y][z] ~= Enum.Material.Air and occupancies[x][y][z] > 0.02 then
					return true
				end
			end
		end
	end
	return false
end

-- A find is the meme's 3D object stuck in the dirt of the crater. It waits in pending[player] until the
-- player pulls it out (ProximityPrompt) or it sinks back into the dirt.
local pending = {} -- [player] = {Artifact = artifact, Model = painting, Info = info for the client}
local findsFolder = workspace:FindFirstChild("BuriedFinds") or Instance.new("Folder")
findsFolder.Name = "BuriedFinds"
findsFolder.Parent = workspace

-- the painting slides back under the dirt and disappears
local function sink(model)
	if not model or not model.Parent then return end
	local canvas = model.PrimaryPart
	if canvas then
		local prompt = canvas:FindFirstChildOfClass("ProximityPrompt")
		if prompt then prompt.Enabled = false end
		local start = model:GetPivot()
		local value = Instance.new("NumberValue")
		value.Changed:Connect(function(v)
			if model.Parent then model:PivotTo(start - Vector3.new(0, v, 0)) end
		end)
		TweenService:Create(value, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Value = 4}):Play()
	end
	Debris:AddItem(model, 1.3)
end

-- puts the pickaxe back in the player's hands after the pull-out animation
local function reequip(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local backpack = player:FindFirstChild("Backpack")
	if not humanoid or not backpack or character:FindFirstChildOfClass("Tool") then return end
	for _, item in ipairs(backpack:GetChildren()) do
		if item:IsA("Tool") and item:GetAttribute("ShovelId") then
			humanoid:EquipTool(item)
			return
		end
	end
end

local function resolveFind(player, take)
	local find = pending[player]
	if not find then return end
	pending[player] = nil
	local data = PlayerData.Get(player)
	if take and data and player.Parent then
		-- a world gimmick may take over giving it (e.g. a meme ghost that must be captured first)
		local handled = GimmickHooks.Run("OnPull", getWorld(player).Id, player, find.Artifact, find.Model:GetPivot().Position)
		if not handled then
			PlayerData.AddArtifact(player, find.Artifact.Id)
		end
		player:SetAttribute("TutorialFound", true)
		data.Stats.TotalDigs += 1
		inventoryChangedRemote:FireClient(player)
		local prompt = find.Model.PrimaryPart and find.Model.PrimaryPart:FindFirstChildOfClass("ProximityPrompt")
		if prompt then prompt.Enabled = false end
		-- hands free for the pull: put the pickaxe away, then give it back
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local hadTool = character and character:FindFirstChildOfClass("Tool") ~= nil
		if humanoid then humanoid:UnequipTools() end
		pullRemote:FireAllClients(player, find.Model, find.Info)
		Debris:AddItem(find.Model, PULL_SECONDS + 1)
		if hadTool then
			task.delay(PULL_SECONDS, reequip, player)
		end
	else
		sink(find.Model)
		if player.Parent then
			digMessageRemote:FireClient(player, "The " .. find.Artifact.Name .. " sank back into the dirt.", Color3.fromRGB(200, 200, 215))
		end
	end
end

claimRemote.OnServerEvent:Connect(function(player, take)
	if take == false then resolveFind(player, false) end
end)

getInventory.OnServerInvoke = function(player)
	local data = PlayerData.WaitForData(player)
	local counts = {}
	for _, artifactId in pairs(data and data.Inventory or {}) do
		counts[artifactId] = (counts[artifactId] or 0) + 1
	end
	local list = {}
	for artifactId, count in pairs(counts) do
		table.insert(list, {Id = artifactId, Count = count})
	end
	return list
end

-- Where the find goes: the crater floor under the dig spot, and which way the finder is
local function findPlacement(player, position, zone)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = {terrain}
	local hit = workspace:Raycast(position + Vector3.new(0, 4, 0), Vector3.new(0, -24, 0), params)
	local floor = hit and hit.Position or position
	local up = hit and hit.Normal or Vector3.yAxis
	if up.Y < 0.5 then up = Vector3.yAxis end
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local toPlayer = root and (root.Position - floor) * Vector3.new(1, 0, 1) or Vector3.zero
	toPlayer = toPlayer.Magnitude > 0.1 and toPlayer.Unit or Vector3.zAxis
	return {Floor = floor, Up = up, ToPlayer = toPlayer, DirtColor = zone and zone.Color}
end

-- the painting is revealed: a burst of dirt, a flash of light in the rarity's color
local function revealFx(cf, color)
	burst(cf.Position, color, 24, 12)
	local beam = Instance.new("Part")
	beam.Name = "RevealBeam"
	beam.Shape = Enum.PartType.Cylinder
	beam.Material = Enum.Material.Neon
	beam.Color = color
	beam.Transparency = 0.45
	beam.Anchored = true
	beam.CanCollide = false
	beam.CanQuery = false
	beam.CanTouch = false
	beam.CastShadow = false
	beam.Size = Vector3.new(18, 3.4, 3.4)
	beam.CFrame = CFrame.new(cf.Position + Vector3.new(0, 9, 0)) * CFrame.Angles(0, 0, math.rad(90))
	beam.Parent = findsFolder
	TweenService:Create(beam, TweenInfo.new(1.4, Enum.EasingStyle.Quad), {Transparency = 1, Size = Vector3.new(22, 0.4, 0.4)}):Play()
	Debris:AddItem(beam, 1.5)
end

local function giveArtifact(player, zone, luck, grade, position, forcedArtifact)
	local artifact = forcedArtifact or ArtifactData.RollForZone(zone, luck)
	local data = PlayerData.Get(player)
	if not artifact or not data or pending[player] then return end

	local rarity = ArtifactData.GetRarity(artifact.Rarity)
	local rarityIndex = ArtifactData.GetRarityIndex(artifact.Rarity)
	local info = {
		Name = artifact.Name,
		Rarity = artifact.Rarity,
		RarityIndex = rarityIndex,
		Color = rarity.Color,
		Income = ArtifactData.GetIncome(artifact),
		Description = artifact.Description,
		Grade = grade,
		Position = position,
		Id = artifact.Id,
		Timeout = PICKUP_SECONDS,
	}

	-- the meme itself is stuck in a mound of dirt in the crater, waiting to be pulled out
	local placement = findPlacement(player, position, zone)
	local model = BuriedPainting(artifact, rarity.Color, placement, rng)
	local cf = model:GetPivot()
	model:SetAttribute("Owner", player.UserId)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Pull Out"
	prompt.ObjectText = artifact.Name
	prompt.HoldDuration = 0.35
	prompt.MaxActivationDistance = 16
	prompt.RequiresLineOfSight = false
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.Parent = model.PrimaryPart
	model.Parent = findsFolder
	revealFx(cf, rarity.Color)

	local find = {Artifact = artifact, Model = model, Info = info}
	pending[player] = find
	info.Painting = model
	prompt.Triggered:Connect(function(who)
		if who == player and pending[player] == find then
			resolveFind(player, true)
		elseif who ~= player then
			digMessageRemote:FireClient(who, "That's " .. player.DisplayName .. "'s find!")
		end
	end)
	task.delay(PICKUP_SECONDS, function()
		if pending[player] == find then
			resolveFind(player, false)
		end
	end)

	resultRemote:FireClient(player, info)
	if rarityIndex >= ANNOUNCE_FROM then
		announceRemote:FireAllClients(player.DisplayName .. " found a " .. string.upper(artifact.Rarity) .. " " .. artifact.Name .. " in " .. zone.Name .. "!", rarity.Color)
	end
end

local function finishLuckyDig(player, grade)
	local session = sessions[player]
	if not session then return end
	sessions[player] = nil
	giveArtifact(player, session.Zone, session.ShovelLuck * (MINIGAME_LUCK[grade] or 1), grade, session.Position)
end

local function onFind(player, def, zone, position, luck)
	if rng:NextNumber() < GameConfig.MinigameChance then
		local session = {Started = os.clock(), ShovelLuck = luck, Zone = zone, Position = position}
		sessions[player] = session
		minigameRemote:FireClient(player)
		task.delay(MINIGAME_TIMEOUT, function()
			if sessions[player] == session then
				finishLuckyDig(player, "Miss")
			end
		end)
	else
		giveArtifact(player, zone, luck, nil, position)
	end
end

-- The shovel hits a zone it isn't rated for: sparks fly and it bounces off
local lastBounceMessage = {}
local function bounceOff(player, world, def, zoneIndex, zone, position)
	burst(position, Color3.fromRGB(255, 214, 150), 10, 16)
	burst(position, zone.Color, 6, 6)
	if os.clock() - (lastBounceMessage[player] or 0) < 1.5 then return end
	lastBounceMessage[player] = os.clock()
	local needed = GameConfig.GetFirstShovelForZone(world, zoneIndex)
	local text = "CLANG! Your " .. def.Name .. " bounces off " .. string.upper(zone.Name) .. " (" .. -zone.Top .. "m+)."
	if needed then
		text ..= " You need the " .. needed.Name .. " or better."
	end
	digMessageRemote:FireClient(player, text, Color3.fromRGB(255, 120, 100))
end

swingRemote.OnServerEvent:Connect(function(player, target, swingLength)
	if resetting or sessions[player] then return end
	if GimmickHooks.IsLocked(player) then
		digMessageRemote:FireClient(player, "{Skull} Your pickaxe is cursed! It unlocks in a moment...", Color3.fromRGB(200, 130, 255))
		return
	end
	local data = PlayerData.Get(player)
	if not data then return end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local tool = character and character:FindFirstChildOfClass("Tool")
	if not root or not tool or not tool:GetAttribute("ShovelId") then return end

	local world = getWorld(player)
	local def = getEquippedDef(player, world)
	if not def or tool:GetAttribute("ShovelId") ~= def.Id then return end
	local now = os.clock()
	local boost = DigBoosts.Get(player, world) -- world gimmicks: events and the merchant's boosts
	if now - (lastSwing[player] or 0) < def.Cooldown * boost.Cooldown * 0.85 then return end
	lastSwing[player] = now
	-- let everyone else see this player's dig animation
	local length = typeof(swingLength) == "number" and math.clamp(swingLength, 0.3, 1) or 0.6
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player then
			swingFxRemote:FireClient(other, player, length)
		end
	end

	-- Where to dig: where the player clicked, or just in front of their feet
	local inFront = root.Position + root.CFrame.LookVector * 3 - Vector3.new(0, 3, 0)
	if typeof(target) ~= "Vector3" or (target - root.Position).Magnitude > MAX_REACH then
		target = inFront
	end

	local origin = world.Origin
	local function diggable(point)
		local flat = Vector3.new(point.X - origin.X, 0, point.Z - origin.Z).Magnitude
		return flat <= world.PitRadius and flat >= world.CenterNoDigRadius and point.Y <= origin.Y + 5
	end
	if not diggable(target) then
		-- standing inside the pit volume? Then never nag: dig at your feet instead
		-- (clicking the sky, the wall or the hard drive from inside the pit used to say "Dig inside the pit!")
		if GameConfig.IsInPit(world, character) then
			target = diggable(inFront) and inFront or root.Position - Vector3.new(0, 3.5, 0)
			if not diggable(target) then return end
		else
			return -- outside the pit: the "Jump into the pit" pill on screen already says so
		end
	end

	-- Aim into the ground: a bit past the clicked point, snapped to the 4-stud terrain grid
	local head = root.Position + Vector3.new(0, 1.5, 0)
	local dir = (target - head).Unit
	local function snap(v) return math.floor(v / 4) * 4 + 2 end
	local carveAt
	for d = 0, 14, 0.5 do
		local point = target + dir * d
		local cell = Vector3.new(snap(point.X), snap(point.Y), snap(point.Z))
		if isSolid(cell) then
			carveAt = cell
			break
		end
	end
	if not carveAt then
		return -- nothing but air there
	end

	-- Which depth zone is this, and is this shovel rated for it?
	local zoneIndex, zone = GameConfig.GetZoneAt(world, carveAt.Y)
	if not zone then
		digMessageRemote:FireClient(player, "Bedrock! This is the bottom of the Abyss.")
		return
	end
	local dig = {Zone = zone, ZoneIndex = zoneIndex, Position = carveAt, Def = def}
	if zoneIndex <= def.MaxZone and GimmickHooks.Run("BeforeDig", world.Id, player, dig) == "block" then
		combos[player] = 0
		return -- a world gimmick stopped this swing (e.g. frozen permafrost)
	end
	if zoneIndex > def.MaxZone then
		bounceOff(player, world, def, zoneIndex, zone, carveAt + Vector3.new(0, 2, 0))
		digHitRemote:FireClient(player, {Bounced = true, Position = carveAt + Vector3.new(0, 2, 0), Color = zone.Color, Combo = 0})
		combos[player] = 0
		return
	end

	-- Carve a round crater (smooth terrain looks much nicer than square holes). It reaches a
	-- bit below the clicked cell and up enough to walk into, but never below the bottom of
	-- the shovel's deepest zone.
	local floorY = origin.Y + world.Zones[def.MaxZone].Bottom
	-- the crater's radius scales straight with the shovel's Power (see GameConfig.DigRadiusForPower)
	local radius = (GameConfig.DigRadiusForPower(def.Power) + 2) / 2 + 0.75
	local centerY = math.max(carveAt.Y + radius * 0.35, floorY + radius)
	terrain:FillBall(Vector3.new(carveAt.X, centerY, carveAt.Z), radius, Enum.Material.Air)
	-- the bedrock can never be dug: if the crater reached down to it, put back any bedrock
	-- the smooth carving nibbled at (nobody digs past the floor or out of the pit)
	local bedrockTop = origin.Y + world.Zones[#world.Zones].Bottom
	if centerY - radius < bedrockTop + 3 then
		terrain:FillCylinder(CFrame.new(carveAt.X, bedrockTop - GameConfig.BedrockThickness / 2, carveAt.Z), GameConfig.BedrockThickness, radius + 2, Enum.Material.Basalt)
	end
	burst(target, zone.Color, 28, 14)

	-- Combo: keep digging without long pauses to build it up (more luck per dig)
	if now - (lastHit[player] or 0) <= COMBO_WINDOW then
		combos[player] = math.min((combos[player] or 0) + 1, COMBO_MAX)
	else
		combos[player] = 1
	end
	lastHit[player] = now
	local combo = combos[player]
	digHitRemote:FireClient(player, {Combo = combo, Position = carveAt, Color = zone.Color})

	-- Did we find something?
	if pending[player] then return end
	-- a world gimmick may turn this swing into something else (a curse trap, a data node...)
	if GimmickHooks.Run("AfterDig", world.Id, player, dig) then return end
	if player:GetAttribute("Tutorial") == 3 then
		-- first-join tutorial: the first find comes after a few swings, no minigame
		tutorialDigs[player] = (tutorialDigs[player] or 0) + 1
		if tutorialDigs[player] >= TUTORIAL_FIND_AFTER then
			giveArtifact(player, zone, def.Luck, nil, carveAt + Vector3.new(0, 2, 0))
			return
		end
	end
	if rng:NextNumber() < def.FindChance * boost.Find * (1 + COMBO_LUCK * (combo - 1)) then
		-- luck: the pickaxe x world events/boosts x the depth bonus x world gimmicks
		local luck = def.Luck * boost.Luck * GameConfig.DepthBonus(world, carveAt.Y) * GimmickHooks.Luck(world.Id, player, dig)
			* (player:GetAttribute("GemLuck") or 1)
		onFind(player, def, zone, carveAt + Vector3.new(0, 2, 0), luck)
	end
end)

minigameRemote.OnServerEvent:Connect(function(player, grade)
	local session = sessions[player]
	if not session then return end
	if typeof(grade) ~= "string" or not MINIGAME_LUCK[grade] then grade = "Miss" end
	if os.clock() - session.Started < 0.3 then grade = "Miss" end
	finishLuckyDig(player, grade)
end)

---------------------------------------------------------------------
-- GETTING OUT OF THE PIT
---------------------------------------------------------------------
local function surfaceCFrame(world, position)
	local origin = world.Origin
	local offset = position - origin
	local angle = math.atan2(offset.Z, offset.X)
	if world.HubPaths then
		-- nearest of the 6 path openings, on the path just outside the rim
		angle = math.floor(angle / (math.pi / 3) + 0.5) * (math.pi / 3)
	end
	local spot = origin + Vector3.new(math.cos(angle) * SURFACE_RING, 4, math.sin(angle) * SURFACE_RING)
	return CFrame.lookAt(spot, origin + Vector3.new(0, 4, 0))
end

surfaceRemote.OnServerEvent:Connect(function(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local world = getWorld(player)
	if root and root.Position.Y < world.Origin.Y - 2 then
		character:PivotTo(surfaceCFrame(world, root.Position))
	end
end)

---------------------------------------------------------------------
-- PIT RESET (refills all the dirt in every open world)
---------------------------------------------------------------------
local function enabledWorlds()
	local list = {}
	for _, world in ipairs(GameConfig.Worlds) do
		if world.Enabled then
			table.insert(list, world)
		end
	end
	return list
end

local function resetPits()
	resetting = true
	for player in pairs(pending) do
		resolveFind(player, false) -- unclaimed paintings sink with the old dirt
	end
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local world = getWorld(player)
		if root then
			local offset = root.Position - world.Origin
			if Vector3.new(offset.X, 0, offset.Z).Magnitude < world.PitRadius + 7 and offset.Y < 6 then
				character:PivotTo(surfaceCFrame(world, root.Position))
			end
		end
	end
	task.wait(0.5)
	for _, world in ipairs(enabledWorlds()) do
		GameConfig.FillDigTerrain(terrain, world)
	end
	resetting = false
end

local worldsBuilt = false -- the floating islands must exist before the pits are filled
task.spawn(function()
	-- wait for the floating islands (worlds 2-9 here, World 1 in MapStyle) before filling the pits
	local waited = 0
	while (not worldsBuilt or not workspace:GetAttribute("MainIslandReady")) and waited < 30 do
		waited += task.wait(0.1)
	end
	resetPits() -- fresh ground when the server starts
	while true do
		task.wait(GameConfig.PitResetMinutes * 60 - 30)
		announceRemote:FireAllClients("The Hard Drives reboot in 30 seconds! All the dirt will come back.", Color3.fromRGB(0, 225, 255))
		task.wait(30)
		resetPits()
		announceRemote:FireAllClients("The Hard Drives have rebooted. Fresh ground to dig!", Color3.fromRGB(90, 255, 120))
	end
end)

---------------------------------------------------------------------
-- SHOVEL SHOP
---------------------------------------------------------------------
buyShovelRemote.OnServerEvent:Connect(function(player, shovelId)
	local data = PlayerData.Get(player)
	local def = typeof(shovelId) == "string" and GameConfig.GetShovel(shovelId)
	if not data or not def or data.OwnedShovels[def.Id] then return end
	if not data.UnlockedWorlds[tostring(def.World)] then
		shopMessageRemote:FireClient(player, "Unlock " .. GameConfig.GetWorld(def.World).Name .. " first!", false)
		return
	end
	if not PlayerData.SpendMoney(player, def.Price) then
		shopMessageRemote:FireClient(player, "Not enough money!", false)
		return
	end
	data.OwnedShovels[def.Id] = true
	data.EquippedShovels[tostring(def.World)] = def.Id
	updateAttributes(player)
	giveShovel(player)
	shopMessageRemote:FireClient(player, "{Pickaxe} You bought the " .. def.Name .. "! It digs down to " .. -GameConfig.GetWorld(def.World).Zones[def.MaxZone].Bottom .. "m.", true)
end)

equipShovelRemote.OnServerEvent:Connect(function(player, shovelId)
	local data = PlayerData.Get(player)
	local def = typeof(shovelId) == "string" and GameConfig.GetShovel(shovelId)
	if not data or not def or not data.OwnedShovels[def.Id] then return end
	data.EquippedShovels[tostring(def.World)] = def.Id
	updateAttributes(player)
	giveShovel(player)
end)

---------------------------------------------------------------------
-- WORLDS: travel + unlocking
---------------------------------------------------------------------
local arrivalSpots = {} -- [worldId] = CFrame in front of that world's gate

local function ringCFrame(world, spot, height)
	local a = math.rad(spot.Angle)
	local pos = world.Origin + Vector3.new(math.cos(a) * spot.Distance, height or 0, math.sin(a) * spot.Distance)
	return CFrame.lookAt(pos, Vector3.new(world.Origin.X, pos.Y, world.Origin.Z))
end

local function travel(player, world)
	local character = player.Character
	if not character then return end
	sessions[player] = nil
	currentWorld[player] = world
	updateAttributes(player)
	giveShovel(player)
	character:PivotTo(arrivalSpots[world.Id] or (CFrame.new(world.Origin + Vector3.new(0, 6, SURFACE_RING))))
end

-- the HUD's MUSEUM button: back to World 1 and in front of your museum
local goHomeRemote = getRemote("GoHome")
local lastHome = {}
goHomeRemote.OnServerEvent:Connect(function(player)
	if os.clock() - (lastHome[player] or 0) < 2 then return end
	lastHome[player] = os.clock()
	if getWorld(player).Id ~= 1 then travel(player, GameConfig.Worlds[1]) end
	local sendHome = script.Parent:FindFirstChild("SendHome")
	if sendHome then sendHome:Fire(player) end
end)

travelRemote.OnServerEvent:Connect(function(player, worldId)
	local data = PlayerData.Get(player)
	local world = typeof(worldId) == "number" and GameConfig.GetWorld(worldId)
	if not data or not world then return end
	if not world.Enabled then
		shopMessageRemote:FireClient(player, world.Name .. " is still being excavated. Coming soon!", false)
	elseif not data.UnlockedWorlds[tostring(world.Id)] then
		shopMessageRemote:FireClient(player, "Unlock " .. world.Name .. " first!", false)
	else
		travel(player, world)
	end
end)

buyWorldRemote.OnServerEvent:Connect(function(player, worldId)
	local data = PlayerData.Get(player)
	local world = typeof(worldId) == "number" and GameConfig.GetWorld(worldId)
	if not data or not world or data.UnlockedWorlds[tostring(world.Id)] then return end
	if not world.Enabled then
		shopMessageRemote:FireClient(player, world.Name .. " is still being excavated. Coming soon!", false)
		return
	end
	if world.Id > 1 and not data.UnlockedWorlds[tostring(world.Id - 1)] then
		shopMessageRemote:FireClient(player, "Unlock the world before this one first!", false)
		return
	end
	if not PlayerData.SpendMoney(player, world.Price) then
		shopMessageRemote:FireClient(player, "Not enough money!", false)
		return
	end
	data.UnlockedWorlds[tostring(world.Id)] = true
	local starter = GameConfig.GetStarterShovel(world)
	if starter then
		data.OwnedShovels[starter.Id] = true
		data.EquippedShovels[tostring(world.Id)] = data.EquippedShovels[tostring(world.Id)] or starter.Id
	end
	updateAttributes(player)
	shopMessageRemote:FireClient(player, "World unlocked: " .. world.Name .. "!", true)
	announceRemote:FireAllClients(player.DisplayName .. " unlocked " .. world.Name .. "!", Color3.fromRGB(200, 205, 215))
end)

---------------------------------------------------------------------
-- BUILD EACH WORLD'S SHOP + GATE
---------------------------------------------------------------------
local worldsFolder = workspace:FindFirstChild("Worlds") or Instance.new("Folder")
worldsFolder.Name = "Worlds"
worldsFolder.Parent = workspace

for _, world in ipairs(enabledWorlds()) do
	local container = digSite
	if world.Id ~= 1 then
		container = Instance.new("Model")
		container.Name = "World" .. world.Id
		container.Parent = worldsFolder
	end
	-- Rebuild every start so the look always matches the code
	for _, name in ipairs({"ShovelShop", "WorldGate"}) do
		local old = container:FindFirstChild(name)
		if old then old:Destroy() end
	end

	local _, shopPrompt = ShopBuilder(container, world, ringCFrame(world, SHOP_SPOT))
	shopPrompt.Triggered:Connect(function(player)
		openShopRemote:FireClient(player, world.Id)
	end)

	local gateCF = ringCFrame(world, GATE_SPOT)
	local _, gatePrompt = WorldGate(container, gateCF, world.Id == 1 and "8 NEW DIG SITES  ·  UNLOCK WITH CASH" or "RETURN  ·  TRAVEL")
	gatePrompt.Triggered:Connect(function(player)
		openWorldMapRemote:FireClient(player)
	end)
	arrivalSpots[world.Id] = gateCF * CFrame.new(0, 5, -10) -- in front of the gate, facing the pit
	if world.Id ~= 1 then
		WorldBuilder(container, world) -- floating island, decorations, rim and zone rings
	end
end
worldsBuilt = true

---------------------------------------------------------------------
-- HELPERS FOR THE WORLD GIMMICKS (GimmickHooks.Api)
---------------------------------------------------------------------
local Api = GimmickHooks.Api
Api.Burst = burst
-- a find that bypasses the normal roll (e.g. a Corrupted meme from a data node)
function Api.GiveFind(player, zone, luck, position, forcedArtifact)
	if pending[player] then return false end
	giveArtifact(player, zone, luck, nil, position, forcedArtifact)
	return true
end
-- straight into the inventory (e.g. a captured meme ghost)
function Api.AddArtifactNow(player, artifact)
	PlayerData.AddArtifact(player, artifact.Id)
	inventoryChangedRemote:FireClient(player)
end
function Api.SendToSurface(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root then character:PivotTo(surfaceCFrame(getWorld(player), root.Position)) end
end
function Api.Message(player, text, color)
	digMessageRemote:FireClient(player, text, color)
end
Api.GetWorld = getWorld

---------------------------------------------------------------------
-- PIT SAFETY: invisible walls around every pit, a solid floor inside the bedrock, a lower
-- void, and a rescue for anyone who still manages to fall out of the world
---------------------------------------------------------------------
-- the Abyss goes 560 studs down; Roblox's default kill height would kill diggers down there.
-- Only Studio (the installer, from the Command Bar) may change it, so here we just try.
pcall(function() workspace.FallenPartsDestroyHeight = -3000 end)
if workspace.FallenPartsDestroyHeight > -1000 then
	warn("Run InstallInStudio.lua again to lower Workspace.FallenPartsDestroyHeight (the Abyss is deeper than the void)")
end

local safetyFolder = workspace:FindFirstChild("PitSafety")
if safetyFolder then safetyFolder:Destroy() end
safetyFolder = Instance.new("Folder")
safetyFolder.Name = "PitSafety"
safetyFolder.Parent = workspace

local function barrier(name, size, cf, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = true
	p.CanQuery = false -- clicks and raycasts go straight through
	p.CanTouch = false
	p.Transparency = 1
	p.CastShadow = false
	p.Size = size
	p.CFrame = cf
	if shape then p.Shape = shape end
	p.Parent = safetyFolder
	return p
end

local WALL_SEGMENTS = 48
local barriersOk, barriersError = pcall(function()
	for _, world in ipairs(enabledWorlds()) do
		local origin = world.Origin
		local bedrockTop = origin.Y + world.Zones[#world.Zones].Bottom
		-- walls: a ring just outside the widest crater a pickaxe can carve, from a few studs
		-- under the surface (so you can still jump in from the top) down to the bedrock
		local wallRadius = world.PitRadius + 7
		local top, bottom = origin.Y - 4, bedrockTop - 4
		local height = top - bottom
		local length = 2 * math.pi * wallRadius / WALL_SEGMENTS + 1
		for i = 0, WALL_SEGMENTS - 1 do
			local a = (i + 0.5) / WALL_SEGMENTS * math.pi * 2
			local pos = origin + Vector3.new(math.cos(a) * (wallRadius + 1), 0, math.sin(a) * (wallRadius + 1))
			pos = Vector3.new(pos.X, (top + bottom) / 2, pos.Z)
			barrier("PitWall", Vector3.new(length, height, 2), CFrame.lookAt(pos, Vector3.new(origin.X, pos.Y, origin.Z)))
		end
		-- a solid floor hidden inside the bedrock, under the whole pit
		barrier("BedrockFloor", Vector3.new(2, (wallRadius + 2) * 2, (wallRadius + 2) * 2),
			CFrame.new(origin.X, bedrockTop - 3, origin.Z) * CFrame.Angles(0, 0, math.rad(90)), Enum.PartType.Cylinder)
	end
end)
if not barriersOk then warn("Pit barriers failed: " .. tostring(barriersError)) end

-- anyone below the bedrock, or who fell off a floating island, is put back safely
task.spawn(function()
	while true do
		task.wait(1)
		for _, player in ipairs(Players:GetPlayers()) do
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local world = currentWorld[player]
			if root and world then
				local offset = root.Position - world.Origin
				local flat = Vector3.new(offset.X, 0, offset.Z).Magnitude
				local floor = world.Zones[#world.Zones].Bottom - GameConfig.BedrockThickness
				local belowBedrock = offset.Y < floor - 10
				local offTheIsland = offset.Y < -30 and flat > world.PitRadius + 10
				if belowBedrock or offTheIsland then
					root.AssemblyLinearVelocity = Vector3.zero
					if flat <= world.PitRadius + 10 then
						character:PivotTo(surfaceCFrame(world, root.Position))
					else
						character:PivotTo(arrivalSpots[world.Id] or CFrame.new(world.Origin + Vector3.new(0, 6, SURFACE_RING)))
					end
					digMessageRemote:FireClient(player, "Whoa! You slipped out of the world. Back to safety!", Color3.fromRGB(120, 230, 255))
				end
			end
		end
	end
end)

---------------------------------------------------------------------
-- PLAYERS
---------------------------------------------------------------------
-- Everyone walks faster than Roblox's default (see GameConfig.WalkSpeed)
game:GetService("StarterPlayer").CharacterWalkSpeed = GameConfig.WalkSpeed
local function setSpeed(character)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if humanoid then
		humanoid.WalkSpeed = GameConfig.WalkSpeed
	end
end
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(setSpeed)
	if player.Character then task.spawn(setSpeed, player.Character) end
end)
for _, player in ipairs(Players:GetPlayers()) do
	player.CharacterAdded:Connect(setSpeed)
	if player.Character then task.spawn(setSpeed, player.Character) end
end

local function onPlayerAdded(player)
	PlayerData.WaitForData(player)
	if not player.Parent then return end
	currentWorld[player] = GameConfig.Worlds[1] -- everyone spawns at their museum in world 1
	updateAttributes(player)
	player.CharacterAdded:Connect(function()
		currentWorld[player] = GameConfig.Worlds[1]
		updateAttributes(player)
		task.wait(0.2)
		giveShovel(player)
	end)
	if player.Character then
		giveShovel(player)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

Players.PlayerRemoving:Connect(function(player)
	lastSwing[player] = nil
	lastHit[player] = nil
	combos[player] = nil
	if pending[player] then sink(pending[player].Model) end
	pending[player] = nil
	sessions[player] = nil
	currentWorld[player] = nil
	lastBounceMessage[player] = nil
	tutorialDigs[player] = nil
end)

print("DigManager ready: " .. #enabledWorlds() .. " world(s), 560-stud pits, pickaxe depth zones active")
]=])
install(game:GetService("ServerScriptService"), "DigSiteStyle", "ModuleScript", [=[
-- DigSiteStyle (ModuleScript in ServerScriptService)
-- Makes a world's dig site match the cartoony 2050 look:
--   * recolors the rim, walkways, racks, gates, lamps and props into the soft palette
--   * adds a chunky candy-striped rim ring with bulbs around the pit
--   * strings party lights between the lamp posts
--   * puts a glowing halo over the giant hard drive
--   * hides glowing zone rings inside the pit walls at every zone boundary, so players
--     see a colored ring appear in the dirt when they dig past 50, 130 and 200 studs
-- The Shovel Shop and World Gate are skipped (they're already built in this style).

local Architecture = require(script.Parent:WaitForChild("Architecture"))
local CityBuilder = require(script.Parent:WaitForChild("CityBuilder"))
local P = Architecture.Palette

local SKIP = {ShovelShop = true, WorldGate = true, Cartoon2050 = true}

-- specific parts that deserve a specific color
local NAMED = {
	RimWall = "Lilac", RimCap = "White", Curb = "Lilac", RampPost = "Lilac",
	Walkway = "White", Ramp = "White", TileJoint = "Cloud",
	GatePost = "Violet", GateBeam = "Violet", GateSign = "Navy",
	ServerRack = "Navy", LampBase = "Violet", LampPole = "White", FloodPole = "White",
	FloodBase = "Violet", FloodHousing = "Sky", Cable = "Violet", BarrelBand = "Violet",
}

local function recolor(root)
	for _, d in ipairs(root:GetDescendants()) do
		local skip = false
		local a = d.Parent
		while a and a ~= root do
			if SKIP[a.Name] then
				skip = true
				break
			end
			a = a.Parent
		end
		if not skip and d:IsA("BasePart") then
			local finish = NAMED[d.Name]
			if finish then
				local f = P[finish]
				d.Color = f.Color
				d.Material = f.Material
				d.Reflectance = 0
			else
				CityBuilder.cartoonify(d)
			end
		end
	end
end

---------------------------------------------------------------------
-- PIT ATMOSPHERE: glowing crystal veins in the walls, floating dust, soft rim lighting
---------------------------------------------------------------------
local rgb = Color3.fromRGB
local VEIN_COLORS = {rgb(110, 230, 255), rgb(255, 130, 220), rgb(170, 140, 255), rgb(120, 255, 200)}

local function invisible(name, size, cf, parent)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Transparency = 1
	p.Size = size
	p.CFrame = cf
	p.Parent = parent
	return p
end

local function crystalVeins(folder, world, rng)
	local origin = world.Origin
	local colors = VEIN_COLORS
	if world.Look and world.Look.Glow then
		colors = {world.Look.Glow, world.Look.Glow:Lerp(Color3.new(1, 1, 1), 0.35), VEIN_COLORS[1]}
	end
	local deepest = -world.Zones[#world.Zones].Bottom
	local VEINS = 18
	for v = 1, VEINS do
		local vein = Instance.new("Model")
		vein.Name = "CrystalVein"
		vein.Parent = folder
		local color = colors[(v - 1) % #colors + 1]
		-- spread evenly around the pit and down through every zone (a few near the top)
		local angle = (v / VEINS) * math.pi * 2 + rng:NextNumber(-0.12, 0.12)
		local depth = v <= 4 and rng:NextNumber(3, 12) or rng:NextNumber(14, deepest - 12)
		local slope = rng:NextNumber(-0.35, 0.35) -- how the streak runs sideways as it goes down
		local steps = rng:NextInteger(6, 9)
		for i = 1, steps do
			local a = angle + slope * i * 0.03
			local y = origin.Y - depth - i * 1.3
			local r = world.PitRadius + 3.2 + rng:NextNumber(-0.4, 0.6)
			local pos = origin + Vector3.new(math.cos(a) * r, 0, math.sin(a) * r)
			pos = Vector3.new(pos.X, y, pos.Z)
			local inward = Vector3.new(origin.X, y, origin.Z)
			local length = rng:NextNumber(1.4, 3.2)
			local cf = CFrame.lookAt(pos, inward) * CFrame.Angles(math.rad(-90) + rng:NextNumber(-0.6, 0.6), 0, rng:NextNumber(-0.6, 0.6))
				* CFrame.new(0, length * 0.3, 0)
			local core = Instance.new("Part")
			core.Name = "VeinCrystal"
			core.Size = Vector3.new(0.45, length, 0.45)
			core.CFrame = cf
			core.Color = color
			core.Material = Enum.Material.Neon
			core.Parent = vein
			local shell = Instance.new("Part")
			shell.Name = "VeinShell"
			shell.Size = Vector3.new(0.85, length * 0.75, 0.85)
			shell.CFrame = cf * CFrame.new(0, -length * 0.1, 0) * CFrame.Angles(0, math.rad(45), 0)
			shell.Color = color:Lerp(Color3.new(1, 1, 1), 0.25)
			shell.Material = Enum.Material.Glass
			shell.Transparency = 0.45
			shell.Reflectance = 0.2
			shell.Parent = vein
			if i == math.ceil(steps / 2) then
				local light = Instance.new("PointLight")
				light.Color = color
				light.Range = 14
				light.Brightness = 0.8
				light.Shadows = false
				light.Parent = core
			end
		end
		for _, p in ipairs(vein:GetChildren()) do
			p.Anchored = true
			p.CanCollide = false
			p.CanQuery = false
			p.CanTouch = false
			p.CastShadow = false
		end
	end
end

-- features that make each deep layer look different when you dig past it:
--   the crystal layer (zone 3) gets big glowing crystal clusters growing out of the walls,
--   the magma core (zone 4) gets glowing cracks of lava with embers drifting up out of them
local function layerFeatures(folder, world, rng)
	local origin = world.Origin
	local crystalZone, magmaZone = world.Zones[3], world.Zones[4]
	local function wallCFrame(angle, depth, inset)
		local r = world.PitRadius + (inset or 3)
		local pos = origin + Vector3.new(math.cos(angle) * r, -depth, math.sin(angle) * r)
		return CFrame.lookAt(pos, Vector3.new(origin.X, pos.Y, origin.Z))
	end
	local function glow(parent, name, size, cf, color, material, transparency)
		local p = Instance.new("Part")
		p.Name = name
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CastShadow = false
		p.Size = size
		p.CFrame = cf
		p.Color = color
		p.Material = material or Enum.Material.Neon
		p.Transparency = transparency or 0
		p.Parent = parent
		return p
	end
	if crystalZone then
		local color = crystalZone.Color:Lerp(Color3.new(1, 1, 1), 0.15)
		for i = 1, 12 do
			local base = wallCFrame(i / 12 * math.pi * 2 + rng:NextNumber(-0.2, 0.2), rng:NextNumber(-crystalZone.Top + 10, -crystalZone.Bottom - 10))
			local cluster = Instance.new("Model")
			cluster.Name = "CrystalCluster"
			cluster.Parent = folder
			for k = 1, 6 do
				local length = rng:NextNumber(2, 5)
				local cf = base * CFrame.Angles(math.rad(-90) + rng:NextNumber(-0.7, 0.7), 0, rng:NextNumber(-0.7, 0.7)) * CFrame.new(0, length * 0.35, 0)
				glow(cluster, "Crystal", Vector3.new(length * 0.28, length, length * 0.28), cf * CFrame.Angles(0, math.rad(45), 0),
					color:Lerp(Color3.new(1, 1, 1), 0.3), Enum.Material.Glass, 0.2)
				glow(cluster, "CrystalCore", Vector3.new(length * 0.12, length * 0.85, length * 0.12), cf, color)
			end
			local light = Instance.new("PointLight")
			light.Color = color
			light.Range = 16
			light.Brightness = 1
			light.Parent = cluster:FindFirstChild("CrystalCore")
		end
	end
	if magmaZone then
		local hot = Color3.fromRGB(255, 120, 40)
		for i = 1, 14 do
			local angle = i / 14 * math.pi * 2 + rng:NextNumber(-0.15, 0.15)
			local depth = rng:NextNumber(-magmaZone.Top + 8, -magmaZone.Bottom - 8)
			local crack = Instance.new("Model")
			crack.Name = "MagmaCrack"
			crack.Parent = folder
			-- a zig-zag glowing seam running down the wall
			local y = depth
			local a = angle
			local last
			for _ = 1, 7 do
				local nextY, nextA = y + rng:NextNumber(2, 4), a + rng:NextNumber(-0.04, 0.04)
				local p0 = wallCFrame(a, y, 1.2).Position
				local p1 = wallCFrame(nextA, nextY, 1.2).Position
				last = glow(crack, "MagmaSeam", Vector3.new(0.35, 0.35, (p1 - p0).Magnitude + 0.3), CFrame.lookAt((p0 + p1) / 2, p1), hot)
				y, a = nextY, nextA
			end
			local light = Instance.new("PointLight")
			light.Color = hot
			light.Range = 18
			light.Brightness = 1.4
			light.Parent = last
			local embers = Instance.new("ParticleEmitter")
			embers.Color = ColorSequence.new(Color3.fromRGB(255, 220, 120), Color3.fromRGB(255, 60, 20))
			embers.LightEmission = 1
			embers.Size = NumberSequence.new(0.18, 0)
			embers.Lifetime = NumberRange.new(2, 3.5)
			embers.Rate = 5
			embers.Speed = NumberRange.new(1, 3)
			embers.Acceleration = Vector3.new(0, 3, 0)
			embers.SpreadAngle = Vector2.new(40, 40)
			embers.EmissionDirection = Enum.NormalId.Top
			embers.Parent = last
		end
	end
end

local function floatingDust(folder, world)
	local origin = world.Origin
	local width = world.PitRadius * 2
	-- one cloud over the pit, one filling the upper dig layers
	for _, layer in ipairs({{Y = 8, Height = 18, Rate = 14}, {Y = -40, Height = 70, Rate = 18}}) do
		local volume = invisible("PitDust", Vector3.new(width, layer.Height, width), CFrame.new(origin + Vector3.new(0, layer.Y, 0)), folder)
		local dust = Instance.new("ParticleEmitter")
		dust.Shape = Enum.ParticleEmitterShape.Box
		dust.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
		dust.Color = ColorSequence.new(rgb(255, 236, 200), rgb(200, 220, 255))
		dust.LightEmission = 0.45
		dust.LightInfluence = 0.4
		dust.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.3, 0.22), NumberSequenceKeypoint.new(1, 0)})
		dust.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.3, 0.35), NumberSequenceKeypoint.new(1, 1)})
		dust.Lifetime = NumberRange.new(6, 10)
		dust.Rate = layer.Rate
		dust.Speed = NumberRange.new(0.2, 0.7)
		dust.SpreadAngle = Vector2.new(180, 180)
		dust.Acceleration = Vector3.new(0, 0.12, 0)
		dust.RotSpeed = NumberRange.new(-30, 30)
		dust.Parent = volume
	end
end

local function rimLighting(folder, world)
	local origin = world.Origin
	-- a soft glowing strip right at the lip of the pit
	local lip = Instance.new("Model")
	lip.Name = "RimGlow"
	lip.Parent = folder
	local lb = Architecture.builder(lip, CFrame.new(origin))
	lb:ring("RimGlowRing", CFrame.new(0, 0.35, 0) * CFrame.Angles(math.rad(90), 0, 0), world.PitRadius + 2.6, 0.5, "GlowCyan", 64)
	for _, p in ipairs(lip:GetChildren()) do
		p.CanCollide = false
		p.CanQuery = false
		if world.Look and world.Look.Glow then p.Color = world.Look.Glow end
	end
	-- lamps on the rim that wash the top of the pit walls with soft light
	local LAMPS = 12
	for i = 0, LAMPS - 1 do
		local a = (i + 0.5) / LAMPS * math.pi * 2
		local pos = origin + Vector3.new(math.cos(a) * (world.PitRadius + 4.5), 5.6, math.sin(a) * (world.PitRadius + 4.5))
		local aim = origin + Vector3.new(math.cos(a) * world.PitRadius * 0.4, -14, math.sin(a) * world.PitRadius * 0.4)
		local holder = invisible("RimLight", Vector3.new(0.6, 0.6, 0.6), CFrame.lookAt(pos, aim), folder)
		local spot = Instance.new("SpotLight")
		spot.Face = Enum.NormalId.Front
		spot.Angle = 75
		spot.Range = 16
		spot.Brightness = 0.8
		spot.Color = i % 2 == 0 and rgb(255, 238, 210) or rgb(200, 230, 255)
		spot.Shadows = false
		spot.Parent = holder
	end
end

return function(digSite, world)
	if digSite:GetAttribute("Cartoon2050") then return end
	recolor(digSite)
	-- the walkway curbs were tall walls; lower them to a slim edge just above the walkway
	-- (the ground banks up to the walkway level beside them, see GameConfig.FillDigTerrain)
	for _, d in ipairs(digSite:GetDescendants()) do
		if d:IsA("BasePart") and (d.Name == "Curb" or d.Name == "CurbGlow") then
			local bottom = d.CFrame.Position.Y - d.Size.Y / 2
			if d.Name == "Curb" then
				d.Size = Vector3.new(d.Size.X, 2.75 - bottom, d.Size.Z)
				d.CFrame = d.CFrame + Vector3.new(0, (bottom + d.Size.Y / 2) - d.CFrame.Position.Y, 0)
			else
				d.CFrame = d.CFrame + Vector3.new(0, 2.8 - d.CFrame.Position.Y, 0)
			end
		end
	end

	local folder = Instance.new("Model")
	folder.Name = "Cartoon2050"
	local origin = world.Origin
	local b = Architecture.builder(folder, CFrame.new(origin))
	local rimRadius = world.PitRadius + 4.5

	-- candy-striped rim ring, broken where the six walkways come in (world 1)
	local segments = 72
	for i = 0, segments - 1 do
		local deg = (i + 0.5) * 360 / segments
		local onPath = false
		if world.HubPaths then
			local fromPath = math.abs(((deg + 30) % 60) - 30)
			onPath = fromPath < 9
		end
		if not onPath then
			local a = math.rad(deg)
			local pos = Vector3.new(math.cos(a) * rimRadius, 4.3, math.sin(a) * rimRadius)
			local tangent = Vector3.new(-math.sin(a), 0, math.cos(a))
			local length = 2 * math.pi * rimRadius / segments + 0.6
			-- a sturdy safety railing: dark posts and two yellow rails, a small lamp on every 6th post
			b:rod("RimRail", length, 0.45, Architecture.alongX(pos + Vector3.new(0, 1.6, 0), tangent), "Sun")
			b:rod("RimRail", length, 0.45, Architecture.alongX(pos + Vector3.new(0, 0.2, 0), tangent), "Sun")
			if i % 2 == 0 then
				b:box("RimPost", Vector3.new(0.6, 2.8, 0.6), CFrame.new(pos + Vector3.new(0, 0.6, 0)), "Navy")
			end
			if i % 6 == 0 then
				b:bulb("RimBulb", 0.8, CFrame.new(pos + Vector3.new(0, 2.3, 0)), "GlowSun", 8)
			end
		end
	end

	-- party lights strung between the lamp posts (world 1 has 6 lamps on a ring)
	local lamps = {}
	for _, d in ipairs(digSite:GetDescendants()) do
		if d:IsA("BasePart") and d.Name == "LampGlow" then
			table.insert(lamps, d.CFrame.Position)
		end
	end
	table.sort(lamps, function(p, q)
		return math.atan2(p.Z - origin.Z, p.X - origin.X) < math.atan2(q.Z - origin.Z, q.X - origin.X)
	end)
	local bulbColors = {"GlowSun", "GlowPink", "GlowCyan", "GlowMint"}
	for i, from in ipairs(lamps) do
		local to = lamps[i % #lamps + 1]
		if #lamps > 1 and (to - from).Magnitude < 80 then
			for k = 1, 9 do
				local t = k / 10
				local sag = math.sin(t * math.pi) * 3.5
				local pos = from:Lerp(to, t) - Vector3.new(0, sag + 0.6, 0)
				b:bulb("PartyBulb", 0.7, CFrame.new(pos - origin), bulbColors[(k % #bulbColors) + 1], 0)
			end
		end
	end

	-- halo over the giant hard drive in the middle
	if world.Id == 1 then
		b:ring("DriveHalo", CFrame.new(0, 13, 0) * CFrame.Angles(math.rad(90), 0, 0), 10, 0.8, "GlowCyan", 24)
		b:ring("DriveHaloOuter", CFrame.new(0, 15.5, 0) * CFrame.Angles(math.rad(90), 0, 0), 12.5, 0.6, "Lilac", 28)
	end

	-- zone rings hidden in the pit wall (you uncover them while digging)
	for i = 2, #world.Zones do
		local zone = world.Zones[i]
		local ringCF = CFrame.new(0, zone.Top, 0) * CFrame.Angles(math.rad(90), 0, 0)
		local marker = Instance.new("Model")
		marker.Name = "ZoneRing_" .. zone.Name
		marker.Parent = folder
		local mb = Architecture.builder(marker, CFrame.new(origin))
		mb:ring("ZoneRing", ringCF, world.PitRadius + 1.5, 0.9, "GlowCyan", 40)
		for _, part in ipairs(marker:GetChildren()) do
			part.Color = zone.Color:Lerp(Color3.new(1, 1, 1), 0.2)
			part.CanCollide = false
		end
	end

	-- the pit itself: crystal veins, dust in the air, soft light around the lip
	local atmosphere = Instance.new("Model")
	atmosphere.Name = "PitAtmosphere"
	atmosphere.Parent = folder
	crystalVeins(atmosphere, world, Random.new(world.Id * 104729))
	layerFeatures(atmosphere, world, Random.new(world.Id * 7907))
	floatingDust(atmosphere, world)
	rimLighting(atmosphere, world)

	for _, d in ipairs(folder:GetDescendants()) do
		if d:IsA("BasePart") and d.Name == "PartyBulb" then
			d.CanCollide = false
			local light = d:FindFirstChildOfClass("PointLight")
			if light then light:Destroy() end -- lots of bulbs; keep it cheap
		end
	end
	folder.Parent = digSite
	digSite:SetAttribute("Cartoon2050", true)
end
]=])
install(game:GetService("ServerScriptService"), "GimmickHooks", "ModuleScript", [=[
-- GimmickHooks (ModuleScript in ServerScriptService)
-- Lets a world's gimmick plug into digging without DigManager knowing about every world.
-- A gimmick registers functions for its world:
--   BeforeDig(player, dig)        return "block" to stop this swing (e.g. frozen permafrost)
--   AfterDig(player, dig)         return true if it took over this swing's find roll
--                                 (e.g. a curse trap or a data node went off instead)
--   OnPull(player, artifact, pos) return true if it takes over giving the artifact
--                                 (e.g. a meme ghost has to be captured first)
--   LuckMult(player, dig)         return a luck multiplier for this swing
-- dig = {Zone = zone, ZoneIndex = n, Position = where it hit, Def = the pickaxe}
-- DigManager fills GimmickHooks.Api with helpers the gimmicks can call (see DigManager).

local GimmickHooks = {}
GimmickHooks.Api = {}

local registry = {} -- [hookName][worldId] = {functions}
local locks = {}    -- [player] = time the pickaxe unlocks

function GimmickHooks.Register(worldId, hookName, fn)
	registry[hookName] = registry[hookName] or {}
	registry[hookName][worldId] = registry[hookName][worldId] or {}
	table.insert(registry[hookName][worldId], fn)
end

-- runs every function for this hook in this world; returns the first truthy answer
function GimmickHooks.Run(hookName, worldId, ...)
	local list = registry[hookName] and registry[hookName][worldId]
	if not list then return nil end
	for _, fn in ipairs(list) do
		local ok, result = pcall(fn, ...)
		if not ok then
			warn("Gimmick hook " .. hookName .. " failed: " .. tostring(result))
		elseif result then
			return result
		end
	end
	return nil
end

-- multiplies every LuckMult answer together
function GimmickHooks.Luck(worldId, ...)
	local list = registry.LuckMult and registry.LuckMult[worldId]
	local luck = 1
	for _, fn in ipairs(list or {}) do
		local ok, result = pcall(fn, ...)
		if ok and typeof(result) == "number" then luck *= result end
	end
	return luck
end

-- stop a player's pickaxe from digging for a few seconds (curse traps)
function GimmickHooks.LockDig(player, seconds)
	locks[player] = os.clock() + seconds
	player:SetAttribute("DigLockedUntil", os.time() + seconds)
end

function GimmickHooks.IsLocked(player)
	return locks[player] ~= nil and os.clock() < locks[player]
end

-- a RemoteEvent in ReplicatedStorage.Remotes (made if it doesn't exist yet)
function GimmickHooks.Remote(name)
	local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
	local r = remotes:FindFirstChild(name) or Instance.new("RemoteEvent")
	r.Name = name
	r.Parent = remotes
	return r
end

game:GetService("Players").PlayerRemoving:Connect(function(player)
	locks[player] = nil
end)

return GimmickHooks
]=])
install(game:GetService("ServerScriptService"), "Gimmick_Blizzard", "ModuleScript", [=[
-- Gimmick_Blizzard (ModuleScript in ServerScriptService) - World 4, Frostbyte Tundra
-- Every few minutes a blizzard rolls in for 40 seconds: snow and fog on everyone's screen
-- (WorldGimmickClient, from the world's "Event" attribute) and 2x luck while it lasts.

local Gimmick = {}

function Gimmick.Start(ctx)
	ctx.EventLoop({
		Every = 170, Duration = 40, Name = "BLIZZARD",
		Boost = {LuckMult = 2},
		Message = "{Snowflake} A BLIZZARD rolls in! The storm stirs up relics: 2x luck for 40 seconds!",
		Color = Color3.fromRGB(170, 230, 255),
	})
end

return Gimmick
]=])
install(game:GetService("ServerScriptService"), "Gimmick_CurseTraps", "ModuleScript", [=[
-- Gimmick_CurseTraps (ModuleScript in ServerScriptService) - World 5, Chrome Dunes
-- Cursed blocks are hidden in the sand. When a swing hits one, a quick-time event pops up
-- (WorldMechanicsClient): press the key shown (or tap the button) before the bar runs out.
--   success: a pile of gold (about half a minute of a Rare meme's income here)
--   failure: your pickaxe is cursed and locked for 3 seconds
-- The client only reports which key was pressed; the server checks it and the timing.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))
local GimmickHooks = require(script.Parent:WaitForChild("GimmickHooks"))

local Gimmick = {}
local TRAP_CHANCE = 0.06
local TIME_LIMIT = 1.8
local LOCK_SECONDS = 3
local KEYS = {"E", "R", "F", "Q"}

local traps = {} -- [player] = {Key, Deadline}

function Gimmick.Start(ctx)
	local world = ctx.World
	local rng = Random.new()
	local Api = GimmickHooks.Api
	local trapRemote = GimmickHooks.Remote("CurseTrap")
	local multiplier = ArtifactData.WorldMultipliers[world.Id - 1] or 1
	local reward = math.floor(ArtifactData.GetRarity("Rare").Income * multiplier * 30)

	local function fail(player)
		traps[player] = nil
		GimmickHooks.LockDig(player, LOCK_SECONDS)
		Api.Message(player, "{Skull} The curse got you! Your pickaxe is locked for 3 seconds.", Color3.fromRGB(200, 120, 255))
	end

	GimmickHooks.Register(world.Id, "AfterDig", function(player, dig)
		if traps[player] or rng:NextNumber() > TRAP_CHANCE then return nil end
		local key = KEYS[rng:NextInteger(1, #KEYS)]
		local trap = {Key = key, Deadline = os.clock() + TIME_LIMIT + 0.4} -- a little slack for lag
		traps[player] = trap
		Api.Burst(dig.Position + Vector3.new(0, 2, 0), Color3.fromRGB(170, 80, 255), 30, 12)
		trapRemote:FireClient(player, key, TIME_LIMIT)
		task.delay(TIME_LIMIT + 0.6, function()
			if traps[player] == trap then fail(player) end
		end)
		return true
	end)

	trapRemote.OnServerEvent:Connect(function(player, pressed)
		local trap = traps[player]
		if not trap then return end
		if pressed == trap.Key and os.clock() <= trap.Deadline then
			traps[player] = nil
			PlayerData.AddMoney(player, reward)
			Api.Message(player, "{Coin} Curse broken! +" .. ArtifactData.FormatMoney(reward) .. " in ancient gold!", Color3.fromRGB(255, 214, 90))
		else
			fail(player)
		end
	end)
end

function Gimmick.OnLeave(_ctx, player)
	traps[player] = nil
end

return Gimmick
]=])
install(game:GetService("ServerScriptService"), "Gimmick_DataHacking", "ModuleScript", [=[
-- Gimmick_DataHacking (ModuleScript in ServerScriptService) - World 9, Glitch Nexus
-- Digging here sometimes uncovers a DATA NODE. Hack it with the rhythm minigame
-- (WorldMechanicsClient): tap on the beat 4 times. Hit at least 3 beats and the node gives
-- you a CORRUPTED meme: a glitched copy of one of this world's memes that earns 2x on
-- display (see ArtifactData). Miss and the node crashes.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GimmickHooks = require(script.Parent:WaitForChild("GimmickHooks"))

local Gimmick = {}
local NODE_CHANCE = 0.07
local BEATS = 4
local BEAT_SECONDS = 0.9
local HITS_NEEDED = 3

local nodes = {} -- [player] = {Started, Zone, Position, Luck, Part}

function Gimmick.Start(ctx)
	local world = ctx.World
	local rng = Random.new()
	local Api = GimmickHooks.Api
	local hackRemote = GimmickHooks.Remote("DataNode")

	GimmickHooks.Register(world.Id, "AfterDig", function(player, dig)
		if nodes[player] or rng:NextNumber() > NODE_CHANCE then return nil end
		-- a glowing data cube pops up where the pickaxe hit
		local cube = Instance.new("Part")
		cube.Name = "DataNode"
		cube.Size = Vector3.one * 2
		cube.Material = Enum.Material.Neon
		cube.Color = Color3.fromRGB(80, 255, 220)
		cube.Anchored = true
		cube.CanCollide = false
		cube.CanQuery = false
		cube.CFrame = CFrame.new(dig.Position + Vector3.new(0, 3, 0)) * CFrame.Angles(0.6, 0.6, 0)
		cube.Parent = ctx.Folder
		local light = Instance.new("PointLight")
		light.Color = cube.Color
		light.Range = 14
		light.Parent = cube
		Debris:AddItem(cube, BEATS * BEAT_SECONDS + 3)
		nodes[player] = {Started = os.clock(), Zone = dig.Zone, Position = dig.Position + Vector3.new(0, 2, 0), Luck = dig.Def.Luck * 1.5, Part = cube}
		hackRemote:FireClient(player, BEATS, BEAT_SECONDS)
		task.delay(BEATS * BEAT_SECONDS + 4, function()
			if nodes[player] and nodes[player].Part == cube then nodes[player] = nil end
		end)
		return true
	end)

	hackRemote.OnServerEvent:Connect(function(player, hits)
		local node = nodes[player]
		if not node then return end
		nodes[player] = nil
		if node.Part.Parent then node.Part:Destroy() end
		-- the minigame can't be finished faster than its beats
		local legit = os.clock() - node.Started >= BEATS * BEAT_SECONDS * 0.8
		if legit and typeof(hits) == "number" and hits >= HITS_NEEDED then
			local base = ArtifactData.RollForZone(node.Zone, node.Luck)
			local corrupted = ArtifactData.GetCorrupted(base) or base
			if Api.GiveFind(player, node.Zone, node.Luck, node.Position, corrupted) then
				Api.Message(player, "{Disk} HACKED! A Corrupted meme (2x income) is waiting in the dirt!", Color3.fromRGB(80, 255, 220))
			end
		else
			Api.Burst(node.Position, Color3.fromRGB(255, 60, 120), 24, 12)
			Api.Message(player, "{Boom} Hack failed, the Data Node crashed.", Color3.fromRGB(255, 110, 150))
		end
	end)
end

function Gimmick.OnLeave(_ctx, player)
	nodes[player] = nil
end

return Gimmick
]=])
install(game:GetService("ServerScriptService"), "Gimmick_Eruption", "ModuleScript", [=[
-- Gimmick_Eruption (ModuleScript in ServerScriptService) - World 8, Volcano Forge
-- Every few minutes the volcano erupts: glowing lava bombs arc down into the pit, and each
-- one leaves a Forge Nugget where it lands. Grab a nugget (walk up and press E) for cash,
-- about a minute of a Rare meme's income in this world. Nuggets cool down after a while.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))

local Gimmick = {}
local BOMBS = 10
local NUGGET_SECONDS = 45

local function glowPart(parent, name, size, cf, color, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = Enum.Material.Neon
	if shape then p.Shape = shape end
	p.Parent = parent
	return p
end

local function burst(parent, position, color, count)
	local anchor = glowPart(parent, "Burst", Vector3.one, CFrame.new(position), color)
	anchor.Transparency = 1
	local e = Instance.new("ParticleEmitter")
	e.Enabled = false
	e.Color = ColorSequence.new(Color3.fromRGB(255, 230, 120), color)
	e.LightEmission = 1
	e.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(1, 0)})
	e.Lifetime = NumberRange.new(0.5, 1)
	e.Speed = NumberRange.new(10, 22)
	e.SpreadAngle = Vector2.new(70, 70)
	e.Acceleration = Vector3.new(0, -40, 0)
	e.EmissionDirection = Enum.NormalId.Top
	e.Parent = anchor
	e:Emit(count)
	Debris:AddItem(anchor, 1.5)
end

function Gimmick.Start(ctx)
	local world = ctx.World
	local origin = world.Origin
	local multiplier = ArtifactData.WorldMultipliers[world.Id - 1] or 1
	local reward = math.floor(ArtifactData.GetRarity("Rare").Income * multiplier * 60)
	local rng = Random.new()
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = {workspace.Terrain}

	local function nugget(position)
		local rock = glowPart(ctx.Folder, "ForgeNugget", Vector3.new(1.6, 1.3, 1.5), CFrame.new(position + Vector3.new(0, 0.6, 0)) * CFrame.Angles(rng:NextNumber(0, 6), rng:NextNumber(0, 6), 0),
			Color3.fromRGB(255, 150, 40))
		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(255, 140, 40)
		light.Range = 12
		light.Brightness = 2
		light.Parent = rock
		local smoke = Instance.new("ParticleEmitter")
		smoke.Color = ColorSequence.new(Color3.fromRGB(255, 180, 90), Color3.fromRGB(90, 70, 70))
		smoke.Size = NumberSequence.new(0.4, 1.4)
		smoke.Transparency = NumberSequence.new(0.3, 1)
		smoke.Lifetime = NumberRange.new(1, 1.6)
		smoke.Rate = 6
		smoke.Speed = NumberRange.new(1, 2)
		smoke.EmissionDirection = Enum.NormalId.Top
		smoke.Parent = rock
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Grab (" .. ArtifactData.FormatMoney(reward) .. ")"
		prompt.ObjectText = "Forge Nugget"
		prompt.MaxActivationDistance = 12
		prompt.RequiresLineOfSight = false
		prompt.Parent = rock
		prompt.Triggered:Connect(function(player)
			if not rock.Parent or rock:GetAttribute("Taken") then return end
			rock:SetAttribute("Taken", true)
			PlayerData.AddMoney(player, reward)
			ReplicatedStorage.Remotes.DigProgress:FireClient(player, "{Volcano} Forge Nugget! +" .. ArtifactData.FormatMoney(reward), Color3.fromRGB(255, 170, 70))
			burst(ctx.Folder, rock.Position, Color3.fromRGB(255, 150, 40), 20)
			rock:Destroy()
		end)
		task.delay(NUGGET_SECONDS, function()
			if rock.Parent then
				-- cools down to dull rock and crumbles away
				TweenService:Create(rock, TweenInfo.new(1.5), {Color = Color3.fromRGB(60, 50, 50), Transparency = 1}):Play()
				Debris:AddItem(rock, 1.6)
			end
		end)
	end

	local function lavaBomb(delay)
		task.wait(delay)
		local a, r = rng:NextNumber(0, math.pi * 2), rng:NextNumber(0, world.PitRadius - 4)
		local x, z = origin.X + math.cos(a) * r, origin.Z + math.sin(a) * r
		local hit = workspace:Raycast(Vector3.new(x, origin.Y + 20, z), Vector3.new(0, -700, 0), params)
		if not hit then return end
		local land = hit.Position
		local start = land + Vector3.new(rng:NextNumber(-30, 30), 160, rng:NextNumber(-30, 30))
		local bomb = glowPart(ctx.Folder, "LavaBomb", Vector3.one * 3, CFrame.new(start), Color3.fromRGB(255, 110, 30), Enum.PartType.Ball)
		local fire = Instance.new("Fire")
		fire.Size = 8
		fire.Heat = 12
		fire.Parent = bomb
		local fall = TweenService:Create(bomb, TweenInfo.new(1.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {CFrame = CFrame.new(land + Vector3.new(0, 1.5, 0))})
		fall:Play()
		fall.Completed:Wait()
		bomb:Destroy()
		burst(ctx.Folder, land, Color3.fromRGB(255, 90, 20), 40)
		nugget(land)
	end

	ctx.EventLoop({
		Every = 140, Duration = 12, Name = "ERUPTION",
		Message = "{Volcano} ERUPTION! Lava bombs are raining into the pit. Grab the glowing Forge Nuggets!",
		Color = Color3.fromRGB(255, 140, 60),
		OnStart = function()
			for i = 1, BOMBS do
				task.spawn(lavaBomb, (i - 1) * 0.9 + rng:NextNumber(0, 0.5))
			end
		end,
	})
end

return Gimmick
]=])
install(game:GetService("ServerScriptService"), "Gimmick_GlitchSurge", "ModuleScript", [=[
-- Gimmick_GlitchSurge (ModuleScript in ServerScriptService) - World 9, Glitch Nexus
-- Every few minutes reality glitches out for 30 seconds: everyone in the world swings twice
-- as fast with 1.5x luck, and the screen flickers (WorldGimmickClient, from the "Event"
-- attribute on the world's folder).

local Gimmick = {}

function Gimmick.Start(ctx)
	ctx.EventLoop({
		Every = 170, Duration = 30, Name = "GLITCH SURGE",
		Boost = {CooldownMult = 0.5, LuckMult = 1.5},
		Message = "{Income} GLITCH SURGE! Swing 2x faster with 1.5x luck for 30 seconds!",
		Color = Color3.fromRGB(190, 120, 255),
	})
end

return Gimmick
]=])
install(game:GetService("ServerScriptService"), "Gimmick_GoldRush", "ModuleScript", [=[
-- Gimmick_GoldRush (ModuleScript in ServerScriptService) - World 5, Chrome Dunes
-- A golden sandstorm sweeps the pit every few minutes: for 45 seconds everyone digging here
-- finds things 3x as often (with a bit more luck), and golden glitter pours into the pit.

local Gimmick = {}

function Gimmick.Start(ctx)
	local world = ctx.World
	local volume = Instance.new("Part")
	volume.Name = "GoldDust"
	volume.Anchored = true
	volume.CanCollide = false
	volume.CanQuery = false
	volume.CanTouch = false
	volume.Transparency = 1
	volume.Size = Vector3.new(world.PitRadius * 2, 2, world.PitRadius * 2)
	volume.CFrame = CFrame.new(world.Origin + Vector3.new(0, 30, 0))
	volume.Parent = ctx.Folder
	local glitter = Instance.new("ParticleEmitter")
	glitter.Shape = Enum.ParticleEmitterShape.Box
	glitter.Color = ColorSequence.new(Color3.fromRGB(255, 240, 150), Color3.fromRGB(255, 180, 40))
	glitter.LightEmission = 1
	glitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0.1)})
	glitter.Lifetime = NumberRange.new(3, 5)
	glitter.Rate = 60
	glitter.Speed = NumberRange.new(6, 12)
	glitter.EmissionDirection = Enum.NormalId.Bottom
	glitter.SpreadAngle = Vector2.new(15, 15)
	glitter.RotSpeed = NumberRange.new(-200, 200)
	glitter.Enabled = false
	glitter.Parent = volume

	ctx.EventLoop({
		Every = 150, Duration = 45, Name = "GOLD RUSH",
		Boost = {FindMult = 3, LuckMult = 1.3},
		Message = "{Coin} GOLD RUSH! You find artifacts 3x as often for 45 seconds!",
		Color = Color3.fromRGB(255, 214, 90),
		OnStart = function() glitter.Enabled = true end,
		OnStop = function() glitter.Enabled = false end,
	})
end

return Gimmick
]=])
install(game:GetService("ServerScriptService"), "Gimmick_GravityShift", "ModuleScript", [=[
-- Gimmick_GravityShift (ModuleScript in ServerScriptService) - World 3, Galaxy Drift
-- Deep in the pit gravity can't make up its mind. Every so often it FLIPS for a few seconds:
-- either it pulls UP (you float up out of your crater) or SIDEWAYS (you get flung toward a
-- wall). The shift is announced on the world folder's "GravityShift" attribute and played
-- on each player's own screen by WorldMechanicsClient (gravity is simulated per player).
-- Reward for braving it: the deep layers (zone 3+) here give 1.5x luck.

local GimmickHooks = require(script.Parent:WaitForChild("GimmickHooks"))

local Gimmick = {}
local EVERY = {18, 30}
local DURATION = 3
Gimmick.DEEP_DEPTH = 150 -- only players deeper than this feel it

function Gimmick.Start(ctx)
	local rng = Random.new()
	ctx.Container:SetAttribute("GravityShiftDepth", Gimmick.DEEP_DEPTH)
	GimmickHooks.Register(ctx.World.Id, "LuckMult", function(_player, dig)
		return dig.ZoneIndex >= 3 and 1.5 or 1
	end)
	task.spawn(function()
		while ctx.Container.Parent do
			task.wait(rng:NextNumber(EVERY[1], EVERY[2]))
			if #ctx.PlayersInWorld() > 0 then
				local mode = rng:NextNumber() < 0.5 and "Up" or "Side"
				local angle = rng:NextNumber(0, 360)
				-- the value changes every time, so the client always notices a new shift
				ctx.Container:SetAttribute("GravityShift", mode .. ":" .. math.floor(angle) .. ":" .. os.clock())
				task.wait(DURATION)
				ctx.Container:SetAttribute("GravityShift", "")
			end
		end
	end)
end

return Gimmick
]=])
install(game:GetService("ServerScriptService"), "Gimmick_LavaSurge", "ModuleScript", [=[
-- Gimmick_LavaSurge (ModuleScript in ServerScriptService) - World 8, Volcano Forge
-- Every few minutes lava surges up from the bottom of the pit. There's a warning first,
-- then the glowing lava rises to SURGE_TOP studs below the surface, stays a moment and
-- sinks back. Anyone it catches is knocked back up to the surface and SCORCHED (swings 1.5x
-- slower for 20 seconds). Glowing basalt ledges on the pit walls just above the lava line
-- are safe spots, and so is anywhere near the surface.

local TweenService = game:GetService("TweenService")

local GimmickHooks = require(script.Parent:WaitForChild("GimmickHooks"))

local Gimmick = {}
local EVERY = 160
local WARNING = 8
local RISE_SECONDS = 12
local HOLD_SECONDS = 6
local SURGE_TOP = 45         -- how far below the surface the lava stops
local LEDGE_DEPTH = 40       -- the safe ledges are just above the lava's highest point
local SCORCH = {Name = "SCORCHED", CooldownMult = 1.5}
local SCORCH_SECONDS = 20

local function part(parent, name, size, cf, color, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanQuery = false
	p.CanTouch = false
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material
	p.Parent = parent
	return p
end

function Gimmick.Start(ctx)
	local world = ctx.World
	local origin = world.Origin
	local Api = GimmickHooks.Api
	local bottom = origin.Y + world.Zones[#world.Zones].Bottom

	-- the safe ledges: glowing basalt shelves around the pit wall
	for i = 0, 5 do
		local a = i / 6 * math.pi * 2
		local r = world.PitRadius - 1
		local pos = origin + Vector3.new(math.cos(a) * r, -LEDGE_DEPTH, math.sin(a) * r)
		local cf = CFrame.lookAt(pos, Vector3.new(origin.X, pos.Y, origin.Z))
		part(ctx.Folder, "SafeLedge", Vector3.new(10, 1.2, 6), cf, Color3.fromRGB(60, 50, 56), Enum.Material.Basalt)
		local glow = part(ctx.Folder, "SafeLedgeGlow", Vector3.new(10.2, 0.2, 6.2), cf * CFrame.new(0, -0.65, 0), Color3.fromRGB(120, 255, 170), Enum.Material.Neon)
		glow.CanCollide = false
	end

	-- the lava column (hidden until a surge)
	local lava = part(ctx.Folder, "LavaSurge", Vector3.new(1, world.PitRadius * 2 + 4, world.PitRadius * 2 + 4),
		CFrame.new(origin.X, bottom, origin.Z) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(255, 100, 30), Enum.Material.Neon)
	lava.Shape = Enum.PartType.Cylinder
	lava.CanCollide = false
	lava.Transparency = 1
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 110, 40)
	light.Range = 40
	light.Brightness = 3
	light.Enabled = false
	light.Parent = lava

	local function setTop(top)
		local height = math.max(top - bottom, 1)
		lava.Size = Vector3.new(height, lava.Size.Y, lava.Size.Z)
		lava.CFrame = CFrame.new(origin.X, bottom + height / 2, origin.Z) * CFrame.Angles(0, 0, math.rad(90))
	end

	local function scorchCaught(top)
		for _, player in ipairs(ctx.PlayersInWorld()) do
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if root then
				local offset = root.Position - origin
				local inPit = Vector3.new(offset.X, 0, offset.Z).Magnitude <= world.PitRadius + 2
				if inPit and root.Position.Y - 3 < top then
					Api.SendToSurface(player)
					ctx.Boosts.GivePersonal(player, table.clone(SCORCH), SCORCH_SECONDS)
					Api.Message(player, "{Fire} The lava got you! Knocked to the surface and SCORCHED (slower swings for 20s).", Color3.fromRGB(255, 130, 70))
				end
			end
		end
	end

	task.spawn(function()
		task.wait(EVERY * 0.6)
		while ctx.Container.Parent do
			if #ctx.PlayersInWorld() > 0 then
				ctx.Announce("{Volcano} LAVA SURGE in " .. WARNING .. " seconds! Get up to a glowing ledge or the surface!", Color3.fromRGB(255, 120, 60))
				ctx.Container:SetAttribute("Event", "LAVA SURGE")
				task.wait(WARNING)
				lava.Transparency = 0.15
				light.Enabled = true
				local peak = origin.Y - SURGE_TOP
				local start = os.clock()
				while os.clock() - start < RISE_SECONDS do
					local u = (os.clock() - start) / RISE_SECONDS
					local top = bottom + (peak - bottom) * (1 - (1 - u) ^ 2)
					setTop(top)
					scorchCaught(top)
					task.wait(0.2)
				end
				local holdEnd = os.clock() + HOLD_SECONDS
				while os.clock() < holdEnd do
					scorchCaught(peak)
					task.wait(0.2)
				end
				-- sink back down
				local value = Instance.new("NumberValue")
				value.Value = peak
				value.Changed:Connect(setTop)
				local sink = TweenService:Create(value, TweenInfo.new(6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Value = bottom})
				sink:Play()
				sink.Completed:Wait()
				value:Destroy()
				lava.Transparency = 1
				light.Enabled = false
				ctx.Container:SetAttribute("Event", "")
			end
			task.wait(EVERY)
		end
	end)
end

return Gimmick
]=])
install(game:GetService("ServerScriptService"), "Gimmick_LowGravity", "ModuleScript", [=[
-- Gimmick_LowGravity (ModuleScript in ServerScriptService) - World 3, Galaxy Drift
-- Gravity is much weaker here: WorldGimmickClient lowers workspace.Gravity on the player's
-- screen (gravity is simulated by each player's own computer for their character) while
-- they're in this world. Drifting star dust floats up out of the pit to sell the feeling.

local Gimmick = {}
local LOW_GRAVITY = 55 -- Roblox's normal gravity is 196.2

function Gimmick.Start(ctx)
	ctx.Container:SetAttribute("Gravity", LOW_GRAVITY)
	local world = ctx.World
	local volume = Instance.new("Part")
	volume.Name = "FloatingStarDust"
	volume.Anchored = true
	volume.CanCollide = false
	volume.CanQuery = false
	volume.CanTouch = false
	volume.Transparency = 1
	volume.Size = Vector3.new(world.PitRadius * 2, 4, world.PitRadius * 2)
	volume.CFrame = CFrame.new(world.Origin + Vector3.new(0, 2, 0))
	volume.Parent = ctx.Folder
	local dust = Instance.new("ParticleEmitter")
	dust.Shape = Enum.ParticleEmitterShape.Box
	dust.Color = ColorSequence.new(Color3.fromRGB(200, 180, 255), Color3.fromRGB(120, 220, 255))
	dust.LightEmission = 1
	dust.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.4, 0.3), NumberSequenceKeypoint.new(1, 0)})
	dust.Lifetime = NumberRange.new(5, 8)
	dust.Rate = 20
	dust.Speed = NumberRange.new(1, 3)
	dust.EmissionDirection = Enum.NormalId.Top
	dust.SpreadAngle = Vector2.new(20, 20)
	dust.Parent = volume
end

return Gimmick
]=])
install(game:GetService("ServerScriptService"), "Gimmick_Merchant", "ModuleScript", [=[
-- Gimmick_Merchant (ModuleScript in ServerScriptService) - World 7, Candy Mainframe
-- A candy-loving alien merchant strolls around the rim of the pit. Talk to it (hold E) to
-- buy a Sugar Rush: you swing 1.5x faster for 3 minutes. The price is about ten minutes of
-- a Rare meme's income in this world, so it's worth it but not free.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))
local buildVisitor = require(script.Parent:WaitForChild("VisitorModels"))

local Gimmick = {}
local BOOST = {Name = "SUGAR RUSH", CooldownMult = 1 / 1.5}
local BOOST_SECONDS = 180
local STOPS = 6          -- places around the rim it walks between
local WAIT_AT_STOP = 14  -- seconds it stands at each one

local WALK_ANIMATION = "rbxassetid://507777826"

function Gimmick.Start(ctx)
	local world = ctx.World
	local origin = world.Origin
	local multiplier = ArtifactData.WorldMultipliers[world.Id - 1] or 1
	local price = math.floor(ArtifactData.GetRarity("Rare").Income * multiplier * 600)

	local rng = Random.new()
	local ok, merchant = pcall(buildVisitor, "Alien", rng)
	if not ok or not merchant then
		warn("Alien merchant couldn't be built: " .. tostring(merchant))
		return
	end
	merchant.Name = "AlienMerchant"
	local humanoid = merchant:FindFirstChildOfClass("Humanoid")
	local root = merchant:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then return end
	humanoid.WalkSpeed = 8
	humanoid.DisplayName = "Alien Merchant"
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
	humanoid.NameDisplayDistance = 60

	-- a candy-striped backpack full of goods
	local pack = Instance.new("Part")
	pack.Name = "CandyPack"
	pack.Size = Vector3.new(1.6, 1.8, 1)
	pack.Color = Color3.fromRGB(255, 130, 200)
	pack.Material = Enum.Material.SmoothPlastic
	pack.CanCollide = false
	pack.Massless = true
	local torso = merchant:FindFirstChild("UpperTorso") or root
	pack.CFrame = torso.CFrame * CFrame.new(0, 0, 1)
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = torso
	weld.Part1 = pack
	weld.Parent = pack
	pack.Parent = merchant

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Buy Sugar Rush (" .. ArtifactData.FormatMoney(price) .. ")"
	prompt.ObjectText = "Alien Merchant · 1.5x dig speed, 3 min"
	prompt.HoldDuration = 0.4
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = root
	prompt.Triggered:Connect(function(player)
		if not ctx.IsHere(player) then return end
		if not PlayerData.SpendMoney(player, price) then
			ReplicatedStorage.Remotes.DigProgress:FireClient(player, "Not enough money for a Sugar Rush (" .. ArtifactData.FormatMoney(price) .. ").", Color3.fromRGB(255, 130, 130))
			return
		end
		ctx.Boosts.GivePersonal(player, table.clone(BOOST), BOOST_SECONDS)
		ReplicatedStorage.Remotes.DigProgress:FireClient(player, "{Candy} SUGAR RUSH! You dig 1.5x faster for 3 minutes!", Color3.fromRGB(255, 150, 220))
	end)

	local function stop(i)
		local a = (i / STOPS) * math.pi * 2 + 0.3
		local r = world.PitRadius + 11
		return origin + Vector3.new(math.cos(a) * r, 3, math.sin(a) * r)
	end
	merchant:PivotTo(CFrame.new(stop(0)))
	merchant.Parent = ctx.Folder
	pcall(function() root:SetNetworkOwner(nil) end)

	-- walking animation
	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator")
	animator.Parent = humanoid
	local animation = Instance.new("Animation")
	animation.AnimationId = WALK_ANIMATION
	local okTrack, walk = pcall(function() return animator:LoadAnimation(animation) end)
	humanoid.Running:Connect(function(speed)
		if not okTrack or not walk then return end
		if speed > 0.5 and not walk.IsPlaying then
			walk:Play(0.2)
		elseif speed <= 0.5 and walk.IsPlaying then
			walk:Stop(0.2)
		end
	end)

	-- stroll around the rim, one stop at a time
	task.spawn(function()
		local i = 0
		while merchant.Parent do
			i = (i + 1) % STOPS
			humanoid:MoveTo(stop(i))
			humanoid.MoveToFinished:Wait()
			task.wait(WAIT_AT_STOP)
		end
	end)
end

return Gimmick
]=])
install(game:GetService("ServerScriptService"), "Gimmick_Oxygen", "ModuleScript", [=[
-- Gimmick_Oxygen (ModuleScript in ServerScriptService) - World 6, Coral Circuit
-- The deep pit is full of toxic fumes. Below OxygenDepth studs your air meter drains
-- (WorldGimmickClient shows it); bubbling air vents set into the pit walls at every few
-- depths refill it, and so does climbing back near the surface. Run out and you're pulled
-- back up to the surface (nobody dies, but you lose your spot).
-- The vents are tagged "AirVent" so the client can find them.

local CollectionService = game:GetService("CollectionService")

local Gimmick = {}
local OXYGEN_DEPTH = 20
local VENT_DEPTHS = {28, 60, 100, 150, 210, 280, 360, 450, 530}
local VENTS_PER_DEPTH = 4

local function part(parent, name, size, cf, color, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.Metal
	p.Parent = parent
	return p
end

function Gimmick.Start(ctx)
	local world = ctx.World
	local origin = world.Origin
	ctx.Container:SetAttribute("OxygenDepth", OXYGEN_DEPTH)
	for d, depth in ipairs(VENT_DEPTHS) do
		for i = 0, VENTS_PER_DEPTH - 1 do
			local a = (i + (d % 2) * 0.5) / VENTS_PER_DEPTH * math.pi * 2
			local r = world.PitRadius + 1.4
			local pos = origin + Vector3.new(math.cos(a) * r, -depth, math.sin(a) * r)
			local facing = CFrame.lookAt(pos, Vector3.new(origin.X, pos.Y, origin.Z))
			local vent = Instance.new("Model")
			vent.Name = "AirVent"
			-- a round grate facing into the pit, a glowing rim, and bubbles pouring out
			local grate = part(vent, "Grate", Vector3.new(1, 4, 4), facing * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(60, 70, 90))
			grate.Shape = Enum.PartType.Cylinder
			local rim = part(vent, "VentGlow", Vector3.new(1.1, 4.6, 4.6), facing * CFrame.new(0, 0, 0.2) * CFrame.Angles(0, math.rad(90), 0),
				Color3.fromRGB(90, 230, 255), Enum.Material.Neon)
			rim.Shape = Enum.PartType.Cylinder
			local light = Instance.new("PointLight")
			light.Color = Color3.fromRGB(120, 230, 255)
			light.Range = 16
			light.Brightness = 1.2
			light.Parent = rim
			local bubbles = Instance.new("ParticleEmitter")
			bubbles.Color = ColorSequence.new(Color3.fromRGB(200, 245, 255))
			bubbles.LightEmission = 0.4
			bubbles.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 0.6)})
			bubbles.Transparency = NumberSequence.new(0.2, 1)
			bubbles.Lifetime = NumberRange.new(1.5, 2.5)
			bubbles.Rate = 18
			bubbles.Speed = NumberRange.new(2, 4)
			bubbles.Acceleration = Vector3.new(0, 4, 0)
			bubbles.EmissionDirection = Enum.NormalId.Left -- out of the grate, into the pit
			bubbles.SpreadAngle = Vector2.new(25, 25)
			bubbles.Parent = grate
			vent.PrimaryPart = grate
			vent.Parent = ctx.Folder
			CollectionService:AddTag(grate, "AirVent")
		end
	end
end

return Gimmick
]=])
install(game:GetService("ServerScriptService"), "Gimmick_Permafrost", "ModuleScript", [=[
-- Gimmick_Permafrost (ModuleScript in ServerScriptService) - World 4, Frostbyte Tundra
-- Below the first layer the ground is frozen solid: an unheated pickaxe often just skids off
-- the ice. Two ways to melt through:
--   * a TORCH FLARE (press F or the flare button, WorldMechanicsClient): 20 seconds of heat,
--     then it has to recharge
--   * a heated pickaxe: this world's top three pickaxes run hot and never freeze
-- The flare's state lives in the player's "HeatUntil" / "FlareReadyAt" attributes (os.time()).

local GimmickHooks = require(script.Parent:WaitForChild("GimmickHooks"))

local Gimmick = {}
local FROZEN_CHANCE = 0.5  -- chance an unheated swing skids off the permafrost
local FLARE_SECONDS = 20
local FLARE_COOLDOWN = 45
local HEATED_FROM_POWER = 6 -- pickaxes this strong or better are heated

local lastMessage = {}

function Gimmick.Start(ctx)
	local world = ctx.World
	local rng = Random.new()
	local Api = GimmickHooks.Api
	local flareRemote = GimmickHooks.Remote("TorchFlare")
	ctx.Container:SetAttribute("TorchFlare", true)

	local function heated(player, def)
		return (def and def.Power >= HEATED_FROM_POWER) or (player:GetAttribute("HeatUntil") or 0) > os.time()
	end

	GimmickHooks.Register(world.Id, "BeforeDig", function(player, dig)
		if dig.ZoneIndex < 2 or heated(player, dig.Def) then return nil end
		if rng:NextNumber() > FROZEN_CHANCE then return nil end
		Api.Burst(dig.Position + Vector3.new(0, 2, 0), Color3.fromRGB(200, 240, 255), 16, 14)
		if os.clock() - (lastMessage[player] or 0) > 3 then
			lastMessage[player] = os.clock()
			Api.Message(player, "{Ice} Permafrost! Use a Torch Flare [F] to melt it, or get a heated pickaxe.", Color3.fromRGB(170, 225, 255))
		end
		return "block"
	end)

	flareRemote.OnServerEvent:Connect(function(player)
		if not ctx.IsHere(player) then return end
		if (player:GetAttribute("FlareReadyAt") or 0) > os.time() then return end
		player:SetAttribute("HeatUntil", os.time() + FLARE_SECONDS)
		player:SetAttribute("FlareReadyAt", os.time() + FLARE_SECONDS + FLARE_COOLDOWN)
		-- flames around the player while the flare burns
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if root then
			local fire = Instance.new("Fire")
			fire.Name = "TorchFlare"
			fire.Size = 5
			fire.Heat = 6
			fire.Color = Color3.fromRGB(255, 160, 60)
			fire.Parent = root
			local light = Instance.new("PointLight")
			light.Color = Color3.fromRGB(255, 170, 80)
			light.Range = 20
			light.Brightness = 2
			light.Parent = root
			task.delay(FLARE_SECONDS, function()
				fire:Destroy()
				light:Destroy()
			end)
		end
		Api.Message(player, "{Fire} Torch Flare! You melt through permafrost for 20 seconds.", Color3.fromRGB(255, 170, 80))
	end)
end

return Gimmick
]=])
install(game:GetService("ServerScriptService"), "Gimmick_Spirits", "ModuleScript", [=[
-- Gimmick_Spirits (ModuleScript in ServerScriptService) - World 2, Neon Sakura Grove
-- Memes dug up here escape as MEME GHOSTS: when you pull a find out of the dirt, its spirit
-- flies up out of it and darts around the pit. Click it (your capture beam) 4 times to catch
-- it and it goes into your bag. Take too long and it sinks back into the ground for good.
-- (Clicks come from WorldMechanicsClient through the CaptureGhost remote.)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local ArtifactModels = require(ReplicatedStorage:WaitForChild("ArtifactModels"))
local MemeFigures = require(ReplicatedStorage:WaitForChild("MemeFigures"))
local GimmickHooks = require(script.Parent:WaitForChild("GimmickHooks"))

local Gimmick = {}
local HITS_NEEDED = 4
local ESCAPE_SECONDS = 40
local BEAM_RANGE = 80

local ghosts = {} -- [ghost model] = {Owner, Artifact, Hits}

local function makeGhost(folder, artifact, position)
	local color = ArtifactData.GetRarity(artifact.Rarity).Color
	local ghost = Instance.new("Model")
	ghost.Name = "MemeGhost"
	local body = Instance.new("Part")
	body.Name = "GhostBody"
	body.Shape = Enum.PartType.Ball
	body.Size = Vector3.one * 3
	body.Material = Enum.Material.Neon
	body.Color = color:Lerp(Color3.new(1, 1, 1), 0.5)
	body.Transparency = 0.35
	body.Anchored = true
	body.CanCollide = false
	body.CanTouch = false
	body.CastShadow = false
	body.CFrame = CFrame.new(position)
	body.Parent = ghost
	ghost.PrimaryPart = body
	-- a wispy tail and its meme's face
	local wisps = Instance.new("ParticleEmitter")
	wisps.Color = ColorSequence.new(color:Lerp(Color3.new(1, 1, 1), 0.6), color)
	wisps.LightEmission = 1
	wisps.Size = NumberSequence.new(1.2, 0)
	wisps.Transparency = NumberSequence.new(0.4, 1)
	wisps.Lifetime = NumberRange.new(0.6, 1)
	wisps.Rate = 30
	wisps.Speed = NumberRange.new(0.5, 1)
	wisps.Parent = body
	local face = Instance.new("BillboardGui")
	face.Size = UDim2.fromScale(2.6, 2.6)
	face.LightInfluence = 0
	face.AlwaysOnTop = true
	face.Parent = body
	-- the escaped meme itself, as a little 3D figure floating in the ghost
	local view = Instance.new("ViewportFrame")
	view.BackgroundTransparency = 1
	view.Size = UDim2.fromScale(1, 1)
	view.Ambient = Color3.fromRGB(220, 220, 235)
	view.LightColor = Color3.new(1, 1, 1)
	view.ImageTransparency = 0.15
	view.Parent = face
	local ok, figure = pcall(ArtifactModels.sculpture, artifact)
	if ok and figure and figure:FindFirstChildWhichIsA("BasePart", true) then
		figure.Parent = view
		local lo, hi = MemeFigures.bounds(figure)
		local centre = (lo + hi) / 2
		local camera = Instance.new("Camera")
		camera.FieldOfView = 20
		camera.CFrame = CFrame.lookAt(centre + Vector3.new(0, 0, -math.max(hi.X - lo.X, hi.Y - lo.Y) * 0.6 / math.tan(math.rad(10))), centre)
		camera.Parent = view
		view.CurrentCamera = camera
	end
	local light = Instance.new("PointLight")
	light.Color = color
	light.Range = 14
	light.Brightness = 1.5
	light.Parent = body
	local attachment = Instance.new("Attachment")
	attachment.Name = "BeamTarget"
	attachment.Parent = body
	ghost.Parent = folder
	return ghost
end

function Gimmick.Start(ctx)
	local world = ctx.World
	local origin = world.Origin
	local rng = Random.new()
	local captureRemote = GimmickHooks.Remote("CaptureGhost")
	local Api = GimmickHooks.Api

	local function randomSpot(nearY)
		local a, r = rng:NextNumber(0, math.pi * 2), rng:NextNumber(0, world.PitRadius - 6)
		local y = math.clamp(nearY + rng:NextNumber(-4, 10), nearY - 4, origin.Y + 16)
		return origin + Vector3.new(math.cos(a) * r, 0, math.sin(a) * r) * Vector3.new(1, 0, 1) + Vector3.new(0, y - origin.Y, 0)
	end

	-- the find is pulled out: instead of going into the bag, its ghost escapes
	GimmickHooks.Register(world.Id, "OnPull", function(player, artifact, position)
		task.delay(1.2, function()
			if not player.Parent then return end
			local ghost = makeGhost(ctx.Folder, artifact, position + Vector3.new(0, 2, 0))
			local entry = {Owner = player, Artifact = artifact, Hits = 0}
			ghosts[ghost] = entry
			Api.Message(player, "{Ghost} The " .. artifact.Name .. " escaped as a ghost! Click it " .. HITS_NEEDED .. " times to capture it!", Color3.fromRGB(255, 170, 230))
			-- dart around the pit until it's caught or gets away
			local started = os.clock()
			task.spawn(function()
				while ghost.Parent and ghosts[ghost] == entry do
					if os.clock() - started > ESCAPE_SECONDS then
						ghosts[ghost] = nil
						local body = ghost.PrimaryPart
						TweenService:Create(body, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{CFrame = body.CFrame - Vector3.new(0, 20, 0), Transparency = 1}):Play()
						Debris:AddItem(ghost, 1.3)
						if player.Parent then Api.Message(player, "The ghost got away... it sank back into the ground.", Color3.fromRGB(200, 200, 215)) end
						return
					end
					local body = ghost.PrimaryPart
					local goal = randomSpot(body.Position.Y)
					local move = TweenService:Create(body, TweenInfo.new(1.1, Enum.EasingStyle.Sine), {CFrame = CFrame.new(goal)})
					move:Play()
					task.wait(1.15)
				end
			end)
		end)
		return true -- the ghost gives the artifact once it's captured
	end)

	captureRemote.OnServerEvent:Connect(function(player, ghost)
		local entry = typeof(ghost) == "Instance" and ghosts[ghost]
		if not entry or entry.Owner ~= player or not ghost.PrimaryPart then return end
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not root or (root.Position - ghost.PrimaryPart.Position).Magnitude > BEAM_RANGE then return end
		entry.Hits += 1
		-- the capture beam, from the player's hand to the ghost
		local hand = player.Character:FindFirstChild("RightHand") or root
		local a0 = Instance.new("Attachment")
		a0.Parent = hand
		local beam = Instance.new("Beam")
		beam.Attachment0 = a0
		beam.Attachment1 = ghost.PrimaryPart:FindFirstChild("BeamTarget")
		beam.Color = ColorSequence.new(Color3.fromRGB(255, 180, 240), Color3.fromRGB(150, 230, 255))
		beam.LightEmission = 1
		beam.Width0 = 0.5
		beam.Width1 = 1.2
		beam.FaceCamera = true
		beam.Parent = a0
		Debris:AddItem(a0, 0.25)
		local body = ghost.PrimaryPart
		body.Size = Vector3.one * (3 - entry.Hits * 0.45) -- it shrinks as the beam drains it
		if entry.Hits >= HITS_NEEDED then
			ghosts[ghost] = nil
			Api.Burst(body.Position, body.Color, 40, 14)
			ghost:Destroy()
			Api.AddArtifactNow(player, entry.Artifact)
			Api.Message(player, "{Ghost} Captured! The " .. entry.Artifact.Name .. " is in your bag.", Color3.fromRGB(150, 255, 200))
		end
	end)
end

function Gimmick.OnLeave(_ctx, player)
	-- ghosts only live while their owner is in the world
	for ghost, entry in pairs(ghosts) do
		if entry.Owner == player then
			ghosts[ghost] = nil
			ghost:Destroy()
		end
	end
end

return Gimmick
]=])
install(game:GetService("ServerScriptService"), "MainIsland", "ModuleScript", [=[
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
]=])
install(game:GetService("ServerScriptService"), "MapStyle", "Script", [=[
-- MapStyle (Script in ServerScriptService)
-- Gives the whole map the cartoony 2050 look when the server starts:
-- builds the compact main island and its skyline (MainIsland), restyles the dig site, brightens the ground and the sky, and sets
-- calm, clean lighting (soft shadows, very little bloom, glow only on small accents).

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local MainIsland = require(script.Parent:WaitForChild("MainIsland"))
local DigSiteStyle = require(script.Parent:WaitForChild("DigSiteStyle"))
local Architecture = require(script.Parent:WaitForChild("Architecture"))
local WorldOneDecor = require(script.Parent:WaitForChild("WorldOneDecor"))

-- Set to false to keep the place's own sky and time of day (the calm lighting still applies)
local SUNNY_SKY = true

---------------------------------------------------------------------
-- GROUND: World 1 is now a compact floating island (MainIsland) instead of the old sprawling
-- city on big baseplates, so those are removed and the island is built in their place.
---------------------------------------------------------------------
for _, part in ipairs(workspace:GetChildren()) do
	if part:IsA("BasePart") and part.Name:find("^Baseplate") then
		part:Destroy()
	end
end
local oldCity = workspace:FindFirstChild("City")
if oldCity then oldCity:Destroy() end
local spawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")
if spawnLocation then
	spawnLocation.Material = Enum.Material.SmoothPlastic
	spawnLocation.Color = Color3.fromRGB(178, 158, 255)
end

-- Terrain colors: bright cartoon grass on top, soft stone walls, warm dig layers, plus the
-- ground materials of worlds 2-9 (see WorldsData.TerrainColors)
local terrain = workspace.Terrain
for materialName, color in pairs(GameConfig.TerrainColors) do
	terrain:SetMaterialColor(Enum.Material[materialName], color)
end
-- (grass blade length can't be set from a script any more: MainIsland keeps terrain grass
-- away from paths and the plaza instead)

---------------------------------------------------------------------
-- MAIN ISLAND + DIG SITE
---------------------------------------------------------------------
MainIsland.build()
WorldOneDecor.build() -- stone plaza details, gardens, the excavation work area, pit shoring
workspace:SetAttribute("MainIslandReady", true) -- DigManager fills the pit after this
local digSite = workspace:FindFirstChild("DigSite")
if digSite then
	DigSiteStyle(digSite, GameConfig.Worlds[1])
end

---------------------------------------------------------------------
-- SKY: clear afternoon with soft shadows and fluffy clouds
---------------------------------------------------------------------
if SUNNY_SKY then
	Lighting.ClockTime = 14.5
	Lighting.GeographicLatitude = 35

	-- the place's night skybox doesn't fit a sunny day; Roblox's default sky does
	local sky = Lighting:FindFirstChildOfClass("Sky")
	if sky then sky:Destroy() end

	local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds") or Instance.new("Clouds")
	clouds.Cover = 0.5
	clouds.Density = 0.6
	clouds.Color = Color3.fromRGB(250, 250, 255)
	clouds.Parent = workspace.Terrain
end

---------------------------------------------------------------------
-- CALM LIGHTING: clean daylight, real shadows, almost no bloom or haze
---------------------------------------------------------------------
Lighting.Brightness = 2
Lighting.ExposureCompensation = -0.1
Lighting.Ambient = Color3.fromRGB(92, 92, 108)          -- shade indoors / under roofs
Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 144) -- shade outdoors: keeps shadows readable
Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
Lighting.EnvironmentDiffuseScale = 0.4
Lighting.EnvironmentSpecularScale = 0.15 -- less mirror-like shine on everything
Lighting.GlobalShadows = true
Lighting.ShadowSoftness = 0.3

local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atmosphere.Density = 0.22
atmosphere.Offset = 0.1
atmosphere.Color = Color3.fromRGB(200, 210, 235)
atmosphere.Decay = Color3.fromRGB(120, 132, 170)
atmosphere.Glare = 0
atmosphere.Haze = 0.4
atmosphere.Parent = Lighting

-- one gentle bloom only (the place had two stacked on top of each other)
local keptBloom = false
for _, effect in ipairs(Lighting:GetChildren()) do
	if effect:IsA("BloomEffect") then
		if keptBloom then
			effect:Destroy()
		else
			keptBloom = true
			effect.Enabled = true
			effect.Intensity = 0.12
			effect.Size = 16
			effect.Threshold = 2.4 -- only the brightest pixels bloom
		end
	elseif effect:IsA("SunRaysEffect") then
		effect.Intensity = 0.02
		effect.Spread = 0.3
	elseif effect:IsA("DepthOfFieldEffect") then
		effect.Enabled = false -- keeps the cartoon look crisp
	end
end
local grade = Lighting:FindFirstChild("Cartoon2050Grade") or Instance.new("ColorCorrectionEffect")
grade.Name = "Cartoon2050Grade"
grade.Saturation = 0.05
grade.Contrast = 0.06
grade.Brightness = 0
grade.TintColor = Color3.fromRGB(255, 255, 255)
grade.Parent = Lighting

-- Tone down glowing parts and lights everywhere. Runs again after a few seconds so it
-- also catches the Shovel Shops and World Gates that DigManager builds on start.
local function calmWorld()
	for _, child in ipairs(workspace:GetChildren()) do
		local isCharacter = child:IsA("Model") and game:GetService("Players"):GetPlayerFromCharacter(child)
		if not isCharacter and not child:GetAttribute("NoCalm") then
			Architecture.calm(child)
		end
	end
end
calmWorld()
task.delay(5, calmWorld)

print("MapStyle: cartoony 2050 skyline, dig site and sky ready")
]=])
install(game:GetService("ServerScriptService"), "MemeToolManager", "Script", [=[
-- MemeToolManager (Script in ServerScriptService)
-- Holding a meme: click a meme in your backpack (InventoryClient) and its real 3D model
-- appears in your hand as a Tool. Walk around with it, show it off. Click it again (or
-- equip your pickaxe) to put it away. Only memes still in your inventory can be held;
-- placing it in the museum or selling it puts it away.
-- The Tool isn't kept in the hotbar: unequipping it removes it, so the hotbar stays clean.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local ArtifactModels = require(ReplicatedStorage:WaitForChild("ArtifactModels"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local equipRemote = remotes:FindFirstChild("EquipMeme") or Instance.new("RemoteEvent")
equipRemote.Name = "EquipMeme"
equipRemote.Parent = remotes

local HELD_HEIGHT = 2.2 -- studs tall in your hand

local held = {} -- [player] = Tool

local function owns(player, artifactId)
	local data = PlayerData.Get(player)
	for _, id in pairs(data and data.Inventory or {}) do
		if id == artifactId then return true end
	end
	return false
end

local function putAway(player)
	local tool = held[player]
	held[player] = nil
	if tool then tool:Destroy() end
	if player.Parent then player:SetAttribute("HeldMeme", nil) end
end

local function makeTool(artifact)
	local tool = Instance.new("Tool")
	tool.Name = artifact.Name
	tool.ToolTip = artifact.Name
	tool.CanBeDropped = false
	tool.RequiresHandle = true
	tool:SetAttribute("MemeId", artifact.Id)
	-- the Handle sits in the palm; the model stands upright on it, front facing forward
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.4, 0.4, 0.4)
	handle.Transparency = 1
	handle.CanCollide = false
	handle.CanQuery = false
	handle.CanTouch = false
	handle.Massless = true
	handle.Parent = tool
	local model = ArtifactModels.buildHeld(artifact, HELD_HEIGHT)
	local half = model:GetAttribute("HalfHeight") or HELD_HEIGHT / 2
	-- the hand holds it a little below its middle, slightly in front of the palm
	model:PivotTo(handle.CFrame * CFrame.new(0, half - 0.45, -0.35))
	for _, p in ipairs(model:GetDescendants()) do
		if p:IsA("BasePart") then
			p.Anchored = false
			p.CanCollide = false
			p.CanQuery = false
			p.CanTouch = false
			p.Massless = true
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = handle
			weld.Part1 = p
			weld.Parent = p
		end
	end
	model.Parent = tool
	return tool
end

local function hold(player, artifactId)
	local artifact = ArtifactData.GetArtifact(artifactId)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not artifact or not humanoid or humanoid.Health <= 0 then return end
	if not owns(player, artifactId) then return end
	local tool = makeTool(artifact)
	held[player] = tool
	tool.Parent = player:FindFirstChild("Backpack") or character
	humanoid:EquipTool(tool)
	player:SetAttribute("HeldMeme", artifactId)
	-- unequipped (pickaxe picked, hotbar key pressed): it goes away instead of sitting in the hotbar
	tool.AncestryChanged:Connect(function()
		if held[player] == tool and tool.Parent and not tool.Parent:IsA("Model") then
			putAway(player)
		end
	end)
end

equipRemote.OnServerEvent:Connect(function(player, artifactId)
	if typeof(artifactId) ~= "string" then return end
	local current = held[player]
	local currentId = current and current:GetAttribute("MemeId")
	putAway(player)
	if currentId ~= artifactId then -- clicking the meme you're holding just puts it away
		hold(player, artifactId)
	end
end)

-- put it away if it left your inventory (placed in the museum, sold) or you respawned
task.spawn(function()
	while true do
		task.wait(1)
		for player, tool in pairs(held) do
			local id = tool:GetAttribute("MemeId")
			if not player.Parent or not tool:IsDescendantOf(game) or not owns(player, id) then
				putAway(player)
			end
		end
	end
end)
Players.PlayerRemoving:Connect(putAway)

print("MemeToolManager ready: click a meme in your backpack to hold it")
]=])
install(game:GetService("ServerScriptService"), "MuseumBuilder", "ModuleScript", [=[
-- MuseumBuilder (ModuleScript in ServerScriptService)
-- Builds the player museum from code: a compact, three-storey 2050 gallery (64 x 64 studs,
-- floors every 22 studs) instead of a huge simulator hall. Cartoony and futuristic: white
-- walls with round porthole windows and rounded capsule corners, a glass curtain front framed
-- by a giant white arch with the museum's sign in it, a round portal entrance under a saucer
-- canopy, a flying saucer hovering over the roof with a glass bubble and an orbit ring, and a
-- plaza with the Alien Art Dealer's kiosk out front.
--
-- Inside, each floor has 8 display alcoves around the walls (24 slots in total) and a glowing
-- lift pad in the middle (the on-screen arrows teleport between the pads).
--
-- The parts keep the names the other scripts look for:
--   Slots/Slot1..24     AlcovePanel, AlcoveGlow, FactScreen (2 labels), FactGlow, GlowRing,
--                       RingCover, Step, Column, Band, Cap, Plaque, DisplaySpot (InfoGui with
--                       NameLabel + IncomeLabel) and ViewSpot (where visitors stand)
--   Arrivals/FloorNArrival, AlienDealer/Counter, Exterior/EntranceSign (TitleLabel, SubLabel)
--   Interior (invisible box around the floors), SpawnPoint, Waypoints/Outside, Door, Lobby
-- Local layout: the entrance faces -Z, ground level is y = 0, and the pivot sits on the plot.
-- Returns a function() -> Model (PlotManager clones it for each player).

local Architecture = require(script.Parent:WaitForChild("Architecture"))
local P = Architecture.Palette

local rgb = Color3.fromRGB
local HALF = 32          -- half the building width/depth
local FLOOR_H = 22       -- height of one storey
local FLOORS = 3
local WALL = 1.4
local ROOF_Y = FLOOR_H * FLOORS

P.MuseumGlass = {Color = rgb(170, 220, 255), Material = Enum.Material.Glass, Transparency = 0.35, Reflectance = 0.2}
P.MuseumTile = {Color = rgb(236, 232, 252), Material = Enum.Material.SmoothPlastic}
P.MuseumWall = {Color = rgb(248, 248, 253), Material = Enum.Material.SmoothPlastic}
P.MuseumAlcove = {Color = rgb(32, 30, 64), Material = Enum.Material.SmoothPlastic}
P.MuseumAlcoveGlow = {Color = rgb(150, 130, 255), Material = Enum.Material.Neon}
P.MuseumGold = {Color = rgb(255, 214, 110), Material = Enum.Material.Metal, Reflectance = 0.1}
P.AlienSkin = {Color = rgb(120, 220, 120), Material = Enum.Material.SmoothPlastic}
P.MuseumPorthole = {Color = rgb(70, 110, 200), Material = Enum.Material.Glass, Transparency = 0.15, Reflectance = 0.3}

---------------------------------------------------------------------
-- HELPERS
---------------------------------------------------------------------
local function marker(parent, name, cf, size)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Transparency = 1
	p.Size = size or Vector3.new(4, 1, 4)
	p.CFrame = cf
	p.Parent = parent
	return p
end

local function textLabel(parent, name, text, pos, size, color, font)
	local l = Instance.new("TextLabel")
	l.Name = name
	l.BackgroundTransparency = 1
	l.Position = pos
	l.Size = size
	l.Text = text
	l.TextScaled = true
	l.TextColor3 = color
	l.Font = font or Enum.Font.FredokaOne
	l.Parent = parent
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = rgb(24, 20, 60)
	stroke.Transparency = 0.3
	stroke.Parent = l
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0.04, 0)
	pad.PaddingRight = UDim.new(0.04, 0)
	pad.Parent = l
	return l
end

local function surface(part, face)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face or Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0
	gui.Parent = part
	return gui
end

---------------------------------------------------------------------
-- ONE DISPLAY SLOT (slotCF: at the pedestal, on the floor, -Z facing into the room)
---------------------------------------------------------------------
local function buildSlot(parent, index, floor, slotCF)
	local slot = Instance.new("Model")
	slot.Name = "Slot" .. index
	slot:SetAttribute("SlotIndex", index)
	slot:SetAttribute("Floor", floor)
	local b = Architecture.builder(slot, slotCF)

	-- wall alcove with a glowing frame and the fact screen above the pedestal
	b:box("AlcoveGlow", Vector3.new(12.8, 16.8, 0.3), CFrame.new(0, 9.4, 5.4), "MuseumAlcoveGlow")
	b:box("AlcovePanel", Vector3.new(12, 16, 0.4), CFrame.new(0, 9.4, 5.2), "MuseumAlcove")
	b:box("FactGlow", Vector3.new(9.6, 4.8, 0.2), CFrame.new(0, 14.6, 4.95), "MuseumAlcoveGlow")
	local screen = b:box("FactScreen", Vector3.new(9, 4.2, 0.3), CFrame.new(0, 14.6, 4.85), "Ink")
	local gui = surface(screen)
	textLabel(gui, "Label", "EMPTY DISPLAY", UDim2.fromScale(0, 0.06), UDim2.fromScale(1, 0.44), rgb(190, 170, 255))
	textLabel(gui, "Label", "Put a meme here to earn money every second!", UDim2.fromScale(0, 0.52), UDim2.fromScale(1, 0.42), rgb(235, 235, 250), Enum.Font.GothamMedium)

	-- round pedestal: glowing ring on the floor, a white step, a column with a light band, a dark cap
	local flat = CFrame.Angles(0, 0, math.rad(90)) -- cylinders stand upright
	b:box("GlowRing", Vector3.new(0.3, 9, 9), CFrame.new(0, 0.75, 0) * flat, "GlowCyan", {Shape = Enum.PartType.Cylinder})
	b:box("RingCover", Vector3.new(0.34, 8.2, 8.2), CFrame.new(0, 0.8, 0) * flat, "White", {Shape = Enum.PartType.Cylinder})
	b:box("Step", Vector3.new(1, 7, 7), CFrame.new(0, 1.2, 0) * flat, "Cloud", {Shape = Enum.PartType.Cylinder})
	b:box("Column", Vector3.new(4.6, 3.6, 3.6), CFrame.new(0, 3.9, 0) * flat, "White", {Shape = Enum.PartType.Cylinder})
	b:box("Band", Vector3.new(0.4, 3.9, 3.9), CFrame.new(0, 4.6, 0) * flat, "GlowCyan", {Shape = Enum.PartType.Cylinder})
	local cap = b:box("Cap", Vector3.new(0.6, 5, 5), CFrame.new(0, 6.5, 0) * flat, "Ink", {Shape = Enum.PartType.Cylinder})
	local light = Instance.new("PointLight")
	light.Range = 10
	light.Brightness = 0.6
	light.Color = rgb(200, 220, 255)
	light.Parent = cap

	-- where the meme card floats, with its name tag
	local spot = b:box("DisplaySpot", Vector3.new(1, 1, 1), CFrame.new(0, 8.6, 0), "White", {Transparency = 1, CanCollide = false, CanQuery = false})
	local info = Instance.new("BillboardGui")
	info.Name = "InfoGui"
	info.Size = UDim2.fromScale(9, 2.4)
	info.StudsOffset = Vector3.new(0, 5.2, 0)
	info.MaxDistance = 60
	info.LightInfluence = 0
	info.Parent = spot
	textLabel(info, "NameLabel", "EMPTY", UDim2.fromScale(0, 0), UDim2.fromScale(1, 0.58), rgb(190, 170, 255))
	textLabel(info, "IncomeLabel", "", UDim2.fromScale(0, 0.58), UDim2.fromScale(1, 0.42), rgb(120, 230, 140))

	-- little plaque on a slanted stand, and a glowing rope line in front
	b:box("PlaqueStand", Vector3.new(0.4, 2, 0.4), CFrame.new(0, 1, -4.6), "Chrome")
	local plaque = b:box("Plaque", Vector3.new(4.2, 1.5, 0.3), CFrame.new(0, 2.2, -4.7) * CFrame.Angles(math.rad(-30), 0, 0), "Ink")
	textLabel(surface(plaque), "Label", "EMPTY SLOT " .. index, UDim2.fromScale(0, 0.1), UDim2.fromScale(1, 0.8), rgb(235, 235, 250))
	for _, x in ipairs({-4.6, 4.6}) do
		b:pill("RopePost", Vector3.new(x, 0.6, -5.4), Vector3.new(x, 3, -5.4), 0.5, "MuseumGold")
	end
	b:box("Rope", Vector3.new(9.2, 0.18, 0.18), CFrame.new(0, 2.6, -5.4), "GlowPink", {CanCollide = false})

	-- where visitors stand to look
	marker(slot, "ViewSpot", slotCF * CFrame.new(0, 3, -8.5))
	slot.Parent = parent
	return slot
end

-- pedestal spots on one floor: 3 along each side wall, 2 on the back wall
local SLOT_SPOTS = {
	{Vector3.new(-25, 0, -16), Vector3.xAxis}, {Vector3.new(-25, 0, 0), Vector3.xAxis}, {Vector3.new(-25, 0, 16), Vector3.xAxis},
	{Vector3.new(-12, 0, 25), -Vector3.zAxis}, {Vector3.new(12, 0, 25), -Vector3.zAxis},
	{Vector3.new(25, 0, 16), -Vector3.xAxis}, {Vector3.new(25, 0, 0), -Vector3.xAxis}, {Vector3.new(25, 0, -16), -Vector3.xAxis},
}

---------------------------------------------------------------------
-- THE BUILDING
---------------------------------------------------------------------
local function build()
	local museum = Instance.new("Model")
	museum.Name = "MuseumTemplate"
	local exterior = Instance.new("Folder")
	exterior.Name = "Exterior"
	exterior.Parent = museum
	local floorsFolder = Instance.new("Folder")
	floorsFolder.Name = "Floors"
	floorsFolder.Parent = museum
	local slots = Instance.new("Folder")
	slots.Name = "Slots"
	slots.Parent = museum
	local arrivals = Instance.new("Folder")
	arrivals.Name = "Arrivals"
	arrivals.Parent = museum
	local waypoints = Instance.new("Folder")
	waypoints.Name = "Waypoints"
	waypoints.Parent = museum

	local ex = Architecture.builder(exterior, CFrame.new())
	local fl = Architecture.builder(floorsFolder, CFrame.new())

	-- FOUNDATION + PLAZA
	ex:roundedBlock("Foundation", Vector3.new(HALF * 2 + 6, 1.2, HALF * 2 + 6), CFrame.new(0, 0.1, 0), 6, "Lilac")
	ex:roundedBlock("Plaza", Vector3.new(76, 0.6, 30), CFrame.new(0, 0.3, -HALF - 16), 10, "MuseumTile")
	ex:roundedBlock("PlazaInlay", Vector3.new(60, 0.64, 18), CFrame.new(0, 0.32, -HALF - 16), 8, "Cloud")
	ex:box("PlazaGlow", Vector3.new(16, 0.66, 0.5), CFrame.new(0, 0.33, -HALF - 16), "GlowCyan")
	for _, x in ipairs({-30, 30}) do
		-- planters with round topiary and a lamp
		ex:tiers("Planter", CFrame.new(x, 0.6, -HALF - 22), {{7, 1.6, "White"}, {6, 0.4, "Mint"}})
		ex:ball("Topiary", 5, CFrame.new(x, 4.6, -HALF - 22), "Mint")
		ex:pill("LampPost", Vector3.new(x * 0.62, 0.6, -HALF - 26), Vector3.new(x * 0.62, 11, -HALF - 26), 0.6, "White")
		ex:bulb("LampGlow", 1.8, CFrame.new(x * 0.62, 12, -HALF - 26), "GlowSun", 16)
	end
	-- benches along the plaza
	for _, x in ipairs({-12, 12}) do
		ex:roundedBlock("Bench", Vector3.new(7, 0.8, 2.2), CFrame.new(x, 1.6, -HALF - 27), 1, "Sky")
		ex:box("BenchLeg", Vector3.new(5, 1.2, 1), CFrame.new(x, 0.8, -HALF - 27), "White")
	end

	-- FLOORS: slabs, ceiling lights, lift pads, arrivals
	for f = 1, FLOORS do
		local base = (f - 1) * FLOOR_H
		fl:box("FloorSlab", Vector3.new(HALF * 2 - WALL, f == 1 and 0.8 or 1.2, HALF * 2 - WALL), CFrame.new(0, base + (f == 1 and 0.6 or 0), 0), "MuseumTile")
		fl:ring("FloorInlay", CFrame.new(0, base + 0.72, 4) * CFrame.Angles(math.rad(90), 0, 0), 11, 0.5, "GlowCyan", 32)
		-- the lift pad: step onto it and use the arrows
		fl:tiers("LiftPad", CFrame.new(0, base + 0.6, 4), {{8, 0.3, "Violet"}, {6.6, 0.3, "GlowCyan"}})
		marker(arrivals, "Floor" .. f .. "Arrival", CFrame.new(0, base + 3.5, 4))
		-- soft ceiling light panels (the next slab is the ceiling)
		for _, x in ipairs({-12, 12}) do
			fl:roundedBlock("CeilingLight", Vector3.new(10, 0.3, 30), CFrame.new(x, base + FLOOR_H - 0.8, 0), 3, "White")
			local strip = fl:box("CeilingGlow", Vector3.new(0.6, 0.35, 28), CFrame.new(x, base + FLOOR_H - 0.9, 0), "GlowCyan")
			local l = Instance.new("SurfaceLight")
			l.Face = Enum.NormalId.Bottom
			l.Range = 18
			l.Brightness = 0.7
			l.Color = rgb(235, 240, 255)
			l.Parent = strip
		end
		local floorTop = base + (f == 1 and 1 or 0.6)
		for i, spot in ipairs(SLOT_SPOTS) do
			local pos = Vector3.new(spot[1].X, floorTop - 0.6, spot[1].Z)
			-- turn so the slot's front (-Z) faces into the room
			local facing = spot[2]
			buildSlot(slots, (f - 1) * #SLOT_SPOTS + i, f, CFrame.new(pos) * CFrame.Angles(0, math.atan2(-facing.X, -facing.Z), 0))
		end
	end
	fl:box("RoofSlab", Vector3.new(HALF * 2 + 2, 1.6, HALF * 2 + 2), CFrame.new(0, ROOF_Y + 0.8, 0), "White")

	-- WALLS: solid white sides and back with glass window strips, a glass front
	local wallX = HALF - WALL / 2
	-- a round porthole window: white rim, a glowing ring, blue glass (cf faces out along X)
	local function porthole(cf)
		ex:rod("PortholeRim", 0.9, 8.8, cf, "White")
		ex:rod("PortholeGlow", 1.1, 7.4, cf, "GlowCyan")
		ex:rod("PortholeGlass", 1.3, 6.6, cf, "MuseumPorthole")
	end
	for _, side in ipairs({-1, 1}) do
		ex:box("SideWall", Vector3.new(WALL, ROOF_Y, HALF * 2), CFrame.new(side * wallX, ROOF_Y / 2, 0), "MuseumWall")
		for f = 1, FLOORS do
			for _, z in ipairs({-16, 0, 16}) do
				porthole(CFrame.new(side * HALF, (f - 1) * FLOOR_H + 12, z))
			end
			-- a lilac band along each floor line
			ex:box("SideBand", Vector3.new(0.6, 1.6, HALF * 2 - 4), CFrame.new(side * (HALF + 0.1), f * FLOOR_H, 0), "Lilac")
		end
		ex:box("BaseBand", Vector3.new(0.6, 3, HALF * 2), CFrame.new(side * (HALF + 0.1), 2.2, 0), "Violet")
	end
	ex:box("BackWall", Vector3.new(HALF * 2, ROOF_Y, WALL), CFrame.new(0, ROOF_Y / 2, wallX), "MuseumWall")
	ex:box("BaseBand", Vector3.new(HALF * 2, 3, 0.6), CFrame.new(0, 2.2, HALF + 0.1), "Violet")
	for f = 1, FLOORS do
		for _, x in ipairs({-16, 0, 16}) do
			porthole(CFrame.new(x, (f - 1) * FLOOR_H + 12, HALF) * CFrame.Angles(0, math.rad(90), 0))
		end
		ex:box("BackBand", Vector3.new(HALF * 2 - 4, 1.6, 0.6), CFrame.new(0, f * FLOOR_H, HALF + 0.1), "Lilac")
	end
	-- front: glass curtain on floors 2-3, glass panels either side of the entrance on floor 1
	local frontZ = -wallX
	ex:box("FrontGlass", Vector3.new(HALF * 2 - 4, FLOOR_H * 2, 0.8), CFrame.new(0, FLOOR_H * 2, frontZ), "MuseumGlass")
	for _, side in ipairs({-1, 1}) do
		ex:box("FrontGlassLow", Vector3.new(HALF - 9, FLOOR_H, 0.8), CFrame.new(side * (HALF / 2 + 4.5), FLOOR_H / 2, frontZ), "MuseumGlass")
		ex:box("EntranceJamb", Vector3.new(2, 14, 1.6), CFrame.new(side * 8, 7, frontZ), "White")
	end
	ex:box("AboveEntrance", Vector3.new(18, FLOOR_H - 14, 0.8), CFrame.new(0, 14 + (FLOOR_H - 14) / 2, frontZ), "MuseumGlass")
	-- mullions and glowing floor bands across the front
	for i = -3, 3 do
		if i == 0 then continue end -- keep the doorway clear
		ex:box("Mullion", Vector3.new(0.5, ROOF_Y, 1.2), CFrame.new(i * 9, ROOF_Y / 2, frontZ - 0.2), "White", {CanCollide = false})
	end
	for f = 1, FLOORS - 1 do
		ex:box("FloorFascia", Vector3.new(HALF * 2, 1.6, 1.4), CFrame.new(0, f * FLOOR_H, frontZ - 0.4), "White")
		ex:box("FloorBand", Vector3.new(HALF * 2 - 2, 0.4, 0.3), CFrame.new(0, f * FLOOR_H - 1.1, frontZ - 1.1), "GlowCyan")
	end
	-- capsule corners
	for _, sx in ipairs({-1, 1}) do
		for _, sz in ipairs({-1, 1}) do
			local x, z = sx * HALF, sz * HALF
			ex:disc("CornerCapsule", 6, ROOF_Y + 2, CFrame.new(x, (ROOF_Y + 2) / 2, z), "Lilac")
			ex:ball("CornerDome", 6, CFrame.new(x, ROOF_Y + 2, z), "Violet")
			for f = 1, FLOORS do
				ex:disc("CornerBand", 6.3, 0.5, CFrame.new(x, (f - 1) * FLOOR_H + 17.5, z), "GlowPink")
			end
		end
	end

	-- ENTRANCE: round portal, saucer canopy
	local portal = CFrame.new(0, 7, frontZ - 1.2)
	ex:ring("PortalRing", portal, 8.4, 1.8, "White", 24, 180, 0)
	ex:ring("PortalGlow", portal * CFrame.new(0, 0, -0.9), 7.4, 0.4, "GlowCyan", 24, 180, 0)
	ex:ellipsoid("Canopy", Vector3.new(26, 2.4, 12), CFrame.new(0, 16.5, frontZ - 5), "White")
	ex:ellipsoid("CanopyUnder", Vector3.new(25, 1.4, 11), CFrame.new(0, 15.9, frontZ - 5), "Sky")
	for i = -2, 2 do
		ex:bulb("CanopyBulb", 0.9, CFrame.new(i * 4.5, 15.2, frontZ - 8.5), i % 2 == 0 and "GlowSun" or "GlowPink", 0)
	end

	-- THE ARCH: a giant white arch framing the whole front, with a glowing pink inner line
	local archZ = frontZ - 3.2
	local archR, archY = 28, 44
	for _, side in ipairs({-1, 1}) do
		ex:pill("ArchLeg", Vector3.new(side * archR, 1, archZ), Vector3.new(side * archR, archY, archZ), 4.6, "White")
		ex:box("ArchLegGlow", Vector3.new(0.8, archY - 3, 0.8), CFrame.new(side * (archR - 2.6), archY / 2 + 1, archZ), "GlowPink")
		ex:disc("ArchFoot", 7.4, 1.6, CFrame.new(side * archR, 0.8, archZ), "Violet")
	end
	ex:ring("Arch", CFrame.new(0, archY, archZ), archR, 4.6, "White", 26, 180, 0)
	ex:ring("ArchGlow", CFrame.new(0, archY, archZ), archR - 2.6, 0.8, "GlowPink", 26, 180, 0)
	ex:ball("ArchKeystone", 6.4, CFrame.new(0, archY + archR + 0.6, archZ), "Sun")

	-- the sign hangs inside the top of the arch
	ex:roundedBlock("SignBack", Vector3.new(36, 9.2, 1.2), CFrame.new(0, ROOF_Y - 2, archZ + 0.6), 3, "Violet")
	local sign = ex:roundedBlock("EntranceSign", Vector3.new(34, 7.8, 1.6), CFrame.new(0, ROOF_Y - 2, archZ), 2.6, "Ink")
	sign.Name = "EntranceSign"
	local signGui = surface(sign)
	textLabel(signGui, "TitleLabel", "MEME MUSEUM 2050", UDim2.fromScale(0, 0.06), UDim2.fromScale(1, 0.56), rgb(255, 222, 110))
	textLabel(signGui, "SubLabel", "EST. 2050", UDim2.fromScale(0, 0.62), UDim2.fromScale(1, 0.32), rgb(150, 230, 255))
	ex:box("SignGlow", Vector3.new(32, 0.4, 1.8), CFrame.new(0, ROOF_Y - 6.3, archZ), "GlowSun")

	-- ROOF: a parapet, and a flying saucer hovering over it on a glowing beam, with a glass
	-- bubble, a golden orb inside and a tilted orbit ring
	ex:roundedBlock("Parapet", Vector3.new(HALF * 2 + 3, 2.4, HALF * 2 + 3), CFrame.new(0, ROOF_Y + 2.6, 0), 4, "Lilac")
	local saucerY = ROOF_Y + 15
	ex:disc("SaucerBeam", 8, 12, CFrame.new(0, ROOF_Y + 7, 4), "MuseumGlass")
	ex:disc("SaucerBeamCore", 3, 12, CFrame.new(0, ROOF_Y + 7, 4), "GlowCyan")
	ex:ellipsoid("Saucer", Vector3.new(56, 7, 56), CFrame.new(0, saucerY, 4), "White")
	ex:ellipsoid("SaucerBelly", Vector3.new(46, 6, 46), CFrame.new(0, saucerY - 1.8, 4), "Violet")
	ex:disc("SaucerRim", 52, 0.6, CFrame.new(0, saucerY - 0.4, 4), "GlowCyan")
	ex:disc("SaucerWindows", 38, 1.8, CFrame.new(0, saucerY + 2.6, 4), "Navy")
	for i = 0, 7 do
		local a = math.rad(i * 45)
		ex:bulb("SaucerLight", 1.6, CFrame.new(math.cos(a) * 21, saucerY - 3.4, 4 + math.sin(a) * 21), i % 2 == 0 and "GlowSun" or "GlowPink", 0)
	end
	ex:ellipsoid("Bubble", Vector3.new(26, 18, 26), CFrame.new(0, saucerY + 3, 4), "MuseumGlass")
	ex:ball("BubbleOrb", 8, CFrame.new(0, saucerY + 6, 4), "MuseumGold")
	ex:ring("BubbleOrbit", CFrame.new(0, saucerY + 6, 4) * CFrame.Angles(math.rad(70), 0, math.rad(15)), 16, 0.9, "GlowSun", 28)
	ex:pill("Spire", Vector3.new(0, saucerY + 11.5, 4), Vector3.new(0, saucerY + 20, 4), 0.9, "Chrome")
	ex:bulb("Beacon", 2.4, CFrame.new(0, saucerY + 21, 4), "GlowPink", 20)

	-- ALIEN ART DEALER kiosk on the plaza (left of the entrance)
	local dealer = Instance.new("Model")
	dealer.Name = "AlienDealer"
	dealer.Parent = museum
	local dealerCF = CFrame.new(-24, 0.6, -HALF - 10) * CFrame.Angles(0, math.rad(-20), 0)
	local d = Architecture.builder(dealer, dealerCF)
	d:tiers("KioskBase", CFrame.new(), {{14, 0.6, "Violet"}, {12.6, 0.3, "GlowPink"}})
	local counter = d:roundedBlock("Counter", Vector3.new(10, 3.6, 3), CFrame.new(0, 2.7, -2.5), 1.2, "Mint")
	counter.Name = "Counter"
	d:roundedBlock("CounterTop", Vector3.new(10.6, 0.5, 3.6), CFrame.new(0, 4.7, -2.5), 1.4, "White")
	for _, x in ipairs({-5.5, 5.5}) do
		d:pill("KioskPole", Vector3.new(x, 0.9, 1.5), Vector3.new(x, 11, 1.5), 0.7, "White")
	end
	d:ellipsoid("KioskRoof", Vector3.new(15, 2.4, 9), CFrame.new(0, 11.6, 0), "Mint")
	local kioskSign = d:roundedBlock("KioskSign", Vector3.new(10, 2.6, 0.6), CFrame.new(0, 13.8, 0), 1, "Ink")
	textLabel(surface(kioskSign), "Label", "ALIEN ART DEALER", UDim2.fromScale(0, 0.1), UDim2.fromScale(1, 0.8), rgb(150, 255, 200))
	-- the dealer: a friendly alien behind the counter
	d:ellipsoid("AlienBody", Vector3.new(3, 4, 2.6), CFrame.new(0, 5.2, 0.4), "Violet")
	d:ellipsoid("AlienHead", Vector3.new(3.8, 3.4, 3.4), CFrame.new(0, 8.4, 0.4), "AlienSkin")
	for _, x in ipairs({-0.8, 0.8}) do
		d:ellipsoid("AlienEye", Vector3.new(1, 1.4, 0.6), CFrame.new(x, 8.6, -1.1) * CFrame.Angles(0, 0, x * 0.3), "Ink")
		d:pill("AlienAntenna", Vector3.new(x * 0.8, 9.8, 0.4), Vector3.new(x * 1.6, 11.2, 0.4), 0.25, "AlienSkin")
		d:bulb("AntennaTip", 0.6, CFrame.new(x * 1.6, 11.3, 0.4), "GlowSun", 0)
	end

	-- MARKERS for scripts
	local interior = marker(museum, "Interior", CFrame.new(0, ROOF_Y / 2, 0), Vector3.new(HALF * 2 - 3, ROOF_Y, HALF * 2 - 3))
	interior:SetAttribute("FloorHeight", FLOOR_H)
	marker(museum, "SpawnPoint", CFrame.lookAt(Vector3.new(0, 3.5, -HALF - 20), Vector3.new(0, 3.5, 0)))
	marker(waypoints, "Outside", CFrame.new(0, 3, -HALF - 22), Vector3.new(24, 1, 8))
	marker(waypoints, "Door", CFrame.new(0, 3, -HALF + 2))
	marker(waypoints, "Lobby", CFrame.new(0, 3, -HALF + 12), Vector3.new(10, 1, 4))

	-- decorative rings and ropes shouldn't trip anyone up
	local NO_COLLIDE = {FloorInlay = true, Rope = true, BubbleOrbit = true, PortalGlow = true, CanopyBulb = true, PlazaGlow = true,
		ArchGlow = true, ArchLegGlow = true, SaucerLight = true}
	for _, part in ipairs(museum:GetDescendants()) do
		if part:IsA("BasePart") and NO_COLLIDE[part.Name] then
			part.CanCollide = false
		end
	end

	museum.WorldPivot = CFrame.new(0, 0.5, 0) -- the plot part's center sits half a stud above the ground
	return museum
end

return build
]=])
install(game:GetService("ServerScriptService"), "MuseumManager", "Script", [=[
-- MuseumManager (Script in ServerScriptService)
-- Makes every player's museum (World 1 only) work:
--   * 24 display slots. Walk up to a pedestal and press E:
--       locked slot   -> buy it (its floor must be unlocked first)
--       empty slot    -> pick a meme from your inventory to put on it
--       occupied slot -> swap it for another meme, or take it back
--     Memes on display earn money every second (PlayerData pays it).
--   * Floors: the up/down arrows (MuseumClient) move you between floors or buy the next one.
--   * The Alien Art Dealer: sell memes from your inventory for cash.
-- The pedestals' signs, fact screens and info tags show what's on display; MuseumClient draws
-- the spinning meme card on top of each pedestal.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local function getRemote(name)
	local r = remotes:FindFirstChild(name) or Instance.new("RemoteEvent")
	r.Name = name
	r.Parent = remotes
	return r
end
local openSlotRemote = getRemote("OpenSlotMenu")      -- server -> client: (slotIndex)
local placeRemote = getRemote("PlaceInSlot")          -- client -> server: (slotIndex, artifactId)
local takeRemote = getRemote("TakeFromSlot")          -- client -> server: (slotIndex)
local openDealerRemote = getRemote("OpenDealer")      -- server -> client
local sellRemote = getRemote("SellArtifacts")         -- client -> server: (artifactId, sellAll)
local floorRemote = getRemote("ChangeFloor")          -- client -> server: (+1 up / -1 down)
local messageRemote = getRemote("ShopMessage")        -- server -> client: (text, success) toast
local inventoryChangedRemote = getRemote("InventoryChanged")
local placeAllRemote = getRemote("PlaceAll")          -- client -> server: fill every empty slot with your best memes

local SLOT_COUNT = #GameConfig.SlotPrices
local LOCKED_COLOR = Color3.fromRGB(150, 150, 170)
local EMPTY_COLOR = Color3.fromRGB(178, 158, 255)

local museums = {} -- [player] = museum model

---------------------------------------------------------------------
-- HELPERS
---------------------------------------------------------------------
local function isOwner(player, museum)
	return museum and museum.Parent and museum:GetAttribute("OwnerUserId") == player.UserId
end

local function labelsIn(part)
	local gui = part and part:FindFirstChildOfClass("SurfaceGui")
	local list = {}
	if gui then
		for _, child in ipairs(gui:GetChildren()) do
			if child:IsA("TextLabel") then table.insert(list, child) end
		end
	end
	return list
end

local function setText(label, text, color)
	if label then
		label.Text = text
		if color then label.TextColor3 = color end
	end
end

local function prompt(parent, name, objectText, distance)
	local p = parent:FindFirstChild(name) or Instance.new("ProximityPrompt")
	p.Name = name
	p.ObjectText = objectText
	p.KeyboardKeyCode = Enum.KeyCode.E
	p.HoldDuration = 0
	p.MaxActivationDistance = distance or 12
	p.RequiresLineOfSight = false
	p.Parent = parent
	return p
end

-- Takes one copy of an artifact out of the inventory (returns true if the player had one)
local function takeFromInventory(player, artifactId)
	local data = PlayerData.Get(player)
	if not data then return false end
	local best
	for uid, id in pairs(data.Inventory) do
		if id == artifactId and (not best or tonumber(uid) < tonumber(best)) then
			best = uid
		end
	end
	if not best then return false end
	PlayerData.RemoveArtifact(player, best)
	return true
end

local function countInInventory(data, artifactId)
	local n = 0
	for _, id in pairs(data.Inventory) do
		if id == artifactId then n += 1 end
	end
	return n
end

---------------------------------------------------------------------
-- SLOT VISUALS
---------------------------------------------------------------------
local function slotModel(museum, index)
	local slots = museum:FindFirstChild("Slots")
	return slots and slots:FindFirstChild("Slot" .. index)
end

local function paintGlow(slot, color)
	for _, name in ipairs({"AlcoveGlow", "GlowRing", "Band", "FactGlow"}) do
		local part = slot:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			part.Color = color
		end
	end
end

local function refreshSlot(player, museum, index)
	local slot = slotModel(museum, index)
	if not slot then return end
	local data = PlayerData.Get(player)
	if not data then return end
	local floor = GameConfig.GetFloorOfSlot(index)
	local unlocked = data.UnlockedSlots[tostring(index)] == true
	local artifact = unlocked and ArtifactData.GetArtifact(data.Displayed[tostring(index)] or "")

	local plaque = labelsIn(slot:FindFirstChild("Plaque"))[1]
	local facts = labelsIn(slot:FindFirstChild("FactScreen"))
	local spot = slot:FindFirstChild("DisplaySpot")
	local info = spot and spot:FindFirstChild("InfoGui")
	if info then
		info.StudsOffset = Vector3.new(0, 5.2, 0) -- above the spinning meme card
		info.MaxDistance = 60
	end
	local nameLabel = info and info:FindFirstChild("NameLabel")
	local incomeLabel = info and info:FindFirstChild("IncomeLabel")

	local slotPrompt = slot:FindFirstChild("Column") or slot:FindFirstChild("Cap") or spot
	slotPrompt = slotPrompt and prompt(slotPrompt, "SlotPrompt", "Display Slot " .. index, 12)

	slot:SetAttribute("SlotIndex", index)
	if not unlocked then
		local price = GameConfig.SlotPrices[index]
		local floorOpen = data.UnlockedFloors[tostring(floor)] == true
		slot:SetAttribute("ArtifactId", nil)
		slot:SetAttribute("Locked", true)
		paintGlow(slot, LOCKED_COLOR)
		setText(plaque, "LOCKED  •  " .. ArtifactData.FormatMoney(price))
		setText(facts[1], "SLOT " .. index .. " LOCKED", LOCKED_COLOR)
		setText(facts[2], floorOpen and ("Unlock it for " .. ArtifactData.FormatMoney(price)) or ("Unlock floor " .. floor .. " first"))
		setText(nameLabel, "LOCKED", LOCKED_COLOR)
		setText(incomeLabel, ArtifactData.FormatMoney(price))
		if slotPrompt then
			slotPrompt.ActionText = floorOpen and ("Unlock  " .. ArtifactData.FormatMoney(price)) or ("Floor " .. floor .. " locked")
		end
	elseif not artifact then
		slot:SetAttribute("ArtifactId", nil)
		slot:SetAttribute("Locked", false)
		paintGlow(slot, EMPTY_COLOR)
		setText(plaque, "EMPTY SLOT " .. index)
		setText(facts[1], "EMPTY DISPLAY", EMPTY_COLOR)
		setText(facts[2], "Put a meme here to earn money every second!")
		setText(nameLabel, "EMPTY", EMPTY_COLOR)
		setText(incomeLabel, "Press E to display a meme")
		if slotPrompt then slotPrompt.ActionText = "Display a meme" end
	else
		local rarity = ArtifactData.GetRarity(artifact.Rarity)
		local income = ArtifactData.GetIncome(artifact)
		slot:SetAttribute("ArtifactId", artifact.Id)
		slot:SetAttribute("Locked", false)
		paintGlow(slot, rarity.Color)
		setText(plaque, string.upper(artifact.Rarity) .. "  •  " .. artifact.Name)
		setText(facts[1], artifact.Name, rarity.Color)
		setText(facts[2], artifact.Description)
		setText(nameLabel, artifact.Name, rarity.Color)
		setText(incomeLabel, "+" .. ArtifactData.FormatMoney(income) .. "/s")
		if slotPrompt then slotPrompt.ActionText = "Swap / take back" end
	end
end

local function refreshAllSlots(player)
	local museum = museums[player]
	if not museum then return end
	for i = 1, SLOT_COUNT do
		refreshSlot(player, museum, i)
	end
end

---------------------------------------------------------------------
-- FLOORS (the up/down arrows in MuseumClient)
---------------------------------------------------------------------
local function arrivalFor(museum, floor)
	local arrivals = museum:FindFirstChild("Arrivals")
	local part = arrivals and arrivals:FindFirstChild("Floor" .. floor .. "Arrival")
	return part and part.CFrame * CFrame.new(0, 3, 0)
end

-- the museum shows which floors its owner has opened, so the arrows know what to show
local function publishFloors(player, museum)
	local data = PlayerData.Get(player)
	if not data then return end
	local list = {}
	for floor = 1, #GameConfig.FloorPrices do
		if data.UnlockedFloors[tostring(floor)] then table.insert(list, tostring(floor)) end
	end
	museum:SetAttribute("UnlockedFloors", table.concat(list, ","))
end

---------------------------------------------------------------------
-- SET UP A MUSEUM WHEN ITS OWNER JOINS
---------------------------------------------------------------------
local function setupMuseum(player, museum)
	museums[player] = museum
	PlayerData.WaitForData(player)
	if not player.Parent or not museum.Parent then return end

	-- display slots
	for i = 1, SLOT_COUNT do
		local slot = slotModel(museum, i)
		if slot then
			refreshSlot(player, museum, i)
			local p = slot:FindFirstChild("SlotPrompt", true)
			if p then
				p.Triggered:Connect(function(who)
					if not isOwner(who, museum) then
						messageRemote:FireClient(who, "This is " .. player.DisplayName .. "'s museum!", false)
						return
					end
					local data = PlayerData.Get(who)
					if not data then return end
					if data.UnlockedSlots[tostring(i)] then
						openSlotRemote:FireClient(who, i)
						return
					end
					-- buying a locked slot
					local floor = GameConfig.GetFloorOfSlot(i)
					if not data.UnlockedFloors[tostring(floor)] then
						messageRemote:FireClient(who, "Unlock floor " .. floor .. " first (use the arrows on the left)!", false)
					elseif PlayerData.SpendMoney(who, GameConfig.SlotPrices[i]) then
						PlayerData.UnlockSlot(who, i)
						refreshSlot(who, museum, i)
						messageRemote:FireClient(who, "Slot " .. i .. " unlocked! Put a meme on it.", true)
					else
						messageRemote:FireClient(who, "You need " .. ArtifactData.FormatMoney(GameConfig.SlotPrices[i]) .. " for this slot.", false)
					end
				end)
			end
		end
	end

	publishFloors(player, museum)

	-- the alien art dealer
	local dealer = museum:FindFirstChild("AlienDealer")
	local counter = dealer and (dealer:FindFirstChild("Counter") or dealer:FindFirstChildWhichIsA("BasePart", true))
	if counter then
		local p = prompt(counter, "DealerPrompt", "Alien Art Dealer", 14)
		p.ActionText = "Sell memes"
		p.Triggered:Connect(function(who)
			openDealerRemote:FireClient(who)
		end)
	end
end

local function watchPlayer(player)
	local function hook(ref)
		if ref:IsA("ObjectValue") and ref.Name == "Museum" and ref.Value then
			task.spawn(setupMuseum, player, ref.Value)
		end
	end
	player.ChildAdded:Connect(hook)
	local existing = player:FindFirstChild("Museum")
	if existing then hook(existing) end
end

Players.PlayerAdded:Connect(watchPlayer)
for _, player in ipairs(Players:GetPlayers()) do
	watchPlayer(player)
end
Players.PlayerRemoving:Connect(function(player)
	museums[player] = nil
end)

---------------------------------------------------------------------
-- REMOTES FROM THE SLOT MENU AND THE DEALER
---------------------------------------------------------------------
local function validSlot(player, index)
	return typeof(index) == "number" and index == math.floor(index) and index >= 1 and index <= SLOT_COUNT
		and PlayerData.IsSlotUnlocked(player, index) and museums[player] ~= nil
end

placeRemote.OnServerEvent:Connect(function(player, index, artifactId)
	if not validSlot(player, index) or typeof(artifactId) ~= "string" or not ArtifactData.GetArtifact(artifactId) then return end
	local data = PlayerData.Get(player)
	if not data or not takeFromInventory(player, artifactId) then
		messageRemote:FireClient(player, "You don't have that meme anymore.", false)
		return
	end
	local old = data.Displayed[tostring(index)]
	if old then
		PlayerData.AddArtifact(player, old) -- the swapped-out meme goes back to the bag
	end
	PlayerData.SetDisplayed(player, index, artifactId)
	refreshSlot(player, museums[player], index)
	inventoryChangedRemote:FireClient(player)
	local artifact = ArtifactData.GetArtifact(artifactId)
	messageRemote:FireClient(player, artifact.Name .. " is on display! +" .. ArtifactData.FormatMoney(ArtifactData.GetIncome(artifact)) .. "/s", true)
end)

-- PLACE ALL (inventory window): every empty, unlocked slot gets your best-earning meme
local lastPlaceAll = {}
placeAllRemote.OnServerEvent:Connect(function(player)
	if os.clock() - (lastPlaceAll[player] or 0) < 1 then return end
	lastPlaceAll[player] = os.clock()
	local data = PlayerData.Get(player)
	local museum = museums[player]
	if not data or not museum then return end
	-- the bag's memes, best earners first
	local memes = {}
	for _, id in pairs(data.Inventory) do
		local artifact = ArtifactData.GetArtifact(id)
		if artifact then table.insert(memes, artifact) end
	end
	table.sort(memes, function(a, b) return ArtifactData.GetIncome(a) > ArtifactData.GetIncome(b) end)
	local placed, nextMeme = 0, 1
	for index = 1, SLOT_COUNT do
		if nextMeme > #memes then break end
		if PlayerData.IsSlotUnlocked(player, index) and not data.Displayed[tostring(index)] then
			local artifact = memes[nextMeme]
			nextMeme += 1
			if takeFromInventory(player, artifact.Id) then
				PlayerData.SetDisplayed(player, index, artifact.Id)
				refreshSlot(player, museum, index)
				placed += 1
			end
		end
	end
	inventoryChangedRemote:FireClient(player)
	if placed > 0 then
		messageRemote:FireClient(player, "{Museum} Placed " .. placed .. " meme" .. (placed == 1 and "" or "s") .. " in your museum! Now earning " .. ArtifactData.FormatMoney(PlayerData.GetIncome(player)) .. "/s", true)
	elseif #memes == 0 then
		messageRemote:FireClient(player, "Your bag is empty. Go dig up some memes!", false)
	else
		messageRemote:FireClient(player, "No empty display slots! Unlock more slots in your museum.", false)
	end
end)

takeRemote.OnServerEvent:Connect(function(player, index)
	if not validSlot(player, index) then return end
	local data = PlayerData.Get(player)
	local old = data and data.Displayed[tostring(index)]
	if not old then return end
	PlayerData.SetDisplayed(player, index, nil)
	PlayerData.AddArtifact(player, old)
	refreshSlot(player, museums[player], index)
	inventoryChangedRemote:FireClient(player)
end)

sellRemote.OnServerEvent:Connect(function(player, artifactId, sellAll)
	if typeof(artifactId) ~= "string" then return end
	local artifact = ArtifactData.GetArtifact(artifactId)
	local data = PlayerData.Get(player)
	if not artifact or not data then return end
	local count = sellAll == true and countInInventory(data, artifactId) or 1
	local sold = 0
	for _ = 1, count do
		if takeFromInventory(player, artifactId) then
			sold += 1
		end
	end
	if sold == 0 then return end
	local total = ArtifactData.GetSellValue(artifact) * sold
	PlayerData.AddMoney(player, total)
	inventoryChangedRemote:FireClient(player)
	messageRemote:FireClient(player, "Sold " .. sold .. "x " .. artifact.Name .. " for " .. ArtifactData.FormatMoney(total) .. "!", true)
end)

local lastFloorChange = {}
floorRemote.OnServerEvent:Connect(function(player, direction)
	if direction ~= 1 and direction ~= -1 then return end
	if lastFloorChange[player] and os.clock() - lastFloorChange[player] < 0.5 then return end
	lastFloorChange[player] = os.clock()
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	-- which museum (and floor) is the player standing in?
	for owner, museum in pairs(museums) do
		local floor = museum.Parent and GameConfig.GetMuseumFloor(museum, root.Position)
		if floor then
			local target = floor + direction
			local data = PlayerData.Get(owner)
			if not data or target < 1 or target > #GameConfig.FloorPrices then return end
			if data.UnlockedFloors[tostring(target)] then
				player.Character:PivotTo(arrivalFor(museum, target))
			elseif player ~= owner then
				messageRemote:FireClient(player, owner.DisplayName .. " hasn't opened floor " .. target .. " yet.", false)
			elseif PlayerData.SpendMoney(owner, GameConfig.FloorPrices[target]) then
				PlayerData.UnlockFloor(owner, target)
				publishFloors(owner, museum)
				refreshAllSlots(owner)
				messageRemote:FireClient(owner, "Floor " .. target .. " unlocked!", true)
				player.Character:PivotTo(arrivalFor(museum, target))
			else
				messageRemote:FireClient(player, "You need " .. ArtifactData.FormatMoney(GameConfig.FloorPrices[target]) .. " to open floor " .. target .. ".", false)
			end
			return
		end
	end
end)
Players.PlayerRemoving:Connect(function(player)
	lastFloorChange[player] = nil
end)

print("MuseumManager ready: " .. SLOT_COUNT .. " display slots, floor arrows and the art dealer")
]=])
install(game:GetService("ServerScriptService"), "PlayerData", "ModuleScript", [=[
-- PlayerData (ModuleScript in ServerScriptService)
-- Loads and saves each player's progress with ProfileService (session-locked, auto-saving,
-- safe against two servers editing the same save), pays passive income every second from
-- the memes on display, gives offline earnings, and lets other server scripts change the
-- data safely. Museum slot and floor purchases go through UnlockSlot/UnlockFloor here
-- (MuseumManager checks the price and takes the money first).

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local ProfileService = require(script.Parent:WaitForChild("ProfileService"))

local STORE_NAME = "PlayerProfiles_v1" -- change the version to wipe everyone's data (e.g. before launch)
local OLD_STORE_NAME = "PlayerData_v1"  -- saves from before ProfileService; imported once per player
local oldStore = DataStoreService:GetDataStore(OLD_STORE_NAME)

local PlayerData = {}
local sessions = {} -- [player] = data table (the profile's Data, saved automatically)
local profiles = {} -- [player] = ProfileService profile

local changedEvent = Instance.new("BindableEvent")
PlayerData.Changed = changedEvent.Event -- fires (player, data) whenever something changes

---------------------------------------------------------------------
-- DEFAULT DATA FOR NEW PLAYERS
---------------------------------------------------------------------
local function defaultData()
	local unlockedSlots = {}
	for i, price in ipairs(GameConfig.SlotPrices) do
		if price == 0 then
			unlockedSlots[tostring(i)] = true
		end
	end
	return {
		DataVersion = 1,
		Money = GameConfig.StartingMoney,
		Inventory = {},       -- [uniqueId] = artifactId (artifacts not on display)
		NextUid = 1,
		Displayed = {},       -- [slotNumber] = artifactId (artifacts on pedestals)
		UnlockedSlots = unlockedSlots,
		UnlockedFloors = {["1"] = true},
		OwnedShovels = {RustyShovel = true},
		EquippedShovels = {["1"] = "RustyShovel"}, -- [worldId] = shovel id equipped in that world
		UnlockedWorlds = {["1"] = true},
		PermitsRefunded = true, -- new players never bought the old Dig Permits
		LastOnline = os.time(),
		Stats = {TotalEarned = 0, TotalDigs = 0},
		TutorialDone = false, -- the first-join walkthrough (TutorialManager)
		-- audio settings (SettingsManager / AudioClient), saved so they stick between visits
		Settings = table.clone(GameConfig.DefaultAudio), -- Music 30%, SFX 20%
		-- rebirths (RebirthManager): each one adds GameConfig.RebirthIncomeBonus to all museum income
		Rebirths = 0,
		Gems = 0,
		GemLuckLevel = 0, -- the Lucky Charm gem upgrade (+10% luck per level)
	}
end

-- Adds any missing fields to old saves (so future updates don't break old players)
local function reconcile(data, template)
	for key, value in pairs(template) do
		if data[key] == nil then
			data[key] = (type(value) == "table") and table.clone(value) or value
		elseif type(value) == "table" and type(data[key]) == "table" then
			reconcile(data[key], value)
		end
	end
end

-- every new profile starts as a copy of this; Reconcile() adds new fields to old saves
local profileStore = ProfileService.GetProfileStore(STORE_NAME, defaultData())

local function retry(fn)
	for attempt = 1, 3 do
		local ok, result = pcall(fn)
		if ok then
			return true, result
		end
		warn("DataStore error (attempt " .. attempt .. "): " .. tostring(result))
		task.wait(2 ^ attempt)
	end
	return false, nil
end

---------------------------------------------------------------------
-- INCOME + DISPLAY
---------------------------------------------------------------------
local function computeIncome(data)
	local total = 0
	for slot, artifactId in pairs(data.Displayed) do
		local artifact = ArtifactData.GetArtifact(artifactId)
		if artifact and data.UnlockedSlots[slot] then
			total += ArtifactData.GetIncome(artifact)
		end
	end
	-- every rebirth adds a permanent income bonus
	return total * (1 + GameConfig.RebirthIncomeBonus * (data.Rebirths or 0))
end

local function refresh(player)
	local data = sessions[player]
	if not data then return end
	local income = computeIncome(data)
	player:SetAttribute("Money", data.Money)
	player:SetAttribute("Income", income)
	player:SetAttribute("Gems", data.Gems or 0)
	player:SetAttribute("Rebirths", data.Rebirths or 0)
	player:SetAttribute("GemLuckLevel", data.GemLuckLevel or 0)
	player:SetAttribute("GemLuck", 1 + GameConfig.GemLuckPerLevel * (data.GemLuckLevel or 0))

	local stats = player:FindFirstChild("leaderstats")
	if stats then
		stats.Cash.Value = ArtifactData.FormatMoney(data.Money)
		stats.Income.Value = ArtifactData.FormatMoney(income) .. "/s"
	end
	changedEvent:Fire(player, data)
end

local function makeLeaderstats(player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local cash = Instance.new("StringValue")
	cash.Name = "Cash"
	cash.Parent = stats
	local income = Instance.new("StringValue")
	income.Name = "Income"
	income.Parent = stats
	stats.Parent = player
end

-- Upgrades saves from before worlds + shovel depth zones existed
local OLD_PERMIT_PRICES = {["2"] = 100000, ["3"] = 250e6} -- the removed Dig Permits
local function migrate(data)
	if data.EquippedShovels == nil then
		data.EquippedShovels = {["1"] = data.EquippedShovel or "RustyShovel"}
	end
	data.EquippedShovel = nil
	-- Depth is now decided by your shovel, so give back what was paid for Dig Permits
	if not data.PermitsRefunded then
		local refund = 0
		for layer, price in pairs(OLD_PERMIT_PRICES) do
			if data.UnlockedLayers and data.UnlockedLayers[layer] then
				refund += price
			end
		end
		data.Money = (data.Money or 0) + refund
		data.PermitsRefunded = true
	end
	data.UnlockedLayers = nil
	-- memes that were removed from the game (the old meme list) disappear from the save
	for uid, artifactId in pairs(data.Inventory or {}) do
		if not ArtifactData.GetArtifact(artifactId) then data.Inventory[uid] = nil end
	end
	for slot, artifactId in pairs(data.Displayed or {}) do
		if not ArtifactData.GetArtifact(artifactId) then data.Displayed[slot] = nil end
	end
end

---------------------------------------------------------------------
-- LOAD / SAVE
---------------------------------------------------------------------
local function load(player)
	local key = "Player_" .. player.UserId
	-- "ForceLoad": if another server still holds this save (e.g. the player just hopped
	-- servers), ProfileService asks it to let go and waits, instead of loading stale data
	local profile = profileStore:LoadProfileAsync(key, "ForceLoad")
	if not profile then
		-- Never play on empty data if loading failed, or we'd overwrite their real save
		player:Kick("Couldn't load your museum data. Please rejoin!")
		return
	end
	profile:AddUserId(player.UserId) -- GDPR: lets Roblox erase it on request
	profile:Reconcile()
	profile:ListenToRelease(function()
		profiles[player] = nil
		sessions[player] = nil
		-- the save was taken by another server: this session must stop using it
		if player.Parent then
			player:Kick("Your museum was opened on another server. Please rejoin!")
		end
	end)
	if not player.Parent then
		profile:Release() -- left while loading
		return
	end

	local data = profile.Data
	-- First time on ProfileService: bring over the save from the old DataStore
	local returning = profile.MetaData.SessionLoadCount > 1
	if not data.ImportedOldSave then
		local ok, old = retry(function()
			return oldStore:GetAsync(key)
		end)
		if not ok then
			profile:Release()
			player:Kick("Couldn't load your museum data. Please rejoin!")
			return
		end
		if type(old) == "table" then
			for field, value in pairs(old) do
				data[field] = value
			end
			migrate(data)
			reconcile(data, defaultData())
			returning = true
			print("[LOAD] Imported " .. player.Name .. "'s old save into ProfileService")
		end
		data.ImportedOldSave = true
	end
	migrate(data)

	-- Offline earnings
	if returning then
		local away = math.max(0, os.time() - (data.LastOnline or os.time()))
		local counted = math.min(away, GameConfig.OfflineCapHours * 3600)
		local earned = math.floor(computeIncome(data) * counted * GameConfig.OfflineMultiplier)
		if earned > 0 then
			data.Money += earned
			data.Stats.TotalEarned += earned
			player:SetAttribute("OfflineEarnings", earned)
			print(player.Name .. " earned " .. ArtifactData.FormatMoney(earned) .. " while offline")
		end
	else
		print("[LOAD] New player " .. player.Name .. ", starting fresh")
	end
	data.LastOnline = os.time()

	profiles[player] = profile
	sessions[player] = data
	makeLeaderstats(player)
	refresh(player)
	player:SetAttribute("DataLoaded", true)
	print(player.Name .. "'s data loaded. Money: " .. ArtifactData.FormatMoney(data.Money))
end

-- ProfileService saves on its own every ~30 seconds; releasing does the final save
local function release(player)
	local profile = profiles[player]
	if not profile then return end
	profile.Data.LastOnline = os.time()
	profiles[player] = nil
	sessions[player] = nil
	profile:Release()
end

---------------------------------------------------------------------
-- PUBLIC FUNCTIONS (other server scripts use these)
---------------------------------------------------------------------
function PlayerData.Get(player)
	return sessions[player]
end

function PlayerData.WaitForData(player)
	while player.Parent and not sessions[player] do
		task.wait(0.1)
	end
	return sessions[player]
end

function PlayerData.GetIncome(player)
	local data = sessions[player]
	return data and computeIncome(data) or 0
end

function PlayerData.AddMoney(player, amount)
	local data = sessions[player]
	if not data then return false end
	data.Money += amount
	if amount > 0 then
		data.Stats.TotalEarned += amount
	end
	refresh(player)
	return true
end

-- updates the player's attributes (money, income, gems...) after a change made directly on data
function PlayerData.Refresh(player)
	refresh(player)
end

-- Returns true if the player could afford it (and takes the money)
function PlayerData.SpendMoney(player, amount)
	local data = sessions[player]
	if not data or data.Money < amount then return false end
	data.Money -= amount
	refresh(player)
	return true
end

-- Adds an artifact to the inventory, returns its unique id
function PlayerData.AddArtifact(player, artifactId)
	local data = sessions[player]
	if not data then return nil end
	local uid = tostring(data.NextUid)
	data.NextUid += 1
	data.Inventory[uid] = artifactId
	refresh(player)
	return uid
end

-- Removes an artifact from the inventory, returns its artifact id
function PlayerData.RemoveArtifact(player, uid)
	local data = sessions[player]
	if not data then return nil end
	local artifactId = data.Inventory[uid]
	data.Inventory[uid] = nil
	refresh(player)
	return artifactId
end

-- Puts an artifact on a slot (or clears it with nil)
function PlayerData.SetDisplayed(player, slotIndex, artifactId)
	local data = sessions[player]
	if not data then return false end
	data.Displayed[tostring(slotIndex)] = artifactId
	refresh(player)
	return true
end

function PlayerData.IsSlotUnlocked(player, slotIndex)
	local data = sessions[player]
	return data ~= nil and data.UnlockedSlots[tostring(slotIndex)] == true
end

function PlayerData.UnlockSlot(player, slotIndex)
	local data = sessions[player]
	if not data then return false end
	data.UnlockedSlots[tostring(slotIndex)] = true
	refresh(player)
	return true
end

function PlayerData.IsFloorUnlocked(player, floor)
	local data = sessions[player]
	return data ~= nil and data.UnlockedFloors[tostring(floor)] == true
end

function PlayerData.UnlockFloor(player, floor)
	local data = sessions[player]
	if not data then return false end
	data.UnlockedFloors[tostring(floor)] = true
	refresh(player)
	return true
end

---------------------------------------------------------------------
-- START EVERYTHING
---------------------------------------------------------------------
Players.PlayerAdded:Connect(load)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(load, player)
end

Players.PlayerRemoving:Connect(release)

-- Pay income every second
task.spawn(function()
	while true do
		task.wait(1)
		for player, data in pairs(sessions) do
			local income = computeIncome(data)
			if income > 0 then
				data.Money += income
				data.Stats.TotalEarned += income
				refresh(player)
			end
		end
	end
end)

-- Autosaving and saving on shutdown are handled by ProfileService (it releases every
-- profile when the server closes).

return PlayerData
]=])
install(game:GetService("ServerScriptService"), "PlotManager", "Script", [=[
-- PlotManager (Script inside ServerScriptService)
-- Gives every player their own museum on a free plot,
-- puts their name on the sign, and spawns them in front of it.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- The museum is built from code (compact 2050 gallery, see MuseumBuilder); every player's
-- museum is a copy of it. (The old ServerStorage.MuseumTemplate is no longer used.)
local template = require(script.Parent:WaitForChild("MuseumBuilder"))()
local plotsFolder = workspace:WaitForChild("Plots")

local museumsFolder = workspace:FindFirstChild("Museums") or Instance.new("Folder")
museumsFolder.Name = "Museums"
museumsFolder.Parent = workspace

local ownedPlots = {}   -- [player] = plot part
local ownedMuseums = {} -- [player] = museum model

---------------------------------------------------------------------
-- FREE PLOTS: a glowing hologram of a museum on a round pad, so an empty plot looks like a
-- spot waiting for the next player instead of a bare patch of ground
---------------------------------------------------------------------
local Architecture = require(script.Parent:WaitForChild("Architecture"))
Architecture.Palette.HologramGlass = {Color = Color3.fromRGB(170, 150, 255), Material = Enum.Material.Glass, Transparency = 0.8}
local padsFolder = Instance.new("Folder")
padsFolder.Name = "FreePlots"
padsFolder.Parent = workspace
local plotPads = {} -- [plot part] = pad model

local function buildPad(plot)
	local pad = Instance.new("Model")
	pad.Name = "FreePlot"
	local b = Architecture.builder(pad, plot.CFrame * CFrame.new(0, -0.5, 0))
	b:roundedBlock("PadBase", Vector3.new(70, 0.8, 70), CFrame.new(0, 0.4, 0), 10, "Cloud")
	b:roundedBlock("PadInlay", Vector3.new(62, 0.84, 62), CFrame.new(0, 0.42, 0), 8, "Lilac")
	for _, side in ipairs({-1, 1}) do
		b:box("PadGlow", Vector3.new(56, 0.9, 0.6), CFrame.new(0, 0.45, side * 28), "GlowCyan")
		b:box("PadGlow", Vector3.new(0.6, 0.9, 56), CFrame.new(side * 28, 0.45, 0), "GlowCyan")
	end
	-- the hologram: a glowing wireframe museum in faintly tinted glass, with a dome
	local holo = {CanCollide = false, CanQuery = false, CanTouch = false, CastShadow = false}
	local H, S = 36, 26 -- height, half width
	b:box("Hologram", Vector3.new(S * 2, H, S * 2), CFrame.new(0, 1 + H / 2, 0), "HologramGlass", holo)
	b:ellipsoid("HologramDome", Vector3.new(30, 16, 30), CFrame.new(0, 1 + H, 0), "HologramGlass", holo)
	for _, sx in ipairs({-1, 1}) do
		for _, sz in ipairs({-1, 1}) do
			b:box("HologramEdge", Vector3.new(0.6, H, 0.6), CFrame.new(sx * S, 1 + H / 2, sz * S), "GlowCyan", holo)
		end
	end
	for _, y in ipairs({1 + H / 3, 1 + H * 2 / 3, 1 + H}) do
		for _, side in ipairs({-1, 1}) do
			b:box("HologramEdge", Vector3.new(S * 2, 0.5, 0.5), CFrame.new(0, y, side * S), "GlowCyan", holo)
			b:box("HologramEdge", Vector3.new(0.5, 0.5, S * 2), CFrame.new(side * S, y, 0), "GlowCyan", holo)
		end
	end
	b:ring("HologramRing", CFrame.new(0, 1 + H + 0.3, 0) * CFrame.Angles(math.rad(90), 0, 0), 15, 0.5, "GlowPink", 24)
	local sign = b:roundedBlock("PadSign", Vector3.new(30, 7, 1.2), CFrame.new(0, 6, -30), 2.4, "Ink")
	Architecture.sign(sign, "FREE PLOT", "A NEW MUSEUM OPENS HERE", Enum.NormalId.Front)
	b:box("PadSignLeg", Vector3.new(1, 3, 1), CFrame.new(-10, 1.5, -30), "White")
	b:box("PadSignLeg", Vector3.new(1, 3, 1), CFrame.new(10, 1.5, -30), "White")
	return pad
end

for _, plot in ipairs(plotsFolder:GetChildren()) do
	if plot:IsA("BasePart") then
		plotPads[plot] = buildPad(plot)
		plotPads[plot].Parent = (plot:GetAttribute("OwnerUserId") or 0) == 0 and padsFolder or nil
	end
end

local function getSortedPlots()
	local list = plotsFolder:GetChildren()
	table.sort(list, function(a, b)
		return (a:GetAttribute("PlotIndex") or 0) < (b:GetAttribute("PlotIndex") or 0)
	end)
	return list
end

local function findFreePlot()
	for _, plot in ipairs(getSortedPlots()) do
		if plot:GetAttribute("OwnerUserId") == 0 then
			return plot
		end
	end
	return nil
end

-- Spot on the plaza in front of the museum, facing the entrance
local function getSpawnCFrame(plot, museum)
	local spawnPoint = museum and museum:FindFirstChild("SpawnPoint")
	if spawnPoint then
		return spawnPoint.CFrame
	end
	return plot.CFrame * CFrame.new(0, 3.5, -52) * CFrame.Angles(0, math.pi, 0)
end

local function setOwnerSign(museum, player)
	local exterior = museum:FindFirstChild("Exterior")
	local sign = exterior and exterior:FindFirstChild("EntranceSign")
	local gui = sign and sign:FindFirstChildOfClass("SurfaceGui")
	local subLabel = gui and gui:FindFirstChild("SubLabel")
	if subLabel then
		subLabel.Text = string.upper(player.DisplayName) .. "'S COLLECTION  •  EST. 2050"
	end
end

local function sendHome(player)
	local plot = ownedPlots[player]
	local character = player.Character
	if plot and character then
		character:PivotTo(getSpawnCFrame(plot, ownedMuseums[player]))
	end
end

-- other scripts (the HUD's MUSEUM button, via DigManager) can send a player home
local sendHomeEvent = script.Parent:FindFirstChild("SendHome") or Instance.new("BindableEvent")
sendHomeEvent.Name = "SendHome"
sendHomeEvent.Parent = script.Parent
sendHomeEvent.Event:Connect(sendHome)

local function onCharacterAdded(player, character)
	character:WaitForChild("HumanoidRootPart")
	-- wait two frames so Roblox finishes its own spawning first
	RunService.Heartbeat:Wait()
	RunService.Heartbeat:Wait()
	sendHome(player)
end

local function onPlayerAdded(player)
	local plot = findFreePlot()
	if not plot then
		warn("No free plot for " .. player.Name)
		return
	end
	plot:SetAttribute("OwnerUserId", player.UserId)
	ownedPlots[player] = plot

	local museum = template:Clone()
	museum.Name = "Museum_" .. player.Name
	museum:SetAttribute("OwnerUserId", player.UserId)
	museum:PivotTo(plot.CFrame)
	-- pave the ground under the museum and its plaza, so the island's grass doesn't grow
	-- up through the floors (filled to 2 studs below the plot: the surface then sits level
	-- with it, see GameConfig.FlattenGround)
	workspace.Terrain:FillBlock(plot.CFrame * CFrame.new(0, -3, -14), Vector3.new(84, 2, 104), Enum.Material.Slate)
	local pad = plotPads[plot]
	if pad then pad.Parent = nil end
	setOwnerSign(museum, player)
	museum.Parent = museumsFolder
	ownedMuseums[player] = museum

	-- Lets other scripts (and the player's UI) find this player's museum
	local ref = Instance.new("ObjectValue")
	ref.Name = "Museum"
	ref.Value = museum
	ref.Parent = player

	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
	if player.Character then
		task.spawn(onCharacterAdded, player, player.Character)
	end
end

local function onPlayerRemoving(player)
	local museum = ownedMuseums[player]
	if museum then
		museum:Destroy()
	end
	local plot = ownedPlots[player]
	if plot then
		plot:SetAttribute("OwnerUserId", 0)
		if plotPads[plot] then plotPads[plot].Parent = padsFolder end
	end
	ownedMuseums[player] = nil
	ownedPlots[player] = nil
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Handle players who joined before this script started
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end
]=])
install(game:GetService("ServerScriptService"), "ProfileService", "ModuleScript", [=[
-- ProfileService by MadStudio (loleris), Apache License 2.0.
-- Source: https://github.com/MadStudioRoblox/ProfileService (full license: third_party/ProfileService/LICENSE)
-- Unmodified copy; PlayerData uses it for session-locked saving.
-- local Madwork = _G.Madwork
--[[
{Madwork}

-[ProfileService]---------------------------------------
	(STANDALONE VERSION)
	DataStore profiles - universal session-locked savable table API
	
	Official documentation:
		https://madstudioroblox.github.io/ProfileService/

	DevForum discussion:
		https://devforum.roblox.com/t/ProfileService/667805
	
	WARNINGS FOR "Profile.Data" VALUES:
	 	! Do not create numeric tables with gaps - attempting to replicate such tables will result in an error;
		! Do not create mixed tables (some values indexed by number and others by string key), as only
		     the data indexed by number will be replicated.
		! Do not index tables by anything other than numbers and strings.
		! Do not reference Roblox Instances
		! Do not reference userdata (Vector3, Color3, CFrame...) - Serialize userdata before referencing
		! Do not reference functions
		
	WARNING: Calling ProfileStore:LoadProfileAsync() with a "profile_key" which wasn't released in the SAME SESSION will result
		in an error! If you want to "ProfileStore:LoadProfileAsync()" instead of using the already loaded profile, :Release()
		the old Profile object.
		
	Members:
	
		ProfileService.ServiceLocked         [bool]
		
		ProfileService.IssueSignal           [ScriptSignal] (error_message, profile_store_name, profile_key)
		ProfileService.CorruptionSignal      [ScriptSignal] (profile_store_name, profile_key)
		ProfileService.CriticalStateSignal   [ScriptSignal] (is_critical_state)
	
	Functions:
	
		ProfileService.GetProfileStore(profile_store_index, profile_template) --> [ProfileStore]
			profile_store_index   [string] -- DataStore name
			OR
			profile_store_index   [table]: -- Allows the developer to define more GlobalDataStore variables
				{
					Name = "StoreName", -- [string] -- DataStore name
					-- Optional arguments:
					Scope = "StoreScope", -- [string] -- DataStore scope
				}
			profile_template      [table] -- Profiles will default to given table (hard-copy) when no data was saved previously

		ProfileService.IsLive() --> [bool] -- (CAN YIELD!!!)
			-- Returns true if ProfileService is connected to live Roblox DataStores
				
	Members [ProfileStore]:
	
		ProfileStore.Mock   [ProfileStore] -- Reflection of ProfileStore methods, but the methods will use a mock DataStore
		
	Methods [ProfileStore]:
	
		ProfileStore:LoadProfileAsync(profile_key, not_released_handler) --> [Profile] or nil -- not_released_handler(place_id, game_job_id)
			profile_key            [string] -- DataStore key
			not_released_handler   nil or []: -- Defaults to "ForceLoad"
				[string] "ForceLoad" -- Force loads profile on first call
				OR
				[string] "Steal" -- Steals the profile ignoring it's session lock
				OR
				[function] (place_id, game_job_id) --> [string] "Repeat", "Cancel", "ForceLoad" or "Steal"
					place_id      [number] or nil
					game_job_id   [string] or nil

				-- not_released_handler [function] will be triggered in cases where the profile is not released by a session. This
				--	function may yield for as long as desirable and must return one of three string values:

						["Repeat"] - ProfileService will repeat the profile loading proccess and may trigger the release handler again
						["Cancel"] - ProfileStore:LoadProfileAsync() will immediately return nil
						["ForceLoad"] - ProfileService will repeat the profile loading call, but will return Profile object afterwards
							and release the profile for another session that has loaded the profile
						["Steal"] - The profile will usually be loaded immediately, ignoring an existing remote session lock and applying
							a session lock for this session.

		ProfileStore:GlobalUpdateProfileAsync(profile_key, update_handler) --> [GlobalUpdates] or nil
			-- Returns GlobalUpdates object if update was successful, otherwise returns nil
			profile_key      [string] -- DataStore key
			update_handler   [function] (global_updates [GlobalUpdates])
			
		ProfileStore:ViewProfileAsync(profile_key, version) --> [Profile] or nil
			-- Reads profile without requesting a session lock; Data will not be saved and profile doesn't need to be released
			profile_key   [string] -- DataStore key
			version       nil or [string] -- DataStore key version

		ProfileStore:ProfileVersionQuery(profile_key, sort_direction, min_date, max_date) --> [ProfileVersionQuery]
			profile_key      [string]
			sort_direction   nil or [Enum.SortDirection]
			min_date         nil or [DateTime]
			max_date         nil or [DateTime]
			
		ProfileStore:WipeProfileAsync(profile_key) --> is_wipe_successful [bool]
			-- Completely wipes out profile data from the DataStore / mock DataStore with no way to recover it.
						
		* Parameter description for "ProfileStore:GlobalUpdateProfileAsync()":
		
			profile_key      [string] -- DataStore key
			update_handler   [function] (GlobalUpdates) -- This function gains access to GlobalUpdates object methods
				(update_handler can't yield)

	Methods [ProfileVersionQuery]:

		ProfileVersionQuery:NextAsync() --> [Profile] or nil -- (Yields)
			-- Returned profile has the same rules as profile returned by :ViewProfileAsync()
		
	Members [Profile]:
	
		Profile.Data              [table] -- Writable table that gets saved automatically and once the profile is released
		Profile.MetaData          [table] (Read-only) -- Information about this profile
		
			Profile.MetaData.ProfileCreateTime   [number] (Read-only) -- os.time() timestamp of profile creation
			Profile.MetaData.SessionLoadCount    [number] (Read-only) -- Amount of times the profile was loaded
			Profile.MetaData.ActiveSession       [table] (Read-only) {place_id, game_job_id} / nil -- Set to a session link if a
				game session is currently having this profile loaded; nil if released
			Profile.MetaData.MetaTags            [table] {["tag_name"] = tag_value, ...} -- Saved and auto-saved just like Profile.Data
			Profile.MetaData.MetaTagsLatest      [table] (Read-only) -- Latest version of MetaData.MetaTags that was definetly saved to DataStore
				(You can use Profile.MetaData.MetaTagsLatest for product purchase save confirmation, but create a system to clear old tags after
				they pile up)

		Profile.MetaTagsUpdated   [ScriptSignal] (meta_tags_latest) -- Fires after every auto-save, after
			--	Profile.MetaData.MetaTagsLatest has been updated with the version that's guaranteed to be saved;
			--  .MetaTagsUpdated will fire regardless of whether .MetaTagsLatest changed after update;
			--	.MetaTagsUpdated may fire after the Profile is released - changes to Profile.Data are not saved
			--	after release.

		Profile.RobloxMetaData    [table] -- Writable table that gets saved automatically and once the profile is released
		Profile.UserIds           [table] -- (Read-only) -- {user_id [number], ...} -- User ids associated with this profile

		Profile.KeyInfo           [DataStoreKeyInfo]
		Profile.KeyInfoUpdated    [ScriptSignal] (key_info [DataStoreKeyInfo])
		
		Profile.GlobalUpdates     [GlobalUpdates]
		
	Methods [Profile]:
	
		-- SAFE METHODS - Will not error after profile expires:
		Profile:IsActive() --> [bool] -- Returns true while the profile is active and can be written to
			
		Profile:GetMetaTag(tag_name) --> value [any]
			tag_name   [string]
		
		Profile:Reconcile() -- Fills in missing (nil) [string_key] = [value] pairs to the Profile.Data structure
		
		Profile:ListenToRelease(listener) --> [ScriptConnection] (place_id / nil, game_job_id / nil)
			-- WARNING: Profiles can be released externally if another session force-loads
			--	this profile - use :ListenToRelease() to handle player leaving cleanup.
			
		Profile:Release() -- Call after the session has finished working with this profile
			e.g., after the player leaves (Profile object will become expired) (Does not yield)

		Profile:ListenToHopReady(listener) --> [ScriptConnection] () -- Passed listener will be executed after the releasing UpdateAsync call finishes;
			--	Wrap universe teleport requests with this method AFTER releasing the profile to improve session lock sharing between universe places;
			--  :ListenToHopReady() will usually call the listener in around a second, but may ocassionally take up to 7 seconds when a release happens
			--	next to an auto-update in regular usage scenarios.

		Profile:AddUserId(user_id) -- Associates user_id with profile (GDPR compliance)
			user_id   [number]

		Profile:RemoveUserId(user_id) -- Unassociates user_id with profile (safe function)
			user_id   [number]

		Profile:Identify() --> [string] -- Returns a string containing DataStore name, scope and key; Used for debug;
			-- Example return: "[Store:"GameData";Scope:"Live";Key:"Player_2312310"]"
		
		Profile:SetMetaTag(tag_name, value) -- Equivalent of Profile.MetaData.MetaTags[tag_name] = value
			tag_name   [string]
			value      [any]
		
		Profile:Save() -- Call to quickly progress global update state or to speed up save validation processes (Does not yield)

		-- VIEW-MODE ONLY:

		Profile:ClearGlobalUpdates() -- Clears all global updates data from a profile payload

		Profile:OverwriteAsync() -- (Yields) Saves the profile payload to the DataStore and removes the session lock
		
	Methods [GlobalUpdates]:
	
	-- ALWAYS PUBLIC:
		GlobalUpdates:GetActiveUpdates() --> [table] {{update_id, update_data [table]}, ...}
		GlobalUpdates:GetLockedUpdates() --> [table] {{update_id, update_data [table]}, ...}
		
	-- ONLY WHEN FROM "Profile.GlobalUpdates":
		GlobalUpdates:ListenToNewActiveUpdate(listener) --> [ScriptConnection] (update_id, update_data)
			update_data   [table]
		GlobalUpdates:ListenToNewLockedUpdate(listener) --> [ScriptConnection] (update_id, update_data)
			update_data   [table]
		GlobalUpdates:LockActiveUpdate(update_id)  -- WARNING: will error after profile expires
		GlobalUpdates:ClearLockedUpdate(update_id) -- WARNING: will error after profile expires
		
	-- EXPOSED TO "update_handler" DURING ProfileStore:GlobalUpdateProfileAsync() CALL
		GlobalUpdates:AddActiveUpdate(update_data)
			update_data   [table]
		GlobalUpdates:ChangeActiveUpdate(update_id, update_data)
			update_data   [table]
		GlobalUpdates:ClearActiveUpdate(update_id)
		
--]]

local SETTINGS = {

	AutoSaveProfiles = 30, -- Seconds (This value may vary - ProfileService will split the auto save load evenly in the given time)
	RobloxWriteCooldown = 7, -- Seconds between successive DataStore calls for the same key
	ForceLoadMaxSteps = 8, -- Steps taken before ForceLoad request steals the active session for a profile
	AssumeDeadSessionLock = 30 * 60, -- (seconds) If a profile hasn't been updated for 30 minutes, assume the session lock is dead
		-- As of writing, os.time() is not completely reliable, so we can only assume session locks are dead after a significant amount of time.
	
	IssueCountForCriticalState = 5, -- Issues to collect to announce critical state
	IssueLast = 120, -- Seconds
	CriticalStateLast = 120, -- Seconds
	
	MetaTagsUpdatedValues = { -- Technical stuff - do not alter
		ProfileCreateTime = true,
		SessionLoadCount = true,
		ActiveSession = true,
		ForceLoadSession = true,
		LastUpdate = true,
	},
	
}

local Madwork -- Standalone Madwork reference for portable version of ProfileService
do

	local MadworkScriptSignal = {}

	local FreeRunnerThread = nil
	
	local function AcquireRunnerThreadAndCallEventHandler(fn, ...)
		local acquired_runner_thread = FreeRunnerThread
		FreeRunnerThread = nil
		fn(...)
		FreeRunnerThread = acquired_runner_thread
	end
	
	local function RunEventHandlerInFreeThread(...)
		AcquireRunnerThreadAndCallEventHandler(...)
		while true do
			AcquireRunnerThreadAndCallEventHandler(coroutine.yield())
		end
	end
	
	-- ScriptConnection object:

	local ScriptConnection = {
		--[[
			_listener = listener,
			_script_signal = script_signal,
			_disconnect_listener = disconnect_listener,
			_disconnect_param = disconnect_param,
			
			_next = next_script_connection,
			_is_connected = is_connected,
		--]]
	}
	ScriptConnection.__index = ScriptConnection

	function ScriptConnection:Disconnect()

		if self._is_connected == false then
			return
		end

		self._is_connected = false
		self._script_signal._listener_count -= 1

		if self._script_signal._head == self then
			self._script_signal._head = self._next
		else
			local prev = self._script_signal._head
			while prev ~= nil and prev._next ~= self do
				prev = prev._next
			end
			if prev ~= nil then
				prev._next = self._next
			end
		end

		if self._disconnect_listener ~= nil then
			if not FreeRunnerThread then
				FreeRunnerThread = coroutine.create(RunEventHandlerInFreeThread)
			end
			task.spawn(FreeRunnerThread, self._disconnect_listener, self._disconnect_param)
			self._disconnect_listener = nil
		end

	end
	
	-- ScriptSignal object:

	local ScriptSignal = {
		--[[
			_head = nil,
			_listener_count = 0,
		--]]
	}
	ScriptSignal.__index = ScriptSignal

	function ScriptSignal:Connect(listener, disconnect_listener, disconnect_param) --> [ScriptConnection]

		local script_connection = {
			_listener = listener,
			_script_signal = self,
			_disconnect_listener = disconnect_listener,
			_disconnect_param = disconnect_param,

			_next = self._head,
			_is_connected = true,
		}
		setmetatable(script_connection, ScriptConnection)

		self._head = script_connection
		self._listener_count += 1

		return script_connection

	end

	function ScriptSignal:GetListenerCount() --> [number]
		return self._listener_count
	end

	function ScriptSignal:Fire(...)
		local item = self._head
		while item ~= nil do
			if item._is_connected == true then
				if not FreeRunnerThread then
					FreeRunnerThread = coroutine.create(RunEventHandlerInFreeThread)
				end
				task.spawn(FreeRunnerThread, item._listener, ...)
			end
			item = item._next
		end
	end

	function ScriptSignal:FireUntil(continue_callback, ...)
		local item = self._head
		while item ~= nil do
			if item._is_connected == true then
				item._listener(...)
				if continue_callback() ~= true then
					return
				end
			end
			item = item._next
		end
	end

	function MadworkScriptSignal.NewScriptSignal() --> [ScriptSignal]
		return {
			_head = nil,
			_listener_count = 0,
			Connect = ScriptSignal.Connect,
			GetListenerCount = ScriptSignal.GetListenerCount,
			Fire = ScriptSignal.Fire,
			FireUntil = ScriptSignal.FireUntil,
		}
	end

	-- Madwork framework namespace:
	
	Madwork = {
		NewScriptSignal = MadworkScriptSignal.NewScriptSignal,
		ConnectToOnClose = function(task, run_in_studio_mode)
			if game:GetService("RunService"):IsStudio() == false or run_in_studio_mode == true then
				game:BindToClose(task)
			end
		end,
	}

end

----- Service Table -----

local ProfileService = {

	ServiceLocked = false, -- Set to true once the server is shutting down

	IssueSignal = Madwork.NewScriptSignal(), -- (error_message, profile_store_name, profile_key) -- Fired when a DataStore API call throws an error
	CorruptionSignal = Madwork.NewScriptSignal(), -- (profile_store_name, profile_key) -- Fired when DataStore key returns a value that has
	-- all or some of it's profile components set to invalid data types. E.g., accidentally setting Profile.Data to a noon table value

	CriticalState = false, -- Set to true while DataStore service is throwing too many errors
	CriticalStateSignal = Madwork.NewScriptSignal(), -- (is_critical_state) -- Fired when CriticalState is set to true
	-- (You may alert players with this, or set up analytics)

	ServiceIssueCount = 0,

	_active_profile_stores = {}, -- {profile_store, ...}

	_auto_save_list = {}, -- {profile, ...} -- loaded profile table which will be circularly auto-saved

	_issue_queue = {}, -- [table] {issue_time, ...}
	_critical_state_start = 0, -- [number] 0 = no critical state / os.clock() = critical state start

	-- Debug:
	_mock_data_store = {},
	_user_mock_data_store = {},

	_use_mock_data_store = false,

}

--[[
	Saved profile structure:
	
	DataStoreProfile = {
		Data = {},
		MetaData = {
			ProfileCreateTime = 0,
			SessionLoadCount = 0,
			ActiveSession = {place_id, game_job_id} / nil,
			ForceLoadSession = {place_id, game_job_id} / nil,
			MetaTags = {},
			LastUpdate = 0, -- os.time()
		},
		RobloxMetaData = {},
		UserIds = {},
		GlobalUpdates = {
			update_index,
			{
				{update_id, version_id, update_locked, update_data},
				...
			}
		},
	}
	
	OR
	
	DataStoreProfile = {
		GlobalUpdates = {
			update_index,
			{
				{update_id, version_id, update_locked, update_data},
				...
			}
		},
	}
--]]

----- Private Variables -----

local ActiveProfileStores = ProfileService._active_profile_stores
local AutoSaveList = ProfileService._auto_save_list
local IssueQueue = ProfileService._issue_queue

local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local PlaceId = game.PlaceId
local JobId = game.JobId

local AutoSaveIndex = 1 -- Next profile to auto save
local LastAutoSave = os.clock()

local LoadIndex = 0

local ActiveProfileLoadJobs = 0 -- Number of active threads that are loading in profiles
local ActiveProfileSaveJobs = 0 -- Number of active threads that are saving profiles

local CriticalStateStart = 0 -- os.clock()

local IsStudio = RunService:IsStudio()
local IsLiveCheckActive = false

local UseMockDataStore = false
local MockDataStore = ProfileService._mock_data_store -- Mock data store used when API access is disabled

local UserMockDataStore = ProfileService._user_mock_data_store -- Separate mock data store accessed via ProfileStore.Mock
local UseMockTag = {}

local CustomWriteQueue = {
	--[[
		[store] = {
			[key] = {
				LastWrite = os.clock(),
				Queue = {callback, ...},
				CleanupJob = nil,
			},
			...
		},
		...
	--]]
}

----- Utils -----

local function DeepCopyTable(t)
	local copy = {}
	for key, value in pairs(t) do
		if type(value) == "table" then
			copy[key] = DeepCopyTable(value)
		else
			copy[key] = value
		end
	end
	return copy
end

local function ReconcileTable(target, template)
	for k, v in pairs(template) do
		if type(k) == "string" then -- Only string keys will be reconciled
			if target[k] == nil then
				if type(v) == "table" then
					target[k] = DeepCopyTable(v)
				else
					target[k] = v
				end
			elseif type(target[k]) == "table" and type(v) == "table" then
				ReconcileTable(target[k], v)
			end
		end
	end
end

----- Private functions -----

local function IdentifyProfile(store_name, store_scope, key)
	return string.format(
		"[Store:\"%s\";%sKey:\"%s\"]",
		store_name,
		store_scope ~= nil and string.format("Scope:\"%s\";", store_scope) or "",
		key
	)
end

local function CustomWriteQueueCleanup(store, key)
	if CustomWriteQueue[store] ~= nil then
		CustomWriteQueue[store][key] = nil
		if next(CustomWriteQueue[store]) == nil then
			CustomWriteQueue[store] = nil
		end
	end
end

local function CustomWriteQueueMarkForCleanup(store, key)
	if CustomWriteQueue[store] ~= nil then
		if CustomWriteQueue[store][key] ~= nil then

			local queue_data = CustomWriteQueue[store][key]
			local queue = queue_data.Queue

			if queue_data.CleanupJob == nil then

				queue_data.CleanupJob = RunService.Heartbeat:Connect(function()
					if os.clock() - queue_data.LastWrite > SETTINGS.RobloxWriteCooldown and #queue == 0 then
						queue_data.CleanupJob:Disconnect()
						CustomWriteQueueCleanup(store, key)
					end
				end)

			end

		elseif next(CustomWriteQueue[store]) == nil then
			CustomWriteQueue[store] = nil
		end
	end
end

local function CustomWriteQueueAsync(callback, store, key) --> ... -- Passed return from callback

	if CustomWriteQueue[store] == nil then
		CustomWriteQueue[store] = {}
	end
	if CustomWriteQueue[store][key] == nil then
		CustomWriteQueue[store][key] = {LastWrite = 0, Queue = {}, CleanupJob = nil}
	end

	local queue_data = CustomWriteQueue[store][key]
	local queue = queue_data.Queue

	-- Cleanup job:

	if queue_data.CleanupJob ~= nil then
		queue_data.CleanupJob:Disconnect()
		queue_data.CleanupJob = nil
	end

	-- Queue logic:

	if os.clock() - queue_data.LastWrite > SETTINGS.RobloxWriteCooldown and #queue == 0 then
		queue_data.LastWrite = os.clock()
		return callback()
	else
		table.insert(queue, callback)
		while true do
			if os.clock() - queue_data.LastWrite > SETTINGS.RobloxWriteCooldown and queue[1] == callback then
				table.remove(queue, 1)
				queue_data.LastWrite = os.clock()
				return callback()
			end
			task.wait()
		end
	end

end

local function IsCustomWriteQueueEmptyFor(store, key) --> is_empty [bool]
	local lookup = CustomWriteQueue[store]
	if lookup ~= nil then
		lookup = lookup[key]
		return lookup == nil or #lookup.Queue == 0
	end
	return true
end

local function WaitForLiveAccessCheck() -- This function was created to prevent the ProfileService module yielding execution when required
	while IsLiveCheckActive == true do
		task.wait()
	end
end

local function WaitForPendingProfileStore(profile_store)
	while profile_store._is_pending == true do
		task.wait()
	end
end

local function RegisterIssue(error_message, store_name, store_scope, profile_key) -- Called when a DataStore API call errors
	warn("[ProfileService]: DataStore API error " .. IdentifyProfile(store_name, store_scope, profile_key) .. " - \"" .. tostring(error_message) .. "\"")
	table.insert(IssueQueue, os.clock()) -- Adding issue time to queue
	ProfileService.IssueSignal:Fire(tostring(error_message), store_name, profile_key)
end

local function RegisterCorruption(store_name, store_scope, profile_key) -- Called when a corrupted profile is loaded
	warn("[ProfileService]: Resolved profile corruption " .. IdentifyProfile(store_name, store_scope, profile_key))
	ProfileService.CorruptionSignal:Fire(store_name, profile_key)
end

local function NewMockDataStoreKeyInfo(params)

	local version_id_string = tostring(params.VersionId or 0)
	local meta_data = params.MetaData or {}
	local user_ids = params.UserIds or {}

	return {
		CreatedTime = params.CreatedTime,
		UpdatedTime = params.UpdatedTime,
		Version = string.rep("0", 16) .. "."
			.. string.rep("0", 10 - string.len(version_id_string)) .. version_id_string
			.. "." .. string.rep("0", 16) .. "." .. "01",

		GetMetadata = function()
			return DeepCopyTable(meta_data)
		end,

		GetUserIds = function()
			return DeepCopyTable(user_ids)
		end,
	}

end

local function MockUpdateAsync(mock_data_store, profile_store_name, key, transform_function, is_get_call) --> loaded_data, key_info

	local profile_store = mock_data_store[profile_store_name]

	if profile_store == nil then
		profile_store = {}
		mock_data_store[profile_store_name] = profile_store
	end

	local epoch_time = math.floor(os.time() * 1000)
	local mock_entry = profile_store[key]
	local mock_entry_was_nil = false

	if mock_entry == nil then
		mock_entry_was_nil = true
		if is_get_call ~= true then
			mock_entry = {
				Data = nil,
				CreatedTime = epoch_time,
				UpdatedTime = epoch_time,
				VersionId = 0,
				UserIds = {},
				MetaData = {},
			}
			profile_store[key] = mock_entry
		end
	end

	local mock_key_info = mock_entry_was_nil == false and NewMockDataStoreKeyInfo(mock_entry) or nil

	local transform, user_ids, roblox_meta_data = transform_function(mock_entry and mock_entry.Data, mock_key_info)

	if transform == nil then
		return nil
	else
		if mock_entry ~= nil and is_get_call ~= true then
			mock_entry.Data = transform
			mock_entry.UserIds = DeepCopyTable(user_ids or {})
			mock_entry.MetaData = DeepCopyTable(roblox_meta_data or {})
			mock_entry.VersionId += 1
			mock_entry.UpdatedTime = epoch_time
		end

		return DeepCopyTable(transform), mock_entry ~= nil and NewMockDataStoreKeyInfo(mock_entry) or nil
	end

end

local function IsThisSession(session_tag)
	return session_tag[1] == PlaceId and session_tag[2] == JobId
end

--[[
update_settings = {
	ExistingProfileHandle = function(latest_data),
	MissingProfileHandle = function(latest_data),
	EditProfile = function(lastest_data),
}
--]]
local function StandardProfileUpdateAsyncDataStore(profile_store, profile_key, update_settings, is_user_mock, is_get_call, version) --> loaded_data, key_info
	local loaded_data, key_info
	local success, error_message = pcall(function()
		local transform_function = function(latest_data)

			local missing_profile = false
			local data_corrupted = false
			local global_updates_data = {0, {}}

			if latest_data == nil then
				missing_profile = true
			elseif type(latest_data) ~= "table" then
				missing_profile = true
				data_corrupted = true
			end

			if type(latest_data) == "table" then
				-- Case #1: Profile was loaded
				if type(latest_data.Data) == "table"
					and type(latest_data.MetaData) == "table"
					and type(latest_data.GlobalUpdates) == "table" then

					latest_data.WasCorrupted = false -- Must be set to false if set previously
					global_updates_data = latest_data.GlobalUpdates
					if update_settings.ExistingProfileHandle ~= nil then
						update_settings.ExistingProfileHandle(latest_data)
					end
					-- Case #2: Profile was not loaded but GlobalUpdate data exists
				elseif latest_data.Data == nil
					and latest_data.MetaData == nil
					and type(latest_data.GlobalUpdates) == "table" then

					latest_data.WasCorrupted = false -- Must be set to false if set previously
					global_updates_data = latest_data.GlobalUpdates or global_updates_data
					missing_profile = true
				else
					missing_profile = true
					data_corrupted = true
				end
			end

			-- Case #3: Profile was not created or corrupted and no GlobalUpdate data exists
			if missing_profile == true then
				latest_data = {
					-- Data = nil,
					-- MetaData = nil,
					GlobalUpdates = global_updates_data,
				}
				if update_settings.MissingProfileHandle ~= nil then
					update_settings.MissingProfileHandle(latest_data)
				end
			end

			-- Editing profile:
			if update_settings.EditProfile ~= nil then
				update_settings.EditProfile(latest_data)
			end

			-- Data corruption handling (Silently override with empty profile) (Also run Case #1)
			if data_corrupted == true then
				latest_data.WasCorrupted = true -- Temporary tag that will be removed on first save
			end

			return latest_data, latest_data.UserIds, latest_data.RobloxMetaData
		end
		if is_user_mock == true then -- Used when the profile is accessed through ProfileStore.Mock
			loaded_data, key_info = MockUpdateAsync(UserMockDataStore, profile_store._profile_store_lookup, profile_key, transform_function, is_get_call)
			task.wait() -- Simulate API call yield
		elseif UseMockDataStore == true then -- Used when API access is disabled
			loaded_data, key_info = MockUpdateAsync(MockDataStore, profile_store._profile_store_lookup, profile_key, transform_function, is_get_call)
			task.wait() -- Simulate API call yield
		else
			loaded_data, key_info = CustomWriteQueueAsync(
				function() -- Callback
					if is_get_call == true then
						local get_data, get_key_info
						if version ~= nil then
							local success, error_message = pcall(function()
								get_data, get_key_info = profile_store._global_data_store:GetVersionAsync(profile_key, version)
							end)
							if success == false and type(error_message) == "string" and string.find(error_message, "not valid") ~= nil then
								warn("[ProfileService]: Passed version argument is not valid; Traceback:\n" .. debug.traceback())
							end
						else
							get_data, get_key_info = profile_store._global_data_store:GetAsync(profile_key)
						end
						get_data = transform_function(get_data)
						return get_data, get_key_info
					else
						return profile_store._global_data_store:UpdateAsync(profile_key, transform_function)
					end
				end,
				profile_store._profile_store_lookup, -- Store
				profile_key -- Key
			)
		end
	end)
	if success == true and type(loaded_data) == "table" then
		-- Corruption handling:
		if loaded_data.WasCorrupted == true and is_get_call ~= true then
			RegisterCorruption(
				profile_store._profile_store_name,
				profile_store._profile_store_scope,
				profile_key
			)
		end
		-- Return loaded_data:
		return loaded_data, key_info
	else
		RegisterIssue(
			(error_message ~= nil) and error_message or "Undefined error",
			profile_store._profile_store_name,
			profile_store._profile_store_scope,
			profile_key
		)
		-- Return nothing:
		return nil
	end
end

local function RemoveProfileFromAutoSave(profile)
	local auto_save_index = table.find(AutoSaveList, profile)
	if auto_save_index ~= nil then
		table.remove(AutoSaveList, auto_save_index)
		if auto_save_index < AutoSaveIndex then
			AutoSaveIndex = AutoSaveIndex - 1 -- Table contents were moved left before AutoSaveIndex so move AutoSaveIndex left as well
		end
		if AutoSaveList[AutoSaveIndex] == nil then -- AutoSaveIndex was at the end of the AutoSaveList - reset to 1
			AutoSaveIndex = 1
		end
	end
end

local function AddProfileToAutoSave(profile) -- Notice: Makes sure this profile isn't auto-saved too soon
	-- Add at AutoSaveIndex and move AutoSaveIndex right:
	table.insert(AutoSaveList, AutoSaveIndex, profile)
	if #AutoSaveList > 1 then
		AutoSaveIndex = AutoSaveIndex + 1
	elseif #AutoSaveList == 1 then
		-- First profile created - make sure it doesn't get immediately auto saved:
		LastAutoSave = os.clock()
	end
end

local function ReleaseProfileInternally(profile)
	-- 1) Remove profile object from ProfileService references: --
	-- Clear reference in ProfileStore:
	local profile_store = profile._profile_store
	local loaded_profiles = profile._is_user_mock == true and profile_store._mock_loaded_profiles or profile_store._loaded_profiles
	loaded_profiles[profile._profile_key] = nil
	if next(profile_store._loaded_profiles) == nil and next(profile_store._mock_loaded_profiles) == nil then -- ProfileStore has turned inactive
		local index = table.find(ActiveProfileStores, profile_store)
		if index ~= nil then
			table.remove(ActiveProfileStores, index)
		end
	end
	-- Clear auto update reference:
	RemoveProfileFromAutoSave(profile)
	-- 2) Trigger release listeners: --
	local place_id
	local game_job_id
	local active_session = profile.MetaData.ActiveSession
	if active_session ~= nil then
		place_id = active_session[1]
		game_job_id = active_session[2]
	end
	profile._release_listeners:Fire(place_id, game_job_id)
end

local function CheckForNewGlobalUpdates(profile, old_global_updates_data, new_global_updates_data)
	local global_updates_object = profile.GlobalUpdates -- [GlobalUpdates]
	local pending_update_lock = global_updates_object._pending_update_lock -- {update_id, ...}
	local pending_update_clear = global_updates_object._pending_update_clear -- {update_id, ...}
	-- "old_" or "new_" global_updates_data = {update_index, {{update_id, version_id, update_locked, update_data}, ...}}
	for _, new_global_update in ipairs(new_global_updates_data[2]) do
		-- Find old global update with the same update_id:
		local old_global_update
		for _, global_update in ipairs(old_global_updates_data[2]) do
			if global_update[1] == new_global_update[1] then
				old_global_update = global_update
				break
			end
		end
		-- A global update is new when it didn't exist before or its version_id or update_locked state changed:
		local is_new = false
		if old_global_update == nil or new_global_update[2] > old_global_update[2] or new_global_update[3] ~= old_global_update[3] then
			is_new = true
		end
		if is_new == true then
			-- Active global updates:
			if new_global_update[3] == false then
				-- Check if update is not pending to be locked: (Preventing firing new active update listeners more than necessary)
				local is_pending_lock = false
				for _, update_id in ipairs(pending_update_lock) do
					if new_global_update[1] == update_id then
						is_pending_lock = true
						break
					end
				end
				if is_pending_lock == false then
					-- Trigger new active update listeners:
					global_updates_object._new_active_update_listeners:Fire(new_global_update[1], new_global_update[4])
				end
			end
			-- Locked global updates:
			if new_global_update[3] == true then
				-- Check if update is not pending to be cleared: (Preventing firing new locked update listeners after marking a locked update for clearing)
				local is_pending_clear = false
				for _, update_id in ipairs(pending_update_clear) do
					if new_global_update[1] == update_id then
						is_pending_clear = true
						break
					end
				end
				if is_pending_clear == false then
					-- Trigger new locked update listeners:

					global_updates_object._new_locked_update_listeners:FireUntil(
						function()
							-- Check if listener marked the update to be cleared:
							-- Normally there should be only one listener per profile for new locked global updates, but
							-- in case several listeners are connected we will not trigger more listeners after one listener
							-- marks the locked global update to be cleared.
							return table.find(pending_update_clear, new_global_update[1]) == nil
						end,
						new_global_update[1], new_global_update[4]
					)

				end
			end
		end
	end
end

local function SaveProfileAsync(profile, release_from_session, is_overwriting)
	if type(profile.Data) ~= "table" then
		RegisterCorruption(
			profile._profile_store._profile_store_name,
			profile._profile_store._profile_store_scope,
			profile._profile_key
		)
		error("[ProfileService]: PROFILE DATA CORRUPTED DURING RUNTIME! Profile: " .. profile:Identify())
	end
	if release_from_session == true and is_overwriting ~= true then
		ReleaseProfileInternally(profile)
	end
	ActiveProfileSaveJobs = ActiveProfileSaveJobs + 1
	local last_session_load_count = profile.MetaData.SessionLoadCount
	-- Compare "SessionLoadCount" when writing to profile to prevent a rare case of repeat last save when the profile is loaded on the same server again
	local repeat_save_flag = true -- Released Profile save calls have to repeat until they succeed
	while repeat_save_flag == true do
		if release_from_session ~= true then
			repeat_save_flag = false
		end
		local loaded_data, key_info = StandardProfileUpdateAsyncDataStore(
			profile._profile_store,
			profile._profile_key,
			{
				ExistingProfileHandle = nil,
				MissingProfileHandle = nil,
				EditProfile = function(latest_data)

					local session_owns_profile = false
					local force_load_pending = false

					if is_overwriting ~= true then
						-- 1) Check if this session still owns the profile: --
						local active_session = latest_data.MetaData.ActiveSession
						local force_load_session = latest_data.MetaData.ForceLoadSession
						local session_load_count = latest_data.MetaData.SessionLoadCount

						if type(active_session) == "table" then
							session_owns_profile = IsThisSession(active_session) and session_load_count == last_session_load_count
						end
						if type(force_load_session) == "table" then
							force_load_pending = not IsThisSession(force_load_session)
						end
					else
						session_owns_profile = true
					end

					if session_owns_profile == true then -- We may only edit the profile if this session has ownership of the profile

						if is_overwriting ~= true then
							-- 2) Manage global updates: --
							local latest_global_updates_data = latest_data.GlobalUpdates -- {update_index, {{update_id, version_id, update_locked, update_data}, ...}}
							local latest_global_updates_list = latest_global_updates_data[2]

							local global_updates_object = profile.GlobalUpdates -- [GlobalUpdates]
							local pending_update_lock = global_updates_object._pending_update_lock -- {update_id, ...}
							local pending_update_clear = global_updates_object._pending_update_clear -- {update_id, ...}
							-- Active update locking:
							for i = 1, #latest_global_updates_list do
								for _, lock_id in ipairs(pending_update_lock) do
									if latest_global_updates_list[i][1] == lock_id then
										latest_global_updates_list[i][3] = true
										break
									end
								end
							end
							-- Locked update clearing:
							for _, clear_id in ipairs(pending_update_clear) do
								for i = 1, #latest_global_updates_list do
									if latest_global_updates_list[i][1] == clear_id and latest_global_updates_list[i][3] == true then
										table.remove(latest_global_updates_list, i)
										break
									end
								end
							end
						end

						-- 3) Save profile data: --
						latest_data.Data = profile.Data
						latest_data.RobloxMetaData = profile.RobloxMetaData
						latest_data.UserIds = profile.UserIds

						if is_overwriting ~= true then
							latest_data.MetaData.MetaTags = profile.MetaData.MetaTags -- MetaData.MetaTags is the only actively savable component of MetaData
							latest_data.MetaData.LastUpdate = os.time()
							if release_from_session == true or force_load_pending == true then
								latest_data.MetaData.ActiveSession = nil
							end
						else
							latest_data.MetaData = profile.MetaData
							latest_data.MetaData.ActiveSession = nil
							latest_data.MetaData.ForceLoadSession = nil
							latest_data.GlobalUpdates = profile.GlobalUpdates._updates_latest
						end

					end
				end,
			},
			profile._is_user_mock
		)
		if loaded_data ~= nil and key_info ~= nil then
			if is_overwriting == true then
				break
			end
			repeat_save_flag = false
			-- 4) Set latest data in profile: --
			-- Updating DataStoreKeyInfo:
			profile.KeyInfo = key_info
			-- Setting global updates:
			local global_updates_object = profile.GlobalUpdates -- [GlobalUpdates]
			local old_global_updates_data = global_updates_object._updates_latest
			local new_global_updates_data = loaded_data.GlobalUpdates
			global_updates_object._updates_latest = new_global_updates_data
			-- Setting MetaData:
			local session_meta_data = profile.MetaData
			local latest_meta_data = loaded_data.MetaData
			for key in pairs(SETTINGS.MetaTagsUpdatedValues) do
				session_meta_data[key] = latest_meta_data[key]
			end
			session_meta_data.MetaTagsLatest = latest_meta_data.MetaTags
			-- 5) Check if session still owns the profile: --
			local active_session = loaded_data.MetaData.ActiveSession
			local session_load_count = loaded_data.MetaData.SessionLoadCount
			local session_owns_profile = false
			if type(active_session) == "table" then
				session_owns_profile = IsThisSession(active_session) and session_load_count == last_session_load_count
			end
			local is_active = profile:IsActive()
			if session_owns_profile == true then
				-- 6) Check for new global updates: --
				if is_active == true then -- Profile could've been released before the saving thread finished
					CheckForNewGlobalUpdates(profile, old_global_updates_data, new_global_updates_data)
				end
			else
				-- Session no longer owns the profile:
				-- 7) Release profile if it hasn't been released yet: --
				if is_active == true then
					ReleaseProfileInternally(profile)
				end
				-- Cleanup reference in custom write queue:
				CustomWriteQueueMarkForCleanup(profile._profile_store._profile_store_lookup, profile._profile_key)
				-- Hop ready listeners:
				if profile._hop_ready == false then
					profile._hop_ready = true
					profile._hop_ready_listeners:Fire()
				end
			end
			-- Signaling MetaTagsUpdated listeners after a possible external profile release was handled:
			profile.MetaTagsUpdated:Fire(profile.MetaData.MetaTagsLatest)
			-- Signaling KeyInfoUpdated listeners:
			profile.KeyInfoUpdated:Fire(key_info)
		elseif repeat_save_flag == true then
			task.wait() -- Prevent infinite loop in case DataStore API does not yield
		end
	end
	ActiveProfileSaveJobs = ActiveProfileSaveJobs - 1
end

----- Public functions -----

-- GlobalUpdates object:

local GlobalUpdates = {
	--[[
		_updates_latest = {}, -- [table] {update_index, {{update_id, version_id, update_locked, update_data}, ...}}
		_pending_update_lock = {update_id, ...} / nil, -- [table / nil]
		_pending_update_clear = {update_id, ...} / nil, -- [table / nil]
		
		_new_active_update_listeners = [ScriptSignal] / nil, -- [table / nil]
		_new_locked_update_listeners = [ScriptSignal] / nil, -- [table / nil]
		
		_profile = Profile / nil, -- [Profile / nil]
		
		_update_handler_mode = true / nil, -- [bool / nil]
	--]]
}
GlobalUpdates.__index = GlobalUpdates

-- ALWAYS PUBLIC:
function GlobalUpdates:GetActiveUpdates() --> [table] {{update_id, update_data}, ...}
	local query_list = {}
	for _, global_update in ipairs(self._updates_latest[2]) do
		if global_update[3] == false then
			local is_pending_lock = false
			if self._pending_update_lock ~= nil then
				for _, update_id in ipairs(self._pending_update_lock) do
					if global_update[1] == update_id then
						is_pending_lock = true -- Exclude global updates pending to be locked
						break
					end
				end
			end
			if is_pending_lock == false then
				table.insert(query_list, {global_update[1], global_update[4]})
			end
		end
	end
	return query_list
end

function GlobalUpdates:GetLockedUpdates() --> [table] {{update_id, update_data}, ...}
	local query_list = {}
	for _, global_update in ipairs(self._updates_latest[2]) do
		if global_update[3] == true then
			local is_pending_clear = false
			if self._pending_update_clear ~= nil then
				for _, update_id in ipairs(self._pending_update_clear) do
					if global_update[1] == update_id then
						is_pending_clear = true -- Exclude global updates pending to be cleared
						break
					end
				end
			end
			if is_pending_clear == false then
				table.insert(query_list, {global_update[1], global_update[4]})
			end
		end
	end
	return query_list
end

-- ONLY WHEN FROM "Profile.GlobalUpdates":
function GlobalUpdates:ListenToNewActiveUpdate(listener) --> [ScriptConnection] listener(update_id, update_data)
	if type(listener) ~= "function" then
		error("[ProfileService]: Only a function can be set as listener in GlobalUpdates:ListenToNewActiveUpdate()")
	end
	local profile = self._profile
	if self._update_handler_mode == true then
		error("[ProfileService]: Can't listen to new global updates in ProfileStore:GlobalUpdateProfileAsync()")
	elseif self._new_active_update_listeners == nil then
		error("[ProfileService]: Can't listen to new global updates in view mode")
	elseif profile:IsActive() == false then -- Check if profile is expired
		return { -- Do not connect listener if the profile is expired
			Disconnect = function() end,
		}
	end
	-- Connect listener:
	return self._new_active_update_listeners:Connect(listener)
end

function GlobalUpdates:ListenToNewLockedUpdate(listener) --> [ScriptConnection] listener(update_id, update_data)
	if type(listener) ~= "function" then
		error("[ProfileService]: Only a function can be set as listener in GlobalUpdates:ListenToNewLockedUpdate()")
	end
	local profile = self._profile
	if self._update_handler_mode == true then
		error("[ProfileService]: Can't listen to new global updates in ProfileStore:GlobalUpdateProfileAsync()")
	elseif self._new_locked_update_listeners == nil then
		error("[ProfileService]: Can't listen to new global updates in view mode")
	elseif profile:IsActive() == false then -- Check if profile is expired
		return { -- Do not connect listener if the profile is expired
			Disconnect = function() end,
		}
	end
	-- Connect listener:
	return self._new_locked_update_listeners:Connect(listener)
end

function GlobalUpdates:LockActiveUpdate(update_id)
	if type(update_id) ~= "number" then
		error("[ProfileService]: Invalid update_id")
	end
	local profile = self._profile
	if self._update_handler_mode == true then
		error("[ProfileService]: Can't lock active global updates in ProfileStore:GlobalUpdateProfileAsync()")
	elseif self._pending_update_lock == nil then
		error("[ProfileService]: Can't lock active global updates in view mode")
	elseif profile:IsActive() == false then -- Check if profile is expired
		error("[ProfileService]: PROFILE EXPIRED - Can't lock active global updates")
	end
	-- Check if global update exists with given update_id
	local global_update_exists = nil
	for _, global_update in ipairs(self._updates_latest[2]) do
		if global_update[1] == update_id then
			global_update_exists = global_update
			break
		end
	end
	if global_update_exists ~= nil then
		local is_pending_lock = false
		for _, lock_update_id in ipairs(self._pending_update_lock) do
			if update_id == lock_update_id then
				is_pending_lock = true -- Exclude global updates pending to be locked
				break
			end
		end
		if is_pending_lock == false and global_update_exists[3] == false then -- Avoid id duplicates in _pending_update_lock
			table.insert(self._pending_update_lock, update_id)
		end
	else
		error("[ProfileService]: Passed non-existant update_id")
	end
end

function GlobalUpdates:ClearLockedUpdate(update_id)
	if type(update_id) ~= "number" then
		error("[ProfileService]: Invalid update_id")
	end
	local profile = self._profile
	if self._update_handler_mode == true then
		error("[ProfileService]: Can't clear locked global updates in ProfileStore:GlobalUpdateProfileAsync()")
	elseif self._pending_update_clear == nil then
		error("[ProfileService]: Can't clear locked global updates in view mode")
	elseif profile:IsActive() == false then -- Check if profile is expired
		error("[ProfileService]: PROFILE EXPIRED - Can't clear locked global updates")
	end
	-- Check if global update exists with given update_id
	local global_update_exists = nil
	for _, global_update in ipairs(self._updates_latest[2]) do
		if global_update[1] == update_id then
			global_update_exists = global_update
			break
		end
	end
	if global_update_exists ~= nil then
		local is_pending_clear = false
		for _, clear_update_id in ipairs(self._pending_update_clear) do
			if update_id == clear_update_id then
				is_pending_clear = true -- Exclude global updates pending to be cleared
				break
			end
		end
		if is_pending_clear == false and global_update_exists[3] == true then -- Avoid id duplicates in _pending_update_clear
			table.insert(self._pending_update_clear, update_id)
		end
	else
		error("[ProfileService]: Passed non-existant update_id")
	end
end

-- EXPOSED TO "update_handler" DURING ProfileStore:GlobalUpdateProfileAsync() CALL
function GlobalUpdates:AddActiveUpdate(update_data)
	if type(update_data) ~= "table" then
		error("[ProfileService]: Invalid update_data")
	end
	if self._new_active_update_listeners ~= nil then
		error("[ProfileService]: Can't add active global updates in loaded Profile; Use ProfileStore:GlobalUpdateProfileAsync()")
	elseif self._update_handler_mode ~= true then
		error("[ProfileService]: Can't add active global updates in view mode; Use ProfileStore:GlobalUpdateProfileAsync()")
	end
	-- self._updates_latest = {}, -- [table] {update_index, {{update_id, version_id, update_locked, update_data}, ...}}
	local updates_latest = self._updates_latest
	local update_index = updates_latest[1] + 1 -- Incrementing global update index
	updates_latest[1] = update_index
	-- Add new active global update:
	table.insert(updates_latest[2], {update_index, 1, false, update_data})
end

function GlobalUpdates:ChangeActiveUpdate(update_id, update_data)
	if type(update_id) ~= "number" then
		error("[ProfileService]: Invalid update_id")
	end
	if type(update_data) ~= "table" then
		error("[ProfileService]: Invalid update_data")
	end
	if self._new_active_update_listeners ~= nil then
		error("[ProfileService]: Can't change active global updates in loaded Profile; Use ProfileStore:GlobalUpdateProfileAsync()")
	elseif self._update_handler_mode ~= true then
		error("[ProfileService]: Can't change active global updates in view mode; Use ProfileStore:GlobalUpdateProfileAsync()")
	end
	-- self._updates_latest = {}, -- [table] {update_index, {{update_id, version_id, update_locked, update_data}, ...}}
	local updates_latest = self._updates_latest
	local get_global_update = nil
	for _, global_update in ipairs(updates_latest[2]) do
		if update_id == global_update[1] then
			get_global_update = global_update
			break
		end
	end
	if get_global_update ~= nil then
		if get_global_update[3] == true then
			error("[ProfileService]: Can't change locked global update")
		end
		get_global_update[2] = get_global_update[2] + 1 -- Increment version id
		get_global_update[4] = update_data -- Set new global update data
	else
		error("[ProfileService]: Passed non-existant update_id")
	end
end

function GlobalUpdates:ClearActiveUpdate(update_id)
	if type(update_id) ~= "number" then
		error("[ProfileService]: Invalid update_id argument")
	end
	if self._new_active_update_listeners ~= nil then
		error("[ProfileService]: Can't clear active global updates in loaded Profile; Use ProfileStore:GlobalUpdateProfileAsync()")
	elseif self._update_handler_mode ~= true then
		error("[ProfileService]: Can't clear active global updates in view mode; Use ProfileStore:GlobalUpdateProfileAsync()")
	end
	-- self._updates_latest = {}, -- [table] {update_index, {{update_id, version_id, update_locked, update_data}, ...}}
	local updates_latest = self._updates_latest
	local get_global_update_index = nil
	local get_global_update = nil
	for index, global_update in ipairs(updates_latest[2]) do
		if update_id == global_update[1] then
			get_global_update_index = index
			get_global_update = global_update
			break
		end
	end
	if get_global_update ~= nil then
		if get_global_update[3] == true then
			error("[ProfileService]: Can't clear locked global update")
		end
		table.remove(updates_latest[2], get_global_update_index) -- Remove active global update
	else
		error("[ProfileService]: Passed non-existant update_id")
	end
end

-- Profile object:

local Profile = {
	--[[
		Data = {}, -- [table] -- Loaded once after ProfileStore:LoadProfileAsync() finishes
		MetaData = {}, -- [table] -- Updated with every auto-save
		GlobalUpdates = GlobalUpdates, -- [GlobalUpdates]
		
		_profile_store = ProfileStore, -- [ProfileStore]
		_profile_key = "", -- [string]
		
		_release_listeners = [ScriptSignal] / nil, -- [table / nil]
		_hop_ready_listeners = [ScriptSignal] / nil, -- [table / nil]
		_hop_ready = false,
		
		_view_mode = true / nil, -- [bool] or nil
		
		_load_timestamp = os.clock(),
		
		_is_user_mock = false, -- ProfileStore.Mock
		_mock_key_info = {},
	--]]
}
Profile.__index = Profile

function Profile:IsActive() --> [bool]
	local loaded_profiles = self._is_user_mock == true and self._profile_store._mock_loaded_profiles or self._profile_store._loaded_profiles
	return loaded_profiles[self._profile_key] == self
end

function Profile:GetMetaTag(tag_name) --> value
	local meta_data = self.MetaData
	if meta_data == nil then
		return nil
		-- error("[ProfileService]: This Profile hasn't been loaded before - MetaData not available")
	end
	return self.MetaData.MetaTags[tag_name]
end

function Profile:SetMetaTag(tag_name, value)
	if type(tag_name) ~= "string" then
		error("[ProfileService]: tag_name must be a string")
	elseif string.len(tag_name) == 0 then
		error("[ProfileService]: Invalid tag_name")
	end
	self.MetaData.MetaTags[tag_name] = value
end

function Profile:Reconcile()
	ReconcileTable(self.Data, self._profile_store._profile_template)
end

function Profile:ListenToRelease(listener) --> [ScriptConnection] (place_id / nil, game_job_id / nil)
	if type(listener) ~= "function" then
		error("[ProfileService]: Only a function can be set as listener in Profile:ListenToRelease()")
	end
	if self._view_mode == true then
		return {Disconnect = function() end}
	end
	if self:IsActive() == false then
		-- Call release listener immediately if profile is expired
		local place_id
		local game_job_id
		local active_session = self.MetaData.ActiveSession
		if active_session ~= nil then
			place_id = active_session[1]
			game_job_id = active_session[2]
		end
		listener(place_id, game_job_id)
		return {Disconnect = function() end}
	else
		return self._release_listeners:Connect(listener)
	end
end

function Profile:Save()
	if self._view_mode == true then
		error("[ProfileService]: Can't save Profile in view mode - Should you be calling :OverwriteAsync() instead?")
	end
	if self:IsActive() == false then
		warn("[ProfileService]: Attempted saving an inactive profile "
			.. self:Identify() .. "; Traceback:\n" .. debug.traceback())
		return
	end
	-- Reject save request if a save is already pending in the queue - this will prevent the user from
	--	unecessary API request spam which we could not meaningfully execute anyways!
	if IsCustomWriteQueueEmptyFor(self._profile_store._profile_store_lookup, self._profile_key) == true then
		-- We don't want auto save to trigger too soon after manual saving - this will reset the auto save timer:
		RemoveProfileFromAutoSave(self)
		AddProfileToAutoSave(self)
		-- Call save function in a new thread:
		task.spawn(SaveProfileAsync, self)
	end
end

function Profile:Release()
	if self._view_mode == true then
		return
	end
	if self:IsActive() == true then
		task.spawn(SaveProfileAsync, self, true) -- Call save function in a new thread with release_from_session = true
	end
end

function Profile:ListenToHopReady(listener) --> [ScriptConnection] ()
	if type(listener) ~= "function" then
		error("[ProfileService]: Only a function can be set as listener in Profile:ListenToHopReady()")
	end
	if self._view_mode == true then
		return {Disconnect = function() end}
	end
	if self._hop_ready == true then
		task.spawn(listener)
		return {Disconnect = function() end}
	else
		return self._hop_ready_listeners:Connect(listener)
	end
end

function Profile:AddUserId(user_id) -- Associates user_id with profile (GDPR compliance)

	if type(user_id) ~= "number" or user_id % 1 ~= 0 then
		warn("[ProfileService]: Invalid UserId argument for :AddUserId() ("
			.. tostring(user_id) .. "); Traceback:\n" .. debug.traceback())
		return
	end

	if user_id < 0 and self._is_user_mock ~= true and UseMockDataStore ~= true then
		return -- Avoid giving real Roblox APIs negative UserId's
	end

	if table.find(self.UserIds, user_id) == nil then
		table.insert(self.UserIds, user_id)
	end
	
end

function Profile:RemoveUserId(user_id) -- Unassociates user_id with profile (safe function)

	if type(user_id) ~= "number" or user_id % 1 ~= 0 then
		warn("[ProfileService]: Invalid UserId argument for :RemoveUserId() ("
			.. tostring(user_id) .. "); Traceback:\n" .. debug.traceback())
		return
	end
	
	local index = table.find(self.UserIds, user_id)

	if index ~= nil then
		table.remove(self.UserIds, index)
	end

end

function Profile:Identify() --> [string]
	return IdentifyProfile(
		self._profile_store._profile_store_name,
		self._profile_store._profile_store_scope,
		self._profile_key
	)
end

function Profile:ClearGlobalUpdates() -- Clears all global updates data from a profile payload

	if self._view_mode ~= true then
		error("[ProfileService]: :ClearGlobalUpdates() can only be used in view mode")
	end

	local global_updates_object = {
		_updates_latest = {0, {}},
		_profile = self,
	}
	setmetatable(global_updates_object, GlobalUpdates)

	self.GlobalUpdates = global_updates_object

end

function Profile:OverwriteAsync() -- Saves the profile to the DataStore and removes the session lock

	if self._view_mode ~= true then
		error("[ProfileService]: :OverwriteAsync() can only be used in view mode")
	end

	SaveProfileAsync(self, nil, true)

end

-- ProfileVersionQuery object:

local ProfileVersionQuery = {
	--[[
		_profile_store = profile_store,
		_profile_key = profile_key,
		_sort_direction = sort_direction,
		_min_date = min_date,
		_max_date = max_date,

		_query_pages = pages, -- [DataStoreVersionPages]
		_query_index = index, -- [number]
		_query_failure = false,

		_is_query_yielded = false,
		_query_queue = {},
	--]]
}
ProfileVersionQuery.__index = ProfileVersionQuery

function ProfileVersionQuery:_MoveQueue()
	while #self._query_queue > 0 do
		local queue_entry = table.remove(self._query_queue, 1)
		task.spawn(queue_entry)
		if self._is_query_yielded == true then
			break
		end
	end
end

function ProfileVersionQuery:NextAsync(_is_stacking) --> [Profile] or nil

	if self._profile_store == nil then
		return nil
	end

	local profile
	local is_finished = false

	local function query_job()

		if self._query_failure == true then
			is_finished = true
			return
		end

		-- First "next" call loads version pages:

		if self._query_pages == nil then

			self._is_query_yielded = true
			task.spawn(function()
				profile = self:NextAsync(true)
				is_finished = true
			end)
			
			local list_success, error_message = pcall(function()
				self._query_pages = self._profile_store._global_data_store:ListVersionsAsync(
					self._profile_key,
					self._sort_direction,
					self._min_date,
					self._max_date
				)
				self._query_index = 0
			end)

			if list_success == false or self._query_pages == nil then
				warn("[ProfileService]: Version query fail - " .. tostring(error_message))
				self._query_failure = true
			end

			self._is_query_yielded = false
			self:_MoveQueue()

			return

		end

		local current_page = self._query_pages:GetCurrentPage()
		local next_item = current_page[self._query_index + 1]

		-- No more entries:
		
		if self._query_pages.IsFinished == true and next_item == nil then
			is_finished = true
			return
		end

		-- Load next page when this page is over:

		if next_item == nil then

			self._is_query_yielded = true
			task.spawn(function()
				profile = self:NextAsync(true)
				is_finished = true
			end)

			local success = pcall(function()
				self._query_pages:AdvanceToNextPageAsync()
				self._query_index = 0
			end)

			if success == false or #self._query_pages:GetCurrentPage() == 0 then
				self._query_failure = true
			end

			self._is_query_yielded = false
			self:_MoveQueue()

			return

		end

		-- Next page item:

		self._query_index += 1
		profile = self._profile_store:ViewProfileAsync(self._profile_key, next_item.Version)
		is_finished = true

	end

	if self._is_query_yielded == false then
		query_job()
	else
		if _is_stacking == true then
			table.insert(self._query_queue, 1, query_job)
		else
			table.insert(self._query_queue, query_job)
		end
	end

	while is_finished == false do
		task.wait()
	end

	return profile

end

-- ProfileStore object:

local ProfileStore = {
	--[[
		Mock = {},
	
		_profile_store_name = "", -- [string] -- DataStore name
		_profile_store_scope = nil, -- [string] or [nil] -- DataStore scope
		_profile_store_lookup = "", -- [string] -- _profile_store_name .. "\0" .. (_profile_store_scope or "")
		
		_profile_template = {}, -- [table]
		_global_data_store = global_data_store, -- [GlobalDataStore] -- Object returned by DataStoreService:GetDataStore(_profile_store_name)
		
		_loaded_profiles = {[profile_key] = Profile, ...},
		_profile_load_jobs = {[profile_key] = {load_id, loaded_data}, ...},
		
		_mock_loaded_profiles = {[profile_key] = Profile, ...},
		_mock_profile_load_jobs = {[profile_key] = {load_id, loaded_data}, ...},
	--]]
}
ProfileStore.__index = ProfileStore

function ProfileStore:LoadProfileAsync(profile_key, not_released_handler, _use_mock) --> [Profile / nil] not_released_handler(place_id, game_job_id)

	not_released_handler = not_released_handler or "ForceLoad"

	if self._profile_template == nil then
		error("[ProfileService]: Profile template not set - ProfileStore:LoadProfileAsync() locked for this ProfileStore")
	end
	if type(profile_key) ~= "string" then
		error("[ProfileService]: profile_key must be a string")
	elseif string.len(profile_key) == 0 then
		error("[ProfileService]: Invalid profile_key")
	end
	if type(not_released_handler) ~= "function" and not_released_handler ~= "ForceLoad" and not_released_handler ~= "Steal" then
		error("[ProfileService]: Invalid not_released_handler")
	end

	if ProfileService.ServiceLocked == true then
		return nil
	end

	WaitForPendingProfileStore(self)

	local is_user_mock = _use_mock == UseMockTag

	-- Check if profile with profile_key isn't already loaded in this session:
	for _, profile_store in ipairs(ActiveProfileStores) do
		if profile_store._profile_store_lookup == self._profile_store_lookup then
			local loaded_profiles = is_user_mock == true and profile_store._mock_loaded_profiles or profile_store._loaded_profiles
			if loaded_profiles[profile_key] ~= nil then
				error("[ProfileService]: Profile " .. IdentifyProfile(self._profile_store_name, self._profile_store_scope, profile_key) .. " is already loaded in this session")
				-- Are you using Profile:Release() properly?
			end
		end
	end

	ActiveProfileLoadJobs = ActiveProfileLoadJobs + 1
	local force_load = not_released_handler == "ForceLoad"
	local force_load_steps = 0
	local request_force_load = force_load -- First step of ForceLoad
	local steal_session = false -- Second step of ForceLoad
	local aggressive_steal = not_released_handler == "Steal" -- Developer invoked steal
	while ProfileService.ServiceLocked == false do
		-- Load profile:
		-- SPECIAL CASE - If LoadProfileAsync is called for the same key before another LoadProfileAsync finishes,
		-- yoink the DataStore return for the new call. The older call will return nil. This would prevent very rare
		-- game breaking errors where a player rejoins the server super fast.
		local profile_load_jobs = is_user_mock == true and self._mock_profile_load_jobs or self._profile_load_jobs
		local loaded_data, key_info
		local load_id = LoadIndex + 1
		LoadIndex = load_id
		local profile_load_job = profile_load_jobs[profile_key] -- {load_id, {loaded_data, key_info} or nil}
		if profile_load_job ~= nil then
			profile_load_job[1] = load_id -- Yoink load job
			while profile_load_job[2] == nil do -- Wait for job to finish
				task.wait()
			end
			if profile_load_job[1] == load_id then -- Load job hasn't been double-yoinked
				loaded_data, key_info = table.unpack(profile_load_job[2])
				profile_load_jobs[profile_key] = nil
			else
				ActiveProfileLoadJobs = ActiveProfileLoadJobs - 1
				return nil
			end
		else
			profile_load_job = {load_id, nil}
			profile_load_jobs[profile_key] = profile_load_job
			profile_load_job[2] = table.pack(StandardProfileUpdateAsyncDataStore(
				self,
				profile_key,
				{
					ExistingProfileHandle = function(latest_data)
						if ProfileService.ServiceLocked == false then
							local active_session = latest_data.MetaData.ActiveSession
							local force_load_session = latest_data.MetaData.ForceLoadSession
							-- IsThisSession(active_session)
							if active_session == nil then
								latest_data.MetaData.ActiveSession = {PlaceId, JobId}
								latest_data.MetaData.ForceLoadSession = nil
							elseif type(active_session) == "table" then
								if IsThisSession(active_session) == false then
									local last_update = latest_data.MetaData.LastUpdate
									if last_update ~= nil then
										if os.time() - last_update > SETTINGS.AssumeDeadSessionLock then
											latest_data.MetaData.ActiveSession = {PlaceId, JobId}
											latest_data.MetaData.ForceLoadSession = nil
											return
										end
									end
									if steal_session == true or aggressive_steal == true then
										local force_load_uninterrupted = false
										if force_load_session ~= nil then
											force_load_uninterrupted = IsThisSession(force_load_session)
										end
										if force_load_uninterrupted == true or aggressive_steal == true then
											latest_data.MetaData.ActiveSession = {PlaceId, JobId}
											latest_data.MetaData.ForceLoadSession = nil
										end
									elseif request_force_load == true then
										latest_data.MetaData.ForceLoadSession = {PlaceId, JobId}
									end
								else
									latest_data.MetaData.ForceLoadSession = nil
								end
							end
						end
					end,
					MissingProfileHandle = function(latest_data)
						latest_data.Data = DeepCopyTable(self._profile_template)
						latest_data.MetaData = {
							ProfileCreateTime = os.time(),
							SessionLoadCount = 0,
							ActiveSession = {PlaceId, JobId},
							ForceLoadSession = nil,
							MetaTags = {},
						}
					end,
					EditProfile = function(latest_data)
						if ProfileService.ServiceLocked == false then
							local active_session = latest_data.MetaData.ActiveSession
							if active_session ~= nil and IsThisSession(active_session) == true then
								latest_data.MetaData.SessionLoadCount = latest_data.MetaData.SessionLoadCount + 1
								latest_data.MetaData.LastUpdate = os.time()
							end
						end
					end,
				},
				is_user_mock
			))
			if profile_load_job[1] == load_id then -- Load job hasn't been yoinked
				loaded_data, key_info = table.unpack(profile_load_job[2])
				profile_load_jobs[profile_key] = nil
			else
				ActiveProfileLoadJobs = ActiveProfileLoadJobs - 1
				return nil -- Load job yoinked
			end
		end
		-- Handle load_data:
		if loaded_data ~= nil and key_info ~= nil then
			local active_session = loaded_data.MetaData.ActiveSession
			if type(active_session) == "table" then
				if IsThisSession(active_session) == true then
					-- Special component in MetaTags:
					loaded_data.MetaData.MetaTagsLatest = DeepCopyTable(loaded_data.MetaData.MetaTags)
					-- Case #1: Profile is now taken by this session:
					-- Create Profile object:
					local global_updates_object = {
						_updates_latest = loaded_data.GlobalUpdates,
						_pending_update_lock = {},
						_pending_update_clear = {},

						_new_active_update_listeners = Madwork.NewScriptSignal(),
						_new_locked_update_listeners = Madwork.NewScriptSignal(),

						_profile = nil,
					}
					setmetatable(global_updates_object, GlobalUpdates)
					local profile = {
						Data = loaded_data.Data,
						MetaData = loaded_data.MetaData,
						MetaTagsUpdated = Madwork.NewScriptSignal(),

						RobloxMetaData = loaded_data.RobloxMetaData or {},
						UserIds = loaded_data.UserIds or {},
						KeyInfo = key_info,
						KeyInfoUpdated = Madwork.NewScriptSignal(),

						GlobalUpdates = global_updates_object,

						_profile_store = self,
						_profile_key = profile_key,

						_release_listeners = Madwork.NewScriptSignal(),
						_hop_ready_listeners = Madwork.NewScriptSignal(),
						_hop_ready = false,

						_load_timestamp = os.clock(),

						_is_user_mock = is_user_mock,
					}
					setmetatable(profile, Profile)
					global_updates_object._profile = profile
					-- Referencing Profile object in ProfileStore:
					if next(self._loaded_profiles) == nil and next(self._mock_loaded_profiles) == nil then -- ProfileStore object was inactive
						table.insert(ActiveProfileStores, self)
					end
					if is_user_mock == true then
						self._mock_loaded_profiles[profile_key] = profile
					else
						self._loaded_profiles[profile_key] = profile
					end
					-- Adding profile to AutoSaveList;
					AddProfileToAutoSave(profile)
					-- Special case - finished loading profile, but session is shutting down:
					if ProfileService.ServiceLocked == true then
						SaveProfileAsync(profile, true) -- Release profile and yield until the DataStore call is finished
						profile = nil -- nil will be returned by this call
					end
					-- Return Profile object:
					ActiveProfileLoadJobs = ActiveProfileLoadJobs - 1
					return profile
				else
					-- Case #2: Profile is taken by some other session:
					if force_load == true then
						local force_load_session = loaded_data.MetaData.ForceLoadSession
						local force_load_uninterrupted = false
						if force_load_session ~= nil then
							force_load_uninterrupted = IsThisSession(force_load_session)
						end
						if force_load_uninterrupted == true then
							if request_force_load == false then
								force_load_steps = force_load_steps + 1
								if force_load_steps == SETTINGS.ForceLoadMaxSteps then
									steal_session = true
								end
							end
							task.wait() -- Overload prevention
						else
							-- Another session tried to force load this profile:
							ActiveProfileLoadJobs = ActiveProfileLoadJobs - 1
							return nil
						end
						request_force_load = false -- Only request a force load once
					elseif aggressive_steal == true then
						task.wait() -- Overload prevention
					else
						local handler_result = not_released_handler(active_session[1], active_session[2])
						if handler_result == "Repeat" then
							task.wait() -- Overload prevention
						elseif handler_result == "Cancel" then
							ActiveProfileLoadJobs = ActiveProfileLoadJobs - 1
							return nil
						elseif handler_result == "ForceLoad" then
							force_load = true
							request_force_load = true
							task.wait() -- Overload prevention
						elseif handler_result == "Steal" then
							aggressive_steal = true
							task.wait() -- Overload prevention
						else
							error(
								"[ProfileService]: Invalid return from not_released_handler (\"" .. tostring(handler_result) .. "\")(" .. type(handler_result) .. ");" ..
									"\n" .. IdentifyProfile(self._profile_store_name, self._profile_store_scope, profile_key) ..
									" Traceback:\n" .. debug.traceback()
							)
						end
					end
				end
			else
				ActiveProfileLoadJobs = ActiveProfileLoadJobs - 1
				return nil -- In this scenario it is likely the ProfileService.ServiceLocked flag was raised
			end
		else
			task.wait() -- Overload prevention
		end
	end
	ActiveProfileLoadJobs = ActiveProfileLoadJobs - 1
	return nil -- If loop breaks return nothing
end

function ProfileStore:GlobalUpdateProfileAsync(profile_key, update_handler, _use_mock) --> [GlobalUpdates / nil] (update_handler(GlobalUpdates))
	if type(profile_key) ~= "string" or string.len(profile_key) == 0 then
		error("[ProfileService]: Invalid profile_key")
	end
	if type(update_handler) ~= "function" then
		error("[ProfileService]: Invalid update_handler")
	end

	if ProfileService.ServiceLocked == true then
		return nil
	end

	WaitForPendingProfileStore(self)

	while ProfileService.ServiceLocked == false do
		-- Updating profile:
		local loaded_data = StandardProfileUpdateAsyncDataStore(
			self,
			profile_key,
			{
				ExistingProfileHandle = nil,
				MissingProfileHandle = nil,
				EditProfile = function(latest_data)
					-- Running update_handler:
					local global_updates_object = {
						_updates_latest = latest_data.GlobalUpdates,
						_update_handler_mode = true,
					}
					setmetatable(global_updates_object, GlobalUpdates)
					update_handler(global_updates_object)
				end,
			},
			_use_mock == UseMockTag
		)
		CustomWriteQueueMarkForCleanup(self._profile_store_lookup, profile_key)
		-- Handling loaded_data:
		if loaded_data ~= nil then
			-- Return GlobalUpdates object (Update successful):
			local global_updates_object = {
				_updates_latest = loaded_data.GlobalUpdates,
			}
			setmetatable(global_updates_object, GlobalUpdates)
			return global_updates_object
		else
			task.wait() -- Overload prevention
		end
	end
	return nil -- Return nothing (Update unsuccessful)
end

function ProfileStore:ViewProfileAsync(profile_key, version, _use_mock) --> [Profile / nil]
	if type(profile_key) ~= "string" or string.len(profile_key) == 0 then
		error("[ProfileService]: Invalid profile_key")
	end

	if ProfileService.ServiceLocked == true then
		return nil
	end

	WaitForPendingProfileStore(self)

	if version ~= nil and (_use_mock == UseMockTag or UseMockDataStore == true) then
		return nil -- No version support in mock mode
	end

	while ProfileService.ServiceLocked == false do
		-- Load profile:
		local loaded_data, key_info = StandardProfileUpdateAsyncDataStore(
			self,
			profile_key,
			{
				ExistingProfileHandle = nil,
				MissingProfileHandle = function(latest_data)
					latest_data.Data = DeepCopyTable(self._profile_template)
					latest_data.MetaData = {
						ProfileCreateTime = os.time(),
						SessionLoadCount = 0,
						ActiveSession = nil,
						ForceLoadSession = nil,
						MetaTags = {},
					}
				end,
				EditProfile = nil,
			},
			_use_mock == UseMockTag,
			true, -- Use :GetAsync()
			version -- DataStore key version
		)
		CustomWriteQueueMarkForCleanup(self._profile_store_lookup, profile_key)
		-- Handle load_data:
		if loaded_data ~= nil then
			if key_info == nil then
				return nil -- Load was successful, but the key was empty - return no profile object
			end
			-- Create Profile object:
			local global_updates_object = {
				_updates_latest = loaded_data.GlobalUpdates, -- {0, {}}
				_profile = nil,
			}
			setmetatable(global_updates_object, GlobalUpdates)
			local profile = {
				Data = loaded_data.Data,
				MetaData = loaded_data.MetaData,
				MetaTagsUpdated = Madwork.NewScriptSignal(),

				RobloxMetaData = loaded_data.RobloxMetaData or {},
				UserIds = loaded_data.UserIds or {},
				KeyInfo = key_info,
				KeyInfoUpdated = Madwork.NewScriptSignal(),

				GlobalUpdates = global_updates_object,

				_profile_store = self,
				_profile_key = profile_key,

				_view_mode = true,

				_load_timestamp = os.clock(),
			}
			setmetatable(profile, Profile)
			global_updates_object._profile = profile
			-- Returning Profile object:
			return profile
		else
			task.wait() -- Overload prevention
		end
	end
	return nil -- If loop breaks return nothing
end

function ProfileStore:ProfileVersionQuery(profile_key, sort_direction, min_date, max_date, _use_mock) --> [ProfileVersionQuery]
	if type(profile_key) ~= "string" or string.len(profile_key) == 0 then
		error("[ProfileService]: Invalid profile_key")
	end

	if ProfileService.ServiceLocked == true then
		return setmetatable({}, ProfileVersionQuery) -- Silently fail :Next() requests
	end

	WaitForPendingProfileStore(self)

	if _use_mock == UseMockTag or UseMockDataStore == true then
		error("[ProfileService]: :ProfileVersionQuery() is not supported in mock mode")
	end

	-- Type check:
	if sort_direction ~= nil and (typeof(sort_direction) ~= "EnumItem"
		or sort_direction.EnumType ~= Enum.SortDirection) then
		error("[ProfileService]: Invalid sort_direction (" .. tostring(sort_direction) .. ")")
	end

	if min_date ~= nil and typeof(min_date) ~= "DateTime" and typeof(min_date) ~= "number" then
		error("[ProfileService]: Invalid min_date (" .. tostring(min_date) .. ")")
	end

	if max_date ~= nil and typeof(max_date) ~= "DateTime" and typeof(max_date) ~= "number" then
		error("[ProfileService]: Invalid max_date (" .. tostring(max_date) .. ")")
	end

	min_date = typeof(min_date) == "DateTime" and min_date.UnixTimestampMillis or min_date
	max_date = typeof(max_date) == "DateTime" and max_date.UnixTimestampMillis or max_date

	local profile_version_query = {
		_profile_store = self,
		_profile_key = profile_key,
		_sort_direction = sort_direction,
		_min_date = min_date,
		_max_date = max_date,

		_query_pages = nil,
		_query_index = 0,
		_query_failure = false,

		_is_query_yielded = false,
		_query_queue = {},
	}
	setmetatable(profile_version_query, ProfileVersionQuery)

	return profile_version_query

end

function ProfileStore:WipeProfileAsync(profile_key, _use_mock) --> is_wipe_successful [bool]
	if type(profile_key) ~= "string" or string.len(profile_key) == 0 then
		error("[ProfileService]: Invalid profile_key")
	end

	if ProfileService.ServiceLocked == true then
		return false
	end

	WaitForPendingProfileStore(self)

	local wipe_status = false

	if _use_mock == UseMockTag then -- Used when the profile is accessed through ProfileStore.Mock
		local mock_data_store = UserMockDataStore[self._profile_store_lookup]
		if mock_data_store ~= nil then
			mock_data_store[profile_key] = nil
		end
		wipe_status = true
		task.wait() -- Simulate API call yield
	elseif UseMockDataStore == true then -- Used when API access is disabled
		local mock_data_store = MockDataStore[self._profile_store_lookup]
		if mock_data_store ~= nil then
			mock_data_store[profile_key] = nil
		end
		wipe_status = true
		task.wait() -- Simulate API call yield
	else
		wipe_status = pcall(function()
			self._global_data_store:RemoveAsync(profile_key)
		end)
	end

	CustomWriteQueueMarkForCleanup(self._profile_store_lookup, profile_key)

	return wipe_status
end

-- New ProfileStore:

function ProfileService.GetProfileStore(profile_store_index, profile_template) --> [ProfileStore]

	local profile_store_name
	local profile_store_scope = nil

	-- Parsing profile_store_index:
	if type(profile_store_index) == "string" then
		-- profile_store_index as string:
		profile_store_name = profile_store_index
	elseif type(profile_store_index) == "table" then
		-- profile_store_index as table:
		profile_store_name = profile_store_index.Name
		profile_store_scope = profile_store_index.Scope
	else
		error("[ProfileService]: Invalid or missing profile_store_index")
	end

	-- Type checking:
	if profile_store_name == nil or type(profile_store_name) ~= "string" then
		error("[ProfileService]: Missing or invalid \"Name\" parameter")
	elseif string.len(profile_store_name) == 0 then
		error("[ProfileService]: ProfileStore name cannot be an empty string")
	end

	if profile_store_scope ~= nil and (type(profile_store_scope) ~= "string" or string.len(profile_store_scope) == 0) then
		error("[ProfileService]: Invalid \"Scope\" parameter")
	end

	if type(profile_template) ~= "table" then
		error("[ProfileService]: Invalid profile_template")
	end

	local profile_store
	profile_store = {
		Mock = {
			LoadProfileAsync = function(_, profile_key, not_released_handler)
				return profile_store:LoadProfileAsync(profile_key, not_released_handler, UseMockTag)
			end,
			GlobalUpdateProfileAsync = function(_, profile_key, update_handler)
				return profile_store:GlobalUpdateProfileAsync(profile_key, update_handler, UseMockTag)
			end,
			ViewProfileAsync = function(_, profile_key, version)
				return profile_store:ViewProfileAsync(profile_key, version, UseMockTag)
			end,
			FindProfileVersionAsync = function(_, profile_key, sort_direction, min_date, max_date)
				return profile_store:FindProfileVersionAsync(profile_key, sort_direction, min_date, max_date, UseMockTag)
			end,
			WipeProfileAsync = function(_, profile_key)
				return profile_store:WipeProfileAsync(profile_key, UseMockTag)
			end
		},

		_profile_store_name = profile_store_name,
		_profile_store_scope = profile_store_scope,
		_profile_store_lookup = profile_store_name .. "\0" .. (profile_store_scope or ""),

		_profile_template = profile_template,
		_global_data_store = nil,
		_loaded_profiles = {},
		_profile_load_jobs = {},
		_mock_loaded_profiles = {},
		_mock_profile_load_jobs = {},
		_is_pending = false,
	}
	setmetatable(profile_store, ProfileStore)

	if IsLiveCheckActive == true then
		profile_store._is_pending = true
		task.spawn(function()
			WaitForLiveAccessCheck()
			if UseMockDataStore == false then
				profile_store._global_data_store = DataStoreService:GetDataStore(profile_store_name, profile_store_scope)
			end
			profile_store._is_pending = false
		end)
	else
		if UseMockDataStore == false then
			profile_store._global_data_store = DataStoreService:GetDataStore(profile_store_name, profile_store_scope)
		end
	end

	return profile_store
end

function ProfileService.IsLive() --> [bool] -- (CAN YIELD!!!)

	WaitForLiveAccessCheck()

	return UseMockDataStore == false

end

----- Initialize -----

if IsStudio == true then
	IsLiveCheckActive = true
	task.spawn(function()
		local status, message = pcall(function()
			-- This will error if current instance has no Studio API access:
			DataStoreService:GetDataStore("____PS"):SetAsync("____PS", os.time())
		end)
		local no_internet_access = status == false and string.find(message, "ConnectFail", 1, true) ~= nil
		if no_internet_access == true then
			warn("[ProfileService]: No internet access - check your network connection")
		end
		if status == false and
			(string.find(message, "403", 1, true) ~= nil or -- Cannot write to DataStore from studio if API access is not enabled
				string.find(message, "must publish", 1, true) ~= nil or -- Game must be published to access live keys
				no_internet_access == true) then -- No internet access

			UseMockDataStore = true
			ProfileService._use_mock_data_store = true
			print("[ProfileService]: Roblox API services unavailable - data will not be saved")
		else
			print("[ProfileService]: Roblox API services available - data will be saved")
		end
		IsLiveCheckActive = false
	end)
end

----- Connections -----

-- Auto saving and issue queue managing:
RunService.Heartbeat:Connect(function()
	-- 1) Auto saving: --
	local auto_save_list_length = #AutoSaveList
	if auto_save_list_length > 0 then
		local auto_save_index_speed = SETTINGS.AutoSaveProfiles / auto_save_list_length
		local os_clock = os.clock()
		while os_clock - LastAutoSave > auto_save_index_speed do
			LastAutoSave = LastAutoSave + auto_save_index_speed
			local profile = AutoSaveList[AutoSaveIndex]
			if os_clock - profile._load_timestamp < SETTINGS.AutoSaveProfiles then
				-- This profile is freshly loaded - auto-saving immediately after loading will cause a warning in the log:
				profile = nil
				for _ = 1, auto_save_list_length - 1 do
					-- Move auto save index to the right:
					AutoSaveIndex = AutoSaveIndex + 1
					if AutoSaveIndex > auto_save_list_length then
						AutoSaveIndex = 1
					end
					profile = AutoSaveList[AutoSaveIndex]
					if os_clock - profile._load_timestamp >= SETTINGS.AutoSaveProfiles then
						break
					else
						profile = nil
					end
				end
			end
			-- Move auto save index to the right:
			AutoSaveIndex = AutoSaveIndex + 1
			if AutoSaveIndex > auto_save_list_length then
				AutoSaveIndex = 1
			end
			-- Perform save call:
			if profile ~= nil then
				task.spawn(SaveProfileAsync, profile) -- Auto save profile in new thread
			end
		end
	end
	-- 2) Issue queue: --
	-- Critical state handling:
	if ProfileService.CriticalState == false then
		if #IssueQueue >= SETTINGS.IssueCountForCriticalState then
			ProfileService.CriticalState = true
			ProfileService.CriticalStateSignal:Fire(true)
			CriticalStateStart = os.clock()
			warn("[ProfileService]: Entered critical state")
		end
	else
		if #IssueQueue >= SETTINGS.IssueCountForCriticalState then
			CriticalStateStart = os.clock()
		elseif os.clock() - CriticalStateStart > SETTINGS.CriticalStateLast then
			ProfileService.CriticalState = false
			ProfileService.CriticalStateSignal:Fire(false)
			warn("[ProfileService]: Critical state ended")
		end
	end
	-- Issue queue:
	while true do
		local issue_time = IssueQueue[1]
		if issue_time == nil then
			break
		elseif os.clock() - issue_time > SETTINGS.IssueLast then
			table.remove(IssueQueue, 1)
		else
			break
		end
	end
end)

-- Release all loaded profiles when the server is shutting down:
task.spawn(function()
	WaitForLiveAccessCheck()
	Madwork.ConnectToOnClose(
		function()
			ProfileService.ServiceLocked = true
			-- 1) Release all active profiles: --
			-- Clone AutoSaveList to a new table because AutoSaveList changes when profiles are released:
			local on_close_save_job_count = 0
			local active_profiles = {}
			for index, profile in ipairs(AutoSaveList) do
				active_profiles[index] = profile
			end
			-- Release the profiles; Releasing profiles can trigger listeners that release other profiles, so check active state:
			for _, profile in ipairs(active_profiles) do
				if profile:IsActive() == true then
					on_close_save_job_count = on_close_save_job_count + 1
					task.spawn(function() -- Save profile on new thread
						SaveProfileAsync(profile, true)
						on_close_save_job_count = on_close_save_job_count - 1
					end)
				end
			end
			-- 2) Yield until all active profile jobs are finished: --
			while on_close_save_job_count > 0 or ActiveProfileLoadJobs > 0 or ActiveProfileSaveJobs > 0 do
				task.wait()
			end
			return -- We're done!
		end,
		UseMockDataStore == false -- Always run this OnClose task if using Roblox API services
	)
end)

return ProfileService]=])
install(game:GetService("ServerScriptService"), "RebirthManager", "Script", [=[
-- RebirthManager (Script in ServerScriptService)
-- REBIRTH: once you have enough cash you can rebirth. Your cash goes back to the starting
-- amount, but you keep everything else (memes, museum, pickaxes, worlds) and get:
--   * +25% income on all your museum memes, forever (stacks with every rebirth)
--   * gems (10 for the first rebirth, 5 more for each one after)
-- Gems buy the LUCKY CHARM: +10% luck on every dig per level.
-- The numbers are in GameConfig (RebirthBaseCost, RebirthIncomeBonus, GemLuck...).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local function getRemote(name)
	local r = remotes:FindFirstChild(name) or Instance.new("RemoteEvent")
	r.Name = name
	r.Parent = remotes
	return r
end
local rebirthRemote = getRemote("Rebirth")
local gemUpgradeRemote = getRemote("BuyGemUpgrade")
local messageRemote = getRemote("ShopMessage")
local announceRemote = getRemote("Announcement")

local busy = {}

rebirthRemote.OnServerEvent:Connect(function(player)
	if busy[player] then return end
	busy[player] = true
	local data = PlayerData.Get(player)
	if data then
		local cost = GameConfig.RebirthCost(data.Rebirths)
		if data.Money < cost then
			messageRemote:FireClient(player, "You need " .. ArtifactData.FormatMoney(cost) .. " to rebirth!", false)
		else
			local gems = GameConfig.RebirthGemReward(data.Rebirths)
			data.Rebirths += 1
			data.Gems += gems
			data.Money = GameConfig.StartingMoney
			PlayerData.Refresh(player)
			messageRemote:FireClient(player, "{Rebirth} REBIRTH " .. data.Rebirths .. "! +" .. math.floor(GameConfig.RebirthIncomeBonus * 100) .. "% income forever and +" .. gems .. " gems", true)
			announceRemote:FireAllClients(player.DisplayName .. " reached Rebirth " .. data.Rebirths .. "!", Color3.fromRGB(255, 130, 150))
		end
	end
	task.wait(0.5)
	busy[player] = nil
end)

gemUpgradeRemote.OnServerEvent:Connect(function(player)
	local data = PlayerData.Get(player)
	if not data then return end
	if data.GemLuckLevel >= GameConfig.GemLuckMaxLevel then
		messageRemote:FireClient(player, "Your Lucky Charm is maxed out!", false)
		return
	end
	local cost = (data.GemLuckLevel + 1) * GameConfig.GemLuckCost
	if data.Gems < cost then
		messageRemote:FireClient(player, "{Gem} You need " .. cost .. " gems for the next Lucky Charm level.", false)
		return
	end
	data.Gems -= cost
	data.GemLuckLevel += 1
	PlayerData.Refresh(player)
	messageRemote:FireClient(player, "{Luck} Lucky Charm level " .. data.GemLuckLevel .. "! +" .. math.floor(GameConfig.GemLuckPerLevel * 100 * data.GemLuckLevel) .. "% luck", true)
end)

Players.PlayerRemoving:Connect(function(player)
	busy[player] = nil
end)
]=])
install(game:GetService("ServerScriptService"), "SettingsManager", "Script", [=[
-- SettingsManager (Script in ServerScriptService)
-- Keeps each player's audio settings in their saved data (ProfileService / DataStore), so
-- music and sound volumes stick between visits. The settings go to the client as the
-- "AudioSettings" attribute (JSON) and come back through the SaveAudioSettings remote.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerData = require(script.Parent:WaitForChild("PlayerData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local saveRemote = remotes:FindFirstChild("SaveAudioSettings") or Instance.new("RemoteEvent")
saveRemote.Name = "SaveAudioSettings"
saveRemote.Parent = remotes

local function publish(player, settings)
	player:SetAttribute("AudioSettings", HttpService:JSONEncode(settings))
end

local function onPlayer(player)
	local data = PlayerData.WaitForData(player)
	if not data or not player.Parent then return end
	-- settings saved before the audio fix were far too loud: start those players on the new defaults
	-- (the version is only ever written here, never by the data template, so old saves don't get it for free)
	if data.Settings.Version ~= GameConfig.AudioSettingsVersion then
		data.Settings = table.clone(GameConfig.DefaultAudio)
		data.Settings.Version = GameConfig.AudioSettingsVersion
	end
	publish(player, data.Settings)
end
Players.PlayerAdded:Connect(onPlayer)
for _, player in ipairs(Players:GetPlayers()) do task.spawn(onPlayer, player) end

saveRemote.OnServerEvent:Connect(function(player, settings)
	local data = PlayerData.Get(player)
	if not data or typeof(settings) ~= "table" then return end
	local function volume(v, fallback)
		return typeof(v) == "number" and v == v and math.clamp(v, 0, 1) or fallback
	end
	data.Settings = {
		MusicVolume = volume(settings.MusicVolume, data.Settings.MusicVolume),
		SfxVolume = volume(settings.SfxVolume, data.Settings.SfxVolume),
		MusicMuted = settings.MusicMuted == true,
		SfxMuted = settings.SfxMuted == true,
		Version = GameConfig.AudioSettingsVersion,
	}
	publish(player, data.Settings)
end)
]=])
install(game:GetService("ServerScriptService"), "ShopBuilder", "ModuleScript", [=[
-- ShopBuilder (ModuleScript in ServerScriptService)
-- Builds a world's Pickaxe Shop: a cartoony 2050 pavilion on a round tiered platform,
-- with a flying-saucer roof held up by chunky capsule pillars, a curved back wall,
-- glass display capsules on stepped pedestals (one pickaxe per depth zone), a floating
-- robot shopkeeper, a big glowing sign with a giant pickaxe, and a depth meter.
-- DigManager calls this once per world on server start.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local ShovelModels = require(ReplicatedStorage:WaitForChild("PickaxeModels"))
local Architecture = require(script.Parent:WaitForChild("Architecture"))

-- Places a copy of a pickaxe model at `target` (target's axes = the tool's axes), scaled
local function displayShovel(parent, def, target, scale)
	local tool = ShovelModels(def)
	local handle = tool:FindFirstChild("Handle")
	local display = Instance.new("Model")
	display.Name = "Display_" .. def.Id
	for _, piece in ipairs(tool:GetChildren()) do
		if piece:IsA("BasePart") and piece ~= handle then
			local rel = handle.CFrame:ToObjectSpace(piece.CFrame)
			piece.Size = piece.Size * scale
			piece.CFrame = target * CFrame.new(rel.Position * scale) * rel.Rotation
			piece.Anchored = true
			piece.CanCollide = false
			local center = piece:GetAttribute("OrbitCenter")
			if center then
				-- ShovelSpinner (client) spins these around the shaft
				local pivot = target * CFrame.new(center * scale)
				piece:SetAttribute("OrbitPivot", pivot)
				piece:SetAttribute("OrbitOffset", pivot:ToObjectSpace(piece.CFrame))
				CollectionService:AddTag(piece, "ShovelOrbit")
			end
			for _, c in ipairs(piece:GetChildren()) do
				if c:IsA("WeldConstraint") then c:Destroy() end
			end
			piece.Parent = display
		end
	end
	tool:Destroy()
	display.Parent = parent
	return display
end

-- a point on a circle around the shop center (0 degrees = straight back, +X to the right)
local function around(deg, radius, y)
	local a = math.rad(deg)
	return Vector3.new(math.sin(a) * radius, y, math.cos(a) * radius)
end

-- parent: where the shop goes. world: a GameConfig world. base: the shop's CFrame
-- (its front, local -Z, faces the pit).
return function(parent, world, base)
	local shop = Instance.new("Model")
	shop.Name = "ShovelShop"
	local b = Architecture.builder(shop, base)

	-----------------------------------------------------------------
	-- ROUND TIERED PLATFORM with a glowing lip
	-----------------------------------------------------------------
	b:disc("PlatformLip", 30, 0.5, CFrame.new(0, 0.25, 0), "Sky")
	b:disc("PlatformGlow", 29.2, 0.3, CFrame.new(0, 0.62, 0), "GlowCyan")
	b:disc("Platform", 28.4, 0.7, CFrame.new(0, 0.85, 0), "White")
	b:disc("PlatformInner", 22, 0.3, CFrame.new(0, 1.35, 0), "Cloud")
	b:disc("FloorStar", 9, 0.06, CFrame.new(0, 1.52, -2.5), "Lilac")
	b:disc("FloorStarCore", 5, 0.08, CFrame.new(0, 1.54, -2.5), "White")
	-- chunky front steps
	b:roundedBlock("StepLow", Vector3.new(10, 0.5, 3), CFrame.new(0, 0.25, -14.6), 1.4, "Cloud")

	-----------------------------------------------------------------
	-- CURVED BACK WALL: rounded panels with porthole windows
	-----------------------------------------------------------------
	for i, deg in ipairs({-72, -36, 0, 36, 72}) do
		local p = around(deg, 11.2, 7)
		local cf = CFrame.lookAt(p, Vector3.new(0, 7, 0))
		b:roundedBlock("WallPanel", Vector3.new(7.4, 11, 1.4), cf, 0.7, i % 2 == 1 and "White" or "Cloud")
		b:ball("WallTop", 1.6, cf * CFrame.new(0, 5.9, 0), "Lilac")
		-- porthole: glass disc in a lilac frame
		b:rod("PortholeRim", 0.4, 3.6, cf * CFrame.new(0, 1.2, -0.6) * CFrame.Angles(0, math.rad(90), 0), "Lilac")
		b:rod("Porthole", 0.5, 2.8, cf * CFrame.new(0, 1.2, -0.65) * CFrame.Angles(0, math.rad(90), 0), "Glass")
		b:box("WallStripe", Vector3.new(6.6, 0.35, 0.2), cf * CFrame.new(0, -3.5, -0.75), "GlowPink")
	end

	-----------------------------------------------------------------
	-- CAPSULE PILLARS holding up the saucer roof
	-----------------------------------------------------------------
	for _, deg in ipairs({-140, 140}) do
		local p = around(deg, 12.6, 0)
		b:pill("Pillar", p + Vector3.new(0, 2.2, 0), p + Vector3.new(0, 13.2, 0), 1.9, "Lilac")
		b:disc("PillarFoot", 3.4, 0.9, CFrame.new(p + Vector3.new(0, 1.65, 0)), "Violet")
		b:disc("PillarBand", 2.3, 0.35, CFrame.new(p + Vector3.new(0, 9, 0)), "GlowSun")
	end

	-----------------------------------------------------------------
	-- FLYING-SAUCER ROOF: disc rim with bulbs, a glass bubble dome on top
	-----------------------------------------------------------------
	b:ellipsoid("SaucerUnder", Vector3.new(30, 3.2, 30), CFrame.new(0, 13.9, 0), "Sky")
	b:disc("SaucerRim", 31, 1.1, CFrame.new(0, 14.6, 0), "Sky")
	b:disc("SaucerRimGlow", 31.4, 0.3, CFrame.new(0, 14.1, 0), "GlowCyan")
	b:ellipsoid("SaucerTop", Vector3.new(29, 4, 29), CFrame.new(0, 15.1, 0), "White")
	for i = 0, 15 do
		local p = around(i * 22.5, 15.4, 14.6)
		b:bulb("RimBulb", 0.8, CFrame.new(p), i % 2 == 0 and "GlowSun" or "GlowPink", 6)
	end
	b:ellipsoid("Bubble", Vector3.new(13, 9, 13), CFrame.new(0, 17, 1.5), "Glass")
	b:disc("BubbleRing", 13.6, 0.5, CFrame.new(0, 17.1, 1.5), "Lilac")
	b:ball("Beacon", 1.5, CFrame.new(0, 21.6, 1.5), "GlowPink")
	b:rod("BeaconStem", 1.2, 0.3, CFrame.new(0, 21, 1.5) * CFrame.Angles(0, 0, math.rad(90)), "Chrome")
	-- ceiling light under the saucer
	local ceiling = b:disc("CeilingLight", 8, 0.2, CFrame.new(0, 12.25, 0), "GlowCyan")
	local light = Instance.new("PointLight")
	light.Color = Architecture.LightColor
	light.Range = 22
	light.Brightness = 1.2
	light.Parent = ceiling

	-----------------------------------------------------------------
	-- BIG SIGN on top, with a giant shovel leaning on it
	-----------------------------------------------------------------
	b:pill("SignPost", Vector3.new(-5, 16.5, -6), Vector3.new(-5, 19.5, -6), 0.7, "Chrome")
	b:pill("SignPost", Vector3.new(5, 16.5, -6), Vector3.new(5, 19.5, -6), 0.7, "Chrome")
	b:roundedBlock("SignBack", Vector3.new(19, 5.2, 1.2), CFrame.new(0, 21.8, -6), 2.2, "Violet")
	local sign = b:roundedBlock("Sign", Vector3.new(18, 4.4, 1.4), CFrame.new(0, 21.8, -6.1), 1.9, "Navy")
	Architecture.sign(sign, "PICKAXE SHOP", "DIG DEEPER, FIND WEIRDER!")
	b:box("SignGlow", Vector3.new(18.4, 0.3, 1.5), CFrame.new(0, 19.35, -6.1), "GlowSun")
	-- a giant copy of this world's best pickaxe standing beside the sign (head up, arms facing out)
	local HEAD_UP = CFrame.Angles(0, math.rad(90), 0) * CFrame.Angles(math.rad(90), 0, 0)
	local best = world.Shovels[#world.Shovels]
	if best then
		displayShovel(shop, best, base * CFrame.new(12, 22, -5) * CFrame.Angles(0, 0, math.rad(-24)) * HEAD_UP, 2.2)
	end

	-----------------------------------------------------------------
	-- COUNTER (rounded, two-tone) with the shop prompt
	-----------------------------------------------------------------
	local counter = b:roundedBlock("Counter", Vector3.new(10, 3, 2.8), CFrame.new(0, 3, -4.2), 1.3, "Sky")
	b:roundedBlock("CounterTop", Vector3.new(10.8, 0.5, 3.4), CFrame.new(0, 4.7, -4.2), 1.6, "White")
	b:box("CounterStripe", Vector3.new(7.6, 0.4, 0.2), CFrame.new(0, 3.2, -5.62), "GlowSun")
	for _, x in ipairs({-3, 0, 3}) do
		b:ball("CounterDot", 0.7, CFrame.new(x, 2.2, -5.55), "White")
	end

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Browse"
	prompt.ObjectText = "Pickaxes"
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = counter

	-----------------------------------------------------------------
	-- ROBOT SHOPKEEPER floating behind the counter
	-----------------------------------------------------------------
	local bot = Vector3.new(0, 7.4, -1.2)
	b:ball("RobotHead", 3, CFrame.new(bot), "White")
	b:ellipsoid("RobotVisor", Vector3.new(2.4, 1.2, 1), CFrame.new(bot + Vector3.new(0, 0.1, -1.15)), "Ink")
	b:ball("RobotEyeL", 0.45, CFrame.new(bot + Vector3.new(-0.5, 0.15, -1.62)), "GlowCyan")
	b:ball("RobotEyeR", 0.45, CFrame.new(bot + Vector3.new(0.5, 0.15, -1.62)), "GlowCyan")
	b:ellipsoid("RobotBlushL", Vector3.new(0.5, 0.25, 0.1), CFrame.new(bot + Vector3.new(-1, -0.45, -1.3)), "Coral")
	b:ellipsoid("RobotBlushR", Vector3.new(0.5, 0.25, 0.1), CFrame.new(bot + Vector3.new(1, -0.45, -1.3)), "Coral")
	b:rod("RobotAntenna", 1.1, 0.16, CFrame.new(bot + Vector3.new(0, 1.9, 0)) * CFrame.Angles(0, 0, math.rad(90)), "Chrome")
	b:bulb("RobotAntennaTip", 0.55, CFrame.new(bot + Vector3.new(0, 2.5, 0)), "GlowPink", 6)
	b:ellipsoid("RobotBody", Vector3.new(2.2, 2.2, 1.8), CFrame.new(bot + Vector3.new(0, -2.2, 0)), "Lilac")
	b:ring("RobotHoverRing", CFrame.new(bot + Vector3.new(0, -3.5, 0)) * CFrame.Angles(math.rad(90), 0, 0), 1.2, 0.25, "GlowCyan", 14)

	-----------------------------------------------------------------
	-- GLASS DISPLAY CAPSULES on stepped pedestals (one per depth zone)
	-----------------------------------------------------------------
	local spots = {-60, -22, 22, 60}
	for zoneIndex, zone in ipairs(world.Zones) do
		local def = GameConfig.GetFirstShovelForZone(world, zoneIndex)
		local p = around(spots[zoneIndex], 7.6, 1.5)
		local cf = CFrame.new(p)
		local _, h = b:tiers("Pedestal" .. zoneIndex, cf, {
			{3.8, 0.4, "Violet"},
			{3.2, 0.3 + zoneIndex * 0.45, "White"},
			{3.5, 0.3, "Sky"},
		})
		local capsuleH = 6.6
		local mid = cf * CFrame.new(0, h + capsuleH / 2, 0)
		b:disc("CapsuleGlass", 3, capsuleH, mid, "Glass", {Transparency = 0.6})
		b:ellipsoid("CapsuleDome", Vector3.new(3.1, 1.9, 3.1), mid * CFrame.new(0, capsuleH / 2, 0), "Glass", {Transparency = 0.6})
		b:disc("CapsuleCap", 3.2, 0.35, mid * CFrame.new(0, capsuleH / 2, 0), "Lilac")
		b:disc("CapsuleGlow", 3, 0.2, cf * CFrame.new(0, h + 0.1, 0), "GlowMint")
		local tag = b:roundedBlock("ZoneTag", Vector3.new(3.2, 1.1, 0.4), cf * CFrame.new(0, h - 0.9, -1.75), 0.2, "Navy")
		Architecture.sign(tag, string.upper(zone.Name), -zone.Top .. "-" .. -zone.Bottom .. "m")
		if def then
			-- head up, arms facing out of the capsule
			displayShovel(shop, def, base * mid * CFrame.new(0, 0.2, 0) * CFrame.Angles(0, math.rad(90), 0) * CFrame.Angles(math.rad(90), 0, 0), 0.85)
		end
	end

	-----------------------------------------------------------------
	-- DEPTH METER: a tall capsule split into the zone colors, labels on the front
	-----------------------------------------------------------------
	local meter = Vector3.new(-15.5, 0, -8)
	b:disc("MeterBase", 4, 0.8, CFrame.new(meter + Vector3.new(0, 0.4, 0)), "Violet")
	local segment = 2.6
	for i, zone in ipairs(world.Zones) do
		local y = 1 + (#world.Zones - i) * segment + segment / 2
		local seg = b:disc("MeterSegment", 2.6, segment - 0.15, CFrame.new(meter + Vector3.new(0, y, 0)), "White")
		seg.Color = zone.Color
		local tag = b:box("MeterLabel", Vector3.new(3.6, 1.6, 0.2), CFrame.new(meter + Vector3.new(0, y, -1.45)), "Navy")
		Architecture.sign(tag, string.upper(zone.Name), -zone.Top .. "-" .. -zone.Bottom .. "m", nil, Color3.new(1, 1, 1))
	end
	local topY = 1 + #world.Zones * segment
	b:ellipsoid("MeterTop", Vector3.new(2.7, 1.8, 2.7), CFrame.new(meter + Vector3.new(0, topY, 0)), "Lilac")
	b:bulb("MeterBulb", 0.8, CFrame.new(meter + Vector3.new(0, topY + 1.1, 0)), "GlowSun", 8)

	shop.Parent = parent
	return shop, prompt
end
]=])
install(game:GetService("ServerScriptService"), "TutorialManager", "Script", [=[
-- TutorialManager (Script in ServerScriptService)
-- The first-join walkthrough. New players go through four steps, shown by TutorialClient:
--   1. Equip your pickaxe   2. Jump into the pit   3. Dig up a framed artifact (and pull it out)
--   4. Put it on display in your museum
-- The current step lives in the player's "Tutorial" attribute (0 = done / not running).
-- DigManager guarantees a quick first find during step 3 and sets "TutorialFound" when the
-- painting is pulled out. Finishing (or skipping) is saved, so it only ever shows once.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local skipRemote = remotes:FindFirstChild("TutorialSkip") or Instance.new("RemoteEvent")
skipRemote.Name = "TutorialSkip"
skipRemote.Parent = remotes

local STEPS = 4

local function finish(player)
	local data = PlayerData.Get(player)
	if data then data.TutorialDone = true end
	player:SetAttribute("Tutorial", 0)
end

local function hasPlayedBefore(data)
	return data.Stats.TotalDigs > 0 or next(data.Displayed) ~= nil or next(data.Inventory) ~= nil
end

local function holdingPickaxe(character)
	local tool = character and character:FindFirstChildOfClass("Tool")
	return tool ~= nil and tool:GetAttribute("ShovelId") ~= nil
end

local function run(player)
	local data = PlayerData.WaitForData(player)
	if not data or not player.Parent then return end
	if data.TutorialDone then return end
	if hasPlayedBefore(data) then
		data.TutorialDone = true -- players from before the tutorial existed skip it
		return
	end
	player:SetAttribute("TutorialFound", false)
	player:SetAttribute("Tutorial", 1)
	local world = GameConfig.Worlds[1]
	while player.Parent do
		local step = player:GetAttribute("Tutorial")
		if not step or step == 0 or step > STEPS then break end
		local character = player.Character
		if step == 1 and holdingPickaxe(character) then
			player:SetAttribute("Tutorial", 2)
		elseif step == 2 and character and GameConfig.IsInPit(world, character) then
			player:SetAttribute("Tutorial", 3)
		elseif step == 3 and player:GetAttribute("TutorialFound") then
			player:SetAttribute("Tutorial", 4)
		elseif step == 4 and next(data.Displayed) ~= nil then
			finish(player)
			break
		end
		task.wait(0.25)
	end
end

skipRemote.OnServerEvent:Connect(function(player)
	if (player:GetAttribute("Tutorial") or 0) > 0 then
		finish(player)
	end
end)

Players.PlayerAdded:Connect(function(player) task.spawn(run, player) end)
for _, player in ipairs(Players:GetPlayers()) do task.spawn(run, player) end
]=])
install(game:GetService("ServerScriptService"), "VisitorManager", "Script", [=[
-- VisitorManager (Script in ServerScriptService)
-- Autonomous NPC visitors on World 1 (they never give money; they make the island feel alive).
--   * Humans from 2050 appear on a museum's plaza, walk in with PathfindingService, visit a
--     few display slots that have a meme on them (taking the "lift" to the right floor),
--     react to each one with a floating 3D face, then walk back out and fade away.
--   * Aliens come through glowing portals at the far lookouts of the island (AlienPortal):
--     they grow out of the vortex in a burst of sparks, roam the island on its paths
--     (the dig site, the boulevard, other lookouts), wander into a museum to inspect the
--     displays, and finally walk into a portal and vanish.

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local buildVisitor = require(script.Parent:WaitForChild("VisitorModels"))
local AlienPortal = require(script.Parent:WaitForChild("AlienPortal"))
local RunService = game:GetService("RunService")

local MAX_VISITORS = 4           -- per museum at once
local SPAWN_EVERY = {8, 18}      -- seconds between new visitors (random in this range)
local SLOTS_PER_VISIT = {2, 4}   -- how many memes each visitor looks at
local LOOK_TIME = {2.5, 4.5}     -- seconds spent in front of each meme
local ALIEN_CHANCE = 0          -- aliens now arrive through the portals instead of the plazas
-- ALIENS
local MAX_ALIENS = 7             -- roaming the island at once
local ALIEN_EVERY = {8, 16}      -- seconds between portal arrivals
local ALIEN_SIGHTS = {1, 3}      -- places they look at before (maybe) visiting a museum
local ALIEN_MUSEUM_CHANCE = 0.8  -- chance an alien visits a museum (if any has memes on show)
local ALIEN_MAX_LIFETIME = 240   -- seconds; after that they beam away wherever they are
local STEP_TIMEOUT = 4           -- give up on a waypoint after this many seconds (then skip ahead)

-- standard R15 animations (made by Roblox, usable in every game)
local WALK_ANIMATION = "rbxassetid://507777826"
local IDLE_ANIMATION = "rbxassetid://507766388"

-- Reactions by how rare the meme is (3D icons from UIKit, see tools/blender/ui_icons.py)
local REACTIONS = {
	Low = {"FaceMeh", "FaceSick", "FaceMeh", "FaceHappy"},
	Mid = {"FaceHappy", "FaceWow", "FaceLaugh", "FaceCool", "Heart"},
	High = {"FaceLove", "FaceWow", "Fire", "Crown", "Star"},
}

-- Visitors don't bump into players (or each other); they still stand on the floors
for _, group in ipairs({"Visitors", "Players"}) do
	if not PhysicsService:IsCollisionGroupRegistered(group) then
		PhysicsService:RegisterCollisionGroup(group)
	end
end
PhysicsService:CollisionGroupSetCollidable("Visitors", "Visitors", false)
PhysicsService:CollisionGroupSetCollidable("Visitors", "Players", false)
local function groupCharacter(character)
	for _, d in ipairs(character:GetDescendants()) do
		if d:IsA("BasePart") then d.CollisionGroup = "Players" end
	end
	character.DescendantAdded:Connect(function(d)
		if d:IsA("BasePart") then d.CollisionGroup = "Players" end
	end)
end
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(groupCharacter)
end)
for _, player in ipairs(Players:GetPlayers()) do
	player.CharacterAdded:Connect(groupCharacter)
	if player.Character then groupCharacter(player.Character) end
end

local rng = Random.new()
local visitorsFolder = workspace:FindFirstChild("MuseumVisitors") or Instance.new("Folder")
visitorsFolder.Name = "MuseumVisitors"
visitorsFolder.Parent = workspace

---------------------------------------------------------------------
-- MUSEUM GEOMETRY
-- MuseumBuilder leaves invisible marker parts for visitors: Waypoints/Outside, Door and
-- Lobby, a ViewSpot in front of every display slot (plus the slot's Floor attribute), and
-- the lift pads' FloorNArrival spots. They move with the museum, so any plot works.
---------------------------------------------------------------------
-- a random point on a marker part's top (so visitors don't all stand in the same spot)
local function pointOn(part)
	local half = part.Size / 2
	return (part.CFrame * CFrame.new(rng:NextNumber(-half.X, half.X) * 0.8, 0, rng:NextNumber(-half.Z, half.Z) * 0.8)).Position
end

local function waypoint(museum, name)
	local folder = museum:FindFirstChild("Waypoints")
	local part = folder and folder:FindFirstChild(name)
	return part and pointOn(part)
end

local function floorArrival(museum, floor)
	local arrivals = museum:FindFirstChild("Arrivals")
	local part = arrivals and arrivals:FindFirstChild("Floor" .. floor .. "Arrival")
	return part and part.Position
end

-- where a visitor stands to look at a slot, what they look at, and which floor it's on
local function viewingSpot(slot)
	local view, spot = slot:FindFirstChild("ViewSpot"), slot:FindFirstChild("DisplaySpot")
	if not view or not spot then return nil end
	local sideways = view.CFrame.RightVector * rng:NextNumber(-1.5, 1.5)
	return view.Position + sideways, spot.Position, slot:GetAttribute("Floor") or 1
end

local function occupiedSlots(museum)
	local list = {}
	local slots = museum:FindFirstChild("Slots")
	for _, slot in ipairs(slots and slots:GetChildren() or {}) do
		local artifact = ArtifactData.GetArtifact(slot:GetAttribute("ArtifactId") or "")
		if artifact then
			table.insert(list, {Slot = slot, Artifact = artifact})
		end
	end
	return list
end

---------------------------------------------------------------------
-- REACTIONS (a speech bubble with a 3D face over the visitor's head)
---------------------------------------------------------------------
local function react(npc, artifact)
	local head = npc:FindFirstChild("Head")
	if not head then return end
	local rarity = ArtifactData.GetRarityIndex(artifact.Rarity)
	local pool = rarity >= 5 and REACTIONS.High or (rarity >= 3 and REACTIONS.Mid or REACTIONS.Low)
	-- rare memes almost always get a great reaction; common ones sometimes still impress
	if rarity < 5 and rng:NextNumber() < 0.15 then pool = REACTIONS.High end

	local old = head:FindFirstChild("Reaction")
	if old then old:Destroy() end
	local gui = Instance.new("BillboardGui")
	gui.Name = "Reaction"
	gui.Size = UDim2.fromScale(0, 0)
	gui.StudsOffset = Vector3.new(0, 2.6, 0)
	gui.AlwaysOnTop = false
	gui.MaxDistance = 90
	gui.LightInfluence = 0
	gui.Parent = head

	local bubble = Instance.new("Frame")
	bubble.Size = UDim2.fromScale(1, 1)
	bubble.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	bubble.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.5, 0)
	corner.Parent = bubble
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = ArtifactData.GetRarity(artifact.Rarity).Color
	stroke.Parent = bubble
	local face = UIKit.icon(bubble, pool[rng:NextInteger(1, #pool)], {Size = UDim2.fromScale(0.9, 0.9), Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5)})

	-- pop in, hover, fade out
	TweenService:Create(gui, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.fromScale(2.6, 2.6)}):Play()
	TweenService:Create(gui, TweenInfo.new(2.4, Enum.EasingStyle.Sine), {StudsOffset = Vector3.new(0, 3.4, 0)}):Play()
	task.delay(2.2, function()
		if not gui.Parent then return end
		local fade = TweenInfo.new(0.4)
		TweenService:Create(bubble, fade, {BackgroundTransparency = 1}):Play()
		TweenService:Create(stroke, fade, {Transparency = 1}):Play()
		TweenService:Create(face, fade, {ImageTransparency = 1}):Play()
		task.delay(0.45, function() gui:Destroy() end)
	end)
end

---------------------------------------------------------------------
-- MOVEMENT
---------------------------------------------------------------------
local function setupAnimations(humanoid)
	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator")
	animator.Parent = humanoid
	local function load(id)
		local a = Instance.new("Animation")
		a.AnimationId = id
		local ok, track = pcall(function() return animator:LoadAnimation(a) end)
		return ok and track or nil
	end
	local walk, idle = load(WALK_ANIMATION), load(IDLE_ANIMATION)
	if idle then
		idle.Looped = true
		idle:Play()
	end
	if walk then walk.Looped = true end
	humanoid.Running:Connect(function(speed)
		if not walk then return end
		if speed > 0.5 then
			if not walk.IsPlaying then walk:Play(0.15) end
			walk:AdjustSpeed(speed / 12)
		elseif walk.IsPlaying then
			walk:Stop(0.2)
		end
	end)
end

local function stepTo(humanoid, position)
	humanoid:MoveTo(position)
	local done = false
	local conn = humanoid.MoveToFinished:Connect(function() done = true end)
	local start = os.clock()
	while not done and os.clock() - start < STEP_TIMEOUT and humanoid.Parent do
		task.wait(0.1)
	end
	conn:Disconnect()
	return done
end

-- Path costs: visitors prefer the paved paths and roads; they cross grass if they must and
-- stay out of the dig pit's dirt
local PATH_COSTS = {Grass = 4, LeafyGrass = 4, Ground = 40, Sandstone = 40, CrackedLava = 40, Glacier = 40, Slate = 8}

-- walks along a computed path; falls back to walking straight there if no path is found
local function walkTo(npc, goal)
	local humanoid = npc:FindFirstChildOfClass("Humanoid")
	local root = npc:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root or not goal then return false end
	local path = PathfindingService:CreatePath({AgentRadius = 1.6, AgentHeight = 5.5, AgentCanJump = false, WaypointSpacing = 6, Costs = PATH_COSTS})
	local ok = pcall(function() path:ComputeAsync(root.Position, goal) end)
	if ok and path.Status == Enum.PathStatus.Success then
		for i, waypoint in ipairs(path:GetWaypoints()) do
			if i > 1 then
				if not npc.Parent then return false end
				stepTo(humanoid, waypoint.Position)
			end
		end
		return true
	end
	-- no path: walk straight there (re-issuing MoveTo, which gives up after 8 seconds)
	local deadline = os.clock() + (goal - root.Position).Magnitude / math.max(humanoid.WalkSpeed, 1) + 3
	while npc.Parent and os.clock() < deadline and (goal - root.Position).Magnitude > 4 do
		stepTo(humanoid, goal)
	end
	return (goal - root.Position).Magnitude <= 4
end

local function faceTowards(npc, target)
	local root = npc:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local flat = Vector3.new(target.X, root.Position.Y, target.Z)
	if (flat - root.Position).Magnitude > 0.1 then
		TweenService:Create(root, TweenInfo.new(0.3), {CFrame = CFrame.lookAt(root.Position, flat)}):Play()
	end
end

local function teleport(npc, position)
	local root = npc:FindFirstChild("HumanoidRootPart")
	if root then
		npc:PivotTo(CFrame.new(position + Vector3.new(0, 3, 0)) * root.CFrame.Rotation)
	end
end

local function fadeOut(npc)
	for _, d in ipairs(npc:GetDescendants()) do
		if d:IsA("BasePart") and d.Transparency < 1 then
			TweenService:Create(d, TweenInfo.new(0.8), {Transparency = 1}):Play()
		elseif d:IsA("Decal") then
			TweenService:Create(d, TweenInfo.new(0.8), {Transparency = 1}):Play()
		end
	end
	task.delay(0.9, function() npc:Destroy() end)
end

---------------------------------------------------------------------
-- ONE VISIT
---------------------------------------------------------------------
-- walks in from the plaza, looks at a few memes, and walks back out to the plaza
local function tour(museum, npc)
	local outside, doorway, lobby = waypoint(museum, "Outside"), waypoint(museum, "Door"), waypoint(museum, "Lobby")
	if not (outside and doorway and lobby) then return end
	walkTo(npc, outside)
	walkTo(npc, doorway)
	walkTo(npc, lobby)

	-- pick which memes to look at (all on one floor, rarest memes are a bit more popular)
	local choices = occupiedSlots(museum)
	local byFloor = {}
	for _, choice in ipairs(choices) do
		local stand, target, floor = viewingSpot(choice.Slot)
		if stand then
			choice.Stand, choice.Target = stand, target
			byFloor[floor] = byFloor[floor] or {}
			table.insert(byFloor[floor], choice)
		end
	end
	local floors = {}
	for floor in pairs(byFloor) do table.insert(floors, floor) end
	local floor = #floors > 0 and floors[rng:NextInteger(1, #floors)] or 1
	local plan = byFloor[floor] or {}
	for i = #plan, 2, -1 do -- shuffle
		local j = rng:NextInteger(1, i)
		plan[i], plan[j] = plan[j], plan[i]
	end

	-- upper floors: walk to the lift spot and ride up
	if floor > 1 then
		walkTo(npc, floorArrival(museum, 1))
		task.wait(0.4)
		teleport(npc, floorArrival(museum, floor))
	end

	local count = math.min(#plan, rng:NextInteger(SLOTS_PER_VISIT[1], SLOTS_PER_VISIT[2]))
	for i = 1, count do
		if not museum.Parent or not npc.Parent then break end
		local choice = plan[i]
		walkTo(npc, choice.Stand)
		faceTowards(npc, choice.Target)
		task.wait(0.4)
		-- the meme may have been swapped while they walked over: react to what's there now
		local artifact = ArtifactData.GetArtifact(choice.Slot:GetAttribute("ArtifactId") or "")
		if artifact then react(npc, artifact) end
		task.wait(rng:NextNumber(LOOK_TIME[1], LOOK_TIME[2]))
	end

	-- head home
	if floor > 1 and npc.Parent and museum.Parent then
		walkTo(npc, floorArrival(museum, floor))
		task.wait(0.3)
		teleport(npc, floorArrival(museum, 1))
	end
	if npc.Parent and museum.Parent then
		walkTo(npc, lobby)
		walkTo(npc, doorway)
		walkTo(npc, outside)
	end
end

-- a human visitor: appears on the plaza, tours the museum, fades away
local function visit(museum, npc)
	local humanoid = npc:FindFirstChildOfClass("Humanoid")
	local outside, doorway = waypoint(museum, "Outside"), waypoint(museum, "Door")
	if not (outside and doorway) or not humanoid then
		npc:Destroy()
		return
	end
	npc:PivotTo(CFrame.lookAt(outside + Vector3.new(0, 3, 0), doorway + Vector3.new(0, 3, 0)))
	npc.Parent = visitorsFolder
	local root = npc:FindFirstChild("HumanoidRootPart")
	if root then pcall(function() root:SetNetworkOwner(nil) end) end
	setupAnimations(humanoid)
	tour(museum, npc)
	if npc.Parent then fadeOut(npc) end
end

---------------------------------------------------------------------
-- ONE SPAWNER PER MUSEUM
---------------------------------------------------------------------
local function runMuseum(museum)
	local active = 0
	task.wait(rng:NextNumber(3, 8))
	while museum.Parent do
		if active < MAX_VISITORS and #occupiedSlots(museum) > 0 then
			active += 1
			task.spawn(function()
				local ok, npc = pcall(buildVisitor, rng:NextNumber() < ALIEN_CHANCE and "Alien" or "Human", rng)
				if ok and npc then
					local visitOk, err = pcall(visit, museum, npc)
					if not visitOk then
						warn("Visitor error: " .. tostring(err))
						if npc.Parent then npc:Destroy() end
					end
				else
					warn("Couldn't build a visitor: " .. tostring(npc))
				end
				active -= 1
			end)
		end
		task.wait(rng:NextNumber(SPAWN_EVERY[1], SPAWN_EVERY[2]))
	end
end

local museumsFolder = workspace:WaitForChild("Museums")
museumsFolder.ChildAdded:Connect(function(museum)
	task.spawn(runMuseum, museum)
end)
for _, museum in ipairs(museumsFolder:GetChildren()) do
	task.spawn(runMuseum, museum)
end

---------------------------------------------------------------------
-- ALIENS: green portals pop open at random spots, aliens roam, then leave through a new portal
---------------------------------------------------------------------
local portalsFolder = workspace:FindFirstChild("AlienPortals")
if portalsFolder then portalsFolder:Destroy() end
portalsFolder = Instance.new("Folder")
portalsFolder.Name = "AlienPortals"
portalsFolder:SetAttribute("NoCalm", true) -- keep the portals' glow (MapStyle tones down the rest)
portalsFolder.Parent = workspace

local WORLD = GameConfig.Worlds[1]
local ORIGIN = WORLD.Origin
local KEEP_OUT = WORLD.PitRadius + 12 -- aliens never walk inside this ring (the dig site and its rim)
local DETOUR_RADIUS = KEEP_OUT + 20   -- they walk around the dig site on this ring instead

-- pathfinding avoids the dig site too (an invisible no-go zone; it can't be clicked or touched)
do
	local zone = Instance.new("Part")
	zone.Name = "DigSiteNoGo"
	zone.Shape = Enum.PartType.Cylinder
	zone.Anchored = true
	zone.CanCollide = false
	zone.CanQuery = false
	zone.CanTouch = false
	zone.Transparency = 1
	zone.Size = Vector3.new(80, KEEP_OUT * 2, KEEP_OUT * 2)
	zone.CFrame = CFrame.new(ORIGIN) * CFrame.Angles(0, 0, math.rad(90))
	local modifier = Instance.new("PathfindingModifier")
	modifier.Label = "DigSite"
	modifier.Parent = zone
	zone.Parent = portalsFolder
end
PATH_COSTS.DigSite = math.huge

local function flatDistance(position)
	return Vector3.new(position.X - ORIGIN.X, 0, position.Z - ORIGIN.Z).Magnitude
end
local function angleOf(position)
	return math.atan2(position.Z - ORIGIN.Z, position.X - ORIGIN.X)
end
-- does the straight line from a to b cut through the dig site?
local function crossesDigSite(a, b)
	local flatA, flatB = Vector3.new(a.X, 0, a.Z), Vector3.new(b.X, 0, b.Z)
	local center = Vector3.new(ORIGIN.X, 0, ORIGIN.Z)
	local ab = flatB - flatA
	local t = ab.Magnitude > 0 and math.clamp((center - flatA):Dot(ab) / ab:Dot(ab), 0, 1) or 0
	return (flatA + ab * t - center).Magnitude < KEEP_OUT + 4
end

-- walks one leg; a path that dips into the dig site is thrown away (the leg is always
-- outside it, so walking it straight is safe)
local function walkLeg(npc, goal)
	local humanoid = npc:FindFirstChildOfClass("Humanoid")
	local root = npc:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then return end
	local path = PathfindingService:CreatePath({AgentRadius = 1.6, AgentHeight = 5.5, AgentCanJump = false, WaypointSpacing = 6, Costs = PATH_COSTS})
	local ok = pcall(function() path:ComputeAsync(root.Position, goal) end)
	local points = {goal}
	if ok and path.Status == Enum.PathStatus.Success then
		local waypoints = path:GetWaypoints()
		local safe = true
		for _, w in ipairs(waypoints) do
			if flatDistance(w.Position) < KEEP_OUT then
				safe = false
				break
			end
		end
		if safe then
			points = {}
			for i, w in ipairs(waypoints) do
				if i > 1 then table.insert(points, w.Position) end
			end
		end
	end
	for _, point in ipairs(points) do
		if not npc.Parent then return end
		stepTo(humanoid, point)
	end
end

-- walks anywhere on the island, going AROUND the dig site (never into or over it)
local function roamTo(npc, goal)
	local root = npc:FindFirstChild("HumanoidRootPart")
	if not root or not goal then return end
	if crossesDigSite(root.Position, goal) then
		-- hop along a ring around the dig site, 45 degrees at a time, the short way round
		local a0, a1 = angleOf(root.Position), angleOf(goal)
		local diff = (a1 - a0 + math.pi) % (math.pi * 2) - math.pi
		local steps = math.max(1, math.ceil(math.abs(diff) / math.rad(45)))
		for i = 1, steps do
			if not npc.Parent then return end
			local a = a0 + diff * i / steps
			walkLeg(npc, ORIGIN + Vector3.new(math.cos(a) * DETOUR_RADIUS, 3, math.sin(a) * DETOUR_RADIUS))
			if not crossesDigSite(root.Position, goal) then break end
		end
	end
	if npc.Parent then walkLeg(npc, goal) end
end

-- the ground at (x, z): returns the surface point if it's open, flat, ground-level land
local function groundAt(x, z)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local ignore = {visitorsFolder, portalsFolder}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character then table.insert(ignore, plr.Character) end
	end
	params.FilterDescendantsInstances = ignore
	local hit = workspace:Raycast(Vector3.new(x, ORIGIN.Y + 80, z), Vector3.new(0, -120, 0), params)
	if not hit or hit.Normal.Y < 0.9 then return nil end
	if hit.Position.Y < ORIGIN.Y - 1.5 or hit.Position.Y > ORIGIN.Y + 2.5 then return nil end -- roofs, holes, water
	return hit.Position
end

local function insideAMuseum(point)
	for _, museum in ipairs(workspace:WaitForChild("Museums"):GetChildren()) do
		local interior = museum:FindFirstChild("Interior")
		if interior then
			local rel = interior.CFrame:PointToObjectSpace(point)
			local half = interior.Size / 2 + Vector3.new(6, 0, 6)
			if math.abs(rel.X) < half.X and math.abs(rel.Z) < half.Z then return true end
		end
	end
	return false
end

-- a random open spot around the museums and the dig site (outside the dig site itself),
-- optionally near a position; with room = true there must be space for a portal there
local function randomSpot(near, room)
	for _ = 1, 30 do
		local x, z
		if near then
			local a, d = rng:NextNumber(0, math.pi * 2), rng:NextNumber(10, 26)
			x, z = near.X + math.cos(a) * d, near.Z + math.sin(a) * d
		else
			local a, d = rng:NextNumber(0, math.pi * 2), rng:NextNumber(KEEP_OUT + 12, 255)
			x, z = ORIGIN.X + math.cos(a) * d, ORIGIN.Z + math.sin(a) * d
		end
		local ground = groundAt(x, z)
		if ground and flatDistance(ground) > KEEP_OUT + 8 and not insideAMuseum(ground) then
			if not room then return ground end
			local params = OverlapParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			local ignore = {workspace.Terrain, visitorsFolder, portalsFolder}
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr.Character then table.insert(ignore, plr.Character) end
			end
			params.FilterDescendantsInstances = ignore
			local size = AlienPortal.Size
			local boxCF = CFrame.new(ground + Vector3.new(0, 1 + size.Y / 2, 0))
			if #workspace:GetPartBoundsInBox(boxCF, size + Vector3.new(4, 0, 8), params) == 0 then
				return ground
			end
		end
	end
	return nil
end

-- grows (or shrinks) a character and fades it in (or out)
local function scaleAndFade(npc, fromScale, toScale, fromAlpha, toAlpha, duration)
	local looks = {}
	for _, d in ipairs(npc:GetDescendants()) do
		if (d:IsA("BasePart") and d.Name ~= "HumanoidRootPart") or d:IsA("Decal") then
			table.insert(looks, {Thing = d, Base = d.Transparency})
		end
	end
	local start = os.clock()
	while npc.Parent do
		local u = math.clamp((os.clock() - start) / duration, 0, 1)
		local e = u * u * (3 - 2 * u)
		pcall(function() npc:ScaleTo(math.max(fromScale + (toScale - fromScale) * e, 0.05)) end)
		local alpha = fromAlpha + (toAlpha - fromAlpha) * e
		for _, look in ipairs(looks) do
			look.Thing.Transparency = look.Base + (1 - look.Base) * alpha
		end
		if u >= 1 then break end
		RunService.Heartbeat:Wait()
	end
end

local function marker(portal, name)
	local part = portal:FindFirstChild(name)
	return part and part.Position
end

local function museumsWithMemes()
	local list = {}
	for _, museum in ipairs(workspace:WaitForChild("Museums"):GetChildren()) do
		if #occupiedSlots(museum) > 0 then table.insert(list, museum) end
	end
	return list
end

-- somewhere to look at: the dig site from just outside it, a museum's plaza, anywhere around
local function randomSight()
	local roll = rng:NextNumber()
	if roll < 0.35 then
		local a = rng:NextNumber(0, math.pi * 2)
		local r = KEEP_OUT + rng:NextNumber(4, 12)
		local ground = groundAt(ORIGIN.X + math.cos(a) * r, ORIGIN.Z + math.sin(a) * r)
		return ground and ground + Vector3.new(0, 3, 0)
	elseif roll < 0.6 then
		local museums = workspace:WaitForChild("Museums"):GetChildren()
		if #museums > 0 then
			return waypoint(museums[rng:NextInteger(1, #museums)], "Outside")
		end
	end
	local spot = randomSpot(nil, false)
	return spot and spot + Vector3.new(0, 3, 0)
end

-- one alien steps out of an open portal (offset = how far to the side it walks out)
local function stepOut(npc, portal, offset)
	local humanoid = npc:FindFirstChildOfClass("Humanoid")
	local root = npc:FindFirstChild("HumanoidRootPart")
	local core, front = marker(portal, "Core"), marker(portal, "Front")
	if not humanoid or not root or not core or not front then return false end
	humanoid.WalkSpeed = rng:NextNumber(11, 14)
	npc:PivotTo(CFrame.lookAt(core, Vector3.new(front.X, core.Y, front.Z)))
	root.Anchored = true
	pcall(function() npc:ScaleTo(0.05) end)
	npc.Parent = visitorsFolder
	scaleAndFade(npc, 0.05, 1, 1, 0, 0.6)
	if not npc.Parent then return false end
	root.Anchored = false
	pcall(function() root:SetNetworkOwner(nil) end)
	setupAnimations(humanoid)
	local side = portal:FindFirstChild("Core").CFrame.RightVector * offset
	stepTo(humanoid, front + side)
	return true
end

-- an alien leaves: a portal pops open next to it, it walks in and is gone
local function leave(npc)
	local root = npc:FindFirstChild("HumanoidRootPart")
	if not root or not npc.Parent then
		if npc.Parent then npc:Destroy() end
		return
	end
	local spot = randomSpot(root.Position, true) or randomSpot(nil, true)
	if spot then
		local facing = Vector3.new(root.Position.X, spot.Y, root.Position.Z)
		if (facing - spot).Magnitude < 1 then facing = spot + Vector3.zAxis end
		local portal = AlienPortal.open(portalsFolder, CFrame.lookAt(spot, facing))
		roamTo(npc, marker(portal, "Front"))
		local humanoid = npc:FindFirstChildOfClass("Humanoid")
		if humanoid and npc.Parent then stepTo(humanoid, marker(portal, "Core")) end
		if npc.Parent then
			root.Anchored = true
			scaleAndFade(npc, 1, 0.05, 0, 1, 0.45)
		end
		task.delay(0.6, AlienPortal.close, portal)
	elseif npc.Parent then
		scaleAndFade(npc, 1, 0.05, 0, 1, 0.45)
	end
	if npc.Parent then npc:Destroy() end
end

local function roam(npc)
	local born = os.clock()
	local function tooOld() return os.clock() - born > ALIEN_MAX_LIFETIME end
	for _ = 1, rng:NextInteger(ALIEN_SIGHTS[1], ALIEN_SIGHTS[2]) do
		if not npc.Parent or tooOld() then break end
		local sight = randomSight()
		if sight then
			roamTo(npc, sight)
			task.wait(rng:NextNumber(1.5, 3.5)) -- have a look around
		end
	end
	-- inspect the displays in a museum
	local museums = museumsWithMemes()
	if npc.Parent and not tooOld() and #museums > 0 and rng:NextNumber() < ALIEN_MUSEUM_CHANCE then
		local museum = museums[rng:NextInteger(1, #museums)]
		roamTo(npc, waypoint(museum, "Outside"))
		tour(museum, npc)
	end
	leave(npc)
end

-- a portal pops open somewhere, one or two aliens come out, it snaps shut
local function arrival(onDone)
	local spot = randomSpot(nil, true)
	if not spot then
		onDone(2) -- no room anywhere this time: hand back both reserved places
		return
	end
	local facing = Vector3.new(ORIGIN.X, spot.Y, ORIGIN.Z)
	-- mostly face the middle of the island, with a random twist
	local look = CFrame.lookAt(spot, facing) * CFrame.Angles(0, rng:NextNumber(-0.8, 0.8), 0)
	local portal = AlienPortal.open(portalsFolder, look)
	task.wait(0.5)
	local count = rng:NextNumber() < 0.3 and 2 or 1
	local out = 0
	for i = 1, count do
		local ok, npc = pcall(buildVisitor, "Alien", rng)
		if ok and npc then
			local stepped = stepOut(npc, portal, count == 1 and 0 or (i == 1 and -2.5 or 2.5))
			if stepped then
				out += 1
				task.spawn(function()
					local roamOk, err = pcall(roam, npc)
					if not roamOk then
						warn("Alien visitor error: " .. tostring(err))
						if npc.Parent then npc:Destroy() end
					end
					onDone(1)
				end)
			elseif npc.Parent then
				npc:Destroy()
			end
		else
			warn("Couldn't build an alien: " .. tostring(npc))
		end
		task.wait(0.6)
	end
	task.wait(1.2)
	AlienPortal.close(portal)
	onDone(2 - out) -- hand back the reserved places nobody used
end

task.spawn(function()
	local waited = 0
	while not workspace:GetAttribute("MainIslandReady") and waited < 30 do
		waited += task.wait(0.2)
	end
	local roaming = 0
	task.wait(rng:NextNumber(3, 6))
	while true do
		if roaming < MAX_ALIENS then
			roaming += 2 -- reserve room for a pair; unused places are handed back
			task.spawn(arrival, function(n) roaming -= n end)
		end
		task.wait(rng:NextNumber(ALIEN_EVERY[1], ALIEN_EVERY[2]))
	end
end)

print("VisitorManager ready: humans visit every museum, aliens pop in through green portals")
]=])
install(game:GetService("ServerScriptService"), "VisitorModels", "ModuleScript", [=[
-- VisitorModels (ModuleScript in ServerScriptService)
-- Builds the museum's NPC visitors: 2050 humans (bright outfits, glowing visors, hover
-- shoes, shoulder pads) and aliens (colored skin, big heads, huge black eyes, antennae).
-- Each one is a normal R15 character made from a HumanoidDescription, so it can walk with
-- Humanoid:MoveTo and play the standard walk animation. Returns a function(kind, rng) -> model.

local Players = game:GetService("Players")

local rgb = Color3.fromRGB

local HUMAN_SKIN = {rgb(255, 219, 180), rgb(234, 184, 146), rgb(198, 140, 104), rgb(141, 94, 66), rgb(94, 62, 44), rgb(255, 204, 170)}
local OUTFITS = { -- {top, bottom, accent glow}
	{rgb(92, 186, 255), rgb(40, 44, 90), rgb(120, 240, 255)},
	{rgb(255, 122, 190), rgb(60, 40, 96), rgb(255, 170, 230)},
	{rgb(255, 206, 84), rgb(56, 58, 76), rgb(255, 230, 140)},
	{rgb(96, 226, 190), rgb(34, 70, 80), rgb(150, 255, 220)},
	{rgb(178, 158, 255), rgb(46, 40, 90), rgb(210, 190, 255)},
	{rgb(246, 247, 252), rgb(90, 96, 140), rgb(120, 240, 255)},
}
local ALIEN_SKIN = {rgb(120, 220, 120), rgb(150, 120, 255), rgb(90, 200, 230), rgb(255, 150, 200), rgb(200, 230, 90)}

local function weldTo(part, anchorPart, offset)
	part.CFrame = anchorPart.CFrame * offset
	part.Anchored = false
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Massless = true
	local w = Instance.new("WeldConstraint")
	w.Part0 = anchorPart
	w.Part1 = part
	w.Parent = part
	part.Parent = anchorPart.Parent
	return part
end

local function piece(name, size, color, material, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if shape then p.Shape = shape end
	return p
end

local function ellipsoid(name, size, color, material)
	local p = piece(name, size, color, material)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = p
	return p
end

local function describe(skin, top, bottom, scale)
	local d = Instance.new("HumanoidDescription")
	d.HeadColor = skin
	d.LeftArmColor = top
	d.RightArmColor = top
	d.TorsoColor = top
	d.LeftLegColor = bottom
	d.RightLegColor = bottom
	d.HeightScale = scale.Height
	d.WidthScale = scale.Width
	d.HeadScale = scale.Head
	d.BodyTypeScale = 0
	d.ProportionScale = 0
	return d
end

local function hands(model, color)
	for _, name in ipairs({"LeftHand", "RightHand"}) do
		local hand = model:FindFirstChild(name)
		if hand then hand.Color = color end
	end
end

local function finish(model, name)
	model.Name = name
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.WalkSpeed = 10
	humanoid.BreakJointsOnDeath = false
	humanoid.RequiresNeck = false
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("BasePart") then
			d.CollisionGroup = "Visitors"
		end
	end
	return model
end

-- a 2050 human: outfit colors, a glowing visor, shoulder pads and hover-shoe glow
local function human(rng)
	local skin = HUMAN_SKIN[rng:NextInteger(1, #HUMAN_SKIN)]
	local outfit = OUTFITS[rng:NextInteger(1, #OUTFITS)]
	local model = Players:CreateHumanoidModelFromDescription(describe(skin, outfit[1], outfit[2],
		{Height = rng:NextNumber(0.9, 1.08), Width = rng:NextNumber(0.9, 1.05), Head = 1}), Enum.HumanoidRigType.R15)
	hands(model, skin)
	local head = model:FindFirstChild("Head")
	local upperTorso = model:FindFirstChild("UpperTorso")
	if head then
		weldTo(piece("Visor", Vector3.new(1.25, 0.28, 0.35), outfit[3], Enum.Material.Neon), head, CFrame.new(0, 0.12, -0.5))
		if rng:NextNumber() < 0.5 then -- futuristic hair dome
			weldTo(ellipsoid("Hair", Vector3.new(1.35, 0.7, 1.35), outfit[2]), head, CFrame.new(0, 0.5, 0.05))
		end
	end
	if upperTorso then
		for _, side in ipairs({-1, 1}) do
			weldTo(ellipsoid("ShoulderPad", Vector3.new(0.8, 0.45, 0.9), outfit[2]), upperTorso, CFrame.new(side * 1.05, 0.7, 0))
		end
		weldTo(piece("ChestStripe", Vector3.new(0.18, 1.2, 0.1), outfit[3], Enum.Material.Neon), upperTorso, CFrame.new(0.3, 0.1, -0.52))
	end
	for _, name in ipairs({"LeftFoot", "RightFoot"}) do
		local foot = model:FindFirstChild(name)
		if foot then
			foot.Color = outfit[2]
			weldTo(piece("HoverGlow", Vector3.new(0.8, 0.08, 0.9), outfit[3], Enum.Material.Neon), foot, CFrame.new(0, -0.2, 0))
		end
	end
	return finish(model, "Visitor2050")
end

-- an alien: colored skin, big head, big glossy eyes, antennae with glowing tips
local function alien(rng)
	local skin = ALIEN_SKIN[rng:NextInteger(1, #ALIEN_SKIN)]
	local suit = OUTFITS[rng:NextInteger(1, #OUTFITS)]
	local model = Players:CreateHumanoidModelFromDescription(describe(skin, suit[2], suit[2],
		{Height = rng:NextNumber(0.8, 1), Width = 0.85, Head = rng:NextNumber(1.35, 1.6)}), Enum.HumanoidRigType.R15)
	hands(model, skin)
	local head = model:FindFirstChild("Head")
	if head then
		local face = head:FindFirstChildOfClass("Decal")
		if face then face:Destroy() end -- aliens get their own eyes
		local s = head.Size.Y / 1.2
		for _, side in ipairs({-1, 1}) do
			weldTo(ellipsoid("AlienEye", Vector3.new(0.42, 0.62, 0.2) * s, rgb(20, 18, 30), Enum.Material.Glass), head,
				CFrame.new(side * 0.28 * s, 0.1 * s, -0.55 * s) * CFrame.Angles(0, 0, side * 0.35))
			weldTo(piece("EyeShine", Vector3.new(0.1, 0.1, 0.06) * s, rgb(255, 255, 255), Enum.Material.Neon, Enum.PartType.Ball), head,
				CFrame.new(side * 0.22 * s, 0.25 * s, -0.63 * s))
			local stalk = weldTo(piece("Antenna", Vector3.new(0.08, 0.9, 0.08) * s, skin), head,
				CFrame.new(side * 0.3 * s, 0.9 * s, 0) * CFrame.Angles(0, 0, -side * 0.35))
			weldTo(piece("AntennaTip", Vector3.new(0.26, 0.26, 0.26) * s, suit[3], Enum.Material.Neon, Enum.PartType.Ball), stalk,
				CFrame.new(0, 0.5 * s, 0))
		end
	end
	local upperTorso = model:FindFirstChild("UpperTorso")
	if upperTorso then
		weldTo(ellipsoid("SuitBadge", Vector3.new(0.45, 0.45, 0.12), suit[3], Enum.Material.Neon), upperTorso, CFrame.new(0, 0.2, -0.5))
	end
	return finish(model, "AlienVisitor")
end

return function(kind, rng)
	if kind == "Alien" then
		return alien(rng)
	end
	return human(rng)
end
]=])
install(game:GetService("ServerScriptService"), "WorldBuilder", "ModuleScript", [=[
-- WorldBuilder (ModuleScript in ServerScriptService)
-- Builds worlds 2-9: a floating terrain island around the pit (in the world's own ground
-- material), an invisible safety wall at the edge, the candy rim ring and zone rings, and a
-- themed set of decorations: a big landmark behind the pit, props around the island and
-- lamps near the rim. Everything stays clear of the Shovel Shop (30°) and World Gate (-30°).
-- DigManager calls it once per world when the server starts, after building the shop and gate.

local Architecture = require(script.Parent:WaitForChild("Architecture"))
local DigSiteStyle = require(script.Parent:WaitForChild("DigSiteStyle"))
local GameConfig = require(game:GetService("ReplicatedStorage"):WaitForChild("GameConfig"))

local terrain = workspace.Terrain
local rgb = Color3.fromRGB
local PLASTIC = Enum.Material.SmoothPlastic

-- Angles (degrees, around the pit) where the island props stand. 30 and -30 (330) are
-- the shop and the gate, so they're left out; 180 is the landmark behind the pit.
local PROP_ANGLES = {75, 110, 145, 215, 250, 285}
local LAMP_ANGLES = {90, 135, 180, 225, 270}
local PROP_DISTANCE = 104
local LAMP_DISTANCE = 58
local LANDMARK_DISTANCE = 96

-- Registers the world's colors as palette finishes ("W2Main", "W2Glow", ...)
local function finishes(world)
	local look = world.Look
	local key = "W" .. world.Id
	local P = Architecture.Palette
	P[key .. "Main"] = {Color = look.Main, Material = PLASTIC}
	P[key .. "Second"] = {Color = look.Second, Material = PLASTIC}
	P[key .. "Dark"] = {Color = look.Dark, Material = PLASTIC}
	P[key .. "Accent"] = {Color = look.Accent, Material = PLASTIC}
	P[key .. "Glow"] = {Color = look.Glow, Material = Enum.Material.Neon}
	P[key .. "Crystal"] = {Color = look.Main, Material = Enum.Material.Glass, Transparency = 0.25, Reflectance = 0.1}
	P[key .. "Metal"] = {Color = look.Second, Material = Enum.Material.Metal, Reflectance = 0.2}
	return {
		Main = key .. "Main", Second = key .. "Second", Dark = key .. "Dark", Accent = key .. "Accent",
		Glow = key .. "Glow", Crystal = key .. "Crystal", Metal = key .. "Metal",
	}
end

local function custom(name, color, material, extra)
	local finish = {Color = color, Material = material or PLASTIC}
	if extra then
		for k, v in pairs(extra) do finish[k] = v end
	end
	Architecture.Palette[name] = finish
	return name
end

-- CFrame on the ground at an angle/distance around the pit, facing the pit
local function spot(angle, distance, height)
	local a = math.rad(angle)
	local pos = Vector3.new(math.cos(a) * distance, height or 0, math.sin(a) * distance)
	return CFrame.lookAt(pos, Vector3.new(0, pos.Y, 0))
end

local function particles(part, color, props)
	local e = Instance.new("ParticleEmitter")
	e.Color = ColorSequence.new(color)
	e.LightEmission = 0.3
	for k, v in pairs(props) do e[k] = v end
	e.Parent = part
	return e
end

---------------------------------------------------------------------
-- THE ISLAND (terrain)
---------------------------------------------------------------------
local function buildIsland(world, rng)
	local origin = world.Origin
	local R = world.IslandRadius
	local wall = Enum.Material[world.WallMaterial]
	local top = Enum.Material[world.TopMaterial]
	-- thick top slab, then an underside that narrows into the pit column (a floating island)
	terrain:FillCylinder(CFrame.new(origin + Vector3.new(0, -14, 0)), 28, R, wall)
	local layers = {{0.82, -34, 14}, {0.64, -52, 22}, {0.48, -76, 28}}
	for _, layer in ipairs(layers) do
		terrain:FillCylinder(CFrame.new(origin + Vector3.new(0, layer[2], 0)), layer[3], R * layer[1], wall)
	end
	-- lumpy rocks hanging under the edge
	for i = 1, 14 do
		local a = rng:NextNumber(0, math.pi * 2)
		local d = rng:NextNumber(R * 0.45, R * 0.85)
		terrain:FillBall(origin + Vector3.new(math.cos(a) * d, rng:NextNumber(-60, -30), math.sin(a) * d), rng:NextNumber(10, 18), wall)
	end
	-- rounded tip under the pit column
	terrain:FillBall(origin + Vector3.new(0, world.Zones[#world.Zones].Bottom - 20, 0), 40, wall)
	-- the surface
	terrain:FillCylinder(CFrame.new(origin + Vector3.new(0, -2, 0)), 4, R, top)
	-- bring the surface down to y = 0, where the gate, shop and decorations stand
	GameConfig.FlattenGround(terrain, origin, R * 2 + 8)
	-- a few soft hills near the edge (away from the shop and gate)
	for _, angle in ipairs({95, 160, 200, 265}) do
		local a = math.rad(angle + rng:NextNumber(-8, 8))
		local d = R - 12
		terrain:FillBall(origin + Vector3.new(math.cos(a) * d, -4, math.sin(a) * d), rng:NextNumber(9, 13), top)
	end
end

-- invisible wall around the edge so nobody walks off the island
local function buildEdgeWall(parent, world)
	local R = world.IslandRadius - 3
	local segments = 48
	local folder = Instance.new("Folder")
	folder.Name = "EdgeWall"
	for i = 0, segments - 1 do
		local a = (i + 0.5) / segments * math.pi * 2
		local pos = world.Origin + Vector3.new(math.cos(a) * R, 20, math.sin(a) * R)
		local p = Instance.new("Part")
		p.Name = "EdgeWall"
		p.Anchored = true
		p.Transparency = 1
		p.CanQuery = false
		p.Size = Vector3.new(2 * math.pi * R / segments + 1, 44, 2)
		p.CFrame = CFrame.lookAt(pos, Vector3.new(world.Origin.X, pos.Y, world.Origin.Z))
		p.Parent = folder
	end
	folder.Parent = parent
end

---------------------------------------------------------------------
-- THEMES: each has Landmark (behind the pit), Props (around the island), Lamp (near the rim)
-- and optional Sky (things floating overhead). b builds relative to the world origin.
---------------------------------------------------------------------
local THEMES = {}

-- NEON SAKURA GROVE --------------------------------------------------
THEMES.Sakura = {
	Landmark = function(b, F, cf)
		local red = custom("SakuraTorii", rgb(236, 84, 96))
		for _, side in ipairs({-1, 1}) do
			b:disc("ToriiFoot", 4.4, 1.2, cf * CFrame.new(side * 11, 0.6, 0), F.Dark)
			b:disc("ToriiPillar", 3, 24, cf * CFrame.new(side * 11, 12.6, 0), red)
		end
		b:roundedBlock("ToriiBeam", Vector3.new(32, 2.2, 3), cf * CFrame.new(0, 25.5, 0), 1, F.Dark)
		b:roundedBlock("ToriiBeamTop", Vector3.new(36, 1.6, 4), cf * CFrame.new(0, 27.4, 0), 1.2, red)
		b:box("ToriiTie", Vector3.new(26, 1.4, 2), cf * CFrame.new(0, 20, 0), red)
		local plaque = b:roundedBlock("ToriiPlaque", Vector3.new(6, 4, 1), cf * CFrame.new(0, 22.8, -0.8), 0.5, F.Dark)
		Architecture.sign(plaque, "SAKURA", nil, Enum.NormalId.Front, rgb(255, 214, 120))
		for i = 0, 5 do
			b:bulb("ToriiLantern", 1.2, cf * CFrame.new(-12.5 + i * 5, 18, -1.2), F.Glow, 8)
		end
	end,
	Props = function(b, F, cf, i, rng)
		-- a round blossom tree; every third spot gets a stone lantern pair instead
		if i % 3 == 0 then
			for _, side in ipairs({-1, 1}) do
				local p = cf * CFrame.new(side * 5, 0, 0)
				b:disc("StoneBase", 3.4, 1, p * CFrame.new(0, 0.5, 0), F.Second)
				b:disc("StonePost", 1.4, 4, p * CFrame.new(0, 3, 0), F.Second)
				b:roundedBlock("LanternBox", Vector3.new(2.6, 2.2, 2.6), p * CFrame.new(0, 6.1, 0), 0.6, F.Accent)
				b:bulb("LanternLight", 1.4, p * CFrame.new(0, 6.1, 0), F.Glow, 12)
				b:disc("LanternRoof", 4, 0.8, p * CFrame.new(0, 7.6, 0), F.Dark)
			end
			return
		end
		local s = rng:NextNumber(1.4, 1.8)
		b:pill("Trunk", (cf * CFrame.new(0, 0, 0)).Position, (cf * CFrame.new(0.8, 10 * s, 0)).Position, 2.2 * s, F.Dark)
		b:pill("Branch", (cf * CFrame.new(0.6, 7 * s, 0)).Position, (cf * CFrame.new(-4 * s, 11 * s, 1)).Position, 1.1 * s, F.Dark)
		b:pill("Branch", (cf * CFrame.new(0.6, 8 * s, 0)).Position, (cf * CFrame.new(4.5 * s, 12 * s, -1)).Position, 1.1 * s, F.Dark)
		local crowns = {Vector3.new(0, 14, 0), Vector3.new(-4.5, 12.5, 1), Vector3.new(4.8, 13, -1), Vector3.new(0.5, 12, 4), Vector3.new(0, 12.5, -4)}
		for c, offset in ipairs(crowns) do
			local crown = b:ball("Blossom", (c == 1 and 9 or 7) * s, cf * CFrame.new(offset * s), c % 2 == 0 and F.Second or F.Main)
			if c == 1 then
				particles(crown, rgb(255, 190, 215), {
					Rate = 3, Lifetime = NumberRange.new(4, 6), Speed = NumberRange.new(1, 2),
					Acceleration = Vector3.new(0.5, -1.2, 0), SpreadAngle = Vector2.new(180, 180),
					Size = NumberSequence.new(0.35), Rotation = NumberRange.new(0, 360), RotSpeed = NumberRange.new(-90, 90),
				})
			end
		end
	end,
	Lamp = function(b, F, cf)
		b:disc("LampBase", 2.2, 0.6, cf * CFrame.new(0, 0.3, 0), F.Dark)
		b:disc("LampPole", 0.6, 6, cf * CFrame.new(0, 3.6, 0), F.Dark)
		b:ellipsoid("PaperLantern", Vector3.new(2, 2.6, 2), cf * CFrame.new(0, 7.6, 0), custom("SakuraPaper", rgb(255, 120, 130)))
		b:bulb("LanternGlow", 0.9, cf * CFrame.new(0, 7.6, 0), F.Glow, 10)
	end,
}

-- GALAXY DRIFT ------------------------------------------------------
THEMES.Galaxy = {
	Landmark = function(b, F, cf)
		-- a giant ringed planet floating over the island, on a beam of light
		local planet = cf * CFrame.new(0, 48, 0)
		b:ball("GiantPlanet", 30, planet, F.Main)
		b:ellipsoid("PlanetBand", Vector3.new(30.4, 6, 30.4), planet * CFrame.new(0, 4, 0), F.Accent)
		b:ring("PlanetRing", planet * CFrame.Angles(math.rad(75), 0, math.rad(15)), 24, 2.4, F.Second, 40)
		b:ring("PlanetRingGlow", planet * CFrame.Angles(math.rad(75), 0, math.rad(15)), 27, 0.8, F.Glow, 40)
		b:tiers("Observatory", cf, {{18, 1, F.Dark}, {15, 1.2, F.Second}, {10, 0.6, F.Glow}})
		local beam = b:disc("TractorBeam", 6, 30, cf * CFrame.new(0, 18, 0), F.Crystal, {CanCollide = false})
		beam.Transparency = 0.75
		for i = 1, 3 do
			local a = math.rad(i * 120)
			b:ball("Moon", 4, planet * CFrame.new(math.cos(a) * 22, math.sin(a) * 6, math.sin(a) * 22), "Cloud")
		end
	end,
	Props = function(b, F, cf, i, rng)
		if i % 2 == 0 then
			-- crystal cluster
			for c = 1, 6 do
				local h = rng:NextNumber(5, 12)
				local tilt = CFrame.Angles(rng:NextNumber(-0.4, 0.4), rng:NextNumber(0, 6), rng:NextNumber(-0.4, 0.4))
				b:box("SpaceCrystal", Vector3.new(1.8, h, 1.8), cf * CFrame.new(rng:NextNumber(-3, 3), h / 2 - 1, rng:NextNumber(-3, 3)) * tilt, c % 3 == 0 and F.Crystal or F.Main)
			end
			b:bulb("CrystalGlow", 1.2, cf * CFrame.new(0, 2, 0), F.Glow, 14)
		else
			-- little planet on a pedestal
			b:tiers("Pedestal", cf, {{6, 1, F.Dark}, {3, 5, F.Second}, {4.4, 0.6, F.Glow}})
			local p = cf * CFrame.new(0, 11, 0)
			b:ball("MiniPlanet", 6, p, i % 3 == 0 and F.Accent or "Coral")
			b:ring("MiniRing", p * CFrame.Angles(math.rad(70), 0, 0), 4.6, 0.5, F.Second, 20)
		end
	end,
	Lamp = function(b, F, cf)
		b:disc("LampBase", 2.2, 0.6, cf * CFrame.new(0, 0.3, 0), F.Dark)
		b:disc("LampPole", 0.5, 7, cf * CFrame.new(0, 4, 0), F.Second)
		b:bulb("StarLamp", 1.6, cf * CFrame.new(0, 8.2, 0), F.Glow, 14)
		b:ring("StarLampRing", cf * CFrame.new(0, 8.2, 0), 1.6, 0.25, F.Accent, 12)
	end,
	Sky = function(b, F, rng)
		for i = 1, 10 do
			local a = rng:NextNumber(0, math.pi * 2)
			local d = rng:NextNumber(150, 260)
			local rock = b:ellipsoid("Asteroid", Vector3.new(rng:NextNumber(8, 16), rng:NextNumber(5, 9), rng:NextNumber(8, 14)),
				CFrame.new(math.cos(a) * d, rng:NextNumber(30, 110), math.sin(a) * d) * CFrame.Angles(rng:NextNumber(0, 3), rng:NextNumber(0, 3), 0), F.Dark)
			rock.CanCollide = false
		end
	end,
}

-- FROSTBYTE TUNDRA --------------------------------------------------
THEMES.Frost = {
	Landmark = function(b, F, cf)
		-- a cluster of huge ice spires with a glowing core
		local spires = {{0, 44, 7}, {-8, 30, 5}, {8, 34, 5.5}, {-4, 22, 4}, {5, 20, 4}, {-12, 16, 3.5}, {12, 18, 3.5}}
		for i, s in ipairs(spires) do
			local lean = CFrame.Angles(0, math.rad(i * 40), math.rad(s[1] * 0.8))
			b:box("IceSpire", Vector3.new(s[3], s[2], s[3]), cf * CFrame.new(s[1], s[2] / 2 - 2, (i % 2) * 3) * lean * CFrame.Angles(0, math.rad(45), 0), i % 2 == 0 and F.Crystal or F.Main)
		end
		b:bulb("SpireCore", 4, cf * CFrame.new(0, 10, -2), F.Glow, 24)
		b:tiers("SnowMound", cf, {{30, 2, "White"}, {22, 1.5, "White"}})
	end,
	Props = function(b, F, cf, i, rng)
		if i % 3 == 0 then
			-- a friendly snowman
			b:ball("SnowBottom", 6, cf * CFrame.new(0, 2.6, 0), "White")
			b:ball("SnowMiddle", 4.4, cf * CFrame.new(0, 6.8, 0), "White")
			b:ball("SnowHead", 3.2, cf * CFrame.new(0, 9.9, 0), "White")
			b:disc("HatBrim", 3.4, 0.3, cf * CFrame.new(0, 11.4, 0), F.Dark)
			b:disc("Hat", 2.2, 2, cf * CFrame.new(0, 12.5, 0), F.Dark)
			b:rod("Nose", 1.4, 0.4, cf * CFrame.new(0, 9.9, -1.9) * CFrame.Angles(0, math.rad(90), 0), custom("Carrot", rgb(255, 150, 60)))
			for _, side in ipairs({-1, 1}) do
				b:ball("Eye", 0.4, cf * CFrame.new(side * 0.6, 10.4, -1.45), "Ink")
			end
			b:disc("Scarf", 3.8, 0.8, cf * CFrame.new(0, 8.5, 0), F.Accent)
			return
		end
		-- a round snowy pine
		local s = rng:NextNumber(1.3, 1.7)
		b:disc("PineTrunk", 1.6 * s, 4 * s, cf * CFrame.new(0, 2 * s, 0), custom("PineWood", rgb(120, 86, 80)))
		for t = 0, 3 do
			local y = (4 + t * 3.2) * s
			local d = (9 - t * 2) * s
			b:ellipsoid("PineLayer", Vector3.new(d, 3.4 * s, d), cf * CFrame.new(0, y, 0), custom("PineGreen", rgb(70, 150, 130)))
			b:ellipsoid("PineSnow", Vector3.new(d * 0.8, 1.6 * s, d * 0.8), cf * CFrame.new(0, y + 1.2 * s, 0), "White")
		end
	end,
	Lamp = function(b, F, cf)
		b:disc("LampBase", 2.2, 0.6, cf * CFrame.new(0, 0.3, 0), F.Dark)
		b:disc("LampPole", 0.6, 6, cf * CFrame.new(0, 3.6, 0), F.Second)
		b:box("IceLamp", Vector3.new(1.6, 2.6, 1.6), cf * CFrame.new(0, 7.8, 0) * CFrame.Angles(0, math.rad(45), 0), F.Crystal)
		b:bulb("IceGlow", 0.8, cf * CFrame.new(0, 7.8, 0), F.Glow, 10)
	end,
	Sky = function(b, F)
		-- aurora: thin glowing ribbons high above the far side of the island
		local colors = {F.Glow, custom("AuroraViolet", rgb(170, 130, 255), Enum.Material.Neon)}
		for i = 0, 11 do
			local ribbon = b:box("Aurora", Vector3.new(34, 2, 0.4),
				CFrame.new(-190 + i * 32, 120 + math.sin(i * 0.9) * 10, 170 + math.cos(i * 0.7) * 20) * CFrame.Angles(0, math.sin(i) * 0.4, math.rad(8)), colors[i % 2 + 1])
			ribbon.Transparency = 0.45
			ribbon.CanCollide = false
		end
	end,
}

-- CHROME DUNES ------------------------------------------------------
THEMES.Dunes = {
	Landmark = function(b, F, cf)
		-- stepped chrome pyramid with a golden cap and a glowing eye
		for t = 0, 6 do
			local w = 34 - t * 4.6
			b:box("PyramidStep", Vector3.new(w, 4, w), cf * CFrame.new(0, 2 + t * 4, 0), t % 2 == 0 and F.Metal or F.Main)
		end
		b:box("PyramidCap", Vector3.new(4, 4, 4), cf * CFrame.new(0, 30, 0) * CFrame.Angles(0, math.rad(45), 0), F.Accent)
		b:bulb("PyramidEye", 3, cf * CFrame.new(0, 18, -8.4), F.Glow, 18)
		b:ring("EyeRing", cf * CFrame.new(0, 18, -8.7), 2.6, 0.5, F.Accent, 16)
	end,
	Props = function(b, F, cf, i, rng)
		if i % 2 == 0 then
			-- solar tower
			b:disc("SolarBase", 5, 1, cf * CFrame.new(0, 0.5, 0), F.Dark)
			b:disc("SolarPole", 1, 10, cf * CFrame.new(0, 6, 0), F.Metal)
			b:box("SolarPanel", Vector3.new(9, 0.4, 6), cf * CFrame.new(0, 11.5, 0) * CFrame.Angles(math.rad(-30), 0, 0), custom("SolarGlass", rgb(60, 80, 160), Enum.Material.Glass, {Reflectance = 0.3}))
			b:box("SolarFrame", Vector3.new(9.4, 0.3, 0.4), cf * CFrame.new(0, 11.9, 2.6) * CFrame.Angles(math.rad(-30), 0, 0), F.Metal)
			return
		end
		-- cartoon cactus
		local green = custom("Cactus", rgb(96, 196, 120))
		local h = rng:NextNumber(11, 16)
		b:pill("CactusBody", (cf * CFrame.new(0, 0, 0)).Position, (cf * CFrame.new(0, h, 0)).Position, 3, green)
		b:pill("CactusArm", (cf * CFrame.new(0, h * 0.5, 0)).Position, (cf * CFrame.new(3, h * 0.5, 0)).Position, 1.8, green)
		b:pill("CactusArm", (cf * CFrame.new(3, h * 0.5, 0)).Position, (cf * CFrame.new(3, h * 0.8, 0)).Position, 1.8, green)
		b:pill("CactusArm", (cf * CFrame.new(0, h * 0.35, 0)).Position, (cf * CFrame.new(-2.6, h * 0.35, 0)).Position, 1.6, green)
		b:pill("CactusArm", (cf * CFrame.new(-2.6, h * 0.35, 0)).Position, (cf * CFrame.new(-2.6, h * 0.6, 0)).Position, 1.6, green)
		b:ball("CactusFlower", 1.2, cf * CFrame.new(0, h + 1.4, 0), "Coral")
	end,
	Lamp = function(b, F, cf)
		b:disc("LampBase", 2.2, 0.6, cf * CFrame.new(0, 0.3, 0), F.Dark)
		b:disc("LampPole", 0.6, 6, cf * CFrame.new(0, 3.6, 0), F.Metal)
		b:bulb("SunLamp", 1.6, cf * CFrame.new(0, 7.6, 0), F.Glow, 12)
		b:ring("SunLampRing", cf * CFrame.new(0, 7.6, 0), 1.5, 0.3, F.Accent, 12)
	end,
}

-- CORAL CIRCUIT -----------------------------------------------------
THEMES.Coral = {
	Landmark = function(b, F, cf)
		-- a giant open clam with a glowing pearl, and a coral arch over it
		b:ellipsoid("ClamBottom", Vector3.new(26, 7, 20), cf * CFrame.new(0, 3, 0), F.Main)
		b:ellipsoid("ClamTop", Vector3.new(26, 7, 20), cf * CFrame.new(0, 12, 6) * CFrame.Angles(math.rad(-60), 0, 0), F.Main)
		b:ball("GiantPearl", 8, cf * CFrame.new(0, 8, -1), custom("Pearl", rgb(250, 244, 255), PLASTIC, {Reflectance = 0.3}))
		b:bulb("PearlGlow", 1, cf * CFrame.new(0, 8, -5.2), F.Glow, 20)
		b:ring("CoralArch", cf * CFrame.new(0, 2, 4), 18, 2.6, F.Second, 28, 180, 0)
	end,
	Props = function(b, F, cf, i, rng)
		if i % 2 == 0 then
			-- branching coral
			local colors = {F.Main, F.Second, F.Accent}
			local base = cf.Position
			for c = 1, 5 do
				local a = c * 1.3
				local tip = base + (cf.RightVector * math.cos(a) * 3 + cf.LookVector * math.sin(a) * 3) + Vector3.new(0, rng:NextNumber(6, 11), 0)
				b:pill("Coral", base + Vector3.new(0, 1, 0), tip, 1.4, colors[c % 3 + 1])
				b:ball("CoralTip", 2.2, CFrame.new(tip), colors[c % 3 + 1])
			end
			return
		end
		-- kelp + bubbles
		local green = custom("Kelp", rgb(70, 190, 140))
		for k = -1, 1 do
			local prev = (cf * CFrame.new(k * 2.5, 0, 0)).Position
			for s = 1, 4 do
				local nextPos = (cf * CFrame.new(k * 2.5 + math.sin(s + k) * 1.2, s * 3.2, 0)).Position
				b:pill("Kelp", prev, nextPos, 1, green)
				prev = nextPos
			end
		end
		for s = 1, 5 do
			local bubble = b:ball("Bubble", rng:NextNumber(1, 2.4), cf * CFrame.new(rng:NextNumber(-3, 3), 6 + s * 3, rng:NextNumber(-2, 2)), "Glass")
			bubble.CanCollide = false
		end
	end,
	Lamp = function(b, F, cf)
		-- jellyfish lamp
		b:disc("LampBase", 2.2, 0.6, cf * CFrame.new(0, 0.3, 0), F.Dark)
		b:disc("LampPole", 0.5, 5, cf * CFrame.new(0, 3, 0), F.Second)
		b:ellipsoid("JellyDome", Vector3.new(3.6, 2.4, 3.6), cf * CFrame.new(0, 7.6, 0), F.Crystal)
		b:bulb("JellyGlow", 1, cf * CFrame.new(0, 7.4, 0), F.Glow, 12)
		for t = 0, 3 do
			local a = math.rad(t * 90 + 45)
			b:box("Tentacle", Vector3.new(0.25, 2.6, 0.25), cf * CFrame.new(math.cos(a), 5.4, math.sin(a)), F.Main, {CanCollide = false})
		end
	end,
	Sky = function(b, F, rng)
		for i = 1, 16 do
			local a = rng:NextNumber(0, math.pi * 2)
			local d = rng:NextNumber(20, 110)
			local bubble = b:ball("FloatingBubble", rng:NextNumber(2, 5), CFrame.new(math.cos(a) * d, rng:NextNumber(24, 60), math.sin(a) * d), "Glass")
			bubble.CanCollide = false
		end
	end,
}

-- CANDY MAINFRAME ---------------------------------------------------
THEMES.Candy = {
	Landmark = function(b, F, cf)
		-- a giant cupcake with a cherry, and two huge lollipops
		b:tiers("CupcakeCup", cf, {{24, 8, F.Second}, {25, 1, F.Accent}})
		b:ellipsoid("Frosting", Vector3.new(26, 10, 26), cf * CFrame.new(0, 12, 0), F.Main)
		b:ellipsoid("FrostingTop", Vector3.new(16, 8, 16), cf * CFrame.new(0, 17, 0), custom("Frosting", rgb(255, 238, 246)))
		b:ball("Cherry", 5, cf * CFrame.new(0, 22.5, 0), custom("Cherry", rgb(236, 60, 90)))
		for _, side in ipairs({-1, 1}) do
			local base = cf * CFrame.new(side * 18, 0, 2)
			b:disc("LollipopStick", 1, 24, base * CFrame.new(0, 12, 0), "White")
			local head = base * CFrame.new(0, 26, 0)
			b:rod("LollipopHead", 1.6, 12, head * CFrame.Angles(0, math.rad(90), 0), side < 0 and F.Main or F.Second)
			b:ring("LollipopSwirl", head * CFrame.new(0, 0, -0.9), 3.6, 1, "White", 20)
		end
	end,
	Props = function(b, F, cf, i, rng)
		if i % 3 == 0 then
			-- gumdrops
			for g = 1, 3 do
				local colors = {F.Main, F.Second, F.Accent}
				b:ellipsoid("Gumdrop", Vector3.new(5, 5, 5), cf * CFrame.new((g - 2) * 5, 1.2, (g % 2) * 3), colors[g])
			end
			return
		elseif i % 3 == 1 then
			-- candy cane: striped pole + hook
			local red = custom("CaneRed", rgb(236, 70, 90))
			for s = 0, 7 do
				b:disc("CaneStripe", 1.6, 1.5, cf * CFrame.new(0, 0.75 + s * 1.5, 0), s % 2 == 0 and red or "White")
			end
			b:ring("CaneHook", cf * CFrame.new(1.8, 12, 0), 1.8, 1.6, red, 12, 180, 0)
			return
		end
		-- giant donut
		b:ring("Donut", cf * CFrame.new(0, 5, 0), 3.4, 3.2, custom("Dough", rgb(236, 180, 110)), 20)
		b:ring("DonutIcing", cf * CFrame.new(0, 5, -0.8), 3.4, 2.4, F.Main, 20)
	end,
	Lamp = function(b, F, cf)
		b:disc("LampStick", 0.6, 7, cf * CFrame.new(0, 3.5, 0), "White")
		b:rod("LampCandy", 0.8, 3.4, cf * CFrame.new(0, 8.4, 0) * CFrame.Angles(0, math.rad(90), 0), F.Main)
		b:bulb("LampGlow", 0.8, cf * CFrame.new(0, 8.4, -0.5), F.Glow, 10)
	end,
	Sky = function(b, F, rng)
		for i = 1, 8 do
			local a = rng:NextNumber(0, math.pi * 2)
			local d = rng:NextNumber(60, 180)
			local center = CFrame.new(math.cos(a) * d, rng:NextNumber(50, 90), math.sin(a) * d)
			for c = 1, 3 do
				local puff = b:ball("CottonCandyCloud", rng:NextNumber(8, 12), center * CFrame.new((c - 2) * 6, rng:NextNumber(-1, 2), 0), c % 2 == 0 and F.Main or "Frosting")
				puff.CanCollide = false
			end
		end
	end,
}

-- VOLCANO FORGE -----------------------------------------------------
THEMES.Forge = {
	Landmark = function(b, F, cf, world)
		-- a terrain volcano with a lava crater, glowing lava streams and smoke
		local origin = world.Origin
		local base = origin + cf.Position
		local layers = {{24, 6}, {19, 12}, {14, 18}, {10, 24}}
		for _, layer in ipairs(layers) do
			terrain:FillCylinder(CFrame.new(base + Vector3.new(0, layer[2] / 2, 0)), layer[2], layer[1], Enum.Material.Basalt)
		end
		terrain:FillCylinder(CFrame.new(base + Vector3.new(0, 22, 0)), 4, 7, Enum.Material.CrackedLava)
		local lava = b:disc("LavaPool", 12, 0.6, cf * CFrame.new(0, 24.3, 0), F.Glow)
		lava.Material = Enum.Material.Neon
		b:bulb("LavaLight", 1, cf * CFrame.new(0, 26, 0), F.Glow, 30)
		particles(lava, rgb(70, 60, 70), {
			Rate = 6, Lifetime = NumberRange.new(5, 8), Speed = NumberRange.new(4, 7),
			SpreadAngle = Vector2.new(15, 15), Size = NumberSequence.new(4, 12), LightEmission = 0,
			Transparency = NumberSequence.new(0.4, 1), EmissionDirection = Enum.NormalId.Top,
		})
		for s = 0, 2 do
			local a = math.rad(-60 + s * 60)
			local from = Vector3.new(math.cos(a) * 6, 23, math.sin(a) * 6)
			local to = Vector3.new(math.cos(a) * 22, 2, math.sin(a) * 22)
			b:pill("LavaStream", (cf * CFrame.new(from)).Position, (cf * CFrame.new(to)).Position, 1.6, F.Glow)
		end
	end,
	Props = function(b, F, cf, i, rng)
		if i % 2 == 0 then
			-- obsidian spikes
			for s = 1, 5 do
				local h = rng:NextNumber(5, 11)
				b:box("ObsidianSpike", Vector3.new(2, h, 2), cf * CFrame.new(rng:NextNumber(-4, 4), h / 2 - 1, rng:NextNumber(-3, 3)) * CFrame.Angles(rng:NextNumber(-0.3, 0.3), rng:NextNumber(0, 3), rng:NextNumber(-0.3, 0.3)),
					custom("Obsidian", rgb(40, 30, 56), Enum.Material.Glass, {Reflectance = 0.2}))
			end
			return
		end
		-- the meme forge: an anvil next to a glowing furnace
		b:roundedBlock("AnvilBase", Vector3.new(3, 3, 3), cf * CFrame.new(-4, 1.5, 0), 0.6, F.Second)
		b:box("AnvilTop", Vector3.new(6, 1.6, 2.6), cf * CFrame.new(-4, 3.8, 0), F.Second)
		b:tiers("Furnace", cf * CFrame.new(4, 0, 0), {{6, 5, F.Dark}, {4.6, 3, F.Second}, {2.4, 3, F.Dark}})
		b:bulb("FurnaceFire", 2.4, cf * CFrame.new(4, 2.6, -2.2), F.Glow, 14)
	end,
	Lamp = function(b, F, cf)
		-- fire brazier
		b:disc("BrazierPole", 0.8, 4.5, cf * CFrame.new(0, 2.25, 0), F.Second)
		b:disc("BrazierBowl", 3, 1.2, cf * CFrame.new(0, 5, 0), F.Dark)
		local fire = b:bulb("BrazierFire", 1.4, cf * CFrame.new(0, 6, 0), F.Glow, 14)
		particles(fire, rgb(255, 150, 60), {
			Rate = 12, Lifetime = NumberRange.new(0.5, 1), Speed = NumberRange.new(2, 4), LightEmission = 1,
			SpreadAngle = Vector2.new(10, 10), Size = NumberSequence.new(1, 0), EmissionDirection = Enum.NormalId.Top,
		})
	end,
}

-- GLITCH NEXUS ------------------------------------------------------
THEMES.Glitch = {
	Landmark = function(b, F, cf, world, rng)
		-- a giant broken monolith with a missing-texture face, and fragments floating off it
		b:box("Monolith", Vector3.new(14, 36, 5), cf * CFrame.new(0, 18, 0), F.Dark)
		for x = 0, 3 do
			for y = 0, 7 do
				b:box("MissingTexture", Vector3.new(3.2, 3.2, 0.3), cf * CFrame.new(-4.8 + x * 3.2, 8 + y * 3.2, -2.6), (x + y) % 2 == 0 and F.Second or "Ink")
			end
		end
		for i = 1, 14 do
			local s = rng:NextNumber(1.5, 4)
			local cube = b:box("Fragment", Vector3.new(s, s, s), cf * CFrame.new(rng:NextNumber(-14, 14), rng:NextNumber(20, 48), rng:NextNumber(-6, 6)) * CFrame.Angles(rng:NextNumber(0, 3), rng:NextNumber(0, 3), 0), i % 3 == 0 and F.Glow or F.Dark)
			cube.CanCollide = false
		end
	end,
	Props = function(b, F, cf, i, rng)
		if i % 2 == 0 then
			-- wireframe cube (the texture never loaded)
			local s = 8
			local h = s / 2
			local corners = {}
			for x = -1, 1, 2 do for y = -1, 1, 2 do for z = -1, 1, 2 do
				table.insert(corners, Vector3.new(x * h, y * h + h + 2, z * h))
			end end end
			for a = 1, #corners do
				for c = a + 1, #corners do
					local d = corners[c] - corners[a]
					if d.Magnitude == s then
						b:rod("Wire", s + 0.4, 0.4, cf * CFrame.new((corners[a] + corners[c]) / 2) * Architecture.alongX(Vector3.zero, d), F.Glow)
					end
				end
			end
			return
		end
		-- stack of pixel cubes that don't line up
		for c = 0, 4 do
			b:box("PixelStack", Vector3.new(4, 4, 4), cf * CFrame.new(rng:NextNumber(-1.2, 1.2), 2 + c * 4, rng:NextNumber(-1.2, 1.2)), c % 2 == 0 and F.Main or F.Second)
		end
	end,
	Lamp = function(b, F, cf)
		b:disc("LampBase", 2.2, 0.6, cf * CFrame.new(0, 0.3, 0), F.Dark)
		b:box("LampPole", Vector3.new(0.6, 6, 0.6), cf * CFrame.new(0, 3.6, 0), F.Dark)
		b:box("PixelLamp", Vector3.new(1.8, 1.8, 1.8), cf * CFrame.new(0, 7.6, 0) * CFrame.Angles(math.rad(45), math.rad(45), 0), F.Glow)
	end,
	Sky = function(b, F, rng)
		for i = 1, 20 do
			local a = rng:NextNumber(0, math.pi * 2)
			local d = rng:NextNumber(70, 220)
			local s = rng:NextNumber(3, 9)
			local cube = b:box("SkyGlitch", Vector3.new(s, s, s), CFrame.new(math.cos(a) * d, rng:NextNumber(30, 120), math.sin(a) * d), i % 2 == 0 and F.Main or F.Second)
			cube.CanCollide = false
		end
	end,
}

---------------------------------------------------------------------
-- BUILD
---------------------------------------------------------------------
return function(container, world)
	local rng = Random.new(world.Id * 7919)
	buildIsland(world, rng)

	-- rim ring + zone rings, recolored to the world's colors
	DigSiteStyle(container, world)
	buildEdgeWall(container, world)
	local F = finishes(world)
	local rim = container:FindFirstChild("Cartoon2050")
	if rim then
		local i = 0
		for _, part in ipairs(rim:GetChildren()) do
			if part:IsA("BasePart") and part.Name == "RimStripe" then
				i += 1
				local f = Architecture.Palette[(i // 2) % 2 == 0 and F.Main or F.Second]
				part.Color = f.Color
			elseif part:IsA("BasePart") and part.Name == "RimBulb" then
				part.Color = world.Look.Glow
			end
		end
	end

	local theme = THEMES[world.Theme]
	if not theme then return end
	local decor = Instance.new("Model")
	decor.Name = "Decor"
	local b = Architecture.builder(decor, CFrame.new(world.Origin))
	theme.Landmark(b, F, spot(180, LANDMARK_DISTANCE), world, rng)
	for i, angle in ipairs(PROP_ANGLES) do
		theme.Props(b, F, spot(angle, PROP_DISTANCE + rng:NextNumber(-4, 6)), i, rng)
	end
	for _, angle in ipairs(LAMP_ANGLES) do
		theme.Lamp(b, F, spot(angle, LAMP_DISTANCE))
	end
	if theme.Sky then
		theme.Sky(b, F, rng)
	end
	decor.Parent = container
end
]=])
install(game:GetService("ServerScriptService"), "WorldGate", "ModuleScript", [=[
-- WorldGate (ModuleScript in ServerScriptService)
-- Builds the portal players use to travel between worlds: a big chunky portal ring
-- with a swirling energy film, standing on a round tiered base between two capsule
-- towers, with orbiting planets, a rounded sign and a friendly terminal kiosk.
-- Once the Blender portal is imported (PortalMeshes), the ring is a heavy machined gunmetal
-- frame with brass conduits, standing in a cradle, around a glowing event horizon with two
-- sets of spiral arms spinning opposite ways and light being pulled into it.
-- Returns the gate model and its ProximityPrompt.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Architecture = require(script.Parent:WaitForChild("Architecture"))
local PortalMeshes = require(ReplicatedStorage:WaitForChild("PortalMeshes"))

local rgb = Color3.fromRGB
local PIECES = {"GatePortalFrame", "GatePortalGlow", "GateHorizon", "GateVortexA", "GateVortexB"}

-- spun around the portal's axis on every player's screen by ShovelSpinner
local function spin(part, pivot, speed)
	part:SetAttribute("OrbitPivot", pivot)
	part:SetAttribute("OrbitOffset", pivot:ToObjectSpace(part.CFrame))
	part:SetAttribute("OrbitSpeed", speed)
	CollectionService:AddTag(part, "ShovelOrbit")
end

-- the Blender portal: frame, glow, event horizon (a force-field skin over a deep violet dish),
-- spinning vortex arms, a light and motes of light drifting into the middle
local function meshPortal(gate, center)
	PortalMeshes.place(gate, "GatePortalFrame", center, {Material = Enum.Material.Metal, Reflectance = 0.05})
	PortalMeshes.place(gate, "GatePortalGlow", center, {Material = Enum.Material.Neon, Color = rgb(150, 235, 255)})
	PortalMeshes.place(gate, "GateHorizon", center * CFrame.new(0, 0, 0.12), {Material = Enum.Material.Neon, Color = rgb(52, 30, 120)})
	local horizon = PortalMeshes.place(gate, "GateHorizon", center, {Material = Enum.Material.ForceField, Color = rgb(175, 130, 255)})
	horizon.Name = "PortalSkin"
	spin(PortalMeshes.place(gate, "GateVortexA", center, {Material = Enum.Material.Neon, Color = rgb(140, 220, 255), Transparency = 0.3}), center, 0.9)
	spin(PortalMeshes.place(gate, "GateVortexB", center, {Material = Enum.Material.Neon, Color = rgb(200, 150, 255), Transparency = 0.45}), center, -0.55)
	local light = Instance.new("PointLight")
	light.Color = rgb(190, 160, 255)
	light.Range = 20
	light.Brightness = 1.4
	light.Parent = horizon
	local motes = Instance.new("ParticleEmitter")
	motes.Name = "PortalMotes"
	motes.Shape = Enum.ParticleEmitterShape.Sphere
	motes.ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface
	motes.ShapeInOut = Enum.ParticleEmitterShapeInOut.Inward
	motes.Color = ColorSequence.new(rgb(220, 245, 255), rgb(170, 120, 255))
	motes.LightEmission = 1
	motes.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.05), NumberSequenceKeypoint.new(0.3, 0.3), NumberSequenceKeypoint.new(1, 0)})
	motes.Transparency = NumberSequence.new(0.1, 0.9)
	motes.Lifetime = NumberRange.new(1, 1.5)
	motes.Speed = NumberRange.new(3.5, 5)
	motes.Rate = 22
	motes.Parent = horizon
end

-- parent: where it goes. base: its CFrame (front, local -Z, faces the players).
return function(parent, base, subtitle)
	local gate = Instance.new("Model")
	gate.Name = "WorldGate"
	local b = Architecture.builder(gate, base)

	-- round tiered base with a glowing lip
	local _, floorY = b:tiers("GateBase", CFrame.new(0, 0, 0), {
		{24, 0.5, "Sky"},
		{23.2, 0.3, "GlowCyan"},
		{22, 0.7, "White"},
		{15, 0.4, "Cloud"},
	})
	b:roundedBlock("GateStep", Vector3.new(10, 0.5, 3), CFrame.new(0, 0.25, -12.4), 1.4, "Cloud")

	-- the portal: the Blender ring once imported, otherwise a thick white ring, a lilac inner
	-- ring, a glowing edge and the energy film
	local center = CFrame.new(0, floorY + 9.5, 0)
	if PortalMeshes.has(table.unpack(PIECES)) then
		meshPortal(gate, base * center)
	else
		b:ring("PortalRing", center, 8.2, 2.2, "White", 32)
		b:ring("PortalInner", center * CFrame.new(0, 0, -0.9), 7, 0.7, "Lilac", 32)
		b:ring("PortalGlow", center * CFrame.new(0, 0, -1.2), 7.2, 0.3, "GlowPink", 32)
		local film = b:rod("PortalFilm", 0.3, 13.6, center * CFrame.Angles(0, math.rad(90), 0), "Portal", {CanCollide = false})
		film.Transparency = 0.25
		local swirl = b:rod("PortalSwirl", 0.2, 9, center * CFrame.new(0, 0, -0.2) * CFrame.Angles(0, math.rad(90), 0), "GlowCyan", {CanCollide = false})
		swirl.Transparency = 0.55
		local glow = Instance.new("PointLight")
		glow.Color = Color3.fromRGB(200, 170, 255)
		glow.Range = 18
		glow.Brightness = 1.2
		glow.Parent = film
		-- chunky feet holding the ring
		for _, side in ipairs({-1, 1}) do
			b:roundedBlock("RingFoot", Vector3.new(3.2, 2.4, 3.2), CFrame.new(side * 5.4, floorY + 1.2, 0), 1.2, "Violet")
		end
		-- sparkle bulbs around the ring
		for i = 0, 11 do
			local a = math.rad(i * 30 + 15)
			b:bulb("RingBulb", 0.7, center * CFrame.new(math.cos(a) * 8.2, math.sin(a) * 8.2, -1.25), i % 2 == 0 and "GlowSun" or "GlowCyan", 5)
		end
	end

	-- capsule towers either side, topped with little planets
	for _, side in ipairs({-1, 1}) do
		local x = side * 11.5
		b:disc("TowerFoot", 3.6, 0.8, CFrame.new(x, floorY + 0.4, 1), "Violet")
		b:pill("Tower", Vector3.new(x, floorY + 1.5, 1), Vector3.new(x, floorY + 14, 1), 2.4, "White")
		b:disc("TowerBand", 2.7, 0.4, CFrame.new(x, floorY + 5, 1), "GlowMint")
		b:disc("TowerBand", 2.7, 0.4, CFrame.new(x, floorY + 10, 1), "Lilac")
		local planet = CFrame.new(x, floorY + 17, 1)
		b:ball("Planet", 3, planet, side < 0 and "Sun" or "Mint")
		b:ring("PlanetRing", planet * CFrame.Angles(math.rad(70), 0, math.rad(side * 20)), 2.3, 0.3, side < 0 and "Coral" or "Lilac", 16)
	end

	-- rounded sign on top of the ring
	local sign = b:roundedBlock("GateSign", Vector3.new(15, 3.6, 1.2), center * CFrame.new(0, 10.6, -0.2), 1.6, "Navy")
	b:roundedBlock("GateSignBack", Vector3.new(15.8, 4.2, 1), center * CFrame.new(0, 10.6, 0.2), 1.9, "Violet")
	Architecture.sign(sign, "WORLD GATE", subtitle or "TRAVEL BETWEEN DIG SITES")
	b:ball("SignStar", 1.4, center * CFrame.new(0, 13.2, 0), "GlowSun")

	-- terminal kiosk (a friendly capsule with a tilted screen)
	b:disc("KioskFoot", 3, 0.4, CFrame.new(0, floorY + 0.2, -7), "Violet")
	local kiosk = b:roundedBlock("Kiosk", Vector3.new(2.6, 3.4, 1.6), CFrame.new(0, floorY + 2.1, -7), 0.8, "Sky")
	local screen = b:roundedBlock("KioskScreen", Vector3.new(3, 1.8, 0.3), CFrame.new(0, floorY + 4.2, -7.3) * CFrame.Angles(math.rad(-25), 0, 0), 0.15, "Navy")
	Architecture.sign(screen, "WORLD MAP", "PRESS E", nil, Color3.new(1, 1, 1))

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Open World Map"
	prompt.ObjectText = "World Gate"
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = kiosk

	gate.Parent = parent
	return gate, prompt
end
]=])
install(game:GetService("ServerScriptService"), "WorldGimmickManager", "Script", [=[
-- WorldGimmickManager (Script in ServerScriptService)
-- Attaches each world's gimmicks (see ReplicatedStorage.WorldGimmicks) to that world's folder
-- (workspace.Worlds.WorldN gets a "Gimmick" attribute and a Gimmick folder for its parts),
-- starts its Gimmick_<Module> scripts, and tells them when players enter or leave the world.
--
-- Each Gimmick_<Module> returns a table with:
--   Start(ctx)            once, when the world is built
--   OnEnter(ctx, player)  optional, when a player arrives in the world
--   OnLeave(ctx, player)  optional, when they leave it (or the game)
-- ctx has: World, Container, Folder (for the gimmick's parts), Boosts (DigBoosts),
--   PlayersInWorld(), Announce(text, color), IsHere(player),
--   EventLoop({Every, Duration, Boost, Name, Color, Message, OnStart, OnStop})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local WorldGimmicks = require(ReplicatedStorage:WaitForChild("WorldGimmicks"))
local DigBoosts = require(script.Parent:WaitForChild("DigBoosts"))

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local announceRemote = remotes:WaitForChild("Announcement")

local contexts = {} -- [worldId] = {{Ctx, Module}, ...} (a world can have more than one gimmick)

local function makeContext(world, container, folder)
	local ctx = {World = world, Container = container, Folder = folder, Boosts = DigBoosts}
	function ctx.IsHere(player)
		return player:GetAttribute("CurrentWorld") == world.Id
	end
	function ctx.PlayersInWorld()
		local list = {}
		for _, player in ipairs(Players:GetPlayers()) do
			if ctx.IsHere(player) then table.insert(list, player) end
		end
		return list
	end
	function ctx.Announce(text, color)
		for _, player in ipairs(ctx.PlayersInWorld()) do
			announceRemote:FireClient(player, text, color)
		end
	end
	-- a repeating timed event: a digging boost for everyone in the world while it runs
	function ctx.EventLoop(event)
		task.spawn(function()
			task.wait(event.Every * 0.5)
			while container.Parent do
				if #ctx.PlayersInWorld() > 0 then
					if event.Boost then
						local boost = table.clone(event.Boost)
						boost.Name = event.Name
						DigBoosts.StartWorldEvent(world.Id, boost, event.Duration)
					end
					container:SetAttribute("Event", event.Name)
					ctx.Announce(event.Message, event.Color)
					if event.OnStart then task.spawn(event.OnStart) end
					task.wait(event.Duration)
					container:SetAttribute("Event", "")
					DigBoosts.EndWorldEvent(world.Id)
					if event.OnStop then task.spawn(event.OnStop) end
				end
				task.wait(event.Every)
			end
		end)
	end
	return ctx
end

local function startWorld(world, info)
	local worldsFolder = workspace:WaitForChild("Worlds", 60)
	local container = worldsFolder and worldsFolder:WaitForChild("World" .. world.Id, 60)
	if not container then
		warn("World gimmicks not started for world " .. world.Id)
		return
	end
	container:SetAttribute("Gimmick", table.concat(info.Modules, ","))
	local folder = container:FindFirstChild("Gimmick")
	if folder then folder:Destroy() end
	folder = Instance.new("Folder")
	folder.Name = "Gimmick"
	folder.Parent = container
	contexts[world.Id] = {}
	for _, name in ipairs(info.Modules) do
		local moduleScript = script.Parent:FindFirstChild("Gimmick_" .. name)
		if moduleScript then
			local module = require(moduleScript)
			local ctx = makeContext(world, container, folder)
			table.insert(contexts[world.Id], {Ctx = ctx, Module = module})
			local ok, err = pcall(module.Start, ctx)
			if not ok then warn("World gimmick " .. name .. " failed: " .. tostring(err)) end
		else
			warn("Missing gimmick script Gimmick_" .. name)
		end
	end
end

for worldId, info in pairs(WorldGimmicks) do
	local world = GameConfig.GetWorld(worldId)
	if world and world.Enabled and #info.Modules > 0 then
		task.spawn(startWorld, world, info)
	end
end

local function notify(worldId, hook, player)
	for _, entry in ipairs(worldId and contexts[worldId] or {}) do
		if entry.Module[hook] then task.spawn(entry.Module[hook], entry.Ctx, player) end
	end
end

-- tell the gimmicks when players come and go
local where = {} -- [player] = worldId the gimmicks last saw them in
local function moved(player)
	local now = player:GetAttribute("CurrentWorld")
	local before = where[player]
	if now == before then return end
	where[player] = now
	notify(before, "OnLeave", player)
	notify(now, "OnEnter", player)
end
local function watch(player)
	player:GetAttributeChangedSignal("CurrentWorld"):Connect(function() moved(player) end)
	moved(player)
end
Players.PlayerAdded:Connect(watch)
for _, player in ipairs(Players:GetPlayers()) do watch(player) end
Players.PlayerRemoving:Connect(function(player)
	local before = where[player]
	where[player] = nil
	notify(before, "OnLeave", player)
end)
]=])
install(game:GetService("ServerScriptService"), "WorldOneDecor", "ModuleScript", [=[
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
local function mosaicRing(b, radius, width, segments, finishes)
	local length = 2 * math.pi * radius / segments + 0.3
	for i = 0, segments - 1 do
		local deg = (i + 0.5) * 360 / segments
		local pos = at(deg, radius, 0.14)
		local tangent = Vector3.new(-math.sin(math.rad(deg)), 0, math.cos(math.rad(deg)))
		b:box("PlazaTile", Vector3.new(length, 0.16, width), Architecture.alongX(pos, tangent), finishes[i % #finishes + 1])
	end
end

local function plaza(b)
	-- around the dig site (just outside its ramps) and inside the boulevard
	mosaicRing(b, 128, 7, 96, {"PlazaTileA", "PlazaTileB", "PlazaTileA", "PlazaTileC"})
	mosaicRing(b, 133, 1.2, 96, {"GlowCyan"})
	mosaicRing(b, 247, 6, 128, {"PlazaTileB", "PlazaTileA"})
	-- glowing inlay lines from the dig site out between the museums
	for _, deg in ipairs(GAP_ANGLES) do
		local from, to = at(deg, 136, 0.3), at(deg, 243, 0.3)
		b:box("InlayLine", Vector3.new(0.7, 0.2, (to - from).Magnitude), CFrame.lookAt((from + to) / 2, to), "GlowCyan")
		for _, side in ipairs({-1, 1}) do
			local off = Vector3.new(-math.sin(math.rad(deg)), 0, math.cos(math.rad(deg))) * side * 3
			b:box("InlayEdge", Vector3.new(1.4, 0.18, (to - from).Magnitude), CFrame.lookAt((from + to) / 2 + off, to + off), "PlazaTileB")
		end
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
		local size = Vector3.new(length, LAWN_TOP - LAWN_BOTTOM, 2 * math.pi * LAWN_TO / 360 + 1.2)
		local cf = Architecture.alongX(dir * ((LAWN_FROM + LAWN_TO) / 2) + Vector3.new(0, (LAWN_TOP + LAWN_BOTTOM) / 2, 0), dir)
		workspace.Terrain:FillBlock(cf - Vector3.new(0, cf.Y + 2, 0), Vector3.new(size.X, 4, size.Z), Enum.Material.Air)
		b:box("Lawn", size, cf, "Lawn")
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
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "AudioClient", "LocalScript", [=[
-- AudioClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Background music and the audio settings.
--   * Music: GameConfig.Music has a track per world; when you travel it crossfades to the
--     new world's track (or GameConfig.Music.Default).
--   * Two SoundGroups: "Music" and "SFX" (every sound effect plays through SFX, see Audio).
--   * SETTINGS window (UIBus "Settings"): a volume slider and a mute button for each group.
--   * The speaker button on the HUD (UIBus "ToggleSound") mutes / unmutes everything at once.
--   Settings are saved in your data (SettingsManager) so they stick between visits.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Audio = require(ReplicatedStorage:WaitForChild("Audio"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local UIBus = require(ReplicatedStorage:WaitForChild("UIBus"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local saveRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SaveAudioSettings")

local player = Players.LocalPlayer
local musicGroup, sfxGroup = Audio.group("Music"), Audio.group("SFX")

local settings = table.clone(GameConfig.DefaultAudio) -- Music 30%, SFX 20% until your saved settings load

local function apply()
	musicGroup.Volume = settings.MusicMuted and 0 or settings.MusicVolume
	sfxGroup.Volume = settings.SfxMuted and 0 or settings.SfxVolume
	player:SetAttribute("SoundMuted", settings.MusicMuted and settings.SfxMuted) -- the HUD speaker icon reads this
end

-- saving is throttled (sliders fire a lot while dragging)
local saveQueued = false
local function save()
	apply()
	if saveQueued then return end
	saveQueued = true
	task.delay(1, function()
		saveQueued = false
		saveRemote:FireServer(settings)
	end)
end

---------------------------------------------------------------------
-- MUSIC: one track per world, crossfading when you travel
---------------------------------------------------------------------
local current -- the Sound playing now
local function trackFor(worldId)
	local id = GameConfig.Music[worldId]
	if not id or id == "" then id = GameConfig.Music.Default end
	return id ~= "" and id or nil
end
local function playMusic(worldId)
	local id = trackFor(worldId)
	if current and current.SoundId == id then return end
	local old = current
	current = nil
	if old then
		TweenService:Create(old, TweenInfo.new(GameConfig.MusicCrossfade), {Volume = 0}):Play()
		task.delay(GameConfig.MusicCrossfade + 0.1, function() old:Destroy() end)
	end
	if not id then return end
	local sound = Instance.new("Sound")
	sound.Name = "BackgroundMusic"
	sound.SoundId = id
	sound.Looped = true
	sound.Volume = 0
	sound.SoundGroup = musicGroup
	sound.Parent = SoundService
	sound:Play()
	TweenService:Create(sound, TweenInfo.new(GameConfig.MusicCrossfade), {Volume = GameConfig.MusicVolume}):Play()
	current = sound
end
player:GetAttributeChangedSignal("CurrentWorld"):Connect(function()
	playMusic(player:GetAttribute("CurrentWorld") or 1)
end)
playMusic(player:GetAttribute("CurrentWorld") or 1)

---------------------------------------------------------------------
-- SETTINGS WINDOW
---------------------------------------------------------------------
local gui = UIKit.screen(player, "SettingsGui", 8)
local window, content = UIKit.window(gui, "SETTINGS", UDim2.fromOffset(460, 330), C.Sky, "Settings")

-- one row: icon + name, a mute button, and a slider underneath
local function audioRow(y, icon, title, volumeKey, mutedKey)
	UIKit.icon(content, icon, {Size = UDim2.fromOffset(40, 40), Position = UDim2.fromOffset(4, y - 5)})
	UIKit.label(content, title, {Size = UDim2.new(0.6, -48, 0, 30), Position = UDim2.fromOffset(50, y), Align = "Left", Color = C.Ink, Stroke = 0, MaxText = 24})
	local mute = UIKit.button(content, "", {Size = UDim2.fromOffset(130, 40), Position = UDim2.new(1, -8, 0, y - 5), AnchorPoint = Vector2.new(1, 0), Radius = 19, MaxText = 16, Icon = "SoundOn"})
	local track = UIKit.panel(content, {Size = UDim2.new(1, -90, 0, 14), Position = UDim2.fromOffset(8, y + 50), Color = C.PanelTint, Radius = 7, Stroke = 2, StrokeColor = C.Lilac, Shade = false})
	local fill = UIKit.panel(track, {Size = UDim2.fromScale(1, 1), Color = C.Sky, Radius = 7, Stroke = false, Shade = false})
	local knob = UIKit.panel(track, {Size = UDim2.fromOffset(26, 26), Position = UDim2.fromScale(1, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.White, Radius = 13, Stroke = 3, StrokeColor = C.Sky, Shade = false})
	local percent = UIKit.label(content, "", {Size = UDim2.fromOffset(64, 24), Position = UDim2.new(1, -8, 0, y + 45), AnchorPoint = Vector2.new(1, 0), Color = C.Grey, Stroke = 0, MaxText = 18})
	local function refresh()
		local v = settings[volumeKey]
		fill.Size = UDim2.fromScale(v, 1)
		knob.Position = UDim2.fromScale(v, 0.5)
		percent.Text = math.floor(v * 100 + 0.5) .. "%"
		local muted = settings[mutedKey]
		UIKit.setButton(mute, muted and "MUTED" or "ON", muted and C.Coral or C.Mint, muted and "SoundOff" or "SoundOn")
		fill.BackgroundColor3 = muted and C.Grey or C.Sky
	end
	mute.MouseButton1Click:Connect(function()
		settings[mutedKey] = not settings[mutedKey]
		refresh()
		save()
	end)
	-- dragging the slider (mouse or touch)
	local dragging = false
	local function setFrom(x)
		local v = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		settings[volumeKey] = math.floor(v * 100 + 0.5) / 100
		if settings[volumeKey] > 0 then settings[mutedKey] = false end
		refresh()
		save()
	end
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setFrom(input.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			setFrom(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	return refresh
end

local refreshMusic = audioRow(14, "Music", "Music", "MusicVolume", "MusicMuted")
local refreshSfx = audioRow(118, "Bell", "Sound Effects", "SfxVolume", "SfxMuted")
UIKit.label(content, "Your settings are saved and stick between visits.", {Size = UDim2.new(1, -16, 0, 20), Position = UDim2.new(0.5, 0, 1, -30), AnchorPoint = Vector2.new(0.5, 0),
	Color = C.Grey, Stroke = 0, Font = UIKit.BodyFont, MaxText = 15})

local function refreshAll()
	refreshMusic()
	refreshSfx()
	apply()
end

UIBus.On("Settings", function()
	if window.Visible then
		window.Visible = false
	else
		refreshAll()
		UIKit.open(window)
	end
end)
-- the HUD's speaker button: everything off, or back to how it was
UIBus.On("ToggleSound", function()
	local allMuted = settings.MusicMuted and settings.SfxMuted
	settings.MusicMuted = not allMuted
	settings.SfxMuted = not allMuted
	refreshAll()
	save()
end)

-- load the saved settings
local function load()
	local raw = player:GetAttribute("AudioSettings")
	if typeof(raw) ~= "string" then return end
	local ok, saved = pcall(function() return HttpService:JSONDecode(raw) end)
	if ok and typeof(saved) == "table" then
		for key in pairs(settings) do
			if saved[key] ~= nil and key ~= "Version" then settings[key] = saved[key] end
		end
		refreshAll()
	end
end
player:GetAttributeChangedSignal("AudioSettings"):Connect(function()
	if not saveQueued then load() end
end)
load()
refreshAll()
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "BackgroundWeather", "LocalScript", [=[
-- BackgroundWeather (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Bizarre background weather: giant plain cubes, spheres and cones tumble out of the sky
-- far away in the background, around whichever world you're in. They spawn well outside
-- the playable area (past the city in World 1, past the island edge in worlds 2-9), fall,
-- spin, and delete themselves at a set height, so they can never touch the ground you play
-- on. Everything happens on this screen only (no server cost, no physics).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local player = Players.LocalPlayer

local MAX_OBJECTS = 40
local SPAWN_EVERY = 0.35      -- seconds between new objects
local SPAWN_HEIGHT = {450, 750} -- studs above the world's ground
local DESTROY_BELOW = -220    -- studs below the world's ground: removed here
-- how far out they fall (studs from the world's center): World 1's island reaches 470 studs,
-- the other islands 125
local DISTANCE = {World1 = {700, 1200}, Island = {520, 1100}}
local CONE_MESH = "rbxassetid://1033714" -- Roblox's classic cone mesh

local COLORS = {
	Color3.fromRGB(255, 110, 124), Color3.fromRGB(92, 186, 255), Color3.fromRGB(255, 206, 84),
	Color3.fromRGB(96, 226, 190), Color3.fromRGB(178, 158, 255), Color3.fromRGB(246, 247, 252),
}
local MATERIALS = {Enum.Material.SmoothPlastic, Enum.Material.SmoothPlastic, Enum.Material.Neon, Enum.Material.Glass}

local folder = Instance.new("Folder")
folder.Name = "BackgroundWeather"
folder.Parent = workspace

local rng = Random.new()
local falling = {} -- {Part, Velocity, Spin, Angles}

local function currentWorld()
	return GameConfig.GetWorld(player:GetAttribute("CurrentWorld") or 1) or GameConfig.Worlds[1]
end

local function spawnOne()
	local world = currentWorld()
	local range = world.Id == 1 and DISTANCE.World1 or DISTANCE.Island
	local angle = rng:NextNumber(0, math.pi * 2)
	local distance = rng:NextNumber(range[1], range[2])
	local origin = world.Origin
	local position = origin + Vector3.new(math.cos(angle) * distance, rng:NextNumber(SPAWN_HEIGHT[1], SPAWN_HEIGHT[2]), math.sin(angle) * distance)

	local part = Instance.new("Part")
	local kind = rng:NextInteger(1, 3)
	local size = rng:NextNumber(10, 38)
	part.Size = Vector3.one * size
	if kind == 2 then
		part.Shape = Enum.PartType.Ball
	elseif kind == 3 then
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = CONE_MESH
		mesh.Scale = Vector3.one * size * 0.5
		mesh.Parent = part
	end
	part.Color = COLORS[rng:NextInteger(1, #COLORS)]
	part.Material = MATERIALS[rng:NextInteger(1, #MATERIALS)]
	if part.Material == Enum.Material.Glass then part.Transparency = 0.3 end
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.CFrame = CFrame.new(position)
	part.Parent = folder

	-- drift slightly away from the world so they never curve in over it
	local outward = Vector3.new(math.cos(angle), 0, math.sin(angle)) * rng:NextNumber(0, 12)
	table.insert(falling, {
		Part = part,
		Velocity = Vector3.new(0, -rng:NextNumber(45, 95), 0) + outward,
		Spin = Vector3.new(rng:NextNumber(-1.5, 1.5), rng:NextNumber(-1.5, 1.5), rng:NextNumber(-1.5, 1.5)),
		Angles = Vector3.zero,
		FloorY = origin.Y + DESTROY_BELOW,
	})
end

local sinceSpawn = 0
RunService.Heartbeat:Connect(function(dt)
	sinceSpawn += dt
	if sinceSpawn >= SPAWN_EVERY and #falling < MAX_OBJECTS then
		sinceSpawn = 0
		spawnOne()
	end
	local parts, cframes = {}, {}
	for i = #falling, 1, -1 do
		local f = falling[i]
		local pos = f.Part.Position + f.Velocity * dt
		if pos.Y < f.FloorY or not f.Part.Parent then
			f.Part:Destroy()
			table.remove(falling, i)
		else
			f.Angles += f.Spin * dt
			table.insert(parts, f.Part)
			table.insert(cframes, CFrame.new(pos) * CFrame.Angles(f.Angles.X, f.Angles.Y, f.Angles.Z))
		end
	end
	if #parts > 0 then
		workspace:BulkMoveTo(parts, cframes, Enum.BulkMoveMode.FireCFrameChanged)
	end
end)

-- travelling to another world: clear the old sky right away
player:GetAttributeChangedSignal("CurrentWorld"):Connect(function()
	for _, f in ipairs(falling) do f.Part:Destroy() end
	table.clear(falling)
end)
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "DigClient", "LocalScript", [=[
-- DigClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Shows the luck minigame, the short "you found" lines, and rare-find announcements.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local minigameRemote = remotes:WaitForChild("DigMinigame")
local resultRemote = remotes:WaitForChild("DigResult")
local announceRemote = remotes:WaitForChild("Announcement")

local player = Players.LocalPlayer

---------------------------------------------------------------------
-- UI
---------------------------------------------------------------------
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local GRADE_COLORS = {
	Perfect = C.Mint,
	Good = C.Sun,
	Miss = C.Coral,
}

local gui = UIKit.screen(player, "DigGui", 5)

---------------------------------------------------------------------
-- MINIGAME
---------------------------------------------------------------------
-- a small card with a colored header strip (used by the minigame and the find popup)
local function headerCard(size, position, color, title)
	local card = UIKit.panel(gui, {Size = size, Position = position, AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Panel, Radius = 24, Stroke = 4, StrokeColor = C.Ink, ShadeAmount = 0.05})
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.BorderSizePixel = 0
	header.Size = UDim2.new(1, 0, 0, 50)
	header.Parent = card
	UIKit.corner(header, 22)
	local fill = Instance.new("Frame")
	fill.BorderSizePixel = 0
	fill.AnchorPoint = Vector2.new(0, 1)
	fill.Position = UDim2.fromScale(0, 1)
	fill.Size = UDim2.new(1, 0, 0, 22)
	fill.Parent = header
	local edge = Instance.new("Frame")
	edge.BorderSizePixel = 0
	edge.AnchorPoint = Vector2.new(0, 1)
	edge.Position = UDim2.fromScale(0, 1)
	edge.Size = UDim2.new(1, 0, 0, 4)
	edge.Parent = header
	local titleLabel = UIKit.label(header, title, {Size = UDim2.new(1, -40, 0, 30), Position = UDim2.new(0.5, 0, 0.5, -2), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 3, MaxText = 28})
	local titleStroke = titleLabel:FindFirstChildOfClass("UIStroke")
	local function paint(c)
		header.BackgroundColor3 = c
		fill.BackgroundColor3 = c
		edge.BackgroundColor3 = UIKit.shadeColor(c, 0.35)
		if titleStroke then titleStroke.Color = UIKit.shadeColor(c, 0.6) end
	end
	paint(color)
	return card, titleLabel, paint
end

local mini = headerCard(UDim2.fromOffset(480, 160), UDim2.fromScale(0.5, 0.7), C.Sun, "LUCKY DIG!")
mini.Visible = false
UIKit.icon(mini, "Luck", {Size = UDim2.fromOffset(64, 64), Position = UDim2.fromOffset(-14, -22), ZIndex = 3})
UIKit.label(mini, "Stop in the green for bonus luck!", {Size = UDim2.new(0.9, 0, 0, 22), Position = UDim2.new(0.5, 0, 0, 58), AnchorPoint = Vector2.new(0.5, 0), Color = C.Ink, Stroke = 0, MaxText = 20})

local bar = UIKit.panel(mini, {Size = UDim2.new(0.88, 0, 0, 30), Position = UDim2.new(0.5, 0, 0, 88), AnchorPoint = Vector2.new(0.5, 0), Color = C.PanelTint, Radius = 15, Stroke = 3, StrokeColor = C.Ink, Shade = false})
bar.ClipsDescendants = false

local goodZone = UIKit.panel(bar, {Size = UDim2.new(0.22, 0, 1, 0), Color = GRADE_COLORS.Good, Radius = 12, Stroke = false})

local perfectZone = UIKit.panel(goodZone, {Size = UDim2.new(0.3, 0, 1, 0), Position = UDim2.new(0.5, 0, 0, 0), AnchorPoint = Vector2.new(0.5, 0), Color = GRADE_COLORS.Perfect, Radius = 8, Stroke = false})

local marker = UIKit.panel(bar, {Size = UDim2.new(0, 12, 1.6, 0), Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.White, Radius = 6, Stroke = 3, StrokeColor = C.Ink, Shade = false})
marker.ZIndex = 3

UIKit.label(mini, "Click, tap, or press Space", {Size = UDim2.new(0.9, 0, 0, 16), Position = UDim2.new(0.5, 0, 1, -26), AnchorPoint = Vector2.new(0.5, 0), Color = C.Grey, Stroke = 0, Font = UIKit.BodyFont, MaxText = 14})
local gradeText = UIKit.label(gui, "", {Size = UDim2.fromOffset(420, 72), Position = UDim2.fromScale(0.5, 0.58), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 5, MaxText = 64})
gradeText.Visible = false

local playing = false
local SPEED = 1.3 -- how fast the marker moves (bar widths per second)

local function showGrade(grade)
	gradeText.Text = string.upper(grade) .. (grade == "Miss" and "" or "!")
	gradeText.TextColor3 = GRADE_COLORS[grade]
	gradeText.Visible = true
	UIKit.pop(gradeText, 0.4)
	task.delay(0.8, function()
		gradeText.Visible = false
	end)
end

local function startMinigame()
	if playing then return end
	playing = true

	-- random zone position each time
	local zoneStart = math.random(10, 68) / 100
	goodZone.Position = UDim2.new(zoneStart, 0, 0, 0)
	local zoneWidth = goodZone.Size.X.Scale
	local perfectWidth = zoneWidth * perfectZone.Size.X.Scale
	local zoneCenter = zoneStart + zoneWidth / 2

	mini.Visible = true
	UIKit.pop(mini)
	local t = 0
	local position = 0
	local renderConn, inputConn
	local done = false

	local function finish(grade)
		if done then return end
		done = true
		playing = false
		renderConn:Disconnect()
		inputConn:Disconnect()
		mini.Visible = false
		showGrade(grade)
		minigameRemote:FireServer(grade)
	end

	renderConn = RunService.RenderStepped:Connect(function(dt)
		t += dt * SPEED
		local cycle = t % 2
		position = (cycle <= 1) and cycle or (2 - cycle) -- bounce left and right
		marker.Position = UDim2.new(position, 0, 0.5, 0)
	end)

	inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		local isClick = input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		local isKey = input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA
		if not (isClick or isKey) then return end
		if gameProcessed and isClick then return end

		local distance = math.abs(position - zoneCenter)
		if distance <= perfectWidth / 2 then
			finish("Perfect")
		elseif distance <= zoneWidth / 2 then
			finish("Good")
		else
			finish("Miss")
		end
	end)

	-- give up after a few seconds
	task.delay(6, function()
		finish("Miss")
	end)
end

minigameRemote.OnClientEvent:Connect(startMinigame)

---------------------------------------------------------------------
-- FIND MESSAGES: just a line of text near the top of the screen that fades away
---------------------------------------------------------------------
local pullRemote = remotes:WaitForChild("PullFind")

local function textLine(y, size)
	local l = UIKit.label(gui, "", {Size = UDim2.fromOffset(640, size), Position = UDim2.new(0.5, 0, 0, y), AnchorPoint = Vector2.new(0.5, 0),
		Color = C.White, Stroke = 2.5, MaxText = size})
	l.Visible = false
	return l, l:FindFirstChildOfClass("UIStroke")
end
local foundText, foundStroke = textLine(262, 30)
local hintText, hintStroke = textLine(298, 20)

local tokens = {}
local function say(label, stroke, text, color, duration)
	tokens[label] = (tokens[label] or 0) + 1
	local myToken = tokens[label]
	label.Text = text
	label.TextColor3 = color
	label.TextTransparency = 0
	if stroke then
		stroke.Color = color:Lerp(Color3.new(0, 0, 0), 0.7)
		stroke.Transparency = 0
	end
	label.Visible = true
	UIKit.pop(label, 0.8)
	task.delay(duration, function()
		if tokens[label] ~= myToken then return end
		local fade = TweenInfo.new(0.5)
		TweenService:Create(label, fade, {TextTransparency = 1}):Play()
		if stroke then TweenService:Create(stroke, fade, {Transparency = 1}):Play() end
		task.delay(0.5, function()
			if tokens[label] == myToken then label.Visible = false end
		end)
	end)
end
local function unsay(label)
	tokens[label] = (tokens[label] or 0) + 1
	label.Visible = false
end

---------------------------------------------------------------------
-- BURIED FIND: one line of text + an outline on the object while it waits in the crater
---------------------------------------------------------------------
local buriedHighlight
local function clearBuried()
	unsay(hintText)
	if buriedHighlight then
		buriedHighlight:Destroy()
		buriedHighlight = nil
	end
end

-- other players' finds can't be pulled by us: hide their prompts on this screen
local findsFolder = workspace:WaitForChild("BuriedFinds", 30)
if findsFolder then
	local function check(d)
		if d:IsA("ProximityPrompt") then
			local model = d:FindFirstAncestorOfClass("Model")
			local owner = model and model:GetAttribute("Owner")
			if owner and owner ~= player.UserId then d.Enabled = false end
		end
	end
	findsFolder.DescendantAdded:Connect(check)
	for _, d in ipairs(findsFolder:GetDescendants()) do check(d) end
end

local Audio = require(ReplicatedStorage:WaitForChild("Audio"))
local function playFindSound()
	Audio.sfx("Find")
end

resultRemote.OnClientEvent:Connect(function(info)
	clearBuried()
	playFindSound()
	local timeout = tonumber(info.Timeout) or 25
	say(hintText, hintStroke, "You uncovered something " .. string.upper(info.Rarity) .. "!  Hold E to pull it out", info.Color:Lerp(C.White, 0.3), timeout)
	if typeof(info.Painting) == "Instance" then
		local model = info.Painting
		buriedHighlight = Instance.new("Highlight")
		buriedHighlight.FillTransparency = 0.9
		buriedHighlight.FillColor = info.Color
		buriedHighlight.OutlineColor = info.Color:Lerp(C.White, 0.3)
		buriedHighlight.OutlineTransparency = 0.35
		-- occluded: the part that's still under the dirt stays hidden
		buriedHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
		buriedHighlight.Adornee = model
		buriedHighlight.Parent = gui
		local highlight = buriedHighlight
		model.AncestryChanged:Connect(function()
			if not model:IsDescendantOf(workspace) and buriedHighlight == highlight then clearBuried() end
		end)
	end
end)

---------------------------------------------------------------------
-- "YOU FOUND X": once it's pulled out
---------------------------------------------------------------------
pullRemote.OnClientEvent:Connect(function(finder, _painting, info)
	if finder ~= player or typeof(info) ~= "table" then return end
	clearBuried()
	task.delay(0.9, function()
		say(foundText, foundStroke, "You found " .. info.Name .. "!  " .. string.upper(info.Rarity) .. "  ·  +"
			.. ArtifactData.FormatMoney(info.Income) .. "/s", info.Color:Lerp(C.White, 0.25), 3.5)
	end)
end)

---------------------------------------------------------------------
-- RARE FIND ANNOUNCEMENTS (whole server)
---------------------------------------------------------------------
local banner = UIKit.panel(gui, {Size = UDim2.fromOffset(640, 54), Position = UDim2.new(0.5, 0, 0, 196), AnchorPoint = Vector2.new(0.5, 0), Color = C.Ink, Radius = 27, Stroke = 3, StrokeColor = C.Sun, ShadeAmount = 0.2})
banner.BackgroundTransparency = 0.08
banner.Visible = false
local bannerStroke = banner:FindFirstChildOfClass("UIStroke")
local bannerStar, bannerIcon = UIKit.badge(banner, "Party", C.Sun, {Diameter = 44, Position = UDim2.new(0, 6, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)})
local bannerText = UIKit.label(banner, "", {Size = UDim2.new(1, -80, 0.56, 0), Position = UDim2.new(0, 62, 0.22, 0), Align = "Left", Color = C.White, Stroke = 0, MaxText = 24})

local bannerToken = 0
announceRemote.OnClientEvent:Connect(function(message, color)
	bannerToken += 1
	local myToken = bannerToken
	local icon, text = UIKit.splitIcon(message)
	bannerText.Text = text
	UIKit.setIcon(bannerIcon, icon or "Party")
	local accent = typeof(color) == "Color3" and color or C.Sun
	bannerStar.BackgroundColor3 = accent
	bannerStroke.Color = accent
	banner.Visible = true
	UIKit.pop(banner, 0.7)
	task.delay(6, function()
		if bannerToken == myToken then
			banner.Visible = false
		end
	end)
end)
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "FindPullClient", "LocalScript", [=[
-- FindPullClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The 1-second pull-out animation for dug-up memes, played on every screen for whoever
-- found it (after they hold E on it):
--   0.00-0.22  it wiggles loose and pops up out of the dirt in a burst of soil
--   0.22-0.78  it flies in an arc straight to the finder, shrinking and turning to face them
--   0.78-1.00  it dissolves into a sparkle at their chest (it's in the inventory now)
-- The dirt mound and the rarity glow around it sink away while it flies.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local pullRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PullFind")
local player = Players.LocalPlayer

-- timeline (seconds)
local RISE_END = 0.22
local FLY_END = 0.78
local DONE = 1.0

local function smooth(u)
	u = math.clamp(u, 0, 1)
	return u * u * (3 - 2 * u)
end
local function easeOutBack(u)
	u = math.clamp(u, 0, 1)
	local c1 = 1.7
	return 1 + (c1 + 1) * (u - 1) ^ 3 + c1 * (u - 1) ^ 2
end

local function burst(position, color, count, speed, size)
	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.Transparency = 1
	anchor.Size = Vector3.one
	anchor.CFrame = CFrame.new(position)
	anchor.Parent = workspace
	local e = Instance.new("ParticleEmitter")
	e.Enabled = false
	e.Color = ColorSequence.new(color)
	e.Size = NumberSequence.new(size or 0.5, 0)
	e.Lifetime = NumberRange.new(0.4, 0.8)
	e.Speed = NumberRange.new(speed * 0.6, speed)
	e.SpreadAngle = Vector2.new(60, 60)
	e.Acceleration = Vector3.new(0, -30, 0)
	e.Rotation = NumberRange.new(0, 360)
	e.LightEmission = 0.3
	e.Parent = anchor
	e:Emit(count)
	Debris:AddItem(anchor, 1.4)
end

local function sparkle(position, color)
	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.Transparency = 1
	anchor.Size = Vector3.one
	anchor.CFrame = CFrame.new(position)
	anchor.Parent = workspace
	local e = Instance.new("ParticleEmitter")
	e.Enabled = false
	e.Color = ColorSequence.new(Color3.new(1, 1, 1), color)
	e.LightEmission = 1
	e.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0)})
	e.Lifetime = NumberRange.new(0.35, 0.6)
	e.Speed = NumberRange.new(4, 9)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Drag = 6
	e.Parent = anchor
	e:Emit(28)
	Debris:AddItem(anchor, 1)
end

local playing = {} -- [model] = true while it animates

local function play(finder, find, info)
	local character = finder.Character
	local core = find and find.PrimaryPart
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not core or not root or playing[find] then return end
	playing[find] = true

	local color = typeof(info) == "table" and typeof(info.Color) == "Color3" and info.Color or Color3.fromRGB(255, 220, 120)
	local startCF = find:GetPivot()
	local world = GameConfig.GetWorldAt(startCF.Position)
	local _, zone = GameConfig.GetZoneAt(world, startCF.Position.Y)
	local dirtColor = zone and zone.Color or Color3.fromRGB(140, 104, 72)
	local sunk = find:GetAttribute("Sunk") or 0.5

	-- the finder stops for a moment and faces it
	local isMe = finder == player
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local oldSpeed, oldJump
	if isMe and humanoid then
		oldSpeed, oldJump = humanoid.WalkSpeed, humanoid.JumpHeight
		humanoid.WalkSpeed = 0
		humanoid.JumpHeight = 0
		local flat = Vector3.new(startCF.Position.X, root.Position.Y, startCF.Position.Z)
		if (flat - root.Position).Magnitude > 0.5 then
			root.CFrame = CFrame.lookAt(root.Position, flat)
		end
	end

	-- sort its parts: the object (and crumbs stuck to it) flies; the mound and glow stay
	local flying, ground, crumbs = {}, {}, {}
	for _, d in ipairs(find:GetDescendants()) do
		if d:IsA("BasePart") then
			if d.Name == "Mound" or d.Name == "Glow" then
				table.insert(ground, {Part = d, CF = d.CFrame, Transparency = d.Transparency})
			elseif d.Name == "Dirt" then
				table.insert(crumbs, {Part = d, Offset = startCF:ToObjectSpace(d.CFrame)})
			else
				table.insert(flying, {Part = d, Offset = startCF:ToObjectSpace(d.CFrame), Size = d.Size})
			end
		elseif d:IsA("ParticleEmitter") then
			d.Enabled = false
		elseif d:IsA("ProximityPrompt") then
			d.Enabled = false
		end
	end
	local light = core:FindFirstChildOfClass("PointLight")

	burst(startCF.Position, dirtColor, 30, 14, 0.55)
	local risenCF = startCF + Vector3.new(0, sunk + 1.2, 0)
	local start = os.clock()
	local fx = false
	local conn
	local function finish()
		conn:Disconnect()
		if find.Parent then find.Parent = nil end -- gone on this screen (the server removes it for real)
		if isMe and humanoid and humanoid.Parent then
			humanoid.WalkSpeed = oldSpeed
			humanoid.JumpHeight = oldJump
		end
		playing[find] = nil
	end

	conn = RunService.RenderStepped:Connect(function()
		local t = os.clock() - start
		if not root.Parent or not find.Parent then
			finish()
			return
		end
		local target = root.CFrame * CFrame.new(0, 0.6, -0.4)
		local cf, scale, fade
		if t < RISE_END then
			-- wiggles loose and pops up out of the soil
			local u = t / RISE_END
			local wiggle = math.sin(t * 70) * math.rad(5) * (1 - u)
			cf = startCF:Lerp(risenCF, easeOutBack(u)) * CFrame.Angles(wiggle, 0, wiggle * 0.7)
			scale, fade = 1, 0
		elseif t < FLY_END then
			-- an arc to the finder, shrinking and turning to face them
			local u = smooth((t - RISE_END) / (FLY_END - RISE_END))
			local from, to = risenCF.Position, target.Position
			local mid = from:Lerp(to, 0.5) + Vector3.new(0, 2.5, 0)
			local pos = from:Lerp(mid, u):Lerp(mid:Lerp(to, u), u)
			local facing = CFrame.lookAt(pos, pos + (root.Position - pos) * Vector3.new(1, 0, 1) + Vector3.new(0.001, 0, 0))
			cf = risenCF.Rotation:Lerp(facing.Rotation, u) + pos
			scale, fade = 1 - 0.7 * u, 0
		elseif t < DONE then
			-- dissolves into the finder's chest
			local u = (t - FLY_END) / (DONE - FLY_END)
			cf = target
			scale, fade = 0.3 * (1 - u) + 0.02, u
			if not fx then
				fx = true
				sparkle(target.Position, color)
			end
		else
			finish()
			return
		end

		-- move and shrink the object around its center
		for _, item in ipairs(flying) do
			local offset = item.Offset
			item.Part.Size = item.Size * scale
			item.Part.CFrame = cf * (offset.Rotation + offset.Position * scale)
			item.Part.LocalTransparencyModifier = fade
		end
		for _, item in ipairs(find:GetDescendants()) do
			if item:IsA("SurfaceGui") then item.Enabled = scale > 0.25 end
		end
		if light then light.Brightness = 1.4 * (1 - fade) end

		-- the crumbs fall off it, the mound and glow sink back into the ground
		for i, clump in ipairs(crumbs) do
			local fall = math.max(0, t - i * 0.02)
			local p = clump.Part
			local base = startCF * clump.Offset
			p.CFrame = CFrame.new(base.Position - Vector3.new(0, fall * fall * 40, 0)) * CFrame.Angles(fall * 9, fall * 7, 0)
			p.LocalTransparencyModifier = math.clamp(fall * 3, 0, 1)
		end
		local sink = smooth(t / FLY_END)
		for _, item in ipairs(ground) do
			item.Part.CFrame = item.CF - Vector3.new(0, sink * 1.2, 0)
			item.Part.LocalTransparencyModifier = sink
		end
	end)
end

pullRemote.OnClientEvent:Connect(function(finder, find, info)
	if typeof(finder) == "Instance" and finder:IsA("Player") and typeof(find) == "Instance" and find:IsA("Model") then
		task.spawn(play, finder, find, info)
	end
end)
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "FlyingTraffic", "LocalScript", [=[
-- FlyingTraffic (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Cartoony bubble cars, hover buses, delivery drones and ad blimps flying around the
-- city in traffic lanes (the vehicle designs live in ReplicatedStorage.VehicleModels).
-- Runs only on each player's screen, so it's smooth and doesn't load the server.

local RunService = game:GetService("RunService")

local folder = Instance.new("Folder")
folder.Name = "FlyingTraffic"
folder.Parent = workspace

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VehicleModels = require(ReplicatedStorage:WaitForChild("VehicleModels"))

local rng = Random.new()

-- Traffic lanes: circles around the map, placed between the rings of towers
-- Dir 1 = counter-clockwise, -1 = clockwise. Kind = which vehicle flies there.
local LANES = { -- World 1 is a compact island now: boulevard at 269, towers from 290 to 450
	{Radius = 269, Height = 26,  Speed = 40,  Count = 6, Dir = 1,  Kind = "drone"},  -- low over the ring boulevard
	{Radius = 269, Height = 42,  Speed = 70,  Count = 6, Dir = -1, Kind = "car"},
	{Radius = 269, Height = 60,  Speed = 55,  Count = 3, Dir = 1,  Kind = "bus"},
	{Radius = 312, Height = 250, Speed = 85,  Count = 6, Dir = 1,  Kind = "car"},    -- above the inner tower ring
	{Radius = 364, Height = 360, Speed = 70,  Count = 5, Dir = -1, Kind = "car"},    -- above the middle ring
	{Radius = 520, Height = 140, Speed = 95,  Count = 7, Dir = -1, Kind = "car"},    -- just past the island edge
	{Radius = 520, Height = 220, Speed = 50,  Count = 4, Dir = 1,  Kind = "drone"},
	{Radius = 300, Height = 600, Speed = 25,  Count = 2, Dir = -1, Kind = "blimp"},
	{Radius = 560, Height = 520, Speed = 22,  Count = 2, Dir = 1,  Kind = "blimp"},
}

---------------------------------------------------------------------
-- SPAWN VEHICLES ON THEIR LANES
---------------------------------------------------------------------
local vehicles = {}
for _, lane in ipairs(LANES) do
	for i = 1, lane.Count do
		local model = VehicleModels[lane.Kind](rng)
		model.Parent = folder
		table.insert(vehicles, {
			Model = model,
			Lane = lane,
			Angle = (i / lane.Count) * math.pi * 2 + rng:NextNumber(-0.2, 0.2),
			Speed = lane.Speed * rng:NextNumber(0.85, 1.15),
			Phase = rng:NextNumber(0, math.pi * 2),
			HeightOffset = rng:NextNumber(-4, 4),
		})
	end
end

---------------------------------------------------------------------
-- MOVE EVERYTHING SMOOTHLY EVERY FRAME
---------------------------------------------------------------------
RunService.Heartbeat:Connect(function(dt)
	local t = os.clock()
	for _, v in ipairs(vehicles) do
		local lane = v.Lane
		v.Angle += lane.Dir * (v.Speed / lane.Radius) * dt
		local a = v.Angle
		local big = lane.Kind == "blimp"
		local bob = math.sin(t * (big and 0.5 or 1.4) + v.Phase) * (big and 3 or 1.2)
		local position = Vector3.new(math.cos(a) * lane.Radius, lane.Height + v.HeightOffset + bob, math.sin(a) * lane.Radius)
		local forward = Vector3.new(-math.sin(a), 0, math.cos(a)) * lane.Dir
		-- lean into the curve and wobble a little, like a bouncy cartoon vehicle
		local wobble = math.sin(t * 2.1 + v.Phase) * (big and 0.01 or 0.06)
		local lean = CFrame.Angles(wobble, 0, lane.Dir * (big and 0.04 or 0.16) + wobble)
		v.Model:PivotTo(CFrame.lookAt(position, position + forward) * lean)
	end
end)
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "HUD", "LocalScript", [=[
-- HUD (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The always-on screen, in a big chunky style:
--   * TOP: three wide studded buttons (Shop, Museum, Worlds) with the world you're in under them
--   * LEFT: the Bag as a square item tile and Rebirth as a big icon (red badge when a rebirth is ready)
--   * TOP RIGHT CORNER: a small round Settings button (music and sound live in Settings)
--   * BOTTOM LEFT: big gem and money numbers (money in full: 15,760,347,332$), income under them
--   * BOTTOM CENTER: a hotbar of square slots (name on top, key number in the corner, 3D icon)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local UIBus = require(ReplicatedStorage:WaitForChild("UIBus"))
local C = UIKit.Colors
local rgb = Color3.fromRGB

local player = Players.LocalPlayer
local gui = UIKit.screen(player, "HUD", 1)
local remotes = ReplicatedStorage:WaitForChild("Remotes")

-- our own hotbar replaces the default one
task.spawn(function()
	for _ = 1, 20 do
		if pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false) end) then break end
		task.wait(0.5)
	end
end)

local function click()
	require(ReplicatedStorage:WaitForChild("Audio")).sfx("Click")
end

-- a red alert badge (a "!" or a number) on the top-right corner of something
local function alertBadge(parent, size, position)
	local alert = UIKit.panel(parent, {Size = UDim2.fromOffset(size, size), Position = position, AnchorPoint = Vector2.new(0.5, 0.5),
		Color = rgb(236, 48, 64), Radius = 999, Stroke = 3, StrokeColor = C.Outline, ShadeAmount = 0.15})
	alert.Name = "Alert"
	alert.ZIndex = 5
	alert.Visible = false
	local text = UIKit.label(alert, "!", {Size = UDim2.fromScale(0.74, 0.74), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
		Stroke = 2.5, MaxText = 26})
	text.ZIndex = 6
	return function(value)
		alert.Visible = value ~= nil and value ~= ""
		if value then text.Text = value end
	end
end

---------------------------------------------------------------------
-- TOP: three big studded buttons, and the world you're in under them
---------------------------------------------------------------------
local TOP_W, TOP_H, TOP_GAP = 180, 64, 12 -- 180 wide keeps clear of the world tips at the top right
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.BackgroundTransparency = 1
topBar.Size = UDim2.fromOffset(TOP_W * 3 + TOP_GAP * 2, TOP_H + 36)
topBar.Position = UDim2.new(0.5, 0, 0, 8)
topBar.AnchorPoint = Vector2.new(0.5, 0)
topBar.Parent = gui

local function topButton(index, text, color, onClick)
	local b = UIKit.button(topBar, text, {Size = UDim2.fromOffset(TOP_W, TOP_H), Position = UDim2.fromOffset((index - 1) * (TOP_W + TOP_GAP), 0),
		Color = color, Radius = 10, MaxText = 40})
	b.Name = text
	b.MouseButton1Click:Connect(onClick)
	return b, alertBadge(b, 30, UDim2.new(1, -4, 0, 4))
end

local _, shopAlert = topButton(1, "Shop", rgb(48, 170, 255), function() UIBus.Fire("Shop") end)
topButton(2, "Museum", rgb(52, 200, 70), function()
	local goHome = remotes:FindFirstChild("GoHome")
	if goHome then goHome:FireServer() end
end)
topButton(3, "Worlds", rgb(236, 56, 72), function() UIBus.Fire("Teleport") end)

local worldText = UIKit.label(topBar, "", {Size = UDim2.new(1, 40, 0, 28), Position = UDim2.new(0.5, 0, 0, TOP_H + 6), AnchorPoint = Vector2.new(0.5, 0),
	Color = C.White, Stroke = 3, MaxText = 26})

---------------------------------------------------------------------
-- LEFT: the Bag as a square item tile (backpack, name across it, key square)
-- and Rebirth as a big 3D icon with a pink label under it
---------------------------------------------------------------------
local function bounce(b)
	local scale = Instance.new("UIScale")
	scale.Parent = b
	local function to(v, t)
		TweenService:Create(scale, TweenInfo.new(t or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = v}):Play()
	end
	b.MouseEnter:Connect(function() to(1.08) end)
	b.MouseLeave:Connect(function() to(1) end)
	b.MouseButton1Down:Connect(function() to(0.9, 0.06) end)
	b.MouseButton1Up:Connect(function() to(1.08) end)
end

local menu = Instance.new("Frame")
menu.BackgroundTransparency = 1
menu.Size = UDim2.fromOffset(116, 240)
menu.Position = UDim2.new(0, 12, 0, 74)
menu.Parent = gui

local bagButton = UIKit.button(menu, "", {Size = UDim2.fromOffset(98, 98), Position = UDim2.new(0.5, 0, 0, 0), AnchorPoint = Vector2.new(0.5, 0),
	Color = rgb(56, 150, 226), Radius = 12, Pattern = false})
bagButton.Name = "Bag"
UIKit.icon(bagButton, "Bag", {Size = UDim2.fromScale(0.92, 0.92), Position = UDim2.fromScale(0.5, 0.44), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 2})
local bagLabel = UIKit.label(bagButton, "Bag", {Size = UDim2.new(1, -6, 0, 30), Position = UDim2.new(0.5, 0, 0.5, 6), AnchorPoint = Vector2.new(0.5, 0.5),
	Color = rgb(190, 236, 255), Stroke = 3.5, MaxText = 28})
bagLabel.ZIndex = 4
local bagKey = UIKit.panel(bagButton, {Size = UDim2.fromOffset(24, 24), Position = UDim2.new(0, 6, 1, -6), AnchorPoint = Vector2.new(0, 1),
	Color = rgb(30, 70, 120), Radius = 5, Stroke = 2, StrokeColor = C.White, Shade = false})
bagKey.ZIndex = 4
UIKit.label(bagKey, "B", {Size = UDim2.fromScale(0.78, 0.78), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2, MaxText = 16}).ZIndex = 5
bagButton.MouseButton1Click:Connect(function() UIBus.Fire("Inventory") end)

local rebirthButton = Instance.new("TextButton")
rebirthButton.Name = "Rebirth"
rebirthButton.Text = ""
rebirthButton.BackgroundTransparency = 1
rebirthButton.Size = UDim2.fromOffset(116, 120)
rebirthButton.Position = UDim2.new(0.5, 0, 0, 112)
rebirthButton.AnchorPoint = Vector2.new(0.5, 0)
rebirthButton.Parent = menu
UIKit.icon(rebirthButton, "Rebirth", {Size = UDim2.fromOffset(104, 104), Position = UDim2.new(0.5, 0, 0, -8), AnchorPoint = Vector2.new(0.5, 0)})
UIKit.label(rebirthButton, "Rebirth", {Size = UDim2.new(1, 8, 0, 32), Position = UDim2.new(0.5, 0, 0, 86), AnchorPoint = Vector2.new(0.5, 0),
	Color = rgb(255, 206, 232), Stroke = 4, MaxText = 30}).ZIndex = 2
local rebirthAlert = alertBadge(rebirthButton, 34, UDim2.new(0.5, 40, 0, 10))
bounce(rebirthButton)
rebirthButton.MouseButton1Click:Connect(function()
	click()
	UIBus.Fire("Rebirth")
end)

---------------------------------------------------------------------
-- TOP RIGHT CORNER: a small dark round Settings button up in Roblox's top bar row
-- (music and sound effects are in the Settings window)
---------------------------------------------------------------------
local corner = UIKit.screen(player, "HUDCorner", 1)
corner.IgnoreGuiInset = true
local settingsButton = Instance.new("TextButton")
settingsButton.Name = "Settings"
settingsButton.Text = ""
settingsButton.AutoButtonColor = false
settingsButton.BackgroundColor3 = Color3.new(0, 0, 0)
settingsButton.BackgroundTransparency = 0.3
settingsButton.Size = UDim2.fromOffset(44, 44)
settingsButton.Position = UDim2.new(1, -14, 0, 7)
settingsButton.AnchorPoint = Vector2.new(1, 0)
settingsButton.Parent = corner
UIKit.corner(settingsButton, 22)
UIKit.icon(settingsButton, "Settings", {Size = UDim2.fromOffset(38, 38), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5)})
bounce(settingsButton)
settingsButton.MouseButton1Click:Connect(function()
	click()
	UIBus.Fire("Settings")
end)

---------------------------------------------------------------------
-- BOTTOM LEFT: gems and money as big outlined numbers next to their 3D icons (money in
-- full with commas, like 15,760,347,332$), income under them
---------------------------------------------------------------------
local wallet = Instance.new("Frame")
wallet.BackgroundTransparency = 1
wallet.Size = UDim2.fromOffset(460, 160)
wallet.Position = UDim2.new(0, 12, 1, -8)
wallet.AnchorPoint = Vector2.new(0, 1)
wallet.Parent = gui

local function counter(y, height, iconSize, icon, color, maxText)
	local row = Instance.new("Frame")
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1, 0, 0, height)
	row.Position = UDim2.fromOffset(0, y)
	row.Parent = wallet
	if icon then
		UIKit.icon(row, icon, {Size = UDim2.fromOffset(iconSize, iconSize), Position = UDim2.new(0, iconSize / 2, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5)})
	end
	local indent = icon and iconSize + 6 or 4
	local text = UIKit.label(row, "", {Size = UDim2.new(1, -indent, 1, 0), Position = UDim2.new(0, indent, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
		Align = "Left", Color = color, Stroke = 4.5, MaxText = maxText})
	return row, text
end
local _, gemText = counter(0, 50, 66, "Gem", rgb(230, 60, 255), 46)
local moneyRow, moneyText = counter(54, 66, 86, "Cash", rgb(60, 255, 50), 58)
local _, incomeText = counter(124, 32, 0, nil, rgb(255, 224, 90), 28)

-- 15760347332 -> "15,760,347,332"
local function commas(n)
	local s = tostring(math.floor(n))
	local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	return (out:gsub("^,", ""))
end

local shownMoney = 0
local moneyScale = Instance.new("UIScale")
moneyScale.Parent = moneyRow
local function refreshMoney()
	local money = player:GetAttribute("Money") or 0
	if money > shownMoney + 0.5 then
		-- little bounce when money goes up
		moneyScale.Scale = 1.08
		TweenService:Create(moneyScale, TweenInfo.new(0.25, Enum.EasingStyle.Back), {Scale = 1}):Play()
	end
	shownMoney = money
	-- in full up to the trillions; past that the short form (the number would be too long)
	moneyText.Text = money < 1e15 and (commas(money) .. "$") or ArtifactData.FormatMoney(money)
end
local function refreshIncome()
	incomeText.Text = "Income: +" .. ArtifactData.FormatMoney(player:GetAttribute("Income") or 0) .. "/s"
end
local function refreshGems()
	gemText.Text = commas(player:GetAttribute("Gems") or 0)
end
local function refreshWorld()
	local world = GameConfig.GetWorld(player:GetAttribute("CurrentWorld") or 1)
	local rebirths = player:GetAttribute("Rebirths") or 0
	worldText.Text = (world and world.Name or "") .. (rebirths > 0 and ("  -  Rebirth " .. rebirths) or "")
end
player:GetAttributeChangedSignal("Money"):Connect(refreshMoney)
player:GetAttributeChangedSignal("Income"):Connect(refreshIncome)
player:GetAttributeChangedSignal("Gems"):Connect(refreshGems)
player:GetAttributeChangedSignal("CurrentWorld"):Connect(refreshWorld)
player:GetAttributeChangedSignal("Rebirths"):Connect(refreshWorld)
refreshMoney()
refreshIncome()
refreshGems()
refreshWorld()

---------------------------------------------------------------------
-- ALERTS: a pickaxe you can afford, a rebirth that's ready, memes waiting in your bag
---------------------------------------------------------------------
local function refreshAlerts()
	local money = player:GetAttribute("Money") or 0
	rebirthAlert(money >= GameConfig.RebirthCost(player:GetAttribute("Rebirths") or 0) and "!" or nil)
	-- a pickaxe in this world you don't own yet but can afford
	local world = GameConfig.GetWorld(player:GetAttribute("CurrentWorld") or 1)
	local owned = {}
	for _, id in ipairs(string.split(player:GetAttribute("OwnedShovels") or "", ",")) do owned[id] = true end
	local canBuy = false
	for _, def in ipairs(world and world.Shovels or {}) do
		if not owned[def.Id] and def.Price > 0 and money >= def.Price then
			canBuy = true
			break
		end
	end
	shopAlert(canBuy and "!" or nil)
end
for _, attribute in ipairs({"Money", "Rebirths", "OwnedShovels", "CurrentWorld"}) do
	player:GetAttributeChangedSignal(attribute):Connect(refreshAlerts)
end
refreshAlerts()

-- the bag bounces when a meme arrives in it
task.spawn(function()
	local changed = remotes:WaitForChild("InventoryChanged", 30)
	if changed then
		changed.OnClientEvent:Connect(function()
			UIKit.pop(bagButton, 1.3)
		end)
	end
end)

---------------------------------------------------------------------
-- HOTBAR (bottom center): square slots with the tool's name on top, its key number in the
-- corner and a 3D icon; the equipped one gets a thick golden ring
---------------------------------------------------------------------
local SLOT = 96
local hotbar = Instance.new("Frame")
hotbar.BackgroundTransparency = 1
hotbar.Size = UDim2.fromOffset(5 * (SLOT + 10), SLOT + 10)
hotbar.Position = UDim2.new(0.5, 0, 1, -10)
hotbar.AnchorPoint = Vector2.new(0.5, 1)
hotbar.Parent = gui
local hotbarLayout = Instance.new("UIListLayout")
hotbarLayout.FillDirection = Enum.FillDirection.Horizontal
hotbarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
hotbarLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
hotbarLayout.Padding = UDim.new(0, 10)
hotbarLayout.SortOrder = Enum.SortOrder.LayoutOrder
hotbarLayout.Parent = hotbar

local KEYS = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five}
local slots = {} -- {Tool, Button, Ring}

local function toggle(tool)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	if tool.Parent == character then
		humanoid:UnequipTools()
	else
		humanoid:EquipTool(tool)
	end
end

local function styleSlot(slot)
	slot.Ring.Visible = slot.Tool.Parent == player.Character
end

local function rebuild()
	local tools = {}
	for _, container in ipairs({player:FindFirstChild("Backpack"), player.Character}) do
		if container then
			for _, item in ipairs(container:GetChildren()) do
				if item:IsA("Tool") then table.insert(tools, item) end
			end
		end
	end
	table.sort(tools, function(a, b) return a.Name < b.Name end)
	-- same tools as before (e.g. one just got equipped)? only restyle, don't redraw icons
	local same = #tools == #slots
	for i, tool in ipairs(tools) do
		if not slots[i] or slots[i].Tool ~= tool then same = false end
	end
	if same then
		for _, slot in ipairs(slots) do styleSlot(slot) end
		return
	end
	for _, slot in ipairs(slots) do
		slot.Button:Destroy()
	end
	slots = {}
	for i, tool in ipairs(tools) do
		if i > #KEYS then break end
		local def = GameConfig.GetShovel(tool:GetAttribute("ShovelId"))
		local color = def and rgb(150, 90, 240) or rgb(48, 170, 255)
		local button = UIKit.button(hotbar, "", {Size = UDim2.fromOffset(SLOT, SLOT), Color = color, Radius = 10, Pattern = false})
		button.LayoutOrder = i
		if def then
			UIKit.shovelIcon(button, def, {Size = UDim2.fromScale(0.86, 0.86), Position = UDim2.fromScale(0.5, 0.56), AnchorPoint = Vector2.new(0.5, 0.5)})
		end
		local name = UIKit.label(button, def and def.Name or tool.Name, {Size = UDim2.new(1, -8, 0, 22), Position = UDim2.new(0.5, 0, 0, 3), AnchorPoint = Vector2.new(0.5, 0),
			Stroke = 2.5, MaxText = 18})
		name.ZIndex = 4
		-- the key number in a little square in the bottom-left corner
		local key = UIKit.panel(button, {Size = UDim2.fromOffset(22, 22), Position = UDim2.new(0, 5, 1, -6), AnchorPoint = Vector2.new(0, 1),
			Color = UIKit.shadeColor(color, 0.45), Radius = 5, Stroke = 2, StrokeColor = C.White, Shade = false})
		key.ZIndex = 4
		UIKit.label(key, tostring(i), {Size = UDim2.fromScale(0.8, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
			Stroke = 2, MaxText = 16}).ZIndex = 5
		-- golden ring around the slot while the tool is in your hand
		local ring = Instance.new("Frame")
		ring.BackgroundTransparency = 1
		ring.Size = UDim2.new(1, 10, 1, 10)
		ring.Position = UDim2.fromScale(0.5, 0.5)
		ring.AnchorPoint = Vector2.new(0.5, 0.5)
		ring.Parent = button
		UIKit.corner(ring, 14)
		UIKit.outline(ring, 4, C.Sun)
		local slot = {Tool = tool, Button = button, Ring = ring}
		button.MouseButton1Click:Connect(function() toggle(tool) end)
		table.insert(slots, slot)
		styleSlot(slot)
	end
end

local pending = false
local function queueRebuild()
	if pending then return end
	pending = true
	task.defer(function()
		pending = false
		rebuild()
	end)
end

local function watch(container)
	local function onChange(child)
		if child:IsA("Tool") then queueRebuild() end
	end
	container.ChildAdded:Connect(onChange)
	container.ChildRemoved:Connect(onChange)
end

local function onCharacter(character)
	watch(character)
	watch(player:WaitForChild("Backpack"))
	queueRebuild()
end
player.CharacterAdded:Connect(onCharacter)
if player.Character then onCharacter(player.Character) end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	for i, key in ipairs(KEYS) do
		if input.KeyCode == key and slots[i] then
			toggle(slots[i].Tool)
		end
	end
end)

-- keep the equipped highlight in sync (equipping moves the tool between Backpack and Character)
task.spawn(function()
	while true do
		task.wait(0.25)
		for _, slot in ipairs(slots) do
			if slot.Button.Parent then styleSlot(slot) end
		end
	end
end)
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "InventoryClient", "LocalScript", [=[
-- InventoryClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The Inventory window: every meme you've picked up, as cards showing its real 3D model,
-- sorted from rarest to most common, with how many you have and how much each one earns.
-- Click a card to hold that meme in your hand (MemeToolManager); click it again to put it away.
-- Open it with the BAG button on the HUD or the B key.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local getInventory = remotes:WaitForChild("GetInventory")
local inventoryChangedRemote = remotes:WaitForChild("InventoryChanged")
local equipRemote = remotes:WaitForChild("EquipMeme")

local player = Players.LocalPlayer
local gui = UIKit.screen(player, "InventoryGui", 3)

---------------------------------------------------------------------
-- WINDOW
---------------------------------------------------------------------
local window, content = UIKit.window(gui, "INVENTORY", UDim2.fromOffset(740, 560), C.Sun, "Bag")
local countLabel = UIKit.label(content, "", {Size = UDim2.new(1, -260, 0, 26), Position = UDim2.fromOffset(4, 4), Align = "Left", Color = C.Violet, Stroke = 0, MaxText = 22})
UIKit.label(content, "Click a meme to hold it", {Size = UDim2.new(1, -260, 0, 14), Position = UDim2.fromOffset(4, 28), Align = "Left", Color = C.Grey, Stroke = 0,
	Font = UIKit.BodyFont, MaxText = 13})
-- fills every empty display slot in your museum with your best-earning memes
local placeAllButton = UIKit.button(content, "PLACE ALL IN MUSEUM", {Icon = "Museum", Size = UDim2.fromOffset(270, 40), Position = UDim2.new(1, -4, 0, 0), AnchorPoint = Vector2.new(1, 0), Color = C.Violet, Radius = 19, MaxText = 16})
placeAllButton.MouseButton1Click:Connect(function()
	remotes:WaitForChild("PlaceAll"):FireServer()
end)

local gridHolder = Instance.new("ScrollingFrame")
gridHolder.BackgroundTransparency = 1
gridHolder.BorderSizePixel = 0
gridHolder.Size = UDim2.new(1, 0, 1, -44)
gridHolder.Position = UDim2.fromOffset(0, 42)
gridHolder.ScrollBarThickness = 8
gridHolder.ScrollBarImageColor3 = C.Lilac
gridHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
gridHolder.CanvasSize = UDim2.new()
gridHolder.Parent = content
local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.fromOffset(150, 186)
grid.CellPadding = UDim2.fromOffset(12, 12)
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
grid.Parent = gridHolder
local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 8)
pad.PaddingBottom = UDim.new(0, 8)
pad.Parent = gridHolder

local emptyLabel = UIKit.label(content, "Nothing here yet... go dig up some memes!", {
	Size = UDim2.new(0.9, 0, 0, 30), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Grey, Stroke = 0,
})

-- rainbow borders spin slowly
local RAINBOW = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 80)), ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 200, 60)),
	ColorSequenceKeypoint.new(0.4, Color3.fromRGB(90, 230, 110)), ColorSequenceKeypoint.new(0.6, Color3.fromRGB(70, 170, 255)),
	ColorSequenceKeypoint.new(0.8, Color3.fromRGB(180, 90, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 80)),
})
local rainbows = {}
game:GetService("RunService").RenderStepped:Connect(function()
	if not window.Visible then return end
	local r = (os.clock() * 90) % 360
	for _, gradient in ipairs(rainbows) do gradient.Rotation = r end
end)

local function refresh()
	local ok, list = pcall(function() return getInventory:InvokeServer() end)
	if not ok or type(list) ~= "table" then return end
	for _, child in ipairs(gridHolder:GetChildren()) do
		if child:IsA("GuiObject") then child:Destroy() end
	end
	rainbows = {}
	-- rarest first, then by name
	local entries, total = {}, 0
	for _, item in ipairs(list) do
		local artifact = ArtifactData.GetArtifact(item.Id)
		if artifact then
			table.insert(entries, {Artifact = artifact, Count = item.Count})
			total += item.Count
		end
	end
	table.sort(entries, function(a, b)
		local ra, rb = ArtifactData.GetRarityIndex(a.Artifact.Rarity), ArtifactData.GetRarityIndex(b.Artifact.Rarity)
		if ra ~= rb then return ra > rb end
		return a.Artifact.Name < b.Artifact.Name
	end)
	countLabel.Text = total .. " memes  •  " .. #entries .. " different"
	emptyLabel.Visible = #entries == 0

	for i, entry in ipairs(entries) do
		local artifact = entry.Artifact
		local rarity = ArtifactData.GetRarity(artifact.Rarity)
		-- the card's border shows the rarity (secret rarities get an animated rainbow border)
		local card = UIKit.panel(gridHolder, {Size = UDim2.fromOffset(150, 186), Color = C.White, Radius = 20, Stroke = 4, StrokeColor = rarity.Color, ShadeAmount = 0.06})
		card.LayoutOrder = i
		if ArtifactData.IsSecret(artifact.Rarity) then
			local border = card:FindFirstChildOfClass("UIStroke")
			border.Color = Color3.new(1, 1, 1)
			local rainbow = Instance.new("UIGradient")
			rainbow.Color = RAINBOW
			rainbow.Parent = border
			table.insert(rainbows, rainbow)
		end
		UIKit.artifactIcon(card, artifact, {Size = UDim2.fromOffset(96, 96), Position = UDim2.new(0.5, 0, 0, 10), AnchorPoint = Vector2.new(0.5, 0)})
		if entry.Count > 1 then
			local countTag = UIKit.panel(card, {Size = UDim2.fromOffset(44, 28), Position = UDim2.fromOffset(8, 8), Color = C.Violet, Radius = 14, Stroke = 2})
			UIKit.label(countTag, "x" .. entry.Count, {Size = UDim2.fromScale(0.8, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2})
		end
		UIKit.label(card, artifact.Name, {Size = UDim2.new(1, -14, 0, 32), Position = UDim2.new(0.5, 0, 0, 110), AnchorPoint = Vector2.new(0.5, 0), Color = C.Ink, Stroke = 0, MaxText = 16})
		local rarityTag = UIKit.panel(card, {Size = UDim2.new(1, -28, 0, 20), Position = UDim2.new(0.5, 0, 0, 144), AnchorPoint = Vector2.new(0.5, 0), Color = rarity.Color, Radius = 10, Stroke = 2})
		UIKit.label(rarityTag, string.upper(artifact.Rarity), {Size = UDim2.fromScale(0.9, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2, StrokeColor = C.Ink, MaxText = 14})
		-- click: hold it in your hand (or put it away if you already are)
		local holding = player:GetAttribute("HeldMeme") == artifact.Id
		if holding then
			local tag = UIKit.panel(card, {Size = UDim2.fromOffset(78, 24), Position = UDim2.new(0.5, 0, 0, 84), AnchorPoint = Vector2.new(0.5, 0),
				Color = C.Mint, Radius = 12, Stroke = 2})
			UIKit.label(tag, "IN HAND", {Size = UDim2.fromScale(0.85, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2})
			card:FindFirstChildOfClass("UIStroke").Thickness = 6
		end
		local hit = Instance.new("TextButton")
		hit.Name = "Hold"
		hit.Text = ""
		hit.BackgroundTransparency = 1
		hit.Size = UDim2.fromScale(1, 1)
		hit.ZIndex = 20
		hit.Parent = card
		hit.MouseButton1Click:Connect(function()
			equipRemote:FireServer(artifact.Id)
		end)
		UIKit.label(card, ArtifactData.FormatMoney(ArtifactData.GetIncome(artifact)) .. "/s", {Size = UDim2.new(1, -14, 0, 16), Position = UDim2.new(0.5, 0, 1, -20), AnchorPoint = Vector2.new(0.5, 0), Color = C.Money, Stroke = 0, MaxText = 15})
	end
end

local function toggle()
	if window.Visible then
		window.Visible = false
	else
		refresh()
		UIKit.open(window)
	end
end

local UIBus = require(ReplicatedStorage:WaitForChild("UIBus"))
UIBus.On("Inventory", toggle) -- the BAG button on the HUD
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.B then
		toggle()
	end
end)
inventoryChangedRemote.OnClientEvent:Connect(function()
	if window.Visible then refresh() end
end)
player:GetAttributeChangedSignal("HeldMeme"):Connect(function()
	if window.Visible then refresh() end
end)
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "MuseumClient", "LocalScript", [=[
-- MuseumClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The museum side of the UI (World 1 only):
--   * the real artifact (painting, statue, coin, tablet or crystal) under a glass case on
--     every pedestal that has a meme on it (in every museum, so visitors see your collection)
--   * the Display window: pick a meme from your inventory to put on a slot, or take it back
--   * the Alien Art Dealer window: sell memes for cash
--   * small up/down arrows at the top center while you're inside a museum, to change floors
--     (the up arrow also buys the next floor in your own museum)
-- Slot prompts only show up in your own museum.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local rgb = Color3.fromRGB
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local getInventory = remotes:WaitForChild("GetInventory")
local inventoryChangedRemote = remotes:WaitForChild("InventoryChanged")
local openSlotRemote = remotes:WaitForChild("OpenSlotMenu")
local placeRemote = remotes:WaitForChild("PlaceInSlot")
local takeRemote = remotes:WaitForChild("TakeFromSlot")
local openDealerRemote = remotes:WaitForChild("OpenDealer")
local sellRemote = remotes:WaitForChild("SellArtifacts")
local floorRemote = remotes:WaitForChild("ChangeFloor")

local player = Players.LocalPlayer
local museumsFolder = workspace:WaitForChild("Museums")

---------------------------------------------------------------------
-- DISPLAYS: the real artifact (painting, statue, coin, tablet or crystal, see
-- ArtifactModels) standing still on its pedestal under a glass case
---------------------------------------------------------------------
local ArtifactModels = require(ReplicatedStorage:WaitForChild("ArtifactModels"))
local cards = {} -- [slot model] = the display model

local function removeCard(slot)
	local display = cards[slot]
	if display then
		display:Destroy()
		cards[slot] = nil
	end
end

local CASE = Vector3.new(5, 6, 5) -- inside size of the glass case

local function casePart(parent, name, size, cf, color, material, transparency)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material
	p.Transparency = transparency or 0
	p.Parent = parent
	return p
end

-- a glass box with a dark metal frame and a thin glowing line at the base
local function glassCase(parent, baseCF, color)
	local glass = Color3.fromRGB(200, 235, 255)
	local frame = Color3.fromRGB(40, 38, 64)
	local w, h = CASE.X, CASE.Y
	casePart(parent, "CaseGlass", Vector3.new(w, h, w), baseCF * CFrame.new(0, h / 2, 0), glass, Enum.Material.Glass, 0.82).Reflectance = 0.25
	casePart(parent, "CaseLid", Vector3.new(w + 0.3, 0.3, w + 0.3), baseCF * CFrame.new(0, h + 0.15, 0), frame, Enum.Material.Metal)
	casePart(parent, "CaseBase", Vector3.new(w + 0.3, 0.3, w + 0.3), baseCF * CFrame.new(0, 0.15, 0), frame, Enum.Material.Metal)
	casePart(parent, "CaseGlow", Vector3.new(w + 0.34, 0.08, w + 0.34), baseCF * CFrame.new(0, 0.32, 0), color, Enum.Material.Neon)
	for _, sx in ipairs({-1, 1}) do
		for _, sz in ipairs({-1, 1}) do
			casePart(parent, "CaseEdge", Vector3.new(0.18, h, 0.18), baseCF * CFrame.new(sx * w / 2, h / 2, sz * w / 2), frame, Enum.Material.Metal)
		end
	end
end

local function updateCard(slot)
	removeCard(slot)
	local artifact = ArtifactData.GetArtifact(slot:GetAttribute("ArtifactId") or "")
	local spot = slot:FindFirstChild("DisplaySpot")
	local cap = slot:FindFirstChild("Cap")
	if not artifact or not spot then return end
	local rarity = ArtifactData.GetRarity(artifact.Rarity)

	local display = Instance.new("Model")
	display.Name = "Display"
	-- the pedestal's top, facing into the room like the slot does
	local topY = cap and (cap.Position.Y + cap.Size.X / 2) or (spot.Position.Y - 1.8)
	local baseCF = CFrame.new(spot.Position.X, topY, spot.Position.Z) * spot.CFrame.Rotation
	glassCase(display, baseCF, rarity.Color)

	local object = ArtifactModels.build(artifact)
	-- shrink big objects so they fit inside the case
	local fit = math.min(1, (CASE.X - 0.8) / (object:GetAttribute("Width") or 4), (CASE.Y - 0.8) / ((object:GetAttribute("HalfHeight") or 2) * 2))
	if fit < 1 then object:ScaleTo(fit) end
	local half = (object:GetAttribute("HalfHeight") or 2) * fit
	object:PivotTo(baseCF * CFrame.new(0, 0.35 + half, 0))
	-- only the physical artifact is shown (its meme is carved/printed on it); the name tag
	-- floats above the glass case
	local info = spot:FindFirstChild("InfoGui")
	if info and info:IsA("BillboardGui") then info.StudsOffset = Vector3.new(0, 8.4, 0) end
	object.Parent = display
	-- a soft spotlight in the rarity's color, and sparkles for the fancy ones
	local light = Instance.new("PointLight")
	light.Color = rarity.Color
	light.Range = 10
	light.Brightness = 0.7
	light.Parent = object.PrimaryPart
	if ArtifactData.GetRarityIndex(artifact.Rarity) >= 5 then
		local sparkles = Instance.new("ParticleEmitter")
		sparkles.Rate = 3
		sparkles.Lifetime = NumberRange.new(0.8, 1.4)
		sparkles.Speed = NumberRange.new(0.3, 0.8)
		sparkles.SpreadAngle = Vector2.new(180, 180)
		sparkles.Size = NumberSequence.new(0.2, 0)
		sparkles.LightEmission = 0.8
		sparkles.Color = ColorSequence.new(rarity.Color)
		sparkles.Parent = object.PrimaryPart
	end
	display.Parent = slot
	cards[slot] = display
end

local function watchSlot(slot, owned)
	slot:GetAttributeChangedSignal("ArtifactId"):Connect(function()
		updateCard(slot)
	end)
	slot.AncestryChanged:Connect(function()
		if not slot:IsDescendantOf(workspace) then removeCard(slot) end
	end)
	updateCard(slot)
	-- only the owner sees the slot prompts
	local function checkPrompt(child)
		if child:IsA("ProximityPrompt") and child.Name == "SlotPrompt" then
			child.Enabled = owned
		end
	end
	slot.DescendantAdded:Connect(checkPrompt)
	for _, d in ipairs(slot:GetDescendants()) do checkPrompt(d) end
end

local function watchMuseum(museum)
	local slots = museum:WaitForChild("Slots", 10)
	if not slots then return end
	local owned = museum:GetAttribute("OwnerUserId") == player.UserId
	for _, slot in ipairs(slots:GetChildren()) do
		watchSlot(slot, owned)
	end
end

museumsFolder.ChildAdded:Connect(watchMuseum)
for _, museum in ipairs(museumsFolder:GetChildren()) do
	task.spawn(watchMuseum, museum)
end


---------------------------------------------------------------------
-- SHARED: an inventory grid with a button on every meme
---------------------------------------------------------------------
local function fetchInventory()
	local ok, list = pcall(function() return getInventory:InvokeServer() end)
	if not ok or type(list) ~= "table" then return {} end
	local entries = {}
	for _, item in ipairs(list) do
		local artifact = ArtifactData.GetArtifact(item.Id)
		if artifact then
			table.insert(entries, {Artifact = artifact, Count = item.Count})
		end
	end
	-- best earners first
	table.sort(entries, function(a, b)
		local ia, ib = ArtifactData.GetIncome(a.Artifact), ArtifactData.GetIncome(b.Artifact)
		if ia ~= ib then return ia > ib end
		return a.Artifact.Name < b.Artifact.Name
	end)
	return entries
end

local function makeGrid(parent, top)
	local holder = Instance.new("ScrollingFrame")
	holder.BackgroundTransparency = 1
	holder.BorderSizePixel = 0
	holder.Size = UDim2.new(1, 0, 1, -top)
	holder.Position = UDim2.fromOffset(0, top)
	holder.ScrollBarThickness = 8
	holder.ScrollBarImageColor3 = C.Lilac
	holder.AutomaticCanvasSize = Enum.AutomaticSize.Y
	holder.CanvasSize = UDim2.new()
	holder.Parent = parent
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.fromOffset(150, 214)
	grid.CellPadding = UDim2.fromOffset(12, 12)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
	grid.Parent = holder
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.Parent = holder
	return holder
end

local function clear(holder)
	for _, child in ipairs(holder:GetChildren()) do
		if child:IsA("GuiObject") then child:Destroy() end
	end
end

-- one meme card; returns the card frame
local function memeCard(holder, entry, order, valueText)
	local artifact = entry.Artifact
	local rarity = ArtifactData.GetRarity(artifact.Rarity)
	local card = UIKit.panel(holder, {Size = UDim2.fromOffset(150, 214), Color = C.White, Radius = 20, ShadeAmount = 0.06})
	card.LayoutOrder = order
	UIKit.artifactIcon(card, artifact, {Size = UDim2.fromOffset(84, 84), Position = UDim2.new(0.5, 0, 0, 8), AnchorPoint = Vector2.new(0.5, 0)})
	if entry.Count and entry.Count > 1 then
		local tag = UIKit.panel(card, {Size = UDim2.fromOffset(44, 26), Position = UDim2.fromOffset(8, 8), Color = C.Violet, Radius = 13, Stroke = 2})
		UIKit.label(tag, "x" .. entry.Count, {Size = UDim2.fromScale(0.8, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2})
	end
	UIKit.label(card, artifact.Name, {Size = UDim2.new(1, -14, 0, 30), Position = UDim2.new(0.5, 0, 0, 96), AnchorPoint = Vector2.new(0.5, 0), Color = C.Ink, Stroke = 0, MaxText = 16})
	local tag = UIKit.panel(card, {Size = UDim2.new(1, -28, 0, 20), Position = UDim2.new(0.5, 0, 0, 128), AnchorPoint = Vector2.new(0.5, 0), Color = rarity.Color, Radius = 10, Stroke = 2})
	UIKit.label(tag, string.upper(artifact.Rarity), {Size = UDim2.fromScale(0.9, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2, StrokeColor = C.Ink, MaxText = 14})
	UIKit.label(card, valueText, {Size = UDim2.new(1, -14, 0, 16), Position = UDim2.new(0.5, 0, 0, 152), AnchorPoint = Vector2.new(0.5, 0), Color = C.Money, Stroke = 0, MaxText = 15})
	return card
end

local gui = UIKit.screen(player, "MuseumGui", 3)

---------------------------------------------------------------------
-- DISPLAY WINDOW (opened from a slot)
---------------------------------------------------------------------
local displayWindow, displayContent = UIKit.window(gui, "DISPLAY", UDim2.fromOffset(740, 580), C.Violet, "Museum")
local currentPanel = UIKit.panel(displayContent, {Size = UDim2.new(1, 0, 0, 96), Color = C.PanelTint, Radius = 20, StrokeColor = C.Lilac})
local currentTitle = UIKit.label(currentPanel, "", {Size = UDim2.new(1, -310, 0, 30), Position = UDim2.fromOffset(104, 16), Align = "Left", Color = C.Ink, Stroke = 0, MaxText = 24})
local currentSub = UIKit.label(currentPanel, "", {Size = UDim2.new(1, -310, 0, 22), Position = UDim2.fromOffset(104, 52), Align = "Left", Color = C.Money, Stroke = 0, MaxText = 18})
local takeButton = UIKit.button(currentPanel, "TAKE BACK", {Size = UDim2.fromOffset(170, 50), Position = UDim2.new(1, -14, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), Color = C.Coral})
local currentIconHolder = Instance.new("Frame")
currentIconHolder.BackgroundTransparency = 1
currentIconHolder.Size = UDim2.fromOffset(80, 80)
currentIconHolder.Position = UDim2.fromOffset(10, 8)
currentIconHolder.Parent = currentPanel
local pickLabel = UIKit.label(displayContent, "Pick a meme from your inventory:", {Size = UDim2.new(1, 0, 0, 24), Position = UDim2.fromOffset(4, 106), Align = "Left", Color = C.Violet, Stroke = 0, MaxText = 20})
local displayGrid = makeGrid(displayContent, 134)
local displayEmpty = UIKit.label(displayContent, "Your bag is empty... go dig up some memes!", {
	Size = UDim2.new(0.9, 0, 0, 30), Position = UDim2.fromScale(0.5, 0.62), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Grey, Stroke = 0,
})

local openSlot -- slot number the window is for

local function myMuseum()
	local ref = player:FindFirstChild("Museum")
	return ref and ref.Value
end

local function refreshDisplay()
	if not openSlot then return end
	local museum = myMuseum()
	local slot = museum and museum:FindFirstChild("Slots") and museum.Slots:FindFirstChild("Slot" .. openSlot)
	local shown = slot and ArtifactData.GetArtifact(slot:GetAttribute("ArtifactId") or "")
	clear(currentIconHolder)
	if shown then
		UIKit.artifactIcon(currentIconHolder, shown, {Size = UDim2.fromScale(1, 1)})
		currentTitle.Text = "Slot " .. openSlot .. ":  " .. shown.Name
		currentSub.Text = "Earning +" .. ArtifactData.FormatMoney(ArtifactData.GetIncome(shown)) .. "/s"
		takeButton.Visible = true
		pickLabel.Text = "Swap it for another meme:"
	else
		currentTitle.Text = "Slot " .. openSlot .. " is empty"
		currentSub.Text = "Memes on display earn money every second"
		takeButton.Visible = false
		pickLabel.Text = "Pick a meme from your inventory:"
	end

	clear(displayGrid)
	local entries = fetchInventory()
	displayEmpty.Visible = #entries == 0
	for i, entry in ipairs(entries) do
		local card = memeCard(displayGrid, entry, i, "+" .. ArtifactData.FormatMoney(ArtifactData.GetIncome(entry.Artifact)) .. "/s")
		local place = UIKit.button(card, shown and "SWAP" or "PLACE", {Size = UDim2.new(1, -20, 0, 34), Position = UDim2.new(0.5, 0, 1, -8), AnchorPoint = Vector2.new(0.5, 1), Color = C.Mint})
		place.MouseButton1Click:Connect(function()
			placeRemote:FireServer(openSlot, entry.Artifact.Id)
			displayWindow.Visible = false
		end)
	end
end

takeButton.MouseButton1Click:Connect(function()
	if openSlot then
		takeRemote:FireServer(openSlot)
		displayWindow.Visible = false
	end
end)

openSlotRemote.OnClientEvent:Connect(function(slotIndex)
	openSlot = slotIndex
	refreshDisplay()
	UIKit.open(displayWindow)
end)

---------------------------------------------------------------------
-- ALIEN ART DEALER WINDOW
---------------------------------------------------------------------
local dealerWindow, dealerContent = UIKit.window(gui, "ALIEN ART DEALER", UDim2.fromOffset(740, 580), C.Mint, "Alien")
UIKit.label(dealerContent, "\"Greetings, Earthling. I pay top dollar for ancient memes.\"", {
	Size = UDim2.new(1, 0, 0, 24), Position = UDim2.fromOffset(4, 4), Align = "Left", Color = C.Violet, Stroke = 0, MaxText = 20,
})
local dealerGrid = makeGrid(dealerContent, 40)
local dealerEmpty = UIKit.label(dealerContent, "Nothing to sell... go dig up some memes!", {
	Size = UDim2.new(0.9, 0, 0, 30), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Grey, Stroke = 0,
})

local function refreshDealer()
	clear(dealerGrid)
	local entries = fetchInventory()
	dealerEmpty.Visible = #entries == 0
	for i, entry in ipairs(entries) do
		local value = ArtifactData.GetSellValue(entry.Artifact)
		local card = memeCard(dealerGrid, entry, i, "Sells for " .. ArtifactData.FormatMoney(value))
		local one = UIKit.button(card, "SELL", {Size = UDim2.new(0.5, -12, 0, 34), Position = UDim2.new(0, 8, 1, -8), AnchorPoint = Vector2.new(0, 1), Color = C.Sun})
		local all = UIKit.button(card, "ALL", {Size = UDim2.new(0.5, -12, 0, 34), Position = UDim2.new(1, -8, 1, -8), AnchorPoint = Vector2.new(1, 1), Color = C.Coral})
		one.MouseButton1Click:Connect(function()
			sellRemote:FireServer(entry.Artifact.Id, false)
		end)
		all.MouseButton1Click:Connect(function()
			sellRemote:FireServer(entry.Artifact.Id, true)
		end)
	end
end

openDealerRemote.OnClientEvent:Connect(function()
	refreshDealer()
	UIKit.open(dealerWindow)
end)

inventoryChangedRemote.OnClientEvent:Connect(function()
	if dealerWindow.Visible then refreshDealer() end
	if displayWindow.Visible then refreshDisplay() end
end)

---------------------------------------------------------------------
-- FLOOR BUTTONS (only while you're inside a museum): big studded buttons at the top center,
-- a blue UP with a white arrow on its left and a red DOWN with the arrow on its right. Only
-- the ones you can use show: UP alone on the ground floor, both in between, DOWN alone on top.
---------------------------------------------------------------------
local floorBar = Instance.new("Frame")
floorBar.Name = "FloorButtons"
floorBar.BackgroundTransparency = 1
floorBar.Size = UDim2.fromOffset(500, 110)
floorBar.Position = UDim2.new(0.5, 0, 0, 108) -- under the HUD's top buttons
floorBar.AnchorPoint = Vector2.new(0.5, 0)
floorBar.Visible = false
floorBar.Parent = gui
local buttonRow = Instance.new("Frame")
buttonRow.BackgroundTransparency = 1
buttonRow.Size = UDim2.new(1, 0, 0, 74)
buttonRow.Parent = floorBar
local rowLayout = Instance.new("UIListLayout")
rowLayout.FillDirection = Enum.FillDirection.Horizontal
rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
rowLayout.Padding = UDim.new(0, 22)
rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
rowLayout.Parent = buttonRow

local function floorButton(text, color, arrow, arrowOnLeft, order)
	local b, label = UIKit.button(buttonRow, text, {Size = UDim2.fromOffset(220, 70), Color = color, Radius = 12, MaxText = 40})
	b.Name = text
	b.LayoutOrder = order
	UIKit.arrowIcon(b, arrow, {Size = UDim2.fromOffset(62, 62), Position = UDim2.new(arrowOnLeft and 0 or 1, arrowOnLeft and 12 or -12, 0.5, -3),
		AnchorPoint = Vector2.new(arrowOnLeft and 0 or 1, 0.5), ZIndex = 3})
	label.Size = UDim2.new(1, -96, 1, -16)
	label.Position = UDim2.new(0.5, arrowOnLeft and 34 or -34, 0.5, -3)
	return b
end
local upButton = floorButton("UP", rgb(48, 160, 245), "Up", true, 1)
local downButton = floorButton("DOWN", rgb(232, 50, 64), "Down", false, 2)

-- which floor you're on, and the price of the next floor while it's still locked
local floorLabel = UIKit.label(floorBar, "", {Size = UDim2.new(1, 0, 0, 24), Position = UDim2.new(0.5, 0, 0, 78), AnchorPoint = Vector2.new(0.5, 0),
	Color = C.White, Stroke = 3, MaxText = 22})

local function currentMuseumFloor()
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end
	for _, museum in ipairs(museumsFolder:GetChildren()) do
		local floor = GameConfig.GetMuseumFloor(museum, root.Position)
		if floor then return museum, floor end
	end
	return nil
end

upButton.MouseButton1Click:Connect(function()
	if upButton.Visible then floorRemote:FireServer(1) end
end)
downButton.MouseButton1Click:Connect(function()
	if downButton.Visible then floorRemote:FireServer(-1) end
end)

task.spawn(function()
	local topFloor = #GameConfig.FloorPrices
	while true do
		local museum, floor = currentMuseumFloor()
		floorBar.Visible = museum ~= nil
		if museum then
			local opened = string.split(museum:GetAttribute("UnlockedFloors") or "1", ",")
			local owned = museum:GetAttribute("OwnerUserId") == player.UserId
			local nextOpen = table.find(opened, tostring(floor + 1)) ~= nil
			local canUp = floor < topFloor and (nextOpen or owned)
			local buying = canUp and not nextOpen
			upButton.Visible = canUp
			downButton.Visible = floor > 1
			floorLabel.Text = buying and ("Floor " .. floor .. "/" .. topFloor .. "  -  Unlock the next floor: " .. ArtifactData.FormatMoney(GameConfig.FloorPrices[floor + 1]))
				or ("Floor " .. floor .. "/" .. topFloor)
			floorLabel.TextColor3 = buying and rgb(255, 214, 80) or C.White
		end
		task.wait(0.25)
	end
end)
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "RebirthClient", "LocalScript", [=[
-- RebirthClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The REBIRTH window (the Rebirth button on the HUD): how close you are to your next rebirth,
-- what it gives you, the rebirth button, and the gem shop's Lucky Charm upgrade.
-- The server side is RebirthManager.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local UIBus = require(ReplicatedStorage:WaitForChild("UIBus"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local player = Players.LocalPlayer
local gui = UIKit.screen(player, "RebirthGui", 3)
local window, content = UIKit.window(gui, "REBIRTH", UDim2.fromOffset(560, 470), C.Coral, "Rebirth")

-- REBIRTH card
local card = UIKit.panel(content, {Size = UDim2.new(1, -8, 0, 236), Position = UDim2.fromOffset(4, 4), Color = C.White, Radius = 20, Shade = false})
local title = UIKit.label(card, "", {Size = UDim2.new(1, -30, 0, 30), Position = UDim2.fromOffset(16, 12), Align = "Left", Color = C.Ink, Stroke = 0, MaxText = 26})
local perks = UIKit.label(card, "", {Size = UDim2.new(1, -30, 0, 46), Position = UDim2.fromOffset(16, 46), Align = "Left", VAlign = "Top", Color = C.Grey, Stroke = 0, Font = UIKit.BodyFont, TextSize = 15})
local track = UIKit.panel(card, {Size = UDim2.new(1, -32, 0, 26), Position = UDim2.fromOffset(16, 104), Color = C.PanelTint, Radius = 13, Stroke = 2, StrokeColor = C.Lilac, Shade = false})
local fill = UIKit.panel(track, {Size = UDim2.fromScale(0, 1), Color = C.Money, Radius = 13, Stroke = false, Shade = false})
local progress = UIKit.label(track, "", {Size = UDim2.new(1, -16, 0.8, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.White, Stroke = 2, MaxText = 16})
progress.ZIndex = 3
UIKit.label(card, "You keep your memes, museum, pickaxes and worlds. Only your cash resets.", {Size = UDim2.new(1, -30, 0, 18), Position = UDim2.fromOffset(16, 138),
	Align = "Left", Color = C.Grey, Stroke = 0, Font = UIKit.BodyFont, MaxText = 14})
local rebirthButton = UIKit.button(card, "REBIRTH", {Icon = "Rebirth", Size = UDim2.new(1, -32, 0, 56), Position = UDim2.new(0.5, 0, 1, -70), AnchorPoint = Vector2.new(0.5, 0), Color = C.Coral, MaxText = 26})

-- GEM SHOP card
local gemCard = UIKit.panel(content, {Size = UDim2.new(1, -8, 0, 130), Position = UDim2.fromOffset(4, 252), Color = C.White, Radius = 20, Shade = false})
UIKit.badge(gemCard, "Luck", C.Mint, {Diameter = 56, Position = UDim2.new(0, 14, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)})
local charmTitle = UIKit.label(gemCard, "", {Size = UDim2.new(0.6, -80, 0, 28), Position = UDim2.fromOffset(84, 22), Align = "Left", Color = C.Ink, Stroke = 0, MaxText = 22})
local charmText = UIKit.label(gemCard, "", {Size = UDim2.new(0.6, -80, 0, 40), Position = UDim2.fromOffset(84, 54), Align = "Left", VAlign = "Top", Color = C.Grey, Stroke = 0, Font = UIKit.BodyFont, TextSize = 14})
local charmButton = UIKit.button(gemCard, "", {Icon = "Gem", Size = UDim2.new(0.36, 0, 0, 54), Position = UDim2.new(1, -14, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), Color = C.Violet, MaxText = 20})

local function refresh()
	local rebirths = player:GetAttribute("Rebirths") or 0
	local money = player:GetAttribute("Money") or 0
	local gems = player:GetAttribute("Gems") or 0
	local cost = GameConfig.RebirthCost(rebirths)
	local bonus = math.floor(GameConfig.RebirthIncomeBonus * 100)
	title.Text = "Rebirth " .. rebirths .. "  →  " .. (rebirths + 1)
	perks.Text = "Now: +" .. bonus * rebirths .. "% income.   After rebirthing: +" .. bonus * (rebirths + 1) .. "% income and +"
		.. GameConfig.RebirthGemReward(rebirths) .. " gems."
	fill.Size = UDim2.fromScale(math.clamp(money / cost, 0, 1), 1)
	progress.Text = ArtifactData.FormatMoney(money) .. " / " .. ArtifactData.FormatMoney(cost)
	UIKit.setButton(rebirthButton, money >= cost and "REBIRTH NOW" or "NEED " .. ArtifactData.FormatMoney(cost), money >= cost and C.Coral or C.Grey,
		money >= cost and "Rebirth" or "Lock")

	local level = player:GetAttribute("GemLuckLevel") or 0
	local maxed = level >= GameConfig.GemLuckMaxLevel
	local charmCost = (level + 1) * GameConfig.GemLuckCost
	charmTitle.Text = "Lucky Charm  ·  Lv " .. level
	charmText.Text = "+" .. math.floor(GameConfig.GemLuckPerLevel * 100 * level) .. "% luck on every dig. Each level adds +" .. math.floor(GameConfig.GemLuckPerLevel * 100) .. "%. You have " .. gems .. " gems."
	UIKit.setButton(charmButton, maxed and "MAXED" or tostring(charmCost), (not maxed and gems >= charmCost) and C.Violet or C.Grey, maxed and "Star" or "Gem")
end

rebirthButton.MouseButton1Click:Connect(function()
	remotes:WaitForChild("Rebirth"):FireServer()
end)
charmButton.MouseButton1Click:Connect(function()
	remotes:WaitForChild("BuyGemUpgrade"):FireServer()
end)
for _, attribute in ipairs({"Money", "Gems", "Rebirths", "GemLuckLevel"}) do
	player:GetAttributeChangedSignal(attribute):Connect(function()
		if window.Visible then refresh() end
	end)
end
UIBus.On("Rebirth", function()
	if window.Visible then
		window.Visible = false
	else
		refresh()
		UIKit.open(window)
	end
end)
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "ShovelClient", "LocalScript", [=[
-- ShovelClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Shovel swing + dig animation, depth + zone meter, underground light,
-- Return to Surface button, and the Shovel Shop window (each world's shovels as cards
-- with 3D icons, stat bars and their depth rating).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local swingRemote = remotes:WaitForChild("DigSwing")
local digMessageRemote = remotes:WaitForChild("DigProgress")
local surfaceRemote = remotes:WaitForChild("ReturnToSurface")
local openShopRemote = remotes:WaitForChild("OpenShovelShop")
local buyShovelRemote = remotes:WaitForChild("BuyShovel")
local equipShovelRemote = remotes:WaitForChild("EquipShovel")
local shopMessageRemote = remotes:WaitForChild("ShopMessage")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local gui = UIKit.screen(player, "ShovelGui", 2)

---------------------------------------------------------------------
-- HINT MESSAGES (bubbly text above the hotbar)
---------------------------------------------------------------------
local hint = UIKit.panel(gui, {
	Size = UDim2.fromOffset(560, 46), Position = UDim2.new(0.5, 0, 1, -196), AnchorPoint = Vector2.new(0.5, 0),
	Color = C.Ink, Radius = 23, Stroke = 2.5, StrokeColor = C.Lilac, ShadeAmount = 0.2,
})
hint.BackgroundTransparency = 0.12
hint.Visible = false
local hintDot = UIKit.panel(hint, {Size = UDim2.fromOffset(14, 14), Position = UDim2.new(0, 16, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Color = C.Sun, Radius = 7, Stroke = false})
-- messages tagged with an icon ("{Skull} ...") show that 3D icon instead of the dot
local hintIcon = UIKit.icon(hint, nil, {Size = UDim2.fromOffset(48, 48), Position = UDim2.new(0, -2, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 2})
local hintText = UIKit.label(hint, "", {Size = UDim2.new(1, -56, 1, -14), Position = UDim2.new(0, 40, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
	Align = "Left", Color = C.White, Stroke = 0, MaxText = 22})

local hintToken = 0
local function showHint(text, color)
	hintToken += 1
	local myToken = hintToken
	local icon
	icon, text = UIKit.splitIcon(text)
	hintText.Text = text
	UIKit.setIcon(hintIcon, icon)
	hintDot.Visible = icon == nil
	hintDot.BackgroundColor3 = color or C.Sun
	hintText.TextColor3 = (color or C.Sun):Lerp(C.White, 0.55)
	hint.Visible = true
	UIKit.pop(hint, 0.7)
	task.delay(2.8, function()
		if hintToken == myToken then hint.Visible = false end
	end)
end

---------------------------------------------------------------------
-- "JUMP INTO THE PIT" PROMPT: shows while you hold a pickaxe outside the pit and vanishes the
-- instant your character enters the pit volume (GameConfig.IsInPit uses GetPartBoundsInBox)
---------------------------------------------------------------------
-- a small pill in the top-left corner, out of the way
local pitPrompt = UIKit.panel(gui, {
	Size = UDim2.fromOffset(250, 36), Position = UDim2.fromOffset(14, 12),
	Color = C.Ink, Radius = 18, Stroke = 2.5, StrokeColor = C.Sky, ShadeAmount = 0.2,
})
pitPrompt.BackgroundTransparency = 0.12
pitPrompt.Visible = false
UIKit.icon(pitPrompt, "Pickaxe", {Size = UDim2.fromOffset(40, 40), Position = UDim2.new(0, -4, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 2})
UIKit.label(pitPrompt, "Jump into the pit to dig!", {Size = UDim2.new(1, -54, 1, -12), Position = UDim2.new(0.5, 14, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
	Color = C.White, Stroke = 0, MaxText = 17})
local insidePit = false

digMessageRemote.OnClientEvent:Connect(function(message, color)
	if typeof(message) == "string" then
		showHint(message, typeof(color) == "Color3" and color or nil)
	end
end)

---------------------------------------------------------------------
-- DEPTH GAUGE (slim tube on the right edge) + RETURN TO SURFACE + UNDERGROUND LIGHT
---------------------------------------------------------------------
local GAUGE_H = 230 -- height of the tube in pixels

local depthPanel = Instance.new("Frame") -- whole gauge; shown while holding a shovel or underground
depthPanel.BackgroundTransparency = 1
depthPanel.Size = UDim2.fromOffset(104, 360)
depthPanel.Position = UDim2.new(1, -12, 0.5, 0)
depthPanel.AnchorPoint = Vector2.new(1, 0.5)
depthPanel.Visible = false
depthPanel.Parent = gui
local gaugeScale = Instance.new("UIScale")
gaugeScale.Parent = depthPanel
local function fitScreen()
	gaugeScale.Scale = math.clamp(camera.ViewportSize.Y / 720, 0.65, 1)
end
camera:GetPropertyChangedSignal("ViewportSize"):Connect(fitScreen)
fitScreen()

-- depth number bubble
local depthBubble = UIKit.panel(depthPanel, {Size = UDim2.fromOffset(96, 42), Position = UDim2.new(0.5, 0, 0, 0), AnchorPoint = Vector2.new(0.5, 0), Color = C.Ink, Radius = 21, StrokeColor = C.Lilac})
depthBubble.BackgroundTransparency = 0.1
local depthLabel = UIKit.label(depthBubble, "0m", {Size = UDim2.new(1, -16, 0.7, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.White, Stroke = 0, MaxText = 26})

-- the depth bonus (more luck the deeper you are, see GameConfig.DepthBonus) above the bubble
local bonusLabel = UIKit.label(depthPanel, "", {Size = UDim2.fromOffset(110, 18), Position = UDim2.new(0.5, 0, 0, -22), AnchorPoint = Vector2.new(0.5, 0),
	Color = C.Mint, Stroke = 2, MaxText = 15})

-- the tube, filled with one colored band per zone (thicker zones = taller bands)
local tube = UIKit.panel(depthPanel, {Size = UDim2.fromOffset(30, GAUGE_H), Position = UDim2.new(0.5, 0, 0, 50), AnchorPoint = Vector2.new(0.5, 0), Color = C.PanelTint, Radius = 15, Stroke = 3, StrokeColor = C.Ink, Shade = false})
-- the zone bands sit in a CanvasGroup, which clips them to the tube's rounded ends
-- (a plain frame clips square, so a band's corner used to poke out as a line at the bottom)
local bands = Instance.new("CanvasGroup")
bands.BackgroundTransparency = 1
bands.BorderSizePixel = 0
bands.Size = UDim2.fromScale(1, 1)
bands.Parent = tube
UIKit.corner(bands, 15)
local tubeGloss = UIKit.panel(tube, {Size = UDim2.new(0, 6, 1, -16), Position = UDim2.new(0, 5, 0, 8), Color = C.White, Radius = 3, Stroke = false, Shade = false})
tubeGloss.BackgroundTransparency = 0.55
tubeGloss.ZIndex = 3

-- your position: a bright bar across the tube
local marker = UIKit.panel(depthPanel, {Size = UDim2.fromOffset(42, 10), Position = UDim2.new(0.5, 0, 0, 50), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Sun, Radius = 5, Stroke = 2.5, Shade = false})
marker.ZIndex = 4

-- your shovel's limit: a red line across the tube with a small tag
local limitLine = UIKit.panel(depthPanel, {Size = UDim2.fromOffset(40, 6), Position = UDim2.new(0.5, 0, 0, 50), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Coral, Radius = 3, Stroke = 2, Shade = false})
limitLine.ZIndex = 4
local shovelLabel = UIKit.label(depthPanel, "", {Size = UDim2.fromOffset(34, 16), Position = UDim2.new(0.5, 22, 0, 50), AnchorPoint = Vector2.new(0, 0.5), Align = "Left", Color = C.Coral, Stroke = 2})
shovelLabel.ZIndex = 4

-- zone name pill under the tube: dark, with the zone's color as a dot and an outline
local zonePill = UIKit.panel(depthPanel, {Size = UDim2.fromOffset(104, 28), Position = UDim2.new(0.5, 0, 0, 50 + GAUGE_H + 12), AnchorPoint = Vector2.new(0.5, 0), Color = C.Ink, Radius = 14, Stroke = 2.5})
zonePill.BackgroundTransparency = 0.1
local zoneStroke = zonePill:FindFirstChildOfClass("UIStroke")
local zoneDot = UIKit.panel(zonePill, {Size = UDim2.fromOffset(12, 12), Position = UDim2.new(0, 8, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Color = C.Sun, Radius = 6, Stroke = false, Shade = false})
local zoneLabel = UIKit.label(zonePill, "", {Size = UDim2.new(1, -30, 0.64, 0), Position = UDim2.new(0, 24, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Color = C.White, Stroke = 0, MaxText = 14})

-- small "surface" button under everything, only while underground
local surfaceButton = UIKit.button(depthPanel, "SURFACE", {
	Size = UDim2.fromOffset(104, 40), Position = UDim2.new(0.5, 0, 0, 50 + GAUGE_H + 50), AnchorPoint = Vector2.new(0.5, 0), Color = C.Sky, Radius = 20,
})
surfaceButton.Visible = false
surfaceButton.MouseButton1Click:Connect(function()
	surfaceRemote:FireServer()
end)

local headlamp -- PointLight on our character when underground
local equippedDef -- the shovel currently in hand
local gaugeWorld -- world the bands were drawn for

---------------------------------------------------------------------
-- PIT AMBIENCE: the deeper you dig, the more the air inside the pit takes on the color of
-- the layer you're in (warm dust in the topsoil, orange clay, cold crystal blue, magma red):
-- a soft haze of drifting particles around you, a color grade, and your headlamp's tint
---------------------------------------------------------------------
local Lighting = game:GetService("Lighting")
local LAYER_AIR = { -- by zone index; worlds 2-9 mix in their own zone colors
	Color3.fromRGB(255, 226, 180), -- topsoil: warm dusty light
	Color3.fromRGB(255, 176, 120), -- dense clay: orange
	Color3.fromRGB(140, 220, 255), -- crystal substratum: cold blue
	Color3.fromRGB(255, 110, 60),  -- magma core: red-hot
}
local pitGrade = Instance.new("ColorCorrectionEffect")
pitGrade.Name = "PitDepthGrade"
pitGrade.Enabled = false
pitGrade.Parent = Lighting
local hazePart = Instance.new("Part")
hazePart.Name = "PitHaze"
hazePart.Anchored = true
hazePart.CanCollide = false
hazePart.CanQuery = false
hazePart.CanTouch = false
hazePart.Transparency = 1
hazePart.Size = Vector3.new(40, 20, 40)
local haze = Instance.new("ParticleEmitter")
haze.Shape = Enum.ParticleEmitterShape.Box
haze.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
haze.LightEmission = 0.3
haze.LightInfluence = 0.2
haze.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1.5), NumberSequenceKeypoint.new(1, 4)})
haze.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.4, 0.86), NumberSequenceKeypoint.new(1, 1)})
haze.Lifetime = NumberRange.new(4, 6)
haze.Speed = NumberRange.new(0.2, 0.6)
haze.RotSpeed = NumberRange.new(-15, 15)
haze.Rate = 0
haze.Parent = hazePart
local airColor = LAYER_AIR[1]

local function updatePitAir(world, depth, zoneIndex, zoneColor)
	local strength = math.clamp((depth - 6) / 40, 0, 1) -- fades in over the first 40 studs down
	if strength <= 0 then
		pitGrade.Enabled = false
		haze.Rate = 0
		return
	end
	local target = LAYER_AIR[zoneIndex or 1] or LAYER_AIR[1]
	if world.Id ~= 1 and zoneColor then target = target:Lerp(zoneColor, 0.6) end
	airColor = airColor:Lerp(target, 0.15) -- blend smoothly as you cross into a new layer
	pitGrade.Enabled = true
	pitGrade.TintColor = Color3.new(1, 1, 1):Lerp(airColor, 0.22 * strength)
	pitGrade.Contrast = 0.05 * strength
	pitGrade.Saturation = 0.08 * strength
	haze.Color = ColorSequence.new(airColor)
	haze.Rate = 22 * strength
	hazePart.CFrame = CFrame.new(camera.CFrame.Position)
	hazePart.Parent = camera
end

local function currentWorld()
	return GameConfig.GetWorld(player:GetAttribute("CurrentWorld") or 1) or GameConfig.Worlds[1]
end

local function drawBands(world)
	gaugeWorld = world
	bands:ClearAllChildren()
	local total = -world.Zones[#world.Zones].Bottom
	for i, zone in ipairs(world.Zones) do
		local top = -zone.Top / total
		local height = (zone.Top - zone.Bottom) / total
		local band = Instance.new("Frame")
		band.BorderSizePixel = 0
		band.BackgroundColor3 = zone.Color
		band.Position = UDim2.fromScale(0, top)
		band.Size = UDim2.fromScale(1, height)
		band.Parent = bands
		if i > 1 then
			local seam = Instance.new("Frame")
			seam.BorderSizePixel = 0
			seam.BackgroundColor3 = C.Ink
			seam.Size = UDim2.new(1, 0, 0, 2)
			seam.Parent = band
		end
	end
end

-- y position (in gauge pixels) of a depth
local function gaugeY(world, depth)
	local total = -world.Zones[#world.Zones].Bottom
	return 50 + math.clamp(depth / total, 0, 1) * GAUGE_H
end

RunService.Heartbeat:Connect(function()
	local character = player.Character
	local wasInside = insidePit
	insidePit = GameConfig.IsInPit(currentWorld(), character)
	if insidePit and not wasInside and hint.Visible and hintText.Text:find("pit") then
		hint.Visible = false -- the old "get in the pit" nag disappears the moment you're in
	end
	local show = equippedDef ~= nil and not insidePit and character ~= nil
	if show and not pitPrompt.Visible then UIKit.pop(pitPrompt, 0.7) end
	pitPrompt.Visible = show
end)

task.spawn(function()
	while true do
		task.wait(0.15)
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root then
			local world = currentWorld()
			if world ~= gaugeWorld then drawBands(world) end
			local feetY = root.Position.Y - 3
			local depth = math.max(0, math.floor(world.Origin.Y - feetY + 0.5))
			local inPit = insidePit

			local zoneIndex, zone = GameConfig.GetZoneAt(world, feetY)
			zone = zone or {Name = "Bedrock", Color = Color3.fromRGB(150, 150, 160)}
			updatePitAir(world, inPit and depth or 0, zoneIndex or #world.Zones, zone.Color)
			depthLabel.Text = depth .. "m"
			local bonus = GameConfig.DepthBonus(world, feetY)
			bonusLabel.Text = bonus >= 1.01 and string.format("x%.2f LUCK", bonus) or ""
			zoneLabel.Text = string.upper(zone.Name)
			zoneDot.BackgroundColor3 = zone.Color
			if zoneStroke then zoneStroke.Color = zone.Color end
			-- the marker stays inside the tube, even at the very bottom
			marker.Position = UDim2.new(0.5, 0, 0, math.clamp(gaugeY(world, depth), 50 + 6, 50 + GAUGE_H - 6))

			if equippedDef and equippedDef.World == world.Id then
				local maxDepth = -world.Zones[equippedDef.MaxZone].Bottom
				limitLine.Visible = equippedDef.MaxZone < #world.Zones
				shovelLabel.Visible = limitLine.Visible
				limitLine.Position = UDim2.new(0.5, 0, 0, gaugeY(world, maxDepth))
				shovelLabel.Position = UDim2.new(0.5, 22, 0, gaugeY(world, maxDepth))
				shovelLabel.Text = "MAX"
				-- marker turns red when you're right at your shovel's limit
				marker.BackgroundColor3 = (limitLine.Visible and maxDepth - depth <= 8) and C.Coral or C.Sun
			else
				limitLine.Visible = false
				shovelLabel.Visible = false
				marker.BackgroundColor3 = C.Sun
			end

			depthPanel.Visible = equippedDef ~= nil or (inPit and depth > 4)
			surfaceButton.Visible = inPit and depth > 4

			-- small light so you can see underground
			if depth > 4 then
				if not headlamp or headlamp.Parent ~= root then
					headlamp = Instance.new("PointLight")
					headlamp.Color = Color3.fromRGB(255, 235, 200)
					headlamp.Range = 22
					headlamp.Brightness = 1.3
					headlamp.Shadows = true
					headlamp.Parent = root
				end
				headlamp.Enabled = true
				headlamp.Color = Color3.fromRGB(255, 240, 220):Lerp(airColor, 0.35)
			elseif headlamp then
				headlamp.Enabled = false
			end
		end
	end
end)

---------------------------------------------------------------------
-- SHOVEL POSE + DIG ANIMATION (for every player's character on this screen)
-- The real tool is hidden on this screen. A copy of the shovel is placed exactly where the
-- pose wants it every frame, the right hand grips its shaft with IK (position AND rotation,
-- so the fist really wraps the handle like a normal Roblox tool), and the torso leans and
-- twists with the swing. The swing is short and snappy with a tiny freeze on impact.
-- The blade is never allowed to sink into the ground.
-- Other players' swings arrive through ShovelSwingFx, so everyone sees everyone dig.
---------------------------------------------------------------------
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local ShovelModels = require(ReplicatedStorage:WaitForChild("PickaxeModels"))
local swingFxRemote = remotes:WaitForChild("ShovelSwingFx")

-- TWO-HANDED PICKAXE POSE. Values are relative to the HumanoidRootPart (+X right, +Y up,
-- -Z forward). The right hand holds the bottom of the handle, the left hand holds it a bit
-- higher up (both by IK, so the grip always matches the pickaxe).
-- Hand  = where the right hand holds the handle (studs)
-- Tilt  = handle pitch, degrees: 0 = head pointing straight down, 90 = head pointing forward,
--         180 = head straight up, 225 = head up and back over the shoulder
-- Turn  = yaw (+ = to the left), Roll = sideways lean of the pickaxe (+ = head leans left)
-- Lean  = torso pitch (+ = bend forward), Twist = torso yaw (+ = turn left)
-- Bend  = torso side bend (+ = lean left), Look = head pitch (+ = look down)
-- Crouch = knee bend, degrees (the body drops, the feet stay planted)
-- Hip   = pelvis pitch (+ = the whole upper body tips forward from the hips)
local CHANNELS = {"Tilt", "Turn", "Roll", "Lean", "Twist", "Bend", "Look", "Crouch", "Hip"}
-- ready stance: pickaxe held low and across the body, head out to the side (clear of the face)
local IDLE = {Hand = Vector3.new(0.35, -0.15, -0.8), Tilt = 105, Turn = 30, Roll = 15, Lean = 3, Twist = 0, Bend = 0, Look = 2, Crouch = 6, Hip = 2}

-- easing curves: how each part of the swing speeds up and slows down
local function easeInOutSine(u) return -(math.cos(math.pi * u) - 1) / 2 end
local function easeOutCubic(u) return 1 - (1 - u) ^ 3 end
local function easeOutSine(u) return math.sin(u * math.pi / 2) end
local function easeInQuad(u) return u * u end
local function easeOutBack(u)
	local c1 = 1.9
	return 1 + (c1 + 1) * (u - 1) ^ 3 + c1 * (u - 1) ^ 2
end
local function easeInOutCubic(u) return u < 0.5 and 4 * u * u * u or 1 - (-2 * u + 2) ^ 3 / 2 end

-- The dig, key by key (a two-beat scoop, like digging with a spade): a quick wind-up, a stab
-- down into the dirt in front, a pry back, then a heave up over the right shoulder that
-- flings the dirt up and behind. Ease = how the motion INTO that key is timed.
local SWING = {
	{T = 0.00, Pose = IDLE},
	-- wind-up: the pickaxe comes up beside the right shoulder
	{T = 0.12, Ease = easeInOutSine, Pose = {Hand = Vector3.new(0.6, 0.55, -0.5), Tilt = 150, Turn = 0, Roll = -20, Lean = -4, Twist = -16, Bend = -2, Look = -4, Crouch = 12, Hip = -2}},
	-- stab: driven down hard into the ground in front of the feet
	{T = 0.26, Ease = easeInQuad, Pose = {Hand = Vector3.new(0.15, -1.0, -1.7), Tilt = 40, Turn = 4, Roll = 0, Lean = 28, Twist = -6, Bend = 4, Look = 22, Crouch = 38, Hip = 26}},
	-- pry: leans back on the handle, levering the dirt loose
	{T = 0.40, Ease = easeOutCubic, Pose = {Hand = Vector3.new(0.3, -0.6, -1.2), Tilt = 62, Turn = 8, Roll = 6, Lean = 22, Twist = -10, Bend = 3, Look = 16, Crouch = 34, Hip = 20}},
	-- fling: heaved up over the right shoulder, throwing the dirt up and behind
	{T = 0.62, Ease = easeInOutSine, Pose = {Hand = Vector3.new(0.95, 1.4, 0.05), Tilt = 215, Turn = -14, Roll = -32, Lean = -10, Twist = -46, Bend = -6, Look = -12, Crouch = 4, Hip = -6}},
	-- settle back into the ready stance
	{T = 1.00, Ease = easeInOutCubic, Pose = IDLE},
}
local STRIKE_TIME = 0.26 -- the blade bites the ground (the dig happens here)
local FLING_TIME = 0.54 -- the dirt leaves the blade on the way up
local HIT_STOP = 0.05 -- the pose freezes this long on impact, which makes hits feel heavy
local TRAILS = {{0.14, 0.28}, {0.44, 0.64}} -- swoosh trail during the stab and the fling
local WOBBLE = {Degrees = 7, Decay = 9, Speed = 38} -- the handle vibrates after the impact

-- tool axes when upright: grip end (+Z) points up (head down), pick arms (+Y) point forward
local UPRIGHT = CFrame.fromMatrix(Vector3.zero, Vector3.xAxis, -Vector3.zAxis, Vector3.yAxis)

-- smooth Catmull-Rom curve through the swing keyframes (never jerky)
local function catmull(p0, p1, p2, p3, u)
	local u2, u3 = u * u, u * u * u
	return (p1 * 2 + (p2 - p0) * u + (p0 * 2 - p1 * 5 + p2 * 4 - p3) * u2 + (p1 * 3 - p0 - p2 * 3 + p3) * u3) * 0.5
end

local function samplePose(t, keys)
	keys = keys or SWING
	t = math.clamp(t, 0, 1)
	local i = 1
	while i < #keys - 1 and t > keys[i + 1].T do i += 1 end
	local k0, k1, k2, k3 = keys[math.max(i - 1, 1)], keys[i], keys[i + 1], keys[math.min(i + 2, #keys)]
	local u = (t - k1.T) / (k2.T - k1.T)
	u = k2.Ease and k2.Ease(u) or u
	local pose = {Hand = catmull(k0.Pose.Hand, k1.Pose.Hand, k2.Pose.Hand, k3.Pose.Hand, u)}
	for _, c in ipairs(CHANNELS) do
		pose[c] = catmull(k0.Pose[c] or 0, k1.Pose[c] or 0, k2.Pose[c] or 0, k3.Pose[c] or 0, u)
	end
	return pose
end

-- the ready stance is never frozen: breathing, a slow weight shift, and a bob while walking
local function idlePose(clock, moving)
	local breathe = math.sin(clock * 2.2)
	local sway = math.sin(clock * 0.8)
	local step = math.sin(clock * 11) * moving
	return {
		Hand = IDLE.Hand + Vector3.new(sway * 0.05, breathe * 0.04 + math.abs(step) * 0.08, 0),
		Tilt = IDLE.Tilt + breathe * 2 + step * 4, Turn = IDLE.Turn + sway * 2,
		Roll = IDLE.Roll + sway * 3, Lean = IDLE.Lean + breathe * 0.6 + moving * 5,
		Twist = IDLE.Twist + sway * 2, Bend = sway * 1.5 + step * 1.2, Look = -breathe * 2,
		Crouch = IDLE.Crouch * (1 - moving) + breathe, Hip = IDLE.Hip,
	}
end

-- EQUIP: the pickaxe fades in at the side with a sparkle, gets flipped up into the air,
-- spins twice, is caught overhead with a flash, then swung down into the ready stance.
local EQUIP_LENGTH = 0.8
local EQUIP = {
	{T = 0.00, Pose = {Hand = Vector3.new(0.6, -0.35, -0.4), Tilt = 30, Turn = 10, Roll = 0, Lean = 0, Twist = 0, Bend = 0, Look = 4}},
	{T = 0.14, Ease = easeInOutSine, Pose = {Hand = Vector3.new(0.5, -0.3, -0.5), Tilt = 60, Turn = 10, Roll = 0, Lean = 4, Twist = 4, Bend = 0, Look = 0}},
	{T = 0.22, Ease = easeOutCubic, Pose = {Hand = Vector3.new(0.9, 1.0, -0.8), Tilt = 160, Turn = 0, Roll = -20, Lean = -4, Twist = -6, Bend = 0, Look = -20}},
	{T = 0.50, Ease = easeOutSine, Pose = {Hand = Vector3.new(1.0, 1.45, -0.7), Tilt = 180, Turn = 0, Roll = -20, Lean = -6, Twist = -10, Bend = -2, Look = -25}},
	{T = 0.64, Ease = easeInQuad, Pose = {Hand = Vector3.new(0.25, -0.05, -1.0), Tilt = 95, Turn = 20, Roll = 10, Lean = 10, Twist = -12, Bend = 2, Look = 8, Crouch = 22, Hip = 8}},
	{T = 1.00, Ease = easeOutBack, Pose = IDLE},
}
local TOSS_FROM, TOSS_TO, TOSS_HEIGHT, TOSS_SPINS = 0.22, 0.5, 3.4, 2
local onEquipCatch -- camera jolt + sound for our own catch (set further down)

local rigs = {} -- [character] = rig
local warnedR6 = false
local puppetFolder = Instance.new("Folder")
puppetFolder.Name = "ShovelPuppets"
puppetFolder.Parent = workspace

local function newAttachment(parent, name)
	local a = Instance.new("Attachment")
	a.Name = name
	a.Parent = parent
	return a
end

local function newArmIK(humanoid, name, upper, hand, target, pole)
	local ik = Instance.new("IKControl")
	ik.Name = name
	ik.Type = Enum.IKControlType.Position
	ik.ChainRoot = upper
	ik.EndEffector = hand
	ik.Target = target
	ik.Pole = pole
	ik.Weight = 1
	ik.SmoothTime = 0
	ik.Parent = humanoid
	return ik
end

local function destroyRig(character)
	local rig = rigs[character]
	if not rig then return end
	rigs[character] = nil
	for _, thing in ipairs(rig.Cleanup) do
		thing:Destroy()
	end
	if rig.Waist and rig.Waist.Parent then rig.Waist.C0 = rig.WaistC0 end
	if rig.Neck and rig.Neck.Parent then rig.Neck.C0 = rig.NeckC0 end
	if rig.Hips and rig.Hips.Parent then rig.Hips.C0 = rig.HipsC0 end
	for _, leg in ipairs(rig.Legs) do
		if leg.Motor.Parent then leg.Motor.C0 = leg.C0 end
	end
	if rig.Tool then
		for _, d in ipairs(rig.Tool:GetDescendants()) do
			if d:IsA("BasePart") then d.LocalTransparencyModifier = 0 end
		end
	end
end

local function createRig(character, tool)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	local upperTorso = character:FindFirstChild("UpperTorso")
	local parts = {
		RU = character:FindFirstChild("RightUpperArm"), RH = character:FindFirstChild("RightHand"),
		LU = character:FindFirstChild("LeftUpperArm"), LH = character:FindFirstChild("LeftHand"),
	}
	-- the pose needs an R15 body; R6 characters keep Roblox's default hold
	if not (humanoid and root and upperTorso and parts.RU and parts.RH) then
		if humanoid and humanoid.RigType == Enum.HumanoidRigType.R6 and not warnedR6 then
			warnedR6 = true
			warn("Pickaxe animations need R15 avatars: Home > Game Settings > Avatar > Avatar Type = R15")
		end
		return nil
	end
	local def = GameConfig.GetShovel(tool:GetAttribute("ShovelId"))
	if not def then return nil end

	-- the copy of the shovel we pose every frame
	local model = ShovelModels(def)
	local handle = model:FindFirstChild("Handle")
	local puppet = {}
	local bladePart
	local tipZ = 0
	for _, piece in ipairs(model:GetChildren()) do
		if piece:IsA("BasePart") and piece ~= handle then
			for _, c in ipairs(piece:GetChildren()) do
				if c:IsA("WeldConstraint") then c:Destroy() end
			end
			piece.Anchored = true
			piece.CanCollide = false
			piece.CanQuery = false
			piece.CanTouch = false
			-- crystal shovels: orbit parts spin around OrbitCenter (along the shaft)
			table.insert(puppet, {Part = piece, Rel = handle.CFrame:ToObjectSpace(piece.CFrame),
				Center = piece:GetAttribute("OrbitCenter"), Speed = piece:GetAttribute("OrbitSpeed")})
			if piece.Name == "Blade" or piece.Name == "DrillTip" then bladePart = piece end
			-- lowest point of the shovel along its shaft (used to keep the blade out of the ground)
			local rel = handle.CFrame:ToObjectSpace(piece.CFrame)
			local h = piece.Size / 2
			for _, corner in ipairs({Vector3.new(h.X, h.Y, h.Z), Vector3.new(-h.X, h.Y, h.Z), Vector3.new(h.X, -h.Y, h.Z), Vector3.new(-h.X, -h.Y, h.Z),
				Vector3.new(h.X, h.Y, -h.Z), Vector3.new(-h.X, h.Y, -h.Z), Vector3.new(h.X, -h.Y, -h.Z), Vector3.new(-h.X, -h.Y, -h.Z)}) do
				tipZ = math.min(tipZ, (rel * corner).Z)
			end
		end
	end
	local holder = Instance.new("Model")
	holder.Name = character.Name .. "_Shovel"
	for _, p in ipairs(puppet) do p.Part.Parent = holder end
	holder.Parent = puppetFolder
	model:Destroy()

	-- hide the real tool on this screen (it still does the digging)
	for _, d in ipairs(tool:GetDescendants()) do
		if d:IsA("BasePart") then d.LocalTransparencyModifier = 1 end
	end

	local rightTarget = newAttachment(root, "ShovelRightHand")
	-- pole keeps the elbow bending down and out, like a relaxed arm
	local rightPole = newAttachment(root, "ShovelRightElbow")
	rightPole.Position = Vector3.new(2.4, -1.4, 0.8)
	local rightIK = newArmIK(humanoid, "ShovelRightArm", parts.RU, parts.RH, rightTarget, rightPole)
	-- match the hand's rotation too, so the fist closes around the shaft
	rightIK.Type = Enum.IKControlType.Transform
	local gripAttachment = parts.RH:FindFirstChild("RightGripAttachment")
	-- the left hand holds the handle higher up (two-handed grip)
	local leftTarget = newAttachment(root, "ShovelLeftHand")
	local leftPole = newAttachment(root, "ShovelLeftElbow")
	leftPole.Position = Vector3.new(-2.2, -1.2, 0.6)
	local leftIK = parts.LU and parts.LH and newArmIK(humanoid, "ShovelLeftArm", parts.LU, parts.LH, leftTarget, leftPole)

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.IgnoreWater = true
	local ignore = {puppetFolder}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character then table.insert(ignore, plr.Character) end
	end
	rayParams.FilterDescendantsInstances = ignore

	-- a swoosh trail from one arm tip of the head to the other (on during the down-swing)
	local trail
	if bladePart then
		local reach = bladePart.Size.Y * 1.7
		local a0 = Instance.new("Attachment")
		a0.Position = bladePart.CFrame:PointToObjectSpace(bladePart.Position + Vector3.new(0, reach, 0))
		a0.Parent = bladePart
		local a1 = Instance.new("Attachment")
		a1.Position = bladePart.CFrame:PointToObjectSpace(bladePart.Position - Vector3.new(0, reach, 0))
		a1.Parent = bladePart
		local gem = holder:FindFirstChild("HeadGem")
		local glow = gem and gem.Color or Color3.new(1, 1, 1)
		trail = Instance.new("Trail")
		trail.Attachment0 = a0
		trail.Attachment1 = a1
		trail.Lifetime = 0.16
		trail.MinLength = 0.05
		trail.FaceCamera = true
		trail.LightEmission = 0.5
		-- the swoosh matches the pickaxe's trail style (sparks, electricity, fire or galaxy)
		local colorA, colorB = tool:GetAttribute("TrailColorA"), tool:GetAttribute("TrailColorB")
		if typeof(colorA) == "Color3" and typeof(colorB) == "Color3" then
			trail.Color = ColorSequence.new(colorA, colorB)
		else
			trail.Color = ColorSequence.new(Color3.new(1, 1, 1), glow)
		end
		trail.Transparency = NumberSequence.new(0.35, 1)
		trail.WidthScale = NumberSequence.new(1, 0.3)
		trail.Enabled = false
		trail.Parent = bladePart
	end

	-- leg joints for the crouch: hip, knee and ankle on each side
	local legs = {}
	local legLength = 0
	for _, side in ipairs({"Left", "Right"}) do
		local upper, lower, foot = character:FindFirstChild(side .. "UpperLeg"), character:FindFirstChild(side .. "LowerLeg"), character:FindFirstChild(side .. "Foot")
		for _, joint in ipairs({{upper, "Hip"}, {lower, "Knee"}, {foot, "Ankle"}}) do
			local motor = joint[1] and joint[1]:FindFirstChild(side .. joint[2])
			if motor and motor:IsA("Motor6D") then
				table.insert(legs, {Motor = motor, C0 = motor.C0, Kind = joint[2]})
			end
		end
		if side == "Left" and upper and lower then legLength = upper.Size.Y + lower.Size.Y end
	end
	if legLength == 0 then legLength = 2.2 end

	local waist = upperTorso:FindFirstChild("Waist")
	local head = character:FindFirstChild("Head")
	local neck = head and head:FindFirstChild("Neck")
	local lowerTorso = character:FindFirstChild("LowerTorso")
	local hips = lowerTorso and lowerTorso:FindFirstChild("Root")
	local rig = {
		Tool = tool, Root = root, Puppet = puppet, Blade = bladePart or (puppet[#puppet] and puppet[#puppet].Part),
		HoldZ = (tool:GetAttribute("RightHoldZ") or tool:GetAttribute("TopHoldZ") or 1.1) - 0.12, -- right hand near the end
		LeftHoldZ = tool:GetAttribute("LeftHoldZ") or 0.4, -- left hand higher up the handle
		TipZ = tipZ,
		RightTarget = rightTarget,
		LeftTarget = leftIK and leftTarget or nil,
		Waist = waist and waist:IsA("Motor6D") and waist or nil,
		WaistC0 = waist and waist:IsA("Motor6D") and waist.C0 or nil,
		Neck = neck and neck:IsA("Motor6D") and neck or nil,
		NeckC0 = neck and neck:IsA("Motor6D") and neck.C0 or nil,
		Hips = hips and hips:IsA("Motor6D") and hips or nil,
		HipsC0 = hips and hips:IsA("Motor6D") and hips.C0 or nil,
		Legs = legs, LegLength = legLength,
		Humanoid = humanoid, Trail = trail, ImpactAt = nil, Smooth = nil,
		SwingStart = nil, SwingLength = 0.4, Struck = true, Flung = true,
		EquipStart = os.clock(), Caught = false, Landed = false,
		GripOffset = gripAttachment and gripAttachment.CFrame or CFrame.new(0, -0.15, 0) * CFrame.Angles(math.rad(-90), 0, 0),
		RayParams = rayParams,
		Cleanup = {holder, rightTarget, rightPole, rightIK, leftTarget, leftPole, leftIK or nil},
	}
	rigs[character] = rig
	return rig
end

-- throws a few little dirt clumps off the blade
local function tossDirt(position, color)
	for i = 1, 7 do
		-- chunky little clods with random sizes and spins (stylized, not round balls)
		local clump = Instance.new("Part")
		clump.Size = Vector3.new(0.3 + math.random() * 0.35, 0.22 + math.random() * 0.25, 0.3 + math.random() * 0.3)
		clump.CFrame = CFrame.Angles(math.random() * 6, math.random() * 6, math.random() * 6)
		clump.Color = color
		clump.Material = Enum.Material.SmoothPlastic
		clump.CanCollide = false
		clump.CanQuery = false
		clump.CanTouch = false
		clump.CastShadow = false
		clump.CFrame = CFrame.new(position + Vector3.new(math.random() - 0.5, 0, math.random() - 0.5) * 0.6) * clump.CFrame.Rotation
		clump.AssemblyAngularVelocity = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 20
		clump.AssemblyLinearVelocity = Vector3.new(math.random() * 12 - 6, 12 + math.random() * 10, math.random() * 12 - 6)
		clump.Parent = puppetFolder
		Debris:AddItem(clump, 1.1 + i * 0.05)
	end
end

-- the scooped dirt flying off the blade: chunky cubes thrown up and back over the shoulder,
-- tumbling, then shrinking away
local function flingDirt(root, position, color, count)
	for _ = 1, count do
		local clod = Instance.new("Part")
		local size = 0.45 + math.random() * 0.4
		clod.Size = Vector3.new(size, size * (0.8 + math.random() * 0.3), size)
		clod.Color = color:Lerp(Color3.new(math.random(), math.random() * 0.8, 0.2), 0.08):Lerp(Color3.new(0, 0, 0), math.random() * 0.15)
		clod.Material = Enum.Material.SmoothPlastic
		clod.CanCollide = false
		clod.CanQuery = false
		clod.CanTouch = false
		clod.CastShadow = false
		clod.CFrame = CFrame.new(position + Vector3.new(math.random() - 0.5, math.random() * 0.4, math.random() - 0.5) * 0.7)
			* CFrame.Angles(math.random() * 6, math.random() * 6, math.random() * 6)
		-- up and backward (+Z behind the player), drifting to the right
		clod.AssemblyLinearVelocity = root.CFrame:VectorToWorldSpace(Vector3.new(math.random() * 9 - 3, 24 + math.random() * 9, 7 + math.random() * 7))
		clod.AssemblyAngularVelocity = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 24
		clod.Parent = puppetFolder
		local life = 0.9 + math.random() * 0.3
		task.delay(life - 0.25, function()
			if clod.Parent then
				TweenService:Create(clod, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = Vector3.one * 0.05}):Play()
			end
		end)
		Debris:AddItem(clod, life)
	end
end

-- a quick burst of glowing sparkles (the equip flash)
local function sparkle(position, colorA, colorB, count, speed)
	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.Transparency = 1
	anchor.Size = Vector3.one
	anchor.CFrame = CFrame.new(position)
	anchor.Parent = puppetFolder
	local e = Instance.new("ParticleEmitter")
	e.Enabled = false
	e.Color = ColorSequence.new(colorA, colorB)
	e.LightEmission = 1
	e.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.45), NumberSequenceKeypoint.new(1, 0)})
	e.Lifetime = NumberRange.new(0.25, 0.5)
	e.Speed = NumberRange.new(speed * 0.5, speed)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Drag = 5
	e.RotSpeed = NumberRange.new(-300, 300)
	e.Parent = anchor
	e:Emit(count)
	Debris:AddItem(anchor, 0.8)
end

-- the moment the pickaxe bites the ground: a burst of dirt chunks, a puff of dust and a
-- ring of dust rolling out across the ground (plus camera shake for our own swings)
local impactShake -- set further down, once the camera shake exists
-- extra impact particles in the tool's style (see PickaxeModels TRAILS), and glowing sparks
-- in the deep layers (crystal sparkles in the crystal layer, embers in the magma core)
local STYLE_IMPACT = {
	Sparks = {Colors = {Color3.new(1, 1, 1), Color3.fromRGB(90, 235, 255)}, Count = 14, Speed = 18, Size = 0.14, Life = 0.35, Gravity = -40},
	Electric = {Colors = {Color3.new(1, 1, 1), Color3.fromRGB(120, 200, 255)}, Count = 18, Speed = 26, Size = 0.12, Life = 0.2, Gravity = 0},
	Ice = {Colors = {Color3.new(1, 1, 1), Color3.fromRGB(150, 225, 255)}, Count = 16, Speed = 14, Size = 0.3, Life = 0.6, Gravity = -50},
	Fire = {Colors = {Color3.fromRGB(255, 240, 150), Color3.fromRGB(255, 90, 20)}, Count = 18, Speed = 10, Size = 0.4, Life = 0.5, Gravity = 12},
	Galaxy = {Colors = {Color3.fromRGB(255, 150, 240), Color3.fromRGB(90, 110, 255)}, Count = 20, Speed = 8, Size = 0.3, Life = 0.9, Gravity = 0},
	Glitch = {Colors = {Color3.fromRGB(255, 60, 200), Color3.fromRGB(60, 255, 230)}, Count = 22, Speed = 20, Size = 0.28, Life = 0.18, Gravity = 0},
}
local LAYER_SPARKS = { -- by depth zone index (3 = crystal layer, 4 = magma core)
	[3] = {Colors = {Color3.new(1, 1, 1), Color3.fromRGB(120, 230, 255)}, Count = 12, Speed = 9, Size = 0.18, Life = 0.7, Gravity = -6},
	[4] = {Colors = {Color3.fromRGB(255, 220, 120), Color3.fromRGB(255, 70, 20)}, Count = 16, Speed = 12, Size = 0.2, Life = 0.8, Gravity = 10},
}
local function sparkBurst(anchor, spec)
	local e = Instance.new("ParticleEmitter")
	e.Enabled = false
	e.Color = ColorSequence.new(spec.Colors[1], spec.Colors[2])
	e.LightEmission = 1
	e.Size = NumberSequence.new(spec.Size, 0)
	e.Lifetime = NumberRange.new(spec.Life * 0.6, spec.Life)
	e.Speed = NumberRange.new(spec.Speed * 0.5, spec.Speed)
	e.SpreadAngle = Vector2.new(70, 70)
	e.EmissionDirection = Enum.NormalId.Top
	e.Acceleration = Vector3.new(0, spec.Gravity, 0)
	e.RotSpeed = NumberRange.new(-200, 200)
	e.Parent = anchor
	e:Emit(spec.Count)
end

local function impactBurst(position, color, toolStyle, zoneIndex)
	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.Transparency = 1
	anchor.Size = Vector3.one
	anchor.CFrame = CFrame.new(position)
	anchor.Parent = puppetFolder
	local chunks = Instance.new("ParticleEmitter")
	chunks.Enabled = false
	chunks.Color = ColorSequence.new(color, color:Lerp(Color3.new(0, 0, 0), 0.3))
	chunks.Size = NumberSequence.new(0.32, 0.1)
	chunks.Lifetime = NumberRange.new(0.35, 0.7)
	chunks.Speed = NumberRange.new(10, 20)
	chunks.SpreadAngle = Vector2.new(55, 55)
	chunks.EmissionDirection = Enum.NormalId.Top
	chunks.Acceleration = Vector3.new(0, -60, 0)
	chunks.Rotation = NumberRange.new(0, 360)
	chunks.RotSpeed = NumberRange.new(-300, 300)
	chunks.Parent = anchor
	chunks:Emit(16)
	local puff = Instance.new("ParticleEmitter")
	puff.Enabled = false
	puff.Color = ColorSequence.new(color:Lerp(Color3.new(1, 1, 1), 0.35))
	puff.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 2.6)})
	puff.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 1)})
	puff.Lifetime = NumberRange.new(0.5, 0.8)
	puff.Speed = NumberRange.new(2, 5)
	puff.SpreadAngle = Vector2.new(80, 80)
	puff.EmissionDirection = Enum.NormalId.Top
	puff.Drag = 4
	puff.Parent = anchor
	puff:Emit(8)
	if toolStyle and STYLE_IMPACT[toolStyle] then sparkBurst(anchor, STYLE_IMPACT[toolStyle]) end
	if zoneIndex and LAYER_SPARKS[zoneIndex] then sparkBurst(anchor, LAYER_SPARKS[zoneIndex]) end
	Debris:AddItem(anchor, 1.2)

	local ring = Instance.new("Part")
	ring.Shape = Enum.PartType.Cylinder
	ring.Anchored = true
	ring.CanCollide = false
	ring.CanQuery = false
	ring.CanTouch = false
	ring.CastShadow = false
	ring.Material = Enum.Material.SmoothPlastic
	ring.Color = color:Lerp(Color3.new(1, 1, 1), 0.3)
	ring.Transparency = 0.45
	ring.Size = Vector3.new(0.15, 1, 1)
	ring.CFrame = CFrame.new(position + Vector3.new(0, 0.15, 0)) * CFrame.Angles(0, 0, math.rad(90))
	ring.Parent = puppetFolder
	TweenService:Create(ring, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Vector3.new(0.15, 7, 7), Transparency = 1}):Play()
	Debris:AddItem(ring, 0.4)
end

local function dirtColorAt(position)
	local world = GameConfig.GetWorldAt(position)
	local _, zone = GameConfig.GetZoneAt(world, position.Y - 3)
	return zone and zone.Color or Color3.fromRGB(150, 110, 80)
end

local function startSwing(character, length)
	local rig = character and rigs[character]
	if not rig then return end
	rig.SwingStart = os.clock()
	rig.SwingLength = length
	rig.Struck = false
	rig.Flung = false
	if rig.EquipStart then -- digging cuts the equip flourish short
		rig.EquipStart = nil
		for _, p in ipairs(rig.Puppet) do p.Part.LocalTransparencyModifier = 0 end
	end
end

local function rigColors(rig)
	local a, b = rig.Tool:GetAttribute("TrailColorA"), rig.Tool:GetAttribute("TrailColorB")
	if typeof(a) == "Color3" and typeof(b) == "Color3" then return a, b end
	return Color3.new(1, 1, 1), Color3.fromRGB(255, 220, 110)
end

local function poseRig(character, rig, clock, dt)
	local moving = rig.Humanoid and math.clamp(rig.Humanoid.MoveDirection.Magnitude, 0, 1) or 0
	local target
	local trailOn = false
	local toss -- 0-1 while the pickaxe is in the air during the equip flip
	if rig.EquipStart and not rig.SwingStart then
		local t = (clock - rig.EquipStart) / EQUIP_LENGTH
		if t >= 1 then
			rig.EquipStart = nil
			target = idlePose(clock, moving)
		else
			target = samplePose(t, EQUIP)
			-- fade in at the start
			local fade = 1 - math.clamp(t / 0.12, 0, 1)
			for _, p in ipairs(rig.Puppet) do p.Part.LocalTransparencyModifier = fade end
			if t > TOSS_FROM and t < TOSS_TO then
				toss = (t - TOSS_FROM) / (TOSS_TO - TOSS_FROM)
				trailOn = true
			end
			if not rig.Caught and t >= TOSS_TO then
				rig.Caught = true
				if rig.Blade then
					local a, b = rigColors(rig)
					sparkle(rig.Blade.Position, a, b, 26, 14)
				end
				if character == player.Character and onEquipCatch then onEquipCatch() end
			end
			if not rig.Landed and t >= 0.66 then
				rig.Landed = true
				trailOn = true
				if rig.Blade then
					local a, b = rigColors(rig)
					sparkle(rig.Blade.Position, b, a, 12, 7)
				end
			end
			if t > 0.52 and t < 0.68 then trailOn = true end
		end
		if rig.EquipStart == nil then
			for _, p in ipairs(rig.Puppet) do p.Part.LocalTransparencyModifier = 0 end
		end
	elseif rig.SwingStart then
		-- hit-stop: time stands still for a moment right at the impact
		local elapsed = clock - rig.SwingStart
		local strikeAt = rig.SwingLength * STRIKE_TIME
		if elapsed > strikeAt then
			elapsed -= math.min(elapsed - strikeAt, HIT_STOP)
		end
		local t = elapsed / rig.SwingLength
		if t >= 1 then
			rig.SwingStart = nil
			target = idlePose(clock, moving)
		else
			target = samplePose(t)
			for _, window in ipairs(TRAILS) do
				if t > window[1] and t < window[2] then trailOn = true end
			end
			if not rig.Flung and t >= FLING_TIME then
				rig.Flung = true
				if rig.Blade then
					flingDirt(rig.Root, rig.Blade.Position, dirtColorAt(rig.Root.Position), character == player.Character and 6 or 3)
				end
			end
			if not rig.Struck and t >= STRIKE_TIME then
				rig.Struck = true
				rig.ImpactAt = clock
				if rig.Blade then
					local color = dirtColorAt(rig.Root.Position)
					local world = GameConfig.GetWorldAt(rig.Root.Position)
					local zoneIndex = GameConfig.GetZoneAt(world, rig.Root.Position.Y - 3)
					tossDirt(rig.Blade.Position, color)
					impactBurst(rig.Blade.Position, color, rig.Tool:GetAttribute("TrailStyle"), zoneIndex)
				end
				if character == player.Character and impactShake then
					impactShake()
				end
			end
		end
	else
		target = idlePose(clock, moving)
	end
	if rig.Trail then rig.Trail.Enabled = trailOn end

	-- impact wobble: the handle rings for a moment after the head bites the ground
	if rig.ImpactAt then
		local since = clock - rig.ImpactAt - HIT_STOP
		if since > 0 and since < 0.6 then
			local ring = math.exp(-WOBBLE.Decay * since) * math.sin(WOBBLE.Speed * since)
			target.Tilt += ring * WOBBLE.Degrees
			target.Hand += Vector3.new(0, ring * 0.06, 0)
		end
	end

	-- smoothing: every channel eases toward its target, so switching between idle and
	-- swinging (or starting a new swing mid-way) never snaps. Swings stay crisp.
	local smooth = rig.Smooth
	if not smooth then
		smooth = table.clone(target)
		rig.Smooth = smooth
	end
	local alpha = 1 - math.exp(-((rig.SwingStart or rig.EquipStart) and 45 or 12) * (dt or 1 / 60))
	smooth.Hand = smooth.Hand:Lerp(target.Hand, alpha)
	for _, c in ipairs(CHANNELS) do
		smooth[c] += ((target[c] or 0) - (smooth[c] or 0)) * alpha
	end
	local pose = smooth

	-- where the shovel goes (in root space): rotate the upright shovel by tilt and turn,
	-- then slide it along its shaft so the grip sits exactly in the hand
	local rotation = CFrame.Angles(0, math.rad(pose.Turn), 0) * CFrame.Angles(0, 0, math.rad(pose.Roll or 0))
		* CFrame.Angles(math.rad(pose.Tilt), 0, 0) * UPRIGHT
	local up = rotation.ZVector
	local hand = pose.Hand
	local origin = hand - up * rig.HoldZ
	local shovelCF = rig.Root.CFrame * CFrame.new(origin) * rotation

	-- keep the blade out of the ground: if its lowest point is below the surface under it,
	-- lift the shovel (and the hand holding it) just enough
	-- (the ray starts at hand height above the tip, which is always in open air, even in tunnels)
	local tip = (shovelCF * CFrame.new(0, 0, rig.TipZ)).Position
	local handY = (rig.Root.CFrame * hand).Y
	local startY = math.max(handY, tip.Y + 0.5)
	local hit = workspace:Raycast(Vector3.new(tip.X, startY, tip.Z), Vector3.new(0, -(startY - tip.Y) - 3, 0), rig.RayParams)
	if hit then
		local lift = (hit.Position.Y + 0.08) - tip.Y
		if lift > 0 then
			local liftLocal = rig.Root.CFrame:VectorToObjectSpace(Vector3.new(0, lift, 0))
			hand += liftLocal
			origin += liftLocal
			shovelCF = rig.Root.CFrame * CFrame.new(origin) * rotation
		end
	end

	-- the hand stays where the grip would be (reaching up to catch), the pickaxe flies:
	-- up in an arc above the hand, spinning end over end around the middle of its handle
	local handShovelCF = shovelCF
	if toss then
		local arc = 4 * TOSS_HEIGHT * toss * (1 - toss)
		local middle = rig.HoldZ * 0.5
		local spin = -easeOutSine(toss) * TOSS_SPINS * math.pi * 2
		shovelCF = CFrame.new(0, arc, 0) * shovelCF * CFrame.new(0, 0, middle) * CFrame.Angles(spin, 0, 0) * CFrame.new(0, 0, -middle)
	end

	local parts, cframes = {}, {}
	for i, p in ipairs(rig.Puppet) do
		parts[i] = p.Part
		local rel = p.Rel
		if p.Center and p.Speed then
			local pivot = CFrame.new(p.Center)
			rel = pivot * CFrame.Angles(0, 0, clock * p.Speed) * pivot:Inverse() * rel
		end
		cframes[i] = shovelCF * rel
	end
	workspace:BulkMoveTo(parts, cframes, Enum.BulkMoveMode.FireCFrameChanged)

	-- the hand goes exactly where a normal Roblox tool grip would put it on this shaft:
	-- handle = hand * gripAttachment * grip^-1, so hand = handle * grip * gripAttachment^-1
	local handCF = handShovelCF * CFrame.new(0, 0, rig.HoldZ) * rig.GripOffset:Inverse()
	rig.RightTarget.CFrame = rig.Root.CFrame:ToObjectSpace(handCF)
	if rig.LeftTarget then
		rig.LeftTarget.Position = rig.Root.CFrame:PointToObjectSpace((handShovelCF * CFrame.new(0, 0, rig.LeftHoldZ)).Position)
	end
	-- whole body: the torso bends and twists with the swing, the hips counter-turn a little,
	-- and the head follows the pickaxe (looks up at the top, down at the impact)
	if rig.Waist then
		rig.Waist.C0 = rig.WaistC0 * CFrame.Angles(math.rad(-pose.Lean), math.rad(pose.Twist), math.rad(pose.Bend))
	end
	-- legs: the knees bend and the body drops (feet stay planted), and the pelvis tips the
	-- whole upper body forward from the hips while the thighs stay put
	local crouch = math.rad(math.max(pose.Crouch or 0, 0))
	local hip = math.rad(pose.Hip or 0)
	local drop = rig.LegLength * 0.5 * (1 - math.cos(crouch)) * 2
	if rig.Hips then
		rig.Hips.C0 = CFrame.new(0, -drop, 0) * rig.HipsC0 * CFrame.Angles(-hip, math.rad(-pose.Twist * 0.35), 0)
	end
	for _, leg in ipairs(rig.Legs) do
		local angle = leg.Kind == "Hip" and crouch + hip or leg.Kind == "Knee" and -2 * crouch or crouch
		leg.Motor.C0 = leg.C0 * CFrame.Angles(angle, 0, 0)
	end
	if rig.Neck then
		rig.Neck.C0 = rig.NeckC0 * CFrame.Angles(math.rad(-pose.Look), math.rad(-pose.Twist * 0.4), 0)
	end
end

RunService.RenderStepped:Connect(function(dt)
	local clock = os.clock()
	-- find every character holding a shovel; build or tear down rigs to match
	for _, plr in ipairs(Players:GetPlayers()) do
		local character = plr.Character
		if character then
			local tool = character:FindFirstChildOfClass("Tool")
			if tool and not tool:GetAttribute("ShovelId") then tool = nil end
			local rig = rigs[character]
			if rig and rig.Tool ~= tool then
				destroyRig(character)
				rig = nil
			end
			if tool and not rig then
				rig = createRig(character, tool)
			end
		end
	end
	for character, rig in pairs(rigs) do
		if not character.Parent or not rig.Root.Parent then
			destroyRig(character)
		else
			poseRig(character, rig, clock, dt)
		end
	end
end)

swingFxRemote.OnClientEvent:Connect(function(otherPlayer, length)
	if typeof(otherPlayer) == "Instance" and otherPlayer:IsA("Player") and otherPlayer ~= player and typeof(length) == "number" then
		startSwing((otherPlayer :: Player).Character, math.clamp(length, 0.3, 1))
	end
end)

---------------------------------------------------------------------
-- DIG JUICE: screen shake, combo counter, sounds, bounce feedback
---------------------------------------------------------------------
local digHitRemote = remotes:WaitForChild("DigHit")

local Audio = require(ReplicatedStorage:WaitForChild("Audio"))


-- short, punchy camera shake (strength in studs)
local shakeUntil, shakeStrength = 0, 0
local function shake(strength, duration)
	shakeStrength = math.max(shakeStrength, strength)
	shakeUntil = math.max(shakeUntil, os.clock() + duration)
end
impactShake = function()
	shake(0.16, 0.1) -- a crisp little jolt right on the strike
end
onEquipCatch = function()
	shake(0.1, 0.08)
	Audio.sfx("Click")
end
RunService:BindToRenderStep("DigShake", Enum.RenderPriority.Camera.Value + 1, function()
	local left = shakeUntil - os.clock()
	if left <= 0 then
		shakeStrength = 0
		return
	end
	local s = shakeStrength * math.clamp(left / 0.15, 0, 1)
	camera.CFrame = camera.CFrame * CFrame.new((math.random() - 0.5) * s, (math.random() - 0.5) * s, 0)
		* CFrame.Angles(0, 0, math.rad((math.random() - 0.5) * s * 6))
end)

-- combo counter: pops up next to the hotbar while you keep digging
local comboLabel = UIKit.label(gui, "", {
	Size = UDim2.fromOffset(300, 44), Position = UDim2.new(0.5, 60, 1, -250), AnchorPoint = Vector2.new(0, 0),
	Align = "Left", Color = C.Sun, Stroke = 3.5, MaxText = 34,
})
comboLabel.Rotation = -6
comboLabel.Visible = false
local comboToken = 0
local COMBO_COLORS = {C.White, C.Sun, C.Sun, C.Mint, C.Mint, C.Sky, C.Sky, C.Lilac, C.Coral, C.Coral}

digHitRemote.OnClientEvent:Connect(function(info)
	if typeof(info) ~= "table" then return end
	if info.Bounced then
		shake(0.35, 0.18)
		Audio.sfx("Clang")
		comboLabel.Visible = false
		return
	end
	local combo = tonumber(info.Combo) or 1
	shake(0.05 + combo * 0.01, 0.1) -- the strike already shook; big combos shake a bit more
	Audio.sfx("Dig") -- rate-limited (max ~4 a second) with a random 0.95-1.05 pitch
	if typeof(info.Position) == "Vector3" and typeof(info.Color) == "Color3" then
		tossDirt(info.Position + Vector3.new(0, 1.5, 0), info.Color)
	end
	if combo >= 2 then
		comboToken += 1
		local myToken = comboToken
		comboLabel.Text = "COMBO x" .. combo .. "  +" .. (combo - 1) * 4 .. "% luck"
		comboLabel.TextColor3 = COMBO_COLORS[math.clamp(combo, 1, #COMBO_COLORS)]
		comboLabel.Visible = true
		UIKit.pop(comboLabel, 1.35)
		Audio.sfx("Combo", 0.9 + math.min(combo, 10) * 0.03)
		task.delay(1.5, function()
			if comboToken == myToken then comboLabel.Visible = false end
		end)
	end
end)

---------------------------------------------------------------------
-- SWINGING: click to dig, or hold the button to keep digging
---------------------------------------------------------------------
local lastSwing = 0
local holding = false

local function trySwing(def)
	local now = os.clock()
	-- world events and boosts (Gold Rush, Sugar Rush, Glitch Surge...) make swings faster
	local cooldown = def.Cooldown * (player:GetAttribute("DigSpeedMult") or 1)
	if now - lastSwing < cooldown then return end
	lastSwing = now

	local length = math.clamp(cooldown, 0.3, 0.5) -- overhead two-handed swing
	startSwing(player.Character, length)

	-- the dig happens exactly when the blade hits the ground
	local target = mouse.Hit and mouse.Hit.Position
	task.delay(length * STRIKE_TIME, function()
		swingRemote:FireServer(target, length)
	end)
end

local function onToolEquipped(tool)
	local def = GameConfig.GetShovel(tool:GetAttribute("ShovelId")) or GameConfig.Shovels[1]
	equippedDef = def
	depthPanel.Visible = true

	local activatedConn = tool.Activated:Connect(function()
		holding = true
		trySwing(def)
	end)
	local deactivatedConn = tool.Deactivated:Connect(function()
		holding = false
	end)
	-- while the button is held, dig again as soon as the shovel is ready
	local holdConn = RunService.Heartbeat:Connect(function()
		if holding and tool.Parent == player.Character then
			trySwing(def)
		end
	end)

	tool.Unequipped:Once(function()
		holding = false
		activatedConn:Disconnect()
		deactivatedConn:Disconnect()
		holdConn:Disconnect()
		if equippedDef == def then equippedDef = nil end
	end)
end

local function watchCharacter(character)
	character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") and child:GetAttribute("ShovelId") then
			onToolEquipped(child)
		end
	end)
end

player.CharacterAdded:Connect(watchCharacter)
if player.Character then
	watchCharacter(player.Character)
end

---------------------------------------------------------------------
-- SHOVEL SHOP WINDOW
---------------------------------------------------------------------
local window, content = UIKit.window(gui, "PICKAXE SHOP", UDim2.fromOffset(780, 580), C.Violet, "Pickaxe")

local moneyTag = UIKit.panel(content, {Size = UDim2.fromOffset(180, 38), Position = UDim2.new(1, 0, 0, 0), AnchorPoint = Vector2.new(1, 0), Color = C.Money, Radius = 19})
local moneyLabel = UIKit.label(moneyTag, "", {Size = UDim2.new(1, -24, 0.72, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2.5, StrokeColor = UIKit.shadeColor(C.Money, 0.6), MaxText = 24})
local worldLabel = UIKit.label(content, "", {Size = UDim2.new(1, -210, 0, 28), Position = UDim2.fromOffset(4, 5), Align = "Left", Color = C.Violet, Stroke = 0, MaxText = 24})

local listHolder = Instance.new("Frame")
listHolder.BackgroundTransparency = 1
listHolder.Size = UDim2.new(1, 0, 1, -48)
listHolder.Position = UDim2.fromOffset(0, 46)
listHolder.Parent = content
local list = UIKit.list(listHolder, 10)

local shopWorld = GameConfig.Worlds[1] -- which world's shop is open
local cards = {} -- [shovelId] = button

-- the best value of each stat in this world, so the bars fill relative to the top shovel
local function maxStat(world, key)
	local m = 0
	for _, def in ipairs(world.Shovels) do m = math.max(m, def[key]) end
	return m
end

local BUTTON_W = 116 -- the buy / equip button on each shop card

local function buildCards(world)
	for _, child in ipairs(list:GetChildren()) do
		if child:IsA("GuiObject") then child:Destroy() end
	end
	cards = {}
	worldLabel.Text = world.Name
	local maxFind, maxLuck, maxPower = maxStat(world, "FindChance"), maxStat(world, "Luck"), maxStat(world, "Power")
	local minCooldown = math.huge
	for _, def in ipairs(world.Shovels) do minCooldown = math.min(minCooldown, def.Cooldown) end
	local starterCooldown = world.Shovels[1].Cooldown
	local maxSpeed = starterCooldown / minCooldown

	for i, def in ipairs(world.Shovels) do
		local zone = world.Zones[def.MaxZone]
		local card = UIKit.panel(list, {Size = UDim2.new(1, -6, 0, 132), Color = C.White, Radius = 20, ShadeAmount = 0.06})
		card.LayoutOrder = i
		-- icon on a colored plate (plate color = the deepest zone it reaches)
		local plate = UIKit.panel(card, {Size = UDim2.fromOffset(108, 108), Position = UDim2.new(0, 12, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Color = zone.Color, Radius = 18, ShadeAmount = 0.2})
		UIKit.shovelIcon(plate, def, {Size = UDim2.fromScale(1, 1)})
		-- middle column: name, depth badge, description (sized to the column so nothing overlaps)
		UIKit.label(card, def.Name, {Size = UDim2.new(0.5, -140, 0, 26), Position = UDim2.fromOffset(134, 10), Align = "Left", Color = C.Ink, Stroke = 0, MaxText = 24})
		local zoneTag = UIKit.panel(card, {Size = UDim2.new(0.5, -140, 0, 24), Position = UDim2.fromOffset(134, 40), Color = zone.Color, Radius = 12})
		UIKit.label(zoneTag, "▼ " .. -zone.Bottom .. "m  •  " .. string.upper(zone.Name), {Size = UDim2.new(1, -14, 0.72, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2, StrokeColor = C.Ink, MaxText = 15})
		UIKit.label(card, def.Description, {Size = UDim2.new(0.5, -140, 0, 52), Position = UDim2.fromOffset(134, 70), Align = "Left", VAlign = "Top", Color = C.Grey, Stroke = 0, Font = UIKit.BodyFont, TextSize = 13})

		-- right column: stat bars. Speed is shown as a multiplier of the starter pickaxe (1.5x = 50% faster swings)
		local statsBox = Instance.new("Frame")
		statsBox.BackgroundTransparency = 1
		-- fills the space between the middle column and the button, with a gap before the button
		statsBox.Size = UDim2.new(0.5, -(BUTTON_W + 44), 0, 90)
		statsBox.Position = UDim2.new(0.5, 0, 0.5, -45)
		statsBox.Parent = card
		local speed = starterCooldown / def.Cooldown
		UIKit.statBar(statsBox, "Power", def.Power / maxPower, tostring(def.Power), C.Coral, {Size = UDim2.new(1, 0, 0, 19), Position = UDim2.fromOffset(0, 0)})
		UIKit.statBar(statsBox, "Find", def.FindChance / maxFind, math.floor(def.FindChance * 1000 + 0.5) / 10 .. "%", C.Mint, {Size = UDim2.new(1, 0, 0, 19), Position = UDim2.fromOffset(0, 23)})
		UIKit.statBar(statsBox, "Luck", def.Luck / maxLuck, "x" .. def.Luck, C.Sun, {Size = UDim2.new(1, 0, 0, 19), Position = UDim2.fromOffset(0, 46)})
		UIKit.statBar(statsBox, "Speed", speed / maxSpeed, string.format("%.1fx", speed), C.Sky, {Size = UDim2.new(1, 0, 0, 19), Position = UDim2.fromOffset(0, 69)})

		local b = UIKit.button(card, "", {Size = UDim2.fromOffset(BUTTON_W, 54), Position = UDim2.new(1, -14, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5)})
		cards[def.Id] = b
		b.MouseButton1Click:Connect(function()
			local owned = string.split(player:GetAttribute("OwnedShovels") or "", ",")
			if table.find(owned, def.Id) then
				equipShovelRemote:FireServer(def.Id)
			else
				buyShovelRemote:FireServer(def.Id)
			end
		end)
	end
end

local function refreshShop()
	local money = player:GetAttribute("Money") or 0
	local owned = string.split(player:GetAttribute("OwnedShovels") or "", ",")
	local equipped = player:GetAttribute("EquippedShovel")
	moneyLabel.Text = ArtifactData.FormatMoney(money)
	for _, def in ipairs(shopWorld.Shovels) do
		local b = cards[def.Id]
		if b then
			if def.Id == equipped then
				UIKit.setButton(b, "EQUIPPED", C.Lilac)
			elseif table.find(owned, def.Id) then
				UIKit.setButton(b, "EQUIP", C.Sky)
			else
				UIKit.setButton(b, def.Price <= 0 and "FREE" or ArtifactData.FormatMoney(def.Price), money >= def.Price and C.Mint or C.Coral)
			end
		end
	end
end

for _, attribute in ipairs({"Money", "OwnedShovels", "EquippedShovel"}) do
	player:GetAttributeChangedSignal(attribute):Connect(function()
		if window.Visible then refreshShop() end
	end)
end

local function openShop(worldId)
	local world = GameConfig.GetWorld(worldId) or GameConfig.Worlds[1]
	if world ~= shopWorld or next(cards) == nil then
		shopWorld = world
		buildCards(world)
	end
	refreshShop()
	UIKit.open(window)
end
openShopRemote.OnClientEvent:Connect(openShop)
-- the SHOP button on the HUD opens the shop of the world you're in, from anywhere
require(ReplicatedStorage:WaitForChild("UIBus")).On("Shop", function()
	if window.Visible then
		window.Visible = false
	else
		openShop(player:GetAttribute("CurrentWorld") or 1)
	end
end)

shopMessageRemote.OnClientEvent:Connect(function(message, success)
	showHint(message, success and C.Mint or C.Coral)
end)
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "ShovelSpinner", "LocalScript", [=[
-- ShovelSpinner (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Spins the orbiting crystals of the crystal shovels on display in the Shovel Shops.
-- (Shovels in players' hands are spun by ShovelClient's pose system.)
-- ShopBuilder tags each orbiting part "ShovelOrbit" and gives it OrbitPivot, OrbitOffset
-- and OrbitSpeed attributes; the spin is local to each player, so it costs the server nothing.

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local spinning = {} -- [part] = {Pivot, Offset, Speed}

local function add(part)
	local pivot, offset = part:GetAttribute("OrbitPivot"), part:GetAttribute("OrbitOffset")
	if typeof(pivot) == "CFrame" and typeof(offset) == "CFrame" then
		spinning[part] = {Pivot = pivot, Offset = offset, Speed = part:GetAttribute("OrbitSpeed") or 2}
	end
end
CollectionService:GetInstanceAddedSignal("ShovelOrbit"):Connect(add)
CollectionService:GetInstanceRemovedSignal("ShovelOrbit"):Connect(function(part)
	spinning[part] = nil
end)
for _, part in ipairs(CollectionService:GetTagged("ShovelOrbit")) do
	add(part)
end

RunService.RenderStepped:Connect(function()
	local t = os.clock()
	local parts, cframes = {}, {}
	for part, spin in pairs(spinning) do
		if part.Parent then
			table.insert(parts, part)
			table.insert(cframes, spin.Pivot * CFrame.Angles(0, 0, t * spin.Speed) * spin.Offset)
		else
			spinning[part] = nil
		end
	end
	if #parts > 0 then
		workspace:BulkMoveTo(parts, cframes, Enum.BulkMoveMode.FireCFrameChanged)
	end
end)
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "SkyPlanets", "LocalScript", [=[
-- SkyPlanets (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The interconnected skybox: the other 8 worlds hang high in the sky as big faint planets,
-- each in its world's colors, so from any world you can see where else you could go.
-- Each planet is a softly transparent sphere inside a larger Neon glow shell (so it blends
-- into the haze like a distant moon); some get a ring. They sit far out and high up, spin
-- slowly, and move to surround whichever world you travel to. Local to this screen only.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local player = Players.LocalPlayer

local DISTANCE = 1900          -- studs from the world you're in
local HEIGHT = {750, 1150}     -- studs above it
local SIZE = {240, 420}        -- planet diameter
local BODY_TRANSPARENCY = 0.35 -- the planet itself
local GLOW_TRANSPARENCY = 0.86 -- the Neon halo around it
local HOME_COLOR = Color3.fromRGB(112, 204, 108) -- World 1 has no theme colors

local folder = Instance.new("Folder")
folder.Name = "SkyPlanets"
folder.Parent = workspace

local planets = {} -- [worldId] = {Model, Body, Glow, Ring, Offset, Spin}

local function part(name, shape, size, color, material, transparency)
	local p = Instance.new("Part")
	p.Name = name
	p.Shape = shape
	p.Size = size
	p.Color = color
	p.Material = material
	p.Transparency = transparency
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	return p
end

for _, world in ipairs(GameConfig.Worlds) do
	local main = world.Look and world.Look.Main or HOME_COLOR
	local glowColor = world.Look and world.Look.Glow or Color3.fromRGB(150, 230, 255)
	local rng = Random.new(world.Id * 131)
	local size = SIZE[1] + (SIZE[2] - SIZE[1]) * rng:NextNumber()
	local model = Instance.new("Model")
	model.Name = "Planet_" .. world.Name
	local body = part("Planet", Enum.PartType.Ball, Vector3.one * size, main, Enum.Material.SmoothPlastic, BODY_TRANSPARENCY)
	body.Parent = model
	local glow = part("Glow", Enum.PartType.Ball, Vector3.one * size * 1.18, glowColor, Enum.Material.Neon, GLOW_TRANSPARENCY)
	glow.Parent = model
	-- a darker band so it reads as a planet, not a ball
	local band = part("Band", Enum.PartType.Cylinder, Vector3.new(size * 0.16, size * 1.005, size * 1.005), main:Lerp(Color3.new(0, 0, 0), 0.25), Enum.Material.SmoothPlastic, BODY_TRANSPARENCY)
	band.Parent = model
	local ring
	if world.Id % 3 == 0 then
		ring = part("Ring", Enum.PartType.Cylinder, Vector3.new(size * 0.02, size * 2, size * 2), glowColor, Enum.Material.Neon, 0.7)
		ring.Parent = model
	end
	model.Parent = nil -- shown when its turn comes
	planets[world.Id] = {
		Model = model, Body = body, Glow = glow, Band = band, Ring = ring,
		Angle = (world.Id - 1) / #GameConfig.Worlds * math.pi * 2 + rng:NextNumber(-0.2, 0.2),
		Height = HEIGHT[1] + (HEIGHT[2] - HEIGHT[1]) * rng:NextNumber(),
		Tilt = CFrame.Angles(rng:NextNumber(-0.5, 0.5), 0, rng:NextNumber(0.2, 0.6)),
		Spin = rng:NextNumber(0.02, 0.06),
	}
end

local centers = {} -- [worldId] = CFrame of the planet around the current world
local function arrange()
	local current = GameConfig.GetWorld(player:GetAttribute("CurrentWorld") or 1) or GameConfig.Worlds[1]
	for id, planet in pairs(planets) do
		if id == current.Id then
			planet.Model.Parent = nil -- no planet for the world you're standing on
			centers[id] = nil
		else
			local offset = Vector3.new(math.cos(planet.Angle) * DISTANCE, planet.Height, math.sin(planet.Angle) * DISTANCE)
			centers[id] = CFrame.new(current.Origin + offset) * planet.Tilt
			planet.Model.Parent = folder
		end
	end
end
player:GetAttributeChangedSignal("CurrentWorld"):Connect(arrange)
arrange()

RunService.Heartbeat:Connect(function()
	local t = os.clock()
	local parts, cframes = {}, {}
	for id, center in pairs(centers) do
		local planet = planets[id]
		local spun = center * CFrame.Angles(0, t * planet.Spin, 0)
		table.insert(parts, planet.Body); table.insert(cframes, spun)
		table.insert(parts, planet.Glow); table.insert(cframes, spun)
		table.insert(parts, planet.Band); table.insert(cframes, spun * CFrame.Angles(0, 0, math.rad(90)))
		if planet.Ring then
			table.insert(parts, planet.Ring); table.insert(cframes, center * CFrame.Angles(0, 0, math.rad(90)))
		end
	end
	if #parts > 0 then
		workspace:BulkMoveTo(parts, cframes, Enum.BulkMoveMode.FireCFrameChanged)
	end
end)
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "TutorialClient", "LocalScript", [=[
-- TutorialClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The first-join walkthrough (TutorialManager runs the steps on the server):
--   a "WELCOME, ARCHAEOLOGIST!" splash, then a step card on the left of the screen
--   (1 Equip Pickaxe -> 2 Jump into Pit -> 3 Dig Up Framed Artifacts -> 4 Display in Museum),
--   a glowing guide beam from your character to where you need to go, and a bouncing arrow
--   over the target. A Skip button ends it for good.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local skipRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TutorialSkip")
local player = Players.LocalPlayer

local STEPS = {
	{Icon = "Pickaxe", Title = "Equip your pickaxe", Text = "Press 1, or click the pickaxe in your hotbar at the bottom of the screen."},
	{Icon = "Hole", Title = "Jump into the pit", Text = "Follow the glowing trail to the dig site and hop down into the dirt!"},
	{Icon = "Picture", Title = "Dig up a framed artifact", Text = "Click the ground to swing. Keep digging until an artifact appears, then hold E to pull it out!"},
	{Icon = "Museum", Title = "Display it in your museum", Text = "Follow the trail home and press E at a glowing pedestal to put your meme on show."},
}
local STEP_COLORS = {C.Sun, C.Mint, C.Coral, C.Violet}

local gui = UIKit.screen(player, "TutorialGui", 6)

---------------------------------------------------------------------
-- WELCOME SPLASH
---------------------------------------------------------------------
local splash = UIKit.panel(gui, {Size = UDim2.fromOffset(520, 150), Position = UDim2.fromScale(0.5, 0.36), AnchorPoint = Vector2.new(0.5, 0.5),
	Color = C.Ink, Radius = 30, Stroke = 4, StrokeColor = C.Sun, ShadeAmount = 0.2})
splash.BackgroundTransparency = 0.06
splash.Visible = false
UIKit.label(splash, "WELCOME, ARCHAEOLOGIST!", {Size = UDim2.new(1, -40, 0, 46), Position = UDim2.new(0.5, 0, 0, 22), AnchorPoint = Vector2.new(0.5, 0),
	Color = C.Sun, Stroke = 3, MaxText = 38})
UIKit.label(splash, "It's 2050. The old internet is buried under your feet.\nLet's dig up your first meme!", {Size = UDim2.new(1, -50, 0, 52),
	Position = UDim2.new(0.5, 0, 0, 78), AnchorPoint = Vector2.new(0.5, 0), Color = C.White, Stroke = 0, Font = UIKit.BodyFont, MaxText = 20})

---------------------------------------------------------------------
-- STEP CARD
---------------------------------------------------------------------
local card = UIKit.panel(gui, {Size = UDim2.fromOffset(330, 178), Position = UDim2.fromOffset(100, 96), Color = C.Ink, Radius = 22, Stroke = 3, StrokeColor = C.Sky, ShadeAmount = 0.2})
card.BackgroundTransparency = 0.08
card.Visible = false
local cardStroke = card:FindFirstChildOfClass("UIStroke")
local stepTag = UIKit.label(card, "", {Size = UDim2.new(1, -110, 0, 18), Position = UDim2.fromOffset(16, 12), Align = "Left", Color = C.Sky, Stroke = 0, MaxText = 15})
local badge, badgeIcon = UIKit.badge(card, "Pickaxe", C.Sun, {Diameter = 50, Position = UDim2.fromOffset(14, 38)})
local title = UIKit.label(card, "", {Size = UDim2.new(1, -90, 0, 28), Position = UDim2.fromOffset(74, 38), Align = "Left", Color = C.White, Stroke = 2, MaxText = 22})
local body = UIKit.label(card, "", {Size = UDim2.new(1, -90, 0, 58), Position = UDim2.fromOffset(74, 68), Align = "Left", VAlign = "Top",
	Color = C.PanelTint, Stroke = 0, Font = UIKit.BodyFont, TextSize = 15})
local dots = {}
for i = 1, #STEPS do
	dots[i] = UIKit.panel(card, {Size = UDim2.fromOffset(40, 8), Position = UDim2.new(0, 16 + (i - 1) * 48, 1, -22), Color = C.Grey, Radius = 4, Stroke = false, Shade = false})
end
local skipButton = UIKit.button(card, "SKIP", {Size = UDim2.fromOffset(70, 30), Position = UDim2.new(1, -12, 0, 8), AnchorPoint = Vector2.new(1, 0), Color = C.Grey, Radius = 12, MaxText = 14})
skipButton.MouseButton1Click:Connect(function()
	skipRemote:FireServer()
end)

-- step 1: a bouncing arrow pointing down at the hotbar
local hotbarArrow = UIKit.label(gui, "▼", {Size = UDim2.fromOffset(60, 60), Position = UDim2.new(0.5, 0, 1, -140), AnchorPoint = Vector2.new(0.5, 1),
	Color = C.Sun, Stroke = 3, MaxText = 56})
hotbarArrow.Visible = false

-- the "done!" toast
local toast = UIKit.panel(gui, {Size = UDim2.fromOffset(460, 70), Position = UDim2.fromScale(0.5, 0.3), AnchorPoint = Vector2.new(0.5, 0.5),
	Color = C.Mint, Radius = 35, Stroke = 4, StrokeColor = C.Ink})
toast.Visible = false
UIKit.icon(toast, "Party", {Size = UDim2.fromOffset(84, 84), Position = UDim2.new(0, -18, 0.5, -6), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 2})
UIKit.label(toast, "TUTORIAL COMPLETE! Your meme is earning money!", {Size = UDim2.new(1, -90, 0.6, 0), Position = UDim2.new(0.5, 30, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5), Color = C.White, Stroke = 2.5, MaxText = 22})

---------------------------------------------------------------------
-- GUIDE BEAM + ARROW IN THE WORLD
---------------------------------------------------------------------
local targetPart = Instance.new("Part")
targetPart.Name = "TutorialTarget"
targetPart.Anchored = true
targetPart.CanCollide = false
targetPart.CanQuery = false
targetPart.CanTouch = false
targetPart.Transparency = 1
targetPart.Size = Vector3.one
local targetAttachment = Instance.new("Attachment")
targetAttachment.Parent = targetPart
local arrowGui = Instance.new("BillboardGui")
arrowGui.Size = UDim2.fromOffset(90, 90)
arrowGui.AlwaysOnTop = true
arrowGui.LightInfluence = 0
arrowGui.Parent = targetPart
local worldArrow = UIKit.label(arrowGui, "▼", {Size = UDim2.fromScale(1, 1), Color = C.Sun, Stroke = 3, MaxText = 80})

local beam = Instance.new("Beam")
beam.Attachment1 = targetAttachment
beam.FaceCamera = true
beam.Width0 = 1.2
beam.Width1 = 1.2
beam.Segments = 60
beam.LightEmission = 0.8
beam.LightInfluence = 0
beam.Color = ColorSequence.new(Color3.fromRGB(120, 240, 255), Color3.fromRGB(255, 230, 120))
beam.Parent = targetPart

local function myMuseumSlot()
	for _, museum in ipairs(workspace:WaitForChild("Museums"):GetChildren()) do
		if museum:GetAttribute("OwnerUserId") == player.UserId then
			local slots = museum:FindFirstChild("Slots")
			local slot = slots and slots:FindFirstChild("Slot1")
			local spot = slot and (slot:FindFirstChild("DisplaySpot") or slot:FindFirstChild("ViewSpot"))
			if spot then return spot.Position end
		end
	end
	return nil
end

local function myBuriedPainting()
	local finds = workspace:FindFirstChild("BuriedFinds")
	for _, model in ipairs(finds and finds:GetChildren() or {}) do
		if model:GetAttribute("Owner") == player.UserId and model.PrimaryPart then
			return model.PrimaryPart.Position
		end
	end
	return nil
end

-- where the trail leads for each step (nil = no trail)
local function targetFor(step, root)
	if step == 2 then
		local world = GameConfig.Worlds[1]
		local flat = (root.Position - world.Origin) * Vector3.new(1, 0, 1)
		local dir = flat.Magnitude > 1 and flat.Unit or Vector3.zAxis
		return world.Origin + dir * (world.PitRadius - 8) + Vector3.new(0, 3, 0)
	elseif step == 3 then
		return myBuriedPainting()
	elseif step == 4 then
		return myMuseumSlot()
	end
	return nil
end

---------------------------------------------------------------------
-- SHOWING THE STEPS
---------------------------------------------------------------------
local shownStep = 0
local welcomed = false
local fromAttachment

local function showStep(step)
	if step == shownStep then return end
	local finished = shownStep > 0 and step == 0
	shownStep = step
	card.Visible = step > 0
	if finished then
		toast.Visible = true
		UIKit.pop(toast, 0.4)
		task.delay(4, function() toast.Visible = false end)
	end
	if step == 0 then return end
	if not welcomed and step == 1 then
		welcomed = true
		splash.Visible = true
		UIKit.pop(splash, 0.5)
		task.delay(3.2, function() splash.Visible = false end)
	end
	local info = STEPS[step]
	local color = STEP_COLORS[step]
	stepTag.Text = "TUTORIAL  ·  STEP " .. step .. " OF " .. #STEPS
	title.Text = info.Title
	body.Text = info.Text
	UIKit.setIcon(badgeIcon, info.Icon)
	badge.BackgroundColor3 = color
	cardStroke.Color = color
	for i, dot in ipairs(dots) do
		dot.BackgroundColor3 = i < step and C.Mint or (i == step and color or C.Grey)
	end
	UIKit.pop(card, 0.8)
end

local function onTutorialChanged()
	showStep(player:GetAttribute("Tutorial") or 0)
end
player:GetAttributeChangedSignal("Tutorial"):Connect(onTutorialChanged)
onTutorialChanged()

RunService.RenderStepped:Connect(function()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local clock = os.clock()
	hotbarArrow.Visible = shownStep == 1
	if hotbarArrow.Visible then
		hotbarArrow.Position = UDim2.new(0.5, 0, 1, -140 + math.sin(clock * 6) * 10)
	end
	local target = root and shownStep > 0 and targetFor(shownStep, root)
	if not target then
		targetPart.Parent = nil
		return
	end
	-- the trail starts at our character
	if not fromAttachment or fromAttachment.Parent ~= root then
		fromAttachment = Instance.new("Attachment")
		fromAttachment.Name = "TutorialTrailStart"
		fromAttachment.Position = Vector3.new(0, -1.5, 0)
		fromAttachment.Parent = root
		beam.Attachment0 = fromAttachment
	end
	targetPart.CFrame = CFrame.new(target)
	targetPart.Parent = workspace
	arrowGui.StudsOffset = Vector3.new(0, 4 + math.sin(clock * 5) * 0.8, 0)
	worldArrow.TextColor3 = STEP_COLORS[shownStep]
	-- glowing pulses run along the trail toward the target
	local keys = {}
	for i = 0, 17 do
		local x = i / 17
		local wave = 0.5 + 0.5 * math.sin((x * 8 - clock * 2.5) * math.pi * 2)
		table.insert(keys, NumberSequenceKeypoint.new(x, 0.15 + 0.6 * (1 - wave)))
	end
	beam.Transparency = NumberSequence.new(keys)
end)

]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "WorldClient", "LocalScript", [=[
-- WorldClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The World Map opened at any World Gate: a card per world showing whether it's unlocked,
-- its price, and a button to unlock it or travel there.
-- Also changes the sky and lighting to each world's mood when you travel there.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local WorldGimmicks = require(ReplicatedStorage:WaitForChild("WorldGimmicks"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local openWorldMapRemote = remotes:WaitForChild("OpenWorldMap")
local buyWorldRemote = remotes:WaitForChild("BuyWorld")
local travelRemote = remotes:WaitForChild("TravelToWorld")

local player = Players.LocalPlayer
local gui = UIKit.screen(player, "WorldMapGui", 3)

local window, content = UIKit.window(gui, "WORLD MAP", UDim2.fromOffset(680, 560), C.Sky, "World")

local moneyTag = UIKit.panel(content, {Size = UDim2.fromOffset(180, 38), Position = UDim2.new(1, 0, 0, 0), AnchorPoint = Vector2.new(1, 0), Color = C.Money, Radius = 19})
local moneyLabel = UIKit.label(moneyTag, "", {Size = UDim2.new(1, -24, 0.72, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2.5, StrokeColor = UIKit.shadeColor(C.Money, 0.6), MaxText = 24})
UIKit.label(content, "Unlock new dig sites with cash!", {Size = UDim2.new(1, -210, 0, 28), Position = UDim2.fromOffset(4, 5), Align = "Left", Color = C.Violet, Stroke = 0, MaxText = 22})

local listHolder = Instance.new("Frame")
listHolder.BackgroundTransparency = 1
listHolder.Size = UDim2.new(1, 0, 1, -48)
listHolder.Position = UDim2.fromOffset(0, 46)
listHolder.Parent = content
local list = UIKit.list(listHolder, 10)

local PLANET_COLORS = {C.Mint, C.Sun, C.Coral, C.Sky, C.Lilac, C.Violet, C.Money, C.Coral, C.Sky}
local buttons = {} -- [worldId] = button

for _, world in ipairs(GameConfig.Worlds) do
	local planetColor = world.Look and world.Look.Main or PLANET_COLORS[world.Id] or C.Lilac
	local card = UIKit.panel(list, {Size = UDim2.new(1, -6, 0, 108), Color = world.Enabled and C.White or C.PanelTint, Radius = 20, Stroke = 3, StrokeColor = planetColor, ShadeAmount = 0.06})
	-- a soft wash of the world's color across the card (a little preview of its look)
	local wash = Instance.new("UIGradient")
	wash.Color = ColorSequence.new(planetColor:Lerp(Color3.new(1, 1, 1), 0.55), Color3.new(1, 1, 1))
	wash.Transparency = NumberSequence.new(0, 0)
	wash.Parent = card
	card.LayoutOrder = world.Id
	-- little planet badge with the world number
	local planet = UIKit.panel(card, {Size = UDim2.fromOffset(62, 62), Position = UDim2.new(0, 12, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Color = planetColor, Radius = 31, ShadeAmount = 0.25})
	UIKit.label(planet, tostring(world.Id), {Size = UDim2.fromScale(0.56, 0.56), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 3, StrokeColor = UIKit.shadeColor(planetColor, 0.6), MaxText = 30})
	UIKit.label(card, world.Name, {Size = UDim2.new(0.62, -90, 0, 28), Position = UDim2.fromOffset(88, 10), Align = "Left", Color = C.Ink, Stroke = 0, MaxText = 24})
	-- the world's unique mechanic, as a tag
	local info = WorldGimmicks[world.Id]
	if info then
		local tag = UIKit.panel(card, {Size = UDim2.fromOffset(170, 24), Position = UDim2.fromOffset(88, 40), Color = C.Ink, Radius = 12, Stroke = 2, StrokeColor = planetColor, Shade = false})
		UIKit.icon(tag, info.Icon, {Size = UDim2.fromOffset(34, 34), Position = UDim2.new(0, -8, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 2})
		UIKit.label(tag, string.upper(info.Tag), {Size = UDim2.new(1, -40, 0.72, 0), Position = UDim2.new(0.5, 12, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.White, Stroke = 0, MaxText = 14})
	end
	local sub = world.Enabled and (world.Tagline or (#world.Shovels .. " pickaxes  •  digs down to " .. -world.Zones[#world.Zones].Bottom .. "m  •  your museum is here"))
		or "Still being excavated... coming soon!"
	UIKit.label(card, sub, {Size = UDim2.new(0.62, -90, 0, 34), Position = UDim2.fromOffset(88, 70), Align = "Left", VAlign = "Top", Color = C.Grey, Stroke = 0, Font = UIKit.BodyFont, TextSize = 13})

	local b = UIKit.button(card, "", {Icon = "World", Size = UDim2.new(0.3, 0, 0, 54), Position = UDim2.new(1, -14, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), MaxText = 20})
	buttons[world.Id] = b
	b.MouseButton1Click:Connect(function()
		local unlocked = table.find(string.split(player:GetAttribute("UnlockedWorlds") or "1", ","), tostring(world.Id))
		if not world.Enabled then
			return
		elseif unlocked then
			if player:GetAttribute("CurrentWorld") ~= world.Id then
				travelRemote:FireServer(world.Id)
				window.Visible = false
			end
		else
			buyWorldRemote:FireServer(world.Id)
		end
	end)
end

local function refresh()
	local money = player:GetAttribute("Money") or 0
	local unlocked = string.split(player:GetAttribute("UnlockedWorlds") or "1", ",")
	local current = player:GetAttribute("CurrentWorld") or 1
	moneyLabel.Text = ArtifactData.FormatMoney(money)
	for _, world in ipairs(GameConfig.Worlds) do
		local b = buttons[world.Id]
		if not world.Enabled then
			UIKit.setButton(b, "SOON • " .. ArtifactData.FormatMoney(world.Price), C.Grey, "Lock")
		elseif world.Id == current then
			UIKit.setButton(b, "YOU ARE HERE", C.Lilac, "Pin")
		elseif table.find(unlocked, tostring(world.Id)) then
			UIKit.setButton(b, "TRAVEL", C.Sky, "World")
		else
			UIKit.setButton(b, ArtifactData.FormatMoney(world.Price), money >= world.Price and C.Mint or C.Coral, "Lock")
		end
	end
end

for _, attribute in ipairs({"Money", "UnlockedWorlds", "CurrentWorld"}) do
	player:GetAttributeChangedSignal(attribute):Connect(function()
		if window.Visible then refresh() end
	end)
end

openWorldMapRemote.OnClientEvent:Connect(function()
	refresh()
	UIKit.open(window)
end)
-- the WORLDS button on the HUD opens the map from anywhere
require(ReplicatedStorage:WaitForChild("UIBus")).On("Teleport", function()
	if window.Visible then
		window.Visible = false
	else
		refresh()
		UIKit.open(window)
	end
end)

---------------------------------------------------------------------
-- WORLD SKIES: each world has its own time of day, haze and color grade (WorldsData.Sky).
-- World 1's look (set by MapStyle on the server) is remembered and restored when you return.
---------------------------------------------------------------------
local home -- World 1's lighting, captured the first time you leave it

-- the one bloom and sun rays effect the lighting uses (made here if the place has none)
local function effect(className)
	local found = Lighting:FindFirstChildOfClass(className)
	if not found then
		found = Instance.new(className)
		found.Intensity = 0
		found.Parent = Lighting
	end
	return found
end

local function capture()
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	local grade = Lighting:FindFirstChild("Cartoon2050Grade")
	local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds")
	local bloom, rays = effect("BloomEffect"), effect("SunRaysEffect")
	return {
		ClockTime = Lighting.ClockTime, Latitude = Lighting.GeographicLatitude, Brightness = Lighting.Brightness,
		Exposure = Lighting.ExposureCompensation, Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
		DiffuseScale = Lighting.EnvironmentDiffuseScale, SpecularScale = Lighting.EnvironmentSpecularScale,
		ShadowSoftness = Lighting.ShadowSoftness,
		Tint = grade and grade.TintColor or Color3.new(1, 1, 1),
		Saturation = grade and grade.Saturation or 0, Contrast = grade and grade.Contrast or 0,
		Fog = atmosphere and atmosphere.Color, Decay = atmosphere and atmosphere.Decay, Density = atmosphere and atmosphere.Density,
		Offset = atmosphere and atmosphere.Offset, Haze = atmosphere and atmosphere.Haze, Glare = atmosphere and atmosphere.Glare,
		Bloom = {bloom.Intensity, bloom.Size, bloom.Threshold}, SunRays = {rays.Intensity, rays.Spread},
		Clouds = clouds and clouds.Cover,
	}
end

-- Realistic defaults for worlds 2-9 (each world's Sky overrides what it needs):
-- stronger sun, full environment lighting and reflections, crisp shadows
local REALISM = {Brightness = 3, Exposure = 0, Latitude = 35, DiffuseScale = 1, SpecularScale = 1, ShadowSoftness = 0.15,
	Offset = 0.25, Haze = 1.5, Glare = 0.4, Saturation = 0.1, Contrast = 0.1, Bloom = {0.35, 24, 1.9}, SunRays = {0.1, 0.25}}

local function applySky(sky)
	local function get(key)
		if sky[key] ~= nil then return sky[key] end
		return REALISM[key]
	end
	local info = TweenInfo.new(1.2, Enum.EasingStyle.Sine)
	-- ClockTime and the sun angle jump (tweening would spin the sun through the whole day)
	Lighting.ClockTime = sky.ClockTime
	Lighting.GeographicLatitude = get("Latitude")
	Lighting.ShadowSoftness = get("ShadowSoftness")
	TweenService:Create(Lighting, info, {
		Ambient = sky.Ambient, OutdoorAmbient = sky.OutdoorAmbient, Brightness = get("Brightness"),
		ExposureCompensation = get("Exposure"), EnvironmentDiffuseScale = get("DiffuseScale"),
		EnvironmentSpecularScale = get("SpecularScale"),
	}):Play()
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere and sky.Fog then
		TweenService:Create(atmosphere, info, {Color = sky.Fog, Decay = sky.Decay, Density = sky.Density,
			Offset = get("Offset"), Haze = get("Haze"), Glare = get("Glare")}):Play()
	end
	local grade = Lighting:FindFirstChild("Cartoon2050Grade")
	if grade then
		TweenService:Create(grade, info, {TintColor = sky.Tint, Saturation = get("Saturation"), Contrast = get("Contrast")}):Play()
	end
	local bloom, rays = effect("BloomEffect"), effect("SunRaysEffect")
	local b, r = get("Bloom"), get("SunRays")
	TweenService:Create(bloom, info, {Intensity = b[1], Size = b[2], Threshold = b[3]}):Play()
	TweenService:Create(rays, info, {Intensity = r[1], Spread = r[2]}):Play()
	local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds")
	if clouds and sky.Clouds then
		clouds.Cover = sky.Clouds
	end
end

-- Only the island you're on is drawn: the other worlds' buildings and decorations are
-- taken out on this screen only (they're also ~9000 studs away, lost in the haze).
local worldsFolder = workspace:WaitForChild("Worlds", 30)
local worldModels = {} -- [model name] = model, even while it's hidden
local function showOnlyWorld(worldId)
	if not worldsFolder then return end
	for _, model in ipairs(worldsFolder:GetChildren()) do
		worldModels[model.Name] = model
	end
	for name, model in pairs(worldModels) do
		model.Parent = (name == "World" .. worldId) and worldsFolder or nil
	end
end
if worldsFolder then
	worldsFolder.ChildAdded:Connect(function(model)
		worldModels[model.Name] = model
		if model.Name ~= "World" .. (player:GetAttribute("CurrentWorld") or 1) then
			task.defer(function() model.Parent = nil end)
		end
	end)
end

local function onWorldChanged()
	showOnlyWorld(player:GetAttribute("CurrentWorld") or 1)
	local world = GameConfig.GetWorld(player:GetAttribute("CurrentWorld") or 1)
	if world and world.Sky then
		home = home or capture()
		applySky(world.Sky)
	elseif home then
		applySky(home)
	end
end
player:GetAttributeChangedSignal("CurrentWorld"):Connect(onWorldChanged)
onWorldChanged()
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "WorldGimmickClient", "LocalScript", [=[
-- WorldGimmickClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The player's side of the world gimmicks (see ReplicatedStorage.WorldGimmicks):
--   * a short intro line when you arrive in a world with a gimmick
--   * low gravity in Galaxy Drift (gravity is simulated on your own screen)
--   * the air meter in Coral Circuit (refill at the AirVent parts or near the surface)
--   * snow and fog during a Blizzard, screen flicker during a Glitch Surge
--   * a small timer pill for the current world event and your personal boost

local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local WorldGimmicks = require(ReplicatedStorage:WaitForChild("WorldGimmicks"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local surfaceRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ReturnToSurface")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local DEFAULT_GRAVITY = workspace.Gravity
local AIR_SECONDS = 70   -- how long a full air meter lasts in the fumes
local VENT_RANGE = 14    -- how close to a vent refills your air

local gui = UIKit.screen(player, "WorldGimmickGui", 4)

-- intro line (top right)
local intro = UIKit.panel(gui, {Size = UDim2.fromOffset(330, 64), Position = UDim2.new(1, -14, 0, 12), AnchorPoint = Vector2.new(1, 0), Color = C.Ink, Radius = 18, Stroke = 2.5, StrokeColor = C.Lilac, ShadeAmount = 0.2})
intro.BackgroundTransparency = 0.1
intro.Visible = false
local introIcon = UIKit.icon(intro, nil, {Size = UDim2.fromOffset(56, 56), Position = UDim2.new(0, -18, 0, -14), ZIndex = 2})
local introTitle = UIKit.label(intro, "", {Size = UDim2.new(1, -50, 0, 22), Position = UDim2.fromOffset(42, 6), Align = "Left", Color = C.Sun, Stroke = 0, MaxText = 18})
local introText = UIKit.label(intro, "", {Size = UDim2.new(1, -20, 0, 32), Position = UDim2.fromOffset(12, 28), Align = "Left", VAlign = "Top",
	Color = C.White, Stroke = 0, Font = UIKit.BodyFont, TextSize = 13})

-- event + boost timers (top right, small pills under the intro)
local function pill(y, color, icon)
	local p = UIKit.panel(gui, {Size = UDim2.fromOffset(250, 32), Position = UDim2.new(1, -14, 0, y), AnchorPoint = Vector2.new(1, 0), Color = color, Radius = 16, Stroke = 2})
	p.Visible = false
	UIKit.icon(p, icon, {Size = UDim2.fromOffset(40, 40), Position = UDim2.new(0, -10, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 2})
	local l = UIKit.label(p, "", {Size = UDim2.new(1, -44, 1, -10), Position = UDim2.new(0.5, 14, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.White, Stroke = 2, MaxText = 15})
	return p, l
end
local eventPill, eventLabel = pill(84, C.Violet, "Star")
local boostPill, boostLabel = pill(122, C.Coral, "Candy")

-- air meter (bottom right, above the flare button's spot)
local airPanel = UIKit.panel(gui, {Size = UDim2.fromOffset(250, 40), Position = UDim2.new(1, -16, 1, -196), AnchorPoint = Vector2.new(1, 1), Color = C.Ink, Radius = 20, Stroke = 2.5, StrokeColor = C.Sky})
airPanel.Visible = false
UIKit.icon(airPanel, "Bubble", {Size = UDim2.fromOffset(40, 40), Position = UDim2.new(0, -6, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 2})
UIKit.label(airPanel, "AIR", {Size = UDim2.fromOffset(40, 22), Position = UDim2.new(0, 34, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Align = "Left", Color = C.White, Stroke = 0, MaxText = 16})
local airTrack = UIKit.panel(airPanel, {Size = UDim2.new(1, -90, 0, 14), Position = UDim2.new(0, 76, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Color = C.PanelTint, Radius = 7, Stroke = false, Shade = false})
local airFill = UIKit.panel(airTrack, {Size = UDim2.fromScale(1, 1), Color = C.Sky, Radius = 7, Stroke = false, Shade = false})

-- blizzard snow around the camera, and a colour grade for fog / glitches
local snowPart = Instance.new("Part")
snowPart.Name = "BlizzardSnow"
snowPart.Anchored = true
snowPart.CanCollide = false
snowPart.CanQuery = false
snowPart.CanTouch = false
snowPart.Transparency = 1
snowPart.Size = Vector3.new(80, 1, 80)
local snow = Instance.new("ParticleEmitter")
snow.Shape = Enum.ParticleEmitterShape.Box
snow.Color = ColorSequence.new(Color3.new(1, 1, 1))
snow.Size = NumberSequence.new(0.35, 0.2)
snow.Lifetime = NumberRange.new(2, 3)
snow.Rate = 0
snow.Speed = NumberRange.new(20, 30)
snow.EmissionDirection = Enum.NormalId.Bottom
snow.SpreadAngle = Vector2.new(25, 25)
snow.Acceleration = Vector3.new(14, 0, 6)
snow.Parent = snowPart
local grade = Instance.new("ColorCorrectionEffect")
grade.Name = "WorldGimmickGrade"
grade.Enabled = false
grade.Parent = Lighting

local function currentWorldId()
	return player:GetAttribute("CurrentWorld") or 1
end

local function container(worldId)
	local worlds = workspace:FindFirstChild("Worlds")
	return worlds and worlds:FindFirstChild("World" .. worldId)
end

-- INTRO on arrival
local introToken = 0
local function showIntro(worldId)
	local info = WorldGimmicks[worldId]
	introToken += 1
	if not info then
		intro.Visible = false
		return
	end
	local myToken = introToken
	introTitle.Text = info.Title
	UIKit.setIcon(introIcon, info.Icon)
	introText.Text = info.Text
	intro.Visible = true
	UIKit.pop(intro, 0.7)
	task.delay(9, function()
		if introToken == myToken then intro.Visible = false end
	end)
end
player:GetAttributeChangedSignal("CurrentWorld"):Connect(function()
	showIntro(currentWorldId())
end)

local air = 1
RunService.RenderStepped:Connect(function(dt)
	local worldId = currentWorldId()
	local world = GameConfig.GetWorld(worldId) or GameConfig.Worlds[1]
	local folder = container(worldId)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local clock = os.clock()

	-- gravity
	local gravity = folder and folder:GetAttribute("Gravity")
	-- a gravity shift (WorldMechanicsClient) overrides it for a few seconds
	workspace.Gravity = player:GetAttribute("GravityOverride") or gravity or DEFAULT_GRAVITY

	-- events
	local event = folder and folder:GetAttribute("Event") or ""
	local eventName = player:GetAttribute("WorldEvent") or ""
	local left = player:GetAttribute("WorldEventLeft") or 0
	eventPill.Visible = eventName ~= ""
	if eventPill.Visible then eventLabel.Text = eventName .. "  ·  " .. left .. "s" end
	local boostName = player:GetAttribute("PersonalBoost") or ""
	boostPill.Visible = boostName ~= ""
	if boostPill.Visible then boostLabel.Text = boostName .. "  ·  " .. (player:GetAttribute("PersonalBoostLeft") or 0) .. "s" end

	-- blizzard: snow falling around the camera and a cold, foggy tint
	local blizzard = event == "BLIZZARD"
	snow.Rate = blizzard and 500 or 0
	if blizzard then
		snowPart.CFrame = CFrame.new(camera.CFrame.Position + Vector3.new(0, 25, 0))
		snowPart.Parent = workspace
	elseif snowPart.Parent and snow.Rate == 0 then
		snowPart.Parent = nil
	end
	local glitch = event == "GLITCH SURGE"
	if blizzard then
		grade.Enabled = true
		grade.TintColor = Color3.fromRGB(215, 230, 255)
		grade.Brightness = 0.12
		grade.Contrast = -0.25
		grade.Saturation = -0.3
	elseif glitch then
		-- flicker: every few frames the colors jump
		grade.Enabled = true
		local on = math.sin(clock * 37) > 0.6
		grade.TintColor = on and Color3.fromRGB(200, 150, 255) or Color3.fromRGB(255, 255, 255)
		grade.Saturation = on and 0.6 or 0.1
		grade.Contrast = on and 0.3 or 0
		grade.Brightness = 0
	else
		grade.Enabled = false
	end

	-- air meter
	local oxygenDepth = folder and folder:GetAttribute("OxygenDepth")
	if oxygenDepth and root then
		local depth = world.Origin.Y - (root.Position.Y - 3)
		local refilling = depth < oxygenDepth * 0.5
		if not refilling then
			for _, vent in ipairs(CollectionService:GetTagged("AirVent")) do
				if (vent.Position - root.Position).Magnitude < VENT_RANGE then
					refilling = true
					break
				end
			end
		end
		if refilling then
			air = math.min(1, air + dt * 0.5)
		elseif depth > oxygenDepth then
			air = math.max(0, air - dt / AIR_SECONDS)
		end
		airPanel.Visible = depth > oxygenDepth * 0.5 or air < 1
		airFill.Size = UDim2.fromScale(air, 1)
		airFill.BackgroundColor3 = air < 0.25 and C.Coral or (air < 0.5 and C.Sun or C.Sky)
		if air <= 0 then
			air = 1
			surfaceRemote:FireServer() -- out of air: pulled back up to the surface
		end
	else
		airPanel.Visible = false
		air = 1
	end
end)
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "WorldMechanicsClient", "LocalScript", [=[
-- WorldMechanicsClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The player's side of the interactive world mechanics:
--   * Neon Sakura:   click a Meme Ghost to hit it with your capture beam (Gimmick_Spirits)
--   * Galaxy Drift:  gravity shifts deep in the pit (Gimmick_GravityShift)
--   * Frostbyte:     the Torch Flare button / F key (Gimmick_Permafrost)
--   * Chrome Dunes:  the curse trap quick-time event (Gimmick_CurseTraps)
--   * Glitch Nexus:  the data hacking rhythm minigame (Gimmick_DataHacking)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local gui = UIKit.screen(player, "WorldMechanicsGui", 7)

local function currentWorldId()
	return player:GetAttribute("CurrentWorld") or 1
end
local function container()
	local worlds = workspace:FindFirstChild("Worlds")
	return worlds and worlds:FindFirstChild("World" .. currentWorldId())
end
local function remote(name, callback)
	task.spawn(function()
		local r = remotes:WaitForChild(name, 60)
		if r and callback then r.OnClientEvent:Connect(callback) end
	end)
	return function(...)
		local r = remotes:FindFirstChild(name)
		if r then r:FireServer(...) end
	end
end
local function isClick(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

-- a big message in the middle of the screen (warnings)
local warning = UIKit.label(gui, "", {Size = UDim2.fromOffset(600, 50), Position = UDim2.fromScale(0.5, 0.3), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Sun, Stroke = 3, MaxText = 40})
warning.Visible = false
local warnToken = 0
local function alert(text, color, seconds)
	warnToken += 1
	local myToken = warnToken
	warning.Text = text
	warning.TextColor3 = color or C.Sun
	warning.Visible = true
	UIKit.pop(warning, 0.6)
	task.delay(seconds or 2, function()
		if warnToken == myToken then warning.Visible = false end
	end)
end

---------------------------------------------------------------------
-- MEME GHOSTS: click (or tap) a ghost to fire the capture beam at it
---------------------------------------------------------------------
local captureGhost = remote("CaptureGhost")
UserInputService.InputBegan:Connect(function(input)
	if not isClick(input) then return end
	local folder = container()
	local ghostFolder = folder and folder:FindFirstChild("Gimmick")
	if not ghostFolder then return end
	local point = input.UserInputType == Enum.UserInputType.Touch and input.Position or UserInputService:GetMouseLocation()
	local ray = input.UserInputType == Enum.UserInputType.Touch and camera:ScreenPointToRay(point.X, point.Y) or camera:ViewportPointToRay(point.X, point.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = {ghostFolder}
	-- a fat ray, so the fast little ghosts are fair to hit
	local hit = workspace:Spherecast(ray.Origin, 2, ray.Direction * 250, params)
	local ghost = hit and hit.Instance:FindFirstAncestor("MemeGhost")
	if ghost then captureGhost(ghost) end
end)

---------------------------------------------------------------------
-- GRAVITY SHIFTS (Galaxy Drift): gravity is simulated on our own screen, so we play it here
---------------------------------------------------------------------
local lastShift
RunService.Heartbeat:Connect(function()
	local folder = container()
	local shift = folder and folder:GetAttribute("GravityShift") or ""
	if shift == lastShift then return end
	lastShift = shift
	if shift == "" then
		player:SetAttribute("GravityOverride", nil)
		return
	end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local world = GameConfig.GetWorld(currentWorldId())
	local minDepth = folder:GetAttribute("GravityShiftDepth") or 150
	if not root or not world or world.Origin.Y - root.Position.Y < minDepth then return end
	local parts = string.split(shift, ":")
	local mode, angle = parts[1], math.rad(tonumber(parts[2]) or 0)
	if mode == "Up" then
		alert("GRAVITY SHIFT! Gravity flips upward!", C.Lilac, 2.5)
		player:SetAttribute("GravityOverride", -30) -- WorldGimmickClient applies it
	else
		alert("GRAVITY SHIFT! Gravity pulls sideways!", C.Lilac, 2.5)
		player:SetAttribute("GravityOverride", 25)
		local push = Vector3.new(math.cos(angle), 0.2, math.sin(angle)) * 40
		task.spawn(function()
			for _ = 1, 6 do
				if root.Parent then root.AssemblyLinearVelocity += push * 0.25 end
				task.wait(0.1)
			end
		end)
	end
end)

---------------------------------------------------------------------
-- TORCH FLARE (Frostbyte Tundra): F key or the button, while in a world that has it
---------------------------------------------------------------------
local torchFlare = remote("TorchFlare")
local flareButton = UIKit.button(gui, "FLARE [F]", {Icon = "Fire", Size = UDim2.fromOffset(180, 50), Position = UDim2.new(1, -16, 1, -130), AnchorPoint = Vector2.new(1, 1), Color = C.Coral, MaxText = 20})
flareButton.Visible = false
local flareLabel = flareButton:FindFirstChild("Label")
local function fireFlare()
	if (player:GetAttribute("FlareReadyAt") or 0) <= os.time() then torchFlare() end
end
flareButton.MouseButton1Click:Connect(fireFlare)
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.F and flareButton.Visible then fireFlare() end
end)
task.spawn(function()
	while true do
		local folder = container()
		flareButton.Visible = folder ~= nil and folder:GetAttribute("TorchFlare") == true
		if flareButton.Visible and flareLabel then
			local now = os.time()
			local heat, ready = player:GetAttribute("HeatUntil") or 0, player:GetAttribute("FlareReadyAt") or 0
			if heat > now then
				flareLabel.Text = "HOT " .. (heat - now) .. "s"
				flareButton.BackgroundColor3 = C.Sun
			elseif ready > now then
				flareLabel.Text = "WAIT " .. (ready - now) .. "s"
				flareButton.BackgroundColor3 = C.Grey
			else
				flareLabel.Text = "FLARE [F]"
				flareButton.BackgroundColor3 = C.Coral
			end
		end
		task.wait(0.25)
	end
end)

---------------------------------------------------------------------
-- CURSE TRAP quick-time event (Chrome Dunes)
---------------------------------------------------------------------
local qte = UIKit.panel(gui, {Size = UDim2.fromOffset(360, 170), Position = UDim2.fromScale(0.5, 0.42), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Ink, Radius = 26, Stroke = 4, StrokeColor = C.Violet, Shade = false})
qte.BackgroundTransparency = 0.05
qte.Visible = false
UIKit.icon(qte, "Skull", {Size = UDim2.fromOffset(76, 76), Position = UDim2.new(0, -24, 0, -30), ZIndex = 2})
UIKit.label(qte, "CURSE TRAP!", {Size = UDim2.new(1, -30, 0, 34), Position = UDim2.new(0.5, 0, 0, 12), AnchorPoint = Vector2.new(0.5, 0), Color = C.Lilac, Stroke = 0, MaxText = 30})
local qteKey = UIKit.button(qte, "PRESS [E]", {Size = UDim2.fromOffset(220, 60), Position = UDim2.new(0.5, 0, 0, 56), AnchorPoint = Vector2.new(0.5, 0), Color = C.Violet, MaxText = 28})
local qteTrack = UIKit.panel(qte, {Size = UDim2.new(1, -40, 0, 12), Position = UDim2.new(0.5, 0, 1, -24), AnchorPoint = Vector2.new(0.5, 0), Color = C.PanelTint, Radius = 6, Stroke = false, Shade = false})
local qteFill = UIKit.panel(qteTrack, {Size = UDim2.fromScale(1, 1), Color = C.Coral, Radius = 6, Stroke = false, Shade = false})
local curseTrap
local activeKey
local function answer(pressed)
	if not activeKey then return end
	activeKey = nil
	qte.Visible = false
	curseTrap(pressed)
end
curseTrap = remote("CurseTrap", function(key, limit)
	activeKey = key
	local qteLabel = qteKey:FindFirstChild("Label")
	if qteLabel then qteLabel.Text = "PRESS [" .. key .. "]" end
	qte.Visible = true
	UIKit.pop(qte, 0.6)
	qteFill.Size = UDim2.fromScale(1, 1)
	local start = os.clock()
	task.spawn(function()
		while activeKey == key and os.clock() - start < limit do
			qteFill.Size = UDim2.fromScale(1 - (os.clock() - start) / limit, 1)
			RunService.RenderStepped:Wait()
		end
		if activeKey == key then
			activeKey = nil
			qte.Visible = false -- too slow: the server fails it
		end
	end)
end)
qteKey.MouseButton1Click:Connect(function() answer(activeKey) end) -- tapping the button counts (mobile)
UserInputService.InputBegan:Connect(function(input)
	if not activeKey or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	local name = input.KeyCode.Name
	if #name == 1 then answer(name) end
end)

---------------------------------------------------------------------
-- DATA HACKING rhythm minigame (Glitch Nexus)
---------------------------------------------------------------------
local hack = UIKit.panel(gui, {Size = UDim2.fromOffset(340, 300), Position = UDim2.fromScale(0.5, 0.45), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Ink, Radius = 26, Stroke = 4, StrokeColor = C.Mint, Shade = false})
hack.BackgroundTransparency = 0.05
hack.Visible = false
UIKit.icon(hack, "Disk", {Size = UDim2.fromOffset(70, 70), Position = UDim2.new(0, -22, 0, -28), ZIndex = 2})
UIKit.label(hack, "HACKING DATA NODE", {Size = UDim2.new(1, -30, 0, 28), Position = UDim2.new(0.5, 0, 0, 12), AnchorPoint = Vector2.new(0.5, 0), Color = C.Mint, Stroke = 0, MaxText = 24})
UIKit.label(hack, "Tap / click / Space when the rings line up!", {Size = UDim2.new(1, -30, 0, 18), Position = UDim2.new(0.5, 0, 0, 42), AnchorPoint = Vector2.new(0.5, 0), Color = C.White, Stroke = 0, Font = UIKit.BodyFont, MaxText = 15})
local function ring(size, color, thickness)
	local r = Instance.new("Frame")
	r.BackgroundTransparency = 1
	r.Size = UDim2.fromOffset(size, size)
	r.Position = UDim2.new(0.5, 0, 0, 170)
	r.AnchorPoint = Vector2.new(0.5, 0.5)
	r.Parent = hack
	UIKit.corner(r, size)
	local s = Instance.new("UIStroke")
	s.Thickness = thickness
	s.Color = color
	s.Parent = r
	return r, s
end
ring(90, C.Mint, 6) -- the target ring
local beatRing, beatStroke = ring(260, C.Sky, 4)
local hackResult = UIKit.label(hack, "", {Size = UDim2.new(1, -30, 0, 26), Position = UDim2.new(0.5, 0, 1, -40), AnchorPoint = Vector2.new(0.5, 0), Color = C.White, Stroke = 2, MaxText = 22})
local dataNode = remote("DataNode", nil)
local hacking = nil -- {Beat, BeatStart, Hits, Tapped}
local WINDOW = 0.2   -- how close to the beat counts as a hit (seconds)
local function tap()
	if not hacking or hacking.Tapped then return end
	hacking.Tapped = true
	local off = math.abs(os.clock() - (hacking.BeatStart + hacking.BeatSeconds))
	if off <= WINDOW then
		hacking.Hits += 1
		hackResult.Text = "HIT! (" .. hacking.Hits .. ")"
		hackResult.TextColor3 = C.Mint
		beatStroke.Color = C.Mint
	else
		hackResult.Text = "MISS"
		hackResult.TextColor3 = C.Coral
		beatStroke.Color = C.Coral
	end
end
task.spawn(function()
	local r = remotes:WaitForChild("DataNode", 60)
	if not r then return end
	r.OnClientEvent:Connect(function(beats, beatSeconds)
		if hacking then return end
		hack.Visible = true
		UIKit.pop(hack, 0.6)
		hackResult.Text = ""
		hacking = {Hits = 0, BeatSeconds = beatSeconds}
		for beat = 1, beats do
			hacking.Beat = beat
			hacking.BeatStart = os.clock()
			hacking.Tapped = false
			beatStroke.Color = C.Sky
			-- the ring shrinks onto the target; tap when they line up (and a little after)
			while os.clock() - hacking.BeatStart < beatSeconds + WINDOW do
				local u = math.clamp((os.clock() - hacking.BeatStart) / beatSeconds, 0, 1.2)
				local size = 90 + (260 - 90) * (1 - u)
				beatRing.Size = UDim2.fromOffset(size, size)
				RunService.RenderStepped:Wait()
			end
		end
		local hits = hacking.Hits
		hacking = nil
		task.wait(0.3)
		hack.Visible = false
		dataNode(hits)
	end)
end)
UserInputService.InputBegan:Connect(function(input)
	if not hacking then return end
	if isClick(input) or input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA then tap() end
end)
]=])
if recording then ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit) end
print("Meme Archaeologist: installed " .. count .. " scripts (build 2026-10-02 00:25). Now save the place (Ctrl+S).")
