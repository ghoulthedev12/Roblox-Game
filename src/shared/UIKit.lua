-- UIKit (ModuleScript in ReplicatedStorage)
-- One chunky simulator-style look for every screen in the game:
--   * rounded panels with a soft top-to-bottom sheen and thick dark outlines
--   * punchy gradient buttons with a heavy dark outline, big white text with a black
--     outline, and a bounce when hovered/pressed
--   * windows with a full-width colored header bar, an icon, and the close button inside it
--   * text that scales with its box but never past a sensible size (so nothing looks huge)
--   * live 3D pickaxe icons (ViewportFrames that render the real pickaxe model)

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIKit = {}

local rgb = Color3.fromRGB
UIKit.Colors = {
	Ink = rgb(40, 32, 92),        -- dark text and window outlines
	Panel = rgb(252, 251, 255),   -- window background
	PanelTint = rgb(236, 231, 255),
	Row = rgb(246, 243, 255),     -- cards inside windows
	Violet = rgb(128, 90, 255),
	Lilac = rgb(184, 164, 255),
	Sky = rgb(58, 168, 255),
	Mint = rgb(38, 206, 140),
	Sun = rgb(255, 188, 40),
	Coral = rgb(255, 84, 112),
	Grey = rgb(128, 122, 162),    -- secondary text
	White = rgb(255, 255, 255),
	Money = rgb(46, 196, 90),
	Outline = rgb(22, 20, 32),    -- the thick dark outline around buttons, windows and text
}
local C = UIKit.Colors
UIKit.Font = Enum.Font.FredokaOne
UIKit.BodyFont = Enum.Font.GothamMedium

-- a darker (amount > 0) or lighter (amount < 0) version of a color
function UIKit.shadeColor(color, amount)
	if amount >= 0 then
		return color:Lerp(Color3.new(0.1, 0.07, 0.25), amount)
	end
	return color:Lerp(Color3.new(1, 1, 1), -amount)
end
local function luminance(c)
	return 0.299 * c.R + 0.587 * c.G + 0.114 * c.B
end
-- outline that suits a background: soft lavender around light panels, a deep shade of the
-- color itself around colored ones
local function autoOutline(color)
	if luminance(color) > 0.86 then
		return rgb(150, 140, 190) -- light cards: a soft but visible edge
	end
	return color:Lerp(C.Outline, 0.72) -- colored panels: a heavy dark edge
end
UIKit.autoOutline = autoOutline

---------------------------------------------------------------------
-- BASICS
---------------------------------------------------------------------
-- RESPONSIVE SIZE: every top-level panel on every screen gets a UIScale set from the screen
-- size (1 on a 1280x760 screen, smaller on phones, a bit bigger on big monitors), so the whole
-- UI fits PC, mobile and console alike. It updates when the window is resized or rotated.
function UIKit.screenScale()
	local camera = workspace.CurrentCamera
	local v = camera and camera.ViewportSize or Vector2.new(1280, 760)
	return math.clamp(math.min(v.X / 1280, v.Y / 760), 0.55, 1.25)
end
local responsive = setmetatable({}, {__mode = "k"}) -- the UIScales we manage
local function makeResponsive(scale)
	scale:SetAttribute("Responsive", true)
	scale.Scale = UIKit.screenScale()
	responsive[scale] = true
end
task.spawn(function()
	local camera = workspace.CurrentCamera
	if not camera then return end
	camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		local k = UIKit.screenScale()
		for scale in pairs(responsive) do
			if scale.Parent then scale.Scale = k end
		end
	end)
end)

function UIKit.screen(player, name, order)
	local gui = Instance.new("ScreenGui")
	gui.Name = name
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = order or 0
	gui.Parent = player:WaitForChild("PlayerGui")
	-- scale every top-level panel to the screen (panels that manage their own UIScale are left alone)
	gui.ChildAdded:Connect(function(child)
		task.defer(function()
			if child.Parent == gui and child:IsA("GuiObject") and not child:FindFirstChildOfClass("UIScale") then
				local scale = Instance.new("UIScale")
				makeResponsive(scale)
				scale.Parent = child
			end
		end)
	end)
	return gui
