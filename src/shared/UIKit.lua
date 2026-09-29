-- UIKit (ModuleScript in ReplicatedStorage)
-- One cartoony 2050 look for every screen in the game: chunky rounded panels with thick
-- outlines, bubbly FredokaOne text with an outline, bouncy buttons, pop-in windows and
-- live 3D shovel icons (ViewportFrames that render the real shovel model).

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIKit = {}

local rgb = Color3.fromRGB
UIKit.Colors = {
	Ink = rgb(38, 34, 84),        -- outlines and dark text
	Panel = rgb(250, 248, 255),   -- window background
	PanelTint = rgb(232, 226, 255),
	Row = rgb(238, 234, 252),
	Violet = rgb(122, 92, 232),
	Lilac = rgb(178, 158, 255),
	Sky = rgb(92, 176, 255),
	Mint = rgb(80, 214, 150),
	Sun = rgb(255, 200, 70),
	Coral = rgb(255, 110, 124),
	Grey = rgb(160, 160, 184),
	White = rgb(255, 255, 255),
	Money = rgb(90, 210, 110),
}
local C = UIKit.Colors
UIKit.Font = Enum.Font.FredokaOne

---------------------------------------------------------------------
-- BASICS
---------------------------------------------------------------------
function UIKit.screen(player, name, order)
	local gui = Instance.new("ScreenGui")
	gui.Name = name
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = order or 0
	gui.Parent = player:WaitForChild("PlayerGui")
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

-- soft top-to-bottom shading so flat panels look chunky
function UIKit.shade(parent, amount)
	local g = Instance.new("UIGradient")
	g.Rotation = 90
	g.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1 - (amount or 0.12), 1 - (amount or 0.12), 1 - (amount or 0.1)))
	g.Parent = parent
	return g
end

-- A plain rounded, outlined box. props: Size, Position, AnchorPoint, Color, Radius, Stroke
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
		UIKit.outline(f, props.Stroke or 3)
	end
	if props.Shade ~= false then
		UIKit.shade(f, props.ShadeAmount)
	end
	return f
end

-- Bubbly outlined text. props: Size, Position, AnchorPoint, Color, Align ("Left"/"Center"/"Right"),
-- Stroke (outline thickness, 0 for none), TextSize (fixed size instead of scaled)
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
	end
	l.TextXAlignment = Enum.TextXAlignment[props.Align or "Center"]
	l.TextYAlignment = Enum.TextYAlignment[props.VAlign or "Center"]
	l.RichText = props.RichText or false
	l.Parent = parent
	local strokeSize = props.Stroke == nil and 2 or props.Stroke
	if strokeSize > 0 then
		local s = Instance.new("UIStroke")
		s.Color = props.StrokeColor or C.Ink
		s.Thickness = strokeSize
		s.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
		s.Parent = l
	end
	return l
end

