-- DigSiteStyle (ModuleScript in ServerScriptService)
-- Makes a world's dig site match the cartoony 2050 look:
--   * recolors the rim, walkways, racks, gates, lamps and props into the soft palette
--   * adds a chunky candy-striped rim ring with bulbs around the pit
--   * strings party lights between the lamp posts
--   * puts a glowing halo over the giant hard drive
--   * hides glowing zone rings inside the pit walls at every zone boundary, so players
--     see a colored ring appear in the dirt when they dig past 50, 130 and 200 studs
-- The Shovel Shop and World Gate are skipped (they're already built in this style).

local Architecture = require(script.Parent:WaitForChild("Architecture"))
local CityBuilder = require(script.Parent:WaitForChild("CityBuilder"))
local P = Architecture.Palette

local SKIP = {ShovelShop = true, WorldGate = true, Cartoon2050 = true}

-- specific parts that deserve a specific color
local NAMED = {
	RimWall = "Lilac", RimCap = "White", Curb = "Lilac", RampPost = "Lilac",
	Walkway = "White", Ramp = "White", TileJoint = "Cloud",
	GatePost = "Violet", GateBeam = "Violet", GateSign = "Navy",
	ServerRack = "Navy", LampBase = "Violet", LampPole = "White", FloodPole = "White",
	FloodBase = "Violet", FloodHousing = "Sky", Cable = "Violet", BarrelBand = "Violet",
}

local function recolor(root)
	for _, d in ipairs(root:GetDescendants()) do
		local skip = false
		local a = d.Parent
		while a and a ~= root do
			if SKIP[a.Name] then
				skip = true
				break
			end
			a = a.Parent
		end
		if not skip and d:IsA("BasePart") then
			local finish = NAMED[d.Name]
			if finish then
				local f = P[finish]
				d.Color = f.Color
				d.Material = f.Material
				d.Reflectance = 0
			else
				CityBuilder.cartoonify(d)
			end
		end
	end
end

---------------------------------------------------------------------
-- PIT ATMOSPHERE: glowing crystal veins in the walls, floating dust, soft rim lighting
---------------------------------------------------------------------
local rgb = Color3.fromRGB
local VEIN_COLORS = {rgb(110, 230, 255), rgb(255, 130, 220), rgb(170, 140, 255), rgb(120, 255, 200)}

local function invisible(name, size, cf, parent)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Transparency = 1
	p.Size = size
	p.CFrame = cf
	p.Parent = parent
	return p
end

local function crystalVeins(folder, world, rng)
	local origin = world.Origin
	local colors = VEIN_COLORS
	if world.Look and world.Look.Glow then
		colors = {world.Look.Glow, world.Look.Glow:Lerp(Color3.new(1, 1, 1), 0.35), VEIN_COLORS[1]}
	end
	local deepest = -world.Zones[#world.Zones].Bottom
	local VEINS = 18
	for v = 1, VEINS do
		local vein = Instance.new("Model")
		vein.Name = "CrystalVein"
		vein.Parent = folder
		local color = colors[(v - 1) % #colors + 1]
		-- spread evenly around the pit and down through every zone (a few near the top)
		local angle = (v / VEINS) * math.pi * 2 + rng:NextNumber(-0.12, 0.12)
		local depth = v <= 4 and rng:NextNumber(3, 12) or rng:NextNumber(14, deepest - 12)
		local slope = rng:NextNumber(-0.35, 0.35) -- how the streak runs sideways as it goes down
		local steps = rng:NextInteger(6, 9)
		for i = 1, steps do
			local a = angle + slope * i * 0.03
			local y = origin.Y - depth - i * 1.3
			local r = world.PitRadius + 3.2 + rng:NextNumber(-0.4, 0.6)
			local pos = origin + Vector3.new(math.cos(a) * r, 0, math.sin(a) * r)
			pos = Vector3.new(pos.X, y, pos.Z)
			local inward = Vector3.new(origin.X, y, origin.Z)
			local length = rng:NextNumber(1.4, 3.2)
			local cf = CFrame.lookAt(pos, inward) * CFrame.Angles(math.rad(-90) + rng:NextNumber(-0.6, 0.6), 0, rng:NextNumber(-0.6, 0.6))
				* CFrame.new(0, length * 0.3, 0)
			local core = Instance.new("Part")
			core.Name = "VeinCrystal"
			core.Size = Vector3.new(0.45, length, 0.45)
			core.CFrame = cf
			core.Color = color
			core.Material = Enum.Material.Neon
			core.Parent = vein
			local shell = Instance.new("Part")
			shell.Name = "VeinShell"
			shell.Size = Vector3.new(0.85, length * 0.75, 0.85)
			shell.CFrame = cf * CFrame.new(0, -length * 0.1, 0) * CFrame.Angles(0, math.rad(45), 0)
			shell.Color = color:Lerp(Color3.new(1, 1, 1), 0.25)
			shell.Material = Enum.Material.Glass
			shell.Transparency = 0.45
			shell.Reflectance = 0.2
			shell.Parent = vein
			if i == math.ceil(steps / 2) then
				local light = Instance.new("PointLight")
				light.Color = color
				light.Range = 14
				light.Brightness = 0.8
				light.Shadows = false
				light.Parent = core
			end
		end
		for _, p in ipairs(vein:GetChildren()) do
			p.Anchored = true
			p.CanCollide = false
			p.CanQuery = false
			p.CanTouch = false
			p.CastShadow = false
		end
	end
end

-- features that make each deep layer look different when you dig past it:
--   the crystal layer (zone 3) gets big glowing crystal clusters growing out of the walls,
--   the magma core (zone 4) gets glowing cracks of lava with embers drifting up out of them
local function layerFeatures(folder, world, rng)
	local origin = world.Origin
	local crystalZone, magmaZone = world.Zones[3], world.Zones[4]
	local function wallCFrame(angle, depth, inset)
		local r = world.PitRadius + (inset or 3)
		local pos = origin + Vector3.new(math.cos(angle) * r, -depth, math.sin(angle) * r)
		return CFrame.lookAt(pos, Vector3.new(origin.X, pos.Y, origin.Z))
	end
	local function glow(parent, name, size, cf, color, material, transparency)
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
		p.Material = material or Enum.Material.Neon
		p.Transparency = transparency or 0
		p.Parent = parent
		return p
	end
	if crystalZone then
		local color = crystalZone.Color:Lerp(Color3.new(1, 1, 1), 0.15)
		for i = 1, 12 do
			local base = wallCFrame(i / 12 * math.pi * 2 + rng:NextNumber(-0.2, 0.2), rng:NextNumber(-crystalZone.Top + 10, -crystalZone.Bottom - 10))
			local cluster = Instance.new("Model")
			cluster.Name = "CrystalCluster"
			cluster.Parent = folder
			for k = 1, 6 do
				local length = rng:NextNumber(2, 5)
				local cf = base * CFrame.Angles(math.rad(-90) + rng:NextNumber(-0.7, 0.7), 0, rng:NextNumber(-0.7, 0.7)) * CFrame.new(0, length * 0.35, 0)
				glow(cluster, "Crystal", Vector3.new(length * 0.28, length, length * 0.28), cf * CFrame.Angles(0, math.rad(45), 0),
					color:Lerp(Color3.new(1, 1, 1), 0.3), Enum.Material.Glass, 0.2)
				glow(cluster, "CrystalCore", Vector3.new(length * 0.12, length * 0.85, length * 0.12), cf, color)
			end
			local light = Instance.new("PointLight")
			light.Color = color
			light.Range = 16
			light.Brightness = 1
			light.Parent = cluster:FindFirstChild("CrystalCore")
		end
	end
	if magmaZone then
		local hot = Color3.fromRGB(255, 120, 40)
		for i = 1, 14 do
			local angle = i / 14 * math.pi * 2 + rng:NextNumber(-0.15, 0.15)
			local depth = rng:NextNumber(-magmaZone.Top + 8, -magmaZone.Bottom - 8)
			local crack = Instance.new("Model")
			crack.Name = "MagmaCrack"
			crack.Parent = folder
			-- a zig-zag glowing seam running down the wall
			local y = depth
			local a = angle
			local last
			for _ = 1, 7 do
				local nextY, nextA = y + rng:NextNumber(2, 4), a + rng:NextNumber(-0.04, 0.04)
				local p0 = wallCFrame(a, y, 1.2).Position
				local p1 = wallCFrame(nextA, nextY, 1.2).Position
				last = glow(crack, "MagmaSeam", Vector3.new(0.35, 0.35, (p1 - p0).Magnitude + 0.3), CFrame.lookAt((p0 + p1) / 2, p1), hot)
				y, a = nextY, nextA
			end
			local light = Instance.new("PointLight")
			light.Color = hot
			light.Range = 18
			light.Brightness = 1.4
			light.Parent = last
			local embers = Instance.new("ParticleEmitter")
			embers.Color = ColorSequence.new(Color3.fromRGB(255, 220, 120), Color3.fromRGB(255, 60, 20))
			embers.LightEmission = 1
			embers.Size = NumberSequence.new(0.18, 0)
			embers.Lifetime = NumberRange.new(2, 3.5)
			embers.Rate = 5
			embers.Speed = NumberRange.new(1, 3)
			embers.Acceleration = Vector3.new(0, 3, 0)
			embers.SpreadAngle = Vector2.new(40, 40)
			embers.EmissionDirection = Enum.NormalId.Top
			embers.Parent = last
		end
	end
end

local function floatingDust(folder, world)
	local origin = world.Origin
	local width = world.PitRadius * 2
	-- one cloud over the pit, one filling the upper dig layers
	for _, layer in ipairs({{Y = 8, Height = 18, Rate = 14}, {Y = -40, Height = 70, Rate = 18}}) do
		local volume = invisible("PitDust", Vector3.new(width, layer.Height, width), CFrame.new(origin + Vector3.new(0, layer.Y, 0)), folder)
		local dust = Instance.new("ParticleEmitter")
		dust.Shape = Enum.ParticleEmitterShape.Box
		dust.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
		dust.Color = ColorSequence.new(rgb(255, 236, 200), rgb(200, 220, 255))
		dust.LightEmission = 0.45
		dust.LightInfluence = 0.4
		dust.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.3, 0.22), NumberSequenceKeypoint.new(1, 0)})
		dust.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.3, 0.35), NumberSequenceKeypoint.new(1, 1)})
		dust.Lifetime = NumberRange.new(6, 10)
		dust.Rate = layer.Rate
		dust.Speed = NumberRange.new(0.2, 0.7)
		dust.SpreadAngle = Vector2.new(180, 180)
		dust.Acceleration = Vector3.new(0, 0.12, 0)
		dust.RotSpeed = NumberRange.new(-30, 30)
		dust.Parent = volume
	end