end

function UIKit.corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 14)
	c.Parent = parent
	return c
end

function UIKit.outline(parent, thickness, color)
	local s = Instance.new("UIStroke")
	s.Color = color or C.Ink
	s.Thickness = thickness or 3
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.LineJoinMode = Enum.LineJoinMode.Round
	s.Parent = parent
	return s
end

-- soft top-to-bottom sheen so flat panels look chunky
function UIKit.shade(parent, amount)
	amount = amount or 0.1
	local g = Instance.new("UIGradient")
	g.Rotation = 90
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(0.5, Color3.new(1 - amount * 0.35, 1 - amount * 0.35, 1 - amount * 0.3)),
		ColorSequenceKeypoint.new(1, Color3.new(1 - amount, 1 - amount, 1 - amount * 0.8)),
	})
	g.Parent = parent
	return g
end

-- A rounded box. props: Size, Position, AnchorPoint, Color, Radius, Transparency,
-- Stroke (thickness or false), StrokeColor (default: matches the color), Shade (false for flat)
function UIKit.panel(parent, props)
	local f = Instance.new("Frame")
	f.Size = props.Size or UDim2.fromOffset(200, 100)
	f.Position = props.Position or UDim2.new()
	f.AnchorPoint = props.AnchorPoint or Vector2.zero
	f.BackgroundColor3 = props.Color or C.Panel
	f.BackgroundTransparency = props.Transparency or 0
	f.BorderSizePixel = 0
	f.Parent = parent
	UIKit.corner(f, props.Radius or 16)
	if props.Stroke ~= false then
		local stroke = UIKit.outline(f, props.Stroke or 2.5, props.StrokeColor or autoOutline(f.BackgroundColor3))
		if not props.StrokeColor then
			-- keep the outline matching when the color changes later (rarity tags etc.)
			f:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				stroke.Color = autoOutline(f.BackgroundColor3)
			end)
		end
	end
	if props.Shade ~= false then
		UIKit.shade(f, props.ShadeAmount)
	end
	return f
end

-- Bubbly text. props: Size, Position, AnchorPoint, Color, Align ("Left"/"Center"/"Right"),
-- VAlign, Stroke (outline thickness, 0 for none), StrokeColor, Font,
-- TextSize (fixed size) or MaxText (largest size scaled text may grow to, default 30)
function UIKit.label(parent, text, props)
	props = props or {}
	local l = Instance.new("TextLabel")
	l.Size = props.Size or UDim2.fromScale(1, 1)
	l.Position = props.Position or UDim2.new()
	l.AnchorPoint = props.AnchorPoint or Vector2.zero
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = props.Color or C.White
	l.Font = props.Font or UIKit.Font
	if props.TextSize then
		l.TextSize = props.TextSize
		l.TextWrapped = true
	else
		l.TextScaled = true
		local limit = Instance.new("UITextSizeConstraint")
		limit.MaxTextSize = props.MaxText or 30
		limit.MinTextSize = 6
		limit.Parent = l
	end
	l.TextXAlignment = Enum.TextXAlignment[props.Align or "Center"]
	l.TextYAlignment = Enum.TextYAlignment[props.VAlign or "Center"]
	l.RichText = props.RichText or false
	l.Parent = parent
	local strokeSize = props.Stroke == nil and 2 or props.Stroke
	if strokeSize > 0 then
		local s = Instance.new("UIStroke")
		s.Color = props.StrokeColor or C.Outline
		s.Thickness = strokeSize
		s.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
		s.Parent = l
	end
	return l
end

