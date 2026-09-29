-- WorldClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The World Map opened at any World Gate: a card per world showing whether it's unlocked,
-- its price, and a button to unlock it or travel there.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local openWorldMapRemote = remotes:WaitForChild("OpenWorldMap")
local buyWorldRemote = remotes:WaitForChild("BuyWorld")
local travelRemote = remotes:WaitForChild("TravelToWorld")

local player = Players.LocalPlayer
local gui = UIKit.screen(player, "WorldMapGui", 3)

local window, content = UIKit.window(gui, "WORLD MAP", UDim2.fromOffset(640, 540), C.Sky)

local moneyTag = UIKit.panel(content, {Size = UDim2.fromOffset(190, 36), Position = UDim2.new(1, 0, 0, 0), AnchorPoint = Vector2.new(1, 0), Color = C.Money, Radius = 18})
local moneyLabel = UIKit.label(moneyTag, "", {Size = UDim2.new(1, -20, 0.8, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2})
UIKit.label(content, "Unlock new dig sites with cash!", {Size = UDim2.new(1, -210, 0, 28), Position = UDim2.fromOffset(4, 4), Align = "Left", Color = C.Violet, Stroke = 0})

local listHolder = Instance.new("Frame")
listHolder.BackgroundTransparency = 1
listHolder.Size = UDim2.new(1, 0, 1, -48)
listHolder.Position = UDim2.fromOffset(0, 46)
listHolder.Parent = content
local list = UIKit.list(listHolder, 10)

local PLANET_COLORS = {C.Mint, C.Sun, C.Coral, C.Sky, C.Lilac, C.Violet, C.Money, C.Coral, C.Sky}
local buttons = {} -- [worldId] = button

for _, world in ipairs(GameConfig.Worlds) do
	local card = UIKit.panel(list, {Size = UDim2.new(1, -6, 0, 84), Color = world.Enabled and C.Row or C.PanelTint, Radius = 18})
	card.LayoutOrder = world.Id
	-- little planet badge with the world number
	local planet = UIKit.panel(card, {Size = UDim2.fromOffset(60, 60), Position = UDim2.new(0, 12, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Color = PLANET_COLORS[world.Id] or C.Lilac, Radius = 30})
	UIKit.label(planet, tostring(world.Id), {Size = UDim2.fromScale(0.6, 0.6), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 3})
	UIKit.label(card, world.Name, {Size = UDim2.new(0.6, -90, 0, 28), Position = UDim2.fromOffset(86, 12), Align = "Left", Color = C.Ink, Stroke = 0})
	local sub = world.Enabled and (#world.Shovels .. " shovels  •  digs down to " .. -world.Zones[#world.Zones].Bottom .. "m")
		or "Still being excavated... coming soon!"
	UIKit.label(card, sub, {Size = UDim2.new(0.6, -90, 0, 20), Position = UDim2.fromOffset(86, 46), Align = "Left", Color = C.Grey, Stroke = 0})

	local b = UIKit.button(card, "", {Size = UDim2.new(0.3, 0, 0, 52), Position = UDim2.new(1, -14, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5)})
	buttons[world.Id] = b
	b.MouseButton1Click:Connect(function()
		local unlocked = table.find(string.split(player:GetAttribute("UnlockedWorlds") or "1", ","), tostring(world.Id))
		if not world.Enabled then
			return
		elseif unlocked then
			if player:GetAttribute("CurrentWorld") ~= world.Id then
				travelRemote:FireServer(world.Id)
				window.Visible = false
			end
		else
			buyWorldRemote:FireServer(world.Id)
		end
	end)
end

local function refresh()
	local money = player:GetAttribute("Money") or 0
	local unlocked = string.split(player:GetAttribute("UnlockedWorlds") or "1", ",")
	local current = player:GetAttribute("CurrentWorld") or 1
	moneyLabel.Text = ArtifactData.FormatMoney(money)
	for _, world in ipairs(GameConfig.Worlds) do
		local b = buttons[world.Id]
		if not world.Enabled then
			UIKit.setButton(b, "SOON • " .. ArtifactData.FormatMoney(world.Price), C.Grey)
		elseif world.Id == current then
			UIKit.setButton(b, "YOU ARE HERE", C.Lilac)
		elseif table.find(unlocked, tostring(world.Id)) then
			UIKit.setButton(b, "TRAVEL", C.Sky)
		else
			UIKit.setButton(b, "UNLOCK " .. ArtifactData.FormatMoney(world.Price), money >= world.Price and C.Mint or C.Coral)
		end
	end
end

for _, attribute in ipairs({"Money", "UnlockedWorlds", "CurrentWorld"}) do
	player:GetAttributeChangedSignal(attribute):Connect(function()
		if window.Visible then refresh() end
	end)
end

openWorldMapRemote.OnClientEvent:Connect(function()
	refresh()
	UIKit.open(window)
end)
