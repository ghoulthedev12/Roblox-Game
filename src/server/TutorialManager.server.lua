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
