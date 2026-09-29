-- ShopBuilder (ModuleScript in ServerScriptService)
-- Builds a world's Shovel Shop: a cartoony 2050 pavilion on a round tiered platform,
-- with a flying-saucer roof held up by chunky capsule pillars, a curved back wall,
-- glass display capsules on stepped pedestals (one shovel per depth zone), a floating
-- robot shopkeeper, a big glowing sign with a giant shovel, and a depth meter.
-- DigManager calls this once per world on server start.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local ShovelModels = require(ReplicatedStorage:WaitForChild("ShovelModels"))
local Architecture = require(script.Parent:WaitForChild("Architecture"))

-- Places a copy of a shovel model at `target` (blade down), scaled up
local function displayShovel(parent, def, target, scale)
	local tool = ShovelModels(def)
	local handle = tool:FindFirstChild("Handle")
	local display = Instance.new("Model")
	display.Name = "Display_" .. def.Id
	for _, piece in ipairs(tool:GetChildren()) do
		if piece:IsA("BasePart") and piece ~= handle then
			local rel = handle.CFrame:ToObjectSpace(piece.CFrame)
			piece.Size = piece.Size * scale
			piece.CFrame = target * CFrame.new(rel.Position * scale) * rel.Rotation
			piece.Anchored = true
			piece.CanCollide = false
			for _, c in ipairs(piece:GetChildren()) do
				if c:IsA("WeldConstraint") then c:Destroy() end
			end
			piece.Parent = display
		end
	end
	tool:Destroy()
	display.Parent = parent
	return display
end

-- a point on a circle around the shop center (0 degrees = straight back, +X to the right)
local function around(deg, radius, y)
	local a = math.rad(deg)
	return Vector3.new(math.sin(a) * radius, y, math.cos(a) * radius)
end

