-- WorldsData (ModuleScript in ReplicatedStorage)
-- The 8 worlds you travel to through the World Gate (worlds 2-9). GameConfig turns each entry
-- into a full world: a floating island with its own pit, Shovel Shop, World Gate, memes,
-- shovels, dirt materials and sky. (The museum only exists in World 1.)
--
-- Per world:
--   Top / Wall      terrain material of the island surface and of the pit walls
--   Zones           terrain material + color of the 4 depth zones (Shallow, Mid, Deep, Abyss)
--   Look            colors for the island decorations and the world's shovels
--   Sky             lighting players see while they're in the world
--   Shovels         {name, description, blade shape, grip}; stats come from SHOVEL_TIERS

local rgb = Color3.fromRGB

local WorldsData = {}

-- Every world's 7 shovels follow the same progression; price = PriceFactor x the world's price.
-- MaxZone: 1 = Shallow, 2 = Mid, 3 = Deep, 4 = Abyss
WorldsData.ShovelTiers = {
	{MaxZone = 1, DigRadius = 4.5, FindChance = 0.012, Luck = 1,   Cooldown = 0.5,  PriceFactor = 0},
	{MaxZone = 2, DigRadius = 5,   FindChance = 0.014, Luck = 1.2, Cooldown = 0.46, PriceFactor = 0.05},
	{MaxZone = 2, DigRadius = 5.5, FindChance = 0.016, Luck = 1.4, Cooldown = 0.43, PriceFactor = 0.15},
	{MaxZone = 3, DigRadius = 6,   FindChance = 0.018, Luck = 1.7, Cooldown = 0.4,  PriceFactor = 0.4},
	{MaxZone = 3, DigRadius = 6.5, FindChance = 0.02,  Luck = 2,   Cooldown = 0.37, PriceFactor = 1},
	{MaxZone = 4, DigRadius = 7.5, FindChance = 0.024, Luck = 2.5, Cooldown = 0.34, PriceFactor = 2.5},
	{MaxZone = 4, DigRadius = 8,   FindChance = 0.027, Luck = 3,   Cooldown = 0.31, PriceFactor = 6},
}

-- Terrain colors are shared by the whole map (Roblox paints each material one color
-- everywhere), so every world uses its own mix of materials. MapStyle applies these.
WorldsData.TerrainColors = {
	-- World 1
	Grass = rgb(112, 204, 108), Slate = rgb(150, 146, 172), Ground = rgb(176, 124, 84),
	Sandstone = rgb(222, 180, 120), CrackedLava = rgb(214, 110, 70), Glacier = rgb(150, 210, 240),
	Basalt = rgb(70, 64, 96),
	-- Worlds 2-9
	LeafyGrass = rgb(255, 176, 208), Mud = rgb(150, 78, 110), Brick = rgb(236, 130, 140),
	WoodPlanks = rgb(120, 60, 70), Salt = rgb(255, 236, 246), Asphalt = rgb(34, 30, 70),
	Pavement = rgb(86, 72, 170), Limestone = rgb(176, 150, 236), Ice = rgb(120, 230, 255),
	Snow = rgb(236, 246, 255), Concrete = rgb(170, 200, 225), Cobblestone = rgb(90, 120, 170),
	Sand = rgb(240, 180, 96), Rock = rgb(110, 90, 120),
}

