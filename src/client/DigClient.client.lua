-- DigClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Shows the luck minigame, the "you found" popup, and rare-find announcements.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local minigameRemote = remotes:WaitForChild("DigMinigame")
local resultRemote = remotes:WaitForChild("DigResult")
local announceRemote = remotes:WaitForChild("Announcement")

local player = Players.LocalPlayer

---------------------------------------------------------------------
-- UI
---------------------------------------------------------------------
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local GRADE_COLORS = {
	Perfect = C.Mint,
	Good = C.Sun,
	Miss = C.Coral,
}

local gui = UIKit.screen(player, "DigGui", 5)

---------------------------------------------------------------------
-- MINIGAME
---------------------------------------------------------------------
-- a small card with a colored header strip (used by the minigame and the find popup)
local function headerCard(size, position, color, title)
	local card = UIKit.panel(gui, {Size = size, Position = position, AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Panel, Radius = 24, Stroke = 4, StrokeColor = C.Ink, ShadeAmount = 0.05})
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.BorderSizePixel = 0
	header.Size = UDim2.new(1, 0, 0, 50)
	header.Parent = card
	UIKit.corner(header, 22)
	local fill = Instance.new("Frame")
	fill.BorderSizePixel = 0
	fill.AnchorPoint = Vector2.new(0, 1)
	fill.Position = UDim2.fromScale(0, 1)
	fill.Size = UDim2.new(1, 0, 0, 22)
	fill.Parent = header
	local edge = Instance.new("Frame")
	edge.BorderSizePixel = 0
	edge.AnchorPoint = Vector2.new(0, 1)
	edge.Position = UDim2.fromScale(0, 1)
	edge.Size = UDim2.new(1, 0, 0, 4)
	edge.Parent = header
	local titleLabel = UIKit.label(header, title, {Size = UDim2.new(1, -40, 0, 30), Position = UDim2.new(0.5, 0, 0.5, -2), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 3, MaxText = 28})
	local titleStroke = titleLabel:FindFirstChildOfClass("UIStroke")
	local function paint(c)
		header.BackgroundColor3 = c
		fill.BackgroundColor3 = c
		edge.BackgroundColor3 = UIKit.shadeColor(c, 0.35)
		if titleStroke then titleStroke.Color = UIKit.shadeColor(c, 0.6) end
	end
	paint(color)
	return card, titleLabel, paint
end

local mini = headerCard(UDim2.fromOffset(480, 160), UDim2.fromScale(0.5, 0.7), C.Sun, "🍀 LUCKY DIG!")
mini.Visible = false
UIKit.label(mini, "Stop in the green for bonus luck!", {Size = UDim2.new(0.9, 0, 0, 22), Position = UDim2.new(0.5, 0, 0, 58), AnchorPoint = Vector2.new(0.5, 0), Color = C.Ink, Stroke = 0, MaxText = 20})

local bar = UIKit.panel(mini, {Size = UDim2.new(0.88, 0, 0, 30), Position = UDim2.new(0.5, 0, 0, 88), AnchorPoint = Vector2.new(0.5, 0), Color = C.PanelTint, Radius = 15, Stroke = 3, StrokeColor = C.Ink, Shade = false})
bar.ClipsDescendants = false

local goodZone = UIKit.panel(bar, {Size = UDim2.new(0.22, 0, 1, 0), Color = GRADE_COLORS.Good, Radius = 12, Stroke = false})

local perfectZone = UIKit.panel(goodZone, {Size = UDim2.new(0.3, 0, 1, 0), Position = UDim2.new(0.5, 0, 0, 0), AnchorPoint = Vector2.new(0.5, 0), Color = GRADE_COLORS.Perfect, Radius = 8, Stroke = false})

local marker = UIKit.panel(bar, {Size = UDim2.new(0, 12, 1.6, 0), Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.White, Radius = 6, Stroke = 3, StrokeColor = C.Ink, Shade = false})
marker.ZIndex = 3

UIKit.label(mini, "Click, tap, or press Space", {Size = UDim2.new(0.9, 0, 0, 16), Position = UDim2.new(0.5, 0, 1, -26), AnchorPoint = Vector2.new(0.5, 0), Color = C.Grey, Stroke = 0, Font = UIKit.BodyFont, MaxText = 14})
local gradeText = UIKit.label(gui, "", {Size = UDim2.fromOffset(420, 72), Position = UDim2.fromScale(0.5, 0.58), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 5, MaxText = 64})
gradeText.Visible = false

