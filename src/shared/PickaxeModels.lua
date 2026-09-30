-- PickaxeModels (ModuleScript in ReplicatedStorage)
-- Builds every digging tool as a blocky voxel pickaxe: a head made of little cubes that arc
-- out to both sides (two-tone rows, pixel shading), a diamond socket with a glowing gem in the
-- middle, a dark handle with diamond gem nodes, an optional diamond cage around a floating
-- gem, a wrapped grip and a gem pommel.
--
-- Every pickaxe is unique: its own colors and a head shape
--   Crescent  classic curved pick          Wide    long, flat, three rows deep
--   Spiked    crescent with spikes         Crystal glassy shards over a glowing core
--   Hammer    a pick on one side, a chunky hammer on the other
-- and it gets fancier with its Power (tier 1-9): bigger, glowing gems, more gem nodes, the
-- cage, sparkling particles, and orbiting cubes (spun by ShovelClient / ShovelSpinner through
-- the OrbitCenter / OrbitSpeed attributes).
--
-- Tool space: the handle runs along Z, the head is at -Z, the grip end at +Z; +Y is the
-- direction the pick's arms point (the swing plane). Returns function(def) -> Tool.

local SCALE = 0.7
-- the crystal-tech look every pickaxe shares: cyan neon cutting edges, dark handles with a
-- glowing inlay, floating crystals and a spark trail off the tips
local NEON_EDGE = Color3.fromRGB(90, 235, 255)
local DARK_HANDLE = Color3.fromRGB(22, 22, 32)

local function rgb(r, g, b)
	return Color3.fromRGB(r, g, b)
end

---------------------------------------------------------------------
-- LOOKS: World 1's pickaxes by id (ids are the old save ids, so nobody loses a tool)
-- Main/Edge = the two rows of the head, Frame = sockets, Gem = gems, Handle, Wrap = grip
---------------------------------------------------------------------
local LOOKS = {
	RustyShovel = {Head = "Crescent", Main = rgb(150, 96, 62), Edge = rgb(112, 70, 46), Frame = rgb(120, 110, 104), Gem = rgb(255, 150, 70), Handle = rgb(84, 58, 40), Wrap = rgb(150, 150, 156)},
	PlasticShovel = {Head = "Wide", Main = rgb(150, 156, 160), Edge = rgb(104, 110, 116), Frame = rgb(132, 136, 142), Gem = rgb(235, 240, 250), Handle = rgb(70, 52, 40), Wrap = rgb(196, 110, 60)},
	GardenSpade = {Head = "Crescent", Main = rgb(214, 124, 72), Edge = rgb(170, 86, 50), Frame = rgb(190, 150, 110), Gem = rgb(70, 230, 210), Handle = rgb(60, 42, 34), Wrap = rgb(90, 190, 170)},
	IronShovel = {Head = "Spiked", Main = rgb(196, 200, 210), Edge = rgb(140, 146, 160), Frame = rgb(170, 174, 184), Gem = rgb(255, 70, 90), Handle = rgb(48, 40, 38), Wrap = rgb(150, 40, 50)},
	SteelSpade = {Head = "Crescent", Main = rgb(150, 160, 156), Edge = rgb(110, 200, 60), Frame = rgb(150, 160, 156), Gem = rgb(60, 255, 120), Handle = rgb(56, 36, 36), Wrap = rgb(214, 120, 80)},
	GoldenShovel = {Head = "Hammer", Main = rgb(255, 208, 72), Edge = rgb(226, 158, 40), Frame = rgb(255, 224, 140), Gem = rgb(255, 60, 110), Handle = rgb(60, 40, 30), Wrap = rgb(150, 30, 50)},
	GamerShovel = {Head = "Crystal", Main = rgb(110, 230, 255), Edge = rgb(180, 246, 255), Frame = rgb(170, 240, 255), Gem = rgb(90, 220, 255), Handle = rgb(40, 44, 64), Wrap = rgb(70, 80, 110)},
	TectonicAuger = {Head = "Spiked", Main = rgb(64, 62, 74), Edge = rgb(255, 120, 40), Frame = rgb(90, 88, 100), Gem = rgb(255, 140, 50), Handle = rgb(30, 28, 34), Wrap = rgb(255, 120, 40)},
	SingularitySpade = {Head = "Crystal", Main = rgb(58, 34, 96), Edge = rgb(190, 120, 255), Frame = rgb(90, 70, 140), Gem = rgb(235, 220, 255), Handle = rgb(20, 16, 30), Wrap = rgb(150, 90, 255)},
}
-- worlds 2-9: head shape per tier, colors from the world's theme
local WORLD_HEADS = {"Crescent", "Wide", "Spiked", "Crescent", "Crystal", "Hammer", "Crystal"}

