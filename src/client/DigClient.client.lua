-- DigClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Shows the luck minigame, the short "you found" lines, and rare-find announcements.

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
-- FIND MESSAGES: just a line of text near the top of the screen that fades away
---------------------------------------------------------------------
local pullRemote = remotes:WaitForChild("PullFind")

local function textLine(y, size)
	local l = UIKit.label(gui, "", {Size = UDim2.fromOffset(640, size), Position = UDim2.new(0.5, 0, 0, y), AnchorPoint = Vector2.new(0.5, 0),
		Color = C.White, Stroke = 2.5, MaxText = size})
	l.Visible = false
	return l, l:FindFirstChildOfClass("UIStroke")
end
local foundText, foundStroke = textLine(262, 30)
local hintText, hintStroke = textLine(298, 20)

local tokens = {}
local function say(label, stroke, text, color, duration)
	tokens[label] = (tokens[label] or 0) + 1
	local myToken = tokens[label]
	label.Text = text
	label.TextColor3 = color
	label.TextTransparency = 0
	if stroke then
		stroke.Color = color:Lerp(Color3.new(0, 0, 0), 0.7)
		stroke.Transparency = 0
	end
	label.Visible = true
	UIKit.pop(label, 0.8)
	task.delay(duration, function()
		if tokens[label] ~= myToken then return end
		local fade = TweenInfo.new(0.5)
		TweenService:Create(label, fade, {TextTransparency = 1}):Play()
		if stroke then TweenService:Create(stroke, fade, {Transparency = 1}):Play() end
		task.delay(0.5, function()
			if tokens[label] == myToken then label.Visible = false end
		end)
	end)
end
local function unsay(label)
	tokens[label] = (tokens[label] or 0) + 1
	label.Visible = false
end

---------------------------------------------------------------------
-- BURIED FIND: one line of text + an outline on the object while it waits in the crater
---------------------------------------------------------------------
local buriedHighlight
local function clearBuried()
	unsay(hintText)
	if buriedHighlight then
		buriedHighlight:Destroy()
		buriedHighlight = nil
	end
end

-- other players' finds can't be pulled by us: hide their prompts on this screen
local findsFolder = workspace:WaitForChild("BuriedFinds", 30)
if findsFolder then
	local function check(d)
		if d:IsA("ProximityPrompt") then
			local model = d:FindFirstAncestorOfClass("Model")
			local owner = model and model:GetAttribute("Owner")
			if owner and owner ~= player.UserId then d.Enabled = false end
		end
	end
	findsFolder.DescendantAdded:Connect(check)
	for _, d in ipairs(findsFolder:GetDescendants()) do check(d) end
end

local Audio = require(ReplicatedStorage:WaitForChild("Audio"))
local function playFindSound()
	Audio.sfx("Find")
end

resultRemote.OnClientEvent:Connect(function(info)
	clearBuried()
	playFindSound()
	local timeout = tonumber(info.Timeout) or 25
	say(hintText, hintStroke, "You uncovered something " .. string.upper(info.Rarity) .. "!  Hold E to pull it out", info.Color:Lerp(C.White, 0.3), timeout)
	if typeof(info.Painting) == "Instance" then
		local model = info.Painting
		buriedHighlight = Instance.new("Highlight")
		buriedHighlight.FillTransparency = 0.9
		buriedHighlight.FillColor = info.Color
		buriedHighlight.OutlineColor = info.Color:Lerp(C.White, 0.3)
		buriedHighlight.OutlineTransparency = 0.35
		-- occluded: the part that's still under the dirt stays hidden
		buriedHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
		buriedHighlight.Adornee = model
		buriedHighlight.Parent = gui
		local highlight = buriedHighlight
		model.AncestryChanged:Connect(function()
			if not model:IsDescendantOf(workspace) and buriedHighlight == highlight then clearBuried() end
		end)
	end
end)

---------------------------------------------------------------------
-- "YOU FOUND X": once it's pulled out
---------------------------------------------------------------------
pullRemote.OnClientEvent:Connect(function(finder, _painting, info)
	if finder ~= player or typeof(info) ~= "table" then return end
	clearBuried()
	task.delay(0.9, function()
		say(foundText, foundStroke, "✨ You found " .. info.Name .. "!  " .. string.upper(info.Rarity) .. "  ·  +"
			.. ArtifactData.FormatMoney(info.Income) .. "/s", info.Color:Lerp(C.White, 0.25), 3.5)
	end)
end)

---------------------------------------------------------------------
-- RARE FIND ANNOUNCEMENTS (whole server)
---------------------------------------------------------------------
local banner = UIKit.panel(gui, {Size = UDim2.fromOffset(640, 54), Position = UDim2.new(0.5, 0, 0, 196), AnchorPoint = Vector2.new(0.5, 0), Color = C.Ink, Radius = 27, Stroke = 3, StrokeColor = C.Sun, ShadeAmount = 0.2})
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
