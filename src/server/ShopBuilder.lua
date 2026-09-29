-- ShopBuilder (ModuleScript in ServerScriptService)
-- Builds the futuristic Shovel Shop next to the dig site.
-- DigManager calls this once when the server starts.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local ShovelModels = require(script.Parent:WaitForChild("ShovelModels"))

local UPRIGHT = CFrame.Angles(0, 0, math.rad(90)) -- makes a cylinder stand up

local WHITE = Color3.fromRGB(238, 240, 245)
local DARK = Color3.fromRGB(18, 20, 32)
local NAVY = Color3.fromRGB(28, 34, 60)
local CYAN = Color3.fromRGB(0, 225, 255)
local GOLD = Color3.fromRGB(255, 200, 60)

local function dim(c, a)
	return Color3.new(c.R * a, c.G * a, c.B * a)
end

return function(parent)
	local shop = Instance.new("Model")
	shop.Name = "ShovelShop"

	-- Position: between two paths, facing the center of the hub
	local angle = math.rad(30)
	local pos = Vector3.new(math.cos(angle) * 80, 0, math.sin(angle) * 80)
	local base = CFrame.lookAt(pos, Vector3.new(0, 0, 0)) -- the shop's front faces the center

	local function part(name, size, offset, color, material, shape)
		local p = Instance.new("Part")
		p.Name = name
		p.Anchored = true
		p.Size = size
		p.CFrame = base * offset
		p.Color = color
		p.Material = material or Enum.Material.SmoothPlastic
		if shape then p.Shape = shape end
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		if p.Material == Enum.Material.Neon or p.Material == Enum.Material.Glass or p.Material == Enum.Material.ForceField then
			p.CastShadow = false
		end
		p.Parent = shop
		return p
	end

	local function disc(name, height, diameter, offset, color, material)
		return part(name, Vector3.new(height, diameter, diameter), offset * UPRIGHT, color, material, Enum.PartType.Cylinder)
	end

	local function ball(name, diameter, offset, color, material)
		return part(name, Vector3.new(diameter, diameter, diameter), offset, color, material, Enum.PartType.Ball)
	end

	local function light(p, color, range, brightness)
		local l = Instance.new("PointLight")
		l.Color = color
		l.Range = range
		l.Brightness = brightness
		l.Parent = p
	end

	-- a point on a circle around the shop center (0 degrees = straight back)
	local function around(deg, radius, y)
		local a = math.rad(deg)
		return Vector3.new(math.sin(a) * radius, y, math.cos(a) * radius)
	end

	-----------------------------------------------------------------
	-- PLATFORM
	-----------------------------------------------------------------
	disc("PlatformGlow", 0.3, 26.6, CFrame.new(0, 0.55, 0), dim(CYAN, 0.7), Enum.Material.Neon)
	disc("Platform", 0.8, 26, CFrame.new(0, 0.4, 0), NAVY)
	local floor = disc("Floor", 0.1, 22, CFrame.new(0, 0.84, 0), WHITE)
	floor.Reflectance = 0.2
	disc("FloorRing", 0.12, 14, CFrame.new(0, 0.85, 0), dim(GOLD, 0.6), Enum.Material.Neon)
	disc("FloorCenter", 0.14, 13.4, CFrame.new(0, 0.86, 0), WHITE).Reflectance = 0.2

	-----------------------------------------------------------------
	-- CURVED BACK WALL (panels in an arc with neon strips)
	-----------------------------------------------------------------
	for deg = -80, 80, 26.7 do
		local p = around(deg, 11, 5.8)
		local cf = CFrame.lookAt(p, Vector3.new(0, 5.8, 0))
		local panel = part("WallPanel", Vector3.new(5.4, 10, 0.6), cf, WHITE)
		panel.CFrame = base * cf
		local strip = part("WallStrip", Vector3.new(0.3, 8.6, 0.1), cf * CFrame.new(0, 0, -0.36), dim(CYAN, 0.8), Enum.Material.Neon)
		strip.CFrame = base * cf * CFrame.new(0, 0, -0.36)
	end

	-----------------------------------------------------------------
	-- FRONT PILLARS
	-----------------------------------------------------------------
	for _, deg in ipairs({-125, 125}) do
		local p = around(deg, 11.2, 5.6)
		part("Pillar", Vector3.new(0.9, 10.4, 0.9), CFrame.new(p), WHITE)
		disc("PillarRingLow", 0.3, 1.3, CFrame.new(p.X, 1.2, p.Z), dim(GOLD, 0.8), Enum.Material.Neon)
		disc("PillarRingHigh", 0.3, 1.3, CFrame.new(p.X, 10.2, p.Z), dim(GOLD, 0.8), Enum.Material.Neon)
	end

	-----------------------------------------------------------------
	-- FLOATING ROOF
	-----------------------------------------------------------------
	disc("RoofEdge", 0.6, 25.8, CFrame.new(0, 11.1, 0), NAVY)
	disc("Roof", 0.8, 24.6, CFrame.new(0, 11.3, 0), WHITE)
	local roofGlow = disc("RoofGlow", 0.15, 23.6, CFrame.new(0, 10.72, 0), dim(CYAN, 0.55), Enum.Material.Neon)
	light(roofGlow, Color3.fromRGB(235, 245, 255), 24, 1.2)
	disc("RoofTop", 0.5, 10, CFrame.new(0, 11.9, 0), NAVY)
	disc("RoofTopGlow", 0.2, 10.6, CFrame.new(0, 11.85, 0), GOLD, Enum.Material.Neon)

	-----------------------------------------------------------------
	-- HOLOGRAPHIC SIGN above the roof
	-----------------------------------------------------------------
	for _, x in ipairs({-5, 5}) do
		part("SignRod", Vector3.new(0.25, 3.2, 0.25), CFrame.new(x, 13.5, -1), dim(GOLD, 0.9), Enum.Material.Metal)
	end
	part("SignGlow", Vector3.new(17, 4, 0.2), CFrame.new(0, 16.3, -0.8), dim(GOLD, 0.8), Enum.Material.Neon)
	local sign = part("Sign", Vector3.new(16.4, 3.4, 0.4), CFrame.new(0, 16.3, -1.05), DARK)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0
	gui.Parent = sign
	local function label(text, color, y, h, font)
		local l = Instance.new("TextLabel")
		l.BackgroundTransparency = 1
		l.Position = UDim2.fromScale(0.03, y)
		l.Size = UDim2.fromScale(0.94, h)
		l.Text = text
		l.TextColor3 = color
		l.Font = font
		l.TextScaled = true
		l.Parent = gui
		local s = Instance.new("UIStroke")
		s.Thickness = 2
		s.Transparency = 0.3
		s.Parent = l
	end
	label("SHOVEL SHOP", GOLD, 0.06, 0.6, Enum.Font.GothamBlack)
	label("TOOLS FOR THE MODERN ARCHAEOLOGIST", CYAN, 0.66, 0.28, Enum.Font.GothamBold)

	-----------------------------------------------------------------
	-- CURVED COUNTER (glass top) with the shop prompt
	-----------------------------------------------------------------
	local counterMid
	for _, deg in ipairs({-155, 180, 155}) do
		local p = around(deg, 6.2, 2)
		local cf = CFrame.lookAt(p, Vector3.new(0, 2, 0))
		local body = part("Counter", Vector3.new(3.4, 2.4, 1.3), cf, DARK)
		body.CFrame = base * cf
		local top = part("CounterGlass", Vector3.new(3.6, 0.2, 1.6), cf * CFrame.new(0, 1.3, 0), Color3.fromRGB(170, 235, 255), Enum.Material.Glass)
		top.CFrame = base * cf * CFrame.new(0, 1.3, 0)
		top.Transparency = 0.35
		local strip = part("CounterStrip", Vector3.new(3.4, 0.15, 0.1), cf * CFrame.new(0, 0.7, 0.7), GOLD, Enum.Material.Neon)
		strip.CFrame = base * cf * CFrame.new(0, 0.7, 0.7)
		if deg == 180 then
			counterMid = body
		end
	end

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Browse"
	prompt.ObjectText = "Shovels & Dig Permits"
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = counterMid

	-----------------------------------------------------------------
	-- ROBOT SHOPKEEPER hovering behind the counter
	-----------------------------------------------------------------
	local botPos = Vector3.new(0, 4.6, -3)
	local bot = ball("RobotBody", 1.8, CFrame.new(botPos), WHITE)
	bot.Reflectance = 0.15
	local visor = part("RobotVisor", Vector3.new(1.3, 0.6, 0.3), CFrame.new(botPos + Vector3.new(0, 0.15, -0.8)), DARK, Enum.Material.Glass)
	visor.Reflectance = 0.3
	local eye = part("RobotEye", Vector3.new(0.9, 0.14, 0.1), CFrame.new(botPos + Vector3.new(0, 0.15, -0.97)), CYAN, Enum.Material.Neon)
	light(eye, CYAN, 6, 1)
	part("RobotAntenna", Vector3.new(0.08, 0.7, 0.08), CFrame.new(botPos + Vector3.new(0, 1.2, 0)), dim(WHITE, 0.8), Enum.Material.Metal)
	ball("RobotAntennaTip", 0.25, CFrame.new(botPos + Vector3.new(0, 1.6, 0)), GOLD, Enum.Material.Neon)
	disc("RobotHoverRing", 0.12, 1.4, CFrame.new(botPos + Vector3.new(0, -1.25, 0)), dim(CYAN, 0.8), Enum.Material.Neon)

	-----------------------------------------------------------------
	-- DISPLAY PEDESTALS with floating shovels
	-----------------------------------------------------------------
	local showcase = {2, 4, 6} -- which shovels from GameConfig.Shovels to show off
	local slots = {-48, 0, 48}
	for i, shovelIndex in ipairs(showcase) do
		local def = GameConfig.Shovels[shovelIndex]
		local p = around(slots[i], 7.6, 0)
		disc("PedestalGlow", 0.2, 2.6, CFrame.new(p.X, 1.0, p.Z), dim(GOLD, 0.7), Enum.Material.Neon)
		disc("Pedestal", 2.2, 2.2, CFrame.new(p.X, 2, p.Z), WHITE)
		local cap = disc("PedestalCap", 0.25, 2.5, CFrame.new(p.X, 3.2, p.Z), NAVY)
		light(cap, def and def.Color or CYAN, 8, 1)

		if def then
			-- build the real shovel model, make it bigger, and float it above the pedestal
			local tool = ShovelModels(def)
			local handle = tool:FindFirstChild("Handle")
			local DISPLAY_SCALE = 1.7
			local target = base * CFrame.new(p.X, 5.9, p.Z)
				* CFrame.Angles(0, math.rad(slots[i] + 90), 0)
				* CFrame.Angles(math.rad(-90), 0, math.rad(12)) -- stand it up, blade down, slight tilt
			local display = Instance.new("Model")
			display.Name = "Display_" .. def.Id
			for _, piece in ipairs(tool:GetChildren()) do
				if piece:IsA("BasePart") then
					local rel = handle.CFrame:ToObjectSpace(piece.CFrame)
					piece.Size = piece.Size * DISPLAY_SCALE
					piece.CFrame = base:ToObjectSpace(target * CFrame.new(rel.Position * DISPLAY_SCALE) * rel.Rotation)
					piece.CFrame = base * piece.CFrame
					piece.Anchored = true
					for _, c in ipairs(piece:GetChildren()) do
						if c:IsA("WeldConstraint") then c:Destroy() end
					end
					piece.Parent = display
				end
			end
			tool:Destroy()
			display.Parent = shop
		end
	end

	shop.Parent = parent
	return shop
end
