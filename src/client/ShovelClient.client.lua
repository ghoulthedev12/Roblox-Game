-- ShovelClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Shovel swing + dig animation, depth + zone display, underground light,
-- Return to Surface button, and the Shovel Shop menu (each world's shovels + their depth rating).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local swingRemote = remotes:WaitForChild("DigSwing")
local digMessageRemote = remotes:WaitForChild("DigProgress")
local surfaceRemote = remotes:WaitForChild("ReturnToSurface")
local openShopRemote = remotes:WaitForChild("OpenShovelShop")
local buyShovelRemote = remotes:WaitForChild("BuyShovel")
local equipShovelRemote = remotes:WaitForChild("EquipShovel")
local shopMessageRemote = remotes:WaitForChild("ShopMessage")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local DARK = Color3.fromRGB(18, 20, 32)
local ROW = Color3.fromRGB(32, 35, 50)
local CYAN = Color3.fromRGB(0, 225, 255)
local GOLD = Color3.fromRGB(255, 200, 60)
local GREEN = Color3.fromRGB(70, 200, 110)
local RED = Color3.fromRGB(200, 70, 70)
local GREY = Color3.fromRGB(90, 95, 110)

local gui = Instance.new("ScreenGui")
gui.Name = "ShovelGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 10)
	c.Parent = parent
end

local function stroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness or 2
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function label(parent, text, size, position, color, font, anchor)
	local l = Instance.new("TextLabel")
	l.Size = size
	l.Position = position
	l.AnchorPoint = anchor or Vector2.new(0, 0)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = color
	l.Font = font or Enum.Font.GothamBold
	l.TextScaled = true
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

local function button(parent, text, size, position, color)
	local b = Instance.new("TextButton")
	b.Size = size
	b.Position = position
	b.BackgroundColor3 = color
	b.Text = text
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBlack
	b.TextScaled = true
	b.Parent = parent
	corner(b, 8)
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 8)
	pad.PaddingTop = UDim.new(0, 7)
	pad.PaddingBottom = UDim.new(0, 7)
	pad.Parent = b
	return b
end

---------------------------------------------------------------------
-- HINT MESSAGES
---------------------------------------------------------------------
local hint = label(gui, "", UDim2.new(0, 560, 0, 28), UDim2.new(0.5, 0, 1, -255), Color3.fromRGB(255, 220, 120), Enum.Font.GothamBlack, Vector2.new(0.5, 0))
hint.TextXAlignment = Enum.TextXAlignment.Center
hint.Visible = false
local hintStroke = Instance.new("UIStroke")
hintStroke.Thickness = 2
hintStroke.Parent = hint

local hintToken = 0
local function showHint(text, color)
	hintToken += 1
	local myToken = hintToken
	hint.Text = text
	hint.TextColor3 = color or Color3.fromRGB(255, 220, 120)
	hint.Visible = true
	task.delay(2.5, function()
		if hintToken == myToken then hint.Visible = false end
	end)
end

digMessageRemote.OnClientEvent:Connect(function(message, color)
	if typeof(message) == "string" then
		showHint(message, typeof(color) == "Color3" and color or nil)
	end
end)

---------------------------------------------------------------------
-- DEPTH PANEL + RETURN TO SURFACE + UNDERGROUND LIGHT
---------------------------------------------------------------------
local depthPanel = Instance.new("Frame")
depthPanel.Size = UDim2.new(0, 330, 0, 60)
depthPanel.Position = UDim2.new(0.5, 0, 1, -100)
depthPanel.AnchorPoint = Vector2.new(0.5, 1)
depthPanel.BackgroundColor3 = DARK
depthPanel.BackgroundTransparency = 0.15
depthPanel.Visible = false
depthPanel.Parent = gui
corner(depthPanel, 12)
local depthStroke = stroke(depthPanel, CYAN, 2)

local shovelLabel = label(depthPanel, "", UDim2.new(1, -20, 0, 18), UDim2.new(0, 10, 0, 7), Color3.new(1, 1, 1), Enum.Font.GothamBlack)
local depthLabel = label(depthPanel, "", UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 32), CYAN, Enum.Font.GothamBold)

local surfaceButton = button(gui, "RETURN TO SURFACE", UDim2.new(0, 220, 0, 40), UDim2.new(0.5, -110, 1, -215), Color3.fromRGB(0, 140, 180))
surfaceButton.Visible = false
surfaceButton.MouseButton1Click:Connect(function()
	surfaceRemote:FireServer()
end)

local headlamp -- PointLight on our character when underground
local equippedDef -- the shovel currently in hand

local function currentWorld()
	return GameConfig.GetWorld(player:GetAttribute("CurrentWorld") or 1) or GameConfig.Worlds[1]
end

