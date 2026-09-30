-- Gimmick_GoldRush (ModuleScript in ServerScriptService) - World 5, Chrome Dunes
-- A golden sandstorm sweeps the pit every few minutes: for 45 seconds everyone digging here
-- finds things 3x as often (with a bit more luck), and golden glitter pours into the pit.

local Gimmick = {}

function Gimmick.Start(ctx)
	local world = ctx.World
	local volume = Instance.new("Part")
	volume.Name = "GoldDust"
	volume.Anchored = true
	volume.CanCollide = false
	volume.CanQuery = false
	volume.CanTouch = false
	volume.Transparency = 1
	volume.Size = Vector3.new(world.PitRadius * 2, 2, world.PitRadius * 2)
	volume.CFrame = CFrame.new(world.Origin + Vector3.new(0, 30, 0))
	volume.Parent = ctx.Folder
	local glitter = Instance.new("ParticleEmitter")
	glitter.Shape = Enum.ParticleEmitterShape.Box
	glitter.Color = ColorSequence.new(Color3.fromRGB(255, 240, 150), Color3.fromRGB(255, 180, 40))
	glitter.LightEmission = 1
	glitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0.1)})
	glitter.Lifetime = NumberRange.new(3, 5)
	glitter.Rate = 60
	glitter.Speed = NumberRange.new(6, 12)
	glitter.EmissionDirection = Enum.NormalId.Bottom
	glitter.SpreadAngle = Vector2.new(15, 15)
	glitter.RotSpeed = NumberRange.new(-200, 200)
	glitter.Enabled = false
	glitter.Parent = volume

	ctx.EventLoop({
		Every = 150, Duration = 45, Name = "GOLD RUSH",
		Boost = {FindMult = 3, LuckMult = 1.3},
		Message = "🪙 GOLD RUSH! You find artifacts 3x as often for 45 seconds!",
		Color = Color3.fromRGB(255, 214, 90),
		OnStart = function() glitter.Enabled = true end,
		OnStop = function() glitter.Enabled = false end,
	})
end

return Gimmick
