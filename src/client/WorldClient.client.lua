-- WorldClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The World Map opened at any World Gate: shows every world, whether it's unlocked,
-- its price, and lets you unlock it or travel there.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local openWorldMapRemote = remotes:WaitForChild("OpenWorldMap")
local buyWorldRemote = remotes:WaitForChild("BuyWorld")
local travelRemote = remotes:WaitForChild("TravelToWorld")

local player = Players.LocalPlayer

-- desaturated 2050 panel colors
local PANEL = Color3.fromRGB(30, 31, 34)
local ROW = Color3.fromRGB(46, 48, 52)
local STEEL = Color3.fromRGB(150, 154, 160)
local TEXT = Color3.fromRGB(222, 218, 210)
local SUBTEXT = Color3.fromRGB(150, 156, 164)
local GO = Color3.fromRGB(86, 120, 98)
local BUY = Color3.fromRGB(150, 122, 70)
local LOCKED = Color3.fromRGB(110, 60, 58)
local IDLE = Color3.fromRGB(70, 72, 78)

local gui = Instance.new("ScreenGui")
gui.Name = "WorldMapGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 6)
	c.Parent = parent
end

local function label(parent, text, size, position, color, font)
	local l = Instance.new("TextLabel")
	l.Size = size
	l.Position = position
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = color
	l.Font = font or Enum.Font.GothamMedium
	l.TextScaled = true
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 560, 0, 470)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = PANEL
frame.Visible = false
frame.Parent = gui
corner(frame, 8)
local frameStroke = Instance.new("UIStroke")
frameStroke.Color = STEEL
frameStroke.Thickness = 1.5
frameStroke.Parent = frame

label(frame, "WORLD MAP", UDim2.new(0, 300, 0, 30), UDim2.new(0, 20, 0, 14), TEXT, Enum.Font.GothamBold)
local moneyLabel = label(frame, "", UDim2.new(0, 200, 0, 20), UDim2.new(1, -270, 0, 20), SUBTEXT)
moneyLabel.TextXAlignment = Enum.TextXAlignment.Right

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 34, 0, 34)
close.Position = UDim2.new(1, -48, 0, 12)
close.BackgroundColor3 = IDLE
close.Text = "X"
close.TextColor3 = TEXT
close.Font = Enum.Font.GothamBold
close.TextScaled = true
close.Parent = frame
corner(close, 6)
close.MouseButton1Click:Connect(function()
	frame.Visible = false
end)

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -30, 1, -70)
list.Position = UDim2.new(0, 15, 0, 58)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 5
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new()
list.Parent = frame
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

local buttons = {} -- [worldId] = button

for _, world in ipairs(GameConfig.Worlds) do
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -8, 0, 58)
	row.BackgroundColor3 = ROW
	row.LayoutOrder = world.Id
	row.Parent = list
	corner(row, 6)
	label(row, world.Id .. ".  " .. string.upper(world.Name), UDim2.new(0, 330, 0, 22), UDim2.new(0, 14, 0, 7), TEXT, Enum.Font.GothamBold)
	local sub = world.Enabled and (#world.Shovels .. " shovels  •  4 depth zones down to " .. -world.Zones[#world.Zones].Bottom .. "m")
		or "Still being excavated. Coming soon."
	label(row, sub, UDim2.new(0, 330, 0, 16), UDim2.new(0, 14, 0, 33), SUBTEXT, Enum.Font.Gotham)

	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 150, 0, 38)
	b.Position = UDim2.new(1, -162, 0.5, -19)
	b.TextColor3 = TEXT
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	b.Parent = row
	corner(b, 6)
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 8)
	pad.Parent = b
	buttons[world.Id] = b

	b.MouseButton1Click:Connect(function()
		local unlocked = table.find(string.split(player:GetAttribute("UnlockedWorlds") or "1", ","), tostring(world.Id))
		if not world.Enabled then
			return
		elseif unlocked then
			if player:GetAttribute("CurrentWorld") ~= world.Id then
				travelRemote:FireServer(world.Id)
				frame.Visible = false
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
			b.Text = "SOON  ·  " .. ArtifactData.FormatMoney(world.Price)
			b.BackgroundColor3 = IDLE
		elseif world.Id == current then
			b.Text = "YOU ARE HERE"
			b.BackgroundColor3 = IDLE
		elseif table.find(unlocked, tostring(world.Id)) then
			b.Text = "TRAVEL"
			b.BackgroundColor3 = GO
		else
			b.Text = "UNLOCK " .. ArtifactData.FormatMoney(world.Price)
			b.BackgroundColor3 = (money >= world.Price) and BUY or LOCKED
		end
	end
end

for _, attribute in ipairs({"Money", "UnlockedWorlds", "CurrentWorld"}) do
	player:GetAttributeChangedSignal(attribute):Connect(function()
		if frame.Visible then refresh() end
	end)
end

local scale = Instance.new("UIScale")
scale.Parent = frame
openWorldMapRemote.OnClientEvent:Connect(function()
	refresh()
	frame.Visible = true
	scale.Scale = 0.85
	TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()
end)
