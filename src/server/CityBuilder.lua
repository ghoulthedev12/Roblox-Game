-- CityBuilder (ModuleScript in ServerScriptService)
-- Rebuilds the city skyline in the cartoony 2050 style. It reads where every old tower
-- stood (its podium) and how tall it was, removes it, and builds a new rounded tower in
-- the same spot. It also recolors the streets, the edge wall and the ground, and swaps the
-- old sky bridges for glass tube bridges. MapStyle calls this once on server start.

local Architecture = require(script.Parent:WaitForChild("Architecture"))
local P = Architecture.Palette

local CityBuilder = {}

local BODIES = {"White", "Cloud", "White"}
local ACCENTS = {"Lilac", "Sky", "Mint", "Sun", "Coral", "Violet"}
local GLOWS = {"GlowCyan", "GlowPink", "GlowSun", "GlowMint"}

---------------------------------------------------------------------
-- COLOR HELPERS
---------------------------------------------------------------------
local function apply(part, finish)
	local f = P[finish]
	part.Color = f.Color
	part.Material = f.Material
	part.Transparency = f.Transparency or 0
	part.Reflectance = f.Reflectance or 0
end

-- Turns any gritty part into a smooth, soft-colored cartoon part
function CityBuilder.cartoonify(part)
	local c = part.Color
	local lum = 0.299 * c.R + 0.587 * c.G + 0.114 * c.B
	local sat = math.max(c.R, c.G, c.B) - math.min(c.R, c.G, c.B)
	if part.Material == Enum.Material.Neon then
		part.Color = c:Lerp(Color3.new(1, 1, 1), 0.25)
		return
	elseif part.Material == Enum.Material.Glass or part.Material == Enum.Material.ForceField or part.Transparency >= 0.99 then
		return
	end
	part.Material = Enum.Material.SmoothPlastic
	part.Reflectance = 0
	if sat > 0.25 then
		part.Color = c:Lerp(Color3.new(1, 1, 1), 0.15) -- keep real colors, just softer
	elseif lum < 0.22 then
		part.Color = P.Navy.Color
	elseif lum < 0.55 then
		part.Color = P.Lilac.Color:Lerp(P.Cloud.Color, 0.45)
	else
		part.Color = P.White.Color
	end
end

