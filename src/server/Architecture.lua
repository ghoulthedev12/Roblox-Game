-- Architecture (ModuleScript in ServerScriptService)
-- Shared building kit for the cartoony 2050 look: chunky rounded shapes (discs, capsules,
-- domes, rings, arches, rounded blocks), a bright soft palette (white, lilac, sky, mint,
-- sunshine) and gentle pastel glow trims.
-- ShopBuilder, WorldGate and MuseumStyle all build with this.

local Architecture = {}

---------------------------------------------------------------------
-- PALETTE
---------------------------------------------------------------------
local rgb = Color3.fromRGB
local PLASTIC = Enum.Material.SmoothPlastic
Architecture.Palette = {
	White    = {Color = rgb(246, 247, 252), Material = PLASTIC},
	Cloud    = {Color = rgb(222, 227, 242), Material = PLASTIC},
	Lilac    = {Color = rgb(178, 158, 255), Material = PLASTIC},
	Violet   = {Color = rgb(122, 92, 232),  Material = PLASTIC},
	Sky      = {Color = rgb(92, 186, 255),  Material = PLASTIC},
	Mint     = {Color = rgb(96, 226, 190),  Material = PLASTIC},
	Sun      = {Color = rgb(255, 206, 84),  Material = PLASTIC},
	Coral    = {Color = rgb(255, 122, 138), Material = PLASTIC},
	Navy     = {Color = rgb(52, 56, 118),   Material = PLASTIC},
	Ink      = {Color = rgb(34, 36, 74),    Material = PLASTIC},
	Chrome   = {Color = rgb(214, 220, 232), Material = Enum.Material.Metal, Reflectance = 0.2},
	Glass    = {Color = rgb(168, 228, 255), Material = Enum.Material.Glass, Transparency = 0.45, Reflectance = 0.15},
	GlowCyan = {Color = rgb(120, 236, 255), Material = Enum.Material.Neon},
	GlowPink = {Color = rgb(255, 140, 222), Material = Enum.Material.Neon},
	GlowSun  = {Color = rgb(255, 222, 120), Material = Enum.Material.Neon},
	GlowMint = {Color = rgb(120, 255, 205), Material = Enum.Material.Neon},
	Portal   = {Color = rgb(170, 130, 255), Material = Enum.Material.ForceField},
}
Architecture.TextColor = rgb(255, 255, 255)
Architecture.TitleColor = rgb(255, 222, 110)
Architecture.AccentText = rgb(150, 230, 255)
Architecture.LightColor = rgb(225, 240, 255)

local UPRIGHT = CFrame.Angles(0, 0, math.rad(90)) -- turns a cylinder (X axis) to stand up (Y axis)

-- A CFrame at `position` whose X axis points along `direction` (for rods and capsules)
function Architecture.alongX(position, direction)
	local x = direction.Unit
	local helper = math.abs(x.Y) > 0.95 and Vector3.zAxis or Vector3.yAxis
	local z = x:Cross(helper).Unit
	local y = z:Cross(x)
	return CFrame.fromMatrix(position, x, y, z)
end

---------------------------------------------------------------------
-- BUILDER: every position is relative to `base` (a CFrame)
---------------------------------------------------------------------
local Builder = {}
Builder.__index = Builder

function Architecture.builder(parent, base)
	return setmetatable({Parent = parent, Base = base}, Builder)
end

-- A plain anchored part. `finish` is a palette name (see above).
function Builder:box(name, size, offset, finish, props)
	local f = Architecture.Palette[finish] or Architecture.Palette.White
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.CFrame = self.Base * offset
	p.Color = f.Color
	p.Material = f.Material
	p.Transparency = f.Transparency or 0
	p.Reflectance = f.Reflectance or 0
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if f.Transparency or f.Material == Enum.Material.Neon then
		p.CastShadow = false
	end
	if props then
		for key, value in pairs(props) do
			p[key] = value
		end
	end
	p.Parent = self.Parent
	return p
end

-- Flat round disc / short cylinder standing upright, centered at `offset`.
function Builder:disc(name, diameter, height, offset, finish, props)
	local p = self:box(name, Vector3.new(height, diameter, diameter), offset * UPRIGHT, finish, props)
	p.Shape = Enum.PartType.Cylinder
	return p
end

-- Cylinder lying along the local X axis of `offset`.
function Builder:rod(name, length, diameter, offset, finish, props)
	local p = self:box(name, Vector3.new(length, diameter, diameter), offset, finish, props)
	p.Shape = Enum.PartType.Cylinder
	return p
end

