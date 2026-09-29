-- MuseumClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The museum side of the UI (World 1 only):
--   * a spinning, floating meme card over every pedestal that has a meme on it (in every
--     player's museum, so visitors can see your collection too)
--   * the Display window: pick a meme from your inventory to put on a slot, or take it back
--   * the Alien Art Dealer window: sell memes for cash
-- Slot prompts only show up in your own museum.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
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

local player = Players.LocalPlayer
local museumsFolder = workspace:WaitForChild("Museums")

---------------------------------------------------------------------
-- SPINNING MEME CARDS ON THE PEDESTALS
---------------------------------------------------------------------
local cards = {} -- [slot model] = {Part, Base CFrame, Phase}

local function removeCard(slot)
	local card = cards[slot]
	if card then
		card.Part:Destroy()
		cards[slot] = nil
	end
end

local function cardFace(part, face, artifact)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 50
	gui.LightInfluence = 0
	gui.Parent = part
	UIKit.artifactIcon(gui, artifact, {Size = UDim2.fromScale(1, 1), Radius = 28, Stroke = 6})
end

local function updateCard(slot)
	removeCard(slot)
	local artifact = ArtifactData.GetArtifact(slot:GetAttribute("ArtifactId") or "")
	local spot = slot:FindFirstChild("DisplaySpot")
	if not artifact or not spot then return end
	local rarity = ArtifactData.GetRarity(artifact.Rarity)

	local part = Instance.new("Part")
	part.Name = "MemeCard"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Size = Vector3.new(4.4, 4.4, 0.35)
	part.Color = rarity.Color
	part.Material = Enum.Material.SmoothPlastic
	cardFace(part, Enum.NormalId.Front, artifact)
	cardFace(part, Enum.NormalId.Back, artifact)
	local light = Instance.new("PointLight")
	light.Color = rarity.Color
	light.Range = 10
	light.Brightness = 0.7
	light.Parent = part
	-- fancier memes sparkle
	if ArtifactData.GetRarityIndex(artifact.Rarity) >= 5 then
		local sparkles = Instance.new("ParticleEmitter")
		sparkles.Rate = 4
		sparkles.Lifetime = NumberRange.new(0.8, 1.4)
		sparkles.Speed = NumberRange.new(0.5, 1.2)
		sparkles.SpreadAngle = Vector2.new(180, 180)
		sparkles.Size = NumberSequence.new(0.25, 0)
		sparkles.LightEmission = 0.8
		sparkles.Color = ColorSequence.new(rarity.Color)
		sparkles.Parent = part
	end
	local base = CFrame.new(spot.Position + Vector3.new(0, 1, 0))
	part.CFrame = base
	part.Parent = slot
	cards[slot] = {Part = part, Base = base, Phase = (slot:GetAttribute("SlotIndex") or 1) * 0.7}
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

RunService.RenderStepped:Connect(function()
	local t = os.clock()
	for _, card in pairs(cards) do
		local bob = math.sin(t * 1.6 + card.Phase) * 0.3
		card.Part.CFrame = card.Base * CFrame.new(0, bob, 0) * CFrame.Angles(0, t * 0.9 + card.Phase, 0)
	end
end)

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
	local card = UIKit.panel(holder, {Size = UDim2.fromOffset(150, 214), Color = C.Row, Radius = 18})
	card.LayoutOrder = order
	UIKit.artifactIcon(card, artifact, {Size = UDim2.fromOffset(84, 84), Position = UDim2.new(0.5, 0, 0, 8), AnchorPoint = Vector2.new(0.5, 0)})
	if entry.Count and entry.Count > 1 then
		local tag = UIKit.panel(card, {Size = UDim2.fromOffset(44, 26), Position = UDim2.fromOffset(8, 8), Color = C.Violet, Radius = 13, Stroke = 2})
		UIKit.label(tag, "x" .. entry.Count, {Size = UDim2.fromScale(0.8, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2})
	end
	UIKit.label(card, artifact.Name, {Size = UDim2.new(1, -14, 0, 32), Position = UDim2.new(0.5, 0, 0, 96), AnchorPoint = Vector2.new(0.5, 0), Color = C.Ink, Stroke = 0})
	local tag = UIKit.panel(card, {Size = UDim2.new(1, -24, 0, 16), Position = UDim2.new(0.5, 0, 0, 130), AnchorPoint = Vector2.new(0.5, 0), Color = rarity.Color, Radius = 8, Stroke = 2, Shade = false})
	UIKit.label(tag, string.upper(artifact.Rarity), {Size = UDim2.fromScale(0.9, 0.85), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2})
	UIKit.label(card, valueText, {Size = UDim2.new(1, -14, 0, 16), Position = UDim2.new(0.5, 0, 0, 150), AnchorPoint = Vector2.new(0.5, 0), Color = C.Money, Stroke = 0})
	return card
end

local gui = UIKit.screen(player, "MuseumGui", 3)

---------------------------------------------------------------------
-- DISPLAY WINDOW (opened from a slot)
---------------------------------------------------------------------
local displayWindow, displayContent = UIKit.window(gui, "DISPLAY", UDim2.fromOffset(720, 560), C.Lilac)
local currentPanel = UIKit.panel(displayContent, {Size = UDim2.new(1, 0, 0, 96), Color = C.PanelTint, Radius = 18})
local currentTitle = UIKit.label(currentPanel, "", {Size = UDim2.new(1, -330, 0, 30), Position = UDim2.fromOffset(104, 14), Align = "Left", Color = C.Ink, Stroke = 0})
local currentSub = UIKit.label(currentPanel, "", {Size = UDim2.new(1, -330, 0, 22), Position = UDim2.fromOffset(104, 50), Align = "Left", Color = C.Money, Stroke = 0})
local takeButton = UIKit.button(currentPanel, "TAKE BACK", {Size = UDim2.fromOffset(170, 50), Position = UDim2.new(1, -14, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), Color = C.Coral})
local currentIconHolder = Instance.new("Frame")
currentIconHolder.BackgroundTransparency = 1
currentIconHolder.Size = UDim2.fromOffset(80, 80)
currentIconHolder.Position = UDim2.fromOffset(10, 8)
currentIconHolder.Parent = currentPanel
local pickLabel = UIKit.label(displayContent, "Pick a meme from your inventory:", {Size = UDim2.new(1, 0, 0, 26), Position = UDim2.fromOffset(4, 104), Align = "Left", Color = C.Violet, Stroke = 0})
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
local dealerWindow, dealerContent = UIKit.window(gui, "ALIEN ART DEALER", UDim2.fromOffset(720, 560), C.Mint)
UIKit.label(dealerContent, "\"Greetings, Earthling. I pay top dollar for ancient memes.\"", {
	Size = UDim2.new(1, 0, 0, 26), Position = UDim2.fromOffset(4, 4), Align = "Left", Color = C.Violet, Stroke = 0,
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
