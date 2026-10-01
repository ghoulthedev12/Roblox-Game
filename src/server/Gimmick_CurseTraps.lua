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
