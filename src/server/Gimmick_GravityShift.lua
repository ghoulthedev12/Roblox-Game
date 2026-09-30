-- Gimmick_GravityShift (ModuleScript in ServerScriptService) - World 3, Galaxy Drift
-- Deep in the pit gravity can't make up its mind. Every so often it FLIPS for a few seconds:
-- either it pulls UP (you float up out of your crater) or SIDEWAYS (you get flung toward a
-- wall). The shift is announced on the world folder's "GravityShift" attribute and played
-- on each player's own screen by WorldMechanicsClient (gravity is simulated per player).
-- Reward for braving it: the deep layers (zone 3+) here give 1.5x luck.

local GimmickHooks = require(script.Parent:WaitForChild("GimmickHooks"))

local Gimmick = {}
local EVERY = {18, 30}
local DURATION = 3
Gimmick.DEEP_DEPTH = 150 -- only players deeper than this feel it

function Gimmick.Start(ctx)
	local rng = Random.new()
	ctx.Container:SetAttribute("GravityShiftDepth", Gimmick.DEEP_DEPTH)
	GimmickHooks.Register(ctx.World.Id, "LuckMult", function(_player, dig)
		return dig.ZoneIndex >= 3 and 1.5 or 1
	end)
	task.spawn(function()
		while ctx.Container.Parent do
			task.wait(rng:NextNumber(EVERY[1], EVERY[2]))
			if #ctx.PlayersInWorld() > 0 then
				local mode = rng:NextNumber() < 0.5 and "Up" or "Side"
				local angle = rng:NextNumber(0, 360)
				-- the value changes every time, so the client always notices a new shift
				ctx.Container:SetAttribute("GravityShift", mode .. ":" .. math.floor(angle) .. ":" .. os.clock())
				task.wait(DURATION)
				ctx.Container:SetAttribute("GravityShift", "")
			end
		end
	end)
end

return Gimmick
