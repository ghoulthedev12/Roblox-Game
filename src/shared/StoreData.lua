-- StoreData (ModuleScript in ReplicatedStorage)
-- The Robux store (StoreManager on the server, StoreClient for the window):
--   GAME PASSES, bought once and kept forever:
--     2x Money        the museum earns double (PlayerData)
--     2x Dig Speed    pickaxe swings come twice as often (DigBoosts)
--     2x Bigger Holes every swing carves a crater twice as wide (DigManager)
--     Relic Pickaxe   an exclusive pickaxe for every world (GameConfig.RelicPickaxe, DigManager)
--   DEVELOPER PRODUCTS, bought as often as you like:
--     Relic Egg x1 / x3  hatches pets from the Relic Egg (PetData, PetManager)
--
-- HOW TO HOOK THEM UP: make each pass / product on the Creator Hub (create.roblox.com >
-- your experience > Monetization > Passes / Developer Products), then paste its ID below.
-- Until an ID is filled in, the store shows the item as "Soon", except in Studio, where
-- buying it gives it to you for that test session only (nothing is saved), so everything can
-- be tried before the passes exist. The price shown in the store is read from Roblox; Robux
-- here is only a fallback for when that fails.

local StoreData = {}

StoreData.Passes = {
	{Key = "DoubleMoney", Id = 2005844738, Robux = 199, Name = "2x Money", Icon = "PassMoney", Color = Color3.fromRGB(90, 200, 80),
		Text = "Your museum earns double money. Forever!"},
	{Key = "DoubleSpeed", Id = 2005832754, Robux = 149, Name = "2x Dig Speed", Icon = "PassSpeed", Color = Color3.fromRGB(70, 170, 255),
		Text = "Swing your pickaxe twice as fast."},
	{Key = "BigHoles", Id = 2005922738, Robux = 99, Name = "2x Bigger Holes", Icon = "PassHoles", Color = Color3.fromRGB(230, 140, 60),
		Text = "Every swing digs a hole twice as wide."},
	{Key = "RelicPickaxe", Id = 2005238738, Robux = 299, Name = "Relic Pickaxe", Icon = "PassPickaxe", Color = Color3.fromRGB(240, 180, 30),
		Text = "Golden pickaxe for every world. Digs deepest, +50% luck!"},
}

StoreData.Products = {
	{Key = "RelicEgg1", Id = 3716189620, Robux = 49, Name = "Relic Egg", Amount = 1, Egg = "RelicEgg", Icon = "PassEgg"},
	{Key = "RelicEgg3", Id = 3716189665, Robux = 129, Name = "3 Relic Eggs", Amount = 3, Egg = "RelicEgg", Icon = "PassEgg"},
}

StoreData.PassesByKey = {}
for _, pass in ipairs(StoreData.Passes) do StoreData.PassesByKey[pass.Key] = pass end
StoreData.ProductsByKey = {}
for _, product in ipairs(StoreData.Products) do StoreData.ProductsByKey[product.Key] = product end

-- the player attribute that says a pass is owned (set by StoreManager): "Pass_DoubleMoney"
function StoreData.Attribute(key)
	return "Pass_" .. key
end

-- does this save own the pass? (data.TestPasses = Studio test buys, never kept between sessions)
function StoreData.Owns(data, key)
	return (data.Passes and data.Passes[key]) or (data.TestPasses and data.TestPasses[key]) or false
end

-- does this player own the pass? (anywhere: server or client)
function StoreData.PlayerOwns(player, key)
	return player:GetAttribute(StoreData.Attribute(key)) == true
end

return StoreData
