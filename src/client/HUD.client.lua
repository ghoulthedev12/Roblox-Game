-- HUD (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The always-on screen: money and income counters, which world you're in, and a
-- custom hotbar that shows your shovel as a 3D icon (replaces Roblox's default backpack bar).

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
-- MONEY / INCOME / WORLD (top left)
---------------------------------------------------------------------
local stats = Instance.new("Frame")
stats.BackgroundTransparency = 1
stats.Size = UDim2.fromOffset(260, 150)
stats.Position = UDim2.fromOffset(16, 16)
stats.Parent = gui
local statsLayout = Instance.new("UIListLayout")
statsLayout.Padding = UDim.new(0, 8)
statsLayout.Parent = stats

local function pill(color, iconText, iconColor, order)
	local p = UIKit.panel(stats, {Size = UDim2.fromOffset(230, 44), Color = C.Panel, Radius = 22})
	p.LayoutOrder = order
	local icon = UIKit.panel(p, {Size = UDim2.fromOffset(52, 52), Position = UDim2.new(0, -8, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Color = color, Radius = 26})
	UIKit.label(icon, iconText, {Size = UDim2.fromScale(0.7, 0.7), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Color = iconColor or C.White, Stroke = 2})
	local text = UIKit.label(p, "", {Size = UDim2.new(1, -62, 0.7, 0), Position = UDim2.new(0, 54, 0.15, 0), Align = "Left", Color = C.Ink, Stroke = 0})
	return p, text
end

local moneyPill, moneyText = pill(C.Money, "$", C.White, 1)
local _, incomeText = pill(C.Sun, "+", C.White, 2)
local _, worldText = pill(C.Lilac, "W", C.White, 3)

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
	incomeText.Text = ArtifactData.FormatMoney(player:GetAttribute("Income") or 0) .. " / sec"
end
local function refreshWorld()
	local world = GameConfig.GetWorld(player:GetAttribute("CurrentWorld") or 1)
	worldText.Text = world and world.Name or ""
end
player:GetAttributeChangedSignal("Money"):Connect(refreshMoney)
player:GetAttributeChangedSignal("Income"):Connect(refreshIncome)
player:GetAttributeChangedSignal("CurrentWorld"):Connect(refreshWorld)
refreshMoney()
refreshIncome()
refreshWorld()

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
		local key = UIKit.panel(button, {Size = UDim2.fromOffset(26, 26), Position = UDim2.fromOffset(-6, -6), Color = C.Violet, Radius = 13, Stroke = 2})
		UIKit.label(key, tostring(i), {Size = UDim2.fromScale(0.8, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 0})
		local hint = UIKit.label(button, "Equip!", {Size = UDim2.new(1.4, 0, 0, 22), Position = UDim2.new(0.5, 0, 0, -30), AnchorPoint = Vector2.new(0.5, 0), Color = C.Sun, Stroke = 2})
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
