-- MuseumManager (Script in ServerScriptService)
-- Makes every player's museum (World 1 only) work:
--   * 24 display slots. Walk up to a pedestal and press E:
--       locked slot   -> buy it (its floor must be unlocked first)
--       empty slot    -> pick a meme from your inventory to put on it
--       occupied slot -> swap it for another meme, or take it back
--     Memes on display earn money every second (PlayerData pays it).
--   * Floors: the up/down arrows (MuseumClient) move you between floors or buy the next one.
--   * The Alien Art Dealer: sell memes from your inventory for cash.
-- The pedestals' signs, fact screens and info tags show what's on display; MuseumClient draws
-- the spinning meme card on top of each pedestal.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local function getRemote(name)
	local r = remotes:FindFirstChild(name) or Instance.new("RemoteEvent")
	r.Name = name
	r.Parent = remotes
	return r
end
local openSlotRemote = getRemote("OpenSlotMenu")      -- server -> client: (slotIndex)
local placeRemote = getRemote("PlaceInSlot")          -- client -> server: (slotIndex, artifactId)
local takeRemote = getRemote("TakeFromSlot")          -- client -> server: (slotIndex)
local openDealerRemote = getRemote("OpenDealer")      -- server -> client
local sellRemote = getRemote("SellArtifacts")         -- client -> server: (artifactId, sellAll)
local floorRemote = getRemote("ChangeFloor")          -- client -> server: (+1 up / -1 down)
local messageRemote = getRemote("ShopMessage")        -- server -> client: (text, success) toast
local inventoryChangedRemote = getRemote("InventoryChanged")
local placeAllRemote = getRemote("PlaceAll")          -- client -> server: fill every empty slot with your best memes

local SLOT_COUNT = #GameConfig.SlotPrices
local LOCKED_COLOR = Color3.fromRGB(150, 150, 170)
local EMPTY_COLOR = Color3.fromRGB(178, 158, 255)

local museums = {} -- [player] = museum model

---------------------------------------------------------------------
-- HELPERS
---------------------------------------------------------------------
local function isOwner(player, museum)
	return museum and museum.Parent and museum:GetAttribute("OwnerUserId") == player.UserId
end

local function labelsIn(part)
	local gui = part and part:FindFirstChildOfClass("SurfaceGui")
	local list = {}
	if gui then
		for _, child in ipairs(gui:GetChildren()) do
			if child:IsA("TextLabel") then table.insert(list, child) end
		end
	end
	return list
end

local function setText(label, text, color)
	if label then
		label.Text = text
		if color then label.TextColor3 = color end
	end
end

local function prompt(parent, name, objectText, distance)
	local p = parent:FindFirstChild(name) or Instance.new("ProximityPrompt")
	p.Name = name
	p.ObjectText = objectText
	p.KeyboardKeyCode = Enum.KeyCode.E
	p.HoldDuration = 0
	p.MaxActivationDistance = distance or 12
	p.RequiresLineOfSight = false
	p.Parent = parent
	return p
end

-- Takes one copy of an artifact out of the inventory (returns true if the player had one)
local function takeFromInventory(player, artifactId)
	local data = PlayerData.Get(player)
	if not data then return false end
	local best
	for uid, id in pairs(data.Inventory) do
		if id == artifactId and (not best or tonumber(uid) < tonumber(best)) then
			best = uid
		end
	end
	if not best then return false end
	PlayerData.RemoveArtifact(player, best)
	return true
end

local function countInInventory(data, artifactId)
	local n = 0
	for _, id in pairs(data.Inventory) do
		if id == artifactId then n += 1 end
	end
	return n
end

---------------------------------------------------------------------
-- SLOT VISUALS
---------------------------------------------------------------------
local function slotModel(museum, index)
	local slots = museum:FindFirstChild("Slots")
	return slots and slots:FindFirstChild("Slot" .. index)
end

local function paintGlow(slot, color)
	for _, name in ipairs({"AlcoveGlow", "GlowRing", "Band", "FactGlow"}) do
		local part = slot:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			part.Color = color
		end
	end
end

