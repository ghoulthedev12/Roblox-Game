-- QuestClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The goals of worlds 2-9 on screen (see ReplicatedStorage.QuestData and the Quests server
-- module):
--   * QUEST TRACKER: top right, the quest you're on in the world you're in, with a progress
--     bar. Click it to open the Quests window.
--   * QUESTS WINDOW (the Quests button on the left, or UIBus "Quests"): two tabs.
--       QUESTS      each world's quest chain: done / current (with progress) / locked, the
--                   rewards, and World Mastery (+25% luck there) at the end
--       MEME INDEX  every meme of the world: found ones as their 3D model, the rest as "?",
--                   and the completion reward (+15% income from that world's memes)
--   * A big banner when a quest (or an index page) is completed.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local QuestData = require(ReplicatedStorage:WaitForChild("QuestData"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local UIBus = require(ReplicatedStorage:WaitForChild("UIBus"))
local Audio = require(ReplicatedStorage:WaitForChild("Audio"))
local C = UIKit.Colors
local rgb = Color3.fromRGB

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local updateRemote = remotes:WaitForChild("QuestUpdate")
local getState = remotes:WaitForChild("GetQuestState")

local GOLD = rgb(255, 196, 50)
local QUEST_WORLDS = {}
for worldId in pairs(QuestData.Worlds) do table.insert(QUEST_WORLDS, worldId) end
table.sort(QUEST_WORLDS)

local state = nil -- {Quests = {["2"] = {Step, Progress}}, Discovered = {ids}, IndexClaimed = {}}
local discovered = {}

local function worldMemes(worldId)
	local list = {}
	for _, artifact in ipairs(ArtifactData.Artifacts) do
		if artifact.World == worldId and not artifact.BaseId then table.insert(list, artifact) end
	end
	return list
end

local function questOf(worldId)
	local q = state and state.Quests[tostring(worldId)]
	return q or {Step = 1, Progress = 0}
end

local function isUnlocked(worldId)
	local list = player:GetAttribute("UnlockedWorlds") or ""
	for id in string.gmatch(list, "[^,]+") do
		if tonumber(id) == worldId then return true end
	end
	return false
end

local function rewardText(worldId, quest)
	local world = GameConfig.GetWorld(worldId)
	local cash = math.floor((world and world.Price or 0) * (quest.Cash or 0))
	return "+" .. ArtifactData.FormatMoney(cash) .. "  +" .. (quest.Gems or 0) .. " gems"
end

local gui = UIKit.screen(player, "QuestGui", 4)

-- a thin rounded progress bar (returns the fill frame)
local function bar(parent, props, fraction, color)
	local track = UIKit.panel(parent, {Size = props.Size, Position = props.Position, AnchorPoint = props.AnchorPoint,
		Color = rgb(225, 220, 245), Radius = 8, Stroke = 2, StrokeColor = rgb(90, 80, 130), Shade = false})
	local fill = UIKit.panel(track, {Size = UDim2.fromScale(math.clamp(fraction, 0, 1), 1), Color = color, Radius = 8, Stroke = false, ShadeAmount = 0.25})
	fill.Name = "Fill"
	fill.Visible = fraction > 0
	return fill, track
end

---------------------------------------------------------------------
-- QUEST TRACKER (top right)
---------------------------------------------------------------------
local tracker = Instance.new("TextButton")
tracker.Name = "QuestTracker"
tracker.Text = ""
tracker.AutoButtonColor = false
tracker.BackgroundColor3 = rgb(40, 32, 70)
tracker.BackgroundTransparency = 0.15
tracker.Size = UDim2.fromOffset(300, 92)
tracker.Position = UDim2.new(1, -128, 0, 164) -- under the world intro + event timers, left of the depth meter
tracker.AnchorPoint = Vector2.new(1, 0)
tracker.Visible = false
tracker.Parent = gui
UIKit.corner(tracker, 16)
UIKit.outline(tracker, 3, C.Outline)
UIKit.icon(tracker, "Star", {Size = UDim2.fromOffset(48, 48), Position = UDim2.new(0, 6, 0, 6)})
local trackerTitle = UIKit.label(tracker, "QUEST", {Size = UDim2.new(1, -66, 0, 24), Position = UDim2.fromOffset(58, 6), Align = "Left",
	Color = GOLD, Stroke = 2.5, MaxText = 20})
local trackerText = UIKit.label(tracker, "", {Size = UDim2.new(1, -66, 0, 36), Position = UDim2.fromOffset(58, 30), Align = "Left",
	Stroke = 2, MaxText = 17})
local trackerFill = bar(tracker, {Size = UDim2.new(1, -24, 0, 14), Position = UDim2.new(0.5, 0, 1, -10), AnchorPoint = Vector2.new(0.5, 1)}, 0, C.Mint)
local trackerCount = UIKit.label(trackerFill.Parent, "", {Size = UDim2.fromScale(1, 1.2), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
	Stroke = 2, MaxText = 13})
trackerCount.ZIndex = 3

local function refreshTracker()
	local worldId = player:GetAttribute("CurrentWorld") or 1
	local list = QuestData.Worlds[worldId]
	if not state or not list then
		tracker.Visible = false
		return
	end
	tracker.Visible = true
	local q = questOf(worldId)
	local quest = list[q.Step]
	if not quest then
		trackerTitle.Text = "WORLD MASTERED"
		trackerText.Text = "+25% luck here forever. Check the Meme Index!"
		trackerFill.Size = UDim2.fromScale(1, 1)
		trackerFill.Visible = true
		trackerCount.Text = QuestData.Count(worldId) .. "/" .. QuestData.Count(worldId) .. " quests"
		return
	end
	trackerTitle.Text = "QUEST " .. q.Step .. "/" .. #list
	trackerText.Text = quest.Text
	local fraction = q.Progress / quest.Goal
	trackerFill.Visible = fraction > 0
	TweenService:Create(trackerFill, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {Size = UDim2.fromScale(math.clamp(fraction, 0.04, 1), 1)}):Play()
	trackerCount.Text = q.Progress .. " / " .. quest.Goal
end

---------------------------------------------------------------------
-- QUESTS WINDOW
---------------------------------------------------------------------
local window, content = UIKit.window(gui, "Quests", UDim2.fromOffset(780, 540), rgb(255, 170, 40), "Star")
window.Name = "QuestWindow"

local tab = "Quests"
local selectedWorld = 2

local tabRow = Instance.new("Frame")
tabRow.BackgroundTransparency = 1
tabRow.Size = UDim2.new(1, 0, 0, 44)
tabRow.Parent = content
local questsTab = UIKit.button(tabRow, "QUESTS", {Size = UDim2.fromOffset(170, 42), Color = rgb(255, 170, 40), Icon = "Star", MaxText = 20})
local indexTab = UIKit.button(tabRow, "MEME INDEX", {Size = UDim2.fromOffset(200, 42), Position = UDim2.fromOffset(180, 0), Color = C.Lilac, Icon = "Picture", MaxText = 20})
questsTab.Name = "QuestsTab"
indexTab.Name = "IndexTab"
tabRow.Name = "Tabs"

local worldRow = Instance.new("Frame")
worldRow.BackgroundTransparency = 1
worldRow.Size = UDim2.new(1, 0, 0, 40)
worldRow.Position = UDim2.fromOffset(0, 52)
worldRow.Parent = content
local worldLayout = Instance.new("UIListLayout")
worldLayout.FillDirection = Enum.FillDirection.Horizontal
worldLayout.Padding = UDim.new(0, 6)
worldLayout.SortOrder = Enum.SortOrder.LayoutOrder
worldLayout.Parent = worldRow
local worldButtons = {}
for i, worldId in ipairs(QUEST_WORLDS) do
	local world = GameConfig.GetWorld(worldId)
	local short = world and string.match(world.Name, "^(%S+)") or ("World " .. worldId)
	local b = UIKit.button(worldRow, short, {Size = UDim2.new(1 / #QUEST_WORLDS, -6, 1, 0), Color = C.Sky, Radius = 10, MaxText = 15, Pattern = false})
	b.LayoutOrder = i
	worldButtons[worldId] = b
end

local body = Instance.new("Frame")
body.BackgroundTransparency = 1
body.Size = UDim2.new(1, 0, 1, -104)
body.Position = UDim2.fromOffset(0, 102)
body.Parent = content

local function clearBody()
	for _, child in ipairs(body:GetChildren()) do child:Destroy() end
end

local function drawQuests(worldId)
	local list = QuestData.Worlds[worldId] or {}
	local q = questOf(worldId)
	local mastered = q.Step > #list
	-- the mastery banner on top
	local banner = UIKit.panel(body, {Size = UDim2.new(1, -10, 0, 46), Color = mastered and GOLD or rgb(70, 60, 120), Radius = 12, Stroke = 2.5})
	UIKit.icon(banner, mastered and "Crown" or "Luck", {Size = UDim2.fromOffset(44, 44), Position = UDim2.new(0, 4, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)})
	UIKit.label(banner, mastered and "WORLD MASTERED!  +25% luck here forever"
		or ("Finish all " .. #list .. " quests to MASTER this world: +25% luck here forever"),
		{Size = UDim2.new(1, -64, 0.8, 0), Position = UDim2.new(0, 54, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Align = "Left", Stroke = 2.5, MaxText = 20})
	local scroller = UIKit.list(body, 8)
	scroller.Size = UDim2.new(1, 0, 1, -54)
	scroller.Position = UDim2.fromOffset(0, 54)
	if not isUnlocked(worldId) then
		local note = UIKit.panel(scroller, {Size = UDim2.new(1, -10, 0, 60), Color = C.Row, Radius = 12})
		UIKit.icon(note, "Lock", {Size = UDim2.fromOffset(46, 46), Position = UDim2.new(0, 8, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)})
		UIKit.label(note, "Unlock this world at the World Gate to start its quests.", {Size = UDim2.new(1, -74, 0.7, 0), Position = UDim2.new(0, 62, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5), Align = "Left", Color = C.Ink, Stroke = 0, MaxText = 20})
	end
	for i, quest in ipairs(list) do
		local done = i < q.Step
		local current = i == q.Step
		local row = UIKit.panel(scroller, {Size = UDim2.new(1, -10, 0, 64), Color = done and rgb(210, 250, 225) or (current and rgb(255, 245, 210) or C.Row),
			Radius = 12, Stroke = current and 3 or 2})
		row.LayoutOrder = i
		local badge = UIKit.panel(row, {Size = UDim2.fromOffset(44, 44), Position = UDim2.new(0, 10, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
			Color = done and C.Mint or (current and GOLD or rgb(180, 175, 200)), Radius = 22, Stroke = 2.5})
		if done then
			UIKit.icon(badge, "Star", {Size = UDim2.fromScale(0.9, 0.9), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5)})
		else
			UIKit.label(badge, tostring(i), {Size = UDim2.fromScale(0.7, 0.7), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
				Stroke = 2.5, MaxText = 24})
		end
		UIKit.label(row, quest.Text, {Size = UDim2.new(0.58, 0, 0, 26), Position = UDim2.new(0, 66, 0, current and 6 or 19), Align = "Left",
			Color = (done or current) and C.Ink or C.Grey, Stroke = 0, MaxText = 20})
		if current then
			local fill = bar(row, {Size = UDim2.new(0.56, 0, 0, 16), Position = UDim2.new(0, 66, 1, -10), AnchorPoint = Vector2.new(0, 1)},
				q.Progress / quest.Goal, C.Mint)
			UIKit.label(fill.Parent, q.Progress .. " / " .. quest.Goal, {Size = UDim2.fromScale(1, 1.2), Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2, MaxText = 13}).ZIndex = 3
		end
		UIKit.label(row, done and "DONE" or rewardText(worldId, quest), {Size = UDim2.new(0.3, -12, 0, 30), Position = UDim2.new(1, -12, 0.5, 0),
			AnchorPoint = Vector2.new(1, 0.5), Align = "Right", Color = done and C.Mint or rgb(40, 150, 70), Stroke = done and 2 or 0, MaxText = 18})
	end
end

local function drawIndex(worldId)
	local memes = worldMemes(worldId)
	local found = 0
	for _, artifact in ipairs(memes) do
		if discovered[artifact.Id] then found += 1 end
	end
	local claimed = state and state.IndexClaimed[tostring(worldId)]
	local banner = UIKit.panel(body, {Size = UDim2.new(1, -10, 0, 46), Color = claimed and C.Sky or rgb(70, 60, 120), Radius = 12, Stroke = 2.5})
	UIKit.icon(banner, claimed and "Crown" or "Picture", {Size = UDim2.fromOffset(44, 44), Position = UDim2.new(0, 4, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)})
	UIKit.label(banner, (claimed and "COMPLETE!  " or "") .. "Found " .. found .. " / " .. #memes .. "   ·   Find them all: +"
		.. math.floor(QuestData.IndexIncomeBonus * 100) .. "% income from these memes + " .. QuestData.IndexGems .. " gems",
		{Size = UDim2.new(1, -64, 0.8, 0), Position = UDim2.new(0, 54, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Align = "Left", Stroke = 2.5, MaxText = 19})
	local scroller = Instance.new("ScrollingFrame")
	scroller.BackgroundTransparency = 1
	scroller.BorderSizePixel = 0
	scroller.ScrollBarThickness = 8
	scroller.ScrollBarImageColor3 = C.Lilac
	scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroller.CanvasSize = UDim2.new()
	scroller.Size = UDim2.new(1, 0, 1, -54)
	scroller.Position = UDim2.fromOffset(0, 54)
	scroller.Parent = body
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.fromOffset(132, 150)
	grid.CellPadding = UDim2.fromOffset(10, 10)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = scroller
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 6)
	pad.PaddingLeft = UDim.new(0, 4)
	pad.Parent = scroller
	for i, artifact in ipairs(memes) do
		local cell = Instance.new("Frame")
		cell.BackgroundTransparency = 1
		cell.LayoutOrder = i
		cell.Parent = scroller
		if discovered[artifact.Id] then
			UIKit.artifactIcon(cell, artifact, {Size = UDim2.fromOffset(120, 116), Position = UDim2.new(0.5, 0, 0, 0), AnchorPoint = Vector2.new(0.5, 0)})
			UIKit.label(cell, artifact.Name, {Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 1, 0), AnchorPoint = Vector2.new(0, 1),
				Color = C.Ink, Stroke = 0, MaxText = 15})
		else
			local tile = UIKit.panel(cell, {Size = UDim2.fromOffset(120, 116), Position = UDim2.new(0.5, 0, 0, 0), AnchorPoint = Vector2.new(0.5, 0),
				Color = rgb(60, 54, 90), Radius = 16, Stroke = 3})
			UIKit.label(tile, "?", {Size = UDim2.fromScale(0.6, 0.6), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
				Color = rgb(170, 160, 210), Stroke = 3, MaxText = 60})
			local rarity = ArtifactData.GetRarity(artifact.Rarity)
			UIKit.label(cell, rarity and rarity.Secret and "Secret" or artifact.Rarity, {Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 1, 0),
				AnchorPoint = Vector2.new(0, 1), Color = rarity and rarity.Color or C.Grey, Stroke = 2, MaxText = 15})
		end
	end
end

local function redraw()
	if not window.Visible then return end
	clearBody()
	questsTab.BackgroundColor3 = tab == "Quests" and rgb(255, 170, 40) or C.Lilac
	indexTab.BackgroundColor3 = tab == "Index" and rgb(255, 170, 40) or C.Lilac
	for worldId, b in pairs(worldButtons) do
		local q = questOf(worldId)
		local mastered = q.Step > QuestData.Count(worldId)
		b.BackgroundColor3 = worldId == selectedWorld and GOLD or (not isUnlocked(worldId) and rgb(150, 145, 170) or (mastered and C.Mint or C.Sky))
	end
	if tab == "Quests" then drawQuests(selectedWorld) else drawIndex(selectedWorld) end
end

local function openWindow(which)
	tab = which or tab
	local here = player:GetAttribute("CurrentWorld") or 1
	if QuestData.Worlds[here] then selectedWorld = here end
	window.Visible = true
	UIKit.pop(window, 0.8)
	redraw()
end

questsTab.MouseButton1Click:Connect(function() tab = "Quests" redraw() end)
indexTab.MouseButton1Click:Connect(function() tab = "Index" redraw() end)
for worldId, b in pairs(worldButtons) do
	b.MouseButton1Click:Connect(function()
		selectedWorld = worldId
		redraw()
	end)
end
tracker.MouseButton1Click:Connect(function()
	if window.Visible then window.Visible = false else openWindow("Quests") end
end)
UIBus.On("Quests", function()
	if window.Visible then window.Visible = false else openWindow() end
end)
-- J for the quest journal (Q is taken by the curse traps in Chrome Dunes)
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.J then
		if window.Visible then window.Visible = false else openWindow() end
	end
end)

---------------------------------------------------------------------
-- QUEST COMPLETE banner
---------------------------------------------------------------------
local banner = UIKit.panel(gui, {Size = UDim2.fromOffset(520, 120), Position = UDim2.new(0.5, 0, 0, -140), AnchorPoint = Vector2.new(0.5, 0),
	Color = GOLD, Radius = 22, Stroke = 5, StrokeColor = C.Outline})
banner.Name = "QuestComplete"
banner.Visible = false
local bannerIcon = UIKit.icon(banner, "Star", {Size = UDim2.fromOffset(96, 96), Position = UDim2.new(0, 8, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)})
local bannerTitle = UIKit.label(banner, "QUEST COMPLETE!", {Size = UDim2.new(1, -120, 0, 40), Position = UDim2.fromOffset(108, 8), Align = "Left",
	Stroke = 3.5, MaxText = 34})
local bannerText = UIKit.label(banner, "", {Size = UDim2.new(1, -120, 0, 26), Position = UDim2.fromOffset(108, 48), Align = "Left",
	Color = C.Ink, Stroke = 0, MaxText = 20})
local bannerReward = UIKit.label(banner, "", {Size = UDim2.new(1, -120, 0, 30), Position = UDim2.fromOffset(108, 78), Align = "Left",
	Color = rgb(20, 120, 50), Stroke = 0, MaxText = 22})
local bannerToken = 0

local function showBanner(info)
	bannerToken += 1
	local token = bannerToken
	if info.Index then
		bannerTitle.Text = "MEME INDEX COMPLETE!"
		UIKit.setIcon(bannerIcon, "Picture")
	elseif info.Mastered then
		bannerTitle.Text = "WORLD MASTERED!"
		UIKit.setIcon(bannerIcon, "Crown")
	else
		bannerTitle.Text = "QUEST COMPLETE!"
		UIKit.setIcon(bannerIcon, "Star")
	end
	bannerText.Text = info.Text or ""
	bannerReward.Text = info.Reward or ""
	banner.Visible = true
	banner.Position = UDim2.new(0.5, 0, 0, -140)
	TweenService:Create(banner, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0, 96)}):Play()
	pcall(function() Audio.sfx("Find") end)
	task.delay(4, function()
		if bannerToken ~= token then return end
		local out = TweenService:Create(banner, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, 0, -140)})
		out:Play()
		out.Completed:Wait()
		if bannerToken == token then banner.Visible = false end
	end)
end

---------------------------------------------------------------------
-- STATE
---------------------------------------------------------------------
local function setState(newState)
	state = newState
	discovered = {}
	for _, id in ipairs(state and state.Discovered or {}) do discovered[id] = true end
	refreshTracker()
	redraw()
end

updateRemote.OnClientEvent:Connect(function(kind, payload)
	if kind == "State" then
		setState(payload)
	elseif kind == "Complete" and typeof(payload) == "table" then
		showBanner(payload)
	end
end)
player:GetAttributeChangedSignal("CurrentWorld"):Connect(refreshTracker)
player:GetAttributeChangedSignal("UnlockedWorlds"):Connect(redraw)

task.spawn(function()
	local ok, result = pcall(function() return getState:InvokeServer() end)
	if ok and result then setState(result) end
end)
