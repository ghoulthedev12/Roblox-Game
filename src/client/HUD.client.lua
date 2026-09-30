-- HUD (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The always-on screen: money, gems and income counters at the top center (with the world
-- you're in), a column of menu buttons on the left (Shop, Museum, Worlds, Rebirth, Bag,
-- Settings, Sound), and a custom hotbar that shows your pickaxe as a 3D icon.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors

local player = Players.LocalPlayer
local gui = UIKit.screen(player, "HUD", 1)

-- our own hotbar replaces the default one
task.spawn(function()
	for _ = 1, 20 do
		if pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false) end) then break end
		task.wait(0.5)
	end
end)

---------------------------------------------------------------------
-- CURRENCIES (top center): money, gems and museum income, with the world name under them
---------------------------------------------------------------------
local topBar = Instance.new("Frame")
topBar.BackgroundTransparency = 1
topBar.Size = UDim2.fromOffset(640, 76)
topBar.Position = UDim2.new(0.5, 0, 0, 8)
topBar.AnchorPoint = Vector2.new(0.5, 0)
topBar.Parent = gui
local counters = Instance.new("Frame")
counters.BackgroundTransparency = 1
counters.Size = UDim2.new(1, 0, 0, 46)
counters.Parent = topBar
local counterLayout = Instance.new("UIListLayout")
counterLayout.FillDirection = Enum.FillDirection.Horizontal
counterLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
counterLayout.VerticalAlignment = Enum.VerticalAlignment.Center
counterLayout.Padding = UDim.new(0, 14)
counterLayout.SortOrder = Enum.SortOrder.LayoutOrder
counterLayout.Parent = counters

-- a glossy colored pill with a round icon badge poking out on the left
local function pill(color, badgeColor, iconText, width, order)
	local height = 42
	local holder = Instance.new("Frame")
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.fromOffset(width + 12, height)
	holder.LayoutOrder = order
	holder.Parent = counters
	local p = UIKit.panel(holder, {Size = UDim2.new(1, -12, 1, 0), Position = UDim2.fromOffset(12, 0), Color = color, Radius = height / 2, ShadeAmount = 0.16})
	UIKit.badge(holder, iconText, badgeColor, {Diameter = height + 6, Position = UDim2.new(0, -4, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)})
	local text = UIKit.label(p, "", {Size = UDim2.new(1, -height - 6, 1, -12), Position = UDim2.new(0, height - 4, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
		Align = "Left", Stroke = 2.5, StrokeColor = UIKit.shadeColor(color, 0.6), MaxText = 26})
	return holder, text
end

local moneyPill, moneyText = pill(C.Money, C.Sun, "💵", 190, 1)
local _, gemText = pill(C.Violet, C.Lilac, "💎", 120, 2)
local _, incomeText = pill(C.Sun, C.White, "⚡", 170, 3)
local worldText = UIKit.label(topBar, "", {Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0.5, 0, 0, 52), AnchorPoint = Vector2.new(0.5, 0),
	Color = C.White, Stroke = 2, MaxText = 17})

local shownMoney = 0
local moneyScale = Instance.new("UIScale")
moneyScale.Parent = moneyPill
local function refreshMoney()
	local money = player:GetAttribute("Money") or 0
	if money > shownMoney + 0.5 then
		-- little bounce when money goes up
		moneyScale.Scale = 1.08
		TweenService:Create(moneyScale, TweenInfo.new(0.25, Enum.EasingStyle.Back), {Scale = 1}):Play()
	end
	shownMoney = money
	moneyText.Text = ArtifactData.FormatMoney(money)
end
local function refreshIncome()
	incomeText.Text = "+" .. ArtifactData.FormatMoney(player:GetAttribute("Income") or 0) .. "/s"
end
local function refreshGems()
	gemText.Text = tostring(player:GetAttribute("Gems") or 0)
end
local function refreshWorld()
	local world = GameConfig.GetWorld(player:GetAttribute("CurrentWorld") or 1)
	local rebirths = player:GetAttribute("Rebirths") or 0
	worldText.Text = "🌍 " .. (world and world.Name or "") .. (rebirths > 0 and ("   ♻️ Rebirth " .. rebirths) or "")
