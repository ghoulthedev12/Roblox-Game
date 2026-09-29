-- ArtifactsWorlds (ModuleScript in ReplicatedStorage)
-- The memes for worlds 2-9. ArtifactData merges these in: each world has one area (22-29)
-- with 14 memes, and each world's depth zones pull from its own area.
-- Format per meme: {rarity code, id, name, museum description}

local ArtifactsWorlds = {}

-- one area per world (area 22 = world 2 ... area 29 = world 9), each worth a big step more
ArtifactsWorlds.Areas = {
	{Name = "Neon Sakura Grove", Era = "Sakura"},
	{Name = "Galaxy Drift",      Era = "Galaxy"},
	{Name = "Frostbyte Tundra",  Era = "Frost"},
	{Name = "Chrome Dunes",      Era = "Dunes"},
	{Name = "Coral Circuit",     Era = "Coral"},
	{Name = "Candy Mainframe",   Era = "Candy"},
	{Name = "Volcano Forge",     Era = "Forge"},
	{Name = "Glitch Nexus",      Era = "Glitch"},
}

ArtifactsWorlds.Eras = {
	Sakura = {DisplayName = "Neon Sakura Grove", Years = "2051"},
	Galaxy = {DisplayName = "Galaxy Drift",      Years = "2052"},
	Frost  = {DisplayName = "Frostbyte Tundra",  Years = "2053"},
	Dunes  = {DisplayName = "Chrome Dunes",      Years = "2054"},
	Coral  = {DisplayName = "Coral Circuit",     Years = "2055"},
	Candy  = {DisplayName = "Candy Mainframe",   Years = "2056"},
	Forge  = {DisplayName = "Volcano Forge",     Years = "2057"},
	Glitch = {DisplayName = "Glitch Nexus",      Years = "2058"},
}

