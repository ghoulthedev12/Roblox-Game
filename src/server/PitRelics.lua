-- PitRelics (ModuleScript in ServerScriptService)
-- Fills the dig site's dirt work yard (World 1) with the story of the game: giant relics of the
-- old internet, half buried in the dirt, each in its own little excavation plot (stakes,
-- caution tape, a dirt mound, an exhibit plaque), with crates, barrels and survey gear between
-- them. PitRelics(builder, world): builder = an Architecture builder placed at the pit center.
--   CRT monitor (404 on its cracked screen) · floppy disk · corded mouse · keyboard keys ·
--   a giant mouse cursor · an old phone stuck on "loading"

local Architecture = require(script.Parent:WaitForChild("Architecture"))

local rgb = Color3.fromRGB
local BEIGE = {Color = rgb(226, 214, 186)}
local BEIGE_DARK = {Color = rgb(190, 178, 150)}
local DIRT = {Color = rgb(150, 106, 70), Material = Enum.Material.Ground}
local DIRT_DARK = {Color = rgb(118, 82, 54), Material = Enum.Material.Ground}
local SCREEN = {Color = rgb(24, 30, 46)}

local RELIC_RADIUS = 104 -- where the relics stand (between the inner props and the yard's curb)
local RELIC_SCALE = 1.8   -- how much bigger than built the relics (and their plots) are

local function at(angleDeg, radius, y)
	local a = math.rad(angleDeg)
	local pos = Vector3.new(math.cos(a) * radius, y or 0, math.sin(a) * radius)
	-- facing the pit
	return CFrame.lookAt(pos, Vector3.new(0, pos.Y, 0))
end

-- a dirt mound around a half-buried relic
local function mound(b, cf, width)
	for k = 0, 5 do
		local a = k / 6 * math.pi * 2
		b:ellipsoid("RelicMound", Vector3.new(width * 0.55, 1.6, width * 0.45),
			cf * CFrame.new(math.cos(a) * width * 0.38, 0.1, math.sin(a) * width * 0.38) * CFrame.Angles(0, a, 0), "White", k % 2 == 0 and DIRT or DIRT_DARK)
	end
end

-- the excavation plot: four stakes, caution tape between them, and an exhibit plaque in front
local function plot(b, cf, size, title, subtitle)
	local h = size / 2
	local corners = {Vector3.new(-h, 0, -h), Vector3.new(h, 0, -h), Vector3.new(h, 0, h), Vector3.new(-h, 0, h)}
	for i, c in ipairs(corners) do
		b:box("PlotStake", Vector3.new(0.35, 2.6, 0.35), cf * CFrame.new(c + Vector3.new(0, 1.3, 0)), "White", {Color = rgb(170, 120, 70)})
		b:box("PlotStakeTop", Vector3.new(0.5, 0.5, 0.5), cf * CFrame.new(c + Vector3.new(0, 2.7, 0)), "Coral")
		local nxt = corners[i % 4 + 1]
		local from, to = cf * (c + Vector3.new(0, 2.2, 0)), cf * (nxt + Vector3.new(0, 2.2, 0))
		local stripes = 8
		for s = 0, stripes - 1 do
			local p0 = from:Lerp(to, s / stripes)
			local p1 = from:Lerp(to, (s + 1) / stripes)
			b:box("CautionTape", Vector3.new(0.08, 0.32, (p1 - p0).Magnitude), CFrame.lookAt((p0 + p1) / 2, p1), s % 2 == 0 and "Sun" or "Ink")
		end
	end
	-- plaque on a little post at the front (the side facing the pit)
	local plaqueCF = cf * CFrame.new(0, 0, -h - 1.4)
	b:box("PlaquePost", Vector3.new(0.3, 2.2, 0.3), plaqueCF * CFrame.new(0, 1.1, 0), "Chrome")
	local plaque = b:box("Plaque", Vector3.new(4.4, 1.7, 0.25), plaqueCF * CFrame.new(0, 2.6, 0) * CFrame.Angles(math.rad(-15), 0, 0), "Navy")
	Architecture.sign(plaque, title, subtitle, Enum.NormalId.Front)
end

local function crt(b, cf)
	-- a chunky beige CRT monitor, tipped back and sunk into the dirt, cracked 404 on the screen
	local tilt = cf * CFrame.new(0, 2.2, 0) * CFrame.Angles(math.rad(14), 0, math.rad(6))
	b:box("CRTBody", Vector3.new(10, 8.4, 6), tilt, "White", BEIGE)
	b:box("CRTBack", Vector3.new(7.2, 6.4, 4.4), tilt * CFrame.new(0, -0.4, 4.6), "White", BEIGE_DARK)
	b:box("CRTBezel", Vector3.new(8.6, 7, 0.4), tilt * CFrame.new(0, 0.3, -3.05), "White", BEIGE_DARK)
	local screen = b:box("CRTScreen", Vector3.new(7.4, 5.8, 0.3), tilt * CFrame.new(0, 0.4, -3.2), "White", SCREEN)
	Architecture.sign(screen, "404", "PAGE NOT FOUND", Enum.NormalId.Front, rgb(120, 255, 170))
	for k, crack in ipairs({{-1.6, 1.2, 35}, {-0.9, 0.4, -20}, {0.4, 1.6, 60}}) do
		b:box("CRTCrack", Vector3.new(2.2 - k * 0.3, 0.1, 0.05), tilt * CFrame.new(crack[1], crack[2], -3.37) * CFrame.Angles(0, 0, math.rad(crack[3])), "White")
	end
	b:disc("CRTButton", 0.5, 0.2, tilt * CFrame.new(3.4, -3.0, -3.25) * CFrame.Angles(0, math.rad(90), 0), "GlowMint")
	mound(b, cf, 13)
end

local function floppy(b, cf)
	-- a giant floppy disk driven into the ground at an angle
	local tilt = cf * CFrame.new(0, 3.6, 0) * CFrame.Angles(math.rad(-10), 0, math.rad(22))
	b:box("FloppyBody", Vector3.new(9, 9, 0.8), tilt, "Navy")
	b:box("FloppyShutter", Vector3.new(4.2, 2.8, 0.9), tilt * CFrame.new(0.4, 3.0, 0), "Chrome")
	b:box("FloppyShutterSlot", Vector3.new(1.2, 2, 0.95), tilt * CFrame.new(1.2, 3.1, 0), "Ink")
	local label = b:box("FloppyLabel", Vector3.new(6.6, 4, 0.88), tilt * CFrame.new(0, -1.6, 0), "White")
	Architecture.sign(label, "MEMES_1999", "DO NOT DELETE", Enum.NormalId.Front, rgb(60, 70, 160))
	Architecture.sign(label, "MEMES_1999", "DO NOT DELETE", Enum.NormalId.Back, rgb(60, 70, 160))
	b:box("FloppyNotch", Vector3.new(0.8, 0.8, 0.9), tilt * CFrame.new(-4.1, 4.1, 0), "White", DIRT)
	mound(b, cf, 10)
end

local function mouse(b, cf)
	-- a giant corded mouse, nose down in the dirt, its cable snaking off into the ground
	local body = cf * CFrame.new(0, 1.6, 0) * CFrame.Angles(math.rad(-12), math.rad(20), 0)
	b:ellipsoid("MouseBody", Vector3.new(5.4, 3.4, 8.4), body, "White", BEIGE)
	b:box("MouseSplit", Vector3.new(0.12, 0.4, 3.6), body * CFrame.new(0, 1.55, -2.2), "Ink")
	b:box("MouseSeam", Vector3.new(5.0, 0.4, 0.12), body * CFrame.new(0, 1.4, -0.4), "Ink")
	b:disc("MouseWheel", 1.2, 0.5, body * CFrame.new(0, 1.7, -2.2) * CFrame.Angles(0, 0, math.rad(90)), "Ink")
	local p = body * CFrame.new(0, 0, -4.2)
	local points = {p.Position}
	for k = 1, 7 do
		points[k + 1] = (cf * CFrame.new(math.sin(k * 0.9) * 2.4, math.max(0.3, 1.2 - k * 0.15), -4.5 - k * 2.2)).Position
	end
	for k = 1, #points - 1 do
		b:pill("MouseCable", points[k], points[k + 1], 0.55, "Ink")
	end
	mound(b, cf, 9)
end

local function keys(b, cf)
	-- giant keyboard keys tumbled out of the dirt: Q W E R T Y
	local letters = {"Q", "W", "E", "R", "T", "Y"}
	for i, letter in ipairs(letters) do
		local x = (i - 3.5) * 3.4
		local key = cf * CFrame.new(x, 1.2 + (i % 2) * 0.4, (i % 3 - 1) * 1.6) * CFrame.Angles(math.rad((i % 3 - 1) * 14), math.rad(i * 23), math.rad((i % 2) * 18 - 9))
		b:box("KeyBase", Vector3.new(3, 1.6, 3), key, "White", BEIGE_DARK)
		local cap = b:box("KeyCap", Vector3.new(2.4, 0.5, 2.4), key * CFrame.new(0, 1.0, 0), "White", BEIGE)
		Architecture.sign(cap, letter, nil, Enum.NormalId.Top, rgb(40, 40, 60))
	end
	mound(b, cf, 14)
end

local function cursor(b, cf)
	-- a giant white mouse-cursor arrow stabbed into the ground, outlined in black
	local tilt = cf * CFrame.new(0, 4.6, 0) * CFrame.Angles(0, math.rad(15), math.rad(-25))
	for _, layer in ipairs({{"Ink", 0.9, 0}, {"White", 0.7, -0.15}}) do
		local grow = layer[2] == 0.9 and 0.5 or 0
		b:box("CursorStem", Vector3.new(1.6 + grow, 5 + grow, layer[2]), tilt * CFrame.new(0.3, -2.0, layer[3]) * CFrame.Angles(0, 0, math.rad(-18)), layer[1])
		b:box("CursorHead", Vector3.new(4.6 + grow, 4.6 + grow, layer[2]), tilt * CFrame.new(0, 2.0, layer[3]) * CFrame.Angles(0, 0, math.rad(45)), layer[1])
	end
	b:bulb("CursorGlow", 0.6, tilt * CFrame.new(0, 4.6, 0), "GlowCyan", 10)
	mound(b, cf, 9)
end

local function phone(b, cf)
	-- an old brick of a phone stuck on LOADING, antenna up
	local tilt = cf * CFrame.new(0, 4.2, 0) * CFrame.Angles(math.rad(12), 0, math.rad(-10))
	b:box("PhoneBody", Vector3.new(4.6, 9.4, 2), tilt, "Ink")
	b:box("PhoneFace", Vector3.new(4.0, 8.8, 0.2), tilt * CFrame.new(0, 0, -1.0), "Navy")
	local screen = b:box("PhoneScreen", Vector3.new(3.2, 2.6, 0.22), tilt * CFrame.new(0, 2.6, -1.05), "White", {Color = rgb(150, 220, 140)})
	Architecture.sign(screen, "LOADING", "...", Enum.NormalId.Front, rgb(30, 70, 40))
	for row = 0, 3 do
		for col = -1, 1 do
			b:box("PhoneKey", Vector3.new(0.8, 0.5, 0.25), tilt * CFrame.new(col * 1.05, -0.4 - row * 0.8, -1.08), "Cloud")
		end
	end
	b:rod("PhoneAntenna", 3, 0.4, tilt * CFrame.new(1.5, 6.1, 0) * CFrame.Angles(0, 0, math.rad(90)), "Ink")
	b:ball("PhoneAntennaTip", 0.6, tilt * CFrame.new(1.5, 7.6, 0), "Coral")
	mound(b, cf, 8)
end

-- crates, barrels and a pallet of bricks, stacked like an active dig's supplies
local function supplies(b, cf)
	for i, spot in ipairs({{-1.7, 0, 0}, {1.7, 0, 0.3}, {0, 3.2, 0.1}}) do
		local crate = cf * CFrame.new(spot[1], 1.6 + spot[2], spot[3]) * CFrame.Angles(0, math.rad(i * 9), 0)
		b:box("Crate", Vector3.new(3.2, 3.2, 3.2), crate, "White", {Color = rgb(196, 146, 92)})
		for _, y in ipairs({-1.3, 1.3}) do
			b:box("CrateBand", Vector3.new(3.3, 0.4, 3.3), crate * CFrame.new(0, y, 0), "White", {Color = rgb(140, 96, 56)})
		end
	end
	for i, x in ipairs({4.6, 6.4}) do
		local barrel = cf * CFrame.new(x, 1.5, (i - 1.5) * 1.8)
		b:disc("Barrel", 2.2, 3, barrel, i == 1 and "Coral" or "Sky")
		b:disc("BarrelBand", 2.3, 0.3, barrel * CFrame.new(0, 0.7, 0), "Ink")
		b:disc("BarrelBand", 2.3, 0.3, barrel * CFrame.new(0, -0.7, 0), "Ink")
	end
end

-- a survey tripod with a little glowing laser level on top
local function tripod(b, cf)
	local top = cf * CFrame.new(0, 3.6, 0)
	for k = 0, 2 do
		local a = k / 3 * math.pi * 2
		local foot = cf * CFrame.new(math.cos(a) * 1.4, 0, math.sin(a) * 1.4)
		b:pill("TripodLeg", top.Position, foot.Position, 0.22, "Chrome")
	end
	b:box("LaserLevel", Vector3.new(1.2, 0.8, 0.8), top * CFrame.new(0, 0.4, 0), "Sun")
	b:bulb("LaserDot", 0.35, top * CFrame.new(0, 0.4, -0.5), "GlowPink", 6)
end

return function(b, world)
	local relics = {
		{90, crt, 15, "EXHIBIT 01", "CRT MONITOR  ·  c. 2003"},
		{150, floppy, 12, "EXHIBIT 02", "FLOPPY DISK  ·  c. 1999"},
		{-150, mouse, 12, "EXHIBIT 03", "CORDED MOUSE  ·  c. 2005"},
		{-90, keys, 16, "EXHIBIT 04", "KEYBOARD KEYS  ·  c. 2010"},
		{-30, cursor, 11, "EXHIBIT 05", "THE CURSOR  ·  c. 1995"},
		{30, phone, 10, "EXHIBIT 06", "OLD PHONE  ·  c. 2004"},
	}
	-- each group is built as its own model at normal size and then scaled up around its spot,
	-- so the relics read as big landmarks across the yard
	local function group(name, cf, scale, build)
		local model = Instance.new("Model")
		model.Name = name
		model.Parent = b.Parent
		build(Architecture.builder(model, b.Base), cf)
		model.WorldPivot = b.Base * cf
		if scale ~= 1 then model:ScaleTo(scale) end
		return model
	end
	for _, relic in ipairs(relics) do
		local cf = at(relic[1], RELIC_RADIUS + (relic[1] == 30 and 4 or 0))
		group("Relic", cf, RELIC_SCALE, function(rb, spot)
			relic[2](rb, spot)
			plot(rb, spot, relic[3], relic[4], relic[5])
		end)
		group("Supplies", at(relic[1] + 15, RELIC_RADIUS + 8), 1.3, supplies)
		group("Survey", at(relic[1] - 14, RELIC_RADIUS - 6), 1.3, tripod)
	end
end
