-- ShopBuilder (ModuleScript in ServerScriptService)
-- Builds a world's Shovel Shop pavilion next to its dig site: staggered slate plinths,
-- a recessed concrete back wall, angled blade walls, steel columns and I-beams carrying
-- two overlapping cantilevered roof plates, and the world's shovels displayed on
-- stepped pedestals (one per depth zone). DigManager calls this once per world on start.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local ShovelModels = require(script.Parent:WaitForChild("ShovelModels"))
local Architecture = require(script.Parent:WaitForChild("Architecture"))

-- Floats a shovel model upright (blade down) at a spot, scaled up for display
local function displayShovel(parent, def, target)
	local tool = ShovelModels(def)
	local handle = tool:FindFirstChild("Handle")
	local DISPLAY_SCALE = 1.6
	local display = Instance.new("Model")
	display.Name = "Display_" .. def.Id
	for _, piece in ipairs(tool:GetChildren()) do
		if piece:IsA("BasePart") and piece ~= handle then
			local rel = handle.CFrame:ToObjectSpace(piece.CFrame)
			piece.Size = piece.Size * DISPLAY_SCALE
			piece.CFrame = target * CFrame.new(rel.Position * DISPLAY_SCALE) * rel.Rotation
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

-- parent: where the shop goes. world: a GameConfig world. base: the shop's CFrame
-- (its front, local -Z, faces the pit).
return function(parent, world, base)
	local shop = Instance.new("Model")
	shop.Name = "ShovelShop"
	local b = Architecture.builder(shop, base)

	-----------------------------------------------------------------
	-- STAGGERED BASE: three offset tiers of slate and concrete
	-----------------------------------------------------------------
	b:box("BaseTier1", Vector3.new(32, 0.6, 24), CFrame.new(0, 0.3, 0), "Graphite")
	b:box("BaseTier2", Vector3.new(27, 0.5, 19), CFrame.new(1, 0.85, 1.5), "ConcreteDark")
	local floor = b:box("Floor", Vector3.new(24, 0.2, 16.5), CFrame.new(1, 1.2, 2), "Charcoal")
	floor.Reflectance = 0.06
	-- inlaid steel joints in the floor
	for x = -8, 10, 6 do
		b:box("FloorJoint", Vector3.new(0.12, 0.05, 16.5), CFrame.new(x, 1.31, 2), "Steel")
	end
	-- low step across the front
	b:box("FrontStep", Vector3.new(14, 0.3, 2), CFrame.new(0, 0.75, -11.5), "SlateGrey")

	-----------------------------------------------------------------
	-- BACK WALL: board-formed concrete with three recessed panels
	-----------------------------------------------------------------
	b:box("BackWall", Vector3.new(24, 14, 1.4), CFrame.new(1, 8.3, 9.6), "Concrete")
	b:box("BackWallCap", Vector3.new(24.6, 0.4, 1.8), CFrame.new(1, 15.5, 9.6), "SteelDark")
	for i, x in ipairs({-6.5, 1, 8.5}) do
		b:recessedPanel("BackPanel" .. i, CFrame.new(x, 8.6, 8.9), 6.6, 9.4, "ConcreteLight", "Graphite")
	end
	-- horizontal board-form lines
	for y = 3, 13, 2.5 do
		b:box("FormLine", Vector3.new(24, 0.08, 0.05), CFrame.new(1, y, 8.88), "ConcreteDark")
	end

	-----------------------------------------------------------------
	-- ANGLED BLADE WALLS on both sides
	-----------------------------------------------------------------
	for _, side in ipairs({-1, 1}) do
		local cf = CFrame.new(1 + side * 12.6, 7.4, 3.2) * CFrame.Angles(0, math.rad(side * -9), 0)
		b:box("BladeWall", Vector3.new(1.2, 12.4, 11), cf, "Graphite")
		b:box("BladeWallReveal", Vector3.new(0.2, 11.2, 0.35), cf * CFrame.new(-side * 0.62, 0, -2.5), "Weathered")
		b:box("BladeWallCoping", Vector3.new(1.6, 0.3, 11.4), cf * CFrame.new(0, 6.35, 0), "SteelDark")
	end

	-----------------------------------------------------------------
	-- STRUCTURE: two steel columns, a header beam, joists, two roof plates
	-----------------------------------------------------------------
	for _, x in ipairs({-10.2, 12.2}) do
		b:column("FrontColumn", Vector3.new(x, 1.3, -6.8), 11.9, 0.8, "Steel")
	end
	b:iBeam("HeaderBeam", Vector3.new(-12.5, 13.65, -6.8), Vector3.new(14.5, 13.65, -6.8), 1.1, 0.7)
	for i, x in ipairs({-8, -2.5, 3, 8.5}) do
		b:iBeam("Joist" .. i, Vector3.new(x, 13.75, -9.2), Vector3.new(x, 13.75, 9.8), 0.9, 0.5)
	end
	-- lower roof: thick concrete plate
	b:box("RoofLower", Vector3.new(29, 1, 21), CFrame.new(1, 14.7, 0.4), "ConcreteLight")
	-- upper roof: thinner brushed-steel plate, shifted forward and sideways so the two overhang each other
	b:box("RoofUpper", Vector3.new(22, 0.5, 17), CFrame.new(3.5, 15.45, -3.8), "Steel")
	b:box("RoofUpperEdge", Vector3.new(22.2, 0.7, 0.3), CFrame.new(3.5, 15.4, -12.35), "SteelDark")
	-- fascia sign hung from the upper plate
	local fascia = b:box("Fascia", Vector3.new(17, 2.3, 0.5), CFrame.new(3.5, 14.0, -12.2), "Charcoal")
	Architecture.sign(fascia, "SHOVEL SHOP", "DEPTH-RATED EXCAVATION TOOLS  ·  EST. 2050")
	-- recessed can lights in the lower plate
	for _, pos in ipairs({Vector3.new(-6, 14.12, -3), Vector3.new(1, 14.12, -3), Vector3.new(8, 14.12, -3),
		Vector3.new(-6, 14.12, 4.5), Vector3.new(1, 14.12, 4.5), Vector3.new(8, 14.12, 4.5)}) do
		b:downlight("Downlight", pos, 14, 1.1)
	end

	-----------------------------------------------------------------
	-- COUNTER: a monolithic concrete block on a recessed charcoal plinth
	-----------------------------------------------------------------
	b:box("CounterKick", Vector3.new(9.4, 0.6, 1.8), CFrame.new(1, 1.6, -2.2), "Charcoal")
	local counter = b:box("Counter", Vector3.new(10, 2.8, 2.4), CFrame.new(1, 3.3, -2.4), "Concrete")
	b:box("CounterTop", Vector3.new(10.4, 0.2, 2.8), CFrame.new(1, 4.8, -2.4), "Steel")
	b:box("CounterInlay", Vector3.new(9.6, 0.5, 0.06), CFrame.new(1, 3.6, -3.62), "SteelDark")

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Browse"
	prompt.ObjectText = "Shovels"
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = counter

	-----------------------------------------------------------------
	-- STAGGERED DISPLAY: one shovel per depth zone, each plinth taller and set further back
	-----------------------------------------------------------------
	for zoneIndex, zone in ipairs(world.Zones) do
		local def = GameConfig.GetFirstShovelForZone(world, zoneIndex)
		local x = -8.5 + (zoneIndex - 1) * 5.6
		local z = 4.6 + ((zoneIndex % 2 == 0) and 1.4 or 0)
		local cf = CFrame.new(x, 1.3, z)
		local _, height = b:stagger("Plinth" .. zoneIndex, cf, {
			{3.6, 0.4, 3.0, "Graphite"},
			{3.0, 0.6 + zoneIndex * 0.55, 2.4, "Concrete"},
			{3.3, 0.15, 2.7, "Steel"},
		}, 0, Vector3.zero)
		local plaque = b:box("Plaque", Vector3.new(2.6, 0.7, 0.1), cf * CFrame.new(0, 0.9, -1.25), "Screen")
		Architecture.sign(plaque, string.upper(zone.Name), -zone.Top .. "–" .. -zone.Bottom .. "m")
		if def then
			local top = base * cf * CFrame.new(0, height + 2.6, 0)
			displayShovel(shop, def, top * CFrame.Angles(0, math.rad(90), 0) * CFrame.Angles(math.rad(-90), 0, math.rad(10)))
		end
	end

	-----------------------------------------------------------------
	-- DEPTH TOTEM: freestanding slate slab explaining which shovel digs how deep
	-----------------------------------------------------------------
	local totemCF = CFrame.new(-13.4, 0.6, -9.2) * CFrame.Angles(0, math.rad(20), 0)
	b:box("TotemBase", Vector3.new(3, 0.4, 2.2), totemCF * CFrame.new(0, 0.2, 0), "SteelDark")
	local totem = b:box("DepthTotem", Vector3.new(2.4, 11, 0.9), totemCF * CFrame.new(0, 5.9, 0), "Graphite")
	for i, zone in ipairs(world.Zones) do
		b:box("TotemBand", Vector3.new(2.5, 0.12, 0.95), totemCF * CFrame.new(0, 10.4 - i * 2.4, 0), "Steel")
	end
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0.6
	gui.Parent = totem
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0.02, 0)
	listLayout.Parent = gui
	local function totemLine(text, color, h, font)
		local l = Instance.new("TextLabel")
		l.BackgroundTransparency = 1
		l.Size = UDim2.fromScale(1, h)
		l.Text = text
		l.TextColor3 = color
		l.Font = font
		l.TextScaled = true
		l.Parent = gui
	end
	totemLine("DEPTH RATING", Architecture.TextColor, 0.06, Enum.Font.GothamMedium)
	for i, zone in ipairs(world.Zones) do
		local first = GameConfig.GetFirstShovelForZone(world, i)
		totemLine(string.upper(zone.Name), zone.Color, 0.06, Enum.Font.GothamMedium)
		totemLine(-zone.Top .. "–" .. -zone.Bottom .. "m", Architecture.AccentText, 0.05, Enum.Font.Gotham)
		totemLine(first and ("needs " .. first.Name) or "", Architecture.AccentText, 0.1, Enum.Font.Gotham)
	end

	shop.Parent = parent
	return shop, prompt
end
