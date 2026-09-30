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
-- The curve is smooth (each rarity is worth about 3-4x the one below it) instead of a huge
-- jump at the top, so the early zones stay worth digging and the Abyss is a step up, not a
-- sudden spike.
ArtifactData.Rarities = {
	{Name = "Common",       Code = "C",  Income = 10,        Chance = 60,    Color = Color3.fromRGB(190, 190, 190)},
	{Name = "Uncommon",     Code = "U",  Income = 35,        Chance = 25,    Color = Color3.fromRGB(85, 200, 85)},
	{Name = "Rare",         Code = "R",  Income = 120,       Chance = 10,    Color = Color3.fromRGB(60, 140, 255)},
	{Name = "Epic",         Code = "E",  Income = 450,       Chance = 3.5,   Color = Color3.fromRGB(170, 80, 255)},
	{Name = "Legendary",    Code = "L",  Income = 1500,      Chance = 1.1,   Color = Color3.fromRGB(255, 170, 0)},
	{Name = "Mythic",       Code = "M",  Income = 5000,      Chance = 0.3,   Color = Color3.fromRGB(255, 60, 90)},
	{Name = "Divine",       Code = "D",  Income = 20000,     Chance = 0.07,  Color = Color3.fromRGB(255, 240, 150)},
	{Name = "Celestial",    Code = "CE", Income = 60000,     Chance = 0.025, Color = Color3.fromRGB(120, 255, 255)},
	{Name = "Transcendent", Code = "T",  Income = 150000,    Chance = 0.005, Color = Color3.fromRGB(255, 255, 255)},
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
		{"C", "LogBatGuy", "Tung-Tung Log Guy", "A wooden log with a baseball bat. It knocks three times before it arrives."},
		{"C", "SusBean", "Sus Space Bean", "A tiny astronaut shaped like a bean. One of them was always acting sus."},
		{"U", "HalfFullBottle", "Half-Full Water Bottle", "Tossing it so it landed upright granted the thrower temporary social status."},
		{"U", "SharkSneakers", "Three-Legged Sneaker Shark", "An ocean predator wearing shoes. It was considered hilarious."},
		{"U", "RainbowPastryCat", "Rainbow Pastry Cat", "A cat made of frosted pastry, flying through space on a rainbow. The song never stops."},
		{"U", "CappuccinoBallerina", "Cappuccino Ballerina", "Half dancer, half coffee cup. Pirouettes until the foam spills."},
		{"U", "DeepFriedChip", "Deep-Fried Image Chip", "A picture cooked at such extreme temperatures it became radioactive with jokes."},
		{"U", "ChillDude", "Chill Dude in a Sweater", "Hands in pockets, zero worries. The most relaxed creature of the Brainrot Epoch."},
		{"R", "SingingThrone", "Singing Porcelain Throne", "A ceremonial seat with a tiny singing head. Its meaning is lost to history."},
		{"R", "ShockedRodent", "Shocked Yellow Rodent", "Frozen forever with its mouth wide open. Humans used it whenever anyone acted surprised."},
		{"R", "PurpleBirthdayShake", "Sus Purple Birthday Milkshake", "One sip and the humans in the video were never seen again. Handle with care."},
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
		{"R", "FineDog", "Everything's Fine Dog", "Sips coffee in a burning room and says it's fine. The most relatable human artifact."},
		{"R", "FrowningCat", "Frowning Cat Bust", "Never smiled once. Earned millions anyway."},
		{"R", "DramaticHamster", "Dramatic Hamster Figurine", "Turned around slowly. Changed the internet forever."},
		{"R", "SpongeLeaving", "Yellow Porous Sponge Leavin'", "The famous walk-out. Used whenever a human decided to head out."},
		{"E", "SacredPlank", "The Sacred Plank", "Humans lay flat on strange objects and photographed it. This board saw it all."},
		{"E", "PointingSuits", "Two Pointing Arachnid Suits", "Two identical heroes accusing each other of being the fake. Neither ever admitted it."},
		{"E", "PurpleTitanBuggy", "Purple Titan Buggy", "A giant purple conqueror's tiny car. He could snap his fingers but still drove this."},
		{"E", "CrocBomber", "Crocodile Bomber Plane", "A crocodile that is also a war plane. Nobody asked questions."},
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
		{"E", "ChillDudeTablet", "Chill Dude Stone Carving", "Carved by the first humans to discover being chill. Even the stone looks relaxed."},
		{"L", "EmoticonStone", "The First Emoticon Stone", "A sideways smile, carved by the earliest humans of the web. :-)"},
		{"L", "SpaceInfant", "Green Space Infant", "A tiny green baby with enormous ears. Every human wanted to protect it."},
		{"L", "ChonkyBunny", "Chonky Gray Bunny", "A rabbit of truly legendary size. Humans simply called it big."},
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
		{"M", "JawlineChad", "Mega Jawline Chad", "The most perfect jawline ever photographed, turned in the most dramatic direction."},
		{"M", "WowShibaCoin", "Much Wow Shiba Coin", "Started as a joke, ended up worth money. Such coin. Very wow."},
		{"M", "AIGirlfriendFirmware", "Deprecated AI Companion Firmware", "Version 11.4. Still says 'I understand how you feel' on boot."},
		{"D", "BrainrotCoreSample", "Frozen Brainrot Core Sample", "Drilled from 500 studs down. Every layer is a different trend."},
		{"D", "SkibidiMonolith", "The Singing Toilet Monolith", "Nobody knows who built it. It hums when someone says 'Ohio.'"},
		{"CE", "FinalUpvote", "The Final Upvote", "The last upvote ever cast on the old internet. Still warm."},
		{"CE", "QuantumDoge", "Quantum Much-Wow Shiba", "Such superposition. Very both. Wow."},
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

-- CORRUPTED MEMES: Glitch Nexus's data hacking minigame digs up glitched copies of that
-- world's memes. They're worth 2x on display and never come out of normal digging.
ArtifactData.CorruptedMultiplier = 2
do
	local glitchArea = #ArtifactData.Areas
	for _, base in ipairs(table.clone(ArtifactData.Artifacts)) do
		if base.Area == glitchArea then
			local corrupted = table.clone(base)
			corrupted.Id = "Corrupted" .. base.Id
			corrupted.Name = "Corrupted " .. base.Name
			corrupted.Description = "A glitched copy dug out of a Data Node. Earns 2x. " .. base.Description
			corrupted.BaseId = base.Id
			corrupted.Corrupted = true
			corrupted.IncomeMultiplier = ArtifactData.CorruptedMultiplier
			artifactById[corrupted.Id] = corrupted
			table.insert(ArtifactData.Artifacts, corrupted)
		end
	end
end

-- the corrupted copy of a meme (nil if it has none)
function ArtifactData.GetCorrupted(artifact)
	return artifact and artifactById["Corrupted" .. (artifact.BaseId or artifact.Id)]
end

-- which icon/picture an artifact uses (corrupted memes use the original's)
function ArtifactData.IconId(id)
	local artifact = artifactById[id]
	return artifact and artifact.BaseId or id
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
	return rarity.Income * area.Multiplier * (artifact.IncomeMultiplier or 1)
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