local playing = false
local SPEED = 1.3 -- how fast the marker moves (bar widths per second)

local function showGrade(grade)
	gradeText.Text = string.upper(grade) .. (grade == "Miss" and "" or "!")
	gradeText.TextColor3 = GRADE_COLORS[grade]
	gradeText.Visible = true
	UIKit.pop(gradeText, 0.4)
	task.delay(0.8, function()
		gradeText.Visible = false
	end)
end

local function startMinigame()
	if playing then return end
	playing = true

	-- random zone position each time
	local zoneStart = math.random(10, 68) / 100
	goodZone.Position = UDim2.new(zoneStart, 0, 0, 0)
	local zoneWidth = goodZone.Size.X.Scale
	local perfectWidth = zoneWidth * perfectZone.Size.X.Scale
	local zoneCenter = zoneStart + zoneWidth / 2

	mini.Visible = true
	UIKit.pop(mini)
	local t = 0
	local position = 0
	local renderConn, inputConn
	local done = false

	local function finish(grade)
		if done then return end
		done = true
		playing = false
		renderConn:Disconnect()
		inputConn:Disconnect()
		mini.Visible = false
		showGrade(grade)
		minigameRemote:FireServer(grade)
	end

	renderConn = RunService.RenderStepped:Connect(function(dt)
		t += dt * SPEED
		local cycle = t % 2
		position = (cycle <= 1) and cycle or (2 - cycle) -- bounce left and right
		marker.Position = UDim2.new(position, 0, 0.5, 0)
	end)

	inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		local isClick = input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		local isKey = input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA
		if not (isClick or isKey) then return end
		if gameProcessed and isClick then return end

		local distance = math.abs(position - zoneCenter)
		if distance <= perfectWidth / 2 then
			finish("Perfect")
		elseif distance <= zoneWidth / 2 then
			finish("Good")
		else
			finish("Miss")
		end
	end)

	-- give up after a few seconds
	task.delay(6, function()
		finish("Miss")
	end)
end

minigameRemote.OnClientEvent:Connect(startMinigame)

---------------------------------------------------------------------
-- "YOU FOUND" POPUP
---------------------------------------------------------------------
local claimRemote = remotes:WaitForChild("ClaimFind")

local popup, foundLabel, paintPopupHeader = headerCard(UDim2.fromOffset(460, 368), UDim2.fromScale(0.5, 0.45), C.Violet, "YOU FOUND")
popup.Visible = false
local popupStroke = popup:FindFirstChildOfClass("UIStroke")
local popupScale = Instance.new("UIScale")
popupScale.Parent = popup

