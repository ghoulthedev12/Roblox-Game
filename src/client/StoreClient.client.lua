-- StoreClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The Robux Store window (the Store button on the left, or UIBus "Store"), see StoreData:
--   * left: the four game passes as bold colored cards: a big glossy icon popping out on a
--     glow, the name, what it does, and a Robux price button (OWNED once bought; the Relic
--     Pickaxe gets an EQUIP button when you've switched to a shop pickaxe). Ribbons mark the
--     popular and the best one.
--   * right: the Relic Egg showcase: the egg turning on a glow, its five pets with their
--     chances, and buttons to buy 1 or 3 eggs (the 3 shows how much it saves)
-- Buying goes through the StoreBuy remote; StoreManager shows Roblox's purchase prompt.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

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
local GREY = rgb(150, 145, 170)
local ROBUX = "rbxasset://textures/ui/common/robux@3x.png" -- Roblox's own Robux symbol (white)

-- which passes get a ribbon
local RIBBONS = {DoubleMoney = {"POPULAR", rgb(255, 70, 90)}, RelicPickaxe = {"BEST!", rgb(150, 70, 255)}}

---------------------------------------------------------------------
-- PRICES: read from Roblox once (the Creator Hub price), StoreData's Robux as a fallback
---------------------------------------------------------------------
local prices = {} -- [key] = Robux
local function price(item)
	return prices[item.Key] or item.Robux
end
local function forSale(item)
	return item.Id > 0 or IS_STUDIO
end

---------------------------------------------------------------------
-- BUILDING BLOCKS
---------------------------------------------------------------------
-- a soft round glow (behind icons and the egg): three circles, fainter toward the outside
-- (UIGradient only fades in straight lines, so the rings do the round fade)
local function glow(parent, size, position, color, z)
	local g = Instance.new("Frame")
	g.Name = "Glow"
	g.BackgroundTransparency = 1
	g.Size = size
	g.Position = position
	g.AnchorPoint = Vector2.new(0.5, 0.5)
	g.Parent = parent
	local ratio = Instance.new("UIAspectRatioConstraint")
	ratio.Parent = g
	for _, ring in ipairs({{1, 0.84}, {0.72, 0.7}, {0.44, 0.55}}) do
		local circle = Instance.new("Frame")
		circle.BorderSizePixel = 0
		circle.BackgroundColor3 = color
		circle.BackgroundTransparency = ring[2]
		circle.Size = UDim2.fromScale(ring[1], ring[1])
		circle.Position = UDim2.fromScale(0.5, 0.5)
		circle.AnchorPoint = Vector2.new(0.5, 0.5)
		circle.ZIndex = z or 1
		circle.Parent = g
		UIKit.corner(circle, 999)
	end
	return g
end

-- a top-to-bottom sheen over a panel (lighter on top, darker at the bottom)
local function sheen(frame, top, bottom)
	local gradient = Instance.new("UIGradient")
	gradient.Rotation = 90
	gradient.Color = ColorSequence.new(Color3.new(top, top, top), Color3.new(bottom, bottom, bottom))
	gradient.Parent = frame
	return gradient
end

-- a slanted ribbon on a card's top-left corner (top-right with onRight)
local function ribbon(card, text, color, onRight)
	local tag = UIKit.panel(card, {Size = UDim2.fromOffset(104, 30), Position = onRight and UDim2.new(1, 10, 0, -10) or UDim2.new(0, -10, 0, -10),
		AnchorPoint = Vector2.new(onRight and 1 or 0, 0), Color = color, Radius = 8, Stroke = 2.5, StrokeColor = C.Outline, ShadeAmount = 0.15})
	tag.Rotation = onRight and 8 or -8
	tag.ZIndex = 6
	UIKit.label(tag, text, {Size = UDim2.fromScale(0.86, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
		Stroke = 2.5, MaxText = 20}).ZIndex = 7
	return tag
end

-- a studded button showing the Robux symbol and a price (or a plain word like OWNED)
local function priceButton(parent, props)
	local b, label = UIKit.button(parent, "", props)
	label.Visible = false
	local row = Instance.new("Frame")
	row.Name = "PriceRow"
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1, -16, 1, -14)
	row.Position = UDim2.new(0.5, 0, 0.5, -2)
	row.AnchorPoint = Vector2.new(0.5, 0.5)
	row.ZIndex = 3
	row.Parent = b
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = row
	local prefix = UIKit.label(row, "", {Size = UDim2.new(0, 0, 0.9, 0), Stroke = 3, MaxText = props.MaxText or 28})
	prefix.AutomaticSize = Enum.AutomaticSize.X
	prefix.TextScaled = false
	prefix.TextSize = props.TextSize or 26
	prefix.LayoutOrder = 1
	prefix.ZIndex = 3
	local icon = Instance.new("ImageLabel")
	icon.Name = "Robux"
	icon.BackgroundTransparency = 1
	icon.Image = ROBUX
	icon.Size = UDim2.fromOffset((props.TextSize or 26) + 6, (props.TextSize or 26) + 6)
	icon.LayoutOrder = 2
	icon.ZIndex = 3
	icon.Parent = row
	local text = UIKit.label(row, "", {Size = UDim2.new(0, 0, 0.9, 0), Stroke = 3, MaxText = props.MaxText or 28})
	text.AutomaticSize = Enum.AutomaticSize.X
	text.TextScaled = false
	text.TextSize = props.TextSize or 26
	text.LayoutOrder = 3
	text.ZIndex = 3
	-- set(prefix text, Robux amount or nil, color, or a plain word with no Robux symbol)
	local function set(word, robux, color, before)
		b.BackgroundColor3 = color
		prefix.Text = before or ""
		prefix.Visible = before ~= nil
		icon.Visible = robux ~= nil
		text.Text = robux and tostring(robux) or word
	end
	return b, set
end

---------------------------------------------------------------------
-- WINDOW
---------------------------------------------------------------------
local gui = UIKit.screen(player, "StoreUI", 7)
local window, content = UIKit.window(gui, "Store", UDim2.fromOffset(940, 600), GOLD, "StoreIcon")
window.Name = "StoreWindow"

-- left: game passes, 2 x 2
local passArea = Instance.new("Frame")
passArea.BackgroundTransparency = 1
passArea.Size = UDim2.new(0.64, -8, 1, 0)
passArea.Parent = content
local passTitle = UIKit.panel(passArea, {Size = UDim2.fromOffset(210, 34), Color = rgb(52, 44, 88), Radius = 10, Stroke = 2.5})
UIKit.label(passTitle, "GAME PASSES", {Size = UDim2.fromScale(0.9, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
	Color = GOLD, Stroke = 2.5, MaxText = 24})
UIKit.label(passArea, "Bought once, yours forever!", {Size = UDim2.new(1, -224, 0, 24), Position = UDim2.fromOffset(222, 5), Align = "Left",
	Color = C.Grey, Stroke = 0, MaxText = 18, Font = UIKit.BodyFont})
local passGrid = Instance.new("Frame")
passGrid.BackgroundTransparency = 1
passGrid.Size = UDim2.new(1, 0, 1, -48)
passGrid.Position = UDim2.fromOffset(0, 48)
passGrid.Parent = passArea
local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0.5, -8, 0.5, -8)
gridLayout.CellPadding = UDim2.fromOffset(16, 16)
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.Parent = passGrid

local passSetters = {} -- [key] = set(...)
for i, pass in ipairs(StoreData.Passes) do
	local card = UIKit.panel(passGrid, {Color = pass.Color, Radius = 18, Stroke = 4, StrokeColor = C.Outline, Shade = false})
	card.LayoutOrder = i
	sheen(card, 1, 0.72)
	-- the icon, big, on a glow, poking out over the card's top-left
	glow(card, UDim2.fromScale(0.62, 0.62), UDim2.fromScale(0.25, 0.36), Color3.new(1, 1, 1), 1)
	local icon = UIKit.icon(card, pass.Icon, {Size = UDim2.fromScale(0.5, 0.66), Position = UDim2.fromScale(0.25, 0.33), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 3})
	local square = Instance.new("UIAspectRatioConstraint")
	square.Parent = icon
	UIKit.label(card, string.upper(pass.Name), {Size = UDim2.new(0.5, -10, 0.24, 0), Position = UDim2.new(0.5, 0, 0.07, 0), Align = "Left",
		Stroke = 3.5, MaxText = 30}).ZIndex = 3
	local blurb = UIKit.label(card, pass.Text, {Size = UDim2.new(0.5, -12, 0.33, 0), Position = UDim2.new(0.5, 0, 0.31, 0), Align = "Left", VAlign = "Top",
		Color = C.White, Stroke = 1.5, MaxText = 17, Font = UIKit.BodyFont})
	blurb.ZIndex = 3
	local button, set = priceButton(card, {Size = UDim2.new(1, -24, 0.27, 0), Position = UDim2.new(0.5, 0, 1, -12), AnchorPoint = Vector2.new(0.5, 1),
		Color = C.Money, TextSize = 28})
	button.ZIndex = 4
	button.MouseButton1Click:Connect(function()
		if pass.Key == "RelicPickaxe" and StoreData.PlayerOwns(player, pass.Key) then
			equipRemote:FireServer("RelicPickaxe")
		elseif not StoreData.PlayerOwns(player, pass.Key) then
			buyRemote:FireServer(pass.Key)
		end
	end)
	-- the card grows a little under the mouse
	local grow = Instance.new("UIScale")
	grow.Parent = card
	card.MouseEnter:Connect(function() TweenService:Create(grow, TweenInfo.new(0.12), {Scale = 1.03}):Play() end)
	card.MouseLeave:Connect(function() TweenService:Create(grow, TweenInfo.new(0.12), {Scale = 1}):Play() end)
	if RIBBONS[pass.Key] then ribbon(card, RIBBONS[pass.Key][1], RIBBONS[pass.Key][2]) end
	passSetters[pass.Key] = set
end

-- right: the Relic Egg showcase
local egg = PetData.RelicEgg
local eggPanel = UIKit.panel(content, {Size = UDim2.new(0.36, -8, 1, 0), Position = UDim2.new(1, 0, 0, 0), AnchorPoint = Vector2.new(1, 0),
	Color = rgb(70, 50, 140), Radius = 20, Stroke = 4, StrokeColor = C.Outline, Shade = false})
sheen(eggPanel, 1, 0.55)
ribbon(eggPanel, "EXCLUSIVE", rgb(40, 200, 185), true)
UIKit.label(eggPanel, string.upper(egg.Name), {Size = UDim2.new(1, -20, 0.075, 0), Position = UDim2.new(0.5, 0, 0.025, 0), AnchorPoint = Vector2.new(0.5, 0),
	Color = GOLD, Stroke = 3.5, MaxText = 34})
local eggGlow = glow(eggPanel, UDim2.fromScale(0.7, 0.7), UDim2.fromScale(0.5, 0.2), rgb(255, 220, 120), 1)
local eggView = Instance.new("Frame")
eggView.BackgroundTransparency = 1
eggView.Size = UDim2.new(1, -20, 0.21, 0)
eggView.Position = UDim2.new(0.5, 0, 0.1, 0)
eggView.AnchorPoint = Vector2.new(0.5, 0)
eggView.ZIndex = 2
eggView.Parent = eggPanel
local eggViewport = PetVisuals.viewport(eggView, egg.Id, {Spin = true})
eggViewport.ZIndex = 2
-- the glow behind the egg breathes
TweenService:Create(eggGlow, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Size = UDim2.fromScale(0.9, 0.9)}):Play()