local function refreshSlot(player, museum, index)
	local slot = slotModel(museum, index)
	if not slot then return end
	local data = PlayerData.Get(player)
	if not data then return end
	local floor = GameConfig.GetFloorOfSlot(index)
	local unlocked = data.UnlockedSlots[tostring(index)] == true
	local artifact = unlocked and ArtifactData.GetArtifact(data.Displayed[tostring(index)] or "")

	local plaque = labelsIn(slot:FindFirstChild("Plaque"))[1]
	local facts = labelsIn(slot:FindFirstChild("FactScreen"))
	local spot = slot:FindFirstChild("DisplaySpot")
	local info = spot and spot:FindFirstChild("InfoGui")
	if info then
		info.StudsOffset = Vector3.new(0, 5.2, 0) -- above the spinning meme card
		info.MaxDistance = 60
	end
	local nameLabel = info and info:FindFirstChild("NameLabel")
	local incomeLabel = info and info:FindFirstChild("IncomeLabel")

	local slotPrompt = slot:FindFirstChild("Column") or slot:FindFirstChild("Cap") or spot
	slotPrompt = slotPrompt and prompt(slotPrompt, "SlotPrompt", "Display Slot " .. index, 12)

	slot:SetAttribute("SlotIndex", index)
	if not unlocked then
		local price = GameConfig.SlotPrices[index]
		local floorOpen = data.UnlockedFloors[tostring(floor)] == true
		slot:SetAttribute("ArtifactId", nil)
		slot:SetAttribute("Locked", true)
		paintGlow(slot, LOCKED_COLOR)
		setText(plaque, "LOCKED  •  " .. ArtifactData.FormatMoney(price))
		setText(facts[1], "SLOT " .. index .. " LOCKED", LOCKED_COLOR)
		setText(facts[2], floorOpen and ("Unlock it for " .. ArtifactData.FormatMoney(price)) or ("Unlock floor " .. floor .. " first"))
		setText(nameLabel, "🔒 LOCKED", LOCKED_COLOR)
		setText(incomeLabel, ArtifactData.FormatMoney(price))
		if slotPrompt then
			slotPrompt.ActionText = floorOpen and ("Unlock  " .. ArtifactData.FormatMoney(price)) or ("Floor " .. floor .. " locked")
		end
	elseif not artifact then
		slot:SetAttribute("ArtifactId", nil)
		slot:SetAttribute("Locked", false)
		paintGlow(slot, EMPTY_COLOR)
		setText(plaque, "EMPTY SLOT " .. index)
		setText(facts[1], "EMPTY DISPLAY", EMPTY_COLOR)
		setText(facts[2], "Put a meme here to earn money every second!")
		setText(nameLabel, "EMPTY", EMPTY_COLOR)
		setText(incomeLabel, "Press E to display a meme")
		if slotPrompt then slotPrompt.ActionText = "Display a meme" end
	else
		local rarity = ArtifactData.GetRarity(artifact.Rarity)
		local income = ArtifactData.GetIncome(artifact)
		slot:SetAttribute("ArtifactId", artifact.Id)
		slot:SetAttribute("Locked", false)
		paintGlow(slot, rarity.Color)
		setText(plaque, string.upper(artifact.Rarity) .. "  •  " .. artifact.Name)
		setText(facts[1], artifact.Name, rarity.Color)
		setText(facts[2], artifact.Description)
		setText(nameLabel, artifact.Name, rarity.Color)
		setText(incomeLabel, "+" .. ArtifactData.FormatMoney(income) .. "/s")
		if slotPrompt then slotPrompt.ActionText = "Swap / take back" end
	end
end

local function refreshAllSlots(player)
	local museum = museums[player]
	if not museum then return end
	for i = 1, SLOT_COUNT do
		refreshSlot(player, museum, i)
	end
end

---------------------------------------------------------------------
-- FLOORS (the up/down arrows in MuseumClient)
---------------------------------------------------------------------
local function arrivalFor(museum, floor)
	local arrivals = museum:FindFirstChild("Arrivals")
	local part = arrivals and arrivals:FindFirstChild("Floor" .. floor .. "Arrival")
	return part and part.CFrame * CFrame.new(0, 3, 0)
end

-- the museum shows which floors its owner has opened, so the arrows know what to show
local function publishFloors(player, museum)
	local data = PlayerData.Get(player)
	if not data then return end
	local list = {}
	for floor = 1, #GameConfig.FloorPrices do
		if data.UnlockedFloors[tostring(floor)] then table.insert(list, tostring(floor)) end
	end
	museum:SetAttribute("UnlockedFloors", table.concat(list, ","))
end

