-- WorldGate (ModuleScript in ServerScriptService)
-- Builds the portal players use to travel between worlds: a big chunky portal ring
-- with a swirling energy film, standing on a round tiered base between two capsule
-- towers, with orbiting planets, a rounded sign and a friendly terminal kiosk.
-- Once the Blender portal is imported (PortalMeshes), the ring is a heavy machined gunmetal
-- frame with brass conduits, standing in a cradle, around a glowing event horizon with two
-- sets of spiral arms spinning opposite ways and light being pulled into it.
-- Returns the gate model and its ProximityPrompt.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Architecture = require(script.Parent:WaitForChild("Architecture"))
local PortalMeshes = require(ReplicatedStorage:WaitForChild("PortalMeshes"))

local rgb = Color3.fromRGB
local PIECES = {"GatePortalFrame", "GatePortalGlow", "GateHorizon", "GateVortexA", "GateVortexB"}

-- spun around the portal's axis on every player's screen by ShovelSpinner
local function spin(part, pivot, speed)
	part:SetAttribute("OrbitPivot", pivot)
	part:SetAttribute("OrbitOffset", pivot:ToObjectSpace(part.CFrame))
	part:SetAttribute("OrbitSpeed", speed)
	CollectionService:AddTag(part, "ShovelOrbit")
end

-- the Blender portal: frame, glow, event horizon (a force-field skin over a deep violet dish),
-- spinning vortex arms, a light and motes of light drifting into the middle
local function meshPortal(gate, center)
	PortalMeshes.place(gate, "GatePortalFrame", center, {Material = Enum.Material.Metal, Reflectance = 0.05})
	PortalMeshes.place(gate, "GatePortalGlow", center, {Material = Enum.Material.Neon, Color = rgb(150, 235, 255)})
	PortalMeshes.place(gate, "GateHorizon", center * CFrame.new(0, 0, 0.12), {Material = Enum.Material.Neon, Color = rgb(52, 30, 120)})
	local horizon = PortalMeshes.place(gate, "GateHorizon", center, {Material = Enum.Material.ForceField, Color = rgb(175, 130, 255)})
	horizon.Name = "PortalSkin"
	spin(PortalMeshes.place(gate, "GateVortexA", center, {Material = Enum.Material.Neon, Color = rgb(140, 220, 255), Transparency = 0.3}), center, 0.9)
	spin(PortalMeshes.place(gate, "GateVortexB", center, {Material = Enum.Material.Neon, Color = rgb(200, 150, 255), Transparency = 0.45}), center, -0.55)
	local light = Instance.new("PointLight")
	light.Color = rgb(190, 160, 255)
	light.Range = 20
	light.Brightness = 1.4
	light.Parent = horizon
	local motes = Instance.new("ParticleEmitter")
	motes.Name = "PortalMotes"
	motes.Shape = Enum.ParticleEmitterShape.Sphere
	motes.ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface
	motes.ShapeInOut = Enum.ParticleEmitterShapeInOut.Inward
	motes.Color = ColorSequence.new(rgb(220, 245, 255), rgb(170, 120, 255))
	motes.LightEmission = 1
	motes.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.05), NumberSequenceKeypoint.new(0.3, 0.3), NumberSequenceKeypoint.new(1, 0)})
	motes.Transparency = NumberSequence.new(0.1, 0.9)
	motes.Lifetime = NumberRange.new(1, 1.5)
	motes.Speed = NumberRange.new(3.5, 5)
	motes.Rate = 22
	motes.Parent = horizon
end

