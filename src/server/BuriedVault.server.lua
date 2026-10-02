-- BuriedVault (Script in ServerScriptService)
-- A race in worlds 2-9: every few minutes (while someone is in the world) a golden vault is
-- buried somewhere in the pit. A golden beam shoots up from it with its depth on top, and
-- everyone in the world is told. The first player to dig into it (a swing within a few studs)
-- cracks it open: a guaranteed Rare-or-better meme from the deep layers waiting in the dirt,
-- plus gems and cash. Nobody gets there in time? It sinks away.
-- Counts toward the "Open a Buried Vault" world quests (Quests.Progress "Vault").

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))
local GimmickHooks = require(script.Parent:WaitForChild("GimmickHooks"))
local Quests = require(script.Parent:WaitForChild("Quests"))

local EVERY = {200, 320}       -- seconds between vaults in a world
local LIFETIME = 180           -- seconds before an unclaimed vault sinks away
local CLAIM_RADIUS = 9         -- a dig this close to the vault cracks it open
local ZONE_WEIGHTS = {0.45, 0.4, 0.15} -- how often it's buried in the Shallow / Mid / Deep zone
local REWARD_LUCK = 30         -- luck of the meme inside (rolled in the world's Deep Zone)
local REWARD_GEMS = 8
local REWARD_CASH = 0.03       -- x the world's unlock price
local GOLD = Color3.fromRGB(255, 205, 70)

local announceRemote = GimmickHooks.Remote("Announcement")
local rng = Random.new()
local active = {} -- [worldId] = {Model, Position, Zone, Spawned}

local function playersIn(worldId)
	local list = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player:GetAttribute("CurrentWorld") == worldId then table.insert(list, player) end
	end
	return list
end

local function announce(worldId, text, color)
	for _, player in ipairs(playersIn(worldId)) do
		announceRemote:FireClient(player, text, color)
	end
end

local function part(parent, name, size, cf, color, material, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	if shape then p.Shape = shape end
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false -- clicks go through to the dirt around it
	p.CanTouch = false
	p.Parent = parent
	return p
end

-- the vault: a chunky gold chest with dark bands and a glowing lock, plus the beam above it
local function buildVault(world, position, depth)
	local model = Instance.new("Model")
	model.Name = "BuriedVault"
	local base = CFrame.new(position) * CFrame.Angles(0, rng:NextNumber(0, math.pi * 2), 0)
	local body = part(model, "Body", Vector3.new(5, 3, 3.4), base, GOLD, Enum.Material.Foil)
	part(model, "Lid", Vector3.new(3.4, 5, 3.4), base * CFrame.new(0, 1.5, 0) * CFrame.Angles(0, 0, math.rad(90)), GOLD:Lerp(Color3.new(1, 1, 1), 0.15),
		Enum.Material.Foil, Enum.PartType.Cylinder)
	for _, x in ipairs({-1.6, 1.6}) do
		part(model, "Band", Vector3.new(0.5, 3.1, 3.5), base * CFrame.new(x, 0, 0), Color3.fromRGB(90, 60, 30))
		part(model, "LidBand", Vector3.new(0.5, 3.5, 3.5), base * CFrame.new(x, 1.5, 0) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(90, 60, 30),
			nil, Enum.PartType.Cylinder)
	end
	local lock = part(model, "Lock", Vector3.new(0.9, 1.1, 0.4), base * CFrame.new(0, 0.6, -1.8), Color3.fromRGB(120, 255, 220), Enum.Material.Neon)
	local light = Instance.new("PointLight")
	light.Color = GOLD
	light.Range = 28
	light.Brightness = 3
	light.Parent = body
	local sparkles = Instance.new("ParticleEmitter")
	sparkles.Color = ColorSequence.new(Color3.new(1, 1, 1), GOLD)
	sparkles.LightEmission = 1
	sparkles.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 0)})
	sparkles.Lifetime = NumberRange.new(0.8, 1.4)
	sparkles.Rate = 18
	sparkles.Speed = NumberRange.new(2, 5)
	sparkles.SpreadAngle = Vector2.new(180, 180)
	sparkles.Parent = lock
	model.PrimaryPart = body

	-- the beam: from the vault up out of the pit, so you can see where to dig
	local top = world.Origin.Y + 45
	local height = top - position.Y
	local beam = part(model, "Beam", Vector3.new(height, 1.6, 1.6), CFrame.new(position.X, position.Y + height / 2, position.Z) * CFrame.Angles(0, 0, math.rad(90)),
		GOLD, Enum.Material.Neon, Enum.PartType.Cylinder)
	beam.Transparency = 0.45
	beam.CastShadow = false
	local tip = part(model, "BeamTip", Vector3.new(1, 1, 1), CFrame.new(position.X, top, position.Z), GOLD)
	tip.Transparency = 1
	local sign = Instance.new("BillboardGui")
	sign.Size = UDim2.fromOffset(260, 80)
	sign.StudsOffset = Vector3.new(0, 4, 0)
	sign.AlwaysOnTop = true
	sign.MaxDistance = 700
	sign.Parent = tip
	local function text(t, y, size, color)
		local l = Instance.new("TextLabel")
		l.BackgroundTransparency = 1
		l.Size = UDim2.new(1, 0, 0.5, 0)
		l.Position = UDim2.fromScale(0, y)
		l.Font = Enum.Font.FredokaOne
		l.Text = t
		l.TextScaled = true
		l.TextColor3 = color
		l.Parent = sign
		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 3
		stroke.Color = Color3.fromRGB(40, 25, 5)
		stroke.Parent = l
		return l
	end
	text("BURIED VAULT", 0, 40, GOLD)
	text(math.floor(depth) .. "m DOWN  ·  DIG IT OUT!", 0.5, 28, Color3.new(1, 1, 1))
	return model