local chances = PetData.Chances(egg)
for i, petId in ipairs(egg.Pets) do
	local pet = PetData.GetPet(petId)
	local rarity = PetData.Rarity(pet)
	local row = UIKit.panel(eggPanel, {Size = UDim2.new(1, -20, 0.072, 0), Position = UDim2.new(0.5, 0, 0.375 + (i - 1) * 0.083, 0), AnchorPoint = Vector2.new(0.5, 0),
		Color = rarity.Color, Radius = 10, Stroke = 2.5})
	local view = Instance.new("Frame")
	view.BackgroundTransparency = 1
	view.Size = UDim2.new(0, 46, 1.4, 0)
	view.Position = UDim2.new(0, 0, 0.5, 0)
	view.AnchorPoint = Vector2.new(0, 0.5)
	view.Parent = row
	PetVisuals.viewport(view, pet.Id)
	UIKit.label(row, pet.Name, {Size = UDim2.new(0.62, -46, 0.8, 0), Position = UDim2.new(0, 46, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
		Align = "Left", Stroke = 2.5, MaxText = 20})
	UIKit.label(row, chances[i] .. "%", {Size = UDim2.new(0.3, 0, 0.8, 0), Position = UDim2.new(1, -8, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5),
		Align = "Right", Stroke = 2.5, MaxText = 20})
end
UIKit.label(eggPanel, "Boosts money, luck AND speed!", {Size = UDim2.new(1, -24, 0.045, 0), Position = UDim2.new(0.5, 0, 0.315, 0),
	AnchorPoint = Vector2.new(0.5, 0), Color = rgb(170, 250, 235), Stroke = 1.5, MaxText = 16, Font = UIKit.BodyFont})
local productSetters = {}
local saveTag
for i, product in ipairs(StoreData.Products) do
	local b, set = priceButton(eggPanel, {Size = UDim2.new(0.5, -15, 0.13, 0), Position = UDim2.new(i == 1 and 0 or 1, i == 1 and 10 or -10, 1, -10),
		AnchorPoint = Vector2.new(i == 1 and 0 or 1, 1), Color = i == 1 and C.Money or GOLD, TextSize = 22})
	b.MouseButton1Click:Connect(function() buyRemote:FireServer(product.Key) end)
	productSetters[product.Key] = set
	if product.Amount > 1 then
		saveTag = UIKit.panel(b, {Size = UDim2.fromOffset(84, 24), Position = UDim2.new(1, 8, 0, -6), AnchorPoint = Vector2.new(1, 0.5),
			Color = rgb(255, 70, 90), Radius = 8, Stroke = 2, StrokeColor = C.Outline})
		saveTag.Rotation = 8
		saveTag.ZIndex = 6
		saveTag.Visible = false
		UIKit.label(saveTag, "", {Name = "Text", Size = UDim2.fromScale(0.9, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
			Stroke = 2, MaxText = 16}).ZIndex = 7
	end
end

---------------------------------------------------------------------
-- STATE
---------------------------------------------------------------------
local function refresh()
	for _, pass in ipairs(StoreData.Passes) do
		local set = passSetters[pass.Key]
		if StoreData.PlayerOwns(player, pass.Key) then
			local inHand = string.sub(player:GetAttribute("EquippedShovel") or "", 1, 12) == "RelicPickaxe"
			if pass.Key == "RelicPickaxe" and not inHand then
				set("EQUIP", nil, C.Sky)
			else
				set("OWNED", nil, GREY)
			end
		elseif forSale(pass) then
			set(nil, price(pass), C.Money)
		else
			set("SOON", nil, GREY)
		end
	end
	local one
	for i, product in ipairs(StoreData.Products) do
		if product.Amount == 1 then one = product end
		if forSale(product) then
			productSetters[product.Key](nil, price(product), i == 1 and C.Money or GOLD, "x" .. product.Amount)
		else
			productSetters[product.Key]("SOON", nil, GREY)
		end
	end
	-- "SAVE 12%" on the bigger pack
	for _, product in ipairs(StoreData.Products) do
		if product.Amount > 1 and one and saveTag then
			local full = price(one) * product.Amount
			local save = math.floor((1 - price(product) / full) * 100 + 0.5)
			saveTag.Visible = save > 0 and forSale(product)
			local label = saveTag:FindFirstChildWhichIsA("TextLabel")
			if label then label.Text = "SAVE " .. save .. "%" end
		end
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
