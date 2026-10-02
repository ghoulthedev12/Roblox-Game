-- PetManager (Script in ServerScriptService)
-- The pets (see ReplicatedStorage.PetData):
--   * EGG STANDS: every world has one, on the ring around its pit (opposite the World Gate):
--     a pedestal with the world's egg turning on top, a sign with its price and the chance of
--     each pet inside, and two prompts: Hatch 1 (E) and Hatch 3 (R).
--   * HATCHING takes the cash, rolls the pets, saves them and tells the player's screen to
--     play the hatch (PetClient). New pets are equipped right away while there's room.
--   * EQUIPPED PETS follow their owner (the models live in workspace.PlayerPets; every
--     player's PetClient moves them) and boost them: income (PlayerData), Dig Luck and Dig
--     Speed (DigBoosts reads the PetLuck / PetSpeed attributes set here).
--   * The Pets window asks for the list and equips, unequips and deletes through PetAction.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local PetData = require(ReplicatedStorage:WaitForChild("PetData"))
local PetVisuals = require(ReplicatedStorage:WaitForChild("PetVisuals"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))

local STAND_SPOT = {Angle = 150, Distance = 80} -- the shop is at 30 degrees, the gate at -30
local STAND_SPOT_WORLD_1 = {Angle = 165, Distance = 89} -- (World 1's Research Lab is at 150)
local HATCH_COOLDOWN = 1.2 -- seconds between hatches (the hatch takes a moment on screen)

local rng = Random.new()

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local function remote(className, name)
	local r = remotes:FindFirstChild(name) or Instance.new(className)
	r.Name = name
	r.Parent = remotes
	return r
end
local actionRemote = remote("RemoteFunction", "PetAction")  -- the Pets window: list, equip, unequip, delete
local stateRemote = remote("RemoteEvent", "PetState")       -- server -> client: the pet list changed
local hatchedRemote = remote("RemoteEvent", "PetHatched")   -- server -> client: play the hatch
local messageRemote = remotes:WaitForChild("ShopMessage", 30) -- the little message toast

local petsFolder = workspace:FindFirstChild("PlayerPets") or Instance.new("Folder")
petsFolder.Name = "PlayerPets"
petsFolder.Parent = workspace

local function say(player, text, good)
	if messageRemote then messageRemote:FireClient(player, text, good) end
end

---------------------------------------------------------------------
-- STATE
---------------------------------------------------------------------
local function count(data)
	local n = 0
	for _ in pairs(data.Pets) do n += 1 end
	return n
end

local function equippedCount(data)
	local n = 0
	for uid in pairs(data.EquippedPets) do
		if data.Pets[uid] then n += 1 else data.EquippedPets[uid] = nil end
	end
	return n
end

local function stateOf(data)
	return {Pets = data.Pets, Equipped = data.EquippedPets, MaxEquipped = PetData.MaxEquipped, MaxOwned = PetData.MaxOwned}
end

-- the pet models following the player: one per equipped pet
local function spawnPets(player, data)
	local folder = petsFolder:FindFirstChild(player.Name)
	if folder then folder:Destroy() end
	folder = Instance.new("Folder")
	folder.Name = player.Name
	folder:SetAttribute("OwnerId", player.UserId)
	local uids = {}
	for uid in pairs(data.EquippedPets) do
		if data.Pets[uid] then table.insert(uids, uid) end
	end
	table.sort(uids, function(a, b) return tonumber(a) < tonumber(b) end)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	for slot, uid in ipairs(uids) do
		local pet = PetData.GetPet(data.Pets[uid])
		if pet then
			local model = PetVisuals.model(pet.Id, PetData.Rarity(pet).Height)
			model.Name = "Pet_" .. uid
			model:SetAttribute("PetId", pet.Id)
			model:SetAttribute("Slot", slot)
			model:SetAttribute("Rarity", pet.Rarity)
			model.ModelStreamingMode = Enum.ModelStreamingMode.Persistent -- every player sees everyone's pets
			PetVisuals.addFlair(model, pet.Rarity)
			if root then model:PivotTo(CFrame.new(root.Position + Vector3.new(slot * 2, -2.5, 3))) end
			model.Parent = folder
		end
	end
	folder.Parent = petsFolder
end

-- boosts, income and the models, after any change
local function changed(player)
	local data = PlayerData.Get(player)
	if not data then return end
	local bonus = PetData.Bonuses(data)
	player:SetAttribute("PetMoney", bonus.Money)
	player:SetAttribute("PetLuck", bonus.Luck)
	player:SetAttribute("PetSpeed", bonus.Speed)
	PlayerData.Refresh(player) -- income includes the money boost
	spawnPets(player, data)
	stateRemote:FireClient(player, stateOf(data))
end

---------------------------------------------------------------------
-- HATCHING
---------------------------------------------------------------------
local lastHatch = {}

local function hatch(player, egg, amount)
	local data = PlayerData.Get(player)
	if not data then return end
	if os.clock() - (lastHatch[player] or 0) < HATCH_COOLDOWN then return end
	local room = PetData.MaxOwned - count(data)
	if room <= 0 then
		say(player, "Your pets are full (" .. PetData.MaxOwned .. ")! Delete some in the Pets window.", false)
		return
	end
	amount = math.min(amount, room)
	local cost = egg.Price * amount
	if not PlayerData.SpendMoney(player, cost) then
		say(player, "You need " .. ArtifactData.FormatMoney(cost) .. " to hatch " .. (amount > 1 and amount .. " eggs" or "this egg") .. ".", false)
		return
	end
	lastHatch[player] = os.clock()
	local got = {}
	for _ = 1, amount do
		local petId = PetData.Roll(egg, rng)
		local uid = tostring(data.NextPetUid)
		data.NextPetUid += 1
		data.Pets[uid] = petId
		-- new pets go straight to work while there's a free spot
		if equippedCount(data) < PetData.MaxEquipped then data.EquippedPets[uid] = true end
		table.insert(got, petId)
		local pet = PetData.GetPet(petId)
		if pet.Rarity == #PetData.Rarities then
			remotes.Announcement:FireAllClients(player.DisplayName .. " hatched a LEGENDARY " .. pet.Name .. "!", PetData.Rarities[pet.Rarity].Color)
		end
	end
	hatchedRemote:FireClient(player, egg.Id, got)
	changed(player)
end

---------------------------------------------------------------------
-- THE PETS WINDOW
---------------------------------------------------------------------
actionRemote.OnServerInvoke = function(player, action, uid)
	local data = PlayerData.Get(player)
	if not data then return nil end
	if type(uid) ~= "string" and uid ~= nil then return stateOf(data) end
	if action == "Equip" and data.Pets[uid] then
		if not data.EquippedPets[uid] then
			if equippedCount(data) >= PetData.MaxEquipped then
				say(player, "You can have " .. PetData.MaxEquipped .. " pets out at once. Unequip one first.", false)
				return stateOf(data)
			end
			data.EquippedPets[uid] = true
			changed(player)
		end
	elseif action == "Unequip" and data.EquippedPets[uid] then
		data.EquippedPets[uid] = nil
		changed(player)
	elseif action == "Delete" and data.Pets[uid] then
		data.Pets[uid] = nil
		data.EquippedPets[uid] = nil
		changed(player)
	elseif action == "EquipBest" then
		local uids = {}
		for id in pairs(data.Pets) do table.insert(uids, id) end
		table.sort(uids, function(a, b)
			local pa, pb = PetData.GetPet(data.Pets[a]), PetData.GetPet(data.Pets[b])
			return (pa and PetData.Score(pa) or 0) > (pb and PetData.Score(pb) or 0)
		end)
		table.clear(data.EquippedPets)
		for i = 1, math.min(PetData.MaxEquipped, #uids) do data.EquippedPets[uids[i]] = true end
		changed(player)
	end
	return stateOf(data)
end

---------------------------------------------------------------------
-- PLAYERS
---------------------------------------------------------------------
local function onPlayer(player)
	local data = PlayerData.WaitForData(player)
	if not data or not player.Parent then return end
	-- pets from an older version of the game that no longer exist disappear from the save
	for uid, petId in pairs(data.Pets) do
		if not PetData.GetPet(petId) then
			data.Pets[uid] = nil
			data.EquippedPets[uid] = nil
		end
	end
	changed(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.5)
		local fresh = PlayerData.Get(player)
		if fresh then spawnPets(player, fresh) end
	end)
end
Players.PlayerAdded:Connect(onPlayer)
for _, player in ipairs(Players:GetPlayers()) do task.spawn(onPlayer, player) end
Players.PlayerRemoving:Connect(function(player)
	lastHatch[player] = nil
	local folder = petsFolder:FindFirstChild(player.Name)
	if folder then folder:Destroy() end
end)

---------------------------------------------------------------------
-- EGG STANDS
---------------------------------------------------------------------
local function part(parent, name, size, cf, color, material, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if shape then p.Shape = shape end
	p.Parent = parent
	return p
end

local UP = CFrame.Angles(0, 0, math.rad(90)) -- a cylinder standing upright

local function sign(anchor, egg)
	local gui = Instance.new("BillboardGui")
	gui.Name = "EggSign"
	gui.Size = UDim2.fromScale(11, 9.5)
	gui.StudsOffset = Vector3.new(0, 0, 0)
	gui.MaxDistance = 110
	gui.LightInfluence = 0
	gui.Parent = anchor
	local panel = UIKit.panel(gui, {Size = UDim2.fromScale(1, 1), Color = Color3.fromRGB(40, 34, 70), Radius = 18, Stroke = 4})
	UIKit.label(panel, string.upper(egg.Name), {Size = UDim2.new(1, -16, 0.15, 0), Position = UDim2.fromScale(0.5, 0.03), AnchorPoint = Vector2.new(0.5, 0),
		Stroke = 3, MaxText = 60})
	UIKit.label(panel, ArtifactData.FormatMoney(egg.Price), {Size = UDim2.new(1, -16, 0.12, 0), Position = UDim2.fromScale(0.5, 0.18), AnchorPoint = Vector2.new(0.5, 0),
		Color = Color3.fromRGB(120, 240, 100), Stroke = 3, MaxText = 50})
	for i, petId in ipairs(egg.Pets) do
		local pet = PetData.GetPet(petId)
		local rarity = PetData.Rarities[i]
		local row = UIKit.panel(panel, {Size = UDim2.new(0.92, 0, 0.115, 0), Position = UDim2.new(0.5, 0, 0.33 + (i - 1) * 0.128, 0), AnchorPoint = Vector2.new(0.5, 0),
			Color = rarity.Color, Radius = 10, Stroke = 2.5})
		UIKit.label(row, pet.Name, {Size = UDim2.new(0.68, 0, 0.8, 0), Position = UDim2.new(0.04, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
			Align = "Left", Stroke = 2.5, MaxText = 40})
		UIKit.label(row, rarity.Chance .. "%", {Size = UDim2.new(0.26, 0, 0.8, 0), Position = UDim2.new(0.96, 0, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5),
			Align = "Right", Stroke = 2.5, MaxText = 40})
	end
end

local function buildStand(world, egg, parent)
	local spot = world.Id == 1 and STAND_SPOT_WORLD_1 or STAND_SPOT
	local a = math.rad(spot.Angle)
	local origin = world.Origin
	local pos = origin + Vector3.new(math.cos(a) * spot.Distance, 0, math.sin(a) * spot.Distance)
	local base = CFrame.lookAt(pos, Vector3.new(origin.X, pos.Y, origin.Z))
	local look = world.Look or {}
	local main = look.Main or Color3.fromRGB(190, 160, 240)
	local glow = look.Glow or Color3.fromRGB(60, 220, 240)
	local light = Color3.fromRGB(246, 246, 252)

	GameConfig.LevelGround(workspace.Terrain, base, 16, 16)
	local stand = Instance.new("Model")
	stand.Name = "EggStand"
	-- a round platform with a glowing rim, a pedestal and the egg on top
	part(stand, "Platform", Vector3.new(1.6, 13, 13), base * CFrame.new(0, 0.4, 0) * UP, light, nil, Enum.PartType.Cylinder)
	part(stand, "PlatformGlow", Vector3.new(0.5, 13.6, 13.6), base * CFrame.new(0, 0.35, 0) * UP, glow, Enum.Material.Neon, Enum.PartType.Cylinder)
	part(stand, "PlatformTop", Vector3.new(0.3, 10.5, 10.5), base * CFrame.new(0, 1.25, 0) * UP, main, nil, Enum.PartType.Cylinder)
	part(stand, "Pedestal", Vector3.new(2.4, 5, 5), base * CFrame.new(0, 2.4, 0) * UP, light, nil, Enum.PartType.Cylinder)
	part(stand, "PedestalRing", Vector3.new(0.4, 5.6, 5.6), base * CFrame.new(0, 3.5, 0) * UP, glow, Enum.Material.Neon, Enum.PartType.Cylinder)
	for k = 0, 3 do -- little posts with lights around the platform
		local pa = math.rad(45 + k * 90)
		local post = base * CFrame.new(math.cos(pa) * 5.4, 0, math.sin(pa) * 5.4)
		part(stand, "Post", Vector3.new(0.6, 3.2, 0.6), post * CFrame.new(0, 2.6, 0), main)
		part(stand, "PostLight", Vector3.new(1, 1, 1), post * CFrame.new(0, 4.5, 0), glow, Enum.Material.Neon, Enum.PartType.Ball)
	end
	for _, p in ipairs(stand:GetChildren()) do
		if p:IsA("BasePart") and p.Material == Enum.Material.Neon then p.CastShadow = false end
	end

	local display = PetVisuals.model(egg.Id, 5.5)
	display.Name = "EggDisplay"
	display:PivotTo(base * CFrame.new(0, 3.75, 0))
	display:SetAttribute("Home", display:GetPivot())
	CollectionService:AddTag(display, "EggDisplay") -- PetClient turns it slowly
	display.Parent = stand

	local light2 = Instance.new("PointLight")
	light2.Color = glow
	light2.Range = 14
	light2.Brightness = 1.5
	light2.Parent = stand.PedestalRing

	local anchor = part(stand, "SignAnchor", Vector3.new(1, 1, 1), base * CFrame.new(0, 15.5, 0), light)
	anchor.Transparency = 1
	anchor.CanCollide = false
	anchor.CanQuery = false
	sign(anchor, egg)

	local promptPart = part(stand, "HatchPrompt", Vector3.new(2, 2, 2), base * CFrame.new(0, 5, 0), light)
	promptPart.Transparency = 1
	promptPart.CanCollide = false
	promptPart.CanQuery = false
	for _, option in ipairs({{1, Enum.KeyCode.E}, {3, Enum.KeyCode.R}}) do
		local amount, key = option[1], option[2]
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "Hatch" .. amount
		prompt.ObjectText = egg.Name .. "  ·  " .. ArtifactData.FormatMoney(egg.Price * amount)
		prompt.ActionText = "Hatch " .. amount
		prompt.KeyboardKeyCode = key
		prompt.GamepadKeyCode = amount == 1 and Enum.KeyCode.ButtonX or Enum.KeyCode.ButtonY
		prompt.HoldDuration = 0
		prompt.MaxActivationDistance = 13
		prompt.RequiresLineOfSight = false
		prompt.UIOffset = Vector2.new(0, amount == 1 and 0 or 72)
		prompt.Parent = promptPart
		prompt.Triggered:Connect(function(player)
			hatch(player, egg, amount)
		end)
	end
	stand.Parent = parent
	return stand
end

-- wait for the worlds to exist (DigManager and MapStyle build them), then add the stands
task.spawn(function()
	local waited = 0
	while not workspace:GetAttribute("MainIslandReady") and waited < 40 do
		waited += task.wait(0.5)
	end
	task.wait(2)
	local folder = workspace:FindFirstChild("EggStands")
	if folder then folder:Destroy() end
	folder = Instance.new("Folder")
	folder.Name = "EggStands"
	folder.Parent = workspace
	for worldId, egg in pairs(PetData.Eggs) do
		local world = GameConfig.GetWorld(worldId)
		if world and world.Enabled ~= false then
			local ok, err = pcall(buildStand, world, egg, folder)
			if not ok then warn("Egg stand for world " .. worldId .. ": " .. tostring(err)) end
		end
	end
	print("PetManager ready: " .. #PetData.Order .. " pets in " .. #PetData.Eggs .. " eggs")
end)
