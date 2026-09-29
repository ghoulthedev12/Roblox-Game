-- DigManager (Script in ServerScriptService)
-- Real terrain digging with shovels: carves holes, finds artifacts by layer,
-- Lucky Dig minigame, Dig Permits, pit resets, and the Shovel Shop.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))

local terrain = workspace.Terrain

---------------------------------------------------------------------
-- SETTINGS
---------------------------------------------------------------------
local MINIGAME_TIMEOUT = 8
local MINIGAME_LUCK = {Perfect = 3, Good = 1.5, Miss = 1} -- multiplies the shovel's luck
local ANNOUNCE_FROM = ArtifactData.GetRarityIndex("Mythic")
local PIT_CENTER = Vector3.new(0, 0, 0)
local PIT_RADIUS = 41          -- how far from the center you can dig
local CENTER_NO_DIG_RADIUS = 9 -- keeps the giant hard drive standing
local MAX_REACH = 14           -- how far from your character you can dig

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
local digMessageRemote = getRemote("DigProgress")  -- server -> client: short messages
local surfaceRemote = getRemote("ReturnToSurface")
local openShopRemote = getRemote("OpenShovelShop")
local buyShovelRemote = getRemote("BuyShovel")
local equipShovelRemote = getRemote("EquipShovel")
local buyLayerRemote = getRemote("BuyLayer")
local shopMessageRemote = getRemote("ShopMessage")

local digSite = workspace:WaitForChild("DigSite")

---------------------------------------------------------------------
-- SHOVEL TOOLS (a realistic spade built from parts)
---------------------------------------------------------------------
local WOOD = Color3.fromRGB(125, 88, 56)
local toolTemplates = {}

