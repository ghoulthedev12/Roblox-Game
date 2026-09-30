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
local TweenService = game:GetService("TweenService")

local terrain = workspace.Terrain

---------------------------------------------------------------------
-- SETTINGS
---------------------------------------------------------------------
local MINIGAME_TIMEOUT = 8
local MINIGAME_LUCK = {Perfect = 3, Good = 1.5, Miss = 1} -- multiplies the shovel's luck
local ANNOUNCE_FROM = ArtifactData.GetRarityIndex("Mythic")
local MAX_REACH = 14 -- how far from your character you can dig
local PICKUP_SECONDS = 25  -- how long a buried painting waits to be pulled out before it sinks back into the dirt
local PULL_SECONDS = 2.9   -- the pull-out animation (the pickaxe is put away meanwhile)
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

-- A find is a framed painting lying in the crater. It waits in pending[player] until the
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
		PlayerData.AddArtifact(player, find.Artifact.Id)
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

-- Where the painting lies: on the crater floor, face up, propped toward the finder and
-- half sunk into the soil
local function paintingCFrame(player, position)
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
	local away = -toPlayer
	local yAxis = (away - up * away:Dot(up)).Unit -- the picture's top edge points away from the finder
	local zAxis = -up                              -- the picture faces the sky
	local xAxis = yAxis:Cross(zAxis)
	return CFrame.fromMatrix(floor + up * 0.05, xAxis, yAxis, zAxis) * CFrame.Angles(math.rad(-16), 0, 0)
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

local function giveArtifact(player, zone, luck, grade, position)
	local artifact = ArtifactData.RollForZone(zone, luck)
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

	-- the framed painting lies in the crater, waiting to be pulled out
	local cf = paintingCFrame(player, position)
	local model = BuriedPainting(artifact, rarity.Color, cf, rng)
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
	if player:GetAttribute("Tutorial") == 3 then
		-- first-join tutorial: the first find comes after a few swings, no minigame
		tutorialDigs[player] = (tutorialDigs[player] or 0) + 1
		if tutorialDigs[player] >= TUTORIAL_FIND_AFTER then
			giveArtifact(player, zone, def.Luck, nil, carveAt + Vector3.new(0, 2, 0))
			return
		end
	end
	if rng:NextNumber() < def.FindChance * boost.Find * (1 + COMBO_LUCK * (combo - 1)) then
		onFind(player, def, zone, carveAt + Vector3.new(0, 2, 0), def.Luck * boost.Luck)
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
	shopMessageRemote:FireClient(player, "You bought the " .. def.Name .. "! It digs down to " .. -GameConfig.GetWorld(def.World).Zones[def.MaxZone].Bottom .. "m.", true)
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
-- PIT SAFETY: invisible walls around every pit, a solid floor inside the bedrock, a lower
-- void, and a rescue for anyone who still manages to fall out of the world
---------------------------------------------------------------------
-- the Abyss goes 560 studs down; Roblox's default kill height would kill diggers down there
workspace.FallenPartsDestroyHeight = -3000

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
