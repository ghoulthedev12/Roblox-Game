-- MuseumClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The museum side of the UI (World 1 only):
--   * the real artifact (painting, statue, coin, tablet or crystal) under a glass case on
--     every pedestal that has a meme on it (in every museum, so visitors see your collection)
--   * the Display window: pick a meme from your inventory to put on a slot, or take it back
--   * the Alien Art Dealer window: sell memes for cash
--   * small up/down arrows at the top center while you're inside a museum, to change floors
--     (the up arrow also buys the next floor in your own museum)
-- Slot prompts only show up in your own museum.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local getInventory = remotes:WaitForChild("GetInventory")
local inventoryChangedRemote = remotes:WaitForChild("InventoryChanged")
local openSlotRemote = remotes:WaitForChild("OpenSlotMenu")
local placeRemote = remotes:WaitForChild("PlaceInSlot")
local takeRemote = remotes:WaitForChild("TakeFromSlot")
local openDealerRemote = remotes:WaitForChild("OpenDealer")
local sellRemote = remotes:WaitForChild("SellArtifacts")
local floorRemote = remotes:WaitForChild("ChangeFloor")

local player = Players.LocalPlayer
local museumsFolder = workspace:WaitForChild("Museums")

---------------------------------------------------------------------
-- DISPLAYS: the real artifact (painting, statue, coin, tablet or crystal, see
-- ArtifactModels) standing still on its pedestal under a glass case
---------------------------------------------------------------------
local ArtifactModels = require(ReplicatedStorage:WaitForChild("ArtifactModels"))
local cards = {} -- [slot model] = the display model

local function removeCard(slot)
	local display = cards[slot]
	if display then
		display:Destroy()
		cards[slot] = nil
	end
end

local CASE = Vector3.new(5, 6, 5) -- inside size of the glass case

local function casePart(parent, name, size, cf, color, material, transparency)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material
	p.Transparency = transparency or 0
	p.Parent = parent
	return p
end

-- a glass box with a dark metal frame and a thin glowing line at the base
local function glassCase(parent, baseCF, color)
	local glass = Color3.fromRGB(200, 235, 255)
	local frame = Color3.fromRGB(40, 38, 64)
	local w, h = CASE.X, CASE.Y
	casePart(parent, "CaseGlass", Vector3.new(w, h, w), baseCF * CFrame.new(0, h / 2, 0), glass, Enum.Material.Glass, 0.82).Reflectance = 0.25
	casePart(parent, "CaseLid", Vector3.new(w + 0.3, 0.3, w + 0.3), baseCF * CFrame.new(0, h + 0.15, 0), frame, Enum.Material.Metal)
	casePart(parent, "CaseBase", Vector3.new(w + 0.3, 0.3, w + 0.3), baseCF * CFrame.new(0, 0.15, 0), frame, Enum.Material.Metal)
	casePart(parent, "CaseGlow", Vector3.new(w + 0.34, 0.08, w + 0.34), baseCF * CFrame.new(0, 0.32, 0), color, Enum.Material.Neon)
	for _, sx in ipairs({-1, 1}) do
		for _, sz in ipairs({-1, 1}) do
			casePart(parent, "CaseEdge", Vector3.new(0.18, h, 0.18), baseCF * CFrame.new(sx * w / 2, h / 2, sz * w / 2), frame, Enum.Material.Metal)
		end
	end
end