end

local function rimLighting(folder, world)
	local origin = world.Origin
	-- a soft glowing strip right at the lip of the pit
	local lip = Instance.new("Model")
	lip.Name = "RimGlow"
	lip.Parent = folder
	local lb = Architecture.builder(lip, CFrame.new(origin))
	lb:ring("RimGlowRing", CFrame.new(0, 0.35, 0) * CFrame.Angles(math.rad(90), 0, 0), world.PitRadius + 2.6, 0.5, "GlowCyan", 64)
	for _, p in ipairs(lip:GetChildren()) do
		p.CanCollide = false
		p.CanQuery = false
		if world.Look and world.Look.Glow then p.Color = world.Look.Glow end
	end
	-- lamps on the rim that wash the top of the pit walls with soft light
	local LAMPS = 12
	for i = 0, LAMPS - 1 do
		local a = (i + 0.5) / LAMPS * math.pi * 2
		local pos = origin + Vector3.new(math.cos(a) * (world.PitRadius + 4.5), 5.6, math.sin(a) * (world.PitRadius + 4.5))
		local aim = origin + Vector3.new(math.cos(a) * world.PitRadius * 0.4, -14, math.sin(a) * world.PitRadius * 0.4)
		local holder = invisible("RimLight", Vector3.new(0.6, 0.6, 0.6), CFrame.lookAt(pos, aim), folder)
		local spot = Instance.new("SpotLight")
		spot.Face = Enum.NormalId.Front
		spot.Angle = 75
		spot.Range = 16
		spot.Brightness = 0.8
		spot.Color = i % 2 == 0 and rgb(255, 238, 210) or rgb(200, 230, 255)
		spot.Shadows = false
		spot.Parent = holder
	end