local iconHolder = Instance.new("Frame")
iconHolder.BackgroundTransparency = 1
iconHolder.Size = UDim2.fromOffset(112, 112)
iconHolder.Position = UDim2.fromOffset(22, 66)
iconHolder.Parent = popup
local nameLabel = UIKit.label(popup, "", {Size = UDim2.new(1, -170, 0, 34), Position = UDim2.fromOffset(150, 66), Align = "Left", Color = C.Ink, Stroke = 0, MaxText = 28})
local rarityTag = UIKit.panel(popup, {Size = UDim2.fromOffset(150, 28), Position = UDim2.fromOffset(150, 106), Color = C.Lilac, Radius = 14})
local rarityLabel = UIKit.label(rarityTag, "", {Size = UDim2.new(1, -16, 0.76, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2.5, StrokeColor = C.Ink, MaxText = 20})
local incomePill = UIKit.panel(popup, {Size = UDim2.fromOffset(170, 32), Position = UDim2.fromOffset(150, 142), Color = C.Money, Radius = 16})
local incomeLabel = UIKit.label(incomePill, "", {Size = UDim2.new(1, -18, 0.72, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2.5, StrokeColor = UIKit.shadeColor(C.Money, 0.6), MaxText = 20})
local descBox = UIKit.panel(popup, {Size = UDim2.new(1, -44, 0, 62), Position = UDim2.new(0.5, 0, 0, 190), AnchorPoint = Vector2.new(0.5, 0), Color = C.PanelTint, Radius = 14, Stroke = false, Shade = false})
local descLabel = UIKit.label(descBox, "", {Size = UDim2.new(1, -24, 1, -12), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Grey, Stroke = 0, Font = UIKit.BodyFont, TextSize = 15})

local pickButton = UIKit.button(popup, "PICK UP  [E]", {Size = UDim2.new(0.5, -28, 0, 56), Position = UDim2.new(0, 22, 1, -94), Color = C.Mint})
local leaveButton = UIKit.button(popup, "LEAVE IT", {Size = UDim2.new(0.5, -28, 0, 56), Position = UDim2.new(1, -22, 1, -94), AnchorPoint = Vector2.new(1, 0), Color = C.Coral})
-- countdown: the find is left in the dirt when this runs out
local timerTrack = UIKit.panel(popup, {Size = UDim2.new(1, -44, 0, 12), Position = UDim2.new(0.5, 0, 1, -26), AnchorPoint = Vector2.new(0.5, 0), Color = C.PanelTint, Radius = 6, Stroke = 2, StrokeColor = C.Lilac, Shade = false})
local timerFill = UIKit.panel(timerTrack, {Size = UDim2.fromScale(1, 1), Color = C.Sun, Radius = 6, Stroke = false})

local flash = Instance.new("Frame")
flash.Size = UDim2.fromScale(1, 1)
flash.BackgroundTransparency = 1
flash.BorderSizePixel = 0
flash.ZIndex = 0
flash.Parent = gui

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

-- the find visibly pops out of the hole: a glowing orb in the rarity's color jumps out of
-- the ground and arcs into the player's hands, then the popup shows
local heldOrb -- the orb floating above the player while they decide

-- what happens to the floating orb: picked up (flies into the player) or left (drops and fades)
local function finishOrb(take)
	local orb = heldOrb
	heldOrb = nil
	if not orb then return end
	orb:SetAttribute("Done", true)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local goal = take and root and root.Position or (orb.Position - Vector3.new(0, 6, 0))
	local tween = TweenService:Create(orb, TweenInfo.new(take and 0.3 or 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In),
		{Position = goal, Size = Vector3.one * (take and 0.2 or 0.6), Transparency = take and 0 or 1})
	tween:Play()
	tween.Completed:Once(function() orb:Destroy() end)
end

local function treasurePop(position, color, onArrive)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if typeof(position) ~= "Vector3" or not root then
		onArrive()
		return
	end
	local orb = Instance.new("Part")
	orb.Shape = Enum.PartType.Ball
	orb.Size = Vector3.one * 1.6
	orb.Material = Enum.Material.Neon
	orb.Color = color
	orb.Anchored = true
	orb.CanCollide = false
	orb.CanQuery = false
	orb.CanTouch = false
	orb.CastShadow = false
	orb.CFrame = CFrame.new(position)
	orb.Parent = workspace
	local light = Instance.new("PointLight")
	light.Color = color
	light.Range = 10
	light.Brightness = 1
	light.Parent = orb
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Color = ColorSequence.new(color)
	sparkle.LightEmission = 0.6
	sparkle.Size = NumberSequence.new(0.35, 0)
	sparkle.Lifetime = NumberRange.new(0.4, 0.7)
	sparkle.Rate = 40
	sparkle.Speed = NumberRange.new(1, 3)
	sparkle.SpreadAngle = Vector2.new(180, 180)
	sparkle.Parent = orb

	local start = os.clock()
	local DURATION = 0.6
	local conn
	conn = RunService.RenderStepped:Connect(function()
		local t = (os.clock() - start) / DURATION
		local goal = root.Parent and (root.Position + Vector3.new(0, 4.5, 0)) or position
		if t >= 1 then
			conn:Disconnect()
			-- float above the player's head, bobbing, until they pick it up or leave it
			heldOrb = orb
			local bob
			bob = RunService.RenderStepped:Connect(function()
				if orb:GetAttribute("Done") or not orb.Parent or not root.Parent then
					bob:Disconnect()
					return
				end
				local c = os.clock()
				orb.CFrame = CFrame.new(root.Position + Vector3.new(0, 4.5 + math.sin(c * 3) * 0.3, 0)) * CFrame.Angles(0, c * 2, 0)
			end)
			onArrive()
			return
		end
		-- pop straight up first, then arc over into the player
		local ease = t * t * (3 - 2 * t)
		local pos = position:Lerp(goal, ease) + Vector3.new(0, math.sin(t * math.pi) * 7, 0)
		local spin = CFrame.Angles(0, t * 12, 0)
		local size = 1.6 * (1 + math.sin(t * math.pi) * 0.5) * (1 - t * 0.5)
		orb.Size = Vector3.one * size
		orb.CFrame = CFrame.new(pos) * spin
	end)
end

local popupToken = 0
local awaiting -- popup token of the find waiting for a choice

local function choose(take)
	if not awaiting then return end
	awaiting = nil
	claimRemote:FireServer(take)
	popup.Visible = false
	finishOrb(take)
end
pickButton.MouseButton1Click:Connect(function() choose(true) end)
leaveButton.MouseButton1Click:Connect(function() choose(false) end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.E and awaiting then
		choose(true)
	end
end)

resultRemote.OnClientEvent:Connect(function(info)
	popupToken += 1
	local myToken = popupToken
	local sound = GameConfig.Sounds and GameConfig.Sounds.Find
	if sound and sound ~= "" then
		local s = Instance.new("Sound")
		s.SoundId = sound
		s.Volume = 0.7
		s.Parent = workspace.CurrentCamera
		s:Play()
		game:GetService("Debris"):AddItem(s, 4)
	end
	treasurePop(info.Position, info.Color, function()
		if popupToken ~= myToken then return end

		for _, child in ipairs(iconHolder:GetChildren()) do child:Destroy() end
		UIKit.artifactIcon(iconHolder, {Id = info.Id, Rarity = info.Rarity}, {Size = UDim2.fromScale(1, 1), Radius = 20})
		nameLabel.Text = info.Name
		rarityLabel.Text = string.upper(info.Rarity)
		rarityTag.BackgroundColor3 = info.Color
		popupStroke.Color = info.Color:Lerp(C.Ink, 0.45)
		paintPopupHeader(info.Color:Lerp(C.Violet, 0.25))
		incomeLabel.Text = "💵 " .. ArtifactData.FormatMoney(info.Income) .. "/s"
		descLabel.Text = info.Description
		foundLabel.Text = (info.Grade == "Perfect" and "✨ PERFECT DIG! ✨") or "YOU FOUND A MEME!"

		-- pop-in animation
		popup.Visible = true
		popupScale.Scale = 0.3
		TweenService:Create(popupScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()

		-- big finds (Legendary and up) flash the screen
		local big = info.RarityIndex >= ArtifactData.GetRarityIndex("Legendary")
		if big then
			flash.BackgroundColor3 = info.Color
			flash.BackgroundTransparency = 0.55
			TweenService:Create(flash, TweenInfo.new(1.2), {BackgroundTransparency = 1}):Play()
		end

		-- wait for the player's choice; the countdown bar shrinks until the find is left behind
		local timeout = tonumber(info.Timeout) or 20
		timerFill.Size = UDim2.fromScale(1, 1)
		TweenService:Create(timerFill, TweenInfo.new(timeout, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(0, 1)}):Play()
		awaiting = myToken
		task.delay(timeout, function()
			if awaiting == myToken then
				awaiting = nil
				popup.Visible = false
				finishOrb(false)
			end
		end)
	end)
end)

---------------------------------------------------------------------
-- RARE FIND ANNOUNCEMENTS (whole server)
---------------------------------------------------------------------
local banner = UIKit.panel(gui, {Size = UDim2.fromOffset(640, 54), Position = UDim2.new(0.5, 0, 0, 14), AnchorPoint = Vector2.new(0.5, 0), Color = C.Ink, Radius = 27, Stroke = 3, StrokeColor = C.Sun, ShadeAmount = 0.2})
banner.BackgroundTransparency = 0.08
banner.Visible = false
local bannerStroke = banner:FindFirstChildOfClass("UIStroke")
local bannerStar = UIKit.badge(banner, "🎉", C.Sun, {Diameter = 44, Position = UDim2.new(0, 6, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)})
local bannerText = UIKit.label(banner, "", {Size = UDim2.new(1, -80, 0.56, 0), Position = UDim2.new(0, 62, 0.22, 0), Align = "Left", Color = C.White, Stroke = 0, MaxText = 24})

local bannerToken = 0
announceRemote.OnClientEvent:Connect(function(message, color)
	bannerToken += 1
	local myToken = bannerToken
	bannerText.Text = message
	local accent = typeof(color) == "Color3" and color or C.Sun
	bannerStar.BackgroundColor3 = accent
	bannerStroke.Color = accent
	banner.Visible = true
	UIKit.pop(banner, 0.7)
	task.delay(6, function()
		if bannerToken == myToken then
			banner.Visible = false
		end
	end)
end)
