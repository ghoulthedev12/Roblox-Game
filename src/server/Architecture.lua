-- Architecture (ModuleScript in ServerScriptService)
-- Shared building kit for the 2050 look: a desaturated palette (slate, concrete,
-- corroded metal, brushed foil), structural steel I-beams, columns with base plates,
-- recessed wall panels, staggered platforms and recessed downlights.
-- ShopBuilder, WorldGate and MuseumStyle all build with this.

local Architecture = {}

---------------------------------------------------------------------
-- PALETTE (dark charcoals, raw concrete, brushed steel)
---------------------------------------------------------------------
local rgb = Color3.fromRGB
Architecture.Palette = {
	Charcoal      = {Color = rgb(34, 35, 38),    Material = Enum.Material.Slate},
	Graphite      = {Color = rgb(52, 54, 58),    Material = Enum.Material.Slate},
	SlateGrey     = {Color = rgb(78, 80, 84),    Material = Enum.Material.Slate},
	Concrete      = {Color = rgb(122, 120, 115), Material = Enum.Material.Concrete},
	ConcreteLight = {Color = rgb(152, 149, 143), Material = Enum.Material.Concrete},
	ConcreteDark  = {Color = rgb(88, 87, 84),    Material = Enum.Material.Concrete},
	Steel         = {Color = rgb(138, 141, 146), Material = Enum.Material.Foil},
	SteelDark     = {Color = rgb(72, 74, 78),    Material = Enum.Material.CorrodedMetal},
	Weathered     = {Color = rgb(96, 90, 84),    Material = Enum.Material.CorrodedMetal},
	SmokedGlass   = {Color = rgb(44, 48, 52),    Material = Enum.Material.Glass, Transparency = 0.35, Reflectance = 0.25},
	Screen        = {Color = rgb(24, 25, 27),    Material = Enum.Material.SmoothPlastic},
}
Architecture.TextColor = rgb(222, 218, 210)   -- off-white engraved-look text
Architecture.AccentText = rgb(160, 168, 176)  -- cool steel grey for sub-lines
Architecture.LightColor = rgb(255, 228, 196)  -- warm architectural light (never neon)

---------------------------------------------------------------------
-- BUILDER: every position is relative to `base` (a CFrame)
---------------------------------------------------------------------
local Builder = {}
Builder.__index = Builder

function Architecture.builder(parent, base)
	return setmetatable({Parent = parent, Base = base}, Builder)
end

-- A plain anchored block. `finish` is a palette name (see above).
function Builder:box(name, size, offset, finish, props)
	local f = Architecture.Palette[finish] or Architecture.Palette.Concrete
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
	if f.Transparency then
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

-- Wide-flange steel I-beam from point a to point b (local coordinates).
-- `depth` = beam height, `width` = flange width.
function Builder:iBeam(name, a, b, depth, width, finish)
	finish = finish or "SteelDark"
	local length = (b - a).Magnitude
	local dir = (b - a).Unit
	local up = math.abs(dir.Y) > 0.95 and Vector3.xAxis or Vector3.yAxis
	local cf = CFrame.lookAt((a + b) / 2, b, up)
	local flange = math.max(depth * 0.12, 0.12)
	self:box(name .. "FlangeTop", Vector3.new(width, flange, length), cf * CFrame.new(0, depth / 2 - flange / 2, 0), finish)
	self:box(name .. "FlangeBottom", Vector3.new(width, flange, length), cf * CFrame.new(0, -depth / 2 + flange / 2, 0), finish)
	self:box(name .. "Web", Vector3.new(math.max(width * 0.18, 0.1), depth - flange * 2, length), cf, finish)
end

-- Square steel column standing on a base plate, with a cap plate on top.
function Builder:column(name, position, height, width, finish)
	finish = finish or "Steel"
	self:box(name .. "BasePlate", Vector3.new(width * 1.8, 0.2, width * 1.8), CFrame.new(position + Vector3.new(0, 0.1, 0)), "SteelDark")
	for _, corner in ipairs({Vector3.new(1, 0, 1), Vector3.new(-1, 0, 1), Vector3.new(1, 0, -1), Vector3.new(-1, 0, -1)}) do
		self:box(name .. "Bolt", Vector3.new(0.18, 0.18, 0.18), CFrame.new(position + corner * width * 0.7 + Vector3.new(0, 0.25, 0)), "Steel")
	end
	self:box(name, Vector3.new(width, height, width), CFrame.new(position + Vector3.new(0, height / 2, 0)), finish)
	self:box(name .. "CapPlate", Vector3.new(width * 1.5, 0.2, width * 1.5), CFrame.new(position + Vector3.new(0, height + 0.1, 0)), "SteelDark")
