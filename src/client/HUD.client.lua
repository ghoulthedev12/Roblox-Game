-- HUD (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The always-on screen, in a big chunky style:
--   * TOP: three wide studded buttons (Shop, Museum, Worlds) with the world you're in under them
--   * LEFT: a column of big 3D menu icons (Bag, Rebirth, Settings, Sound) with bold labels and
--     red alert badges
--   * BOTTOM LEFT: large gem and money counters, income under them
--   * BOTTOM CENTER: a hotbar of square slots (name on top, key number in the corner, 3D icon)
--   * BOTTOM RIGHT: colored progress stats (pickaxes owned, worlds unlocked, rebirths)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local UIBus = require(ReplicatedStorage:WaitForChild("UIBus"))
local C = UIKit.Colors
local rgb = Color3.fromRGB

local player = Players.LocalPlayer
local gui = UIKit.screen(player, "HUD", 1)
local remotes = ReplicatedStorage:WaitForChild("Remotes")

-- our own hotbar replaces the default one
task.spawn(function()
	for _ = 1, 20 do
		if pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false) end) then break end
		task.wait(0.5)
	end
end)

local function click()
	require(ReplicatedStorage:WaitForChild("Audio")).sfx("Click")
end

-- a red alert badge (a "!" or a number) on the top-right corner of something
local function alertBadge(parent, size, position)
	local alert = UIKit.panel(parent, {Size = UDim2.fromOffset(size, size), Position = position, AnchorPoint = Vector2.new(0.5, 0.5),
		Color = rgb(236, 48, 64), Radius = 999, Stroke = 3, StrokeColor = C.Outline, ShadeAmount = 0.15})
	alert.Name = "Alert"
	alert.ZIndex = 5
	alert.Visible = false
	local text = UIKit.label(alert, "!", {Size = UDim2.fromScale(0.74, 0.74), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
		Stroke = 2.5, MaxText = 26})
	text.ZIndex = 6
	return function(value)
		alert.Visible = value ~= nil and value ~= ""
		if value then text.Text = value end
	end
end

---------------------------------------------------------------------
-- TOP: three big studded buttons, and the world you're in under them
---------------------------------------------------------------------
local TOP_W, TOP_H, TOP_GAP = 180, 64, 12 -- 180 wide keeps clear of the world tips at the top right
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.BackgroundTransparency = 1
topBar.Size = UDim2.fromOffset(TOP_W * 3 + TOP_GAP * 2, TOP_H + 36)
topBar.Position = UDim2.new(0.5, 0, 0, 8)
topBar.AnchorPoint = Vector2.new(0.5, 0)
topBar.Parent = gui

local function topButton(index, text, color, onClick)
	local b = UIKit.button(topBar, text, {Size = UDim2.fromOffset(TOP_W, TOP_H), Position = UDim2.fromOffset((index - 1) * (TOP_W + TOP_GAP), 0),
		Color = color, Radius = 10, MaxText = 40})
	b.Name = text
	b.MouseButton1Click:Connect(onClick)
	return b, alertBadge(b, 30, UDim2.new(1, -4, 0, 4))
end

local _, shopAlert = topButton(1, "Shop", rgb(48, 170, 255), function() UIBus.Fire("Shop") end)
topButton(2, "Museum", rgb(52, 200, 70), function()
	local goHome = remotes:FindFirstChild("GoHome")
	if goHome then goHome:FireServer() end
end)
topButton(3, "Worlds", rgb(236, 56, 72), function() UIBus.Fire("Teleport") end)

local worldText = UIKit.label(topBar, "", {Size = UDim2.new(1, 40, 0, 28), Position = UDim2.new(0.5, 0, 0, TOP_H + 6), AnchorPoint = Vector2.new(0.5, 0),
	Color = C.White, Stroke = 3, MaxText = 26})

---------------------------------------------------------------------
-- LEFT: big 3D menu icons with a soft dark disc behind them and a bold label under them
---------------------------------------------------------------------
local ICON_ROW = 104
local menu = Instance.new("Frame")
menu.BackgroundTransparency = 1
menu.Size = UDim2.fromOffset(112, 4 * ICON_ROW)
menu.Position = UDim2.new(0, 10, 0, 70)
menu.Parent = gui
local menuLayout = Instance.new("UIListLayout")
menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
menuLayout.Parent = menu

