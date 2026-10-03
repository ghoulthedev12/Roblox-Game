-- AdminCommands (Script in ServerScriptService)
-- Chat commands for the game's owners, typed in the normal chat box while playing:
--   /givemoney <player> <amount>   e.g. /givemoney me 1m   or   /givemoney Bob 500k
--   /givegems <player> <amount>    e.g. /givegems me 100
-- <player> can be "me", "all", or the start of a username / display name.
-- <amount> understands k, m, b, t (1k = 1,000, 1m = 1,000,000 ...). A negative amount takes money away.
-- Only the group owner (rank 255 in the group that owns the game), people in ADMIN_IDS, and
-- anyone testing in Studio can use them. Everyone else gets nothing (the command is ignored).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local GroupService = game:GetService("GroupService")

local PlayerData = require(script.Parent:WaitForChild("PlayerData"))
local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))

-- extra admins by UserId (find it in the profile link: roblox.com/users/<UserId>/profile)
local ADMIN_IDS = {
	3644018974, -- ghouIk1 (owner)
}
local MIN_GROUP_RANK = 255 -- 255 = group owner; lower it (e.g. 254) to let group admins in too

local GOOD = Color3.fromRGB(120, 230, 120)
local BAD = Color3.fromRGB(255, 130, 130)
local SUFFIX = { k = 1e3, m = 1e6, b = 1e9, t = 1e12 }

local progressRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DigProgress")

local function isAdmin(player)
	if RunService:IsStudio() then return true end
	if table.find(ADMIN_IDS, player.UserId) then return true end
	if game.CreatorType == Enum.CreatorType.User then
		return player.UserId == game.CreatorId
	end
	local okInfo, info = pcall(GroupService.GetGroupInfoAsync, GroupService, game.CreatorId)
	if okInfo and info.Owner and info.Owner.Id == player.UserId then return true end
	local ok, rank = pcall(player.GetRankInGroup, player, game.CreatorId)
	return ok and rank >= MIN_GROUP_RANK
end

local function say(player, text, color)
	progressRemote:FireClient(player, text, color)
end

local function parseAmount(text)
	if not text then return nil end
	local number, suffix = string.match(string.lower(text), "^(%-?[%d%.]+)(%a?)$")
	number = tonumber(number)
	if not number then return nil end
	if suffix ~= "" then
		if not SUFFIX[suffix] then return nil end
		number *= SUFFIX[suffix]
	end
	return math.floor(number)
end

local function findTargets(caller, name)
	if not name or name == "" then return {} end
	name = string.lower(name)
	if name == "me" then return { caller } end
	if name == "all" then return Players:GetPlayers() end
	for _, player in Players:GetPlayers() do
		if string.lower(player.Name) == name or string.lower(player.DisplayName) == name then
			return { player }
		end
	end
	local found = {}
	for _, player in Players:GetPlayers() do
		if string.sub(string.lower(player.Name), 1, #name) == name
			or string.sub(string.lower(player.DisplayName), 1, #name) == name then
			table.insert(found, player)
		end
	end
	return #found == 1 and found or {} -- two matches = too unclear, give nothing
end

local function addGems(player, amount)
	local data = PlayerData.Get(player)
	if not data then return false end
	data.Gems = math.max(0, (data.Gems or 0) + amount)
	PlayerData.Refresh(player)
	return true
end

local GIVERS = {
	givemoney = {
		Give = PlayerData.AddMoney,
		Label = function(amount) return ArtifactData.FormatMoney(amount) end,
	},
	givegems = {
		Give = addGems,
		Label = function(amount) return amount .. " gems" end,
	},
}

local function run(caller, commandName, message)
	if not isAdmin(caller) then return end
	local giver = GIVERS[commandName]
	local args = string.split(message, " ")
	local targetName, amountText = args[2], args[3]
	local amount = parseAmount(amountText)
	if not amount then
		say(caller, "Use: /" .. commandName .. " <player|me|all> <amount>   (like 1m, 500k)", BAD)
		return
	end
	local targets = findTargets(caller, targetName)
	if #targets == 0 then
		say(caller, "No single player found for \"" .. tostring(targetName) .. "\".", BAD)
		return
	end
	for _, target in targets do
		if giver.Give(target, amount) then
			say(caller, "Gave " .. giver.Label(amount) .. " to " .. target.DisplayName .. ".", GOOD)
			if target ~= caller then
				say(target, "{Coin} An admin gave you " .. giver.Label(amount) .. "!", GOOD)
			end
		end
	end
end

for commandName in GIVERS do
	local command = Instance.new("TextChatCommand")
	command.Name = "Admin_" .. commandName
	command.PrimaryAlias = "/" .. commandName
	command.Parent = TextChatService
	command.Triggered:Connect(function(textSource, message)
		local caller = Players:GetPlayerByUserId(textSource.UserId)
		if caller then run(caller, commandName, message) end
	end)
end
