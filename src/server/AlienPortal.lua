-- AlienPortal (ModuleScript in ServerScriptService)
-- A green, swirly "Rick and Morty" style portal that pops open out of thin air, stands on
-- the ground for a moment while aliens step through, then snaps shut.
-- It's a tall glowing oval: a lime rim, a bright jelly-green middle, a pale glowing core and
-- a swirling force-field skin, with green sparks, dripping goo, a splash ring on the ground
-- and a green light. It wobbles like jelly while it's open.
-- Once the Blender pieces are imported (PortalMeshes) it's a lumpy rim of goo with drips
-- hanging off it, around a deep rippled glassy tunnel with glowing spiral arms spinning into it.
--
--   local portal = AlienPortal.open(parent, cframe)  -- cframe on the ground, -Z = the side aliens come out of
--   AlienPortal.close(portal)                        -- shrinks it away and destroys it
--   AlienPortal.Size                                 -- how much room it needs (for picking a spot)
-- Markers in the model: "Core" (in the middle of the oval, at standing height) and "Front"
-- (on the ground a few studs in front of it).

local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PortalMeshes = require(ReplicatedStorage:WaitForChild("PortalMeshes"))

local rgb = Color3.fromRGB
local AlienPortal = {}

local HEIGHT, WIDTH = 9.5, 6.6
local CENTER_Y = HEIGHT / 2 + 0.3
AlienPortal.Size = Vector3.new(WIDTH + 2, HEIGHT + 1, 4)

-- {name, size multiplier (x, y), thickness, color, material, transparency}
local LAYERS = {
	{"PortalRim", 1, 0.3, rgb(140, 255, 60), Enum.Material.Neon, 0},
	{"PortalJelly", 0.88, 0.42, rgb(40, 170, 40), Enum.Material.Neon, 0},
	{"PortalSwirl", 0.86, 0.5, rgb(120, 255, 80), Enum.Material.ForceField, 0},
	{"PortalCore", 0.34, 0.62, rgb(235, 255, 205), Enum.Material.Neon, 0.1},
}

-- the Blender pieces: {name, properties}
local MESH_PIECES = {
	{"AlienPortalFunnel", {Material = Enum.Material.Glass, Color = rgb(60, 190, 50), Transparency = 0.12, Reflectance = 0.08}},
	{"AlienPortalRim", {Material = Enum.Material.Neon, Color = rgb(140, 255, 60)}},
	{"AlienPortalSwirl", {Material = Enum.Material.Neon, Color = rgb(215, 255, 170), Transparency = 0.1}},
}
local CLOSED = 0.03 -- how small the pieces start and end

local function part(parent, name, size, cf, color, material, transparency)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material
	p.Transparency = transparency or 0
	p.Parent = parent
	return p
end

local function oval(parent, name, size, cf, color, material, transparency)
	local p = part(parent, name, size, cf, color, material, transparency)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Scale = Vector3.new(0.02, 0.02, 1) -- starts closed
	mesh.Parent = p
	return p, mesh
end

local function emitter(parent, props)
	local e = Instance.new("ParticleEmitter")
	for k, v in pairs(props) do e[k] = v end
	e.Parent = parent
	return e
end