task.spawn(function()
	while true do
		task.wait(0.2)
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root then
			local world = currentWorld()
			local feetY = root.Position.Y - 3
			local depth = math.max(0, math.floor(world.Origin.Y - feetY + 0.5))
			local offset = root.Position - world.Origin
			local inPit = Vector3.new(offset.X, 0, offset.Z).Magnitude < world.PitRadius + 7

			local zoneIndex, zone = GameConfig.GetZoneAt(world, feetY)
			zone = zone or {Name = "Bedrock", Color = Color3.fromRGB(150, 150, 160)}
			local text = "DEPTH " .. depth .. "m  •  " .. string.upper(zone.Name)
			-- warn when the next zone down is too hard for this shovel
			if equippedDef and zoneIndex and zoneIndex == equippedDef.MaxZone and zoneIndex < #world.Zones then
				local floorDepth = -world.Zones[zoneIndex].Bottom
				if floorDepth - depth <= 12 then
					text ..= "  •  LIMIT " .. floorDepth .. "m"
				end
			end
			depthLabel.Text = text
			depthLabel.TextColor3 = zone.Color
			depthStroke.Color = zone.Color

			surfaceButton.Visible = inPit and depth > 4

			-- small light so you can see underground
			if depth > 4 then
				if not headlamp or headlamp.Parent ~= root then
					headlamp = Instance.new("PointLight")
					headlamp.Color = Color3.fromRGB(255, 235, 200)
					headlamp.Range = 22
					headlamp.Brightness = 1.3
					headlamp.Shadows = true
					headlamp.Parent = root
				end
				headlamp.Enabled = true
			elseif headlamp then
				headlamp.Enabled = false
			end
		end
	end
end)

---------------------------------------------------------------------
-- SWING + DIG ANIMATION
---------------------------------------------------------------------
local lastSwing = 0

-- One smooth dig motion, driven every frame.
-- Keyframes: {time 0-1, hand up/down, hand forward/back, blade tilt in degrees}
-- Hand offsets are in studs from where the hand normally rests (+up, -forward).
-- Blade: + tips the blade down into the ground.
local DIG_KEYS = {
	{0.00,  0.0,  0.0,   0},  -- resting
	{0.32,  1.3,  0.3, -18},  -- raise the shovel up
	{0.52, -1.3, -0.7,  26},  -- strike down into the dirt
	{0.72, -0.3, -0.4, -16},  -- scoop the dirt up
	{1.00,  0.0,  0.0,   0},  -- back to resting
}
local STRIKE_TIME = 0.52

