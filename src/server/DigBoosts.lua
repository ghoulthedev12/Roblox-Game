-- DigBoosts (ModuleScript in ServerScriptService)
-- Temporary digging bonuses from the world gimmicks: world-wide events (Gold Rush, Blizzard
-- luck, Glitch Surge) and personal boosts (the Candy merchant's Sugar Rush).
-- DigManager asks DigBoosts.Get(player, world) on every swing. Each player's attributes
-- "DigSpeedMult" (swing cooldown multiplier), "WorldEvent" and "WorldEventEnds" and
-- "PersonalBoost"/"PersonalBoostEnds" are kept up to date so the client can show them.

local Players = game:GetService("Players")

local DigBoosts = {}

local worldEvents = {}    -- [worldId] = {Name, FindMult, LuckMult, CooldownMult, EndsAt}
local personal = {}       -- [player] = {Name, CooldownMult, LuckMult, EndsAt}

local function active(boost)
	return boost and os.clock() < boost.EndsAt
end

-- a world-wide event, e.g. DigBoosts.StartWorldEvent(5, {Name = "GOLD RUSH", FindMult = 3}, 40)
function DigBoosts.StartWorldEvent(worldId, boost, seconds)
	boost.EndsAt = os.clock() + seconds
	worldEvents[worldId] = boost
end

function DigBoosts.EndWorldEvent(worldId)
	worldEvents[worldId] = nil
end

function DigBoosts.GetWorldEvent(worldId)
	local e = worldEvents[worldId]
	return active(e) and e or nil
end

function DigBoosts.GivePersonal(player, boost, seconds)
	boost.EndsAt = os.clock() + seconds
	personal[player] = boost
end

function DigBoosts.GetPersonal(player)
	local p = personal[player]
	return active(p) and p or nil
end

-- the multipliers for this player's next swing in this world
function DigBoosts.Get(player, world)
	local find, luck, cooldown = 1, 1, 1
	local e = DigBoosts.GetWorldEvent(world.Id)
	if e then
		find *= e.FindMult or 1
		luck *= e.LuckMult or 1
		cooldown *= e.CooldownMult or 1
	end
	local p = DigBoosts.GetPersonal(player)
	if p then
		find *= p.FindMult or 1
		luck *= p.LuckMult or 1
		cooldown *= p.CooldownMult or 1
	end
	return {Find = find, Luck = luck, Cooldown = cooldown}
end

-- keep every player's attributes in sync (the client times its swings and shows timers from them)
task.spawn(function()
	while true do
		for _, player in ipairs(Players:GetPlayers()) do
			local worldId = player:GetAttribute("CurrentWorld") or 1
			local e = DigBoosts.GetWorldEvent(worldId)
			local p = DigBoosts.GetPersonal(player)
			local now = os.clock()
			local cooldown = (e and e.CooldownMult or 1) * (p and p.CooldownMult or 1)
			player:SetAttribute("DigSpeedMult", cooldown)
			player:SetAttribute("WorldEvent", e and e.Name or "")
			player:SetAttribute("WorldEventLeft", e and math.ceil(e.EndsAt - now) or 0)
			player:SetAttribute("PersonalBoost", p and p.Name or "")
			player:SetAttribute("PersonalBoostLeft", p and math.ceil(p.EndsAt - now) or 0)
		end
		task.wait(0.5)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	personal[player] = nil
end)

return DigBoosts
