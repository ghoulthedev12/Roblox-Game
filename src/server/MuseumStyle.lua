-- MuseumStyle (ModuleScript in ServerScriptService)
-- Restyles ServerStorage.MuseumTemplate once, on server start, before any museum is cloned:
--   1. Swaps the white-plastic + bright-neon look for a desaturated 2050 palette
--      (concrete, slate, corroded metal, brushed foil, smoked glass, dimmed light strips).
--   2. Adds layered architecture to the outside: facade steel fins, floor-line spandrels,
--      recessed side panels, a deep entrance portal, a two-layer cantilevered roof on
--      I-beams, ribbed corner towers and staggered sculpture plinths on the plaza.
-- Slot, elevator and sign parts keep their names and positions, so nothing that looks
-- them up by name breaks.

local Architecture = require(script.Parent:WaitForChild("Architecture"))
local P = Architecture.Palette

local function luminance(c)
	return 0.299 * c.R + 0.587 * c.G + 0.114 * c.B
end

-- Pulls a color toward grey and darkens it (amount 0 = unchanged, 1 = fully grey)
local function mute(c, amount, darken)
	local l = luminance(c)
	local grey = Color3.new(l, l, l)
	local m = grey:Lerp(c, 1 - amount)
	darken = darken or 1
	return Color3.new(m.R * darken, m.G * darken, m.B * darken)
end

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
	local name = part.Name

	if m == Enum.Material.Neon then
		-- light strips stay as thin, dim, desaturated glows; big glowing panels become steel
		local s = part.Size
		local dims = {s.X, s.Y, s.Z}
		table.sort(dims)
		if dims[2] > 3 then
			apply(part, P.SteelDark)
		else
			part.Color = mute(c, 0.8, 0.42)
		end
	elseif m == Enum.Material.Glass then
		if luminance(c) > 0.5 and c.G > c.R * 1.25 and c.G > 0.8 then
			-- glowing sci-fi foliage becomes real planting
			part.Material = Enum.Material.Grass
			part.Color = Color3.fromRGB(78, 94, 72)
			part.Transparency = 0
		else
			apply(part, P.SmokedGlass)
		end
	elseif m == Enum.Material.ForceField then
		part.Color = mute(c, 0.85, 0.7)
	elseif m == Enum.Material.Metal then
		apply(part, P.Steel)
	elseif m == Enum.Material.Fabric then
		part.Color = mute(c, 0.45, 0.7)
	elseif m == Enum.Material.Grass then
		part.Color = mute(c, 0.5, 0.75)
	elseif m == Enum.Material.SmoothPlastic or m == Enum.Material.Plastic then
		if hasGui(part) then
			apply(part, P.Screen) -- keep signs and screens smooth so text stays readable
		elseif name:find("Floor") or name == "Plaza" or name == "Runner" or name:find("Slab") then
			apply(part, P.Graphite)
			part.Reflectance = 0.05
		elseif near(c, 238, 240, 245) or near(c, 222, 226, 234) or near(c, 208, 212, 220) then
			apply(part, P.Concrete)
		elseif near(c, 28, 34, 60) or near(c, 20, 22, 34) or near(c, 40, 32, 66) then
			apply(part, P.Charcoal)
		elseif near(c, 150, 155, 165) then
			apply(part, P.SlateGrey)
		else
			-- any other colored plastic: keep its hue but desaturate it heavily
			part.Color = mute(c, 0.75, 0.75)
			part.Material = Enum.Material.Slate
		end
	end
end

local function restyleDescendant(d)
	if d:IsA("BasePart") then
		restylePart(d)
	elseif d:IsA("Light") then
		d.Color = Architecture.LightColor
		d.Brightness = d.Brightness * 0.8
	elseif d:IsA("TextLabel") or d:IsA("TextButton") then
		d.TextColor3 = mute(d.TextColor3, 0.7, 1):Lerp(Architecture.TextColor, 0.35)
	elseif d:IsA("UIStroke") then
		d.Color = Color3.fromRGB(12, 12, 14)
	end
end

