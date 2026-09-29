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
-- UI HELPERS
---------------------------------------------------------------------
local DARK = Color3.fromRGB(18, 20, 32)
local CYAN = Color3.fromRGB(0, 225, 255)
local GRADE_COLORS = {
	Perfect = Color3.fromRGB(90, 255, 120),
	Good = Color3.fromRGB(255, 210, 60),
	Miss = Color3.fromRGB(255, 80, 80),
}

local gui = Instance.new("ScreenGui")
gui.Name = "DigGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 12)
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

local function frame(parent, size, position, color, transparency)
	local f = Instance.new("Frame")
	f.Size = size
	f.Position = position
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.BackgroundColor3 = color
	f.BackgroundTransparency = transparency or 0
	f.BorderSizePixel = 0
	f.Parent = parent
	return f
end

local function label(parent, text, size, position, color, font)
	local l = Instance.new("TextLabel")
	l.Size = size
	l.Position = position
	l.AnchorPoint = Vector2.new(0.5, 0.5)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = color
	l.Font = font or Enum.Font.GothamBold
	l.TextScaled = true
	l.TextWrapped = true
	l.Parent = parent
	return l
end

---------------------------------------------------------------------
-- MINIGAME
---------------------------------------------------------------------
local mini = frame(gui, UDim2.new(0, 440, 0, 120), UDim2.new(0.5, 0, 0.74, 0), DARK, 0.15)
mini.Visible = false
corner(mini, 14)
stroke(mini, CYAN, 2)
local miniTitle = label(mini, "HIT THE GLOWING ZONE FOR BONUS LUCK!", UDim2.new(0.9, 0, 0, 22), UDim2.new(0.5, 0, 0, 20), Color3.new(1, 1, 1), Enum.Font.GothamBlack)

local bar = frame(mini, UDim2.new(0.9, 0, 0, 28), UDim2.new(0.5, 0, 0, 58), Color3.fromRGB(45, 48, 62))
corner(bar, 8)
bar.ClipsDescendants = false

local goodZone = Instance.new("Frame")
goodZone.BackgroundColor3 = GRADE_COLORS.Good
goodZone.BorderSizePixel = 0
goodZone.Size = UDim2.new(0.22, 0, 1, 0)
goodZone.Parent = bar
corner(goodZone, 6)

local perfectZone = Instance.new("Frame")
perfectZone.BackgroundColor3 = GRADE_COLORS.Perfect
perfectZone.BorderSizePixel = 0
perfectZone.AnchorPoint = Vector2.new(0.5, 0)
perfectZone.Position = UDim2.new(0.5, 0, 0, 0)
perfectZone.Size = UDim2.new(0.3, 0, 1, 0) -- 30% of the good zone
perfectZone.Parent = goodZone

local marker = Instance.new("Frame")
marker.BackgroundColor3 = Color3.new(1, 1, 1)
marker.BorderSizePixel = 0
marker.AnchorPoint = Vector2.new(0.5, 0.5)
marker.Size = UDim2.new(0, 6, 1.5, 0)
marker.Position = UDim2.new(0, 0, 0.5, 0)
marker.ZIndex = 3
marker.Parent = bar
corner(marker, 3)

local hint = label(mini, "Click, tap, or press Space", UDim2.new(0.9, 0, 0, 18), UDim2.new(0.5, 0, 0, 98), Color3.fromRGB(180, 185, 200), Enum.Font.GothamMedium)
local gradeText = label(gui, "", UDim2.new(0, 400, 0, 70), UDim2.new(0.5, 0, 0.6, 0), Color3.new(1, 1, 1), Enum.Font.GothamBlack)
gradeText.Visible = false
stroke(gradeText, Color3.new(0, 0, 0), 3).ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual

local playing = false
local SPEED = 1.3 -- how fast the marker moves (bar widths per second)

local function showGrade(grade)
	gradeText.Text = string.upper(grade) .. (grade == "Miss" and "" or "!")
	gradeText.TextColor3 = GRADE_COLORS[grade]
	gradeText.Visible = true
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
local popup = frame(gui, UDim2.new(0, 380, 0, 230), UDim2.new(0.5, 0, 0.42, 0), DARK, 0.05)
popup.Visible = false
corner(popup, 16)
local popupStroke = stroke(popup, Color3.new(1, 1, 1), 4)
local popupScale = Instance.new("UIScale")
popupScale.Parent = popup

