-- Gimmick_Permafrost (ModuleScript in ServerScriptService) - World 4, Frostbyte Tundra
-- Below the first layer the ground is frozen solid: an unheated pickaxe often just skids off
-- the ice. Two ways to melt through:
--   * a TORCH FLARE (press F or the flare button, WorldMechanicsClient): 20 seconds of heat,
--     then it has to recharge
--   * a heated pickaxe: this world's top three pickaxes run hot and never freeze
-- The flare's state lives in the player's "HeatUntil" / "FlareReadyAt" attributes (os.time()).

local GimmickHooks = require(script.Parent:WaitForChild("GimmickHooks"))

local Gimmick = {}
local FROZEN_CHANCE = 0.5  -- chance an unheated swing skids off the permafrost
local FLARE_SECONDS = 20
local FLARE_COOLDOWN = 45
local HEATED_FROM_POWER = 6 -- pickaxes this strong or better are heated

local lastMessage = {}

function Gimmick.Start(ctx)
	local world = ctx.World
	local rng = Random.new()
	local Api = GimmickHooks.Api
	local flareRemote = GimmickHooks.Remote("TorchFlare")
	ctx.Container:SetAttribute("TorchFlare", true)

	local function heated(player, def)
		return (def and def.Power >= HEATED_FROM_POWER) or (player:GetAttribute("HeatUntil") or 0) > os.time()
	end

	GimmickHooks.Register(world.Id, "BeforeDig", function(player, dig)
		if dig.ZoneIndex < 2 or heated(player, dig.Def) then return nil end
		if rng:NextNumber() > FROZEN_CHANCE then return nil end
		Api.Burst(dig.Position + Vector3.new(0, 2, 0), Color3.fromRGB(200, 240, 255), 16, 14)
		if os.clock() - (lastMessage[player] or 0) > 3 then
			lastMessage[player] = os.clock()
			Api.Message(player, "{Ice} Permafrost! Use a Torch Flare [F] to melt it, or get a heated pickaxe.", Color3.fromRGB(170, 225, 255))
		end
		return "block"
	end)

	flareRemote.OnServerEvent:Connect(function(player)
		if not ctx.IsHere(player) then return end
		if (player:GetAttribute("FlareReadyAt") or 0) > os.time() then return end
		player:SetAttribute("HeatUntil", os.time() + FLARE_SECONDS)
		player:SetAttribute("FlareReadyAt", os.time() + FLARE_SECONDS + FLARE_COOLDOWN)
		-- flames around the player while the flare burns
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if root then
			local fire = Instance.new("Fire")
			fire.Name = "TorchFlare"
			fire.Size = 5
			fire.Heat = 6
			fire.Color = Color3.fromRGB(255, 160, 60)
			fire.Parent = root
			local light = Instance.new("PointLight")
			light.Color = Color3.fromRGB(255, 170, 80)
			light.Range = 20
			light.Brightness = 2
			light.Parent = root
			task.delay(FLARE_SECONDS, function()
				fire:Destroy()
				light:Destroy()
			end)
		end
		Api.Message(player, "{Fire} Torch Flare! You melt through permafrost for 20 seconds.", Color3.fromRGB(255, 170, 80))
	end)
end

return Gimmick