-- A glossy candy button that squishes when pressed and grows a bit on hover.
-- props: Size, Position, AnchorPoint, Color, TextColor, Radius, MaxText
-- Changing the button's BackgroundColor3 later recolors the whole button.
function UIKit.button(parent, text, props)
	props = props or {}
	local b = Instance.new("TextButton")
	b.Size = props.Size or UDim2.fromOffset(140, 44)
	b.Position = props.Position or UDim2.new()
	b.AnchorPoint = props.AnchorPoint or Vector2.zero
	b.BackgroundColor3 = props.Color or C.Mint
	b.AutoButtonColor = false
	b.Text = ""
	b.Parent = parent
	local radius = props.Radius or 14
	UIKit.corner(b, radius)
	local stroke = UIKit.outline(b, 3.5)
	local gloss = Instance.new("UIGradient")
	gloss.Rotation = 90
	gloss.Parent = b
	local label = UIKit.label(b, text, {
		Size = UDim2.new(1, -16, 1, -14), Position = UDim2.new(0.5, 0, 0.5, -2), AnchorPoint = Vector2.new(0.5, 0.5),
		Color = props.TextColor or C.White, Stroke = 3, MaxText = props.MaxText or 26,
	})
	label.Name = "Label"
	local labelStroke = label:FindFirstChildOfClass("UIStroke")

	local function paint()
		local c = b.BackgroundColor3
		stroke.Color = c:Lerp(C.Outline, 0.78)
		-- one smooth gradient does the shine: a bright top half, the full color in the middle,
		-- and a deeper bottom edge (no separate strips, so there are never lines across it)
		gloss.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(0.42, Color3.new(0.97, 0.97, 0.98)),
			ColorSequenceKeypoint.new(0.62, Color3.new(0.86, 0.86, 0.9)),
			ColorSequenceKeypoint.new(1, Color3.new(0.68, 0.68, 0.74)),
		})
		if labelStroke then labelStroke.Color = C.Outline end
	end
	paint()
	b:GetPropertyChangedSignal("BackgroundColor3"):Connect(paint)

	local scale = Instance.new("UIScale")
	scale.Parent = b
	local function to(v, t)
		TweenService:Create(scale, TweenInfo.new(t or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = v}):Play()
	end
	b.MouseEnter:Connect(function() to(1.05) end)
	b.MouseLeave:Connect(function() to(1) end)
	b.MouseButton1Down:Connect(function() to(0.92, 0.06) end)
	b.MouseButton1Click:Connect(function()
		-- a soft click on every button (through the SFX group, so it follows the SFX setting)
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local Audio = require(ReplicatedStorage:WaitForChild("Audio"))
		Audio.sfx("Click")
	end)
	b.MouseButton1Up:Connect(function() to(1.05) end)
	return b, label
end

function UIKit.setButton(button, text, color)
	button.BackgroundColor3 = color
	local label = button:FindFirstChild("Label")
	if label then label.Text = text end
end

-- Pops a frame in with a bouncy scale
function UIKit.pop(frame, from)
	local scale = frame:FindFirstChildOfClass("UIScale")
	if not scale then
		scale = Instance.new("UIScale")
		if frame.Parent and frame.Parent:IsA("ScreenGui") then makeResponsive(scale) end
		scale.Parent = frame
	end
	-- pop relative to the panel's screen-size scale
	local base = scale:GetAttribute("Responsive") and UIKit.screenScale() or 1
	scale.Scale = (from or 0.6) * base
	TweenService:Create(scale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = base}):Play()
end

-- A round colored badge with an emoji (or short text) in it
function UIKit.badge(parent, iconText, color, props)
	props = props or {}
	local d = props.Diameter or 44
	local circle = UIKit.panel(parent, {Size = UDim2.fromOffset(d, d), Position = props.Position, AnchorPoint = props.AnchorPoint,
		Color = color, Radius = d, Stroke = props.Stroke or 2.5})
	local icon = UIKit.label(circle, iconText, {Size = UDim2.fromScale(0.64, 0.64), Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5), Stroke = props.TextStroke or 0, MaxText = 60, Font = props.Font or Enum.Font.GothamBlack})
	icon.Name = "Icon"
	return circle, icon
end