end
player:GetAttributeChangedSignal("Money"):Connect(refreshMoney)
player:GetAttributeChangedSignal("Income"):Connect(refreshIncome)
player:GetAttributeChangedSignal("Gems"):Connect(refreshGems)
player:GetAttributeChangedSignal("CurrentWorld"):Connect(refreshWorld)
player:GetAttributeChangedSignal("Rebirths"):Connect(refreshWorld)
refreshMoney()
refreshIncome()
refreshGems()
refreshWorld()

---------------------------------------------------------------------
-- MENU BUTTONS (left side): compact icon buttons with a label
---------------------------------------------------------------------
local UIBus = require(ReplicatedStorage:WaitForChild("UIBus"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local menu = Instance.new("Frame")
menu.BackgroundTransparency = 1
menu.Size = UDim2.fromOffset(76, 520)
menu.Position = UDim2.new(0, 12, 0.5, 10)
menu.AnchorPoint = Vector2.new(0, 0.5)
menu.Parent = gui
local menuLayout = Instance.new("UIListLayout")
menuLayout.Padding = UDim.new(0, 8)
menuLayout.VerticalAlignment = Enum.VerticalAlignment.Center
menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
menuLayout.Parent = menu

local menuButtons = {}
local function menuButton(order, icon, label, color, onClick, key)
	local b = UIKit.button(menu, "", {Size = UDim2.fromOffset(66, 64), Color = color, Radius = 18})
	b.LayoutOrder = order
	local emoji = Instance.new("TextLabel")
	emoji.Name = "Icon"
	emoji.BackgroundTransparency = 1
	emoji.Size = UDim2.new(1, 0, 0, 34)
	emoji.Position = UDim2.fromOffset(0, 6)
	emoji.Text = icon
	emoji.TextScaled = true
	emoji.Font = Enum.Font.GothamBold
	emoji.Parent = b
	UIKit.label(b, label .. (key and (" [" .. key .. "]") or ""), {Size = UDim2.new(1, -6, 0, 14), Position = UDim2.new(0.5, 0, 1, -18), AnchorPoint = Vector2.new(0.5, 0),
		Stroke = 1.5, StrokeColor = UIKit.shadeColor(color, 0.6), MaxText = 12})
	b.MouseButton1Click:Connect(onClick)
	menuButtons[label] = b
	return b
end

menuButton(1, "🛒", "SHOP", C.Mint, function() UIBus.Fire("Shop") end)
menuButton(2, "🏛️", "MUSEUM", C.Violet, function()
	local goHome = remotes:FindFirstChild("GoHome")
	if goHome then goHome:FireServer() end
end)
menuButton(3, "🌍", "WORLDS", C.Sky, function() UIBus.Fire("Teleport") end)
menuButton(4, "♻️", "REBIRTH", C.Coral, function() UIBus.Fire("Rebirth") end)
local bagButton = menuButton(5, "🎒", "BAG", C.Sun, function() UIBus.Fire("Inventory") end, "B")
menuButton(6, "⚙️", "SETTINGS", C.Grey, function() UIBus.Fire("Settings") end)
local soundButton = menuButton(7, "🔊", "SOUND", C.Lilac, function() UIBus.Fire("ToggleSound") end)
local function refreshSound()
	local icon = soundButton:FindFirstChild("Icon")
	if icon then icon.Text = player:GetAttribute("SoundMuted") and "🔇" or "🔊" end
end
player:GetAttributeChangedSignal("SoundMuted"):Connect(refreshSound)
refreshSound()
-- the bag bounces when something new goes in it
task.spawn(function()
	local changed = remotes:WaitForChild("InventoryChanged", 30)
	if changed then
		changed.OnClientEvent:Connect(function() UIKit.pop(bagButton, 1.3) end)
	end
end)

---------------------------------------------------------------------
-- HOTBAR (bottom center): one slot per tool, 3D icon for shovels
---------------------------------------------------------------------
local hotbar = Instance.new("Frame")
hotbar.BackgroundTransparency = 1
hotbar.Size = UDim2.fromOffset(400, 86)
hotbar.Position = UDim2.new(0.5, 0, 1, -12)
hotbar.AnchorPoint = Vector2.new(0.5, 1)
hotbar.Parent = gui
local hotbarLayout = Instance.new("UIListLayout")
hotbarLayout.FillDirection = Enum.FillDirection.Horizontal
hotbarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
hotbarLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
hotbarLayout.Padding = UDim.new(0, 10)
hotbarLayout.SortOrder = Enum.SortOrder.LayoutOrder
hotbarLayout.Parent = hotbar

local KEYS = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five}
local slots = {} -- {Tool, Button}

local function toggle(tool)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	if tool.Parent == character then
		humanoid:UnequipTools()
	else
		humanoid:EquipTool(tool)
	end
end

local function styleSlot(slot)
	local equipped = slot.Tool.Parent == player.Character
	slot.Button.BackgroundColor3 = equipped and C.Sun or C.Panel
	slot.Hint.Visible = not equipped
end

local function rebuild()
	local tools = {}
	for _, container in ipairs({player:FindFirstChild("Backpack"), player.Character}) do
		if container then
			for _, item in ipairs(container:GetChildren()) do
				if item:IsA("Tool") then table.insert(tools, item) end
			end
		end
	end
	table.sort(tools, function(a, b) return a.Name < b.Name end)
	-- same tools as before (e.g. one just got equipped)? only restyle, don't redraw icons
	local same = #tools == #slots
	for i, tool in ipairs(tools) do
		if not slots[i] or slots[i].Tool ~= tool then same = false end
	end
	if same then
		for _, slot in ipairs(slots) do styleSlot(slot) end
		return
	end
	for _, slot in ipairs(slots) do
		slot.Button:Destroy()
	end
	slots = {}
	for i, tool in ipairs(tools) do
		if i > #KEYS then break end
		local button = UIKit.button(hotbar, "", {Size = UDim2.fromOffset(78, 78), Color = C.Panel, Radius = 18})
		button.LayoutOrder = i
		local def = GameConfig.GetShovel(tool:GetAttribute("ShovelId"))
		if def then
			UIKit.shovelIcon(button, def, {Size = UDim2.fromScale(0.92, 0.92), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5)})
		else
			UIKit.label(button, tool.Name, {Size = UDim2.fromScale(0.9, 0.5), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Ink, Stroke = 0})
		end
		UIKit.badge(button, tostring(i), C.Violet, {Diameter = 26, Position = UDim2.fromOffset(-7, -7), Font = UIKit.Font, TextStroke = 0})
		local hint = UIKit.panel(button, {Size = UDim2.fromOffset(70, 24), Position = UDim2.new(0.5, 0, 0, -32), AnchorPoint = Vector2.new(0.5, 0), Color = C.Sun, Radius = 12})
		UIKit.label(hint, "EQUIP [" .. i .. "]", {Size = UDim2.new(1, -10, 1, -6), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2, StrokeColor = UIKit.shadeColor(C.Sun, 0.6)})
		local slot = {Tool = tool, Button = button, Hint = hint}
		button.MouseButton1Click:Connect(function() toggle(tool) end)
		table.insert(slots, slot)
		styleSlot(slot)
	end
end

local pending = false
local function queueRebuild()
	if pending then return end
	pending = true
	task.defer(function()
		pending = false
		rebuild()
	end)
end

local function watch(container)
	local function onChange(child)
		if child:IsA("Tool") then queueRebuild() end
	end
	container.ChildAdded:Connect(onChange)
	container.ChildRemoved:Connect(onChange)
end

local function onCharacter(character)
	watch(character)
	watch(player:WaitForChild("Backpack"))
	queueRebuild()
end
player.CharacterAdded:Connect(onCharacter)
if player.Character then onCharacter(player.Character) end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	for i, key in ipairs(KEYS) do
		if input.KeyCode == key and slots[i] then
			toggle(slots[i].Tool)
		end
	end
end)

-- keep the equipped highlight in sync (equipping moves the tool between Backpack and Character)
task.spawn(function()
	while true do
		task.wait(0.25)
		for _, slot in ipairs(slots) do
			if slot.Button.Parent then styleSlot(slot) end
		end
	end
end)