end

-- A panel set back into a wall: raised frame, shadow reveal, and a darker inset.
-- `cf` is the panel's center on the wall face, facing out along -Z of `cf`.
function Builder:recessedPanel(name, cf, width, height, frameFinish, insetFinish)
	frameFinish = frameFinish or "ConcreteLight"
	insetFinish = insetFinish or "Graphite"
	local t = 0.5 -- frame thickness
	self:box(name .. "FrameTop", Vector3.new(width, t, 0.5), cf * CFrame.new(0, height / 2 - t / 2, -0.25), frameFinish)
	self:box(name .. "FrameBottom", Vector3.new(width, t, 0.5), cf * CFrame.new(0, -height / 2 + t / 2, -0.25), frameFinish)
	self:box(name .. "FrameL", Vector3.new(t, height - t * 2, 0.5), cf * CFrame.new(-width / 2 + t / 2, 0, -0.25), frameFinish)
	self:box(name .. "FrameR", Vector3.new(t, height - t * 2, 0.5), cf * CFrame.new(width / 2 - t / 2, 0, -0.25), frameFinish)
	self:box(name .. "Reveal", Vector3.new(width - t * 2, height - t * 2, 0.1), cf * CFrame.new(0, 0, -0.05), "Charcoal")
	return self:box(name .. "Inset", Vector3.new(width - t * 2 - 0.3, height - t * 2 - 0.3, 0.2), cf * CFrame.new(0, 0, -0.12), insetFinish)
end

-- Stacked slabs that shrink and twist as they go up (a staggered platform).
-- tiers = {{width, height, depth, finish}, ...}, bottom first. Returns the top slab.
function Builder:stagger(name, cf, tiers, twistDegrees, shift)
	local y = 0
	local top
	for i, tier in ipairs(tiers) do
		local w, h, d, finish = tier[1], tier[2], tier[3], tier[4]
		local offset = CFrame.new((shift or Vector3.zero) * (i - 1)) * CFrame.Angles(0, math.rad((twistDegrees or 0) * (i - 1)), 0)
		top = self:box(name .. "Tier" .. i, Vector3.new(w, h, d), cf * offset * CFrame.new(0, y + h / 2, 0), finish)
		y += h
	end
	return top, y
end

-- A small recessed can light in a ceiling, shining down with warm light.
function Builder:downlight(name, position, range, brightness)
	self:box(name, Vector3.new(0.9, 0.15, 0.9), CFrame.new(position), "Charcoal", {CanCollide = false, CastShadow = false})
	local lens = self:box(name .. "Lens", Vector3.new(0.6, 0.05, 0.6), CFrame.new(position - Vector3.new(0, 0.09, 0)), "Steel", {CanCollide = false, CastShadow = false})
	lens.Material = Enum.Material.Glass
	lens.Color = Color3.fromRGB(235, 225, 210)
	lens.Transparency = 0.1
	local light = Instance.new("SpotLight")
	light.Face = Enum.NormalId.Bottom
	light.Color = Architecture.LightColor
	light.Range = range or 16
	light.Brightness = brightness or 1.4
	light.Angle = 75
	light.Shadows = true
	light.Parent = lens
	return lens
end

-- Engraved-look sign text on a part's front face (no neon, no glow).
function Architecture.sign(part, title, subtitle, face)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face or Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0.6
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
		return l
	end
	line(title, Architecture.TextColor, subtitle and 0.1 or 0.15, subtitle and 0.52 or 0.7, Enum.Font.GothamMedium)
	if subtitle then
		line(subtitle, Architecture.AccentText, 0.66, 0.24, Enum.Font.Gotham)
	end
	return gui
end

return Architecture