---------------------------------------------------------------------
-- WINDOW: a panel with a colored header bar (icon + title + close button) and a body.
-- returns window, content (frame to put things in), closeButton
---------------------------------------------------------------------
local HEADER = 58
function UIKit.window(gui, title, size, accent, icon)
	accent = accent or C.Violet
	local window = UIKit.panel(gui, {
		Size = size, Position = UDim2.fromScale(0.5, 0.52), AnchorPoint = Vector2.new(0.5, 0.5),
		Color = C.Panel, Radius = 24, Stroke = 5, StrokeColor = C.Outline, ShadeAmount = 0.05,
	})
	window.Visible = false
	local sizeLimit = Instance.new("UISizeConstraint")
	sizeLimit.MaxSize = Vector2.new(size.X.Offset, size.Y.Offset)
	sizeLimit.Parent = window
	local aspect = Instance.new("UIAspectRatioConstraint")
	aspect.AspectRatio = size.X.Offset / size.Y.Offset
	aspect.Parent = window
	window.Size = UDim2.fromScale(0.92, 0.85)

	-- header bar: rounded on top, square where it meets the body
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.BorderSizePixel = 0
	header.BackgroundColor3 = accent
	header.Size = UDim2.new(1, 0, 0, HEADER)
	header.Parent = window
	UIKit.corner(header, 22)
	local headerFill = Instance.new("Frame")
	headerFill.BorderSizePixel = 0
	headerFill.BackgroundColor3 = accent
	headerFill.AnchorPoint = Vector2.new(0, 1)
	headerFill.Position = UDim2.fromScale(0, 1)
	headerFill.Size = UDim2.new(1, 0, 0, 22)
	headerFill.Parent = header

	local titleX = 22
	if icon then
		UIKit.badge(header, icon, UIKit.shadeColor(accent, -0.25), {Diameter = 40, Position = UDim2.new(0, 14, 0.5, -2), AnchorPoint = Vector2.new(0, 0.5)})
		titleX = 64
	end
	local titleLabel = UIKit.label(header, title, {Size = UDim2.new(1, -titleX - 70, 0, 38), Position = UDim2.new(0, titleX, 0.5, -2), AnchorPoint = Vector2.new(0, 0.5),
		Align = "Left", Stroke = 3.5, StrokeColor = C.Outline, MaxText = 34})
	-- the header gets the same shine as the buttons
	local headerShine = Instance.new("UIGradient")
	headerShine.Rotation = 90
	headerShine.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(0.5, Color3.new(0.95, 0.95, 0.97)),
		ColorSequenceKeypoint.new(1, Color3.new(0.78, 0.78, 0.84)),
	})
	headerShine.Parent = header
	-- the square filler under the header's bottom corners continues the same gradient
	-- (it covers the bottom 22 of the header's 58 pixels), so there's no seam
	local fillShine = Instance.new("UIGradient")
	fillShine.Rotation = 90
	local from = (HEADER - 22) / HEADER
	local at = 0.95 - (from - 0.5) / 0.5 * 0.17
	fillShine.Color = ColorSequence.new(Color3.new(at, at, at + 0.012), Color3.new(0.78, 0.78, 0.84))
	fillShine.Parent = headerFill
	titleLabel.Name = "Title"

	local close = UIKit.button(header, "X", {
		Size = UDim2.fromOffset(42, 42), Position = UDim2.new(1, -10, 0.5, -2), AnchorPoint = Vector2.new(1, 0.5), Color = C.Coral, Radius = 14, MaxText = 22,
	})
	close.MouseButton1Click:Connect(function()
		window.Visible = false
	end)

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundTransparency = 1
	content.Size = UDim2.new(1, -36, 1, -HEADER - 30)
	content.Position = UDim2.new(0, 18, 0, HEADER + 14)
	content.Parent = window
	return window, content, close
end

function UIKit.open(window)
	window.Visible = true
	UIKit.pop(window, 0.8)
end

-- Scrolling list with padding. returns the scrolling frame
function UIKit.list(parent, padding)
	local list = Instance.new("ScrollingFrame")
	list.Size = UDim2.fromScale(1, 1)
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.ScrollBarThickness = 8
	list.ScrollBarImageColor3 = C.Lilac
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new()
	list.Parent = parent
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, padding or 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = list
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 6)
	pad.PaddingBottom = UDim.new(0, 6)
	pad.PaddingRight = UDim.new(0, 10)
	pad.Parent = list
	return list