-- Smooth curve through the keyframes (Catmull-Rom), so the motion never jerks
local function sampleKeys(t, column)
	t = math.clamp(t, 0, 1)
	local i = 1
	while i < #DIG_KEYS - 1 and t > DIG_KEYS[i + 1][1] do
		i += 1
	end
	local k1, k2 = DIG_KEYS[i], DIG_KEYS[i + 1]
	local k0 = DIG_KEYS[math.max(i - 1, 1)]
	local k3 = DIG_KEYS[math.min(i + 2, #DIG_KEYS)]
	local u = (t - k1[1]) / (k2[1] - k1[1])
	local p0, p1, p2, p3 = k0[column], k1[column], k2[column], k3[column]
	local u2, u3 = u * u, u * u * u
	return 0.5 * ((2 * p1) + (-p0 + p2) * u + (2 * p0 - 5 * p1 + 4 * p2 - p3) * u2 + (-p0 + 3 * p1 - 3 * p2 + p3) * u3)
end

local function smoothstep(x)
	x = math.clamp(x, 0, 1)
	return x * x * (3 - 2 * x)
end

-- IKControl moves the hand to a target point and bends the arm naturally
local function getArmIK(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	local upperArm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm")
	local hand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
	if not (humanoid and root and upperArm and hand) then return nil end
	local target = root:FindFirstChild("DigHandTarget")
	if not target then
		target = Instance.new("Attachment")
		target.Name = "DigHandTarget"
		target.Parent = root
	end
	local ik = humanoid:FindFirstChild("DigArmIK")
	if not ik then
		ik = Instance.new("IKControl")
		ik.Name = "DigArmIK"
		ik.Type = Enum.IKControlType.Position
		ik.ChainRoot = upperArm
		ik.EndEffector = hand
		ik.Target = target
		ik.Weight = 0
		ik.SmoothTime = 0 -- follow the path exactly, no lag
		ik.Parent = humanoid
	end
	return ik, target, root, hand
end

local digConn -- the animation currently playing
local restore -- puts the arm and shovel back to rest

local function stopDigAnimation()
	if digConn then
		digConn:Disconnect()
		digConn = nil
	end
	if restore then
		restore()
		restore = nil
	end
end

local function playDigAnimation(tool, baseGrip, duration)
	local character = player.Character
	if not character then return end
	local ik, target, root, hand = getArmIK(character)
	-- remember where the hand rests (only when no swing is running, so it never drifts)
	local restPos
	if ik and not digConn then
		restPos = root.CFrame:PointToObjectSpace(hand.Position)
		target:SetAttribute("RestPos", restPos)
	elseif ik then
		restPos = target:GetAttribute("RestPos") or root.CFrame:PointToObjectSpace(hand.Position)
	end
	stopDigAnimation() -- a new swing smoothly takes over from the old one
	local start = os.clock()

	restore = function()
		tool.Grip = baseGrip
		if ik then ik.Weight = 0 end
	end

	digConn = RunService.RenderStepped:Connect(function()
		local t = (os.clock() - start) / duration
		if t >= 1 or tool.Parent ~= character then
			stopDigAnimation()
			return
		end
		if ik then
			target.Position = restPos + Vector3.new(0, sampleKeys(t, 2), sampleKeys(t, 3))
			-- fade the arm control in and out so it never pops
			ik.Weight = math.min(smoothstep(t / 0.15), smoothstep((1 - t) / 0.2))
		end
		tool.Grip = baseGrip * CFrame.Angles(math.rad(sampleKeys(t, 4)), 0, 0)
	end)
end

-- A small, smooth camera dip when the shovel hits the ground
local function impactDip()
	local start = os.clock()
	local conn
	conn = RunService.RenderStepped:Connect(function()
		local t = (os.clock() - start) / 0.18
		if t >= 1 then
			conn:Disconnect()
			return
		end
		local offset = math.sin(t * math.pi) * 0.12
		camera.CFrame = camera.CFrame * CFrame.new(0, -offset, 0)
	end)
end

local function onToolEquipped(tool)
	local def = GameConfig.GetShovel(tool:GetAttribute("ShovelId")) or GameConfig.Shovels[1]
	local baseGrip = tool.Grip
	local world = GameConfig.GetWorld(def.World) or GameConfig.Worlds[1]
	equippedDef = def
	shovelLabel.Text = string.upper(def.Name) .. "  •  " .. math.floor(def.FindChance * 100 + 0.5) .. "% find  •  digs to " .. -world.Zones[def.MaxZone].Bottom .. "m"
	depthPanel.Visible = true

	local activatedConn = tool.Activated:Connect(function()
		local now = os.clock()
		if now - lastSwing < def.Cooldown then return end
		lastSwing = now

		local duration = math.clamp(def.Cooldown * 0.95, 0.35, 0.65)
		playDigAnimation(tool, baseGrip, duration)

		-- the dig happens exactly when the shovel hits the ground
		local target = mouse.Hit and mouse.Hit.Position
		task.delay(duration * STRIKE_TIME, function()
			swingRemote:FireServer(target)
			impactDip()
		end)
	end)

	tool.Unequipped:Once(function()
		activatedConn:Disconnect()
		stopDigAnimation()
		tool.Grip = baseGrip
		depthPanel.Visible = false
		if equippedDef == def then equippedDef = nil end
	end)
end

local function watchCharacter(character)
	character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") and child:GetAttribute("ShovelId") then
			onToolEquipped(child)
		end
	end)
end

player.CharacterAdded:Connect(watchCharacter)
if player.Character then
	watchCharacter(player.Character)
end

---------------------------------------------------------------------
-- SHOP MENU (the world's shovels + its depth zones)
---------------------------------------------------------------------
local shop = Instance.new("Frame")
shop.Size = UDim2.new(0, 600, 0, 480)
shop.Position = UDim2.new(0.5, 0, 0.5, 0)
shop.AnchorPoint = Vector2.new(0.5, 0.5)
shop.BackgroundColor3 = DARK
shop.BackgroundTransparency = 0.05
shop.Visible = false
shop.Parent = gui
corner(shop, 16)
stroke(shop, GOLD, 3)

label(shop, "SHOVEL SHOP", UDim2.new(0, 300, 0, 34), UDim2.new(0, 20, 0, 14), GOLD, Enum.Font.GothamBlack)
local moneyLabel = label(shop, "", UDim2.new(0, 220, 0, 22), UDim2.new(1, -290, 0, 22), Color3.fromRGB(90, 255, 120), Enum.Font.GothamBold)
moneyLabel.TextXAlignment = Enum.TextXAlignment.Right
local closeButton = button(shop, "X", UDim2.new(0, 36, 0, 36), UDim2.new(1, -50, 0, 14), RED)

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -30, 1, -80)
list.Position = UDim2.new(0, 15, 0, 64)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 6
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.Parent = shop
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

local order = 0
local function header(text)
	order += 1
	local h = label(list, text, UDim2.new(1, -10, 0, 26), UDim2.new(), CYAN, Enum.Font.GothamBlack)
	h.LayoutOrder = order
end

local function makeRow(color, title, stats, description)
	order += 1
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -10, 0, 78)
	row.BackgroundColor3 = ROW
	row.LayoutOrder = order
	row.Parent = list
	corner(row, 10)
	local swatch = Instance.new("Frame")
	swatch.Size = UDim2.new(0, 54, 0, 54)
	swatch.Position = UDim2.new(0, 12, 0.5, 0)
	swatch.AnchorPoint = Vector2.new(0, 0.5)
	swatch.BackgroundColor3 = color
	swatch.Parent = row
	corner(swatch, 10)
	label(row, title, UDim2.new(0, 320, 0, 22), UDim2.new(0, 80, 0, 8), Color3.new(1, 1, 1), Enum.Font.GothamBlack)
	label(row, stats, UDim2.new(0, 320, 0, 17), UDim2.new(0, 80, 0, 32), CYAN, Enum.Font.GothamBold)
	label(row, description, UDim2.new(0, 320, 0, 15), UDim2.new(0, 80, 0, 53), Color3.fromRGB(170, 175, 190), Enum.Font.GothamMedium)
	local b = button(row, "", UDim2.new(0, 130, 0, 42), UDim2.new(1, -142, 0.5, -21), GREEN)
	return b
end

local shovelButtons = {}
local shopWorld = GameConfig.Worlds[1] -- which world's shop is open

local function zoneLabel(world, def)
	local zone = world.Zones[def.MaxZone]
	return "Digs to " .. -zone.Bottom .. "m (" .. zone.Name .. ")"
end

-- Fills the list with one world's shovels
local function buildRows(world)
	for _, child in ipairs(list:GetChildren()) do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end
	shovelButtons = {}
	order = 0
	header(string.upper(world.Name) .. "  •  SHOVELS")
	for _, def in ipairs(world.Shovels) do
		local stats = zoneLabel(world, def) .. "  •  " .. math.floor(def.FindChance * 100 + 0.5) .. "% find  •  Luck x" .. def.Luck
		local b = makeRow(def.Color, def.Name, stats, def.Description)
		shovelButtons[def.Id] = b
		b.MouseButton1Click:Connect(function()
			local owned = string.split(player:GetAttribute("OwnedShovels") or "", ",")
			if table.find(owned, def.Id) then
				equipShovelRemote:FireServer(def.Id)
			else
				buyShovelRemote:FireServer(def.Id)
			end
		end)
	end
	header("DEPTH ZONES")
	for i, zone in ipairs(world.Zones) do
		local first = GameConfig.GetFirstShovelForZone(world, i)
		order += 1
		local line = label(list, string.upper(zone.Name) .. "   " .. -zone.Top .. "-" .. -zone.Bottom .. "m   •   "
			.. table.concat(zone.Rarities, ", ") .. "   •   needs " .. (first and first.Name or "?"),
			UDim2.new(1, -10, 0, 18), UDim2.new(), zone.Color, Enum.Font.GothamBold)
		line.LayoutOrder = order
	end
end

local function refreshShop()
	local money = player:GetAttribute("Money") or 0
	local owned = string.split(player:GetAttribute("OwnedShovels") or "", ",")
	local equipped = player:GetAttribute("EquippedShovel")
	moneyLabel.Text = ArtifactData.FormatMoney(money)

	for _, def in ipairs(shopWorld.Shovels) do
		local b = shovelButtons[def.Id]
		if not b then continue end
		if def.Id == equipped then
			b.Text = "EQUIPPED"
			b.BackgroundColor3 = GREY
		elseif table.find(owned, def.Id) then
			b.Text = "EQUIP"
			b.BackgroundColor3 = Color3.fromRGB(0, 150, 190)
		else
			b.Text = "BUY " .. ArtifactData.FormatMoney(def.Price)
			b.BackgroundColor3 = (money >= def.Price) and GREEN or RED
		end
	end
end

player:GetAttributeChangedSignal("Money"):Connect(function()
	if shop.Visible then refreshShop() end
end)
player:GetAttributeChangedSignal("OwnedShovels"):Connect(refreshShop)
player:GetAttributeChangedSignal("EquippedShovel"):Connect(refreshShop)

local shopScale = Instance.new("UIScale")
shopScale.Parent = shop

openShopRemote.OnClientEvent:Connect(function(worldId)
	shopWorld = GameConfig.GetWorld(worldId) or GameConfig.Worlds[1]
	buildRows(shopWorld)
	refreshShop()
	shop.Visible = true
	shopScale.Scale = 0.6
	TweenService:Create(shopScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
end)

closeButton.MouseButton1Click:Connect(function()
	shop.Visible = false
end)

shopMessageRemote.OnClientEvent:Connect(function(message, success)
	showHint(message, success and Color3.fromRGB(90, 255, 120) or Color3.fromRGB(255, 90, 90))
end)
