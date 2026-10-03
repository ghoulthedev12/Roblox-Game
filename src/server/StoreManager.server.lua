-- StoreManager (Script in ServerScriptService)
-- The Robux store (see ReplicatedStorage.StoreData):
--   * GAME PASSES: on join, checks which passes the player owns and saves them in their data
--     (data.Passes); the attribute "Pass_<Key>" tells every other script (PlayerData doubles the
--     income, DigBoosts the dig speed, DigManager the hole size and the Relic Pickaxe).
--   * DEVELOPER PRODUCTS (the Relic Egg): ProcessReceipt hatches the eggs through PetManager's
--     GrantEggs and remembers each purchase, so a purchase is given exactly once.
--   * StoreBuy (from the Store window) and StorePrompt (from the Relic Egg stand) show Roblox's
--     purchase prompt. In Studio, an item without an ID yet is given for free for that test
--     session only (nothing is saved), so the store can be tried before the passes exist.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local StoreData = require(ReplicatedStorage:WaitForChild("StoreData"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))

local MAX_RECEIPTS = 100 -- purchase ids remembered per player (the newest ones)
local IS_STUDIO = RunService:IsStudio()

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local function remote(className, name)
	local r = remotes:FindFirstChild(name) or Instance.new(className)
	r.Name = name
	r.Parent = remotes
	return r
end
local buyRemote = remote("RemoteEvent", "StoreBuy") -- client -> server: (item key) show the purchase
local messageRemote = remotes:WaitForChild("ShopMessage", 30)

-- PetManager's Relic Egg stand fires this with (player, product key)
local storePrompt = script.Parent:FindFirstChild("StorePrompt") or Instance.new("BindableEvent")
storePrompt.Name = "StorePrompt"
storePrompt.Parent = script.Parent

local function say(player, text, good)
	if messageRemote then messageRemote:FireClient(player, text, good) end
end

local passById, productById = {}, {}
for _, pass in ipairs(StoreData.Passes) do
	if pass.Id > 0 then passById[pass.Id] = pass end
end
for _, product in ipairs(StoreData.Products) do
	if product.Id > 0 then productById[product.Id] = product end
end

---------------------------------------------------------------------
-- GAME PASSES
---------------------------------------------------------------------
-- publishes what the save owns as attributes and refreshes the income
local function applyPasses(player, data)
	for _, pass in ipairs(StoreData.Passes) do
		player:SetAttribute(StoreData.Attribute(pass.Key), StoreData.Owns(data, pass.Key) and true or nil)
	end
	PlayerData.Refresh(player)
end

local function grantPass(player, pass, testOnly)
	local data = PlayerData.Get(player)
	if not data then return end
	if testOnly then
		data.TestPasses = data.TestPasses or {}
		data.TestPasses[pass.Key] = true
	else
		data.Passes[pass.Key] = true
	end
	if pass.Key == "RelicPickaxe" then data.UseRelic = true end
	applyPasses(player, data)
	say(player, "{Star} You got " .. pass.Name .. "!" .. (testOnly and " (Studio test, not saved)" or " Thank you!"), true)
end

local function checkOwnership(player)
	local data = PlayerData.WaitForData(player)
	if not data or not player.Parent then return end
	data.Passes = data.Passes or {}
	data.Receipts = data.Receipts or {}
	for _, pass in ipairs(StoreData.Passes) do
		if pass.Id > 0 and not data.Passes[pass.Key] then
			local ok, owns = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, pass.Id)
			if ok and owns then
				data.Passes[pass.Key] = true -- bought on the website, or in another server
				if pass.Key == "RelicPickaxe" then data.UseRelic = true end
			end
		end
	end
	applyPasses(player, data)
end
Players.PlayerAdded:Connect(checkOwnership)
for _, player in ipairs(Players:GetPlayers()) do task.spawn(checkOwnership, player) end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
	local pass = passById[passId]
	if purchased and pass then grantPass(player, pass, false) end
end)

---------------------------------------------------------------------
-- DEVELOPER PRODUCTS (the Relic Egg)
---------------------------------------------------------------------
local function grantProduct(player, product)
	local grantEggs = script.Parent:FindFirstChild("GrantEggs")
	if not grantEggs or not product.Egg then return false end
	local ok, result = pcall(grantEggs.Invoke, grantEggs, player, product.Egg, product.Amount)
	return ok and result == true
end

local function forgetOldReceipts(receipts)
	local list = {}
	for id, t in pairs(receipts) do table.insert(list, {id, t}) end
	if #list <= MAX_RECEIPTS then return end
	table.sort(list, function(a, b) return a[2] > b[2] end)
	for i = MAX_RECEIPTS + 1, #list do receipts[list[i][1]] = nil end
end

MarketplaceService.ProcessReceipt = function(info)
	local player = Players:GetPlayerByUserId(info.PlayerId)
	local product = productById[info.ProductId]
	if not player or not product then
		return Enum.ProductPurchaseDecision.NotProcessedYet -- Roblox tries again next time they join
	end
	local data = PlayerData.Get(player)
	if not data then return Enum.ProductPurchaseDecision.NotProcessedYet end
	data.Receipts = data.Receipts or {}
	local id = tostring(info.PurchaseId)
	if data.Receipts[id] then
		return Enum.ProductPurchaseDecision.PurchaseGranted -- already given
	end
	if not grantProduct(player, product) then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	data.Receipts[id] = os.time()
	forgetOldReceipts(data.Receipts)
	say(player, "{Star} Thanks for buying " .. product.Name .. "!", true)
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

---------------------------------------------------------------------
-- BUYING
---------------------------------------------------------------------
local lastPrompt = {}

local function buy(player, key)
	if typeof(key) ~= "string" then return end
	if os.clock() - (lastPrompt[player] or 0) < 0.5 then return end
	lastPrompt[player] = os.clock()
	local data = PlayerData.Get(player)
	if not data then return end
	local pass = StoreData.PassesByKey[key]
	local product = StoreData.ProductsByKey[key]
	if pass then
		if StoreData.Owns(data, pass.Key) then
			say(player, "You already own " .. pass.Name .. "!", true)
		elseif pass.Id > 0 then
			MarketplaceService:PromptGamePassPurchase(player, pass.Id)
		elseif IS_STUDIO then
			grantPass(player, pass, true)
		else
			say(player, pass.Name .. " is coming soon!", false)
		end
	elseif product then
		if product.Id > 0 then
			MarketplaceService:PromptProductPurchase(player, product.Id)
		elseif IS_STUDIO then
			if grantProduct(player, product) then say(player, "{Star} " .. product.Name .. " (Studio test, free)", true) end
		else
			say(player, product.Name .. " is coming soon!", false)
		end
	end
end

buyRemote.OnServerEvent:Connect(buy)
storePrompt.Event:Connect(buy)

Players.PlayerRemoving:Connect(function(player)
	lastPrompt[player] = nil
end)

print("StoreManager ready: " .. #StoreData.Passes .. " game passes, " .. #StoreData.Products .. " products")