end

-- A small stat bar: label on the left, filled bar, value on the right
function UIKit.statBar(parent, name, fraction, valueText, color, props)
	local row = Instance.new("Frame")
	row.BackgroundTransparency = 1
	row.Size = props and props.Size or UDim2.new(1, 0, 0, 18)
	row.Position = props and props.Position or UDim2.new()
	row.Parent = parent
	UIKit.label(row, name, {Size = UDim2.new(0.26, 0, 0.9, 0), Position = UDim2.fromScale(0, 0.05), Align = "Left", Color = C.Grey, Stroke = 0, MaxText = 16})
	local track = UIKit.panel(row, {Size = UDim2.new(0.46, 0, 0.62, 0), Position = UDim2.new(0.27, 0, 0.19, 0), Color = rgb(232, 227, 250), Radius = 8, Stroke = false, Shade = false})
	local fill = UIKit.panel(track, {Size = UDim2.new(math.clamp(fraction, 0.06, 1), 0, 1, 0), Color = color, Radius = 8, Stroke = false, ShadeAmount = 0.2})
	fill.Name = "Fill"
	UIKit.label(row, valueText, {Size = UDim2.new(0.25, 0, 0.9, 0), Position = UDim2.new(0.75, 0, 0.05, 0), Align = "Right", Color = C.Ink, Stroke = 0, MaxText = 16})
	return row
end

---------------------------------------------------------------------
-- 3D PICKAXE ICON: renders the real pickaxe model inside a ViewportFrame
---------------------------------------------------------------------
local ShovelModels -- loaded on first use (only needed where icons are drawn)
function UIKit.shovelIcon(parent, def, props)
	props = props or {}
	ShovelModels = ShovelModels or require(ReplicatedStorage:WaitForChild("PickaxeModels"))
	local vp = Instance.new("ViewportFrame")
	vp.Size = props.Size or UDim2.fromOffset(80, 80)
	vp.Position = props.Position or UDim2.new()
	vp.AnchorPoint = props.AnchorPoint or Vector2.zero
	vp.BackgroundTransparency = 1
	vp.Ambient = rgb(200, 198, 215)
	vp.LightColor = rgb(255, 250, 240)
	vp.LightDirection = Vector3.new(-1, -1.5, -1)
	vp.Parent = parent

	-- show the pickaxe diagonally: head at the top-left, grip at the bottom-right, with the
	-- head's arms facing the camera (tool Y/Z in the screen plane) and a slight 3D turn
	local pose = CFrame.Angles(0, math.rad(22), 0) * CFrame.fromMatrix(Vector3.zero, Vector3.new(0, 0, -1), Vector3.new(1, 1, 0).Unit)
	local tool = ShovelModels(def)
	local model = Instance.new("Model")
	local minV, maxV = Vector3.new(math.huge, math.huge, math.huge), -Vector3.new(math.huge, math.huge, math.huge)
	for _, piece in ipairs(tool:GetChildren()) do
		if piece:IsA("BasePart") and piece.Name ~= "Handle" then
			for _, c in ipairs(piece:GetChildren()) do
				if c:IsA("WeldConstraint") or c:IsA("ParticleEmitter") or c:IsA("Light") then c:Destroy() end
			end
			piece.CFrame = pose * piece.CFrame
			local half = piece.Size / 2
			minV = minV:Min(piece.CFrame.Position - Vector3.new(half.Magnitude, half.Magnitude, half.Magnitude) * 0.6)
			maxV = maxV:Max(piece.CFrame.Position + Vector3.new(half.Magnitude, half.Magnitude, half.Magnitude) * 0.6)
			piece.Parent = model
		end
	end
	tool:Destroy()
	model.Parent = vp

	local center = (minV + maxV) / 2
	local extent = (maxV - minV).Magnitude
	local camera = Instance.new("Camera")
	camera.FieldOfView = 30
	camera.CFrame = CFrame.new(center + Vector3.new(0, 0, extent * 1.75), center)
	camera.Parent = vp
	vp.CurrentCamera = camera
	return vp
