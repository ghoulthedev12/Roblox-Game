-- TutorialSign (ModuleScript in ServerScriptService)
-- A futuristic 2050 "HOW TO DIG" sign: a hover pedestal, two glowing pylons joined by a neon
-- arch, and a hologram projector. The steps float inside the frame on a BillboardGui:
--   1. Equip Pickaxe -> 2. Jump into Pit -> 3. Dig Up Framed Artifacts -> 4. Display in Museum
-- MuseumBuilder puts one on every museum's plaza, next to the spawn, facing the main pit.
-- Usage: TutorialSign(parent, cframe)  (cframe on the ground, -Z = the side people read from)

local Architecture = require(script.Parent:WaitForChild("Architecture"))

local rgb = Color3.fromRGB
local CYAN = rgb(110, 230, 255)
local STEPS = {
	{"⛏", "Equip Pickaxe", rgb(255, 206, 84)},
	{"🕳", "Jump into Pit", rgb(96, 226, 190)},
	{"🖼", "Dig Up Framed Artifacts", rgb(255, 150, 200)},
	{"🏛", "Display in Museum", rgb(178, 158, 255)},
}

local WIDTH, HEIGHT = 12, 11.5 -- the hologram's size in studs
local SCREEN_Y = 8.2           -- its center, above the ground

local function corner(parent, scale)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(scale, 0)
	c.Parent = parent
end

local function text(parent, value, props)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text = value
	l.TextScaled = true
	l.Font = props.Font or Enum.Font.GothamBlack
	l.TextColor3 = props.Color or Color3.new(1, 1, 1)
	l.TextXAlignment = props.Align or Enum.TextXAlignment.Center
	l.Size = props.Size
	l.Position = props.Position or UDim2.new()
	l.AnchorPoint = props.AnchorPoint or Vector2.zero
	l.Parent = parent
	if props.Stroke then
		local s = Instance.new("UIStroke")
		s.Thickness = props.Stroke
		s.Color = rgb(20, 22, 50)
		s.Parent = l
	end
	return l
end

local function hologram(anchor)
	local gui = Instance.new("BillboardGui")
	gui.Name = "TutorialBoard"
	gui.Adornee = anchor
	gui.Size = UDim2.fromScale(WIDTH, HEIGHT) -- in studs, so it scales with distance like a real sign
	gui.LightInfluence = 0
	gui.MaxDistance = 160
	gui.AlwaysOnTop = false
	gui.ResetOnSpawn = false
	gui.Parent = anchor

	local panel = Instance.new("Frame")
	panel.Size = UDim2.fromScale(1, 1)
	panel.BackgroundColor3 = rgb(16, 20, 48)
	panel.BackgroundTransparency = 0.18
	panel.Parent = gui
	corner(panel, 0.06)
	local edge = Instance.new("UIStroke")
	edge.Thickness = 3
	edge.Color = CYAN
	edge.Transparency = 0.1
	edge.Parent = panel
	local sheen = Instance.new("UIGradient")
	sheen.Rotation = 90
	sheen.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 0.12), NumberSequenceKeypoint.new(1, 0.3),
	})
	sheen.Parent = panel

	text(panel, "HOW TO DIG", {Size = UDim2.fromScale(0.86, 0.12), Position = UDim2.fromScale(0.5, 0.035), AnchorPoint = Vector2.new(0.5, 0),
		Color = rgb(255, 222, 110), Stroke = 2})
	local line = Instance.new("Frame")
	line.BorderSizePixel = 0
	line.BackgroundColor3 = CYAN
	line.Size = UDim2.fromScale(0.7, 0.008)
	line.Position = UDim2.fromScale(0.5, 0.165)
	line.AnchorPoint = Vector2.new(0.5, 0)
	line.Parent = panel

	local ROW_H, GAP, TOP = 0.15, 0.052, 0.2
	for i, step in ipairs(STEPS) do
		local y = TOP + (i - 1) * (ROW_H + GAP)
		local row = Instance.new("Frame")
		row.Size = UDim2.fromScale(0.9, ROW_H)
		row.Position = UDim2.fromScale(0.05, y)
		row.BackgroundColor3 = step[3]
		row.BackgroundTransparency = 0.78
		row.Parent = panel
		corner(row, 0.3)
		local rowEdge = Instance.new("UIStroke")
		rowEdge.Thickness = 2
		rowEdge.Color = step[3]
		rowEdge.Parent = row

		local badge = Instance.new("Frame")
		badge.Size = UDim2.fromScale(0.16, 0.86)
		badge.Position = UDim2.fromScale(0.02, 0.5)
		badge.AnchorPoint = Vector2.new(0, 0.5)
		badge.BackgroundColor3 = step[3]
		badge.Parent = row
		corner(badge, 0.5)
		text(badge, tostring(i), {Size = UDim2.fromScale(0.7, 0.7), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
			Color = rgb(24, 26, 60)})
		text(row, step[1], {Size = UDim2.fromScale(0.13, 0.8), Position = UDim2.fromScale(0.2, 0.5), AnchorPoint = Vector2.new(0, 0.5), Font = Enum.Font.GothamBold})
		text(row, step[2], {Size = UDim2.fromScale(0.62, 0.56), Position = UDim2.fromScale(0.35, 0.5), AnchorPoint = Vector2.new(0, 0.5),
			Align = Enum.TextXAlignment.Left, Stroke = 1.5})

		-- a glowing arrow down to the next step
		if i < #STEPS then
			text(panel, "▼", {Size = UDim2.fromScale(0.1, GAP * 0.9), Position = UDim2.fromScale(0.5, y + ROW_H + GAP * 0.05), AnchorPoint = Vector2.new(0.5, 0),
				Color = CYAN, Font = Enum.Font.GothamBold})
		end
	end
	return gui