local function updateCard(slot)
	removeCard(slot)
	local artifact = ArtifactData.GetArtifact(slot:GetAttribute("ArtifactId") or "")
	local spot = slot:FindFirstChild("DisplaySpot")
	local cap = slot:FindFirstChild("Cap")
	if not artifact or not spot then return end
	local rarity = ArtifactData.GetRarity(artifact.Rarity)

	local display = Instance.new("Model")
	display.Name = "Display"
	-- the pedestal's top, facing into the room like the slot does
	local topY = cap and (cap.Position.Y + cap.Size.X / 2) or (spot.Position.Y - 1.8)
	local baseCF = CFrame.new(spot.Position.X, topY, spot.Position.Z) * spot.CFrame.Rotation
	glassCase(display, baseCF, rarity.Color)

	local object = ArtifactModels.build(artifact)
	-- shrink big objects so they fit inside the case
	local fit = math.min(1, (CASE.X - 0.8) / (object:GetAttribute("Width") or 4), (CASE.Y - 0.8) / ((object:GetAttribute("HalfHeight") or 2) * 2))
	if fit < 1 then object:ScaleTo(fit) end
	local half = (object:GetAttribute("HalfHeight") or 2) * fit
	object:PivotTo(baseCF * CFrame.new(0, 0.35 + half, 0))
	-- only the physical artifact is shown (its meme is carved/printed on it); the name tag
	-- floats above the glass case
	local info = spot:FindFirstChild("InfoGui")
	if info and info:IsA("BillboardGui") then info.StudsOffset = Vector3.new(0, 8.4, 0) end
	object.Parent = display
	-- a soft spotlight in the rarity's color, and sparkles for the fancy ones
	local light = Instance.new("PointLight")
	light.Color = rarity.Color
	light.Range = 10
	light.Brightness = 0.7
	light.Parent = object.PrimaryPart
	if ArtifactData.GetRarityIndex(artifact.Rarity) >= 5 then
		local sparkles = Instance.new("ParticleEmitter")
		sparkles.Rate = 3
		sparkles.Lifetime = NumberRange.new(0.8, 1.4)
		sparkles.Speed = NumberRange.new(0.3, 0.8)
		sparkles.SpreadAngle = Vector2.new(180, 180)
		sparkles.Size = NumberSequence.new(0.2, 0)
		sparkles.LightEmission = 0.8
		sparkles.Color = ColorSequence.new(rarity.Color)
		sparkles.Parent = object.PrimaryPart
	end
	display.Parent = slot
	cards[slot] = display
end

local function watchSlot(slot, owned)
	slot:GetAttributeChangedSignal("ArtifactId"):Connect(function()
		updateCard(slot)
	end)
	slot.AncestryChanged:Connect(function()
		if not slot:IsDescendantOf(workspace) then removeCard(slot) end
	end)
	updateCard(slot)
	-- only the owner sees the slot prompts
	local function checkPrompt(child)
		if child:IsA("ProximityPrompt") and child.Name == "SlotPrompt" then
			child.Enabled = owned
		end
	end
	slot.DescendantAdded:Connect(checkPrompt)
	for _, d in ipairs(slot:GetDescendants()) do checkPrompt(d) end
end

local function watchMuseum(museum)
	local slots = museum:WaitForChild("Slots", 10)
	if not slots then return end
	local owned = museum:GetAttribute("OwnerUserId") == player.UserId
	for _, slot in ipairs(slots:GetChildren()) do
		watchSlot(slot, owned)
	end
end

museumsFolder.ChildAdded:Connect(watchMuseum)
for _, museum in ipairs(museumsFolder:GetChildren()) do
	task.spawn(watchMuseum, museum)
end


---------------------------------------------------------------------
-- SHARED: an inventory grid with a button on every meme
---------------------------------------------------------------------
local function fetchInventory()
	local ok, list = pcall(function() return getInventory:InvokeServer() end)
	if not ok or type(list) ~= "table" then return {} end
	local entries = {}
	for _, item in ipairs(list) do
		local artifact = ArtifactData.GetArtifact(item.Id)
		if artifact then
			table.insert(entries, {Artifact = artifact, Count = item.Count})
		end
	end
	-- best earners first
	table.sort(entries, function(a, b)
		local ia, ib = ArtifactData.GetIncome(a.Artifact), ArtifactData.GetIncome(b.Artifact)
		if ia ~= ib then return ia > ib end
		return a.Artifact.Name < b.Artifact.Name
	end)
	return entries
end

local function makeGrid(parent, top)
	local holder = Instance.new("ScrollingFrame")
	holder.BackgroundTransparency = 1
	holder.BorderSizePixel = 0
	holder.Size = UDim2.new(1, 0, 1, -top)
	holder.Position = UDim2.fromOffset(0, top)
	holder.ScrollBarThickness = 8
	holder.ScrollBarImageColor3 = C.Lilac
	holder.AutomaticCanvasSize = Enum.AutomaticSize.Y
	holder.CanvasSize = UDim2.new()
	holder.Parent = parent
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.fromOffset(150, 214)
	grid.CellPadding = UDim2.fromOffset(12, 12)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
	grid.Parent = holder
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.Parent = holder
	return holder
end

local function clear(holder)
	for _, child in ipairs(holder:GetChildren()) do
		if child:IsA("GuiObject") then child:Destroy() end
	end
end

