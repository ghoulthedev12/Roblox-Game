-- StoreClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The Robux Store window (the Store button on the left, or UIBus "Store"), see StoreData:
--   * left: the four game passes as cards (icon, what it does, a Robux button, or OWNED;
--     the Relic Pickaxe gets an EQUIP button when you've switched to a shop pickaxe)
--   * right: the Relic Egg, turning, with its five pets and their chances, and buttons to
--     buy 1 or 3 eggs
-- Buying goes through the StoreBuy remote; StoreManager shows Roblox's purchase prompt.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local PetData = require(ReplicatedStorage:WaitForChild("PetData"))
local PetVisuals = require(ReplicatedStorage:WaitForChild("PetVisuals"))
local StoreData = require(ReplicatedStorage:WaitForChild("StoreData"))
local UIBus = require(ReplicatedStorage:WaitForChild("UIBus"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local rgb = Color3.fromRGB

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local buyRemote = remotes:WaitForChild("StoreBuy")
local equipRemote = remotes:WaitForChild("EquipShovel")

local IS_STUDIO = RunService:IsStudio()
local GOLD = rgb(255, 196, 40)

---------------------------------------------------------------------
-- PRICES: read from Roblox once (the Creator Hub price), StoreData's Robux as a fallback
---------------------------------------------------------------------
local prices = {} -- [key] = Robux
local function priceText(item)
	if item.Id == 0 and not IS_STUDIO then return "SOON" end
	return "R$ " .. (prices[item.Key] or item.Robux)
end

---------------------------------------------------------------------
-- WINDOW
---------------------------------------------------------------------
local gui = UIKit.screen(player, "StoreUI", 7)
local window, content = UIKit.window(gui, "Store", UDim2.fromOffset(880, 570), GOLD, "PassMoney")
window.Name = "StoreWindow"

-- left: game passes, 2 x 2
local passArea = Instance.new("Frame")
passArea.BackgroundTransparency = 1
passArea.Size = UDim2.new(0.62, -8, 1, 0)
passArea.Parent = content
UIKit.label(passArea, "GAME PASSES", {Size = UDim2.new(1, 0, 0, 30), Align = "Left", Color = C.Ink, Stroke = 0, MaxText = 26})
local passGrid = Instance.new("Frame")
passGrid.BackgroundTransparency = 1
passGrid.Size = UDim2.new(1, 0, 1, -36)
passGrid.Position = UDim2.fromOffset(0, 36)
passGrid.Parent = passArea
local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0.5, -6, 0.5, -6)
gridLayout.CellPadding = UDim2.fromOffset(12, 12)
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.Parent = passGrid

local passButtons = {} -- [key] = button
for i, pass in ipairs(StoreData.Passes) do
	local card = UIKit.panel(passGrid, {Color = pass.Color:Lerp(Color3.new(1, 1, 1), 0.72), Radius = 16, Stroke = 3, StrokeColor = pass.Color:Lerp(C.Outline, 0.55)})
	card.LayoutOrder = i
	UIKit.icon(card, pass.Icon, {Size = UDim2.fromScale(0.36, 0.5), Position = UDim2.new(0, 4, 0, 2)}).ZIndex = 2
	UIKit.label(card, pass.Name, {Size = UDim2.new(0.62, -10, 0.2, 0), Position = UDim2.new(0.38, 0, 0.06, 0), Align = "Left", Stroke = 3, MaxText = 26})
	UIKit.label(card, pass.Text, {Size = UDim2.new(0.62, -10, 0.3, 0), Position = UDim2.new(0.38, 0, 0.26, 0), Align = "Left", VAlign = "Top",
		Color = C.Ink, Stroke = 0, MaxText = 15, Font = UIKit.BodyFont})
	local button = UIKit.button(card, priceText(pass), {Size = UDim2.new(1, -20, 0.3, 0), Position = UDim2.new(0.5, 0, 1, -10), AnchorPoint = Vector2.new(0.5, 1),
		Color = C.Money, MaxText = 26})
	button.MouseButton1Click:Connect(function()
		if pass.Key == "RelicPickaxe" and StoreData.PlayerOwns(player, pass.Key) then
			equipRemote:FireServer("RelicPickaxe")
		elseif not StoreData.PlayerOwns(player, pass.Key) then
			buyRemote:FireServer(pass.Key)
		end
	end)
	passButtons[pass.Key] = button
end

-- right: the Relic Egg
local egg = PetData.RelicEgg
local eggPanel = UIKit.panel(content, {Size = UDim2.new(0.38, -8, 1, 0), Position = UDim2.new(1, 0, 0, 0), AnchorPoint = Vector2.new(1, 0),
	Color = rgb(40, 34, 70), Radius = 18, Stroke = 3})
UIKit.label(eggPanel, string.upper(egg.Name), {Size = UDim2.new(1, -20, 0.08, 0), Position = UDim2.new(0.5, 0, 0.02, 0), AnchorPoint = Vector2.new(0.5, 0),
	Color = GOLD, Stroke = 3, MaxText = 30})
local eggView = Instance.new("Frame")
eggView.BackgroundTransparency = 1
eggView.Size = UDim2.new(1, -20, 0.27, 0)
eggView.Position = UDim2.new(0.5, 0, 0.1, 0)
eggView.AnchorPoint = Vector2.new(0.5, 0)
eggView.Parent = eggPanel
PetVisuals.viewport(eggView, egg.Id, {Spin = true})
local chances = PetData.Chances(egg)
for i, petId in ipairs(egg.Pets) do
	local pet = PetData.GetPet(petId)
	local rarity = PetData.Rarity(pet)
	local row = UIKit.panel(eggPanel, {Size = UDim2.new(1, -20, 0.072, 0), Position = UDim2.new(0.5, 0, 0.38 + (i - 1) * 0.082, 0), AnchorPoint = Vector2.new(0.5, 0),
		Color = rarity.Color, Radius = 10, Stroke = 2.5})
	local view = Instance.new("Frame")
	view.BackgroundTransparency = 1
	view.Size = UDim2.new(0, 40, 1.3, 0)
	view.Position = UDim2.new(0, 2, 0.5, 0)
	view.AnchorPoint = Vector2.new(0, 0.5)
	view.Parent = row
	PetVisuals.viewport(view, pet.Id)
	UIKit.label(row, pet.Name, {Size = UDim2.new(0.62, -44, 0.8, 0), Position = UDim2.new(0, 44, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
		Align = "Left", Stroke = 2.5, MaxText = 20})
	UIKit.label(row, chances[i] .. "%", {Size = UDim2.new(0.3, 0, 0.8, 0), Position = UDim2.new(1, -8, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5),
		Align = "Right", Stroke = 2.5, MaxText = 20})
end
UIKit.label(eggPanel, "Exclusive pets: every one boosts money, luck AND speed!", {Size = UDim2.new(1, -24, 0.06, 0), Position = UDim2.new(0.5, 0, 0.79, 0),
	AnchorPoint = Vector2.new(0.5, 0), Color = rgb(150, 245, 230), Stroke = 0, MaxText = 15, Font = UIKit.BodyFont})
local productButtons = {}
for i, product in ipairs(StoreData.Products) do
	local b = UIKit.button(eggPanel, "", {Size = UDim2.new(0.5, -14, 0.12, 0), Position = UDim2.new(i == 1 and 0 or 1, i == 1 and 10 or -10, 1, -10),
		AnchorPoint = Vector2.new(i == 1 and 0 or 1, 1), Color = i == 1 and C.Money or GOLD, MaxText = 20})
	b.MouseButton1Click:Connect(function() buyRemote:FireServer(product.Key) end)
	productButtons[product.Key] = b
end

---------------------------------------------------------------------
-- STATE
---------------------------------------------------------------------
local function refresh()
	for _, pass in ipairs(StoreData.Passes) do
		local button = passButtons[pass.Key]
		if StoreData.PlayerOwns(player, pass.Key) then
			local inHand = string.sub(player:GetAttribute("EquippedShovel") or "", 1, 12) == "RelicPickaxe"
			if pass.Key == "RelicPickaxe" and not inHand then
				UIKit.setButton(button, "EQUIP", C.Sky)
			else
				UIKit.setButton(button, "OWNED", rgb(150, 145, 170))
			end
		else
			UIKit.setButton(button, priceText(pass), pass.Id == 0 and not IS_STUDIO and rgb(150, 145, 170) or C.Money)
		end
	end
	for i, product in ipairs(StoreData.Products) do
		local text = "x" .. product.Amount .. "  " .. priceText(product)
		UIKit.setButton(productButtons[product.Key], text, product.Id == 0 and not IS_STUDIO and rgb(150, 145, 170) or (i == 1 and C.Money or GOLD))
	end
end
refresh()
for _, pass in ipairs(StoreData.Passes) do
	player:GetAttributeChangedSignal(StoreData.Attribute(pass.Key)):Connect(refresh)
end
player:GetAttributeChangedSignal("EquippedShovel"):Connect(refresh)

task.spawn(function()
	for _, item in ipairs(StoreData.Passes) do
		if item.Id > 0 then
			local ok, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, item.Id, Enum.InfoType.GamePass)
			if ok and info and info.PriceInRobux then prices[item.Key] = info.PriceInRobux end
		end
	end
	for _, item in ipairs(StoreData.Products) do
		if item.Id > 0 then
			local ok, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, item.Id, Enum.InfoType.Product)
			if ok and info and info.PriceInRobux then prices[item.Key] = info.PriceInRobux end
		end
	end
	refresh()
end)

local function toggle()
	if window.Visible then
		window.Visible = false
	else
		refresh()
		UIKit.open(window)
	end
end
UIBus.On("Store", toggle)