local function toolPart(tool, name, size, cframe, color, material, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Color = color
	p.Material = material
	if shape then p.Shape = shape end
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Massless = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = tool
	return p
end

-- A bar from point a to point b
local function toolBar(tool, name, a, b, thickness, color, material)
	local length = (b - a).Magnitude
	return toolPart(tool, name, Vector3.new(thickness, thickness, length), CFrame.lookAt((a + b) / 2, b), color, material)
end

local ALONG_Z = CFrame.Angles(0, math.rad(90), 0) -- turns a cylinder to point along the shaft

local function buildShovelTool(def)
	local tool = Instance.new("Tool")
	tool.Name = def.Name
	tool.ToolTip = def.Name
	tool.CanBeDropped = false
	tool.RequiresHandle = true
	tool:SetAttribute("ShovelId", def.Id)
	tool.Grip = CFrame.new(0, 0, 1.4) * CFrame.Angles(math.rad(50), 0, 0) -- shovel points forward and down

	local bladeMat = Enum.Material[def.Material] or Enum.Material.Metal
	local fancy = def.Material == "Neon" or def.Material == "ForceField" or def.Material == "Glass"
	local shaftColor = fancy and Color3.fromRGB(28, 30, 42) or WOOD
	local shaftMat = fancy and Enum.Material.Metal or Enum.Material.Wood
	local metalColor = fancy and def.Color or Color3.fromRGB(95, 98, 105)
	local metalMat = fancy and bladeMat or Enum.Material.Metal
	if def.Material == "CorrodedMetal" then
		metalColor = def.Color
		metalMat = Enum.Material.CorrodedMetal
	end

	-- Invisible handle (the hand holds this), everything else is welded to it
	local handle = toolPart(tool, "Handle", Vector3.new(0.3, 0.3, 4.4), CFrame.new(), shaftColor, shaftMat)
	handle.Transparency = 1

	local parts = {}
	local function add(p) table.insert(parts, p) return p end

	-- Round shaft
	add(toolPart(tool, "Shaft", Vector3.new(4.4, 0.22, 0.22), ALONG_Z, shaftColor, shaftMat, Enum.PartType.Cylinder))
	-- Grip wrap near the hand
	add(toolPart(tool, "GripWrap", Vector3.new(0.9, 0.26, 0.26), CFrame.new(0, 0, 1.4) * ALONG_Z, Color3.fromRGB(30, 30, 30), Enum.Material.Fabric, Enum.PartType.Cylinder))
	-- D-shaped grip at the top
	add(toolBar(tool, "GripSideL", Vector3.new(0, 0, 2.15), Vector3.new(-0.42, 0, 2.8), 0.14, shaftColor, shaftMat))
	add(toolBar(tool, "GripSideR", Vector3.new(0, 0, 2.15), Vector3.new(0.42, 0, 2.8), 0.14, shaftColor, shaftMat))
	add(toolPart(tool, "GripBar", Vector3.new(0.95, 0.18, 0.18), CFrame.new(0, 0, 2.82), Color3.fromRGB(30, 30, 30), Enum.Material.Fabric, Enum.PartType.Cylinder))
	-- Metal socket where the blade meets the shaft
	add(toolPart(tool, "Socket", Vector3.new(0.8, 0.3, 0.3), CFrame.new(0, 0, -2.35) * ALONG_Z, metalColor, metalMat, Enum.PartType.Cylinder))

	-- Blade (slightly angled, curved sides, pointed tip, foot step on top)
	local bladeCF = CFrame.new(0, -0.05, -2.7) * CFrame.Angles(math.rad(-14), 0, 0)
	local blade = add(toolPart(tool, "Blade", Vector3.new(1.3, 0.08, 1.3), bladeCF * CFrame.new(0, 0, -0.65), def.Color, bladeMat))
	add(toolPart(tool, "BladeTip", Vector3.new(0.92, 0.08, 0.92), bladeCF * CFrame.new(0, 0, -1.3) * CFrame.Angles(0, math.rad(45), 0), def.Color, bladeMat))
	add(toolPart(tool, "BladeSideL", Vector3.new(0.28, 0.08, 1.3), bladeCF * CFrame.new(-0.72, 0.06, -0.65) * CFrame.Angles(0, 0, math.rad(-22)), def.Color, bladeMat))
	add(toolPart(tool, "BladeSideR", Vector3.new(0.28, 0.08, 1.3), bladeCF * CFrame.new(0.72, 0.06, -0.65) * CFrame.Angles(0, 0, math.rad(22)), def.Color, bladeMat))
	add(toolPart(tool, "FootStep", Vector3.new(1.45, 0.12, 0.12), bladeCF * CFrame.new(0, 0.04, 0), metalColor, metalMat, Enum.PartType.Cylinder))

	if def.Material ~= "CorrodedMetal" and def.Material ~= "SmoothPlastic" then
		blade.Reflectance = 0.15
	end
	if fancy then
		local light = Instance.new("PointLight")
		light.Color = def.Color
		light.Range = 9
		light.Brightness = 1.2
		light.Parent = blade
	end

	-- Make the whole shovel smaller
	local SCALE = 0.65
	for _, part in ipairs(tool:GetChildren()) do
		if part:IsA("BasePart") then
			local rotation = part.CFrame.Rotation
			part.Size = part.Size * SCALE
			part.CFrame = CFrame.new(part.Position * SCALE) * rotation
		end
	end
	tool.Grip = CFrame.new(0, 0, 1.4 * SCALE) * CFrame.Angles(math.rad(50), 0, 0)

	for _, part in ipairs(parts) do
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = handle
		weld.Part1 = part
		weld.Parent = handle
	end
	return tool
end

buildShovelTool = require(script.Parent:WaitForChild("ShovelModels"))
for _, def in ipairs(GameConfig.Shovels) do
	toolTemplates[def.Id] = buildShovelTool(def)
end

---------------------------------------------------------------------
-- PLAYER SHOVEL / PERMIT STATE
---------------------------------------------------------------------
local function getEquippedDef(player)
	local data = PlayerData.Get(player)
	return (data and GameConfig.GetShovel(data.EquippedShovel)) or GameConfig.Shovels[1]
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
	player:SetAttribute("OwnedShovels", keysToString(data.OwnedShovels))
	player:SetAttribute("EquippedShovel", data.EquippedShovel)
	player:SetAttribute("UnlockedLayers", keysToString(data.UnlockedLayers))
end

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
	if backpack then
		toolTemplates[def.Id]:Clone().Parent = backpack
	end
end

---------------------------------------------------------------------
-- DIGGING
---------------------------------------------------------------------
local rng = Random.new()
local lastSwing = {}  -- [player] = time of last swing
local sessions = {}   -- [player] = Lucky Dig session
local resetting = false

local function dirtBurst(position, color)
	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.Transparency = 1
	anchor.Size = Vector3.new(1, 1, 1)
	anchor.CFrame = CFrame.new(position)
	anchor.Parent = workspace

	local burst = Instance.new("ParticleEmitter")
	burst.Enabled = false
	burst.Color = ColorSequence.new(color)
	burst.Size = NumberSequence.new(0.5, 0.1)
	burst.Lifetime = NumberRange.new(0.5, 0.9)
	burst.Speed = NumberRange.new(10, 16)
	burst.SpreadAngle = Vector2.new(40, 40)
	burst.Acceleration = Vector3.new(0, -45, 0)
	burst.Rotation = NumberRange.new(0, 360)
	burst.EmissionDirection = Enum.NormalId.Top
	burst.Parent = anchor
	burst:Emit(18)
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

local function giveArtifact(player, era, luck, grade)
	local artifact = ArtifactData.RollArtifact(era, luck)
	local data = PlayerData.Get(player)
	if not artifact or not data then return end

	PlayerData.AddArtifact(player, artifact.Id)
	data.Stats.TotalDigs += 1

	local rarity = ArtifactData.GetRarity(artifact.Rarity)
	local rarityIndex = ArtifactData.GetRarityIndex(artifact.Rarity)
	resultRemote:FireClient(player, {
		Name = artifact.Name,
		Rarity = artifact.Rarity,
		RarityIndex = rarityIndex,
		Color = rarity.Color,
		Income = ArtifactData.GetIncome(artifact),
		Description = artifact.Description,
		Grade = grade,
	})
	if rarityIndex >= ANNOUNCE_FROM then
		announceRemote:FireAllClients(player.DisplayName .. " found a " .. string.upper(artifact.Rarity) .. " " .. artifact.Name .. "!", rarity.Color)
	end
end

local function finishLuckyDig(player, grade)
	local session = sessions[player]
	if not session then return end
	sessions[player] = nil
	giveArtifact(player, session.Era, session.ShovelLuck * (MINIGAME_LUCK[grade] or 1), grade)
end

local function onFind(player, def, era)
	if rng:NextNumber() < GameConfig.MinigameChance then
		local session = {Started = os.clock(), ShovelLuck = def.Luck, Era = era}
		sessions[player] = session
		minigameRemote:FireClient(player)
		task.delay(MINIGAME_TIMEOUT, function()
			if sessions[player] == session then
				finishLuckyDig(player, "Miss")
			end
		end)
	else
		giveArtifact(player, era, def.Luck, nil)
	end
end

swingRemote.OnServerEvent:Connect(function(player, target)
	if resetting or sessions[player] then return end
	local data = PlayerData.Get(player)
	if not data then return end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local tool = character and character:FindFirstChildOfClass("Tool")
	if not root or not tool or not tool:GetAttribute("ShovelId") then return end

	local def = getEquippedDef(player)
	local now = os.clock()
	if now - (lastSwing[player] or 0) < def.Cooldown * 0.85 then return end
	lastSwing[player] = now

	-- Where to dig: where the player clicked, or just in front of their feet
	if typeof(target) ~= "Vector3" or (target - root.Position).Magnitude > MAX_REACH then
		target = root.Position + root.CFrame.LookVector * 3 - Vector3.new(0, 3, 0)
	end

	local flat = Vector3.new(target.X - PIT_CENTER.X, 0, target.Z - PIT_CENTER.Z).Magnitude
	if flat > PIT_RADIUS or flat < CENTER_NO_DIG_RADIUS or target.Y > GameConfig.Layers[1].Top + 5 then
		digMessageRemote:FireClient(player, "Dig inside the pit!")
		return
	end

	-- Which layer is this?
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

	local layerIndex, layer = GameConfig.GetLayerAt(carveAt.Y)
	if not layer then
		digMessageRemote:FireClient(player, "Bedrock! You can't dig any deeper.")
		return
	end
	if not data.UnlockedLayers[tostring(layerIndex)] then
		digMessageRemote:FireClient(player, "Locked! You need the Dig Permit for " .. layer.Name .. " (" .. ArtifactData.FormatMoney(layer.Price) .. "). Get it at the Shovel Shop.")
		return
	end

	if not isSolid(carveAt) then
		return -- swinging at air
	end

	-- Carve the hole and throw dirt
	-- wide but one block deep, plus the block above so tunnels are tall enough to walk into
	terrain:FillBlock(CFrame.new(carveAt + Vector3.new(0, 2, 0)), Vector3.new(def.DigRadius + 2, 8, def.DigRadius + 2), Enum.Material.Air)
	dirtBurst(target, layer.Color)

	-- Did we find something?
	if rng:NextNumber() < def.FindChance then
		onFind(player, def, layer.Era)
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
local function surfaceCFrame(position)
	-- nearest of the 6 path openings, on the path just outside the rim
	local angle = math.atan2(position.Z, position.X)
	local snapped = math.floor(angle / (math.pi / 3) + 0.5) * (math.pi / 3)
	local spot = Vector3.new(math.cos(snapped) * 52, 4, math.sin(snapped) * 52)
	return CFrame.lookAt(spot, Vector3.new(0, 4, 0))
end

surfaceRemote.OnServerEvent:Connect(function(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root and root.Position.Y < GameConfig.Layers[1].Top - 2 then
		character:PivotTo(surfaceCFrame(root.Position))
	end
end)

---------------------------------------------------------------------
-- PIT RESET (refills all the dirt)
---------------------------------------------------------------------
local function resetPit()
	resetting = true
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root then
			local flat = Vector3.new(root.Position.X, 0, root.Position.Z).Magnitude
			if flat < 48 and root.Position.Y < 6 then
				character:PivotTo(surfaceCFrame(root.Position))
			end
		end
	end
	task.wait(0.5)
	GameConfig.FillDigTerrain(terrain)
	resetting = false
end

task.spawn(function()
	resetPit() -- fresh ground when the server starts
	while true do
		task.wait(GameConfig.PitResetMinutes * 60 - 30)
		announceRemote:FireAllClients("The Hard Drives reboot in 30 seconds! All the dirt will come back.", Color3.fromRGB(0, 225, 255))
		task.wait(30)
		resetPit()
		announceRemote:FireAllClients("The Hard Drives have rebooted. Fresh ground to dig!", Color3.fromRGB(90, 255, 120))
	end
end)

---------------------------------------------------------------------
-- SHOVEL SHOP + DIG PERMITS
---------------------------------------------------------------------
buyShovelRemote.OnServerEvent:Connect(function(player, shovelId)
	local data = PlayerData.Get(player)
	local def = typeof(shovelId) == "string" and GameConfig.GetShovel(shovelId)
	if not data or not def or data.OwnedShovels[def.Id] then return end
	if not PlayerData.SpendMoney(player, def.Price) then
		shopMessageRemote:FireClient(player, "Not enough money!", false)
		return
	end
	data.OwnedShovels[def.Id] = true
	data.EquippedShovel = def.Id
	updateAttributes(player)
	giveShovel(player)
	shopMessageRemote:FireClient(player, "You bought the " .. def.Name .. "!", true)
end)

equipShovelRemote.OnServerEvent:Connect(function(player, shovelId)
	local data = PlayerData.Get(player)
	local def = typeof(shovelId) == "string" and GameConfig.GetShovel(shovelId)
	if not data or not def or not data.OwnedShovels[def.Id] then return end
	data.EquippedShovel = def.Id
	updateAttributes(player)
	giveShovel(player)
end)

buyLayerRemote.OnServerEvent:Connect(function(player, layerIndex)
	local data = PlayerData.Get(player)
	local layer = typeof(layerIndex) == "number" and GameConfig.Layers[layerIndex]
	if not data or not layer or data.UnlockedLayers[tostring(layerIndex)] then return end
	if layerIndex > 1 and not data.UnlockedLayers[tostring(layerIndex - 1)] then
		shopMessageRemote:FireClient(player, "Unlock the layer above first!", false)
		return
	end
	if not PlayerData.SpendMoney(player, layer.Price) then
		shopMessageRemote:FireClient(player, "Not enough money!", false)
		return
	end
	data.UnlockedLayers[tostring(layerIndex)] = true
	updateAttributes(player)
	shopMessageRemote:FireClient(player, "Dig Permit unlocked: " .. layer.Name .. "!", true)
end)

-- Shop booth next to the dig site
local function buildShopBooth()
	if digSite:FindFirstChild("ShovelShop") then
		return digSite.ShovelShop
	end
	local shop = Instance.new("Model")
	shop.Name = "ShovelShop"

	local angle = math.rad(30)
	local pos = Vector3.new(math.cos(angle) * 76, 0, math.sin(angle) * 76)
	local base = CFrame.lookAt(pos, Vector3.new(0, 0, 0))
	local GOLD = Color3.fromRGB(255, 200, 60)
	local DARK = Color3.fromRGB(20, 22, 34)
	local NAVY = Color3.fromRGB(28, 34, 60)
	local WHITE = Color3.fromRGB(238, 240, 245)

	local function part(name, size, offset, color, material)
		local p = Instance.new("Part")
		p.Name = name
		p.Anchored = true
		p.Size = size
		p.CFrame = base * offset
		p.Color = color
		p.Material = material or Enum.Material.SmoothPlastic
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		if p.Material == Enum.Material.Neon then p.CastShadow = false end
		p.Parent = shop
		return p
	end

	part("Platform", Vector3.new(14, 0.6, 10), CFrame.new(0, 0.3, 0), NAVY)
	local counter = part("Counter", Vector3.new(12, 3.5, 2.5), CFrame.new(0, 2.35, -2.5), DARK)
	part("CounterTop", Vector3.new(12.4, 0.3, 3), CFrame.new(0, 4.25, -2.5), WHITE)
	part("CounterGlow", Vector3.new(12, 0.25, 0.2), CFrame.new(0, 3.5, -3.8), Color3.new(GOLD.R * 0.6, GOLD.G * 0.6, GOLD.B * 0.6), Enum.Material.Neon)
	part("BackWall", Vector3.new(14, 10, 0.8), CFrame.new(0, 5.6, 4.6), NAVY)
	part("PostL", Vector3.new(0.8, 10, 0.8), CFrame.new(-6.8, 5.6, -4.6), WHITE)
	part("PostR", Vector3.new(0.8, 10, 0.8), CFrame.new(6.8, 5.6, -4.6), WHITE)
	part("Roof", Vector3.new(15, 0.6, 11), CFrame.new(0, 10.9, 0), WHITE)
	part("RoofGlow", Vector3.new(15, 0.3, 0.3), CFrame.new(0, 10.5, -5.4), GOLD, Enum.Material.Neon)

	local colors = {Color3.fromRGB(255, 200, 40), Color3.fromRGB(175, 180, 190), Color3.fromRGB(255, 60, 200), Color3.fromRGB(120, 240, 255)}
	for i, color in ipairs(colors) do
		local x = -4.5 + (i - 1) * 3
		local lean = CFrame.new(x, 4.9, 3.8) * CFrame.Angles(math.rad(-10), 0, 0)
		part("DisplayShaft", Vector3.new(0.25, 6, 0.25), lean, WOOD, Enum.Material.Wood)
		part("DisplayBlade", Vector3.new(1.3, 1.5, 0.12), lean * CFrame.new(0, -3.5, 0), color, Enum.Material.Metal)
	end

	local sign = part("Sign", Vector3.new(12, 2.5, 0.4), CFrame.new(0, 12.5, -4.8), DARK)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0
	gui.Parent = sign
	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Size = UDim2.fromScale(1, 1)
	title.Text = "SHOVEL SHOP"
	title.TextColor3 = GOLD
	title.Font = Enum.Font.GothamBlack
	title.TextScaled = true
	title.Parent = gui

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Browse"
	prompt.ObjectText = "Shovels & Dig Permits"
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = counter

	shop.Parent = digSite
	return shop
end

-- Rebuild the booth each start so it matches the new ground height
local oldShop = digSite:FindFirstChild("ShovelShop")
if oldShop then oldShop:Destroy() end
local shop = require(script.Parent:WaitForChild("ShopBuilder"))(digSite)
shop:FindFirstChildWhichIsA("ProximityPrompt", true).Triggered:Connect(function(player)
	openShopRemote:FireClient(player)
end)

---------------------------------------------------------------------
-- PLAYERS
---------------------------------------------------------------------
local function onPlayerAdded(player)
	PlayerData.WaitForData(player)
	if not player.Parent then return end
	updateAttributes(player)
	player.CharacterAdded:Connect(function()
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
	sessions[player] = nil
end)

print("DigManager ready: terrain digging active")
