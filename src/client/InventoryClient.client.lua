-- InventoryClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The Inventory window: every meme you've picked up, as cards showing its real 3D model,
-- sorted from rarest to most common, with how many you have and how much each one earns.
-- Click a card to hold that meme in your hand (MemeToolManager); click it again to put it away.
-- Open it with the BAG button on the HUD or the B key.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local getInventory = remotes:WaitForChild("GetInventory")
local inventoryChangedRemote = remotes:WaitForChild("InventoryChanged")
local equipRemote = remotes:WaitForChild("EquipMeme")

local player = Players.LocalPlayer
local gui = UIKit.screen(player, "InventoryGui", 3)

---------------------------------------------------------------------
-- WINDOW
---------------------------------------------------------------------
local window, content = UIKit.window(gui, "INVENTORY", UDim2.fromOffset(740, 560), C.Sun, "Bag")
local countLabel = UIKit.label(content, "", {Size = UDim2.new(1, -260, 0, 26), Position = UDim2.fromOffset(4, 4), Align = "Left", Color = C.Violet, Stroke = 0, MaxText = 22})
UIKit.label(content, "Click a meme to hold it", {Size = UDim2.new(1, -260, 0, 14), Position = UDim2.fromOffset(4, 28), Align = "Left", Color = C.Grey, Stroke = 0,
	Font = UIKit.BodyFont, MaxText = 13})
-- fills every empty display slot in your museum with your best-earning memes
local placeAllButton = UIKit.button(content, "PLACE ALL IN MUSEUM", {Icon = "Museum", Size = UDim2.fromOffset(270, 40), Position = UDim2.new(1, -4, 0, 0), AnchorPoint = Vector2.new(1, 0), Color = C.Violet, Radius = 19, MaxText = 16})
placeAllButton.MouseButton1Click:Connect(function()
	remotes:WaitForChild("PlaceAll"):FireServer()
end)

local gridHolder = Instance.new("ScrollingFrame")
gridHolder.BackgroundTransparency = 1
gridHolder.BorderSizePixel = 0
gridHolder.Size = UDim2.new(1, 0, 1, -44)
gridHolder.Position = UDim2.fromOffset(0, 42)
gridHolder.ScrollBarThickness = 8
gridHolder.ScrollBarImageColor3 = C.Lilac
gridHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
gridHolder.CanvasSize = UDim2.new()
gridHolder.Parent = content
local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.fromOffset(150, 186)
grid.CellPadding = UDim2.fromOffset(12, 12)
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
grid.Parent = gridHolder
local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 8)
pad.PaddingBottom = UDim.new(0, 8)
pad.Parent = gridHolder

local emptyLabel = UIKit.label(content, "Nothing here yet... go dig up some memes!", {
	Size = UDim2.new(0.9, 0, 0, 30), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Grey, Stroke = 0,
})

-- rainbow borders spin slowly
local RAINBOW = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 80)), ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 200, 60)),
	ColorSequenceKeypoint.new(0.4, Color3.fromRGB(90, 230, 110)), ColorSequenceKeypoint.new(0.6, Color3.fromRGB(70, 170, 255)),
	ColorSequenceKeypoint.new(0.8, Color3.fromRGB(180, 90, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 80)),
})
local rainbows = {}
game:GetService("RunService").RenderStepped:Connect(function()
	if not window.Visible then return end
	local r = (os.clock() * 90) % 360
	for _, gradient in ipairs(rainbows) do gradient.Rotation = r end
end)

