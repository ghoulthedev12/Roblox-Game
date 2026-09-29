-- ShovelClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Shovel swing + dig animation, depth + zone meter, underground light,
-- Return to Surface button, and the Shovel Shop window (each world's shovels as cards
-- with 3D icons, stat bars and their depth rating).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
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

local gui = UIKit.screen(player, "ShovelGui", 2)

---------------------------------------------------------------------
-- HINT MESSAGES (bubbly text above the hotbar)
---------------------------------------------------------------------
local hint = UIKit.label(gui, "", {
	Size = UDim2.fromOffset(620, 30), Position = UDim2.new(0.5, 0, 1, -150), AnchorPoint = Vector2.new(0.5, 0),
	Color = C.Sun, Stroke = 3,
})
hint.Visible = false

local hintToken = 0
local function showHint(text, color)
	hintToken += 1
	local myToken = hintToken
	hint.Text = text
	hint.TextColor3 = color or C.Sun
	hint.Visible = true
	UIKit.pop(hint, 0.7)
	task.delay(2.8, function()
		if hintToken == myToken then hint.Visible = false end
	end)
end

digMessageRemote.OnClientEvent:Connect(function(message, color)
	if typeof(message) == "string" then
		showHint(message, typeof(color) == "Color3" and color or nil)
	end
end)

---------------------------------------------------------------------
-- DEPTH GAUGE (slim tube on the right edge) + RETURN TO SURFACE + UNDERGROUND LIGHT
---------------------------------------------------------------------
local GAUGE_H = 230 -- height of the tube in pixels

local depthPanel = Instance.new("Frame") -- whole gauge; shown while holding a shovel or underground
depthPanel.BackgroundTransparency = 1
depthPanel.Size = UDim2.fromOffset(104, 360)
depthPanel.Position = UDim2.new(1, -12, 0.5, 0)
depthPanel.AnchorPoint = Vector2.new(1, 0.5)
depthPanel.Visible = false
depthPanel.Parent = gui
local gaugeScale = Instance.new("UIScale")
gaugeScale.Parent = depthPanel
local function fitScreen()
	gaugeScale.Scale = math.clamp(camera.ViewportSize.Y / 720, 0.65, 1)
end
camera:GetPropertyChangedSignal("ViewportSize"):Connect(fitScreen)
fitScreen()

