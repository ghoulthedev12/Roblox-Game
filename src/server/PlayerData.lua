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
	return total
end

local function refresh(player)
	local data = sessions[player]
	if not data then return end
	local income = computeIncome(data)
	player:SetAttribute("Money", data.Money)
	player:SetAttribute("Income", income)

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