WorldsData.Worlds = {
	-----------------------------------------------------------------
	{
		Name = "Neon Sakura Grove", Theme = "Sakura", Price = 15e6,
		Tagline = "Pink blossoms, paper lanterns and robot koi.",
		Top = "LeafyGrass", Wall = "Rock",
		Zones = {"Mud", "Brick", "WoodPlanks", "Salt"},
		Look = {Main = rgb(255, 170, 205), Second = rgb(255, 238, 244), Dark = rgb(128, 62, 80), Glow = rgb(255, 120, 180), Accent = rgb(255, 214, 120)},
		Sky = {ClockTime = 17.3, Ambient = rgb(120, 96, 120), OutdoorAmbient = rgb(160, 130, 160), Tint = rgb(255, 232, 242),
			Fog = rgb(255, 200, 225), Decay = rgb(200, 130, 170), Density = 0.32, Clouds = 0.55},
		Shovels = {
			{"Blossom Trowel", "A little pink trowel. Leaves petals everywhere it digs.", "Spade", "D"},
			{"Bamboo Spade", "Light, strong and grown in a week.", "Spade", "T"},
			{"Koi Scoop", "Shaped like a koi fin. Scoops dirt like water.", "Scoop", "T"},
			{"Lantern Spade", "A paper lantern lights every swing.", "Spade", "D"},
			{"Katana Shovel", "Folded 1000 times. Cuts through bricks like tofu.", "Spade", "T"},
			{"Petal Excavator", "Blows a storm of petals into the Abyss.", "Spoon", "D"},
			{"Hanami Harvester", "Mythic. Blossoms bloom wherever it strikes.", "Spade", "T"},
		},
	},
	-----------------------------------------------------------------
	{
		Name = "Galaxy Drift", Theme = "Galaxy", Price = 500e6,
		Tagline = "A dig site floating between the stars.",
		Top = "Asphalt", Wall = "Rock",
		Zones = {"Pavement", "Limestone", "Basalt", "Ice"},
		Look = {Main = rgb(130, 96, 255), Second = rgb(40, 36, 96), Dark = rgb(22, 20, 52), Glow = rgb(110, 220, 255), Accent = rgb(255, 214, 110)},
		Sky = {ClockTime = 0, Ambient = rgb(118, 110, 170), OutdoorAmbient = rgb(140, 130, 200), Tint = rgb(226, 222, 255),
			Fog = rgb(80, 60, 160), Decay = rgb(40, 30, 100), Density = 0.32, Clouds = 0},
		Shovels = {
			{"Meteor Scoop", "Made from a meteor that landed on a meme.", "Scoop", "T"},
			{"Rocket Spade", "Has tiny thrusters. Mostly for style.", "Spade", "T"},
			{"Orbit Shovel", "A little moon orbits the handle.", "Spade", "D"},
			{"Nebula Trowel", "Swirls with space dust.", "Spoon", "D"},
			{"Comet Crusher", "Leaves a sparkly tail with every swing.", "Spade", "T"},
			{"Supernova Spade", "Legendary. Hot as a dying star.", "Spade", "D"},
			{"Event Horizon", "Mythic. Nothing escapes it. Not even the Abyss.", "Spoon", "T"},
		},
	},
	-----------------------------------------------------------------
	{
		Name = "Frostbyte Tundra", Theme = "Frost", Price = 1e9,
		Tagline = "Snowy servers, ice crystals and a big aurora.",
		Top = "Snow", Wall = "Rock",
		Zones = {"Ice", "Concrete", "Glacier", "Cobblestone"},
		Look = {Main = rgb(150, 226, 255), Second = rgb(246, 250, 255), Dark = rgb(56, 88, 140), Glow = rgb(130, 255, 220), Accent = rgb(190, 170, 255)},
		Sky = {ClockTime = 9.5, Ambient = rgb(110, 120, 150), OutdoorAmbient = rgb(150, 165, 195), Tint = rgb(236, 246, 255),
			Fog = rgb(215, 235, 255), Decay = rgb(140, 170, 220), Density = 0.3, Clouds = 0.7},
		Shovels = {
			{"Snowball Scoop", "Packs perfect snowballs. Also digs.", "Scoop", "T"},
			{"Icicle Spade", "Sharp, shiny and a bit drippy.", "Spade", "D"},
			{"Penguin Paddle", "Waddles through snow at top speed.", "Scoop", "D"},
			{"Frostbite Shovel", "Cold enough to freeze a lag spike.", "Spade", "T"},
			{"Blizzard Breaker", "Every swing is a tiny snowstorm.", "Spade", "D"},
			{"Aurora Auger", "Legendary. Glows with northern lights.", "Spoon", "T"},
			{"Absolute Zero Spade", "Mythic. So cold the Abyss shatters.", "Spade", "T"},
		},
	},
	-----------------------------------------------------------------
	{
		Name = "Chrome Dunes", Theme = "Dunes", Price = 5e9,
		Tagline = "Golden sand, chrome pyramids and solar towers.",
		Top = "Sand", Wall = "Rock",
		Zones = {"Sandstone", "Ground", "Brick", "Salt"},
		Look = {Main = rgb(255, 196, 90), Second = rgb(226, 232, 244), Dark = rgb(120, 76, 50), Glow = rgb(255, 150, 70), Accent = rgb(80, 210, 220)},
		Sky = {ClockTime = 13, Ambient = rgb(128, 112, 96), OutdoorAmbient = rgb(170, 150, 128), Tint = rgb(255, 244, 226),
			Fog = rgb(255, 222, 170), Decay = rgb(220, 160, 110), Density = 0.3, Clouds = 0.2},
		Shovels = {
			{"Sandy Scoop", "Full of sand. Always. Forever.", "Scoop", "T"},
			{"Cactus Spade", "Hug it at your own risk.", "Spade", "D"},
			{"Mirage Shovel", "Is it really there? Yes. Probably.", "Spade", "T"},
			{"Pharaoh Spade", "Once dug a pyramid in an afternoon.", "Spade", "D"},
			{"Solar Sifter", "Solar powered. Works best at noon.", "Spoon", "T"},
			{"Sandstorm Drill", "Legendary. Spins up a sandstorm on every swing.", "Spade", "T"},
			{"Sun King Shovel", "Mythic. Blazes like a second sun.", "Spade", "D"},
		},
	},
	-----------------------------------------------------------------
	{
		Name = "Coral Circuit", Theme = "Coral", Price = 30e9,
		Tagline = "A bubbly reef of coral, shells and glowing jellies.",
		Top = "Sand", Wall = "Rock",
		Zones = {"Brick", "Limestone", "Ice", "Pavement"},
		Look = {Main = rgb(255, 128, 150), Second = rgb(90, 220, 220), Dark = rgb(30, 80, 120), Glow = rgb(120, 240, 255), Accent = rgb(255, 230, 160)},
		Sky = {ClockTime = 15, Ambient = rgb(90, 120, 140), OutdoorAmbient = rgb(120, 160, 180), Tint = rgb(226, 250, 255),
			Fog = rgb(120, 210, 230), Decay = rgb(60, 140, 180), Density = 0.35, Clouds = 0.4},
		Shovels = {
			{"Seashell Scoop", "Hold it to your ear: you hear dirt.", "Scoop", "D"},
			{"Anchor Spade", "Heavy. Very heavy. Digs straight down.", "Spade", "T"},
			{"Pearl Shovel", "A perfect pearl sits on the blade.", "Spade", "D"},
			{"Trident Trowel", "Borrowed from a sea king. No returns.", "Spoon", "T"},
			{"Kraken Claw", "Eight times the grip.", "Scoop", "T"},
			{"Tidal Excavator", "Legendary. Moves dirt like a wave.", "Spade", "D"},
			{"Atlantis Spade", "Mythic. Found at the bottom of a lost city.", "Spade", "T"},
		},
	},
	-----------------------------------------------------------------
	{
		Name = "Candy Mainframe", Theme = "Candy", Price = 100e9,
		Tagline = "A sugar-coated server farm made of sweets.",
		Top = "Salt", Wall = "Rock",
		Zones = {"LeafyGrass", "Sand", "Mud", "Ice"},
		Look = {Main = rgb(255, 120, 190), Second = rgb(130, 236, 200), Dark = rgb(120, 70, 60), Glow = rgb(255, 170, 230), Accent = rgb(255, 226, 110)},
		Sky = {ClockTime = 14, Ambient = rgb(130, 110, 130), OutdoorAmbient = rgb(175, 150, 175), Tint = rgb(255, 238, 248),
			Fog = rgb(255, 214, 240), Decay = rgb(220, 160, 210), Density = 0.32, Clouds = 0.6},
		Shovels = {
			{"Lollipop Scoop", "Swirly, sticky and surprisingly strong.", "Scoop", "T"},
			{"Candy Cane Spade", "Minty fresh digging.", "Spade", "D"},
			{"Gummy Shovel", "Bends a lot. Never breaks.", "Scoop", "D"},
			{"Sprinkle Spade", "Leaves sprinkles in every hole.", "Spade", "T"},
			{"Choco Crusher", "Solid chocolate. Please don't eat it.", "Spade", "D"},
			{"Jawbreaker Auger", "Legendary. Harder than any rock.", "Spoon", "T"},
			{"Sugar Rush Spade", "Mythic. Digs at 1000% speed. Crashes later.", "Spade", "T"},
		},
	},
	-----------------------------------------------------------------
	{
		Name = "Volcano Forge", Theme = "Forge", Price = 500e9,
		Tagline = "Lava rivers, obsidian and a giant meme forge.",
		Top = "Basalt", Wall = "Rock",
		Zones = {"Ground", "Brick", "Asphalt", "CrackedLava"},
		Look = {Main = rgb(255, 120, 50), Second = rgb(60, 52, 70), Dark = rgb(34, 28, 40), Glow = rgb(255, 150, 60), Accent = rgb(255, 214, 90)},
		Sky = {ClockTime = 18.6, Ambient = rgb(120, 86, 80), OutdoorAmbient = rgb(150, 105, 95), Tint = rgb(255, 232, 220),
			Fog = rgb(200, 110, 80), Decay = rgb(120, 60, 50), Density = 0.35, Clouds = 0.5},
		Shovels = {
			{"Ember Spade", "Always a little bit warm.", "Spade", "D"},
			{"Anvil Shovel", "Forged on an anvil. Kind of shaped like one too.", "Spade", "T"},
			{"Magma Scoop", "Scoops lava like soup.", "Scoop", "T"},
			{"Obsidian Blade", "Glassy black and razor sharp.", "Spade", "D"},
			{"Dragonbone Spade", "Made from a dragon's lost tooth.", "Spade", "T"},
			{"Inferno Auger", "Legendary. Melts straight through rock.", "Spoon", "D"},
			{"Core Breaker", "Mythic. Forged in the heart of the volcano.", "Spade", "T"},
		},
	},
	-----------------------------------------------------------------
	{
		Name = "Glitch Nexus", Theme = "Glitch", Price = 2.5e12,
		Tagline = "The edge of the simulation. Things don't load right here.",
		Top = "Concrete", Wall = "Rock",
		Zones = {"Cobblestone", "Asphalt", "Limestone", "Snow"},
		Look = {Main = rgb(90, 255, 150), Second = rgb(255, 80, 220), Dark = rgb(20, 18, 30), Glow = rgb(90, 255, 170), Accent = rgb(90, 200, 255)},
		Sky = {ClockTime = 21.5, Ambient = rgb(100, 120, 120), OutdoorAmbient = rgb(125, 150, 150), Tint = rgb(236, 255, 244),
			Fog = rgb(40, 60, 70), Decay = rgb(90, 40, 110), Density = 0.32, Clouds = 0},
		Shovels = {
			{"Placeholder Spade", "TODO: add a description.", "Spade", "D"},
			{"Pixel Shovel", "Rendered at 8 pixels. Works anyway.", "Spade", "T"},
			{"Lag Spade", "Hits the ground a second after you swing.", "Scoop", "T"},
			{"Wireframe Shovel", "The texture never loaded.", "Spade", "D"},
			{"Error 404 Scoop", "Scoop not found. Digging anyway.", "Scoop", "D"},
			{"Debug Drill", "Legendary. Has admin commands built in.", "Spoon", "T"},
			{"The Final Patch", "Mythic. Fixes the simulation, one hole at a time.", "Spade", "T"},
		},
	},
}

return WorldsData
