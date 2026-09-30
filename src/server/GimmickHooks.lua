-- GimmickHooks (ModuleScript in ServerScriptService)
-- Lets a world's gimmick plug into digging without DigManager knowing about every world.
-- A gimmick registers functions for its world:
--   BeforeDig(player, dig)        return "block" to stop this swing (e.g. frozen permafrost)
--   AfterDig(player, dig)         return true if it took over this swing's find roll
--                                 (e.g. a curse trap or a data node went off instead)
--   OnPull(player, artifact, pos) return true if it takes over giving the artifact
--                                 (e.g. a meme ghost has to be captured first)
--   LuckMult(player, dig)         return a luck multiplier for this swing
-- dig = {Zone = zone, ZoneIndex = n, Position = where it hit, Def = the pickaxe}
-- DigManager fills GimmickHooks.Api with helpers the gimmicks can call (see DigManager).

local GimmickHooks = {}
GimmickHooks.Api = {}

local registry = {} -- [hookName][worldId] = {functions}
local locks = {}    -- [player] = time the pickaxe unlocks

function GimmickHooks.Register(worldId, hookName, fn)
	registry[hookName] = registry[hookName] or {}
	registry[hookName][worldId] = registry[hookName][worldId] or {}
	table.insert(registry[hookName][worldId], fn)
end

-- runs every function for this hook in this world; returns the first truthy answer
function GimmickHooks.Run(hookName, worldId, ...)
	local list = registry[hookName] and registry[hookName][worldId]
	if not list then return nil end
	for _, fn in ipairs(list) do
		local ok, result = pcall(fn, ...)
		if not ok then
			warn("Gimmick hook " .. hookName .. " failed: " .. tostring(result))
		elseif result then
			return result
		end
	end
	return nil
end

-- multiplies every LuckMult answer together
function GimmickHooks.Luck(worldId, ...)
	local list = registry.LuckMult and registry.LuckMult[worldId]
	local luck = 1
	for _, fn in ipairs(list or {}) do
		local ok, result = pcall(fn, ...)
		if ok and typeof(result) == "number" then luck *= result end
	end
	return luck
end

-- stop a player's pickaxe from digging for a few seconds (curse traps)
function GimmickHooks.LockDig(player, seconds)
	locks[player] = os.clock() + seconds
	player:SetAttribute("DigLockedUntil", os.time() + seconds)
end

function GimmickHooks.IsLocked(player)
	return locks[player] ~= nil and os.clock() < locks[player]
end

-- a RemoteEvent in ReplicatedStorage.Remotes (made if it doesn't exist yet)
function GimmickHooks.Remote(name)
	local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
	local r = remotes:FindFirstChild(name) or Instance.new("RemoteEvent")
	r.Name = name
	r.Parent = remotes
	return r
end

game:GetService("Players").PlayerRemoving:Connect(function(player)
	locks[player] = nil
end)

return GimmickHooks