local function refresh()
	local ok, list = pcall(function() return getInventory:InvokeServer() end)
	if not ok or type(list) ~= "table" then return end
	for _, child in ipairs(gridHolder:GetChildren()) do
		if child:IsA("GuiObject") then child:Destroy() end
	end
	rainbows = {}
	-- rarest first, then by name
	local entries, total = {}, 0
	for _, item in ipairs(list) do
		local artifact = ArtifactData.GetArtifact(item.Id)
		if artifact then
			table.insert(entries, {Artifact = artifact, Count = item.Count})
			total += item.Count
		end
	end
	table.sort(entries, function(a, b)
		local ra, rb = ArtifactData.GetRarityIndex(a.Artifact.Rarity), ArtifactData.GetRarityIndex(b.Artifact.Rarity)
		if ra ~= rb then return ra > rb end
		return a.Artifact.Name < b.Artifact.Name
	end)
	countLabel.Text = total .. " memes  •  " .. #entries .. " different"
	emptyLabel.Visible = #entries == 0

	for i, entry in ipairs(entries) do
		local artifact = entry.Artifact
		local rarity = ArtifactData.GetRarity(artifact.Rarity)
		-- the card's border shows the rarity (secret rarities get an animated rainbow border)
		local card = UIKit.panel(gridHolder, {Size = UDim2.fromOffset(150, 186), Color = C.White, Radius = 20, Stroke = 4, StrokeColor = rarity.Color, ShadeAmount = 0.06})
		card.LayoutOrder = i
		if ArtifactData.IsSecret(artifact.Rarity) then
			local border = card:FindFirstChildOfClass("UIStroke")
			border.Color = Color3.new(1, 1, 1)
			local rainbow = Instance.new("UIGradient")
			rainbow.Color = RAINBOW
			rainbow.Parent = border
			table.insert(rainbows, rainbow)
		end
		UIKit.artifactIcon(card, artifact, {Size = UDim2.fromOffset(96, 96), Position = UDim2.new(0.5, 0, 0, 10), AnchorPoint = Vector2.new(0.5, 0)})
		if entry.Count > 1 then
			local countTag = UIKit.panel(card, {Size = UDim2.fromOffset(44, 28), Position = UDim2.fromOffset(8, 8), Color = C.Violet, Radius = 14, Stroke = 2})
			UIKit.label(countTag, "x" .. entry.Count, {Size = UDim2.fromScale(0.8, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2})
		end
		UIKit.label(card, artifact.Name, {Size = UDim2.new(1, -14, 0, 32), Position = UDim2.new(0.5, 0, 0, 110), AnchorPoint = Vector2.new(0.5, 0), Color = C.Ink, Stroke = 0, MaxText = 16})
		local rarityTag = UIKit.panel(card, {Size = UDim2.new(1, -28, 0, 20), Position = UDim2.new(0.5, 0, 0, 144), AnchorPoint = Vector2.new(0.5, 0), Color = rarity.Color, Radius = 10, Stroke = 2})
		UIKit.label(rarityTag, string.upper(artifact.Rarity), {Size = UDim2.fromScale(0.9, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2, StrokeColor = C.Ink, MaxText = 14})
		-- click: hold it in your hand (or put it away if you already are)
		local holding = player:GetAttribute("HeldMeme") == artifact.Id
		if holding then
			local tag = UIKit.panel(card, {Size = UDim2.fromOffset(78, 24), Position = UDim2.new(0.5, 0, 0, 84), AnchorPoint = Vector2.new(0.5, 0),
				Color = C.Mint, Radius = 12, Stroke = 2})
			UIKit.label(tag, "IN HAND", {Size = UDim2.fromScale(0.85, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2})
			card:FindFirstChildOfClass("UIStroke").Thickness = 6
		end
		local hit = Instance.new("TextButton")
		hit.Name = "Hold"
		hit.Text = ""
		hit.BackgroundTransparency = 1
		hit.Size = UDim2.fromScale(1, 1)
		hit.ZIndex = 20
		hit.Parent = card
		hit.MouseButton1Click:Connect(function()
			equipRemote:FireServer(artifact.Id)
		end)
		UIKit.label(card, ArtifactData.FormatMoney(ArtifactData.GetIncome(artifact)) .. "/s", {Size = UDim2.new(1, -14, 0, 16), Position = UDim2.new(0.5, 0, 1, -20), AnchorPoint = Vector2.new(0.5, 0), Color = C.Money, Stroke = 0, MaxText = 15})
	end
end

local function toggle()
	if window.Visible then
		window.Visible = false
	else
		refresh()
		UIKit.open(window)
	end
end

local UIBus = require(ReplicatedStorage:WaitForChild("UIBus"))
UIBus.On("Inventory", toggle) -- the BAG button on the HUD
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.B then
		toggle()
	end
end)
inventoryChangedRemote.OnClientEvent:Connect(function()
	if window.Visible then refresh() end
end)
player:GetAttributeChangedSignal("HeldMeme"):Connect(function()
	if window.Visible then refresh() end
end)
