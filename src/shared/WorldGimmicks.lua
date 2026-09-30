-- WorldGimmicks (ModuleScript in ReplicatedStorage)
-- Every world has its own twist so no two worlds play the same.
--   Modules = which Gimmick_<Module> scripts in ServerScriptService run it (WorldGimmickManager
--             starts them and tells them when players come and go)
--   Tag     = the short label on the world's card in the World Gate menu
--   Icon, Title, Text = what WorldGimmickClient shows when you arrive
-- World 1 has no gimmick scripts; its twist (the depth bonus) is built into digging itself.

return {
	[1] = {Modules = {}, Icon = "⛏️", Tag = "Depth Bonus", Title = "DEPTH BONUS",
		Text = "The deeper you dig, the luckier your finds: up to 1.6x luck at the bottom of the Abyss!"},
	[2] = {Modules = {"Spirits"}, Icon = "👻", Tag = "Meme Ghosts", Title = "MEME GHOSTS",
		Text = "Memes you dig up here escape as ghosts! Click the ghost 4 times to capture it before it gets away."},
	[3] = {Modules = {"LowGravity", "GravityShift"}, Icon = "🌌", Tag = "Gravity Shift", Title = "LOW GRAVITY + GRAVITY SHIFTS",
		Text = "Gravity is weak here, and deep down it flips! Hold on during a shift. The deep layers give 1.5x luck."},
	[4] = {Modules = {"Blizzard", "Permafrost"}, Icon = "🔥", Tag = "Permafrost", Title = "PERMAFROST",
		Text = "Below the topsoil the ground is frozen solid. Use a Torch Flare [F] to melt it, or get a heated pickaxe (the top 3)."},
	[5] = {Modules = {"GoldRush", "CurseTraps"}, Icon = "☠️", Tag = "Curse Traps", Title = "CURSE TRAPS + GOLD RUSH",
		Text = "Cursed blocks hide in the sand. When one goes off, press the key shown in time for gold, or your pickaxe is locked for 3s!"},
	[6] = {Modules = {"Oxygen"}, Icon = "🫧", Tag = "Oxygen", Title = "LOW OXYGEN",
		Text = "The deep pit is flooded with toxic fumes. Watch your air meter and refill it at the bubbling air vents!"},
	[7] = {Modules = {"Merchant"}, Icon = "🍭", Tag = "Alien Merchant", Title = "ALIEN MERCHANT",
		Text = "A candy-loving alien wanders the rim selling Sugar Rush: dig 1.5x faster for 3 minutes!"},
	[8] = {Modules = {"Eruption", "LavaSurge"}, Icon = "🌋", Tag = "Lava Surge", Title = "LAVA SURGES + ERUPTIONS",
		Text = "Every few minutes lava rises from the bottom of the pit! Climb up to the glowing safe ledges or the surface before it hits."},
	[9] = {Modules = {"GlitchSurge", "DataHacking"}, Icon = "💾", Tag = "Data Hacking", Title = "DATA HACKING",
		Text = "Digging uncovers Data Nodes. Hit the beats to hack them and dig up a Corrupted meme worth 2x!"},
}
