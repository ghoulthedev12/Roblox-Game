-- MuseumStyle (ModuleScript in ServerScriptService)
-- Restyles ServerStorage.MuseumTemplate once, on server start, before any museum is cloned:
--   1. Softens the colors into a friendly cartoony palette (pastel glow instead of harsh
--      neon, playful indigo instead of dark navy, cartoon trees instead of glowing glass).
--   2. Adds chunky rounded 2050 architecture to the outside: capsule corner towers with
--      domed caps, a glass bubble dome on the roof, porthole windows, rounded floor bands,
--      a bubble canopy and capsule pillars at the entrance, and floating orb pedestals.
-- Slot, elevator and sign parts keep their names and positions, so nothing that looks
-- them up by name breaks.

local Architecture = require(script.Parent:WaitForChild("Architecture"))
local P = Architecture.Palette

local function near(c, r, g, b)
	return math.abs(c.R * 255 - r) < 12 and math.abs(c.G * 255 - g) < 12 and math.abs(c.B * 255 - b) < 12
end

local function apply(part, finish)
	part.Color = finish.Color
	part.Material = finish.Material
	if finish.Transparency then part.Transparency = finish.Transparency end
	if finish.Reflectance then part.Reflectance = finish.Reflectance end
end

local function hasGui(part)
	return part:FindFirstChildWhichIsA("SurfaceGui") ~= nil
end

---------------------------------------------------------------------
-- 1. PALETTE PASS
---------------------------------------------------------------------
local function restylePart(part)
	local c = part.Color
	local m = part.Material

	if m == Enum.Material.Neon then
		-- keep the hue, make it a soft pastel glow instead of a blinding one
		part.Color = c:Lerp(Color3.new(0.8, 0.8, 0.85), 0.2)
	elseif m == Enum.Material.Glass then
		local name = part.Name
		if name == "Bush" or name == "TreeCrown" or name == "Leaves" then
			-- glowing sci-fi foliage becomes chunky cartoon greenery
			part.Material = Enum.Material.SmoothPlastic
			part.Color = Color3.fromRGB(96, 214, 150)
			part.Transparency = 0
		else
			apply(part, P.Glass)
		end
	elseif m == Enum.Material.Grass then
		part.Material = Enum.Material.SmoothPlastic
		part.Color = Color3.fromRGB(110, 200, 120)
	elseif m == Enum.Material.SmoothPlastic or m == Enum.Material.Plastic then
		if near(c, 238, 240, 245) then
			apply(part, P.White)
		elseif near(c, 222, 226, 234) or near(c, 208, 212, 220) then
			apply(part, P.Cloud)
		elseif near(c, 28, 34, 60) or near(c, 20, 22, 34) or near(c, 40, 32, 66) then
			apply(part, hasGui(part) and P.Ink or P.Navy)
		end
	end
end

local function restyleDescendant(d)
	if d:IsA("BasePart") then
		restylePart(d)
	elseif d:IsA("UIStroke") then
		d.Color = Color3.fromRGB(30, 26, 70)
	end
end