local foundLabel = label(popup, "YOU FOUND", UDim2.new(0.9, 0, 0, 20), UDim2.new(0.5, 0, 0, 22), Color3.fromRGB(180, 185, 200), Enum.Font.GothamBold)
local nameLabel = label(popup, "", UDim2.new(0.9, 0, 0, 36), UDim2.new(0.5, 0, 0, 56), Color3.new(1, 1, 1), Enum.Font.GothamBlack)
local rarityLabel = label(popup, "", UDim2.new(0.9, 0, 0, 26), UDim2.new(0.5, 0, 0, 90), Color3.new(1, 1, 1), Enum.Font.GothamBlack)
local incomeLabel = label(popup, "", UDim2.new(0.9, 0, 0, 22), UDim2.new(0.5, 0, 0, 120), Color3.fromRGB(90, 255, 120), Enum.Font.GothamBold)
local descLabel = label(popup, "", UDim2.new(0.88, 0, 0, 46), UDim2.new(0.5, 0, 0, 164), Color3.fromRGB(200, 205, 215), Enum.Font.GothamMedium)
descLabel.TextScaled = false
descLabel.TextSize = 15
local footerLabel = label(popup, "Added to your inventory", UDim2.new(0.9, 0, 0, 16), UDim2.new(0.5, 0, 0, 208), Color3.fromRGB(140, 145, 160), Enum.Font.GothamMedium)

local flash = Instance.new("Frame")
flash.Size = UDim2.fromScale(1, 1)
flash.BackgroundTransparency = 1
flash.BorderSizePixel = 0
flash.ZIndex = 0
flash.Parent = gui

local popupToken = 0
resultRemote.OnClientEvent:Connect(function(info)
	popupToken += 1
	local myToken = popupToken

	nameLabel.Text = info.Name
	rarityLabel.Text = string.upper(info.Rarity)
	rarityLabel.TextColor3 = info.Color
	popupStroke.Color = info.Color
	incomeLabel.Text = ArtifactData.FormatMoney(info.Income) .. " / sec"
	descLabel.Text = info.Description
	foundLabel.Text = (info.Grade == "Perfect" and "PERFECT DIG! YOU FOUND") or "YOU FOUND"

	-- pop-in animation
	popup.Visible = true
	popupScale.Scale = 0.3
	TweenService:Create(popupScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()

	-- big finds (Legendary and up) flash the screen
	local big = info.RarityIndex >= ArtifactData.GetRarityIndex("Legendary")
	if big then
		flash.BackgroundColor3 = info.Color
		flash.BackgroundTransparency = 0.35
		TweenService:Create(flash, TweenInfo.new(1.2), {BackgroundTransparency = 1}):Play()
	end

	task.delay(big and 6 or 4, function()
		if popupToken == myToken then
			popup.Visible = false
		end
	end)
end)

---------------------------------------------------------------------
-- RARE FIND ANNOUNCEMENTS (whole server)
---------------------------------------------------------------------
local banner = frame(gui, UDim2.new(0, 640, 0, 52), UDim2.new(0.5, 0, 0, 90), DARK, 0.1)
banner.Visible = false
corner(banner, 12)
local bannerStroke = stroke(banner, Color3.new(1, 1, 1), 3)
local bannerText = label(banner, "", UDim2.new(0.94, 0, 0.7, 0), UDim2.new(0.5, 0, 0.5, 0), Color3.new(1, 1, 1), Enum.Font.GothamBlack)

local bannerToken = 0
announceRemote.OnClientEvent:Connect(function(message, color)
	bannerToken += 1
	local myToken = bannerToken
	bannerText.Text = "🌟 " .. message
	bannerText.TextColor3 = color
	bannerStroke.Color = color
	banner.Visible = true
	task.delay(6, function()
		if bannerToken == myToken then
			banner.Visible = false
		end
	end)
end)
