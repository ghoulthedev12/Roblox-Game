-- QuestData (ModuleScript in ReplicatedStorage)
-- Goals for worlds 2-9 so there's always something to chase:
--   * QUESTS: each world has a chain of quests built around its own twist (capture ghosts,
--     break curses, hack data nodes...). One quest at a time, in order. Each pays cash (a
--     share of the world's unlock price) and gems. Finishing the whole chain MASTERS the
--     world: +25% luck there forever.
--   * MEME INDEX: find every meme of a world once (any rarity) to complete its page:
--     +15% income from that world's memes on display, forever, and a gem reward.
--   * BURIED VAULTS (BuriedVault on the server): every few minutes a golden vault is buried
--     somewhere in the pit; the first player to dig it out gets a rare meme and gems.
--
-- Quest kinds (counted by the server, see Quests.lua):
--   Find        dig up memes in this world            FindZone   ...at least this deep (Zone 1-4)
--   FindRarity  dig up a meme of Rarity or better     EventFind  ...during a world event
--   Combo       reach a x10 dig combo                 Vault      open a Buried Vault
--   Ghost (W2)  capture meme ghosts                   Flare (W4) light Torch Flares
--   Curse (W5)  break curse traps                     Sugar (W7) buy a Sugar Rush
--   Nugget (W8) grab Forge Nuggets                    Hack (W9)  hack Data Nodes
-- Cash = Cash x the world's unlock price.

local QuestData = {}

QuestData.MasteryLuck = 1.25      -- luck multiplier in a world once its quests are all done
QuestData.IndexIncomeBonus = 0.15 -- +15% income from a world's memes once its index is complete
QuestData.IndexGems = 40          -- gems for completing a world's index

QuestData.Worlds = {
	[2] = { -- Neon Sakura Grove: meme ghosts
		{Kind = "Find", Goal = 10, Text = "Dig up 10 memes", Cash = 0.01, Gems = 3},
		{Kind = "Ghost", Goal = 3, Text = "Capture 3 meme ghosts", Cash = 0.015, Gems = 4},
		{Kind = "Combo", Goal = 1, Text = "Build a x10 dig combo", Cash = 0.02, Gems = 4},
		{Kind = "FindZone", Zone = 3, Goal = 5, Text = "Dig up 5 memes in the Deep Zone", Cash = 0.03, Gems = 6},
		{Kind = "Ghost", Goal = 15, Text = "Capture 15 meme ghosts", Cash = 0.05, Gems = 8},
		{Kind = "Vault", Goal = 1, Text = "Open a Buried Vault", Cash = 0.06, Gems = 10},
		{Kind = "FindRarity", Rarity = "Legendary", Goal = 1, Text = "Find a Legendary meme (or rarer)", Cash = 0.1, Gems = 15},
	},
	[3] = { -- Galaxy Drift: low gravity, gravity shifts
		{Kind = "Find", Goal = 15, Text = "Dig up 15 memes", Cash = 0.01, Gems = 3},
		{Kind = "FindZone", Zone = 3, Goal = 3, Text = "Brave the gravity shifts: 3 memes in the Deep Zone", Cash = 0.015, Gems = 4},
		{Kind = "Combo", Goal = 3, Text = "Build a x10 dig combo 3 times", Cash = 0.02, Gems = 5},
		{Kind = "FindRarity", Rarity = "Epic", Goal = 3, Text = "Find 3 Epic memes (or rarer)", Cash = 0.03, Gems = 6},
		{Kind = "FindZone", Zone = 4, Goal = 3, Text = "Dig up 3 memes in The Abyss", Cash = 0.05, Gems = 8},
		{Kind = "Vault", Goal = 2, Text = "Open 2 Buried Vaults", Cash = 0.07, Gems = 12},
		{Kind = "FindRarity", Rarity = "Legendary", Goal = 2, Text = "Find 2 Legendary memes (or rarer)", Cash = 0.12, Gems = 18},
	},
	[4] = { -- Frostbyte Tundra: permafrost, blizzards
		{Kind = "Find", Goal = 15, Text = "Dig up 15 memes", Cash = 0.01, Gems = 3},
		{Kind = "Flare", Goal = 3, Text = "Light 3 Torch Flares [F]", Cash = 0.015, Gems = 4},
		{Kind = "EventFind", Goal = 3, Text = "Dig up 3 memes during a Blizzard", Cash = 0.02, Gems = 5},
		{Kind = "FindZone", Zone = 3, Goal = 6, Text = "Dig up 6 memes in the Deep Zone", Cash = 0.03, Gems = 6},
		{Kind = "Flare", Goal = 12, Text = "Light 12 Torch Flares", Cash = 0.05, Gems = 8},
		{Kind = "Vault", Goal = 2, Text = "Open 2 Buried Vaults", Cash = 0.07, Gems = 12},
		{Kind = "FindRarity", Rarity = "Legendary", Goal = 2, Text = "Find 2 Legendary memes (or rarer)", Cash = 0.12, Gems = 18},
	},
	[5] = { -- Chrome Dunes: curse traps, gold rush
		{Kind = "Find", Goal = 15, Text = "Dig up 15 memes", Cash = 0.01, Gems = 3},
		{Kind = "Curse", Goal = 2, Text = "Break 2 curse traps", Cash = 0.015, Gems = 4},
		{Kind = "EventFind", Goal = 5, Text = "Dig up 5 memes during a Gold Rush", Cash = 0.02, Gems = 5},
		{Kind = "Curse", Goal = 8, Text = "Break 8 curse traps", Cash = 0.03, Gems = 6},
		{Kind = "FindZone", Zone = 4, Goal = 4, Text = "Dig up 4 memes in The Abyss", Cash = 0.05, Gems = 8},
		{Kind = "Vault", Goal = 2, Text = "Open 2 Buried Vaults", Cash = 0.07, Gems = 12},
		{Kind = "FindRarity", Rarity = "Legendary", Goal = 3, Text = "Find 3 Legendary memes (or rarer)", Cash = 0.12, Gems = 18},
	},
	[6] = { -- Coral Circuit: low oxygen
		{Kind = "Find", Goal = 15, Text = "Dig up 15 memes", Cash = 0.01, Gems = 3},
		{Kind = "FindZone", Zone = 2, Goal = 5, Text = "Hold your breath: 5 memes in the toxic Mid Zone", Cash = 0.015, Gems = 4},
		{Kind = "Combo", Goal = 3, Text = "Build a x10 dig combo 3 times", Cash = 0.02, Gems = 5},
		{Kind = "FindZone", Zone = 3, Goal = 8, Text = "Dig up 8 memes in the Deep Zone", Cash = 0.03, Gems = 6},
		{Kind = "FindZone", Zone = 4, Goal = 5, Text = "Dig up 5 memes in The Abyss", Cash = 0.05, Gems = 8},
		{Kind = "Vault", Goal = 3, Text = "Open 3 Buried Vaults", Cash = 0.07, Gems = 12},
		{Kind = "FindRarity", Rarity = "Legendary", Goal = 3, Text = "Find 3 Legendary memes (or rarer)", Cash = 0.12, Gems = 18},
	},
	[7] = { -- Candy Mainframe: the alien merchant
		{Kind = "Find", Goal = 20, Text = "Dig up 20 memes", Cash = 0.01, Gems = 3},
		{Kind = "Sugar", Goal = 1, Text = "Buy a Sugar Rush from the Alien Merchant", Cash = 0.015, Gems = 4},
		{Kind = "Combo", Goal = 5, Text = "Build a x10 dig combo 5 times", Cash = 0.02, Gems = 5},
		{Kind = "FindRarity", Rarity = "Legendary", Goal = 3, Text = "Find 3 Legendary memes (or rarer)", Cash = 0.03, Gems = 6},
		{Kind = "Sugar", Goal = 5, Text = "Buy 5 Sugar Rushes", Cash = 0.05, Gems = 8},
		{Kind = "Vault", Goal = 3, Text = "Open 3 Buried Vaults", Cash = 0.07, Gems = 12},
		{Kind = "FindZone", Zone = 4, Goal = 10, Text = "Dig up 10 memes in The Abyss", Cash = 0.12, Gems = 18},
	},
	[8] = { -- Volcano Forge: lava surges, eruptions
		{Kind = "Find", Goal = 20, Text = "Dig up 20 memes", Cash = 0.01, Gems = 3},
		{Kind = "Nugget", Goal = 3, Text = "Grab 3 Forge Nuggets after an eruption", Cash = 0.015, Gems = 4},
		{Kind = "FindZone", Zone = 3, Goal = 8, Text = "Dodge the lava: 8 memes in the Deep Zone", Cash = 0.02, Gems = 5},
		{Kind = "Nugget", Goal = 12, Text = "Grab 12 Forge Nuggets", Cash = 0.03, Gems = 6},
		{Kind = "FindZone", Zone = 4, Goal = 6, Text = "Dig up 6 memes in The Abyss", Cash = 0.05, Gems = 8},
		{Kind = "Vault", Goal = 3, Text = "Open 3 Buried Vaults", Cash = 0.07, Gems = 12},
		{Kind = "FindRarity", Rarity = "Legendary", Goal = 4, Text = "Find 4 Legendary memes (or rarer)", Cash = 0.12, Gems = 18},
	},
	[9] = { -- Glitch Nexus: data hacking, glitch surges
		{Kind = "Find", Goal = 20, Text = "Dig up 20 memes", Cash = 0.01, Gems = 3},
		{Kind = "Hack", Goal = 2, Text = "Hack 2 Data Nodes", Cash = 0.015, Gems = 4},
		{Kind = "EventFind", Goal = 5, Text = "Dig up 5 memes during a Glitch Surge", Cash = 0.02, Gems = 5},
		{Kind = "Hack", Goal = 10, Text = "Hack 10 Data Nodes", Cash = 0.03, Gems = 6},
		{Kind = "FindZone", Zone = 4, Goal = 8, Text = "Dig up 8 memes in The Abyss", Cash = 0.05, Gems = 8},
		{Kind = "Vault", Goal = 4, Text = "Open 4 Buried Vaults", Cash = 0.07, Gems = 12},
		{Kind = "FindRarity", Rarity = "Legendary", Goal = 4, Text = "Find 4 Legendary memes (or rarer)", Cash = 0.12, Gems = 18},
	},
}

function QuestData.Get(worldId, step)
	local list = QuestData.Worlds[worldId]
	return list and list[step]
end

function QuestData.Count(worldId)
	local list = QuestData.Worlds[worldId]
	return list and #list or 0
end

return QuestData