---------------------------------------------------------------------
-- TOWER STYLES. `b` is a builder at the tower's footprint (ground = y 0),
-- w = tower width, h = total height, rng = this tower's random generator.
---------------------------------------------------------------------
local function pick(rng, list)
	return list[rng:NextInteger(1, #list)]
end

local function antenna(b, y, rng, glow)
	local length = rng:NextNumber(6, 12)
	b:pill("Antenna", Vector3.new(0, y, 0), Vector3.new(0, y + length, 0), 0.8, "Chrome")
	b:bulb("AntennaTip", 1.8, CFrame.new(0, y + length + 1, 0), glow, 30)
end

-- A: stacked rounded tiers that step in as they rise, with window bands and a dome
local function stackTower(b, w, h, rng, body, accent, glow)
	local tiers = math.clamp(math.floor(h / 45) + 2, 2, 6)
	local y = 10
	local tierH = (h - 10 - w * 0.25) / tiers
	for i = 1, tiers do
		local size = w * (1 - (i - 1) * 0.12)
		b:roundedBlock("Tier", Vector3.new(size, tierH, size), CFrame.new(0, y + tierH / 2, 0), size * 0.28, i % 2 == 1 and body or accent)
		-- two glowing window bands per tier
		for _, f in ipairs({0.35, 0.72}) do
			b:roundedBlock("WindowBand", Vector3.new(size + 0.5, 1.6, size + 0.5), CFrame.new(0, y + tierH * f, 0), size * 0.3, "Glass")
		end
		b:roundedBlock("TierLip", Vector3.new(size + 1.6, 1.2, size + 1.6), CFrame.new(0, y + tierH, 0), size * 0.32, accent)
		y += tierH
	end
	local top = w * (1 - tiers * 0.12)
	b:ellipsoid("Dome", Vector3.new(top, w * 0.5, top), CFrame.new(0, y, 0), accent)
	antenna(b, y + w * 0.22, rng, glow)
end

-- B: a round tube with glass rings, a flying-saucer crown and a beacon
local function tubeTower(b, w, h, rng, body, accent, glow)
	local shaftH = h - 10 - 6
	b:disc("Shaft", w * 0.85, shaftH, CFrame.new(0, 10 + shaftH / 2, 0), body)
	local bands = math.floor(shaftH / 16)
	for i = 1, bands do
		local y = 10 + i * (shaftH / (bands + 1))
		b:disc("GlassRing", w * 0.85 + 0.6, 3, CFrame.new(0, y, 0), "Glass")
		if i % 2 == 0 then
			b:disc("ColorRing", w * 0.85 + 1.2, 1, CFrame.new(0, y + 2.4, 0), accent)
		end
	end
	local crown = 10 + shaftH
	b:ellipsoid("SaucerUnder", Vector3.new(w * 1.5, 4, w * 1.5), CFrame.new(0, crown, 0), accent)
	b:disc("SaucerRim", w * 1.55, 1.2, CFrame.new(0, crown + 0.6, 0), glow)
	b:ellipsoid("SaucerTop", Vector3.new(w * 1.4, 5, w * 1.4), CFrame.new(0, crown + 1.4, 0), body)
	b:ellipsoid("Bubble", Vector3.new(w * 0.6, w * 0.45, w * 0.6), CFrame.new(0, crown + 3, 0), "Glass")
	antenna(b, crown + 3 + w * 0.2, rng, glow)
end

-- C: twisting stack of rounded slabs (each floor turned a bit more)
local function twistTower(b, w, h, rng, body, accent, glow)
	local slabH = 14
	local count = math.floor((h - 12) / slabH)
	local twist = rng:NextNumber(5, 9) * (rng:NextNumber() < 0.5 and -1 or 1)
	for i = 0, count - 1 do
		local y = 10 + i * slabH
		local cf = CFrame.new(0, y + slabH / 2, 0) * CFrame.Angles(0, math.rad(twist * i), 0)
		b:box("Slab", Vector3.new(w * 0.8, slabH - 2.2, w * 0.8), cf, i % 3 == 0 and accent or body)
		b:box("SlabGlass", Vector3.new(w * 0.8 + 0.4, slabH - 6, w * 0.8 + 0.4), cf, "Glass")
		b:box("SlabLip", Vector3.new(w * 0.92, 2.2, w * 0.92), cf * CFrame.new(0, slabH / 2 - 1.1, 0), accent)
	end
	local topY = 10 + count * slabH
	b:ball("TopOrb", w * 0.55, CFrame.new(0, topY + w * 0.2, 0), accent)
	b:disc("TopOrbRing", w * 0.8, 0.8, CFrame.new(0, topY + w * 0.2, 0), glow)
	antenna(b, topY + w * 0.45, rng, glow)
end

-- D: slim core with big bubble pods sticking out at different heights
local function podTower(b, w, h, rng, body, accent, glow)
	local coreH = h - 10
	b:disc("Core", w * 0.55, coreH, CFrame.new(0, 10 + coreH / 2, 0), body)
	for i = 1, math.floor(coreH / 12) do
		b:disc("CoreGlass", w * 0.55 + 0.5, 1.6, CFrame.new(0, 10 + i * 12, 0), "Glass")
	end
	local pods = math.clamp(math.floor(coreH / 30), 2, 7)
	for i = 1, pods do
		local y = 10 + coreH * (i / (pods + 1))
		local a = math.rad(i * 137.5 + rng:NextNumber(0, 40))
		local out = w * 0.5
		local pos = Vector3.new(math.cos(a) * out, y, math.sin(a) * out)
		local size = w * rng:NextNumber(0.45, 0.6)
		b:ball("Pod", size, CFrame.new(pos), i % 2 == 0 and accent or body)
		b:ellipsoid("PodWindow", Vector3.new(size * 0.7, size * 0.35, size * 0.7), CFrame.new(pos + Vector3.new(0, size * 0.12, 0)), "Glass")
		b:disc("PodRing", size * 1.15, 0.7, CFrame.new(pos), glow)
	end
	b:ellipsoid("CoreCap", Vector3.new(w * 0.7, w * 0.4, w * 0.7), CFrame.new(0, 10 + coreH, 0), accent)
	antenna(b, 10 + coreH + w * 0.15, rng, glow)
end

local STYLES = {stackTower, tubeTower, twistTower, podTower}

---------------------------------------------------------------------
-- MEGATOWERS: the towering landmarks of the 2050 skyline (the 8 sturdiest tower spots).
-- Blended cartoony-realism: tinted Glass floors that twist as they rise (each floor is
-- turned a little more with CFrame.Angles), thin white floor plates, Neon corner ribs that
-- spiral up with the twist, cantilevered sky gardens, a stepped crown and a glowing spire.
---------------------------------------------------------------------
local MEGA_COUNT = 8
local MEGA_GLASS = {
	{Name = "MegaGlassSky", Color = Color3.fromRGB(120, 200, 255)},
	{Name = "MegaGlassLilac", Color = Color3.fromRGB(180, 160, 255)},
	{Name = "MegaGlassMint", Color = Color3.fromRGB(110, 235, 205)},
	{Name = "MegaGlassRose", Color = Color3.fromRGB(255, 160, 205)},
}
for _, g in ipairs(MEGA_GLASS) do
	P[g.Name] = {Color = g.Color, Material = Enum.Material.Glass, Transparency = 0.25, Reflectance = 0.25}
end
P.MegaSteel = {Color = Color3.fromRGB(236, 240, 248), Material = Enum.Material.Metal, Reflectance = 0.1}
local MEGA_NEON = {
	{Name = "MegaNeonCyan", Color = Color3.fromRGB(90, 220, 255)},
	{Name = "MegaNeonPink", Color = Color3.fromRGB(255, 110, 200)},
	{Name = "MegaNeonGold", Color = Color3.fromRGB(255, 205, 90)},
	{Name = "MegaNeonMint", Color = Color3.fromRGB(90, 255, 190)},
}
for _, g in ipairs(MEGA_NEON) do
	P[g.Name] = {Color = g.Color, Material = Enum.Material.Neon}
end

local function megaTower(b, w, h, rng)
	local glass = pick(rng, MEGA_GLASS).Name
	local neon = pick(rng, MEGA_NEON).Name
	local twistPerFloor = math.rad(rng:NextNumber(2.2, 3.6)) * (rng:NextNumber() < 0.5 and -1 or 1)
	local floorH = 12
	local podiumH = 14

	-- podium: two rounded steps with a glowing lip
	b:roundedBlock("MegaPodium", Vector3.new(w + 14, podiumH * 0.6, w + 14), CFrame.new(0, podiumH * 0.3, 0), 8, "MegaSteel")
	b:roundedBlock("MegaPodiumLip", Vector3.new(w + 15, 0.8, w + 15), CFrame.new(0, podiumH * 0.6, 0), 8.2, neon)
	b:roundedBlock("MegaLobby", Vector3.new(w + 6, podiumH * 0.4, w + 6), CFrame.new(0, podiumH * 0.8, 0), 6, glass)

	local floors = math.floor((h - podiumH - 40) / floorH)
	local prevCorners
	for i = 0, floors - 1 do
		local y = podiumH + i * floorH
		local t = i / math.max(floors - 1, 1)
		-- slim waist at 60% height, slight flare near the top (an elegant hourglass taper)
		local size = w * (1 - 0.28 * math.sin(t * math.pi * 0.85)) * (1 - 0.15 * t)
		local turn = CFrame.Angles(0, i * twistPerFloor, 0)
		local floorCF = CFrame.new(0, y + floorH / 2, 0) * turn
		-- (plain boxes keep the part count low: 2 parts per floor)
		b:box("MegaFloor", Vector3.new(size, floorH - 1, size), floorCF, glass)
		b:box("MegaPlate", Vector3.new(size + 1.4, 1, size + 1.4), CFrame.new(0, y, 0) * turn, "MegaSteel")

		-- corner ribs: every 2 floors a neon rod joins each corner to the same corner two floors
		-- up, which is turned further, so the ribs spiral around the tower
		local inset = size * 0.5
		local corners = {}
		for k = 0, 3 do
			local a = math.rad(45 + k * 90)
			corners[k + 1] = (CFrame.new(0, y, 0) * turn * CFrame.new(math.cos(a) * inset * 1.414 + math.cos(a) * 0.4, 0, math.sin(a) * inset * 1.414 + math.sin(a) * 0.4)).Position
		end
		if i % 3 == 0 then
			if prevCorners then
				for k = 1, 4 do
					local a, c = prevCorners[k], corners[k]
					b:rod("MegaRib", (c - a).Magnitude + 0.6, 0.9, Architecture.alongX((a + c) / 2, c - a), neon)
				end
			end
			prevCorners = corners
		end

		-- sky gardens at one third and two thirds of the height
		if i == math.floor(floors / 3) or i == math.floor(floors * 2 / 3) then
			local gardenCF = CFrame.new(0, y + 0.5, 0) * turn
			b:disc("SkyGarden", size * 1.5, 1.4, gardenCF, "MegaSteel")
			b:ring("SkyGardenRail", gardenCF * CFrame.new(0, 1.4, 0) * CFrame.Angles(math.rad(90), 0, 0), size * 0.75, 0.5, neon, 28)
			for k = 1, 6 do
				local a = math.pi * 2 * k / 6
				local spot = gardenCF * CFrame.new(math.cos(a) * size * 0.62, 0.7, math.sin(a) * size * 0.62)
				b:pill("GardenTrunk", spot.Position, (spot * CFrame.new(0, 3, 0)).Position, 0.6, "Chrome")
				b:ball("GardenTree", 3.4, spot * CFrame.new(0, 4.2, 0), k % 2 == 0 and "Mint" or "GlowMint")
			end
		end
	end

	-- crown: stepped discs, a halo ring and a spire with a beacon
	local topY = podiumH + floors * floorH
	local crownW = w * 0.6
	local _, crownH = b:tiers("MegaCrown", CFrame.new(0, topY, 0) * CFrame.Angles(0, floors * twistPerFloor, 0), {
		{crownW, 4, "MegaSteel"}, {crownW * 0.78, 3, glass}, {crownW * 0.55, 3, "MegaSteel"}, {crownW * 0.3, 6, glass},
	})
	b:ring("MegaHalo", CFrame.new(0, topY + crownH + 4, 0) * CFrame.Angles(math.rad(90), 0, 0), crownW * 0.5, 1, neon, 32)
	local spireTop = topY + crownH + 30
	b:pill("MegaSpire", Vector3.new(0, topY + crownH, 0), Vector3.new(0, spireTop, 0), 1.6, "Chrome")
	b:bulb("MegaBeacon", 3, CFrame.new(0, spireTop + 2, 0), neon, 40)
end


-- Podium + little park around every tower
local function base(b, w, rng, accent)
	b:disc("Park", w * 1.9, 0.4, CFrame.new(0, 0.2, 0), "Mint")
	b:disc("ParkEdge", w * 1.9 + 1.2, 0.3, CFrame.new(0, 0.15, 0), "White")
	b:roundedBlock("Podium", Vector3.new(w + 4, 10, w + 4), CFrame.new(0, 5, 0), (w + 4) * 0.3, "Cloud")
	b:roundedBlock("PodiumBand", Vector3.new(w + 4.6, 1.4, w + 4.6), CFrame.new(0, 8.4, 0), (w + 4.6) * 0.3, accent)
	b:roundedBlock("Lobby", Vector3.new(w * 0.6, 6, w + 4.3), CFrame.new(0, 3.2, 0), 1, "Glass")
	-- lollipop trees
	for i = 1, 3 do
		local a = math.rad(i * 120 + rng:NextNumber(-20, 20))
		local r = w * 0.8
		local pos = Vector3.new(math.cos(a) * r, 0, math.sin(a) * r)
		b:rod("TreeTrunk", 5, 0.8, CFrame.new(pos + Vector3.new(0, 2.5, 0)) * CFrame.Angles(0, 0, math.rad(90)), "White")
		b:ball("TreeTop", rng:NextNumber(4, 5.5), CFrame.new(pos + Vector3.new(0, 6.5, 0)), pick(rng, {"Mint", "Sun", "Coral", "Lilac"}))
	end
end

---------------------------------------------------------------------
-- REBUILD THE SKYLINE
---------------------------------------------------------------------
local function findTowers(towersFolder)
	local podiums = {}
	local parts = {}
	for _, d in ipairs(towersFolder:GetDescendants()) do
		if d:IsA("BasePart") then
			table.insert(parts, d)
			if d.Name == "Podium" then
				table.insert(podiums, {CFrame = d.CFrame, Size = d.Size, Top = 0})
			end
		end
	end
	-- each part belongs to the nearest podium; the tallest part sets the tower height
	for _, part in ipairs(parts) do
		local pos = part.CFrame.Position
		local best, bestD = nil, math.huge
		for _, pod in ipairs(podiums) do
			local pp = pod.CFrame.Position
			local d = (pp.X - pos.X) ^ 2 + (pp.Z - pos.Z) ^ 2
			if d < bestD then best, bestD = pod, d end
		end
		if best then
			best.Top = math.max(best.Top, pos.Y + part.Size.Y / 2)
		end
	end
	return podiums
end

function CityBuilder.rebuildTowers(city)
	local towers = city:FindFirstChild("Towers")
	if not towers or towers:GetAttribute("Cartoon2050") then return end
	local list = findTowers(towers)
	towers:ClearAllChildren()
	-- the sturdiest footprints become megatowers
	local bySize = table.clone(list)
	table.sort(bySize, function(a, c) return math.min(a.Size.X, a.Size.Z) > math.min(c.Size.X, c.Size.Z) end)
	local mega = {}
	for i = 1, math.min(MEGA_COUNT, #bySize) do mega[bySize[i]] = true end
	for i, tower in ipairs(list) do
		local pos = tower.CFrame.Position
		local rng = Random.new(i * 7919)
		local model = Instance.new("Model")
		model.Name = "Tower"
		local b = Architecture.builder(model, CFrame.new(pos.X, 0, pos.Z) * tower.CFrame.Rotation)
		local w = math.clamp(math.min(tower.Size.X, tower.Size.Z) - 6, 16, 30)
		local h = math.max(tower.Top, 50)
		local body = pick(rng, BODIES)
		local accent = pick(rng, ACCENTS)
		local glow = pick(rng, GLOWS)
		if mega[tower] then
			model.Name = "MegaTower"
			megaTower(b, math.clamp(math.min(tower.Size.X, tower.Size.Z) - 4, 24, 40), math.clamp(math.max(h * 1.6, 400), 400, 580), rng)
		else
			base(b, w, rng, accent)
			STYLES[(i - 1) % #STYLES + 1](b, w, h, rng, body, accent, glow)
		end
		model.Parent = towers
	end
	towers:SetAttribute("Cartoon2050", true)
end

-- Old sky bridges pointed at towers that no longer exist, so replace them with glass tubes
function CityBuilder.rebuildBridges(city)
	local bridges = city:FindFirstChild("SkyBridges")
	if not bridges or bridges:GetAttribute("Cartoon2050") then return end
	local spans = {}
	for _, d in ipairs(bridges:GetDescendants()) do
		if d:IsA("BasePart") and d.Name == "SkyBridge" then
			table.insert(spans, {CFrame = d.CFrame, Size = d.Size})
		end
	end
	bridges:ClearAllChildren()
	local b = Architecture.builder(bridges, CFrame.new())
	for _, span in ipairs(spans) do
		-- the long side of the old bridge is the direction the tube runs
		local s = span.Size
		local axis = s.X >= s.Z and span.CFrame.RightVector or span.CFrame.LookVector
		local length = math.max(s.X, s.Z)
		local mid = span.CFrame.Position
		b:rod("Tube", length, 6, Architecture.alongX(mid, axis), "Glass")
		b:rod("TubeFloor", length, 4.6, Architecture.alongX(mid - Vector3.new(0, 1.6, 0), axis), "White")
		for k = -1, 1 do
			b:rod("TubeRing", 1, 7, Architecture.alongX(mid + axis * (length * 0.33 * k), axis), "Lilac")
		end
	end
	bridges:SetAttribute("Cartoon2050", true)
end

-- Streets, edge wall and anything else: recolor in place
function CityBuilder.restyleRest(city)
	for _, name in ipairs({"Streets", "EdgeWall"}) do
		local folder = city:FindFirstChild(name)
		if folder then
			for _, d in ipairs(folder:GetDescendants()) do
				if d:IsA("BasePart") then
					if d.Name == "Road" then
						d.Material = Enum.Material.SmoothPlastic
						d.Color = Color3.fromRGB(88, 92, 140)
					elseif d.Name == "LaneLine" then
						apply(d, "Sun")
					elseif d.Name == "Curb" then
						apply(d, "White")
					elseif d.Name == "Megastructure" then
						d.Material = Enum.Material.SmoothPlastic
						d.Color = Color3.fromRGB(176, 186, 236)
					elseif d.Name == "WallFrame" then
						apply(d, "White")
					else
						CityBuilder.cartoonify(d)
					end
				end
			end
		end
	end
end

function CityBuilder.build(city)
	CityBuilder.rebuildTowers(city)
	CityBuilder.rebuildBridges(city)
	CityBuilder.restyleRest(city)
end

return CityBuilder
