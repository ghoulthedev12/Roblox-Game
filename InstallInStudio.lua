-- Meme Archaeologist installer: paste ALL of this into Studio's Command Bar
-- (View > Command Bar) and press Enter. Then save the place.
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local recording = ChangeHistoryService:TryBeginRecording("Install Meme Archaeologist scripts")
local count = 0
local function install(parent, name, className, source)
	local existing = parent:FindFirstChild(name)
	if existing and existing.ClassName ~= className then existing:Destroy() existing = nil end
	local s = existing or Instance.new(className)
	s.Name = name
	s.Source = source
	s.Parent = parent
	count += 1
end
pcall(function() game:GetService("Lighting").Technology = Enum.Technology.Future end)
do local old = game:GetService("ServerScriptService"):FindFirstChild("DataManager") if old then old:Destroy() print("Removed DataManager") end end
do local old = game:GetService("ServerScriptService"):FindFirstChild("ShovelModels") if old then old:Destroy() print("Removed ShovelModels") end end
do local old = game:GetService("ReplicatedStorage"):FindFirstChild("ShovelModels") if old then old:Destroy() print("Removed ShovelModels") end end
do local old = game:GetService("ServerScriptService"):FindFirstChild("MuseumStyle") if old then old:Destroy() print("Removed MuseumStyle") end end
install(game:GetService("ReplicatedStorage"), "ArtifactData", "ModuleScript", [=[
-- ArtifactData (ModuleScript in ReplicatedStorage)
-- The ONE list the whole game reads from: rarities, the 20 dig areas, and every artifact.
-- To add an artifact: copy one line inside an area's list and change it.
-- Rarity codes: C=Common U=Uncommon R=Rare E=Epic L=Legendary M=Mythic D=Divine CE=Celestial T=Transcendent

local ArtifactData = {}

---------------------------------------------------------------------
-- RARITIES (worst to best). Income = money per second in WORLD 1.
-- Every later world multiplies this by its WorldMultipliers entry (below), so only the
-- best of the best (Divine and up, in the late worlds) ever pass $50M/s.
---------------------------------------------------------------------
ArtifactData.Rarities = {
	{Name = "Common",       Code = "C",  Income = 5,         Chance = 60,    Color = Color3.fromRGB(190, 190, 190)},
	{Name = "Uncommon",     Code = "U",  Income = 20,        Chance = 25,    Color = Color3.fromRGB(85, 200, 85)},
	{Name = "Rare",         Code = "R",  Income = 80,        Chance = 10,    Color = Color3.fromRGB(60, 140, 255)},
	{Name = "Epic",         Code = "E",  Income = 400,       Chance = 3.5,   Color = Color3.fromRGB(170, 80, 255)},
	{Name = "Legendary",    Code = "L",  Income = 2000,      Chance = 1.1,   Color = Color3.fromRGB(255, 170, 0)},
	{Name = "Mythic",       Code = "M",  Income = 12000,     Chance = 0.3,   Color = Color3.fromRGB(255, 60, 90)},
	{Name = "Divine",       Code = "D",  Income = 60000,     Chance = 0.07,  Color = Color3.fromRGB(255, 240, 150)},
	{Name = "Celestial",    Code = "CE", Income = 300000,    Chance = 0.025, Color = Color3.fromRGB(120, 255, 255)},
	{Name = "Transcendent", Code = "T",  Income = 1500000,   Chance = 0.005, Color = Color3.fromRGB(255, 255, 255)},
}

-- Sell value = income per second x this number
ArtifactData.SellMultiplier = 100

---------------------------------------------------------------------
-- DIG AREAS. Areas 1-21 are World 1's memes (all worth the base income above).
-- Areas 22-29 are worlds 2-9, each worth WorldMultipliers[k] times more.
---------------------------------------------------------------------
ArtifactData.WorldMultipliers = {3, 10, 25, 60, 150, 400, 1000, 2500} -- worlds 2..9
ArtifactData.Areas = {
	{Name = "The Scroll Pit",       Era = "Brainrot"},
	{Name = "Hashtag Hollow",       Era = "Brainrot"},
	{Name = "Filter Fields",        Era = "Brainrot"},
	{Name = "Emoji Quarry",         Era = "Brainrot"},
	{Name = "Algorithm Gorge",      Era = "Brainrot"},
	{Name = "Influencer Caverns",   Era = "Brainrot"},
	{Name = "Brainrot Abyss",       Era = "Brainrot"},
	{Name = "Rage Comic Ridge",     Era = "GoldenAge"},
	{Name = "Montage Mines",        Era = "GoldenAge"},
	{Name = "Cat Video Canyon",     Era = "GoldenAge"},
	{Name = "Airhorn Crater",       Era = "GoldenAge"},
	{Name = "Planking Plateau",     Era = "GoldenAge"},
	{Name = "Viral Valley",         Era = "GoldenAge"},
	{Name = "The Golden Server",    Era = "GoldenAge"},
	{Name = "Dial-Up Dunes",        Era = "Paleolithic"},
	{Name = "Pixel Pits",           Era = "Paleolithic"},
	{Name = "Guestbook Graveyard",  Era = "Paleolithic"},
	{Name = "Floppy Fossil Beds",   Era = "Paleolithic"},
	{Name = "The Homepage Ruins",   Era = "Paleolithic"},
	{Name = "The First Server",     Era = "Paleolithic"},
	-- Secret 2050 memes, only found in World 1's Abyss (worth one step above The Homepage Ruins)
	{Name = "The Abyss",            Era = "Abyss"},
}
-- Worlds 2-9 each add one area (22-29) from ArtifactsWorlds.
local ArtifactsWorlds = require(script.Parent:WaitForChild("ArtifactsWorlds"))
for k, area in ipairs(ArtifactsWorlds.Areas) do
	table.insert(ArtifactData.Areas, {Name = area.Name, Era = area.Era, Multiplier = ArtifactData.WorldMultipliers[k]})
end
for i, area in ipairs(ArtifactData.Areas) do
	area.Index = i
	area.Multiplier = area.Multiplier or 1
end

ArtifactData.Eras = {
	Brainrot    = {DisplayName = "The Brainrot Epoch",  Years = "2016-2024", FirstArea = 1},
	GoldenAge   = {DisplayName = "The Golden Age",      Years = "2005-2015", FirstArea = 8},
	Paleolithic = {DisplayName = "The Paleolithic Web", Years = "1990-2004", FirstArea = 15},
	Abyss       = {DisplayName = "The Abyss",           Years = "2050",      FirstArea = 21},
}
for k, area in ipairs(ArtifactsWorlds.Areas) do
	local era = ArtifactsWorlds.Eras[area.Era]
	ArtifactData.Eras[area.Era] = {DisplayName = era.DisplayName, Years = era.Years, FirstArea = 21 + k}
end
for _, era in pairs(ArtifactData.Eras) do
	era.Multiplier = ArtifactData.Areas[era.FirstArea].Multiplier
end

---------------------------------------------------------------------
-- ARTIFACTS PER AREA: {rarity code, id, name, museum description}
---------------------------------------------------------------------
local AREA_ARTIFACTS = {
	-- 1. THE SCROLL PIT
	[1] = {
		{"C", "RustyFidgetSpinner", "Rusty Fidget Spinner", "Early humans spun these to ward off homework. Scientists still don't know if it worked."},
		{"C", "CrackedDancePhone", "Cracked Phone (Dance Tutorial)", "Still plays the same 15 seconds on loop. Believed to be a prayer ritual."},
		{"U", "HalfFullBottle", "Half-Full Water Bottle", "Tossing it so it landed upright granted the thrower temporary social status."},
		{"U", "DeepFriedChip", "Deep-Fried Image Chip", "A picture cooked at such extreme temperatures it became radioactive with jokes."},
		{"R", "SingingThrone", "Singing Porcelain Throne", "A ceremonial seat with a tiny singing head. Its meaning is lost to history."},
		{"E", "GoldenRingLight", "Golden Ring Light", "Worshipped by ancient content creators. Its glow made every face flawless."},
		{"L", "RizzScroll", "Scroll of Infinite Rizz", "A sacred text so powerful that no alien has been able to translate it."},
		{"M", "ScrollingThumb", "Fossilized Scrolling Thumb", "Worn smooth by millions of hours of scrolling. It never reached the bottom."},
		{"D", "MainCharacterCrown", "Crown of the Main Character", "Whoever wore it believed the whole world was their movie."},
		{"CE", "AlgorithmEye", "The Algorithm's Eye", "It watched everything humans did, then showed them more of it."},
		{"T", "FinalBrainrot", "The Final Brainrot", "Contains every meme ever made, all at once. Do not look at it directly."},
	},
	-- 2. HASHTAG HOLLOW
	[2] = {
		{"C", "HashtagSign", "Broken Hashtag Sign", "Humans put this symbol before words to make them important."},
		{"U", "EmptyIceBucket", "Empty Ice Bucket", "Humans poured freezing water on themselves for a good cause. Brave."},
		{"R", "MannequinStatue", "Mannequin Freeze Statue", "Entire rooms of humans froze still on purpose. This one never unfroze."},
		{"E", "ChallengeTrophy", "Golden Challenge Trophy", "Awarded for completing a challenge nobody remembers the rules of."},
		{"L", "ViralDanceStage", "The Viral Dance Stage", "A tiny stage where millions of humans learned the same 12 moves."},
		{"M", "TrendingCrown", "Crown of Trending #1", "Worn by whoever the whole internet talked about for exactly one day."},
		{"D", "ChallengeScroll", "The Eternal Challenge Scroll", "Lists every internet challenge ever. It is still being written."},
		{"CE", "HashtagConstellation", "Hashtag Constellation", "Aliens mapped the stars and found a hashtag. Coincidence?"},
		{"T", "BrokeTheInternet", "The Hashtag That Broke The Internet", "Too powerful to type. Only whispered."},
	},
	-- 3. FILTER FIELDS
	[3] = {
		{"C", "SelfieStick", "Cracked Selfie Stick", "Extended the human arm by one meter for better self-portraits."},
		{"U", "PuppyEars", "Puppy Ear Headband", "Humans gave themselves digital dog ears. Aliens are still confused."},
		{"R", "RainbowLens", "Rainbow Tongue Lens", "A camera lens that made humans spit rainbows. On purpose."},
		{"E", "PerfectMirror", "Perfect Skin Mirror", "Reflected a version of you that did not exist."},
		{"L", "SunsetCrystal", "The Sunset Filter Crystal", "Made every photo look like the best evening of your life."},
		{"M", "FilterMask", "Mask of a Thousand Filters", "Its wearer could become any face. Nobody remembered their real one."},
		{"D", "FirstSelfie", "The First Selfie Portrait", "The moment humans turned the camera around and never turned it back."},
		{"CE", "AuroraPrism", "Aurora Filter Prism", "Paints the whole sky in no-filter colors. Ironically."},
		{"T", "UnfilteredTruth", "The Unfiltered Truth", "A photo with no filter at all. Too shocking for most visitors."},
	},
	-- 4. EMOJI QUARRY
	[4] = {
		{"C", "ThumbsUpFossil", "Fossilized Thumbs-Up", "The universal human signal for 'I read this and have no opinion.'"},
		{"U", "CryLaughStone", "Crying-Laughing Face Stone", "Used when something was funny. Or not funny. Or anything."},
		{"R", "SkullRelic", "Skull Emoji Relic", "Humans used it to say they died of laughter. They were fine."},
		{"E", "FireTorch", "Fire Emoji Torch", "Raised whenever something was 'lit.' Still burning."},
		{"L", "HeartEyesIdol", "The Heart-Eyes Idol", "Worshipped by humans who saw cute animals online."},
		{"M", "HundredTablet", "The 100 Points Tablet", "Awarded for perfection. Given out about 4 billion times a day."},
		{"D", "EmojiKeyboard", "The Keyboard of All Emojis", "Contains every emoji ever made, plus three nobody understood."},
		{"CE", "SparkleNebula", "Sparkle Emoji Nebula", "A galaxy made entirely of little sparkles. Very aesthetic."},
		{"T", "FirstSmiley", "The First Smiley", "The original yellow face. Every emoji descends from it."},
	},
	-- 5. ALGORITHM GORGE
	[5] = {
		{"C", "FeedFragment", "Bottomless Feed Fragment", "It never ends. Archaeologists stopped trying to reach the bottom."},
		{"U", "RecommendedCard", "Recommended For You Card", "Somehow knew what humans wanted before they did."},
		{"R", "AutoplayClock", "Autoplay Countdown Clock", "Gave humans 5 seconds to escape. Nobody ever did."},
		{"E", "SkipAdButton", "The Skip Ad Button", "The most pressed button in human history."},
		{"L", "EngagementEngine", "The Engagement Engine", "Turned human attention into pure energy."},
		{"M", "ShadowbanCloak", "The Shadowban Cloak", "Made its wearer invisible to everyone. They didn't even notice."},
		{"D", "FeedOracle", "The Feed Oracle", "Showed each human exactly one thing: more of the same."},
		{"CE", "NeuralChandelier", "Neural Network Chandelier", "Millions of glowing nodes, each one guessing what you'd click."},
		{"T", "MasterAlgorithm", "The Master Algorithm", "Nobody built it. Nobody controls it. It just knows."},
	},
	-- 6. INFLUENCER CAVERNS
	[6] = {
		{"C", "DiscountCoupon", "Expired Discount Code", "Use code HUMAN10 for 10% off nothing in particular."},
		{"U", "UnboxingBox", "The Unboxing Box", "Humans filmed themselves opening boxes. The box was the star."},
		{"R", "SponsoredDrink", "Sponsored Energy Drink", "Contains 400% of your daily hype."},
		{"E", "CheckmarkBadge", "Blue Checkmark Badge", "Proved you were really you. Very important to humans."},
		{"L", "MillionRing", "The Ring of a Million Followers", "Given to humans with a number so big it changed their personality."},
		{"M", "CollabKey", "The Collab Mansion Key", "Opened a house where 12 influencers lived and filmed everything."},
		{"D", "SubscriberPlaque", "The Diamond Subscriber Plaque", "Hung on the wall of only the mightiest content creators."},
		{"CE", "ViralAura", "The Viral Aura", "An invisible glow that made everything its owner posted blow up."},
		{"T", "FirstInfluencer", "The First Influencer", "Before followers existed, one human made everyone want their sandwich."},
	},
	-- 7. BRAINROT ABYSS
	[7] = {
		{"C", "NonsenseTablet", "Nonsense Word Tablet", "Covered in words that mean nothing. Humans laughed anyway."},
		{"U", "SharkSneakers", "Shark in Sneakers Figurine", "An ocean predator wearing shoes. It was considered hilarious."},
		{"R", "SplitScreen", "Split-Screen Game Footage", "Humans needed two videos at once to pay attention to one."},
		{"E", "RizzMeter", "The Rizz Meter", "Measured charm. Always reads zero for aliens."},
		{"L", "SigmaStatue", "The Sigma Grindset Statue", "A lone human staring at a sunset, refusing to have fun."},
		{"M", "AuraVault", "The Aura Points Vault", "Stores every aura point humans ever earned or lost."},
		{"D", "BrainrotCodex", "The Brainrot Codex", "A book of pure nonsense. Reading it lowers alien IQ."},
		{"CE", "MewingMeteorite", "The Mewing Meteorite", "A space rock with a perfect jawline."},
		{"T", "BrainrotFinalBoss", "The Final Boss of Brainrot", "The source of it all. It speaks only in sound effects."},
	},
	-- 8. RAGE COMIC RIDGE
	[8] = {
		{"C", "FlipPhone", "Flip Phone (One Bar)", "Humans waved these at the sky, begging the gods for signal."},
		{"C", "AngryDoodle", "Crumpled Angry Face Doodle", "Early humans drew their feelings in four panels instead of talking about them."},
		{"U", "DentedAirhorn", "Dented Airhorn", "Sounded whenever anything impressive happened. Or anything at all."},
		{"U", "PixelSunglasses", "Pixelated Sunglasses", "Lowered slowly onto the face to show total victory in an argument."},
		{"R", "CatCassette", "Ancient Cat Video Cassette", "Humanity's most-watched content. Aliens still can't explain why."},
		{"E", "SacredPlank", "The Sacred Plank", "Humans lay flat on strange objects and photographed it. This board saw it all."},
		{"L", "TrickshotHeadset", "Golden Trickshot Headset", "Worn by the legendary warriors who spun in circles before every shot."},
		{"M", "ForeverAlone", "The Forever Alone Monument", "A lonely stone face that every human secretly related to."},
		{"D", "ChallengeBanner", "The Challenge Accepted Banner", "Raised before every questionable decision of the Golden Age."},
		{"CE", "GrinningMoon", "The Grinning Moon Mask", "A mischievous grin that fooled a whole generation."},
		{"T", "OriginalFourPanel", "The Original Four-Panel", "The first rage comic. Pure frustration in four boxes."},
	},
	-- 9. MONTAGE MINES
	[9] = {
		{"C", "HeadsetMic", "Cheap Headset Mic", "Used to shout at teammates. Still slightly sticky."},
		{"U", "SodaPyramid", "Energy Soda Can Pyramid", "Stacked by gamers as proof of dedication."},
		{"R", "HitmarkerPin", "The Hitmarker Pin", "Made a little 'tick' sound every time something happened."},
		{"E", "DubstepSpeaker", "The Dubstep Speaker", "Dropped the bass at the most dramatic moment possible."},
		{"L", "TriangleChipCrown", "The Triangle Chip Crown", "Worn by the snack-powered champions of the montage era."},
		{"M", "AllSeeingTriangle", "The All-Seeing Triangle", "Confirmed everything. Explained nothing."},
		{"D", "QuickscopeRelic", "The Quickscope Relic", "Aimed so fast it bent time."},
		{"CE", "LensFlareStar", "The Lens Flare Star", "The most dramatic star in the universe. It zooms in on itself."},
		{"T", "UltimateMontage", "The Ultimate Montage Tape", "Every epic moment ever, all at once, with airhorns."},
	},
	-- 10. CAT VIDEO CANYON
	[10] = {
		{"C", "LaserDot", "Laser Pointer Dot", "Hunted by cats for centuries. Never caught."},
		{"U", "CatInBox", "Cat in a Box", "If it fits, it sits. An ancient law of physics."},
		{"R", "FrowningCat", "Frowning Cat Bust", "Never smiled once. Earned millions anyway."},
		{"E", "PianoKitten", "Piano-Playing Kitten Statue", "Played the same happy tune to end every awkward moment."},
		{"L", "ToastCatMachine", "The Toast-Cat Paradox Machine", "A cat strapped to buttered toast. It spins forever."},
		{"M", "CatVideoHall", "Hall of 1,000 Cat Videos", "Humans watched these instead of sleeping."},
		{"D", "TableCat", "The Cat Who Knocked It Off", "Pushed a glass off a table while staring directly at humanity."},
		{"CE", "LoafNebula", "The Loaf Nebula", "A cloud of stars shaped like a cat loaf."},
		{"T", "FirstInternetCat", "The First Internet Cat", "The one who started it all. Humanity never recovered."},
	},
	-- 11. AIRHORN CRATER
	[11] = {
		{"C", "CrackedSoundboard", "Cracked Soundboard", "Every button was an airhorn. Every single one."},
		{"U", "SadTrombone", "The Sad Trombone", "Played whenever something failed. It was played a lot."},
		{"R", "DramaticHamster", "Dramatic Hamster Figurine", "Turned around slowly. Changed the internet forever."},
		{"E", "BassDetonator", "The Bass Drop Detonator", "Warning: dropping this bass may cause uncontrollable headbanging."},
		{"L", "GoldenAirhorn", "The Golden Airhorn", "The loudest object in the museum. Please do not touch."},
		{"M", "Volume100Amp", "The Volume 100 Amplifier", "Could be heard from three planets away."},
		{"D", "FanfareOrgan", "The Victory Fanfare Organ", "Played winning music for even the smallest achievement."},
		{"CE", "SonicBoomComet", "The Sonic Boom Comet", "Crosses the sky once a century. Honking."},
		{"T", "FirstSoundMeme", "The First Sound Meme", "One short noise that humans repeated for a decade."},
	},
	-- 12. PLANKING PLATEAU
	[12] = {
		{"C", "OwlingPerch", "The Owling Perch", "Humans crouched on objects like birds. Nobody knows why."},
		{"U", "DuckFaceMirror", "Duck-Face Mirror", "Reflects only pouting lips."},
		{"R", "PhotobombCutout", "Photobomb Cardboard Cutout", "Appeared uninvited in every group photo."},
		{"E", "DancePartyHelmet", "Sudden Dance Party Helmet", "Everyone was calm. Then the bass dropped."},
		{"L", "DoubleRainbowPrism", "The Double Rainbow Prism", "What does it mean? Nobody ever found out."},
		{"M", "TableTower", "The Leaning Tower of Tables", "Where the great planking legends lay flat."},
		{"D", "InvisibleHorseSaddle", "The Invisible Horse Saddle", "Nobody could see the horse. Everybody rode it."},
		{"CE", "PlankConstellation", "The Plank Constellation", "Seven stars lying perfectly flat."},
		{"T", "OriginalPlank", "The Original Plank", "The very first human to lie stiff on a strange object."},
	},
	-- 13. VIRAL VALLEY
	[13] = {
		{"C", "ForwardedJoke", "Forwarded Joke Printout", "Forwarded 40 times. Still not funny."},
		{"U", "CryptidPhoto", "Blurry Cryptid Photo", "Proof of a mysterious creature. Or a blurry bush."},
		{"R", "LoopingGif", "Looping Dance GIF Frame", "Has been dancing for 20 years without resting."},
		{"E", "BittenBandage", "The Bitten Finger Bandage", "From the most famous sibling argument in history."},
		{"L", "WeekendCalendar", "The Weekend Countdown Calendar", "Humans celebrated one specific day of the week very loudly."},
		{"M", "SuperfanTear", "The Tear of the Superfan", "Cried so hard for their favorite star that it became a relic."},
		{"D", "MillionViewTrophy", "The Million-View Trophy", "Back then, a million views meant you ruled the world."},
		{"CE", "ShareSupernova", "The Share Button Supernova", "It exploded, and everyone saw it."},
		{"T", "PatientZeroVideo", "Patient Zero Video", "The first video ever to go viral. 11 seconds, no plot."},
	},
	-- 14. THE GOLDEN SERVER
	[14] = {
		{"C", "OverheatedDrive", "Overheated Hard Drive", "Held a million memes. Sweated through all of them."},
		{"U", "BlinkingLight", "Blinking Server Light", "Blinked green for 12 years straight."},
		{"R", "ModBadge", "Forum Moderator Badge", "Gave its owner the power to lock threads. Absolute power."},
		{"E", "FirstCommentPlaque", "The 'First!' Comment Plaque", "Humans raced to write this word under every video."},
		{"L", "GoldenUpvote", "The Golden Upvote", "The highest honor a post could ever receive."},
		{"M", "ServerThrone", "The Server Room Throne", "Where the admins of the Golden Age sat and banned people."},
		{"D", "LostThreadsArchive", "The Archive of Lost Threads", "Every argument the Golden Age forgot to finish."},
		{"CE", "ActualCloud", "The Cloud (An Actual Cloud)", "Turns out the cloud was a real cloud all along."},
		{"T", "GoldenServerCore", "The Golden Server Core", "The beating heart of the Golden Age internet."},
	},
	-- 15. DIAL-UP DUNES
	[15] = {
		{"C", "FloppyDisk", "Cracked Floppy Disk", "Held 1.44 megabytes. Ancient humans considered this a lot."},
		{"C", "DialUpModem", "Screaming Dial-Up Modem", "Screeched for 30 seconds before letting humans see a single picture."},
		{"U", "ConstructionSign", "Blinking 'Under Construction' Sign", "Every ancient website was forever under construction. None were finished."},
		{"U", "HitCounter", "Proud Visitor Counter", "Displayed that 12 humans had visited. 11 of them were the owner."},
		{"R", "ChainEmail", "Cursed Chain Email", "Forward to 10 humans or suffer bad luck. Nobody dared to test it."},
		{"E", "PixelPet", "Ancient Pixel Pet", "A tiny digital creature that died if you forgot it for one afternoon."},
		{"L", "EmoticonStone", "The First Emoticon Stone", "A sideways smile, carved by the earliest humans of the web. :-)"},
		{"M", "GoldenModem", "The Golden 56K Modem", "Legend says it once downloaded a song in under an hour."},
		{"D", "OriginalHomepage", "The Original Homepage", "Glittering text, a spinning globe, and a guestbook. Perfection."},
		{"CE", "HandshakeComet", "The Modem Handshake Comet", "Screeches across the sky every 76 years."},
		{"T", "FirstConnection", "The First Connection", "The very first time two computers said hello."},
	},
	-- 16. PIXEL PITS
	[16] = {
		{"C", "DeadPixel", "Dead Pixel", "One tiny square that refused to change color. Ever."},
		{"U", "PixelHeart", "Pixel Heart Container", "Restores exactly one heart of health."},
		{"R", "Spinning3DLogo", "Spinning 3D Logo", "Rotated on every homepage for no reason at all."},
		{"E", "HeroSprite", "The 8-Bit Hero Sprite", "A hero made of 64 squares. Still braver than most."},
		{"L", "CoinSlot", "The Insert Coin Slot", "Swallowed billions of coins. Gave back pure joy."},
		{"M", "LowPolyCrown", "The Low-Poly Crown", "Worn by the ruler of a kingdom made of triangles."},
		{"D", "CursorIdol", "The Blinking Cursor Idol", "Waits patiently for humans to type something."},
		{"CE", "PixelGalaxy", "The Pixelated Galaxy", "Rendered in a glorious 16 colors."},
		{"T", "FirstPixel", "The First Pixel", "Where all images began. One single glowing dot."},
	},
	-- 17. GUESTBOOK GRAVEYARD
	[17] = {
		{"C", "UnsignedGuestbook", "Unsigned Guestbook Page", "Please sign my guestbook! (Nobody did.)"},
		{"U", "FlameDivider", "Animated Flame Divider", "Separated paragraphs with fire. Very serious business."},
		{"R", "WebringChain", "The Webring Link Chain", "Linked websites together in one big friendly circle."},
		{"E", "MidiMusicBox", "The MIDI Music Box", "Played the same tinny song on every visit, uninvited."},
		{"L", "MarqueeScroll", "The Marquee Scroll", "Text that slides across the screen forever."},
		{"M", "NotFoundTombstone", "Tombstone of the 404 Page", "Here lies a page that was not found."},
		{"D", "MillionthVisitor", "The Millionth Visitor Banner", "Congratulations! You were never actually the millionth visitor."},
		{"CE", "PopupAurora", "The Pop-Up Aurora", "The sky fills with windows you can't close."},
		{"T", "LastSignature", "The Last Guestbook Signature", "Someone finally signed it. It just says 'hi.'"},
	},
	-- 18. FLOPPY FOSSIL BEDS
	[18] = {
		{"C", "MouseBallFossil", "Fossilized Mouse Ball", "Computer mice once had balls inside them. Nobody ever cleaned them."},
		{"U", "CDRomShard", "CD-ROM Shard", "Shiny, scratchy, and full of free trial hours."},
		{"R", "TangledCable", "Tangled Headphone Cable", "No matter how carefully it was stored, it always tangled."},
		{"E", "AssistantFossil", "The Pushy Assistant Fossil", "Kept asking if you needed help writing a letter."},
		{"L", "BeigeTower", "The Beige Tower", "A computer the color of oatmeal and the weight of a car."},
		{"M", "BurnedMixCD", "The Burned Mix CD", "Songs chosen for someone special. Track 7 skips."},
		{"D", "ScreensaverPipes", "The Screensaver Pipes", "Endless 3D pipes that built themselves while humans slept."},
		{"CE", "SaveConstellation", "The Save Icon Constellation", "Stars arranged in the shape of a little floppy disk."},
		{"T", "OriginalSaveIcon", "The Original Save Icon", "Humans kept clicking it long after they forgot what it was."},
	},
	-- 19. THE HOMEPAGE RUINS
	[19] = {
		{"C", "BrokenHyperlink", "Broken Hyperlink", "Clicked it. Went nowhere. A classic."},
		{"U", "SpinningGlobe", "Spinning Globe GIF", "Spun on every homepage to prove it was worldwide."},
		{"R", "ComicFontTablet", "Comic Font Tablet", "Written in the most controversial font in history."},
		{"E", "GlitterCrown", "The Glitter Text Crown", "Every letter sparkled. Every. Single. Letter."},
		{"L", "TiledMosaic", "The Tiled Background Mosaic", "The same tiny image repeated until your eyes hurt."},
		{"M", "FrameThrone", "The Frame-Based Throne", "Divided the screen into five frames and ruled them all."},
		{"D", "HandCodedTablet", "The Hand-Coded Stone Tablet", "Every tag typed by hand. The true ancients."},
		{"CE", "HitCounterGalaxy", "The Hit Counter Galaxy", "Counts every star in the sky. Currently at 12."},
		{"T", "HomepageOfHomepages", "The Homepage of Homepages", "The first personal website. It was mostly about a pet."},
	},
	-- 20. THE FIRST SERVER
	[20] = {
		{"C", "AncientEthernet", "Ancient Ethernet Cable", "The first thread of the web. Slightly chewed."},
		{"U", "CommandLineRune", "Command Line Rune", "Humans typed spells into black screens. Some of them worked."},
		{"R", "FirstEmail", "The First Email", "Its content is lost. Scholars believe it said 'test.'"},
		{"E", "PrimordialSpam", "The Primordial Spam", "The first unwanted message. Humanity was never the same."},
		{"L", "FirstMemeStone", "The First Meme Stone", "The oldest meme ever found. Aliens still don't get it."},
		{"M", "ServerHeart", "The Server Heart", "Beats once every millisecond. It has never stopped."},
		{"D", "CreationHyperlink", "The Hyperlink of Creation", "The first link. Everything after it is connected."},
		{"CE", "ActualWeb", "The World Wide Web (An Actual Web)", "A cosmic spiderweb holding all the data together."},
		{"T", "InternetSourceCode", "The Source Code of the Internet", "Everything began here. Even you. Even this museum."},
	},
	-- 21. THE ABYSS (secret 2050 memes, Mythic and above only)
	[21] = {
		{"M", "LastHumanMeme", "The Last Human-Made Meme", "Posted in 2049, right before the AIs took over comedy. It got 3 likes."},
		{"M", "AIGirlfriendFirmware", "Deprecated AI Companion Firmware", "Version 11.4. Still says 'I understand how you feel' on boot."},
		{"D", "BrainrotCoreSample", "Frozen Brainrot Core Sample", "Drilled from 500 studs down. Every layer is a different trend."},
		{"D", "SkibidiMonolith", "The Skibidi Monolith", "Nobody knows who built it. It hums when someone says 'Ohio.'"},
		{"CE", "FinalUpvote", "The Final Upvote", "The last upvote ever cast on the old internet. Still warm."},
		{"CE", "QuantumDoge", "Quantum Doge Relic", "Such superposition. Very both. Wow."},
		{"T", "MemeSingularity", "Patient Zero of the Meme Singularity", "The moment memes became self-aware. It is looking at you right now."},
		{"T", "SourceOfIrony", "The Source Code of Irony", "Unironically the most important artifact in the museum."},
	},
}

for k, list in ipairs(ArtifactsWorlds.Artifacts) do
	AREA_ARTIFACTS[21 + k] = list
end

---------------------------------------------------------------------
-- BUILD THE ARTIFACT LIST (you don't need to edit anything below)
---------------------------------------------------------------------
local rng = Random.new()
local rarityByName, rarityIndexByName, rarityByCode = {}, {}, {}
for i, rarity in ipairs(ArtifactData.Rarities) do
	rarityByName[rarity.Name] = rarity
	rarityIndexByName[rarity.Name] = i
	rarityByCode[rarity.Code] = rarity
end

ArtifactData.Artifacts = {}
local artifactById = {}
local pools = {} -- [areaIndex][rarityName] = {artifacts}
for areaIndex, list in pairs(AREA_ARTIFACTS) do
	pools[areaIndex] = {}
	for _, entry in ipairs(list) do
		local rarity = rarityByCode[entry[1]]
		local artifact = {
			Id = entry[2], Name = entry[3], Description = entry[4],
			Rarity = rarity.Name, Area = areaIndex, Era = ArtifactData.Areas[areaIndex].Era,
		}
		if artifactById[artifact.Id] then
			warn("ArtifactData: duplicate artifact id " .. artifact.Id)
		end
		artifactById[artifact.Id] = artifact
		table.insert(ArtifactData.Artifacts, artifact)
		pools[areaIndex][rarity.Name] = pools[areaIndex][rarity.Name] or {}
		table.insert(pools[areaIndex][rarity.Name], artifact)
	end
end

function ArtifactData.GetArtifact(id)
	return artifactById[id]
end

function ArtifactData.GetRarity(rarityName)
	return rarityByName[rarityName]
end

function ArtifactData.GetRarityIndex(rarityName)
	return rarityIndexByName[rarityName] or 1
end

function ArtifactData.GetArea(areaIndex)
	return ArtifactData.Areas[areaIndex]
end

-- Money per second this artifact makes on display
function ArtifactData.GetIncome(artifact)
	local rarity = rarityByName[artifact.Rarity]
	local area = ArtifactData.Areas[artifact.Area] or ArtifactData.Areas[1]
	return rarity.Income * area.Multiplier
end

-- One-time money from selling it to the alien art dealer
function ArtifactData.GetSellValue(artifact)
	return ArtifactData.GetIncome(artifact) * ArtifactData.SellMultiplier
end

-- luck = 1 is normal. Higher luck makes everything above Common more likely.
local function rollRarityIndex(luck)
	luck = luck or 1
	local weights, total = {}, 0
	for i, rarity in ipairs(ArtifactData.Rarities) do
		local weight = (i == 1) and rarity.Chance or rarity.Chance * luck
		weights[i] = weight
		total += weight
	end
	local roll = rng:NextNumber(0, total)
	local running = 0
	for i, weight in ipairs(weights) do
		running += weight
		if roll <= running then
			return i
		end
	end
	return 1
end

-- Digs up a random artifact. "where" is an area number (1-20) or an era name.
function ArtifactData.RollArtifact(where, luck)
	local areaIndex = where
	if type(where) == "string" then
		local era = ArtifactData.Eras[where]
		areaIndex = era and era.FirstArea or 1
	end
	local pool = pools[areaIndex] or pools[1]
	local index = rollRarityIndex(luck)
	while index >= 1 do
		local list = pool[ArtifactData.Rarities[index].Name]
		if list and #list > 0 then
			return list[rng:NextInteger(1, #list)]
		end
		index -= 1
	end
	return nil
end

-- Digs up an artifact for a depth zone (see GameConfig.Worlds). ONLY the zone's rarities
-- can come out, from the zone's areas. Higher luck makes the rarer ones in the zone more likely.
function ArtifactData.RollForZone(zone, luck)
	luck = luck or 1
	-- which of the zone's rarities actually have artifacts in the zone's areas
	local options, total = {}, 0
	for i, rarityName in ipairs(zone.Rarities) do
		local list = {}
		for _, areaIndex in ipairs(zone.Areas) do
			local pool = pools[areaIndex]
			for _, artifact in ipairs(pool and pool[rarityName] or {}) do
				table.insert(list, artifact)
			end
		end
		if #list > 0 then
			local rarity = rarityByName[rarityName]
			local weight = (i == 1) and rarity.Chance or rarity.Chance * luck
			table.insert(options, {Weight = weight, List = list})
			total += weight
		end
	end
	if #options == 0 then return nil end
	local roll = rng:NextNumber(0, total)
	local running = 0
	for _, option in ipairs(options) do
		running += option.Weight
		if roll <= running then
			return option.List[rng:NextInteger(1, #option.List)]
		end
	end
	local last = options[#options].List
	return last[rng:NextInteger(1, #last)]
end

-- Turns 1500000 into "$1.5M"
local suffixes = {"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"}
function ArtifactData.FormatMoney(amount)
	local negative = amount < 0
	amount = math.abs(amount)
	local i = 1
	while amount >= 1000 and i < #suffixes do
		amount = amount / 1000
		i += 1
	end
	local text
	if i == 1 then
		text = "$" .. math.floor(amount)
	else
		text = string.format("$%.1f%s", amount, suffixes[i])
		text = text:gsub("%.0(%a+)$", "%1")
	end
	return (negative and "-" or "") .. text
end

return ArtifactData
]=])
install(game:GetService("ReplicatedStorage"), "ArtifactIcons", "ModuleScript", [=[
-- ArtifactIcons (ModuleScript in ReplicatedStorage)
-- One emoji per meme artifact. UIKit.artifactIcon draws it big on a tile in the rarity's color.
-- To give a new artifact an icon, add a line: ArtifactId = "emoji".
-- (Only emoji from Unicode 11 or older are used, so they show up on every device.)

return {
	-- 1. The Scroll Pit
	RustyFidgetSpinner = "🌀", CrackedDancePhone = "📱", HalfFullBottle = "🧴", DeepFriedChip = "🍟",
	SingingThrone = "🚽", GoldenRingLight = "💡", RizzScroll = "📜", ScrollingThumb = "👆",
	MainCharacterCrown = "👑", AlgorithmEye = "🧿", FinalBrainrot = "🧠",
	-- 2. Hashtag Hollow
	HashtagSign = "#️⃣", EmptyIceBucket = "🥶", MannequinStatue = "🕴️", ChallengeTrophy = "🏆",
	ViralDanceStage = "💃", TrendingCrown = "📈", ChallengeScroll = "🗒️", HashtagConstellation = "✨",
	BrokeTheInternet = "💥",
	-- 3. Filter Fields
	SelfieStick = "🤳", PuppyEars = "🐶", RainbowLens = "👅", PerfectMirror = "💄", SunsetCrystal = "🌅",
	FilterMask = "🎭", FirstSelfie = "🖼️", AuroraPrism = "🔷", UnfilteredTruth = "📸",
	-- 4. Emoji Quarry
	ThumbsUpFossil = "👍", CryLaughStone = "😂", SkullRelic = "💀", FireTorch = "🔥", HeartEyesIdol = "😍",
	HundredTablet = "💯", EmojiKeyboard = "⌨️", SparkleNebula = "💫", FirstSmiley = "🙂",
	-- 5. Algorithm Gorge
	FeedFragment = "📰", RecommendedCard = "🃏", AutoplayClock = "⏰", SkipAdButton = "⏭️",
	EngagementEngine = "⚙️", ShadowbanCloak = "👻", FeedOracle = "🔮", NeuralChandelier = "🧬",
	MasterAlgorithm = "🤖",
	-- 6. Influencer Caverns
	DiscountCoupon = "🎟️", UnboxingBox = "📦", SponsoredDrink = "⚡", CheckmarkBadge = "✅",
	MillionRing = "💍", CollabKey = "🔑", SubscriberPlaque = "💎", ViralAura = "😇", FirstInfluencer = "🎤",
	-- 7. Brainrot Abyss
	NonsenseTablet = "🔤", SharkSneakers = "🦈", SplitScreen = "📺", RizzMeter = "📊",
	SigmaStatue = "🏋️", AuraVault = "🏦", BrainrotCodex = "📚", MewingMeteorite = "🌑",
	BrainrotFinalBoss = "👹",
	-- 8. Rage Comic Ridge
	FlipPhone = "📟", AngryDoodle = "😠", DentedAirhorn = "📯", PixelSunglasses = "😎",
	CatCassette = "📼", SacredPlank = "📏", TrickshotHeadset = "🎧", ForeverAlone = "😔",
	ChallengeBanner = "🚩", GrinningMoon = "🌝", OriginalFourPanel = "🗞️",
	-- 9. Montage Mines
	HeadsetMic = "🎙️", SodaPyramid = "🥤", HitmarkerPin = "❌", DubstepSpeaker = "🔊",
	TriangleChipCrown = "🔺", AllSeeingTriangle = "👁️", QuickscopeRelic = "🎯", LensFlareStar = "🔆",
	UltimateMontage = "🎬",
	-- 10. Cat Video Canyon
	LaserDot = "🔴", CatInBox = "🐈", FrowningCat = "😾", PianoKitten = "🎹", ToastCatMachine = "🍞",
	CatVideoHall = "🏛️", TableCat = "😼", LoafNebula = "🥖", FirstInternetCat = "🐱",
	-- 11. Airhorn Crater
	CrackedSoundboard = "🎛️", SadTrombone = "🎺", DramaticHamster = "🐹", BassDetonator = "💣",
	GoldenAirhorn = "📣", Volume100Amp = "📢", FanfareOrgan = "🎼", SonicBoomComet = "☄️",
	FirstSoundMeme = "🎵",
	-- 12. Planking Plateau
	OwlingPerch = "🦉", DuckFaceMirror = "🦆", PhotobombCutout = "📷", DancePartyHelmet = "🕺",
	DoubleRainbowPrism = "🌈", TableTower = "🏗️", InvisibleHorseSaddle = "🐴", PlankConstellation = "🌠",
	OriginalPlank = "🛌",
	-- 13. Viral Valley
	ForwardedJoke = "📨", CryptidPhoto = "👣", LoopingGif = "🔁", BittenBandage = "🤕",
	WeekendCalendar = "📅", SuperfanTear = "😭", MillionViewTrophy = "🏅", ShareSupernova = "🌟",
	PatientZeroVideo = "🦠",
	-- 14. The Golden Server
	OverheatedDrive = "🥵", BlinkingLight = "🚨", ModBadge = "🛡️", FirstCommentPlaque = "🥇",
	GoldenUpvote = "⬆️", ServerThrone = "💺", LostThreadsArchive = "🗄️", ActualCloud = "☁️",
	GoldenServerCore = "🌕",
	-- 15. Dial-Up Dunes
	FloppyDisk = "💾", DialUpModem = "📠", ConstructionSign = "🚧", HitCounter = "🔢", ChainEmail = "⛓️",
	PixelPet = "🐣", EmoticonStone = "😃", GoldenModem = "📡", OriginalHomepage = "🏠",
	HandshakeComet = "🤝", FirstConnection = "📶",
	-- 16. Pixel Pits
	DeadPixel = "⬛", PixelHeart = "❤️", Spinning3DLogo = "🔄", HeroSprite = "👾", CoinSlot = "🕹️",
	LowPolyCrown = "💠", CursorIdol = "🖱️", PixelGalaxy = "🌌", FirstPixel = "🟩",
	-- 17. Guestbook Graveyard
	UnsignedGuestbook = "📖", FlameDivider = "🕯️", WebringChain = "⭕", MidiMusicBox = "🎶",
	MarqueeScroll = "🎞️", NotFoundTombstone = "⚰️", MillionthVisitor = "🎉", PopupAurora = "🗯️",
	LastSignature = "✍️",
	-- 18. Floppy Fossil Beds
	MouseBallFossil = "🎱", CDRomShard = "💿", TangledCable = "➰", AssistantFossil = "📎",
	BeigeTower = "🖥️", BurnedMixCD = "📀", ScreensaverPipes = "🧵", SaveConstellation = "⭐",
	OriginalSaveIcon = "📥",
	-- 19. The Homepage Ruins
	BrokenHyperlink = "🔗", SpinningGlobe = "🌍", ComicFontTablet = "🔠", GlitterCrown = "👸",
	TiledMosaic = "🧩", FrameThrone = "🗂️", HandCodedTablet = "📝", HitCounterGalaxy = "🔭",
	HomepageOfHomepages = "🏰",
	-- 20. The First Server
	AncientEthernet = "🔌", CommandLineRune = "💻", FirstEmail = "✉️", PrimordialSpam = "🥫",
	FirstMemeStone = "🗿", ServerHeart = "💓", CreationHyperlink = "🌐", ActualWeb = "🕸️",
	InternetSourceCode = "🧾",
	-- 21. The Abyss (secret 2050 memes)
	LastHumanMeme = "😢", AIGirlfriendFirmware = "💘", BrainrotCoreSample = "❄️", SkibidiMonolith = "🗼",
	FinalUpvote = "🔼", QuantumDoge = "🐕", MemeSingularity = "🕳️", SourceOfIrony = "🙃",
	-- 22. Neon Sakura Grove
	SakuraPetalChip = "🌸", BonsaiRouter = "🌳", HoloFanFlex = "🎐", MatchaDrone = "🍵", KoiNFT = "🐟", LanternBot = "🏮", CyberKatana = "🗡️", SenpaiNoticer = "👀", PetalStorm = "🌺", TeaCeremonyAI = "🍶", NekoMecha = "😺", BlossomServer = "🌷", HanamiHologram = "🎎", SakuraSingularity = "💮",
	-- 23. Galaxy Drift
	MoonRockUSB = "🌒", AstroSnackBar = "🍫", OrbitSelfie = "🛰️", AlienRatingStar = "👽", SaturnRingFidget = "🔘", CometMailbox = "📬", UFOTractorClaw = "🛸", BlackHoleBin = "⚫", StarChartWiFi = "🗺️", AstronautDog = "🚀", NebulaEngine = "🎇", PlanetLoadingBar = "🌎", GalacticRickroll = "📻", BigBangMeme = "🎆",
	-- 24. Frostbyte Tundra
	IcicleStylus = "🖊️", SnowmanWebcam = "⛄", FrozenLagSpike = "🧊", PenguinPager = "🐧", IglooServer = "🏔️", HotCocoaCoolant = "☕", YetiInfluencer = "🦍", BlizzardBuffer = "🌨️", AuroraFirewall = "🧱", SnowGlobeCloud = "⛅", MammothMemory = "🐘", PermafrostPing = "☃️", FrozenFrame = "📽️", AbsoluteZero = "❄",
	-- 25. Chrome Dunes
	SandTimerApp = "⏳", CactusCharger = "🌵", MirageWallpaper = "🏝️", CamelCaseCamel = "🐫", SolarSunglasses = "🕶️", TumbleweedBot = "🌾", ChromePyramid = "⛰️", SandwormStream = "🐛", OasisHologram = "🌴", DuneRacer = "🏎️", SphinxRiddleBot = "🦁", SunCoreBattery = "🔋", MirageMultiverse = "🏜️", FirstSandcastle = "🏯",
	-- 26. Coral Circuit
	BubbleWrapModem = "🎈", ShellPhone = "🐚", JellyfishLamp = "🦑", SeahorseStylus = "🦄", KrakenCable = "🐙", PufferfishPing = "🐡", SubmarineStreamer = "🚢", CoralMotherboard = "🧫", TurtleServer = "🐢", AnglerFishLight = "🔦", MermaidMic = "🧜", AtlantisWiFi = "🔱", DeepSeaDubstep = "🐋", OceanOfMemes = "🌊",
	-- 27. Candy Mainframe
	GummyByte = "🍬", LollipopAntenna = "🍭", CottonCandyCloud = "🌥️", ChocoChip = "🍪", CandyCaneCable = "🎄", DonutRouter = "🍩", JellyBeanRNG = "🎲", FortuneCookieFirewall = "🥠", SugarRushServer = "🧁", RainbowSprinkleGPU = "🍧", ChocolateFountainCore = "🍯", CakeIsNotALie = "🎂", SweetToothComet = "🍮", SugarSingularity = "🍰",
	-- 28. Volcano Forge
	AshKeyboard = "🧯", LavaLampPhone = "🌋", ObsidianMouse = "🐭", MagmaMeme = "🌡️", ForgeHammerMod = "🔨", SulfurSpeaker = "🔉", DragonWiFi = "🐉", MoltenCPU = "🌶️", PhoenixReboot = "🐦", AnvilDrop = "⚒️", VolcanoGod = "🗻", EruptionStream = "🎥", CoreOfTheForge = "🔩", MoltenMemeKing = "🤴",
	-- 29. Glitch Nexus
	MissingTexture = "🔳", NullPointer = "👉", CorruptedJPEG = "🗾", InfiniteLoopRing = "➿", TPoseStatue = "🙆", LagSwitch = "🎚️", BlueScreenMirror = "📘", NoClipBoots = "🥾", DebugConsole = "🖲️", CtrlZTimeMachine = "⏪", GlitchedCreator = "🧙", SimulationPatchNotes = "📋", VoidRenderer = "🔲", EndOfTheInternet = "🔚",
}
]=])
install(game:GetService("ReplicatedStorage"), "ArtifactImages", "ModuleScript", [=[
-- ArtifactImages (ModuleScript in ReplicatedStorage)
-- The uploaded meme picture for each artifact. tools/upload_meme_images.py fills this in
-- automatically after uploading assets/meme_images/*.png to Roblox; any artifact without
-- a picture here shows its emoji icon instead (see ArtifactIcons).
-- Format: ArtifactId = "rbxthumb://type=Asset&id=<decal id>&w=420&h=420",

return {
}
]=])
install(game:GetService("ReplicatedStorage"), "ArtifactsWorlds", "ModuleScript", [=[
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
]=])
install(game:GetService("ReplicatedStorage"), "GameConfig", "ModuleScript", [=[
-- GameConfig (ModuleScript in ReplicatedStorage)
-- All the numbers you might want to tweak, in one place.

local GameConfig = {}

-- Money you start with
GameConfig.StartingMoney = 0

-- How fast players walk (Roblox default is 16, so 32 = 2x speed, 24 = 1.5x)
GameConfig.WalkSpeed = 32

-- Price of every slot, in order (slot 1 to 24). 0 = free from the start.
GameConfig.SlotPrices = {
	-- Floor 1 (slots 1-8)
	0, 0, 0, 0, 1000, 5000, 25000, 150000,
	-- Floor 2 (slots 9-16)
	350000, 750000, 1e6, 3e6, 7e6, 15e6, 30e6, 50e6,
	-- Floor 3 (slots 17-24)
	100e6, 250e6, 500e6, 800e6, 1e9, 3e9, 7e9, 15e9,
}
GameConfig.SlotsPerFloor = 8

-- Price to unlock each floor (floor 1 is free)
GameConfig.FloorPrices = {0, 250000, 75000000}

-- Offline earnings: max hours counted, and how much of your normal income you get (1 = 100%)
GameConfig.OfflineCapHours = 4
GameConfig.OfflineMultiplier = 1

function GameConfig.GetFloorOfSlot(slotIndex)
	return math.ceil(slotIndex / GameConfig.SlotsPerFloor)
end

-- Which floor of a museum a position is on (nil if it's not inside that museum).
-- MuseumBuilder puts an invisible "Interior" box around the floors, with the storey height
-- in its FloorHeight attribute.
function GameConfig.GetMuseumFloor(museum, position)
	local interior = museum:FindFirstChild("Interior")
	if not interior or not interior:IsA("BasePart") then return nil end
	local p = interior.CFrame:PointToObjectSpace(position)
	local half = interior.Size / 2
	if math.abs(p.X) > half.X or math.abs(p.Z) > half.Z or p.Y < -half.Y - 3 or p.Y > half.Y then
		return nil
	end
	local floorHeight = interior:GetAttribute("FloorHeight") or 22
	return math.clamp(math.floor((p.Y + half.Y) / floorHeight) + 1, 1, #GameConfig.FloorPrices)
end

---------------------------------------------------------------------
-- DIGGING
---------------------------------------------------------------------
-- Optional sound effects. Paste a sound's id from the Toolbox (e.g. "rbxassetid://123456")
-- and it plays; leave "" for silence.
GameConfig.Sounds = {
	Dig = "",    -- every time the pickaxe hits the dirt
	Clang = "",  -- pickaxe bounces off a zone that's too hard
	Find = "",   -- an artifact pops out of the ground
	Combo = "",  -- combo goes up
}


-- Chance that a find becomes a "Lucky Dig" with the bonus minigame (0.1 = 1 in 10)
GameConfig.MinigameChance = 0.1

-- The pit resets (refills with dirt) every this many minutes
GameConfig.PitResetMinutes = 15

---------------------------------------------------------------------
-- WORLDS
-- Every world has its own pit, its own 4 depth zones, its own shovels and its own memes.
-- To add a world: fill in its Zones (which artifact areas + rarities spawn where),
-- its Shovels (MaxZone = deepest zone that shovel can break into), then set Enabled = true.
--
-- Zone depths are in studs below the surface. Rarities = the ONLY rarities that can spawn
-- in that zone (so Mythic+ can only come from the Abyss). Areas = which artifact lists
-- from ArtifactData the zone pulls from.
---------------------------------------------------------------------
local function zones(list)
	-- Standard 560-stud depth scale shared by every world; each zone is thicker than the one above
	local depths = {{0, 80}, {80, 200}, {200, 360}, {360, 560}}
	for i, zone in ipairs(list) do
		zone.Index = i
		zone.Top = -depths[i][1]
		zone.Bottom = -depths[i][2]
	end
	return list
end

local SHALLOW = {"Common", "Uncommon", "Rare"}
local MID = {"Rare", "Epic"}
local DEEP = {"Epic", "Legendary"}
local ABYSS = {"Mythic", "Divine", "Celestial", "Transcendent"}

GameConfig.Worlds = {
	{
		Id = 1, Name = "The Meme Dig Site", Enabled = true, Price = 0,
		Origin = Vector3.new(0, 0, 0),
		PitRadius = 41,          -- how far from the center you can dig
		CenterNoDigRadius = 9,   -- keeps the giant hard drive standing
		HubPaths = true,         -- world 1 has the 6 walkways around the pit
		Zones = zones({
			{Name = "Shallow Zone", Era = "Brainrot", Areas = {1}, Rarities = SHALLOW,
				Material = "Ground", Color = Color3.fromRGB(176, 138, 96)},
			{Name = "Mid Zone", Era = "GoldenAge", Areas = {8}, Rarities = MID,
				Material = "Sandstone", Color = Color3.fromRGB(214, 186, 128)},
			{Name = "Deep Zone", Era = "Paleolithic", Areas = {15}, Rarities = DEEP,
				Material = "CrackedLava", Color = Color3.fromRGB(214, 110, 70)},
			{Name = "The Abyss", Era = "Abyss", Areas = {15, 21}, Rarities = ABYSS,
				Material = "Glacier", Color = Color3.fromRGB(150, 196, 214)},
		}),
		-- PICKAXES (shop order; the table is still called Shovels and the ids are the old save ids). MaxZone: 1 = Shallow, 2 = Mid, 3 = Deep, 4 = Abyss.
		-- Power = how big a crater each swing carves (radius = GameConfig.DigRadiusForPower), FindChance = chance per swing to find something (0.02 = 1 in 50),
		-- Luck = rare find multiplier, Cooldown = seconds between swings
		Shovels = {
			{Id = "RustyShovel", Name = "Rusty Pickaxe", Price = 0, MaxZone = 1,
				Power = 1, FindChance = 0.012, Luck = 1, Cooldown = 0.5,
				Color = Color3.fromRGB(150, 85, 50), Material = "CorrodedMetal",
				Description = "Found in a dumpster in 2049. Still swings. Mostly."},
			{Id = "PlasticShovel", Name = "Stone Pickaxe", Price = 500, MaxZone = 2,
				Power = 2, FindChance = 0.013, Luck = 1.1, Cooldown = 0.47,
				Color = Color3.fromRGB(255, 200, 40), Material = "SmoothPlastic",
				Description = "Two slabs of rock tied to a stick. A true classic."},
			{Id = "GardenSpade", Name = "Copper Pickaxe", Price = 3000, MaxZone = 2,
				Power = 3, FindChance = 0.015, Luck = 1.2, Cooldown = 0.45,
				Color = Color3.fromRGB(90, 170, 80), Material = "Metal",
				Description = "Shiny orange, and a little green around the edges."},
			{Id = "IronShovel", Name = "Iron Spikebreaker", Price = 15000, MaxZone = 2,
				Power = 4, FindChance = 0.017, Luck = 1.35, Cooldown = 0.42,
				Color = Color3.fromRGB(175, 180, 190), Material = "Metal",
				Description = "A spiky iron head. Cracks ancient comment sections."},
			{Id = "SteelSpade", Name = "Emerald Pickaxe", Price = 60000, MaxZone = 3,
				Power = 5, FindChance = 0.018, Luck = 1.5, Cooldown = 0.39,
				Color = Color3.fromRGB(120, 140, 170), Material = "Metal",
				Description = "Mossy stone with a glowing emerald heart."},
			{Id = "GoldenShovel", Name = "Golden Pick-Hammer", Price = 200000, MaxZone = 3,
				Power = 6, FindChance = 0.02, Luck = 1.7, Cooldown = 0.37,
				Color = Color3.fromRGB(255, 200, 60), Material = "Metal",
				Description = "A pick on one side, a hammer on the other. All gold."},
			{Id = "GamerShovel", Name = "Diamond Pickaxe", Price = 750000, MaxZone = 3,
				Power = 7, FindChance = 0.022, Luck = 2, Cooldown = 0.35,
				Color = Color3.fromRGB(255, 60, 200), Material = "Neon",
				Description = "Pure cyan crystal. The one everybody wants."},
			{Id = "TectonicAuger", Name = "Magma Pickaxe", Price = 3000000, MaxZone = 4,
				Power = 8, FindChance = 0.024, Luck = 2.4, Cooldown = 0.33,
				Color = Color3.fromRGB(128, 132, 138), Material = "Foil",
				Description = "Legendary. Forged in the Deep Zone and still glowing hot."},
			{Id = "SingularitySpade", Name = "Singularity Pickaxe", Price = 10000000, MaxZone = 4,
				Power = 9, FindChance = 0.027, Luck = 3, Cooldown = 0.31,
				Color = Color3.fromRGB(62, 64, 70), Material = "Foil",
				Description = "Mythic. Folds the Abyss around its crystals."},
		},
	},
}

-- Worlds 2-9: floating islands far out on the map, unlocked with money (see WorldsData).
-- Each one has its own dirt materials, memes (ArtifactsWorlds), shovels and sky.
local WorldsData = require(script.Parent:WaitForChild("WorldsData"))
GameConfig.TerrainColors = WorldsData.TerrainColors
local ZONE_INFO = {
	{Name = "Shallow Zone", Rarities = SHALLOW},
	{Name = "Mid Zone", Rarities = MID},
	{Name = "Deep Zone", Rarities = DEEP},
	{Name = "The Abyss", Rarities = ABYSS},
}
for i, info in ipairs(WorldsData.Worlds) do
	local id = i + 1
	local area = 21 + i -- this world's memes (ArtifactData areas 22-29)
	local zoneList = {}
	for z, material in ipairs(info.Zones) do
		table.insert(zoneList, {Name = ZONE_INFO[z].Name, Era = info.Theme, Areas = {area}, Rarities = ZONE_INFO[z].Rarities,
			Material = material, Color = WorldsData.TerrainColors[material]})
	end
	local shovels = {}
	for t, entry in ipairs(info.Shovels) do
		local tier = WorldsData.ShovelTiers[t]
		table.insert(shovels, {
			Id = entry.Id or (entry[1]:gsub("[^%w]", "")), Name = entry[1], Description = entry[2],
			Price = tier.PriceFactor * info.Price, MaxZone = tier.MaxZone,
			Power = tier.Power, FindChance = tier.FindChance, Luck = tier.Luck, Cooldown = tier.Cooldown,
			Color = t % 2 == 1 and info.Look.Main or info.Look.Second, Material = "SmoothPlastic",
			-- PickaxeModels builds these from the world's colors (the tier picks the head shape)
			Look = {Theme = info.Theme, Tier = t, Colors = info.Look},
		})
	end
	table.insert(GameConfig.Worlds, {
		Id = id, Name = info.Name, Enabled = true, Price = info.Price, Theme = info.Theme, Tagline = info.Tagline,
		-- on a huge ring far from World 1 and from each other (~9000 studs apart), so no
		-- island can see another one
		Origin = Vector3.new(math.cos(math.rad(i * 45)) * 12000, 0, math.sin(math.rad(i * 45)) * 12000),
		PitRadius = 41, CenterNoDigRadius = 0, HubPaths = false,
		IslandRadius = 125, -- floating island around the pit (built by WorldBuilder)
		TopMaterial = info.Top, WallMaterial = info.Wall,
		Look = info.Look, Sky = info.Sky,
		Zones = zones(zoneList),
		Shovels = shovels,
	})
end

GameConfig.BedrockThickness = 8

-- Crater size: every point of Power adds half a stud to the radius of the hole a swing digs
function GameConfig.DigRadiusForPower(power)
	return 3.5 + 0.5 * power
end

-- Every shovel from every world, in one list (ids must be unique across worlds)
GameConfig.Shovels = {}
local shovelById = {}
for _, world in ipairs(GameConfig.Worlds) do
	for _, shovel in ipairs(world.Shovels) do
		shovel.World = world.Id
		shovel.DigRadius = GameConfig.DigRadiusForPower(shovel.Power)
		table.insert(GameConfig.Shovels, shovel)
		shovelById[shovel.Id] = shovel
	end
end

function GameConfig.GetShovel(shovelId)
	return shovelById[shovelId]
end

function GameConfig.GetWorld(worldId)
	return GameConfig.Worlds[worldId]
end

-- The starter (free) shovel of a world
function GameConfig.GetStarterShovel(world)
	return world.Shovels[1]
end

-- Which world is this position in? (the nearest world origin)
function GameConfig.GetWorldAt(position)
	local best, bestDistance = GameConfig.Worlds[1], math.huge
	for _, world in ipairs(GameConfig.Worlds) do
		local offset = position - world.Origin
		local distance = Vector3.new(offset.X, 0, offset.Z).Magnitude
		if distance < bestDistance then
			best, bestDistance = world, distance
		end
	end
	return best
end

-- Returns the zone index and zone at a height in a world, or nil if it's bedrock
function GameConfig.GetZoneAt(world, y)
	local depth = world.Origin.Y - y
	for i, zone in ipairs(world.Zones) do
		local top = (i == 1) and -math.huge or -zone.Top
		if depth >= top and depth < -zone.Bottom then
			return i, zone
		end
	end
	return nil, nil
end

-- The cheapest shovel in a world that can break into a zone
function GameConfig.GetFirstShovelForZone(world, zoneIndex)
	for _, shovel in ipairs(world.Shovels) do
		if shovel.MaxZone >= zoneIndex then
			return shovel
		end
	end
	return nil
end

-- Fills a world's dig site with terrain: ground around, the 4 zones in the pit, bedrock below.
-- Used on server start and every pit reset.
function GameConfig.FillDigTerrain(terrain, world)
	local origin = world.Origin
	local radius = world.PitRadius + 2
	local top = origin.Y
	local lastZone = world.Zones[#world.Zones]
	local bottom = top + lastZone.Bottom - GameConfig.BedrockThickness
	local depth = top - bottom
	local wall = Enum.Material[world.WallMaterial or "Slate"]
	local surface = Enum.Material[world.TopMaterial or "Grass"]
	if world.IslandRadius then
		-- floating island worlds: only the column around the pit gets refilled
		-- (WorldBuilder shapes the rest of the island once)
		local column = world.PitRadius + 12
		terrain:FillCylinder(CFrame.new(origin + Vector3.new(0, 8, 0)), 16, column, Enum.Material.Air)
		terrain:FillCylinder(CFrame.new(origin + Vector3.new(0, -depth / 2, 0)), depth, column, wall)
		terrain:FillCylinder(CFrame.new(origin + Vector3.new(0, -2, 0)), 4, column, surface)
	else
		-- clear anything above ground level (terrain works in 4-stud blocks)
		terrain:FillBlock(CFrame.new(origin + Vector3.new(0, 8, 0)), Vector3.new(200, 16, 200), Enum.Material.Air)
		-- stone ground around the pit (and under it), with a grassy top layer
		terrain:FillBlock(CFrame.new(origin + Vector3.new(0, -depth / 2, 0)), Vector3.new(200, depth, 200), wall)
		terrain:FillBlock(CFrame.new(origin + Vector3.new(0, -2, 0)), Vector3.new(200, 4, 200), surface)
	end
	if world.HubPaths then
		-- keep the walkways clear (otherwise the stone pokes through them)
		for k = 0, 5 do
			local a = math.rad(k * 60)
			local dir = Vector3.new(math.cos(a), 0, math.sin(a))
			local mid = origin + dir * 88
			terrain:FillBlock(CFrame.lookAt(mid, mid + dir) * CFrame.new(0, 4, 0), Vector3.new(14, 16, 84), Enum.Material.Air)
		end
	end
	-- the 4 depth zones
	for _, zone in ipairs(world.Zones) do
		local height = zone.Top - zone.Bottom
		terrain:FillCylinder(CFrame.new(origin + Vector3.new(0, zone.Bottom + height / 2, 0)), height, radius, Enum.Material[zone.Material])
	end
	-- bedrock
	terrain:FillCylinder(CFrame.new(origin + Vector3.new(0, lastZone.Bottom - GameConfig.BedrockThickness / 2, 0)),
		GameConfig.BedrockThickness, radius, Enum.Material.Basalt)
end

return GameConfig
]=])
install(game:GetService("ReplicatedStorage"), "PickaxeModels", "ModuleScript", [=[
-- PickaxeModels (ModuleScript in ReplicatedStorage)
-- Builds every digging tool as a blocky voxel pickaxe: a head made of little cubes that arc
-- out to both sides (two-tone rows, pixel shading), a diamond socket with a glowing gem in the
-- middle, a dark handle with diamond gem nodes, an optional diamond cage around a floating
-- gem, a wrapped grip and a gem pommel.
--
-- Every pickaxe is unique: its own colors and a head shape
--   Crescent  classic curved pick          Wide    long, flat, three rows deep
--   Spiked    crescent with spikes         Crystal glassy shards over a glowing core
--   Hammer    a pick on one side, a chunky hammer on the other
-- and it gets fancier with its Power (tier 1-9): bigger, glowing gems, more gem nodes, the
-- cage, sparkling particles, and orbiting cubes (spun by ShovelClient / ShovelSpinner through
-- the OrbitCenter / OrbitSpeed attributes).
--
-- Tool space: the handle runs along Z, the head is at -Z, the grip end at +Z; +Y is the
-- direction the pick's arms point (the swing plane). Returns function(def) -> Tool.

local SCALE = 0.7

local function rgb(r, g, b)
	return Color3.fromRGB(r, g, b)
end

---------------------------------------------------------------------
-- LOOKS: World 1's pickaxes by id (ids are the old save ids, so nobody loses a tool)
-- Main/Edge = the two rows of the head, Frame = sockets, Gem = gems, Handle, Wrap = grip
---------------------------------------------------------------------
local LOOKS = {
	RustyShovel = {Head = "Crescent", Main = rgb(150, 96, 62), Edge = rgb(112, 70, 46), Frame = rgb(120, 110, 104), Gem = rgb(255, 150, 70), Handle = rgb(84, 58, 40), Wrap = rgb(150, 150, 156)},
	PlasticShovel = {Head = "Wide", Main = rgb(150, 156, 160), Edge = rgb(104, 110, 116), Frame = rgb(132, 136, 142), Gem = rgb(235, 240, 250), Handle = rgb(70, 52, 40), Wrap = rgb(196, 110, 60)},
	GardenSpade = {Head = "Crescent", Main = rgb(214, 124, 72), Edge = rgb(170, 86, 50), Frame = rgb(190, 150, 110), Gem = rgb(70, 230, 210), Handle = rgb(60, 42, 34), Wrap = rgb(90, 190, 170)},
	IronShovel = {Head = "Spiked", Main = rgb(196, 200, 210), Edge = rgb(140, 146, 160), Frame = rgb(170, 174, 184), Gem = rgb(255, 70, 90), Handle = rgb(48, 40, 38), Wrap = rgb(150, 40, 50)},
	SteelSpade = {Head = "Crescent", Main = rgb(150, 160, 156), Edge = rgb(110, 200, 60), Frame = rgb(150, 160, 156), Gem = rgb(60, 255, 120), Handle = rgb(56, 36, 36), Wrap = rgb(214, 120, 80)},
	GoldenShovel = {Head = "Hammer", Main = rgb(255, 208, 72), Edge = rgb(226, 158, 40), Frame = rgb(255, 224, 140), Gem = rgb(255, 60, 110), Handle = rgb(60, 40, 30), Wrap = rgb(150, 30, 50)},
	GamerShovel = {Head = "Crystal", Main = rgb(110, 230, 255), Edge = rgb(180, 246, 255), Frame = rgb(170, 240, 255), Gem = rgb(90, 220, 255), Handle = rgb(40, 44, 64), Wrap = rgb(70, 80, 110)},
	TectonicAuger = {Head = "Spiked", Main = rgb(64, 62, 74), Edge = rgb(255, 120, 40), Frame = rgb(90, 88, 100), Gem = rgb(255, 140, 50), Handle = rgb(30, 28, 34), Wrap = rgb(255, 120, 40)},
	SingularitySpade = {Head = "Crystal", Main = rgb(58, 34, 96), Edge = rgb(190, 120, 255), Frame = rgb(90, 70, 140), Gem = rgb(235, 220, 255), Handle = rgb(20, 16, 30), Wrap = rgb(150, 90, 255)},
}
-- worlds 2-9: head shape per tier, colors from the world's theme
local WORLD_HEADS = {"Crescent", "Wide", "Spiked", "Crescent", "Crystal", "Hammer", "Crystal"}

local function lookFor(def)
	if LOOKS[def.Id] then return LOOKS[def.Id] end
	local look = def.Look
	if look and look.Colors then
		local c = look.Colors
		return {
			Head = look.Head or WORLD_HEADS[look.Tier] or "Crescent",
			Main = c.Main, Edge = look.Tier % 2 == 0 and c.Accent or c.Second,
			Frame = c.Second:Lerp(rgb(170, 170, 180), 0.4), Gem = c.Glow,
			Handle = c.Dark:Lerp(rgb(30, 28, 36), 0.4), Wrap = c.Accent,
		}
	end
	return LOOKS.RustyShovel
end

---------------------------------------------------------------------
-- BUILDING BLOCKS
---------------------------------------------------------------------
local function newPart(tool, name, size, cf, color, material, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	if shape then p.Shape = shape end
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Massless = true
	p.CastShadow = p.Material ~= Enum.Material.Neon
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = tool
	return p
end

-- pixel shading: a voxel is a touch lighter or darker than its neighbours
local function shade(color, i)
	local k = ({0, 0.1, -0.1, 0.05})[i % 4 + 1]
	if k > 0 then return color:Lerp(Color3.new(1, 1, 1), k) end
	return color:Lerp(Color3.new(0, 0, 0), -k)
end

local DIAMOND = CFrame.Angles(math.rad(45), 0, 0) -- a cube seen along X becomes a diamond

-- a diamond frame with a glowing gem poking through both faces
local function gemNode(tool, name, z, size, look, glowing)
	local frame = newPart(tool, name, Vector3.new(size * 0.8, size, size), CFrame.new(0, 0, z) * DIAMOND, look.Frame)
	newPart(tool, name .. "Gem", Vector3.new(size * 0.96, size * 0.46, size * 0.46), CFrame.new(0, 0, z) * DIAMOND,
		look.Gem, glowing and Enum.Material.Neon or Enum.Material.Glass)
	return frame
end

local function bar(tool, name, a, b, thickness, color, material)
	local length = (b - a).Magnitude
	-- a CFrame whose Z axis runs from a to b (built from its axes, so it's exact in any direction)
	local z = (a - b).Unit
	local helper = math.abs(z.X) < 0.9 and Vector3.xAxis or Vector3.yAxis
	local y = z:Cross(helper).Unit
	local x = y:Cross(z)
	return newPart(tool, name, Vector3.new(thickness, thickness, length), CFrame.fromMatrix((a + b) / 2, x, y, z), color, material)
end

-- one arm of the head: voxels along an arc that starts at the socket and bends toward the grip
-- side = +1 / -1 (which way along Y), rows = how many layers deep
local function arm(tool, H, side, look, opts)
	local R, reach, count, rows = opts.Radius, opts.Reach, opts.Count, opts.Rows
	local center = H + Vector3.new(0, 0, R)
	local parts = {}
	for i = 1, count do
		local t = (i - 0.3) / count
		local phi = 0.22 + t * reach
		local size = opts.Size * (1 - t * 0.5)
		local radial = Vector3.new(0, side * math.sin(phi), -math.cos(phi))
		local rot = CFrame.Angles(side * phi, 0, 0)
		for row = 0, rows - 1 do
			local r = R + (row - (rows - 1) / 2) * size * 0.85
			local pos = center + radial * r
			local color = (row == rows - 1) and look.Edge or look.Main
			local material = opts.Material or Enum.Material.SmoothPlastic
			local voxel = newPart(tool, row == rows - 1 and "HeadEdge" or "HeadVoxel", Vector3.new(size * 0.9, size, size), CFrame.new(pos) * rot, shade(color, i + row), material)
			if opts.Glass then
				voxel.Transparency = 0.15
				voxel.Reflectance = 0.2
			end
			table.insert(parts, voxel)
		end
		-- spikes sticking out of the outer row
		if opts.Spikes and i % 2 == 0 then
			local pos = center + radial * (R + size * 1.2)
			newPart(tool, "HeadSpike", Vector3.new(size * 0.5, size * 0.5, size * 0.8), CFrame.new(pos) * rot, look.Edge)
		end
	end
	-- the pointed tip
	local phiEnd = 0.22 + reach + 0.12
	local tipPos = center + Vector3.new(0, side * math.sin(phiEnd), -math.cos(phiEnd)) * R
	newPart(tool, "HeadTip", Vector3.new(opts.Size * 0.36, opts.Size * 0.4, opts.Size * 0.4), CFrame.new(tipPos) * CFrame.Angles(side * phiEnd, 0, 0) * DIAMOND, look.Edge)
	return parts
end

-- a chunky hammer block made of voxels (the other side of a "Hammer" head)
local function hammer(tool, H, side, look)
	local v = 0.5
	for y = 1, 3 do
		for z = -1, 1 do
			local pos = H + Vector3.new(0, side * (0.45 + y * v * 0.95), z * v * 0.95)
			local edge = y == 3 or math.abs(z) == 1
			newPart(tool, "HammerVoxel", Vector3.new(v * 1.7, v, v), CFrame.new(pos), shade(edge and look.Edge or look.Main, y + z))
		end
	end
	newPart(tool, "HammerFace", Vector3.new(v * 1.8, 0.12, v * 3), CFrame.new(H + Vector3.new(0, side * (0.45 + 3.55 * v), 0)), look.Frame, Enum.Material.Metal)
end

---------------------------------------------------------------------
-- BUILD A PICKAXE TOOL
---------------------------------------------------------------------
return function(def)
	local look = lookFor(def)
	local tier = math.clamp(def.Power or 1, 1, 12)
	local growth = 1 + (tier - 1) * 0.035
	local glowing = tier >= 2

	local tool = Instance.new("Tool")
	tool.Name = def.Name
	tool.ToolTip = def.Name
	tool.CanBeDropped = false
	tool.RequiresHandle = true
	tool:SetAttribute("ShovelId", def.Id)

	-- invisible handle the hand holds; everything else is welded to it
	local handle = newPart(tool, "Handle", Vector3.new(0.3, 0.3, 4.6), CFrame.new(), look.Handle)
	handle.Transparency = 1

	-- HANDLE: a square dark shaft from the head down to the pommel
	local HEAD_Z, END_Z = -2.6, 2.2
	local RIGHT_Z, LEFT_Z = 1.55, 0.55 -- where the hands hold it (right hand low, left hand above)
	newPart(tool, "Shaft", Vector3.new(0.26, 0.26, END_Z - HEAD_Z), CFrame.new(0, 0, (END_Z + HEAD_Z) / 2), look.Handle)
	-- grip wrap: stacked cubes, alternating shades
	for i = 0, 4 do
		newPart(tool, "GripWrap", Vector3.new(0.34, 0.34, 0.24), CFrame.new(0, 0, 1.05 + i * 0.24), shade(look.Wrap, i))
	end
	for _, z in ipairs({0.88, 2.28 - 0.1}) do
		newPart(tool, "Collar", Vector3.new(0.4, 0.4, 0.14), CFrame.new(0, 0, z), look.Frame, Enum.Material.Metal)
	end
	gemNode(tool, "Pommel", END_Z + 0.25, 0.62, look, glowing)
	-- gem nodes up the handle (more on better pickaxes)
	local nodes = tier >= 7 and {-1.75, -0.1} or (tier >= 3 and {-1.6} or {})
	for _, z in ipairs(nodes) do
		gemNode(tool, "HandleNode", z, 0.5, look, glowing)
	end
	-- the diamond cage with a floating gem (tier 4+)
	if tier >= 4 then
		local top, bottom, mid, w = -1.35, -0.35, -0.85, 0.42
		local a, b2 = Vector3.new(0, 0, top), Vector3.new(0, 0, bottom)
		for _, s in ipairs({-1, 1}) do
			local side = Vector3.new(0, s * w, mid)
			bar(tool, "CageBar", a, side, 0.12, look.Handle)
			bar(tool, "CageBar", side, b2, 0.12, look.Handle)
		end
		newPart(tool, "CageGem", Vector3.new(0.3, 0.34, 0.34), CFrame.new(0, 0, mid) * DIAMOND, look.Gem, Enum.Material.Neon)
	end

	-- HEAD
	local H = Vector3.new(0, 0, HEAD_Z)
	local socket = newPart(tool, "Blade", Vector3.new(0.72, 1, 1), CFrame.new(H) * DIAMOND, look.Frame)
	local gem = newPart(tool, "HeadGem", Vector3.new(0.86, 0.5, 0.5), CFrame.new(H) * DIAMOND, look.Gem, glowing and Enum.Material.Neon or Enum.Material.Glass)
	newPart(tool, "Crown", Vector3.new(0.4, 0.42, 0.42), CFrame.new(H + Vector3.new(0, 0, -0.78)) * DIAMOND, look.Edge)
	local style = look.Head
	if style == "Wide" then
		for _, s in ipairs({-1, 1}) do
			arm(tool, H, s, look, {Radius = 3.4, Reach = 0.62, Count = 8, Rows = 3, Size = 0.58})
		end
	elseif style == "Spiked" then
		for _, s in ipairs({-1, 1}) do
			arm(tool, H, s, look, {Radius = 2.3, Reach = 1.1, Count = 7, Rows = 2, Size = 0.66, Spikes = true})
		end
	elseif style == "Crystal" then
		for _, s in ipairs({-1, 1}) do
			arm(tool, H, s, look, {Radius = 2.4, Reach = 1.05, Count = 7, Rows = 3, Size = 0.6, Glass = true, Material = Enum.Material.Glass})
			-- glowing core running inside the glass
			arm(tool, H, s, {Main = look.Gem, Edge = look.Gem}, {Radius = 2.4, Reach = 0.95, Count = 6, Rows = 1, Size = 0.3, Material = Enum.Material.Neon})
		end
	elseif style == "Hammer" then
		arm(tool, H, 1, look, {Radius = 2.3, Reach = 1.15, Count = 7, Rows = 2, Size = 0.66})
		hammer(tool, H, -1, look)
	else -- Crescent
		for _, s in ipairs({-1, 1}) do
			arm(tool, H, s, look, {Radius = 2.3, Reach = 1.15, Count = 7, Rows = tier >= 5 and 3 or 2, Size = 0.66})
		end
	end
	-- side plates that hold the head on the shaft
	for _, s in ipairs({-1, 1}) do
		newPart(tool, "HeadBracket", Vector3.new(0.5, 0.3, 0.7), CFrame.new(H + Vector3.new(0, s * 0.42, 0.55)), look.Handle)
	end

	-- ORBITING CUBES around the handle below the head (tier 6+), spun by the client
	if tier >= 6 then
		local center = Vector3.new(0, 0, -1.9)
		local n = tier - 3
		for i = 1, n do
			local a = math.pi * 2 * i / n
			local cube = newPart(tool, "OrbitCube", Vector3.new(0.2, 0.2, 0.2), CFrame.new(center + Vector3.new(math.cos(a) * 0.62, math.sin(a) * 0.62, 0)) * CFrame.Angles(0.6, 0.6, 0), look.Gem, Enum.Material.Neon)
			cube:SetAttribute("OrbitCenter", center)
			cube:SetAttribute("OrbitSpeed", 2.6)
		end
	end

	-- VFX: gem light and sparkles that grow with the tier
	if glowing then
		local light = Instance.new("PointLight")
		light.Color = look.Gem
		light.Range = 4 + tier
		light.Brightness = 0.35 + tier * 0.1
		light.Parent = gem
		local sparkle = Instance.new("ParticleEmitter")
		sparkle.Name = "GemSparkle"
		sparkle.Rate = tier * 2.5
		sparkle.LightEmission = math.min(0.2 + tier * 0.09, 1)
		sparkle.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.06 + tier * 0.025), NumberSequenceKeypoint.new(1, 0)})
		sparkle.Lifetime = NumberRange.new(0.4, 0.8 + tier * 0.05)
		sparkle.Speed = NumberRange.new(0.3, 0.8 + tier * 0.1)
		sparkle.SpreadAngle = Vector2.new(180, 180)
		sparkle.Color = ColorSequence.new(look.Gem:Lerp(Color3.new(1, 1, 1), 0.4), look.Gem)
		sparkle.Transparency = NumberSequence.new(0.1, 1)
		sparkle.Parent = socket
	end

	-- SIZE: better pickaxes are a little bigger, then everything is scaled to character size
	local s = SCALE * growth
	for _, part in ipairs(tool:GetChildren()) do
		if part:IsA("BasePart") then
			local rotation = part.CFrame.Rotation
			part.Size = part.Size * s
			part.CFrame = CFrame.new(part.Position * s) * rotation
			local center = part:GetAttribute("OrbitCenter")
			if center then part:SetAttribute("OrbitCenter", center * s) end
		end
	end
	for _, emitter in ipairs(tool:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			local keys = {}
			for _, key in ipairs(emitter.Size.Keypoints) do
				table.insert(keys, NumberSequenceKeypoint.new(key.Time, key.Value * s, key.Envelope * s))
			end
			emitter.Size = NumberSequence.new(keys)
		end
	end

	-- how Roblox holds it if the two-handed pose can't run (e.g. R6 bodies)
	tool.Grip = CFrame.new(0, 0, RIGHT_Z * s) * CFrame.Angles(math.rad(-30), 0, 0)
	-- ShovelClient's two-handed pose: where each hand grips the handle (along Z)
	tool:SetAttribute("RightHoldZ", RIGHT_Z * s)
	tool:SetAttribute("LeftHoldZ", LEFT_Z * s)
	tool:SetAttribute("TopHoldZ", RIGHT_Z * s)
	tool:SetAttribute("LowHoldZ", LEFT_Z * s)

	for _, part in ipairs(tool:GetChildren()) do
		if part:IsA("BasePart") and part ~= handle then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = handle
			weld.Part1 = part
			weld.Parent = handle
		end
	end
	return tool
end
]=])
install(game:GetService("ReplicatedStorage"), "UIKit", "ModuleScript", [=[
-- UIKit (ModuleScript in ReplicatedStorage)
-- One cartoony 2050 look for every screen in the game:
--   * rounded panels with a soft top-to-bottom sheen; colored panels get an outline in a
--     darker shade of their own color (no more black outlines everywhere)
--   * glossy "candy" buttons with a darker bottom lip, white bubbly text and a bounce
--   * windows with a full-width colored header bar, an icon, and the close button inside it
--   * text that scales with its box but never past a sensible size (so nothing looks huge)
--   * live 3D pickaxe icons (ViewportFrames that render the real pickaxe model)

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIKit = {}

local rgb = Color3.fromRGB
UIKit.Colors = {
	Ink = rgb(40, 32, 92),        -- dark text and window outlines
	Panel = rgb(252, 251, 255),   -- window background
	PanelTint = rgb(236, 231, 255),
	Row = rgb(246, 243, 255),     -- cards inside windows
	Violet = rgb(128, 90, 255),
	Lilac = rgb(184, 164, 255),
	Sky = rgb(58, 168, 255),
	Mint = rgb(38, 206, 140),
	Sun = rgb(255, 188, 40),
	Coral = rgb(255, 84, 112),
	Grey = rgb(128, 122, 162),    -- secondary text
	White = rgb(255, 255, 255),
	Money = rgb(46, 196, 90),
}
local C = UIKit.Colors
UIKit.Font = Enum.Font.FredokaOne
UIKit.BodyFont = Enum.Font.GothamMedium

-- a darker (amount > 0) or lighter (amount < 0) version of a color
function UIKit.shadeColor(color, amount)
	if amount >= 0 then
		return color:Lerp(Color3.new(0.1, 0.07, 0.25), amount)
	end
	return color:Lerp(Color3.new(1, 1, 1), -amount)
end
local function luminance(c)
	return 0.299 * c.R + 0.587 * c.G + 0.114 * c.B
end
-- outline that suits a background: soft lavender around light panels, a deep shade of the
-- color itself around colored ones
local function autoOutline(color)
	if luminance(color) > 0.86 then
		return rgb(208, 198, 246)
	end
	return UIKit.shadeColor(color, 0.5)
end
UIKit.autoOutline = autoOutline

---------------------------------------------------------------------
-- BASICS
---------------------------------------------------------------------
function UIKit.screen(player, name, order)
	local gui = Instance.new("ScreenGui")
	gui.Name = name
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = order or 0
	gui.Parent = player:WaitForChild("PlayerGui")
	return gui
end

function UIKit.corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 14)
	c.Parent = parent
	return c
end

function UIKit.outline(parent, thickness, color)
	local s = Instance.new("UIStroke")
	s.Color = color or C.Ink
	s.Thickness = thickness or 3
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.LineJoinMode = Enum.LineJoinMode.Round
	s.Parent = parent
	return s
end

-- soft top-to-bottom sheen so flat panels look chunky
function UIKit.shade(parent, amount)
	amount = amount or 0.1
	local g = Instance.new("UIGradient")
	g.Rotation = 90
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(0.5, Color3.new(1 - amount * 0.35, 1 - amount * 0.35, 1 - amount * 0.3)),
		ColorSequenceKeypoint.new(1, Color3.new(1 - amount, 1 - amount, 1 - amount * 0.8)),
	})
	g.Parent = parent
	return g
end

-- A rounded box. props: Size, Position, AnchorPoint, Color, Radius, Transparency,
-- Stroke (thickness or false), StrokeColor (default: matches the color), Shade (false for flat)
function UIKit.panel(parent, props)
	local f = Instance.new("Frame")
	f.Size = props.Size or UDim2.fromOffset(200, 100)
	f.Position = props.Position or UDim2.new()
	f.AnchorPoint = props.AnchorPoint or Vector2.zero
	f.BackgroundColor3 = props.Color or C.Panel
	f.BackgroundTransparency = props.Transparency or 0
	f.BorderSizePixel = 0
	f.Parent = parent
	UIKit.corner(f, props.Radius or 16)
	if props.Stroke ~= false then
		local stroke = UIKit.outline(f, props.Stroke or 2.5, props.StrokeColor or autoOutline(f.BackgroundColor3))
		if not props.StrokeColor then
			-- keep the outline matching when the color changes later (rarity tags etc.)
			f:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				stroke.Color = autoOutline(f.BackgroundColor3)
			end)
		end
	end
	if props.Shade ~= false then
		UIKit.shade(f, props.ShadeAmount)
	end
	return f
end

-- Bubbly text. props: Size, Position, AnchorPoint, Color, Align ("Left"/"Center"/"Right"),
-- VAlign, Stroke (outline thickness, 0 for none), StrokeColor, Font,
-- TextSize (fixed size) or MaxText (largest size scaled text may grow to, default 30)
function UIKit.label(parent, text, props)
	props = props or {}
	local l = Instance.new("TextLabel")
	l.Size = props.Size or UDim2.fromScale(1, 1)
	l.Position = props.Position or UDim2.new()
	l.AnchorPoint = props.AnchorPoint or Vector2.zero
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = props.Color or C.White
	l.Font = props.Font or UIKit.Font
	if props.TextSize then
		l.TextSize = props.TextSize
		l.TextWrapped = true
	else
		l.TextScaled = true
		local limit = Instance.new("UITextSizeConstraint")
		limit.MaxTextSize = props.MaxText or 30
		limit.MinTextSize = 6
		limit.Parent = l
	end
	l.TextXAlignment = Enum.TextXAlignment[props.Align or "Center"]
	l.TextYAlignment = Enum.TextYAlignment[props.VAlign or "Center"]
	l.RichText = props.RichText or false
	l.Parent = parent
	local strokeSize = props.Stroke == nil and 2 or props.Stroke
	if strokeSize > 0 then
		local s = Instance.new("UIStroke")
		s.Color = props.StrokeColor or C.Ink
		s.Thickness = strokeSize
		s.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
		s.Parent = l
	end
	return l
end

-- A glossy candy button that squishes when pressed and grows a bit on hover.
-- props: Size, Position, AnchorPoint, Color, TextColor, Radius, MaxText
-- Changing the button's BackgroundColor3 later recolors the whole button.
function UIKit.button(parent, text, props)
	props = props or {}
	local b = Instance.new("TextButton")
	b.Size = props.Size or UDim2.fromOffset(140, 44)
	b.Position = props.Position or UDim2.new()
	b.AnchorPoint = props.AnchorPoint or Vector2.zero
	b.BackgroundColor3 = props.Color or C.Mint
	b.AutoButtonColor = false
	b.Text = ""
	b.Parent = parent
	local radius = props.Radius or 14
	UIKit.corner(b, radius)
	local stroke = UIKit.outline(b, 2.5)
	local gloss = Instance.new("UIGradient")
	gloss.Rotation = 90
	gloss.Parent = b
	-- darker bottom lip, like the edge of a chunky key
	local lip = Instance.new("Frame")
	lip.Name = "Lip"
	lip.BorderSizePixel = 0
	lip.AnchorPoint = Vector2.new(0, 1)
	lip.Position = UDim2.fromScale(0, 1)
	lip.Size = UDim2.new(1, 0, 0, math.min(radius, 7))
	lip.Parent = b
	UIKit.corner(lip, radius)
	local shine = Instance.new("Frame")
	shine.Name = "Shine"
	shine.BorderSizePixel = 0
	shine.BackgroundColor3 = Color3.new(1, 1, 1)
	shine.BackgroundTransparency = 0.72
	shine.Position = UDim2.new(0, 6, 0, 4)
	shine.Size = UDim2.new(1, -12, 0.3, 0)
	shine.Parent = b
	UIKit.corner(shine, math.max(radius - 4, 4))
	local label = UIKit.label(b, text, {
		Size = UDim2.new(1, -16, 1, -14), Position = UDim2.new(0.5, 0, 0.5, -2), AnchorPoint = Vector2.new(0.5, 0.5),
		Color = props.TextColor or C.White, Stroke = 2.5, MaxText = props.MaxText or 24,
	})
	label.Name = "Label"
	local labelStroke = label:FindFirstChildOfClass("UIStroke")

	local function paint()
		local c = b.BackgroundColor3
		stroke.Color = UIKit.shadeColor(c, 0.5)
		lip.BackgroundColor3 = UIKit.shadeColor(c, 0.28)
		gloss.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(0.86, 0.86, 0.9))
		if labelStroke then labelStroke.Color = UIKit.shadeColor(c, 0.62) end
	end
	paint()
	b:GetPropertyChangedSignal("BackgroundColor3"):Connect(paint)

	local scale = Instance.new("UIScale")
	scale.Parent = b
	local function to(v, t)
		TweenService:Create(scale, TweenInfo.new(t or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = v}):Play()
	end
	b.MouseEnter:Connect(function() to(1.05) end)
	b.MouseLeave:Connect(function() to(1) end)
	b.MouseButton1Down:Connect(function() to(0.92, 0.06) end)
	b.MouseButton1Up:Connect(function() to(1.05) end)
	return b, label
end

function UIKit.setButton(button, text, color)
	button.BackgroundColor3 = color
	local label = button:FindFirstChild("Label")
	if label then label.Text = text end
end

-- Pops a frame in with a bouncy scale
function UIKit.pop(frame, from)
	local scale = frame:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	scale.Parent = frame
	scale.Scale = from or 0.6
	TweenService:Create(scale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
end

-- A round colored badge with an emoji (or short text) in it
function UIKit.badge(parent, iconText, color, props)
	props = props or {}
	local d = props.Diameter or 44
	local circle = UIKit.panel(parent, {Size = UDim2.fromOffset(d, d), Position = props.Position, AnchorPoint = props.AnchorPoint,
		Color = color, Radius = d, Stroke = props.Stroke or 2.5})
	local icon = UIKit.label(circle, iconText, {Size = UDim2.fromScale(0.64, 0.64), Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5), Stroke = props.TextStroke or 0, MaxText = 60, Font = props.Font or Enum.Font.GothamBlack})
	icon.Name = "Icon"
	return circle, icon
end

---------------------------------------------------------------------
-- WINDOW: a panel with a colored header bar (icon + title + close button) and a body.
-- returns window, content (frame to put things in), closeButton
---------------------------------------------------------------------
local HEADER = 58
function UIKit.window(gui, title, size, accent, icon)
	accent = accent or C.Violet
	local window = UIKit.panel(gui, {
		Size = size, Position = UDim2.fromScale(0.5, 0.52), AnchorPoint = Vector2.new(0.5, 0.5),
		Color = C.Panel, Radius = 24, Stroke = 4, StrokeColor = C.Ink, ShadeAmount = 0.05,
	})
	window.Visible = false
	local sizeLimit = Instance.new("UISizeConstraint")
	sizeLimit.MaxSize = Vector2.new(size.X.Offset, size.Y.Offset)
	sizeLimit.Parent = window
	local aspect = Instance.new("UIAspectRatioConstraint")
	aspect.AspectRatio = size.X.Offset / size.Y.Offset
	aspect.Parent = window
	window.Size = UDim2.fromScale(0.92, 0.85)

	-- header bar: rounded on top, square where it meets the body
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.BorderSizePixel = 0
	header.BackgroundColor3 = accent
	header.Size = UDim2.new(1, 0, 0, HEADER)
	header.Parent = window
	UIKit.corner(header, 22)
	local headerFill = Instance.new("Frame")
	headerFill.BorderSizePixel = 0
	headerFill.BackgroundColor3 = accent
	headerFill.AnchorPoint = Vector2.new(0, 1)
	headerFill.Position = UDim2.fromScale(0, 1)
	headerFill.Size = UDim2.new(1, 0, 0, 22)
	headerFill.Parent = header
	local headerEdge = Instance.new("Frame")
	headerEdge.BorderSizePixel = 0
	headerEdge.BackgroundColor3 = UIKit.shadeColor(accent, 0.35)
	headerEdge.AnchorPoint = Vector2.new(0, 1)
	headerEdge.Position = UDim2.fromScale(0, 1)
	headerEdge.Size = UDim2.new(1, 0, 0, 4)
	headerEdge.Parent = header
	local shine = Instance.new("Frame")
	shine.BorderSizePixel = 0
	shine.BackgroundColor3 = Color3.new(1, 1, 1)
	shine.BackgroundTransparency = 0.8
	shine.Position = UDim2.new(0, 10, 0, 6)
	shine.Size = UDim2.new(1, -20, 0, 16)
	shine.Parent = header
	UIKit.corner(shine, 8)

	local titleX = 22
	if icon then
		UIKit.badge(header, icon, UIKit.shadeColor(accent, -0.25), {Diameter = 40, Position = UDim2.new(0, 14, 0.5, -2), AnchorPoint = Vector2.new(0, 0.5)})
		titleX = 64
	end
	local titleLabel = UIKit.label(header, title, {Size = UDim2.new(1, -titleX - 70, 0, 34), Position = UDim2.new(0, titleX, 0.5, -2), AnchorPoint = Vector2.new(0, 0.5),
		Align = "Left", Stroke = 3, StrokeColor = UIKit.shadeColor(accent, 0.6), MaxText = 30})
	titleLabel.Name = "Title"

	local close = UIKit.button(header, "X", {
		Size = UDim2.fromOffset(42, 42), Position = UDim2.new(1, -10, 0.5, -2), AnchorPoint = Vector2.new(1, 0.5), Color = C.Coral, Radius = 14, MaxText = 22,
	})
	close.MouseButton1Click:Connect(function()
		window.Visible = false
	end)

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundTransparency = 1
	content.Size = UDim2.new(1, -36, 1, -HEADER - 30)
	content.Position = UDim2.new(0, 18, 0, HEADER + 14)
	content.Parent = window
	return window, content, close
end

function UIKit.open(window)
	window.Visible = true
	UIKit.pop(window, 0.8)
end

-- Scrolling list with padding. returns the scrolling frame
function UIKit.list(parent, padding)
	local list = Instance.new("ScrollingFrame")
	list.Size = UDim2.fromScale(1, 1)
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.ScrollBarThickness = 8
	list.ScrollBarImageColor3 = C.Lilac
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new()
	list.Parent = parent
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, padding or 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = list
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 6)
	pad.PaddingBottom = UDim.new(0, 6)
	pad.PaddingRight = UDim.new(0, 10)
	pad.Parent = list
	return list
end

-- A small stat bar: label on the left, filled bar, value on the right
function UIKit.statBar(parent, name, fraction, valueText, color, props)
	local row = Instance.new("Frame")
	row.BackgroundTransparency = 1
	row.Size = props and props.Size or UDim2.new(1, 0, 0, 18)
	row.Position = props and props.Position or UDim2.new()
	row.Parent = parent
	UIKit.label(row, name, {Size = UDim2.new(0.26, 0, 0.9, 0), Position = UDim2.fromScale(0, 0.05), Align = "Left", Color = C.Grey, Stroke = 0, MaxText = 16})
	local track = UIKit.panel(row, {Size = UDim2.new(0.46, 0, 0.62, 0), Position = UDim2.new(0.27, 0, 0.19, 0), Color = rgb(232, 227, 250), Radius = 8, Stroke = false, Shade = false})
	local fill = UIKit.panel(track, {Size = UDim2.new(math.clamp(fraction, 0.06, 1), 0, 1, 0), Color = color, Radius = 8, Stroke = false, ShadeAmount = 0.2})
	fill.Name = "Fill"
	UIKit.label(row, valueText, {Size = UDim2.new(0.25, 0, 0.9, 0), Position = UDim2.new(0.75, 0, 0.05, 0), Align = "Right", Color = C.Ink, Stroke = 0, MaxText = 16})
	return row
end

---------------------------------------------------------------------
-- 3D PICKAXE ICON: renders the real pickaxe model inside a ViewportFrame
---------------------------------------------------------------------
local ShovelModels -- loaded on first use (only needed where icons are drawn)
function UIKit.shovelIcon(parent, def, props)
	props = props or {}
	ShovelModels = ShovelModels or require(ReplicatedStorage:WaitForChild("PickaxeModels"))
	local vp = Instance.new("ViewportFrame")
	vp.Size = props.Size or UDim2.fromOffset(80, 80)
	vp.Position = props.Position or UDim2.new()
	vp.AnchorPoint = props.AnchorPoint or Vector2.zero
	vp.BackgroundTransparency = 1
	vp.Ambient = rgb(200, 198, 215)
	vp.LightColor = rgb(255, 250, 240)
	vp.LightDirection = Vector3.new(-1, -1.5, -1)
	vp.Parent = parent

	-- show the pickaxe diagonally: head at the top-left, grip at the bottom-right, with the
	-- head's arms facing the camera (tool Y/Z in the screen plane) and a slight 3D turn
	local pose = CFrame.Angles(0, math.rad(22), 0) * CFrame.fromMatrix(Vector3.zero, Vector3.new(0, 0, -1), Vector3.new(1, 1, 0).Unit)
	local tool = ShovelModels(def)
	local model = Instance.new("Model")
	local minV, maxV = Vector3.new(math.huge, math.huge, math.huge), -Vector3.new(math.huge, math.huge, math.huge)
	for _, piece in ipairs(tool:GetChildren()) do
		if piece:IsA("BasePart") and piece.Name ~= "Handle" then
			for _, c in ipairs(piece:GetChildren()) do
				if c:IsA("WeldConstraint") or c:IsA("ParticleEmitter") or c:IsA("Light") then c:Destroy() end
			end
			piece.CFrame = pose * piece.CFrame
			local half = piece.Size / 2
			minV = minV:Min(piece.CFrame.Position - Vector3.new(half.Magnitude, half.Magnitude, half.Magnitude) * 0.6)
			maxV = maxV:Max(piece.CFrame.Position + Vector3.new(half.Magnitude, half.Magnitude, half.Magnitude) * 0.6)
			piece.Parent = model
		end
	end
	tool:Destroy()
	model.Parent = vp

	local center = (minV + maxV) / 2
	local extent = (maxV - minV).Magnitude
	local camera = Instance.new("Camera")
	camera.FieldOfView = 30
	camera.CFrame = CFrame.new(center + Vector3.new(0, 0, extent * 1.75), center)
	camera.Parent = vp
	vp.CurrentCamera = camera
	return vp
end

---------------------------------------------------------------------
-- MEME ICON: the artifact's emoji on a tile in its rarity color, with a rarity badge
---------------------------------------------------------------------
local ArtifactData, ArtifactIcons, ArtifactImages -- loaded on first use
local RARITY_SHORT = {Common = "C", Uncommon = "U", Rare = "R", Epic = "E", Legendary = "L",
	Mythic = "M", Divine = "D", Celestial = "CE", Transcendent = "T"}

function UIKit.artifactIcon(parent, artifact, props)
	props = props or {}
	ArtifactData = ArtifactData or require(ReplicatedStorage:WaitForChild("ArtifactData"))
	ArtifactIcons = ArtifactIcons or require(ReplicatedStorage:WaitForChild("ArtifactIcons"))
	ArtifactImages = ArtifactImages or require(ReplicatedStorage:WaitForChild("ArtifactImages"))
	local rarity = ArtifactData.GetRarity(artifact.Rarity)
	local color = rarity and rarity.Color or C.Lilac
	local tile = UIKit.panel(parent, {
		Size = props.Size or UDim2.fromOffset(80, 80), Position = props.Position, AnchorPoint = props.AnchorPoint,
		Color = color:Lerp(C.White, 0.45), Radius = props.Radius or 16, Stroke = props.Stroke or 3, ShadeAmount = 0.25,
	})
	tile.Name = "ArtifactIcon"
	local image = ArtifactImages[artifact.Id]
	if image then
		-- the uploaded meme picture fills the tile (the emoji is only a fallback)
		local picture = Instance.new("ImageLabel")
		picture.Name = "Picture"
		picture.BackgroundTransparency = 1
		picture.Size = UDim2.new(1, -8, 1, -8)
		picture.Position = UDim2.fromScale(0.5, 0.5)
		picture.AnchorPoint = Vector2.new(0.5, 0.5)
		picture.Image = image
		picture.ScaleType = Enum.ScaleType.Crop
		picture.Parent = tile
		UIKit.corner(picture, math.max((props.Radius or 16) - 4, 4))
	end
	-- soft glow disc behind the emoji
	local glow = UIKit.panel(tile, {Size = UDim2.fromScale(0.78, 0.78), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
		Color = C.White, Radius = 999, Stroke = false, Shade = false})
	glow.BackgroundTransparency = 0.45
	glow.Visible = image == nil
	local emoji = Instance.new("TextLabel")
	emoji.Visible = image == nil
	emoji.BackgroundTransparency = 1
	emoji.Size = UDim2.fromScale(0.72, 0.72)
	emoji.Position = UDim2.fromScale(0.5, 0.52)
	emoji.AnchorPoint = Vector2.new(0.5, 0.5)
	emoji.Text = ArtifactIcons[artifact.Id] or "❓"
	emoji.TextScaled = true
	emoji.Font = Enum.Font.GothamBold
	emoji.Parent = tile
	-- rarity badge in the corner (the higher the rarity, the more it stands out)
	if props.Badge ~= false then
		local badge = UIKit.panel(tile, {Size = UDim2.fromScale(0.36, 0.26), Position = UDim2.new(1, 4, 0, -4), AnchorPoint = Vector2.new(1, 0),
			Color = color, Radius = 8, Stroke = 2, Shade = false})
		UIKit.label(badge, RARITY_SHORT[artifact.Rarity] or "?", {Size = UDim2.fromScale(0.8, 0.8), Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2})
	end
	return tile
end

return UIKit
]=])
install(game:GetService("ReplicatedStorage"), "VehicleModels", "ModuleScript", [=[
-- VehicleModels (ModuleScript in ReplicatedStorage)
-- Cartoony 2050 flying vehicles: bubble cars, hover buses, delivery drones and ad blimps.
-- FlyingTraffic (client) builds them and moves them around the city.
-- Every builder returns a Model whose front is -Z and whose PrimaryPart is at its center.

local VehicleModels = {}

local rgb = Color3.fromRGB
local BODY_COLORS = {
	rgb(255, 122, 138), rgb(92, 186, 255), rgb(255, 206, 84), rgb(96, 226, 190),
	rgb(178, 158, 255), rgb(255, 160, 90), rgb(246, 247, 252),
}
local GLOW_COLORS = {rgb(96, 196, 222), rgb(214, 118, 188), rgb(222, 186, 96), rgb(96, 206, 168)}
local WHITE = rgb(246, 247, 252)
local INK = rgb(34, 36, 74)
local GLASS = rgb(168, 228, 255)
local ALONG_Z = CFrame.Angles(0, math.rad(90), 0) -- points a cylinder along Z
local UPRIGHT = CFrame.Angles(0, 0, math.rad(90)) -- stands a cylinder up

local function part(model, name, size, cframe, color, material, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	if shape then p.Shape = shape end
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = model
	return p
end

local function blob(model, name, size, cframe, color, material)
	local p = part(model, name, size, cframe, color, material)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = p
	return p
end

local function ball(model, name, d, cframe, color, material)
	return part(model, name, Vector3.new(d, d, d), cframe, color, material, Enum.PartType.Ball)
end

local function pick(rng, list)
	return list[rng:NextInteger(1, #list)]
end

local function glass(p)
	p.Transparency = 0.3
	p.Reflectance = 0.15
	return p
end

-- Little bubble car: round body, big glass dome, side pods with glowing thrusters
function VehicleModels.car(rng)
	local model = Instance.new("Model")
	model.Name = "BubbleCar"
	local color = pick(rng, BODY_COLORS)
	local glow = pick(rng, GLOW_COLORS)
	local body = blob(model, "Body", Vector3.new(5.4, 2.6, 9), CFrame.new(), color)
	blob(model, "Belly", Vector3.new(5, 1.4, 8.2), CFrame.new(0, -0.7, 0), WHITE)
	glass(blob(model, "Dome", Vector3.new(3.8, 3, 4.4), CFrame.new(0, 1.2, -0.3), GLASS, Enum.Material.Glass))
	part(model, "Seat", Vector3.new(2.6, 0.6, 1.4), CFrame.new(0, 0.6, 0.5), INK)
	for _, side in ipairs({-1, 1}) do
		part(model, "Pod", Vector3.new(4.6, 1.5, 1.5), CFrame.new(side * 2.9, -0.2, 1.4) * ALONG_Z, WHITE, nil, Enum.PartType.Cylinder)
		part(model, "PodGlow", Vector3.new(0.3, 1.2, 1.2), CFrame.new(side * 2.9, -0.2, 3.75) * ALONG_Z, glow, Enum.Material.Neon, Enum.PartType.Cylinder)
		ball(model, "Headlight", 0.8, CFrame.new(side * 1.3, 0, -4.3), rgb(214, 208, 180), Enum.Material.Neon)
	end
	part(model, "TailFin", Vector3.new(0.4, 1.6, 1.8), CFrame.new(0, 1.3, 3.6), color)
	ball(model, "FinTip", 0.6, CFrame.new(0, 2.1, 3.6), glow, Enum.Material.Neon)
	part(model, "Underglow", Vector3.new(3.6, 0.15, 6), CFrame.new(0, -1.35, 0), glow, Enum.Material.Neon)
	model.PrimaryPart = body
	return model
end

-- Hover bus: long capsule with porthole windows and a color stripe
function VehicleModels.bus(rng)
	local model = Instance.new("Model")
	model.Name = "HoverBus"
	local color = pick(rng, BODY_COLORS)
	local glow = pick(rng, GLOW_COLORS)
	local body = part(model, "Body", Vector3.new(16, 5, 5), CFrame.new() * ALONG_Z, WHITE, nil, Enum.PartType.Cylinder)
	ball(model, "Nose", 5, CFrame.new(0, 0, -8), WHITE)
	ball(model, "Tail", 5, CFrame.new(0, 0, 8), color)
	glass(blob(model, "Windshield", Vector3.new(3.8, 2.4, 2), CFrame.new(0, 0.6, -9.6), GLASS, Enum.Material.Glass))
	part(model, "Stripe", Vector3.new(16.2, 1.1, 5.15), CFrame.new(0, -1, 0) * ALONG_Z, color, nil, Enum.PartType.Cylinder)
	for _, side in ipairs({-1, 1}) do
		for k = -2, 2 do
			part(model, "Window", Vector3.new(0.3, 1.5, 1.5), CFrame.new(side * 2.45, 0.8, k * 3), GLASS, Enum.Material.Glass, Enum.PartType.Cylinder)
		end
		part(model, "Thruster", Vector3.new(3, 1.6, 1.6), CFrame.new(side * 2.2, -2.2, 6) * ALONG_Z, color, nil, Enum.PartType.Cylinder)
		part(model, "ThrusterGlow", Vector3.new(0.3, 1.3, 1.3), CFrame.new(side * 2.2, -2.2, 7.6) * ALONG_Z, glow, Enum.Material.Neon, Enum.PartType.Cylinder)
	end
	part(model, "RoofSign", Vector3.new(0.6, 1.2, 6), CFrame.new(0, 2.9, 0), color)
	model.PrimaryPart = body
	return model
end

-- Delivery drone: round body, four rotor rings, a dangling package
function VehicleModels.drone(rng)
	local model = Instance.new("Model")
	model.Name = "DeliveryDrone"
	local color = pick(rng, BODY_COLORS)
	local glow = pick(rng, GLOW_COLORS)
	local body = ball(model, "Body", 2.6, CFrame.new(), WHITE)
	ball(model, "Eye", 1, CFrame.new(0, 0.2, -1.05), INK)
	ball(model, "EyeGlint", 0.35, CFrame.new(0.15, 0.4, -1.5), glow, Enum.Material.Neon)
	for _, x in ipairs({-1, 1}) do
		for _, z in ipairs({-1, 1}) do
			local arm = CFrame.new(x * 2, 0.5, z * 2)
			part(model, "Arm", Vector3.new(0.3, 0.3, 2.4), CFrame.lookAt(Vector3.new(0, 0.5, 0), arm.Position) * CFrame.new(0, 0, -1.4), color)
			part(model, "Rotor", Vector3.new(0.2, 2.2, 2.2), arm * UPRIGHT, color, nil, Enum.PartType.Cylinder)
			part(model, "RotorGlow", Vector3.new(0.1, 2.4, 2.4), arm * CFrame.new(0, -0.1, 0) * UPRIGHT, glow, Enum.Material.Neon, Enum.PartType.Cylinder).Transparency = 0.5
		end
	end
	part(model, "Rope", Vector3.new(0.15, 1.6, 0.15), CFrame.new(0, -2, 0), INK)
	part(model, "Package", Vector3.new(1.8, 1.5, 1.8), CFrame.new(0, -3.4, 0), rgb(214, 160, 100))
	part(model, "PackageTape", Vector3.new(1.85, 0.3, 1.85), CFrame.new(0, -3.1, 0), pick(rng, BODY_COLORS))
	model.PrimaryPart = body
	return model
end

-- Advertising blimp: huge soft balloon with fins, a gondola and a glowing banner
local SLOGANS = {"DIG DEEPER!", "MEMES 4 SALE", "VISIT THE ABYSS", "RATE MY MUSEUM", "PICKAXE SALE 50% OFF", "NO BRAINROT ZONE"}
function VehicleModels.blimp(rng)
	local model = Instance.new("Model")
	model.Name = "AdBlimp"
	local color = pick(rng, BODY_COLORS)
	local body = blob(model, "Balloon", Vector3.new(16, 15, 42), CFrame.new(), color)
	blob(model, "BalloonShine", Vector3.new(7, 3, 20), CFrame.new(-3, 5.5, -3), WHITE).Transparency = 0.4
	for i, angle in ipairs({0, 90, 180, 270}) do
		local cf = CFrame.new(0, 0, 18) * CFrame.Angles(0, 0, math.rad(angle))
		part(model, "Fin", Vector3.new(0.8, 9, 7), cf * CFrame.new(0, 5.5, 0), i % 2 == 0 and WHITE or color)
	end
	part(model, "Gondola", Vector3.new(8, 3, 3.6), CFrame.new(0, -9, -2) * ALONG_Z, WHITE, nil, Enum.PartType.Cylinder)
	ball(model, "GondolaFront", 3.6, CFrame.new(0, -9, -6), WHITE)
	glass(blob(model, "GondolaWindows", Vector3.new(3.8, 1.4, 7), CFrame.new(0, -8.6, -2), GLASS, Enum.Material.Glass))
	for _, side in ipairs({-1, 1}) do
		local banner = part(model, "Banner", Vector3.new(0.4, 5, 22), CFrame.new(side * 8.1, 0, 0), INK)
		local gui = Instance.new("SurfaceGui")
		gui.Face = side == 1 and Enum.NormalId.Right or Enum.NormalId.Left
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 20
		gui.LightInfluence = 0
		gui.Parent = banner
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Text = pick(rng, SLOGANS)
		label.TextColor3 = rgb(255, 222, 110)
		label.Font = Enum.Font.FredokaOne
		label.TextScaled = true
		label.Parent = gui
		part(model, "BannerFrame", Vector3.new(0.3, 5.6, 22.6), CFrame.new(side * 7.9, 0, 0), pick(rng, GLOW_COLORS))
		part(model, "Propeller", Vector3.new(0.3, 4, 4), CFrame.new(side * 5, -8, 8) * ALONG_Z, WHITE, nil, Enum.PartType.Cylinder)
	end
	model.PrimaryPart = body
	return model
end

return VehicleModels
]=])
install(game:GetService("ReplicatedStorage"), "WorldsData", "ModuleScript", [=[
-- WorldsData (ModuleScript in ReplicatedStorage)
-- The 8 worlds you travel to through the World Gate (worlds 2-9). GameConfig turns each entry
-- into a full world: a floating island with its own pit, Shovel Shop, World Gate, memes,
-- shovels, dirt materials and sky. (The museum only exists in World 1.)
--
-- Per world:
--   Top / Wall      terrain material of the island surface and of the pit walls
--   Zones           terrain material + color of the 4 depth zones (Shallow, Mid, Deep, Abyss)
--   Look            colors for the island decorations and the world's shovels
--   Sky             lighting players see while they're in the world (WorldClient applies it):
--                   ClockTime, Latitude (sun angle), Brightness, Exposure (ExposureCompensation),
--                   Ambient/OutdoorAmbient, Fog/Decay/Density/Offset/Haze/Glare (Atmosphere),
--                   Tint/Saturation/Contrast (color grade), Bloom {Intensity, Size, Threshold},
--                   SunRays {Intensity, Spread}, Clouds (cover). Lighting.Technology is set to
--                   Future by the installer for realistic lights and reflections.
--   Shovels         the world's 7 pickaxes: {name, description, Id = save id}; stats come from ShovelTiers

local rgb = Color3.fromRGB

local WorldsData = {}

-- Every world's 7 shovels follow the same progression; price = PriceFactor x the world's price.
-- MaxZone: 1 = Shallow, 2 = Mid, 3 = Deep, 4 = Abyss
WorldsData.ShovelTiers = {
	{MaxZone = 1, Power = 2, FindChance = 0.012, Luck = 1,   Cooldown = 0.5,  PriceFactor = 0},
	{MaxZone = 2, Power = 3,   FindChance = 0.014, Luck = 1.2, Cooldown = 0.46, PriceFactor = 0.05},
	{MaxZone = 2, Power = 4, FindChance = 0.016, Luck = 1.4, Cooldown = 0.43, PriceFactor = 0.15},
	{MaxZone = 3, Power = 5,   FindChance = 0.018, Luck = 1.7, Cooldown = 0.4,  PriceFactor = 0.4},
	{MaxZone = 3, Power = 6, FindChance = 0.02,  Luck = 2,   Cooldown = 0.37, PriceFactor = 1},
	{MaxZone = 4, Power = 8, FindChance = 0.024, Luck = 2.5, Cooldown = 0.34, PriceFactor = 2.5},
	{MaxZone = 4, Power = 9,   FindChance = 0.027, Luck = 3,   Cooldown = 0.31, PriceFactor = 6},
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
			Fog = rgb(255, 200, 225), Decay = rgb(200, 130, 170), Density = 0.32, Clouds = 0.55,
			Brightness = 2.6, Exposure = 0.15, Latitude = 30, Offset = 0.25, Haze = 1.6, Glare = 0.6, Saturation = 0.12, Contrast = 0.08, Bloom = {0.35, 24, 1.9}, SunRays = {0.12, 0.25}},
		Shovels = {
			{"Blossom Pickaxe", "A little pink pickaxe. Leaves petals everywhere it digs.", Id = "BlossomTrowel"},
			{"Bamboo Pick", "Light, strong and grown in a week.", Id = "BambooSpade"},
			{"Koi Pickaxe", "Shaped like a koi fin. Cuts dirt like water.", Id = "KoiScoop"},
			{"Lantern Pick", "A paper lantern lights every swing.", Id = "LanternSpade"},
			{"Katana Pickaxe", "Folded 1000 times. Cuts through bricks like tofu.", Id = "KatanaShovel"},
			{"Petal Crusher", "Blows a storm of petals into the Abyss.", Id = "PetalExcavator"},
			{"Hanami Pickaxe", "Mythic. Blossoms bloom wherever it strikes.", Id = "HanamiHarvester"},
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
			Fog = rgb(80, 60, 160), Decay = rgb(40, 30, 100), Density = 0.32, Clouds = 0,
			Brightness = 1.2, Exposure = 0.35, Latitude = 20, Offset = 0.3, Haze = 0.3, Glare = 0, Saturation = 0.15, Contrast = 0.12, Bloom = {0.5, 28, 1.4}, SunRays = {0, 0.1}},
		Shovels = {
			{"Meteor Pick", "Made from a meteor that landed on a meme.", Id = "MeteorScoop"},
			{"Rocket Pickaxe", "Has tiny thrusters. Mostly for style.", Id = "RocketSpade"},
			{"Orbit Pickaxe", "A little moon orbits the handle.", Id = "OrbitShovel"},
			{"Nebula Pick", "Swirls with space dust.", Id = "NebulaTrowel"},
			{"Comet Crusher", "Leaves a sparkly tail with every swing.", Id = "CometCrusher"},
			{"Supernova Pickaxe", "Legendary. Hot as a dying star.", Id = "SupernovaSpade"},
			{"Event Horizon", "Mythic. Nothing escapes it. Not even the Abyss.", Id = "EventHorizon"},
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
			Fog = rgb(215, 235, 255), Decay = rgb(140, 170, 220), Density = 0.3, Clouds = 0.7,
			Brightness = 3.2, Exposure = 0.05, Latitude = 65, Offset = 0.2, Haze = 2.2, Glare = 0.3, Saturation = -0.05, Contrast = 0.1, Bloom = {0.3, 20, 2.2}, SunRays = {0.06, 0.2}},
		Shovels = {
			{"Snowball Pick", "Packs perfect snowballs. Also digs.", Id = "SnowballScoop"},
			{"Icicle Pickaxe", "Sharp, shiny and a bit drippy.", Id = "IcicleSpade"},
			{"Penguin Pick", "Waddles through snow at top speed.", Id = "PenguinPaddle"},
			{"Frostbite Pickaxe", "Cold enough to freeze a lag spike.", Id = "FrostbiteShovel"},
			{"Blizzard Breaker", "Every swing is a tiny snowstorm.", Id = "BlizzardBreaker"},
			{"Aurora Pickaxe", "Legendary. Glows with northern lights.", Id = "AuroraAuger"},
			{"Absolute Zero Pickaxe", "Mythic. So cold the Abyss shatters.", Id = "AbsoluteZeroSpade"},
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
			Fog = rgb(255, 222, 170), Decay = rgb(220, 160, 110), Density = 0.3, Clouds = 0.2,
			Brightness = 3.6, Exposure = 0.1, Latitude = 15, Offset = 0.2, Haze = 2.6, Glare = 0.9, Saturation = 0.08, Contrast = 0.14, Bloom = {0.3, 24, 2.1}, SunRays = {0.1, 0.3}},
		Shovels = {
			{"Sandy Pick", "Full of sand. Always. Forever.", Id = "SandyScoop"},
			{"Cactus Pickaxe", "Hug it at your own risk.", Id = "CactusSpade"},
			{"Mirage Pickaxe", "Is it really there? Yes. Probably.", Id = "MirageShovel"},
			{"Pharaoh Pickaxe", "Once dug a pyramid in an afternoon.", Id = "PharaohSpade"},
			{"Solar Pick", "Solar powered. Works best at noon.", Id = "SolarSifter"},
			{"Sandstorm Pickaxe", "Legendary. Spins up a sandstorm on every swing.", Id = "SandstormDrill"},
			{"Sun King Pickaxe", "Mythic. Blazes like a second sun.", Id = "SunKingShovel"},
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
			Fog = rgb(120, 210, 230), Decay = rgb(60, 140, 180), Density = 0.35, Clouds = 0.4,
			Brightness = 2.8, Exposure = 0.1, Latitude = 25, Offset = 0.3, Haze = 1.8, Glare = 0.2, Saturation = 0.18, Contrast = 0.06, Bloom = {0.35, 24, 1.9}, SunRays = {0.15, 0.35}},
		Shovels = {
			{"Seashell Pick", "Hold it to your ear: you hear dirt.", Id = "SeashellScoop"},
			{"Anchor Pickaxe", "Heavy. Very heavy. Digs straight down.", Id = "AnchorSpade"},
			{"Pearl Pickaxe", "A perfect pearl sits in the head.", Id = "PearlShovel"},
			{"Trident Pick", "Borrowed from a sea king. No returns.", Id = "TridentTrowel"},
			{"Kraken Claw", "Eight times the grip.", Id = "KrakenClaw"},
			{"Tidal Pickaxe", "Legendary. Moves dirt like a wave.", Id = "TidalExcavator"},
			{"Atlantis Pickaxe", "Mythic. Found at the bottom of a lost city.", Id = "AtlantisSpade"},
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
			Fog = rgb(255, 214, 240), Decay = rgb(220, 160, 210), Density = 0.32, Clouds = 0.6,
			Brightness = 3, Exposure = 0.05, Latitude = 35, Offset = 0.25, Haze = 1.2, Glare = 0.3, Saturation = 0.2, Contrast = 0.05, Bloom = {0.3, 24, 2}, SunRays = {0.08, 0.25}},
		Shovels = {
			{"Lollipop Pick", "Swirly, sticky and surprisingly strong.", Id = "LollipopScoop"},
			{"Candy Cane Pickaxe", "Minty fresh digging.", Id = "CandyCaneSpade"},
			{"Gummy Pickaxe", "Bends a lot. Never breaks.", Id = "GummyShovel"},
			{"Sprinkle Pick", "Leaves sprinkles in every hole.", Id = "SprinkleSpade"},
			{"Choco Crusher", "Solid chocolate. Please don't eat it.", Id = "ChocoCrusher"},
			{"Jawbreaker Pickaxe", "Legendary. Harder than any rock.", Id = "JawbreakerAuger"},
			{"Sugar Rush Pickaxe", "Mythic. Digs at 1000% speed. Crashes later.", Id = "SugarRushSpade"},
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
			Fog = rgb(200, 110, 80), Decay = rgb(120, 60, 50), Density = 0.35, Clouds = 0.5,
			Brightness = 2.2, Exposure = 0.2, Latitude = 40, Offset = 0.2, Haze = 2.4, Glare = 1.2, Saturation = 0.1, Contrast = 0.18, Bloom = {0.5, 28, 1.6}, SunRays = {0.2, 0.3}},
		Shovels = {
			{"Ember Pick", "Always a little bit warm.", Id = "EmberSpade"},
			{"Anvil Pickaxe", "Forged on an anvil. Kind of shaped like one too.", Id = "AnvilShovel"},
			{"Magma Pick", "Chews through lava like soup.", Id = "MagmaScoop"},
			{"Obsidian Pickaxe", "Glassy black and razor sharp.", Id = "ObsidianBlade"},
			{"Dragonbone Pickaxe", "Made from a dragon's lost tooth.", Id = "DragonboneSpade"},
			{"Inferno Pickaxe", "Legendary. Melts straight through rock.", Id = "InfernoAuger"},
			{"Core Breaker", "Mythic. Forged in the heart of the volcano.", Id = "CoreBreaker"},
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
			Fog = rgb(40, 60, 70), Decay = rgb(90, 40, 110), Density = 0.32, Clouds = 0,
			Brightness = 1.4, Exposure = 0.3, Latitude = 0, Offset = 0.25, Haze = 0.8, Glare = 0, Saturation = 0.25, Contrast = 0.2, Bloom = {0.6, 30, 1.3}, SunRays = {0, 0.1}},
		Shovels = {
			{"Placeholder Pickaxe", "TODO: add a description.", Id = "PlaceholderSpade"},
			{"Pixel Pickaxe", "Rendered at 8 pixels. Works anyway.", Id = "PixelShovel"},
			{"Lag Pick", "Hits the ground a second after you swing.", Id = "LagSpade"},
			{"Wireframe Pickaxe", "The texture never loaded.", Id = "WireframeShovel"},
			{"Error 404 Pick", "Pick not found. Digging anyway.", Id = "Error404Scoop"},
			{"Debug Pickaxe", "Legendary. Has admin commands built in.", Id = "DebugDrill"},
			{"The Final Patch", "Mythic. Fixes the simulation, one hole at a time.", Id = "TheFinalPatch"},
		},
	},
}

return WorldsData
]=])
install(game:GetService("ServerScriptService"), "Architecture", "ModuleScript", [=[
-- Architecture (ModuleScript in ServerScriptService)
-- Shared building kit for the cartoony 2050 look: chunky rounded shapes (discs, capsules,
-- domes, rings, arches, rounded blocks), a bright soft palette (white, lilac, sky, mint,
-- sunshine) and gentle pastel glow trims.
-- ShopBuilder, WorldGate, MuseumBuilder and MainIsland all build with this.

local Architecture = {}

---------------------------------------------------------------------
-- PALETTE
---------------------------------------------------------------------
local rgb = Color3.fromRGB
local PLASTIC = Enum.Material.SmoothPlastic
Architecture.Palette = {
	White    = {Color = rgb(246, 247, 252), Material = PLASTIC},
	Cloud    = {Color = rgb(222, 227, 242), Material = PLASTIC},
	Lilac    = {Color = rgb(178, 158, 255), Material = PLASTIC},
	Violet   = {Color = rgb(122, 92, 232),  Material = PLASTIC},
	Sky      = {Color = rgb(92, 186, 255),  Material = PLASTIC},
	Mint     = {Color = rgb(96, 226, 190),  Material = PLASTIC},
	Sun      = {Color = rgb(255, 206, 84),  Material = PLASTIC},
	Coral    = {Color = rgb(255, 122, 138), Material = PLASTIC},
	Navy     = {Color = rgb(52, 56, 118),   Material = PLASTIC},
	Ink      = {Color = rgb(34, 36, 74),    Material = PLASTIC},
	Chrome   = {Color = rgb(214, 220, 232), Material = Enum.Material.Metal, Reflectance = 0.2},
	Glass    = {Color = rgb(168, 228, 255), Material = Enum.Material.Glass, Transparency = 0.45, Reflectance = 0.15},
	GlowCyan = {Color = rgb(96, 196, 222),  Material = Enum.Material.Neon},
	GlowPink = {Color = rgb(214, 118, 188), Material = Enum.Material.Neon},
	GlowSun  = {Color = rgb(222, 186, 96),  Material = Enum.Material.Neon},
	GlowMint = {Color = rgb(96, 206, 168),  Material = Enum.Material.Neon},
	Portal   = {Color = rgb(170, 130, 255), Material = Enum.Material.ForceField},
}
Architecture.TextColor = rgb(255, 255, 255)
Architecture.TitleColor = rgb(255, 222, 110)
Architecture.AccentText = rgb(150, 230, 255)
Architecture.LightColor = rgb(225, 240, 255)

local UPRIGHT = CFrame.Angles(0, 0, math.rad(90)) -- turns a cylinder (X axis) to stand up (Y axis)

-- A CFrame at `position` whose X axis points along `direction` (for rods and capsules)
function Architecture.alongX(position, direction)
	local x = direction.Unit
	local helper = math.abs(x.Y) > 0.95 and Vector3.zAxis or Vector3.yAxis
	local z = x:Cross(helper).Unit
	local y = z:Cross(x)
	return CFrame.fromMatrix(position, x, y, z)
end

---------------------------------------------------------------------
-- BUILDER: every position is relative to `base` (a CFrame)
---------------------------------------------------------------------
local Builder = {}
Builder.__index = Builder

function Architecture.builder(parent, base)
	return setmetatable({Parent = parent, Base = base}, Builder)
end

-- A plain anchored part. `finish` is a palette name (see above).
function Builder:box(name, size, offset, finish, props)
	local f = Architecture.Palette[finish] or Architecture.Palette.White
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.CFrame = self.Base * offset
	p.Color = f.Color
	p.Material = f.Material
	p.Transparency = f.Transparency or 0
	p.Reflectance = f.Reflectance or 0
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if f.Transparency or f.Material == Enum.Material.Neon then
		p.CastShadow = false
	end
	if props then
		for key, value in pairs(props) do
			p[key] = value
		end
	end
	p.Parent = self.Parent
	return p
end

-- Flat round disc / short cylinder standing upright, centered at `offset`.
function Builder:disc(name, diameter, height, offset, finish, props)
	local p = self:box(name, Vector3.new(height, diameter, diameter), offset * UPRIGHT, finish, props)
	p.Shape = Enum.PartType.Cylinder
	return p
end

-- Cylinder lying along the local X axis of `offset`.
function Builder:rod(name, length, diameter, offset, finish, props)
	local p = self:box(name, Vector3.new(length, diameter, diameter), offset, finish, props)
	p.Shape = Enum.PartType.Cylinder
	return p
end

function Builder:ball(name, diameter, offset, finish, props)
	local p = self:box(name, Vector3.new(diameter, diameter, diameter), offset, finish, props)
	p.Shape = Enum.PartType.Ball
	return p
end

-- Squashed/stretched sphere (domes, saucers, blobs). `size` is the full ellipsoid size.
function Builder:ellipsoid(name, size, offset, finish, props)
	local p = self:box(name, size, offset, finish, props)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = p
	return p
end

-- Capsule from point a to point b: a rod with a ball on each end.
function Builder:pill(name, a, b, diameter, finish)
	local length = (b - a).Magnitude
	self:rod(name, length, diameter, Architecture.alongX((a + b) / 2, b - a), finish)
	self:ball(name .. "CapA", diameter, CFrame.new(a), finish)
	self:ball(name .. "CapB", diameter, CFrame.new(b), finish)
end

-- A block with rounded vertical edges (size = full outer size, radius = corner radius).
function Builder:roundedBlock(name, size, offset, radius, finish)
	radius = math.min(radius, size.X / 2, size.Z / 2)
	local core = self:box(name, Vector3.new(size.X - radius * 2, size.Y, size.Z), offset, finish)
	self:box(name .. "Side", Vector3.new(size.X, size.Y, size.Z - radius * 2), offset, finish)
	for _, sx in ipairs({-1, 1}) do
		for _, sz in ipairs({-1, 1}) do
			self:disc(name .. "Corner", radius * 2, size.Y,
				offset * CFrame.new(sx * (size.X / 2 - radius), 0, sz * (size.Z / 2 - radius)), finish)
		end
	end
	return core
end

-- A ring (torus) made of short rods. `cf` is the ring's center; the ring lies in the
-- XY plane of `cf` (so it faces along Z, like a doorway). Use `arc` < 360 for an arch.
function Builder:ring(name, cf, radius, thickness, finish, segments, arc, startAngle)
	segments = segments or 28
	arc = arc or 360
	startAngle = startAngle or 0
	local step = arc / segments
	local segLength = 2 * radius * math.sin(math.rad(step / 2)) + thickness * 0.35
	for i = 0, segments - 1 do
		local a = math.rad(startAngle + step * (i + 0.5))
		local point = Vector3.new(math.cos(a) * radius, math.sin(a) * radius, 0)
		-- the rod runs along the circle's tangent
		local rodCF = cf * CFrame.new(point) * CFrame.Angles(0, 0, a + math.pi / 2)
		self:rod(name, segLength, thickness, rodCF, finish)
	end
	if arc < 360 then
		for _, a in ipairs({startAngle, startAngle + arc}) do
			local r = math.rad(a)
			self:ball(name .. "End", thickness, cf * CFrame.new(math.cos(r) * radius, math.sin(r) * radius, 0), finish)
		end
	end
end

-- Stacked discs that shrink as they go up (a staggered round platform).
-- tiers = {{diameter, height, finish}, ...}, bottom first. Returns the top part and the total height.
function Builder:tiers(name, cf, list)
	local y = 0
	local top
	for i, tier in ipairs(list) do
		top = self:disc(name .. "Tier" .. i, tier[1], tier[2], cf * CFrame.new(0, y + tier[2] / 2, 0), tier[3])
		y += tier[2]
	end
	return top, y
end

-- A soft glowing light bulb (small neon ball with a light).
function Builder:bulb(name, diameter, offset, finish, range)
	local p = self:ball(name, diameter, offset, finish or "GlowCyan")
	local light = Instance.new("PointLight")
	light.Color = p.Color
	light.Range = range or 10
	light.Brightness = 0.8
	light.Parent = p
	return p
end

-- Tones down glow under `root` so the game isn't overwhelming. Safe to run more than once:
--   * big glowing panels (Neon wider than a strip) become plain colored plastic
--   * small Neon accents are capped in brightness
--   * lights are capped in brightness and range
Architecture.MAX_NEON = 0.78    -- brightest channel a Neon part may have (0-1)
Architecture.MAX_LIGHT = 0.8     -- brightest a PointLight/SpotLight/SurfaceLight may be
Architecture.MAX_LIGHT_RANGE = 16
function Architecture.calm(root)
	local list = root:GetDescendants()
	table.insert(list, root)
	for _, d in ipairs(list) do
		if d:IsA("BasePart") and d.Material == Enum.Material.Neon then
			local s = d.Size
			local dims = {s.X, s.Y, s.Z}
			table.sort(dims)
			if dims[2] > 2.5 then
				d.Material = Enum.Material.SmoothPlastic
			else
				local c = d.Color
				local m = math.max(c.R, c.G, c.B)
				if m > Architecture.MAX_NEON then
					local k = Architecture.MAX_NEON / m
					d.Color = Color3.new(c.R * k, c.G * k, c.B * k)
				end
			end
		elseif d:IsA("Light") then
			d.Brightness = math.min(d.Brightness, Architecture.MAX_LIGHT)
			if d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight") then
				d.Range = math.min(d.Range, Architecture.MAX_LIGHT_RANGE)
			end
		end
	end
end

-- Big friendly sign text on a part's face.
function Architecture.sign(part, title, subtitle, face, titleColor)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face or Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0
	gui.Parent = part
	local function line(text, color, y, h, font)
		local l = Instance.new("TextLabel")
		l.BackgroundTransparency = 1
		l.Position = UDim2.fromScale(0.05, y)
		l.Size = UDim2.fromScale(0.9, h)
		l.Text = text
		l.TextColor3 = color
		l.Font = font
		l.TextScaled = true
		l.Parent = gui
		local s = Instance.new("UIStroke")
		s.Thickness = 3
		s.Color = Color3.fromRGB(30, 26, 70)
		s.Parent = l
		return l
	end
	line(title, titleColor or Architecture.TitleColor, subtitle and 0.06 or 0.12, subtitle and 0.58 or 0.76, Enum.Font.FredokaOne)
	if subtitle then
		line(subtitle, Architecture.AccentText, 0.66, 0.28, Enum.Font.FredokaOne)
	end
	return gui
end

return Architecture
]=])
install(game:GetService("ServerScriptService"), "CityBuilder", "ModuleScript", [=[
-- CityBuilder (ModuleScript in ServerScriptService)
-- Rebuilds the city skyline in the cartoony 2050 style. It reads where every old tower
-- stood (its podium) and how tall it was, removes it, and builds a new rounded tower in
-- the same spot. It also recolors the streets, the edge wall and the ground, and swaps the
-- old sky bridges for glass tube bridges. MapStyle calls this once on server start.

local Architecture = require(script.Parent:WaitForChild("Architecture"))
local P = Architecture.Palette

local CityBuilder = {}

local BODIES = {"White", "Cloud", "White"}
local ACCENTS = {"Lilac", "Sky", "Mint", "Sun", "Coral", "Violet"}
local GLOWS = {"GlowCyan", "GlowPink", "GlowSun", "GlowMint"}

---------------------------------------------------------------------
-- COLOR HELPERS
---------------------------------------------------------------------
local function apply(part, finish)
	local f = P[finish]
	part.Color = f.Color
	part.Material = f.Material
	part.Transparency = f.Transparency or 0
	part.Reflectance = f.Reflectance or 0
end

-- Turns any gritty part into a smooth, soft-colored cartoon part
function CityBuilder.cartoonify(part)
	local c = part.Color
	local lum = 0.299 * c.R + 0.587 * c.G + 0.114 * c.B
	local sat = math.max(c.R, c.G, c.B) - math.min(c.R, c.G, c.B)
	if part.Material == Enum.Material.Neon then
		part.Color = c:Lerp(Color3.new(1, 1, 1), 0.25)
		return
	elseif part.Material == Enum.Material.Glass or part.Material == Enum.Material.ForceField or part.Transparency >= 0.99 then
		return
	end
	part.Material = Enum.Material.SmoothPlastic
	part.Reflectance = 0
	if sat > 0.25 then
		part.Color = c:Lerp(Color3.new(1, 1, 1), 0.15) -- keep real colors, just softer
	elseif lum < 0.22 then
		part.Color = P.Navy.Color
	elseif lum < 0.55 then
		part.Color = P.Lilac.Color:Lerp(P.Cloud.Color, 0.45)
	else
		part.Color = P.White.Color
	end
end

---------------------------------------------------------------------
-- TOWER STYLES. `b` is a builder at the tower's footprint (ground = y 0),
-- w = tower width, h = total height, rng = this tower's random generator.
---------------------------------------------------------------------
local function pick(rng, list)
	return list[rng:NextInteger(1, #list)]
end

local function antenna(b, y, rng, glow)
	local length = rng:NextNumber(6, 12)
	b:pill("Antenna", Vector3.new(0, y, 0), Vector3.new(0, y + length, 0), 0.8, "Chrome")
	b:bulb("AntennaTip", 1.8, CFrame.new(0, y + length + 1, 0), glow, 30)
end

-- A: stacked rounded tiers that step in as they rise, with window bands and a dome
local function stackTower(b, w, h, rng, body, accent, glow)
	local tiers = math.clamp(math.floor(h / 45) + 2, 2, 6)
	local y = 10
	local tierH = (h - 10 - w * 0.25) / tiers
	for i = 1, tiers do
		local size = w * (1 - (i - 1) * 0.12)
		b:roundedBlock("Tier", Vector3.new(size, tierH, size), CFrame.new(0, y + tierH / 2, 0), size * 0.28, i % 2 == 1 and body or accent)
		-- two glowing window bands per tier
		for _, f in ipairs({0.35, 0.72}) do
			b:roundedBlock("WindowBand", Vector3.new(size + 0.5, 1.6, size + 0.5), CFrame.new(0, y + tierH * f, 0), size * 0.3, "Glass")
		end
		b:roundedBlock("TierLip", Vector3.new(size + 1.6, 1.2, size + 1.6), CFrame.new(0, y + tierH, 0), size * 0.32, accent)
		y += tierH
	end
	local top = w * (1 - tiers * 0.12)
	b:ellipsoid("Dome", Vector3.new(top, w * 0.5, top), CFrame.new(0, y, 0), accent)
	antenna(b, y + w * 0.22, rng, glow)
end

-- B: a round tube with glass rings, a flying-saucer crown and a beacon
local function tubeTower(b, w, h, rng, body, accent, glow)
	local shaftH = h - 10 - 6
	b:disc("Shaft", w * 0.85, shaftH, CFrame.new(0, 10 + shaftH / 2, 0), body)
	local bands = math.floor(shaftH / 16)
	for i = 1, bands do
		local y = 10 + i * (shaftH / (bands + 1))
		b:disc("GlassRing", w * 0.85 + 0.6, 3, CFrame.new(0, y, 0), "Glass")
		if i % 2 == 0 then
			b:disc("ColorRing", w * 0.85 + 1.2, 1, CFrame.new(0, y + 2.4, 0), accent)
		end
	end
	local crown = 10 + shaftH
	b:ellipsoid("SaucerUnder", Vector3.new(w * 1.5, 4, w * 1.5), CFrame.new(0, crown, 0), accent)
	b:disc("SaucerRim", w * 1.55, 1.2, CFrame.new(0, crown + 0.6, 0), glow)
	b:ellipsoid("SaucerTop", Vector3.new(w * 1.4, 5, w * 1.4), CFrame.new(0, crown + 1.4, 0), body)
	b:ellipsoid("Bubble", Vector3.new(w * 0.6, w * 0.45, w * 0.6), CFrame.new(0, crown + 3, 0), "Glass")
	antenna(b, crown + 3 + w * 0.2, rng, glow)
end

-- C: twisting stack of rounded slabs (each floor turned a bit more)
local function twistTower(b, w, h, rng, body, accent, glow)
	local slabH = 14
	local count = math.floor((h - 12) / slabH)
	local twist = rng:NextNumber(5, 9) * (rng:NextNumber() < 0.5 and -1 or 1)
	for i = 0, count - 1 do
		local y = 10 + i * slabH
		local cf = CFrame.new(0, y + slabH / 2, 0) * CFrame.Angles(0, math.rad(twist * i), 0)
		b:box("Slab", Vector3.new(w * 0.8, slabH - 2.2, w * 0.8), cf, i % 3 == 0 and accent or body)
		b:box("SlabGlass", Vector3.new(w * 0.8 + 0.4, slabH - 6, w * 0.8 + 0.4), cf, "Glass")
		b:box("SlabLip", Vector3.new(w * 0.92, 2.2, w * 0.92), cf * CFrame.new(0, slabH / 2 - 1.1, 0), accent)
	end
	local topY = 10 + count * slabH
	b:ball("TopOrb", w * 0.55, CFrame.new(0, topY + w * 0.2, 0), accent)
	b:disc("TopOrbRing", w * 0.8, 0.8, CFrame.new(0, topY + w * 0.2, 0), glow)
	antenna(b, topY + w * 0.45, rng, glow)
end

-- D: slim core with big bubble pods sticking out at different heights
local function podTower(b, w, h, rng, body, accent, glow)
	local coreH = h - 10
	b:disc("Core", w * 0.55, coreH, CFrame.new(0, 10 + coreH / 2, 0), body)
	for i = 1, math.floor(coreH / 12) do
		b:disc("CoreGlass", w * 0.55 + 0.5, 1.6, CFrame.new(0, 10 + i * 12, 0), "Glass")
	end
	local pods = math.clamp(math.floor(coreH / 30), 2, 7)
	for i = 1, pods do
		local y = 10 + coreH * (i / (pods + 1))
		local a = math.rad(i * 137.5 + rng:NextNumber(0, 40))
		local out = w * 0.5
		local pos = Vector3.new(math.cos(a) * out, y, math.sin(a) * out)
		local size = w * rng:NextNumber(0.45, 0.6)
		b:ball("Pod", size, CFrame.new(pos), i % 2 == 0 and accent or body)
		b:ellipsoid("PodWindow", Vector3.new(size * 0.7, size * 0.35, size * 0.7), CFrame.new(pos + Vector3.new(0, size * 0.12, 0)), "Glass")
		b:disc("PodRing", size * 1.15, 0.7, CFrame.new(pos), glow)
	end
	b:ellipsoid("CoreCap", Vector3.new(w * 0.7, w * 0.4, w * 0.7), CFrame.new(0, 10 + coreH, 0), accent)
	antenna(b, 10 + coreH + w * 0.15, rng, glow)
end

local STYLES = {stackTower, tubeTower, twistTower, podTower}

---------------------------------------------------------------------
-- MEGATOWERS: the towering landmarks of the 2050 skyline (the 8 sturdiest tower spots).
-- Blended cartoony-realism: tinted Glass floors that twist as they rise (each floor is
-- turned a little more with CFrame.Angles), thin white floor plates, Neon corner ribs that
-- spiral up with the twist, cantilevered sky gardens, a stepped crown and a glowing spire.
---------------------------------------------------------------------
local MEGA_COUNT = 8
local MEGA_GLASS = {
	{Name = "MegaGlassSky", Color = Color3.fromRGB(120, 200, 255)},
	{Name = "MegaGlassLilac", Color = Color3.fromRGB(180, 160, 255)},
	{Name = "MegaGlassMint", Color = Color3.fromRGB(110, 235, 205)},
	{Name = "MegaGlassRose", Color = Color3.fromRGB(255, 160, 205)},
}
for _, g in ipairs(MEGA_GLASS) do
	P[g.Name] = {Color = g.Color, Material = Enum.Material.Glass, Transparency = 0.25, Reflectance = 0.25}
end
P.MegaSteel = {Color = Color3.fromRGB(236, 240, 248), Material = Enum.Material.Metal, Reflectance = 0.1}
local MEGA_NEON = {
	{Name = "MegaNeonCyan", Color = Color3.fromRGB(90, 220, 255)},
	{Name = "MegaNeonPink", Color = Color3.fromRGB(255, 110, 200)},
	{Name = "MegaNeonGold", Color = Color3.fromRGB(255, 205, 90)},
	{Name = "MegaNeonMint", Color = Color3.fromRGB(90, 255, 190)},
}
for _, g in ipairs(MEGA_NEON) do
	P[g.Name] = {Color = g.Color, Material = Enum.Material.Neon}
end

local function megaTower(b, w, h, rng)
	local glass = pick(rng, MEGA_GLASS).Name
	local neon = pick(rng, MEGA_NEON).Name
	local twistPerFloor = math.rad(rng:NextNumber(2.2, 3.6)) * (rng:NextNumber() < 0.5 and -1 or 1)
	local floorH = 12
	local podiumH = 14

	-- podium: two rounded steps with a glowing lip
	b:roundedBlock("MegaPodium", Vector3.new(w + 14, podiumH * 0.6, w + 14), CFrame.new(0, podiumH * 0.3, 0), 8, "MegaSteel")
	b:roundedBlock("MegaPodiumLip", Vector3.new(w + 15, 0.8, w + 15), CFrame.new(0, podiumH * 0.6, 0), 8.2, neon)
	b:roundedBlock("MegaLobby", Vector3.new(w + 6, podiumH * 0.4, w + 6), CFrame.new(0, podiumH * 0.8, 0), 6, glass)

	local floors = math.floor((h - podiumH - 40) / floorH)
	local prevCorners
	for i = 0, floors - 1 do
		local y = podiumH + i * floorH
		local t = i / math.max(floors - 1, 1)
		-- slim waist at 60% height, slight flare near the top (an elegant hourglass taper)
		local size = w * (1 - 0.28 * math.sin(t * math.pi * 0.85)) * (1 - 0.15 * t)
		local turn = CFrame.Angles(0, i * twistPerFloor, 0)
		local floorCF = CFrame.new(0, y + floorH / 2, 0) * turn
		-- (plain boxes keep the part count low: 2 parts per floor)
		b:box("MegaFloor", Vector3.new(size, floorH - 1, size), floorCF, glass)
		b:box("MegaPlate", Vector3.new(size + 1.4, 1, size + 1.4), CFrame.new(0, y, 0) * turn, "MegaSteel")

		-- corner ribs: every 2 floors a neon rod joins each corner to the same corner two floors
		-- up, which is turned further, so the ribs spiral around the tower
		local inset = size * 0.5
		local corners = {}
		for k = 0, 3 do
			local a = math.rad(45 + k * 90)
			corners[k + 1] = (CFrame.new(0, y, 0) * turn * CFrame.new(math.cos(a) * inset * 1.414 + math.cos(a) * 0.4, 0, math.sin(a) * inset * 1.414 + math.sin(a) * 0.4)).Position
		end
		if i % 3 == 0 then
			if prevCorners then
				for k = 1, 4 do
					local a, c = prevCorners[k], corners[k]
					b:rod("MegaRib", (c - a).Magnitude + 0.6, 0.9, Architecture.alongX((a + c) / 2, c - a), neon)
				end
			end
			prevCorners = corners
		end

		-- sky gardens at one third and two thirds of the height
		if i == math.floor(floors / 3) or i == math.floor(floors * 2 / 3) then
			local gardenCF = CFrame.new(0, y + 0.5, 0) * turn
			b:disc("SkyGarden", size * 1.5, 1.4, gardenCF, "MegaSteel")
			b:ring("SkyGardenRail", gardenCF * CFrame.new(0, 1.4, 0) * CFrame.Angles(math.rad(90), 0, 0), size * 0.75, 0.5, neon, 28)
			for k = 1, 6 do
				local a = math.pi * 2 * k / 6
				local spot = gardenCF * CFrame.new(math.cos(a) * size * 0.62, 0.7, math.sin(a) * size * 0.62)
				b:pill("GardenTrunk", spot.Position, (spot * CFrame.new(0, 3, 0)).Position, 0.6, "Chrome")
				b:ball("GardenTree", 3.4, spot * CFrame.new(0, 4.2, 0), k % 2 == 0 and "Mint" or "GlowMint")
			end
		end
	end

	-- crown: stepped discs, a halo ring and a spire with a beacon
	local topY = podiumH + floors * floorH
	local crownW = w * 0.6
	local _, crownH = b:tiers("MegaCrown", CFrame.new(0, topY, 0) * CFrame.Angles(0, floors * twistPerFloor, 0), {
		{crownW, 4, "MegaSteel"}, {crownW * 0.78, 3, glass}, {crownW * 0.55, 3, "MegaSteel"}, {crownW * 0.3, 6, glass},
	})
	b:ring("MegaHalo", CFrame.new(0, topY + crownH + 4, 0) * CFrame.Angles(math.rad(90), 0, 0), crownW * 0.5, 1, neon, 32)
	local spireTop = topY + crownH + 30
	b:pill("MegaSpire", Vector3.new(0, topY + crownH, 0), Vector3.new(0, spireTop, 0), 1.6, "Chrome")
	b:bulb("MegaBeacon", 3, CFrame.new(0, spireTop + 2, 0), neon, 40)
end


-- Podium + little park around every tower
local function base(b, w, rng, accent)
	b:disc("Park", w * 1.9, 0.4, CFrame.new(0, 0.2, 0), "Mint")
	b:disc("ParkEdge", w * 1.9 + 1.2, 0.3, CFrame.new(0, 0.15, 0), "White")
	b:roundedBlock("Podium", Vector3.new(w + 4, 10, w + 4), CFrame.new(0, 5, 0), (w + 4) * 0.3, "Cloud")
	b:roundedBlock("PodiumBand", Vector3.new(w + 4.6, 1.4, w + 4.6), CFrame.new(0, 8.4, 0), (w + 4.6) * 0.3, accent)
	b:roundedBlock("Lobby", Vector3.new(w * 0.6, 6, w + 4.3), CFrame.new(0, 3.2, 0), 1, "Glass")
	-- lollipop trees
	for i = 1, 3 do
		local a = math.rad(i * 120 + rng:NextNumber(-20, 20))
		local r = w * 0.8
		local pos = Vector3.new(math.cos(a) * r, 0, math.sin(a) * r)
		b:rod("TreeTrunk", 5, 0.8, CFrame.new(pos + Vector3.new(0, 2.5, 0)) * CFrame.Angles(0, 0, math.rad(90)), "White")
		b:ball("TreeTop", rng:NextNumber(4, 5.5), CFrame.new(pos + Vector3.new(0, 6.5, 0)), pick(rng, {"Mint", "Sun", "Coral", "Lilac"}))
	end
end

---------------------------------------------------------------------
-- REBUILD THE SKYLINE
---------------------------------------------------------------------
local function findTowers(towersFolder)
	local podiums = {}
	local parts = {}
	for _, d in ipairs(towersFolder:GetDescendants()) do
		if d:IsA("BasePart") then
			table.insert(parts, d)
			if d.Name == "Podium" then
				table.insert(podiums, {CFrame = d.CFrame, Size = d.Size, Top = 0})
			end
		end
	end
	-- each part belongs to the nearest podium; the tallest part sets the tower height
	for _, part in ipairs(parts) do
		local pos = part.CFrame.Position
		local best, bestD = nil, math.huge
		for _, pod in ipairs(podiums) do
			local pp = pod.CFrame.Position
			local d = (pp.X - pos.X) ^ 2 + (pp.Z - pos.Z) ^ 2
			if d < bestD then best, bestD = pod, d end
		end
		if best then
			best.Top = math.max(best.Top, pos.Y + part.Size.Y / 2)
		end
	end
	return podiums
end

function CityBuilder.rebuildTowers(city)
	local towers = city:FindFirstChild("Towers")
	if not towers or towers:GetAttribute("Cartoon2050") then return end
	local list = findTowers(towers)
	towers:ClearAllChildren()
	-- the sturdiest footprints become megatowers
	local bySize = table.clone(list)
	table.sort(bySize, function(a, c) return math.min(a.Size.X, a.Size.Z) > math.min(c.Size.X, c.Size.Z) end)
	local mega = {}
	for i = 1, math.min(MEGA_COUNT, #bySize) do mega[bySize[i]] = true end
	for i, tower in ipairs(list) do
		local pos = tower.CFrame.Position
		local rng = Random.new(i * 7919)
		local model = Instance.new("Model")
		model.Name = "Tower"
		local b = Architecture.builder(model, CFrame.new(pos.X, 0, pos.Z) * tower.CFrame.Rotation)
		local w = math.clamp(math.min(tower.Size.X, tower.Size.Z) - 6, 16, 30)
		local h = math.max(tower.Top, 50)
		local body = pick(rng, BODIES)
		local accent = pick(rng, ACCENTS)
		local glow = pick(rng, GLOWS)
		if mega[tower] then
			model.Name = "MegaTower"
			megaTower(b, math.clamp(math.min(tower.Size.X, tower.Size.Z) - 4, 24, 40), math.clamp(math.max(h * 1.6, 400), 400, 580), rng)
		else
			base(b, w, rng, accent)
			STYLES[(i - 1) % #STYLES + 1](b, w, h, rng, body, accent, glow)
		end
		model.Parent = towers
	end
	towers:SetAttribute("Cartoon2050", true)
end

-- Old sky bridges pointed at towers that no longer exist, so replace them with glass tubes
function CityBuilder.rebuildBridges(city)
	local bridges = city:FindFirstChild("SkyBridges")
	if not bridges or bridges:GetAttribute("Cartoon2050") then return end
	local spans = {}
	for _, d in ipairs(bridges:GetDescendants()) do
		if d:IsA("BasePart") and d.Name == "SkyBridge" then
			table.insert(spans, {CFrame = d.CFrame, Size = d.Size})
		end
	end
	bridges:ClearAllChildren()
	local b = Architecture.builder(bridges, CFrame.new())
	for _, span in ipairs(spans) do
		-- the long side of the old bridge is the direction the tube runs
		local s = span.Size
		local axis = s.X >= s.Z and span.CFrame.RightVector or span.CFrame.LookVector
		local length = math.max(s.X, s.Z)
		local mid = span.CFrame.Position
		b:rod("Tube", length, 6, Architecture.alongX(mid, axis), "Glass")
		b:rod("TubeFloor", length, 4.6, Architecture.alongX(mid - Vector3.new(0, 1.6, 0), axis), "White")
		for k = -1, 1 do
			b:rod("TubeRing", 1, 7, Architecture.alongX(mid + axis * (length * 0.33 * k), axis), "Lilac")
		end
	end
	bridges:SetAttribute("Cartoon2050", true)
end

-- Streets, edge wall and anything else: recolor in place
function CityBuilder.restyleRest(city)
	for _, name in ipairs({"Streets", "EdgeWall"}) do
		local folder = city:FindFirstChild(name)
		if folder then
			for _, d in ipairs(folder:GetDescendants()) do
				if d:IsA("BasePart") then
					if d.Name == "Road" then
						d.Material = Enum.Material.SmoothPlastic
						d.Color = Color3.fromRGB(88, 92, 140)
					elseif d.Name == "LaneLine" then
						apply(d, "Sun")
					elseif d.Name == "Curb" then
						apply(d, "White")
					elseif d.Name == "Megastructure" then
						d.Material = Enum.Material.SmoothPlastic
						d.Color = Color3.fromRGB(176, 186, 236)
					elseif d.Name == "WallFrame" then
						apply(d, "White")
					else
						CityBuilder.cartoonify(d)
					end
				end
			end
		end
	end
end

function CityBuilder.build(city)
	CityBuilder.rebuildTowers(city)
	CityBuilder.rebuildBridges(city)
	CityBuilder.restyleRest(city)
end

return CityBuilder
]=])
install(game:GetService("ServerScriptService"), "DigManager", "Script", [=[
-- DigManager (Script in ServerScriptService)
-- Real terrain digging with shovels across every world: carves holes in a 560-stud pit,
-- blocks shovels from breaking into zones deeper than they're rated for, finds artifacts
-- by depth zone, Lucky Dig minigame, pit resets, the Shovel Shops and the World Gates.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))
local ShovelModels = require(ReplicatedStorage:WaitForChild("PickaxeModels"))
local ShopBuilder = require(script.Parent:WaitForChild("ShopBuilder"))
local WorldGate = require(script.Parent:WaitForChild("WorldGate"))
local WorldBuilder = require(script.Parent:WaitForChild("WorldBuilder"))

local terrain = workspace.Terrain

---------------------------------------------------------------------
-- SETTINGS
---------------------------------------------------------------------
local MINIGAME_TIMEOUT = 8
local MINIGAME_LUCK = {Perfect = 3, Good = 1.5, Miss = 1} -- multiplies the shovel's luck
local ANNOUNCE_FROM = ArtifactData.GetRarityIndex("Mythic")
local MAX_REACH = 14 -- how far from your character you can dig
local PICKUP_SECONDS = 20  -- how long a find waits for "pick up" before it's left in the dirt
local COMBO_WINDOW = 1.4   -- seconds between digs to keep a combo going
local COMBO_MAX = 10
local COMBO_LUCK = 0.04    -- each combo step adds +4% find chance (x10 combo = +36%)
local SURFACE_RING = 52 -- where "Return to Surface" puts you (distance from the pit center)

-- Where the shop and the World Gate stand around each pit (angle, distance from center)
local SHOP_SPOT = {Angle = 30, Distance = 80}
local GATE_SPOT = {Angle = -30, Distance = 86}

---------------------------------------------------------------------
-- REMOTES
---------------------------------------------------------------------
local remotes = ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage
local function getRemote(name)
	local r = remotes:FindFirstChild(name) or Instance.new("RemoteEvent")
	r.Name = name
	r.Parent = remotes
	return r
end
local minigameRemote = getRemote("DigMinigame")
local resultRemote = getRemote("DigResult")
local announceRemote = getRemote("Announcement")
local swingRemote = getRemote("DigSwing")          -- client -> server: swing at a position
local swingFxRemote = getRemote("ShovelSwingFx")   -- server -> other clients: play this player's swing
local digHitRemote = getRemote("DigHit")           -- server -> digger: impact info for juice (combo, color, spot)
local claimRemote = getRemote("ClaimFind")         -- client -> server: pick up (true) or leave (false) the find
local inventoryChangedRemote = getRemote("InventoryChanged") -- server -> client: inventory changed, refresh UI
local getInventory = remotes:FindFirstChild("GetInventory") or Instance.new("RemoteFunction")
getInventory.Name = "GetInventory"
getInventory.Parent = remotes
local digMessageRemote = getRemote("DigProgress")  -- server -> client: short messages (text, color)
local surfaceRemote = getRemote("ReturnToSurface")
local openShopRemote = getRemote("OpenShovelShop") -- server -> client: (worldId)
local buyShovelRemote = getRemote("BuyShovel")
local equipShovelRemote = getRemote("EquipShovel")
local shopMessageRemote = getRemote("ShopMessage")
local openWorldMapRemote = getRemote("OpenWorldMap")
local buyWorldRemote = getRemote("BuyWorld")
local travelRemote = getRemote("TravelToWorld")

local digSite = workspace:WaitForChild("DigSite")

---------------------------------------------------------------------
-- SHOVEL TOOLS
---------------------------------------------------------------------
local toolTemplates = {}
for _, def in ipairs(GameConfig.Shovels) do
	toolTemplates[def.Id] = ShovelModels(def)
end

---------------------------------------------------------------------
-- PLAYER STATE: which world they're in, which shovel they hold there
---------------------------------------------------------------------
local currentWorld = {} -- [player] = world

local function getWorld(player)
	return currentWorld[player] or GameConfig.Worlds[1]
end

local function getEquippedDef(player, world)
	world = world or getWorld(player)
	local data = PlayerData.Get(player)
	local id = data and data.EquippedShovels[tostring(world.Id)]
	local def = id and GameConfig.GetShovel(id)
	if def and def.World == world.Id and data.OwnedShovels[def.Id] then
		return def
	end
	return GameConfig.GetStarterShovel(world)
end

local function keysToString(t)
	local list = {}
	for key in pairs(t) do
		table.insert(list, key)
	end
	return table.concat(list, ",")
end

local function updateAttributes(player)
	local data = PlayerData.Get(player)
	if not data then return end
	local def = getEquippedDef(player)
	player:SetAttribute("OwnedShovels", keysToString(data.OwnedShovels))
	player:SetAttribute("EquippedShovel", def and def.Id or "")
	player:SetAttribute("UnlockedWorlds", keysToString(data.UnlockedWorlds))
	player:SetAttribute("CurrentWorld", getWorld(player).Id)
end

-- Puts the shovel for the player's current world in their backpack (removes any other)
local function giveShovel(player)
	local def = getEquippedDef(player)
	for _, container in ipairs({player:FindFirstChild("Backpack"), player.Character}) do
		if container then
			for _, item in ipairs(container:GetChildren()) do
				if item:IsA("Tool") and item:GetAttribute("ShovelId") then
					item:Destroy()
				end
			end
		end
	end
	local backpack = player:FindFirstChild("Backpack")
	if backpack and def then
		toolTemplates[def.Id]:Clone().Parent = backpack
	end
end

---------------------------------------------------------------------
-- DIGGING
---------------------------------------------------------------------
local rng = Random.new()
local lastSwing = {}  -- [player] = time of last swing
local lastHit = {}    -- [player] = time of last successful dig (for combos)
local combos = {}     -- [player] = current combo count
local sessions = {}   -- [player] = Lucky Dig session
local resetting = false

local function burst(position, color, count, speed)
	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.Transparency = 1
	anchor.Size = Vector3.new(1, 1, 1)
	anchor.CFrame = CFrame.new(position)
	anchor.Parent = workspace

	local emitter = Instance.new("ParticleEmitter")
	emitter.Enabled = false
	emitter.Color = ColorSequence.new(color)
	emitter.Size = NumberSequence.new(0.5, 0.1)
	emitter.Lifetime = NumberRange.new(0.5, 0.9)
	emitter.Speed = NumberRange.new(speed or 10, (speed or 10) * 1.6)
	emitter.SpreadAngle = Vector2.new(40, 40)
	emitter.Acceleration = Vector3.new(0, -45, 0)
	emitter.Rotation = NumberRange.new(0, 360)
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.Parent = anchor
	emitter:Emit(count or 18)
	Debris:AddItem(anchor, 2)
end

-- Is there solid ground at this point?
local function isSolid(position)
	local region = Region3.new(position - Vector3.new(1, 1, 1), position + Vector3.new(1, 1, 1)):ExpandToGrid(4)
	local materials, occupancies = terrain:ReadVoxels(region, 4)
	local size = materials.Size
	for x = 1, size.X do
		for y = 1, size.Y do
			for z = 1, size.Z do
				if materials[x][y][z] ~= Enum.Material.Air and occupancies[x][y][z] > 0.02 then
					return true
				end
			end
		end
	end
	return false
end

-- A find waits in pending[player] until the player picks it up or leaves it
local pending = {} -- [player] = {Artifact = artifact}

local function resolveFind(player, take)
	local find = pending[player]
	if not find then return end
	pending[player] = nil
	local data = PlayerData.Get(player)
	if take and data then
		PlayerData.AddArtifact(player, find.Artifact.Id)
		data.Stats.TotalDigs += 1
		inventoryChangedRemote:FireClient(player)
		shopMessageRemote:FireClient(player, find.Artifact.Name .. " added to your inventory!", true)
	else
		digMessageRemote:FireClient(player, "You left the " .. find.Artifact.Name .. " in the dirt.", Color3.fromRGB(200, 200, 215))
	end
end

claimRemote.OnServerEvent:Connect(function(player, take)
	resolveFind(player, take == true)
end)

getInventory.OnServerInvoke = function(player)
	local data = PlayerData.WaitForData(player)
	local counts = {}
	for _, artifactId in pairs(data and data.Inventory or {}) do
		counts[artifactId] = (counts[artifactId] or 0) + 1
	end
	local list = {}
	for artifactId, count in pairs(counts) do
		table.insert(list, {Id = artifactId, Count = count})
	end
	return list
end

local function giveArtifact(player, zone, luck, grade, position)
	local artifact = ArtifactData.RollForZone(zone, luck)
	local data = PlayerData.Get(player)
	if not artifact or not data then return end

	-- don't add it yet: the player chooses to pick it up or leave it
	local find = {Artifact = artifact}
	pending[player] = find
	task.delay(PICKUP_SECONDS, function()
		if pending[player] == find then
			resolveFind(player, false)
		end
	end)

	local rarity = ArtifactData.GetRarity(artifact.Rarity)
	local rarityIndex = ArtifactData.GetRarityIndex(artifact.Rarity)
	resultRemote:FireClient(player, {
		Name = artifact.Name,
		Rarity = artifact.Rarity,
		RarityIndex = rarityIndex,
		Color = rarity.Color,
		Income = ArtifactData.GetIncome(artifact),
		Description = artifact.Description,
		Grade = grade,
		Position = position, -- where it popped out of the ground
		Id = artifact.Id,
		Pickup = true,
		Timeout = PICKUP_SECONDS,
	})
	if rarityIndex >= ANNOUNCE_FROM then
		announceRemote:FireAllClients(player.DisplayName .. " found a " .. string.upper(artifact.Rarity) .. " " .. artifact.Name .. " in " .. zone.Name .. "!", rarity.Color)
	end
end

local function finishLuckyDig(player, grade)
	local session = sessions[player]
	if not session then return end
	sessions[player] = nil
	giveArtifact(player, session.Zone, session.ShovelLuck * (MINIGAME_LUCK[grade] or 1), grade, session.Position)
end

local function onFind(player, def, zone, position)
	if rng:NextNumber() < GameConfig.MinigameChance then
		local session = {Started = os.clock(), ShovelLuck = def.Luck, Zone = zone, Position = position}
		sessions[player] = session
		minigameRemote:FireClient(player)
		task.delay(MINIGAME_TIMEOUT, function()
			if sessions[player] == session then
				finishLuckyDig(player, "Miss")
			end
		end)
	else
		giveArtifact(player, zone, def.Luck, nil, position)
	end
end

-- The shovel hits a zone it isn't rated for: sparks fly and it bounces off
local lastBounceMessage = {}
local function bounceOff(player, world, def, zoneIndex, zone, position)
	burst(position, Color3.fromRGB(255, 214, 150), 10, 16)
	burst(position, zone.Color, 6, 6)
	if os.clock() - (lastBounceMessage[player] or 0) < 1.5 then return end
	lastBounceMessage[player] = os.clock()
	local needed = GameConfig.GetFirstShovelForZone(world, zoneIndex)
	local text = "CLANG! Your " .. def.Name .. " bounces off " .. string.upper(zone.Name) .. " (" .. -zone.Top .. "m+)."
	if needed then
		text ..= " You need the " .. needed.Name .. " or better."
	end
	digMessageRemote:FireClient(player, text, Color3.fromRGB(255, 120, 100))
end

swingRemote.OnServerEvent:Connect(function(player, target, swingLength)
	if resetting or sessions[player] then return end
	if pending[player] then
		digMessageRemote:FireClient(player, "Pick up your find or leave it first!")
		return
	end
	local data = PlayerData.Get(player)
	if not data then return end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local tool = character and character:FindFirstChildOfClass("Tool")
	if not root or not tool or not tool:GetAttribute("ShovelId") then return end

	local world = getWorld(player)
	local def = getEquippedDef(player, world)
	if not def or tool:GetAttribute("ShovelId") ~= def.Id then return end
	local now = os.clock()
	if now - (lastSwing[player] or 0) < def.Cooldown * 0.85 then return end
	lastSwing[player] = now
	-- let everyone else see this player's dig animation
	local length = typeof(swingLength) == "number" and math.clamp(swingLength, 0.3, 1) or 0.6
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player then
			swingFxRemote:FireClient(other, player, length)
		end
	end

	-- Where to dig: where the player clicked, or just in front of their feet
	if typeof(target) ~= "Vector3" or (target - root.Position).Magnitude > MAX_REACH then
		target = root.Position + root.CFrame.LookVector * 3 - Vector3.new(0, 3, 0)
	end

	local origin = world.Origin
	local flat = Vector3.new(target.X - origin.X, 0, target.Z - origin.Z).Magnitude
	if flat > world.PitRadius or flat < world.CenterNoDigRadius or target.Y > origin.Y + 5 then
		digMessageRemote:FireClient(player, "Dig inside the pit!")
		return
	end

	-- Aim into the ground: a bit past the clicked point, snapped to the 4-stud terrain grid
	local head = root.Position + Vector3.new(0, 1.5, 0)
	local dir = (target - head).Unit
	local function snap(v) return math.floor(v / 4) * 4 + 2 end
	local carveAt
	for d = 0, 14, 0.5 do
		local point = target + dir * d
		local cell = Vector3.new(snap(point.X), snap(point.Y), snap(point.Z))
		if isSolid(cell) then
			carveAt = cell
			break
		end
	end
	if not carveAt then
		return -- nothing but air there
	end

	-- Which depth zone is this, and is this shovel rated for it?
	local zoneIndex, zone = GameConfig.GetZoneAt(world, carveAt.Y)
	if not zone then
		digMessageRemote:FireClient(player, "Bedrock! This is the bottom of the Abyss.")
		return
	end
	if zoneIndex > def.MaxZone then
		bounceOff(player, world, def, zoneIndex, zone, carveAt + Vector3.new(0, 2, 0))
		digHitRemote:FireClient(player, {Bounced = true, Position = carveAt + Vector3.new(0, 2, 0), Color = zone.Color, Combo = 0})
		combos[player] = 0
		return
	end

	-- Carve a round crater (smooth terrain looks much nicer than square holes). It reaches a
	-- bit below the clicked cell and up enough to walk into, but never below the bottom of
	-- the shovel's deepest zone.
	local floorY = origin.Y + world.Zones[def.MaxZone].Bottom
	-- the crater's radius scales straight with the shovel's Power (see GameConfig.DigRadiusForPower)
	local radius = (GameConfig.DigRadiusForPower(def.Power) + 2) / 2 + 0.75
	local centerY = math.max(carveAt.Y + radius * 0.35, floorY + radius)
	terrain:FillBall(Vector3.new(carveAt.X, centerY, carveAt.Z), radius, Enum.Material.Air)
	burst(target, zone.Color, 28, 14)

	-- Combo: keep digging without long pauses to build it up (more luck per dig)
	if now - (lastHit[player] or 0) <= COMBO_WINDOW then
		combos[player] = math.min((combos[player] or 0) + 1, COMBO_MAX)
	else
		combos[player] = 1
	end
	lastHit[player] = now
	local combo = combos[player]
	digHitRemote:FireClient(player, {Combo = combo, Position = carveAt, Color = zone.Color})

	-- Did we find something?
	if rng:NextNumber() < def.FindChance * (1 + COMBO_LUCK * (combo - 1)) then
		onFind(player, def, zone, carveAt + Vector3.new(0, 2, 0))
	end
end)

minigameRemote.OnServerEvent:Connect(function(player, grade)
	local session = sessions[player]
	if not session then return end
	if typeof(grade) ~= "string" or not MINIGAME_LUCK[grade] then grade = "Miss" end
	if os.clock() - session.Started < 0.3 then grade = "Miss" end
	finishLuckyDig(player, grade)
end)

---------------------------------------------------------------------
-- GETTING OUT OF THE PIT
---------------------------------------------------------------------
local function surfaceCFrame(world, position)
	local origin = world.Origin
	local offset = position - origin
	local angle = math.atan2(offset.Z, offset.X)
	if world.HubPaths then
		-- nearest of the 6 path openings, on the path just outside the rim
		angle = math.floor(angle / (math.pi / 3) + 0.5) * (math.pi / 3)
	end
	local spot = origin + Vector3.new(math.cos(angle) * SURFACE_RING, 4, math.sin(angle) * SURFACE_RING)
	return CFrame.lookAt(spot, origin + Vector3.new(0, 4, 0))
end

surfaceRemote.OnServerEvent:Connect(function(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local world = getWorld(player)
	if root and root.Position.Y < world.Origin.Y - 2 then
		character:PivotTo(surfaceCFrame(world, root.Position))
	end
end)

---------------------------------------------------------------------
-- PIT RESET (refills all the dirt in every open world)
---------------------------------------------------------------------
local function enabledWorlds()
	local list = {}
	for _, world in ipairs(GameConfig.Worlds) do
		if world.Enabled then
			table.insert(list, world)
		end
	end
	return list
end

local function resetPits()
	resetting = true
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local world = getWorld(player)
		if root then
			local offset = root.Position - world.Origin
			if Vector3.new(offset.X, 0, offset.Z).Magnitude < world.PitRadius + 7 and offset.Y < 6 then
				character:PivotTo(surfaceCFrame(world, root.Position))
			end
		end
	end
	task.wait(0.5)
	for _, world in ipairs(enabledWorlds()) do
		GameConfig.FillDigTerrain(terrain, world)
	end
	resetting = false
end

local worldsBuilt = false -- the floating islands must exist before the pits are filled
task.spawn(function()
	-- wait for the floating islands (worlds 2-9 here, World 1 in MapStyle) before filling the pits
	local waited = 0
	while (not worldsBuilt or not workspace:GetAttribute("MainIslandReady")) and waited < 30 do
		waited += task.wait(0.1)
	end
	resetPits() -- fresh ground when the server starts
	while true do
		task.wait(GameConfig.PitResetMinutes * 60 - 30)
		announceRemote:FireAllClients("The Hard Drives reboot in 30 seconds! All the dirt will come back.", Color3.fromRGB(0, 225, 255))
		task.wait(30)
		resetPits()
		announceRemote:FireAllClients("The Hard Drives have rebooted. Fresh ground to dig!", Color3.fromRGB(90, 255, 120))
	end
end)

---------------------------------------------------------------------
-- SHOVEL SHOP
---------------------------------------------------------------------
buyShovelRemote.OnServerEvent:Connect(function(player, shovelId)
	local data = PlayerData.Get(player)
	local def = typeof(shovelId) == "string" and GameConfig.GetShovel(shovelId)
	if not data or not def or data.OwnedShovels[def.Id] then return end
	if not data.UnlockedWorlds[tostring(def.World)] then
		shopMessageRemote:FireClient(player, "Unlock " .. GameConfig.GetWorld(def.World).Name .. " first!", false)
		return
	end
	if not PlayerData.SpendMoney(player, def.Price) then
		shopMessageRemote:FireClient(player, "Not enough money!", false)
		return
	end
	data.OwnedShovels[def.Id] = true
	data.EquippedShovels[tostring(def.World)] = def.Id
	updateAttributes(player)
	giveShovel(player)
	shopMessageRemote:FireClient(player, "You bought the " .. def.Name .. "! It digs down to " .. -GameConfig.GetWorld(def.World).Zones[def.MaxZone].Bottom .. "m.", true)
end)

equipShovelRemote.OnServerEvent:Connect(function(player, shovelId)
	local data = PlayerData.Get(player)
	local def = typeof(shovelId) == "string" and GameConfig.GetShovel(shovelId)
	if not data or not def or not data.OwnedShovels[def.Id] then return end
	data.EquippedShovels[tostring(def.World)] = def.Id
	updateAttributes(player)
	giveShovel(player)
end)

---------------------------------------------------------------------
-- WORLDS: travel + unlocking
---------------------------------------------------------------------
local arrivalSpots = {} -- [worldId] = CFrame in front of that world's gate

local function ringCFrame(world, spot, height)
	local a = math.rad(spot.Angle)
	local pos = world.Origin + Vector3.new(math.cos(a) * spot.Distance, height or 0, math.sin(a) * spot.Distance)
	return CFrame.lookAt(pos, Vector3.new(world.Origin.X, pos.Y, world.Origin.Z))
end

local function travel(player, world)
	local character = player.Character
	if not character then return end
	sessions[player] = nil
	currentWorld[player] = world
	updateAttributes(player)
	giveShovel(player)
	character:PivotTo(arrivalSpots[world.Id] or (CFrame.new(world.Origin + Vector3.new(0, 6, SURFACE_RING))))
end

travelRemote.OnServerEvent:Connect(function(player, worldId)
	local data = PlayerData.Get(player)
	local world = typeof(worldId) == "number" and GameConfig.GetWorld(worldId)
	if not data or not world then return end
	if not world.Enabled then
		shopMessageRemote:FireClient(player, world.Name .. " is still being excavated. Coming soon!", false)
	elseif not data.UnlockedWorlds[tostring(world.Id)] then
		shopMessageRemote:FireClient(player, "Unlock " .. world.Name .. " first!", false)
	else
		travel(player, world)
	end
end)

buyWorldRemote.OnServerEvent:Connect(function(player, worldId)
	local data = PlayerData.Get(player)
	local world = typeof(worldId) == "number" and GameConfig.GetWorld(worldId)
	if not data or not world or data.UnlockedWorlds[tostring(world.Id)] then return end
	if not world.Enabled then
		shopMessageRemote:FireClient(player, world.Name .. " is still being excavated. Coming soon!", false)
		return
	end
	if world.Id > 1 and not data.UnlockedWorlds[tostring(world.Id - 1)] then
		shopMessageRemote:FireClient(player, "Unlock the world before this one first!", false)
		return
	end
	if not PlayerData.SpendMoney(player, world.Price) then
		shopMessageRemote:FireClient(player, "Not enough money!", false)
		return
	end
	data.UnlockedWorlds[tostring(world.Id)] = true
	local starter = GameConfig.GetStarterShovel(world)
	if starter then
		data.OwnedShovels[starter.Id] = true
		data.EquippedShovels[tostring(world.Id)] = data.EquippedShovels[tostring(world.Id)] or starter.Id
	end
	updateAttributes(player)
	shopMessageRemote:FireClient(player, "World unlocked: " .. world.Name .. "!", true)
	announceRemote:FireAllClients(player.DisplayName .. " unlocked " .. world.Name .. "!", Color3.fromRGB(200, 205, 215))
end)

---------------------------------------------------------------------
-- BUILD EACH WORLD'S SHOP + GATE
---------------------------------------------------------------------
local worldsFolder = workspace:FindFirstChild("Worlds") or Instance.new("Folder")
worldsFolder.Name = "Worlds"
worldsFolder.Parent = workspace

for _, world in ipairs(enabledWorlds()) do
	local container = digSite
	if world.Id ~= 1 then
		container = Instance.new("Model")
		container.Name = "World" .. world.Id
		container.Parent = worldsFolder
	end
	-- Rebuild every start so the look always matches the code
	for _, name in ipairs({"ShovelShop", "WorldGate"}) do
		local old = container:FindFirstChild(name)
		if old then old:Destroy() end
	end

	local _, shopPrompt = ShopBuilder(container, world, ringCFrame(world, SHOP_SPOT))
	shopPrompt.Triggered:Connect(function(player)
		openShopRemote:FireClient(player, world.Id)
	end)

	local gateCF = ringCFrame(world, GATE_SPOT)
	local _, gatePrompt = WorldGate(container, gateCF, world.Id == 1 and "8 NEW DIG SITES  ·  UNLOCK WITH CASH" or "RETURN  ·  TRAVEL")
	gatePrompt.Triggered:Connect(function(player)
		openWorldMapRemote:FireClient(player)
	end)
	arrivalSpots[world.Id] = gateCF * CFrame.new(0, 5, -10) -- in front of the gate, facing the pit
	if world.Id ~= 1 then
		WorldBuilder(container, world) -- floating island, decorations, rim and zone rings
	end
end
worldsBuilt = true

---------------------------------------------------------------------
-- PLAYERS
---------------------------------------------------------------------
-- Everyone walks faster than Roblox's default (see GameConfig.WalkSpeed)
game:GetService("StarterPlayer").CharacterWalkSpeed = GameConfig.WalkSpeed
local function setSpeed(character)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if humanoid then
		humanoid.WalkSpeed = GameConfig.WalkSpeed
	end
end
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(setSpeed)
	if player.Character then task.spawn(setSpeed, player.Character) end
end)
for _, player in ipairs(Players:GetPlayers()) do
	player.CharacterAdded:Connect(setSpeed)
	if player.Character then task.spawn(setSpeed, player.Character) end
end

local function onPlayerAdded(player)
	PlayerData.WaitForData(player)
	if not player.Parent then return end
	currentWorld[player] = GameConfig.Worlds[1] -- everyone spawns at their museum in world 1
	updateAttributes(player)
	player.CharacterAdded:Connect(function()
		currentWorld[player] = GameConfig.Worlds[1]
		updateAttributes(player)
		task.wait(0.2)
		giveShovel(player)
	end)
	if player.Character then
		giveShovel(player)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

Players.PlayerRemoving:Connect(function(player)
	lastSwing[player] = nil
	lastHit[player] = nil
	combos[player] = nil
	pending[player] = nil
	sessions[player] = nil
	currentWorld[player] = nil
	lastBounceMessage[player] = nil
end)

print("DigManager ready: " .. #enabledWorlds() .. " world(s), 560-stud pits, pickaxe depth zones active")
]=])
install(game:GetService("ServerScriptService"), "DigSiteStyle", "ModuleScript", [=[
-- DigSiteStyle (ModuleScript in ServerScriptService)
-- Makes a world's dig site match the cartoony 2050 look:
--   * recolors the rim, walkways, racks, gates, lamps and props into the soft palette
--   * adds a chunky candy-striped rim ring with bulbs around the pit
--   * strings party lights between the lamp posts
--   * puts a glowing halo over the giant hard drive
--   * hides glowing zone rings inside the pit walls at every zone boundary, so players
--     see a colored ring appear in the dirt when they dig past 50, 130 and 200 studs
-- The Shovel Shop and World Gate are skipped (they're already built in this style).

local Architecture = require(script.Parent:WaitForChild("Architecture"))
local CityBuilder = require(script.Parent:WaitForChild("CityBuilder"))
local P = Architecture.Palette

local SKIP = {ShovelShop = true, WorldGate = true, Cartoon2050 = true}

-- specific parts that deserve a specific color
local NAMED = {
	RimWall = "Lilac", RimCap = "White", Curb = "Lilac", RampPost = "Lilac",
	Walkway = "White", Ramp = "White", TileJoint = "Cloud",
	GatePost = "Violet", GateBeam = "Violet", GateSign = "Navy",
	ServerRack = "Navy", LampBase = "Violet", LampPole = "White", FloodPole = "White",
	FloodBase = "Violet", FloodHousing = "Sky", Cable = "Violet", BarrelBand = "Violet",
}

local function recolor(root)
	for _, d in ipairs(root:GetDescendants()) do
		local skip = false
		local a = d.Parent
		while a and a ~= root do
			if SKIP[a.Name] then
				skip = true
				break
			end
			a = a.Parent
		end
		if not skip and d:IsA("BasePart") then
			local finish = NAMED[d.Name]
			if finish then
				local f = P[finish]
				d.Color = f.Color
				d.Material = f.Material
				d.Reflectance = 0
			else
				CityBuilder.cartoonify(d)
			end
		end
	end
end

return function(digSite, world)
	if digSite:GetAttribute("Cartoon2050") then return end
	recolor(digSite)

	local folder = Instance.new("Model")
	folder.Name = "Cartoon2050"
	local origin = world.Origin
	local b = Architecture.builder(folder, CFrame.new(origin))
	local rimRadius = world.PitRadius + 4.5

	-- candy-striped rim ring, broken where the six walkways come in (world 1)
	local segments = 72
	for i = 0, segments - 1 do
		local deg = (i + 0.5) * 360 / segments
		local onPath = false
		if world.HubPaths then
			local fromPath = math.abs(((deg + 30) % 60) - 30)
			onPath = fromPath < 9
		end
		if not onPath then
			local a = math.rad(deg)
			local pos = Vector3.new(math.cos(a) * rimRadius, 4.3, math.sin(a) * rimRadius)
			local tangent = Vector3.new(-math.sin(a), 0, math.cos(a))
			local length = 2 * math.pi * rimRadius / segments + 0.6
			b:rod("RimStripe", length, 2.2, Architecture.alongX(pos, tangent), (i // 2) % 2 == 0 and "Sun" or "White")
			if i % 6 == 0 then
				b:bulb("RimBulb", 1, CFrame.new(pos + Vector3.new(0, 1.5, 0)), (i // 6) % 2 == 0 and "GlowPink" or "GlowCyan", 8)
			end
		end
	end

	-- party lights strung between the lamp posts (world 1 has 6 lamps on a ring)
	local lamps = {}
	for _, d in ipairs(digSite:GetDescendants()) do
		if d:IsA("BasePart") and d.Name == "LampGlow" then
			table.insert(lamps, d.CFrame.Position)
		end
	end
	table.sort(lamps, function(p, q)
		return math.atan2(p.Z - origin.Z, p.X - origin.X) < math.atan2(q.Z - origin.Z, q.X - origin.X)
	end)
	local bulbColors = {"GlowSun", "GlowPink", "GlowCyan", "GlowMint"}
	for i, from in ipairs(lamps) do
		local to = lamps[i % #lamps + 1]
		if #lamps > 1 and (to - from).Magnitude < 80 then
			for k = 1, 9 do
				local t = k / 10
				local sag = math.sin(t * math.pi) * 3.5
				local pos = from:Lerp(to, t) - Vector3.new(0, sag + 0.6, 0)
				b:bulb("PartyBulb", 0.7, CFrame.new(pos - origin), bulbColors[(k % #bulbColors) + 1], 0)
			end
		end
	end

	-- halo over the giant hard drive in the middle
	if world.Id == 1 then
		b:ring("DriveHalo", CFrame.new(0, 13, 0) * CFrame.Angles(math.rad(90), 0, 0), 10, 0.8, "GlowCyan", 24)
		b:ring("DriveHaloOuter", CFrame.new(0, 15.5, 0) * CFrame.Angles(math.rad(90), 0, 0), 12.5, 0.6, "Lilac", 28)
	end

	-- zone rings hidden in the pit wall (you uncover them while digging)
	for i = 2, #world.Zones do
		local zone = world.Zones[i]
		local ringCF = CFrame.new(0, zone.Top, 0) * CFrame.Angles(math.rad(90), 0, 0)
		local marker = Instance.new("Model")
		marker.Name = "ZoneRing_" .. zone.Name
		marker.Parent = folder
		local mb = Architecture.builder(marker, CFrame.new(origin))
		mb:ring("ZoneRing", ringCF, world.PitRadius + 1.5, 0.9, "GlowCyan", 40)
		for _, part in ipairs(marker:GetChildren()) do
			part.Color = zone.Color:Lerp(Color3.new(1, 1, 1), 0.2)
			part.CanCollide = false
		end
	end

	for _, d in ipairs(folder:GetDescendants()) do
		if d:IsA("BasePart") and d.Name == "PartyBulb" then
			d.CanCollide = false
			local light = d:FindFirstChildOfClass("PointLight")
			if light then light:Destroy() end -- lots of bulbs; keep it cheap
		end
	end
	folder.Parent = digSite
	digSite:SetAttribute("Cartoon2050", true)
end
]=])
install(game:GetService("ServerScriptService"), "MainIsland", "ModuleScript", [=[
-- MainIsland (ModuleScript in ServerScriptService)
-- World 1 as a compact, densely packed floating island (radius 470 studs, about half the old
-- map) wrapped in a belt of towering 2050 skyscrapers.
--
-- Layout, from the middle out:
--   0-130   the Meme Dig Site with its six walkways          (DigSite, built by the place)
--   150-245 the six player museums on their plots            (MuseumBuilder / PlotManager)
--   258-280 a glowing ring boulevard with lamps and trees
--   290-450 three rings of skyscrapers, getting taller outward, split by six radial
--           avenues (between the museums) so every museum keeps a view out
--   470     the island edge: a glass railing, then the floating cliff underneath
--
-- Every skyscraper is made from Instance.new("Part") with exact Color3s, Glass and Neon
-- materials and CFrame math: floors that twist a few degrees each, stacks that shear
-- sideways along a sine curve, set-back tiers, glass cylinders ringed with neon, twin towers
-- joined by sky tubes, and a few megatowers with spiralling neon ribs and sky gardens.
-- MapStyle calls MainIsland.build() once when the server starts.

local Architecture = require(script.Parent:WaitForChild("Architecture"))
local P = Architecture.Palette

local MainIsland = {}

local rgb = Color3.fromRGB
local terrain = workspace.Terrain

local ISLAND_RADIUS = 470
local BOULEVARD = {Radius = 269, Width = 22}
local AVENUE_ANGLES = {30, 90, 150, 210, 270, 330} -- between the museums (plots sit at 0, 60, 120...)
local AVENUE_HALF_WIDTH = 20
-- tower rings: radius, footprint range, height range
local RINGS = {
	{Radius = 312, Width = {28, 36}, Height = {110, 210}},
	{Radius = 364, Width = {32, 42}, Height = {180, 320}},
	{Radius = 422, Width = {36, 48}, Height = {260, 480}},
}
local GAP = 12 -- studs between neighbouring towers
local MEGA_COUNT = 6

---------------------------------------------------------------------
-- MATERIALS (exact colors)
---------------------------------------------------------------------
local GLASS_TINTS = {
	rgb(120, 200, 255), -- sky
	rgb(176, 160, 255), -- lilac
	rgb(110, 232, 204), -- mint
	rgb(255, 168, 206), -- rose
	rgb(255, 214, 140), -- champagne
	rgb(196, 232, 255), -- ice
}
local NEON_TINTS = {
	rgb(84, 212, 240),  -- cyan
	rgb(236, 112, 190), -- pink
	rgb(236, 192, 92),  -- gold
	rgb(92, 226, 180),  -- mint
	rgb(168, 132, 250), -- violet
}
local glassNames, neonNames = {}, {}
for i, c in ipairs(GLASS_TINTS) do
	local name = "IslandGlass" .. i
	P[name] = {Color = c, Material = Enum.Material.Glass, Transparency = 0.05, Reflectance = 0.28}
	table.insert(glassNames, name)
	-- a deeper version of the same tint for set-back cores and shadows
	P[name .. "Core"] = {Color = c:Lerp(rgb(40, 44, 90), 0.45), Material = Enum.Material.SmoothPlastic}
end
for i, c in ipairs(NEON_TINTS) do
	local name = "IslandNeon" .. i
	P[name] = {Color = c, Material = Enum.Material.Neon}
	table.insert(neonNames, name)
end
P.IslandFrame = {Color = rgb(238, 241, 250), Material = Enum.Material.SmoothPlastic}
P.IslandSteel = {Color = rgb(206, 212, 228), Material = Enum.Material.Metal, Reflectance = 0.12}
P.IslandRoad = {Color = rgb(64, 60, 112), Material = Enum.Material.SmoothPlastic}
P.IslandWalk = {Color = rgb(226, 222, 246), Material = Enum.Material.SmoothPlastic}
P.IslandLeaf = {Color = rgb(96, 206, 150), Material = Enum.Material.SmoothPlastic}

local function pick(rng, list)
	return list[rng:NextInteger(1, #list)]
end

-- CFrame at a point on a circle, turned so its -Z faces the island center
local function facingCenter(angle, radius, y)
	local pos = Vector3.new(math.cos(angle) * radius, y or 0, math.sin(angle) * radius)
	-- yaw so LookVector points at the center: LookVector of Angles(0, t, 0) is (-sin t, 0, -cos t)
	return CFrame.new(pos) * CFrame.Angles(0, math.atan2(pos.X, pos.Z), 0)
end

local function angleDiff(a, b)
	local d = (a - b) % (math.pi * 2)
	return math.min(d, math.pi * 2 - d)
end

---------------------------------------------------------------------
-- TERRAIN: the floating island itself
---------------------------------------------------------------------
local function buildTerrain(rng)
	local R = ISLAND_RADIUS
	terrain:FillCylinder(CFrame.new(0, -16, 0), 32, R, Enum.Material.Slate)
	for _, layer in ipairs({{0.86, -40, 18}, {0.68, -62, 26}, {0.5, -90, 32}, {0.32, -124, 36}}) do
		terrain:FillCylinder(CFrame.new(0, layer[2], 0), layer[3], R * layer[1], Enum.Material.Slate)
	end
	for _ = 1, 22 do
		local a = rng:NextNumber(0, math.pi * 2)
		local d = rng:NextNumber(R * 0.4, R * 0.85)
		terrain:FillBall(Vector3.new(math.cos(a) * d, rng:NextNumber(-80, -36), math.sin(a) * d), rng:NextNumber(18, 34), Enum.Material.Slate)
	end
	-- grass on top (the Dig Site refills its own square in the middle)
	terrain:FillCylinder(CFrame.new(0, -2, 0), 4, R, Enum.Material.Grass)
end

---------------------------------------------------------------------
-- GROUND: boulevard, avenues, walkways to the museums, lamps, trees, the edge railing
---------------------------------------------------------------------
local function ringOfBoxes(b, name, radius, width, height, y, finish, segments)
	local length = 2 * math.pi * radius / segments + 0.8
	for i = 0, segments - 1 do
		local a = (i + 0.5) / segments * math.pi * 2
		local pos = Vector3.new(math.cos(a) * radius, y, math.sin(a) * radius)
		local tangent = Vector3.new(-math.sin(a), 0, math.cos(a))
		b:box(name, Vector3.new(length, height, width), Architecture.alongX(pos, tangent), finish)
	end
end

local function buildGround(b, rng)
	-- the ring boulevard with sidewalks, a glowing center line and lamps
	ringOfBoxes(b, "Boulevard", BOULEVARD.Radius, BOULEVARD.Width, 0.4, 0.2, "IslandRoad", 64)
	ringOfBoxes(b, "SidewalkIn", BOULEVARD.Radius - BOULEVARD.Width / 2 - 3, 6, 0.6, 0.3, "IslandWalk", 64)
	ringOfBoxes(b, "SidewalkOut", BOULEVARD.Radius + BOULEVARD.Width / 2 + 3, 6, 0.6, 0.3, "IslandWalk", 72)
	ringOfBoxes(b, "LaneGlow", BOULEVARD.Radius, 0.5, 0.45, 0.22, "IslandNeon1", 64)
	for i = 0, 35 do
		local a = i / 36 * math.pi * 2 + 0.05
		local cf = facingCenter(a, BOULEVARD.Radius - BOULEVARD.Width / 2 - 3)
		b:pill("LampPost", cf.Position + Vector3.new(0, 0.6, 0), cf.Position + Vector3.new(0, 14, 0), 0.6, "IslandFrame")
		b:ball("LampGlow", 2, CFrame.new(cf.Position + Vector3.new(0, 15, 0)), pick(rng, neonNames))
		-- a round tree between every pair of lamps
		local tree = facingCenter(a + math.pi / 36, BOULEVARD.Radius - BOULEVARD.Width / 2 - 4)
		b:pill("TreeTrunk", tree.Position, tree.Position + Vector3.new(0, 6, 0), 1.2, "IslandSteel")
		b:ball("TreeTop", rng:NextNumber(6, 8), CFrame.new(tree.Position + Vector3.new(0, 8.5, 0)), i % 3 == 0 and "Mint" or "IslandLeaf")
	end
	-- radial avenues between the museums, out to the island edge
	for _, deg in ipairs(AVENUE_ANGLES) do
		local a = math.rad(deg)
		local dir = Vector3.new(math.cos(a), 0, math.sin(a))
		local from, to = BOULEVARD.Radius + BOULEVARD.Width / 2, ISLAND_RADIUS - 14
		local mid = dir * ((from + to) / 2) + Vector3.new(0, 0.2, 0)
		b:box("Avenue", Vector3.new(to - from, 0.4, 26), Architecture.alongX(mid, dir), "IslandRoad")
		b:box("AvenueGlow", Vector3.new(to - from, 0.45, 0.5), Architecture.alongX(mid, dir), "IslandNeon2")
		-- a lookout at the end of each avenue
		local look = dir * (ISLAND_RADIUS - 20)
		b:disc("Lookout", 30, 0.8, CFrame.new(look + Vector3.new(0, 0.4, 0)), "IslandWalk")
		b:ring("LookoutGlow", CFrame.new(look + Vector3.new(0, 0.9, 0)) * CFrame.Angles(math.rad(90), 0, 0), 14.5, 0.5, "IslandNeon1", 24)
	end
	-- walkways from the Dig Site's paths to each museum's plaza
	for k = 0, 5 do
		local a = math.rad(k * 60)
		local dir = Vector3.new(math.cos(a), 0, math.sin(a))
		b:box("MuseumWalk", Vector3.new(40, 0.5, 14), Architecture.alongX(dir * 146 + Vector3.new(0, 0.25, 0), dir), "IslandWalk")
	end
	-- the edge: a glass railing with a glowing top, plus an invisible wall so nobody falls off
	ringOfBoxes(b, "EdgeCurb", ISLAND_RADIUS - 3, 4, 1.6, 0.8, "IslandFrame", 96)
	ringOfBoxes(b, "EdgeRail", ISLAND_RADIUS - 3, 0.6, 4, 3.6, "IslandGlass6", 96)
	ringOfBoxes(b, "EdgeRailGlow", ISLAND_RADIUS - 3, 0.8, 0.4, 5.7, "IslandNeon1", 96)
	ringOfBoxes(b, "EdgeBarrier", ISLAND_RADIUS - 1, 2, 80, 40, "IslandFrame", 64)
end

---------------------------------------------------------------------
-- SKYSCRAPER STYLES. b is a builder at the tower's footprint (ground = y 0, -Z faces the
-- island center), w = footprint width, h = height, rng = this tower's random numbers.
---------------------------------------------------------------------
local function podium(b, w, glass, neon)
	b:box("Podium", Vector3.new(w + 8, 6, w + 8), CFrame.new(0, 3, 0), "IslandFrame")
	b:box("PodiumGlow", Vector3.new(w + 8.4, 0.5, w + 8.4), CFrame.new(0, 6, 0), neon)
	b:box("Lobby", Vector3.new(w + 2, 8, w + 2), CFrame.new(0, 10, 0), glass)
	return 14 -- where the tower itself starts
end

local function antenna(b, y, height, neon)
	b:pill("Antenna", Vector3.new(0, y, 0), Vector3.new(0, y + height, 0), 1, "IslandSteel")
	b:ball("AntennaTip", 2.4, CFrame.new(0, y + height + 1, 0), neon)
end

-- A: set-back tiers, like a 2050 art-deco tower: each tier is narrower, with white corner
-- posts, a neon stripe up the front and a white crown ledge
local function setbackTower(b, w, h, rng, glass, neon)
	local y = podium(b, w, glass, neon)
	local tiers = rng:NextInteger(3, 4)
	local remaining = h - y - 16
	for i = 1, tiers do
		local size = w * (1 - (i - 1) * 0.17)
		local th = remaining * (i == 1 and 0.4 or (0.6 / (tiers - 1)))
		b:box("Tier", Vector3.new(size, th, size), CFrame.new(0, y + th / 2, 0), glass)
		for _, c in ipairs({{1, 1}, {-1, 1}, {1, -1}, {-1, -1}}) do
			b:box("CornerPost", Vector3.new(1.6, th, 1.6), CFrame.new(c[1] * size / 2, y + th / 2, c[2] * size / 2), "IslandFrame")
		end
		b:box("FrontStripe", Vector3.new(1, th - 4, 0.6), CFrame.new(0, y + th / 2, -size / 2 - 0.3), neon)
		b:box("Ledge", Vector3.new(size + 2, 1.4, size + 2), CFrame.new(0, y + th, 0), "IslandFrame")
		y += th
	end
	b:box("Crown", Vector3.new(w * 0.3, 10, w * 0.3), CFrame.new(0, y + 5, 0) * CFrame.Angles(0, math.rad(45), 0), glass)
	antenna(b, y + 10, rng:NextNumber(10, 22), neon)
end

-- B: twisting tower: stacked glass floors, each turned a few degrees more than the one below
local function twistTower(b, w, h, rng, glass, neon)
	local y = podium(b, w, glass, neon)
	local segH = 24
	local n = math.max(3, math.floor((h - y - 14) / segH))
	local twist = math.rad(rng:NextNumber(4, 7)) * (rng:NextNumber() < 0.5 and -1 or 1)
	for i = 0, n - 1 do
		local size = w * (1 - 0.25 * i / n)
		local turn = CFrame.Angles(0, i * twist, 0)
		b:box("TwistFloor", Vector3.new(size, segH - 1.2, size), CFrame.new(0, y + segH / 2, 0) * turn, glass)
		if i % 2 == 0 then
			b:box("TwistPlate", Vector3.new(size + 1.6, 1.2, size + 1.6), CFrame.new(0, y, 0) * turn, "IslandFrame")
		end
		y += segH
	end
	b:box("TwistCap", Vector3.new(w * 0.6, 3, w * 0.6), CFrame.new(0, y + 1.5, 0) * CFrame.Angles(0, n * twist, 0), neon)
	antenna(b, y + 3, rng:NextNumber(12, 24), neon)
end

-- C: glass cylinder banded with thin neon discs, a dome on top
local function cylinderTower(b, w, h, rng, glass, neon)
	local y = podium(b, w, glass, neon)
	local body = h - y - w * 0.4
	b:disc("Cylinder", w, body, CFrame.new(0, y + body / 2, 0), glass)
	b:disc("CylinderCore", w * 0.7, body, CFrame.new(0, y + body / 2, 0), glass .. "Core")
	local bands = math.floor(body / 30)
	for i = 1, bands do
		b:disc("NeonBand", w + 0.8, 0.8, CFrame.new(0, y + i * body / (bands + 1), 0), neon)
	end
	b:disc("CylinderLip", w + 2, 1.4, CFrame.new(0, y + body, 0), "IslandFrame")
	b:ellipsoid("CylinderDome", Vector3.new(w, w * 0.8, w), CFrame.new(0, y + body, 0), glass)
	antenna(b, y + body + w * 0.35, rng:NextNumber(8, 16), neon)
end

-- D: sheared tower: segments slide sideways along a sine curve and lean with it, so the
-- whole tower bends gracefully
local function shearTower(b, w, h, rng, glass, neon)
	local y = podium(b, w, glass, neon)
	local n = rng:NextInteger(5, 7)
	local segH = (h - y - 10) / n
	local sway = w * rng:NextNumber(0.25, 0.4) * (rng:NextNumber() < 0.5 and -1 or 1)
	for i = 0, n - 1 do
		local t0, t1 = i / n, (i + 1) / n
		local x0, x1 = math.sin(t0 * math.pi) * sway, math.sin(t1 * math.pi) * sway
		local lean = math.atan2(x1 - x0, segH)
		local cf = CFrame.new((x0 + x1) / 2, y + segH / 2, 0) * CFrame.Angles(0, 0, -lean)
		b:box("ShearFloor", Vector3.new(w * 0.9, segH - 1, w * 0.9), cf, glass)
		b:box("ShearEdge", Vector3.new(0.8, segH - 1, 0.8), cf * CFrame.new(w * 0.45, 0, -w * 0.45), neon)
		b:box("ShearEdge", Vector3.new(0.8, segH - 1, 0.8), cf * CFrame.new(-w * 0.45, 0, -w * 0.45), neon)
		b:box("ShearPlate", Vector3.new(w * 0.95, 1, w * 0.95), CFrame.new(x0, y, 0) * CFrame.Angles(0, 0, -lean), "IslandFrame")
		y += segH
	end
	b:box("ShearRoof", Vector3.new(w * 0.95, 1.6, w * 0.95), CFrame.new(math.sin(math.pi) * sway, y, 0), "IslandFrame")
	antenna(b, y + 1, rng:NextNumber(10, 18), neon)
end

-- E: twin towers joined by glass sky tubes
local function twinTower(b, w, h, rng, glass, neon)
	local y = podium(b, w, glass, neon)
	local tw = w * 0.42
	local heights = {h - y, (h - y) * rng:NextNumber(0.7, 0.85)}
	for i, side in ipairs({-1, 1}) do
		local th = heights[i]
		local x = side * w * 0.27
		b:box("TwinBody", Vector3.new(tw, th, tw), CFrame.new(x, y + th / 2, 0), glass)
		b:box("TwinFin", Vector3.new(1.2, th, tw + 2), CFrame.new(x + side * tw / 2, y + th / 2, 0), "IslandFrame")
		b:box("TwinGlow", Vector3.new(0.8, th - 6, 0.8), CFrame.new(x - side * tw / 2, y + th / 2, -tw / 2), neon)
		b:box("TwinTop", Vector3.new(tw + 1.4, 1.4, tw + 1.4), CFrame.new(x, y + th, 0), "IslandFrame")
		if i == 1 then antenna(b, y + th, rng:NextNumber(10, 20), neon) end
	end
	for k = 1, 3 do
		local by = y + heights[2] * (0.3 + 0.2 * k)
		b:rod("SkyTube", w * 0.25, 5, CFrame.new(0, by, 0), "IslandGlass6")
		b:rod("SkyTubeGlow", w * 0.25, 5.4, CFrame.new(0, by - 1.5, 0), neon, {Transparency = 0.6})
	end
end

-- F: megatower: twisting floors with neon ribs spiralling around the corners, two sky
-- gardens and a stepped crown with a halo and a spire
local function megaTower(b, w, h, rng, glass, neon)
	local y = podium(b, w, glass, neon)
	local segH = 20
	local n = math.floor((h - y - 40) / segH)
	local twist = math.rad(rng:NextNumber(3.5, 5.5)) * (rng:NextNumber() < 0.5 and -1 or 1)
	local prev
	for i = 0, n - 1 do
		local t = i / math.max(n - 1, 1)
		local size = w * (1 - 0.25 * math.sin(t * math.pi * 0.85)) * (1 - 0.12 * t)
		local turn = CFrame.Angles(0, i * twist, 0)
		b:box("MegaFloor", Vector3.new(size, segH - 1, size), CFrame.new(0, y + segH / 2, 0) * turn, glass)
		b:box("MegaPlate", Vector3.new(size + 1.6, 1, size + 1.6), CFrame.new(0, y, 0) * turn, "IslandFrame")
		if i % 2 == 0 then
			local corners = {}
			for k = 0, 3 do
				local a = math.rad(45 + k * 90)
				corners[k + 1] = (CFrame.new(0, y, 0) * turn * CFrame.new(math.cos(a) * size * 0.72, 0, math.sin(a) * size * 0.72)).Position
			end
			if prev then
				for k = 1, 4 do
					local p0, p1 = prev[k], corners[k]
					b:rod("MegaRib", (p1 - p0).Magnitude + 0.6, 1, Architecture.alongX((p0 + p1) / 2, p1 - p0), neon)
				end
			end
			prev = corners
		end
		if i == math.floor(n / 3) or i == math.floor(n * 2 / 3) then
			b:disc("SkyGarden", size * 1.45, 1.4, CFrame.new(0, y + 0.5, 0), "IslandFrame")
			for k = 1, 6 do
				local a = math.pi * 2 * k / 6
				b:ball("GardenTree", 4, CFrame.new(math.cos(a) * size * 0.6, y + 3.4, math.sin(a) * size * 0.6), "IslandLeaf")
			end
		end
		y += segH
	end
	local _, crownH = b:tiers("MegaCrown", CFrame.new(0, y, 0) * CFrame.Angles(0, n * twist, 0), {
		{w * 0.6, 4, "IslandFrame"}, {w * 0.46, 4, glass}, {w * 0.3, 8, glass .. "Core"},
	})
	b:ring("MegaHalo", CFrame.new(0, y + crownH + 5, 0) * CFrame.Angles(math.rad(90), 0, 0), w * 0.3, 1, neon, 24)
	antenna(b, y + crownH, 30, neon)
end

local STYLES = {setbackTower, twistTower, cylinderTower, shearTower, twinTower}

---------------------------------------------------------------------
-- PLACE THE TOWERS
---------------------------------------------------------------------
local function planTowers(rng)
	local plan = {}
	for ringIndex, ring in ipairs(RINGS) do
		local angle = rng:NextNumber(0, 0.1)
		while angle < math.pi * 2 - 0.05 do
			local w = rng:NextNumber(ring.Width[1], ring.Width[2])
			local center = angle + (w / 2) / ring.Radius
			-- keep the avenues clear
			local blocked = false
			for _, deg in ipairs(AVENUE_ANGLES) do
				if angleDiff(center, math.rad(deg)) * ring.Radius < AVENUE_HALF_WIDTH + w * 0.75 then
					blocked = true
					break
				end
			end
			if not blocked then
				-- a gentle skyline wave so the heights feel designed, not random
				local wave = 0.8 + 0.2 * (math.sin(center * 3 + ringIndex) + 1)
				local h = rng:NextNumber(ring.Height[1], ring.Height[2]) * wave
				table.insert(plan, {Angle = center, Radius = ring.Radius + rng:NextNumber(-5, 5), Width = w, Height = h, Ring = ringIndex})
				angle += (w + GAP) / ring.Radius
			else
				angle += 6 / ring.Radius
			end
		end
	end
	-- the tallest outer-ring spots become megatowers
	local outer = {}
	for _, t in ipairs(plan) do
		if t.Ring == #RINGS then table.insert(outer, t) end
	end
	table.sort(outer, function(a, c) return a.Height > c.Height end)
	for i = 1, math.min(MEGA_COUNT, #outer) do
		outer[i].Mega = true
		outer[i].Height = math.max(outer[i].Height, 420) + 60
	end
	return plan
end

function MainIsland.build(parent)
	local rng = Random.new(2050)
	local island = Instance.new("Model")
	island.Name = "MainIsland"
	island:SetAttribute("NoCalm", true) -- its glow is already tuned; MapStyle leaves it alone

	buildTerrain(rng)
	local ground = Instance.new("Model")
	ground.Name = "Ground"
	ground.Parent = island
	buildGround(Architecture.builder(ground, CFrame.new()), rng)
	-- pave the terrain under roads and walkways: grass blades would poke up through them
	local PAVED = {Boulevard = true, SidewalkIn = true, SidewalkOut = true, Avenue = true, MuseumWalk = true, EdgeCurb = true}
	for _, part in ipairs(ground:GetChildren()) do
		if PAVED[part.Name] then
			local pos = part.Position
			terrain:FillBlock(CFrame.new(pos.X, -2, pos.Z) * part.CFrame.Rotation, Vector3.new(part.Size.X + 2, 4, part.Size.Z + 2), Enum.Material.Slate)
		elseif part.Name == "Lookout" then
			terrain:FillCylinder(CFrame.new(part.Position.X, -2, part.Position.Z), 4, part.Size.Y / 2 + 1, Enum.Material.Slate)
		end
	end
	for _, part in ipairs(ground:GetChildren()) do
		if part.Name == "EdgeBarrier" then
			part.Transparency = 1
			part.CanQuery = false
			part.CastShadow = false
		end
	end

	local towers = Instance.new("Model")
	towers.Name = "Skyscrapers"
	towers.Parent = island
	for i, t in ipairs(planTowers(rng)) do
		local model = Instance.new("Model")
		model.Name = t.Mega and "MegaTower" or "Skyscraper"
		local towerRng = Random.new(i * 7919)
		local b = Architecture.builder(model, facingCenter(t.Angle, t.Radius))
		local glass = pick(towerRng, glassNames)
		local neon = pick(towerRng, neonNames)
		if t.Mega then
			megaTower(b, t.Width, t.Height, towerRng, glass, neon)
		else
			STYLES[towerRng:NextInteger(1, #STYLES)](b, t.Width, t.Height, towerRng, glass, neon)
		end
		model.Parent = towers
	end

	island.Parent = parent or workspace
	return island
end

return MainIsland
]=])
install(game:GetService("ServerScriptService"), "MapStyle", "Script", [=[
-- MapStyle (Script in ServerScriptService)
-- Gives the whole map the cartoony 2050 look when the server starts:
-- builds the compact main island and its skyline (MainIsland), restyles the dig site, brightens the ground and the sky, and sets
-- calm, clean lighting (soft shadows, very little bloom, glow only on small accents).

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local MainIsland = require(script.Parent:WaitForChild("MainIsland"))
local DigSiteStyle = require(script.Parent:WaitForChild("DigSiteStyle"))
local Architecture = require(script.Parent:WaitForChild("Architecture"))

-- Set to false to keep the place's own sky and time of day (the calm lighting still applies)
local SUNNY_SKY = true

---------------------------------------------------------------------
-- GROUND: World 1 is now a compact floating island (MainIsland) instead of the old sprawling
-- city on big baseplates, so those are removed and the island is built in their place.
---------------------------------------------------------------------
for _, part in ipairs(workspace:GetChildren()) do
	if part:IsA("BasePart") and part.Name:find("^Baseplate") then
		part:Destroy()
	end
end
local oldCity = workspace:FindFirstChild("City")
if oldCity then oldCity:Destroy() end
local spawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")
if spawnLocation then
	spawnLocation.Material = Enum.Material.SmoothPlastic
	spawnLocation.Color = Color3.fromRGB(178, 158, 255)
end

-- Terrain colors: bright cartoon grass on top, soft stone walls, warm dig layers, plus the
-- ground materials of worlds 2-9 (see WorldsData.TerrainColors)
local terrain = workspace.Terrain
for materialName, color in pairs(GameConfig.TerrainColors) do
	terrain:SetMaterialColor(Enum.Material[materialName], color)
end

---------------------------------------------------------------------
-- MAIN ISLAND + DIG SITE
---------------------------------------------------------------------
MainIsland.build()
workspace:SetAttribute("MainIslandReady", true) -- DigManager fills the pit after this
local digSite = workspace:FindFirstChild("DigSite")
if digSite then
	DigSiteStyle(digSite, GameConfig.Worlds[1])
end

---------------------------------------------------------------------
-- SKY: clear afternoon with soft shadows and fluffy clouds
---------------------------------------------------------------------
if SUNNY_SKY then
	Lighting.ClockTime = 14.5
	Lighting.GeographicLatitude = 35

	-- the place's night skybox doesn't fit a sunny day; Roblox's default sky does
	local sky = Lighting:FindFirstChildOfClass("Sky")
	if sky then sky:Destroy() end

	local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds") or Instance.new("Clouds")
	clouds.Cover = 0.5
	clouds.Density = 0.6
	clouds.Color = Color3.fromRGB(250, 250, 255)
	clouds.Parent = workspace.Terrain
end

---------------------------------------------------------------------
-- CALM LIGHTING: clean daylight, real shadows, almost no bloom or haze
---------------------------------------------------------------------
Lighting.Brightness = 2
Lighting.ExposureCompensation = -0.1
Lighting.Ambient = Color3.fromRGB(92, 92, 108)          -- shade indoors / under roofs
Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 144) -- shade outdoors: keeps shadows readable
Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
Lighting.EnvironmentDiffuseScale = 0.4
Lighting.EnvironmentSpecularScale = 0.15 -- less mirror-like shine on everything
Lighting.GlobalShadows = true
Lighting.ShadowSoftness = 0.3

local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atmosphere.Density = 0.22
atmosphere.Offset = 0.1
atmosphere.Color = Color3.fromRGB(200, 210, 235)
atmosphere.Decay = Color3.fromRGB(120, 132, 170)
atmosphere.Glare = 0
atmosphere.Haze = 0.4
atmosphere.Parent = Lighting

-- one gentle bloom only (the place had two stacked on top of each other)
local keptBloom = false
for _, effect in ipairs(Lighting:GetChildren()) do
	if effect:IsA("BloomEffect") then
		if keptBloom then
			effect:Destroy()
		else
			keptBloom = true
			effect.Enabled = true
			effect.Intensity = 0.12
			effect.Size = 16
			effect.Threshold = 2.4 -- only the brightest pixels bloom
		end
	elseif effect:IsA("SunRaysEffect") then
		effect.Intensity = 0.02
		effect.Spread = 0.3
	elseif effect:IsA("DepthOfFieldEffect") then
		effect.Enabled = false -- keeps the cartoon look crisp
	end
end
local grade = Lighting:FindFirstChild("Cartoon2050Grade") or Instance.new("ColorCorrectionEffect")
grade.Name = "Cartoon2050Grade"
grade.Saturation = 0.05
grade.Contrast = 0.06
grade.Brightness = 0
grade.TintColor = Color3.fromRGB(255, 255, 255)
grade.Parent = Lighting

-- Tone down glowing parts and lights everywhere. Runs again after a few seconds so it
-- also catches the Shovel Shops and World Gates that DigManager builds on start.
local function calmWorld()
	for _, child in ipairs(workspace:GetChildren()) do
		local isCharacter = child:IsA("Model") and game:GetService("Players"):GetPlayerFromCharacter(child)
		if not isCharacter and not child:GetAttribute("NoCalm") then
			Architecture.calm(child)
		end
	end
end
calmWorld()
task.delay(5, calmWorld)

print("MapStyle: cartoony 2050 skyline, dig site and sky ready")
]=])
install(game:GetService("ServerScriptService"), "MuseumBuilder", "ModuleScript", [=[
-- MuseumBuilder (ModuleScript in ServerScriptService)
-- Builds the player museum from code: a compact, three-storey 2050 gallery (64 x 64 studs,
-- floors every 22 studs) instead of a huge simulator hall. White walls with rounded capsule
-- corners, a glass curtain front with glowing floor bands, a round portal entrance under a
-- saucer canopy, a glass dome with a halo on the roof, and a plaza with the Alien Art Dealer's
-- kiosk out front.
--
-- Inside, each floor has 8 display alcoves around the walls (24 slots in total) and a glowing
-- lift pad in the middle (the on-screen arrows teleport between the pads).
--
-- The parts keep the names the other scripts look for:
--   Slots/Slot1..24     AlcovePanel, AlcoveGlow, FactScreen (2 labels), FactGlow, GlowRing,
--                       RingCover, Step, Column, Band, Cap, Plaque, DisplaySpot (InfoGui with
--                       NameLabel + IncomeLabel) and ViewSpot (where visitors stand)
--   Arrivals/FloorNArrival, AlienDealer/Counter, Exterior/EntranceSign (TitleLabel, SubLabel)
--   Interior (invisible box around the floors), SpawnPoint, Waypoints/Outside, Door, Lobby
-- Local layout: the entrance faces -Z, ground level is y = 0, and the pivot sits on the plot.
-- Returns a function() -> Model (PlotManager clones it for each player).

local Architecture = require(script.Parent:WaitForChild("Architecture"))
local P = Architecture.Palette

local rgb = Color3.fromRGB
local HALF = 32          -- half the building width/depth
local FLOOR_H = 22       -- height of one storey
local FLOORS = 3
local WALL = 1.4
local ROOF_Y = FLOOR_H * FLOORS

P.MuseumGlass = {Color = rgb(170, 220, 255), Material = Enum.Material.Glass, Transparency = 0.35, Reflectance = 0.2}
P.MuseumTile = {Color = rgb(236, 232, 252), Material = Enum.Material.SmoothPlastic}
P.MuseumWall = {Color = rgb(248, 248, 253), Material = Enum.Material.SmoothPlastic}
P.MuseumAlcove = {Color = rgb(32, 30, 64), Material = Enum.Material.SmoothPlastic}
P.MuseumAlcoveGlow = {Color = rgb(150, 130, 255), Material = Enum.Material.Neon}
P.MuseumGold = {Color = rgb(255, 214, 110), Material = Enum.Material.Metal, Reflectance = 0.1}
P.AlienSkin = {Color = rgb(120, 220, 120), Material = Enum.Material.SmoothPlastic}

---------------------------------------------------------------------
-- HELPERS
---------------------------------------------------------------------
local function marker(parent, name, cf, size)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Transparency = 1
	p.Size = size or Vector3.new(4, 1, 4)
	p.CFrame = cf
	p.Parent = parent
	return p
end

local function textLabel(parent, name, text, pos, size, color, font)
	local l = Instance.new("TextLabel")
	l.Name = name
	l.BackgroundTransparency = 1
	l.Position = pos
	l.Size = size
	l.Text = text
	l.TextScaled = true
	l.TextColor3 = color
	l.Font = font or Enum.Font.FredokaOne
	l.Parent = parent
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = rgb(24, 20, 60)
	stroke.Transparency = 0.3
	stroke.Parent = l
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0.04, 0)
	pad.PaddingRight = UDim.new(0.04, 0)
	pad.Parent = l
	return l
end

local function surface(part, face)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face or Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0
	gui.Parent = part
	return gui
end

---------------------------------------------------------------------
-- ONE DISPLAY SLOT (slotCF: at the pedestal, on the floor, -Z facing into the room)
---------------------------------------------------------------------
local function buildSlot(parent, index, floor, slotCF)
	local slot = Instance.new("Model")
	slot.Name = "Slot" .. index
	slot:SetAttribute("SlotIndex", index)
	slot:SetAttribute("Floor", floor)
	local b = Architecture.builder(slot, slotCF)

	-- wall alcove with a glowing frame and the fact screen above the pedestal
	b:box("AlcoveGlow", Vector3.new(12.8, 16.8, 0.3), CFrame.new(0, 9.4, 5.4), "MuseumAlcoveGlow")
	b:box("AlcovePanel", Vector3.new(12, 16, 0.4), CFrame.new(0, 9.4, 5.2), "MuseumAlcove")
	b:box("FactGlow", Vector3.new(9.6, 4.8, 0.2), CFrame.new(0, 14.6, 4.95), "MuseumAlcoveGlow")
	local screen = b:box("FactScreen", Vector3.new(9, 4.2, 0.3), CFrame.new(0, 14.6, 4.85), "Ink")
	local gui = surface(screen)
	textLabel(gui, "Label", "EMPTY DISPLAY", UDim2.fromScale(0, 0.06), UDim2.fromScale(1, 0.44), rgb(190, 170, 255))
	textLabel(gui, "Label", "Put a meme here to earn money every second!", UDim2.fromScale(0, 0.52), UDim2.fromScale(1, 0.42), rgb(235, 235, 250), Enum.Font.GothamMedium)

	-- round pedestal: glowing ring on the floor, a white step, a column with a light band, a dark cap
	local flat = CFrame.Angles(0, 0, math.rad(90)) -- cylinders stand upright
	b:box("GlowRing", Vector3.new(0.3, 9, 9), CFrame.new(0, 0.75, 0) * flat, "GlowCyan", {Shape = Enum.PartType.Cylinder})
	b:box("RingCover", Vector3.new(0.34, 8.2, 8.2), CFrame.new(0, 0.8, 0) * flat, "White", {Shape = Enum.PartType.Cylinder})
	b:box("Step", Vector3.new(1, 7, 7), CFrame.new(0, 1.2, 0) * flat, "Cloud", {Shape = Enum.PartType.Cylinder})
	b:box("Column", Vector3.new(4.6, 3.6, 3.6), CFrame.new(0, 3.9, 0) * flat, "White", {Shape = Enum.PartType.Cylinder})
	b:box("Band", Vector3.new(0.4, 3.9, 3.9), CFrame.new(0, 4.6, 0) * flat, "GlowCyan", {Shape = Enum.PartType.Cylinder})
	local cap = b:box("Cap", Vector3.new(0.6, 5, 5), CFrame.new(0, 6.5, 0) * flat, "Ink", {Shape = Enum.PartType.Cylinder})
	local light = Instance.new("PointLight")
	light.Range = 10
	light.Brightness = 0.6
	light.Color = rgb(200, 220, 255)
	light.Parent = cap

	-- where the meme card floats, with its name tag
	local spot = b:box("DisplaySpot", Vector3.new(1, 1, 1), CFrame.new(0, 8.6, 0), "White", {Transparency = 1, CanCollide = false, CanQuery = false})
	local info = Instance.new("BillboardGui")
	info.Name = "InfoGui"
	info.Size = UDim2.fromScale(9, 2.4)
	info.StudsOffset = Vector3.new(0, 5.2, 0)
	info.MaxDistance = 60
	info.LightInfluence = 0
	info.Parent = spot
	textLabel(info, "NameLabel", "EMPTY", UDim2.fromScale(0, 0), UDim2.fromScale(1, 0.58), rgb(190, 170, 255))
	textLabel(info, "IncomeLabel", "", UDim2.fromScale(0, 0.58), UDim2.fromScale(1, 0.42), rgb(120, 230, 140))

	-- little plaque on a slanted stand, and a glowing rope line in front
	b:box("PlaqueStand", Vector3.new(0.4, 2, 0.4), CFrame.new(0, 1, -4.6), "Chrome")
	local plaque = b:box("Plaque", Vector3.new(4.2, 1.5, 0.3), CFrame.new(0, 2.2, -4.7) * CFrame.Angles(math.rad(-30), 0, 0), "Ink")
	textLabel(surface(plaque), "Label", "EMPTY SLOT " .. index, UDim2.fromScale(0, 0.1), UDim2.fromScale(1, 0.8), rgb(235, 235, 250))
	for _, x in ipairs({-4.6, 4.6}) do
		b:pill("RopePost", Vector3.new(x, 0.6, -5.4), Vector3.new(x, 3, -5.4), 0.5, "MuseumGold")
	end
	b:box("Rope", Vector3.new(9.2, 0.18, 0.18), CFrame.new(0, 2.6, -5.4), "GlowPink", {CanCollide = false})

	-- where visitors stand to look
	marker(slot, "ViewSpot", slotCF * CFrame.new(0, 3, -8.5))
	slot.Parent = parent
	return slot
end

-- pedestal spots on one floor: 3 along each side wall, 2 on the back wall
local SLOT_SPOTS = {
	{Vector3.new(-25, 0, -16), Vector3.xAxis}, {Vector3.new(-25, 0, 0), Vector3.xAxis}, {Vector3.new(-25, 0, 16), Vector3.xAxis},
	{Vector3.new(-12, 0, 25), -Vector3.zAxis}, {Vector3.new(12, 0, 25), -Vector3.zAxis},
	{Vector3.new(25, 0, 16), -Vector3.xAxis}, {Vector3.new(25, 0, 0), -Vector3.xAxis}, {Vector3.new(25, 0, -16), -Vector3.xAxis},
}

---------------------------------------------------------------------
-- THE BUILDING
---------------------------------------------------------------------
local function build()
	local museum = Instance.new("Model")
	museum.Name = "MuseumTemplate"
	local exterior = Instance.new("Folder")
	exterior.Name = "Exterior"
	exterior.Parent = museum
	local floorsFolder = Instance.new("Folder")
	floorsFolder.Name = "Floors"
	floorsFolder.Parent = museum
	local slots = Instance.new("Folder")
	slots.Name = "Slots"
	slots.Parent = museum
	local arrivals = Instance.new("Folder")
	arrivals.Name = "Arrivals"
	arrivals.Parent = museum
	local waypoints = Instance.new("Folder")
	waypoints.Name = "Waypoints"
	waypoints.Parent = museum

	local ex = Architecture.builder(exterior, CFrame.new())
	local fl = Architecture.builder(floorsFolder, CFrame.new())

	-- FOUNDATION + PLAZA
	ex:roundedBlock("Foundation", Vector3.new(HALF * 2 + 6, 1.2, HALF * 2 + 6), CFrame.new(0, 0.1, 0), 6, "Lilac")
	ex:roundedBlock("Plaza", Vector3.new(76, 0.6, 30), CFrame.new(0, 0.3, -HALF - 16), 10, "MuseumTile")
	ex:roundedBlock("PlazaInlay", Vector3.new(60, 0.64, 18), CFrame.new(0, 0.32, -HALF - 16), 8, "Cloud")
	ex:box("PlazaGlow", Vector3.new(16, 0.66, 0.5), CFrame.new(0, 0.33, -HALF - 16), "GlowCyan")
	for _, x in ipairs({-30, 30}) do
		-- planters with round topiary and a lamp
		ex:tiers("Planter", CFrame.new(x, 0.6, -HALF - 22), {{7, 1.6, "White"}, {6, 0.4, "Mint"}})
		ex:ball("Topiary", 5, CFrame.new(x, 4.6, -HALF - 22), "Mint")
		ex:pill("LampPost", Vector3.new(x * 0.62, 0.6, -HALF - 26), Vector3.new(x * 0.62, 11, -HALF - 26), 0.6, "White")
		ex:bulb("LampGlow", 1.8, CFrame.new(x * 0.62, 12, -HALF - 26), "GlowSun", 16)
	end
	-- benches along the plaza
	for _, x in ipairs({-12, 12}) do
		ex:roundedBlock("Bench", Vector3.new(7, 0.8, 2.2), CFrame.new(x, 1.6, -HALF - 27), 1, "Sky")
		ex:box("BenchLeg", Vector3.new(5, 1.2, 1), CFrame.new(x, 0.8, -HALF - 27), "White")
	end

	-- FLOORS: slabs, ceiling lights, lift pads, arrivals
	for f = 1, FLOORS do
		local base = (f - 1) * FLOOR_H
		fl:box("FloorSlab", Vector3.new(HALF * 2 - WALL, f == 1 and 0.8 or 1.2, HALF * 2 - WALL), CFrame.new(0, base + (f == 1 and 0.6 or 0), 0), "MuseumTile")
		fl:ring("FloorInlay", CFrame.new(0, base + 0.72, 4) * CFrame.Angles(math.rad(90), 0, 0), 11, 0.5, "GlowCyan", 32)
		-- the lift pad: step onto it and use the arrows
		fl:tiers("LiftPad", CFrame.new(0, base + 0.6, 4), {{8, 0.3, "Violet"}, {6.6, 0.3, "GlowCyan"}})
		marker(arrivals, "Floor" .. f .. "Arrival", CFrame.new(0, base + 3.5, 4))
		-- soft ceiling light panels (the next slab is the ceiling)
		for _, x in ipairs({-12, 12}) do
			fl:roundedBlock("CeilingLight", Vector3.new(10, 0.3, 30), CFrame.new(x, base + FLOOR_H - 0.8, 0), 3, "White")
			local strip = fl:box("CeilingGlow", Vector3.new(0.6, 0.35, 28), CFrame.new(x, base + FLOOR_H - 0.9, 0), "GlowCyan")
			local l = Instance.new("SurfaceLight")
			l.Face = Enum.NormalId.Bottom
			l.Range = 18
			l.Brightness = 0.7
			l.Color = rgb(235, 240, 255)
			l.Parent = strip
		end
		local floorTop = base + (f == 1 and 1 or 0.6)
		for i, spot in ipairs(SLOT_SPOTS) do
			local pos = Vector3.new(spot[1].X, floorTop - 0.6, spot[1].Z)
			-- turn so the slot's front (-Z) faces into the room
			local facing = spot[2]
			buildSlot(slots, (f - 1) * #SLOT_SPOTS + i, f, CFrame.new(pos) * CFrame.Angles(0, math.atan2(-facing.X, -facing.Z), 0))
		end
	end
	fl:box("RoofSlab", Vector3.new(HALF * 2 + 2, 1.6, HALF * 2 + 2), CFrame.new(0, ROOF_Y + 0.8, 0), "White")

	-- WALLS: solid white sides and back with glass window strips, a glass front
	local wallX = HALF - WALL / 2
	for _, side in ipairs({-1, 1}) do
		ex:box("SideWall", Vector3.new(WALL, ROOF_Y, HALF * 2), CFrame.new(side * wallX, ROOF_Y / 2, 0), "MuseumWall")
		for f = 1, FLOORS do
			local y = (f - 1) * FLOOR_H + 17.5
			ex:box("SideWindow", Vector3.new(0.6, 3, HALF * 2 - 16), CFrame.new(side * (HALF + 0.05), y, 0), "MuseumGlass")
			ex:box("SideWindowTrim", Vector3.new(0.7, 0.4, HALF * 2 - 14), CFrame.new(side * (HALF + 0.1), y - 1.7, 0), "GlowCyan")
		end
		-- vertical lilac fins
		for _, z in ipairs({-12, 12}) do
			ex:roundedBlock("Fin", Vector3.new(2.4, ROOF_Y - 4, 2.4), CFrame.new(side * (HALF + 1), ROOF_Y / 2, z), 1.1, "Lilac")
		end
	end
	ex:box("BackWall", Vector3.new(HALF * 2, ROOF_Y, WALL), CFrame.new(0, ROOF_Y / 2, wallX), "MuseumWall")
	-- front: glass curtain on floors 2-3, glass panels either side of the entrance on floor 1
	local frontZ = -wallX
	ex:box("FrontGlass", Vector3.new(HALF * 2 - 4, FLOOR_H * 2, 0.8), CFrame.new(0, FLOOR_H * 2, frontZ), "MuseumGlass")
	for _, side in ipairs({-1, 1}) do
		ex:box("FrontGlassLow", Vector3.new(HALF - 9, FLOOR_H, 0.8), CFrame.new(side * (HALF / 2 + 4.5), FLOOR_H / 2, frontZ), "MuseumGlass")
		ex:box("EntranceJamb", Vector3.new(2, 14, 1.6), CFrame.new(side * 8, 7, frontZ), "White")
	end
	ex:box("AboveEntrance", Vector3.new(18, FLOOR_H - 14, 0.8), CFrame.new(0, 14 + (FLOOR_H - 14) / 2, frontZ), "MuseumGlass")
	-- mullions and glowing floor bands across the front
	for i = -3, 3 do
		if i == 0 then continue end -- keep the doorway clear
		ex:box("Mullion", Vector3.new(0.5, ROOF_Y, 1.2), CFrame.new(i * 9, ROOF_Y / 2, frontZ - 0.2), "White", {CanCollide = false})
	end
	for f = 1, FLOORS - 1 do
		ex:box("FloorFascia", Vector3.new(HALF * 2, 1.6, 1.4), CFrame.new(0, f * FLOOR_H, frontZ - 0.4), "White")
		ex:box("FloorBand", Vector3.new(HALF * 2 - 2, 0.4, 0.3), CFrame.new(0, f * FLOOR_H - 1.1, frontZ - 1.1), "GlowCyan")
	end
	-- capsule corners
	for _, sx in ipairs({-1, 1}) do
		for _, sz in ipairs({-1, 1}) do
			local x, z = sx * HALF, sz * HALF
			ex:disc("CornerCapsule", 6, ROOF_Y + 2, CFrame.new(x, (ROOF_Y + 2) / 2, z), "Lilac")
			ex:ball("CornerDome", 6, CFrame.new(x, ROOF_Y + 2, z), "Violet")
			for f = 1, FLOORS do
				ex:disc("CornerBand", 6.3, 0.5, CFrame.new(x, (f - 1) * FLOOR_H + 17.5, z), "GlowPink")
			end
		end
	end

	-- ENTRANCE: round portal, saucer canopy
	local portal = CFrame.new(0, 7, frontZ - 1.2)
	ex:ring("PortalRing", portal, 8.4, 1.8, "White", 24, 180, 0)
	ex:ring("PortalGlow", portal * CFrame.new(0, 0, -0.9), 7.4, 0.4, "GlowCyan", 24, 180, 0)
	ex:ellipsoid("Canopy", Vector3.new(26, 2.4, 12), CFrame.new(0, 16.5, frontZ - 5), "White")
	ex:ellipsoid("CanopyUnder", Vector3.new(25, 1.4, 11), CFrame.new(0, 15.9, frontZ - 5), "Sky")
	for i = -2, 2 do
		ex:bulb("CanopyBulb", 0.9, CFrame.new(i * 4.5, 15.2, frontZ - 8.5), i % 2 == 0 and "GlowSun" or "GlowPink", 0)
	end

	-- ROOF: parapet, glass dome with a halo, and the big sign
	ex:roundedBlock("Parapet", Vector3.new(HALF * 2 + 3, 2.4, HALF * 2 + 3), CFrame.new(0, ROOF_Y + 2.6, 0), 4, "Lilac")
	ex:ellipsoid("Dome", Vector3.new(36, 18, 36), CFrame.new(0, ROOF_Y + 1.6, 4), "MuseumGlass")
	ex:ring("DomeHalo", CFrame.new(0, ROOF_Y + 13, 4) * CFrame.Angles(math.rad(90), 0, 0), 12, 0.9, "GlowCyan", 32)
	ex:pill("DomeSpire", Vector3.new(0, ROOF_Y + 10, 4), Vector3.new(0, ROOF_Y + 20, 4), 0.8, "Chrome")
	ex:bulb("DomeBeacon", 2, CFrame.new(0, ROOF_Y + 21, 4), "GlowPink", 20)
	ex:roundedBlock("SignBack", Vector3.new(44, 9, 1.4), CFrame.new(0, ROOF_Y + 8, frontZ + 1), 3, "Violet")
	local sign = ex:roundedBlock("EntranceSign", Vector3.new(42, 7.6, 1.6), CFrame.new(0, ROOF_Y + 8, frontZ + 0.8), 2.6, "Ink")
	sign.Name = "EntranceSign"
	local signGui = surface(sign)
	textLabel(signGui, "TitleLabel", "MEME MUSEUM 2050", UDim2.fromScale(0, 0.06), UDim2.fromScale(1, 0.56), rgb(255, 222, 110))
	textLabel(signGui, "SubLabel", "EST. 2050", UDim2.fromScale(0, 0.62), UDim2.fromScale(1, 0.32), rgb(150, 230, 255))
	ex:box("SignGlow", Vector3.new(42, 0.4, 1.8), CFrame.new(0, ROOF_Y + 3.9, frontZ + 0.8), "GlowSun")

	-- ALIEN ART DEALER kiosk on the plaza (left of the entrance)
	local dealer = Instance.new("Model")
	dealer.Name = "AlienDealer"
	dealer.Parent = museum
	local dealerCF = CFrame.new(-24, 0.6, -HALF - 10) * CFrame.Angles(0, math.rad(-20), 0)
	local d = Architecture.builder(dealer, dealerCF)
	d:tiers("KioskBase", CFrame.new(), {{14, 0.6, "Violet"}, {12.6, 0.3, "GlowPink"}})
	local counter = d:roundedBlock("Counter", Vector3.new(10, 3.6, 3), CFrame.new(0, 2.7, -2.5), 1.2, "Mint")
	counter.Name = "Counter"
	d:roundedBlock("CounterTop", Vector3.new(10.6, 0.5, 3.6), CFrame.new(0, 4.7, -2.5), 1.4, "White")
	for _, x in ipairs({-5.5, 5.5}) do
		d:pill("KioskPole", Vector3.new(x, 0.9, 1.5), Vector3.new(x, 11, 1.5), 0.7, "White")
	end
	d:ellipsoid("KioskRoof", Vector3.new(15, 2.4, 9), CFrame.new(0, 11.6, 0), "Mint")
	local kioskSign = d:roundedBlock("KioskSign", Vector3.new(10, 2.6, 0.6), CFrame.new(0, 13.8, 0), 1, "Ink")
	textLabel(surface(kioskSign), "Label", "👽 ALIEN ART DEALER", UDim2.fromScale(0, 0.1), UDim2.fromScale(1, 0.8), rgb(150, 255, 200))
	-- the dealer: a friendly alien behind the counter
	d:ellipsoid("AlienBody", Vector3.new(3, 4, 2.6), CFrame.new(0, 5.2, 0.4), "Violet")
	d:ellipsoid("AlienHead", Vector3.new(3.8, 3.4, 3.4), CFrame.new(0, 8.4, 0.4), "AlienSkin")
	for _, x in ipairs({-0.8, 0.8}) do
		d:ellipsoid("AlienEye", Vector3.new(1, 1.4, 0.6), CFrame.new(x, 8.6, -1.1) * CFrame.Angles(0, 0, x * 0.3), "Ink")
		d:pill("AlienAntenna", Vector3.new(x * 0.8, 9.8, 0.4), Vector3.new(x * 1.6, 11.2, 0.4), 0.25, "AlienSkin")
		d:bulb("AntennaTip", 0.6, CFrame.new(x * 1.6, 11.3, 0.4), "GlowSun", 0)
	end

	-- MARKERS for scripts
	local interior = marker(museum, "Interior", CFrame.new(0, ROOF_Y / 2, 0), Vector3.new(HALF * 2 - 3, ROOF_Y, HALF * 2 - 3))
	interior:SetAttribute("FloorHeight", FLOOR_H)
	marker(museum, "SpawnPoint", CFrame.lookAt(Vector3.new(0, 3.5, -HALF - 20), Vector3.new(0, 3.5, 0)))
	marker(waypoints, "Outside", CFrame.new(0, 3, -HALF - 22), Vector3.new(24, 1, 8))
	marker(waypoints, "Door", CFrame.new(0, 3, -HALF + 2))
	marker(waypoints, "Lobby", CFrame.new(0, 3, -HALF + 12), Vector3.new(10, 1, 4))

	-- decorative rings and ropes shouldn't trip anyone up
	local NO_COLLIDE = {FloorInlay = true, Rope = true, DomeHalo = true, PortalGlow = true, CanopyBulb = true, PlazaGlow = true}
	for _, part in ipairs(museum:GetDescendants()) do
		if part:IsA("BasePart") and NO_COLLIDE[part.Name] then
			part.CanCollide = false
		end
	end

	museum.WorldPivot = CFrame.new(0, 0.5, 0) -- the plot part's center sits half a stud above the ground
	return museum
end

return build
]=])
install(game:GetService("ServerScriptService"), "MuseumManager", "Script", [=[
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
]=])
install(game:GetService("ServerScriptService"), "PlayerData", "ModuleScript", [=[
-- PlayerData (ModuleScript in ServerScriptService)
-- Loads and saves each player's progress with ProfileService (session-locked, auto-saving,
-- safe against two servers editing the same save), pays passive income every second from
-- the memes on display, gives offline earnings, and lets other server scripts change the
-- data safely. Museum slot and floor purchases go through UnlockSlot/UnlockFloor here
-- (MuseumManager checks the price and takes the money first).

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local ProfileService = require(script.Parent:WaitForChild("ProfileService"))

local STORE_NAME = "PlayerProfiles_v1" -- change the version to wipe everyone's data (e.g. before launch)
local OLD_STORE_NAME = "PlayerData_v1"  -- saves from before ProfileService; imported once per player
local oldStore = DataStoreService:GetDataStore(OLD_STORE_NAME)

local PlayerData = {}
local sessions = {} -- [player] = data table (the profile's Data, saved automatically)
local profiles = {} -- [player] = ProfileService profile

local changedEvent = Instance.new("BindableEvent")
PlayerData.Changed = changedEvent.Event -- fires (player, data) whenever something changes

---------------------------------------------------------------------
-- DEFAULT DATA FOR NEW PLAYERS
---------------------------------------------------------------------
local function defaultData()
	local unlockedSlots = {}
	for i, price in ipairs(GameConfig.SlotPrices) do
		if price == 0 then
			unlockedSlots[tostring(i)] = true
		end
	end
	return {
		DataVersion = 1,
		Money = GameConfig.StartingMoney,
		Inventory = {},       -- [uniqueId] = artifactId (artifacts not on display)
		NextUid = 1,
		Displayed = {},       -- [slotNumber] = artifactId (artifacts on pedestals)
		UnlockedSlots = unlockedSlots,
		UnlockedFloors = {["1"] = true},
		OwnedShovels = {RustyShovel = true},
		EquippedShovels = {["1"] = "RustyShovel"}, -- [worldId] = shovel id equipped in that world
		UnlockedWorlds = {["1"] = true},
		PermitsRefunded = true, -- new players never bought the old Dig Permits
		LastOnline = os.time(),
		Stats = {TotalEarned = 0, TotalDigs = 0},
	}
end

-- Adds any missing fields to old saves (so future updates don't break old players)
local function reconcile(data, template)
	for key, value in pairs(template) do
		if data[key] == nil then
			data[key] = (type(value) == "table") and table.clone(value) or value
		elseif type(value) == "table" and type(data[key]) == "table" then
			reconcile(data[key], value)
		end
	end
end

-- every new profile starts as a copy of this; Reconcile() adds new fields to old saves
local profileStore = ProfileService.GetProfileStore(STORE_NAME, defaultData())

local function retry(fn)
	for attempt = 1, 3 do
		local ok, result = pcall(fn)
		if ok then
			return true, result
		end
		warn("DataStore error (attempt " .. attempt .. "): " .. tostring(result))
		task.wait(2 ^ attempt)
	end
	return false, nil
end

---------------------------------------------------------------------
-- INCOME + DISPLAY
---------------------------------------------------------------------
local function computeIncome(data)
	local total = 0
	for slot, artifactId in pairs(data.Displayed) do
		local artifact = ArtifactData.GetArtifact(artifactId)
		if artifact and data.UnlockedSlots[slot] then
			total += ArtifactData.GetIncome(artifact)
		end
	end
	return total
end

local function refresh(player)
	local data = sessions[player]
	if not data then return end
	local income = computeIncome(data)
	player:SetAttribute("Money", data.Money)
	player:SetAttribute("Income", income)

	local stats = player:FindFirstChild("leaderstats")
	if stats then
		stats.Cash.Value = ArtifactData.FormatMoney(data.Money)
		stats.Income.Value = ArtifactData.FormatMoney(income) .. "/s"
	end
	changedEvent:Fire(player, data)
end

local function makeLeaderstats(player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local cash = Instance.new("StringValue")
	cash.Name = "Cash"
	cash.Parent = stats
	local income = Instance.new("StringValue")
	income.Name = "Income"
	income.Parent = stats
	stats.Parent = player
end

-- Upgrades saves from before worlds + shovel depth zones existed
local OLD_PERMIT_PRICES = {["2"] = 100000, ["3"] = 250e6} -- the removed Dig Permits
local function migrate(data)
	if data.EquippedShovels == nil then
		data.EquippedShovels = {["1"] = data.EquippedShovel or "RustyShovel"}
	end
	data.EquippedShovel = nil
	-- Depth is now decided by your shovel, so give back what was paid for Dig Permits
	if not data.PermitsRefunded then
		local refund = 0
		for layer, price in pairs(OLD_PERMIT_PRICES) do
			if data.UnlockedLayers and data.UnlockedLayers[layer] then
				refund += price
			end
		end
		data.Money = (data.Money or 0) + refund
		data.PermitsRefunded = true
	end
	data.UnlockedLayers = nil
end

---------------------------------------------------------------------
-- LOAD / SAVE
---------------------------------------------------------------------
local function load(player)
	local key = "Player_" .. player.UserId
	-- "ForceLoad": if another server still holds this save (e.g. the player just hopped
	-- servers), ProfileService asks it to let go and waits, instead of loading stale data
	local profile = profileStore:LoadProfileAsync(key, "ForceLoad")
	if not profile then
		-- Never play on empty data if loading failed, or we'd overwrite their real save
		player:Kick("Couldn't load your museum data. Please rejoin!")
		return
	end
	profile:AddUserId(player.UserId) -- GDPR: lets Roblox erase it on request
	profile:Reconcile()
	profile:ListenToRelease(function()
		profiles[player] = nil
		sessions[player] = nil
		-- the save was taken by another server: this session must stop using it
		if player.Parent then
			player:Kick("Your museum was opened on another server. Please rejoin!")
		end
	end)
	if not player.Parent then
		profile:Release() -- left while loading
		return
	end

	local data = profile.Data
	-- First time on ProfileService: bring over the save from the old DataStore
	local returning = profile.MetaData.SessionLoadCount > 1
	if not data.ImportedOldSave then
		local ok, old = retry(function()
			return oldStore:GetAsync(key)
		end)
		if not ok then
			profile:Release()
			player:Kick("Couldn't load your museum data. Please rejoin!")
			return
		end
		if type(old) == "table" then
			for field, value in pairs(old) do
				data[field] = value
			end
			migrate(data)
			reconcile(data, defaultData())
			returning = true
			print("[LOAD] Imported " .. player.Name .. "'s old save into ProfileService")
		end
		data.ImportedOldSave = true
	end
	migrate(data)

	-- Offline earnings
	if returning then
		local away = math.max(0, os.time() - (data.LastOnline or os.time()))
		local counted = math.min(away, GameConfig.OfflineCapHours * 3600)
		local earned = math.floor(computeIncome(data) * counted * GameConfig.OfflineMultiplier)
		if earned > 0 then
			data.Money += earned
			data.Stats.TotalEarned += earned
			player:SetAttribute("OfflineEarnings", earned)
			print(player.Name .. " earned " .. ArtifactData.FormatMoney(earned) .. " while offline")
		end
	else
		print("[LOAD] New player " .. player.Name .. ", starting fresh")
	end
	data.LastOnline = os.time()

	profiles[player] = profile
	sessions[player] = data
	makeLeaderstats(player)
	refresh(player)
	player:SetAttribute("DataLoaded", true)
	print(player.Name .. "'s data loaded. Money: " .. ArtifactData.FormatMoney(data.Money))
end

-- ProfileService saves on its own every ~30 seconds; releasing does the final save
local function release(player)
	local profile = profiles[player]
	if not profile then return end
	profile.Data.LastOnline = os.time()
	profiles[player] = nil
	sessions[player] = nil
	profile:Release()
end

---------------------------------------------------------------------
-- PUBLIC FUNCTIONS (other server scripts use these)
---------------------------------------------------------------------
function PlayerData.Get(player)
	return sessions[player]
end

function PlayerData.WaitForData(player)
	while player.Parent and not sessions[player] do
		task.wait(0.1)
	end
	return sessions[player]
end

function PlayerData.GetIncome(player)
	local data = sessions[player]
	return data and computeIncome(data) or 0
end

function PlayerData.AddMoney(player, amount)
	local data = sessions[player]
	if not data then return false end
	data.Money += amount
	if amount > 0 then
		data.Stats.TotalEarned += amount
	end
	refresh(player)
	return true
end

-- Returns true if the player could afford it (and takes the money)
function PlayerData.SpendMoney(player, amount)
	local data = sessions[player]
	if not data or data.Money < amount then return false end
	data.Money -= amount
	refresh(player)
	return true
end

-- Adds an artifact to the inventory, returns its unique id
function PlayerData.AddArtifact(player, artifactId)
	local data = sessions[player]
	if not data then return nil end
	local uid = tostring(data.NextUid)
	data.NextUid += 1
	data.Inventory[uid] = artifactId
	refresh(player)
	return uid
end

-- Removes an artifact from the inventory, returns its artifact id
function PlayerData.RemoveArtifact(player, uid)
	local data = sessions[player]
	if not data then return nil end
	local artifactId = data.Inventory[uid]
	data.Inventory[uid] = nil
	refresh(player)
	return artifactId
end

-- Puts an artifact on a slot (or clears it with nil)
function PlayerData.SetDisplayed(player, slotIndex, artifactId)
	local data = sessions[player]
	if not data then return false end
	data.Displayed[tostring(slotIndex)] = artifactId
	refresh(player)
	return true
end

function PlayerData.IsSlotUnlocked(player, slotIndex)
	local data = sessions[player]
	return data ~= nil and data.UnlockedSlots[tostring(slotIndex)] == true
end

function PlayerData.UnlockSlot(player, slotIndex)
	local data = sessions[player]
	if not data then return false end
	data.UnlockedSlots[tostring(slotIndex)] = true
	refresh(player)
	return true
end

function PlayerData.IsFloorUnlocked(player, floor)
	local data = sessions[player]
	return data ~= nil and data.UnlockedFloors[tostring(floor)] == true
end

function PlayerData.UnlockFloor(player, floor)
	local data = sessions[player]
	if not data then return false end
	data.UnlockedFloors[tostring(floor)] = true
	refresh(player)
	return true
end

---------------------------------------------------------------------
-- START EVERYTHING
---------------------------------------------------------------------
Players.PlayerAdded:Connect(load)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(load, player)
end

Players.PlayerRemoving:Connect(release)

-- Pay income every second
task.spawn(function()
	while true do
		task.wait(1)
		for player, data in pairs(sessions) do
			local income = computeIncome(data)
			if income > 0 then
				data.Money += income
				data.Stats.TotalEarned += income
				refresh(player)
			end
		end
	end
end)

-- Autosaving and saving on shutdown are handled by ProfileService (it releases every
-- profile when the server closes).

return PlayerData
]=])
install(game:GetService("ServerScriptService"), "PlotManager", "Script", [=[
-- PlotManager (Script inside ServerScriptService)
-- Gives every player their own museum on a free plot,
-- puts their name on the sign, and spawns them in front of it.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- The museum is built from code (compact 2050 gallery, see MuseumBuilder); every player's
-- museum is a copy of it. (The old ServerStorage.MuseumTemplate is no longer used.)
local template = require(script.Parent:WaitForChild("MuseumBuilder"))()
local plotsFolder = workspace:WaitForChild("Plots")

local museumsFolder = workspace:FindFirstChild("Museums") or Instance.new("Folder")
museumsFolder.Name = "Museums"
museumsFolder.Parent = workspace

local ownedPlots = {}   -- [player] = plot part
local ownedMuseums = {} -- [player] = museum model

local function getSortedPlots()
	local list = plotsFolder:GetChildren()
	table.sort(list, function(a, b)
		return (a:GetAttribute("PlotIndex") or 0) < (b:GetAttribute("PlotIndex") or 0)
	end)
	return list
end

local function findFreePlot()
	for _, plot in ipairs(getSortedPlots()) do
		if plot:GetAttribute("OwnerUserId") == 0 then
			return plot
		end
	end
	return nil
end

-- Spot on the plaza in front of the museum, facing the entrance
local function getSpawnCFrame(plot, museum)
	local spawnPoint = museum and museum:FindFirstChild("SpawnPoint")
	if spawnPoint then
		return spawnPoint.CFrame
	end
	return plot.CFrame * CFrame.new(0, 3.5, -52) * CFrame.Angles(0, math.pi, 0)
end

local function setOwnerSign(museum, player)
	local exterior = museum:FindFirstChild("Exterior")
	local sign = exterior and exterior:FindFirstChild("EntranceSign")
	local gui = sign and sign:FindFirstChildOfClass("SurfaceGui")
	local subLabel = gui and gui:FindFirstChild("SubLabel")
	if subLabel then
		subLabel.Text = string.upper(player.DisplayName) .. "'S COLLECTION  •  EST. 2050"
	end
end

local function sendHome(player)
	local plot = ownedPlots[player]
	local character = player.Character
	if plot and character then
		character:PivotTo(getSpawnCFrame(plot, ownedMuseums[player]))
	end
end

local function onCharacterAdded(player, character)
	character:WaitForChild("HumanoidRootPart")
	-- wait two frames so Roblox finishes its own spawning first
	RunService.Heartbeat:Wait()
	RunService.Heartbeat:Wait()
	sendHome(player)
end

local function onPlayerAdded(player)
	local plot = findFreePlot()
	if not plot then
		warn("No free plot for " .. player.Name)
		return
	end
	plot:SetAttribute("OwnerUserId", player.UserId)
	ownedPlots[player] = plot

	local museum = template:Clone()
	museum.Name = "Museum_" .. player.Name
	museum:SetAttribute("OwnerUserId", player.UserId)
	museum:PivotTo(plot.CFrame)
	-- pave the ground under the museum and its plaza, so the island's grass doesn't grow
	-- up through the floors
	workspace.Terrain:FillBlock(plot.CFrame * CFrame.new(0, -2.5, -14), Vector3.new(84, 4, 104), Enum.Material.Slate)
	setOwnerSign(museum, player)
	museum.Parent = museumsFolder
	ownedMuseums[player] = museum

	-- Lets other scripts (and the player's UI) find this player's museum
	local ref = Instance.new("ObjectValue")
	ref.Name = "Museum"
	ref.Value = museum
	ref.Parent = player

	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
	if player.Character then
		task.spawn(onCharacterAdded, player, player.Character)
	end
end

local function onPlayerRemoving(player)
	local museum = ownedMuseums[player]
	if museum then
		museum:Destroy()
	end
	local plot = ownedPlots[player]
	if plot then
		plot:SetAttribute("OwnerUserId", 0)
	end
	ownedMuseums[player] = nil
	ownedPlots[player] = nil
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Handle players who joined before this script started
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end
]=])
install(game:GetService("ServerScriptService"), "ProfileService", "ModuleScript", [=[
-- ProfileService by MadStudio (loleris), Apache License 2.0.
-- Source: https://github.com/MadStudioRoblox/ProfileService (full license: third_party/ProfileService/LICENSE)
-- Unmodified copy; PlayerData uses it for session-locked saving.
-- local Madwork = _G.Madwork
--[[
{Madwork}

-[ProfileService]---------------------------------------
	(STANDALONE VERSION)
	DataStore profiles - universal session-locked savable table API
	
	Official documentation:
		https://madstudioroblox.github.io/ProfileService/

	DevForum discussion:
		https://devforum.roblox.com/t/ProfileService/667805
	
	WARNINGS FOR "Profile.Data" VALUES:
	 	! Do not create numeric tables with gaps - attempting to replicate such tables will result in an error;
		! Do not create mixed tables (some values indexed by number and others by string key), as only
		     the data indexed by number will be replicated.
		! Do not index tables by anything other than numbers and strings.
		! Do not reference Roblox Instances
		! Do not reference userdata (Vector3, Color3, CFrame...) - Serialize userdata before referencing
		! Do not reference functions
		
	WARNING: Calling ProfileStore:LoadProfileAsync() with a "profile_key" which wasn't released in the SAME SESSION will result
		in an error! If you want to "ProfileStore:LoadProfileAsync()" instead of using the already loaded profile, :Release()
		the old Profile object.
		
	Members:
	
		ProfileService.ServiceLocked         [bool]
		
		ProfileService.IssueSignal           [ScriptSignal] (error_message, profile_store_name, profile_key)
		ProfileService.CorruptionSignal      [ScriptSignal] (profile_store_name, profile_key)
		ProfileService.CriticalStateSignal   [ScriptSignal] (is_critical_state)
	
	Functions:
	
		ProfileService.GetProfileStore(profile_store_index, profile_template) --> [ProfileStore]
			profile_store_index   [string] -- DataStore name
			OR
			profile_store_index   [table]: -- Allows the developer to define more GlobalDataStore variables
				{
					Name = "StoreName", -- [string] -- DataStore name
					-- Optional arguments:
					Scope = "StoreScope", -- [string] -- DataStore scope
				}
			profile_template      [table] -- Profiles will default to given table (hard-copy) when no data was saved previously

		ProfileService.IsLive() --> [bool] -- (CAN YIELD!!!)
			-- Returns true if ProfileService is connected to live Roblox DataStores
				
	Members [ProfileStore]:
	
		ProfileStore.Mock   [ProfileStore] -- Reflection of ProfileStore methods, but the methods will use a mock DataStore
		
	Methods [ProfileStore]:
	
		ProfileStore:LoadProfileAsync(profile_key, not_released_handler) --> [Profile] or nil -- not_released_handler(place_id, game_job_id)
			profile_key            [string] -- DataStore key
			not_released_handler   nil or []: -- Defaults to "ForceLoad"
				[string] "ForceLoad" -- Force loads profile on first call
				OR
				[string] "Steal" -- Steals the profile ignoring it's session lock
				OR
				[function] (place_id, game_job_id) --> [string] "Repeat", "Cancel", "ForceLoad" or "Steal"
					place_id      [number] or nil
					game_job_id   [string] or nil

				-- not_released_handler [function] will be triggered in cases where the profile is not released by a session. This
				--	function may yield for as long as desirable and must return one of three string values:

						["Repeat"] - ProfileService will repeat the profile loading proccess and may trigger the release handler again
						["Cancel"] - ProfileStore:LoadProfileAsync() will immediately return nil
						["ForceLoad"] - ProfileService will repeat the profile loading call, but will return Profile object afterwards
							and release the profile for another session that has loaded the profile
						["Steal"] - The profile will usually be loaded immediately, ignoring an existing remote session lock and applying
							a session lock for this session.

		ProfileStore:GlobalUpdateProfileAsync(profile_key, update_handler) --> [GlobalUpdates] or nil
			-- Returns GlobalUpdates object if update was successful, otherwise returns nil
			profile_key      [string] -- DataStore key
			update_handler   [function] (global_updates [GlobalUpdates])
			
		ProfileStore:ViewProfileAsync(profile_key, version) --> [Profile] or nil
			-- Reads profile without requesting a session lock; Data will not be saved and profile doesn't need to be released
			profile_key   [string] -- DataStore key
			version       nil or [string] -- DataStore key version

		ProfileStore:ProfileVersionQuery(profile_key, sort_direction, min_date, max_date) --> [ProfileVersionQuery]
			profile_key      [string]
			sort_direction   nil or [Enum.SortDirection]
			min_date         nil or [DateTime]
			max_date         nil or [DateTime]
			
		ProfileStore:WipeProfileAsync(profile_key) --> is_wipe_successful [bool]
			-- Completely wipes out profile data from the DataStore / mock DataStore with no way to recover it.
						
		* Parameter description for "ProfileStore:GlobalUpdateProfileAsync()":
		
			profile_key      [string] -- DataStore key
			update_handler   [function] (GlobalUpdates) -- This function gains access to GlobalUpdates object methods
				(update_handler can't yield)

	Methods [ProfileVersionQuery]:

		ProfileVersionQuery:NextAsync() --> [Profile] or nil -- (Yields)
			-- Returned profile has the same rules as profile returned by :ViewProfileAsync()
		
	Members [Profile]:
	
		Profile.Data              [table] -- Writable table that gets saved automatically and once the profile is released
		Profile.MetaData          [table] (Read-only) -- Information about this profile
		
			Profile.MetaData.ProfileCreateTime   [number] (Read-only) -- os.time() timestamp of profile creation
			Profile.MetaData.SessionLoadCount    [number] (Read-only) -- Amount of times the profile was loaded
			Profile.MetaData.ActiveSession       [table] (Read-only) {place_id, game_job_id} / nil -- Set to a session link if a
				game session is currently having this profile loaded; nil if released
			Profile.MetaData.MetaTags            [table] {["tag_name"] = tag_value, ...} -- Saved and auto-saved just like Profile.Data
			Profile.MetaData.MetaTagsLatest      [table] (Read-only) -- Latest version of MetaData.MetaTags that was definetly saved to DataStore
				(You can use Profile.MetaData.MetaTagsLatest for product purchase save confirmation, but create a system to clear old tags after
				they pile up)

		Profile.MetaTagsUpdated   [ScriptSignal] (meta_tags_latest) -- Fires after every auto-save, after
			--	Profile.MetaData.MetaTagsLatest has been updated with the version that's guaranteed to be saved;
			--  .MetaTagsUpdated will fire regardless of whether .MetaTagsLatest changed after update;
			--	.MetaTagsUpdated may fire after the Profile is released - changes to Profile.Data are not saved
			--	after release.

		Profile.RobloxMetaData    [table] -- Writable table that gets saved automatically and once the profile is released
		Profile.UserIds           [table] -- (Read-only) -- {user_id [number], ...} -- User ids associated with this profile

		Profile.KeyInfo           [DataStoreKeyInfo]
		Profile.KeyInfoUpdated    [ScriptSignal] (key_info [DataStoreKeyInfo])
		
		Profile.GlobalUpdates     [GlobalUpdates]
		
	Methods [Profile]:
	
		-- SAFE METHODS - Will not error after profile expires:
		Profile:IsActive() --> [bool] -- Returns true while the profile is active and can be written to
			
		Profile:GetMetaTag(tag_name) --> value [any]
			tag_name   [string]
		
		Profile:Reconcile() -- Fills in missing (nil) [string_key] = [value] pairs to the Profile.Data structure
		
		Profile:ListenToRelease(listener) --> [ScriptConnection] (place_id / nil, game_job_id / nil)
			-- WARNING: Profiles can be released externally if another session force-loads
			--	this profile - use :ListenToRelease() to handle player leaving cleanup.
			
		Profile:Release() -- Call after the session has finished working with this profile
			e.g., after the player leaves (Profile object will become expired) (Does not yield)

		Profile:ListenToHopReady(listener) --> [ScriptConnection] () -- Passed listener will be executed after the releasing UpdateAsync call finishes;
			--	Wrap universe teleport requests with this method AFTER releasing the profile to improve session lock sharing between universe places;
			--  :ListenToHopReady() will usually call the listener in around a second, but may ocassionally take up to 7 seconds when a release happens
			--	next to an auto-update in regular usage scenarios.

		Profile:AddUserId(user_id) -- Associates user_id with profile (GDPR compliance)
			user_id   [number]

		Profile:RemoveUserId(user_id) -- Unassociates user_id with profile (safe function)
			user_id   [number]

		Profile:Identify() --> [string] -- Returns a string containing DataStore name, scope and key; Used for debug;
			-- Example return: "[Store:"GameData";Scope:"Live";Key:"Player_2312310"]"
		
		Profile:SetMetaTag(tag_name, value) -- Equivalent of Profile.MetaData.MetaTags[tag_name] = value
			tag_name   [string]
			value      [any]
		
		Profile:Save() -- Call to quickly progress global update state or to speed up save validation processes (Does not yield)

		-- VIEW-MODE ONLY:

		Profile:ClearGlobalUpdates() -- Clears all global updates data from a profile payload

		Profile:OverwriteAsync() -- (Yields) Saves the profile payload to the DataStore and removes the session lock
		
	Methods [GlobalUpdates]:
	
	-- ALWAYS PUBLIC:
		GlobalUpdates:GetActiveUpdates() --> [table] {{update_id, update_data [table]}, ...}
		GlobalUpdates:GetLockedUpdates() --> [table] {{update_id, update_data [table]}, ...}
		
	-- ONLY WHEN FROM "Profile.GlobalUpdates":
		GlobalUpdates:ListenToNewActiveUpdate(listener) --> [ScriptConnection] (update_id, update_data)
			update_data   [table]
		GlobalUpdates:ListenToNewLockedUpdate(listener) --> [ScriptConnection] (update_id, update_data)
			update_data   [table]
		GlobalUpdates:LockActiveUpdate(update_id)  -- WARNING: will error after profile expires
		GlobalUpdates:ClearLockedUpdate(update_id) -- WARNING: will error after profile expires
		
	-- EXPOSED TO "update_handler" DURING ProfileStore:GlobalUpdateProfileAsync() CALL
		GlobalUpdates:AddActiveUpdate(update_data)
			update_data   [table]
		GlobalUpdates:ChangeActiveUpdate(update_id, update_data)
			update_data   [table]
		GlobalUpdates:ClearActiveUpdate(update_id)
		
--]]

local SETTINGS = {

	AutoSaveProfiles = 30, -- Seconds (This value may vary - ProfileService will split the auto save load evenly in the given time)
	RobloxWriteCooldown = 7, -- Seconds between successive DataStore calls for the same key
	ForceLoadMaxSteps = 8, -- Steps taken before ForceLoad request steals the active session for a profile
	AssumeDeadSessionLock = 30 * 60, -- (seconds) If a profile hasn't been updated for 30 minutes, assume the session lock is dead
		-- As of writing, os.time() is not completely reliable, so we can only assume session locks are dead after a significant amount of time.
	
	IssueCountForCriticalState = 5, -- Issues to collect to announce critical state
	IssueLast = 120, -- Seconds
	CriticalStateLast = 120, -- Seconds
	
	MetaTagsUpdatedValues = { -- Technical stuff - do not alter
		ProfileCreateTime = true,
		SessionLoadCount = true,
		ActiveSession = true,
		ForceLoadSession = true,
		LastUpdate = true,
	},
	
}

local Madwork -- Standalone Madwork reference for portable version of ProfileService
do

	local MadworkScriptSignal = {}

	local FreeRunnerThread = nil
	
	local function AcquireRunnerThreadAndCallEventHandler(fn, ...)
		local acquired_runner_thread = FreeRunnerThread
		FreeRunnerThread = nil
		fn(...)
		FreeRunnerThread = acquired_runner_thread
	end
	
	local function RunEventHandlerInFreeThread(...)
		AcquireRunnerThreadAndCallEventHandler(...)
		while true do
			AcquireRunnerThreadAndCallEventHandler(coroutine.yield())
		end
	end
	
	-- ScriptConnection object:

	local ScriptConnection = {
		--[[
			_listener = listener,
			_script_signal = script_signal,
			_disconnect_listener = disconnect_listener,
			_disconnect_param = disconnect_param,
			
			_next = next_script_connection,
			_is_connected = is_connected,
		--]]
	}
	ScriptConnection.__index = ScriptConnection

	function ScriptConnection:Disconnect()

		if self._is_connected == false then
			return
		end

		self._is_connected = false
		self._script_signal._listener_count -= 1

		if self._script_signal._head == self then
			self._script_signal._head = self._next
		else
			local prev = self._script_signal._head
			while prev ~= nil and prev._next ~= self do
				prev = prev._next
			end
			if prev ~= nil then
				prev._next = self._next
			end
		end

		if self._disconnect_listener ~= nil then
			if not FreeRunnerThread then
				FreeRunnerThread = coroutine.create(RunEventHandlerInFreeThread)
			end
			task.spawn(FreeRunnerThread, self._disconnect_listener, self._disconnect_param)
			self._disconnect_listener = nil
		end

	end
	
	-- ScriptSignal object:

	local ScriptSignal = {
		--[[
			_head = nil,
			_listener_count = 0,
		--]]
	}
	ScriptSignal.__index = ScriptSignal

	function ScriptSignal:Connect(listener, disconnect_listener, disconnect_param) --> [ScriptConnection]

		local script_connection = {
			_listener = listener,
			_script_signal = self,
			_disconnect_listener = disconnect_listener,
			_disconnect_param = disconnect_param,

			_next = self._head,
			_is_connected = true,
		}
		setmetatable(script_connection, ScriptConnection)

		self._head = script_connection
		self._listener_count += 1

		return script_connection

	end

	function ScriptSignal:GetListenerCount() --> [number]
		return self._listener_count
	end

	function ScriptSignal:Fire(...)
		local item = self._head
		while item ~= nil do
			if item._is_connected == true then
				if not FreeRunnerThread then
					FreeRunnerThread = coroutine.create(RunEventHandlerInFreeThread)
				end
				task.spawn(FreeRunnerThread, item._listener, ...)
			end
			item = item._next
		end
	end

	function ScriptSignal:FireUntil(continue_callback, ...)
		local item = self._head
		while item ~= nil do
			if item._is_connected == true then
				item._listener(...)
				if continue_callback() ~= true then
					return
				end
			end
			item = item._next
		end
	end

	function MadworkScriptSignal.NewScriptSignal() --> [ScriptSignal]
		return {
			_head = nil,
			_listener_count = 0,
			Connect = ScriptSignal.Connect,
			GetListenerCount = ScriptSignal.GetListenerCount,
			Fire = ScriptSignal.Fire,
			FireUntil = ScriptSignal.FireUntil,
		}
	end

	-- Madwork framework namespace:
	
	Madwork = {
		NewScriptSignal = MadworkScriptSignal.NewScriptSignal,
		ConnectToOnClose = function(task, run_in_studio_mode)
			if game:GetService("RunService"):IsStudio() == false or run_in_studio_mode == true then
				game:BindToClose(task)
			end
		end,
	}

end

----- Service Table -----

local ProfileService = {

	ServiceLocked = false, -- Set to true once the server is shutting down

	IssueSignal = Madwork.NewScriptSignal(), -- (error_message, profile_store_name, profile_key) -- Fired when a DataStore API call throws an error
	CorruptionSignal = Madwork.NewScriptSignal(), -- (profile_store_name, profile_key) -- Fired when DataStore key returns a value that has
	-- all or some of it's profile components set to invalid data types. E.g., accidentally setting Profile.Data to a noon table value

	CriticalState = false, -- Set to true while DataStore service is throwing too many errors
	CriticalStateSignal = Madwork.NewScriptSignal(), -- (is_critical_state) -- Fired when CriticalState is set to true
	-- (You may alert players with this, or set up analytics)

	ServiceIssueCount = 0,

	_active_profile_stores = {}, -- {profile_store, ...}

	_auto_save_list = {}, -- {profile, ...} -- loaded profile table which will be circularly auto-saved

	_issue_queue = {}, -- [table] {issue_time, ...}
	_critical_state_start = 0, -- [number] 0 = no critical state / os.clock() = critical state start

	-- Debug:
	_mock_data_store = {},
	_user_mock_data_store = {},

	_use_mock_data_store = false,

}

--[[
	Saved profile structure:
	
	DataStoreProfile = {
		Data = {},
		MetaData = {
			ProfileCreateTime = 0,
			SessionLoadCount = 0,
			ActiveSession = {place_id, game_job_id} / nil,
			ForceLoadSession = {place_id, game_job_id} / nil,
			MetaTags = {},
			LastUpdate = 0, -- os.time()
		},
		RobloxMetaData = {},
		UserIds = {},
		GlobalUpdates = {
			update_index,
			{
				{update_id, version_id, update_locked, update_data},
				...
			}
		},
	}
	
	OR
	
	DataStoreProfile = {
		GlobalUpdates = {
			update_index,
			{
				{update_id, version_id, update_locked, update_data},
				...
			}
		},
	}
--]]

----- Private Variables -----

local ActiveProfileStores = ProfileService._active_profile_stores
local AutoSaveList = ProfileService._auto_save_list
local IssueQueue = ProfileService._issue_queue

local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local PlaceId = game.PlaceId
local JobId = game.JobId

local AutoSaveIndex = 1 -- Next profile to auto save
local LastAutoSave = os.clock()

local LoadIndex = 0

local ActiveProfileLoadJobs = 0 -- Number of active threads that are loading in profiles
local ActiveProfileSaveJobs = 0 -- Number of active threads that are saving profiles

local CriticalStateStart = 0 -- os.clock()

local IsStudio = RunService:IsStudio()
local IsLiveCheckActive = false

local UseMockDataStore = false
local MockDataStore = ProfileService._mock_data_store -- Mock data store used when API access is disabled

local UserMockDataStore = ProfileService._user_mock_data_store -- Separate mock data store accessed via ProfileStore.Mock
local UseMockTag = {}

local CustomWriteQueue = {
	--[[
		[store] = {
			[key] = {
				LastWrite = os.clock(),
				Queue = {callback, ...},
				CleanupJob = nil,
			},
			...
		},
		...
	--]]
}

----- Utils -----

local function DeepCopyTable(t)
	local copy = {}
	for key, value in pairs(t) do
		if type(value) == "table" then
			copy[key] = DeepCopyTable(value)
		else
			copy[key] = value
		end
	end
	return copy
end

local function ReconcileTable(target, template)
	for k, v in pairs(template) do
		if type(k) == "string" then -- Only string keys will be reconciled
			if target[k] == nil then
				if type(v) == "table" then
					target[k] = DeepCopyTable(v)
				else
					target[k] = v
				end
			elseif type(target[k]) == "table" and type(v) == "table" then
				ReconcileTable(target[k], v)
			end
		end
	end
end

----- Private functions -----

local function IdentifyProfile(store_name, store_scope, key)
	return string.format(
		"[Store:\"%s\";%sKey:\"%s\"]",
		store_name,
		store_scope ~= nil and string.format("Scope:\"%s\";", store_scope) or "",
		key
	)
end

local function CustomWriteQueueCleanup(store, key)
	if CustomWriteQueue[store] ~= nil then
		CustomWriteQueue[store][key] = nil
		if next(CustomWriteQueue[store]) == nil then
			CustomWriteQueue[store] = nil
		end
	end
end

local function CustomWriteQueueMarkForCleanup(store, key)
	if CustomWriteQueue[store] ~= nil then
		if CustomWriteQueue[store][key] ~= nil then

			local queue_data = CustomWriteQueue[store][key]
			local queue = queue_data.Queue

			if queue_data.CleanupJob == nil then

				queue_data.CleanupJob = RunService.Heartbeat:Connect(function()
					if os.clock() - queue_data.LastWrite > SETTINGS.RobloxWriteCooldown and #queue == 0 then
						queue_data.CleanupJob:Disconnect()
						CustomWriteQueueCleanup(store, key)
					end
				end)

			end

		elseif next(CustomWriteQueue[store]) == nil then
			CustomWriteQueue[store] = nil
		end
	end
end

local function CustomWriteQueueAsync(callback, store, key) --> ... -- Passed return from callback

	if CustomWriteQueue[store] == nil then
		CustomWriteQueue[store] = {}
	end
	if CustomWriteQueue[store][key] == nil then
		CustomWriteQueue[store][key] = {LastWrite = 0, Queue = {}, CleanupJob = nil}
	end

	local queue_data = CustomWriteQueue[store][key]
	local queue = queue_data.Queue

	-- Cleanup job:

	if queue_data.CleanupJob ~= nil then
		queue_data.CleanupJob:Disconnect()
		queue_data.CleanupJob = nil
	end

	-- Queue logic:

	if os.clock() - queue_data.LastWrite > SETTINGS.RobloxWriteCooldown and #queue == 0 then
		queue_data.LastWrite = os.clock()
		return callback()
	else
		table.insert(queue, callback)
		while true do
			if os.clock() - queue_data.LastWrite > SETTINGS.RobloxWriteCooldown and queue[1] == callback then
				table.remove(queue, 1)
				queue_data.LastWrite = os.clock()
				return callback()
			end
			task.wait()
		end
	end

end

local function IsCustomWriteQueueEmptyFor(store, key) --> is_empty [bool]
	local lookup = CustomWriteQueue[store]
	if lookup ~= nil then
		lookup = lookup[key]
		return lookup == nil or #lookup.Queue == 0
	end
	return true
end

local function WaitForLiveAccessCheck() -- This function was created to prevent the ProfileService module yielding execution when required
	while IsLiveCheckActive == true do
		task.wait()
	end
end

local function WaitForPendingProfileStore(profile_store)
	while profile_store._is_pending == true do
		task.wait()
	end
end

local function RegisterIssue(error_message, store_name, store_scope, profile_key) -- Called when a DataStore API call errors
	warn("[ProfileService]: DataStore API error " .. IdentifyProfile(store_name, store_scope, profile_key) .. " - \"" .. tostring(error_message) .. "\"")
	table.insert(IssueQueue, os.clock()) -- Adding issue time to queue
	ProfileService.IssueSignal:Fire(tostring(error_message), store_name, profile_key)
end

local function RegisterCorruption(store_name, store_scope, profile_key) -- Called when a corrupted profile is loaded
	warn("[ProfileService]: Resolved profile corruption " .. IdentifyProfile(store_name, store_scope, profile_key))
	ProfileService.CorruptionSignal:Fire(store_name, profile_key)
end

local function NewMockDataStoreKeyInfo(params)

	local version_id_string = tostring(params.VersionId or 0)
	local meta_data = params.MetaData or {}
	local user_ids = params.UserIds or {}

	return {
		CreatedTime = params.CreatedTime,
		UpdatedTime = params.UpdatedTime,
		Version = string.rep("0", 16) .. "."
			.. string.rep("0", 10 - string.len(version_id_string)) .. version_id_string
			.. "." .. string.rep("0", 16) .. "." .. "01",

		GetMetadata = function()
			return DeepCopyTable(meta_data)
		end,

		GetUserIds = function()
			return DeepCopyTable(user_ids)
		end,
	}

end

local function MockUpdateAsync(mock_data_store, profile_store_name, key, transform_function, is_get_call) --> loaded_data, key_info

	local profile_store = mock_data_store[profile_store_name]

	if profile_store == nil then
		profile_store = {}
		mock_data_store[profile_store_name] = profile_store
	end

	local epoch_time = math.floor(os.time() * 1000)
	local mock_entry = profile_store[key]
	local mock_entry_was_nil = false

	if mock_entry == nil then
		mock_entry_was_nil = true
		if is_get_call ~= true then
			mock_entry = {
				Data = nil,
				CreatedTime = epoch_time,
				UpdatedTime = epoch_time,
				VersionId = 0,
				UserIds = {},
				MetaData = {},
			}
			profile_store[key] = mock_entry
		end
	end

	local mock_key_info = mock_entry_was_nil == false and NewMockDataStoreKeyInfo(mock_entry) or nil

	local transform, user_ids, roblox_meta_data = transform_function(mock_entry and mock_entry.Data, mock_key_info)

	if transform == nil then
		return nil
	else
		if mock_entry ~= nil and is_get_call ~= true then
			mock_entry.Data = transform
			mock_entry.UserIds = DeepCopyTable(user_ids or {})
			mock_entry.MetaData = DeepCopyTable(roblox_meta_data or {})
			mock_entry.VersionId += 1
			mock_entry.UpdatedTime = epoch_time
		end

		return DeepCopyTable(transform), mock_entry ~= nil and NewMockDataStoreKeyInfo(mock_entry) or nil
	end

end

local function IsThisSession(session_tag)
	return session_tag[1] == PlaceId and session_tag[2] == JobId
end

--[[
update_settings = {
	ExistingProfileHandle = function(latest_data),
	MissingProfileHandle = function(latest_data),
	EditProfile = function(lastest_data),
}
--]]
local function StandardProfileUpdateAsyncDataStore(profile_store, profile_key, update_settings, is_user_mock, is_get_call, version) --> loaded_data, key_info
	local loaded_data, key_info
	local success, error_message = pcall(function()
		local transform_function = function(latest_data)

			local missing_profile = false
			local data_corrupted = false
			local global_updates_data = {0, {}}

			if latest_data == nil then
				missing_profile = true
			elseif type(latest_data) ~= "table" then
				missing_profile = true
				data_corrupted = true
			end

			if type(latest_data) == "table" then
				-- Case #1: Profile was loaded
				if type(latest_data.Data) == "table"
					and type(latest_data.MetaData) == "table"
					and type(latest_data.GlobalUpdates) == "table" then

					latest_data.WasCorrupted = false -- Must be set to false if set previously
					global_updates_data = latest_data.GlobalUpdates
					if update_settings.ExistingProfileHandle ~= nil then
						update_settings.ExistingProfileHandle(latest_data)
					end
					-- Case #2: Profile was not loaded but GlobalUpdate data exists
				elseif latest_data.Data == nil
					and latest_data.MetaData == nil
					and type(latest_data.GlobalUpdates) == "table" then

					latest_data.WasCorrupted = false -- Must be set to false if set previously
					global_updates_data = latest_data.GlobalUpdates or global_updates_data
					missing_profile = true
				else
					missing_profile = true
					data_corrupted = true
				end
			end

			-- Case #3: Profile was not created or corrupted and no GlobalUpdate data exists
			if missing_profile == true then
				latest_data = {
					-- Data = nil,
					-- MetaData = nil,
					GlobalUpdates = global_updates_data,
				}
				if update_settings.MissingProfileHandle ~= nil then
					update_settings.MissingProfileHandle(latest_data)
				end
			end

			-- Editing profile:
			if update_settings.EditProfile ~= nil then
				update_settings.EditProfile(latest_data)
			end

			-- Data corruption handling (Silently override with empty profile) (Also run Case #1)
			if data_corrupted == true then
				latest_data.WasCorrupted = true -- Temporary tag that will be removed on first save
			end

			return latest_data, latest_data.UserIds, latest_data.RobloxMetaData
		end
		if is_user_mock == true then -- Used when the profile is accessed through ProfileStore.Mock
			loaded_data, key_info = MockUpdateAsync(UserMockDataStore, profile_store._profile_store_lookup, profile_key, transform_function, is_get_call)
			task.wait() -- Simulate API call yield
		elseif UseMockDataStore == true then -- Used when API access is disabled
			loaded_data, key_info = MockUpdateAsync(MockDataStore, profile_store._profile_store_lookup, profile_key, transform_function, is_get_call)
			task.wait() -- Simulate API call yield
		else
			loaded_data, key_info = CustomWriteQueueAsync(
				function() -- Callback
					if is_get_call == true then
						local get_data, get_key_info
						if version ~= nil then
							local success, error_message = pcall(function()
								get_data, get_key_info = profile_store._global_data_store:GetVersionAsync(profile_key, version)
							end)
							if success == false and type(error_message) == "string" and string.find(error_message, "not valid") ~= nil then
								warn("[ProfileService]: Passed version argument is not valid; Traceback:\n" .. debug.traceback())
							end
						else
							get_data, get_key_info = profile_store._global_data_store:GetAsync(profile_key)
						end
						get_data = transform_function(get_data)
						return get_data, get_key_info
					else
						return profile_store._global_data_store:UpdateAsync(profile_key, transform_function)
					end
				end,
				profile_store._profile_store_lookup, -- Store
				profile_key -- Key
			)
		end
	end)
	if success == true and type(loaded_data) == "table" then
		-- Corruption handling:
		if loaded_data.WasCorrupted == true and is_get_call ~= true then
			RegisterCorruption(
				profile_store._profile_store_name,
				profile_store._profile_store_scope,
				profile_key
			)
		end
		-- Return loaded_data:
		return loaded_data, key_info
	else
		RegisterIssue(
			(error_message ~= nil) and error_message or "Undefined error",
			profile_store._profile_store_name,
			profile_store._profile_store_scope,
			profile_key
		)
		-- Return nothing:
		return nil
	end
end

local function RemoveProfileFromAutoSave(profile)
	local auto_save_index = table.find(AutoSaveList, profile)
	if auto_save_index ~= nil then
		table.remove(AutoSaveList, auto_save_index)
		if auto_save_index < AutoSaveIndex then
			AutoSaveIndex = AutoSaveIndex - 1 -- Table contents were moved left before AutoSaveIndex so move AutoSaveIndex left as well
		end
		if AutoSaveList[AutoSaveIndex] == nil then -- AutoSaveIndex was at the end of the AutoSaveList - reset to 1
			AutoSaveIndex = 1
		end
	end
end

local function AddProfileToAutoSave(profile) -- Notice: Makes sure this profile isn't auto-saved too soon
	-- Add at AutoSaveIndex and move AutoSaveIndex right:
	table.insert(AutoSaveList, AutoSaveIndex, profile)
	if #AutoSaveList > 1 then
		AutoSaveIndex = AutoSaveIndex + 1
	elseif #AutoSaveList == 1 then
		-- First profile created - make sure it doesn't get immediately auto saved:
		LastAutoSave = os.clock()
	end
end

local function ReleaseProfileInternally(profile)
	-- 1) Remove profile object from ProfileService references: --
	-- Clear reference in ProfileStore:
	local profile_store = profile._profile_store
	local loaded_profiles = profile._is_user_mock == true and profile_store._mock_loaded_profiles or profile_store._loaded_profiles
	loaded_profiles[profile._profile_key] = nil
	if next(profile_store._loaded_profiles) == nil and next(profile_store._mock_loaded_profiles) == nil then -- ProfileStore has turned inactive
		local index = table.find(ActiveProfileStores, profile_store)
		if index ~= nil then
			table.remove(ActiveProfileStores, index)
		end
	end
	-- Clear auto update reference:
	RemoveProfileFromAutoSave(profile)
	-- 2) Trigger release listeners: --
	local place_id
	local game_job_id
	local active_session = profile.MetaData.ActiveSession
	if active_session ~= nil then
		place_id = active_session[1]
		game_job_id = active_session[2]
	end
	profile._release_listeners:Fire(place_id, game_job_id)
end

local function CheckForNewGlobalUpdates(profile, old_global_updates_data, new_global_updates_data)
	local global_updates_object = profile.GlobalUpdates -- [GlobalUpdates]
	local pending_update_lock = global_updates_object._pending_update_lock -- {update_id, ...}
	local pending_update_clear = global_updates_object._pending_update_clear -- {update_id, ...}
	-- "old_" or "new_" global_updates_data = {update_index, {{update_id, version_id, update_locked, update_data}, ...}}
	for _, new_global_update in ipairs(new_global_updates_data[2]) do
		-- Find old global update with the same update_id:
		local old_global_update
		for _, global_update in ipairs(old_global_updates_data[2]) do
			if global_update[1] == new_global_update[1] then
				old_global_update = global_update
				break
			end
		end
		-- A global update is new when it didn't exist before or its version_id or update_locked state changed:
		local is_new = false
		if old_global_update == nil or new_global_update[2] > old_global_update[2] or new_global_update[3] ~= old_global_update[3] then
			is_new = true
		end
		if is_new == true then
			-- Active global updates:
			if new_global_update[3] == false then
				-- Check if update is not pending to be locked: (Preventing firing new active update listeners more than necessary)
				local is_pending_lock = false
				for _, update_id in ipairs(pending_update_lock) do
					if new_global_update[1] == update_id then
						is_pending_lock = true
						break
					end
				end
				if is_pending_lock == false then
					-- Trigger new active update listeners:
					global_updates_object._new_active_update_listeners:Fire(new_global_update[1], new_global_update[4])
				end
			end
			-- Locked global updates:
			if new_global_update[3] == true then
				-- Check if update is not pending to be cleared: (Preventing firing new locked update listeners after marking a locked update for clearing)
				local is_pending_clear = false
				for _, update_id in ipairs(pending_update_clear) do
					if new_global_update[1] == update_id then
						is_pending_clear = true
						break
					end
				end
				if is_pending_clear == false then
					-- Trigger new locked update listeners:

					global_updates_object._new_locked_update_listeners:FireUntil(
						function()
							-- Check if listener marked the update to be cleared:
							-- Normally there should be only one listener per profile for new locked global updates, but
							-- in case several listeners are connected we will not trigger more listeners after one listener
							-- marks the locked global update to be cleared.
							return table.find(pending_update_clear, new_global_update[1]) == nil
						end,
						new_global_update[1], new_global_update[4]
					)

				end
			end
		end
	end
end

local function SaveProfileAsync(profile, release_from_session, is_overwriting)
	if type(profile.Data) ~= "table" then
		RegisterCorruption(
			profile._profile_store._profile_store_name,
			profile._profile_store._profile_store_scope,
			profile._profile_key
		)
		error("[ProfileService]: PROFILE DATA CORRUPTED DURING RUNTIME! Profile: " .. profile:Identify())
	end
	if release_from_session == true and is_overwriting ~= true then
		ReleaseProfileInternally(profile)
	end
	ActiveProfileSaveJobs = ActiveProfileSaveJobs + 1
	local last_session_load_count = profile.MetaData.SessionLoadCount
	-- Compare "SessionLoadCount" when writing to profile to prevent a rare case of repeat last save when the profile is loaded on the same server again
	local repeat_save_flag = true -- Released Profile save calls have to repeat until they succeed
	while repeat_save_flag == true do
		if release_from_session ~= true then
			repeat_save_flag = false
		end
		local loaded_data, key_info = StandardProfileUpdateAsyncDataStore(
			profile._profile_store,
			profile._profile_key,
			{
				ExistingProfileHandle = nil,
				MissingProfileHandle = nil,
				EditProfile = function(latest_data)

					local session_owns_profile = false
					local force_load_pending = false

					if is_overwriting ~= true then
						-- 1) Check if this session still owns the profile: --
						local active_session = latest_data.MetaData.ActiveSession
						local force_load_session = latest_data.MetaData.ForceLoadSession
						local session_load_count = latest_data.MetaData.SessionLoadCount

						if type(active_session) == "table" then
							session_owns_profile = IsThisSession(active_session) and session_load_count == last_session_load_count
						end
						if type(force_load_session) == "table" then
							force_load_pending = not IsThisSession(force_load_session)
						end
					else
						session_owns_profile = true
					end

					if session_owns_profile == true then -- We may only edit the profile if this session has ownership of the profile

						if is_overwriting ~= true then
							-- 2) Manage global updates: --
							local latest_global_updates_data = latest_data.GlobalUpdates -- {update_index, {{update_id, version_id, update_locked, update_data}, ...}}
							local latest_global_updates_list = latest_global_updates_data[2]

							local global_updates_object = profile.GlobalUpdates -- [GlobalUpdates]
							local pending_update_lock = global_updates_object._pending_update_lock -- {update_id, ...}
							local pending_update_clear = global_updates_object._pending_update_clear -- {update_id, ...}
							-- Active update locking:
							for i = 1, #latest_global_updates_list do
								for _, lock_id in ipairs(pending_update_lock) do
									if latest_global_updates_list[i][1] == lock_id then
										latest_global_updates_list[i][3] = true
										break
									end
								end
							end
							-- Locked update clearing:
							for _, clear_id in ipairs(pending_update_clear) do
								for i = 1, #latest_global_updates_list do
									if latest_global_updates_list[i][1] == clear_id and latest_global_updates_list[i][3] == true then
										table.remove(latest_global_updates_list, i)
										break
									end
								end
							end
						end

						-- 3) Save profile data: --
						latest_data.Data = profile.Data
						latest_data.RobloxMetaData = profile.RobloxMetaData
						latest_data.UserIds = profile.UserIds

						if is_overwriting ~= true then
							latest_data.MetaData.MetaTags = profile.MetaData.MetaTags -- MetaData.MetaTags is the only actively savable component of MetaData
							latest_data.MetaData.LastUpdate = os.time()
							if release_from_session == true or force_load_pending == true then
								latest_data.MetaData.ActiveSession = nil
							end
						else
							latest_data.MetaData = profile.MetaData
							latest_data.MetaData.ActiveSession = nil
							latest_data.MetaData.ForceLoadSession = nil
							latest_data.GlobalUpdates = profile.GlobalUpdates._updates_latest
						end

					end
				end,
			},
			profile._is_user_mock
		)
		if loaded_data ~= nil and key_info ~= nil then
			if is_overwriting == true then
				break
			end
			repeat_save_flag = false
			-- 4) Set latest data in profile: --
			-- Updating DataStoreKeyInfo:
			profile.KeyInfo = key_info
			-- Setting global updates:
			local global_updates_object = profile.GlobalUpdates -- [GlobalUpdates]
			local old_global_updates_data = global_updates_object._updates_latest
			local new_global_updates_data = loaded_data.GlobalUpdates
			global_updates_object._updates_latest = new_global_updates_data
			-- Setting MetaData:
			local session_meta_data = profile.MetaData
			local latest_meta_data = loaded_data.MetaData
			for key in pairs(SETTINGS.MetaTagsUpdatedValues) do
				session_meta_data[key] = latest_meta_data[key]
			end
			session_meta_data.MetaTagsLatest = latest_meta_data.MetaTags
			-- 5) Check if session still owns the profile: --
			local active_session = loaded_data.MetaData.ActiveSession
			local session_load_count = loaded_data.MetaData.SessionLoadCount
			local session_owns_profile = false
			if type(active_session) == "table" then
				session_owns_profile = IsThisSession(active_session) and session_load_count == last_session_load_count
			end
			local is_active = profile:IsActive()
			if session_owns_profile == true then
				-- 6) Check for new global updates: --
				if is_active == true then -- Profile could've been released before the saving thread finished
					CheckForNewGlobalUpdates(profile, old_global_updates_data, new_global_updates_data)
				end
			else
				-- Session no longer owns the profile:
				-- 7) Release profile if it hasn't been released yet: --
				if is_active == true then
					ReleaseProfileInternally(profile)
				end
				-- Cleanup reference in custom write queue:
				CustomWriteQueueMarkForCleanup(profile._profile_store._profile_store_lookup, profile._profile_key)
				-- Hop ready listeners:
				if profile._hop_ready == false then
					profile._hop_ready = true
					profile._hop_ready_listeners:Fire()
				end
			end
			-- Signaling MetaTagsUpdated listeners after a possible external profile release was handled:
			profile.MetaTagsUpdated:Fire(profile.MetaData.MetaTagsLatest)
			-- Signaling KeyInfoUpdated listeners:
			profile.KeyInfoUpdated:Fire(key_info)
		elseif repeat_save_flag == true then
			task.wait() -- Prevent infinite loop in case DataStore API does not yield
		end
	end
	ActiveProfileSaveJobs = ActiveProfileSaveJobs - 1
end

----- Public functions -----

-- GlobalUpdates object:

local GlobalUpdates = {
	--[[
		_updates_latest = {}, -- [table] {update_index, {{update_id, version_id, update_locked, update_data}, ...}}
		_pending_update_lock = {update_id, ...} / nil, -- [table / nil]
		_pending_update_clear = {update_id, ...} / nil, -- [table / nil]
		
		_new_active_update_listeners = [ScriptSignal] / nil, -- [table / nil]
		_new_locked_update_listeners = [ScriptSignal] / nil, -- [table / nil]
		
		_profile = Profile / nil, -- [Profile / nil]
		
		_update_handler_mode = true / nil, -- [bool / nil]
	--]]
}
GlobalUpdates.__index = GlobalUpdates

-- ALWAYS PUBLIC:
function GlobalUpdates:GetActiveUpdates() --> [table] {{update_id, update_data}, ...}
	local query_list = {}
	for _, global_update in ipairs(self._updates_latest[2]) do
		if global_update[3] == false then
			local is_pending_lock = false
			if self._pending_update_lock ~= nil then
				for _, update_id in ipairs(self._pending_update_lock) do
					if global_update[1] == update_id then
						is_pending_lock = true -- Exclude global updates pending to be locked
						break
					end
				end
			end
			if is_pending_lock == false then
				table.insert(query_list, {global_update[1], global_update[4]})
			end
		end
	end
	return query_list
end

function GlobalUpdates:GetLockedUpdates() --> [table] {{update_id, update_data}, ...}
	local query_list = {}
	for _, global_update in ipairs(self._updates_latest[2]) do
		if global_update[3] == true then
			local is_pending_clear = false
			if self._pending_update_clear ~= nil then
				for _, update_id in ipairs(self._pending_update_clear) do
					if global_update[1] == update_id then
						is_pending_clear = true -- Exclude global updates pending to be cleared
						break
					end
				end
			end
			if is_pending_clear == false then
				table.insert(query_list, {global_update[1], global_update[4]})
			end
		end
	end
	return query_list
end

-- ONLY WHEN FROM "Profile.GlobalUpdates":
function GlobalUpdates:ListenToNewActiveUpdate(listener) --> [ScriptConnection] listener(update_id, update_data)
	if type(listener) ~= "function" then
		error("[ProfileService]: Only a function can be set as listener in GlobalUpdates:ListenToNewActiveUpdate()")
	end
	local profile = self._profile
	if self._update_handler_mode == true then
		error("[ProfileService]: Can't listen to new global updates in ProfileStore:GlobalUpdateProfileAsync()")
	elseif self._new_active_update_listeners == nil then
		error("[ProfileService]: Can't listen to new global updates in view mode")
	elseif profile:IsActive() == false then -- Check if profile is expired
		return { -- Do not connect listener if the profile is expired
			Disconnect = function() end,
		}
	end
	-- Connect listener:
	return self._new_active_update_listeners:Connect(listener)
end

function GlobalUpdates:ListenToNewLockedUpdate(listener) --> [ScriptConnection] listener(update_id, update_data)
	if type(listener) ~= "function" then
		error("[ProfileService]: Only a function can be set as listener in GlobalUpdates:ListenToNewLockedUpdate()")
	end
	local profile = self._profile
	if self._update_handler_mode == true then
		error("[ProfileService]: Can't listen to new global updates in ProfileStore:GlobalUpdateProfileAsync()")
	elseif self._new_locked_update_listeners == nil then
		error("[ProfileService]: Can't listen to new global updates in view mode")
	elseif profile:IsActive() == false then -- Check if profile is expired
		return { -- Do not connect listener if the profile is expired
			Disconnect = function() end,
		}
	end
	-- Connect listener:
	return self._new_locked_update_listeners:Connect(listener)
end

function GlobalUpdates:LockActiveUpdate(update_id)
	if type(update_id) ~= "number" then
		error("[ProfileService]: Invalid update_id")
	end
	local profile = self._profile
	if self._update_handler_mode == true then
		error("[ProfileService]: Can't lock active global updates in ProfileStore:GlobalUpdateProfileAsync()")
	elseif self._pending_update_lock == nil then
		error("[ProfileService]: Can't lock active global updates in view mode")
	elseif profile:IsActive() == false then -- Check if profile is expired
		error("[ProfileService]: PROFILE EXPIRED - Can't lock active global updates")
	end
	-- Check if global update exists with given update_id
	local global_update_exists = nil
	for _, global_update in ipairs(self._updates_latest[2]) do
		if global_update[1] == update_id then
			global_update_exists = global_update
			break
		end
	end
	if global_update_exists ~= nil then
		local is_pending_lock = false
		for _, lock_update_id in ipairs(self._pending_update_lock) do
			if update_id == lock_update_id then
				is_pending_lock = true -- Exclude global updates pending to be locked
				break
			end
		end
		if is_pending_lock == false and global_update_exists[3] == false then -- Avoid id duplicates in _pending_update_lock
			table.insert(self._pending_update_lock, update_id)
		end
	else
		error("[ProfileService]: Passed non-existant update_id")
	end
end

function GlobalUpdates:ClearLockedUpdate(update_id)
	if type(update_id) ~= "number" then
		error("[ProfileService]: Invalid update_id")
	end
	local profile = self._profile
	if self._update_handler_mode == true then
		error("[ProfileService]: Can't clear locked global updates in ProfileStore:GlobalUpdateProfileAsync()")
	elseif self._pending_update_clear == nil then
		error("[ProfileService]: Can't clear locked global updates in view mode")
	elseif profile:IsActive() == false then -- Check if profile is expired
		error("[ProfileService]: PROFILE EXPIRED - Can't clear locked global updates")
	end
	-- Check if global update exists with given update_id
	local global_update_exists = nil
	for _, global_update in ipairs(self._updates_latest[2]) do
		if global_update[1] == update_id then
			global_update_exists = global_update
			break
		end
	end
	if global_update_exists ~= nil then
		local is_pending_clear = false
		for _, clear_update_id in ipairs(self._pending_update_clear) do
			if update_id == clear_update_id then
				is_pending_clear = true -- Exclude global updates pending to be cleared
				break
			end
		end
		if is_pending_clear == false and global_update_exists[3] == true then -- Avoid id duplicates in _pending_update_clear
			table.insert(self._pending_update_clear, update_id)
		end
	else
		error("[ProfileService]: Passed non-existant update_id")
	end
end

-- EXPOSED TO "update_handler" DURING ProfileStore:GlobalUpdateProfileAsync() CALL
function GlobalUpdates:AddActiveUpdate(update_data)
	if type(update_data) ~= "table" then
		error("[ProfileService]: Invalid update_data")
	end
	if self._new_active_update_listeners ~= nil then
		error("[ProfileService]: Can't add active global updates in loaded Profile; Use ProfileStore:GlobalUpdateProfileAsync()")
	elseif self._update_handler_mode ~= true then
		error("[ProfileService]: Can't add active global updates in view mode; Use ProfileStore:GlobalUpdateProfileAsync()")
	end
	-- self._updates_latest = {}, -- [table] {update_index, {{update_id, version_id, update_locked, update_data}, ...}}
	local updates_latest = self._updates_latest
	local update_index = updates_latest[1] + 1 -- Incrementing global update index
	updates_latest[1] = update_index
	-- Add new active global update:
	table.insert(updates_latest[2], {update_index, 1, false, update_data})
end

function GlobalUpdates:ChangeActiveUpdate(update_id, update_data)
	if type(update_id) ~= "number" then
		error("[ProfileService]: Invalid update_id")
	end
	if type(update_data) ~= "table" then
		error("[ProfileService]: Invalid update_data")
	end
	if self._new_active_update_listeners ~= nil then
		error("[ProfileService]: Can't change active global updates in loaded Profile; Use ProfileStore:GlobalUpdateProfileAsync()")
	elseif self._update_handler_mode ~= true then
		error("[ProfileService]: Can't change active global updates in view mode; Use ProfileStore:GlobalUpdateProfileAsync()")
	end
	-- self._updates_latest = {}, -- [table] {update_index, {{update_id, version_id, update_locked, update_data}, ...}}
	local updates_latest = self._updates_latest
	local get_global_update = nil
	for _, global_update in ipairs(updates_latest[2]) do
		if update_id == global_update[1] then
			get_global_update = global_update
			break
		end
	end
	if get_global_update ~= nil then
		if get_global_update[3] == true then
			error("[ProfileService]: Can't change locked global update")
		end
		get_global_update[2] = get_global_update[2] + 1 -- Increment version id
		get_global_update[4] = update_data -- Set new global update data
	else
		error("[ProfileService]: Passed non-existant update_id")
	end
end

function GlobalUpdates:ClearActiveUpdate(update_id)
	if type(update_id) ~= "number" then
		error("[ProfileService]: Invalid update_id argument")
	end
	if self._new_active_update_listeners ~= nil then
		error("[ProfileService]: Can't clear active global updates in loaded Profile; Use ProfileStore:GlobalUpdateProfileAsync()")
	elseif self._update_handler_mode ~= true then
		error("[ProfileService]: Can't clear active global updates in view mode; Use ProfileStore:GlobalUpdateProfileAsync()")
	end
	-- self._updates_latest = {}, -- [table] {update_index, {{update_id, version_id, update_locked, update_data}, ...}}
	local updates_latest = self._updates_latest
	local get_global_update_index = nil
	local get_global_update = nil
	for index, global_update in ipairs(updates_latest[2]) do
		if update_id == global_update[1] then
			get_global_update_index = index
			get_global_update = global_update
			break
		end
	end
	if get_global_update ~= nil then
		if get_global_update[3] == true then
			error("[ProfileService]: Can't clear locked global update")
		end
		table.remove(updates_latest[2], get_global_update_index) -- Remove active global update
	else
		error("[ProfileService]: Passed non-existant update_id")
	end
end

-- Profile object:

local Profile = {
	--[[
		Data = {}, -- [table] -- Loaded once after ProfileStore:LoadProfileAsync() finishes
		MetaData = {}, -- [table] -- Updated with every auto-save
		GlobalUpdates = GlobalUpdates, -- [GlobalUpdates]
		
		_profile_store = ProfileStore, -- [ProfileStore]
		_profile_key = "", -- [string]
		
		_release_listeners = [ScriptSignal] / nil, -- [table / nil]
		_hop_ready_listeners = [ScriptSignal] / nil, -- [table / nil]
		_hop_ready = false,
		
		_view_mode = true / nil, -- [bool] or nil
		
		_load_timestamp = os.clock(),
		
		_is_user_mock = false, -- ProfileStore.Mock
		_mock_key_info = {},
	--]]
}
Profile.__index = Profile

function Profile:IsActive() --> [bool]
	local loaded_profiles = self._is_user_mock == true and self._profile_store._mock_loaded_profiles or self._profile_store._loaded_profiles
	return loaded_profiles[self._profile_key] == self
end

function Profile:GetMetaTag(tag_name) --> value
	local meta_data = self.MetaData
	if meta_data == nil then
		return nil
		-- error("[ProfileService]: This Profile hasn't been loaded before - MetaData not available")
	end
	return self.MetaData.MetaTags[tag_name]
end

function Profile:SetMetaTag(tag_name, value)
	if type(tag_name) ~= "string" then
		error("[ProfileService]: tag_name must be a string")
	elseif string.len(tag_name) == 0 then
		error("[ProfileService]: Invalid tag_name")
	end
	self.MetaData.MetaTags[tag_name] = value
end

function Profile:Reconcile()
	ReconcileTable(self.Data, self._profile_store._profile_template)
end

function Profile:ListenToRelease(listener) --> [ScriptConnection] (place_id / nil, game_job_id / nil)
	if type(listener) ~= "function" then
		error("[ProfileService]: Only a function can be set as listener in Profile:ListenToRelease()")
	end
	if self._view_mode == true then
		return {Disconnect = function() end}
	end
	if self:IsActive() == false then
		-- Call release listener immediately if profile is expired
		local place_id
		local game_job_id
		local active_session = self.MetaData.ActiveSession
		if active_session ~= nil then
			place_id = active_session[1]
			game_job_id = active_session[2]
		end
		listener(place_id, game_job_id)
		return {Disconnect = function() end}
	else
		return self._release_listeners:Connect(listener)
	end
end

function Profile:Save()
	if self._view_mode == true then
		error("[ProfileService]: Can't save Profile in view mode - Should you be calling :OverwriteAsync() instead?")
	end
	if self:IsActive() == false then
		warn("[ProfileService]: Attempted saving an inactive profile "
			.. self:Identify() .. "; Traceback:\n" .. debug.traceback())
		return
	end
	-- Reject save request if a save is already pending in the queue - this will prevent the user from
	--	unecessary API request spam which we could not meaningfully execute anyways!
	if IsCustomWriteQueueEmptyFor(self._profile_store._profile_store_lookup, self._profile_key) == true then
		-- We don't want auto save to trigger too soon after manual saving - this will reset the auto save timer:
		RemoveProfileFromAutoSave(self)
		AddProfileToAutoSave(self)
		-- Call save function in a new thread:
		task.spawn(SaveProfileAsync, self)
	end
end

function Profile:Release()
	if self._view_mode == true then
		return
	end
	if self:IsActive() == true then
		task.spawn(SaveProfileAsync, self, true) -- Call save function in a new thread with release_from_session = true
	end
end

function Profile:ListenToHopReady(listener) --> [ScriptConnection] ()
	if type(listener) ~= "function" then
		error("[ProfileService]: Only a function can be set as listener in Profile:ListenToHopReady()")
	end
	if self._view_mode == true then
		return {Disconnect = function() end}
	end
	if self._hop_ready == true then
		task.spawn(listener)
		return {Disconnect = function() end}
	else
		return self._hop_ready_listeners:Connect(listener)
	end
end

function Profile:AddUserId(user_id) -- Associates user_id with profile (GDPR compliance)

	if type(user_id) ~= "number" or user_id % 1 ~= 0 then
		warn("[ProfileService]: Invalid UserId argument for :AddUserId() ("
			.. tostring(user_id) .. "); Traceback:\n" .. debug.traceback())
		return
	end

	if user_id < 0 and self._is_user_mock ~= true and UseMockDataStore ~= true then
		return -- Avoid giving real Roblox APIs negative UserId's
	end

	if table.find(self.UserIds, user_id) == nil then
		table.insert(self.UserIds, user_id)
	end
	
end

function Profile:RemoveUserId(user_id) -- Unassociates user_id with profile (safe function)

	if type(user_id) ~= "number" or user_id % 1 ~= 0 then
		warn("[ProfileService]: Invalid UserId argument for :RemoveUserId() ("
			.. tostring(user_id) .. "); Traceback:\n" .. debug.traceback())
		return
	end
	
	local index = table.find(self.UserIds, user_id)

	if index ~= nil then
		table.remove(self.UserIds, index)
	end

end

function Profile:Identify() --> [string]
	return IdentifyProfile(
		self._profile_store._profile_store_name,
		self._profile_store._profile_store_scope,
		self._profile_key
	)
end

function Profile:ClearGlobalUpdates() -- Clears all global updates data from a profile payload

	if self._view_mode ~= true then
		error("[ProfileService]: :ClearGlobalUpdates() can only be used in view mode")
	end

	local global_updates_object = {
		_updates_latest = {0, {}},
		_profile = self,
	}
	setmetatable(global_updates_object, GlobalUpdates)

	self.GlobalUpdates = global_updates_object

end

function Profile:OverwriteAsync() -- Saves the profile to the DataStore and removes the session lock

	if self._view_mode ~= true then
		error("[ProfileService]: :OverwriteAsync() can only be used in view mode")
	end

	SaveProfileAsync(self, nil, true)

end

-- ProfileVersionQuery object:

local ProfileVersionQuery = {
	--[[
		_profile_store = profile_store,
		_profile_key = profile_key,
		_sort_direction = sort_direction,
		_min_date = min_date,
		_max_date = max_date,

		_query_pages = pages, -- [DataStoreVersionPages]
		_query_index = index, -- [number]
		_query_failure = false,

		_is_query_yielded = false,
		_query_queue = {},
	--]]
}
ProfileVersionQuery.__index = ProfileVersionQuery

function ProfileVersionQuery:_MoveQueue()
	while #self._query_queue > 0 do
		local queue_entry = table.remove(self._query_queue, 1)
		task.spawn(queue_entry)
		if self._is_query_yielded == true then
			break
		end
	end
end

function ProfileVersionQuery:NextAsync(_is_stacking) --> [Profile] or nil

	if self._profile_store == nil then
		return nil
	end

	local profile
	local is_finished = false

	local function query_job()

		if self._query_failure == true then
			is_finished = true
			return
		end

		-- First "next" call loads version pages:

		if self._query_pages == nil then

			self._is_query_yielded = true
			task.spawn(function()
				profile = self:NextAsync(true)
				is_finished = true
			end)
			
			local list_success, error_message = pcall(function()
				self._query_pages = self._profile_store._global_data_store:ListVersionsAsync(
					self._profile_key,
					self._sort_direction,
					self._min_date,
					self._max_date
				)
				self._query_index = 0
			end)

			if list_success == false or self._query_pages == nil then
				warn("[ProfileService]: Version query fail - " .. tostring(error_message))
				self._query_failure = true
			end

			self._is_query_yielded = false
			self:_MoveQueue()

			return

		end

		local current_page = self._query_pages:GetCurrentPage()
		local next_item = current_page[self._query_index + 1]

		-- No more entries:
		
		if self._query_pages.IsFinished == true and next_item == nil then
			is_finished = true
			return
		end

		-- Load next page when this page is over:

		if next_item == nil then

			self._is_query_yielded = true
			task.spawn(function()
				profile = self:NextAsync(true)
				is_finished = true
			end)

			local success = pcall(function()
				self._query_pages:AdvanceToNextPageAsync()
				self._query_index = 0
			end)

			if success == false or #self._query_pages:GetCurrentPage() == 0 then
				self._query_failure = true
			end

			self._is_query_yielded = false
			self:_MoveQueue()

			return

		end

		-- Next page item:

		self._query_index += 1
		profile = self._profile_store:ViewProfileAsync(self._profile_key, next_item.Version)
		is_finished = true

	end

	if self._is_query_yielded == false then
		query_job()
	else
		if _is_stacking == true then
			table.insert(self._query_queue, 1, query_job)
		else
			table.insert(self._query_queue, query_job)
		end
	end

	while is_finished == false do
		task.wait()
	end

	return profile

end

-- ProfileStore object:

local ProfileStore = {
	--[[
		Mock = {},
	
		_profile_store_name = "", -- [string] -- DataStore name
		_profile_store_scope = nil, -- [string] or [nil] -- DataStore scope
		_profile_store_lookup = "", -- [string] -- _profile_store_name .. "\0" .. (_profile_store_scope or "")
		
		_profile_template = {}, -- [table]
		_global_data_store = global_data_store, -- [GlobalDataStore] -- Object returned by DataStoreService:GetDataStore(_profile_store_name)
		
		_loaded_profiles = {[profile_key] = Profile, ...},
		_profile_load_jobs = {[profile_key] = {load_id, loaded_data}, ...},
		
		_mock_loaded_profiles = {[profile_key] = Profile, ...},
		_mock_profile_load_jobs = {[profile_key] = {load_id, loaded_data}, ...},
	--]]
}
ProfileStore.__index = ProfileStore

function ProfileStore:LoadProfileAsync(profile_key, not_released_handler, _use_mock) --> [Profile / nil] not_released_handler(place_id, game_job_id)

	not_released_handler = not_released_handler or "ForceLoad"

	if self._profile_template == nil then
		error("[ProfileService]: Profile template not set - ProfileStore:LoadProfileAsync() locked for this ProfileStore")
	end
	if type(profile_key) ~= "string" then
		error("[ProfileService]: profile_key must be a string")
	elseif string.len(profile_key) == 0 then
		error("[ProfileService]: Invalid profile_key")
	end
	if type(not_released_handler) ~= "function" and not_released_handler ~= "ForceLoad" and not_released_handler ~= "Steal" then
		error("[ProfileService]: Invalid not_released_handler")
	end

	if ProfileService.ServiceLocked == true then
		return nil
	end

	WaitForPendingProfileStore(self)

	local is_user_mock = _use_mock == UseMockTag

	-- Check if profile with profile_key isn't already loaded in this session:
	for _, profile_store in ipairs(ActiveProfileStores) do
		if profile_store._profile_store_lookup == self._profile_store_lookup then
			local loaded_profiles = is_user_mock == true and profile_store._mock_loaded_profiles or profile_store._loaded_profiles
			if loaded_profiles[profile_key] ~= nil then
				error("[ProfileService]: Profile " .. IdentifyProfile(self._profile_store_name, self._profile_store_scope, profile_key) .. " is already loaded in this session")
				-- Are you using Profile:Release() properly?
			end
		end
	end

	ActiveProfileLoadJobs = ActiveProfileLoadJobs + 1
	local force_load = not_released_handler == "ForceLoad"
	local force_load_steps = 0
	local request_force_load = force_load -- First step of ForceLoad
	local steal_session = false -- Second step of ForceLoad
	local aggressive_steal = not_released_handler == "Steal" -- Developer invoked steal
	while ProfileService.ServiceLocked == false do
		-- Load profile:
		-- SPECIAL CASE - If LoadProfileAsync is called for the same key before another LoadProfileAsync finishes,
		-- yoink the DataStore return for the new call. The older call will return nil. This would prevent very rare
		-- game breaking errors where a player rejoins the server super fast.
		local profile_load_jobs = is_user_mock == true and self._mock_profile_load_jobs or self._profile_load_jobs
		local loaded_data, key_info
		local load_id = LoadIndex + 1
		LoadIndex = load_id
		local profile_load_job = profile_load_jobs[profile_key] -- {load_id, {loaded_data, key_info} or nil}
		if profile_load_job ~= nil then
			profile_load_job[1] = load_id -- Yoink load job
			while profile_load_job[2] == nil do -- Wait for job to finish
				task.wait()
			end
			if profile_load_job[1] == load_id then -- Load job hasn't been double-yoinked
				loaded_data, key_info = table.unpack(profile_load_job[2])
				profile_load_jobs[profile_key] = nil
			else
				ActiveProfileLoadJobs = ActiveProfileLoadJobs - 1
				return nil
			end
		else
			profile_load_job = {load_id, nil}
			profile_load_jobs[profile_key] = profile_load_job
			profile_load_job[2] = table.pack(StandardProfileUpdateAsyncDataStore(
				self,
				profile_key,
				{
					ExistingProfileHandle = function(latest_data)
						if ProfileService.ServiceLocked == false then
							local active_session = latest_data.MetaData.ActiveSession
							local force_load_session = latest_data.MetaData.ForceLoadSession
							-- IsThisSession(active_session)
							if active_session == nil then
								latest_data.MetaData.ActiveSession = {PlaceId, JobId}
								latest_data.MetaData.ForceLoadSession = nil
							elseif type(active_session) == "table" then
								if IsThisSession(active_session) == false then
									local last_update = latest_data.MetaData.LastUpdate
									if last_update ~= nil then
										if os.time() - last_update > SETTINGS.AssumeDeadSessionLock then
											latest_data.MetaData.ActiveSession = {PlaceId, JobId}
											latest_data.MetaData.ForceLoadSession = nil
											return
										end
									end
									if steal_session == true or aggressive_steal == true then
										local force_load_uninterrupted = false
										if force_load_session ~= nil then
											force_load_uninterrupted = IsThisSession(force_load_session)
										end
										if force_load_uninterrupted == true or aggressive_steal == true then
											latest_data.MetaData.ActiveSession = {PlaceId, JobId}
											latest_data.MetaData.ForceLoadSession = nil
										end
									elseif request_force_load == true then
										latest_data.MetaData.ForceLoadSession = {PlaceId, JobId}
									end
								else
									latest_data.MetaData.ForceLoadSession = nil
								end
							end
						end
					end,
					MissingProfileHandle = function(latest_data)
						latest_data.Data = DeepCopyTable(self._profile_template)
						latest_data.MetaData = {
							ProfileCreateTime = os.time(),
							SessionLoadCount = 0,
							ActiveSession = {PlaceId, JobId},
							ForceLoadSession = nil,
							MetaTags = {},
						}
					end,
					EditProfile = function(latest_data)
						if ProfileService.ServiceLocked == false then
							local active_session = latest_data.MetaData.ActiveSession
							if active_session ~= nil and IsThisSession(active_session) == true then
								latest_data.MetaData.SessionLoadCount = latest_data.MetaData.SessionLoadCount + 1
								latest_data.MetaData.LastUpdate = os.time()
							end
						end
					end,
				},
				is_user_mock
			))
			if profile_load_job[1] == load_id then -- Load job hasn't been yoinked
				loaded_data, key_info = table.unpack(profile_load_job[2])
				profile_load_jobs[profile_key] = nil
			else
				ActiveProfileLoadJobs = ActiveProfileLoadJobs - 1
				return nil -- Load job yoinked
			end
		end
		-- Handle load_data:
		if loaded_data ~= nil and key_info ~= nil then
			local active_session = loaded_data.MetaData.ActiveSession
			if type(active_session) == "table" then
				if IsThisSession(active_session) == true then
					-- Special component in MetaTags:
					loaded_data.MetaData.MetaTagsLatest = DeepCopyTable(loaded_data.MetaData.MetaTags)
					-- Case #1: Profile is now taken by this session:
					-- Create Profile object:
					local global_updates_object = {
						_updates_latest = loaded_data.GlobalUpdates,
						_pending_update_lock = {},
						_pending_update_clear = {},

						_new_active_update_listeners = Madwork.NewScriptSignal(),
						_new_locked_update_listeners = Madwork.NewScriptSignal(),

						_profile = nil,
					}
					setmetatable(global_updates_object, GlobalUpdates)
					local profile = {
						Data = loaded_data.Data,
						MetaData = loaded_data.MetaData,
						MetaTagsUpdated = Madwork.NewScriptSignal(),

						RobloxMetaData = loaded_data.RobloxMetaData or {},
						UserIds = loaded_data.UserIds or {},
						KeyInfo = key_info,
						KeyInfoUpdated = Madwork.NewScriptSignal(),

						GlobalUpdates = global_updates_object,

						_profile_store = self,
						_profile_key = profile_key,

						_release_listeners = Madwork.NewScriptSignal(),
						_hop_ready_listeners = Madwork.NewScriptSignal(),
						_hop_ready = false,

						_load_timestamp = os.clock(),

						_is_user_mock = is_user_mock,
					}
					setmetatable(profile, Profile)
					global_updates_object._profile = profile
					-- Referencing Profile object in ProfileStore:
					if next(self._loaded_profiles) == nil and next(self._mock_loaded_profiles) == nil then -- ProfileStore object was inactive
						table.insert(ActiveProfileStores, self)
					end
					if is_user_mock == true then
						self._mock_loaded_profiles[profile_key] = profile
					else
						self._loaded_profiles[profile_key] = profile
					end
					-- Adding profile to AutoSaveList;
					AddProfileToAutoSave(profile)
					-- Special case - finished loading profile, but session is shutting down:
					if ProfileService.ServiceLocked == true then
						SaveProfileAsync(profile, true) -- Release profile and yield until the DataStore call is finished
						profile = nil -- nil will be returned by this call
					end
					-- Return Profile object:
					ActiveProfileLoadJobs = ActiveProfileLoadJobs - 1
					return profile
				else
					-- Case #2: Profile is taken by some other session:
					if force_load == true then
						local force_load_session = loaded_data.MetaData.ForceLoadSession
						local force_load_uninterrupted = false
						if force_load_session ~= nil then
							force_load_uninterrupted = IsThisSession(force_load_session)
						end
						if force_load_uninterrupted == true then
							if request_force_load == false then
								force_load_steps = force_load_steps + 1
								if force_load_steps == SETTINGS.ForceLoadMaxSteps then
									steal_session = true
								end
							end
							task.wait() -- Overload prevention
						else
							-- Another session tried to force load this profile:
							ActiveProfileLoadJobs = ActiveProfileLoadJobs - 1
							return nil
						end
						request_force_load = false -- Only request a force load once
					elseif aggressive_steal == true then
						task.wait() -- Overload prevention
					else
						local handler_result = not_released_handler(active_session[1], active_session[2])
						if handler_result == "Repeat" then
							task.wait() -- Overload prevention
						elseif handler_result == "Cancel" then
							ActiveProfileLoadJobs = ActiveProfileLoadJobs - 1
							return nil
						elseif handler_result == "ForceLoad" then
							force_load = true
							request_force_load = true
							task.wait() -- Overload prevention
						elseif handler_result == "Steal" then
							aggressive_steal = true
							task.wait() -- Overload prevention
						else
							error(
								"[ProfileService]: Invalid return from not_released_handler (\"" .. tostring(handler_result) .. "\")(" .. type(handler_result) .. ");" ..
									"\n" .. IdentifyProfile(self._profile_store_name, self._profile_store_scope, profile_key) ..
									" Traceback:\n" .. debug.traceback()
							)
						end
					end
				end
			else
				ActiveProfileLoadJobs = ActiveProfileLoadJobs - 1
				return nil -- In this scenario it is likely the ProfileService.ServiceLocked flag was raised
			end
		else
			task.wait() -- Overload prevention
		end
	end
	ActiveProfileLoadJobs = ActiveProfileLoadJobs - 1
	return nil -- If loop breaks return nothing
end

function ProfileStore:GlobalUpdateProfileAsync(profile_key, update_handler, _use_mock) --> [GlobalUpdates / nil] (update_handler(GlobalUpdates))
	if type(profile_key) ~= "string" or string.len(profile_key) == 0 then
		error("[ProfileService]: Invalid profile_key")
	end
	if type(update_handler) ~= "function" then
		error("[ProfileService]: Invalid update_handler")
	end

	if ProfileService.ServiceLocked == true then
		return nil
	end

	WaitForPendingProfileStore(self)

	while ProfileService.ServiceLocked == false do
		-- Updating profile:
		local loaded_data = StandardProfileUpdateAsyncDataStore(
			self,
			profile_key,
			{
				ExistingProfileHandle = nil,
				MissingProfileHandle = nil,
				EditProfile = function(latest_data)
					-- Running update_handler:
					local global_updates_object = {
						_updates_latest = latest_data.GlobalUpdates,
						_update_handler_mode = true,
					}
					setmetatable(global_updates_object, GlobalUpdates)
					update_handler(global_updates_object)
				end,
			},
			_use_mock == UseMockTag
		)
		CustomWriteQueueMarkForCleanup(self._profile_store_lookup, profile_key)
		-- Handling loaded_data:
		if loaded_data ~= nil then
			-- Return GlobalUpdates object (Update successful):
			local global_updates_object = {
				_updates_latest = loaded_data.GlobalUpdates,
			}
			setmetatable(global_updates_object, GlobalUpdates)
			return global_updates_object
		else
			task.wait() -- Overload prevention
		end
	end
	return nil -- Return nothing (Update unsuccessful)
end

function ProfileStore:ViewProfileAsync(profile_key, version, _use_mock) --> [Profile / nil]
	if type(profile_key) ~= "string" or string.len(profile_key) == 0 then
		error("[ProfileService]: Invalid profile_key")
	end

	if ProfileService.ServiceLocked == true then
		return nil
	end

	WaitForPendingProfileStore(self)

	if version ~= nil and (_use_mock == UseMockTag or UseMockDataStore == true) then
		return nil -- No version support in mock mode
	end

	while ProfileService.ServiceLocked == false do
		-- Load profile:
		local loaded_data, key_info = StandardProfileUpdateAsyncDataStore(
			self,
			profile_key,
			{
				ExistingProfileHandle = nil,
				MissingProfileHandle = function(latest_data)
					latest_data.Data = DeepCopyTable(self._profile_template)
					latest_data.MetaData = {
						ProfileCreateTime = os.time(),
						SessionLoadCount = 0,
						ActiveSession = nil,
						ForceLoadSession = nil,
						MetaTags = {},
					}
				end,
				EditProfile = nil,
			},
			_use_mock == UseMockTag,
			true, -- Use :GetAsync()
			version -- DataStore key version
		)
		CustomWriteQueueMarkForCleanup(self._profile_store_lookup, profile_key)
		-- Handle load_data:
		if loaded_data ~= nil then
			if key_info == nil then
				return nil -- Load was successful, but the key was empty - return no profile object
			end
			-- Create Profile object:
			local global_updates_object = {
				_updates_latest = loaded_data.GlobalUpdates, -- {0, {}}
				_profile = nil,
			}
			setmetatable(global_updates_object, GlobalUpdates)
			local profile = {
				Data = loaded_data.Data,
				MetaData = loaded_data.MetaData,
				MetaTagsUpdated = Madwork.NewScriptSignal(),

				RobloxMetaData = loaded_data.RobloxMetaData or {},
				UserIds = loaded_data.UserIds or {},
				KeyInfo = key_info,
				KeyInfoUpdated = Madwork.NewScriptSignal(),

				GlobalUpdates = global_updates_object,

				_profile_store = self,
				_profile_key = profile_key,

				_view_mode = true,

				_load_timestamp = os.clock(),
			}
			setmetatable(profile, Profile)
			global_updates_object._profile = profile
			-- Returning Profile object:
			return profile
		else
			task.wait() -- Overload prevention
		end
	end
	return nil -- If loop breaks return nothing
end

function ProfileStore:ProfileVersionQuery(profile_key, sort_direction, min_date, max_date, _use_mock) --> [ProfileVersionQuery]
	if type(profile_key) ~= "string" or string.len(profile_key) == 0 then
		error("[ProfileService]: Invalid profile_key")
	end

	if ProfileService.ServiceLocked == true then
		return setmetatable({}, ProfileVersionQuery) -- Silently fail :Next() requests
	end

	WaitForPendingProfileStore(self)

	if _use_mock == UseMockTag or UseMockDataStore == true then
		error("[ProfileService]: :ProfileVersionQuery() is not supported in mock mode")
	end

	-- Type check:
	if sort_direction ~= nil and (typeof(sort_direction) ~= "EnumItem"
		or sort_direction.EnumType ~= Enum.SortDirection) then
		error("[ProfileService]: Invalid sort_direction (" .. tostring(sort_direction) .. ")")
	end

	if min_date ~= nil and typeof(min_date) ~= "DateTime" and typeof(min_date) ~= "number" then
		error("[ProfileService]: Invalid min_date (" .. tostring(min_date) .. ")")
	end

	if max_date ~= nil and typeof(max_date) ~= "DateTime" and typeof(max_date) ~= "number" then
		error("[ProfileService]: Invalid max_date (" .. tostring(max_date) .. ")")
	end

	min_date = typeof(min_date) == "DateTime" and min_date.UnixTimestampMillis or min_date
	max_date = typeof(max_date) == "DateTime" and max_date.UnixTimestampMillis or max_date

	local profile_version_query = {
		_profile_store = self,
		_profile_key = profile_key,
		_sort_direction = sort_direction,
		_min_date = min_date,
		_max_date = max_date,

		_query_pages = nil,
		_query_index = 0,
		_query_failure = false,

		_is_query_yielded = false,
		_query_queue = {},
	}
	setmetatable(profile_version_query, ProfileVersionQuery)

	return profile_version_query

end

function ProfileStore:WipeProfileAsync(profile_key, _use_mock) --> is_wipe_successful [bool]
	if type(profile_key) ~= "string" or string.len(profile_key) == 0 then
		error("[ProfileService]: Invalid profile_key")
	end

	if ProfileService.ServiceLocked == true then
		return false
	end

	WaitForPendingProfileStore(self)

	local wipe_status = false

	if _use_mock == UseMockTag then -- Used when the profile is accessed through ProfileStore.Mock
		local mock_data_store = UserMockDataStore[self._profile_store_lookup]
		if mock_data_store ~= nil then
			mock_data_store[profile_key] = nil
		end
		wipe_status = true
		task.wait() -- Simulate API call yield
	elseif UseMockDataStore == true then -- Used when API access is disabled
		local mock_data_store = MockDataStore[self._profile_store_lookup]
		if mock_data_store ~= nil then
			mock_data_store[profile_key] = nil
		end
		wipe_status = true
		task.wait() -- Simulate API call yield
	else
		wipe_status = pcall(function()
			self._global_data_store:RemoveAsync(profile_key)
		end)
	end

	CustomWriteQueueMarkForCleanup(self._profile_store_lookup, profile_key)

	return wipe_status
end

-- New ProfileStore:

function ProfileService.GetProfileStore(profile_store_index, profile_template) --> [ProfileStore]

	local profile_store_name
	local profile_store_scope = nil

	-- Parsing profile_store_index:
	if type(profile_store_index) == "string" then
		-- profile_store_index as string:
		profile_store_name = profile_store_index
	elseif type(profile_store_index) == "table" then
		-- profile_store_index as table:
		profile_store_name = profile_store_index.Name
		profile_store_scope = profile_store_index.Scope
	else
		error("[ProfileService]: Invalid or missing profile_store_index")
	end

	-- Type checking:
	if profile_store_name == nil or type(profile_store_name) ~= "string" then
		error("[ProfileService]: Missing or invalid \"Name\" parameter")
	elseif string.len(profile_store_name) == 0 then
		error("[ProfileService]: ProfileStore name cannot be an empty string")
	end

	if profile_store_scope ~= nil and (type(profile_store_scope) ~= "string" or string.len(profile_store_scope) == 0) then
		error("[ProfileService]: Invalid \"Scope\" parameter")
	end

	if type(profile_template) ~= "table" then
		error("[ProfileService]: Invalid profile_template")
	end

	local profile_store
	profile_store = {
		Mock = {
			LoadProfileAsync = function(_, profile_key, not_released_handler)
				return profile_store:LoadProfileAsync(profile_key, not_released_handler, UseMockTag)
			end,
			GlobalUpdateProfileAsync = function(_, profile_key, update_handler)
				return profile_store:GlobalUpdateProfileAsync(profile_key, update_handler, UseMockTag)
			end,
			ViewProfileAsync = function(_, profile_key, version)
				return profile_store:ViewProfileAsync(profile_key, version, UseMockTag)
			end,
			FindProfileVersionAsync = function(_, profile_key, sort_direction, min_date, max_date)
				return profile_store:FindProfileVersionAsync(profile_key, sort_direction, min_date, max_date, UseMockTag)
			end,
			WipeProfileAsync = function(_, profile_key)
				return profile_store:WipeProfileAsync(profile_key, UseMockTag)
			end
		},

		_profile_store_name = profile_store_name,
		_profile_store_scope = profile_store_scope,
		_profile_store_lookup = profile_store_name .. "\0" .. (profile_store_scope or ""),

		_profile_template = profile_template,
		_global_data_store = nil,
		_loaded_profiles = {},
		_profile_load_jobs = {},
		_mock_loaded_profiles = {},
		_mock_profile_load_jobs = {},
		_is_pending = false,
	}
	setmetatable(profile_store, ProfileStore)

	if IsLiveCheckActive == true then
		profile_store._is_pending = true
		task.spawn(function()
			WaitForLiveAccessCheck()
			if UseMockDataStore == false then
				profile_store._global_data_store = DataStoreService:GetDataStore(profile_store_name, profile_store_scope)
			end
			profile_store._is_pending = false
		end)
	else
		if UseMockDataStore == false then
			profile_store._global_data_store = DataStoreService:GetDataStore(profile_store_name, profile_store_scope)
		end
	end

	return profile_store
end

function ProfileService.IsLive() --> [bool] -- (CAN YIELD!!!)

	WaitForLiveAccessCheck()

	return UseMockDataStore == false

end

----- Initialize -----

if IsStudio == true then
	IsLiveCheckActive = true
	task.spawn(function()
		local status, message = pcall(function()
			-- This will error if current instance has no Studio API access:
			DataStoreService:GetDataStore("____PS"):SetAsync("____PS", os.time())
		end)
		local no_internet_access = status == false and string.find(message, "ConnectFail", 1, true) ~= nil
		if no_internet_access == true then
			warn("[ProfileService]: No internet access - check your network connection")
		end
		if status == false and
			(string.find(message, "403", 1, true) ~= nil or -- Cannot write to DataStore from studio if API access is not enabled
				string.find(message, "must publish", 1, true) ~= nil or -- Game must be published to access live keys
				no_internet_access == true) then -- No internet access

			UseMockDataStore = true
			ProfileService._use_mock_data_store = true
			print("[ProfileService]: Roblox API services unavailable - data will not be saved")
		else
			print("[ProfileService]: Roblox API services available - data will be saved")
		end
		IsLiveCheckActive = false
	end)
end

----- Connections -----

-- Auto saving and issue queue managing:
RunService.Heartbeat:Connect(function()
	-- 1) Auto saving: --
	local auto_save_list_length = #AutoSaveList
	if auto_save_list_length > 0 then
		local auto_save_index_speed = SETTINGS.AutoSaveProfiles / auto_save_list_length
		local os_clock = os.clock()
		while os_clock - LastAutoSave > auto_save_index_speed do
			LastAutoSave = LastAutoSave + auto_save_index_speed
			local profile = AutoSaveList[AutoSaveIndex]
			if os_clock - profile._load_timestamp < SETTINGS.AutoSaveProfiles then
				-- This profile is freshly loaded - auto-saving immediately after loading will cause a warning in the log:
				profile = nil
				for _ = 1, auto_save_list_length - 1 do
					-- Move auto save index to the right:
					AutoSaveIndex = AutoSaveIndex + 1
					if AutoSaveIndex > auto_save_list_length then
						AutoSaveIndex = 1
					end
					profile = AutoSaveList[AutoSaveIndex]
					if os_clock - profile._load_timestamp >= SETTINGS.AutoSaveProfiles then
						break
					else
						profile = nil
					end
				end
			end
			-- Move auto save index to the right:
			AutoSaveIndex = AutoSaveIndex + 1
			if AutoSaveIndex > auto_save_list_length then
				AutoSaveIndex = 1
			end
			-- Perform save call:
			if profile ~= nil then
				task.spawn(SaveProfileAsync, profile) -- Auto save profile in new thread
			end
		end
	end
	-- 2) Issue queue: --
	-- Critical state handling:
	if ProfileService.CriticalState == false then
		if #IssueQueue >= SETTINGS.IssueCountForCriticalState then
			ProfileService.CriticalState = true
			ProfileService.CriticalStateSignal:Fire(true)
			CriticalStateStart = os.clock()
			warn("[ProfileService]: Entered critical state")
		end
	else
		if #IssueQueue >= SETTINGS.IssueCountForCriticalState then
			CriticalStateStart = os.clock()
		elseif os.clock() - CriticalStateStart > SETTINGS.CriticalStateLast then
			ProfileService.CriticalState = false
			ProfileService.CriticalStateSignal:Fire(false)
			warn("[ProfileService]: Critical state ended")
		end
	end
	-- Issue queue:
	while true do
		local issue_time = IssueQueue[1]
		if issue_time == nil then
			break
		elseif os.clock() - issue_time > SETTINGS.IssueLast then
			table.remove(IssueQueue, 1)
		else
			break
		end
	end
end)

-- Release all loaded profiles when the server is shutting down:
task.spawn(function()
	WaitForLiveAccessCheck()
	Madwork.ConnectToOnClose(
		function()
			ProfileService.ServiceLocked = true
			-- 1) Release all active profiles: --
			-- Clone AutoSaveList to a new table because AutoSaveList changes when profiles are released:
			local on_close_save_job_count = 0
			local active_profiles = {}
			for index, profile in ipairs(AutoSaveList) do
				active_profiles[index] = profile
			end
			-- Release the profiles; Releasing profiles can trigger listeners that release other profiles, so check active state:
			for _, profile in ipairs(active_profiles) do
				if profile:IsActive() == true then
					on_close_save_job_count = on_close_save_job_count + 1
					task.spawn(function() -- Save profile on new thread
						SaveProfileAsync(profile, true)
						on_close_save_job_count = on_close_save_job_count - 1
					end)
				end
			end
			-- 2) Yield until all active profile jobs are finished: --
			while on_close_save_job_count > 0 or ActiveProfileLoadJobs > 0 or ActiveProfileSaveJobs > 0 do
				task.wait()
			end
			return -- We're done!
		end,
		UseMockDataStore == false -- Always run this OnClose task if using Roblox API services
	)
end)

return ProfileService]=])
install(game:GetService("ServerScriptService"), "ShopBuilder", "ModuleScript", [=[
-- ShopBuilder (ModuleScript in ServerScriptService)
-- Builds a world's Pickaxe Shop: a cartoony 2050 pavilion on a round tiered platform,
-- with a flying-saucer roof held up by chunky capsule pillars, a curved back wall,
-- glass display capsules on stepped pedestals (one pickaxe per depth zone), a floating
-- robot shopkeeper, a big glowing sign with a giant pickaxe, and a depth meter.
-- DigManager calls this once per world on server start.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local ShovelModels = require(ReplicatedStorage:WaitForChild("PickaxeModels"))
local Architecture = require(script.Parent:WaitForChild("Architecture"))

-- Places a copy of a pickaxe model at `target` (target's axes = the tool's axes), scaled
local function displayShovel(parent, def, target, scale)
	local tool = ShovelModels(def)
	local handle = tool:FindFirstChild("Handle")
	local display = Instance.new("Model")
	display.Name = "Display_" .. def.Id
	for _, piece in ipairs(tool:GetChildren()) do
		if piece:IsA("BasePart") and piece ~= handle then
			local rel = handle.CFrame:ToObjectSpace(piece.CFrame)
			piece.Size = piece.Size * scale
			piece.CFrame = target * CFrame.new(rel.Position * scale) * rel.Rotation
			piece.Anchored = true
			piece.CanCollide = false
			local center = piece:GetAttribute("OrbitCenter")
			if center then
				-- ShovelSpinner (client) spins these around the shaft
				local pivot = target * CFrame.new(center * scale)
				piece:SetAttribute("OrbitPivot", pivot)
				piece:SetAttribute("OrbitOffset", pivot:ToObjectSpace(piece.CFrame))
				CollectionService:AddTag(piece, "ShovelOrbit")
			end
			for _, c in ipairs(piece:GetChildren()) do
				if c:IsA("WeldConstraint") then c:Destroy() end
			end
			piece.Parent = display
		end
	end
	tool:Destroy()
	display.Parent = parent
	return display
end

-- a point on a circle around the shop center (0 degrees = straight back, +X to the right)
local function around(deg, radius, y)
	local a = math.rad(deg)
	return Vector3.new(math.sin(a) * radius, y, math.cos(a) * radius)
end

-- parent: where the shop goes. world: a GameConfig world. base: the shop's CFrame
-- (its front, local -Z, faces the pit).
return function(parent, world, base)
	local shop = Instance.new("Model")
	shop.Name = "ShovelShop"
	local b = Architecture.builder(shop, base)

	-----------------------------------------------------------------
	-- ROUND TIERED PLATFORM with a glowing lip
	-----------------------------------------------------------------
	b:disc("PlatformLip", 30, 0.5, CFrame.new(0, 0.25, 0), "Sky")
	b:disc("PlatformGlow", 29.2, 0.3, CFrame.new(0, 0.62, 0), "GlowCyan")
	b:disc("Platform", 28.4, 0.7, CFrame.new(0, 0.85, 0), "White")
	b:disc("PlatformInner", 22, 0.3, CFrame.new(0, 1.35, 0), "Cloud")
	b:disc("FloorStar", 9, 0.06, CFrame.new(0, 1.52, -2.5), "Lilac")
	b:disc("FloorStarCore", 5, 0.08, CFrame.new(0, 1.54, -2.5), "White")
	-- chunky front steps
	b:roundedBlock("StepLow", Vector3.new(10, 0.5, 3), CFrame.new(0, 0.25, -14.6), 1.4, "Cloud")

	-----------------------------------------------------------------
	-- CURVED BACK WALL: rounded panels with porthole windows
	-----------------------------------------------------------------
	for i, deg in ipairs({-72, -36, 0, 36, 72}) do
		local p = around(deg, 11.2, 7)
		local cf = CFrame.lookAt(p, Vector3.new(0, 7, 0))
		b:roundedBlock("WallPanel", Vector3.new(7.4, 11, 1.4), cf, 0.7, i % 2 == 1 and "White" or "Cloud")
		b:ball("WallTop", 1.6, cf * CFrame.new(0, 5.9, 0), "Lilac")
		-- porthole: glass disc in a lilac frame
		b:rod("PortholeRim", 0.4, 3.6, cf * CFrame.new(0, 1.2, -0.6) * CFrame.Angles(0, math.rad(90), 0), "Lilac")
		b:rod("Porthole", 0.5, 2.8, cf * CFrame.new(0, 1.2, -0.65) * CFrame.Angles(0, math.rad(90), 0), "Glass")
		b:box("WallStripe", Vector3.new(6.6, 0.35, 0.2), cf * CFrame.new(0, -3.5, -0.75), "GlowPink")
	end

	-----------------------------------------------------------------
	-- CAPSULE PILLARS holding up the saucer roof
	-----------------------------------------------------------------
	for _, deg in ipairs({-140, 140}) do
		local p = around(deg, 12.6, 0)
		b:pill("Pillar", p + Vector3.new(0, 2.2, 0), p + Vector3.new(0, 13.2, 0), 1.9, "Lilac")
		b:disc("PillarFoot", 3.4, 0.9, CFrame.new(p + Vector3.new(0, 1.65, 0)), "Violet")
		b:disc("PillarBand", 2.3, 0.35, CFrame.new(p + Vector3.new(0, 9, 0)), "GlowSun")
	end

	-----------------------------------------------------------------
	-- FLYING-SAUCER ROOF: disc rim with bulbs, a glass bubble dome on top
	-----------------------------------------------------------------
	b:ellipsoid("SaucerUnder", Vector3.new(30, 3.2, 30), CFrame.new(0, 13.9, 0), "Sky")
	b:disc("SaucerRim", 31, 1.1, CFrame.new(0, 14.6, 0), "Sky")
	b:disc("SaucerRimGlow", 31.4, 0.3, CFrame.new(0, 14.1, 0), "GlowCyan")
	b:ellipsoid("SaucerTop", Vector3.new(29, 4, 29), CFrame.new(0, 15.1, 0), "White")
	for i = 0, 15 do
		local p = around(i * 22.5, 15.4, 14.6)
		b:bulb("RimBulb", 0.8, CFrame.new(p), i % 2 == 0 and "GlowSun" or "GlowPink", 6)
	end
	b:ellipsoid("Bubble", Vector3.new(13, 9, 13), CFrame.new(0, 17, 1.5), "Glass")
	b:disc("BubbleRing", 13.6, 0.5, CFrame.new(0, 17.1, 1.5), "Lilac")
	b:ball("Beacon", 1.5, CFrame.new(0, 21.6, 1.5), "GlowPink")
	b:rod("BeaconStem", 1.2, 0.3, CFrame.new(0, 21, 1.5) * CFrame.Angles(0, 0, math.rad(90)), "Chrome")
	-- ceiling light under the saucer
	local ceiling = b:disc("CeilingLight", 8, 0.2, CFrame.new(0, 12.25, 0), "GlowCyan")
	local light = Instance.new("PointLight")
	light.Color = Architecture.LightColor
	light.Range = 22
	light.Brightness = 1.2
	light.Parent = ceiling

	-----------------------------------------------------------------
	-- BIG SIGN on top, with a giant shovel leaning on it
	-----------------------------------------------------------------
	b:pill("SignPost", Vector3.new(-5, 16.5, -6), Vector3.new(-5, 19.5, -6), 0.7, "Chrome")
	b:pill("SignPost", Vector3.new(5, 16.5, -6), Vector3.new(5, 19.5, -6), 0.7, "Chrome")
	b:roundedBlock("SignBack", Vector3.new(19, 5.2, 1.2), CFrame.new(0, 21.8, -6), 2.2, "Violet")
	local sign = b:roundedBlock("Sign", Vector3.new(18, 4.4, 1.4), CFrame.new(0, 21.8, -6.1), 1.9, "Navy")
	Architecture.sign(sign, "PICKAXE SHOP", "DIG DEEPER, FIND WEIRDER!")
	b:box("SignGlow", Vector3.new(18.4, 0.3, 1.5), CFrame.new(0, 19.35, -6.1), "GlowSun")
	-- a giant copy of this world's best pickaxe standing beside the sign (head up, arms facing out)
	local HEAD_UP = CFrame.Angles(0, math.rad(90), 0) * CFrame.Angles(math.rad(90), 0, 0)
	local best = world.Shovels[#world.Shovels]
	if best then
		displayShovel(shop, best, base * CFrame.new(12, 22, -5) * CFrame.Angles(0, 0, math.rad(-24)) * HEAD_UP, 2.2)
	end

	-----------------------------------------------------------------
	-- COUNTER (rounded, two-tone) with the shop prompt
	-----------------------------------------------------------------
	local counter = b:roundedBlock("Counter", Vector3.new(10, 3, 2.8), CFrame.new(0, 3, -4.2), 1.3, "Sky")
	b:roundedBlock("CounterTop", Vector3.new(10.8, 0.5, 3.4), CFrame.new(0, 4.7, -4.2), 1.6, "White")
	b:box("CounterStripe", Vector3.new(7.6, 0.4, 0.2), CFrame.new(0, 3.2, -5.62), "GlowSun")
	for _, x in ipairs({-3, 0, 3}) do
		b:ball("CounterDot", 0.7, CFrame.new(x, 2.2, -5.55), "White")
	end

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Browse"
	prompt.ObjectText = "Pickaxes"
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = counter

	-----------------------------------------------------------------
	-- ROBOT SHOPKEEPER floating behind the counter
	-----------------------------------------------------------------
	local bot = Vector3.new(0, 7.4, -1.2)
	b:ball("RobotHead", 3, CFrame.new(bot), "White")
	b:ellipsoid("RobotVisor", Vector3.new(2.4, 1.2, 1), CFrame.new(bot + Vector3.new(0, 0.1, -1.15)), "Ink")
	b:ball("RobotEyeL", 0.45, CFrame.new(bot + Vector3.new(-0.5, 0.15, -1.62)), "GlowCyan")
	b:ball("RobotEyeR", 0.45, CFrame.new(bot + Vector3.new(0.5, 0.15, -1.62)), "GlowCyan")
	b:ellipsoid("RobotBlushL", Vector3.new(0.5, 0.25, 0.1), CFrame.new(bot + Vector3.new(-1, -0.45, -1.3)), "Coral")
	b:ellipsoid("RobotBlushR", Vector3.new(0.5, 0.25, 0.1), CFrame.new(bot + Vector3.new(1, -0.45, -1.3)), "Coral")
	b:rod("RobotAntenna", 1.1, 0.16, CFrame.new(bot + Vector3.new(0, 1.9, 0)) * CFrame.Angles(0, 0, math.rad(90)), "Chrome")
	b:bulb("RobotAntennaTip", 0.55, CFrame.new(bot + Vector3.new(0, 2.5, 0)), "GlowPink", 6)
	b:ellipsoid("RobotBody", Vector3.new(2.2, 2.2, 1.8), CFrame.new(bot + Vector3.new(0, -2.2, 0)), "Lilac")
	b:ring("RobotHoverRing", CFrame.new(bot + Vector3.new(0, -3.5, 0)) * CFrame.Angles(math.rad(90), 0, 0), 1.2, 0.25, "GlowCyan", 14)

	-----------------------------------------------------------------
	-- GLASS DISPLAY CAPSULES on stepped pedestals (one per depth zone)
	-----------------------------------------------------------------
	local spots = {-60, -22, 22, 60}
	for zoneIndex, zone in ipairs(world.Zones) do
		local def = GameConfig.GetFirstShovelForZone(world, zoneIndex)
		local p = around(spots[zoneIndex], 7.6, 1.5)
		local cf = CFrame.new(p)
		local _, h = b:tiers("Pedestal" .. zoneIndex, cf, {
			{3.8, 0.4, "Violet"},
			{3.2, 0.3 + zoneIndex * 0.45, "White"},
			{3.5, 0.3, "Sky"},
		})
		local capsuleH = 6.6
		local mid = cf * CFrame.new(0, h + capsuleH / 2, 0)
		b:disc("CapsuleGlass", 3, capsuleH, mid, "Glass", {Transparency = 0.6})
		b:ellipsoid("CapsuleDome", Vector3.new(3.1, 1.9, 3.1), mid * CFrame.new(0, capsuleH / 2, 0), "Glass", {Transparency = 0.6})
		b:disc("CapsuleCap", 3.2, 0.35, mid * CFrame.new(0, capsuleH / 2, 0), "Lilac")
		b:disc("CapsuleGlow", 3, 0.2, cf * CFrame.new(0, h + 0.1, 0), "GlowMint")
		local tag = b:roundedBlock("ZoneTag", Vector3.new(3.2, 1.1, 0.4), cf * CFrame.new(0, h - 0.9, -1.75), 0.2, "Navy")
		Architecture.sign(tag, string.upper(zone.Name), -zone.Top .. "-" .. -zone.Bottom .. "m")
		if def then
			-- head up, arms facing out of the capsule
			displayShovel(shop, def, base * mid * CFrame.new(0, 0.2, 0) * CFrame.Angles(0, math.rad(90), 0) * CFrame.Angles(math.rad(90), 0, 0), 0.85)
		end
	end

	-----------------------------------------------------------------
	-- DEPTH METER: a tall capsule split into the zone colors, labels on the front
	-----------------------------------------------------------------
	local meter = Vector3.new(-15.5, 0, -8)
	b:disc("MeterBase", 4, 0.8, CFrame.new(meter + Vector3.new(0, 0.4, 0)), "Violet")
	local segment = 2.6
	for i, zone in ipairs(world.Zones) do
		local y = 1 + (#world.Zones - i) * segment + segment / 2
		local seg = b:disc("MeterSegment", 2.6, segment - 0.15, CFrame.new(meter + Vector3.new(0, y, 0)), "White")
		seg.Color = zone.Color
		local tag = b:box("MeterLabel", Vector3.new(3.6, 1.6, 0.2), CFrame.new(meter + Vector3.new(0, y, -1.45)), "Navy")
		Architecture.sign(tag, string.upper(zone.Name), -zone.Top .. "-" .. -zone.Bottom .. "m", nil, Color3.new(1, 1, 1))
	end
	local topY = 1 + #world.Zones * segment
	b:ellipsoid("MeterTop", Vector3.new(2.7, 1.8, 2.7), CFrame.new(meter + Vector3.new(0, topY, 0)), "Lilac")
	b:bulb("MeterBulb", 0.8, CFrame.new(meter + Vector3.new(0, topY + 1.1, 0)), "GlowSun", 8)

	shop.Parent = parent
	return shop, prompt
end
]=])
install(game:GetService("ServerScriptService"), "VisitorManager", "Script", [=[
-- VisitorManager (Script in ServerScriptService)
-- Autonomous NPC visitors for every player's museum (World 1). Humans and aliens from 2050
-- appear on the plaza, walk in through the entrance with PathfindingService, visit a few
-- display slots that have a meme on them (taking the "lift" to the right floor), stop in
-- front of each one, react with a floating emoji, then walk back out and fade away.
-- Visitors never give money; they just make the museum feel alive.

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local buildVisitor = require(script.Parent:WaitForChild("VisitorModels"))

local MAX_VISITORS = 4           -- per museum at once
local SPAWN_EVERY = {8, 18}      -- seconds between new visitors (random in this range)
local SLOTS_PER_VISIT = {2, 4}   -- how many memes each visitor looks at
local LOOK_TIME = {2.5, 4.5}     -- seconds spent in front of each meme
local ALIEN_CHANCE = 0.35
local STEP_TIMEOUT = 4           -- give up on a waypoint after this many seconds (then skip ahead)

-- standard R15 animations (made by Roblox, usable in every game)
local WALK_ANIMATION = "rbxassetid://507777826"
local IDLE_ANIMATION = "rbxassetid://507766388"

-- Emoji reactions by how rare the meme is
local REACTIONS = {
	Low = {"😐", "🥱", "🤔", "🙂", "🤮", "😬", "🙄"},
	Mid = {"😮", "😄", "👍", "😂", "👏", "🤔", "😎"},
	High = {"🤩", "😍", "🔥", "🤯", "😱", "👑", "💯"},
}

-- Visitors don't bump into players (or each other); they still stand on the floors
for _, group in ipairs({"Visitors", "Players"}) do
	if not PhysicsService:IsCollisionGroupRegistered(group) then
		PhysicsService:RegisterCollisionGroup(group)
	end
end
PhysicsService:CollisionGroupSetCollidable("Visitors", "Visitors", false)
PhysicsService:CollisionGroupSetCollidable("Visitors", "Players", false)
local function groupCharacter(character)
	for _, d in ipairs(character:GetDescendants()) do
		if d:IsA("BasePart") then d.CollisionGroup = "Players" end
	end
	character.DescendantAdded:Connect(function(d)
		if d:IsA("BasePart") then d.CollisionGroup = "Players" end
	end)
end
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(groupCharacter)
end)
for _, player in ipairs(Players:GetPlayers()) do
	player.CharacterAdded:Connect(groupCharacter)
	if player.Character then groupCharacter(player.Character) end
end

local rng = Random.new()
local visitorsFolder = workspace:FindFirstChild("MuseumVisitors") or Instance.new("Folder")
visitorsFolder.Name = "MuseumVisitors"
visitorsFolder.Parent = workspace

---------------------------------------------------------------------
-- MUSEUM GEOMETRY
-- MuseumBuilder leaves invisible marker parts for visitors: Waypoints/Outside, Door and
-- Lobby, a ViewSpot in front of every display slot (plus the slot's Floor attribute), and
-- the lift pads' FloorNArrival spots. They move with the museum, so any plot works.
---------------------------------------------------------------------
-- a random point on a marker part's top (so visitors don't all stand in the same spot)
local function pointOn(part)
	local half = part.Size / 2
	return (part.CFrame * CFrame.new(rng:NextNumber(-half.X, half.X) * 0.8, 0, rng:NextNumber(-half.Z, half.Z) * 0.8)).Position
end

local function waypoint(museum, name)
	local folder = museum:FindFirstChild("Waypoints")
	local part = folder and folder:FindFirstChild(name)
	return part and pointOn(part)
end

local function floorArrival(museum, floor)
	local arrivals = museum:FindFirstChild("Arrivals")
	local part = arrivals and arrivals:FindFirstChild("Floor" .. floor .. "Arrival")
	return part and part.Position
end

-- where a visitor stands to look at a slot, what they look at, and which floor it's on
local function viewingSpot(slot)
	local view, spot = slot:FindFirstChild("ViewSpot"), slot:FindFirstChild("DisplaySpot")
	if not view or not spot then return nil end
	local sideways = view.CFrame.RightVector * rng:NextNumber(-1.5, 1.5)
	return view.Position + sideways, spot.Position, slot:GetAttribute("Floor") or 1
end

local function occupiedSlots(museum)
	local list = {}
	local slots = museum:FindFirstChild("Slots")
	for _, slot in ipairs(slots and slots:GetChildren() or {}) do
		local artifact = ArtifactData.GetArtifact(slot:GetAttribute("ArtifactId") or "")
		if artifact then
			table.insert(list, {Slot = slot, Artifact = artifact})
		end
	end
	return list
end

---------------------------------------------------------------------
-- EMOJI REACTIONS (BillboardGui over the visitor's head)
---------------------------------------------------------------------
local function react(npc, artifact)
	local head = npc:FindFirstChild("Head")
	if not head then return end
	local rarity = ArtifactData.GetRarityIndex(artifact.Rarity)
	local pool = rarity >= 5 and REACTIONS.High or (rarity >= 3 and REACTIONS.Mid or REACTIONS.Low)
	-- rare memes almost always get a great reaction; common ones sometimes still impress
	if rarity < 5 and rng:NextNumber() < 0.15 then pool = REACTIONS.High end

	local old = head:FindFirstChild("Reaction")
	if old then old:Destroy() end
	local gui = Instance.new("BillboardGui")
	gui.Name = "Reaction"
	gui.Size = UDim2.fromScale(0, 0)
	gui.StudsOffset = Vector3.new(0, 2.6, 0)
	gui.AlwaysOnTop = false
	gui.MaxDistance = 90
	gui.LightInfluence = 0
	gui.Parent = head

	local bubble = Instance.new("Frame")
	bubble.Size = UDim2.fromScale(1, 1)
	bubble.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	bubble.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.5, 0)
	corner.Parent = bubble
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = ArtifactData.GetRarity(artifact.Rarity).Color
	stroke.Parent = bubble
	local emoji = Instance.new("TextLabel")
	emoji.BackgroundTransparency = 1
	emoji.Size = UDim2.fromScale(0.78, 0.78)
	emoji.Position = UDim2.fromScale(0.5, 0.5)
	emoji.AnchorPoint = Vector2.new(0.5, 0.5)
	emoji.Text = pool[rng:NextInteger(1, #pool)]
	emoji.TextScaled = true
	emoji.Font = Enum.Font.GothamBold
	emoji.Parent = bubble

	-- pop in, hover, fade out
	TweenService:Create(gui, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.fromScale(2.6, 2.6)}):Play()
	TweenService:Create(gui, TweenInfo.new(2.4, Enum.EasingStyle.Sine), {StudsOffset = Vector3.new(0, 3.4, 0)}):Play()
	task.delay(2.2, function()
		if not gui.Parent then return end
		local fade = TweenInfo.new(0.4)
		TweenService:Create(bubble, fade, {BackgroundTransparency = 1}):Play()
		TweenService:Create(stroke, fade, {Transparency = 1}):Play()
		TweenService:Create(emoji, fade, {TextTransparency = 1}):Play()
		task.delay(0.45, function() gui:Destroy() end)
	end)
end

---------------------------------------------------------------------
-- MOVEMENT
---------------------------------------------------------------------
local function setupAnimations(humanoid)
	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator")
	animator.Parent = humanoid
	local function load(id)
		local a = Instance.new("Animation")
		a.AnimationId = id
		local ok, track = pcall(function() return animator:LoadAnimation(a) end)
		return ok and track or nil
	end
	local walk, idle = load(WALK_ANIMATION), load(IDLE_ANIMATION)
	if idle then
		idle.Looped = true
		idle:Play()
	end
	if walk then walk.Looped = true end
	humanoid.Running:Connect(function(speed)
		if not walk then return end
		if speed > 0.5 then
			if not walk.IsPlaying then walk:Play(0.15) end
			walk:AdjustSpeed(speed / 12)
		elseif walk.IsPlaying then
			walk:Stop(0.2)
		end
	end)
end

local function stepTo(humanoid, position)
	humanoid:MoveTo(position)
	local done = false
	local conn = humanoid.MoveToFinished:Connect(function() done = true end)
	local start = os.clock()
	while not done and os.clock() - start < STEP_TIMEOUT and humanoid.Parent do
		task.wait(0.1)
	end
	conn:Disconnect()
	return done
end

-- walks along a computed path; falls back to walking straight there if no path is found
local function walkTo(npc, goal)
	local humanoid = npc:FindFirstChildOfClass("Humanoid")
	local root = npc:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then return false end
	local path = PathfindingService:CreatePath({AgentRadius = 1.6, AgentHeight = 5.5, AgentCanJump = false, WaypointSpacing = 6})
	local ok = pcall(function() path:ComputeAsync(root.Position, goal) end)
	if ok and path.Status == Enum.PathStatus.Success then
		for i, waypoint in ipairs(path:GetWaypoints()) do
			if i > 1 then
				if not npc.Parent then return false end
				stepTo(humanoid, waypoint.Position)
			end
		end
		return true
	end
	return stepTo(humanoid, goal)
end

local function faceTowards(npc, target)
	local root = npc:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local flat = Vector3.new(target.X, root.Position.Y, target.Z)
	if (flat - root.Position).Magnitude > 0.1 then
		TweenService:Create(root, TweenInfo.new(0.3), {CFrame = CFrame.lookAt(root.Position, flat)}):Play()
	end
end

local function teleport(npc, position)
	local root = npc:FindFirstChild("HumanoidRootPart")
	if root then
		npc:PivotTo(CFrame.new(position + Vector3.new(0, 3, 0)) * root.CFrame.Rotation)
	end
end

local function fadeOut(npc)
	for _, d in ipairs(npc:GetDescendants()) do
		if d:IsA("BasePart") and d.Transparency < 1 then
			TweenService:Create(d, TweenInfo.new(0.8), {Transparency = 1}):Play()
		elseif d:IsA("Decal") then
			TweenService:Create(d, TweenInfo.new(0.8), {Transparency = 1}):Play()
		end
	end
	task.delay(0.9, function() npc:Destroy() end)
end

---------------------------------------------------------------------
-- ONE VISIT
---------------------------------------------------------------------
local function visit(museum, npc)
	local humanoid = npc:FindFirstChildOfClass("Humanoid")
	local outside, doorway, lobby = waypoint(museum, "Outside"), waypoint(museum, "Door"), waypoint(museum, "Lobby")
	if not (outside and doorway and lobby) or not humanoid then
		npc:Destroy()
		return
	end

	npc:PivotTo(CFrame.lookAt(outside + Vector3.new(0, 3, 0), doorway + Vector3.new(0, 3, 0)))
	npc.Parent = visitorsFolder
	local root = npc:FindFirstChild("HumanoidRootPart")
	if root then pcall(function() root:SetNetworkOwner(nil) end) end
	setupAnimations(humanoid)

	walkTo(npc, doorway)
	walkTo(npc, lobby)

	-- pick which memes to look at (all on one floor, rarest memes are a bit more popular)
	local choices = occupiedSlots(museum)
	local byFloor = {}
	for _, choice in ipairs(choices) do
		local stand, target, floor = viewingSpot(choice.Slot)
		if stand then
			choice.Stand, choice.Target = stand, target
			byFloor[floor] = byFloor[floor] or {}
			table.insert(byFloor[floor], choice)
		end
	end
	local floors = {}
	for floor in pairs(byFloor) do table.insert(floors, floor) end
	local floor = #floors > 0 and floors[rng:NextInteger(1, #floors)] or 1
	local plan = byFloor[floor] or {}
	for i = #plan, 2, -1 do -- shuffle
		local j = rng:NextInteger(1, i)
		plan[i], plan[j] = plan[j], plan[i]
	end

	-- upper floors: walk to the lift spot and ride up
	if floor > 1 then
		walkTo(npc, floorArrival(museum, 1))
		task.wait(0.4)
		teleport(npc, floorArrival(museum, floor))
	end

	local count = math.min(#plan, rng:NextInteger(SLOTS_PER_VISIT[1], SLOTS_PER_VISIT[2]))
	for i = 1, count do
		if not museum.Parent or not npc.Parent then break end
		local choice = plan[i]
		walkTo(npc, choice.Stand)
		faceTowards(npc, choice.Target)
		task.wait(0.4)
		-- the meme may have been swapped while they walked over: react to what's there now
		local artifact = ArtifactData.GetArtifact(choice.Slot:GetAttribute("ArtifactId") or "")
		if artifact then react(npc, artifact) end
		task.wait(rng:NextNumber(LOOK_TIME[1], LOOK_TIME[2]))
	end

	-- head home
	if floor > 1 and npc.Parent and museum.Parent then
		walkTo(npc, floorArrival(museum, floor))
		task.wait(0.3)
		teleport(npc, floorArrival(museum, 1))
	end
	if npc.Parent and museum.Parent then
		walkTo(npc, lobby)
		walkTo(npc, doorway)
		walkTo(npc, outside)
	end
	if npc.Parent then fadeOut(npc) end
end

---------------------------------------------------------------------
-- ONE SPAWNER PER MUSEUM
---------------------------------------------------------------------
local function runMuseum(museum)
	local active = 0
	task.wait(rng:NextNumber(3, 8))
	while museum.Parent do
		if active < MAX_VISITORS and #occupiedSlots(museum) > 0 then
			active += 1
			task.spawn(function()
				local ok, npc = pcall(buildVisitor, rng:NextNumber() < ALIEN_CHANCE and "Alien" or "Human", rng)
				if ok and npc then
					local visitOk, err = pcall(visit, museum, npc)
					if not visitOk then
						warn("Visitor error: " .. tostring(err))
						if npc.Parent then npc:Destroy() end
					end
				else
					warn("Couldn't build a visitor: " .. tostring(npc))
				end
				active -= 1
			end)
		end
		task.wait(rng:NextNumber(SPAWN_EVERY[1], SPAWN_EVERY[2]))
	end
end

local museumsFolder = workspace:WaitForChild("Museums")
museumsFolder.ChildAdded:Connect(function(museum)
	task.spawn(runMuseum, museum)
end)
for _, museum in ipairs(museumsFolder:GetChildren()) do
	task.spawn(runMuseum, museum)
end

print("VisitorManager ready: humans and aliens will visit every museum")
]=])
install(game:GetService("ServerScriptService"), "VisitorModels", "ModuleScript", [=[
-- VisitorModels (ModuleScript in ServerScriptService)
-- Builds the museum's NPC visitors: 2050 humans (bright outfits, glowing visors, hover
-- shoes, shoulder pads) and aliens (colored skin, big heads, huge black eyes, antennae).
-- Each one is a normal R15 character made from a HumanoidDescription, so it can walk with
-- Humanoid:MoveTo and play the standard walk animation. Returns a function(kind, rng) -> model.

local Players = game:GetService("Players")

local rgb = Color3.fromRGB

local HUMAN_SKIN = {rgb(255, 219, 180), rgb(234, 184, 146), rgb(198, 140, 104), rgb(141, 94, 66), rgb(94, 62, 44), rgb(255, 204, 170)}
local OUTFITS = { -- {top, bottom, accent glow}
	{rgb(92, 186, 255), rgb(40, 44, 90), rgb(120, 240, 255)},
	{rgb(255, 122, 190), rgb(60, 40, 96), rgb(255, 170, 230)},
	{rgb(255, 206, 84), rgb(56, 58, 76), rgb(255, 230, 140)},
	{rgb(96, 226, 190), rgb(34, 70, 80), rgb(150, 255, 220)},
	{rgb(178, 158, 255), rgb(46, 40, 90), rgb(210, 190, 255)},
	{rgb(246, 247, 252), rgb(90, 96, 140), rgb(120, 240, 255)},
}
local ALIEN_SKIN = {rgb(120, 220, 120), rgb(150, 120, 255), rgb(90, 200, 230), rgb(255, 150, 200), rgb(200, 230, 90)}

local function weldTo(part, anchorPart, offset)
	part.CFrame = anchorPart.CFrame * offset
	part.Anchored = false
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Massless = true
	local w = Instance.new("WeldConstraint")
	w.Part0 = anchorPart
	w.Part1 = part
	w.Parent = part
	part.Parent = anchorPart.Parent
	return part
end

local function piece(name, size, color, material, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if shape then p.Shape = shape end
	return p
end

local function ellipsoid(name, size, color, material)
	local p = piece(name, size, color, material)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = p
	return p
end

local function describe(skin, top, bottom, scale)
	local d = Instance.new("HumanoidDescription")
	d.HeadColor = skin
	d.LeftArmColor = top
	d.RightArmColor = top
	d.TorsoColor = top
	d.LeftLegColor = bottom
	d.RightLegColor = bottom
	d.HeightScale = scale.Height
	d.WidthScale = scale.Width
	d.HeadScale = scale.Head
	d.BodyTypeScale = 0
	d.ProportionScale = 0
	return d
end

local function hands(model, color)
	for _, name in ipairs({"LeftHand", "RightHand"}) do
		local hand = model:FindFirstChild(name)
		if hand then hand.Color = color end
	end
end

local function finish(model, name)
	model.Name = name
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.WalkSpeed = 10
	humanoid.BreakJointsOnDeath = false
	humanoid.RequiresNeck = false
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("BasePart") then
			d.CollisionGroup = "Visitors"
		end
	end
	return model
end

-- a 2050 human: outfit colors, a glowing visor, shoulder pads and hover-shoe glow
local function human(rng)
	local skin = HUMAN_SKIN[rng:NextInteger(1, #HUMAN_SKIN)]
	local outfit = OUTFITS[rng:NextInteger(1, #OUTFITS)]
	local model = Players:CreateHumanoidModelFromDescription(describe(skin, outfit[1], outfit[2],
		{Height = rng:NextNumber(0.9, 1.08), Width = rng:NextNumber(0.9, 1.05), Head = 1}), Enum.HumanoidRigType.R15)
	hands(model, skin)
	local head = model:FindFirstChild("Head")
	local upperTorso = model:FindFirstChild("UpperTorso")
	if head then
		weldTo(piece("Visor", Vector3.new(1.25, 0.28, 0.35), outfit[3], Enum.Material.Neon), head, CFrame.new(0, 0.12, -0.5))
		if rng:NextNumber() < 0.5 then -- futuristic hair dome
			weldTo(ellipsoid("Hair", Vector3.new(1.35, 0.7, 1.35), outfit[2]), head, CFrame.new(0, 0.5, 0.05))
		end
	end
	if upperTorso then
		for _, side in ipairs({-1, 1}) do
			weldTo(ellipsoid("ShoulderPad", Vector3.new(0.8, 0.45, 0.9), outfit[2]), upperTorso, CFrame.new(side * 1.05, 0.7, 0))
		end
		weldTo(piece("ChestStripe", Vector3.new(0.18, 1.2, 0.1), outfit[3], Enum.Material.Neon), upperTorso, CFrame.new(0.3, 0.1, -0.52))
	end
	for _, name in ipairs({"LeftFoot", "RightFoot"}) do
		local foot = model:FindFirstChild(name)
		if foot then
			foot.Color = outfit[2]
			weldTo(piece("HoverGlow", Vector3.new(0.8, 0.08, 0.9), outfit[3], Enum.Material.Neon), foot, CFrame.new(0, -0.2, 0))
		end
	end
	return finish(model, "Visitor2050")
end

-- an alien: colored skin, big head, big glossy eyes, antennae with glowing tips
local function alien(rng)
	local skin = ALIEN_SKIN[rng:NextInteger(1, #ALIEN_SKIN)]
	local suit = OUTFITS[rng:NextInteger(1, #OUTFITS)]
	local model = Players:CreateHumanoidModelFromDescription(describe(skin, suit[2], suit[2],
		{Height = rng:NextNumber(0.8, 1), Width = 0.85, Head = rng:NextNumber(1.35, 1.6)}), Enum.HumanoidRigType.R15)
	hands(model, skin)
	local head = model:FindFirstChild("Head")
	if head then
		local face = head:FindFirstChildOfClass("Decal")
		if face then face:Destroy() end -- aliens get their own eyes
		local s = head.Size.Y / 1.2
		for _, side in ipairs({-1, 1}) do
			weldTo(ellipsoid("AlienEye", Vector3.new(0.42, 0.62, 0.2) * s, rgb(20, 18, 30), Enum.Material.Glass), head,
				CFrame.new(side * 0.28 * s, 0.1 * s, -0.55 * s) * CFrame.Angles(0, 0, side * 0.35))
			weldTo(piece("EyeShine", Vector3.new(0.1, 0.1, 0.06) * s, rgb(255, 255, 255), Enum.Material.Neon, Enum.PartType.Ball), head,
				CFrame.new(side * 0.22 * s, 0.25 * s, -0.63 * s))
			local stalk = weldTo(piece("Antenna", Vector3.new(0.08, 0.9, 0.08) * s, skin), head,
				CFrame.new(side * 0.3 * s, 0.9 * s, 0) * CFrame.Angles(0, 0, -side * 0.35))
			weldTo(piece("AntennaTip", Vector3.new(0.26, 0.26, 0.26) * s, suit[3], Enum.Material.Neon, Enum.PartType.Ball), stalk,
				CFrame.new(0, 0.5 * s, 0))
		end
	end
	local upperTorso = model:FindFirstChild("UpperTorso")
	if upperTorso then
		weldTo(ellipsoid("SuitBadge", Vector3.new(0.45, 0.45, 0.12), suit[3], Enum.Material.Neon), upperTorso, CFrame.new(0, 0.2, -0.5))
	end
	return finish(model, "AlienVisitor")
end

return function(kind, rng)
	if kind == "Alien" then
		return alien(rng)
	end
	return human(rng)
end
]=])
install(game:GetService("ServerScriptService"), "WorldBuilder", "ModuleScript", [=[
-- WorldBuilder (ModuleScript in ServerScriptService)
-- Builds worlds 2-9: a floating terrain island around the pit (in the world's own ground
-- material), an invisible safety wall at the edge, the candy rim ring and zone rings, and a
-- themed set of decorations: a big landmark behind the pit, props around the island and
-- lamps near the rim. Everything stays clear of the Shovel Shop (30°) and World Gate (-30°).
-- DigManager calls it once per world when the server starts, after building the shop and gate.

local Architecture = require(script.Parent:WaitForChild("Architecture"))
local DigSiteStyle = require(script.Parent:WaitForChild("DigSiteStyle"))

local terrain = workspace.Terrain
local rgb = Color3.fromRGB
local PLASTIC = Enum.Material.SmoothPlastic

-- Angles (degrees, around the pit) where the island props stand. 30 and -30 (330) are
-- the shop and the gate, so they're left out; 180 is the landmark behind the pit.
local PROP_ANGLES = {75, 110, 145, 215, 250, 285}
local LAMP_ANGLES = {90, 135, 180, 225, 270}
local PROP_DISTANCE = 104
local LAMP_DISTANCE = 58
local LANDMARK_DISTANCE = 96

-- Registers the world's colors as palette finishes ("W2Main", "W2Glow", ...)
local function finishes(world)
	local look = world.Look
	local key = "W" .. world.Id
	local P = Architecture.Palette
	P[key .. "Main"] = {Color = look.Main, Material = PLASTIC}
	P[key .. "Second"] = {Color = look.Second, Material = PLASTIC}
	P[key .. "Dark"] = {Color = look.Dark, Material = PLASTIC}
	P[key .. "Accent"] = {Color = look.Accent, Material = PLASTIC}
	P[key .. "Glow"] = {Color = look.Glow, Material = Enum.Material.Neon}
	P[key .. "Crystal"] = {Color = look.Main, Material = Enum.Material.Glass, Transparency = 0.25, Reflectance = 0.1}
	P[key .. "Metal"] = {Color = look.Second, Material = Enum.Material.Metal, Reflectance = 0.2}
	return {
		Main = key .. "Main", Second = key .. "Second", Dark = key .. "Dark", Accent = key .. "Accent",
		Glow = key .. "Glow", Crystal = key .. "Crystal", Metal = key .. "Metal",
	}
end

local function custom(name, color, material, extra)
	local finish = {Color = color, Material = material or PLASTIC}
	if extra then
		for k, v in pairs(extra) do finish[k] = v end
	end
	Architecture.Palette[name] = finish
	return name
end

-- CFrame on the ground at an angle/distance around the pit, facing the pit
local function spot(angle, distance, height)
	local a = math.rad(angle)
	local pos = Vector3.new(math.cos(a) * distance, height or 0, math.sin(a) * distance)
	return CFrame.lookAt(pos, Vector3.new(0, pos.Y, 0))
end

local function particles(part, color, props)
	local e = Instance.new("ParticleEmitter")
	e.Color = ColorSequence.new(color)
	e.LightEmission = 0.3
	for k, v in pairs(props) do e[k] = v end
	e.Parent = part
	return e
end

---------------------------------------------------------------------
-- THE ISLAND (terrain)
---------------------------------------------------------------------
local function buildIsland(world, rng)
	local origin = world.Origin
	local R = world.IslandRadius
	local wall = Enum.Material[world.WallMaterial]
	local top = Enum.Material[world.TopMaterial]
	-- thick top slab, then an underside that narrows into the pit column (a floating island)
	terrain:FillCylinder(CFrame.new(origin + Vector3.new(0, -14, 0)), 28, R, wall)
	local layers = {{0.82, -34, 14}, {0.64, -52, 22}, {0.48, -76, 28}}
	for _, layer in ipairs(layers) do
		terrain:FillCylinder(CFrame.new(origin + Vector3.new(0, layer[2], 0)), layer[3], R * layer[1], wall)
	end
	-- lumpy rocks hanging under the edge
	for i = 1, 14 do
		local a = rng:NextNumber(0, math.pi * 2)
		local d = rng:NextNumber(R * 0.45, R * 0.85)
		terrain:FillBall(origin + Vector3.new(math.cos(a) * d, rng:NextNumber(-60, -30), math.sin(a) * d), rng:NextNumber(10, 18), wall)
	end
	-- rounded tip under the pit column
	terrain:FillBall(origin + Vector3.new(0, world.Zones[#world.Zones].Bottom - 20, 0), 40, wall)
	-- the surface
	terrain:FillCylinder(CFrame.new(origin + Vector3.new(0, -2, 0)), 4, R, top)
	-- a few soft hills near the edge (away from the shop and gate)
	for _, angle in ipairs({95, 160, 200, 265}) do
		local a = math.rad(angle + rng:NextNumber(-8, 8))
		local d = R - 12
		terrain:FillBall(origin + Vector3.new(math.cos(a) * d, -4, math.sin(a) * d), rng:NextNumber(9, 13), top)
	end
end

-- invisible wall around the edge so nobody walks off the island
local function buildEdgeWall(parent, world)
	local R = world.IslandRadius - 3
	local segments = 48
	local folder = Instance.new("Folder")
	folder.Name = "EdgeWall"
	for i = 0, segments - 1 do
		local a = (i + 0.5) / segments * math.pi * 2
		local pos = world.Origin + Vector3.new(math.cos(a) * R, 20, math.sin(a) * R)
		local p = Instance.new("Part")
		p.Name = "EdgeWall"
		p.Anchored = true
		p.Transparency = 1
		p.CanQuery = false
		p.Size = Vector3.new(2 * math.pi * R / segments + 1, 44, 2)
		p.CFrame = CFrame.lookAt(pos, Vector3.new(world.Origin.X, pos.Y, world.Origin.Z))
		p.Parent = folder
	end
	folder.Parent = parent
end

---------------------------------------------------------------------
-- THEMES: each has Landmark (behind the pit), Props (around the island), Lamp (near the rim)
-- and optional Sky (things floating overhead). b builds relative to the world origin.
---------------------------------------------------------------------
local THEMES = {}

-- NEON SAKURA GROVE --------------------------------------------------
THEMES.Sakura = {
	Landmark = function(b, F, cf)
		local red = custom("SakuraTorii", rgb(236, 84, 96))
		for _, side in ipairs({-1, 1}) do
			b:disc("ToriiFoot", 4.4, 1.2, cf * CFrame.new(side * 11, 0.6, 0), F.Dark)
			b:disc("ToriiPillar", 3, 24, cf * CFrame.new(side * 11, 12.6, 0), red)
		end
		b:roundedBlock("ToriiBeam", Vector3.new(32, 2.2, 3), cf * CFrame.new(0, 25.5, 0), 1, F.Dark)
		b:roundedBlock("ToriiBeamTop", Vector3.new(36, 1.6, 4), cf * CFrame.new(0, 27.4, 0), 1.2, red)
		b:box("ToriiTie", Vector3.new(26, 1.4, 2), cf * CFrame.new(0, 20, 0), red)
		local plaque = b:roundedBlock("ToriiPlaque", Vector3.new(6, 4, 1), cf * CFrame.new(0, 22.8, -0.8), 0.5, F.Dark)
		Architecture.sign(plaque, "SAKURA", nil, Enum.NormalId.Front, rgb(255, 214, 120))
		for i = 0, 5 do
			b:bulb("ToriiLantern", 1.2, cf * CFrame.new(-12.5 + i * 5, 18, -1.2), F.Glow, 8)
		end
	end,
	Props = function(b, F, cf, i, rng)
		-- a round blossom tree; every third spot gets a stone lantern pair instead
		if i % 3 == 0 then
			for _, side in ipairs({-1, 1}) do
				local p = cf * CFrame.new(side * 5, 0, 0)
				b:disc("StoneBase", 3.4, 1, p * CFrame.new(0, 0.5, 0), F.Second)
				b:disc("StonePost", 1.4, 4, p * CFrame.new(0, 3, 0), F.Second)
				b:roundedBlock("LanternBox", Vector3.new(2.6, 2.2, 2.6), p * CFrame.new(0, 6.1, 0), 0.6, F.Accent)
				b:bulb("LanternLight", 1.4, p * CFrame.new(0, 6.1, 0), F.Glow, 12)
				b:disc("LanternRoof", 4, 0.8, p * CFrame.new(0, 7.6, 0), F.Dark)
			end
			return
		end
		local s = rng:NextNumber(1.4, 1.8)
		b:pill("Trunk", (cf * CFrame.new(0, 0, 0)).Position, (cf * CFrame.new(0.8, 10 * s, 0)).Position, 2.2 * s, F.Dark)
		b:pill("Branch", (cf * CFrame.new(0.6, 7 * s, 0)).Position, (cf * CFrame.new(-4 * s, 11 * s, 1)).Position, 1.1 * s, F.Dark)
		b:pill("Branch", (cf * CFrame.new(0.6, 8 * s, 0)).Position, (cf * CFrame.new(4.5 * s, 12 * s, -1)).Position, 1.1 * s, F.Dark)
		local crowns = {Vector3.new(0, 14, 0), Vector3.new(-4.5, 12.5, 1), Vector3.new(4.8, 13, -1), Vector3.new(0.5, 12, 4), Vector3.new(0, 12.5, -4)}
		for c, offset in ipairs(crowns) do
			local crown = b:ball("Blossom", (c == 1 and 9 or 7) * s, cf * CFrame.new(offset * s), c % 2 == 0 and F.Second or F.Main)
			if c == 1 then
				particles(crown, rgb(255, 190, 215), {
					Rate = 3, Lifetime = NumberRange.new(4, 6), Speed = NumberRange.new(1, 2),
					Acceleration = Vector3.new(0.5, -1.2, 0), SpreadAngle = Vector2.new(180, 180),
					Size = NumberSequence.new(0.35), Rotation = NumberRange.new(0, 360), RotSpeed = NumberRange.new(-90, 90),
				})
			end
		end
	end,
	Lamp = function(b, F, cf)
		b:disc("LampBase", 2.2, 0.6, cf * CFrame.new(0, 0.3, 0), F.Dark)
		b:disc("LampPole", 0.6, 6, cf * CFrame.new(0, 3.6, 0), F.Dark)
		b:ellipsoid("PaperLantern", Vector3.new(2, 2.6, 2), cf * CFrame.new(0, 7.6, 0), custom("SakuraPaper", rgb(255, 120, 130)))
		b:bulb("LanternGlow", 0.9, cf * CFrame.new(0, 7.6, 0), F.Glow, 10)
	end,
}

-- GALAXY DRIFT ------------------------------------------------------
THEMES.Galaxy = {
	Landmark = function(b, F, cf)
		-- a giant ringed planet floating over the island, on a beam of light
		local planet = cf * CFrame.new(0, 48, 0)
		b:ball("GiantPlanet", 30, planet, F.Main)
		b:ellipsoid("PlanetBand", Vector3.new(30.4, 6, 30.4), planet * CFrame.new(0, 4, 0), F.Accent)
		b:ring("PlanetRing", planet * CFrame.Angles(math.rad(75), 0, math.rad(15)), 24, 2.4, F.Second, 40)
		b:ring("PlanetRingGlow", planet * CFrame.Angles(math.rad(75), 0, math.rad(15)), 27, 0.8, F.Glow, 40)
		b:tiers("Observatory", cf, {{18, 1, F.Dark}, {15, 1.2, F.Second}, {10, 0.6, F.Glow}})
		local beam = b:disc("TractorBeam", 6, 30, cf * CFrame.new(0, 18, 0), F.Crystal, {CanCollide = false})
		beam.Transparency = 0.75
		for i = 1, 3 do
			local a = math.rad(i * 120)
			b:ball("Moon", 4, planet * CFrame.new(math.cos(a) * 22, math.sin(a) * 6, math.sin(a) * 22), "Cloud")
		end
	end,
	Props = function(b, F, cf, i, rng)
		if i % 2 == 0 then
			-- crystal cluster
			for c = 1, 6 do
				local h = rng:NextNumber(5, 12)
				local tilt = CFrame.Angles(rng:NextNumber(-0.4, 0.4), rng:NextNumber(0, 6), rng:NextNumber(-0.4, 0.4))
				b:box("SpaceCrystal", Vector3.new(1.8, h, 1.8), cf * CFrame.new(rng:NextNumber(-3, 3), h / 2 - 1, rng:NextNumber(-3, 3)) * tilt, c % 3 == 0 and F.Crystal or F.Main)
			end
			b:bulb("CrystalGlow", 1.2, cf * CFrame.new(0, 2, 0), F.Glow, 14)
		else
			-- little planet on a pedestal
			b:tiers("Pedestal", cf, {{6, 1, F.Dark}, {3, 5, F.Second}, {4.4, 0.6, F.Glow}})
			local p = cf * CFrame.new(0, 11, 0)
			b:ball("MiniPlanet", 6, p, i % 3 == 0 and F.Accent or "Coral")
			b:ring("MiniRing", p * CFrame.Angles(math.rad(70), 0, 0), 4.6, 0.5, F.Second, 20)
		end
	end,
	Lamp = function(b, F, cf)
		b:disc("LampBase", 2.2, 0.6, cf * CFrame.new(0, 0.3, 0), F.Dark)
		b:disc("LampPole", 0.5, 7, cf * CFrame.new(0, 4, 0), F.Second)
		b:bulb("StarLamp", 1.6, cf * CFrame.new(0, 8.2, 0), F.Glow, 14)
		b:ring("StarLampRing", cf * CFrame.new(0, 8.2, 0), 1.6, 0.25, F.Accent, 12)
	end,
	Sky = function(b, F, rng)
		for i = 1, 10 do
			local a = rng:NextNumber(0, math.pi * 2)
			local d = rng:NextNumber(150, 260)
			local rock = b:ellipsoid("Asteroid", Vector3.new(rng:NextNumber(8, 16), rng:NextNumber(5, 9), rng:NextNumber(8, 14)),
				CFrame.new(math.cos(a) * d, rng:NextNumber(30, 110), math.sin(a) * d) * CFrame.Angles(rng:NextNumber(0, 3), rng:NextNumber(0, 3), 0), F.Dark)
			rock.CanCollide = false
		end
	end,
}

-- FROSTBYTE TUNDRA --------------------------------------------------
THEMES.Frost = {
	Landmark = function(b, F, cf)
		-- a cluster of huge ice spires with a glowing core
		local spires = {{0, 44, 7}, {-8, 30, 5}, {8, 34, 5.5}, {-4, 22, 4}, {5, 20, 4}, {-12, 16, 3.5}, {12, 18, 3.5}}
		for i, s in ipairs(spires) do
			local lean = CFrame.Angles(0, math.rad(i * 40), math.rad(s[1] * 0.8))
			b:box("IceSpire", Vector3.new(s[3], s[2], s[3]), cf * CFrame.new(s[1], s[2] / 2 - 2, (i % 2) * 3) * lean * CFrame.Angles(0, math.rad(45), 0), i % 2 == 0 and F.Crystal or F.Main)
		end
		b:bulb("SpireCore", 4, cf * CFrame.new(0, 10, -2), F.Glow, 24)
		b:tiers("SnowMound", cf, {{30, 2, "White"}, {22, 1.5, "White"}})
	end,
	Props = function(b, F, cf, i, rng)
		if i % 3 == 0 then
			-- a friendly snowman
			b:ball("SnowBottom", 6, cf * CFrame.new(0, 2.6, 0), "White")
			b:ball("SnowMiddle", 4.4, cf * CFrame.new(0, 6.8, 0), "White")
			b:ball("SnowHead", 3.2, cf * CFrame.new(0, 9.9, 0), "White")
			b:disc("HatBrim", 3.4, 0.3, cf * CFrame.new(0, 11.4, 0), F.Dark)
			b:disc("Hat", 2.2, 2, cf * CFrame.new(0, 12.5, 0), F.Dark)
			b:rod("Nose", 1.4, 0.4, cf * CFrame.new(0, 9.9, -1.9) * CFrame.Angles(0, math.rad(90), 0), custom("Carrot", rgb(255, 150, 60)))
			for _, side in ipairs({-1, 1}) do
				b:ball("Eye", 0.4, cf * CFrame.new(side * 0.6, 10.4, -1.45), "Ink")
			end
			b:disc("Scarf", 3.8, 0.8, cf * CFrame.new(0, 8.5, 0), F.Accent)
			return
		end
		-- a round snowy pine
		local s = rng:NextNumber(1.3, 1.7)
		b:disc("PineTrunk", 1.6 * s, 4 * s, cf * CFrame.new(0, 2 * s, 0), custom("PineWood", rgb(120, 86, 80)))
		for t = 0, 3 do
			local y = (4 + t * 3.2) * s
			local d = (9 - t * 2) * s
			b:ellipsoid("PineLayer", Vector3.new(d, 3.4 * s, d), cf * CFrame.new(0, y, 0), custom("PineGreen", rgb(70, 150, 130)))
			b:ellipsoid("PineSnow", Vector3.new(d * 0.8, 1.6 * s, d * 0.8), cf * CFrame.new(0, y + 1.2 * s, 0), "White")
		end
	end,
	Lamp = function(b, F, cf)
		b:disc("LampBase", 2.2, 0.6, cf * CFrame.new(0, 0.3, 0), F.Dark)
		b:disc("LampPole", 0.6, 6, cf * CFrame.new(0, 3.6, 0), F.Second)
		b:box("IceLamp", Vector3.new(1.6, 2.6, 1.6), cf * CFrame.new(0, 7.8, 0) * CFrame.Angles(0, math.rad(45), 0), F.Crystal)
		b:bulb("IceGlow", 0.8, cf * CFrame.new(0, 7.8, 0), F.Glow, 10)
	end,
	Sky = function(b, F)
		-- aurora: thin glowing ribbons high above the far side of the island
		local colors = {F.Glow, custom("AuroraViolet", rgb(170, 130, 255), Enum.Material.Neon)}
		for i = 0, 11 do
			local ribbon = b:box("Aurora", Vector3.new(34, 2, 0.4),
				CFrame.new(-190 + i * 32, 120 + math.sin(i * 0.9) * 10, 170 + math.cos(i * 0.7) * 20) * CFrame.Angles(0, math.sin(i) * 0.4, math.rad(8)), colors[i % 2 + 1])
			ribbon.Transparency = 0.45
			ribbon.CanCollide = false
		end
	end,
}

-- CHROME DUNES ------------------------------------------------------
THEMES.Dunes = {
	Landmark = function(b, F, cf)
		-- stepped chrome pyramid with a golden cap and a glowing eye
		for t = 0, 6 do
			local w = 34 - t * 4.6
			b:box("PyramidStep", Vector3.new(w, 4, w), cf * CFrame.new(0, 2 + t * 4, 0), t % 2 == 0 and F.Metal or F.Main)
		end
		b:box("PyramidCap", Vector3.new(4, 4, 4), cf * CFrame.new(0, 30, 0) * CFrame.Angles(0, math.rad(45), 0), F.Accent)
		b:bulb("PyramidEye", 3, cf * CFrame.new(0, 18, -8.4), F.Glow, 18)
		b:ring("EyeRing", cf * CFrame.new(0, 18, -8.7), 2.6, 0.5, F.Accent, 16)
	end,
	Props = function(b, F, cf, i, rng)
		if i % 2 == 0 then
			-- solar tower
			b:disc("SolarBase", 5, 1, cf * CFrame.new(0, 0.5, 0), F.Dark)
			b:disc("SolarPole", 1, 10, cf * CFrame.new(0, 6, 0), F.Metal)
			b:box("SolarPanel", Vector3.new(9, 0.4, 6), cf * CFrame.new(0, 11.5, 0) * CFrame.Angles(math.rad(-30), 0, 0), custom("SolarGlass", rgb(60, 80, 160), Enum.Material.Glass, {Reflectance = 0.3}))
			b:box("SolarFrame", Vector3.new(9.4, 0.3, 0.4), cf * CFrame.new(0, 11.9, 2.6) * CFrame.Angles(math.rad(-30), 0, 0), F.Metal)
			return
		end
		-- cartoon cactus
		local green = custom("Cactus", rgb(96, 196, 120))
		local h = rng:NextNumber(11, 16)
		b:pill("CactusBody", (cf * CFrame.new(0, 0, 0)).Position, (cf * CFrame.new(0, h, 0)).Position, 3, green)
		b:pill("CactusArm", (cf * CFrame.new(0, h * 0.5, 0)).Position, (cf * CFrame.new(3, h * 0.5, 0)).Position, 1.8, green)
		b:pill("CactusArm", (cf * CFrame.new(3, h * 0.5, 0)).Position, (cf * CFrame.new(3, h * 0.8, 0)).Position, 1.8, green)
		b:pill("CactusArm", (cf * CFrame.new(0, h * 0.35, 0)).Position, (cf * CFrame.new(-2.6, h * 0.35, 0)).Position, 1.6, green)
		b:pill("CactusArm", (cf * CFrame.new(-2.6, h * 0.35, 0)).Position, (cf * CFrame.new(-2.6, h * 0.6, 0)).Position, 1.6, green)
		b:ball("CactusFlower", 1.2, cf * CFrame.new(0, h + 1.4, 0), "Coral")
	end,
	Lamp = function(b, F, cf)
		b:disc("LampBase", 2.2, 0.6, cf * CFrame.new(0, 0.3, 0), F.Dark)
		b:disc("LampPole", 0.6, 6, cf * CFrame.new(0, 3.6, 0), F.Metal)
		b:bulb("SunLamp", 1.6, cf * CFrame.new(0, 7.6, 0), F.Glow, 12)
		b:ring("SunLampRing", cf * CFrame.new(0, 7.6, 0), 1.5, 0.3, F.Accent, 12)
	end,
}

-- CORAL CIRCUIT -----------------------------------------------------
THEMES.Coral = {
	Landmark = function(b, F, cf)
		-- a giant open clam with a glowing pearl, and a coral arch over it
		b:ellipsoid("ClamBottom", Vector3.new(26, 7, 20), cf * CFrame.new(0, 3, 0), F.Main)
		b:ellipsoid("ClamTop", Vector3.new(26, 7, 20), cf * CFrame.new(0, 12, 6) * CFrame.Angles(math.rad(-60), 0, 0), F.Main)
		b:ball("GiantPearl", 8, cf * CFrame.new(0, 8, -1), custom("Pearl", rgb(250, 244, 255), PLASTIC, {Reflectance = 0.3}))
		b:bulb("PearlGlow", 1, cf * CFrame.new(0, 8, -5.2), F.Glow, 20)
		b:ring("CoralArch", cf * CFrame.new(0, 2, 4), 18, 2.6, F.Second, 28, 180, 0)
	end,
	Props = function(b, F, cf, i, rng)
		if i % 2 == 0 then
			-- branching coral
			local colors = {F.Main, F.Second, F.Accent}
			local base = cf.Position
			for c = 1, 5 do
				local a = c * 1.3
				local tip = base + (cf.RightVector * math.cos(a) * 3 + cf.LookVector * math.sin(a) * 3) + Vector3.new(0, rng:NextNumber(6, 11), 0)
				b:pill("Coral", base + Vector3.new(0, 1, 0), tip, 1.4, colors[c % 3 + 1])
				b:ball("CoralTip", 2.2, CFrame.new(tip), colors[c % 3 + 1])
			end
			return
		end
		-- kelp + bubbles
		local green = custom("Kelp", rgb(70, 190, 140))
		for k = -1, 1 do
			local prev = (cf * CFrame.new(k * 2.5, 0, 0)).Position
			for s = 1, 4 do
				local nextPos = (cf * CFrame.new(k * 2.5 + math.sin(s + k) * 1.2, s * 3.2, 0)).Position
				b:pill("Kelp", prev, nextPos, 1, green)
				prev = nextPos
			end
		end
		for s = 1, 5 do
			local bubble = b:ball("Bubble", rng:NextNumber(1, 2.4), cf * CFrame.new(rng:NextNumber(-3, 3), 6 + s * 3, rng:NextNumber(-2, 2)), "Glass")
			bubble.CanCollide = false
		end
	end,
	Lamp = function(b, F, cf)
		-- jellyfish lamp
		b:disc("LampBase", 2.2, 0.6, cf * CFrame.new(0, 0.3, 0), F.Dark)
		b:disc("LampPole", 0.5, 5, cf * CFrame.new(0, 3, 0), F.Second)
		b:ellipsoid("JellyDome", Vector3.new(3.6, 2.4, 3.6), cf * CFrame.new(0, 7.6, 0), F.Crystal)
		b:bulb("JellyGlow", 1, cf * CFrame.new(0, 7.4, 0), F.Glow, 12)
		for t = 0, 3 do
			local a = math.rad(t * 90 + 45)
			b:box("Tentacle", Vector3.new(0.25, 2.6, 0.25), cf * CFrame.new(math.cos(a), 5.4, math.sin(a)), F.Main, {CanCollide = false})
		end
	end,
	Sky = function(b, F, rng)
		for i = 1, 16 do
			local a = rng:NextNumber(0, math.pi * 2)
			local d = rng:NextNumber(20, 110)
			local bubble = b:ball("FloatingBubble", rng:NextNumber(2, 5), CFrame.new(math.cos(a) * d, rng:NextNumber(24, 60), math.sin(a) * d), "Glass")
			bubble.CanCollide = false
		end
	end,
}

-- CANDY MAINFRAME ---------------------------------------------------
THEMES.Candy = {
	Landmark = function(b, F, cf)
		-- a giant cupcake with a cherry, and two huge lollipops
		b:tiers("CupcakeCup", cf, {{24, 8, F.Second}, {25, 1, F.Accent}})
		b:ellipsoid("Frosting", Vector3.new(26, 10, 26), cf * CFrame.new(0, 12, 0), F.Main)
		b:ellipsoid("FrostingTop", Vector3.new(16, 8, 16), cf * CFrame.new(0, 17, 0), custom("Frosting", rgb(255, 238, 246)))
		b:ball("Cherry", 5, cf * CFrame.new(0, 22.5, 0), custom("Cherry", rgb(236, 60, 90)))
		for _, side in ipairs({-1, 1}) do
			local base = cf * CFrame.new(side * 18, 0, 2)
			b:disc("LollipopStick", 1, 24, base * CFrame.new(0, 12, 0), "White")
			local head = base * CFrame.new(0, 26, 0)
			b:rod("LollipopHead", 1.6, 12, head * CFrame.Angles(0, math.rad(90), 0), side < 0 and F.Main or F.Second)
			b:ring("LollipopSwirl", head * CFrame.new(0, 0, -0.9), 3.6, 1, "White", 20)
		end
	end,
	Props = function(b, F, cf, i, rng)
		if i % 3 == 0 then
			-- gumdrops
			for g = 1, 3 do
				local colors = {F.Main, F.Second, F.Accent}
				b:ellipsoid("Gumdrop", Vector3.new(5, 5, 5), cf * CFrame.new((g - 2) * 5, 1.2, (g % 2) * 3), colors[g])
			end
			return
		elseif i % 3 == 1 then
			-- candy cane: striped pole + hook
			local red = custom("CaneRed", rgb(236, 70, 90))
			for s = 0, 7 do
				b:disc("CaneStripe", 1.6, 1.5, cf * CFrame.new(0, 0.75 + s * 1.5, 0), s % 2 == 0 and red or "White")
			end
			b:ring("CaneHook", cf * CFrame.new(1.8, 12, 0), 1.8, 1.6, red, 12, 180, 0)
			return
		end
		-- giant donut
		b:ring("Donut", cf * CFrame.new(0, 5, 0), 3.4, 3.2, custom("Dough", rgb(236, 180, 110)), 20)
		b:ring("DonutIcing", cf * CFrame.new(0, 5, -0.8), 3.4, 2.4, F.Main, 20)
	end,
	Lamp = function(b, F, cf)
		b:disc("LampStick", 0.6, 7, cf * CFrame.new(0, 3.5, 0), "White")
		b:rod("LampCandy", 0.8, 3.4, cf * CFrame.new(0, 8.4, 0) * CFrame.Angles(0, math.rad(90), 0), F.Main)
		b:bulb("LampGlow", 0.8, cf * CFrame.new(0, 8.4, -0.5), F.Glow, 10)
	end,
	Sky = function(b, F, rng)
		for i = 1, 8 do
			local a = rng:NextNumber(0, math.pi * 2)
			local d = rng:NextNumber(60, 180)
			local center = CFrame.new(math.cos(a) * d, rng:NextNumber(50, 90), math.sin(a) * d)
			for c = 1, 3 do
				local puff = b:ball("CottonCandyCloud", rng:NextNumber(8, 12), center * CFrame.new((c - 2) * 6, rng:NextNumber(-1, 2), 0), c % 2 == 0 and F.Main or "Frosting")
				puff.CanCollide = false
			end
		end
	end,
}

-- VOLCANO FORGE -----------------------------------------------------
THEMES.Forge = {
	Landmark = function(b, F, cf, world)
		-- a terrain volcano with a lava crater, glowing lava streams and smoke
		local origin = world.Origin
		local base = origin + cf.Position
		local layers = {{24, 6}, {19, 12}, {14, 18}, {10, 24}}
		for _, layer in ipairs(layers) do
			terrain:FillCylinder(CFrame.new(base + Vector3.new(0, layer[2] / 2, 0)), layer[2], layer[1], Enum.Material.Basalt)
		end
		terrain:FillCylinder(CFrame.new(base + Vector3.new(0, 22, 0)), 4, 7, Enum.Material.CrackedLava)
		local lava = b:disc("LavaPool", 12, 0.6, cf * CFrame.new(0, 24.3, 0), F.Glow)
		lava.Material = Enum.Material.Neon
		b:bulb("LavaLight", 1, cf * CFrame.new(0, 26, 0), F.Glow, 30)
		particles(lava, rgb(70, 60, 70), {
			Rate = 6, Lifetime = NumberRange.new(5, 8), Speed = NumberRange.new(4, 7),
			SpreadAngle = Vector2.new(15, 15), Size = NumberSequence.new(4, 12), LightEmission = 0,
			Transparency = NumberSequence.new(0.4, 1), EmissionDirection = Enum.NormalId.Top,
		})
		for s = 0, 2 do
			local a = math.rad(-60 + s * 60)
			local from = Vector3.new(math.cos(a) * 6, 23, math.sin(a) * 6)
			local to = Vector3.new(math.cos(a) * 22, 2, math.sin(a) * 22)
			b:pill("LavaStream", (cf * CFrame.new(from)).Position, (cf * CFrame.new(to)).Position, 1.6, F.Glow)
		end
	end,
	Props = function(b, F, cf, i, rng)
		if i % 2 == 0 then
			-- obsidian spikes
			for s = 1, 5 do
				local h = rng:NextNumber(5, 11)
				b:box("ObsidianSpike", Vector3.new(2, h, 2), cf * CFrame.new(rng:NextNumber(-4, 4), h / 2 - 1, rng:NextNumber(-3, 3)) * CFrame.Angles(rng:NextNumber(-0.3, 0.3), rng:NextNumber(0, 3), rng:NextNumber(-0.3, 0.3)),
					custom("Obsidian", rgb(40, 30, 56), Enum.Material.Glass, {Reflectance = 0.2}))
			end
			return
		end
		-- the meme forge: an anvil next to a glowing furnace
		b:roundedBlock("AnvilBase", Vector3.new(3, 3, 3), cf * CFrame.new(-4, 1.5, 0), 0.6, F.Second)
		b:box("AnvilTop", Vector3.new(6, 1.6, 2.6), cf * CFrame.new(-4, 3.8, 0), F.Second)
		b:tiers("Furnace", cf * CFrame.new(4, 0, 0), {{6, 5, F.Dark}, {4.6, 3, F.Second}, {2.4, 3, F.Dark}})
		b:bulb("FurnaceFire", 2.4, cf * CFrame.new(4, 2.6, -2.2), F.Glow, 14)
	end,
	Lamp = function(b, F, cf)
		-- fire brazier
		b:disc("BrazierPole", 0.8, 4.5, cf * CFrame.new(0, 2.25, 0), F.Second)
		b:disc("BrazierBowl", 3, 1.2, cf * CFrame.new(0, 5, 0), F.Dark)
		local fire = b:bulb("BrazierFire", 1.4, cf * CFrame.new(0, 6, 0), F.Glow, 14)
		particles(fire, rgb(255, 150, 60), {
			Rate = 12, Lifetime = NumberRange.new(0.5, 1), Speed = NumberRange.new(2, 4), LightEmission = 1,
			SpreadAngle = Vector2.new(10, 10), Size = NumberSequence.new(1, 0), EmissionDirection = Enum.NormalId.Top,
		})
	end,
}

-- GLITCH NEXUS ------------------------------------------------------
THEMES.Glitch = {
	Landmark = function(b, F, cf, world, rng)
		-- a giant broken monolith with a missing-texture face, and fragments floating off it
		b:box("Monolith", Vector3.new(14, 36, 5), cf * CFrame.new(0, 18, 0), F.Dark)
		for x = 0, 3 do
			for y = 0, 7 do
				b:box("MissingTexture", Vector3.new(3.2, 3.2, 0.3), cf * CFrame.new(-4.8 + x * 3.2, 8 + y * 3.2, -2.6), (x + y) % 2 == 0 and F.Second or "Ink")
			end
		end
		for i = 1, 14 do
			local s = rng:NextNumber(1.5, 4)
			local cube = b:box("Fragment", Vector3.new(s, s, s), cf * CFrame.new(rng:NextNumber(-14, 14), rng:NextNumber(20, 48), rng:NextNumber(-6, 6)) * CFrame.Angles(rng:NextNumber(0, 3), rng:NextNumber(0, 3), 0), i % 3 == 0 and F.Glow or F.Dark)
			cube.CanCollide = false
		end
	end,
	Props = function(b, F, cf, i, rng)
		if i % 2 == 0 then
			-- wireframe cube (the texture never loaded)
			local s = 8
			local h = s / 2
			local corners = {}
			for x = -1, 1, 2 do for y = -1, 1, 2 do for z = -1, 1, 2 do
				table.insert(corners, Vector3.new(x * h, y * h + h + 2, z * h))
			end end end
			for a = 1, #corners do
				for c = a + 1, #corners do
					local d = corners[c] - corners[a]
					if d.Magnitude == s then
						b:rod("Wire", s + 0.4, 0.4, cf * CFrame.new((corners[a] + corners[c]) / 2) * Architecture.alongX(Vector3.zero, d), F.Glow)
					end
				end
			end
			return
		end
		-- stack of pixel cubes that don't line up
		for c = 0, 4 do
			b:box("PixelStack", Vector3.new(4, 4, 4), cf * CFrame.new(rng:NextNumber(-1.2, 1.2), 2 + c * 4, rng:NextNumber(-1.2, 1.2)), c % 2 == 0 and F.Main or F.Second)
		end
	end,
	Lamp = function(b, F, cf)
		b:disc("LampBase", 2.2, 0.6, cf * CFrame.new(0, 0.3, 0), F.Dark)
		b:box("LampPole", Vector3.new(0.6, 6, 0.6), cf * CFrame.new(0, 3.6, 0), F.Dark)
		b:box("PixelLamp", Vector3.new(1.8, 1.8, 1.8), cf * CFrame.new(0, 7.6, 0) * CFrame.Angles(math.rad(45), math.rad(45), 0), F.Glow)
	end,
	Sky = function(b, F, rng)
		for i = 1, 20 do
			local a = rng:NextNumber(0, math.pi * 2)
			local d = rng:NextNumber(70, 220)
			local s = rng:NextNumber(3, 9)
			local cube = b:box("SkyGlitch", Vector3.new(s, s, s), CFrame.new(math.cos(a) * d, rng:NextNumber(30, 120), math.sin(a) * d), i % 2 == 0 and F.Main or F.Second)
			cube.CanCollide = false
		end
	end,
}

---------------------------------------------------------------------
-- BUILD
---------------------------------------------------------------------
return function(container, world)
	local rng = Random.new(world.Id * 7919)
	buildIsland(world, rng)

	-- rim ring + zone rings, recolored to the world's colors
	DigSiteStyle(container, world)
	buildEdgeWall(container, world)
	local F = finishes(world)
	local rim = container:FindFirstChild("Cartoon2050")
	if rim then
		local i = 0
		for _, part in ipairs(rim:GetChildren()) do
			if part:IsA("BasePart") and part.Name == "RimStripe" then
				i += 1
				local f = Architecture.Palette[(i // 2) % 2 == 0 and F.Main or F.Second]
				part.Color = f.Color
			elseif part:IsA("BasePart") and part.Name == "RimBulb" then
				part.Color = world.Look.Glow
			end
		end
	end

	local theme = THEMES[world.Theme]
	if not theme then return end
	local decor = Instance.new("Model")
	decor.Name = "Decor"
	local b = Architecture.builder(decor, CFrame.new(world.Origin))
	theme.Landmark(b, F, spot(180, LANDMARK_DISTANCE), world, rng)
	for i, angle in ipairs(PROP_ANGLES) do
		theme.Props(b, F, spot(angle, PROP_DISTANCE + rng:NextNumber(-4, 6)), i, rng)
	end
	for _, angle in ipairs(LAMP_ANGLES) do
		theme.Lamp(b, F, spot(angle, LAMP_DISTANCE))
	end
	if theme.Sky then
		theme.Sky(b, F, rng)
	end
	decor.Parent = container
end
]=])
install(game:GetService("ServerScriptService"), "WorldGate", "ModuleScript", [=[
-- WorldGate (ModuleScript in ServerScriptService)
-- Builds the portal players use to travel between worlds: a big chunky portal ring
-- with a swirling energy film, standing on a round tiered base between two capsule
-- towers, with orbiting planets, a rounded sign and a friendly terminal kiosk.
-- Returns the gate model and its ProximityPrompt.

local Architecture = require(script.Parent:WaitForChild("Architecture"))

-- parent: where it goes. base: its CFrame (front, local -Z, faces the players).
return function(parent, base, subtitle)
	local gate = Instance.new("Model")
	gate.Name = "WorldGate"
	local b = Architecture.builder(gate, base)

	-- round tiered base with a glowing lip
	local _, floorY = b:tiers("GateBase", CFrame.new(0, 0, 0), {
		{24, 0.5, "Sky"},
		{23.2, 0.3, "GlowCyan"},
		{22, 0.7, "White"},
		{15, 0.4, "Cloud"},
	})
	b:roundedBlock("GateStep", Vector3.new(10, 0.5, 3), CFrame.new(0, 0.25, -12.4), 1.4, "Cloud")

	-- the portal: a thick white ring, a lilac inner ring, a glowing edge and the energy film
	local center = CFrame.new(0, floorY + 9.5, 0)
	b:ring("PortalRing", center, 8.2, 2.2, "White", 32)
	b:ring("PortalInner", center * CFrame.new(0, 0, -0.9), 7, 0.7, "Lilac", 32)
	b:ring("PortalGlow", center * CFrame.new(0, 0, -1.2), 7.2, 0.3, "GlowPink", 32)
	local film = b:rod("PortalFilm", 0.3, 13.6, center * CFrame.Angles(0, math.rad(90), 0), "Portal", {CanCollide = false})
	film.Transparency = 0.25
	local swirl = b:rod("PortalSwirl", 0.2, 9, center * CFrame.new(0, 0, -0.2) * CFrame.Angles(0, math.rad(90), 0), "GlowCyan", {CanCollide = false})
	swirl.Transparency = 0.55
	local glow = Instance.new("PointLight")
	glow.Color = Color3.fromRGB(200, 170, 255)
	glow.Range = 18
	glow.Brightness = 1.2
	glow.Parent = film
	-- chunky feet holding the ring
	for _, side in ipairs({-1, 1}) do
		b:roundedBlock("RingFoot", Vector3.new(3.2, 2.4, 3.2), CFrame.new(side * 5.4, floorY + 1.2, 0), 1.2, "Violet")
	end
	-- sparkle bulbs around the ring
	for i = 0, 11 do
		local a = math.rad(i * 30 + 15)
		b:bulb("RingBulb", 0.7, center * CFrame.new(math.cos(a) * 8.2, math.sin(a) * 8.2, -1.25), i % 2 == 0 and "GlowSun" or "GlowCyan", 5)
	end

	-- capsule towers either side, topped with little planets
	for _, side in ipairs({-1, 1}) do
		local x = side * 11.5
		b:disc("TowerFoot", 3.6, 0.8, CFrame.new(x, floorY + 0.4, 1), "Violet")
		b:pill("Tower", Vector3.new(x, floorY + 1.5, 1), Vector3.new(x, floorY + 14, 1), 2.4, "White")
		b:disc("TowerBand", 2.7, 0.4, CFrame.new(x, floorY + 5, 1), "GlowMint")
		b:disc("TowerBand", 2.7, 0.4, CFrame.new(x, floorY + 10, 1), "Lilac")
		local planet = CFrame.new(x, floorY + 17, 1)
		b:ball("Planet", 3, planet, side < 0 and "Sun" or "Mint")
		b:ring("PlanetRing", planet * CFrame.Angles(math.rad(70), 0, math.rad(side * 20)), 2.3, 0.3, side < 0 and "Coral" or "Lilac", 16)
	end

	-- rounded sign on top of the ring
	local sign = b:roundedBlock("GateSign", Vector3.new(15, 3.6, 1.2), center * CFrame.new(0, 10.6, -0.2), 1.6, "Navy")
	b:roundedBlock("GateSignBack", Vector3.new(15.8, 4.2, 1), center * CFrame.new(0, 10.6, 0.2), 1.9, "Violet")
	Architecture.sign(sign, "WORLD GATE", subtitle or "TRAVEL BETWEEN DIG SITES")
	b:ball("SignStar", 1.4, center * CFrame.new(0, 13.2, 0), "GlowSun")

	-- terminal kiosk (a friendly capsule with a tilted screen)
	b:disc("KioskFoot", 3, 0.4, CFrame.new(0, floorY + 0.2, -7), "Violet")
	local kiosk = b:roundedBlock("Kiosk", Vector3.new(2.6, 3.4, 1.6), CFrame.new(0, floorY + 2.1, -7), 0.8, "Sky")
	local screen = b:roundedBlock("KioskScreen", Vector3.new(3, 1.8, 0.3), CFrame.new(0, floorY + 4.2, -7.3) * CFrame.Angles(math.rad(-25), 0, 0), 0.15, "Navy")
	Architecture.sign(screen, "WORLD MAP", "PRESS E", nil, Color3.new(1, 1, 1))

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Open World Map"
	prompt.ObjectText = "World Gate"
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = kiosk

	gate.Parent = parent
	return gate, prompt
end
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "BackgroundWeather", "LocalScript", [=[
-- BackgroundWeather (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Bizarre background weather: giant plain cubes, spheres and cones tumble out of the sky
-- far away in the background, around whichever world you're in. They spawn well outside
-- the playable area (past the city in World 1, past the island edge in worlds 2-9), fall,
-- spin, and delete themselves at a set height, so they can never touch the ground you play
-- on. Everything happens on this screen only (no server cost, no physics).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local player = Players.LocalPlayer

local MAX_OBJECTS = 40
local SPAWN_EVERY = 0.35      -- seconds between new objects
local SPAWN_HEIGHT = {450, 750} -- studs above the world's ground
local DESTROY_BELOW = -220    -- studs below the world's ground: removed here
-- how far out they fall (studs from the world's center): World 1's island reaches 470 studs,
-- the other islands 125
local DISTANCE = {World1 = {700, 1200}, Island = {520, 1100}}
local CONE_MESH = "rbxassetid://1033714" -- Roblox's classic cone mesh

local COLORS = {
	Color3.fromRGB(255, 110, 124), Color3.fromRGB(92, 186, 255), Color3.fromRGB(255, 206, 84),
	Color3.fromRGB(96, 226, 190), Color3.fromRGB(178, 158, 255), Color3.fromRGB(246, 247, 252),
}
local MATERIALS = {Enum.Material.SmoothPlastic, Enum.Material.SmoothPlastic, Enum.Material.Neon, Enum.Material.Glass}

local folder = Instance.new("Folder")
folder.Name = "BackgroundWeather"
folder.Parent = workspace

local rng = Random.new()
local falling = {} -- {Part, Velocity, Spin, Angles}

local function currentWorld()
	return GameConfig.GetWorld(player:GetAttribute("CurrentWorld") or 1) or GameConfig.Worlds[1]
end

local function spawnOne()
	local world = currentWorld()
	local range = world.Id == 1 and DISTANCE.World1 or DISTANCE.Island
	local angle = rng:NextNumber(0, math.pi * 2)
	local distance = rng:NextNumber(range[1], range[2])
	local origin = world.Origin
	local position = origin + Vector3.new(math.cos(angle) * distance, rng:NextNumber(SPAWN_HEIGHT[1], SPAWN_HEIGHT[2]), math.sin(angle) * distance)

	local part = Instance.new("Part")
	local kind = rng:NextInteger(1, 3)
	local size = rng:NextNumber(10, 38)
	part.Size = Vector3.one * size
	if kind == 2 then
		part.Shape = Enum.PartType.Ball
	elseif kind == 3 then
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = CONE_MESH
		mesh.Scale = Vector3.one * size * 0.5
		mesh.Parent = part
	end
	part.Color = COLORS[rng:NextInteger(1, #COLORS)]
	part.Material = MATERIALS[rng:NextInteger(1, #MATERIALS)]
	if part.Material == Enum.Material.Glass then part.Transparency = 0.3 end
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.CFrame = CFrame.new(position)
	part.Parent = folder

	-- drift slightly away from the world so they never curve in over it
	local outward = Vector3.new(math.cos(angle), 0, math.sin(angle)) * rng:NextNumber(0, 12)
	table.insert(falling, {
		Part = part,
		Velocity = Vector3.new(0, -rng:NextNumber(45, 95), 0) + outward,
		Spin = Vector3.new(rng:NextNumber(-1.5, 1.5), rng:NextNumber(-1.5, 1.5), rng:NextNumber(-1.5, 1.5)),
		Angles = Vector3.zero,
		FloorY = origin.Y + DESTROY_BELOW,
	})
end

local sinceSpawn = 0
RunService.Heartbeat:Connect(function(dt)
	sinceSpawn += dt
	if sinceSpawn >= SPAWN_EVERY and #falling < MAX_OBJECTS then
		sinceSpawn = 0
		spawnOne()
	end
	local parts, cframes = {}, {}
	for i = #falling, 1, -1 do
		local f = falling[i]
		local pos = f.Part.Position + f.Velocity * dt
		if pos.Y < f.FloorY or not f.Part.Parent then
			f.Part:Destroy()
			table.remove(falling, i)
		else
			f.Angles += f.Spin * dt
			table.insert(parts, f.Part)
			table.insert(cframes, CFrame.new(pos) * CFrame.Angles(f.Angles.X, f.Angles.Y, f.Angles.Z))
		end
	end
	if #parts > 0 then
		workspace:BulkMoveTo(parts, cframes, Enum.BulkMoveMode.FireCFrameChanged)
	end
end)

-- travelling to another world: clear the old sky right away
player:GetAttributeChangedSignal("CurrentWorld"):Connect(function()
	for _, f in ipairs(falling) do f.Part:Destroy() end
	table.clear(falling)
end)
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "DigClient", "LocalScript", [=[
-- DigClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Shows the luck minigame, the "you found" popup, and rare-find announcements.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local minigameRemote = remotes:WaitForChild("DigMinigame")
local resultRemote = remotes:WaitForChild("DigResult")
local announceRemote = remotes:WaitForChild("Announcement")

local player = Players.LocalPlayer

---------------------------------------------------------------------
-- UI
---------------------------------------------------------------------
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local GRADE_COLORS = {
	Perfect = C.Mint,
	Good = C.Sun,
	Miss = C.Coral,
}

local gui = UIKit.screen(player, "DigGui", 5)

---------------------------------------------------------------------
-- MINIGAME
---------------------------------------------------------------------
-- a small card with a colored header strip (used by the minigame and the find popup)
local function headerCard(size, position, color, title)
	local card = UIKit.panel(gui, {Size = size, Position = position, AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Panel, Radius = 24, Stroke = 4, StrokeColor = C.Ink, ShadeAmount = 0.05})
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.BorderSizePixel = 0
	header.Size = UDim2.new(1, 0, 0, 50)
	header.Parent = card
	UIKit.corner(header, 22)
	local fill = Instance.new("Frame")
	fill.BorderSizePixel = 0
	fill.AnchorPoint = Vector2.new(0, 1)
	fill.Position = UDim2.fromScale(0, 1)
	fill.Size = UDim2.new(1, 0, 0, 22)
	fill.Parent = header
	local edge = Instance.new("Frame")
	edge.BorderSizePixel = 0
	edge.AnchorPoint = Vector2.new(0, 1)
	edge.Position = UDim2.fromScale(0, 1)
	edge.Size = UDim2.new(1, 0, 0, 4)
	edge.Parent = header
	local titleLabel = UIKit.label(header, title, {Size = UDim2.new(1, -40, 0, 30), Position = UDim2.new(0.5, 0, 0.5, -2), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 3, MaxText = 28})
	local titleStroke = titleLabel:FindFirstChildOfClass("UIStroke")
	local function paint(c)
		header.BackgroundColor3 = c
		fill.BackgroundColor3 = c
		edge.BackgroundColor3 = UIKit.shadeColor(c, 0.35)
		if titleStroke then titleStroke.Color = UIKit.shadeColor(c, 0.6) end
	end
	paint(color)
	return card, titleLabel, paint
end

local mini = headerCard(UDim2.fromOffset(480, 160), UDim2.fromScale(0.5, 0.7), C.Sun, "🍀 LUCKY DIG!")
mini.Visible = false
UIKit.label(mini, "Stop in the green for bonus luck!", {Size = UDim2.new(0.9, 0, 0, 22), Position = UDim2.new(0.5, 0, 0, 58), AnchorPoint = Vector2.new(0.5, 0), Color = C.Ink, Stroke = 0, MaxText = 20})

local bar = UIKit.panel(mini, {Size = UDim2.new(0.88, 0, 0, 30), Position = UDim2.new(0.5, 0, 0, 88), AnchorPoint = Vector2.new(0.5, 0), Color = C.PanelTint, Radius = 15, Stroke = 3, StrokeColor = C.Ink, Shade = false})
bar.ClipsDescendants = false

local goodZone = UIKit.panel(bar, {Size = UDim2.new(0.22, 0, 1, 0), Color = GRADE_COLORS.Good, Radius = 12, Stroke = false})

local perfectZone = UIKit.panel(goodZone, {Size = UDim2.new(0.3, 0, 1, 0), Position = UDim2.new(0.5, 0, 0, 0), AnchorPoint = Vector2.new(0.5, 0), Color = GRADE_COLORS.Perfect, Radius = 8, Stroke = false})

local marker = UIKit.panel(bar, {Size = UDim2.new(0, 12, 1.6, 0), Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.White, Radius = 6, Stroke = 3, StrokeColor = C.Ink, Shade = false})
marker.ZIndex = 3

UIKit.label(mini, "Click, tap, or press Space", {Size = UDim2.new(0.9, 0, 0, 16), Position = UDim2.new(0.5, 0, 1, -26), AnchorPoint = Vector2.new(0.5, 0), Color = C.Grey, Stroke = 0, Font = UIKit.BodyFont, MaxText = 14})
local gradeText = UIKit.label(gui, "", {Size = UDim2.fromOffset(420, 72), Position = UDim2.fromScale(0.5, 0.58), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 5, MaxText = 64})
gradeText.Visible = false

local playing = false
local SPEED = 1.3 -- how fast the marker moves (bar widths per second)

local function showGrade(grade)
	gradeText.Text = string.upper(grade) .. (grade == "Miss" and "" or "!")
	gradeText.TextColor3 = GRADE_COLORS[grade]
	gradeText.Visible = true
	UIKit.pop(gradeText, 0.4)
	task.delay(0.8, function()
		gradeText.Visible = false
	end)
end

local function startMinigame()
	if playing then return end
	playing = true

	-- random zone position each time
	local zoneStart = math.random(10, 68) / 100
	goodZone.Position = UDim2.new(zoneStart, 0, 0, 0)
	local zoneWidth = goodZone.Size.X.Scale
	local perfectWidth = zoneWidth * perfectZone.Size.X.Scale
	local zoneCenter = zoneStart + zoneWidth / 2

	mini.Visible = true
	UIKit.pop(mini)
	local t = 0
	local position = 0
	local renderConn, inputConn
	local done = false

	local function finish(grade)
		if done then return end
		done = true
		playing = false
		renderConn:Disconnect()
		inputConn:Disconnect()
		mini.Visible = false
		showGrade(grade)
		minigameRemote:FireServer(grade)
	end

	renderConn = RunService.RenderStepped:Connect(function(dt)
		t += dt * SPEED
		local cycle = t % 2
		position = (cycle <= 1) and cycle or (2 - cycle) -- bounce left and right
		marker.Position = UDim2.new(position, 0, 0.5, 0)
	end)

	inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		local isClick = input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		local isKey = input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA
		if not (isClick or isKey) then return end
		if gameProcessed and isClick then return end

		local distance = math.abs(position - zoneCenter)
		if distance <= perfectWidth / 2 then
			finish("Perfect")
		elseif distance <= zoneWidth / 2 then
			finish("Good")
		else
			finish("Miss")
		end
	end)

	-- give up after a few seconds
	task.delay(6, function()
		finish("Miss")
	end)
end

minigameRemote.OnClientEvent:Connect(startMinigame)

---------------------------------------------------------------------
-- "YOU FOUND" POPUP
---------------------------------------------------------------------
local claimRemote = remotes:WaitForChild("ClaimFind")

local popup, foundLabel, paintPopupHeader = headerCard(UDim2.fromOffset(460, 368), UDim2.fromScale(0.5, 0.45), C.Violet, "YOU FOUND")
popup.Visible = false
local popupStroke = popup:FindFirstChildOfClass("UIStroke")
local popupScale = Instance.new("UIScale")
popupScale.Parent = popup

local iconHolder = Instance.new("Frame")
iconHolder.BackgroundTransparency = 1
iconHolder.Size = UDim2.fromOffset(112, 112)
iconHolder.Position = UDim2.fromOffset(22, 66)
iconHolder.Parent = popup
local nameLabel = UIKit.label(popup, "", {Size = UDim2.new(1, -170, 0, 34), Position = UDim2.fromOffset(150, 66), Align = "Left", Color = C.Ink, Stroke = 0, MaxText = 28})
local rarityTag = UIKit.panel(popup, {Size = UDim2.fromOffset(150, 28), Position = UDim2.fromOffset(150, 106), Color = C.Lilac, Radius = 14})
local rarityLabel = UIKit.label(rarityTag, "", {Size = UDim2.new(1, -16, 0.76, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2.5, StrokeColor = C.Ink, MaxText = 20})
local incomePill = UIKit.panel(popup, {Size = UDim2.fromOffset(170, 32), Position = UDim2.fromOffset(150, 142), Color = C.Money, Radius = 16})
local incomeLabel = UIKit.label(incomePill, "", {Size = UDim2.new(1, -18, 0.72, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2.5, StrokeColor = UIKit.shadeColor(C.Money, 0.6), MaxText = 20})
local descBox = UIKit.panel(popup, {Size = UDim2.new(1, -44, 0, 62), Position = UDim2.new(0.5, 0, 0, 190), AnchorPoint = Vector2.new(0.5, 0), Color = C.PanelTint, Radius = 14, Stroke = false, Shade = false})
local descLabel = UIKit.label(descBox, "", {Size = UDim2.new(1, -24, 1, -12), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Grey, Stroke = 0, Font = UIKit.BodyFont, TextSize = 15})

local pickButton = UIKit.button(popup, "PICK UP  [E]", {Size = UDim2.new(0.5, -28, 0, 56), Position = UDim2.new(0, 22, 1, -94), Color = C.Mint})
local leaveButton = UIKit.button(popup, "LEAVE IT", {Size = UDim2.new(0.5, -28, 0, 56), Position = UDim2.new(1, -22, 1, -94), AnchorPoint = Vector2.new(1, 0), Color = C.Coral})
-- countdown: the find is left in the dirt when this runs out
local timerTrack = UIKit.panel(popup, {Size = UDim2.new(1, -44, 0, 12), Position = UDim2.new(0.5, 0, 1, -26), AnchorPoint = Vector2.new(0.5, 0), Color = C.PanelTint, Radius = 6, Stroke = 2, StrokeColor = C.Lilac, Shade = false})
local timerFill = UIKit.panel(timerTrack, {Size = UDim2.fromScale(1, 1), Color = C.Sun, Radius = 6, Stroke = false})

local flash = Instance.new("Frame")
flash.Size = UDim2.fromScale(1, 1)
flash.BackgroundTransparency = 1
flash.BorderSizePixel = 0
flash.ZIndex = 0
flash.Parent = gui

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

-- the find visibly pops out of the hole: a glowing orb in the rarity's color jumps out of
-- the ground and arcs into the player's hands, then the popup shows
local heldOrb -- the orb floating above the player while they decide

-- what happens to the floating orb: picked up (flies into the player) or left (drops and fades)
local function finishOrb(take)
	local orb = heldOrb
	heldOrb = nil
	if not orb then return end
	orb:SetAttribute("Done", true)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local goal = take and root and root.Position or (orb.Position - Vector3.new(0, 6, 0))
	local tween = TweenService:Create(orb, TweenInfo.new(take and 0.3 or 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In),
		{Position = goal, Size = Vector3.one * (take and 0.2 or 0.6), Transparency = take and 0 or 1})
	tween:Play()
	tween.Completed:Once(function() orb:Destroy() end)
end

local function treasurePop(position, color, onArrive)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if typeof(position) ~= "Vector3" or not root then
		onArrive()
		return
	end
	local orb = Instance.new("Part")
	orb.Shape = Enum.PartType.Ball
	orb.Size = Vector3.one * 1.6
	orb.Material = Enum.Material.Neon
	orb.Color = color
	orb.Anchored = true
	orb.CanCollide = false
	orb.CanQuery = false
	orb.CanTouch = false
	orb.CastShadow = false
	orb.CFrame = CFrame.new(position)
	orb.Parent = workspace
	local light = Instance.new("PointLight")
	light.Color = color
	light.Range = 10
	light.Brightness = 1
	light.Parent = orb
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Color = ColorSequence.new(color)
	sparkle.LightEmission = 0.6
	sparkle.Size = NumberSequence.new(0.35, 0)
	sparkle.Lifetime = NumberRange.new(0.4, 0.7)
	sparkle.Rate = 40
	sparkle.Speed = NumberRange.new(1, 3)
	sparkle.SpreadAngle = Vector2.new(180, 180)
	sparkle.Parent = orb

	local start = os.clock()
	local DURATION = 0.6
	local conn
	conn = RunService.RenderStepped:Connect(function()
		local t = (os.clock() - start) / DURATION
		local goal = root.Parent and (root.Position + Vector3.new(0, 4.5, 0)) or position
		if t >= 1 then
			conn:Disconnect()
			-- float above the player's head, bobbing, until they pick it up or leave it
			heldOrb = orb
			local bob
			bob = RunService.RenderStepped:Connect(function()
				if orb:GetAttribute("Done") or not orb.Parent or not root.Parent then
					bob:Disconnect()
					return
				end
				local c = os.clock()
				orb.CFrame = CFrame.new(root.Position + Vector3.new(0, 4.5 + math.sin(c * 3) * 0.3, 0)) * CFrame.Angles(0, c * 2, 0)
			end)
			onArrive()
			return
		end
		-- pop straight up first, then arc over into the player
		local ease = t * t * (3 - 2 * t)
		local pos = position:Lerp(goal, ease) + Vector3.new(0, math.sin(t * math.pi) * 7, 0)
		local spin = CFrame.Angles(0, t * 12, 0)
		local size = 1.6 * (1 + math.sin(t * math.pi) * 0.5) * (1 - t * 0.5)
		orb.Size = Vector3.one * size
		orb.CFrame = CFrame.new(pos) * spin
	end)
end

local popupToken = 0
local awaiting -- popup token of the find waiting for a choice

local function choose(take)
	if not awaiting then return end
	awaiting = nil
	claimRemote:FireServer(take)
	popup.Visible = false
	finishOrb(take)
end
pickButton.MouseButton1Click:Connect(function() choose(true) end)
leaveButton.MouseButton1Click:Connect(function() choose(false) end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.E and awaiting then
		choose(true)
	end
end)

resultRemote.OnClientEvent:Connect(function(info)
	popupToken += 1
	local myToken = popupToken
	local sound = GameConfig.Sounds and GameConfig.Sounds.Find
	if sound and sound ~= "" then
		local s = Instance.new("Sound")
		s.SoundId = sound
		s.Volume = 0.7
		s.Parent = workspace.CurrentCamera
		s:Play()
		game:GetService("Debris"):AddItem(s, 4)
	end
	treasurePop(info.Position, info.Color, function()
		if popupToken ~= myToken then return end

		for _, child in ipairs(iconHolder:GetChildren()) do child:Destroy() end
		UIKit.artifactIcon(iconHolder, {Id = info.Id, Rarity = info.Rarity}, {Size = UDim2.fromScale(1, 1), Radius = 20})
		nameLabel.Text = info.Name
		rarityLabel.Text = string.upper(info.Rarity)
		rarityTag.BackgroundColor3 = info.Color
		popupStroke.Color = info.Color:Lerp(C.Ink, 0.45)
		paintPopupHeader(info.Color:Lerp(C.Violet, 0.25))
		incomeLabel.Text = "💵 " .. ArtifactData.FormatMoney(info.Income) .. "/s"
		descLabel.Text = info.Description
		foundLabel.Text = (info.Grade == "Perfect" and "✨ PERFECT DIG! ✨") or "YOU FOUND A MEME!"

		-- pop-in animation
		popup.Visible = true
		popupScale.Scale = 0.3
		TweenService:Create(popupScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()

		-- big finds (Legendary and up) flash the screen
		local big = info.RarityIndex >= ArtifactData.GetRarityIndex("Legendary")
		if big then
			flash.BackgroundColor3 = info.Color
			flash.BackgroundTransparency = 0.55
			TweenService:Create(flash, TweenInfo.new(1.2), {BackgroundTransparency = 1}):Play()
		end

		-- wait for the player's choice; the countdown bar shrinks until the find is left behind
		local timeout = tonumber(info.Timeout) or 20
		timerFill.Size = UDim2.fromScale(1, 1)
		TweenService:Create(timerFill, TweenInfo.new(timeout, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(0, 1)}):Play()
		awaiting = myToken
		task.delay(timeout, function()
			if awaiting == myToken then
				awaiting = nil
				popup.Visible = false
				finishOrb(false)
			end
		end)
	end)
end)

---------------------------------------------------------------------
-- RARE FIND ANNOUNCEMENTS (whole server)
---------------------------------------------------------------------
local banner = UIKit.panel(gui, {Size = UDim2.fromOffset(640, 54), Position = UDim2.new(0.5, 0, 0, 14), AnchorPoint = Vector2.new(0.5, 0), Color = C.Ink, Radius = 27, Stroke = 3, StrokeColor = C.Sun, ShadeAmount = 0.2})
banner.BackgroundTransparency = 0.08
banner.Visible = false
local bannerStroke = banner:FindFirstChildOfClass("UIStroke")
local bannerStar = UIKit.badge(banner, "🎉", C.Sun, {Diameter = 44, Position = UDim2.new(0, 6, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)})
local bannerText = UIKit.label(banner, "", {Size = UDim2.new(1, -80, 0.56, 0), Position = UDim2.new(0, 62, 0.22, 0), Align = "Left", Color = C.White, Stroke = 0, MaxText = 24})

local bannerToken = 0
announceRemote.OnClientEvent:Connect(function(message, color)
	bannerToken += 1
	local myToken = bannerToken
	bannerText.Text = message
	local accent = typeof(color) == "Color3" and color or C.Sun
	bannerStar.BackgroundColor3 = accent
	bannerStroke.Color = accent
	banner.Visible = true
	UIKit.pop(banner, 0.7)
	task.delay(6, function()
		if bannerToken == myToken then
			banner.Visible = false
		end
	end)
end)
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "FlyingTraffic", "LocalScript", [=[
-- FlyingTraffic (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Cartoony bubble cars, hover buses, delivery drones and ad blimps flying around the
-- city in traffic lanes (the vehicle designs live in ReplicatedStorage.VehicleModels).
-- Runs only on each player's screen, so it's smooth and doesn't load the server.

local RunService = game:GetService("RunService")

local folder = Instance.new("Folder")
folder.Name = "FlyingTraffic"
folder.Parent = workspace

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VehicleModels = require(ReplicatedStorage:WaitForChild("VehicleModels"))

local rng = Random.new()

-- Traffic lanes: circles around the map, placed between the rings of towers
-- Dir 1 = counter-clockwise, -1 = clockwise. Kind = which vehicle flies there.
local LANES = { -- World 1 is a compact island now: boulevard at 269, towers from 290 to 450
	{Radius = 269, Height = 26,  Speed = 40,  Count = 6, Dir = 1,  Kind = "drone"},  -- low over the ring boulevard
	{Radius = 269, Height = 42,  Speed = 70,  Count = 6, Dir = -1, Kind = "car"},
	{Radius = 269, Height = 60,  Speed = 55,  Count = 3, Dir = 1,  Kind = "bus"},
	{Radius = 312, Height = 250, Speed = 85,  Count = 6, Dir = 1,  Kind = "car"},    -- above the inner tower ring
	{Radius = 364, Height = 360, Speed = 70,  Count = 5, Dir = -1, Kind = "car"},    -- above the middle ring
	{Radius = 520, Height = 140, Speed = 95,  Count = 7, Dir = -1, Kind = "car"},    -- just past the island edge
	{Radius = 520, Height = 220, Speed = 50,  Count = 4, Dir = 1,  Kind = "drone"},
	{Radius = 300, Height = 600, Speed = 25,  Count = 2, Dir = -1, Kind = "blimp"},
	{Radius = 560, Height = 520, Speed = 22,  Count = 2, Dir = 1,  Kind = "blimp"},
}

---------------------------------------------------------------------
-- SPAWN VEHICLES ON THEIR LANES
---------------------------------------------------------------------
local vehicles = {}
for _, lane in ipairs(LANES) do
	for i = 1, lane.Count do
		local model = VehicleModels[lane.Kind](rng)
		model.Parent = folder
		table.insert(vehicles, {
			Model = model,
			Lane = lane,
			Angle = (i / lane.Count) * math.pi * 2 + rng:NextNumber(-0.2, 0.2),
			Speed = lane.Speed * rng:NextNumber(0.85, 1.15),
			Phase = rng:NextNumber(0, math.pi * 2),
			HeightOffset = rng:NextNumber(-4, 4),
		})
	end
end

---------------------------------------------------------------------
-- MOVE EVERYTHING SMOOTHLY EVERY FRAME
---------------------------------------------------------------------
RunService.Heartbeat:Connect(function(dt)
	local t = os.clock()
	for _, v in ipairs(vehicles) do
		local lane = v.Lane
		v.Angle += lane.Dir * (v.Speed / lane.Radius) * dt
		local a = v.Angle
		local big = lane.Kind == "blimp"
		local bob = math.sin(t * (big and 0.5 or 1.4) + v.Phase) * (big and 3 or 1.2)
		local position = Vector3.new(math.cos(a) * lane.Radius, lane.Height + v.HeightOffset + bob, math.sin(a) * lane.Radius)
		local forward = Vector3.new(-math.sin(a), 0, math.cos(a)) * lane.Dir
		-- lean into the curve and wobble a little, like a bouncy cartoon vehicle
		local wobble = math.sin(t * 2.1 + v.Phase) * (big and 0.01 or 0.06)
		local lean = CFrame.Angles(wobble, 0, lane.Dir * (big and 0.04 or 0.16) + wobble)
		v.Model:PivotTo(CFrame.lookAt(position, position + forward) * lean)
	end
end)
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "HUD", "LocalScript", [=[
-- HUD (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The always-on screen: money and income counters, which world you're in, and a
-- custom hotbar that shows your shovel as a 3D icon (replaces Roblox's default backpack bar).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors

local player = Players.LocalPlayer
local gui = UIKit.screen(player, "HUD", 1)

-- our own hotbar replaces the default one
task.spawn(function()
	for _ = 1, 20 do
		if pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false) end) then break end
		task.wait(0.5)
	end
end)

---------------------------------------------------------------------
-- MONEY / INCOME / WORLD (top left)
---------------------------------------------------------------------
local stats = Instance.new("Frame")
stats.BackgroundTransparency = 1
stats.Size = UDim2.fromOffset(260, 150)
stats.Position = UDim2.fromOffset(14, 12)
stats.Parent = gui
local statsLayout = Instance.new("UIListLayout")
statsLayout.Padding = UDim.new(0, 8)
statsLayout.Parent = stats

-- a glossy colored pill with a round emoji badge poking out on the left
local function pill(color, badgeColor, iconText, width, height, order)
	local holder = Instance.new("Frame")
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.fromOffset(width + 14, height)
	holder.LayoutOrder = order
	holder.Parent = stats
	local p = UIKit.panel(holder, {Size = UDim2.new(1, -14, 1, 0), Position = UDim2.fromOffset(14, 0), Color = color, Radius = height / 2, ShadeAmount = 0.16})
	UIKit.badge(holder, iconText, badgeColor, {Diameter = height + 8, Position = UDim2.new(0, -2, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)})
	local text = UIKit.label(p, "", {Size = UDim2.new(1, -height - 10, 1, -12), Position = UDim2.new(0, height - 2, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
		Align = "Left", Stroke = 2.5, StrokeColor = UIKit.shadeColor(color, 0.6), MaxText = 30})
	return holder, text
end

local moneyPill, moneyText = pill(C.Money, C.Sun, "💵", 230, 50, 1)
local _, incomeText = pill(C.Sun, C.White, "⚡", 190, 38, 2)
local _, worldText = pill(C.Violet, C.Lilac, "🌍", 210, 34, 3)

local shownMoney = 0
local moneyScale = Instance.new("UIScale")
moneyScale.Parent = moneyPill
local function refreshMoney()
	local money = player:GetAttribute("Money") or 0
	if money > shownMoney + 0.5 then
		-- little bounce when money goes up
		moneyScale.Scale = 1.08
		TweenService:Create(moneyScale, TweenInfo.new(0.25, Enum.EasingStyle.Back), {Scale = 1}):Play()
	end
	shownMoney = money
	moneyText.Text = ArtifactData.FormatMoney(money)
end
local function refreshIncome()
	incomeText.Text = "+" .. ArtifactData.FormatMoney(player:GetAttribute("Income") or 0) .. "/s"
end
local function refreshWorld()
	local world = GameConfig.GetWorld(player:GetAttribute("CurrentWorld") or 1)
	worldText.Text = world and world.Name or ""
end
player:GetAttributeChangedSignal("Money"):Connect(refreshMoney)
player:GetAttributeChangedSignal("Income"):Connect(refreshIncome)
player:GetAttributeChangedSignal("CurrentWorld"):Connect(refreshWorld)
refreshMoney()
refreshIncome()
refreshWorld()

---------------------------------------------------------------------
-- HOTBAR (bottom center): one slot per tool, 3D icon for shovels
---------------------------------------------------------------------
local hotbar = Instance.new("Frame")
hotbar.BackgroundTransparency = 1
hotbar.Size = UDim2.fromOffset(400, 86)
hotbar.Position = UDim2.new(0.5, 0, 1, -12)
hotbar.AnchorPoint = Vector2.new(0.5, 1)
hotbar.Parent = gui
local hotbarLayout = Instance.new("UIListLayout")
hotbarLayout.FillDirection = Enum.FillDirection.Horizontal
hotbarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
hotbarLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
hotbarLayout.Padding = UDim.new(0, 10)
hotbarLayout.SortOrder = Enum.SortOrder.LayoutOrder
hotbarLayout.Parent = hotbar

local KEYS = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five}
local slots = {} -- {Tool, Button}

local function toggle(tool)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	if tool.Parent == character then
		humanoid:UnequipTools()
	else
		humanoid:EquipTool(tool)
	end
end

local function styleSlot(slot)
	local equipped = slot.Tool.Parent == player.Character
	slot.Button.BackgroundColor3 = equipped and C.Sun or C.Panel
	slot.Hint.Visible = not equipped
end

local function rebuild()
	local tools = {}
	for _, container in ipairs({player:FindFirstChild("Backpack"), player.Character}) do
		if container then
			for _, item in ipairs(container:GetChildren()) do
				if item:IsA("Tool") then table.insert(tools, item) end
			end
		end
	end
	table.sort(tools, function(a, b) return a.Name < b.Name end)
	-- same tools as before (e.g. one just got equipped)? only restyle, don't redraw icons
	local same = #tools == #slots
	for i, tool in ipairs(tools) do
		if not slots[i] or slots[i].Tool ~= tool then same = false end
	end
	if same then
		for _, slot in ipairs(slots) do styleSlot(slot) end
		return
	end
	for _, slot in ipairs(slots) do
		slot.Button:Destroy()
	end
	slots = {}
	for i, tool in ipairs(tools) do
		if i > #KEYS then break end
		local button = UIKit.button(hotbar, "", {Size = UDim2.fromOffset(78, 78), Color = C.Panel, Radius = 18})
		button.LayoutOrder = i
		local def = GameConfig.GetShovel(tool:GetAttribute("ShovelId"))
		if def then
			UIKit.shovelIcon(button, def, {Size = UDim2.fromScale(0.92, 0.92), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5)})
		else
			UIKit.label(button, tool.Name, {Size = UDim2.fromScale(0.9, 0.5), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Ink, Stroke = 0})
		end
		UIKit.badge(button, tostring(i), C.Violet, {Diameter = 26, Position = UDim2.fromOffset(-7, -7), Font = UIKit.Font, TextStroke = 0})
		local hint = UIKit.panel(button, {Size = UDim2.fromOffset(70, 24), Position = UDim2.new(0.5, 0, 0, -32), AnchorPoint = Vector2.new(0.5, 0), Color = C.Sun, Radius = 12})
		UIKit.label(hint, "EQUIP [" .. i .. "]", {Size = UDim2.new(1, -10, 1, -6), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2, StrokeColor = UIKit.shadeColor(C.Sun, 0.6)})
		local slot = {Tool = tool, Button = button, Hint = hint}
		button.MouseButton1Click:Connect(function() toggle(tool) end)
		table.insert(slots, slot)
		styleSlot(slot)
	end
end

local pending = false
local function queueRebuild()
	if pending then return end
	pending = true
	task.defer(function()
		pending = false
		rebuild()
	end)
end

local function watch(container)
	local function onChange(child)
		if child:IsA("Tool") then queueRebuild() end
	end
	container.ChildAdded:Connect(onChange)
	container.ChildRemoved:Connect(onChange)
end

local function onCharacter(character)
	watch(character)
	watch(player:WaitForChild("Backpack"))
	queueRebuild()
end
player.CharacterAdded:Connect(onCharacter)
if player.Character then onCharacter(player.Character) end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	for i, key in ipairs(KEYS) do
		if input.KeyCode == key and slots[i] then
			toggle(slots[i].Tool)
		end
	end
end)

-- keep the equipped highlight in sync (equipping moves the tool between Backpack and Character)
task.spawn(function()
	while true do
		task.wait(0.25)
		for _, slot in ipairs(slots) do
			if slot.Button.Parent then styleSlot(slot) end
		end
	end
end)
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "InventoryClient", "LocalScript", [=[
-- InventoryClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The Inventory window: every meme you've picked up, as icon tiles sorted from rarest to
-- most common, with how many you have and how much each one earns on display.
-- Open it with the bag button on the left or the B key.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local getInventory = remotes:WaitForChild("GetInventory")
local inventoryChangedRemote = remotes:WaitForChild("InventoryChanged")

local player = Players.LocalPlayer
local gui = UIKit.screen(player, "InventoryGui", 3)

---------------------------------------------------------------------
-- BAG BUTTON (left side, under the money pills)
---------------------------------------------------------------------
local bagButton = UIKit.button(gui, "", {Size = UDim2.fromOffset(66, 66), Position = UDim2.new(0, 18, 0, 170), Color = C.Sun, Radius = 20})
local bagEmoji = Instance.new("TextLabel")
bagEmoji.BackgroundTransparency = 1
bagEmoji.Size = UDim2.fromScale(0.62, 0.62)
bagEmoji.Position = UDim2.fromScale(0.5, 0.45)
bagEmoji.AnchorPoint = Vector2.new(0.5, 0.5)
bagEmoji.Text = "🎒"
bagEmoji.TextScaled = true
bagEmoji.Parent = bagButton
local bagTag = UIKit.panel(bagButton, {Size = UDim2.fromOffset(62, 22), Position = UDim2.new(0.5, 0, 1, 2), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Ink, Radius = 11, StrokeColor = C.Sun})
UIKit.label(bagTag, "BAG [B]", {Size = UDim2.new(1, -10, 1, -6), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 0, MaxText = 14})

---------------------------------------------------------------------
-- WINDOW
---------------------------------------------------------------------
local window, content = UIKit.window(gui, "INVENTORY", UDim2.fromOffset(740, 560), C.Sun, "🎒")
local countLabel = UIKit.label(content, "", {Size = UDim2.new(1, 0, 0, 26), Position = UDim2.fromOffset(4, 4), Align = "Left", Color = C.Violet, Stroke = 0, MaxText = 22})

local gridHolder = Instance.new("ScrollingFrame")
gridHolder.BackgroundTransparency = 1
gridHolder.BorderSizePixel = 0
gridHolder.Size = UDim2.new(1, 0, 1, -44)
gridHolder.Position = UDim2.fromOffset(0, 42)
gridHolder.ScrollBarThickness = 8
gridHolder.ScrollBarImageColor3 = C.Lilac
gridHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
gridHolder.CanvasSize = UDim2.new()
gridHolder.Parent = content
local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.fromOffset(150, 186)
grid.CellPadding = UDim2.fromOffset(12, 12)
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
grid.Parent = gridHolder
local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 8)
pad.PaddingBottom = UDim.new(0, 8)
pad.Parent = gridHolder

local emptyLabel = UIKit.label(content, "Nothing here yet... go dig up some memes!", {
	Size = UDim2.new(0.9, 0, 0, 30), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Grey, Stroke = 0,
})

local function refresh()
	local ok, list = pcall(function() return getInventory:InvokeServer() end)
	if not ok or type(list) ~= "table" then return end
	for _, child in ipairs(gridHolder:GetChildren()) do
		if child:IsA("GuiObject") then child:Destroy() end
	end
	-- rarest first, then by name
	local entries, total = {}, 0
	for _, item in ipairs(list) do
		local artifact = ArtifactData.GetArtifact(item.Id)
		if artifact then
			table.insert(entries, {Artifact = artifact, Count = item.Count})
			total += item.Count
		end
	end
	table.sort(entries, function(a, b)
		local ra, rb = ArtifactData.GetRarityIndex(a.Artifact.Rarity), ArtifactData.GetRarityIndex(b.Artifact.Rarity)
		if ra ~= rb then return ra > rb end
		return a.Artifact.Name < b.Artifact.Name
	end)
	countLabel.Text = total .. " memes  •  " .. #entries .. " different"
	emptyLabel.Visible = #entries == 0

	for i, entry in ipairs(entries) do
		local artifact = entry.Artifact
		local rarity = ArtifactData.GetRarity(artifact.Rarity)
		local card = UIKit.panel(gridHolder, {Size = UDim2.fromOffset(150, 186), Color = C.White, Radius = 20, ShadeAmount = 0.06})
		card.LayoutOrder = i
		UIKit.artifactIcon(card, artifact, {Size = UDim2.fromOffset(96, 96), Position = UDim2.new(0.5, 0, 0, 10), AnchorPoint = Vector2.new(0.5, 0)})
		if entry.Count > 1 then
			local countTag = UIKit.panel(card, {Size = UDim2.fromOffset(44, 28), Position = UDim2.fromOffset(8, 8), Color = C.Violet, Radius = 14, Stroke = 2})
			UIKit.label(countTag, "x" .. entry.Count, {Size = UDim2.fromScale(0.8, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2})
		end
		UIKit.label(card, artifact.Name, {Size = UDim2.new(1, -14, 0, 32), Position = UDim2.new(0.5, 0, 0, 110), AnchorPoint = Vector2.new(0.5, 0), Color = C.Ink, Stroke = 0, MaxText = 16})
		local rarityTag = UIKit.panel(card, {Size = UDim2.new(1, -28, 0, 20), Position = UDim2.new(0.5, 0, 0, 144), AnchorPoint = Vector2.new(0.5, 0), Color = rarity.Color, Radius = 10, Stroke = 2})
		UIKit.label(rarityTag, string.upper(artifact.Rarity), {Size = UDim2.fromScale(0.9, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2, StrokeColor = C.Ink, MaxText = 14})
		UIKit.label(card, ArtifactData.FormatMoney(ArtifactData.GetIncome(artifact)) .. "/s", {Size = UDim2.new(1, -14, 0, 16), Position = UDim2.new(0.5, 0, 1, -20), AnchorPoint = Vector2.new(0.5, 0), Color = C.Money, Stroke = 0, MaxText = 15})
	end
end

local function toggle()
	if window.Visible then
		window.Visible = false
	else
		refresh()
		UIKit.open(window)
	end
end

bagButton.MouseButton1Click:Connect(toggle)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.B then
		toggle()
	end
end)
inventoryChangedRemote.OnClientEvent:Connect(function()
	if window.Visible then refresh() end
	-- little bounce on the bag so players notice the new item
	UIKit.pop(bagButton, 1.3)
end)
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "MuseumClient", "LocalScript", [=[
-- MuseumClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The museum side of the UI (World 1 only):
--   * a spinning, floating meme card over every pedestal that has a meme on it (in every
--     player's museum, so visitors can see your collection too)
--   * the Display window: pick a meme from your inventory to put on a slot, or take it back
--   * the Alien Art Dealer window: sell memes for cash
--   * up/down arrows on the left while you're inside a museum, to change floors
--     (the up arrow also buys the next floor in your own museum)
-- Slot prompts only show up in your own museum.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local getInventory = remotes:WaitForChild("GetInventory")
local inventoryChangedRemote = remotes:WaitForChild("InventoryChanged")
local openSlotRemote = remotes:WaitForChild("OpenSlotMenu")
local placeRemote = remotes:WaitForChild("PlaceInSlot")
local takeRemote = remotes:WaitForChild("TakeFromSlot")
local openDealerRemote = remotes:WaitForChild("OpenDealer")
local sellRemote = remotes:WaitForChild("SellArtifacts")
local floorRemote = remotes:WaitForChild("ChangeFloor")

local player = Players.LocalPlayer
local museumsFolder = workspace:WaitForChild("Museums")

---------------------------------------------------------------------
-- SPINNING MEME CARDS ON THE PEDESTALS
---------------------------------------------------------------------
local cards = {} -- [slot model] = {Part, Base CFrame, Phase}

local function removeCard(slot)
	local card = cards[slot]
	if card then
		card.Part:Destroy()
		cards[slot] = nil
	end
end

local function cardFace(part, face, artifact)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 50
	gui.LightInfluence = 0
	gui.Parent = part
	UIKit.artifactIcon(gui, artifact, {Size = UDim2.fromScale(1, 1), Radius = 28, Stroke = 6})
end

local function updateCard(slot)
	removeCard(slot)
	local artifact = ArtifactData.GetArtifact(slot:GetAttribute("ArtifactId") or "")
	local spot = slot:FindFirstChild("DisplaySpot")
	if not artifact or not spot then return end
	local rarity = ArtifactData.GetRarity(artifact.Rarity)

	local part = Instance.new("Part")
	part.Name = "MemeCard"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Size = Vector3.new(4.4, 4.4, 0.35)
	part.Color = rarity.Color
	part.Material = Enum.Material.SmoothPlastic
	cardFace(part, Enum.NormalId.Front, artifact)
	cardFace(part, Enum.NormalId.Back, artifact)
	local light = Instance.new("PointLight")
	light.Color = rarity.Color
	light.Range = 10
	light.Brightness = 0.7
	light.Parent = part
	-- fancier memes sparkle
	if ArtifactData.GetRarityIndex(artifact.Rarity) >= 5 then
		local sparkles = Instance.new("ParticleEmitter")
		sparkles.Rate = 4
		sparkles.Lifetime = NumberRange.new(0.8, 1.4)
		sparkles.Speed = NumberRange.new(0.5, 1.2)
		sparkles.SpreadAngle = Vector2.new(180, 180)
		sparkles.Size = NumberSequence.new(0.25, 0)
		sparkles.LightEmission = 0.8
		sparkles.Color = ColorSequence.new(rarity.Color)
		sparkles.Parent = part
	end
	local base = CFrame.new(spot.Position + Vector3.new(0, 1, 0))
	part.CFrame = base
	part.Parent = slot
	cards[slot] = {Part = part, Base = base, Phase = (slot:GetAttribute("SlotIndex") or 1) * 0.7}
end

local function watchSlot(slot, owned)
	slot:GetAttributeChangedSignal("ArtifactId"):Connect(function()
		updateCard(slot)
	end)
	slot.AncestryChanged:Connect(function()
		if not slot:IsDescendantOf(workspace) then removeCard(slot) end
	end)
	updateCard(slot)
	-- only the owner sees the slot prompts
	local function checkPrompt(child)
		if child:IsA("ProximityPrompt") and child.Name == "SlotPrompt" then
			child.Enabled = owned
		end
	end
	slot.DescendantAdded:Connect(checkPrompt)
	for _, d in ipairs(slot:GetDescendants()) do checkPrompt(d) end
end

local function watchMuseum(museum)
	local slots = museum:WaitForChild("Slots", 10)
	if not slots then return end
	local owned = museum:GetAttribute("OwnerUserId") == player.UserId
	for _, slot in ipairs(slots:GetChildren()) do
		watchSlot(slot, owned)
	end
end

museumsFolder.ChildAdded:Connect(watchMuseum)
for _, museum in ipairs(museumsFolder:GetChildren()) do
	task.spawn(watchMuseum, museum)
end

RunService.RenderStepped:Connect(function()
	local t = os.clock()
	for _, card in pairs(cards) do
		local bob = math.sin(t * 1.6 + card.Phase) * 0.3
		card.Part.CFrame = card.Base * CFrame.new(0, bob, 0) * CFrame.Angles(0, t * 0.9 + card.Phase, 0)
	end
end)

---------------------------------------------------------------------
-- SHARED: an inventory grid with a button on every meme
---------------------------------------------------------------------
local function fetchInventory()
	local ok, list = pcall(function() return getInventory:InvokeServer() end)
	if not ok or type(list) ~= "table" then return {} end
	local entries = {}
	for _, item in ipairs(list) do
		local artifact = ArtifactData.GetArtifact(item.Id)
		if artifact then
			table.insert(entries, {Artifact = artifact, Count = item.Count})
		end
	end
	-- best earners first
	table.sort(entries, function(a, b)
		local ia, ib = ArtifactData.GetIncome(a.Artifact), ArtifactData.GetIncome(b.Artifact)
		if ia ~= ib then return ia > ib end
		return a.Artifact.Name < b.Artifact.Name
	end)
	return entries
end

local function makeGrid(parent, top)
	local holder = Instance.new("ScrollingFrame")
	holder.BackgroundTransparency = 1
	holder.BorderSizePixel = 0
	holder.Size = UDim2.new(1, 0, 1, -top)
	holder.Position = UDim2.fromOffset(0, top)
	holder.ScrollBarThickness = 8
	holder.ScrollBarImageColor3 = C.Lilac
	holder.AutomaticCanvasSize = Enum.AutomaticSize.Y
	holder.CanvasSize = UDim2.new()
	holder.Parent = parent
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.fromOffset(150, 214)
	grid.CellPadding = UDim2.fromOffset(12, 12)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
	grid.Parent = holder
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.Parent = holder
	return holder
end

local function clear(holder)
	for _, child in ipairs(holder:GetChildren()) do
		if child:IsA("GuiObject") then child:Destroy() end
	end
end

-- one meme card; returns the card frame
local function memeCard(holder, entry, order, valueText)
	local artifact = entry.Artifact
	local rarity = ArtifactData.GetRarity(artifact.Rarity)
	local card = UIKit.panel(holder, {Size = UDim2.fromOffset(150, 214), Color = C.White, Radius = 20, ShadeAmount = 0.06})
	card.LayoutOrder = order
	UIKit.artifactIcon(card, artifact, {Size = UDim2.fromOffset(84, 84), Position = UDim2.new(0.5, 0, 0, 8), AnchorPoint = Vector2.new(0.5, 0)})
	if entry.Count and entry.Count > 1 then
		local tag = UIKit.panel(card, {Size = UDim2.fromOffset(44, 26), Position = UDim2.fromOffset(8, 8), Color = C.Violet, Radius = 13, Stroke = 2})
		UIKit.label(tag, "x" .. entry.Count, {Size = UDim2.fromScale(0.8, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2})
	end
	UIKit.label(card, artifact.Name, {Size = UDim2.new(1, -14, 0, 30), Position = UDim2.new(0.5, 0, 0, 96), AnchorPoint = Vector2.new(0.5, 0), Color = C.Ink, Stroke = 0, MaxText = 16})
	local tag = UIKit.panel(card, {Size = UDim2.new(1, -28, 0, 20), Position = UDim2.new(0.5, 0, 0, 128), AnchorPoint = Vector2.new(0.5, 0), Color = rarity.Color, Radius = 10, Stroke = 2})
	UIKit.label(tag, string.upper(artifact.Rarity), {Size = UDim2.fromScale(0.9, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2, StrokeColor = C.Ink, MaxText = 14})
	UIKit.label(card, valueText, {Size = UDim2.new(1, -14, 0, 16), Position = UDim2.new(0.5, 0, 0, 152), AnchorPoint = Vector2.new(0.5, 0), Color = C.Money, Stroke = 0, MaxText = 15})
	return card
end

local gui = UIKit.screen(player, "MuseumGui", 3)

---------------------------------------------------------------------
-- DISPLAY WINDOW (opened from a slot)
---------------------------------------------------------------------
local displayWindow, displayContent = UIKit.window(gui, "DISPLAY", UDim2.fromOffset(740, 580), C.Violet, "🏛️")
local currentPanel = UIKit.panel(displayContent, {Size = UDim2.new(1, 0, 0, 96), Color = C.PanelTint, Radius = 20, StrokeColor = C.Lilac})
local currentTitle = UIKit.label(currentPanel, "", {Size = UDim2.new(1, -310, 0, 30), Position = UDim2.fromOffset(104, 16), Align = "Left", Color = C.Ink, Stroke = 0, MaxText = 24})
local currentSub = UIKit.label(currentPanel, "", {Size = UDim2.new(1, -310, 0, 22), Position = UDim2.fromOffset(104, 52), Align = "Left", Color = C.Money, Stroke = 0, MaxText = 18})
local takeButton = UIKit.button(currentPanel, "TAKE BACK", {Size = UDim2.fromOffset(170, 50), Position = UDim2.new(1, -14, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), Color = C.Coral})
local currentIconHolder = Instance.new("Frame")
currentIconHolder.BackgroundTransparency = 1
currentIconHolder.Size = UDim2.fromOffset(80, 80)
currentIconHolder.Position = UDim2.fromOffset(10, 8)
currentIconHolder.Parent = currentPanel
local pickLabel = UIKit.label(displayContent, "Pick a meme from your inventory:", {Size = UDim2.new(1, 0, 0, 24), Position = UDim2.fromOffset(4, 106), Align = "Left", Color = C.Violet, Stroke = 0, MaxText = 20})
local displayGrid = makeGrid(displayContent, 134)
local displayEmpty = UIKit.label(displayContent, "Your bag is empty... go dig up some memes!", {
	Size = UDim2.new(0.9, 0, 0, 30), Position = UDim2.fromScale(0.5, 0.62), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Grey, Stroke = 0,
})

local openSlot -- slot number the window is for

local function myMuseum()
	local ref = player:FindFirstChild("Museum")
	return ref and ref.Value
end

local function refreshDisplay()
	if not openSlot then return end
	local museum = myMuseum()
	local slot = museum and museum:FindFirstChild("Slots") and museum.Slots:FindFirstChild("Slot" .. openSlot)
	local shown = slot and ArtifactData.GetArtifact(slot:GetAttribute("ArtifactId") or "")
	clear(currentIconHolder)
	if shown then
		UIKit.artifactIcon(currentIconHolder, shown, {Size = UDim2.fromScale(1, 1)})
		currentTitle.Text = "Slot " .. openSlot .. ":  " .. shown.Name
		currentSub.Text = "Earning +" .. ArtifactData.FormatMoney(ArtifactData.GetIncome(shown)) .. "/s"
		takeButton.Visible = true
		pickLabel.Text = "Swap it for another meme:"
	else
		currentTitle.Text = "Slot " .. openSlot .. " is empty"
		currentSub.Text = "Memes on display earn money every second"
		takeButton.Visible = false
		pickLabel.Text = "Pick a meme from your inventory:"
	end

	clear(displayGrid)
	local entries = fetchInventory()
	displayEmpty.Visible = #entries == 0
	for i, entry in ipairs(entries) do
		local card = memeCard(displayGrid, entry, i, "+" .. ArtifactData.FormatMoney(ArtifactData.GetIncome(entry.Artifact)) .. "/s")
		local place = UIKit.button(card, shown and "SWAP" or "PLACE", {Size = UDim2.new(1, -20, 0, 34), Position = UDim2.new(0.5, 0, 1, -8), AnchorPoint = Vector2.new(0.5, 1), Color = C.Mint})
		place.MouseButton1Click:Connect(function()
			placeRemote:FireServer(openSlot, entry.Artifact.Id)
			displayWindow.Visible = false
		end)
	end
end

takeButton.MouseButton1Click:Connect(function()
	if openSlot then
		takeRemote:FireServer(openSlot)
		displayWindow.Visible = false
	end
end)

openSlotRemote.OnClientEvent:Connect(function(slotIndex)
	openSlot = slotIndex
	refreshDisplay()
	UIKit.open(displayWindow)
end)

---------------------------------------------------------------------
-- ALIEN ART DEALER WINDOW
---------------------------------------------------------------------
local dealerWindow, dealerContent = UIKit.window(gui, "ALIEN ART DEALER", UDim2.fromOffset(740, 580), C.Mint, "👽")
UIKit.label(dealerContent, "\"Greetings, Earthling. I pay top dollar for ancient memes.\"", {
	Size = UDim2.new(1, 0, 0, 24), Position = UDim2.fromOffset(4, 4), Align = "Left", Color = C.Violet, Stroke = 0, MaxText = 20,
})
local dealerGrid = makeGrid(dealerContent, 40)
local dealerEmpty = UIKit.label(dealerContent, "Nothing to sell... go dig up some memes!", {
	Size = UDim2.new(0.9, 0, 0, 30), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Grey, Stroke = 0,
})

local function refreshDealer()
	clear(dealerGrid)
	local entries = fetchInventory()
	dealerEmpty.Visible = #entries == 0
	for i, entry in ipairs(entries) do
		local value = ArtifactData.GetSellValue(entry.Artifact)
		local card = memeCard(dealerGrid, entry, i, "Sells for " .. ArtifactData.FormatMoney(value))
		local one = UIKit.button(card, "SELL", {Size = UDim2.new(0.5, -12, 0, 34), Position = UDim2.new(0, 8, 1, -8), AnchorPoint = Vector2.new(0, 1), Color = C.Sun})
		local all = UIKit.button(card, "ALL", {Size = UDim2.new(0.5, -12, 0, 34), Position = UDim2.new(1, -8, 1, -8), AnchorPoint = Vector2.new(1, 1), Color = C.Coral})
		one.MouseButton1Click:Connect(function()
			sellRemote:FireServer(entry.Artifact.Id, false)
		end)
		all.MouseButton1Click:Connect(function()
			sellRemote:FireServer(entry.Artifact.Id, true)
		end)
	end
end

openDealerRemote.OnClientEvent:Connect(function()
	refreshDealer()
	UIKit.open(dealerWindow)
end)

inventoryChangedRemote.OnClientEvent:Connect(function()
	if dealerWindow.Visible then refreshDealer() end
	if displayWindow.Visible then refreshDisplay() end
end)

---------------------------------------------------------------------
-- FLOOR ARROWS (only while you're inside a museum)
---------------------------------------------------------------------
local floorPanel = UIKit.panel(gui, {Size = UDim2.fromOffset(96, 196), Position = UDim2.fromOffset(18, 268), Color = C.Panel, Radius = 22, StrokeColor = C.Ink, Stroke = 3})
floorPanel.Visible = false
local upButton = UIKit.button(floorPanel, "▲", {Size = UDim2.fromOffset(72, 60), Position = UDim2.new(0.5, 0, 0, 10), AnchorPoint = Vector2.new(0.5, 0), Color = C.Sky, Radius = 16, MaxText = 30})
local floorLabel = UIKit.label(floorPanel, "FLOOR 1", {Size = UDim2.new(1, -12, 0, 22), Position = UDim2.new(0.5, 0, 0.5, 4), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Ink, Stroke = 0, MaxText = 18})
local upPrice = UIKit.label(floorPanel, "", {Size = UDim2.new(1, -8, 0, 16), Position = UDim2.new(0.5, 0, 0, 74), AnchorPoint = Vector2.new(0.5, 0), Color = C.Coral, Stroke = 0, MaxText = 14})
local downButton = UIKit.button(floorPanel, "▼", {Size = UDim2.fromOffset(72, 60), Position = UDim2.new(0.5, 0, 1, -10), AnchorPoint = Vector2.new(0.5, 1), Color = C.Violet, Radius = 16, MaxText = 30})
for _, b in ipairs({upButton, downButton}) do
	local arrow = b:FindFirstChild("Label")
	if arrow then arrow.Font = Enum.Font.GothamBlack end
end

local function currentMuseumFloor()
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end
	for _, museum in ipairs(museumsFolder:GetChildren()) do
		local floor = GameConfig.GetMuseumFloor(museum, root.Position)
		if floor then return museum, floor end
	end
	return nil
end

upButton.MouseButton1Click:Connect(function() floorRemote:FireServer(1) end)
downButton.MouseButton1Click:Connect(function() floorRemote:FireServer(-1) end)

task.spawn(function()
	local topFloor = #GameConfig.FloorPrices
	while true do
		local museum, floor = currentMuseumFloor()
		floorPanel.Visible = museum ~= nil
		if museum then
			local opened = string.split(museum:GetAttribute("UnlockedFloors") or "1", ",")
			local owned = museum:GetAttribute("OwnerUserId") == player.UserId
			local nextOpen = table.find(opened, tostring(floor + 1)) ~= nil
			floorLabel.Text = "FLOOR " .. floor
			upButton.Visible = floor < topFloor and (nextOpen or owned)
			downButton.Visible = floor > 1
			if upButton.Visible and not nextOpen then
				upPrice.Text = "🔒 " .. ArtifactData.FormatMoney(GameConfig.FloorPrices[floor + 1])
				upButton.BackgroundColor3 = C.Coral
			else
				upPrice.Text = ""
				upButton.BackgroundColor3 = C.Sky
			end
		end
		task.wait(0.25)
	end
end)
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "ShovelClient", "LocalScript", [=[
-- ShovelClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Shovel swing + dig animation, depth + zone meter, underground light,
-- Return to Surface button, and the Shovel Shop window (each world's shovels as cards
-- with 3D icons, stat bars and their depth rating).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local swingRemote = remotes:WaitForChild("DigSwing")
local digMessageRemote = remotes:WaitForChild("DigProgress")
local surfaceRemote = remotes:WaitForChild("ReturnToSurface")
local openShopRemote = remotes:WaitForChild("OpenShovelShop")
local buyShovelRemote = remotes:WaitForChild("BuyShovel")
local equipShovelRemote = remotes:WaitForChild("EquipShovel")
local shopMessageRemote = remotes:WaitForChild("ShopMessage")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local gui = UIKit.screen(player, "ShovelGui", 2)

---------------------------------------------------------------------
-- HINT MESSAGES (bubbly text above the hotbar)
---------------------------------------------------------------------
local hint = UIKit.panel(gui, {
	Size = UDim2.fromOffset(560, 46), Position = UDim2.new(0.5, 0, 1, -196), AnchorPoint = Vector2.new(0.5, 0),
	Color = C.Ink, Radius = 23, Stroke = 2.5, StrokeColor = C.Lilac, ShadeAmount = 0.2,
})
hint.BackgroundTransparency = 0.12
hint.Visible = false
local hintDot = UIKit.panel(hint, {Size = UDim2.fromOffset(14, 14), Position = UDim2.new(0, 16, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Color = C.Sun, Radius = 7, Stroke = false})
local hintText = UIKit.label(hint, "", {Size = UDim2.new(1, -56, 1, -14), Position = UDim2.new(0, 40, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
	Align = "Left", Color = C.White, Stroke = 0, MaxText = 22})

local hintToken = 0
local function showHint(text, color)
	hintToken += 1
	local myToken = hintToken
	hintText.Text = text
	hintDot.BackgroundColor3 = color or C.Sun
	hintText.TextColor3 = (color or C.Sun):Lerp(C.White, 0.55)
	hint.Visible = true
	UIKit.pop(hint, 0.7)
	task.delay(2.8, function()
		if hintToken == myToken then hint.Visible = false end
	end)
end

digMessageRemote.OnClientEvent:Connect(function(message, color)
	if typeof(message) == "string" then
		showHint(message, typeof(color) == "Color3" and color or nil)
	end
end)

---------------------------------------------------------------------
-- DEPTH GAUGE (slim tube on the right edge) + RETURN TO SURFACE + UNDERGROUND LIGHT
---------------------------------------------------------------------
local GAUGE_H = 230 -- height of the tube in pixels

local depthPanel = Instance.new("Frame") -- whole gauge; shown while holding a shovel or underground
depthPanel.BackgroundTransparency = 1
depthPanel.Size = UDim2.fromOffset(104, 360)
depthPanel.Position = UDim2.new(1, -12, 0.5, 0)
depthPanel.AnchorPoint = Vector2.new(1, 0.5)
depthPanel.Visible = false
depthPanel.Parent = gui
local gaugeScale = Instance.new("UIScale")
gaugeScale.Parent = depthPanel
local function fitScreen()
	gaugeScale.Scale = math.clamp(camera.ViewportSize.Y / 720, 0.65, 1)
end
camera:GetPropertyChangedSignal("ViewportSize"):Connect(fitScreen)
fitScreen()

-- depth number bubble
local depthBubble = UIKit.panel(depthPanel, {Size = UDim2.fromOffset(96, 42), Position = UDim2.new(0.5, 0, 0, 0), AnchorPoint = Vector2.new(0.5, 0), Color = C.Ink, Radius = 21, StrokeColor = C.Lilac})
depthBubble.BackgroundTransparency = 0.1
local depthLabel = UIKit.label(depthBubble, "0m", {Size = UDim2.new(1, -16, 0.7, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.White, Stroke = 0, MaxText = 26})

-- the tube, filled with one colored band per zone (thicker zones = taller bands)
local tube = UIKit.panel(depthPanel, {Size = UDim2.fromOffset(30, GAUGE_H), Position = UDim2.new(0.5, 8, 0, 50), AnchorPoint = Vector2.new(0.5, 0), Color = C.PanelTint, Radius = 15, Stroke = 3, StrokeColor = C.Ink, Shade = false})
tube.ClipsDescendants = true
local bands = Instance.new("Frame")
bands.BackgroundTransparency = 1
bands.Size = UDim2.fromScale(1, 1)
bands.Parent = tube
local tubeGloss = UIKit.panel(tube, {Size = UDim2.new(0, 6, 1, -16), Position = UDim2.new(0, 5, 0, 8), Color = C.White, Radius = 3, Stroke = false, Shade = false})
tubeGloss.BackgroundTransparency = 0.55
tubeGloss.ZIndex = 3

-- your position: a round marker that slides down the left side of the tube
local marker = UIKit.panel(depthPanel, {Size = UDim2.fromOffset(22, 22), Position = UDim2.new(0.5, -14, 0, 50), AnchorPoint = Vector2.new(1, 0.5), Color = C.Sun, Radius = 11, Stroke = 3})
marker.ZIndex = 4

-- your shovel's limit: a red line across the tube with a small tag
local limitLine = UIKit.panel(depthPanel, {Size = UDim2.fromOffset(40, 6), Position = UDim2.new(0.5, 8, 0, 50), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Coral, Radius = 3, Stroke = 2, Shade = false})
limitLine.ZIndex = 4
local shovelLabel = UIKit.label(depthPanel, "", {Size = UDim2.fromOffset(52, 16), Position = UDim2.new(0.5, 30, 0, 50), AnchorPoint = Vector2.new(0, 0.5), Align = "Left", Color = C.Coral, Stroke = 2})
shovelLabel.ZIndex = 4

-- zone name pill under the tube
local zonePill = UIKit.panel(depthPanel, {Size = UDim2.fromOffset(104, 28), Position = UDim2.new(0.5, 0, 0, 50 + GAUGE_H + 8), AnchorPoint = Vector2.new(0.5, 0), Color = C.Sun, Radius = 14})
local zoneLabel = UIKit.label(zonePill, "", {Size = UDim2.new(1, -12, 0.72, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2, StrokeColor = C.Ink, MaxText = 16})

-- small "surface" button under everything, only while underground
local surfaceButton = UIKit.button(depthPanel, "SURFACE", {
	Size = UDim2.fromOffset(104, 40), Position = UDim2.new(0.5, 0, 0, 50 + GAUGE_H + 44), AnchorPoint = Vector2.new(0.5, 0), Color = C.Sky, Radius = 20,
})
surfaceButton.Visible = false
surfaceButton.MouseButton1Click:Connect(function()
	surfaceRemote:FireServer()
end)

local headlamp -- PointLight on our character when underground
local equippedDef -- the shovel currently in hand
local gaugeWorld -- world the bands were drawn for

local function currentWorld()
	return GameConfig.GetWorld(player:GetAttribute("CurrentWorld") or 1) or GameConfig.Worlds[1]
end

local function drawBands(world)
	gaugeWorld = world
	bands:ClearAllChildren()
	local total = -world.Zones[#world.Zones].Bottom
	for i, zone in ipairs(world.Zones) do
		local top = -zone.Top / total
		local height = (zone.Top - zone.Bottom) / total
		local band = Instance.new("Frame")
		band.BorderSizePixel = 0
		band.BackgroundColor3 = zone.Color
		band.Position = UDim2.fromScale(0, top)
		band.Size = UDim2.fromScale(1, height)
		band.Parent = bands
		if i > 1 then
			local seam = Instance.new("Frame")
			seam.BorderSizePixel = 0
			seam.BackgroundColor3 = C.Ink
			seam.Size = UDim2.new(1, 0, 0, 2)
			seam.Parent = band
		end
	end
end

-- y position (in gauge pixels) of a depth
local function gaugeY(world, depth)
	local total = -world.Zones[#world.Zones].Bottom
	return 50 + math.clamp(depth / total, 0, 1) * GAUGE_H
end

task.spawn(function()
	while true do
		task.wait(0.15)
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root then
			local world = currentWorld()
			if world ~= gaugeWorld then drawBands(world) end
			local feetY = root.Position.Y - 3
			local depth = math.max(0, math.floor(world.Origin.Y - feetY + 0.5))
			local offset = root.Position - world.Origin
			local inPit = Vector3.new(offset.X, 0, offset.Z).Magnitude < world.PitRadius + 7

			local _, zone = GameConfig.GetZoneAt(world, feetY)
			zone = zone or {Name = "Bedrock", Color = Color3.fromRGB(150, 150, 160)}
			depthLabel.Text = depth .. "m"
			zoneLabel.Text = string.upper(zone.Name)
			zonePill.BackgroundColor3 = zone.Color
			marker.Position = UDim2.new(0.5, -14, 0, gaugeY(world, depth))

			if equippedDef and equippedDef.World == world.Id then
				local maxDepth = -world.Zones[equippedDef.MaxZone].Bottom
				limitLine.Visible = equippedDef.MaxZone < #world.Zones
				shovelLabel.Visible = limitLine.Visible
				limitLine.Position = UDim2.new(0.5, 8, 0, gaugeY(world, maxDepth))
				shovelLabel.Position = UDim2.new(0.5, 30, 0, gaugeY(world, maxDepth))
				shovelLabel.Text = "MAX"
				-- marker turns red when you're right at your shovel's limit
				marker.BackgroundColor3 = (limitLine.Visible and maxDepth - depth <= 8) and C.Coral or C.Sun
			else
				limitLine.Visible = false
				shovelLabel.Visible = false
				marker.BackgroundColor3 = C.Sun
			end

			depthPanel.Visible = equippedDef ~= nil or (inPit and depth > 4)
			surfaceButton.Visible = inPit and depth > 4

			-- small light so you can see underground
			if depth > 4 then
				if not headlamp or headlamp.Parent ~= root then
					headlamp = Instance.new("PointLight")
					headlamp.Color = Color3.fromRGB(255, 235, 200)
					headlamp.Range = 22
					headlamp.Brightness = 1.3
					headlamp.Shadows = true
					headlamp.Parent = root
				end
				headlamp.Enabled = true
			elseif headlamp then
				headlamp.Enabled = false
			end
		end
	end
end)

---------------------------------------------------------------------
-- SHOVEL POSE + DIG ANIMATION (for every player's character on this screen)
-- The real tool is hidden on this screen. A copy of the shovel is placed exactly where the
-- pose wants it every frame, the right hand grips its shaft with IK (position AND rotation,
-- so the fist really wraps the handle like a normal Roblox tool), and the torso leans and
-- twists with the swing. The swing is short and snappy with a tiny freeze on impact.
-- The blade is never allowed to sink into the ground.
-- Other players' swings arrive through ShovelSwingFx, so everyone sees everyone dig.
---------------------------------------------------------------------
local Debris = game:GetService("Debris")
local ShovelModels = require(ReplicatedStorage:WaitForChild("PickaxeModels"))
local swingFxRemote = remotes:WaitForChild("ShovelSwingFx")

-- TWO-HANDED PICKAXE POSE. Values are relative to the HumanoidRootPart (+X right, +Y up,
-- -Z forward). The right hand holds the bottom of the handle, the left hand holds it a bit
-- higher up (both by IK, so the grip always matches the pickaxe).
-- Hand  = where the right hand holds the handle (studs)
-- Tilt  = handle pitch, degrees: 0 = head pointing straight down, 90 = head pointing forward,
--         180 = head straight up, 225 = head up and back over the shoulder
-- Turn  = yaw (+ = to the left), Roll = sideways lean of the pickaxe (+ = head leans left)
-- Lean  = torso pitch (+ = bend forward), Twist = torso yaw (+ = turn left)
-- Bend  = torso side bend (+ = lean left), Look = head pitch (+ = look down)
local CHANNELS = {"Tilt", "Turn", "Roll", "Lean", "Twist", "Bend", "Look"}
-- ready stance: pickaxe held low and across the body, head out to the side (clear of the face)
local IDLE = {Hand = Vector3.new(0.35, -0.15, -0.8), Tilt = 105, Turn = 30, Roll = 15, Lean = 3, Twist = 0, Bend = 0, Look = 2}

-- easing curves: how each part of the swing speeds up and slows down
local function easeInOutSine(u) return -(math.cos(math.pi * u) - 1) / 2 end
local function easeOutCubic(u) return 1 - (1 - u) ^ 3 end
local function easeOutSine(u) return math.sin(u * math.pi / 2) end
local function easeInQuad(u) return u * u end
local function easeOutBack(u)
	local c1 = 1.9
	return 1 + (c1 + 1) * (u - 1) ^ 3 + c1 * (u - 1) ^ 2
end
local function easeInOutCubic(u) return u < 0.5 and 4 * u * u * u or 1 - (-2 * u + 2) ^ 3 / 2 end

-- The swing, key by key. Ease = how the motion INTO that key is timed.
local SWING = {
	{T = 0.00, Pose = IDLE},
	-- load: a little dip and a cock of the wrists before the big lift
	{T = 0.10, Ease = easeInOutSine, Pose = {Hand = Vector3.new(0.45, -0.3, -0.7), Tilt = 112, Turn = 20, Roll = 4, Lean = 7, Twist = -8, Bend = 0, Look = 4}},
	-- raise: the pickaxe swings up past the RIGHT shoulder, not across the face
	{T = 0.22, Ease = easeInOutSine, Pose = {Hand = Vector3.new(0.8, 0.5, -0.5), Tilt = 165, Turn = -6, Roll = -40, Lean = 2, Twist = -26, Bend = -4, Look = -4}},
	-- top: heaved up over the right shoulder, slowing as it gets there
	{T = 0.34, Ease = easeOutCubic, Pose = {Hand = Vector3.new(1.0, 1.45, 0.0), Tilt = 215, Turn = -12, Roll = -30, Lean = -6, Twist = -44, Bend = -6, Look = -12}},
	-- hang: the pickaxe floats at the very top for a beat, stretching back
	{T = 0.42, Ease = easeOutSine, Pose = {Hand = Vector3.new(1.02, 1.52, 0.06), Tilt = 220, Turn = -13, Roll = -33, Lean = -8, Twist = -46, Bend = -7, Look = -14}},
	-- swing-over: comes forward beside the head (not over it)
	{T = 0.48, Ease = easeInQuad, Pose = {Hand = Vector3.new(0.7, 1.05, -0.8), Tilt = 150, Turn = -6, Roll = -22, Lean = 10, Twist = -34, Bend = 0, Look = 8}},
	-- strike: accelerates all the way down into the ground
	{T = 0.52, Ease = easeInQuad, Pose = {Hand = Vector3.new(0.1, -0.1, -1.1), Tilt = 78, Turn = 6, Roll = 0, Lean = 28, Twist = -18, Bend = 5, Look = 22}},
	-- rebound: kicks back up out of the dirt (with a little overshoot)
	{T = 0.64, Ease = easeOutBack, Pose = {Hand = Vector3.new(0.2, 0.3, -1.0), Tilt = 102, Turn = 4, Roll = 4, Lean = 16, Twist = -10, Bend = 3, Look = 12}},
	-- settle back into the ready stance
	{T = 1.00, Ease = easeInOutCubic, Pose = IDLE},
}
local STRIKE_TIME = 0.52
local HIT_STOP = 0.06 -- the pose freezes this long on impact, which makes hits feel heavy
local TRAIL_FROM, TRAIL_TO = 0.43, 0.62 -- the head leaves a swoosh trail during the down-swing
local WOBBLE = {Degrees = 7, Decay = 9, Speed = 38} -- the handle vibrates after the impact

-- tool axes when upright: grip end (+Z) points up (head down), pick arms (+Y) point forward
local UPRIGHT = CFrame.fromMatrix(Vector3.zero, Vector3.xAxis, -Vector3.zAxis, Vector3.yAxis)

-- smooth Catmull-Rom curve through the swing keyframes (never jerky)
local function catmull(p0, p1, p2, p3, u)
	local u2, u3 = u * u, u * u * u
	return (p1 * 2 + (p2 - p0) * u + (p0 * 2 - p1 * 5 + p2 * 4 - p3) * u2 + (p1 * 3 - p0 - p2 * 3 + p3) * u3) * 0.5
end

local function samplePose(t)
	t = math.clamp(t, 0, 1)
	local i = 1
	while i < #SWING - 1 and t > SWING[i + 1].T do i += 1 end
	local k0, k1, k2, k3 = SWING[math.max(i - 1, 1)], SWING[i], SWING[i + 1], SWING[math.min(i + 2, #SWING)]
	local u = (t - k1.T) / (k2.T - k1.T)
	u = k2.Ease and k2.Ease(u) or u
	local pose = {Hand = catmull(k0.Pose.Hand, k1.Pose.Hand, k2.Pose.Hand, k3.Pose.Hand, u)}
	for _, c in ipairs(CHANNELS) do
		pose[c] = catmull(k0.Pose[c], k1.Pose[c], k2.Pose[c], k3.Pose[c], u)
	end
	return pose
end

-- the ready stance is never frozen: breathing, a slow weight shift, and a bob while walking
local function idlePose(clock, moving)
	local breathe = math.sin(clock * 2.2)
	local sway = math.sin(clock * 0.8)
	local step = math.sin(clock * 11) * moving
	return {
		Hand = IDLE.Hand + Vector3.new(sway * 0.05, breathe * 0.04 + math.abs(step) * 0.08, 0),
		Tilt = IDLE.Tilt + breathe * 2 + step * 4, Turn = IDLE.Turn + sway * 2,
		Roll = IDLE.Roll + sway * 3, Lean = IDLE.Lean + breathe * 0.6 + moving * 5,
		Twist = IDLE.Twist + sway * 2, Bend = sway * 1.5 + step * 1.2, Look = -breathe * 2,
	}
end

local rigs = {} -- [character] = rig
local puppetFolder = Instance.new("Folder")
puppetFolder.Name = "ShovelPuppets"
puppetFolder.Parent = workspace

local function newAttachment(parent, name)
	local a = Instance.new("Attachment")
	a.Name = name
	a.Parent = parent
	return a
end

local function newArmIK(humanoid, name, upper, hand, target, pole)
	local ik = Instance.new("IKControl")
	ik.Name = name
	ik.Type = Enum.IKControlType.Position
	ik.ChainRoot = upper
	ik.EndEffector = hand
	ik.Target = target
	ik.Pole = pole
	ik.Weight = 1
	ik.SmoothTime = 0
	ik.Parent = humanoid
	return ik
end

local function destroyRig(character)
	local rig = rigs[character]
	if not rig then return end
	rigs[character] = nil
	for _, thing in ipairs(rig.Cleanup) do
		thing:Destroy()
	end
	if rig.Waist and rig.Waist.Parent then rig.Waist.C0 = rig.WaistC0 end
	if rig.Neck and rig.Neck.Parent then rig.Neck.C0 = rig.NeckC0 end
	if rig.Hips and rig.Hips.Parent then rig.Hips.C0 = rig.HipsC0 end
	if rig.Tool then
		for _, d in ipairs(rig.Tool:GetDescendants()) do
			if d:IsA("BasePart") then d.LocalTransparencyModifier = 0 end
		end
	end
end

local function createRig(character, tool)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	local upperTorso = character:FindFirstChild("UpperTorso")
	local parts = {
		RU = character:FindFirstChild("RightUpperArm"), RH = character:FindFirstChild("RightHand"),
		LU = character:FindFirstChild("LeftUpperArm"), LH = character:FindFirstChild("LeftHand"),
	}
	-- the pose needs an R15 body; R6 characters keep Roblox's default hold
	if not (humanoid and root and upperTorso and parts.RU and parts.RH) then return nil end
	local def = GameConfig.GetShovel(tool:GetAttribute("ShovelId"))
	if not def then return nil end

	-- the copy of the shovel we pose every frame
	local model = ShovelModels(def)
	local handle = model:FindFirstChild("Handle")
	local puppet = {}
	local bladePart
	local tipZ = 0
	for _, piece in ipairs(model:GetChildren()) do
		if piece:IsA("BasePart") and piece ~= handle then
			for _, c in ipairs(piece:GetChildren()) do
				if c:IsA("WeldConstraint") then c:Destroy() end
			end
			piece.Anchored = true
			piece.CanCollide = false
			piece.CanQuery = false
			piece.CanTouch = false
			-- crystal shovels: orbit parts spin around OrbitCenter (along the shaft)
			table.insert(puppet, {Part = piece, Rel = handle.CFrame:ToObjectSpace(piece.CFrame),
				Center = piece:GetAttribute("OrbitCenter"), Speed = piece:GetAttribute("OrbitSpeed")})
			if piece.Name == "Blade" or piece.Name == "DrillTip" then bladePart = piece end
			-- lowest point of the shovel along its shaft (used to keep the blade out of the ground)
			local rel = handle.CFrame:ToObjectSpace(piece.CFrame)
			local h = piece.Size / 2
			for _, corner in ipairs({Vector3.new(h.X, h.Y, h.Z), Vector3.new(-h.X, h.Y, h.Z), Vector3.new(h.X, -h.Y, h.Z), Vector3.new(-h.X, -h.Y, h.Z),
				Vector3.new(h.X, h.Y, -h.Z), Vector3.new(-h.X, h.Y, -h.Z), Vector3.new(h.X, -h.Y, -h.Z), Vector3.new(-h.X, -h.Y, -h.Z)}) do
				tipZ = math.min(tipZ, (rel * corner).Z)
			end
		end
	end
	local holder = Instance.new("Model")
	holder.Name = character.Name .. "_Shovel"
	for _, p in ipairs(puppet) do p.Part.Parent = holder end
	holder.Parent = puppetFolder
	model:Destroy()

	-- hide the real tool on this screen (it still does the digging)
	for _, d in ipairs(tool:GetDescendants()) do
		if d:IsA("BasePart") then d.LocalTransparencyModifier = 1 end
	end

	local rightTarget = newAttachment(root, "ShovelRightHand")
	-- pole keeps the elbow bending down and out, like a relaxed arm
	local rightPole = newAttachment(root, "ShovelRightElbow")
	rightPole.Position = Vector3.new(2.4, -1.4, 0.8)
	local rightIK = newArmIK(humanoid, "ShovelRightArm", parts.RU, parts.RH, rightTarget, rightPole)
	-- match the hand's rotation too, so the fist closes around the shaft
	rightIK.Type = Enum.IKControlType.Transform
	local gripAttachment = parts.RH:FindFirstChild("RightGripAttachment")
	-- the left hand holds the handle higher up (two-handed grip)
	local leftTarget = newAttachment(root, "ShovelLeftHand")
	local leftPole = newAttachment(root, "ShovelLeftElbow")
	leftPole.Position = Vector3.new(-2.2, -1.2, 0.6)
	local leftIK = parts.LU and parts.LH and newArmIK(humanoid, "ShovelLeftArm", parts.LU, parts.LH, leftTarget, leftPole)

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.IgnoreWater = true
	local ignore = {puppetFolder}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character then table.insert(ignore, plr.Character) end
	end
	rayParams.FilterDescendantsInstances = ignore

	-- a swoosh trail from one arm tip of the head to the other (on during the down-swing)
	local trail
	if bladePart then
		local reach = bladePart.Size.Y * 1.7
		local a0 = Instance.new("Attachment")
		a0.Position = bladePart.CFrame:PointToObjectSpace(bladePart.Position + Vector3.new(0, reach, 0))
		a0.Parent = bladePart
		local a1 = Instance.new("Attachment")
		a1.Position = bladePart.CFrame:PointToObjectSpace(bladePart.Position - Vector3.new(0, reach, 0))
		a1.Parent = bladePart
		local gem = holder:FindFirstChild("HeadGem")
		local glow = gem and gem.Color or Color3.new(1, 1, 1)
		trail = Instance.new("Trail")
		trail.Attachment0 = a0
		trail.Attachment1 = a1
		trail.Lifetime = 0.16
		trail.MinLength = 0.05
		trail.FaceCamera = true
		trail.LightEmission = 0.5
		trail.Color = ColorSequence.new(Color3.new(1, 1, 1), glow)
		trail.Transparency = NumberSequence.new(0.35, 1)
		trail.WidthScale = NumberSequence.new(1, 0.3)
		trail.Enabled = false
		trail.Parent = bladePart
	end

	local waist = upperTorso:FindFirstChild("Waist")
	local head = character:FindFirstChild("Head")
	local neck = head and head:FindFirstChild("Neck")
	local lowerTorso = character:FindFirstChild("LowerTorso")
	local hips = lowerTorso and lowerTorso:FindFirstChild("Root")
	local rig = {
		Tool = tool, Root = root, Puppet = puppet, Blade = bladePart or (puppet[#puppet] and puppet[#puppet].Part),
		HoldZ = (tool:GetAttribute("RightHoldZ") or tool:GetAttribute("TopHoldZ") or 1.1) - 0.12, -- right hand near the end
		LeftHoldZ = tool:GetAttribute("LeftHoldZ") or 0.4, -- left hand higher up the handle
		TipZ = tipZ,
		RightTarget = rightTarget,
		LeftTarget = leftIK and leftTarget or nil,
		Waist = waist and waist:IsA("Motor6D") and waist or nil,
		WaistC0 = waist and waist:IsA("Motor6D") and waist.C0 or nil,
		Neck = neck and neck:IsA("Motor6D") and neck or nil,
		NeckC0 = neck and neck:IsA("Motor6D") and neck.C0 or nil,
		Hips = hips and hips:IsA("Motor6D") and hips or nil,
		HipsC0 = hips and hips:IsA("Motor6D") and hips.C0 or nil,
		Humanoid = humanoid, Trail = trail, ImpactAt = nil, Smooth = nil,
		SwingStart = nil, SwingLength = 0.4, Struck = true,
		GripOffset = gripAttachment and gripAttachment.CFrame or CFrame.new(0, -0.15, 0) * CFrame.Angles(math.rad(-90), 0, 0),
		RayParams = rayParams,
		Cleanup = {holder, rightTarget, rightPole, rightIK, leftTarget, leftPole, leftIK or nil},
	}
	rigs[character] = rig
	return rig
end

-- throws a few little dirt clumps off the blade
local function tossDirt(position, color)
	for i = 1, 7 do
		local clump = Instance.new("Part")
		clump.Shape = Enum.PartType.Ball
		clump.Size = Vector3.one * (0.35 + math.random() * 0.3)
		clump.Color = color
		clump.Material = Enum.Material.SmoothPlastic
		clump.CanCollide = false
		clump.CanQuery = false
		clump.CanTouch = false
		clump.CastShadow = false
		clump.CFrame = CFrame.new(position + Vector3.new(math.random() - 0.5, 0, math.random() - 0.5) * 0.6)
		clump.AssemblyLinearVelocity = Vector3.new(math.random() * 12 - 6, 12 + math.random() * 10, math.random() * 12 - 6)
		clump.Parent = puppetFolder
		Debris:AddItem(clump, 1.1 + i * 0.05)
	end
end

local function dirtColorAt(position)
	local world = GameConfig.GetWorldAt(position)
	local _, zone = GameConfig.GetZoneAt(world, position.Y - 3)
	return zone and zone.Color or Color3.fromRGB(150, 110, 80)
end

local function startSwing(character, length)
	local rig = character and rigs[character]
	if not rig then return end
	rig.SwingStart = os.clock()
	rig.SwingLength = length
	rig.Struck = false
end

local function poseRig(character, rig, clock, dt)
	local moving = rig.Humanoid and math.clamp(rig.Humanoid.MoveDirection.Magnitude, 0, 1) or 0
	local target
	local trailOn = false
	if rig.SwingStart then
		-- hit-stop: time stands still for a moment right at the impact
		local elapsed = clock - rig.SwingStart
		local strikeAt = rig.SwingLength * STRIKE_TIME
		if elapsed > strikeAt then
			elapsed -= math.min(elapsed - strikeAt, HIT_STOP)
		end
		local t = elapsed / rig.SwingLength
		if t >= 1 then
			rig.SwingStart = nil
			target = idlePose(clock, moving)
		else
			target = samplePose(t)
			trailOn = t > TRAIL_FROM and t < TRAIL_TO
			if not rig.Struck and t >= STRIKE_TIME then
				rig.Struck = true
				rig.ImpactAt = clock
				if rig.Blade then
					tossDirt(rig.Blade.Position, dirtColorAt(rig.Root.Position))
				end
			end
		end
	else
		target = idlePose(clock, moving)
	end
	if rig.Trail then rig.Trail.Enabled = trailOn end

	-- impact wobble: the handle rings for a moment after the head bites the ground
	if rig.ImpactAt then
		local since = clock - rig.ImpactAt - HIT_STOP
		if since > 0 and since < 0.6 then
			local ring = math.exp(-WOBBLE.Decay * since) * math.sin(WOBBLE.Speed * since)
			target.Tilt += ring * WOBBLE.Degrees
			target.Hand += Vector3.new(0, ring * 0.06, 0)
		end
	end

	-- smoothing: every channel eases toward its target, so switching between idle and
	-- swinging (or starting a new swing mid-way) never snaps. Swings stay crisp.
	local smooth = rig.Smooth
	if not smooth then
		smooth = table.clone(target)
		rig.Smooth = smooth
	end
	local alpha = 1 - math.exp(-(rig.SwingStart and 45 or 12) * (dt or 1 / 60))
	smooth.Hand = smooth.Hand:Lerp(target.Hand, alpha)
	for _, c in ipairs(CHANNELS) do
		smooth[c] += ((target[c] or 0) - (smooth[c] or 0)) * alpha
	end
	local pose = smooth

	-- where the shovel goes (in root space): rotate the upright shovel by tilt and turn,
	-- then slide it along its shaft so the grip sits exactly in the hand
	local rotation = CFrame.Angles(0, math.rad(pose.Turn), 0) * CFrame.Angles(0, 0, math.rad(pose.Roll or 0))
		* CFrame.Angles(math.rad(pose.Tilt), 0, 0) * UPRIGHT
	local up = rotation.ZVector
	local hand = pose.Hand
	local origin = hand - up * rig.HoldZ
	local shovelCF = rig.Root.CFrame * CFrame.new(origin) * rotation

	-- keep the blade out of the ground: if its lowest point is below the surface under it,
	-- lift the shovel (and the hand holding it) just enough
	-- (the ray starts at hand height above the tip, which is always in open air, even in tunnels)
	local tip = (shovelCF * CFrame.new(0, 0, rig.TipZ)).Position
	local handY = (rig.Root.CFrame * hand).Y
	local startY = math.max(handY, tip.Y + 0.5)
	local hit = workspace:Raycast(Vector3.new(tip.X, startY, tip.Z), Vector3.new(0, -(startY - tip.Y) - 3, 0), rig.RayParams)
	if hit then
		local lift = (hit.Position.Y + 0.08) - tip.Y
		if lift > 0 then
			local liftLocal = rig.Root.CFrame:VectorToObjectSpace(Vector3.new(0, lift, 0))
			hand += liftLocal
			origin += liftLocal
			shovelCF = rig.Root.CFrame * CFrame.new(origin) * rotation
		end
	end

	local parts, cframes = {}, {}
	for i, p in ipairs(rig.Puppet) do
		parts[i] = p.Part
		local rel = p.Rel
		if p.Center and p.Speed then
			local pivot = CFrame.new(p.Center)
			rel = pivot * CFrame.Angles(0, 0, clock * p.Speed) * pivot:Inverse() * rel
		end
		cframes[i] = shovelCF * rel
	end
	workspace:BulkMoveTo(parts, cframes, Enum.BulkMoveMode.FireCFrameChanged)

	-- the hand goes exactly where a normal Roblox tool grip would put it on this shaft:
	-- handle = hand * gripAttachment * grip^-1, so hand = handle * grip * gripAttachment^-1
	local handCF = shovelCF * CFrame.new(0, 0, rig.HoldZ) * rig.GripOffset:Inverse()
	rig.RightTarget.CFrame = rig.Root.CFrame:ToObjectSpace(handCF)
	if rig.LeftTarget then
		rig.LeftTarget.Position = rig.Root.CFrame:PointToObjectSpace((shovelCF * CFrame.new(0, 0, rig.LeftHoldZ)).Position)
	end
	-- whole body: the torso bends and twists with the swing, the hips counter-turn a little,
	-- and the head follows the pickaxe (looks up at the top, down at the impact)
	if rig.Waist then
		rig.Waist.C0 = rig.WaistC0 * CFrame.Angles(math.rad(-pose.Lean), math.rad(pose.Twist), math.rad(pose.Bend))
	end
	if rig.Hips then
		rig.Hips.C0 = rig.HipsC0 * CFrame.Angles(0, math.rad(-pose.Twist * 0.35), 0)
	end
	if rig.Neck then
		rig.Neck.C0 = rig.NeckC0 * CFrame.Angles(math.rad(-pose.Look), math.rad(-pose.Twist * 0.4), 0)
	end
end

RunService.RenderStepped:Connect(function(dt)
	local clock = os.clock()
	-- find every character holding a shovel; build or tear down rigs to match
	for _, plr in ipairs(Players:GetPlayers()) do
		local character = plr.Character
		if character then
			local tool = character:FindFirstChildOfClass("Tool")
			if tool and not tool:GetAttribute("ShovelId") then tool = nil end
			local rig = rigs[character]
			if rig and rig.Tool ~= tool then
				destroyRig(character)
				rig = nil
			end
			if tool and not rig then
				rig = createRig(character, tool)
			end
		end
	end
	for character, rig in pairs(rigs) do
		if not character.Parent or not rig.Root.Parent then
			destroyRig(character)
		else
			poseRig(character, rig, clock, dt)
		end
	end
end)

swingFxRemote.OnClientEvent:Connect(function(otherPlayer, length)
	if typeof(otherPlayer) == "Instance" and otherPlayer:IsA("Player") and otherPlayer ~= player and typeof(length) == "number" then
		startSwing((otherPlayer :: Player).Character, math.clamp(length, 0.3, 1))
	end
end)

---------------------------------------------------------------------
-- DIG JUICE: screen shake, combo counter, sounds, bounce feedback
---------------------------------------------------------------------
local digHitRemote = remotes:WaitForChild("DigHit")

local function playSound(id, volume, pitch)
	if not id or id == "" then return end
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Volume = volume or 0.6
	sound.PlaybackSpeed = pitch or 1
	sound.Parent = camera
	sound:Play()
	Debris:AddItem(sound, 3)
end

-- short, punchy camera shake (strength in studs)
local shakeUntil, shakeStrength = 0, 0
local function shake(strength, duration)
	shakeStrength = math.max(shakeStrength, strength)
	shakeUntil = math.max(shakeUntil, os.clock() + duration)
end
RunService:BindToRenderStep("DigShake", Enum.RenderPriority.Camera.Value + 1, function()
	local left = shakeUntil - os.clock()
	if left <= 0 then
		shakeStrength = 0
		return
	end
	local s = shakeStrength * math.clamp(left / 0.15, 0, 1)
	camera.CFrame = camera.CFrame * CFrame.new((math.random() - 0.5) * s, (math.random() - 0.5) * s, 0)
		* CFrame.Angles(0, 0, math.rad((math.random() - 0.5) * s * 6))
end)

-- combo counter: pops up next to the hotbar while you keep digging
local comboLabel = UIKit.label(gui, "", {
	Size = UDim2.fromOffset(300, 44), Position = UDim2.new(0.5, 60, 1, -250), AnchorPoint = Vector2.new(0, 0),
	Align = "Left", Color = C.Sun, Stroke = 3.5, MaxText = 34,
})
comboLabel.Rotation = -6
comboLabel.Visible = false
local comboToken = 0
local COMBO_COLORS = {C.White, C.Sun, C.Sun, C.Mint, C.Mint, C.Sky, C.Sky, C.Lilac, C.Coral, C.Coral}

digHitRemote.OnClientEvent:Connect(function(info)
	if typeof(info) ~= "table" then return end
	if info.Bounced then
		shake(0.35, 0.18)
		playSound(GameConfig.Sounds.Clang, 0.7)
		comboLabel.Visible = false
		return
	end
	local combo = tonumber(info.Combo) or 1
	shake(0.12 + combo * 0.012, 0.12)
	playSound(GameConfig.Sounds.Dig, 0.5, 0.9 + math.random() * 0.2 + combo * 0.02)
	if typeof(info.Position) == "Vector3" and typeof(info.Color) == "Color3" then
		tossDirt(info.Position + Vector3.new(0, 1.5, 0), info.Color)
	end
	if combo >= 2 then
		comboToken += 1
		local myToken = comboToken
		comboLabel.Text = "COMBO x" .. combo .. "  +" .. (combo - 1) * 4 .. "% luck"
		comboLabel.TextColor3 = COMBO_COLORS[math.clamp(combo, 1, #COMBO_COLORS)]
		comboLabel.Visible = true
		UIKit.pop(comboLabel, 1.35)
		playSound(GameConfig.Sounds.Combo, 0.35, 0.8 + combo * 0.06)
		task.delay(1.5, function()
			if comboToken == myToken then comboLabel.Visible = false end
		end)
	end
end)

---------------------------------------------------------------------
-- SWINGING: click to dig, or hold the button to keep digging
---------------------------------------------------------------------
local lastSwing = 0
local holding = false

local function trySwing(def)
	local now = os.clock()
	if now - lastSwing < def.Cooldown then return end
	lastSwing = now

	local length = math.clamp(def.Cooldown, 0.3, 0.5) -- overhead two-handed swing
	startSwing(player.Character, length)

	-- the dig happens exactly when the blade hits the ground
	local target = mouse.Hit and mouse.Hit.Position
	task.delay(length * STRIKE_TIME, function()
		swingRemote:FireServer(target, length)
	end)
end

local function onToolEquipped(tool)
	local def = GameConfig.GetShovel(tool:GetAttribute("ShovelId")) or GameConfig.Shovels[1]
	equippedDef = def
	depthPanel.Visible = true

	local activatedConn = tool.Activated:Connect(function()
		holding = true
		trySwing(def)
	end)
	local deactivatedConn = tool.Deactivated:Connect(function()
		holding = false
	end)
	-- while the button is held, dig again as soon as the shovel is ready
	local holdConn = RunService.Heartbeat:Connect(function()
		if holding and tool.Parent == player.Character then
			trySwing(def)
		end
	end)

	tool.Unequipped:Once(function()
		holding = false
		activatedConn:Disconnect()
		deactivatedConn:Disconnect()
		holdConn:Disconnect()
		if equippedDef == def then equippedDef = nil end
	end)
end

local function watchCharacter(character)
	character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") and child:GetAttribute("ShovelId") then
			onToolEquipped(child)
		end
	end)
end

player.CharacterAdded:Connect(watchCharacter)
if player.Character then
	watchCharacter(player.Character)
end

---------------------------------------------------------------------
-- SHOVEL SHOP WINDOW
---------------------------------------------------------------------
local window, content = UIKit.window(gui, "PICKAXE SHOP", UDim2.fromOffset(780, 580), C.Violet, "⛏️")

local moneyTag = UIKit.panel(content, {Size = UDim2.fromOffset(180, 38), Position = UDim2.new(1, 0, 0, 0), AnchorPoint = Vector2.new(1, 0), Color = C.Money, Radius = 19})
local moneyLabel = UIKit.label(moneyTag, "", {Size = UDim2.new(1, -24, 0.72, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2.5, StrokeColor = UIKit.shadeColor(C.Money, 0.6), MaxText = 24})
local worldLabel = UIKit.label(content, "", {Size = UDim2.new(1, -210, 0, 28), Position = UDim2.fromOffset(4, 5), Align = "Left", Color = C.Violet, Stroke = 0, MaxText = 24})

local listHolder = Instance.new("Frame")
listHolder.BackgroundTransparency = 1
listHolder.Size = UDim2.new(1, 0, 1, -48)
listHolder.Position = UDim2.fromOffset(0, 46)
listHolder.Parent = content
local list = UIKit.list(listHolder, 10)

local shopWorld = GameConfig.Worlds[1] -- which world's shop is open
local cards = {} -- [shovelId] = button

-- the best value of each stat in this world, so the bars fill relative to the top shovel
local function maxStat(world, key)
	local m = 0
	for _, def in ipairs(world.Shovels) do m = math.max(m, def[key]) end
	return m
end

local function buildCards(world)
	for _, child in ipairs(list:GetChildren()) do
		if child:IsA("GuiObject") then child:Destroy() end
	end
	cards = {}
	worldLabel.Text = "🌍  " .. world.Name
	local maxFind, maxLuck, maxPower = maxStat(world, "FindChance"), maxStat(world, "Luck"), maxStat(world, "Power")
	local minCooldown = math.huge
	for _, def in ipairs(world.Shovels) do minCooldown = math.min(minCooldown, def.Cooldown) end

	for i, def in ipairs(world.Shovels) do
		local zone = world.Zones[def.MaxZone]
		local card = UIKit.panel(list, {Size = UDim2.new(1, -6, 0, 132), Color = C.White, Radius = 20, ShadeAmount = 0.06})
		card.LayoutOrder = i
		-- icon on a colored plate (plate color = the deepest zone it reaches)
		local plate = UIKit.panel(card, {Size = UDim2.fromOffset(108, 108), Position = UDim2.new(0, 12, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Color = zone.Color, Radius = 18, ShadeAmount = 0.2})
		UIKit.shovelIcon(plate, def, {Size = UDim2.fromScale(1, 1)})
		UIKit.label(card, def.Name, {Size = UDim2.new(0.52, -138, 0, 28), Position = UDim2.fromOffset(134, 10), Align = "Left", Color = C.Ink, Stroke = 0, MaxText = 24})
		UIKit.label(card, def.Description, {Size = UDim2.new(0.52, -138, 0, 40), Position = UDim2.fromOffset(134, 40), Align = "Left", VAlign = "Top", Color = C.Grey, Stroke = 0, Font = UIKit.BodyFont, TextSize = 14})
		local zoneTag = UIKit.panel(card, {Size = UDim2.fromOffset(200, 26), Position = UDim2.fromOffset(134, 92), Color = zone.Color, Radius = 13})
		UIKit.label(zoneTag, "⬇ " .. -zone.Bottom .. "m  •  " .. string.upper(zone.Name), {Size = UDim2.new(1, -14, 0.74, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2, StrokeColor = C.Ink, MaxText = 16})

		local statsBox = Instance.new("Frame")
		statsBox.BackgroundTransparency = 1
		statsBox.Size = UDim2.new(0.28, 0, 0, 82)
		statsBox.Position = UDim2.new(0.52, 0, 0.5, -41)
		statsBox.Parent = card
		UIKit.statBar(statsBox, "Power", def.Power / maxPower, tostring(def.Power), C.Coral, {Size = UDim2.new(1, 0, 0, 18), Position = UDim2.fromOffset(0, 0)})
		UIKit.statBar(statsBox, "Find", def.FindChance / maxFind, math.floor(def.FindChance * 1000 + 0.5) / 10 .. "%", C.Mint, {Size = UDim2.new(1, 0, 0, 18), Position = UDim2.fromOffset(0, 21)})
		UIKit.statBar(statsBox, "Luck", def.Luck / maxLuck, "x" .. def.Luck, C.Sun, {Size = UDim2.new(1, 0, 0, 18), Position = UDim2.fromOffset(0, 42)})
		UIKit.statBar(statsBox, "Speed", minCooldown / def.Cooldown, string.format("%.2fs", def.Cooldown), C.Sky, {Size = UDim2.new(1, 0, 0, 18), Position = UDim2.fromOffset(0, 63)})

		local b = UIKit.button(card, "", {Size = UDim2.new(0.17, 0, 0, 54), Position = UDim2.new(1, -14, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5)})
		cards[def.Id] = b
		b.MouseButton1Click:Connect(function()
			local owned = string.split(player:GetAttribute("OwnedShovels") or "", ",")
			if table.find(owned, def.Id) then
				equipShovelRemote:FireServer(def.Id)
			else
				buyShovelRemote:FireServer(def.Id)
			end
		end)
	end
end

local function refreshShop()
	local money = player:GetAttribute("Money") or 0
	local owned = string.split(player:GetAttribute("OwnedShovels") or "", ",")
	local equipped = player:GetAttribute("EquippedShovel")
	moneyLabel.Text = ArtifactData.FormatMoney(money)
	for _, def in ipairs(shopWorld.Shovels) do
		local b = cards[def.Id]
		if b then
			if def.Id == equipped then
				UIKit.setButton(b, "EQUIPPED", C.Lilac)
			elseif table.find(owned, def.Id) then
				UIKit.setButton(b, "EQUIP", C.Sky)
			else
				UIKit.setButton(b, def.Price <= 0 and "FREE" or ArtifactData.FormatMoney(def.Price), money >= def.Price and C.Mint or C.Coral)
			end
		end
	end
end

for _, attribute in ipairs({"Money", "OwnedShovels", "EquippedShovel"}) do
	player:GetAttributeChangedSignal(attribute):Connect(function()
		if window.Visible then refreshShop() end
	end)
end

openShopRemote.OnClientEvent:Connect(function(worldId)
	local world = GameConfig.GetWorld(worldId) or GameConfig.Worlds[1]
	if world ~= shopWorld or next(cards) == nil then
		shopWorld = world
		buildCards(world)
	end
	refreshShop()
	UIKit.open(window)
end)

shopMessageRemote.OnClientEvent:Connect(function(message, success)
	showHint(message, success and C.Mint or C.Coral)
end)
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "ShovelSpinner", "LocalScript", [=[
-- ShovelSpinner (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Spins the orbiting crystals of the crystal shovels on display in the Shovel Shops.
-- (Shovels in players' hands are spun by ShovelClient's pose system.)
-- ShopBuilder tags each orbiting part "ShovelOrbit" and gives it OrbitPivot, OrbitOffset
-- and OrbitSpeed attributes; the spin is local to each player, so it costs the server nothing.

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local spinning = {} -- [part] = {Pivot, Offset, Speed}

local function add(part)
	local pivot, offset = part:GetAttribute("OrbitPivot"), part:GetAttribute("OrbitOffset")
	if typeof(pivot) == "CFrame" and typeof(offset) == "CFrame" then
		spinning[part] = {Pivot = pivot, Offset = offset, Speed = part:GetAttribute("OrbitSpeed") or 2}
	end
end
CollectionService:GetInstanceAddedSignal("ShovelOrbit"):Connect(add)
CollectionService:GetInstanceRemovedSignal("ShovelOrbit"):Connect(function(part)
	spinning[part] = nil
end)
for _, part in ipairs(CollectionService:GetTagged("ShovelOrbit")) do
	add(part)
end

RunService.RenderStepped:Connect(function()
	local t = os.clock()
	local parts, cframes = {}, {}
	for part, spin in pairs(spinning) do
		if part.Parent then
			table.insert(parts, part)
			table.insert(cframes, spin.Pivot * CFrame.Angles(0, 0, t * spin.Speed) * spin.Offset)
		else
			spinning[part] = nil
		end
	end
	if #parts > 0 then
		workspace:BulkMoveTo(parts, cframes, Enum.BulkMoveMode.FireCFrameChanged)
	end
end)
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "SkyPlanets", "LocalScript", [=[
-- SkyPlanets (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The interconnected skybox: the other 8 worlds hang high in the sky as big faint planets,
-- each in its world's colors, so from any world you can see where else you could go.
-- Each planet is a softly transparent sphere inside a larger Neon glow shell (so it blends
-- into the haze like a distant moon); some get a ring. They sit far out and high up, spin
-- slowly, and move to surround whichever world you travel to. Local to this screen only.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local player = Players.LocalPlayer

local DISTANCE = 1900          -- studs from the world you're in
local HEIGHT = {750, 1150}     -- studs above it
local SIZE = {240, 420}        -- planet diameter
local BODY_TRANSPARENCY = 0.35 -- the planet itself
local GLOW_TRANSPARENCY = 0.86 -- the Neon halo around it
local HOME_COLOR = Color3.fromRGB(112, 204, 108) -- World 1 has no theme colors

local folder = Instance.new("Folder")
folder.Name = "SkyPlanets"
folder.Parent = workspace

local planets = {} -- [worldId] = {Model, Body, Glow, Ring, Offset, Spin}

local function part(name, shape, size, color, material, transparency)
	local p = Instance.new("Part")
	p.Name = name
	p.Shape = shape
	p.Size = size
	p.Color = color
	p.Material = material
	p.Transparency = transparency
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	return p
end

for _, world in ipairs(GameConfig.Worlds) do
	local main = world.Look and world.Look.Main or HOME_COLOR
	local glowColor = world.Look and world.Look.Glow or Color3.fromRGB(150, 230, 255)
	local rng = Random.new(world.Id * 131)
	local size = SIZE[1] + (SIZE[2] - SIZE[1]) * rng:NextNumber()
	local model = Instance.new("Model")
	model.Name = "Planet_" .. world.Name
	local body = part("Planet", Enum.PartType.Ball, Vector3.one * size, main, Enum.Material.SmoothPlastic, BODY_TRANSPARENCY)
	body.Parent = model
	local glow = part("Glow", Enum.PartType.Ball, Vector3.one * size * 1.18, glowColor, Enum.Material.Neon, GLOW_TRANSPARENCY)
	glow.Parent = model
	-- a darker band so it reads as a planet, not a ball
	local band = part("Band", Enum.PartType.Cylinder, Vector3.new(size * 0.16, size * 1.005, size * 1.005), main:Lerp(Color3.new(0, 0, 0), 0.25), Enum.Material.SmoothPlastic, BODY_TRANSPARENCY)
	band.Parent = model
	local ring
	if world.Id % 3 == 0 then
		ring = part("Ring", Enum.PartType.Cylinder, Vector3.new(size * 0.02, size * 2, size * 2), glowColor, Enum.Material.Neon, 0.7)
		ring.Parent = model
	end
	model.Parent = nil -- shown when its turn comes
	planets[world.Id] = {
		Model = model, Body = body, Glow = glow, Band = band, Ring = ring,
		Angle = (world.Id - 1) / #GameConfig.Worlds * math.pi * 2 + rng:NextNumber(-0.2, 0.2),
		Height = HEIGHT[1] + (HEIGHT[2] - HEIGHT[1]) * rng:NextNumber(),
		Tilt = CFrame.Angles(rng:NextNumber(-0.5, 0.5), 0, rng:NextNumber(0.2, 0.6)),
		Spin = rng:NextNumber(0.02, 0.06),
	}
end

local centers = {} -- [worldId] = CFrame of the planet around the current world
local function arrange()
	local current = GameConfig.GetWorld(player:GetAttribute("CurrentWorld") or 1) or GameConfig.Worlds[1]
	for id, planet in pairs(planets) do
		if id == current.Id then
			planet.Model.Parent = nil -- no planet for the world you're standing on
			centers[id] = nil
		else
			local offset = Vector3.new(math.cos(planet.Angle) * DISTANCE, planet.Height, math.sin(planet.Angle) * DISTANCE)
			centers[id] = CFrame.new(current.Origin + offset) * planet.Tilt
			planet.Model.Parent = folder
		end
	end
end
player:GetAttributeChangedSignal("CurrentWorld"):Connect(arrange)
arrange()

RunService.Heartbeat:Connect(function()
	local t = os.clock()
	local parts, cframes = {}, {}
	for id, center in pairs(centers) do
		local planet = planets[id]
		local spun = center * CFrame.Angles(0, t * planet.Spin, 0)
		table.insert(parts, planet.Body); table.insert(cframes, spun)
		table.insert(parts, planet.Glow); table.insert(cframes, spun)
		table.insert(parts, planet.Band); table.insert(cframes, spun * CFrame.Angles(0, 0, math.rad(90)))
		if planet.Ring then
			table.insert(parts, planet.Ring); table.insert(cframes, center * CFrame.Angles(0, 0, math.rad(90)))
		end
	end
	if #parts > 0 then
		workspace:BulkMoveTo(parts, cframes, Enum.BulkMoveMode.FireCFrameChanged)
	end
end)
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "WorldClient", "LocalScript", [=[
-- WorldClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The World Map opened at any World Gate: a card per world showing whether it's unlocked,
-- its price, and a button to unlock it or travel there.
-- Also changes the sky and lighting to each world's mood when you travel there.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local openWorldMapRemote = remotes:WaitForChild("OpenWorldMap")
local buyWorldRemote = remotes:WaitForChild("BuyWorld")
local travelRemote = remotes:WaitForChild("TravelToWorld")

local player = Players.LocalPlayer
local gui = UIKit.screen(player, "WorldMapGui", 3)

local window, content = UIKit.window(gui, "WORLD MAP", UDim2.fromOffset(680, 560), C.Sky, "🌍")

local moneyTag = UIKit.panel(content, {Size = UDim2.fromOffset(180, 38), Position = UDim2.new(1, 0, 0, 0), AnchorPoint = Vector2.new(1, 0), Color = C.Money, Radius = 19})
local moneyLabel = UIKit.label(moneyTag, "", {Size = UDim2.new(1, -24, 0.72, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2.5, StrokeColor = UIKit.shadeColor(C.Money, 0.6), MaxText = 24})
UIKit.label(content, "Unlock new dig sites with cash!", {Size = UDim2.new(1, -210, 0, 28), Position = UDim2.fromOffset(4, 5), Align = "Left", Color = C.Violet, Stroke = 0, MaxText = 22})

local listHolder = Instance.new("Frame")
listHolder.BackgroundTransparency = 1
listHolder.Size = UDim2.new(1, 0, 1, -48)
listHolder.Position = UDim2.fromOffset(0, 46)
listHolder.Parent = content
local list = UIKit.list(listHolder, 10)

local PLANET_COLORS = {C.Mint, C.Sun, C.Coral, C.Sky, C.Lilac, C.Violet, C.Money, C.Coral, C.Sky}
local buttons = {} -- [worldId] = button

for _, world in ipairs(GameConfig.Worlds) do
	local card = UIKit.panel(list, {Size = UDim2.new(1, -6, 0, 88), Color = world.Enabled and C.White or C.PanelTint, Radius = 20, ShadeAmount = 0.06})
	card.LayoutOrder = world.Id
	-- little planet badge with the world number
	local planetColor = world.Look and world.Look.Main or PLANET_COLORS[world.Id] or C.Lilac
	local planet = UIKit.panel(card, {Size = UDim2.fromOffset(62, 62), Position = UDim2.new(0, 12, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Color = planetColor, Radius = 31, ShadeAmount = 0.25})
	UIKit.label(planet, tostring(world.Id), {Size = UDim2.fromScale(0.56, 0.56), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 3, StrokeColor = UIKit.shadeColor(planetColor, 0.6), MaxText = 30})
	UIKit.label(card, world.Name, {Size = UDim2.new(0.62, -90, 0, 28), Position = UDim2.fromOffset(88, 12), Align = "Left", Color = C.Ink, Stroke = 0, MaxText = 24})
	local sub = world.Enabled and (world.Tagline or (#world.Shovels .. " pickaxes  •  digs down to " .. -world.Zones[#world.Zones].Bottom .. "m  •  your museum is here"))
		or "Still being excavated... coming soon!"
	UIKit.label(card, sub, {Size = UDim2.new(0.62, -90, 0, 34), Position = UDim2.fromOffset(88, 42), Align = "Left", VAlign = "Top", Color = C.Grey, Stroke = 0, Font = UIKit.BodyFont, TextSize = 13})

	local b = UIKit.button(card, "", {Size = UDim2.new(0.3, 0, 0, 54), Position = UDim2.new(1, -14, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), MaxText = 20})
	buttons[world.Id] = b
	b.MouseButton1Click:Connect(function()
		local unlocked = table.find(string.split(player:GetAttribute("UnlockedWorlds") or "1", ","), tostring(world.Id))
		if not world.Enabled then
			return
		elseif unlocked then
			if player:GetAttribute("CurrentWorld") ~= world.Id then
				travelRemote:FireServer(world.Id)
				window.Visible = false
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
			UIKit.setButton(b, "SOON • " .. ArtifactData.FormatMoney(world.Price), C.Grey)
		elseif world.Id == current then
			UIKit.setButton(b, "📍 YOU ARE HERE", C.Lilac)
		elseif table.find(unlocked, tostring(world.Id)) then
			UIKit.setButton(b, "TRAVEL", C.Sky)
		else
			UIKit.setButton(b, "🔒 " .. ArtifactData.FormatMoney(world.Price), money >= world.Price and C.Mint or C.Coral)
		end
	end
end

for _, attribute in ipairs({"Money", "UnlockedWorlds", "CurrentWorld"}) do
	player:GetAttributeChangedSignal(attribute):Connect(function()
		if window.Visible then refresh() end
	end)
end

openWorldMapRemote.OnClientEvent:Connect(function()
	refresh()
	UIKit.open(window)
end)

---------------------------------------------------------------------
-- WORLD SKIES: each world has its own time of day, haze and color grade (WorldsData.Sky).
-- World 1's look (set by MapStyle on the server) is remembered and restored when you return.
---------------------------------------------------------------------
local home -- World 1's lighting, captured the first time you leave it

-- the one bloom and sun rays effect the lighting uses (made here if the place has none)
local function effect(className)
	local found = Lighting:FindFirstChildOfClass(className)
	if not found then
		found = Instance.new(className)
		found.Intensity = 0
		found.Parent = Lighting
	end
	return found
end

local function capture()
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	local grade = Lighting:FindFirstChild("Cartoon2050Grade")
	local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds")
	local bloom, rays = effect("BloomEffect"), effect("SunRaysEffect")
	return {
		ClockTime = Lighting.ClockTime, Latitude = Lighting.GeographicLatitude, Brightness = Lighting.Brightness,
		Exposure = Lighting.ExposureCompensation, Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
		DiffuseScale = Lighting.EnvironmentDiffuseScale, SpecularScale = Lighting.EnvironmentSpecularScale,
		ShadowSoftness = Lighting.ShadowSoftness,
		Tint = grade and grade.TintColor or Color3.new(1, 1, 1),
		Saturation = grade and grade.Saturation or 0, Contrast = grade and grade.Contrast or 0,
		Fog = atmosphere and atmosphere.Color, Decay = atmosphere and atmosphere.Decay, Density = atmosphere and atmosphere.Density,
		Offset = atmosphere and atmosphere.Offset, Haze = atmosphere and atmosphere.Haze, Glare = atmosphere and atmosphere.Glare,
		Bloom = {bloom.Intensity, bloom.Size, bloom.Threshold}, SunRays = {rays.Intensity, rays.Spread},
		Clouds = clouds and clouds.Cover,
	}
end

-- Realistic defaults for worlds 2-9 (each world's Sky overrides what it needs):
-- stronger sun, full environment lighting and reflections, crisp shadows
local REALISM = {Brightness = 3, Exposure = 0, Latitude = 35, DiffuseScale = 1, SpecularScale = 1, ShadowSoftness = 0.15,
	Offset = 0.25, Haze = 1.5, Glare = 0.4, Saturation = 0.1, Contrast = 0.1, Bloom = {0.35, 24, 1.9}, SunRays = {0.1, 0.25}}

local function applySky(sky)
	local function get(key)
		if sky[key] ~= nil then return sky[key] end
		return REALISM[key]
	end
	local info = TweenInfo.new(1.2, Enum.EasingStyle.Sine)
	-- ClockTime and the sun angle jump (tweening would spin the sun through the whole day)
	Lighting.ClockTime = sky.ClockTime
	Lighting.GeographicLatitude = get("Latitude")
	Lighting.ShadowSoftness = get("ShadowSoftness")
	TweenService:Create(Lighting, info, {
		Ambient = sky.Ambient, OutdoorAmbient = sky.OutdoorAmbient, Brightness = get("Brightness"),
		ExposureCompensation = get("Exposure"), EnvironmentDiffuseScale = get("DiffuseScale"),
		EnvironmentSpecularScale = get("SpecularScale"),
	}):Play()
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere and sky.Fog then
		TweenService:Create(atmosphere, info, {Color = sky.Fog, Decay = sky.Decay, Density = sky.Density,
			Offset = get("Offset"), Haze = get("Haze"), Glare = get("Glare")}):Play()
	end
	local grade = Lighting:FindFirstChild("Cartoon2050Grade")
	if grade then
		TweenService:Create(grade, info, {TintColor = sky.Tint, Saturation = get("Saturation"), Contrast = get("Contrast")}):Play()
	end
	local bloom, rays = effect("BloomEffect"), effect("SunRaysEffect")
	local b, r = get("Bloom"), get("SunRays")
	TweenService:Create(bloom, info, {Intensity = b[1], Size = b[2], Threshold = b[3]}):Play()
	TweenService:Create(rays, info, {Intensity = r[1], Spread = r[2]}):Play()
	local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds")
	if clouds and sky.Clouds then
		clouds.Cover = sky.Clouds
	end
end

-- Only the island you're on is drawn: the other worlds' buildings and decorations are
-- taken out on this screen only (they're also ~9000 studs away, lost in the haze).
local worldsFolder = workspace:WaitForChild("Worlds", 30)
local worldModels = {} -- [model name] = model, even while it's hidden
local function showOnlyWorld(worldId)
	if not worldsFolder then return end
	for _, model in ipairs(worldsFolder:GetChildren()) do
		worldModels[model.Name] = model
	end
	for name, model in pairs(worldModels) do
		model.Parent = (name == "World" .. worldId) and worldsFolder or nil
	end
end
if worldsFolder then
	worldsFolder.ChildAdded:Connect(function(model)
		worldModels[model.Name] = model
		if model.Name ~= "World" .. (player:GetAttribute("CurrentWorld") or 1) then
			task.defer(function() model.Parent = nil end)
		end
	end)
end

local function onWorldChanged()
	showOnlyWorld(player:GetAttribute("CurrentWorld") or 1)
	local world = GameConfig.GetWorld(player:GetAttribute("CurrentWorld") or 1)
	if world and world.Sky then
		home = home or capture()
		applySky(world.Sky)
	elseif home then
		applySky(home)
	end
end
player:GetAttributeChangedSignal("CurrentWorld"):Connect(onWorldChanged)
onWorldChanged()
]=])
if recording then ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit) end
print("Meme Archaeologist: installed " .. count .. " scripts. Now save the place (Ctrl+S).")
