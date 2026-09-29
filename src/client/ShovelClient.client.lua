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
-- SHOVEL POSE + DIG ANIMATION (for every player's character on this screen)
-- The real tool is hidden on this screen. A copy of the shovel is placed exactly where the
-- pose wants it every frame, both arms reach for its shaft with IK (so it's held with two
-- hands), and the torso leans and twists with the swing. Other players' swings arrive
-- through ShovelSwingFx, so everyone sees everyone dig.
---------------------------------------------------------------------
local Debris = game:GetService("Debris")
local ShovelModels = require(ReplicatedStorage:WaitForChild("ShovelModels"))
local swingFxRemote = remotes:WaitForChild("ShovelSwingFx")

-- Pose values, all relative to the HumanoidRootPart (+X right, +Y up, -Z forward):
-- Hand  = where the LEFT hand holds the top of the grip (studs). The right hand holds the
--         shaft a little lower down, so the shovel sits on the right side of the body.
-- Tilt  = shaft angle from straight down, degrees (+ = blade pushed forward, 90 = level)
-- Turn  = shovel yaw, degrees (+ = swings to the left, - = to the right)
-- Lean  = torso pitch (+ = bend forward), Twist = torso yaw (+ = turn left)
local IDLE = {Hand = Vector3.new(0.15, 0.85, -1.05), Tilt = 22, Turn = -12, Lean = 4, Twist = 6}
local SWING = {
	{0.00, IDLE.Hand, 22, -12, 4, 6},
	{0.26, Vector3.new(0.15, 1.85, -0.65), -6, -8, -10, 12},   -- wind up: lift it high, lean back
	{0.44, Vector3.new(0.25, 0.3, -1.3), 32, -6, 24, 0},       -- strike: drive the blade into the dirt
	{0.60, Vector3.new(0.3, 0.45, -1.05), 66, -12, 14, -6},    -- lever: pry the dirt up
	{0.78, Vector3.new(0.6, 1.3, -0.85), 82, -60, 4, -30},     -- toss it over the right shoulder
	{1.00, IDLE.Hand, 22, -12, 4, 6},
}
local STRIKE_TIME = 0.44
local TOSS_TIME = 0.78

-- tool axes when upright: shaft (+Z) points up, blade face (+Y) points forward
local UPRIGHT = CFrame.fromMatrix(Vector3.zero, Vector3.xAxis, -Vector3.zAxis, Vector3.yAxis)

-- smooth Catmull-Rom curve through the swing keyframes (never jerky)
local function catmull(p0, p1, p2, p3, u)
	local u2, u3 = u * u, u * u * u
	return (p1 * 2 + (p2 - p0) * u + (p0 * 2 - p1 * 5 + p2 * 4 - p3) * u2 + (p1 * 3 - p0 - p2 * 3 + p3) * u3) * 0.5
end

local function samplePose(t)
	t = math.clamp(t, 0, 1)
	local i = 1
	while i < #SWING - 1 and t > SWING[i + 1][1] do i += 1 end
	local k0, k1, k2, k3 = SWING[math.max(i - 1, 1)], SWING[i], SWING[i + 1], SWING[math.min(i + 2, #SWING)]
	local u = (t - k1[1]) / (k2[1] - k1[1])
	return {
		Hand = catmull(k0[2], k1[2], k2[2], k3[2], u),
		Tilt = catmull(k0[3], k1[3], k2[3], k3[3], u),
		Turn = catmull(k0[4], k1[4], k2[4], k3[4], u),
		Lean = catmull(k0[5], k1[5], k2[5], k3[5], u),
		Twist = catmull(k0[6], k1[6], k2[6], k3[6], u),
	}
end

-- gentle breathing sway while holding the shovel
local function idlePose(clock)
	local breathe = math.sin(clock * 2.2)
	return {
		Hand = IDLE.Hand + Vector3.new(0, breathe * 0.05, 0),
		Tilt = IDLE.Tilt + breathe * 1.5, Turn = IDLE.Turn,
		Lean = IDLE.Lean + breathe * 0.8, Twist = IDLE.Twist,
	}
end

local rigs = {} -- [character] = rig
local puppetFolder = Instance.new("Folder")
puppetFolder.Name = "ShovelPuppets"
puppetFolder.Parent = workspace

local function newAttachment(parent, name)
	local a = Instance.new("Attachment")
	a.Name = name
	a.Parent = parent
	return a
end

local function newArmIK(humanoid, name, upper, hand, target, pole)
	local ik = Instance.new("IKControl")
	ik.Name = name
	ik.Type = Enum.IKControlType.Position
	ik.ChainRoot = upper
	ik.EndEffector = hand
	ik.Target = target
	ik.Pole = pole
	ik.Weight = 1
	ik.SmoothTime = 0
	ik.Parent = humanoid
	return ik
end

local function destroyRig(character)
	local rig = rigs[character]
	if not rig then return end
	rigs[character] = nil
	for _, thing in ipairs(rig.Cleanup) do
		thing:Destroy()
	end
	if rig.Waist and rig.Waist.Parent then rig.Waist.C0 = rig.WaistC0 end
	if rig.Tool then
		for _, d in ipairs(rig.Tool:GetDescendants()) do
			if d:IsA("BasePart") then d.LocalTransparencyModifier = 0 end
		end
	end
end

local function createRig(character, tool)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	local upperTorso = character:FindFirstChild("UpperTorso")
	local parts = {
		RU = character:FindFirstChild("RightUpperArm"), RH = character:FindFirstChild("RightHand"),
		LU = character:FindFirstChild("LeftUpperArm"), LH = character:FindFirstChild("LeftHand"),
	}
	-- the two-handed pose needs an R15 body; R6 characters keep Roblox's default hold
	if not (humanoid and root and upperTorso and parts.RU and parts.RH and parts.LU and parts.LH) then return nil end
	local def = GameConfig.GetShovel(tool:GetAttribute("ShovelId"))
	if not def then return nil end

	-- the copy of the shovel we pose every frame
	local model = ShovelModels(def)
	local handle = model:FindFirstChild("Handle")
	local puppet = {}
	local bladePart
	for _, piece in ipairs(model:GetChildren()) do
		if piece:IsA("BasePart") and piece ~= handle then
			for _, c in ipairs(piece:GetChildren()) do
				if c:IsA("WeldConstraint") then c:Destroy() end
			end
			piece.Anchored = true
			piece.CanCollide = false
			piece.CanQuery = false
			piece.CanTouch = false
			table.insert(puppet, {Part = piece, Rel = handle.CFrame:ToObjectSpace(piece.CFrame)})
			if piece.Name == "Blade" or piece.Name == "DrillTip" then bladePart = piece end
		end
	end
	local holder = Instance.new("Model")
	holder.Name = character.Name .. "_Shovel"
	for _, p in ipairs(puppet) do p.Part.Parent = holder end
	holder.Parent = puppetFolder
	model:Destroy()

	-- hide the real tool on this screen (it still does the digging)
	for _, d in ipairs(tool:GetDescendants()) do
		if d:IsA("BasePart") then d.LocalTransparencyModifier = 1 end
	end

	local rightTarget = newAttachment(root, "ShovelRightHand")
	local leftTarget = newAttachment(root, "ShovelLeftHand")
	-- poles keep the elbows bending down and out, like a real person holding a shovel
	local rightPole = newAttachment(root, "ShovelRightElbow")
	rightPole.Position = Vector3.new(2.2, -1.2, 0.6)
	local leftPole = newAttachment(root, "ShovelLeftElbow")
	leftPole.Position = Vector3.new(-2.2, -1.2, 0.6)
	local rightIK = newArmIK(humanoid, "ShovelRightArm", parts.RU, parts.RH, rightTarget, rightPole)
	local leftIK = newArmIK(humanoid, "ShovelLeftArm", parts.LU, parts.LH, leftTarget, leftPole)

	local waist = upperTorso:FindFirstChild("Waist")
	local rig = {
		Tool = tool, Root = root, Puppet = puppet, Blade = bladePart or (puppet[#puppet] and puppet[#puppet].Part),
		TopZ = tool:GetAttribute("TopHoldZ") or 1.3,
		LowZ = tool:GetAttribute("LowHoldZ") or 0.5,
		RightTarget = rightTarget, LeftTarget = leftTarget,
		Waist = waist and waist:IsA("Motor6D") and waist or nil,
		WaistC0 = waist and waist:IsA("Motor6D") and waist.C0 or nil,
		SwingStart = nil, SwingLength = 0.6, Tossed = true,
		Cleanup = {holder, rightTarget, leftTarget, rightPole, leftPole, rightIK, leftIK},
	}
	rigs[character] = rig
	return rig
end

-- throws a few little dirt clumps off the blade
local function tossDirt(position, color)
	for i = 1, 5 do
		local clump = Instance.new("Part")
		clump.Shape = Enum.PartType.Ball
		clump.Size = Vector3.one * (0.35 + math.random() * 0.3)
		clump.Color = color
		clump.Material = Enum.Material.SmoothPlastic
		clump.CanCollide = false
		clump.CanQuery = false
		clump.CanTouch = false
		clump.CastShadow = false
		clump.CFrame = CFrame.new(position + Vector3.new(math.random() - 0.5, 0, math.random() - 0.5) * 0.6)
		clump.AssemblyLinearVelocity = Vector3.new(math.random() * 8 - 4, 14 + math.random() * 8, math.random() * 8 - 4)
		clump.Parent = puppetFolder
		Debris:AddItem(clump, 1.1 + i * 0.05)
	end
end

local function dirtColorAt(position)
	local world = GameConfig.GetWorldAt(position)
	local _, zone = GameConfig.GetZoneAt(world, position.Y - 3)
	return zone and zone.Color or Color3.fromRGB(150, 110, 80)
end

local function startSwing(character, length)
	local rig = character and rigs[character]
	if not rig then return end
	rig.SwingStart = os.clock()
	rig.SwingLength = length
	rig.Tossed = false
end

local function poseRig(character, rig, clock)
	local pose
	if rig.SwingStart then
		local t = (clock - rig.SwingStart) / rig.SwingLength
		if t >= 1 then
			rig.SwingStart = nil
			pose = idlePose(clock)
		else
			pose = samplePose(t)
			if not rig.Tossed and t >= TOSS_TIME then
				rig.Tossed = true
				if rig.Blade then
					tossDirt(rig.Blade.Position, dirtColorAt(rig.Root.Position))
				end
			end
		end
	else
		pose = idlePose(clock)
	end

	-- where the shovel goes (in root space): rotate the upright shovel by tilt and turn,
	-- then slide it along its shaft so the top of the grip sits exactly on pose.Hand
	local rotation = CFrame.Angles(0, math.rad(pose.Turn), 0) * CFrame.Angles(math.rad(pose.Tilt), 0, 0) * UPRIGHT
	local up = rotation.ZVector
	local origin = pose.Hand - up * rig.TopZ
	local shovelCF = rig.Root.CFrame * CFrame.new(origin) * rotation

	local parts, cframes = {}, {}
	for i, p in ipairs(rig.Puppet) do
		parts[i] = p.Part
		cframes[i] = shovelCF * p.Rel
	end
	workspace:BulkMoveTo(parts, cframes, Enum.BulkMoveMode.FireCFrameChanged)

	rig.LeftTarget.Position = pose.Hand -- left hand on top of the grip
	rig.RightTarget.Position = origin + up * rig.LowZ -- right hand lower on the shaft
	if rig.Waist then
		rig.Waist.C0 = rig.WaistC0 * CFrame.Angles(math.rad(-pose.Lean), math.rad(pose.Twist), 0)
	end
end

RunService.RenderStepped:Connect(function()
	local clock = os.clock()
	-- find every character holding a shovel; build or tear down rigs to match
	for _, plr in ipairs(Players:GetPlayers()) do
		local character = plr.Character
		if character then
			local tool = character:FindFirstChildOfClass("Tool")
			if tool and not tool:GetAttribute("ShovelId") then tool = nil end
			local rig = rigs[character]
			if rig and rig.Tool ~= tool then
				destroyRig(character)
				rig = nil
			end
			if tool and not rig then
				rig = createRig(character, tool)
			end
		end
	end
	for character, rig in pairs(rigs) do
		if not character.Parent or not rig.Root.Parent then
			destroyRig(character)
		else
			poseRig(character, rig, clock)
		end
	end
end)

swingFxRemote.OnClientEvent:Connect(function(otherPlayer, length)
	if typeof(otherPlayer) == "Instance" and otherPlayer:IsA("Player") and otherPlayer ~= player and typeof(length) == "number" then
		startSwing((otherPlayer :: Player).Character, math.clamp(length, 0.3, 1))
	end
end)

-- A small, smooth camera dip when the shovel hits the ground
local function impactDip()
	local start = os.clock()
	local conn
	conn = RunService.RenderStepped:Connect(function()
		local t = (os.clock() - start) / 0.2
		if t >= 1 then
			conn:Disconnect()
			return
		end
		local offset = math.sin(t * math.pi) * 0.16
		camera.CFrame = camera.CFrame * CFrame.new(0, -offset, 0)
	end)
end

local lastSwing = 0
local function onToolEquipped(tool)
	local def = GameConfig.GetShovel(tool:GetAttribute("ShovelId")) or GameConfig.Shovels[1]
	equippedDef = def
	depthPanel.Visible = true

	local activatedConn = tool.Activated:Connect(function()
		local now = os.clock()
		if now - lastSwing < def.Cooldown then return end
		lastSwing = now

		local length = math.clamp(def.Cooldown * 1.05, 0.45, 0.75)
		startSwing(player.Character, length)

		-- the dig happens exactly when the blade hits the ground
		local target = mouse.Hit and mouse.Hit.Position
		task.delay(length * STRIKE_TIME, function()
			swingRemote:FireServer(target, length)
			impactDip()
		end)
	end)

	tool.Unequipped:Once(function()
		activatedConn:Disconnect()
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