-- parent: where the shop goes. world: a GameConfig world. base: the shop's CFrame
-- (its front, local -Z, faces the pit).
return function(parent, world, base)
	local shop = Instance.new("Model")
	shop.Name = "ShovelShop"
	local b = Architecture.builder(shop, base)

	-----------------------------------------------------------------
	-- ROUND TIERED PLATFORM with a glowing lip
	-----------------------------------------------------------------
	b:disc("PlatformLip", 30, 0.5, CFrame.new(0, 0.25, 0), "Sky")
	b:disc("PlatformGlow", 29.2, 0.3, CFrame.new(0, 0.62, 0), "GlowCyan")
	b:disc("Platform", 28.4, 0.7, CFrame.new(0, 0.85, 0), "White")
	b:disc("PlatformInner", 22, 0.3, CFrame.new(0, 1.35, 0), "Cloud")
	b:disc("FloorStar", 9, 0.06, CFrame.new(0, 1.52, -2.5), "Lilac")
	b:disc("FloorStarCore", 5, 0.08, CFrame.new(0, 1.54, -2.5), "White")
	-- chunky front steps
	b:roundedBlock("StepLow", Vector3.new(10, 0.5, 3), CFrame.new(0, 0.25, -14.6), 1.4, "Cloud")

	-----------------------------------------------------------------
	-- CURVED BACK WALL: rounded panels with porthole windows
	-----------------------------------------------------------------
	for i, deg in ipairs({-72, -36, 0, 36, 72}) do
		local p = around(deg, 11.2, 7)
		local cf = CFrame.lookAt(p, Vector3.new(0, 7, 0))
		b:roundedBlock("WallPanel", Vector3.new(7.4, 11, 1.4), cf, 0.7, i % 2 == 1 and "White" or "Cloud")
		b:ball("WallTop", 1.6, cf * CFrame.new(0, 5.9, 0), "Lilac")
		-- porthole: glass disc in a lilac frame
		b:rod("PortholeRim", 0.4, 3.6, cf * CFrame.new(0, 1.2, -0.6) * CFrame.Angles(0, math.rad(90), 0), "Lilac")
		b:rod("Porthole", 0.5, 2.8, cf * CFrame.new(0, 1.2, -0.65) * CFrame.Angles(0, math.rad(90), 0), "Glass")
		b:box("WallStripe", Vector3.new(6.6, 0.35, 0.2), cf * CFrame.new(0, -3.5, -0.75), "GlowPink")
	end

	-----------------------------------------------------------------
	-- CAPSULE PILLARS holding up the saucer roof
	-----------------------------------------------------------------
	for _, deg in ipairs({-140, 140}) do
		local p = around(deg, 12.6, 0)
		b:pill("Pillar", p + Vector3.new(0, 2.2, 0), p + Vector3.new(0, 13.2, 0), 1.9, "Lilac")
		b:disc("PillarFoot", 3.4, 0.9, CFrame.new(p + Vector3.new(0, 1.65, 0)), "Violet")
		b:disc("PillarBand", 2.3, 0.35, CFrame.new(p + Vector3.new(0, 9, 0)), "GlowSun")
	end

	-----------------------------------------------------------------
	-- FLYING-SAUCER ROOF: disc rim with bulbs, a glass bubble dome on top
	-----------------------------------------------------------------
	b:ellipsoid("SaucerUnder", Vector3.new(30, 3.2, 30), CFrame.new(0, 13.9, 0), "Sky")
	b:disc("SaucerRim", 31, 1.1, CFrame.new(0, 14.6, 0), "Sky")
	b:disc("SaucerRimGlow", 31.4, 0.3, CFrame.new(0, 14.1, 0), "GlowCyan")
	b:ellipsoid("SaucerTop", Vector3.new(29, 4, 29), CFrame.new(0, 15.1, 0), "White")
	for i = 0, 15 do
		local p = around(i * 22.5, 15.4, 14.6)
		b:bulb("RimBulb", 0.8, CFrame.new(p), i % 2 == 0 and "GlowSun" or "GlowPink", 6)
	end
	b:ellipsoid("Bubble", Vector3.new(13, 9, 13), CFrame.new(0, 17, 1.5), "Glass")
	b:disc("BubbleRing", 13.6, 0.5, CFrame.new(0, 17.1, 1.5), "Lilac")
	b:ball("Beacon", 1.5, CFrame.new(0, 21.6, 1.5), "GlowPink")
	b:rod("BeaconStem", 1.2, 0.3, CFrame.new(0, 21, 1.5) * CFrame.Angles(0, 0, math.rad(90)), "Chrome")
	-- ceiling light under the saucer
	local ceiling = b:disc("CeilingLight", 8, 0.2, CFrame.new(0, 12.25, 0), "GlowCyan")
	local light = Instance.new("PointLight")
	light.Color = Architecture.LightColor
	light.Range = 22
	light.Brightness = 1.2
	light.Parent = ceiling

	-----------------------------------------------------------------
	-- BIG SIGN on top, with a giant shovel leaning on it
	-----------------------------------------------------------------
	b:pill("SignPost", Vector3.new(-5, 16.5, -6), Vector3.new(-5, 19.5, -6), 0.7, "Chrome")
	b:pill("SignPost", Vector3.new(5, 16.5, -6), Vector3.new(5, 19.5, -6), 0.7, "Chrome")
	b:roundedBlock("SignBack", Vector3.new(19, 5.2, 1.2), CFrame.new(0, 21.8, -6), 2.2, "Violet")
	local sign = b:roundedBlock("Sign", Vector3.new(18, 4.4, 1.4), CFrame.new(0, 21.8, -6.1), 1.9, "Navy")
	Architecture.sign(sign, "SHOVEL SHOP", "DIG DEEPER, FIND WEIRDER!")
	b:box("SignGlow", Vector3.new(18.4, 0.3, 1.5), CFrame.new(0, 19.35, -6.1), "GlowSun")
	-- a giant cartoon shovel leaning against the sign
	local grip = Vector3.new(8, 26, -4.6)
	local tip = Vector3.new(11.4, 17.2, -4.6)
	local dir = (tip - grip).Unit
	b:pill("GiantHandle", grip, tip - dir * 3.4, 0.9, "Violet")
	b:rod("GiantGrip", 2.4, 0.7, Architecture.alongX(grip, dir:Cross(Vector3.zAxis)), "Sun")
	b:ball("GiantGripEndA", 0.9, CFrame.new(grip + dir:Cross(Vector3.zAxis).Unit * 1.2), "Sun")
	b:ball("GiantGripEndB", 0.9, CFrame.new(grip - dir:Cross(Vector3.zAxis).Unit * 1.2), "Sun")
	local bladeCF = Architecture.alongX(tip - dir * 1.6, dir)
	b:ellipsoid("GiantBlade", Vector3.new(4.4, 3.4, 0.7), bladeCF, "Sun")
	b:ellipsoid("GiantBladeShine", Vector3.new(2.6, 1.4, 0.75), bladeCF * CFrame.new(-0.6, 0.5, 0), "White")
	b:rod("GiantCollar", 0.8, 1.2, Architecture.alongX(tip - dir * 3.5, dir), "Chrome")

	-----------------------------------------------------------------
	-- COUNTER (rounded, two-tone) with the shop prompt
	-----------------------------------------------------------------
	local counter = b:roundedBlock("Counter", Vector3.new(10, 3, 2.8), CFrame.new(0, 3, -4.2), 1.3, "Sky")
	b:roundedBlock("CounterTop", Vector3.new(10.8, 0.5, 3.4), CFrame.new(0, 4.7, -4.2), 1.6, "White")
	b:box("CounterStripe", Vector3.new(7.6, 0.4, 0.2), CFrame.new(0, 3.2, -5.62), "GlowSun")
	for _, x in ipairs({-3, 0, 3}) do
		b:ball("CounterDot", 0.7, CFrame.new(x, 2.2, -5.55), "White")
	end

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Browse"
	prompt.ObjectText = "Shovels"
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = counter

	-----------------------------------------------------------------
	-- ROBOT SHOPKEEPER floating behind the counter
	-----------------------------------------------------------------
	local bot = Vector3.new(0, 7.4, -1.2)
	b:ball("RobotHead", 3, CFrame.new(bot), "White")
	b:ellipsoid("RobotVisor", Vector3.new(2.4, 1.2, 1), CFrame.new(bot + Vector3.new(0, 0.1, -1.15)), "Ink")
	b:ball("RobotEyeL", 0.45, CFrame.new(bot + Vector3.new(-0.5, 0.15, -1.62)), "GlowCyan")
	b:ball("RobotEyeR", 0.45, CFrame.new(bot + Vector3.new(0.5, 0.15, -1.62)), "GlowCyan")
	b:ellipsoid("RobotBlushL", Vector3.new(0.5, 0.25, 0.1), CFrame.new(bot + Vector3.new(-1, -0.45, -1.3)), "Coral")
	b:ellipsoid("RobotBlushR", Vector3.new(0.5, 0.25, 0.1), CFrame.new(bot + Vector3.new(1, -0.45, -1.3)), "Coral")
	b:rod("RobotAntenna", 1.1, 0.16, CFrame.new(bot + Vector3.new(0, 1.9, 0)) * CFrame.Angles(0, 0, math.rad(90)), "Chrome")
	b:bulb("RobotAntennaTip", 0.55, CFrame.new(bot + Vector3.new(0, 2.5, 0)), "GlowPink", 6)
	b:ellipsoid("RobotBody", Vector3.new(2.2, 2.2, 1.8), CFrame.new(bot + Vector3.new(0, -2.2, 0)), "Lilac")
	b:ring("RobotHoverRing", CFrame.new(bot + Vector3.new(0, -3.5, 0)) * CFrame.Angles(math.rad(90), 0, 0), 1.2, 0.25, "GlowCyan", 14)

	-----------------------------------------------------------------
	-- GLASS DISPLAY CAPSULES on stepped pedestals (one per depth zone)
	-----------------------------------------------------------------
	local spots = {-60, -22, 22, 60}
	for zoneIndex, zone in ipairs(world.Zones) do
		local def = GameConfig.GetFirstShovelForZone(world, zoneIndex)
		local p = around(spots[zoneIndex], 7.6, 1.5)
		local cf = CFrame.new(p)
		local _, h = b:tiers("Pedestal" .. zoneIndex, cf, {
			{3.8, 0.4, "Violet"},
			{3.2, 0.3 + zoneIndex * 0.45, "White"},
			{3.5, 0.3, "Sky"},
		})
		local capsuleH = 6.6
		local mid = cf * CFrame.new(0, h + capsuleH / 2, 0)
		b:disc("CapsuleGlass", 3, capsuleH, mid, "Glass", {Transparency = 0.6})
		b:ellipsoid("CapsuleDome", Vector3.new(3.1, 1.9, 3.1), mid * CFrame.new(0, capsuleH / 2, 0), "Glass", {Transparency = 0.6})
		b:disc("CapsuleCap", 3.2, 0.35, mid * CFrame.new(0, capsuleH / 2, 0), "Lilac")
		b:disc("CapsuleGlow", 3, 0.2, cf * CFrame.new(0, h + 0.1, 0), "GlowMint")
		local tag = b:roundedBlock("ZoneTag", Vector3.new(3.2, 1.1, 0.4), cf * CFrame.new(0, h - 0.9, -1.75), 0.2, "Navy")
		Architecture.sign(tag, string.upper(zone.Name), -zone.Top .. "-" .. -zone.Bottom .. "m")
		if def then
			-- blade down, facing out; raised a little so the blade clears the capsule floor
			displayShovel(shop, def, base * mid * CFrame.new(0, 0.6, 0) * CFrame.Angles(math.rad(-90), 0, math.rad(8)), 1.3)
		end
	end

	-----------------------------------------------------------------
	-- DEPTH METER: a tall capsule split into the zone colors, labels on the front
	-----------------------------------------------------------------
	local meter = Vector3.new(-15.5, 0, -8)
	b:disc("MeterBase", 4, 0.8, CFrame.new(meter + Vector3.new(0, 0.4, 0)), "Violet")
	local segment = 2.6
	for i, zone in ipairs(world.Zones) do
		local y = 1 + (#world.Zones - i) * segment + segment / 2
		local seg = b:disc("MeterSegment", 2.6, segment - 0.15, CFrame.new(meter + Vector3.new(0, y, 0)), "White")
		seg.Color = zone.Color
		local tag = b:box("MeterLabel", Vector3.new(3.6, 1.6, 0.2), CFrame.new(meter + Vector3.new(0, y, -1.45)), "Navy")
		Architecture.sign(tag, string.upper(zone.Name), -zone.Top .. "-" .. -zone.Bottom .. "m", nil, Color3.new(1, 1, 1))
	end
	local topY = 1 + #world.Zones * segment
	b:ellipsoid("MeterTop", Vector3.new(2.7, 1.8, 2.7), CFrame.new(meter + Vector3.new(0, topY, 0)), "Lilac")
	b:bulb("MeterBulb", 0.8, CFrame.new(meter + Vector3.new(0, topY + 1.1, 0)), "GlowSun", 8)

	shop.Parent = parent
	return shop, prompt
end