---------------------------------------------------------------------
-- SET UP A MUSEUM WHEN ITS OWNER JOINS
---------------------------------------------------------------------
local function setupMuseum(player, museum)
	museums[player] = museum
	PlayerData.WaitForData(player)
	if not player.Parent or not museum.Parent then return end

	-- display slots
	for i = 1, SLOT_COUNT do
		local slot = slotModel(museum, i)
		if slot then
			refreshSlot(player, museum, i)
			local p = slot:FindFirstChild("SlotPrompt", true)
			if p then
				p.Triggered:Connect(function(who)
					if not isOwner(who, museum) then
						messageRemote:FireClient(who, "This is " .. player.DisplayName .. "'s museum!", false)
						return
					end
					local data = PlayerData.Get(who)
					if not data then return end
					if data.UnlockedSlots[tostring(i)] then
						openSlotRemote:FireClient(who, i)
						return
					end
					-- buying a locked slot
					local floor = GameConfig.GetFloorOfSlot(i)
					if not data.UnlockedFloors[tostring(floor)] then
						messageRemote:FireClient(who, "Unlock floor " .. floor .. " first (use the arrows on the left)!", false)
					elseif PlayerData.SpendMoney(who, GameConfig.SlotPrices[i]) then
						PlayerData.UnlockSlot(who, i)
						refreshSlot(who, museum, i)
						messageRemote:FireClient(who, "Slot " .. i .. " unlocked! Put a meme on it.", true)
					else
						messageRemote:FireClient(who, "You need " .. ArtifactData.FormatMoney(GameConfig.SlotPrices[i]) .. " for this slot.", false)
					end
				end)
			end
		end
	end

	publishFloors(player, museum)

	-- the alien art dealer
	local dealer = museum:FindFirstChild("AlienDealer")
	local counter = dealer and (dealer:FindFirstChild("Counter") or dealer:FindFirstChildWhichIsA("BasePart", true))
	if counter then
		local p = prompt(counter, "DealerPrompt", "Alien Art Dealer", 14)
		p.ActionText = "Sell memes"
		p.Triggered:Connect(function(who)
			openDealerRemote:FireClient(who)
		end)
	end
end

local function watchPlayer(player)
	local function hook(ref)
		if ref:IsA("ObjectValue") and ref.Name == "Museum" and ref.Value then
			task.spawn(setupMuseum, player, ref.Value)
		end
	end
	player.ChildAdded:Connect(hook)
	local existing = player:FindFirstChild("Museum")
	if existing then hook(existing) end
end

Players.PlayerAdded:Connect(watchPlayer)
for _, player in ipairs(Players:GetPlayers()) do
	watchPlayer(player)
end
Players.PlayerRemoving:Connect(function(player)
	museums[player] = nil
end)

---------------------------------------------------------------------
-- REMOTES FROM THE SLOT MENU AND THE DEALER
---------------------------------------------------------------------
local function validSlot(player, index)
	return typeof(index) == "number" and index == math.floor(index) and index >= 1 and index <= SLOT_COUNT
		and PlayerData.IsSlotUnlocked(player, index) and museums[player] ~= nil
end

placeRemote.OnServerEvent:Connect(function(player, index, artifactId)
	if not validSlot(player, index) or typeof(artifactId) ~= "string" or not ArtifactData.GetArtifact(artifactId) then return end
	local data = PlayerData.Get(player)
	if not data or not takeFromInventory(player, artifactId) then
		messageRemote:FireClient(player, "You don't have that meme anymore.", false)
		return
	end
	local old = data.Displayed[tostring(index)]
	if old then
		PlayerData.AddArtifact(player, old) -- the swapped-out meme goes back to the bag
	end
	PlayerData.SetDisplayed(player, index, artifactId)
	refreshSlot(player, museums[player], index)
	inventoryChangedRemote:FireClient(player)
	local artifact = ArtifactData.GetArtifact(artifactId)
	messageRemote:FireClient(player, artifact.Name .. " is on display! +" .. ArtifactData.FormatMoney(ArtifactData.GetIncome(artifact)) .. "/s", true)
end)

