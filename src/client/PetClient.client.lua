-- PetClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Pets on your screen (see ReplicatedStorage.PetData and the PetManager server script):
--   * FOLLOWING: every player's equipped pets (workspace.PlayerPets) trot along behind
--     them, hopping as they go; flying pets hover and bob beside them.
--   * EGG STANDS: the eggs on the stands turn slowly and bob.
--   * PETS WINDOW (the Pets button on the left, P, or UIBus "Pets"): your pets as a grid,
--     your total boosts, Equip Best, and for the pet you pick: its boosts, Equip/Unequip and
--     Delete.
--   * HATCHING: the egg wobbles, cracks in a flash of light and the pet pops out, with its
--     rarity and boosts.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Audio = require(ReplicatedStorage:WaitForChild("Audio"))
local PetData = require(ReplicatedStorage:WaitForChild("PetData"))
local PetVisuals = require(ReplicatedStorage:WaitForChild("PetVisuals"))
local UIBus = require(ReplicatedStorage:WaitForChild("UIBus"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local rgb = Color3.fromRGB

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local actionRemote = remotes:WaitForChild("PetAction")
local stateRemote = remotes:WaitForChild("PetState")
local hatchedRemote = remotes:WaitForChild("PetHatched")
local petsFolder = workspace:WaitForChild("PlayerPets")

---------------------------------------------------------------------
-- FOLLOWING
---------------------------------------------------------------------
-- where each slot walks, behind the owner (x to the right, z backwards)
local SLOTS = {Vector3.new(-3.4, 0, 3.2), Vector3.new(3.4, 0, 3.2), Vector3.new(0, 0, 5.6)}

local motion = {} -- [model] = {Pos = Vector3, Yaw = number, Phase = number}
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function groundBelow(position, ignore)
	rayParams.FilterDescendantsInstances = ignore
	local hit = workspace:Raycast(position + Vector3.new(0, 4, 0), Vector3.new(0, -14, 0), rayParams)
	return hit and hit.Position.Y
end

RunService.RenderStepped:Connect(function(dt)
	local now = os.clock()
	local ignore = {petsFolder}
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character then table.insert(ignore, p.Character) end
	end
	local visitors = workspace:FindFirstChild("MuseumVisitors")
	if visitors then table.insert(ignore, visitors) end
	for _, folder in ipairs(petsFolder:GetChildren()) do
		local owner = Players:GetPlayerByUserId(folder:GetAttribute("OwnerId") or 0)
		local root = owner and owner.Character and owner.Character:FindFirstChild("HumanoidRootPart")
		if root then
			local speed = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z).Magnitude
			for _, model in ipairs(folder:GetChildren()) do
				if model:IsA("Model") then
					local slot = model:GetAttribute("Slot") or 1
					local pet = PetData.GetPet(model:GetAttribute("PetId") or "")
					local m = motion[model]
					local target = root.CFrame * (SLOTS[slot] or SLOTS[1])
					if not m then
						m = {Pos = target, Yaw = 0, Phase = slot * 1.7}
						motion[model] = m
					end
					-- catch up smoothly; teleport if the owner jumped far away (traveling between worlds)
					local flat = Vector3.new(target.X, m.Pos.Y, target.Z)
					if (flat - m.Pos).Magnitude > 60 then m.Pos = flat end
					local before = m.Pos
					m.Pos = m.Pos:Lerp(flat, 1 - math.exp(-dt * 7))
					local step = Vector3.new(m.Pos.X - before.X, 0, m.Pos.Z - before.Z)
					-- face where it's going, or the way the owner looks when standing still
					local dir = step.Magnitude > 0.02 and step.Unit or root.CFrame.LookVector * Vector3.new(1, 0, 1)
					if dir.Magnitude > 0.01 then
						local want = math.atan2(-dir.X, -dir.Z)
						local diff = (want - m.Yaw + math.pi) % (2 * math.pi) - math.pi
						m.Yaw += diff * (1 - math.exp(-dt * 10))
					end
					local ground = groundBelow(Vector3.new(m.Pos.X, root.Position.Y, m.Pos.Z), ignore) or (root.Position.Y - 3)
					local y
					if pet and pet.Fly then
						y = math.max(ground, root.Position.Y - 3) + 2.2 + math.sin(now * 2.4 + m.Phase) * 0.35
					else
						local moving = speed > 1.5
						y = ground + (moving and math.abs(math.sin(now * 11 + m.Phase)) * 0.75 or 0)
					end
					m.Pos = Vector3.new(m.Pos.X, y, m.Pos.Z)
					local tilt = (pet and pet.Fly) and math.sin(now * 2 + m.Phase) * 0.06 or 0
					model:PivotTo(CFrame.new(m.Pos) * CFrame.Angles(0, m.Yaw, tilt))
				end
			end
		end
	end
	-- the eggs on the stands turn and bob
	for _, egg in ipairs(CollectionService:GetTagged("EggDisplay")) do
		local home = egg:GetAttribute("Home")
		if typeof(home) == "CFrame" then
			egg:PivotTo(home * CFrame.new(0, 0.35 + math.sin(now * 1.6) * 0.35, 0) * CFrame.Angles(0, now * 0.7, 0))
		end
	end
end)
petsFolder.DescendantRemoving:Connect(function(d)
	motion[d] = nil
end)

---------------------------------------------------------------------
-- PETS WINDOW
---------------------------------------------------------------------
local state = {Pets = {}, Equipped = {}, MaxEquipped = PetData.MaxEquipped, MaxOwned = PetData.MaxOwned}
local selected = nil
local deleteArmed = nil

local gui = UIKit.screen(player, "PetsUI", 6)
local window, content = UIKit.window(gui, "Pets", UDim2.fromOffset(840, 560), rgb(255, 120, 170), "Heart")
window.Name = "PetsWindow"

-- top: your total boosts and Equip Best
local top = Instance.new("Frame")
top.BackgroundTransparency = 1
top.Size = UDim2.new(1, 0, 0, 50)
top.Parent = content
local statChips = {}
for i, statName in ipairs({"Money", "Luck", "Speed"}) do
	local stat = PetData.Stats[statName]
	local chip = UIKit.panel(top, {Size = UDim2.new(0.22, -6, 1, -4), Position = UDim2.new((i - 1) * 0.22, 0, 0, 2), Color = rgb(52, 44, 88), Radius = 12, Stroke = 2.5})
	UIKit.icon(chip, stat.Icon, {Size = UDim2.fromOffset(40, 40), Position = UDim2.new(0, 4, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)})
	statChips[statName] = UIKit.label(chip, "+0%", {Size = UDim2.new(1, -52, 0.8, 0), Position = UDim2.new(0, 48, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
		Align = "Left", Color = stat.Color, Stroke = 2.5, MaxText = 22})
end
local equipBest = UIKit.button(top, "EQUIP BEST", {Size = UDim2.new(0.3, 0, 1, -2), Position = UDim2.new(1, 0, 0, 0), AnchorPoint = Vector2.new(1, 0),
	Color = C.Mint, MaxText = 22})

local countLabel = UIKit.label(content, "", {Size = UDim2.new(0.6, 0, 0, 24), Position = UDim2.fromOffset(2, 56), Align = "Left", Color = C.Ink, Stroke = 0, MaxText = 20})

-- left: the grid of pets
local grid = Instance.new("ScrollingFrame")
grid.BackgroundTransparency = 1
grid.BorderSizePixel = 0
grid.Size = UDim2.new(0.6, 0, 1, -86)
grid.Position = UDim2.fromOffset(0, 84)
grid.ScrollBarThickness = 8
grid.ScrollBarImageColor3 = C.Lilac
grid.AutomaticCanvasSize = Enum.AutomaticSize.Y
grid.CanvasSize = UDim2.new()
grid.Parent = content
local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0.25, -8, 0, 120)
gridLayout.CellPadding = UDim2.fromOffset(8, 8)
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.Parent = grid
local gridPad = Instance.new("UIPadding")
gridPad.PaddingTop = UDim.new(0, 4)
gridPad.PaddingLeft = UDim.new(0, 4)
gridPad.PaddingRight = UDim.new(0, 12)
gridPad.Parent = grid
local emptyNote = UIKit.label(grid, "No pets yet! Hatch an egg at the egg stand by the dig site.", {Size = UDim2.new(1, -20, 0, 60),
	Color = C.Ink, Stroke = 0, MaxText = 20})

-- right: the pet you picked
local detail = UIKit.panel(content, {Size = UDim2.new(0.38, 0, 1, -58), Position = UDim2.new(1, 0, 0, 58), AnchorPoint = Vector2.new(1, 0),
	Color = rgb(244, 240, 255), Radius = 16, Stroke = 3})
local detailView = Instance.new("Frame")
detailView.BackgroundTransparency = 1
detailView.Size = UDim2.new(1, -20, 0.36, 0)
detailView.Position = UDim2.new(0.5, 0, 0, 8)
detailView.AnchorPoint = Vector2.new(0.5, 0)
detailView.Parent = detail
-- (laid out in fractions of the panel's height, so it fits on small screens too)
local detailName = UIKit.label(detail, "", {Size = UDim2.new(1, -20, 0.08, 0), Position = UDim2.new(0.5, 0, 0.38, 0), AnchorPoint = Vector2.new(0.5, 0), Stroke = 3, MaxText = 30})
local detailRarity = UIKit.label(detail, "", {Size = UDim2.new(1, -20, 0.055, 0), Position = UDim2.new(0.5, 0, 0.465, 0), AnchorPoint = Vector2.new(0.5, 0), Stroke = 2.5, MaxText = 22})
local detailDesc = UIKit.label(detail, "", {Size = UDim2.new(1, -24, 0.07, 0), Position = UDim2.new(0.5, 0, 0.53, 0), AnchorPoint = Vector2.new(0.5, 0),
	Color = C.Ink, Stroke = 0, MaxText = 16, Font = UIKit.BodyFont})
local boostRows = Instance.new("Frame")
boostRows.BackgroundTransparency = 1
boostRows.Size = UDim2.new(1, -24, 0.2, 0)
boostRows.Position = UDim2.new(0.5, 0, 0.61, 0)
boostRows.AnchorPoint = Vector2.new(0.5, 0)
boostRows.Parent = detail
local equipButton = UIKit.button(detail, "EQUIP", {Size = UDim2.new(0.56, -6, 0.13, 0), Position = UDim2.new(0, 10, 1, -8), AnchorPoint = Vector2.new(0, 1), Color = C.Mint, MaxText = 22})
local deleteButton = UIKit.button(detail, "DELETE", {Size = UDim2.new(0.44, -14, 0.13, 0), Position = UDim2.new(1, -10, 1, -8), AnchorPoint = Vector2.new(1, 1), Color = C.Coral, MaxText = 20})

local function ownedUids()
	local list = {}
	for uid, petId in pairs(state.Pets) do
		if PetData.GetPet(petId) then table.insert(list, uid) end
	end
	table.sort(list, function(a, b)
		local ea, eb = state.Equipped[a] and 1 or 0, state.Equipped[b] and 1 or 0
		if ea ~= eb then return ea > eb end
		local sa, sb = PetData.Score(PetData.GetPet(state.Pets[a])), PetData.Score(PetData.GetPet(state.Pets[b]))
		if sa ~= sb then return sa > sb end
		return tonumber(a) > tonumber(b)
	end)
	return list
end

local function equippedTotal()
	local n = 0
	for uid in pairs(state.Equipped) do
		if state.Pets[uid] then n += 1 end
	end
	return n
end

local function boostLines(parent, pet)
	for _, child in ipairs(parent:GetChildren()) do child:Destroy() end
	local i = 0
	for _, statName in ipairs({"Money", "Luck", "Speed"}) do
		local value = pet.Boosts[statName]
		if value then
			local stat = PetData.Stats[statName]
			local row = UIKit.panel(parent, {Size = UDim2.new(1, 0, 0.3, 0), Position = UDim2.fromScale(0, i * 0.34), Color = rgb(52, 44, 88), Radius = 8, Stroke = 2})
			UIKit.icon(row, stat.Icon, {Size = UDim2.fromScale(0.13, 1), Position = UDim2.new(0, 4, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)})
			UIKit.label(row, PetData.Percent(value) .. " " .. stat.Text, {Size = UDim2.new(0.8, 0, 0.85, 0), Position = UDim2.new(0.17, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
				Align = "Left", Color = stat.Color, Stroke = 2, MaxText = 18})
			i += 1
		end
	end
end

local function drawDetail()
	for _, child in ipairs(detailView:GetChildren()) do child:Destroy() end
	local petId = selected and state.Pets[selected]
	local pet = petId and PetData.GetPet(petId)
	detail.Visible = pet ~= nil
	if not pet then return end
	local rarity = PetData.Rarity(pet)
	PetVisuals.viewport(detailView, pet.Id, {Spin = true})
	detailName.Text = pet.Name
	detailRarity.Text = string.upper(rarity.Name)
	detailRarity.TextColor3 = rarity.Color
	detailDesc.Text = pet.Description
	boostLines(boostRows, pet)
	local on = state.Equipped[selected]
	UIKit.setButton(equipButton, on and "UNEQUIP" or "EQUIP", on and C.Sky or C.Mint)
	UIKit.setButton(deleteButton, deleteArmed == selected and "SURE?" or "DELETE", C.Coral)
end

local function redraw()
	local bonus = PetData.Total((function()
		local ids = {}
		for uid in pairs(state.Equipped) do
			if state.Pets[uid] then table.insert(ids, state.Pets[uid]) end
		end
		return ids
	end)())
	for statName, label in pairs(statChips) do
		label.Text = PetData.Percent(bonus[statName]) .. " " .. PetData.Stats[statName].Text
	end
	for _, child in ipairs(grid:GetChildren()) do
		if child:IsA("GuiObject") and child ~= emptyNote then child:Destroy() end
	end
	local list = ownedUids()
	emptyNote.Visible = #list == 0
	countLabel.Text = #list .. " / " .. state.MaxOwned .. " pets   ·   " .. equippedTotal() .. " / " .. state.MaxEquipped .. " equipped"
	if selected and not state.Pets[selected] then selected = nil end
	if not selected then selected = list[1] end
	for i, uid in ipairs(list) do
		local pet = PetData.GetPet(state.Pets[uid])
		local rarity = PetData.Rarity(pet)
		local tile = UIKit.button(grid, "", {Size = UDim2.fromOffset(100, 120), Color = rarity.Color, Radius = 14, Pattern = false})
		tile.LayoutOrder = i
		PetVisuals.viewport(tile, pet.Id, {Size = UDim2.new(1, -8, 1, -30), Position = UDim2.fromOffset(4, 4), ZIndex = 2})
		UIKit.label(tile, pet.Name, {Size = UDim2.new(1, -8, 0, 22), Position = UDim2.new(0.5, 0, 1, -6), AnchorPoint = Vector2.new(0.5, 1), Stroke = 2.5, MaxText = 16}).ZIndex = 3
		if state.Equipped[uid] then
			local badge = UIKit.panel(tile, {Size = UDim2.fromOffset(26, 26), Position = UDim2.fromOffset(5, 5), Color = C.Mint, Radius = 999, Stroke = 2})
			badge.ZIndex = 4
			UIKit.label(badge, "E", {Size = UDim2.fromScale(0.8, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2, MaxText = 16}).ZIndex = 5
		end
		if uid == selected then
			local ring = Instance.new("UIStroke")
			ring.Thickness = 5
			ring.Color = rgb(255, 255, 255)
			ring.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			ring.Parent = tile
		end
		tile.MouseButton1Click:Connect(function()
			Audio.sfx("Click")
			selected = uid
			deleteArmed = nil
			redraw()
		end)
	end
	drawDetail()
end

local function apply(newState)
	if type(newState) == "table" then
		state = newState
		if window.Visible then redraw() end
	end
end

local busy = false
local function act(action, uid)
	if busy then return end
	busy = true
	local ok, result = pcall(function() return actionRemote:InvokeServer(action, uid) end)
	busy = false
	if ok then apply(result) end
end

equipButton.MouseButton1Click:Connect(function()
	if not selected then return end
	Audio.sfx("Click")
	act(state.Equipped[selected] and "Unequip" or "Equip", selected)
end)
deleteButton.MouseButton1Click:Connect(function()
	if not selected then return end
	Audio.sfx("Click")
	if deleteArmed ~= selected then
		deleteArmed = selected -- a second click deletes
		drawDetail()
		return
	end
	deleteArmed = nil
	act("Delete", selected)
end)
equipBest.MouseButton1Click:Connect(function()
	Audio.sfx("Click")
	act("EquipBest")
end)

local function toggle()
	if window.Visible then
		window.Visible = false
		return
	end
	deleteArmed = nil
	redraw()
	UIKit.open(window)
	task.spawn(function()
		local ok, result = pcall(function() return actionRemote:InvokeServer("GetState") end)
		if ok then apply(result) end
	end)
end
UIBus.On("Pets", toggle)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.P then toggle() end
end)
stateRemote.OnClientEvent:Connect(apply)

---------------------------------------------------------------------
-- HATCHING
---------------------------------------------------------------------
local hatchGui = UIKit.screen(player, "PetHatch", 40)
hatchGui.IgnoreGuiInset = true

local function playHatch(eggId, petIds)
	for _, child in ipairs(hatchGui:GetChildren()) do
		if child:IsA("GuiObject") then child:Destroy() end
	end
	local dim = Instance.new("TextButton")
	dim.Text = ""
	dim.AutoButtonColor = false
	dim.BackgroundColor3 = rgb(10, 6, 24)
	dim.BackgroundTransparency = 1
	dim.Size = UDim2.fromScale(1, 1)
	dim.Parent = hatchGui
	local uiScale = Instance.new("UIScale") -- (the screen's own scaling would shrink the dim too)
	uiScale.Parent = dim
	TweenService:Create(dim, TweenInfo.new(0.25), {BackgroundTransparency = 0.35}):Play()

	local n = #petIds
	local slots = {}
	for i = 1, n do
		local x = 0.5 + (i - (n + 1) / 2) * 0.24
		local holder = Instance.new("Frame")
		holder.BackgroundTransparency = 1
		holder.Size = UDim2.fromScale(0.22, 0.36)
		holder.Position = UDim2.fromScale(x, 0.45)
		holder.AnchorPoint = Vector2.new(0.5, 0.5)
		holder.Parent = dim
		local aspect = Instance.new("UIAspectRatioConstraint")
		aspect.AspectRatio = 0.85
		aspect.Parent = holder
		local eggView = PetVisuals.viewport(holder, eggId, {Size = UDim2.fromScale(0.2, 0.2), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5)})
		TweenService:Create(eggView, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.fromScale(1, 1)}):Play()
		slots[i] = {Holder = holder, Egg = eggView}
	end
	-- the eggs wobble harder and harder...
	local start = os.clock()
	while os.clock() - start < 1.6 do
		local t = os.clock() - start
		for _, s in ipairs(slots) do
			s.Egg.Rotation = math.sin(t * (14 + t * 10)) * (4 + t * 12)
		end
		if math.floor(t * 4) ~= math.floor((t - 0.03) * 4) then Audio.sfx("Click", 0.8 + t * 0.3) end
		task.wait()
	end
	-- ...flash, and out pops the pet
	local flash = Instance.new("Frame")
	flash.BackgroundColor3 = rgb(255, 255, 255)
	flash.Size = UDim2.fromScale(1, 1)
	flash.Parent = dim
	TweenService:Create(flash, TweenInfo.new(0.6), {BackgroundTransparency = 1}):Play()
	Audio.sfx("Find")
	for i, s in ipairs(slots) do
		s.Egg:Destroy()
		local pet = PetData.GetPet(petIds[i])
		local rarity = PetData.Rarity(pet)
		local glow = Instance.new("ImageLabel")
		glow.BackgroundTransparency = 1
		glow.Image = "rbxasset://textures/particles/sparkles_main.dds"
		glow.ImageColor3 = rarity.Color
		glow.Size = UDim2.fromScale(1.5, 1.5)
		glow.Position = UDim2.fromScale(0.5, 0.42)
		glow.AnchorPoint = Vector2.new(0.5, 0.5)
		glow.Parent = s.Holder
		local view = PetVisuals.viewport(s.Holder, pet.Id, {Size = UDim2.fromScale(0.3, 0.3), Position = UDim2.fromScale(0.5, 0.42), AnchorPoint = Vector2.new(0.5, 0.5), Spin = true, ZIndex = 2})
		TweenService:Create(view, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.fromScale(0.95, 0.8)}):Play()
		UIKit.label(s.Holder, pet.Name, {Size = UDim2.new(1.2, 0, 0.12, 0), Position = UDim2.fromScale(0.5, 0.86), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 3, MaxText = 34})
		UIKit.label(s.Holder, string.upper(rarity.Name), {Size = UDim2.new(1, 0, 0.09, 0), Position = UDim2.fromScale(0.5, 0.96), AnchorPoint = Vector2.new(0.5, 0.5),
			Color = rarity.Color, Stroke = 3, MaxText = 26})
		local parts = {}
		for _, statName in ipairs({"Money", "Luck", "Speed"}) do
			if pet.Boosts[statName] then table.insert(parts, PetData.Percent(pet.Boosts[statName]) .. " " .. PetData.Stats[statName].Text) end
		end
		UIKit.label(s.Holder, table.concat(parts, "   "), {Size = UDim2.new(1.3, 0, 0.07, 0), Position = UDim2.fromScale(0.5, 1.05), AnchorPoint = Vector2.new(0.5, 0.5),
			Color = rgb(255, 245, 200), Stroke = 2.5, MaxText = 20})
		task.spawn(function()
			while glow.Parent do
				glow.Rotation += 1.2
				task.wait()
			end
		end)
	end
	-- click (or wait) to close
	local closed = false
	local function close()
		if closed then return end
		closed = true
		TweenService:Create(dim, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
		for _, d in ipairs(dim:GetDescendants()) do
			if d:IsA("GuiObject") then d.Visible = false end
		end
		task.delay(0.3, function() dim:Destroy() end)
	end
	dim.MouseButton1Click:Connect(close)
	task.delay(3.5, close)
end

hatchedRemote.OnClientEvent:Connect(function(eggId, petIds)
	if type(petIds) == "table" and #petIds > 0 then
		task.spawn(playHatch, eggId, petIds)
	end
end)