local function menuButton(order, icon, label, onClick, key, labelColor)
	local b = Instance.new("TextButton")
	b.Name = label
	b.Text = ""
	b.BackgroundTransparency = 1
	b.Size = UDim2.fromOffset(112, ICON_ROW)
	b.LayoutOrder = order
	b.Parent = menu
	local disc = UIKit.panel(b, {Size = UDim2.fromOffset(78, 78), Position = UDim2.new(0.5, 0, 0, 6), AnchorPoint = Vector2.new(0.5, 0),
		Color = Color3.new(0, 0, 0), Radius = 999, Stroke = false, Shade = false})
	disc.BackgroundTransparency = 0.7
	UIKit.icon(b, icon, {Size = UDim2.fromOffset(92, 92), Position = UDim2.new(0.5, 0, 0, -4), AnchorPoint = Vector2.new(0.5, 0)})
	local caption = UIKit.label(b, label .. (key and (" [" .. key .. "]") or ""), {Size = UDim2.new(1, 4, 0, 26), Position = UDim2.new(0.5, 0, 0, 74),
		AnchorPoint = Vector2.new(0.5, 0), Color = labelColor or C.White, Stroke = 3.5, MaxText = 24})
	caption.ZIndex = 2
	local setAlert = alertBadge(b, 34, UDim2.new(0.5, 36, 0, 12))
	local scale = Instance.new("UIScale")
	scale.Parent = b
	local function to(v, t)
		TweenService:Create(scale, TweenInfo.new(t or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = v}):Play()
	end
	b.MouseEnter:Connect(function() to(1.08) end)
	b.MouseLeave:Connect(function() to(1) end)
	b.MouseButton1Down:Connect(function() to(0.9, 0.06) end)
	b.MouseButton1Up:Connect(function() to(1.08) end)
	b.MouseButton1Click:Connect(function()
		click()
		onClick()
	end)
	return b, setAlert
end

local bagButton, bagAlert = menuButton(1, "Bag", "Bag", function() UIBus.Fire("Inventory") end, "B", C.Sun)
local _, rebirthAlert = menuButton(2, "Rebirth", "Rebirth", function() UIBus.Fire("Rebirth") end)
menuButton(3, "Settings", "Settings", function() UIBus.Fire("Settings") end)
local soundButton = menuButton(4, "SoundOn", "Sound", function() UIBus.Fire("ToggleSound") end)
local function refreshSound()
	local holder = soundButton:FindFirstChild("Icon")
	if holder then UIKit.setIcon(holder, player:GetAttribute("SoundMuted") and "SoundOff" or "SoundOn") end
end
player:GetAttributeChangedSignal("SoundMuted"):Connect(refreshSound)
refreshSound()

---------------------------------------------------------------------
-- BOTTOM LEFT: big gem and money counters, income under them
---------------------------------------------------------------------
local wallet = Instance.new("Frame")
wallet.BackgroundTransparency = 1
wallet.Size = UDim2.fromOffset(380, 168)
wallet.Position = UDim2.new(0, 12, 1, -10)
wallet.AnchorPoint = Vector2.new(0, 1)
wallet.Parent = gui

local function counter(y, height, icon, color, maxText)
	local row = Instance.new("Frame")
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1, 0, 0, height)
	row.Position = UDim2.fromOffset(0, y)
	row.Parent = wallet
	if icon then
		UIKit.icon(row, icon, {Size = UDim2.fromOffset(height * 1.35, height * 1.35), Position = UDim2.new(0, -height * 0.12, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)})
	end
	local indent = icon and height * 1.2 + 4 or 4
	local text = UIKit.label(row, "", {Size = UDim2.new(1, -indent, 1, 0), Position = UDim2.new(0, indent, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
		Align = "Left", Color = color, Stroke = 4, MaxText = maxText})
	return row, text
end
local _, gemText = counter(0, 48, "Gem", rgb(222, 70, 255), 44)
local moneyRow, moneyText = counter(52, 66, "Cash", rgb(70, 240, 70), 60)
local _, incomeText = counter(124, 36, nil, C.White, 30)

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
	incomeText.Text = "Income: +" .. ArtifactData.FormatMoney(player:GetAttribute("Income") or 0) .. "/s"
end
local function refreshGems()
	gemText.Text = tostring(player:GetAttribute("Gems") or 0)
end
local function refreshWorld()
	local world = GameConfig.GetWorld(player:GetAttribute("CurrentWorld") or 1)
	local rebirths = player:GetAttribute("Rebirths") or 0
	worldText.Text = (world and world.Name or "") .. (rebirths > 0 and ("  -  Rebirth " .. rebirths) or "")
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
-- BOTTOM RIGHT: colored progress stats, each with its icon on the right
---------------------------------------------------------------------
local stats = Instance.new("Frame")
stats.BackgroundTransparency = 1
stats.Size = UDim2.fromOffset(300, 3 * 38)
stats.Position = UDim2.new(1, -12, 1, -10)
stats.AnchorPoint = Vector2.new(1, 1)
stats.Parent = gui

local function stat(index, icon, color)
	local row = Instance.new("Frame")
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1, 0, 0, 38)
	row.Position = UDim2.fromOffset(0, (index - 1) * 38)
	row.Parent = stats
	UIKit.icon(row, icon, {Size = UDim2.fromOffset(42, 42), Position = UDim2.new(1, 4, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5)})
	return UIKit.label(row, "", {Size = UDim2.new(1, -44, 1, -2), Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
		Align = "Right", Color = color, Stroke = 3.5, MaxText = 30})
