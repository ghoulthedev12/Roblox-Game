-- Gimmick_Oxygen (ModuleScript in ServerScriptService) - World 6, Coral Circuit
-- The deep pit is full of toxic fumes. Below OxygenDepth studs your air meter drains
-- (WorldGimmickClient shows it); bubbling air vents set into the pit walls at every few
-- depths refill it, and so does climbing back near the surface. Run out and you're pulled
-- back up to the surface (nobody dies, but you lose your spot).
-- The vents are tagged "AirVent" so the client can find them.

local CollectionService = game:GetService("CollectionService")

local Gimmick = {}
local OXYGEN_DEPTH = 20
local VENT_DEPTHS = {28, 60, 100, 150, 210, 280, 360, 450, 530}
local VENTS_PER_DEPTH = 4

local function part(parent, name, size, cf, color, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.Metal
	p.Parent = parent
	return p
end

function Gimmick.Start(ctx)
	local world = ctx.World
	local origin = world.Origin
	ctx.Container:SetAttribute("OxygenDepth", OXYGEN_DEPTH)
	for d, depth in ipairs(VENT_DEPTHS) do
		for i = 0, VENTS_PER_DEPTH - 1 do
			local a = (i + (d % 2) * 0.5) / VENTS_PER_DEPTH * math.pi * 2
			local r = world.PitRadius + 1.4
			local pos = origin + Vector3.new(math.cos(a) * r, -depth, math.sin(a) * r)
			local facing = CFrame.lookAt(pos, Vector3.new(origin.X, pos.Y, origin.Z))
			local vent = Instance.new("Model")
			vent.Name = "AirVent"
			-- a round grate facing into the pit, a glowing rim, and bubbles pouring out
			local grate = part(vent, "Grate", Vector3.new(1, 4, 4), facing * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(60, 70, 90))
			grate.Shape = Enum.PartType.Cylinder
			local rim = part(vent, "VentGlow", Vector3.new(1.1, 4.6, 4.6), facing * CFrame.new(0, 0, 0.2) * CFrame.Angles(0, math.rad(90), 0),
				Color3.fromRGB(90, 230, 255), Enum.Material.Neon)
			rim.Shape = Enum.PartType.Cylinder
			local light = Instance.new("PointLight")
			light.Color = Color3.fromRGB(120, 230, 255)
			light.Range = 16
			light.Brightness = 1.2
			light.Parent = rim
			local bubbles = Instance.new("ParticleEmitter")
			bubbles.Color = ColorSequence.new(Color3.fromRGB(200, 245, 255))
			bubbles.LightEmission = 0.4
			bubbles.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 0.6)})
			bubbles.Transparency = NumberSequence.new(0.2, 1)
			bubbles.Lifetime = NumberRange.new(1.5, 2.5)
			bubbles.Rate = 18
			bubbles.Speed = NumberRange.new(2, 4)
			bubbles.Acceleration = Vector3.new(0, 4, 0)
			bubbles.EmissionDirection = Enum.NormalId.Left -- out of the grate, into the pit
			bubbles.SpreadAngle = Vector2.new(25, 25)
			bubbles.Parent = grate
			vent.PrimaryPart = grate
			vent.Parent = ctx.Folder
			CollectionService:AddTag(grate, "AirVent")
		end
	end
end

return Gimmick