end

---------------------------------------------------------------------
-- MEME ICON: the meme's actual 3D model in a little viewport, on a tile in its rarity
-- color, with a rarity badge. (No emoji or pictures: what you see is the real object.)
---------------------------------------------------------------------
local ArtifactData, ArtifactModels -- loaded on first use

local function modelViewport(tile, artifact, radius)
	local viewport = Instance.new("ViewportFrame")
	viewport.Name = "Model3D"
	viewport.BackgroundTransparency = 1
	viewport.Size = UDim2.new(1, -6, 1, -6)
	viewport.Position = UDim2.fromScale(0.5, 0.5)
	viewport.AnchorPoint = Vector2.new(0.5, 0.5)
	viewport.Ambient = Color3.fromRGB(170, 170, 185)
	viewport.LightColor = Color3.fromRGB(255, 250, 240)
	viewport.LightDirection = Vector3.new(-0.6, -1, -0.8)
	viewport.Parent = tile
	UIKit.corner(viewport, math.max(radius - 3, 4))
	local ok, model = pcall(ArtifactModels.buildHeld, artifact, 4)
	if not ok or not model then return viewport end
	model:PivotTo(CFrame.new())
	model.Parent = viewport
	local half = math.max(model:GetAttribute("HalfHeight") or 2, (model:GetAttribute("Width") or 4) / 2)
	local camera = Instance.new("Camera")
	camera.FieldOfView = 30
	-- three-quarter front view (the front is -Z), slightly from above
	local turn, tilt, distance = math.rad(28), math.rad(12), half * 4.2
	local eye = Vector3.new(math.sin(turn) * math.cos(tilt), math.sin(tilt), -math.cos(turn) * math.cos(tilt)) * distance
	camera.CFrame = CFrame.lookAt(eye, Vector3.zero)
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	return viewport
end

function UIKit.artifactIcon(parent, artifact, props)
	props = props or {}
	ArtifactData = ArtifactData or require(ReplicatedStorage:WaitForChild("ArtifactData"))
	ArtifactModels = ArtifactModels or require(ReplicatedStorage:WaitForChild("ArtifactModels"))
	local rarity = ArtifactData.GetRarity(artifact.Rarity)
	local color = rarity and rarity.Color or C.Lilac
	local tile = UIKit.panel(parent, {
		Size = props.Size or UDim2.fromOffset(80, 80), Position = props.Position, AnchorPoint = props.AnchorPoint,
		Color = color:Lerp(C.White, 0.45), Radius = props.Radius or 16, Stroke = props.Stroke or 3, ShadeAmount = 0.25,
	})
	tile.Name = "ArtifactIcon"
	-- soft glow disc behind the model
	local glow = UIKit.panel(tile, {Size = UDim2.fromScale(0.78, 0.78), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
		Color = C.White, Radius = 999, Stroke = false, Shade = false})
	glow.BackgroundTransparency = 0.45
	modelViewport(tile, artifact, props.Radius or 16)
	-- rarity badge in the corner (the higher the rarity, the more it stands out)
	if props.Badge ~= false then
		local badge = UIKit.panel(tile, {Size = UDim2.fromScale(0.36, 0.26), Position = UDim2.new(1, 4, 0, -4), AnchorPoint = Vector2.new(1, 0),
			Color = color, Radius = 8, Stroke = 2, Shade = false})
		UIKit.label(badge, rarity and (rarity.Secret and "★" or rarity.Code) or "?", {Size = UDim2.fromScale(0.8, 0.8), Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2})
	end
	return tile
end

return UIKit
