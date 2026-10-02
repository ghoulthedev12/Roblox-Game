-- Quests (ModuleScript in ServerScriptService)
-- World quests, the Meme Index and World Mastery for worlds 2-9 (the lists are in
-- ReplicatedStorage.QuestData). Other server scripts report what players do:
--   Quests.Found(player, artifact, zoneIndex)  a meme was dug up (and kept)
--   Quests.Progress(player, kind, amount)      something else happened (Ghost, Flare, Vault...)
-- Progress only counts toward the quest the player is on in the world they're standing in.
-- Finishing a quest pays its reward straight away and moves on to the next one; finishing
-- the last one masters the world (+25% luck there, a LuckMult gimmick hook).
-- The Meme Index (every meme you've ever found) is tracked in PlayerData.AddArtifact; this
-- module pays the reward when a world's page is complete. Its income bonus is applied by
-- PlayerData's income (data.IndexClaimed).
--
-- Saved in the player's data:
--   Quests = {["2"] = {Step = 3, Progress = 1}, ...}   (Step past the last = mastered)
--   Discovered = {[memeId] = true}                    IndexClaimed = {["2"] = true}
-- The client asks for its state with the GetQuestState RemoteFunction and is pushed
-- updates on the QuestUpdate RemoteEvent ("State", state) and ("Complete", info).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local QuestData = require(ReplicatedStorage:WaitForChild("QuestData"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))
local GimmickHooks = require(script.Parent:WaitForChild("GimmickHooks"))

local Quests = {}

-- (DigManager loads this module before it makes the Remotes folder, so make it if needed)
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not remotes then
	remotes = Instance.new("Folder")
	remotes.Name = "Remotes"
	remotes.Parent = ReplicatedStorage
end
local function remoteEvent(name)
	local r = remotes:FindFirstChild(name) or Instance.new("RemoteEvent")
	r.Name = name
	r.Parent = remotes
	return r
end
local updateRemote = remoteEvent("QuestUpdate")
local announceRemote = remoteEvent("Announcement")
local getState = remotes:FindFirstChild("GetQuestState") or Instance.new("RemoteFunction")
getState.Name = "GetQuestState"
getState.Parent = remotes

-- which world each meme belongs to, and how many memes each world has (for the index)
local worldMemes = {} -- [worldId] = {ids}
for _, artifact in ipairs(ArtifactData.Artifacts) do
	if not artifact.BaseId then
		worldMemes[artifact.World] = worldMemes[artifact.World] or {}
		table.insert(worldMemes[artifact.World], artifact.Id)
	end
end
Quests.WorldMemes = worldMemes

local function questState(data, worldId)
	data.Quests = data.Quests or {}
	local key = tostring(worldId)
	data.Quests[key] = data.Quests[key] or {Step = 1, Progress = 0}
	return data.Quests[key]
end

function Quests.IsMastered(player, worldId)
	local data = PlayerData.Get(player)
	if not data or not QuestData.Worlds[worldId] then return false end
	return questState(data, worldId).Step > QuestData.Count(worldId)
end

-- everything the client needs to draw the Quests window
local function snapshot(data)
	local state = {Quests = {}, Discovered = {}, IndexClaimed = {}}
	for worldId in pairs(QuestData.Worlds) do
		local q = questState(data, worldId)
		state.Quests[tostring(worldId)] = {Step = q.Step, Progress = q.Progress}
	end
	for id in pairs(data.Discovered or {}) do table.insert(state.Discovered, id) end
	for key, value in pairs(data.IndexClaimed or {}) do state.IndexClaimed[key] = value end
	return state
end

local function push(player)
	local data = PlayerData.Get(player)
	if data then updateRemote:FireClient(player, "State", snapshot(data)) end
end
Quests.Push = push

getState.OnServerInvoke = function(player)
	local data = PlayerData.WaitForData(player)
	return data and snapshot(data) or nil
end

local function giveGems(player, amount)
	local data = PlayerData.Get(player)
	if not data or amount <= 0 then return end
	data.Gems = (data.Gems or 0) + amount
	PlayerData.Refresh(player)
end

local function rewardText(cash, gems)
	local parts = {}
	if cash > 0 then table.insert(parts, "+" .. ArtifactData.FormatMoney(cash)) end
	if gems > 0 then table.insert(parts, "+" .. gems .. " gems") end
	return table.concat(parts, "  ")
end

-- adds progress to the quest the player is on in this world; pays out when it's done
local function advance(player, worldId, kind, amount, test)
	local list = QuestData.Worlds[worldId]
	local data = PlayerData.Get(player)
	if not list or not data then return end
	local q = questState(data, worldId)
	local quest = list[q.Step]
	if not quest or quest.Kind ~= kind then return end
	if test and not test(quest) then return end
	q.Progress = math.min(q.Progress + (amount or 1), quest.Goal)
	if q.Progress < quest.Goal then
		push(player)
		return
	end
	-- done: pay it, move on
	local world = GameConfig.GetWorld(worldId)
	local cash = math.floor((world and world.Price or 0) * (quest.Cash or 0))
	if cash > 0 then PlayerData.AddMoney(player, cash) end
	giveGems(player, quest.Gems or 0)
	q.Step += 1
	q.Progress = 0
	local mastered = q.Step > #list
	updateRemote:FireClient(player, "Complete", {
		World = worldId, Text = quest.Text, Reward = rewardText(cash, quest.Gems or 0), Mastered = mastered,
		Next = list[q.Step] and list[q.Step].Text or nil,
	})
	if mastered then
		announceRemote:FireAllClients(player.DisplayName .. " MASTERED " .. (world and world.Name or "a world") .. "! +25% luck there forever.",
			Color3.fromRGB(255, 215, 90))
	end
	push(player)
end

local function currentWorldId(player)
	return player:GetAttribute("CurrentWorld") or 1
end

function Quests.Progress(player, kind, amount)
	advance(player, currentWorldId(player), kind, amount)
end

local function eventRunning(worldId)
	local worlds = workspace:FindFirstChild("Worlds")
	local container = worlds and worlds:FindFirstChild("World" .. worldId)
	local event = container and container:GetAttribute("Event")
	return typeof(event) == "string" and event ~= ""
end

-- a meme was dug up and kept (zoneIndex = the depth zone it came from, nil if unknown)
function Quests.Found(player, artifact, zoneIndex)
	if not artifact then return end
	local worldId = currentWorldId(player)
	advance(player, worldId, "Find", 1)
	if zoneIndex then
		advance(player, worldId, "FindZone", 1, function(quest) return zoneIndex >= (quest.Zone or 1) end)
	end
	local rarityIndex = ArtifactData.GetRarityIndex(artifact.Rarity)
	advance(player, worldId, "FindRarity", 1, function(quest) return rarityIndex >= ArtifactData.GetRarityIndex(quest.Rarity) end)
	if eventRunning(worldId) then
		advance(player, worldId, "EventFind", 1)
	end
end

---------------------------------------------------------------------
-- MEME INDEX: PlayerData marks every meme you get as discovered; when a world's whole page
-- is found, pay the reward once and switch on its income bonus
---------------------------------------------------------------------
local function checkIndex(player, worldId)
	local data = PlayerData.Get(player)
	local ids = worldMemes[worldId]
	if not data or not ids or worldId == 1 then return end
	data.IndexClaimed = data.IndexClaimed or {}
	local key = tostring(worldId)
	if data.IndexClaimed[key] then return end
	for _, id in ipairs(ids) do
		if not (data.Discovered and data.Discovered[id]) then return end
	end
	data.IndexClaimed[key] = true
	giveGems(player, QuestData.IndexGems)
	PlayerData.Refresh(player) -- the income bonus kicks in
	local world = GameConfig.GetWorld(worldId)
	updateRemote:FireClient(player, "Complete", {
		World = worldId, Index = true, Text = (world and world.Name or "World") .. " Meme Index complete!",
		Reward = "+" .. QuestData.IndexGems .. " gems  +" .. math.floor(QuestData.IndexIncomeBonus * 100) .. "% income from its memes",
	})
	announceRemote:FireAllClients(player.DisplayName .. " completed the " .. (world and world.Name or "") .. " Meme Index!", Color3.fromRGB(120, 230, 255))
end

PlayerData.ArtifactAdded:Connect(function(player, artifactId, isNew)
	local artifact = ArtifactData.GetArtifact(artifactId)
	if not artifact then return end
	if isNew then
		checkIndex(player, artifact.World)
		push(player)
	end
end)

---------------------------------------------------------------------
-- MASTERY: +25% luck in a world once all its quests are done
---------------------------------------------------------------------
for worldId in pairs(QuestData.Worlds) do
	GimmickHooks.Register(worldId, "LuckMult", function(player)
		return Quests.IsMastered(player, worldId) and QuestData.MasteryLuck or 1
	end)
end

-- returning players: everything already in their bag or museum counts as discovered, and
-- worlds whose index they already finished pay out
local function onLoaded(player)
	local data = PlayerData.WaitForData(player)
	if not data then return end
	data.Discovered = data.Discovered or {}
	for _, list in ipairs({data.Inventory or {}, data.Displayed or {}}) do
		for _, id in pairs(list) do
			local artifact = ArtifactData.GetArtifact(id)
			if artifact then data.Discovered[artifact.BaseId or artifact.Id] = true end
		end
	end
	for worldId in pairs(QuestData.Worlds) do
		questState(data, worldId)
		checkIndex(player, worldId)
	end
	push(player)
end
Players.PlayerAdded:Connect(onLoaded)
for _, player in ipairs(Players:GetPlayers()) do task.spawn(onLoaded, player) end

return Quests