end

return function(parent, cf)
	local sign = Instance.new("Model")
	sign.Name = "TutorialSign"
	sign.Parent = parent
	local b = Architecture.builder(sign, cf)
	local half = WIDTH / 2 + 0.9

	-- hover pedestal with a glowing seam
	b:tiers("SignBase", CFrame.new(), {{WIDTH + 5, 0.5, "Violet"}, {WIDTH + 3.8, 0.25, "GlowCyan"}, {WIDTH + 3, 0.7, "White"}})
	-- hologram projector bar along the front of the pedestal
	b:rod("Projector", WIDTH, 0.9, CFrame.new(0, 1.9, 0), "Ink")
	b:rod("ProjectorLens", WIDTH - 1, 0.5, CFrame.new(0, 2.3, 0), "GlowCyan")
	-- two slim pylons with neon strips on their faces
	for _, x in ipairs({-half, half}) do
		b:roundedBlock("Pylon", Vector3.new(1.6, SCREEN_Y + HEIGHT / 2 - 0.6, 1.6), CFrame.new(x, (SCREEN_Y + HEIGHT / 2 + 0.4) / 2 + 0.7, 0), 0.5, "Ink")
		b:box("PylonGlow", Vector3.new(0.3, SCREEN_Y + HEIGHT / 2 - 2.5, 0.2), CFrame.new(x, (SCREEN_Y + HEIGHT / 2) / 2 + 1.2, -0.82), "GlowCyan")
		b:bulb("PylonCap", 1.3, CFrame.new(x, SCREEN_Y + HEIGHT / 2 + 0.9, 0), "GlowSun", 8)
	end
	-- neon arch over the top
	b:ring("SignArch", CFrame.new(0, SCREEN_Y + HEIGHT / 2 + 0.6, 0), half, 0.9, "White", 18, 180, 0)
	b:ring("SignArchGlow", CFrame.new(0, SCREEN_Y + HEIGHT / 2 + 0.6, -0.5), half - 0.2, 0.35, "GlowCyan", 18, 180, 0)
	b:bulb("ArchGem", 1.6, CFrame.new(0, SCREEN_Y + HEIGHT / 2 + 0.6 + half, 0), "GlowPink", 10)

	-- the hologram itself floats between the pylons
	local anchor = b:box("HologramAnchor", Vector3.new(1, 1, 1), CFrame.new(0, SCREEN_Y, 0), "White",
		{Transparency = 1, CanCollide = false, CanQuery = false, CanTouch = false})
	hologram(anchor)
	-- a soft beam up from the projector, and drifting sparkles
	local beam = b:box("HoloBeam", Vector3.new(WIDTH - 0.6, HEIGHT - 1, 0.1), CFrame.new(0, SCREEN_Y - 0.2, 0.3), "GlowCyan",
		{Transparency = 0.93, CanCollide = false, CanQuery = false, CanTouch = false})
	local sparkles = Instance.new("ParticleEmitter")
	sparkles.Color = ColorSequence.new(CYAN)
	sparkles.LightEmission = 0.8
	sparkles.Size = NumberSequence.new(0.18, 0)
	sparkles.Transparency = NumberSequence.new(0.2, 1)
	sparkles.Lifetime = NumberRange.new(1.5, 2.5)
	sparkles.Rate = 6
	sparkles.Speed = NumberRange.new(0.5, 1.2)
	sparkles.EmissionDirection = Enum.NormalId.Top
	sparkles.SpreadAngle = Vector2.new(10, 10)
	sparkles.Parent = beam

	for _, d in ipairs(sign:GetDescendants()) do
		if d:IsA("BasePart") and (d.Name:find("Glow") or d.Name:find("Lens") or d.Name:find("Arch")) then
			d.CanCollide = false
		end
	end
	return sign
end