-- depth number bubble
local depthBubble = UIKit.panel(depthPanel, {Size = UDim2.fromOffset(92, 40), Position = UDim2.new(0.5, 0, 0, 0), AnchorPoint = Vector2.new(0.5, 0), Color = C.Panel, Radius = 20})
local depthLabel = UIKit.label(depthBubble, "0m", {Size = UDim2.new(1, -16, 0.72, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Ink, Stroke = 0})

-- the tube, filled with one colored band per zone (thicker zones = taller bands)
local tube = UIKit.panel(depthPanel, {Size = UDim2.fromOffset(30, GAUGE_H), Position = UDim2.new(0.5, 8, 0, 50), AnchorPoint = Vector2.new(0.5, 0), Color = C.PanelTint, Radius = 15, Stroke = 3, Shade = false})
tube.ClipsDescendants = true
local bands = Instance.new("Frame")
bands.BackgroundTransparency = 1
bands.Size = UDim2.fromScale(1, 1)
bands.Parent = tube
local tubeGloss = UIKit.panel(tube, {Size = UDim2.new(0, 6, 1, -16), Position = UDim2.new(0, 5, 0, 8), Color = C.White, Radius = 3, Stroke = false, Shade = false})
tubeGloss.BackgroundTransparency = 0.55
tubeGloss.ZIndex = 3

-- your position: a round marker that slides down the left side of the tube
local marker = UIKit.panel(depthPanel, {Size = UDim2.fromOffset(22, 22), Position = UDim2.new(0.5, -14, 0, 50), AnchorPoint = Vector2.new(1, 0.5), Color = C.Sun, Radius = 11, Stroke = 3})
marker.ZIndex = 4

-- your shovel's limit: a red line across the tube with a small tag
local limitLine = UIKit.panel(depthPanel, {Size = UDim2.fromOffset(40, 6), Position = UDim2.new(0.5, 8, 0, 50), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Coral, Radius = 3, Stroke = 2, Shade = false})
limitLine.ZIndex = 4
local shovelLabel = UIKit.label(depthPanel, "", {Size = UDim2.fromOffset(52, 16), Position = UDim2.new(0.5, 30, 0, 50), AnchorPoint = Vector2.new(0, 0.5), Align = "Left", Color = C.Coral, Stroke = 2})
shovelLabel.ZIndex = 4

-- zone name pill under the tube
local zonePill = UIKit.panel(depthPanel, {Size = UDim2.fromOffset(104, 28), Position = UDim2.new(0.5, 0, 0, 50 + GAUGE_H + 8), AnchorPoint = Vector2.new(0.5, 0), Color = C.Sun, Radius = 14})
local zoneLabel = UIKit.label(zonePill, "", {Size = UDim2.new(1, -12, 0.72, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2})

-- small "surface" button under everything, only while underground
local surfaceButton = UIKit.button(depthPanel, "SURFACE", {
	Size = UDim2.fromOffset(104, 40), Position = UDim2.new(0.5, 0, 0, 50 + GAUGE_H + 44), AnchorPoint = Vector2.new(0.5, 0), Color = C.Sky, Radius = 20,
})
surfaceButton.Visible = false
surfaceButton.MouseButton1Click:Connect(function()
	surfaceRemote:FireServer()
end)

local headlamp -- PointLight on our character when underground
local equippedDef -- the shovel currently in hand
local gaugeWorld -- world the bands were drawn for

local function currentWorld()
	return GameConfig.GetWorld(player:GetAttribute("CurrentWorld") or 1) or GameConfig.Worlds[1]
end

local function drawBands(world)
	gaugeWorld = world
	bands:ClearAllChildren()
	local total = -world.Zones[#world.Zones].Bottom
	for i, zone in ipairs(world.Zones) do
		local top = -zone.Top / total
		local height = (zone.Top - zone.Bottom) / total
		local band = Instance.new("Frame")
		band.BorderSizePixel = 0
		band.BackgroundColor3 = zone.Color
		band.Position = UDim2.fromScale(0, top)
		band.Size = UDim2.fromScale(1, height)
		band.Parent = bands
		if i > 1 then
			local seam = Instance.new("Frame")
			seam.BorderSizePixel = 0
			seam.BackgroundColor3 = C.Ink
			seam.Size = UDim2.new(1, 0, 0, 2)
			seam.Parent = band
		end
	end
end

-- y position (in gauge pixels) of a depth
local function gaugeY(world, depth)
	local total = -world.Zones[#world.Zones].Bottom
	return 50 + math.clamp(depth / total, 0, 1) * GAUGE_H
end

task.spawn(function()
	while true do
		task.wait(0.15)
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root then
			local world = currentWorld()
			if world ~= gaugeWorld then drawBands(world) end
			local feetY = root.Position.Y - 3
			local depth = math.max(0, math.floor(world.Origin.Y - feetY + 0.5))
			local offset = root.Position - world.Origin
			local inPit = Vector3.new(offset.X, 0, offset.Z).Magnitude < world.PitRadius + 7

			local _, zone = GameConfig.GetZoneAt(world, feetY)
			zone = zone or {Name = "Bedrock", Color = Color3.fromRGB(150, 150, 160)}
			depthLabel.Text = depth .. "m"
			zoneLabel.Text = string.upper(zone.Name)
			zonePill.BackgroundColor3 = zone.Color
			marker.Position = UDim2.new(0.5, -14, 0, gaugeY(world, depth))

			if equippedDef and equippedDef.World == world.Id then
				local maxDepth = -world.Zones[equippedDef.MaxZone].Bottom
				limitLine.Visible = equippedDef.MaxZone < #world.Zones
				shovelLabel.Visible = limitLine.Visible
				limitLine.Position = UDim2.new(0.5, 8, 0, gaugeY(world, maxDepth))
				shovelLabel.Position = UDim2.new(0.5, 30, 0, gaugeY(world, maxDepth))
				shovelLabel.Text = "MAX"
				-- marker turns red when you're right at your shovel's limit
				marker.BackgroundColor3 = (limitLine.Visible and maxDepth - depth <= 8) and C.Coral or C.Sun
			else
				limitLine.Visible = false
				shovelLabel.Visible = false
				marker.BackgroundColor3 = C.Sun
			end

			depthPanel.Visible = equippedDef ~= nil or (inPit and depth > 4)
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
	equippedDef = def
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
-- SHOVEL SHOP WINDOW
---------------------------------------------------------------------
local window, content = UIKit.window(gui, "SHOVEL SHOP", UDim2.fromOffset(760, 560), C.Violet)

local moneyTag = UIKit.panel(content, {Size = UDim2.fromOffset(190, 36), Position = UDim2.new(1, 0, 0, 0), AnchorPoint = Vector2.new(1, 0), Color = C.Money, Radius = 18})
local moneyLabel = UIKit.label(moneyTag, "", {Size = UDim2.new(1, -20, 0.8, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2})
local worldLabel = UIKit.label(content, "", {Size = UDim2.new(1, -210, 0, 30), Position = UDim2.fromOffset(4, 3), Align = "Left", Color = C.Violet, Stroke = 0})

local listHolder = Instance.new("Frame")
listHolder.BackgroundTransparency = 1
listHolder.Size = UDim2.new(1, 0, 1, -48)
listHolder.Position = UDim2.fromOffset(0, 46)
listHolder.Parent = content
local list = UIKit.list(listHolder, 10)

local shopWorld = GameConfig.Worlds[1] -- which world's shop is open
local cards = {} -- [shovelId] = button

-- the best value of each stat in this world, so the bars fill relative to the top shovel
local function maxStat(world, key)
	local m = 0
	for _, def in ipairs(world.Shovels) do m = math.max(m, def[key]) end
	return m
end

local function buildCards(world)
	for _, child in ipairs(list:GetChildren()) do
		if child:IsA("GuiObject") then child:Destroy() end
	end
	cards = {}
	worldLabel.Text = world.Name
	local maxFind, maxLuck = maxStat(world, "FindChance"), maxStat(world, "Luck")
	local minCooldown = math.huge
	for _, def in ipairs(world.Shovels) do minCooldown = math.min(minCooldown, def.Cooldown) end

	for i, def in ipairs(world.Shovels) do
		local zone = world.Zones[def.MaxZone]
		local card = UIKit.panel(list, {Size = UDim2.new(1, -6, 0, 128), Color = C.Row, Radius = 18})
		card.LayoutOrder = i
		-- icon on a colored plate (plate color = the deepest zone it reaches)
		local plate = UIKit.panel(card, {Size = UDim2.fromOffset(104, 104), Position = UDim2.new(0, 12, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Color = zone.Color, Radius = 16})
		UIKit.shovelIcon(plate, def, {Size = UDim2.fromScale(1, 1)})
		UIKit.label(card, def.Name, {Size = UDim2.new(0.52, -136, 0, 26), Position = UDim2.fromOffset(128, 10), Align = "Left", Color = C.Ink, Stroke = 0})
		UIKit.label(card, def.Description, {Size = UDim2.new(0.52, -136, 0, 46), Position = UDim2.fromOffset(128, 36), Align = "Left", VAlign = "Top", Color = C.Grey, Stroke = 0, Font = Enum.Font.GothamMedium, TextSize = 12})
		local zoneTag = UIKit.panel(card, {Size = UDim2.fromOffset(190, 26), Position = UDim2.fromOffset(128, 90), Color = zone.Color, Radius = 13, Stroke = 2})
		UIKit.label(zoneTag, "DIGS TO " .. -zone.Bottom .. "m  •  " .. string.upper(zone.Name), {Size = UDim2.new(1, -12, 0.8, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2})

		local statsBox = Instance.new("Frame")
		statsBox.BackgroundTransparency = 1
		statsBox.Size = UDim2.new(0.3, 0, 0, 80)
		statsBox.Position = UDim2.new(0.52, 0, 0, 14)
		statsBox.Parent = card
		UIKit.statBar(statsBox, "Find", def.FindChance / maxFind, math.floor(def.FindChance * 1000 + 0.5) / 10 .. "%", C.Mint, {Size = UDim2.new(1, 0, 0, 20), Position = UDim2.fromOffset(0, 0)})
		UIKit.statBar(statsBox, "Luck", def.Luck / maxLuck, "x" .. def.Luck, C.Sun, {Size = UDim2.new(1, 0, 0, 20), Position = UDim2.fromOffset(0, 26)})
		UIKit.statBar(statsBox, "Speed", minCooldown / def.Cooldown, string.format("%.2fs", def.Cooldown), C.Sky, {Size = UDim2.new(1, 0, 0, 20), Position = UDim2.fromOffset(0, 52)})

		local b = UIKit.button(card, "", {Size = UDim2.new(0.15, 0, 0, 52), Position = UDim2.new(1, -12, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5)})
		cards[def.Id] = b
		b.MouseButton1Click:Connect(function()
			local owned = string.split(player:GetAttribute("OwnedShovels") or "", ",")
			if table.find(owned, def.Id) then
				equipShovelRemote:FireServer(def.Id)
			else
				buyShovelRemote:FireServer(def.Id)
			end
		end)
	end
end

local function refreshShop()
	local money = player:GetAttribute("Money") or 0
	local owned = string.split(player:GetAttribute("OwnedShovels") or "", ",")
	local equipped = player:GetAttribute("EquippedShovel")
	moneyLabel.Text = ArtifactData.FormatMoney(money)
	for _, def in ipairs(shopWorld.Shovels) do
		local b = cards[def.Id]
		if b then
			if def.Id == equipped then
				UIKit.setButton(b, "EQUIPPED", C.Grey)
			elseif table.find(owned, def.Id) then
				UIKit.setButton(b, "EQUIP", C.Sky)
			else
				UIKit.setButton(b, ArtifactData.FormatMoney(def.Price), money >= def.Price and C.Mint or C.Coral)
			end
		end
	end
end

for _, attribute in ipairs({"Money", "OwnedShovels", "EquippedShovel"}) do
	player:GetAttributeChangedSignal(attribute):Connect(function()
		if window.Visible then refreshShop() end
	end)
end

openShopRemote.OnClientEvent:Connect(function(worldId)
	local world = GameConfig.GetWorld(worldId) or GameConfig.Worlds[1]
	if world ~= shopWorld or next(cards) == nil then
		shopWorld = world
		buildCards(world)
	end
	refreshShop()
	UIKit.open(window)
end)

shopMessageRemote.OnClientEvent:Connect(function(message, success)
	showHint(message, success and C.Mint or C.Coral)
end)