local function lookFor(def)
	if LOOKS[def.Id] then return LOOKS[def.Id] end
	local look = def.Look
	if look and look.Colors then
		local c = look.Colors
		return {
			Head = look.Head or WORLD_HEADS[look.Tier] or "Crescent",
			Main = c.Main, Edge = look.Tier % 2 == 0 and c.Accent or c.Second,
			Frame = c.Second:Lerp(rgb(170, 170, 180), 0.4), Gem = c.Glow,
			Handle = c.Dark:Lerp(rgb(30, 28, 36), 0.4), Wrap = c.Accent,
		}
	end
	return LOOKS.RustyShovel
end

---------------------------------------------------------------------
-- BUILDING BLOCKS
---------------------------------------------------------------------
local function newPart(tool, name, size, cf, color, material, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	if shape then p.Shape = shape end
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Massless = true
	p.CastShadow = p.Material ~= Enum.Material.Neon
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = tool
	return p
end

-- pixel shading: a voxel is a touch lighter or darker than its neighbours
local function shade(color, i)
	local k = ({0, 0.1, -0.1, 0.05})[i % 4 + 1]
	if k > 0 then return color:Lerp(Color3.new(1, 1, 1), k) end
	return color:Lerp(Color3.new(0, 0, 0), -k)
end

local DIAMOND = CFrame.Angles(math.rad(45), 0, 0) -- a cube seen along X becomes a diamond

-- particle trails by tier (off the tips of the head)
local TRAILS = {
	Sparks = {Name = "Sparks", Colors = {Color3.new(1, 1, 1), NEON_EDGE}, Rate = 6, Light = 0.85, Size = 0.12,
		Lifetime = NumberRange.new(0.25, 0.45), Speed = NumberRange.new(0.2, 0.8)},
	Electric = {Name = "Electric", Colors = {Color3.new(1, 1, 1), rgb(140, 220, 255), rgb(60, 120, 255)}, Rate = 10, Light = 1, Size = 0.1,
		Lifetime = NumberRange.new(0.12, 0.25), Speed = NumberRange.new(1.5, 3.5)},
	Fire = {Name = "Fire", Colors = {rgb(255, 240, 150), rgb(255, 150, 40), rgb(220, 40, 20)}, Rate = 14, Light = 0.9, Size = 0.28, EndSize = 0.05,
		Lifetime = NumberRange.new(0.3, 0.55), Speed = NumberRange.new(0.5, 1.5), Acceleration = Vector3.new(0, 6, 0), RotSpeed = NumberRange.new(-120, 120)},
	Galaxy = {Name = "Galaxy", Colors = {rgb(255, 140, 230), rgb(160, 90, 255), rgb(70, 110, 255)}, Rate = 14, Light = 0.9, Size = 0.24, EndSize = 0.08,
		Lifetime = NumberRange.new(0.6, 1), Speed = NumberRange.new(0.2, 0.6), RotSpeed = NumberRange.new(-60, 60)},
}

-- a diamond frame with a glowing gem poking through both faces
local function gemNode(tool, name, z, size, look, glowing)
	local frame = newPart(tool, name, Vector3.new(size * 0.8, size, size), CFrame.new(0, 0, z) * DIAMOND, look.Frame)
	newPart(tool, name .. "Gem", Vector3.new(size * 0.96, size * 0.46, size * 0.46), CFrame.new(0, 0, z) * DIAMOND,
		look.Gem, glowing and Enum.Material.Neon or Enum.Material.Glass)
	return frame
end

local function bar(tool, name, a, b, thickness, color, material)
	local length = (b - a).Magnitude
	-- a CFrame whose Z axis runs from a to b (built from its axes, so it's exact in any direction)
	local z = (a - b).Unit
	local helper = math.abs(z.X) < 0.9 and Vector3.xAxis or Vector3.yAxis
	local y = z:Cross(helper).Unit
	local x = y:Cross(z)
	return newPart(tool, name, Vector3.new(thickness, thickness, length), CFrame.fromMatrix((a + b) / 2, x, y, z), color, material)
end

-- one arm of the head: voxels along an arc that starts at the socket and bends toward the grip
-- side = +1 / -1 (which way along Y), rows = how many layers deep
local function arm(tool, H, side, look, opts)
	local R, reach, count, rows = opts.Radius, opts.Reach, opts.Count, opts.Rows
	local center = H + Vector3.new(0, 0, R)
	local parts = {}
	for i = 1, count do
		local t = (i - 0.3) / count
		local phi = 0.22 + t * reach
		local size = opts.Size * (1 - t * 0.5)
		local radial = Vector3.new(0, side * math.sin(phi), -math.cos(phi))
		local rot = CFrame.Angles(side * phi, 0, 0)
		for row = 0, rows - 1 do
			local r = R + (row - (rows - 1) / 2) * size * 0.85
			local pos = center + radial * r
			local color = (row == rows - 1) and look.Edge or look.Main
			local material = opts.Material or Enum.Material.SmoothPlastic
			local voxel = newPart(tool, row == rows - 1 and "HeadEdge" or "HeadVoxel", Vector3.new(size * 0.9, size, size), CFrame.new(pos) * rot, shade(color, i + row), material)
			if opts.Glass then
				voxel.Transparency = 0.15
				voxel.Reflectance = 0.2
			end
			table.insert(parts, voxel)
		end
		-- cyan neon cutting edge along the outside of the arm
		local outer = R + ((rows - 1) / 2) * size * 0.85
		newPart(tool, "BladeEdge", Vector3.new(size * 0.7, size * 0.9, 0.09), CFrame.new(center + radial * (outer + size / 2 + 0.02)) * rot, NEON_EDGE, Enum.Material.Neon)
		-- jagged energy blade: neon shards along the edge, alternating long and short
		if opts.Jagged then
			local len = (i % 2 == 0) and size * 1.1 or size * 0.55
			newPart(tool, "EnergySpike", Vector3.new(size * 0.22, size * 0.22, len),
				CFrame.new(center + radial * (outer + size / 2 + len / 2 - 0.05)) * rot * CFrame.Angles(0, 0, math.rad(45)), opts.Jagged, Enum.Material.Neon)
		end
		-- spikes sticking out of the outer row
		if opts.Spikes and i % 2 == 0 then
			local pos = center + radial * (R + size * 1.2)
			newPart(tool, "HeadSpike", Vector3.new(size * 0.5, size * 0.5, size * 0.8), CFrame.new(pos) * rot, look.Edge)
		end
	end
	-- the pointed tip
	local phiEnd = 0.22 + reach + 0.12
	local tipPos = center + Vector3.new(0, side * math.sin(phiEnd), -math.cos(phiEnd)) * R
	local tip = newPart(tool, "HeadTip", Vector3.new(opts.Size * 0.36, opts.Size * 0.4, opts.Size * 0.4), CFrame.new(tipPos) * CFrame.Angles(side * phiEnd, 0, 0) * DIAMOND, NEON_EDGE, Enum.Material.Neon)
	return parts, tip
end

-- a chunky hammer block made of voxels (the other side of a "Hammer" head)
local function hammer(tool, H, side, look)
	local v = 0.5
	for y = 1, 3 do
		for z = -1, 1 do
			local pos = H + Vector3.new(0, side * (0.45 + y * v * 0.95), z * v * 0.95)
			local edge = y == 3 or math.abs(z) == 1
			newPart(tool, "HammerVoxel", Vector3.new(v * 1.7, v, v), CFrame.new(pos), shade(edge and look.Edge or look.Main, y + z))
		end
	end
	newPart(tool, "HammerFace", Vector3.new(v * 1.8, 0.12, v * 3), CFrame.new(H + Vector3.new(0, side * (0.45 + 3.55 * v), 0)), look.Frame, Enum.Material.Metal)
end

---------------------------------------------------------------------
-- BUILD A PICKAXE TOOL
---------------------------------------------------------------------
-- a crystal shard: a stretched diamond, glassy on the outside with a neon heart
local function crystal(tool, name, cf, length, color)
	local shell = newPart(tool, name, Vector3.new(length * 0.42, length * 0.42, length), cf * CFrame.Angles(0, 0, math.rad(45)), color:Lerp(Color3.new(1, 1, 1), 0.3), Enum.Material.Glass)
	shell.Transparency = 0.3
	shell.Reflectance = 0.25
	local core = newPart(tool, name .. "Core", Vector3.new(length * 0.2, length * 0.2, length * 0.8), cf * CFrame.Angles(0, 0, math.rad(45)), color, Enum.Material.Neon)
	return shell, core
end

return function(def)
	local look = table.clone(lookFor(def))
	-- dark handles everywhere (a hint of the pickaxe's own color stays in them)
	look.Handle = look.Handle:Lerp(DARK_HANDLE, 0.6)
	local tier = math.clamp(def.Power or 1, 1, 12)
	local growth = 1 + (tier - 1) * 0.035
	local glowing = tier >= 2

	local tool = Instance.new("Tool")
	tool.Name = def.Name
	tool.ToolTip = def.Name
	tool.CanBeDropped = false
	tool.RequiresHandle = true
	tool:SetAttribute("ShovelId", def.Id)

	-- invisible handle the hand holds; everything else is welded to it
	local handle = newPart(tool, "Handle", Vector3.new(0.3, 0.3, 4.6), CFrame.new(), look.Handle)
	handle.Transparency = 1

	-- HANDLE: a square dark shaft from the head down to the pommel
	local HEAD_Z, END_Z = -2.6, 2.2
	local RIGHT_Z, LEFT_Z = 1.55, 0.55 -- where the hands hold it (right hand low, left hand above)
	newPart(tool, "Shaft", Vector3.new(0.26, 0.26, END_Z - HEAD_Z), CFrame.new(0, 0, (END_Z + HEAD_Z) / 2), look.Handle)
	-- glowing cyan inlay lines down both sides of the shaft (between the head and the grip)
	for _, sx in ipairs({-1, 1}) do
		newPart(tool, "ShaftGlow", Vector3.new(0.04, 0.08, 2.7), CFrame.new(sx * 0.135, 0, -0.95), NEON_EDGE, Enum.Material.Neon)
	end
	-- grip wrap: stacked cubes, alternating shades
	for i = 0, 4 do
		newPart(tool, "GripWrap", Vector3.new(0.34, 0.34, 0.24), CFrame.new(0, 0, 1.05 + i * 0.24), shade(look.Wrap, i))
	end
	for _, z in ipairs({0.88, 2.28 - 0.1}) do
		newPart(tool, "Collar", Vector3.new(0.4, 0.4, 0.14), CFrame.new(0, 0, z), look.Frame, Enum.Material.Metal)
	end
	gemNode(tool, "Pommel", END_Z + 0.25, 0.62, look, glowing)
	-- gem nodes up the handle (more on better pickaxes)
	local nodes = tier >= 7 and {-1.75, -0.1} or (tier >= 3 and {-1.6} or {})
	for _, z in ipairs(nodes) do
		gemNode(tool, "HandleNode", z, 0.5, look, glowing)
	end
	-- the diamond cage with a floating gem (tier 4+)
	if tier >= 4 then
		local top, bottom, mid, w = -1.35, -0.35, -0.85, 0.42
		local a, b2 = Vector3.new(0, 0, top), Vector3.new(0, 0, bottom)
		for _, s in ipairs({-1, 1}) do
			local side = Vector3.new(0, s * w, mid)
			bar(tool, "CageBar", a, side, 0.12, look.Handle)
			bar(tool, "CageBar", side, b2, 0.12, look.Handle)
		end
		newPart(tool, "CageGem", Vector3.new(0.3, 0.34, 0.34), CFrame.new(0, 0, mid) * DIAMOND, look.Gem, Enum.Material.Neon)
	end

	-- HEAD
	local tips = {}
	local H = Vector3.new(0, 0, HEAD_Z)
	local socket = newPart(tool, "Blade", Vector3.new(0.72, 1, 1), CFrame.new(H) * DIAMOND, look.Frame)
	local gem = newPart(tool, "HeadGem", Vector3.new(0.86, 0.5, 0.5), CFrame.new(H) * DIAMOND, look.Gem, glowing and Enum.Material.Neon or Enum.Material.Glass)
	newPart(tool, "Crown", Vector3.new(0.4, 0.42, 0.42), CFrame.new(H + Vector3.new(0, 0, -0.78)) * DIAMOND, look.Edge)
	local style = look.Head
	local jagged = tier >= 5 and (tier >= 8 and look.Gem or NEON_EDGE) or nil
	local arm = function(t, h, side, lk, opts)
		if lk.Frame and jagged then
			opts = table.clone(opts)
			opts.Jagged = jagged
		end
		local parts, tip = arm(t, h, side, lk, opts)
		if lk.Frame then -- not the glowing core inside a crystal head, or the second blade
			table.insert(tips, tip)
		end
		return parts, tip
	end
	if style == "Wide" then
		for _, s in ipairs({-1, 1}) do
			arm(tool, H, s, look, {Radius = 3.4, Reach = 0.62, Count = 8, Rows = 3, Size = 0.58})
		end
	elseif style == "Spiked" then
		for _, s in ipairs({-1, 1}) do
			arm(tool, H, s, look, {Radius = 2.3, Reach = 1.1, Count = 7, Rows = 2, Size = 0.66, Spikes = true})
		end
	elseif style == "Crystal" then
		for _, s in ipairs({-1, 1}) do
			arm(tool, H, s, look, {Radius = 2.4, Reach = 1.05, Count = 7, Rows = 3, Size = 0.6, Glass = true, Material = Enum.Material.Glass})
			-- glowing core running inside the glass
			arm(tool, H, s, {Main = look.Gem, Edge = look.Gem}, {Radius = 2.4, Reach = 0.95, Count = 6, Rows = 1, Size = 0.3, Material = Enum.Material.Neon})
		end
	elseif style == "Hammer" then
		arm(tool, H, 1, look, {Radius = 2.3, Reach = 1.15, Count = 7, Rows = 2, Size = 0.66})
		hammer(tool, H, -1, look)
	else -- Crescent
		for _, s in ipairs({-1, 1}) do
			arm(tool, H, s, look, {Radius = 2.3, Reach = 1.15, Count = 7, Rows = tier >= 5 and 3 or 2, Size = 0.66})
		end
	end
	-- side plates that hold the head on the shaft
	for _, s in ipairs({-1, 1}) do
		newPart(tool, "HeadBracket", Vector3.new(0.5, 0.3, 0.7), CFrame.new(H + Vector3.new(0, s * 0.42, 0.55)), look.Handle)
	end

	-- DUAL BLADE (tier 7+): a second, thinner blade of pure energy on each side of the head
	if tier >= 7 then
		for _, sx in ipairs({-1, 1}) do
			local offset = H + Vector3.new(sx * 0.5, 0, 0.1)
			for _, s in ipairs({-1, 1}) do
				arm(tool, offset, s, {Main = look.Gem, Edge = NEON_EDGE}, {Radius = 2.1, Reach = 1, Count = 6, Rows = 1, Size = 0.32, Material = Enum.Material.Neon})
			end
		end
	end

	-- ROTATING CORE (tier 3+): glowing bits circling the head's gem, faster on better pickaxes
	if tier >= 3 then
		local n = tier >= 6 and 6 or 4
		for i = 1, n do
			local a = math.pi * 2 * i / n
			local bit = newPart(tool, "CoreBit", Vector3.new(0.18, 0.18, 0.18), CFrame.new(H + Vector3.new(math.cos(a) * 0.95, math.sin(a) * 0.95, 0)) * DIAMOND,
				i % 2 == 0 and look.Gem or NEON_EDGE, Enum.Material.Neon)
			bit:SetAttribute("OrbitCenter", H)
			bit:SetAttribute("OrbitSpeed", 2 + tier * 0.4)
		end
		-- a spinning ring around the socket
		local ringCount = 10
		for i = 1, ringCount do
			local a = math.pi * 2 * i / ringCount
			local seg = newPart(tool, "CoreRing", Vector3.new(0.08, 0.34, 0.08), CFrame.new(H + Vector3.new(math.cos(a) * 1.2, math.sin(a) * 1.2, 0)) * CFrame.Angles(0, 0, a),
				NEON_EDGE, Enum.Material.Neon)
			seg:SetAttribute("OrbitCenter", H)
			seg:SetAttribute("OrbitSpeed", -(1.2 + tier * 0.2))
		end
	end

	-- ORBITING CUBES around the handle below the head (tier 6+), spun by the client
	if tier >= 6 then
		local center = Vector3.new(0, 0, -1.9)
		local n = tier - 3
		for i = 1, n do
			local a = math.pi * 2 * i / n
			local cube = newPart(tool, "OrbitCube", Vector3.new(0.2, 0.2, 0.2), CFrame.new(center + Vector3.new(math.cos(a) * 0.62, math.sin(a) * 0.62, 0)) * CFrame.Angles(0.6, 0.6, 0), look.Gem, Enum.Material.Neon)
			cube:SetAttribute("OrbitCenter", center)
			cube:SetAttribute("OrbitSpeed", 2.6)
		end
	end

	-- FLOATING CRYSTALS: glassy shards hovering around the shaft under the head, orbiting it
	-- (every pickaxe has one; better ones have up to four)
	do
		local center = Vector3.new(0, 0, -1.15)
		local n = math.clamp(1 + math.floor(tier / 3), 1, 4)
		for i = 1, n do
			local a = math.pi * 2 * i / n + 0.4
			local pos = center + Vector3.new(math.cos(a) * 0.95, math.sin(a) * 0.95, 0)
			local shell, core = crystal(tool, "FloatCrystal", CFrame.new(pos) * CFrame.Angles(0.35, 0.2, a), 0.55 + tier * 0.02, i % 2 == 0 and look.Gem or NEON_EDGE)
			for _, p in ipairs({shell, core}) do
				p:SetAttribute("OrbitCenter", center)
				p:SetAttribute("OrbitSpeed", 1.4)
			end
		end
	end

	-- SPARK TRAIL: cyan sparks stream off both tips; they're left behind in the air while the
	-- pickaxe moves, so every swing draws a glittering arc (denser on better pickaxes)
	-- the trail's style depends on the tier: sparks -> electricity -> fire -> galaxy
	local trail = TRAILS[tier >= 8 and "Galaxy" or (tier >= 6 and "Fire" or (tier >= 4 and "Electric" or "Sparks"))]
	tool:SetAttribute("TrailStyle", trail.Name)
	tool:SetAttribute("TrailColorA", trail.Colors[1])
	tool:SetAttribute("TrailColorB", trail.Colors[#trail.Colors])
	for _, tip in ipairs(tips) do
		local sparks = Instance.new("ParticleEmitter")
		sparks.Name = "TipSparks"
		sparks.Rate = trail.Rate + tier * 2
		sparks.LightEmission = trail.Light
		local keys = {}
		for k, c in ipairs(trail.Colors) do
			table.insert(keys, ColorSequenceKeypoint.new((k - 1) / (#trail.Colors - 1), c))
		end
		sparks.Color = ColorSequence.new(keys)
		sparks.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, trail.Size), NumberSequenceKeypoint.new(1, trail.EndSize or 0)})
		sparks.Transparency = NumberSequence.new(0, 1)
		sparks.Lifetime = trail.Lifetime
		sparks.Speed = trail.Speed
		sparks.SpreadAngle = Vector2.new(180, 180)
		sparks.Acceleration = trail.Acceleration or Vector3.zero
		sparks.RotSpeed = trail.RotSpeed or NumberRange.new(0)
		sparks.Drag = 3
		sparks.Parent = tip
		if trail.Name == "Electric" then
			-- crackling: little bright zaps flicker around the tip
			local zap = sparks:Clone()
			zap.Name = "TipZaps"
			zap.Rate = 12
			zap.Size = NumberSequence.new(0.22, 0.05)
			zap.Lifetime = NumberRange.new(0.05, 0.12)
			zap.Speed = NumberRange.new(4, 8)
			zap.Parent = tip
		elseif trail.Name == "Galaxy" then
			-- tiny white stars twinkling in the purple dust
			local stars = sparks:Clone()
			stars.Name = "TipStars"
			stars.Rate = 8
			stars.Color = ColorSequence.new(Color3.new(1, 1, 1))
			stars.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 0.14), NumberSequenceKeypoint.new(1, 0)})
			stars.Lifetime = NumberRange.new(0.6, 1)
			stars.Parent = tip
		end
	end

	-- VFX: gem light and sparkles that grow with the tier
	if glowing then
		local light = Instance.new("PointLight")
		light.Color = look.Gem
		light.Range = 4 + tier
		light.Brightness = 0.35 + tier * 0.1
		light.Parent = gem
		local sparkle = Instance.new("ParticleEmitter")
		sparkle.Name = "GemSparkle"
		sparkle.Rate = tier * 2.5
		sparkle.LightEmission = math.min(0.2 + tier * 0.09, 1)
		sparkle.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.06 + tier * 0.025), NumberSequenceKeypoint.new(1, 0)})
		sparkle.Lifetime = NumberRange.new(0.4, 0.8 + tier * 0.05)
		sparkle.Speed = NumberRange.new(0.3, 0.8 + tier * 0.1)
		sparkle.SpreadAngle = Vector2.new(180, 180)
		sparkle.Color = ColorSequence.new(look.Gem:Lerp(Color3.new(1, 1, 1), 0.4), look.Gem)
		sparkle.Transparency = NumberSequence.new(0.1, 1)
		sparkle.Parent = socket
	end

	-- SIZE: better pickaxes are a little bigger, then everything is scaled to character size
	local s = SCALE * growth
	for _, part in ipairs(tool:GetChildren()) do
		if part:IsA("BasePart") then
			local rotation = part.CFrame.Rotation
			part.Size = part.Size * s
			part.CFrame = CFrame.new(part.Position * s) * rotation
			local center = part:GetAttribute("OrbitCenter")
			if center then part:SetAttribute("OrbitCenter", center * s) end
		end
	end
	for _, emitter in ipairs(tool:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			local keys = {}
			for _, key in ipairs(emitter.Size.Keypoints) do
				table.insert(keys, NumberSequenceKeypoint.new(key.Time, key.Value * s, key.Envelope * s))
			end
			emitter.Size = NumberSequence.new(keys)
		end
	end

	-- how Roblox holds it if the two-handed pose can't run (e.g. R6 bodies)
	tool.Grip = CFrame.new(0, 0, RIGHT_Z * s) * CFrame.Angles(math.rad(-30), 0, 0)
	-- ShovelClient's two-handed pose: where each hand grips the handle (along Z)
	tool:SetAttribute("RightHoldZ", RIGHT_Z * s)
	tool:SetAttribute("LeftHoldZ", LEFT_Z * s)
	tool:SetAttribute("TopHoldZ", RIGHT_Z * s)
	tool:SetAttribute("LowHoldZ", LEFT_Z * s)

	for _, part in ipairs(tool:GetChildren()) do
		if part:IsA("BasePart") and part ~= handle then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = handle
			weld.Part1 = part
			weld.Parent = handle
		end
	end
	return tool
end