-- Chunky button that squishes when pressed and grows a bit on hover.
-- props: Size, Position, AnchorPoint, Color, TextColor
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
	UIKit.corner(b, props.Radius or 12)
	UIKit.outline(b, 3)
	UIKit.shade(b, 0.18)
	local label = UIKit.label(b, text, {
		Size = UDim2.new(1, -14, 1, -12), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
		Color = props.TextColor or C.White,
	})
	label.Name = "Label"
	local scale = Instance.new("UIScale")
	scale.Parent = b
	local function to(v, t)
		TweenService:Create(scale, TweenInfo.new(t or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = v}):Play()
	end
	b.MouseEnter:Connect(function() to(1.05) end)
	b.MouseLeave:Connect(function() to(1) end)
	b.MouseButton1Down:Connect(function() to(0.92, 0.06) end)
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
	local scale = frame:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	scale.Parent = frame
	scale.Scale = from or 0.6
	TweenService:Create(scale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
end

---------------------------------------------------------------------
-- WINDOW: a big panel with a colored title tab and a round close button
-- returns window, content (frame to put things in), closeButton
---------------------------------------------------------------------
function UIKit.window(gui, title, size, accent)
	local window = UIKit.panel(gui, {
		Size = size, Position = UDim2.fromScale(0.5, 0.52), AnchorPoint = Vector2.new(0.5, 0.5),
		Color = C.Panel, Radius = 22, Stroke = 4,
	})
	window.Visible = false
	local sizeLimit = Instance.new("UISizeConstraint")
	sizeLimit.MaxSize = Vector2.new(size.X.Offset, size.Y.Offset)
	sizeLimit.Parent = window
	local aspect = Instance.new("UIAspectRatioConstraint")
	aspect.AspectRatio = size.X.Offset / size.Y.Offset
	aspect.Parent = window
	window.Size = UDim2.fromScale(0.92, 0.85)

	local tab = UIKit.panel(window, {
		Size = UDim2.new(0.5, 0, 0, 52), Position = UDim2.new(0.5, 0, 0, -20), AnchorPoint = Vector2.new(0.5, 0),
		Color = accent or C.Violet, Radius = 16, Stroke = 4,
	})
	UIKit.label(tab, title, {Size = UDim2.new(1, -20, 1, -12), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 3})

	local close = UIKit.button(window, "X", {
		Size = UDim2.fromOffset(46, 46), Position = UDim2.new(1, 14, 0, -14), AnchorPoint = Vector2.new(1, 0), Color = C.Coral, Radius = 23,
	})
	close.MouseButton1Click:Connect(function()
		window.Visible = false
	end)

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundTransparency = 1
	content.Size = UDim2.new(1, -36, 1, -64)
	content.Position = UDim2.new(0, 18, 0, 46)
	content.Parent = window
	return window, content, close
end

function UIKit.open(window)
	window.Visible = true
	UIKit.pop(window)
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
	UIKit.label(row, name, {Size = UDim2.new(0.26, 0, 1, 0), Align = "Left", Color = C.Ink, Stroke = 0})
	local track = UIKit.panel(row, {Size = UDim2.new(0.46, 0, 0.7, 0), Position = UDim2.new(0.27, 0, 0.15, 0), Color = rgb(222, 218, 240), Radius = 8, Stroke = 2, Shade = false})
	local fill = UIKit.panel(track, {Size = UDim2.new(math.clamp(fraction, 0.04, 1), 0, 1, 0), Color = color, Radius = 8, Stroke = false})
	fill.Name = "Fill"
	UIKit.label(row, valueText, {Size = UDim2.new(0.25, 0, 1, 0), Position = UDim2.new(0.75, 0, 0, 0), Align = "Right", Color = C.Ink, Stroke = 0})
	return row
end

---------------------------------------------------------------------
-- 3D SHOVEL ICON: renders the real shovel model inside a ViewportFrame
---------------------------------------------------------------------
local ShovelModels -- loaded on first use (only needed where icons are drawn)
function UIKit.shovelIcon(parent, def, props)
	props = props or {}
	ShovelModels = ShovelModels or require(ReplicatedStorage:WaitForChild("ShovelModels"))
	local vp = Instance.new("ViewportFrame")
	vp.Size = props.Size or UDim2.fromOffset(80, 80)
	vp.Position = props.Position or UDim2.new()
	vp.AnchorPoint = props.AnchorPoint or Vector2.zero
	vp.BackgroundTransparency = 1
	vp.Ambient = rgb(200, 198, 215)
	vp.LightColor = rgb(255, 250, 240)
	vp.LightDirection = Vector3.new(-1, -1.5, -1)
	vp.Parent = parent

	-- lay the shovel diagonally: blade at the bottom-left, grip at the top-right
	local tool = ShovelModels(def)
	local model = Instance.new("Model")
	local pose = CFrame.Angles(0, math.rad(20), 0) * CFrame.Angles(0, 0, math.rad(135)) * CFrame.Angles(math.rad(90), 0, 0)
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

return UIKit