-- one meme card; returns the card frame
local function memeCard(holder, entry, order, valueText)
	local artifact = entry.Artifact
	local rarity = ArtifactData.GetRarity(artifact.Rarity)
	local card = UIKit.panel(holder, {Size = UDim2.fromOffset(150, 214), Color = C.White, Radius = 20, ShadeAmount = 0.06})
	card.LayoutOrder = order
	UIKit.artifactIcon(card, artifact, {Size = UDim2.fromOffset(84, 84), Position = UDim2.new(0.5, 0, 0, 8), AnchorPoint = Vector2.new(0.5, 0)})
	if entry.Count and entry.Count > 1 then
		local tag = UIKit.panel(card, {Size = UDim2.fromOffset(44, 26), Position = UDim2.fromOffset(8, 8), Color = C.Violet, Radius = 13, Stroke = 2})
		UIKit.label(tag, "x" .. entry.Count, {Size = UDim2.fromScale(0.8, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2})
	end
	UIKit.label(card, artifact.Name, {Size = UDim2.new(1, -14, 0, 30), Position = UDim2.new(0.5, 0, 0, 96), AnchorPoint = Vector2.new(0.5, 0), Color = C.Ink, Stroke = 0, MaxText = 16})
	local tag = UIKit.panel(card, {Size = UDim2.new(1, -28, 0, 20), Position = UDim2.new(0.5, 0, 0, 128), AnchorPoint = Vector2.new(0.5, 0), Color = rarity.Color, Radius = 10, Stroke = 2})
	UIKit.label(tag, string.upper(artifact.Rarity), {Size = UDim2.fromScale(0.9, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2, StrokeColor = C.Ink, MaxText = 14})
	UIKit.label(card, valueText, {Size = UDim2.new(1, -14, 0, 16), Position = UDim2.new(0.5, 0, 0, 152), AnchorPoint = Vector2.new(0.5, 0), Color = C.Money, Stroke = 0, MaxText = 15})
	return card
end

local gui = UIKit.screen(player, "MuseumGui", 3)

---------------------------------------------------------------------
-- DISPLAY WINDOW (opened from a slot)
---------------------------------------------------------------------
local displayWindow, displayContent = UIKit.window(gui, "DISPLAY", UDim2.fromOffset(740, 580), C.Violet, "🏛️")
local currentPanel = UIKit.panel(displayContent, {Size = UDim2.new(1, 0, 0, 96), Color = C.PanelTint, Radius = 20, StrokeColor = C.Lilac})
local currentTitle = UIKit.label(currentPanel, "", {Size = UDim2.new(1, -310, 0, 30), Position = UDim2.fromOffset(104, 16), Align = "Left", Color = C.Ink, Stroke = 0, MaxText = 24})
local currentSub = UIKit.label(currentPanel, "", {Size = UDim2.new(1, -310, 0, 22), Position = UDim2.fromOffset(104, 52), Align = "Left", Color = C.Money, Stroke = 0, MaxText = 18})
local takeButton = UIKit.button(currentPanel, "TAKE BACK", {Size = UDim2.fromOffset(170, 50), Position = UDim2.new(1, -14, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), Color = C.Coral})
local currentIconHolder = Instance.new("Frame")
currentIconHolder.BackgroundTransparency = 1
currentIconHolder.Size = UDim2.fromOffset(80, 80)
currentIconHolder.Position = UDim2.fromOffset(10, 8)
currentIconHolder.Parent = currentPanel
local pickLabel = UIKit.label(displayContent, "Pick a meme from your inventory:", {Size = UDim2.new(1, 0, 0, 24), Position = UDim2.fromOffset(4, 106), Align = "Left", Color = C.Violet, Stroke = 0, MaxText = 20})
local displayGrid = makeGrid(displayContent, 134)
local displayEmpty = UIKit.label(displayContent, "Your bag is empty... go dig up some memes!", {
	Size = UDim2.new(0.9, 0, 0, 30), Position = UDim2.fromScale(0.5, 0.62), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Grey, Stroke = 0,
})

local openSlot -- slot number the window is for

local function myMuseum()
	local ref = player:FindFirstChild("Museum")
	return ref and ref.Value
end

local function refreshDisplay()
	if not openSlot then return end
	local museum = myMuseum()
	local slot = museum and museum:FindFirstChild("Slots") and museum.Slots:FindFirstChild("Slot" .. openSlot)
	local shown = slot and ArtifactData.GetArtifact(slot:GetAttribute("ArtifactId") or "")
	clear(currentIconHolder)
	if shown then
		UIKit.artifactIcon(currentIconHolder, shown, {Size = UDim2.fromScale(1, 1)})
		currentTitle.Text = "Slot " .. openSlot .. ":  " .. shown.Name
		currentSub.Text = "Earning +" .. ArtifactData.FormatMoney(ArtifactData.GetIncome(shown)) .. "/s"
		takeButton.Visible = true
		pickLabel.Text = "Swap it for another meme:"
	else
		currentTitle.Text = "Slot " .. openSlot .. " is empty"
		currentSub.Text = "Memes on display earn money every second"
		takeButton.Visible = false
		pickLabel.Text = "Pick a meme from your inventory:"
	end

	clear(displayGrid)
	local entries = fetchInventory()
	displayEmpty.Visible = #entries == 0
	for i, entry in ipairs(entries) do
		local card = memeCard(displayGrid, entry, i, "+" .. ArtifactData.FormatMoney(ArtifactData.GetIncome(entry.Artifact)) .. "/s")
		local place = UIKit.button(card, shown and "SWAP" or "PLACE", {Size = UDim2.new(1, -20, 0, 34), Position = UDim2.new(0.5, 0, 1, -8), AnchorPoint = Vector2.new(0.5, 1), Color = C.Mint})
		place.MouseButton1Click:Connect(function()
			placeRemote:FireServer(openSlot, entry.Artifact.Id)
			displayWindow.Visible = false
		end)
	end
end

takeButton.MouseButton1Click:Connect(function()
	if openSlot then
		takeRemote:FireServer(openSlot)
		displayWindow.Visible = false
	end
end)

openSlotRemote.OnClientEvent:Connect(function(slotIndex)
	openSlot = slotIndex
	refreshDisplay()
	UIKit.open(displayWindow)
end)

---------------------------------------------------------------------
-- ALIEN ART DEALER WINDOW
---------------------------------------------------------------------
local dealerWindow, dealerContent = UIKit.window(gui, "ALIEN ART DEALER", UDim2.fromOffset(740, 580), C.Mint, "👽")
UIKit.label(dealerContent, "\"Greetings, Earthling. I pay top dollar for ancient memes.\"", {
	Size = UDim2.new(1, 0, 0, 24), Position = UDim2.fromOffset(4, 4), Align = "Left", Color = C.Violet, Stroke = 0, MaxText = 20,
})
local dealerGrid = makeGrid(dealerContent, 40)
local dealerEmpty = UIKit.label(dealerContent, "Nothing to sell... go dig up some memes!", {
	Size = UDim2.new(0.9, 0, 0, 30), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Grey, Stroke = 0,
})

local function refreshDealer()
	clear(dealerGrid)
	local entries = fetchInventory()
	dealerEmpty.Visible = #entries == 0
	for i, entry in ipairs(entries) do
		local value = ArtifactData.GetSellValue(entry.Artifact)
		local card = memeCard(dealerGrid, entry, i, "Sells for " .. ArtifactData.FormatMoney(value))
		local one = UIKit.button(card, "SELL", {Size = UDim2.new(0.5, -12, 0, 34), Position = UDim2.new(0, 8, 1, -8), AnchorPoint = Vector2.new(0, 1), Color = C.Sun})
		local all = UIKit.button(card, "ALL", {Size = UDim2.new(0.5, -12, 0, 34), Position = UDim2.new(1, -8, 1, -8), AnchorPoint = Vector2.new(1, 1), Color = C.Coral})
		one.MouseButton1Click:Connect(function()
			sellRemote:FireServer(entry.Artifact.Id, false)
		end)
		all.MouseButton1Click:Connect(function()
			sellRemote:FireServer(entry.Artifact.Id, true)
		end)
	end
end

openDealerRemote.OnClientEvent:Connect(function()
	refreshDealer()
	UIKit.open(dealerWindow)
end)

inventoryChangedRemote.OnClientEvent:Connect(function()
	if dealerWindow.Visible then refreshDealer() end
	if displayWindow.Visible then refreshDisplay() end
end)

---------------------------------------------------------------------
-- FLOOR ARROWS (only while you're inside a museum)
---------------------------------------------------------------------
-- a bright elevator bar pinned to the top center of the screen:  [▼ DOWN]  🛗 FLOOR 2/3  [UP ▲]
-- (flat pills with no shading strips, so there are no stray lines)
local floorPanel = UIKit.panel(gui, {Size = UDim2.fromOffset(360, 62), Position = UDim2.new(0.5, 0, 0, 90), AnchorPoint = Vector2.new(0.5, 0),
	Color = C.Panel, Radius = 31, StrokeColor = C.Violet, Stroke = 4, Shade = false})
floorPanel.Visible = false

local function pillButton(text, color, position, anchor)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(104, 46)
	b.Position = position
	b.AnchorPoint = anchor
	b.BackgroundColor3 = color
	b.AutoButtonColor = false
	b.Text = ""
	b.Parent = floorPanel
	UIKit.corner(b, 23)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = b
	local label = UIKit.label(b, text, {Size = UDim2.new(1, -18, 0, 20), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
		Color = C.White, Stroke = 1.5, MaxText = 18})
	label.Name = "Label"
	label.Font = Enum.Font.GothamBlack
	local labelStroke = label:FindFirstChildOfClass("UIStroke")
	local function paint()
		stroke.Color = UIKit.shadeColor(b.BackgroundColor3, 0.35)
		if labelStroke then labelStroke.Color = UIKit.shadeColor(b.BackgroundColor3, 0.55) end
	end
	b:GetPropertyChangedSignal("BackgroundColor3"):Connect(paint)
	paint()
	return b
end
local downButton = pillButton("▼ DOWN", C.Violet, UDim2.new(0, 8, 0.5, 0), Vector2.new(0, 0.5))
local upButton = pillButton("UP ▲", C.Sky, UDim2.new(1, -8, 0.5, 0), Vector2.new(1, 0.5))
local floorLabel = UIKit.label(floorPanel, "FLOOR 1", {Size = UDim2.new(1, -236, 0, 24), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Ink, Stroke = 0, MaxText = 22})
-- the price of the next floor hangs under the bar when it's still locked
local pricePill = UIKit.panel(floorPanel, {Size = UDim2.fromOffset(190, 28), Position = UDim2.new(0.5, 0, 1, 6), AnchorPoint = Vector2.new(0.5, 0), Color = C.Coral, Radius = 14, Stroke = 2.5, Shade = false})
local upPrice = UIKit.label(pricePill, "", {Size = UDim2.new(1, -16, 0.72, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.White, Stroke = 2, MaxText = 15})
pricePill.Visible = false
-- a soft glow pulsing around the bar so it's easy to spot
local barStroke = floorPanel:FindFirstChildOfClass("UIStroke")
task.spawn(function()
	while true do
		if floorPanel.Visible and barStroke then
			barStroke.Color = C.Violet:Lerp(C.Sky, 0.5 + 0.5 * math.sin(os.clock() * 3))
		end
		task.wait(0.05)
	end
end)

local function currentMuseumFloor()
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end
	for _, museum in ipairs(museumsFolder:GetChildren()) do
		local floor = GameConfig.GetMuseumFloor(museum, root.Position)
		if floor then return museum, floor end
	end
	return nil
end

-- both buttons always stay in place (so the bar never looks lopsided); one that can't be
-- used right now is greyed out instead of disappearing
local canGo = {[upButton] = false, [downButton] = false}
local function setUsable(button, usable, color)
	canGo[button] = usable
	button.BackgroundColor3 = usable and color or C.Lilac:Lerp(C.Grey, 0.5)
	local label = button:FindFirstChild("Label")
	if label then label.TextTransparency = usable and 0 or 0.45 end
end
upButton.MouseButton1Click:Connect(function()
	if canGo[upButton] then floorRemote:FireServer(1) end
end)
downButton.MouseButton1Click:Connect(function()
	if canGo[downButton] then floorRemote:FireServer(-1) end
end)

task.spawn(function()
	local topFloor = #GameConfig.FloorPrices
	while true do
		local museum, floor = currentMuseumFloor()
		floorPanel.Visible = museum ~= nil
		if museum then
			local opened = string.split(museum:GetAttribute("UnlockedFloors") or "1", ",")
			local owned = museum:GetAttribute("OwnerUserId") == player.UserId
			local nextOpen = table.find(opened, tostring(floor + 1)) ~= nil
			floorLabel.Text = "🛗 FLOOR " .. floor .. "/" .. topFloor
			local canUp = floor < topFloor and (nextOpen or owned)
			local buying = canUp and not nextOpen
			setUsable(upButton, canUp, buying and C.Coral or C.Sky)
			setUsable(downButton, floor > 1, C.Violet)
			pricePill.Visible = buying
			if buying then
				upPrice.Text = "🔒 Unlock " .. ArtifactData.FormatMoney(GameConfig.FloorPrices[floor + 1])
			end
		end
		task.wait(0.25)
	end
end)
