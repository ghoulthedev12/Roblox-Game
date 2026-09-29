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
local mini = UIKit.panel(gui, {Size = UDim2.fromOffset(460, 130), Position = UDim2.fromScale(0.5, 0.7), AnchorPoint = Vector2.new(0.5, 0.5), Radius = 22, Stroke = 4})
mini.Visible = false
local miniTab = UIKit.panel(mini, {Size = UDim2.new(0.7, 0, 0, 40), Position = UDim2.new(0.5, 0, 0, -18), AnchorPoint = Vector2.new(0.5, 0), Color = C.Sun, Radius = 14})
UIKit.label(miniTab, "LUCKY DIG!", {Size = UDim2.new(1, -16, 0.8, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 3})
UIKit.label(mini, "Stop in the green for bonus luck!", {Size = UDim2.new(0.9, 0, 0, 22), Position = UDim2.new(0.5, 0, 0, 30), AnchorPoint = Vector2.new(0.5, 0), Color = C.Ink, Stroke = 0})

local bar = UIKit.panel(mini, {Size = UDim2.new(0.9, 0, 0, 32), Position = UDim2.new(0.5, 0, 0, 60), AnchorPoint = Vector2.new(0.5, 0), Color = C.PanelTint, Radius = 16, Stroke = 3, Shade = false})
bar.ClipsDescendants = false

local goodZone = UIKit.panel(bar, {Size = UDim2.new(0.22, 0, 1, 0), Color = GRADE_COLORS.Good, Radius = 12, Stroke = false, Shade = false})

local perfectZone = UIKit.panel(goodZone, {Size = UDim2.new(0.3, 0, 1, 0), Position = UDim2.new(0.5, 0, 0, 0), AnchorPoint = Vector2.new(0.5, 0), Color = GRADE_COLORS.Perfect, Radius = 8, Stroke = false, Shade = false})

local marker = UIKit.panel(bar, {Size = UDim2.new(0, 12, 1.6, 0), Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.White, Radius = 6, Stroke = 3, Shade = false})
marker.ZIndex = 3

UIKit.label(mini, "Click, tap, or press Space", {Size = UDim2.new(0.9, 0, 0, 18), Position = UDim2.new(0.5, 0, 1, -24), AnchorPoint = Vector2.new(0.5, 0), Color = C.Grey, Stroke = 0})
local gradeText = UIKit.label(gui, "", {Size = UDim2.fromOffset(420, 72), Position = UDim2.fromScale(0.5, 0.58), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 4})
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
local popup = UIKit.panel(gui, {Size = UDim2.fromOffset(400, 250), Position = UDim2.fromScale(0.5, 0.42), AnchorPoint = Vector2.new(0.5, 0.5), Radius = 24, Stroke = 5})
popup.Visible = false
local popupStroke = popup:FindFirstChildOfClass("UIStroke")
local popupScale = Instance.new("UIScale")
popupScale.Parent = popup

local foundTab = UIKit.panel(popup, {Size = UDim2.new(0.62, 0, 0, 42), Position = UDim2.new(0.5, 0, 0, -20), AnchorPoint = Vector2.new(0.5, 0), Color = C.Violet, Radius = 14})
local foundLabel = UIKit.label(foundTab, "YOU FOUND", {Size = UDim2.new(1, -16, 0.78, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 3})
local nameLabel = UIKit.label(popup, "", {Size = UDim2.new(0.9, 0, 0, 38), Position = UDim2.new(0.5, 0, 0, 34), AnchorPoint = Vector2.new(0.5, 0), Color = C.Ink, Stroke = 0})
local rarityTag = UIKit.panel(popup, {Size = UDim2.fromOffset(190, 34), Position = UDim2.new(0.5, 0, 0, 78), AnchorPoint = Vector2.new(0.5, 0), Color = C.Lilac, Radius = 17})
local rarityLabel = UIKit.label(rarityTag, "", {Size = UDim2.new(1, -16, 0.8, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 3})
local incomeLabel = UIKit.label(popup, "", {Size = UDim2.new(0.9, 0, 0, 26), Position = UDim2.new(0.5, 0, 0, 120), AnchorPoint = Vector2.new(0.5, 0), Color = C.Money, Stroke = 2})
local descLabel = UIKit.label(popup, "", {Size = UDim2.new(0.86, 0, 0, 48), Position = UDim2.new(0.5, 0, 0, 152), AnchorPoint = Vector2.new(0.5, 0), Color = C.Grey, Stroke = 0, Font = Enum.Font.GothamMedium, TextSize = 15})
UIKit.label(popup, "Added to your inventory", {Size = UDim2.new(0.9, 0, 0, 18), Position = UDim2.new(0.5, 0, 1, -28), AnchorPoint = Vector2.new(0.5, 0), Color = C.Violet, Stroke = 0})

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
	rarityTag.BackgroundColor3 = info.Color
	popupStroke.Color = info.Color:Lerp(C.Ink, 0.35)
	incomeLabel.Text = ArtifactData.FormatMoney(info.Income) .. " / sec"
	descLabel.Text = info.Description
	foundLabel.Text = (info.Grade == "Perfect" and "PERFECT DIG!") or "YOU FOUND"

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

	task.delay(big and 6 or 4, function()
		if popupToken == myToken then
			popup.Visible = false
		end
	end)
end)

---------------------------------------------------------------------
-- RARE FIND ANNOUNCEMENTS (whole server)
---------------------------------------------------------------------
local banner = UIKit.panel(gui, {Size = UDim2.fromOffset(660, 56), Position = UDim2.new(0.5, 0, 0, 70), AnchorPoint = Vector2.new(0.5, 0), Radius = 28, Stroke = 4})
banner.Visible = false
local bannerStroke = banner:FindFirstChildOfClass("UIStroke")
local bannerStar = UIKit.panel(banner, {Size = UDim2.fromOffset(46, 46), Position = UDim2.new(0, 6, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Color = C.Sun, Radius = 23})
UIKit.label(bannerStar, "!", {Size = UDim2.fromScale(0.7, 0.7), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 3})
local bannerText = UIKit.label(banner, "", {Size = UDim2.new(1, -80, 0.62, 0), Position = UDim2.new(0, 62, 0.19, 0), Align = "Left", Color = C.Ink, Stroke = 0})

local bannerToken = 0
announceRemote.OnClientEvent:Connect(function(message, color)
	bannerToken += 1
	local myToken = bannerToken
	bannerText.Text = message
	bannerStar.BackgroundColor3 = typeof(color) == "Color3" and color or C.Sun
	bannerStroke.Color = C.Ink
	banner.Visible = true
	UIKit.pop(banner, 0.7)
	task.delay(6, function()
		if bannerToken == myToken then
			banner.Visible = false
		end
	end)
end)