-- parent: where it goes. base: its CFrame (front, local -Z, faces the players).
return function(parent, base, subtitle)
	local gate = Instance.new("Model")
	gate.Name = "WorldGate"
	local b = Architecture.builder(gate, base)

	-- round tiered base with a glowing lip
	local _, floorY = b:tiers("GateBase", CFrame.new(0, 0, 0), {
		{24, 0.5, "Sky"},
		{23.2, 0.3, "GlowCyan"},
		{22, 0.7, "White"},
		{15, 0.4, "Cloud"},
	})
	b:roundedBlock("GateStep", Vector3.new(10, 0.5, 3), CFrame.new(0, 0.25, -12.4), 1.4, "Cloud")

	-- the portal: the Blender ring once imported, otherwise a thick white ring, a lilac inner
	-- ring, a glowing edge and the energy film
	local center = CFrame.new(0, floorY + 9.5, 0)
	if PortalMeshes.has(table.unpack(PIECES)) then
		meshPortal(gate, base * center)
	else
		b:ring("PortalRing", center, 8.2, 2.2, "White", 32)
		b:ring("PortalInner", center * CFrame.new(0, 0, -0.9), 7, 0.7, "Lilac", 32)
		b:ring("PortalGlow", center * CFrame.new(0, 0, -1.2), 7.2, 0.3, "GlowPink", 32)
		local film = b:rod("PortalFilm", 0.3, 13.6, center * CFrame.Angles(0, math.rad(90), 0), "Portal", {CanCollide = false})
		film.Transparency = 0.25
		local swirl = b:rod("PortalSwirl", 0.2, 9, center * CFrame.new(0, 0, -0.2) * CFrame.Angles(0, math.rad(90), 0), "GlowCyan", {CanCollide = false})
		swirl.Transparency = 0.55
		local glow = Instance.new("PointLight")
		glow.Color = Color3.fromRGB(200, 170, 255)
		glow.Range = 18
		glow.Brightness = 1.2
		glow.Parent = film
		-- chunky feet holding the ring
		for _, side in ipairs({-1, 1}) do
			b:roundedBlock("RingFoot", Vector3.new(3.2, 2.4, 3.2), CFrame.new(side * 5.4, floorY + 1.2, 0), 1.2, "Violet")
		end
		-- sparkle bulbs around the ring
		for i = 0, 11 do
			local a = math.rad(i * 30 + 15)
			b:bulb("RingBulb", 0.7, center * CFrame.new(math.cos(a) * 8.2, math.sin(a) * 8.2, -1.25), i % 2 == 0 and "GlowSun" or "GlowCyan", 5)
		end
	end

	-- capsule towers either side, topped with little planets
	for _, side in ipairs({-1, 1}) do
		local x = side * 11.5
		b:disc("TowerFoot", 3.6, 0.8, CFrame.new(x, floorY + 0.4, 1), "Violet")
		b:pill("Tower", Vector3.new(x, floorY + 1.5, 1), Vector3.new(x, floorY + 14, 1), 2.4, "White")
		b:disc("TowerBand", 2.7, 0.4, CFrame.new(x, floorY + 5, 1), "GlowMint")
		b:disc("TowerBand", 2.7, 0.4, CFrame.new(x, floorY + 10, 1), "Lilac")
		local planet = CFrame.new(x, floorY + 17, 1)
		b:ball("Planet", 3, planet, side < 0 and "Sun" or "Mint")
		b:ring("PlanetRing", planet * CFrame.Angles(math.rad(70), 0, math.rad(side * 20)), 2.3, 0.3, side < 0 and "Coral" or "Lilac", 16)
	end

	-- rounded sign on top of the ring
	local sign = b:roundedBlock("GateSign", Vector3.new(15, 3.6, 1.2), center * CFrame.new(0, 10.6, -0.2), 1.6, "Navy")
	b:roundedBlock("GateSignBack", Vector3.new(15.8, 4.2, 1), center * CFrame.new(0, 10.6, 0.2), 1.9, "Violet")
	Architecture.sign(sign, "WORLD GATE", subtitle or "TRAVEL BETWEEN DIG SITES")
	b:ball("SignStar", 1.4, center * CFrame.new(0, 13.2, 0), "GlowSun")

	-- terminal kiosk (a friendly capsule with a tilted screen)
	b:disc("KioskFoot", 3, 0.4, CFrame.new(0, floorY + 0.2, -7), "Violet")
	local kiosk = b:roundedBlock("Kiosk", Vector3.new(2.6, 3.4, 1.6), CFrame.new(0, floorY + 2.1, -7), 0.8, "Sky")
	local screen = b:roundedBlock("KioskScreen", Vector3.new(3, 1.8, 0.3), CFrame.new(0, floorY + 4.2, -7.3) * CFrame.Angles(math.rad(-25), 0, 0), 0.15, "Navy")
	Architecture.sign(screen, "WORLD MAP", "PRESS E", nil, Color3.new(1, 1, 1))

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Open World Map"
	prompt.ObjectText = "World Gate"
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = kiosk

	gate.Parent = parent
	return gate, prompt
end