---------------------------------------------------------------------
-- 2. ARCHITECTURE PASS (template coordinates: entrance faces -Z,
--    building spans X -48..48, Z 28..163, Y 0..96)
---------------------------------------------------------------------
local function addArchitecture(template)
	local folder = Instance.new("Folder")
	folder.Name = "Architecture"
	folder.Parent = template
	-- the template's own space: every template part position is measured from here
	local b = Architecture.builder(folder, CFrame.new())

	-- A. Facade steel fins on the front wall (skip the entrance zone)
	for _, x in ipairs({21, 28, 35, 42}) do
		for _, side in ipairs({-1, 1}) do
			b:box("FacadeFin", Vector3.new(0.8, 94, 1.8), CFrame.new(side * x, 49, 27.1), "SteelDark")
		end
	end

	-- B. Floor-line spandrels: heavy concrete bands that project past the facade
	for _, y in ipairs({33.4, 65.4}) do
		b:box("Spandrel", Vector3.new(98, 2.4, 3), CFrame.new(0, y, 26.6), "ConcreteLight")
		b:box("SpandrelShadow", Vector3.new(96, 0.3, 2.6), CFrame.new(0, y - 1.35, 26.8), "Charcoal")
	end

	-- C. Recessed panels on both side walls, between the existing fins, per floor
	for _, side in ipairs({-1, 1}) do
		for z = 47, 143, 16 do
			for _, y in ipairs({16, 48, 80}) do
				-- set against the wall face, facing outward; the existing fins stand 1 stud proud of it
				local cf = CFrame.new(side * 47, y, z) * CFrame.Angles(0, math.rad(-side * 90), 0)
				b:recessedPanel("SidePanel", cf, 13.6, 28, "Concrete", "Graphite")
			end
		end
	end

	-- D. Deep entrance portal: projecting reveal walls, a heavy lintel, and an
	--    upper steel canopy layered over the existing concrete one
	for _, side in ipairs({-1, 1}) do
		b:box("PortalReveal", Vector3.new(0.8, 18, 6), CFrame.new(side * 10.8, 9.5, 26), "ConcreteDark")
	end
	b:box("PortalLintel", Vector3.new(22.4, 3, 7), CFrame.new(0, 20, 25.5), "Concrete")
	-- thin steel plate slung under the concrete canopy, reaching further out, hung on rods
	b:box("CanopyUpper", Vector3.new(46, 0.5, 14), CFrame.new(0, 23.7, 19), "Steel")
	for _, x in ipairs({-21.5, 21.5}) do
		b:iBeam("CanopyHanger", Vector3.new(x, 23.9, 12.5), Vector3.new(x, 39, 27.5), 0.5, 0.35)
	end
	for _, x in ipairs({-12, -4, 4, 12}) do
		b:downlight("EntranceLight", Vector3.new(x, 23.35, 16), 18, 1.2)
	end

	-- E. Two-layer cantilevered roof on exposed I-beams
	b:box("RoofOverhang", Vector3.new(108, 1.2, 22), CFrame.new(0, 97.5, 29), "ConcreteLight")
	b:box("RoofOverhangLower", Vector3.new(116, 0.6, 12), CFrame.new(-3, 96.3, 24), "Steel")
	for x = -48, 48, 12 do
		b:iBeam("RoofBeam", Vector3.new(x, 95.5, 18.5), Vector3.new(x, 95.5, 34), 0.9, 0.5)
	end
	for _, x in ipairs({-36, -12, 12, 36}) do
		b:downlight("SoffitLight", Vector3.new(x, 95.9, 22), 30, 1)
	end

	-- F. Ribbed corner towers
	for _, x in ipairs({-48, 48}) do
		for _, z in ipairs({27, 163}) do
			for y = 8, 92, 12 do
				b:box("TowerRib", Vector3.new(7, 0.8, 7), CFrame.new(x, y, z), "ConcreteDark")
			end
		end
	end

	-- G. Staggered sculpture plinths on the plaza, each carrying a slate monolith
	for _, side in ipairs({-1, 1}) do
		local cf = CFrame.new(side * 16.5, 0.6, 10)
		local _, height = b:stagger("PlazaPlinth", cf, {
			{8, 0.6, 8, "Graphite"},
			{6.2, 0.6, 6.2, "ConcreteDark"},
			{4.4, 0.5, 4.4, "Steel"},
		}, side * 14, Vector3.zero)
		b:box("Monolith", Vector3.new(1.6, 8, 3.2), cf * CFrame.Angles(0, math.rad(side * 28), 0) * CFrame.new(0, height + 4, 0), "Charcoal")
		b:box("MonolithInlay", Vector3.new(1.7, 6.5, 0.15), cf * CFrame.Angles(0, math.rad(side * 28), 0) * CFrame.new(0, height + 4, -0.6), "Steel")
	end
end

---------------------------------------------------------------------
return function(template)
	if template:GetAttribute("Styled2050") then return end
	for _, d in ipairs(template:GetDescendants()) do
		restyleDescendant(d)
	end
	addArchitecture(template)
	template:SetAttribute("Styled2050", true)
end