function AlienPortal.open(parent, cf)
	local portal = Instance.new("Model")
	portal.Name = "AlienPortal"
	portal:SetAttribute("NoCalm", true)
	local center = cf * CFrame.new(0, CENTER_Y, 0)
	local meshes, grow = {}, {} -- sphere meshes that pop open, Blender pieces that grow {Part, Size}
	local useMeshes = PortalMeshes.has("AlienPortalRim", "AlienPortalFunnel", "AlienPortalSwirl")
	if useMeshes then
		for _, piece in ipairs(MESH_PIECES) do
			local data = PortalMeshes.Data[piece[1]]
			local p = PortalMeshes.place(portal, piece[1], center, piece[2], CLOSED)
			p.CFrame = center * CFrame.new(data.Center)
			table.insert(grow, {Part = p, Size = data.Size})
		end
		-- a pale glow deep in the tunnel
		local _, mesh = oval(portal, "PortalCore", Vector3.new(1.7, 2.4, 0.3), center * CFrame.new(0, 0, 1.05), rgb(235, 255, 205), Enum.Material.Neon, 0.1)
		table.insert(meshes, mesh)
		-- the spiral arms spin into the tunnel on every player's screen (ShovelSpinner)
		local swirl = portal:FindFirstChild("AlienPortalSwirl")
		swirl:SetAttribute("OrbitPivot", center)
		swirl:SetAttribute("OrbitOffset", center:ToObjectSpace(swirl.CFrame))
		swirl:SetAttribute("OrbitSpeed", -2.6)
		CollectionService:AddTag(swirl, "ShovelOrbit")
	else
		for i, layer in ipairs(LAYERS) do
			local size = Vector3.new(WIDTH * layer[2], HEIGHT * layer[2], layer[3])
			-- layers stack front to back a little so they don't flicker into each other
			local _, mesh = oval(portal, layer[1], size, center * CFrame.new(0, 0, (i - 2.5) * 0.04), layer[4], layer[5], layer[6])
			table.insert(meshes, mesh)
		end
	end
	local core = portal:FindFirstChild("PortalCore")
	local rim = portal:FindFirstChild("PortalRim") or portal:FindFirstChild("AlienPortalRim")

	-- green light spilling out onto the ground
	local light = Instance.new("PointLight")
	light.Color = rgb(120, 255, 80)
	light.Range = 18
	light.Brightness = 0
	light.Parent = core

	-- swirling sparks pouring out of the front, and goo dripping off the rim
	emitter(core, {
		Name = "PortalSparks", Color = ColorSequence.new(rgb(210, 255, 170), rgb(90, 230, 50)), LightEmission = 1,
		Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.45), NumberSequenceKeypoint.new(1, 0)}),
		Transparency = NumberSequence.new(0, 1), Lifetime = NumberRange.new(0.6, 1.1), Rate = 40,
		Speed = NumberRange.new(2, 5), SpreadAngle = Vector2.new(35, 35), RotSpeed = NumberRange.new(-360, 360),
		EmissionDirection = Enum.NormalId.Front, Drag = 2,
	})
	emitter(rim, {
		Name = "PortalGoo", Color = ColorSequence.new(rgb(120, 240, 60)), LightEmission = 0.6,
		Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0.1)}),
		Transparency = NumberSequence.new(0.1, 0.8), Lifetime = NumberRange.new(0.6, 1), Rate = 14,
		Speed = NumberRange.new(0, 1), SpreadAngle = Vector2.new(180, 180), Acceleration = Vector3.new(0, -30, 0),
		Shape = Enum.ParticleEmitterShape.Box,
	})

	-- a splash of green light on the ground under it
	local splash = part(portal, "PortalSplash", Vector3.new(0.12, 1, 1), cf * CFrame.new(0, 0.1, -0.5) * CFrame.Angles(0, 0, math.rad(90)),
		rgb(120, 255, 80), Enum.Material.Neon, 0.5)
	splash.Shape = Enum.PartType.Cylinder

	-- markers for VisitorManager
	local coreMarker = part(portal, "Core", Vector3.new(1, 1, 1), cf * CFrame.new(0, 3, 0), Color3.new(), Enum.Material.SmoothPlastic, 1)
	coreMarker.Name = "Core"
	part(portal, "Front", Vector3.new(1, 1, 1), cf * CFrame.new(0, 3, -6), Color3.new(), Enum.Material.SmoothPlastic, 1)
	portal.Parent = parent

	-- POP OPEN: a burst of sparks, then the oval springs out with an overshoot
	local burst = emitter(core, {
		Enabled = false, Color = ColorSequence.new(rgb(230, 255, 200), rgb(100, 240, 60)), LightEmission = 1,
		Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(1, 0)}),
		Transparency = NumberSequence.new(0, 1), Lifetime = NumberRange.new(0.4, 0.8),
		Speed = NumberRange.new(10, 22), SpreadAngle = Vector2.new(180, 180), Drag = 4,
	})
	burst:Emit(70)
	local pop = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	for _, mesh in ipairs(meshes) do
		TweenService:Create(mesh, pop, {Scale = Vector3.new(1, 1, 1)}):Play()
	end
	for _, item in ipairs(grow) do
		TweenService:Create(item.Part, pop, {Size = item.Size}):Play()
	end
	TweenService:Create(light, TweenInfo.new(0.3), {Brightness = 3}):Play()
	TweenService:Create(splash, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Size = Vector3.new(0.12, 9, 9), Transparency = 0.7}):Play()
	-- then wobble like jelly while it's open, with a glowing spiral spinning inside
	task.delay(0.5, function()
		if not portal.Parent or portal:GetAttribute("Closing") then return end
		local wobble = TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		if useMeshes then
			for i, item in ipairs(grow) do
				local k = i % 2 == 0 and 1 or -1
				TweenService:Create(item.Part, wobble, {Size = item.Size * Vector3.new(1 + 0.04 * k, 1 - 0.03 * k, 1)}):Play()
			end
			TweenService:Create(core, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.5}):Play()
			return
		end
		local spiral = Instance.new("Model")
		spiral.Name = "Spiral"
		for arm = 0, 2 do
			for i = 1, 24 do
				local t = i / 24
				local a = arm * math.pi * 2 / 3 + t * math.pi * 1.8
				local r = 0.35 + t * 2.55
				local dot = part(spiral, "SpiralDot", Vector3.one * (0.62 - t * 0.3),
					center * CFrame.new(math.cos(a) * r, math.sin(a) * r, -0.36), rgb(200, 255, 150):Lerp(rgb(60, 200, 40), t), Enum.Material.Neon, 0.05)
				dot.Shape = Enum.PartType.Ball
				-- spun on every player's screen by ShovelSpinner
				dot:SetAttribute("OrbitPivot", center)
				dot:SetAttribute("OrbitOffset", center:ToObjectSpace(dot.CFrame))
				dot:SetAttribute("OrbitSpeed", -3.2)
				CollectionService:AddTag(dot, "ShovelOrbit")
			end
		end
		spiral.Parent = portal
		for i, mesh in ipairs(meshes) do
			local k = i % 2 == 0 and 1 or -1
			TweenService:Create(mesh, wobble, {Scale = Vector3.new(1 + 0.05 * k, 1 - 0.04 * k, 1)}):Play()
		end
		local core2 = portal:FindFirstChild("PortalCore")
		if core2 then
			TweenService:Create(core2, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.45}):Play()
		end
	end)
	return portal
end

function AlienPortal.close(portal)
	if not portal or not portal.Parent or portal:GetAttribute("Closing") then return end
	portal:SetAttribute("Closing", true)
	local spiral = portal:FindFirstChild("Spiral")
	if spiral then spiral:Destroy() end
	local shut = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	for _, d in ipairs(portal:GetDescendants()) do
		if d:IsA("SpecialMesh") then
			TweenService:Create(d, shut, {Scale = Vector3.new(0.02, 0.02, 1)}):Play()
		elseif d:IsA("MeshPart") then
			TweenService:Create(d, shut, {Size = d.Size * CLOSED}):Play()
		elseif d:IsA("ParticleEmitter") then
			d.Enabled = false
		elseif d:IsA("PointLight") then
			TweenService:Create(d, shut, {Brightness = 0}):Play()
		end
	end
	local splash = portal:FindFirstChild("PortalSplash")
	if splash then TweenService:Create(splash, shut, {Size = Vector3.new(0.12, 0.5, 0.5), Transparency = 1}):Play() end
	Debris:AddItem(portal, 0.8)
end

return AlienPortal
