-- WorldGimmicks (ModuleScript in ReplicatedStorage)
-- Every world from World 3 on has its own twist, so the later worlds never feel the same.
-- Module = which Gimmick_<Module> script in ServerScriptService runs it (WorldGimmickManager
-- starts it and tells it when players come and go); the rest is shown to players by
-- WorldGimmickClient when they arrive.

return {
	[3] = {Module = "LowGravity", Icon = "🌌", Title = "LOW GRAVITY",
		Text = "Galaxy Drift barely holds you down. Jump way higher and float down into the pit!"},
	[4] = {Module = "Blizzard", Icon = "❄️", Title = "BLIZZARDS",
		Text = "Every few minutes a blizzard rolls in. The storm stirs up relics: 2x luck while it lasts!"},
	[5] = {Module = "GoldRush", Icon = "🪙", Title = "GOLD RUSH",
		Text = "Golden sandstorms sweep the dunes. During a Gold Rush you find things 3x as often!"},
	[6] = {Module = "Oxygen", Icon = "🫧", Title = "LOW OXYGEN",
		Text = "The deep pit is flooded with toxic fumes. Watch your air meter and refill it at the bubbling air vents!"},
	[7] = {Module = "Merchant", Icon = "👽", Title = "ALIEN MERCHANT",
		Text = "A candy-loving alien wanders the rim selling Sugar Rush: dig 1.5x faster for 3 minutes!"},
	[8] = {Module = "Eruption", Icon = "🌋", Title = "ERUPTIONS",
		Text = "The volcano erupts every few minutes, raining lava bombs. Grab the glowing Forge Nuggets for cash!"},
	[9] = {Module = "GlitchSurge", Icon = "👾", Title = "GLITCH SURGES",
		Text = "Reality glitches out every few minutes: swing 2x faster with 1.5x luck during a Glitch Surge!"},
}