ArtifactsWorlds.Artifacts = {
	-- 22. NEON SAKURA GROVE (world 2)
	{
		{"C", "SakuraPetalChip", "Petal-Shaped Memory Chip", "Stores exactly one blossom. Deletes itself every spring."},
		{"C", "BonsaiRouter", "Bonsai Wi-Fi Router", "Trimmed so carefully that the signal only reaches one room."},
		{"U", "HoloFanFlex", "Holographic Flex Fan", "Snapped open whenever someone bragged online."},
		{"U", "MatchaDrone", "Matcha Delivery Drone", "Delivered tea at 300 mph. Mostly spilled it."},
		{"R", "KoiNFT", "The Koi NFT Pond", "Every fish was 'one of a kind'. There were 10,000 of them."},
		{"R", "LanternBot", "Lantern Bot", "A floating paper lantern with a tiny robot inside."},
		{"E", "CyberKatana", "Cyber Katana of Hot Takes", "Sliced through a whole comment section in one post."},
		{"E", "SenpaiNoticer", "The Senpai Noticer 3000", "Beeps loudly whenever someone finally notices you."},
		{"L", "PetalStorm", "Bottled Petal Storm", "Open it and your screen fills with sakura for 3 hours."},
		{"L", "TeaCeremonyAI", "Tea Ceremony AI", "Performs a perfect ceremony, then asks you to rate it 5 stars."},
		{"M", "NekoMecha", "Neko Mecha Core", "The heart of a giant cat robot. Purrs at 90 decibels."},
		{"D", "BlossomServer", "The Blossom Server", "A server made of living cherry wood. Blooms when traffic spikes."},
		{"CE", "HanamiHologram", "Eternal Hanami Hologram", "A picnic under the blossoms that never ends and never loads."},
		{"T", "SakuraSingularity", "The Sakura Singularity", "Every petal that ever fell, squeezed into one pink star."},
	},
	-- 23. GALAXY DRIFT (world 3)
	{
		{"C", "MoonRockUSB", "Moon Rock USB Stick", "Holds 2 GB of memes and a little moon dust."},
		{"C", "AstroSnackBar", "Freeze-Dried Astro Snack", "Tastes like strawberry and vacuum."},
		{"U", "OrbitSelfie", "Zero-G Selfie Satellite", "Took selfies from every angle at once."},
		{"U", "AlienRatingStar", "One-Star Alien Review", "Rated planet Earth: 'Loud. Weird memes. Would visit again.'"},
		{"R", "SaturnRingFidget", "Saturn Ring Fidget", "Spins forever, because there is no friction in space."},
		{"R", "CometMailbox", "Comet Mailbox", "Delivers messages 400 years late."},
		{"E", "UFOTractorClaw", "UFO Claw Machine", "Abducts plushies with a 3% success rate."},
		{"E", "BlackHoleBin", "Black Hole Recycle Bin", "Empty it once and it takes the whole desktop with it."},
		{"L", "StarChartWiFi", "Star Chart Wi-Fi Map", "Shows every hotspot in the galaxy. Password: stars123."},
		{"L", "AstronautDog", "Astronaut Doge Helmet", "Such space. Very helmet. Much oxygen."},
		{"M", "NebulaEngine", "The Nebula Engine", "Turns space dust into memes at warp speed."},
		{"D", "PlanetLoadingBar", "Planet Loading Bar", "A whole planet stuck at 99%."},
		{"CE", "GalacticRickroll", "The Galactic Rickroll", "A signal that plays the same song across the universe. It never gives up."},
		{"T", "BigBangMeme", "The Big Bang Meme", "The joke that started everything. It was a pun."},
	},
	-- 24. FROSTBYTE TUNDRA (world 4)
	{
		{"C", "IcicleStylus", "Icicle Stylus", "Writes on any screen. Melts halfway through the message."},
		{"C", "SnowmanWebcam", "Snowman Webcam", "Always online. Always frozen."},
		{"U", "FrozenLagSpike", "Frozen Lag Spike", "A 3000 ms ping, preserved in ice."},
		{"U", "PenguinPager", "Penguin Pager", "Waddles your messages over to you. Slowly."},
		{"R", "IglooServer", "Igloo Server Rack", "Naturally cooled. Unnaturally cute."},
		{"R", "HotCocoaCoolant", "Hot Cocoa Coolant", "Kept the servers warm and the admins happy."},
		{"E", "YetiInfluencer", "Yeti Influencer Ring Light", "Nobody ever saw the yeti. Everyone saw its posts."},
		{"E", "BlizzardBuffer", "The Blizzard Buffer", "The loading wheel, but made of snowflakes."},
		{"L", "AuroraFirewall", "Aurora Firewall", "Blocks hackers with a very pretty light show."},
		{"L", "SnowGlobeCloud", "Snow Globe Cloud Storage", "Shake it to defragment."},
		{"M", "MammothMemory", "Woolly Mammoth Memory", "Remembers every meme since the Ice Age."},
		{"D", "PermafrostPing", "The Permafrost Ping", "A message sent in 2050. Still on its way."},
		{"CE", "FrozenFrame", "The Frozen Frame", "One video frame, frozen for eternity. It's a sneeze."},
		{"T", "AbsoluteZero", "Absolute Zero Chill", "The chillest meme ever made. Literally 0 kelvin."},
	},
	-- 25. CHROME DUNES (world 5)
	{
		{"C", "SandTimerApp", "Hourglass Loading App", "Every app in the desert loaded like this."},
		{"C", "CactusCharger", "Cactus Phone Charger", "Charges your phone. Pokes your hand."},
		{"U", "MirageWallpaper", "Mirage Wallpaper", "Looks like an oasis. It's a pop-up ad."},
		{"U", "CamelCaseCamel", "The camelCase Camel", "A camel that only speaks in variable names."},
		{"R", "SolarSunglasses", "Solar-Powered Shades", "Deal with it, but renewable."},
		{"R", "TumbleweedBot", "Tumbleweed Bot", "Rolls across the chat whenever nobody says anything."},
		{"E", "ChromePyramid", "Chrome Pyramid Router", "Pharaoh-grade Wi-Fi. Cursed if you forget the password."},
		{"E", "SandwormStream", "Sandworm Livestream", "12 hours of a sandworm. 4 million viewers."},
		{"L", "OasisHologram", "The Oasis Hologram", "The most refreshing thing in the desert, and none of it is real."},
		{"L", "DuneRacer", "Hover Dune Racer", "Fastest thing on sand. Once lost a race to a snail meme."},
		{"M", "SphinxRiddleBot", "Sphinx Riddle Bot", "Asks 'are you a robot?' and never accepts your answer."},
		{"D", "SunCoreBattery", "Sun Core Battery", "A tiny sun in a can. Do not shake."},
		{"CE", "MirageMultiverse", "The Mirage Multiverse", "Every desert mirage from every timeline, all at once."},
		{"T", "FirstSandcastle", "The First Sandcastle Server", "Built by hand in 2049. Still online. Somehow."},
	},
	-- 26. CORAL CIRCUIT (world 6)
	{
		{"C", "BubbleWrapModem", "Bubble Wrap Modem", "Pop it to connect."},
		{"C", "ShellPhone", "Seashell Smartphone", "Hold it to your ear to hear the ocean's notifications."},
		{"U", "JellyfishLamp", "Jellyfish Desk Lamp", "Glows gently. Stings lightly."},
		{"U", "SeahorseStylus", "Seahorse Stylus", "The only pen that can draw underwater."},
		{"R", "KrakenCable", "Kraken Ethernet Cable", "Eight connections at once. Very fast. Very wet."},
		{"R", "PufferfishPing", "Pufferfish Ping", "Puffs up to 999 ms whenever the lag hits."},
		{"E", "SubmarineStreamer", "Submarine Streaming Setup", "The deepest stream ever. Zero viewers above sea level."},
		{"E", "CoralMotherboard", "Coral Motherboard", "Grown, not built. Still needs updates."},
		{"L", "TurtleServer", "Ancient Turtle Server", "Slow, reliable, 200 years of uptime."},
		{"L", "AnglerFishLight", "Anglerfish Ring Light", "Makes every face look spooky and professional."},
		{"M", "MermaidMic", "The Mermaid Microphone", "Every song comes out as an ocean ballad."},
		{"D", "AtlantisWiFi", "Atlantis Wi-Fi Password", "Nobody has found it. The password or the city."},
		{"CE", "DeepSeaDubstep", "Deep Sea Dubstep", "Whales invented the bass drop. This is the proof."},
		{"T", "OceanOfMemes", "The Ocean of Memes", "Every meme ever dumped into the sea, in one bottle."},
	},
	-- 27. CANDY MAINFRAME (world 7)
	{
		{"C", "GummyByte", "Gummy Byte", "Eight bits of pure sugar."},
		{"C", "LollipopAntenna", "Lollipop Antenna", "Better signal every time you lick it. Please don't."},
		{"U", "CottonCandyCloud", "Cotton Candy Cloud Drive", "Your files dissolve in water."},
		{"U", "ChocoChip", "Chocolate Chip Processor", "Runs hot. Melts faster."},
		{"R", "CandyCaneCable", "Candy Cane Cable", "Striped for faster sugar transfer."},
		{"R", "DonutRouter", "Donut Router", "The signal goes through the hole."},
		{"E", "JellyBeanRNG", "Jelly Bean RNG", "Every bean is a random flavor. Some are 'earwax'."},
		{"E", "FortuneCookieFirewall", "Fortune Cookie Firewall", "Every blocked hacker gets a fortune: 'You will not get in.'"},
		{"L", "SugarRushServer", "Sugar Rush Server", "A million requests a second, then it crashes for a nap."},
		{"L", "RainbowSprinkleGPU", "Rainbow Sprinkle GPU", "Renders everything with extra sprinkles."},
		{"M", "ChocolateFountainCore", "Chocolate Fountain Core", "Endless flowing chocolate. Endless flowing data."},
		{"D", "CakeIsNotALie", "The Cake That Is Not a Lie", "Scientists confirm: the cake was real all along."},
		{"CE", "SweetToothComet", "The Sweet Tooth Comet", "A comet made of pudding. Tastes like 2012."},
		{"T", "SugarSingularity", "The Sugar Singularity", "Infinitely sweet. Your teeth hurt just looking at it."},
	},
	-- 28. VOLCANO FORGE (world 8)
	{
		{"C", "AshKeyboard", "Ash-Covered Keyboard", "Every key types 'hot'."},
		{"C", "LavaLampPhone", "Lava Lamp Phone", "Very groovy. Very hot to hold."},
		{"U", "ObsidianMouse", "Obsidian Mouse", "Every click sounds like a tiny eruption."},
		{"U", "MagmaMeme", "Magma Meme Template", "The caption melts before you can read it."},
		{"R", "ForgeHammerMod", "The Forged Ban Hammer", "Smithed in lava. Bans in one swing."},
		{"R", "SulfurSpeaker", "Sulfur Speaker", "Great bass. Terrible smell."},
		{"E", "DragonWiFi", "Dragon Wi-Fi", "Breathes fire on anyone who steals bandwidth."},
		{"E", "MoltenCPU", "The Molten CPU", "Overclocked until it became a lava lake."},
		{"L", "PhoenixReboot", "Phoenix Reboot Button", "Your PC burns down and comes back stronger."},
		{"L", "AnvilDrop", "The Anvil Drop", "The heaviest bass drop ever recorded."},
		{"M", "VolcanoGod", "The Volcano Idol", "Demands one sacrifice: your screen time."},
		{"D", "EruptionStream", "The Eruption Stream", "The most explosive livestream in history."},
		{"CE", "CoreOfTheForge", "Core of the Forge", "Every meme ever forged started here."},
		{"T", "MoltenMemeKing", "The Molten Meme King", "Crowned in lava. Ruler of the hottest takes."},
	},
	-- 29. GLITCH NEXUS (world 9)
	{
		{"C", "MissingTexture", "Missing Texture Cube", "Purple and black. Everyone knows it. Nobody fixed it."},
		{"C", "NullPointer", "Null Pointer", "Points at nothing. Very confidently."},
		{"U", "CorruptedJPEG", "Corrupted JPEG", "Was a cat once. Now it's modern art."},
		{"U", "InfiniteLoopRing", "Infinite Loop Ring", "Wear it forever. Literally, it won't come off."},
		{"R", "TPoseStatue", "T-Pose Statue", "Asserting dominance since the first missing animation."},
		{"R", "LagSwitch", "The Lag Switch", "Makes everyone else freeze. Rude."},
		{"E", "BlueScreenMirror", "Blue Screen Mirror", "Look into it and it tells you something went wrong."},
		{"E", "NoClipBoots", "No-Clip Boots", "Walk through walls. Fall through floors. Worth it."},
		{"L", "DebugConsole", "The Admin Debug Console", "Type /fly. It worked once."},
		{"L", "CtrlZTimeMachine", "Ctrl+Z Time Machine", "Undo anything. Except this purchase."},
		{"M", "GlitchedCreator", "The Glitched Creator", "The developer of the simulation. They left a bug."},
		{"D", "SimulationPatchNotes", "Simulation Patch Notes", "v2050.1: fixed gravity. Added more memes."},
		{"CE", "VoidRenderer", "The Void Renderer", "Draws the empty space between all the memes."},
		{"T", "EndOfTheInternet", "The End of the Internet", "You have reached the last page. Please go outside."},
	},
}

return ArtifactsWorlds
