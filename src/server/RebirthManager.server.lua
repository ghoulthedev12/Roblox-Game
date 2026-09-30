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
			messageRemote:FireClient(player, "♻️ REBIRTH " .. data.Rebirths .. "! +" .. math.floor(GameConfig.RebirthIncomeBonus * 100) .. "% income forever and +" .. gems .. " 💎", true)
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
		messageRemote:FireClient(player, "You need " .. cost .. " 💎 for the next Lucky Charm level.", false)
		return
	end
	data.Gems -= cost
	data.GemLuckLevel += 1
	PlayerData.Refresh(player)
	messageRemote:FireClient(player, "🍀 Lucky Charm level " .. data.GemLuckLevel .. "! +" .. math.floor(GameConfig.GemLuckPerLevel * 100 * data.GemLuckLevel) .. "% luck", true)
end)

Players.PlayerRemoving:Connect(function(player)
	busy[player] = nil
end)