-- PLACE ALL (inventory window): every empty, unlocked slot gets your best-earning meme
local lastPlaceAll = {}
placeAllRemote.OnServerEvent:Connect(function(player)
	if os.clock() - (lastPlaceAll[player] or 0) < 1 then return end
	lastPlaceAll[player] = os.clock()
	local data = PlayerData.Get(player)
	local museum = museums[player]
	if not data or not museum then return end
	-- the bag's memes, best earners first
	local memes = {}
	for _, id in pairs(data.Inventory) do
		local artifact = ArtifactData.GetArtifact(id)
		if artifact then table.insert(memes, artifact) end
	end
	table.sort(memes, function(a, b) return ArtifactData.GetIncome(a) > ArtifactData.GetIncome(b) end)
	local placed, nextMeme = 0, 1
	for index = 1, SLOT_COUNT do
		if nextMeme > #memes then break end
		if PlayerData.IsSlotUnlocked(player, index) and not data.Displayed[tostring(index)] then
			local artifact = memes[nextMeme]
			nextMeme += 1
			if takeFromInventory(player, artifact.Id) then
				PlayerData.SetDisplayed(player, index, artifact.Id)
				refreshSlot(player, museum, index)
				placed += 1
			end
		end
	end
	inventoryChangedRemote:FireClient(player)
	if placed > 0 then
		messageRemote:FireClient(player, "🏛️ Placed " .. placed .. " meme" .. (placed == 1 and "" or "s") .. " in your museum! Now earning " .. ArtifactData.FormatMoney(PlayerData.GetIncome(player)) .. "/s", true)
	elseif #memes == 0 then
		messageRemote:FireClient(player, "Your bag is empty. Go dig up some memes!", false)
	else
		messageRemote:FireClient(player, "No empty display slots! Unlock more slots in your museum.", false)
	end
end)

takeRemote.OnServerEvent:Connect(function(player, index)
	if not validSlot(player, index) then return end
	local data = PlayerData.Get(player)
	local old = data and data.Displayed[tostring(index)]
	if not old then return end
	PlayerData.SetDisplayed(player, index, nil)
	PlayerData.AddArtifact(player, old)
	refreshSlot(player, museums[player], index)
	inventoryChangedRemote:FireClient(player)
end)

sellRemote.OnServerEvent:Connect(function(player, artifactId, sellAll)
	if typeof(artifactId) ~= "string" then return end
	local artifact = ArtifactData.GetArtifact(artifactId)
	local data = PlayerData.Get(player)
	if not artifact or not data then return end
	local count = sellAll == true and countInInventory(data, artifactId) or 1
	local sold = 0
	for _ = 1, count do
		if takeFromInventory(player, artifactId) then
			sold += 1
		end
	end
	if sold == 0 then return end
	local total = ArtifactData.GetSellValue(artifact) * sold
	PlayerData.AddMoney(player, total)
	inventoryChangedRemote:FireClient(player)
	messageRemote:FireClient(player, "Sold " .. sold .. "x " .. artifact.Name .. " for " .. ArtifactData.FormatMoney(total) .. "!", true)
end)

local lastFloorChange = {}
floorRemote.OnServerEvent:Connect(function(player, direction)
	if direction ~= 1 and direction ~= -1 then return end
	if lastFloorChange[player] and os.clock() - lastFloorChange[player] < 0.5 then return end
	lastFloorChange[player] = os.clock()
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	-- which museum (and floor) is the player standing in?
	for owner, museum in pairs(museums) do
		local floor = museum.Parent and GameConfig.GetMuseumFloor(museum, root.Position)
		if floor then
			local target = floor + direction
			local data = PlayerData.Get(owner)
			if not data or target < 1 or target > #GameConfig.FloorPrices then return end
			if data.UnlockedFloors[tostring(target)] then
				player.Character:PivotTo(arrivalFor(museum, target))
			elseif player ~= owner then
				messageRemote:FireClient(player, owner.DisplayName .. " hasn't opened floor " .. target .. " yet.", false)
			elseif PlayerData.SpendMoney(owner, GameConfig.FloorPrices[target]) then
				PlayerData.UnlockFloor(owner, target)
				publishFloors(owner, museum)
				refreshAllSlots(owner)
				messageRemote:FireClient(owner, "Floor " .. target .. " unlocked!", true)
				player.Character:PivotTo(arrivalFor(museum, target))
			else
				messageRemote:FireClient(player, "You need " .. ArtifactData.FormatMoney(GameConfig.FloorPrices[target]) .. " to open floor " .. target .. ".", false)
			end
			return
		end
	end
end)
Players.PlayerRemoving:Connect(function(player)
	lastFloorChange[player] = nil
end)

print("MuseumManager ready: " .. SLOT_COUNT .. " display slots, floor arrows and the art dealer")
