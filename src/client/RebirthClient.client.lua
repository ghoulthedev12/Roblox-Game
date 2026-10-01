-- RebirthClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The REBIRTH window (the Rebirth button on the HUD): how close you are to your next rebirth,
-- what it gives you, the rebirth button, and the gem shop's Lucky Charm upgrade.
-- The server side is RebirthManager.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local UIBus = require(ReplicatedStorage:WaitForChild("UIBus"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local player = Players.LocalPlayer
local gui = UIKit.screen(player, "RebirthGui", 3)
local window, content = UIKit.window(gui, "REBIRTH", UDim2.fromOffset(560, 470), C.Coral, "Rebirth")

-- REBIRTH card
local card = UIKit.panel(content, {Size = UDim2.new(1, -8, 0, 236), Position = UDim2.fromOffset(4, 4), Color = C.White, Radius = 20, Shade = false})
local title = UIKit.label(card, "", {Size = UDim2.new(1, -30, 0, 30), Position = UDim2.fromOffset(16, 12), Align = "Left", Color = C.Ink, Stroke = 0, MaxText = 26})
local perks = UIKit.label(card, "", {Size = UDim2.new(1, -30, 0, 46), Position = UDim2.fromOffset(16, 46), Align = "Left", VAlign = "Top", Color = C.Grey, Stroke = 0, Font = UIKit.BodyFont, TextSize = 15})
local track = UIKit.panel(card, {Size = UDim2.new(1, -32, 0, 26), Position = UDim2.fromOffset(16, 104), Color = C.PanelTint, Radius = 13, Stroke = 2, StrokeColor = C.Lilac, Shade = false})
local fill = UIKit.panel(track, {Size = UDim2.fromScale(0, 1), Color = C.Money, Radius = 13, Stroke = false, Shade = false})
local progress = UIKit.label(track, "", {Size = UDim2.new(1, -16, 0.8, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.White, Stroke = 2, MaxText = 16})
progress.ZIndex = 3
UIKit.label(card, "You keep your memes, museum, pickaxes and worlds. Only your cash resets.", {Size = UDim2.new(1, -30, 0, 18), Position = UDim2.fromOffset(16, 138),
	Align = "Left", Color = C.Grey, Stroke = 0, Font = UIKit.BodyFont, MaxText = 14})
local rebirthButton = UIKit.button(card, "REBIRTH", {Icon = "Rebirth", Size = UDim2.new(1, -32, 0, 56), Position = UDim2.new(0.5, 0, 1, -70), AnchorPoint = Vector2.new(0.5, 0), Color = C.Coral, MaxText = 26})

-- GEM SHOP card
local gemCard = UIKit.panel(content, {Size = UDim2.new(1, -8, 0, 130), Position = UDim2.fromOffset(4, 252), Color = C.White, Radius = 20, Shade = false})
UIKit.badge(gemCard, "Luck", C.Mint, {Diameter = 56, Position = UDim2.new(0, 14, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)})
local charmTitle = UIKit.label(gemCard, "", {Size = UDim2.new(0.6, -80, 0, 28), Position = UDim2.fromOffset(84, 22), Align = "Left", Color = C.Ink, Stroke = 0, MaxText = 22})
local charmText = UIKit.label(gemCard, "", {Size = UDim2.new(0.6, -80, 0, 40), Position = UDim2.fromOffset(84, 54), Align = "Left", VAlign = "Top", Color = C.Grey, Stroke = 0, Font = UIKit.BodyFont, TextSize = 14})
local charmButton = UIKit.button(gemCard, "", {Icon = "Gem", Size = UDim2.new(0.36, 0, 0, 54), Position = UDim2.new(1, -14, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), Color = C.Violet, MaxText = 20})

local function refresh()
	local rebirths = player:GetAttribute("Rebirths") or 0
	local money = player:GetAttribute("Money") or 0
	local gems = player:GetAttribute("Gems") or 0
	local cost = GameConfig.RebirthCost(rebirths)
	local bonus = math.floor(GameConfig.RebirthIncomeBonus * 100)
	title.Text = "Rebirth " .. rebirths .. "  →  " .. (rebirths + 1)
	perks.Text = "Now: +" .. bonus * rebirths .. "% income.   After rebirthing: +" .. bonus * (rebirths + 1) .. "% income and +"
		.. GameConfig.RebirthGemReward(rebirths) .. " gems."
	fill.Size = UDim2.fromScale(math.clamp(money / cost, 0, 1), 1)
	progress.Text = ArtifactData.FormatMoney(money) .. " / " .. ArtifactData.FormatMoney(cost)
	UIKit.setButton(rebirthButton, money >= cost and "REBIRTH NOW" or "NEED " .. ArtifactData.FormatMoney(cost), money >= cost and C.Coral or C.Grey,
		money >= cost and "Rebirth" or "Lock")

	local level = player:GetAttribute("GemLuckLevel") or 0
	local maxed = level >= GameConfig.GemLuckMaxLevel
	local charmCost = (level + 1) * GameConfig.GemLuckCost
	charmTitle.Text = "Lucky Charm  ·  Lv " .. level
	charmText.Text = "+" .. math.floor(GameConfig.GemLuckPerLevel * 100 * level) .. "% luck on every dig. Each level adds +" .. math.floor(GameConfig.GemLuckPerLevel * 100) .. "%. You have " .. gems .. " gems."
	UIKit.setButton(charmButton, maxed and "MAXED" or tostring(charmCost), (not maxed and gems >= charmCost) and C.Violet or C.Grey, maxed and "Star" or "Gem")
end

rebirthButton.MouseButton1Click:Connect(function()
	remotes:WaitForChild("Rebirth"):FireServer()
end)
charmButton.MouseButton1Click:Connect(function()
	remotes:WaitForChild("BuyGemUpgrade"):FireServer()
end)
for _, attribute in ipairs({"Money", "Gems", "Rebirths", "GemLuckLevel"}) do
	player:GetAttributeChangedSignal(attribute):Connect(function()
		if window.Visible then refresh() end
	end)
end
UIBus.On("Rebirth", function()
	if window.Visible then
		window.Visible = false
	else
		refresh()
		UIKit.open(window)
	end
end)