function Builder:ball(name, diameter, offset, finish, props)
	local p = self:box(name, Vector3.new(diameter, diameter, diameter), offset, finish, props)
	p.Shape = Enum.PartType.Ball
	return p
end

-- Squashed/stretched sphere (domes, saucers, blobs). `size` is the full ellipsoid size.
function Builder:ellipsoid(name, size, offset, finish, props)
	local p = self:box(name, size, offset, finish, props)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = p
	return p
end

-- Capsule from point a to point b: a rod with a ball on each end.
function Builder:pill(name, a, b, diameter, finish)
	local length = (b - a).Magnitude
	self:rod(name, length, diameter, Architecture.alongX((a + b) / 2, b - a), finish)
	self:ball(name .. "CapA", diameter, CFrame.new(a), finish)
	self:ball(name .. "CapB", diameter, CFrame.new(b), finish)
end

-- A block with rounded vertical edges (size = full outer size, radius = corner radius).
function Builder:roundedBlock(name, size, offset, radius, finish)
	radius = math.min(radius, size.X / 2, size.Z / 2)
	local core = self:box(name, Vector3.new(size.X - radius * 2, size.Y, size.Z), offset, finish)
	self:box(name .. "Side", Vector3.new(size.X, size.Y, size.Z - radius * 2), offset, finish)
	for _, sx in ipairs({-1, 1}) do
		for _, sz in ipairs({-1, 1}) do
			self:disc(name .. "Corner", radius * 2, size.Y,
				offset * CFrame.new(sx * (size.X / 2 - radius), 0, sz * (size.Z / 2 - radius)), finish)
		end
	end
	return core
end

-- A ring (torus) made of short rods. `cf` is the ring's center; the ring lies in the
-- XY plane of `cf` (so it faces along Z, like a doorway). Use `arc` < 360 for an arch.
function Builder:ring(name, cf, radius, thickness, finish, segments, arc, startAngle)
	segments = segments or 28
	arc = arc or 360
	startAngle = startAngle or 0
	local step = arc / segments
	local segLength = 2 * radius * math.sin(math.rad(step / 2)) + thickness * 0.35
	for i = 0, segments - 1 do
		local a = math.rad(startAngle + step * (i + 0.5))
		local point = Vector3.new(math.cos(a) * radius, math.sin(a) * radius, 0)
		-- the rod runs along the circle's tangent
		local rodCF = cf * CFrame.new(point) * CFrame.Angles(0, 0, a + math.pi / 2)
		self:rod(name, segLength, thickness, rodCF, finish)
	end
	if arc < 360 then
		for _, a in ipairs({startAngle, startAngle + arc}) do
			local r = math.rad(a)
			self:ball(name .. "End", thickness, cf * CFrame.new(math.cos(r) * radius, math.sin(r) * radius, 0), finish)
		end
	end
end

-- Stacked discs that shrink as they go up (a staggered round platform).
-- tiers = {{diameter, height, finish}, ...}, bottom first. Returns the top part and the total height.
function Builder:tiers(name, cf, list)
	local y = 0
	local top
	for i, tier in ipairs(list) do
		top = self:disc(name .. "Tier" .. i, tier[1], tier[2], cf * CFrame.new(0, y + tier[2] / 2, 0), tier[3])
		y += tier[2]
	end
	return top, y
end

-- A soft glowing light bulb (small neon ball with a light).
function Builder:bulb(name, diameter, offset, finish, range)
	local p = self:ball(name, diameter, offset, finish or "GlowCyan")
	local light = Instance.new("PointLight")
	light.Color = p.Color
	light.Range = range or 10
	light.Brightness = 0.8
	light.Parent = p
	return p
end

-- Big friendly sign text on a part's face.
function Architecture.sign(part, title, subtitle, face, titleColor)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face or Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0
	gui.Parent = part
	local function line(text, color, y, h, font)
		local l = Instance.new("TextLabel")
		l.BackgroundTransparency = 1
		l.Position = UDim2.fromScale(0.05, y)
		l.Size = UDim2.fromScale(0.9, h)
		l.Text = text
		l.TextColor3 = color
		l.Font = font
		l.TextScaled = true
		l.Parent = gui
		local s = Instance.new("UIStroke")
		s.Thickness = 3
		s.Color = Color3.fromRGB(30, 26, 70)
		s.Parent = l
		return l
	end
	line(title, titleColor or Architecture.TitleColor, subtitle and 0.06 or 0.12, subtitle and 0.58 or 0.76, Enum.Font.FredokaOne)
	if subtitle then
		line(subtitle, Architecture.AccentText, 0.66, 0.28, Enum.Font.FredokaOne)
	end
	return gui
end

return Architecture
