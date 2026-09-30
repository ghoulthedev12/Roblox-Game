-- WorldMechanicsClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The player's side of the interactive world mechanics:
--   * Neon Sakura:   click a Meme Ghost to hit it with your capture beam (Gimmick_Spirits)
--   * Galaxy Drift:  gravity shifts deep in the pit (Gimmick_GravityShift)
--   * Frostbyte:     the Torch Flare button / F key (Gimmick_Permafrost)
--   * Chrome Dunes:  the curse trap quick-time event (Gimmick_CurseTraps)
--   * Glitch Nexus:  the data hacking rhythm minigame (Gimmick_DataHacking)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local gui = UIKit.screen(player, "WorldMechanicsGui", 7)

local function currentWorldId()
	return player:GetAttribute("CurrentWorld") or 1
end
local function container()
	local worlds = workspace:FindFirstChild("Worlds")
	return worlds and worlds:FindFirstChild("World" .. currentWorldId())
end
local function remote(name, callback)
	task.spawn(function()
		local r = remotes:WaitForChild(name, 60)
		if r and callback then r.OnClientEvent:Connect(callback) end
	end)
	return function(...)
		local r = remotes:FindFirstChild(name)
		if r then r:FireServer(...) end
	end
end
local function isClick(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

-- a big message in the middle of the screen (warnings)
local warning = UIKit.label(gui, "", {Size = UDim2.fromOffset(600, 50), Position = UDim2.fromScale(0.5, 0.3), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Sun, Stroke = 3, MaxText = 40})
warning.Visible = false
local warnToken = 0
local function alert(text, color, seconds)
	warnToken += 1
	local myToken = warnToken
	warning.Text = text
	warning.TextColor3 = color or C.Sun
	warning.Visible = true
	UIKit.pop(warning, 0.6)
	task.delay(seconds or 2, function()
		if warnToken == myToken then warning.Visible = false end
	end)
end

---------------------------------------------------------------------
-- MEME GHOSTS: click (or tap) a ghost to fire the capture beam at it
---------------------------------------------------------------------
local captureGhost = remote("CaptureGhost")
UserInputService.InputBegan:Connect(function(input)
	if not isClick(input) then return end
	local folder = container()
	local ghostFolder = folder and folder:FindFirstChild("Gimmick")
	if not ghostFolder then return end
	local point = input.UserInputType == Enum.UserInputType.Touch and input.Position or UserInputService:GetMouseLocation()
	local ray = input.UserInputType == Enum.UserInputType.Touch and camera:ScreenPointToRay(point.X, point.Y) or camera:ViewportPointToRay(point.X, point.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = {ghostFolder}
	-- a fat ray, so the fast little ghosts are fair to hit
	local hit = workspace:Spherecast(ray.Origin, 2, ray.Direction * 250, params)
	local ghost = hit and hit.Instance:FindFirstAncestor("MemeGhost")
	if ghost then captureGhost(ghost) end
end)

---------------------------------------------------------------------
-- GRAVITY SHIFTS (Galaxy Drift): gravity is simulated on our own screen, so we play it here
---------------------------------------------------------------------
local lastShift
RunService.Heartbeat:Connect(function()
	local folder = container()
	local shift = folder and folder:GetAttribute("GravityShift") or ""
	if shift == lastShift then return end
	lastShift = shift
	if shift == "" then
		player:SetAttribute("GravityOverride", nil)
		return
	end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local world = GameConfig.GetWorld(currentWorldId())
	local minDepth = folder:GetAttribute("GravityShiftDepth") or 150
	if not root or not world or world.Origin.Y - root.Position.Y < minDepth then return end
	local parts = string.split(shift, ":")
	local mode, angle = parts[1], math.rad(tonumber(parts[2]) or 0)
	if mode == "Up" then
		alert("⚠️ GRAVITY SHIFT! Gravity flips upward!", C.Lilac, 2.5)
		player:SetAttribute("GravityOverride", -30) -- WorldGimmickClient applies it
	else
		alert("⚠️ GRAVITY SHIFT! Gravity pulls sideways!", C.Lilac, 2.5)
		player:SetAttribute("GravityOverride", 25)
		local push = Vector3.new(math.cos(angle), 0.2, math.sin(angle)) * 40
		task.spawn(function()
			for _ = 1, 6 do
				if root.Parent then root.AssemblyLinearVelocity += push * 0.25 end
				task.wait(0.1)
			end
		end)
	end
end)

---------------------------------------------------------------------
-- TORCH FLARE (Frostbyte Tundra): F key or the button, while in a world that has it
---------------------------------------------------------------------
local torchFlare = remote("TorchFlare")
local flareButton = UIKit.button(gui, "🔥 FLARE [F]", {Size = UDim2.fromOffset(170, 50), Position = UDim2.new(1, -16, 1, -130), AnchorPoint = Vector2.new(1, 1), Color = C.Coral, MaxText = 20})
flareButton.Visible = false
local flareLabel = flareButton:FindFirstChild("Label")
local function fireFlare()
	if (player:GetAttribute("FlareReadyAt") or 0) <= os.time() then torchFlare() end
end
flareButton.MouseButton1Click:Connect(fireFlare)
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.F and flareButton.Visible then fireFlare() end
end)
task.spawn(function()
	while true do
		local folder = container()
		flareButton.Visible = folder ~= nil and folder:GetAttribute("TorchFlare") == true
		if flareButton.Visible and flareLabel then
			local now = os.time()
			local heat, ready = player:GetAttribute("HeatUntil") or 0, player:GetAttribute("FlareReadyAt") or 0
			if heat > now then
				flareLabel.Text = "🔥 HOT " .. (heat - now) .. "s"
				flareButton.BackgroundColor3 = C.Sun
			elseif ready > now then
				flareLabel.Text = "⏳ " .. (ready - now) .. "s"
				flareButton.BackgroundColor3 = C.Grey
			else
				flareLabel.Text = "🔥 FLARE [F]"
				flareButton.BackgroundColor3 = C.Coral
			end
		end
		task.wait(0.25)
	end
end)

---------------------------------------------------------------------
-- CURSE TRAP quick-time event (Chrome Dunes)
---------------------------------------------------------------------
local qte = UIKit.panel(gui, {Size = UDim2.fromOffset(360, 170), Position = UDim2.fromScale(0.5, 0.42), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Ink, Radius = 26, Stroke = 4, StrokeColor = C.Violet, Shade = false})
qte.BackgroundTransparency = 0.05
qte.Visible = false
UIKit.label(qte, "☠️ CURSE TRAP!", {Size = UDim2.new(1, -30, 0, 34), Position = UDim2.new(0.5, 0, 0, 12), AnchorPoint = Vector2.new(0.5, 0), Color = C.Lilac, Stroke = 0, MaxText = 30})
local qteKey = UIKit.button(qte, "PRESS [E]", {Size = UDim2.fromOffset(220, 60), Position = UDim2.new(0.5, 0, 0, 56), AnchorPoint = Vector2.new(0.5, 0), Color = C.Violet, MaxText = 28})
local qteTrack = UIKit.panel(qte, {Size = UDim2.new(1, -40, 0, 12), Position = UDim2.new(0.5, 0, 1, -24), AnchorPoint = Vector2.new(0.5, 0), Color = C.PanelTint, Radius = 6, Stroke = false, Shade = false})
local qteFill = UIKit.panel(qteTrack, {Size = UDim2.fromScale(1, 1), Color = C.Coral, Radius = 6, Stroke = false, Shade = false})
local curseTrap
local activeKey
local function answer(pressed)
	if not activeKey then return end
	activeKey = nil
	qte.Visible = false
	curseTrap(pressed)
end
curseTrap = remote("CurseTrap", function(key, limit)
	activeKey = key
	local qteLabel = qteKey:FindFirstChild("Label")
	if qteLabel then qteLabel.Text = "PRESS [" .. key .. "]" end
	qte.Visible = true
	UIKit.pop(qte, 0.6)
	qteFill.Size = UDim2.fromScale(1, 1)
	local start = os.clock()
	task.spawn(function()
		while activeKey == key and os.clock() - start < limit do
			qteFill.Size = UDim2.fromScale(1 - (os.clock() - start) / limit, 1)
			RunService.RenderStepped:Wait()
		end
		if activeKey == key then
			activeKey = nil
			qte.Visible = false -- too slow: the server fails it
		end
	end)
end)
qteKey.MouseButton1Click:Connect(function() answer(activeKey) end) -- tapping the button counts (mobile)
UserInputService.InputBegan:Connect(function(input)
	if not activeKey or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	local name = input.KeyCode.Name
	if #name == 1 then answer(name) end
end)

---------------------------------------------------------------------
-- DATA HACKING rhythm minigame (Glitch Nexus)
---------------------------------------------------------------------
local hack = UIKit.panel(gui, {Size = UDim2.fromOffset(340, 300), Position = UDim2.fromScale(0.5, 0.45), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Ink, Radius = 26, Stroke = 4, StrokeColor = C.Mint, Shade = false})
hack.BackgroundTransparency = 0.05
hack.Visible = false
UIKit.label(hack, "💾 HACKING DATA NODE", {Size = UDim2.new(1, -30, 0, 28), Position = UDim2.new(0.5, 0, 0, 12), AnchorPoint = Vector2.new(0.5, 0), Color = C.Mint, Stroke = 0, MaxText = 24})
UIKit.label(hack, "Tap / click / Space when the rings line up!", {Size = UDim2.new(1, -30, 0, 18), Position = UDim2.new(0.5, 0, 0, 42), AnchorPoint = Vector2.new(0.5, 0), Color = C.White, Stroke = 0, Font = UIKit.BodyFont, MaxText = 15})
local function ring(size, color, thickness)
	local r = Instance.new("Frame")
	r.BackgroundTransparency = 1
	r.Size = UDim2.fromOffset(size, size)
	r.Position = UDim2.new(0.5, 0, 0, 170)
	r.AnchorPoint = Vector2.new(0.5, 0.5)
	r.Parent = hack
	UIKit.corner(r, size)
	local s = Instance.new("UIStroke")
	s.Thickness = thickness
	s.Color = color
	s.Parent = r
	return r, s
end
ring(90, C.Mint, 6) -- the target ring
local beatRing, beatStroke = ring(260, C.Sky, 4)
local hackResult = UIKit.label(hack, "", {Size = UDim2.new(1, -30, 0, 26), Position = UDim2.new(0.5, 0, 1, -40), AnchorPoint = Vector2.new(0.5, 0), Color = C.White, Stroke = 2, MaxText = 22})
local dataNode = remote("DataNode", nil)
local hacking = nil -- {Beat, BeatStart, Hits, Tapped}
local WINDOW = 0.2   -- how close to the beat counts as a hit (seconds)
local function tap()
	if not hacking or hacking.Tapped then return end
	hacking.Tapped = true
	local off = math.abs(os.clock() - (hacking.BeatStart + hacking.BeatSeconds))
	if off <= WINDOW then
		hacking.Hits += 1
		hackResult.Text = "HIT! (" .. hacking.Hits .. ")"
		hackResult.TextColor3 = C.Mint
		beatStroke.Color = C.Mint
	else
		hackResult.Text = "MISS"
		hackResult.TextColor3 = C.Coral
		beatStroke.Color = C.Coral
	end
end
task.spawn(function()
	local r = remotes:WaitForChild("DataNode", 60)
	if not r then return end
	r.OnClientEvent:Connect(function(beats, beatSeconds)
		if hacking then return end
		hack.Visible = true
		UIKit.pop(hack, 0.6)
		hackResult.Text = ""
		hacking = {Hits = 0, BeatSeconds = beatSeconds}
		for beat = 1, beats do
			hacking.Beat = beat
			hacking.BeatStart = os.clock()
			hacking.Tapped = false
			beatStroke.Color = C.Sky
			-- the ring shrinks onto the target; tap when they line up (and a little after)
			while os.clock() - hacking.BeatStart < beatSeconds + WINDOW do
				local u = math.clamp((os.clock() - hacking.BeatStart) / beatSeconds, 0, 1.2)
				local size = 90 + (260 - 90) * (1 - u)
				beatRing.Size = UDim2.fromOffset(size, size)
				RunService.RenderStepped:Wait()
			end
		end
		local hits = hacking.Hits
		hacking = nil
		task.wait(0.3)
		hack.Visible = false
		dataNode(hits)
	end)
end)
UserInputService.InputBegan:Connect(function(input)
	if not hacking then return end
	if isClick(input) or input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA then tap() end
end)
