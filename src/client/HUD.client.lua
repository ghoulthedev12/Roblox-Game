-- HUD (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The always-on screen, in a big chunky style:
--   * TOP: three wide studded buttons (Shop, Museum, Worlds) with the world you're in under them,
--     right at the top edge of the screen (in Roblox's top bar row). Inside a museum they make
--     way for the museum's UP / DOWN floor buttons (MuseumClient sets the InMuseum attribute).
--   * LEFT: the Bag as a square item tile and Rebirth as a big icon (red badge when a rebirth is ready)
--   * TOP RIGHT CORNER: a small round Settings button (music and sound live in Settings)
--   * BOTTOM LEFT: big gem and money numbers (money short: $15.7B), income under them
--   * BOTTOM CENTER: a hotbar of square slots (name on top, key number in the corner, 3D icon)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local UIBus = require(ReplicatedStorage:WaitForChild("UIBus"))
local PetVisuals = require(ReplicatedStorage:WaitForChild("PetVisuals"))
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
-- its own screen that reaches into Roblox's top bar row, so the buttons sit at the very top
local topGui = UIKit.screen(player, "HUDTop", 1)
topGui.IgnoreGuiInset = true
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.BackgroundTransparency = 1
topBar.Size = UDim2.fromOffset(TOP_W * 3 + TOP_GAP * 2, TOP_H + 36)
topBar.Position = UDim2.new(0.5, 0, 0, 6)
topBar.AnchorPoint = Vector2.new(0.5, 0)
topBar.Parent = topGui

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

-- inside a museum the museum's UP / DOWN buttons take this spot
local function museumCheck()
	topBar.Visible = not player:GetAttribute("InMuseum")
end
player:GetAttributeChangedSignal("InMuseum"):Connect(museumCheck)
museumCheck()

---------------------------------------------------------------------
-- LEFT: the Bag as a square item tile (backpack, name across it, key square)
-- and Rebirth as a big 3D icon with a pink label under it
---------------------------------------------------------------------
local function bounce(b)
	local scale = Instance.new("UIScale")
	scale.Parent = b
	local function to(v, t)
		TweenService:Create(scale, TweenInfo.new(t or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = v}):Play()
	end
	b.MouseEnter:Connect(function() to(1.08) end)
	b.MouseLeave:Connect(function() to(1) end)
	b.MouseButton1Down:Connect(function() to(0.9, 0.06) end)
	b.MouseButton1Up:Connect(function() to(1.08) end)
end

local menu = Instance.new("Frame")
menu.BackgroundTransparency = 1
menu.Size = UDim2.fromOffset(224, 350)
menu.Position = UDim2.new(0, 12, 0, 74)
menu.Parent = gui

local bagButton = UIKit.button(menu, "", {Size = UDim2.fromOffset(98, 98), Position = UDim2.new(0, 58, 0, 0), AnchorPoint = Vector2.new(0.5, 0),
	Color = rgb(56, 150, 226), Radius = 12, Pattern = false})
bagButton.Name = "Bag"
UIKit.icon(bagButton, "Bag", {Size = UDim2.fromScale(0.92, 0.92), Position = UDim2.fromScale(0.5, 0.44), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 2})
local bagLabel = UIKit.label(bagButton, "Bag", {Size = UDim2.new(1, -6, 0, 30), Position = UDim2.new(0.5, 0, 0.5, 6), AnchorPoint = Vector2.new(0.5, 0.5),
	Color = rgb(190, 236, 255), Stroke = 3.5, MaxText = 28})
bagLabel.ZIndex = 4
local bagKey = UIKit.panel(bagButton, {Size = UDim2.fromOffset(24, 24), Position = UDim2.new(0, 6, 1, -6), AnchorPoint = Vector2.new(0, 1),
	Color = rgb(30, 70, 120), Radius = 5, Stroke = 2, StrokeColor = C.White, Shade = false})
bagKey.ZIndex = 4
UIKit.label(bagKey, "B", {Size = UDim2.fromScale(0.78, 0.78), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2, MaxText = 16}).ZIndex = 5
bagButton.MouseButton1Click:Connect(function() UIBus.Fire("Inventory") end)

local rebirthButton = Instance.new("TextButton")
rebirthButton.Name = "Rebirth"
rebirthButton.Text = ""
rebirthButton.BackgroundTransparency = 1
rebirthButton.Size = UDim2.fromOffset(116, 120)
rebirthButton.Position = UDim2.new(0, 58, 0, 112)
rebirthButton.AnchorPoint = Vector2.new(0.5, 0)
rebirthButton.Parent = menu
UIKit.icon(rebirthButton, "Rebirth", {Size = UDim2.fromOffset(104, 104), Position = UDim2.new(0.5, 0, 0, -8), AnchorPoint = Vector2.new(0.5, 0)})
UIKit.label(rebirthButton, "Rebirth", {Size = UDim2.new(1, 8, 0, 32), Position = UDim2.new(0.5, 0, 0, 86), AnchorPoint = Vector2.new(0.5, 0),
	Color = rgb(255, 206, 232), Stroke = 4, MaxText = 30}).ZIndex = 2
local rebirthAlert = alertBadge(rebirthButton, 34, UDim2.new(0.5, 40, 0, 10))
bounce(rebirthButton)
rebirthButton.MouseButton1Click:Connect(function()
	click()
	UIBus.Fire("Rebirth")
end)

-- Quests: the same square tile as the Bag, in gold (world quests + Meme Index, QuestClient)
local questButton = UIKit.button(menu, "", {Size = UDim2.fromOffset(98, 98), Position = UDim2.new(0, 58, 0, 244), AnchorPoint = Vector2.new(0.5, 0),
	Color = rgb(255, 170, 40), Radius = 12, Pattern = false})
questButton.Name = "Quests"
UIKit.icon(questButton, "Star", {Size = UDim2.fromScale(0.86, 0.86), Position = UDim2.fromScale(0.5, 0.42), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 2})
UIKit.label(questButton, "Quests", {Size = UDim2.new(1, -6, 0, 30), Position = UDim2.new(0.5, 0, 0.5, 8), AnchorPoint = Vector2.new(0.5, 0.5),
	Color = rgb(255, 240, 200), Stroke = 3.5, MaxText = 26}).ZIndex = 4
local questKey = UIKit.panel(questButton, {Size = UDim2.fromOffset(24, 24), Position = UDim2.new(0, 6, 1, -6), AnchorPoint = Vector2.new(0, 1),
	Color = rgb(150, 90, 10), Radius = 5, Stroke = 2, StrokeColor = C.White, Shade = false})
questKey.ZIndex = 4
UIKit.label(questKey, "J", {Size = UDim2.fromScale(0.78, 0.78), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2, MaxText = 16}).ZIndex = 5
questButton.MouseButton1Click:Connect(function() UIBus.Fire("Quests") end)

-- Pets: a pink tile with the World 1 egg on it, beside Quests (the Pets window, PetClient)
local petButton = UIKit.button(menu, "", {Size = UDim2.fromOffset(98, 98), Position = UDim2.new(0, 166, 0, 244), AnchorPoint = Vector2.new(0.5, 0),
	Color = rgb(255, 120, 170), Radius = 12, Pattern = false})
petButton.Name = "Pets"
PetVisuals.viewport(petButton, "ByteEgg", {Size = UDim2.fromScale(0.78, 0.78), Position = UDim2.fromScale(0.5, 0.4), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 2})
UIKit.label(petButton, "Pets", {Size = UDim2.new(1, -6, 0, 30), Position = UDim2.new(0.5, 0, 0.5, 8), AnchorPoint = Vector2.new(0.5, 0.5),
	Color = rgb(255, 230, 240), Stroke = 3.5, MaxText = 26}).ZIndex = 4
local petKey = UIKit.panel(petButton, {Size = UDim2.fromOffset(24, 24), Position = UDim2.new(0, 6, 1, -6), AnchorPoint = Vector2.new(0, 1),
	Color = rgb(170, 50, 100), Radius = 5, Stroke = 2, StrokeColor = C.White, Shade = false})
petKey.ZIndex = 4
UIKit.label(petKey, "P", {Size = UDim2.fromScale(0.78, 0.78), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2, MaxText = 16}).ZIndex = 5
petButton.MouseButton1Click:Connect(function() UIBus.Fire("Pets") end)

-- Store: a gold tile beside the Bag (the Robux store: game passes and the Relic Egg, StoreClient)
local storeButton = UIKit.button(menu, "", {Size = UDim2.fromOffset(98, 98), Position = UDim2.new(0, 166, 0, 0), AnchorPoint = Vector2.new(0.5, 0),
	Color = rgb(255, 196, 40), Radius = 12, Pattern = false})
storeButton.Name = "Store"
-- the treasure chest pokes out over the top of the tile and wobbles now and then
local storeIcon = UIKit.icon(storeButton, "StoreIcon", {Size = UDim2.fromScale(1.12, 1.12), Position = UDim2.new(0.5, 0, 0.36, 0),
	AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 2})
UIKit.label(storeButton, "Store", {Size = UDim2.new(1, -6, 0, 30), Position = UDim2.new(0.5, 0, 1, -18), AnchorPoint = Vector2.new(0.5, 0.5),
	Color = rgb(255, 245, 200), Stroke = 3.5, MaxText = 26}).ZIndex = 4
storeButton.MouseButton1Click:Connect(function() UIBus.Fire("Store") end)
task.spawn(function()
	local wobble = TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	while storeIcon.Parent do
		task.wait(4)
		-- (a frame's Rotation doesn't turn its children: turn the picture itself)
		local picture = storeIcon:FindFirstChild("IconImage")
		if picture then
			for _, angle in ipairs({-10, 9, -6, 4, 0}) do
				TweenService:Create(picture, wobble, {Rotation = angle}):Play()
				task.wait(0.12)
			end
		end
	end
end)

---------------------------------------------------------------------
-- TOP RIGHT CORNER: a small dark round Settings button up in Roblox's top bar row
-- (music and sound effects are in the Settings window)
---------------------------------------------------------------------
local corner = UIKit.screen(player, "HUDCorner", 1)
corner.IgnoreGuiInset = true
local settingsButton = Instance.new("TextButton")
settingsButton.Name = "Settings"
settingsButton.Text = ""
settingsButton.AutoButtonColor = false
settingsButton.BackgroundColor3 = Color3.new(0, 0, 0)
settingsButton.BackgroundTransparency = 0.3
settingsButton.Size = UDim2.fromOffset(44, 44)
settingsButton.Position = UDim2.new(1, -14, 0, 7)
settingsButton.AnchorPoint = Vector2.new(1, 0)
settingsButton.Parent = corner
UIKit.corner(settingsButton, 22)
UIKit.icon(settingsButton, "Settings", {Size = UDim2.fromOffset(38, 38), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5)})
bounce(settingsButton)
settingsButton.MouseButton1Click:Connect(function()
	click()
	UIBus.Fire("Settings")
end)

---------------------------------------------------------------------
-- BOTTOM LEFT: gems and money as big outlined numbers next to their 3D icons (money short,
-- like $15.7B), income under them
---------------------------------------------------------------------
local wallet = Instance.new("Frame")
wallet.BackgroundTransparency = 1
wallet.Size = UDim2.fromOffset(460, 160)
wallet.Position = UDim2.new(0, 12, 1, -8)
wallet.AnchorPoint = Vector2.new(0, 1)
wallet.Parent = gui

local function counter(y, height, iconSize, icon, color, maxText)
	local row = Instance.new("Frame")
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1, 0, 0, height)
	row.Position = UDim2.fromOffset(0, y)
	row.Parent = wallet
	if icon then
		UIKit.icon(row, icon, {Size = UDim2.fromOffset(iconSize, iconSize), Position = UDim2.new(0, iconSize / 2, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5)})
	end
	local indent = icon and iconSize + 6 or 4
	local text = UIKit.label(row, "", {Size = UDim2.new(1, -indent, 1, 0), Position = UDim2.new(0, indent, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
		Align = "Left", Color = color, Stroke = 4.5, MaxText = maxText})
	return row, text
end
local _, gemText = counter(0, 50, 66, "Gem", rgb(230, 60, 255), 46)
local moneyRow, moneyText = counter(54, 66, 86, "Cash", rgb(60, 255, 50), 58)
local _, incomeText = counter(124, 32, 0, nil, rgb(255, 224, 90), 28)

-- 15760347332 -> "15,760,347,332"
local function commas(n)
	local s = tostring(math.floor(n))
	local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	return (out:gsub("^,", ""))
end

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
	-- in full up to the trillions; past that the short form (the number would be too long)
	moneyText.Text = ArtifactData.FormatMoney(money) -- short: $12K, $3.4M, $250.5B, $1.2T
end
local function refreshIncome()
	incomeText.Text = "Income: +" .. ArtifactData.FormatMoney(player:GetAttribute("Income") or 0) .. "/s"
end
local function refreshGems()
	gemText.Text = commas(player:GetAttribute("Gems") or 0)
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

-- the bag bounces when a meme arrives in it
task.spawn(function()
	local changed = remotes:WaitForChild("InventoryChanged", 30)
	if changed then
		changed.OnClientEvent:Connect(function()
			UIKit.pop(bagButton, 1.3)
		end)
	end
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
