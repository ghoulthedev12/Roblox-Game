-- AlienPortal (ModuleScript in ServerScriptService)
-- A glowing sci-fi portal the alien visitors come out of and leave through: a hover platform,
-- a thick violet ring with a neon inner rim, two spinning chrome arcs, pylons with glowing
-- tips, a swirling force-field vortex with sparkles, and floating crystals over the top.
-- Usage: AlienPortal(parent, cframe) -> model. cframe sits on the ground; -Z is the side the
-- aliens walk out of. Markers in the model: "Core" (inside the ring, where aliens appear and
-- vanish) and "Front" (on the ground in front of the portal).
-- The vortex and the arcs are spun on each player's screen by ShovelSpinner ("ShovelOrbit" tag).

local CollectionService = game:GetService("CollectionService")
local Architecture = require(script.Parent:WaitForChild("Architecture"))

local rgb = Color3.fromRGB
local RING_R = 7
local PLATFORM_TOP = 1.7

local function marker(parent, name, cf)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Transparency = 1
	p.Size = Vector3.new(2, 1, 2)
	p.CFrame = cf
	p.Parent = parent
	return p
end

-- makes a part spin around the portal's axis on every player's screen
local function spin(part, pivot, speed)
	part:SetAttribute("OrbitPivot", pivot)
	part:SetAttribute("OrbitOffset", pivot:ToObjectSpace(part.CFrame))
	part:SetAttribute("OrbitSpeed", speed)
	CollectionService:AddTag(part, "ShovelOrbit")
end

return function(parent, cf)
	local portal = Instance.new("Model")
	portal.Name = "AlienPortal"
	portal.Parent = parent
	local b = Architecture.builder(portal, cf)
	local ringY = PLATFORM_TOP + RING_R + 0.4
	local center = cf * CFrame.new(0, ringY, 0)

	-- hover platform
	b:tiers("PortalBase", CFrame.new(), {{RING_R * 2 + 5, 0.6, "Ink"}, {RING_R * 2 + 3.6, 0.3, "GlowPink"}, {RING_R * 2 + 2.4, 0.8, "Navy"}})
	b:ring("PortalBaseGlow", CFrame.new(0, PLATFORM_TOP + 0.05, 0) * CFrame.Angles(math.rad(90), 0, 0), RING_R + 0.2, 0.3, "GlowCyan", 40)

	-- the ring itself
	b:ring("PortalRing", CFrame.new(0, ringY, 0), RING_R, 1.7, "Violet", 36)
	b:ring("PortalRim", CFrame.new(0, ringY, -0.9), RING_R - 0.9, 0.45, "GlowCyan", 36)
	b:ring("PortalRim", CFrame.new(0, ringY, 0.9), RING_R - 0.9, 0.45, "GlowPink", 36)
	-- feet that hold the ring on the platform
	for _, s in ipairs({-1, 1}) do
		b:box("PortalFoot", Vector3.new(2.2, 2.2, 3.2), CFrame.new(s * 2.4, PLATFORM_TOP + 0.9, 0) * CFrame.Angles(0, 0, s * math.rad(-30)), "Ink")
	end

	-- chrome arcs that spin around the ring
	local arcs = Instance.new("Model")
	arcs.Name = "PortalArcs"
	arcs.Parent = portal
	local ab = Architecture.builder(arcs, cf)
	ab:ring("PortalArc", CFrame.new(0, ringY, 0), RING_R + 1.5, 0.5, "Chrome", 10, 110, 20)
	ab:ring("PortalArc", CFrame.new(0, ringY, 0), RING_R + 1.5, 0.5, "Chrome", 10, 110, 200)
	for _, p in ipairs(arcs:GetDescendants()) do
		if p:IsA("BasePart") then spin(p, center, 0.8) end
	end

	-- pylons with glowing tips on both sides
	for _, s in ipairs({-1, 1}) do
		b:pill("PortalPylon", Vector3.new(s * (RING_R + 3.2), PLATFORM_TOP, 0), Vector3.new(s * (RING_R + 3.2), PLATFORM_TOP + 10, 0), 1.1, "Ink")
		b:box("PylonStrip", Vector3.new(0.2, 8, 0.2), CFrame.new(s * (RING_R + 3.2), PLATFORM_TOP + 5, -0.6), "GlowCyan")
		b:bulb("PylonTip", 1.5, CFrame.new(s * (RING_R + 3.2), PLATFORM_TOP + 10.9, 0), "GlowPink", 10)
	end

	-- the vortex: a force-field disc and a glowing disc behind it, both spinning
	local swirl = b:rod("PortalVortex", 0.25, RING_R * 2 - 1.4, CFrame.new(0, ringY, 0) * CFrame.Angles(0, math.rad(90), 0), "Portal")
	swirl.Color = rgb(170, 130, 255)
	local glow = b:rod("PortalVortexGlow", 0.2, RING_R * 2 - 1.8, CFrame.new(0, ringY, 0.25) * CFrame.Angles(0, math.rad(90), 0), "GlowCyan")
	glow.Color = rgb(120, 90, 255)
	glow.Transparency = 0.55
	spin(swirl, center, 2.2)
	spin(glow, center, -1.4)
	for _, p in ipairs({swirl, glow}) do
		p.CanCollide = false
		p.CanQuery = false
	end
	local light = Instance.new("PointLight")
	light.Color = rgb(170, 130, 255)
	light.Range = 18
	light.Brightness = 1.4
	light.Parent = swirl
	local sparkles = Instance.new("ParticleEmitter")
	sparkles.Name = "VortexSparkles"
	sparkles.Color = ColorSequence.new(rgb(200, 170, 255), rgb(110, 230, 255))
	sparkles.LightEmission = 1
	sparkles.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0)})
	sparkles.Transparency = NumberSequence.new(0.1, 1)
	sparkles.Lifetime = NumberRange.new(0.8, 1.4)
	sparkles.Rate = 30
	sparkles.Speed = NumberRange.new(1, 3)
	sparkles.SpreadAngle = Vector2.new(25, 25)
	sparkles.RotSpeed = NumberRange.new(-180, 180)
	sparkles.EmissionDirection = Enum.NormalId.Right -- out of the portal's face
	sparkles.Parent = swirl

	-- floating crystals over the ring
	for i, x in ipairs({-3, 0, 3}) do
		local y = ringY + RING_R + 2.2 + (i == 2 and 1.2 or 0)
		b:box("PortalCrystal", Vector3.new(0.7, 1.8, 0.7), CFrame.new(x, y, 0) * CFrame.Angles(0, math.rad(45), math.rad(x * 6)), i == 2 and "GlowPink" or "GlowCyan")
	end

	for _, d in ipairs(portal:GetDescendants()) do
		-- only the platform and the pylons are solid: aliens walk straight through the ring
		if d:IsA("BasePart") and not (d.Name:find("^PortalBase") or d.Name:find("^PortalPylon")) then
			d.CanCollide = false
		end
	end

	-- markers for VisitorManager
	marker(portal, "Core", cf * CFrame.new(0, PLATFORM_TOP + 3, 0))
	marker(portal, "Front", cf * CFrame.new(0, 3, -(RING_R + 5)))
	portal:SetAttribute("NoCalm", true)
	return portal
end
