-- InventoryClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The Inventory window: every meme you've picked up, as icon tiles sorted from rarest to
-- most common, with how many you have and how much each one earns on display.
-- Open it with the bag button on the left or the B key.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local getInventory = remotes:WaitForChild("GetInventory")
local inventoryChangedRemote = remotes:WaitForChild("InventoryChanged")

local player = Players.LocalPlayer
local gui = UIKit.screen(player, "InventoryGui", 3)

---------------------------------------------------------------------
-- BAG BUTTON (left side, under the money pills)
---------------------------------------------------------------------
local bagButton = UIKit.button(gui, "", {Size = UDim2.fromOffset(66, 66), Position = UDim2.new(0, 18, 0, 170), Color = C.Sun, Radius = 20})
local bagEmoji = Instance.new("TextLabel")
bagEmoji.BackgroundTransparency = 1
bagEmoji.Size = UDim2.fromScale(0.62, 0.62)
bagEmoji.Position = UDim2.fromScale(0.5, 0.45)
bagEmoji.AnchorPoint = Vector2.new(0.5, 0.5)
bagEmoji.Text = "🎒"
bagEmoji.TextScaled = true
bagEmoji.Parent = bagButton
local bagTag = UIKit.panel(bagButton, {Size = UDim2.fromOffset(62, 22), Position = UDim2.new(0.5, 0, 1, 2), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Ink, Radius = 11, StrokeColor = C.Sun})
UIKit.label(bagTag, "BAG [B]", {Size = UDim2.new(1, -10, 1, -6), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 0, MaxText = 14})

---------------------------------------------------------------------
-- WINDOW
---------------------------------------------------------------------
local window, content = UIKit.window(gui, "INVENTORY", UDim2.fromOffset(740, 560), C.Sun, "🎒")
local countLabel = UIKit.label(content, "", {Size = UDim2.new(1, 0, 0, 26), Position = UDim2.fromOffset(4, 4), Align = "Left", Color = C.Violet, Stroke = 0, MaxText = 22})

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

local function refresh()
	local ok, list = pcall(function() return getInventory:InvokeServer() end)
	if not ok or type(list) ~= "table" then return end
	for _, child in ipairs(gridHolder:GetChildren()) do
		if child:IsA("GuiObject") then child:Destroy() end
	end
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
		local card = UIKit.panel(gridHolder, {Size = UDim2.fromOffset(150, 186), Color = C.White, Radius = 20, ShadeAmount = 0.06})
		card.LayoutOrder = i
		UIKit.artifactIcon(card, artifact, {Size = UDim2.fromOffset(96, 96), Position = UDim2.new(0.5, 0, 0, 10), AnchorPoint = Vector2.new(0.5, 0)})
		if entry.Count > 1 then
			local countTag = UIKit.panel(card, {Size = UDim2.fromOffset(44, 28), Position = UDim2.fromOffset(8, 8), Color = C.Violet, Radius = 14, Stroke = 2})
			UIKit.label(countTag, "x" .. entry.Count, {Size = UDim2.fromScale(0.8, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2})
		end
		UIKit.label(card, artifact.Name, {Size = UDim2.new(1, -14, 0, 32), Position = UDim2.new(0.5, 0, 0, 110), AnchorPoint = Vector2.new(0.5, 0), Color = C.Ink, Stroke = 0, MaxText = 16})
		local rarityTag = UIKit.panel(card, {Size = UDim2.new(1, -28, 0, 20), Position = UDim2.new(0.5, 0, 0, 144), AnchorPoint = Vector2.new(0.5, 0), Color = rarity.Color, Radius = 10, Stroke = 2})
		UIKit.label(rarityTag, string.upper(artifact.Rarity), {Size = UDim2.fromScale(0.9, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2, StrokeColor = C.Ink, MaxText = 14})
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

bagButton.MouseButton1Click:Connect(toggle)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.B then
		toggle()
	end
end)
inventoryChangedRemote.OnClientEvent:Connect(function()
	if window.Visible then refresh() end
	-- little bounce on the bag so players notice the new item
	UIKit.pop(bagButton, 1.3)
end)