end

local function removeVault(worldId, sink)
	local vault = active[worldId]
	if not vault then return end
	active[worldId] = nil
	local model = vault.Model
	if sink and model.PrimaryPart then
		for _, p in ipairs(model:GetDescendants()) do
			if p:IsA("BasePart") then
				TweenService:Create(p, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{CFrame = p.CFrame - Vector3.new(0, 12, 0), Transparency = 1}):Play()
			end
		end
		Debris:AddItem(model, 1.6)
	else
		model:Destroy()
	end
end

local function spawnVault(world)
	-- which zone (only the first three: every pickaxe past the starter can reach them)
	local roll, zoneIndex = rng:NextNumber(), 1
	local running = 0
	for i, w in ipairs(ZONE_WEIGHTS) do
		running += w
		if roll <= running then zoneIndex = i break end
	end
	local zone = world.Zones[zoneIndex]
	local depth = rng:NextNumber(-zone.Top + 8, -zone.Bottom - 8)
	local a = rng:NextNumber(0, math.pi * 2)
	local r = rng:NextNumber(world.CenterNoDigRadius + 8, world.PitRadius - 8)
	local position = world.Origin + Vector3.new(math.cos(a) * r, -depth, math.sin(a) * r)
	local worlds = workspace:FindFirstChild("Worlds")
	local container = worlds and worlds:FindFirstChild("World" .. world.Id) or workspace
	local model = buildVault(world, position, depth)
	model.Parent = container
	local vault = {Model = model, Position = position, Zone = zone, Spawned = os.clock()}
	active[world.Id] = vault
	announce(world.Id, "{Coin} A BURIED VAULT appeared " .. math.floor(depth) .. "m down! Follow the golden beam and dig it out first!", GOLD)
	task.delay(LIFETIME, function()
		if active[world.Id] == vault then
			removeVault(world.Id, true)
			announce(world.Id, "The Buried Vault sank out of reach...", Color3.fromRGB(200, 200, 215))
		end
	end)
end

local function claim(player, world, vault)
	removeVault(world.Id, false)
	local Api = GimmickHooks.Api
	Api.Burst(vault.Position, GOLD, 60, 22)
	-- the reward: a deep-layer meme rolled with huge luck, left in the dirt to pull out
	local deep = world.Zones[math.min(3, #world.Zones)]
	local artifact = ArtifactData.RollForZone(deep, REWARD_LUCK)
	if artifact and not Api.GiveFind(player, deep, REWARD_LUCK, vault.Position, artifact) then
		Api.AddArtifactNow(player, artifact) -- they're already pulling something out: straight into the bag
		Quests.Found(player, artifact, deep.Index)
	end
	local cash = math.floor(world.Price * REWARD_CASH)
	if cash > 0 then PlayerData.AddMoney(player, cash) end
	local data = PlayerData.Get(player)
	if data then
		data.Gems = (data.Gems or 0) + REWARD_GEMS
		PlayerData.Refresh(player)
	end
	Api.Message(player, "{Coin} VAULT CRACKED! +" .. ArtifactData.FormatMoney(cash) .. " +" .. REWARD_GEMS .. " gems, and a rare meme is waiting in the dirt!", GOLD)
	announce(world.Id, player.DisplayName .. " cracked open the Buried Vault!", GOLD)
	Quests.Progress(player, "Vault")
end

for _, world in ipairs(GameConfig.Worlds) do
	if world.Id ~= 1 and world.Enabled then
		-- a swing close enough to the vault cracks it (and takes the place of a normal find roll)
		GimmickHooks.Register(world.Id, "AfterDig", function(player, dig)
			local vault = active[world.Id]
			if vault and (dig.Position - vault.Position).Magnitude <= CLAIM_RADIUS then
				claim(player, world, vault)
				return true
			end
			return nil
		end)
		task.spawn(function()
			task.wait(rng:NextNumber(60, 120))
			while true do
				if not active[world.Id] and #playersIn(world.Id) > 0 then
					spawnVault(world)
				end
				task.wait(rng:NextNumber(EVERY[1], EVERY[2]))
			end
		end)
	end
end