end
local pickaxeStat = stat(1, "Pickaxe", rgb(255, 210, 60))
local worldStat = stat(2, "World", rgb(90, 200, 255))
local rebirthStat = stat(3, "Rebirth", rgb(255, 110, 150))

local function refreshStats()
	local world = GameConfig.GetWorld(player:GetAttribute("CurrentWorld") or 1)
	local owned = {}
	for _, id in ipairs(string.split(player:GetAttribute("OwnedShovels") or "", ",")) do owned[id] = true end
	local have, total = 0, 0
	for _, def in ipairs(world and world.Shovels or {}) do
		total += 1
		if owned[def.Id] or def.Price == 0 then have += 1 end
	end
	pickaxeStat.Text = ("Pickaxes: %d/%d"):format(have, total)
	local unlocked = #string.split(player:GetAttribute("UnlockedWorlds") or "1", ",")
	worldStat.Text = ("Worlds: %d/%d"):format(unlocked, #GameConfig.Worlds)
	rebirthStat.Text = ("Rebirths: %d"):format(player:GetAttribute("Rebirths") or 0)
end
for _, attribute in ipairs({"OwnedShovels", "CurrentWorld", "UnlockedWorlds", "Rebirths"}) do
	player:GetAttributeChangedSignal(attribute):Connect(refreshStats)
end
refreshStats()

---------------------------------------------------------------------
-- ALERTS: a pickaxe you can afford, a rebirth that's ready, memes waiting in your bag
---------------------------------------------------------------------
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
-- HOTBAR (bottom center): square slots with the tool's name on top, its key number in the
-- corner and a 3D icon; the equipped one gets a thick golden ring
---------------------------------------------------------------------
local SLOT = 96
local hotbar = Instance.new("Frame")
hotbar.BackgroundTransparency = 1
hotbar.Size = UDim2.fromOffset(5 * (SLOT + 10), SLOT + 10)
hotbar.Position = UDim2.new(0.5, 0, 1, -10)
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
local slots = {} -- {Tool, Button, Ring}

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
	slot.Ring.Visible = slot.Tool.Parent == player.Character
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
		local def = GameConfig.GetShovel(tool:GetAttribute("ShovelId"))
		local color = def and rgb(150, 90, 240) or rgb(48, 170, 255)
		local button = UIKit.button(hotbar, "", {Size = UDim2.fromOffset(SLOT, SLOT), Color = color, Radius = 10, Pattern = false})
		button.LayoutOrder = i
		if def then
			UIKit.shovelIcon(button, def, {Size = UDim2.fromScale(0.86, 0.86), Position = UDim2.fromScale(0.5, 0.56), AnchorPoint = Vector2.new(0.5, 0.5)})
		end
		local name = UIKit.label(button, def and def.Name or tool.Name, {Size = UDim2.new(1, -8, 0, 22), Position = UDim2.new(0.5, 0, 0, 3), AnchorPoint = Vector2.new(0.5, 0),
			Stroke = 2.5, MaxText = 18})
		name.ZIndex = 4
		-- the key number in a little square in the bottom-left corner
		local key = UIKit.panel(button, {Size = UDim2.fromOffset(22, 22), Position = UDim2.new(0, 5, 1, -6), AnchorPoint = Vector2.new(0, 1),
			Color = UIKit.shadeColor(color, 0.45), Radius = 5, Stroke = 2, StrokeColor = C.White, Shade = false})
		key.ZIndex = 4
		UIKit.label(key, tostring(i), {Size = UDim2.fromScale(0.8, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
			Stroke = 2, MaxText = 16}).ZIndex = 5
		-- golden ring around the slot while the tool is in your hand
		local ring = Instance.new("Frame")
		ring.BackgroundTransparency = 1
		ring.Size = UDim2.new(1, 10, 1, 10)
		ring.Position = UDim2.fromScale(0.5, 0.5)
		ring.AnchorPoint = Vector2.new(0.5, 0.5)
		ring.Parent = button
		UIKit.corner(ring, 14)
		UIKit.outline(ring, 4, C.Sun)
		local slot = {Tool = tool, Button = button, Ring = ring}
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
