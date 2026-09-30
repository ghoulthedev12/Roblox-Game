-- Gimmick_LowGravity (ModuleScript in ServerScriptService) - World 3, Galaxy Drift
-- Gravity is much weaker here: WorldGimmickClient lowers workspace.Gravity on the player's
-- screen (gravity is simulated by each player's own computer for their character) while
-- they're in this world. Drifting star dust floats up out of the pit to sell the feeling.

local Gimmick = {}
local LOW_GRAVITY = 55 -- Roblox's normal gravity is 196.2

function Gimmick.Start(ctx)
	ctx.Container:SetAttribute("Gravity", LOW_GRAVITY)
	local world = ctx.World
	local volume = Instance.new("Part")
	volume.Name = "FloatingStarDust"
	volume.Anchored = true
	volume.CanCollide = false
	volume.CanQuery = false
	volume.CanTouch = false
	volume.Transparency = 1
	volume.Size = Vector3.new(world.PitRadius * 2, 4, world.PitRadius * 2)
	volume.CFrame = CFrame.new(world.Origin + Vector3.new(0, 2, 0))
	volume.Parent = ctx.Folder
	local dust = Instance.new("ParticleEmitter")
	dust.Shape = Enum.ParticleEmitterShape.Box
	dust.Color = ColorSequence.new(Color3.fromRGB(200, 180, 255), Color3.fromRGB(120, 220, 255))
	dust.LightEmission = 1
	dust.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.4, 0.3), NumberSequenceKeypoint.new(1, 0)})
	dust.Lifetime = NumberRange.new(5, 8)
	dust.Rate = 20
	dust.Speed = NumberRange.new(1, 3)
	dust.EmissionDirection = Enum.NormalId.Top
	dust.SpreadAngle = Vector2.new(20, 20)
	dust.Parent = volume
end

return Gimmick