end

return function(digSite, world)
	if digSite:GetAttribute("Cartoon2050") then return end
	recolor(digSite)
	-- the walkway curbs were tall walls; lower them to a slim edge just above the walkway
	-- (the ground banks up to the walkway level beside them, see GameConfig.FillDigTerrain)
	for _, d in ipairs(digSite:GetDescendants()) do
		if d:IsA("BasePart") and (d.Name == "Curb" or d.Name == "CurbGlow") then
			local bottom = d.CFrame.Position.Y - d.Size.Y / 2
			if d.Name == "Curb" then
				d.Size = Vector3.new(d.Size.X, 2.75 - bottom, d.Size.Z)
				d.CFrame = d.CFrame + Vector3.new(0, (bottom + d.Size.Y / 2) - d.CFrame.Position.Y, 0)
			else
				d.CFrame = d.CFrame + Vector3.new(0, 2.8 - d.CFrame.Position.Y, 0)
			end
		end
	end

	local folder = Instance.new("Model")
	folder.Name = "Cartoon2050"
	local origin = world.Origin
	local b = Architecture.builder(folder, CFrame.new(origin))
	local rimRadius = world.PitRadius + 4.5

	-- candy-striped rim ring, broken where the six walkways come in (world 1)
	local segments = 72
	for i = 0, segments - 1 do
		local deg = (i + 0.5) * 360 / segments
		local onPath = false
		if world.HubPaths then
			local fromPath = math.abs(((deg + 30) % 60) - 30)
			onPath = fromPath < 9
		end
		if not onPath then
			local a = math.rad(deg)
			local pos = Vector3.new(math.cos(a) * rimRadius, 4.3, math.sin(a) * rimRadius)
			local tangent = Vector3.new(-math.sin(a), 0, math.cos(a))
			local length = 2 * math.pi * rimRadius / segments + 0.6
			-- a sturdy safety railing: dark posts and two yellow rails, a small lamp on every 6th post
			b:rod("RimRail", length, 0.45, Architecture.alongX(pos + Vector3.new(0, 1.6, 0), tangent), "Sun")
			b:rod("RimRail", length, 0.45, Architecture.alongX(pos + Vector3.new(0, 0.2, 0), tangent), "Sun")
			if i % 2 == 0 then
				b:box("RimPost", Vector3.new(0.6, 2.8, 0.6), CFrame.new(pos + Vector3.new(0, 0.6, 0)), "Navy")
			end
			if i % 6 == 0 then
				b:bulb("RimBulb", 0.8, CFrame.new(pos + Vector3.new(0, 2.3, 0)), "GlowSun", 8)
			end
		end
	end

	-- party lights strung between the lamp posts (world 1 has 6 lamps on a ring)
	local lamps = {}
	for _, d in ipairs(digSite:GetDescendants()) do
		if d:IsA("BasePart") and d.Name == "LampGlow" then
			table.insert(lamps, d.CFrame.Position)
		end
	end
	table.sort(lamps, function(p, q)
		return math.atan2(p.Z - origin.Z, p.X - origin.X) < math.atan2(q.Z - origin.Z, q.X - origin.X)
	end)
	local bulbColors = {"GlowSun", "GlowPink", "GlowCyan", "GlowMint"}
	for i, from in ipairs(lamps) do
		local to = lamps[i % #lamps + 1]
		if #lamps > 1 and (to - from).Magnitude < 80 then
			for k = 1, 9 do
				local t = k / 10
				local sag = math.sin(t * math.pi) * 3.5
				local pos = from:Lerp(to, t) - Vector3.new(0, sag + 0.6, 0)
				b:bulb("PartyBulb", 0.7, CFrame.new(pos - origin), bulbColors[(k % #bulbColors) + 1], 0)
			end
		end
	end

	-- halo over the giant hard drive in the middle
	if world.Id == 1 then
		b:ring("DriveHalo", CFrame.new(0, 13, 0) * CFrame.Angles(math.rad(90), 0, 0), 10, 0.8, "GlowCyan", 24)
		b:ring("DriveHaloOuter", CFrame.new(0, 15.5, 0) * CFrame.Angles(math.rad(90), 0, 0), 12.5, 0.6, "Lilac", 28)
	end

	-- zone rings hidden in the pit wall (you uncover them while digging)
	for i = 2, #world.Zones do
		local zone = world.Zones[i]
		local ringCF = CFrame.new(0, zone.Top, 0) * CFrame.Angles(math.rad(90), 0, 0)
		local marker = Instance.new("Model")
		marker.Name = "ZoneRing_" .. zone.Name
		marker.Parent = folder
		local mb = Architecture.builder(marker, CFrame.new(origin))
		mb:ring("ZoneRing", ringCF, world.PitRadius + 1.5, 0.9, "GlowCyan", 40)
		for _, part in ipairs(marker:GetChildren()) do
			part.Color = zone.Color:Lerp(Color3.new(1, 1, 1), 0.2)
			part.CanCollide = false
		end
	end

	-- the pit itself: crystal veins, dust in the air, soft light around the lip
	local atmosphere = Instance.new("Model")
	atmosphere.Name = "PitAtmosphere"
	atmosphere.Parent = folder
	crystalVeins(atmosphere, world, Random.new(world.Id * 104729))
	layerFeatures(atmosphere, world, Random.new(world.Id * 7907))
	floatingDust(atmosphere, world)
	rimLighting(atmosphere, world)

	for _, d in ipairs(folder:GetDescendants()) do
		if d:IsA("BasePart") and d.Name == "PartyBulb" then
			d.CanCollide = false
			local light = d:FindFirstChildOfClass("PointLight")
			if light then light:Destroy() end -- lots of bulbs; keep it cheap
		end
	end
	folder.Parent = digSite
	digSite:SetAttribute("Cartoon2050", true)
end
