-- HUD (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The always-on screen: big gem, money and income counters in the bottom left, the world
-- you're in at the top, a column of big menu icons on the left (Shop, Museum, Worlds,
-- Rebirth, Bag, Settings, Sound) with red alert badges, and a custom hotbar that shows your
-- pickaxe as a 3D icon.

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
-- CURRENCIES (bottom left): big chunky counters, no boxes: gems, money and income, each
-- with its icon and a thick dark outline. The world you're in sits at the top center.
---------------------------------------------------------------------
local wallet = Instance.new("Frame")
wallet.BackgroundTransparency = 1
wallet.Size = UDim2.fromOffset(330, 150)
wallet.Position = UDim2.new(0, 14, 1, -14)
wallet.AnchorPoint = Vector2.new(0, 1)
wallet.Parent = gui

local function counter(y, height, icon, color, maxText)
	local row = Instance.new("Frame")
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1, 0, 0, height)
	row.Position = UDim2.fromOffset(0, y)
	row.Parent = wallet
	local iconLabel = UIKit.label(row, icon, {Size = UDim2.fromOffset(height, height), Stroke = 0, MaxText = 80, Font = Enum.Font.GothamBold})
	iconLabel.Name = "Icon"
	local text = UIKit.label(row, "", {Size = UDim2.new(1, -height - 6, 1, -4), Position = UDim2.new(0, height + 6, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
		Align = "Left", Color = color, Stroke = 3.5, MaxText = maxText})
	return row, text
end
local _, gemText = counter(0, 40, "💎", Color3.fromRGB(230, 110, 255), 34)
local moneyRow, moneyText = counter(44, 52, "💵", Color3.fromRGB(80, 235, 90), 44)
local _, incomeText = counter(100, 30, "⚡", C.Sun, 24)

local worldText = UIKit.label(gui, "", {Size = UDim2.fromOffset(520, 26), Position = UDim2.new(0.5, 0, 0, 10), AnchorPoint = Vector2.new(0.5, 0),
	Color = C.White, Stroke = 3, MaxText = 22})

local shownMoney = 0
local moneyScale = Instance.new("UIScale")
moneyScale.Parent = moneyRow
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
-- MENU (left side): big icons with a bold label under them, no boxes, and a red alert
-- badge when something needs you (a pickaxe you can afford, a rebirth that's ready,
-- memes waiting in your bag)
---------------------------------------------------------------------
local UIBus = require(ReplicatedStorage:WaitForChild("UIBus"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local menu = Instance.new("Frame")
menu.BackgroundTransparency = 1
menu.Size = UDim2.fromOffset(96, 470)
menu.Position = UDim2.new(0, 8, 0, 58)
menu.AnchorPoint = Vector2.new(0, 0)
menu.Parent = gui
local menuLayout = Instance.new("UIListLayout")
menuLayout.Padding = UDim.new(0, 0)
menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
menuLayout.Parent = menu

local menuButtons = {}
local function menuButton(order, icon, label, onClick, key)
	local b = Instance.new("TextButton")
	b.Name = label
	b.Text = ""
	b.BackgroundTransparency = 1
	b.Size = UDim2.fromOffset(96, 66)
	b.LayoutOrder = order
	b.Parent = menu
	-- the icon, with a soft dark copy under it as a drop shadow
	for k, offset in ipairs({3, 0}) do
		local e = Instance.new("TextLabel")
		e.Name = k == 1 and "IconShadow" or "Icon"
		e.BackgroundTransparency = 1
		e.Size = UDim2.fromOffset(44, 44)
		e.Position = UDim2.new(0.5, offset, 0, offset)
		e.AnchorPoint = Vector2.new(0.5, 0)
		e.Text = icon
		e.TextScaled = true
		e.Font = Enum.Font.GothamBold
		if k == 1 then
			e.TextColor3 = Color3.new(0, 0, 0)
			e.TextTransparency = 0.55
		end
		e.Parent = b
	end
	UIKit.label(b, label .. (key and (" [" .. key .. "]") or ""), {Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0.5, 0, 0, 44), AnchorPoint = Vector2.new(0.5, 0),
		Stroke = 3, MaxText = 19})
	-- the red alert badge (hidden until something needs you)
	local alert = UIKit.panel(b, {Size = UDim2.fromOffset(28, 28), Position = UDim2.new(0.5, 26, 0, -4), AnchorPoint = Vector2.new(0.5, 0),
		Color = C.Coral, Radius = 14, Stroke = 2.5, StrokeColor = C.Outline, ShadeAmount = 0.15})
	alert.Name = "Alert"
	alert.Visible = false
	local alertText = UIKit.label(alert, "!", {Size = UDim2.fromScale(0.8, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2.5, MaxText = 18})
	local scale = Instance.new("UIScale")
	scale.Parent = b
	local function to(v, t)
		TweenService:Create(scale, TweenInfo.new(t or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = v}):Play()
	end
	b.MouseEnter:Connect(function() to(1.1) end)
	b.MouseLeave:Connect(function() to(1) end)
	b.MouseButton1Down:Connect(function() to(0.9, 0.06) end)
	b.MouseButton1Up:Connect(function() to(1.1) end)
	b.MouseButton1Click:Connect(function()
		require(ReplicatedStorage:WaitForChild("Audio")).sfx("Click")
		onClick()
	end)
	menuButtons[label] = b
	return b, function(text)
		alert.Visible = text ~= nil and text ~= ""
		if text then alertText.Text = text end
	end
end

local _, shopAlert = menuButton(1, "🛒", "Shop", function() UIBus.Fire("Shop") end)
menuButton(2, "🏛️", "Museum", function()
	local goHome = remotes:FindFirstChild("GoHome")
	if goHome then goHome:FireServer() end
end)
menuButton(3, "🌍", "Worlds", function() UIBus.Fire("Teleport") end)
local _, rebirthAlert = menuButton(4, "♻️", "Rebirth", function() UIBus.Fire("Rebirth") end)
local bagButton, bagAlert = menuButton(5, "🎒", "Bag", function() UIBus.Fire("Inventory") end, "B")
menuButton(6, "⚙️", "Settings", function() UIBus.Fire("Settings") end)
local soundButton = menuButton(7, "🔊", "Sound", function() UIBus.Fire("ToggleSound") end)
local function refreshSound()
	local icon = player:GetAttribute("SoundMuted") and "🔇" or "🔊"
	for _, name in ipairs({"Icon", "IconShadow"}) do
		local e = soundButton:FindFirstChild(name)
		if e then e.Text = icon end
	end
end
player:GetAttributeChangedSignal("SoundMuted"):Connect(refreshSound)
refreshSound()

-- ALERTS
local function refreshAlerts()
	local money = player:GetAttribute("Money") or 0
	rebirthAlert(money >= GameConfig.RebirthCost(player:GetAttribute("Rebirths") or 0) and "!" or nil)
	-- a pickaxe in this world you don't own yet but can afford
	local world = GameConfig.GetWorld(player:GetAttribute("CurrentWorld") or 1)
	local owned = {}
	for _, id in ipairs(string.split(player:GetAttribute("OwnedShovels") or "", ",")) do owned[id] = true end
	local canBuy = false
	for _, def in ipairs(world and world.Shovels or {}) do
		if not owned[def.Id] and def.Price > 0 and money >= def.Price then
			canBuy = true
			break
		end
	end
	shopAlert(canBuy and "!" or nil)
end
for _, attribute in ipairs({"Money", "Rebirths", "OwnedShovels", "CurrentWorld"}) do
	player:GetAttributeChangedSignal(attribute):Connect(refreshAlerts)
end
refreshAlerts()

-- the bag shows how many memes are waiting in it (not on display yet), and bounces when one arrives
task.spawn(function()
	local changed = remotes:WaitForChild("InventoryChanged", 30)
	local getInventory = remotes:WaitForChild("GetInventory", 30)
	local function refreshBag()
		local ok, list = pcall(function() return getInventory:InvokeServer() end)
		if not ok or type(list) ~= "table" then return end
		local count = 0
		for _, item in ipairs(list) do count += item.Count or 1 end
		bagAlert(count > 0 and (count > 99 and "99+" or tostring(count)) or nil)
	end
	if changed then
		changed.OnClientEvent:Connect(function()
			UIKit.pop(bagButton, 1.3)
			refreshBag()
		end)
	end
	if getInventory then refreshBag() end
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