---------------------------------------------------------------------
-- 2. ARCHITECTURE PASS (template coordinates: entrance faces -Z,
--    building spans X -48..48, Z 28..163, Y 0..96, floors every 32)
---------------------------------------------------------------------
local function addArchitecture(template)
	local folder = Instance.new("Folder")
	folder.Name = "Architecture"
	folder.Parent = template
	-- the template's own space: every template part position is measured from here
	local b = Architecture.builder(folder, CFrame.new())

	-- A. Capsule corner towers: round shells, colored bands per floor, domed caps with a bulb
	local bandColors = {"Sky", "Lilac", "Mint"}
	for _, x in ipairs({-48, 48}) do
		for _, z in ipairs({27, 163}) do
			b:disc("TowerShell", 8, 99, CFrame.new(x, 49.5, z), "White")
			b:disc("TowerFoot", 9.6, 1.4, CFrame.new(x, 0.7, z), "Violet")
			for i, y in ipairs({32, 64, 96}) do
				b:disc("TowerBand", 8.8, 1.6, CFrame.new(x, y, z), bandColors[i])
			end
			b:ellipsoid("TowerDome", Vector3.new(8.8, 7, 8.8), CFrame.new(x, 99, z), "Lilac")
			b:bulb("TowerBulb", 1.6, CFrame.new(x, 103.2, z), "GlowSun", 16)
		end
	end

	-- B. Rounded floor bands wrapping the front and both sides
	for i, y in ipairs({32.4, 64.4}) do
		local finish = i == 1 and "Sky" or "Lilac"
		b:rod("FrontBand", 96, 2.2, CFrame.new(0, y, 27.1), finish)
		for _, side in ipairs({-1, 1}) do
			b:rod("SideBand", 134, 2.2, CFrame.new(side * 48.6, y, 95) * CFrame.Angles(0, math.rad(90), 0), finish)
		end
	end

	-- C. Round porthole windows along both side walls, between the existing fins
	for _, side in ipairs({-1, 1}) do
		for z = 47, 143, 16 do
			for _, y in ipairs({16, 48, 80}) do
				b:rod("PortholeRim", 0.7, 9.4, CFrame.new(side * 47.3, y, z), "Lilac")
				b:rod("PortholeGlass", 0.8, 7.6, CFrame.new(side * 47.35, y, z), "Glass")
				b:ball("PortholeShine", 1.4, CFrame.new(side * 47.75, y + 1.9, z - 1.9), "White", {CastShadow = false})
			end
		end
	end

	-- D. Entrance: bubble canopy, capsule pillars, rounded sign backing
	b:ellipsoid("CanopyBubble", Vector3.new(38, 3.4, 13), CFrame.new(0, 25.2, 24.5), "Sky")
	b:ellipsoid("CanopyBubbleTop", Vector3.new(34, 2.2, 10.5), CFrame.new(0, 26.4, 24.5), "White")
	for i = -3, 3 do
		b:bulb("CanopyBulb", 0.9, CFrame.new(i * 5, 23.7, 18.5), i % 2 == 0 and "GlowSun" or "GlowPink", 8)
	end
	for _, side in ipairs({-1, 1}) do
		b:disc("PillarShell", 7, 22.4, CFrame.new(side * 14, 11.2, 27), "Lilac")
		b:ball("PillarTop", 7.2, CFrame.new(side * 14, 22.4, 27), "Lilac")
		b:disc("PillarBand", 7.6, 1.2, CFrame.new(side * 14, 6, 27), "Sun")
		b:disc("PillarBand", 7.6, 1.2, CFrame.new(side * 14, 17, 27), "Sun")
		b:disc("PillarFoot", 8.6, 1.2, CFrame.new(side * 14, 0.6, 27), "Violet")
	end
	b:roundedBlock("EntranceSignBack", Vector3.new(40, 10.6, 0.8), CFrame.new(0, 30, 24.2), 3, "Violet")
	b:roundedBlock("RoofSignBack", Vector3.new(53.5, 12, 1), CFrame.new(0, 103.5, 34.5), 3.5, "Violet")

	-- E. Glass bubble dome on the roof with a floating meme orb inside
	b:disc("DomeDrum", 46, 4, CFrame.new(0, 101, 80), "White")
	b:disc("DomeDrumBand", 47, 1.4, CFrame.new(0, 101.6, 80), "Sky")
	local dome = b:ellipsoid("RoofDome", Vector3.new(44, 30, 44), CFrame.new(0, 103, 80), "Glass")
	dome.Color = Color3.fromRGB(196, 176, 255)
	dome.Transparency = 0.3
	b:ring("RoofDomeRing", CFrame.new(0, 103.2, 80) * CFrame.Angles(math.rad(90), 0, 0), 22.2, 1.4, "Lilac", 40)
	b:ball("MemeOrb", 8, CFrame.new(0, 109, 80), "Coral")
	b:ring("MemeOrbRing", CFrame.new(0, 109, 80) * CFrame.Angles(math.rad(70), 0, math.rad(15)), 6.2, 0.7, "Sun", 24)
	b:disc("DomeCap", 6, 1.2, CFrame.new(0, 118, 80), "Lilac")
	b:bulb("DomeBeacon", 2.4, CFrame.new(0, 119.6, 80), "GlowPink", 30)

	-- F. Floating orb pedestals on the plaza
	for _, side in ipairs({-1, 1}) do
		local cf = CFrame.new(side * 16.5, 0.6, 10)
		local _, h = b:tiers("PlazaPedestal", cf, {
			{8, 0.6, "Violet"},
			{6.4, 0.8, "White"},
			{5, 0.4, "Sky"},
		})
		local orb = cf * CFrame.new(0, h + 3.4, 0)
		b:ball("PlazaOrb", 3.2, orb, side < 0 and "Sun" or "Mint")
		b:ring("PlazaOrbRing", orb * CFrame.Angles(math.rad(75), 0, math.rad(side * 18)), 2.6, 0.35, "Lilac", 18)
		b:disc("PlazaOrbGlow", 3.6, 0.15, cf * CFrame.new(0, h + 0.08, 0), "GlowCyan")
	end
end

---------------------------------------------------------------------
return function(template)
	if template:GetAttribute("StyledCartoon2050") then return end
	for _, d in ipairs(template:GetDescendants()) do
		restyleDescendant(d)
	end
	addArchitecture(template)
	Architecture.calm(template)
	template:SetAttribute("StyledCartoon2050", true)
end
