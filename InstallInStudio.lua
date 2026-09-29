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
do local old = game:GetService("ServerScriptService"):FindFirstChild("DataManager") if old then old:Destroy() print("Removed DataManager") end end
do local old = game:GetService("ServerScriptService"):FindFirstChild("ShovelModels") if old then old:Destroy() print("Removed ShovelModels") end end
install(game:GetService("ReplicatedStorage"), "ArtifactData", "ModuleScript", [=[
-- ArtifactData (ModuleScript in ReplicatedStorage)
-- The ONE list the whole game reads from: rarities, the 20 dig areas, and every artifact.
-- To add an artifact: copy one line inside an area's list and change it.
-- Rarity codes: C=Common U=Uncommon R=Rare E=Epic L=Legendary M=Mythic D=Divine CE=Celestial T=Transcendent

local ArtifactData = {}

---------------------------------------------------------------------
-- RARITIES (worst to best). Income = money per second in AREA 1.
---------------------------------------------------------------------
ArtifactData.Rarities = {
	{Name = "Common",       Code = "C",  Income = 10,        Chance = 60,    Color = Color3.fromRGB(190, 190, 190)},
	{Name = "Uncommon",     Code = "U",  Income = 100,       Chance = 25,    Color = Color3.fromRGB(85, 200, 85)},
	{Name = "Rare",         Code = "R",  Income = 1000,      Chance = 10,    Color = Color3.fromRGB(60, 140, 255)},
	{Name = "Epic",         Code = "E",  Income = 10000,     Chance = 3.5,   Color = Color3.fromRGB(170, 80, 255)},
	{Name = "Legendary",    Code = "L",  Income = 100000,    Chance = 1.1,   Color = Color3.fromRGB(255, 170, 0)},
	{Name = "Mythic",       Code = "M",  Income = 500000,    Chance = 0.3,   Color = Color3.fromRGB(255, 60, 90)},
	{Name = "Divine",       Code = "D",  Income = 2500000,   Chance = 0.07,  Color = Color3.fromRGB(255, 240, 150)},
	{Name = "Celestial",    Code = "CE", Income = 10000000,  Chance = 0.025, Color = Color3.fromRGB(120, 255, 255)},
	{Name = "Transcendent", Code = "T",  Income = 50000000,  Chance = 0.005, Color = Color3.fromRGB(255, 255, 255)},
}

-- Sell value = income per second x this number
ArtifactData.SellMultiplier = 100

---------------------------------------------------------------------
-- DIG AREAS. Every area multiplies artifact value by AreaMultiplier.
---------------------------------------------------------------------
ArtifactData.AreaMultiplier = 4
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
	{Name = "The Abyss",            Era = "Abyss", Multiplier = ArtifactData.AreaMultiplier ^ 15},
}
for i, area in ipairs(ArtifactData.Areas) do
	area.Index = i
	area.Multiplier = area.Multiplier or ArtifactData.AreaMultiplier ^ (i - 1)
end

ArtifactData.Eras = {
	Brainrot    = {DisplayName = "The Brainrot Epoch",  Years = "2016-2024", FirstArea = 1},
	GoldenAge   = {DisplayName = "The Golden Age",      Years = "2005-2015", FirstArea = 8},
	Paleolithic = {DisplayName = "The Paleolithic Web", Years = "1990-2004", FirstArea = 15},
	Abyss       = {DisplayName = "The Abyss",           Years = "2050",      FirstArea = 21},
}
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

---------------------------------------------------------------------
-- DIGGING
---------------------------------------------------------------------
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
		-- SHOVELS (shop order). MaxZone: 1 = Shallow, 2 = Mid, 3 = Deep, 4 = Abyss.
		-- DigRadius = hole size, FindChance = chance per swing to find something (0.02 = 1 in 50),
		-- Luck = rare find multiplier, Cooldown = seconds between swings
		Shovels = {
			{Id = "RustyShovel", Name = "Rusty Shovel", Price = 0, MaxZone = 1,
				DigRadius = 4, FindChance = 0.02, Luck = 1, Cooldown = 0.7,
				Color = Color3.fromRGB(150, 85, 50), Material = "CorrodedMetal",
				Description = "Found in a dumpster in 2049. Still works. Mostly."},
			{Id = "PlasticShovel", Name = "Plastic Beach Shovel", Price = 1000, MaxZone = 2,
				DigRadius = 4.5, FindChance = 0.022, Luck = 1.1, Cooldown = 0.67,
				Color = Color3.fromRGB(255, 200, 40), Material = "SmoothPlastic",
				Description = "Built for sandcastles. Somehow better than rust."},
			{Id = "GardenSpade", Name = "Garden Spade", Price = 7500, MaxZone = 2,
				DigRadius = 5, FindChance = 0.025, Luck = 1.2, Cooldown = 0.64,
				Color = Color3.fromRGB(90, 170, 80), Material = "Metal",
				Description = "Borrowed from a grandma. She wants it back."},
			{Id = "IronShovel", Name = "Iron Shovel", Price = 40000, MaxZone = 2,
				DigRadius = 5.5, FindChance = 0.028, Luck = 1.35, Cooldown = 0.6,
				Color = Color3.fromRGB(175, 180, 190), Material = "Metal",
				Description = "A real tool for a real archaeologist."},
			{Id = "SteelSpade", Name = "Steel Spade", Price = 200000, MaxZone = 3,
				DigRadius = 6, FindChance = 0.03, Luck = 1.5, Cooldown = 0.56,
				Color = Color3.fromRGB(120, 140, 170), Material = "Metal",
				Description = "Sharp enough to cut through ancient comment sections."},
			{Id = "GoldenShovel", Name = "Golden Shovel", Price = 500000, MaxZone = 3,
				DigRadius = 6.5, FindChance = 0.033, Luck = 1.7, Cooldown = 0.53,
				Color = Color3.fromRGB(255, 200, 60), Material = "Metal",
				Description = "Shiny. Heavy. Completely unnecessary. Perfect."},
			{Id = "GamerShovel", Name = "RGB Gamer Shovel", Price = 1000000, MaxZone = 3,
				DigRadius = 7, FindChance = 0.036, Luck = 2, Cooldown = 0.5,
				Color = Color3.fromRGB(255, 60, 200), Material = "Neon",
				Description = "The RGB lights add +200% digging power. Science."},
			{Id = "TectonicAuger", Name = "Tectonic Auger", Price = 10000000, MaxZone = 4,
				DigRadius = 7.5, FindChance = 0.04, Luck = 2.4, Cooldown = 0.47,
				Color = Color3.fromRGB(128, 132, 138), Material = "Foil",
				Description = "Legendary. Rated for bedrock, permafrost and 2049-era server racks."},
			{Id = "SingularitySpade", Name = "Singularity Spade", Price = 50000000, MaxZone = 4,
				DigRadius = 8, FindChance = 0.045, Luck = 3, Cooldown = 0.44,
				Color = Color3.fromRGB(62, 64, 70), Material = "Foil",
				Description = "Mythic. Folds the Abyss around the blade. Do not dig near pets."},
		},
	},
}

-- Worlds 2-9: placeholders. Each one sits far out on the map and is unlocked with money.
-- Give each one Zones + Shovels like World 1 above, then set Enabled = true.
local FUTURE_WORLD_PRICES = {1e9, 25e9, 500e9, 10e12, 250e12, 5e15, 100e15, 2.5e18}
for i, price in ipairs(FUTURE_WORLD_PRICES) do
	local id = i + 1
	table.insert(GameConfig.Worlds, {
		Id = id, Name = "World " .. id, Enabled = false, Price = price,
		Origin = Vector3.new(0, 0, 3000 * id), -- far away along +Z, clear of the city
		PitRadius = 41, CenterNoDigRadius = 0, HubPaths = false,
		Zones = zones({
			{Name = "Shallow Zone", Era = "Brainrot", Areas = {1}, Rarities = SHALLOW, Material = "Ground", Color = Color3.fromRGB(176, 138, 96)},
			{Name = "Mid Zone", Era = "GoldenAge", Areas = {8}, Rarities = MID, Material = "Sandstone", Color = Color3.fromRGB(214, 186, 128)},
			{Name = "Deep Zone", Era = "Paleolithic", Areas = {15}, Rarities = DEEP, Material = "CrackedLava", Color = Color3.fromRGB(214, 110, 70)},
			{Name = "The Abyss", Era = "Abyss", Areas = {21}, Rarities = ABYSS, Material = "Glacier", Color = Color3.fromRGB(150, 196, 214)},
		}),
		Shovels = {},
	})
end

GameConfig.BedrockThickness = 8

-- Every shovel from every world, in one list (ids must be unique across worlds)
GameConfig.Shovels = {}
local shovelById = {}
for _, world in ipairs(GameConfig.Worlds) do
	for _, shovel in ipairs(world.Shovels) do
		shovel.World = world.Id
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

-- Fills a world's dig site with terrain: stone ground around, the 4 zones in the pit, bedrock below.
-- Used on server start and every pit reset.
function GameConfig.FillDigTerrain(terrain, world)
	local origin = world.Origin
	local radius = world.PitRadius + 2
	local top = origin.Y
	local lastZone = world.Zones[#world.Zones]
	local bottom = top + lastZone.Bottom - GameConfig.BedrockThickness
	local depth = top - bottom
	-- clear anything above ground level (terrain works in 4-stud blocks)
	terrain:FillBlock(CFrame.new(origin + Vector3.new(0, 8, 0)), Vector3.new(200, 16, 200), Enum.Material.Air)
	-- stone ground around the pit (and under it), with a grassy top layer
	terrain:FillBlock(CFrame.new(origin + Vector3.new(0, -depth / 2, 0)), Vector3.new(200, depth, 200), Enum.Material.Slate)
	terrain:FillBlock(CFrame.new(origin + Vector3.new(0, -2, 0)), Vector3.new(200, 4, 200), Enum.Material.Grass)
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
install(game:GetService("ReplicatedStorage"), "ShovelModels", "ModuleScript", [=[
-- ShovelModels (ModuleScript in ReplicatedStorage)
-- Builds a detailed, individually styled model for every shovel.
-- World 1's shovels each have a hand-made cartoon design (see CUSTOM below); any other
-- shovel is built from its STYLES entry. The server uses it for the tools and the shop
-- displays, the client uses it to draw 3D shovel icons in the UI.

local SCALE = 0.68 -- overall size of the shovels
local ALONG_Z = CFrame.Angles(0, math.rad(90), 0) -- points a cylinder along the shaft

local function rgb(r, g, b)
	return Color3.fromRGB(r, g, b)
end

---------------------------------------------------------------------
-- LOOK OF EACH SHOVEL
-- Blade shapes: "Spade" (classic), "Scoop" (round toy), "Spoon", "Trowel"
-- Grip: "D" (D-shaped handle) or "T" (T-bar handle)
---------------------------------------------------------------------
local STYLES = {
	RustyShovel = {
		Shape = "Spade", Grip = "D",
		Shaft = rgb(92, 64, 42), ShaftMat = "Wood",
		Blade = rgb(150, 82, 45), BladeMat = "CorrodedMetal",
		Metal = rgb(105, 68, 45), MetalMat = "CorrodedMetal",
		GripColor = rgb(75, 75, 78), GripMat = "Fabric",
		Tape = true, Rust = true,
	},
	PlasticShovel = {
		Shape = "Scoop", Grip = "T",
		Shaft = rgb(40, 120, 255), ShaftMat = "SmoothPlastic",
		Blade = rgb(255, 205, 40), BladeMat = "SmoothPlastic", Shine = 0.12,
		Metal = rgb(255, 75, 75), MetalMat = "SmoothPlastic",
		GripColor = rgb(255, 75, 75), GripMat = "SmoothPlastic",
	},
	GardenSpade = {
		Shape = "Spade", Grip = "D",
		Shaft = rgb(70, 130, 60), ShaftMat = "SmoothPlastic",
		Blade = rgb(165, 170, 178), BladeMat = "Metal", Shine = 0.15,
		Metal = rgb(55, 110, 50), MetalMat = "SmoothPlastic",
		GripColor = rgb(45, 90, 40), GripMat = "SmoothPlastic",
		Rivets = true,
	},
	IronShovel = {
		Shape = "Spade", Grip = "D",
		Shaft = rgb(170, 125, 82), ShaftMat = "Wood",
		Blade = rgb(118, 122, 132), BladeMat = "Metal", Shine = 0.2,
		Metal = rgb(58, 60, 66), MetalMat = "Metal",
		GripColor = rgb(30, 30, 32), GripMat = "Fabric",
		Rivets = true,
	},
	SteelSpade = {
		Shape = "Spade", Grip = "T",
		Shaft = rgb(45, 50, 60), ShaftMat = "Metal",
		Blade = rgb(190, 200, 215), BladeMat = "Metal", Shine = 0.35,
		Metal = rgb(120, 140, 170), MetalMat = "Metal",
		GripColor = rgb(20, 20, 24), GripMat = "Fabric",
		Rivets = true,
	},
	GoldenShovel = {
		Shape = "Spade", Grip = "D",
		Shaft = rgb(35, 32, 30), ShaftMat = "Wood",
		Blade = rgb(255, 196, 55), BladeMat = "Metal", Shine = 0.4,
		Metal = rgb(255, 205, 80), MetalMat = "Metal",
		GripColor = rgb(130, 25, 35), GripMat = "Fabric",
		Rivets = true, Sparkles = rgb(255, 220, 120),
	},
	GamerShovel = {
		Shape = "Spade", Grip = "T",
		Shaft = rgb(24, 24, 30), ShaftMat = "Metal",
		Blade = rgb(30, 30, 40), BladeMat = "Metal", Shine = 0.25,
		Metal = rgb(40, 40, 50), MetalMat = "Metal",
		GripColor = rgb(15, 15, 18), GripMat = "Fabric",
		Edge = rgb(255, 60, 200), Glow = rgb(255, 60, 200),
		Strips = {rgb(255, 60, 200), rgb(0, 225, 255), rgb(90, 255, 120)},
	},
	PixelSpade = {
		Shape = "Spade", Grip = "T",
		Shaft = rgb(60, 60, 200), ShaftMat = "SmoothPlastic",
		Blade = rgb(80, 200, 255), BladeMat = "SmoothPlastic",
		Metal = rgb(255, 255, 255), MetalMat = "SmoothPlastic",
		GripColor = rgb(255, 80, 80), GripMat = "SmoothPlastic",
		Pixels = true,
	},
	RainbowShovel = {
		Shape = "Spade", Grip = "D",
		Shaft = rgb(245, 245, 250), ShaftMat = "SmoothPlastic",
		Blade = rgb(255, 120, 220), BladeMat = "Glass", Shine = 0.3,
		Metal = rgb(255, 255, 255), MetalMat = "Metal",
		GripColor = rgb(120, 90, 255), GripMat = "SmoothPlastic",
		Strips = {rgb(255, 60, 60), rgb(255, 200, 40), rgb(80, 220, 120), rgb(60, 140, 255)},
		Glow = rgb(255, 150, 230), Sparkles = rgb(255, 200, 255),
	},
	DiamondShovel = {
		Shape = "Spade", Grip = "D",
		Shaft = rgb(235, 238, 245), ShaftMat = "Metal",
		Blade = rgb(150, 240, 255), BladeMat = "Glass", Shine = 0.45, BladeTransparency = 0.2,
		Metal = rgb(205, 210, 225), MetalMat = "Metal",
		GripColor = rgb(60, 110, 160), GripMat = "Fabric",
		Core = rgb(120, 240, 255), Glow = rgb(120, 240, 255), Sparkles = rgb(200, 250, 255),
	},
	FidgetDrill = {
		Shape = "Trowel", Grip = "T",
		Shaft = rgb(40, 40, 45), ShaftMat = "Metal",
		Blade = rgb(255, 140, 40), BladeMat = "Metal", Shine = 0.3,
		Metal = rgb(255, 140, 40), MetalMat = "Metal",
		GripColor = rgb(20, 20, 20), GripMat = "Fabric",
		Rings = rgb(255, 140, 40),
	},
	LaserExcavator = {
		Shape = "Spade", Grip = "T",
		Shaft = rgb(240, 242, 248), ShaftMat = "SmoothPlastic",
		Blade = rgb(255, 50, 50), BladeMat = "Neon", BladeTransparency = 0.15,
		Metal = rgb(55, 58, 68), MetalMat = "Metal",
		GripColor = rgb(40, 40, 48), GripMat = "SmoothPlastic",
		Edge = rgb(255, 180, 180), Glow = rgb(255, 60, 60), Field = rgb(255, 60, 60),
	},
	PlasmaSpade = {
		Shape = "Spade", Grip = "T",
		Shaft = rgb(30, 34, 50), ShaftMat = "Metal",
		Blade = rgb(80, 140, 255), BladeMat = "Neon", BladeTransparency = 0.2,
		Metal = rgb(120, 180, 255), MetalMat = "Metal",
		GripColor = rgb(20, 22, 30), GripMat = "Fabric",
		Glow = rgb(80, 140, 255), Field = rgb(120, 180, 255), Sparkles = rgb(160, 200, 255),
	},
	HoverScoop = {
		Shape = "Scoop", Grip = "T",
		Shaft = rgb(235, 240, 245), ShaftMat = "SmoothPlastic",
		Blade = rgb(60, 255, 200), BladeMat = "Glass", Shine = 0.3, BladeTransparency = 0.15,
		Metal = rgb(60, 255, 200), MetalMat = "Neon",
		GripColor = rgb(40, 45, 55), GripMat = "SmoothPlastic",
		Glow = rgb(60, 255, 200), Rings = rgb(60, 255, 200),
	},
	QuantumSpoon = {
		Shape = "Spoon", Grip = "T",
		Shaft = rgb(30, 22, 50), ShaftMat = "Metal",
		Blade = rgb(170, 90, 255), BladeMat = "ForceField",
		Metal = rgb(200, 150, 255), MetalMat = "Neon",
		GripColor = rgb(25, 18, 40), GripMat = "Fabric",
		Core = rgb(200, 140, 255), Glow = rgb(170, 90, 255), Rings = rgb(200, 150, 255), Sparkles = rgb(220, 180, 255),
	},
	DialUpDigger = {
		Shape = "Spade", Grip = "D",
		Shaft = rgb(215, 205, 175), ShaftMat = "SmoothPlastic",
		Blade = rgb(200, 190, 160), BladeMat = "SmoothPlastic",
		Metal = rgb(120, 115, 100), MetalMat = "SmoothPlastic",
		GripColor = rgb(90, 85, 75), GripMat = "SmoothPlastic",
		Edge = rgb(90, 255, 120), Pixels = true,
	},
	BlackHoleShovel = {
		Shape = "Spoon", Grip = "D",
		Shaft = rgb(15, 12, 20), ShaftMat = "Metal",
		Blade = rgb(10, 5, 20), BladeMat = "Glass", Shine = 0.5,
		Metal = rgb(140, 60, 255), MetalMat = "Neon",
		GripColor = rgb(10, 10, 12), GripMat = "Fabric",
		Core = rgb(140, 60, 255), Glow = rgb(140, 60, 255), Rings = rgb(255, 150, 60),
	},
	CosmicTrowel = {
		Shape = "Trowel", Grip = "T",
		Shaft = rgb(20, 24, 50), ShaftMat = "Metal",
		Blade = rgb(120, 200, 255), BladeMat = "Glass", Shine = 0.35, BladeTransparency = 0.1,
		Metal = rgb(255, 220, 140), MetalMat = "Metal",
		GripColor = rgb(20, 24, 50), GripMat = "Fabric",
		Core = rgb(255, 255, 255), Glow = rgb(120, 200, 255), Sparkles = rgb(255, 255, 255),
	},
	VoidExcavator = {
		Shape = "Spade", Grip = "T",
		Shaft = rgb(20, 10, 30), ShaftMat = "Metal",
		Blade = rgb(110, 40, 160), BladeMat = "ForceField",
		Metal = rgb(110, 40, 160), MetalMat = "Neon",
		GripColor = rgb(15, 8, 22), GripMat = "Fabric",
		Core = rgb(60, 0, 90), Edge = rgb(200, 120, 255), Glow = rgb(150, 60, 220), Sparkles = rgb(180, 100, 255),
	},
	AlgorithmTrowel = {
		Shape = "Trowel", Grip = "D",
		Shaft = rgb(30, 26, 20), ShaftMat = "Metal",
		Blade = rgb(255, 205, 70), BladeMat = "Metal", Shine = 0.4,
		Metal = rgb(255, 225, 120), MetalMat = "Metal",
		GripColor = rgb(40, 30, 15), GripMat = "Fabric",
		Edge = rgb(255, 240, 150), Strips = {rgb(255, 230, 120), rgb(255, 230, 120)},
		Glow = rgb(255, 210, 80), Sparkles = rgb(255, 240, 170), Rivets = true,
	},
	-- World 1 Abyss shovels: industrial, desaturated, built for bedrock
	TectonicAuger = {
		Shape = "Trowel", Grip = "T",
		Shaft = rgb(58, 60, 64), ShaftMat = "CorrodedMetal",
		Blade = rgb(150, 154, 160), BladeMat = "Foil", Shine = 0.25,
		Metal = rgb(92, 95, 100), MetalMat = "Metal",
		GripColor = rgb(28, 28, 30), GripMat = "Fabric",
		Rings = rgb(170, 160, 140), Rivets = true,
	},
	SingularitySpade = {
		Shape = "Spade", Grip = "D",
		Shaft = rgb(30, 31, 34), ShaftMat = "Metal",
		Blade = rgb(52, 54, 60), BladeMat = "Foil", Shine = 0.45,
		Metal = rgb(140, 144, 150), MetalMat = "Foil",
		GripColor = rgb(18, 18, 20), GripMat = "Fabric",
		Edge = rgb(200, 205, 212), Core = rgb(150, 196, 214), Glow = rgb(150, 196, 214),
		Sparkles = rgb(190, 215, 225),
	},
}

-- A decent look for any shovel that has no style above (e.g. new shovels you add later)
local function defaultStyle(def)
	local fancy = def.Material == "Neon" or def.Material == "ForceField" or def.Material == "Glass"
	return {
		Shape = "Spade", Grip = "D",
		Shaft = fancy and rgb(28, 30, 42) or rgb(150, 108, 70), ShaftMat = fancy and "Metal" or "Wood",
		Blade = def.Color, BladeMat = def.Material or "Metal", Shine = 0.2,
		Metal = fancy and def.Color or rgb(80, 82, 90), MetalMat = fancy and "Neon" or "Metal",
		GripColor = rgb(30, 30, 34), GripMat = "Fabric",
		Glow = fancy and def.Color or nil, Rivets = not fancy,
	}
end

---------------------------------------------------------------------
-- BUILDING HELPERS
---------------------------------------------------------------------
local function mat(name)
	return Enum.Material[name] or Enum.Material.SmoothPlastic
end

local function newPart(tool, name, size, cframe, color, material, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Color = color
	p.Material = mat(material)
	if shape then p.Shape = shape end
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Massless = true
	p.CastShadow = p.Material ~= Enum.Material.Neon and p.Material ~= Enum.Material.ForceField
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = tool
	return p
end

local function ellipsoid(tool, name, size, cframe, color, material)
	local p = newPart(tool, name, size, cframe, color, material)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = p
	return p
end

local function cylinderZ(tool, name, length, diameter, z, color, material)
	return newPart(tool, name, Vector3.new(length, diameter, diameter), CFrame.new(0, 0, z) * ALONG_Z, color, material, Enum.PartType.Cylinder)
end

-- a round bar from point a to point b
local function bar(tool, name, a, b, thickness, color, material)
	local length = (b - a).Magnitude
	return newPart(tool, name, Vector3.new(thickness, thickness, length), CFrame.lookAt((a + b) / 2, b), color, material)
end

---------------------------------------------------------------------
-- BLADES (built in "blade space": 0 = top of the blade, -Z = toward the tip)
---------------------------------------------------------------------
local function buildSpade(tool, s, b)
	local plate = newPart(tool, "Blade", Vector3.new(1.3, 0.08, 1.25), b * CFrame.new(0, 0, -0.62), s.Blade, s.BladeMat)
	newPart(tool, "BladeTip", Vector3.new(0.92, 0.08, 0.92), b * CFrame.new(0, 0, -1.25) * CFrame.Angles(0, math.rad(45), 0), s.Blade, s.BladeMat)
	newPart(tool, "LipL", Vector3.new(0.26, 0.08, 1.25), b * CFrame.new(-0.72, 0.06, -0.62) * CFrame.Angles(0, 0, math.rad(-22)), s.Blade, s.BladeMat)
	newPart(tool, "LipR", Vector3.new(0.26, 0.08, 1.25), b * CFrame.new(0.72, 0.06, -0.62) * CFrame.Angles(0, 0, math.rad(22)), s.Blade, s.BladeMat)
	-- raised spine down the back of the blade
	newPart(tool, "Spine", Vector3.new(0.16, 0.07, 1.0), b * CFrame.new(0, 0.07, -0.5), s.Metal, s.MetalMat)
	-- rolled foot step on top
	newPart(tool, "FootStep", Vector3.new(1.45, 0.13, 0.13), b, s.Metal, s.MetalMat, Enum.PartType.Cylinder)
	if s.Edge then
		newPart(tool, "EdgeL", Vector3.new(0.05, 0.1, 1.2), b * CFrame.new(-0.86, 0.12, -0.62) * CFrame.Angles(0, 0, math.rad(-22)), s.Edge, "Neon")
		newPart(tool, "EdgeR", Vector3.new(0.05, 0.1, 1.2), b * CFrame.new(0.86, 0.12, -0.62) * CFrame.Angles(0, 0, math.rad(22)), s.Edge, "Neon")
		newPart(tool, "EdgeTip", Vector3.new(0.7, 0.1, 0.05), b * CFrame.new(0, 0, -1.85), s.Edge, "Neon")
	end
	return plate
end

local function buildScoop(tool, s, b)
	local bowl = ellipsoid(tool, "Blade", Vector3.new(1.6, 0.14, 1.75), b * CFrame.new(0, 0, -0.85), s.Blade, s.BladeMat)
	ellipsoid(tool, "BowlRim", Vector3.new(1.7, 0.2, 1.85), b * CFrame.new(0, 0.05, -0.85), s.Blade, s.BladeMat).Transparency = 0.6
	newPart(tool, "Spine", Vector3.new(0.18, 0.08, 1.1), b * CFrame.new(0, 0.08, -0.55), s.Metal, s.MetalMat)
	return bowl
end

local function buildSpoon(tool, s, b)
	local bowl = ellipsoid(tool, "Blade", Vector3.new(1.35, 0.4, 1.8), b * CFrame.new(0, 0.05, -0.95), s.Blade, s.BladeMat)
	ellipsoid(tool, "BowlShell", Vector3.new(1.45, 0.3, 1.9), b * CFrame.new(0, 0, -0.95), s.Metal, s.MetalMat).Transparency = 0.5
	return bowl
end

local function buildTrowel(tool, s, b)
	local plate = newPart(tool, "Blade", Vector3.new(1.0, 0.07, 0.7), b * CFrame.new(0, 0, -0.35), s.Blade, s.BladeMat)
	newPart(tool, "BladeTip", Vector3.new(1.05, 0.07, 1.05), b * CFrame.new(0, 0, -0.95) * CFrame.Angles(0, math.rad(45), 0), s.Blade, s.BladeMat)
	newPart(tool, "Spine", Vector3.new(0.14, 0.08, 1.4), b * CFrame.new(0, 0.07, -0.75), s.Metal, s.MetalMat)
	newPart(tool, "Guard", Vector3.new(1.1, 0.14, 0.14), b, s.Metal, s.MetalMat, Enum.PartType.Cylinder)
	if s.Edge then
		newPart(tool, "EdgeL", Vector3.new(0.05, 0.1, 1.1), b * CFrame.new(-0.4, 0.06, -1.0) * CFrame.Angles(0, math.rad(-45), 0), s.Edge, "Neon")
		newPart(tool, "EdgeR", Vector3.new(0.05, 0.1, 1.1), b * CFrame.new(0.4, 0.06, -1.0) * CFrame.Angles(0, math.rad(45), 0), s.Edge, "Neon")
	end
	return plate
end

local BLADES = {Spade = buildSpade, Scoop = buildScoop, Spoon = buildSpoon, Trowel = buildTrowel}


---------------------------------------------------------------------
-- HAND-MADE CARTOON SHOVELS FOR WORLD 1
-- Tool space: the shaft runs along Z, the grip is at +Z, the blade at -Z.
-- `k.blade` is "blade space": 0 = top of the blade, -Z = toward the tip, +Y = the front face.
---------------------------------------------------------------------
local function kit(tool)
	local k = {}
	function k.part(name, size, cf, color, material, shape)
		return newPart(tool, name, size, cf, color, material or "SmoothPlastic", shape)
	end
	function k.ball(name, d, cf, color, material)
		return newPart(tool, name, Vector3.new(d, d, d), cf, color, material or "SmoothPlastic", Enum.PartType.Ball)
	end
	function k.blob(name, size, cf, color, material)
		return ellipsoid(tool, name, size, cf, color, material or "SmoothPlastic")
	end
	function k.rodZ(name, length, diameter, z, color, material) -- round bar on the shaft line
		return cylinderZ(tool, name, length, diameter, z, color, material or "SmoothPlastic")
	end
	function k.rodX(name, length, diameter, cf, color, material) -- round bar across (along X of cf)
		return newPart(tool, name, Vector3.new(length, diameter, diameter), cf, color, material or "SmoothPlastic", Enum.PartType.Cylinder)
	end
	function k.bar(name, a, b, thickness, color, material)
		return bar(tool, name, a, b, thickness, color, material or "SmoothPlastic")
	end
	k.blade = CFrame.new(0, -0.05, -2.7) * CFrame.Angles(math.rad(-14), 0, 0)
	return k
end

-- shared pieces ------------------------------------------------------
local function shaft(k, color, material, diameter)
	k.rodZ("Shaft", 5, diameter or 0.3, 0.2, color, material)
end

local function socket(k, color, material)
	k.rodZ("Socket", 0.9, 0.44, -2.35, color, material)
	k.rodZ("SocketLip", 0.14, 0.5, -1.95, color, material)
end

local function dGrip(k, frameColor, frameMat, barColor, barMat)
	k.bar("GripSideL", Vector3.new(0, 0, 2.55), Vector3.new(-0.5, 0, 3.2), 0.2, frameColor, frameMat)
	k.bar("GripSideR", Vector3.new(0, 0, 2.55), Vector3.new(0.5, 0, 3.2), 0.2, frameColor, frameMat)
	k.rodX("GripBar", 1.15, 0.28, CFrame.new(0, 0, 3.22), barColor, barMat)
end

local function tGrip(k, barColor, barMat, capColor, capMat)
	k.rodX("TBar", 1.2, 0.3, CFrame.new(0, 0, 2.7), barColor, barMat)
	k.ball("TCapL", 0.4, CFrame.new(-0.62, 0, 2.7), capColor, capMat)
	k.ball("TCapR", 0.4, CFrame.new(0.62, 0, 2.7), capColor, capMat)
end

-- a chunky cartoon spade blade: wide plate, pointed tip, curled-up sides, a foot step
local function spade(k, color, material, width, stepColor)
	width = width or 1.7
	local b = k.blade
	local plate = k.part("Blade", Vector3.new(width, 0.12, 1.5), b * CFrame.new(0, 0, -0.75), color, material)
	k.part("BladeTip", Vector3.new(width * 0.72, 0.12, width * 0.72), b * CFrame.new(0, 0, -1.5) * CFrame.Angles(0, math.rad(45), 0), color, material)
	k.part("LipL", Vector3.new(0.32, 0.12, 1.5), b * CFrame.new(-width / 2 - 0.1, 0.08, -0.75) * CFrame.Angles(0, 0, math.rad(-25)), color, material)
	k.part("LipR", Vector3.new(0.32, 0.12, 1.5), b * CFrame.new(width / 2 + 0.1, 0.08, -0.75) * CFrame.Angles(0, 0, math.rad(25)), color, material)
	k.rodX("FootStep", width + 0.3, 0.2, b, stepColor or color, material)
	return plate
end

local function light(part, color, range)
	local l = Instance.new("PointLight")
	l.Color = color
	l.Range = range or 6
	l.Brightness = 0.6
	l.Parent = part
end

local CUSTOM = {}

-- Rusty Shovel: taped-up wooden shaft, chipped rusty blade with a bolted-on patch
CUSTOM.RustyShovel = function(k)
	local wood, tape, rust = rgb(128, 88, 58), rgb(170, 170, 176), rgb(168, 92, 52)
	shaft(k, wood, "Wood")
	dGrip(k, wood, "Wood", rgb(80, 80, 86), "Fabric")
	k.rodZ("Tape", 0.5, 0.35, 0.4, tape, "Fabric")
	k.rodZ("Tape", 0.35, 0.35, -1.2, tape, "Fabric")
	socket(k, rgb(112, 72, 48), "CorrodedMetal")
	local b = k.blade
	spade(k, rust, "CorrodedMetal")
	for i, pos in ipairs({Vector3.new(-0.4, 0.07, -0.5), Vector3.new(0.45, 0.07, -1.05), Vector3.new(-0.15, 0.07, -1.45)}) do
		k.blob("RustSpot", Vector3.new(0.34 + i * 0.05, 0.03, 0.26), b * CFrame.new(pos), rgb(110, 58, 34))
	end
	k.part("Patch", Vector3.new(0.62, 0.05, 0.5), b * CFrame.new(0.35, 0.08, -0.55), rgb(150, 152, 158), "Metal")
	for _, o in ipairs({Vector3.new(-0.22, 0, -0.18), Vector3.new(0.22, 0, -0.18), Vector3.new(-0.22, 0, 0.18), Vector3.new(0.22, 0, 0.18)}) do
		k.ball("PatchBolt", 0.1, b * CFrame.new(Vector3.new(0.35, 0.12, -0.55) + o), rgb(200, 200, 205), "Metal")
	end
	k.part("Chip", Vector3.new(0.34, 0.14, 0.34), b * CFrame.new(-0.72, 0, -1.28) * CFrame.Angles(0, math.rad(45), 0), rgb(46, 36, 30))
end

-- Plastic Beach Shovel: chunky toy with a scoop, ball-ended T grip and a bucket charm
CUSTOM.PlasticShovel = function(k)
	local blue, red, yellow = rgb(70, 150, 255), rgb(255, 96, 96), rgb(255, 212, 70)
	shaft(k, blue, "SmoothPlastic", 0.38)
	tGrip(k, red, "SmoothPlastic", yellow, "SmoothPlastic")
	socket(k, red, "SmoothPlastic")
	local b = k.blade
	local bowl = k.blob("Blade", Vector3.new(2.1, 0.3, 2.3), b * CFrame.new(0, 0, -1.05), yellow)
	bowl.Reflectance = 0.1
	k.blob("ScoopRim", Vector3.new(2.25, 0.16, 2.45), b * CFrame.new(0, -0.06, -1.05), red)
	k.ball("Star", 0.3, b * CFrame.new(0.45, 0.16, -0.7), rgb(255, 255, 255))
	-- little bucket charm hanging off the shaft
	k.part("CharmString", Vector3.new(0.04, 0.56, 0.04), CFrame.new(0, -0.47, 1.6), rgb(255, 255, 255))
	k.part("Bucket", Vector3.new(0.4, 0.5, 0.5), CFrame.new(0, -0.95, 1.6) * CFrame.Angles(0, 0, math.rad(90)), rgb(96, 226, 190), "SmoothPlastic", Enum.PartType.Cylinder)
end

-- Garden Spade: green painted shaft, shiny pointed blade with little painted flowers
CUSTOM.GardenSpade = function(k)
	local green, dark = rgb(90, 176, 96), rgb(58, 128, 66)
	shaft(k, green, "SmoothPlastic")
	for z = -1.4, 1.6, 0.75 do
		k.rodZ("Stripe", 0.12, 0.32, z, rgb(246, 247, 252))
	end
	dGrip(k, dark, "SmoothPlastic", dark, "SmoothPlastic")
	socket(k, dark, "SmoothPlastic")
	local b = k.blade
	spade(k, rgb(200, 206, 216), "Metal", 1.55, dark).Reflectance = 0.15
	for _, spot in ipairs({Vector3.new(-0.35, 0.09, -0.55), Vector3.new(0.35, 0.09, -1.05)}) do
		k.ball("FlowerCore", 0.22, b * CFrame.new(spot), rgb(255, 212, 70))
		for i = 0, 4 do
			local a = math.rad(i * 72)
			k.ball("Petal", 0.2, b * CFrame.new(spot + Vector3.new(math.cos(a) * 0.19, -0.02, math.sin(a) * 0.19)), rgb(255, 140, 190))
		end
	end
	k.blob("Leaf", Vector3.new(0.55, 0.07, 0.28), CFrame.new(0.2, 0.12, -1.6) * CFrame.Angles(0, math.rad(30), math.rad(20)), rgb(110, 200, 110))
end

-- Iron Shovel: sturdy dark wood, leather wrap, iron bands, riveted heavy blade
CUSTOM.IronShovel = function(k)
	local wood, iron = rgb(98, 68, 46), rgb(76, 78, 86)
	shaft(k, wood, "Wood", 0.33)
	k.rodZ("LeatherWrap", 1.1, 0.38, 1.75, rgb(128, 84, 52), "Fabric")
	for _, z in ipairs({0.6, -0.9}) do
		k.rodZ("IronBand", 0.16, 0.4, z, iron, "Metal")
	end
	dGrip(k, iron, "Metal", wood, "Wood")
	socket(k, iron, "Metal")
	local b = k.blade
	k.part("BladeBacking", Vector3.new(1.95, 0.08, 1.7), b * CFrame.new(0, -0.05, -0.8), iron, "Metal")
	spade(k, rgb(128, 132, 142), "Metal", 1.75, iron).Reflectance = 0.1
	for i = -2, 2 do
		k.ball("Rivet", 0.14, b * CFrame.new(i * 0.34, 0.08, -0.18), rgb(190, 192, 198), "Metal")
	end
end

-- Steel Spade: sleek dark shaft, polished pointed blade with a sky-blue racing stripe
CUSTOM.SteelSpade = function(k)
	local dark, steel, sky = rgb(52, 58, 72), rgb(206, 214, 228), rgb(92, 186, 255)
	shaft(k, dark, "Metal", 0.28)
	k.rodZ("Grip", 1, 0.34, 1.9, rgb(30, 32, 40), "Fabric")
	tGrip(k, rgb(30, 32, 40), "Fabric", steel, "Metal")
	socket(k, steel, "Metal")
	local b = k.blade
	local plate = spade(k, steel, "Metal", 1.5)
	plate.Reflectance = 0.3
	k.part("RacingStripe", Vector3.new(0.2, 0.13, 1.7), b * CFrame.new(0, 0.02, -0.9), sky)
	k.part("TipGuard", Vector3.new(0.5, 0.14, 0.5), b * CFrame.new(0, 0.01, -1.72) * CFrame.Angles(0, math.rad(45), 0), sky)
	k.ball("StatusLight", 0.16, CFrame.new(0, 0.22, -2.1), sky, "Neon")
end

-- Golden Shovel: gold everything, a jeweled socket, a little crown on the foot step
CUSTOM.GoldenShovel = function(k)
	local gold, deep = rgb(255, 202, 72), rgb(214, 156, 40)
	shaft(k, gold, "Metal", 0.3)
	for _, z in ipairs({1.9, 1.5}) do
		k.rodZ("Wrap", 0.2, 0.34, z, rgb(150, 30, 50), "Fabric")
	end
	dGrip(k, gold, "Metal", rgb(150, 30, 50), "Fabric")
	socket(k, deep, "Metal")
	local gems = {rgb(230, 50, 80), rgb(70, 130, 255), rgb(60, 205, 130)}
	for i, color in ipairs(gems) do
		local a = math.rad(i * 120)
		k.ball("Gem", 0.2, CFrame.new(math.cos(a) * 0.22, math.sin(a) * 0.22, -2.3), color, "Glass")
	end
	local b = k.blade
	spade(k, gold, "Metal", 1.7, deep).Reflectance = 0.35
	for i = -1, 1 do
		k.part("CrownSpike", Vector3.new(0.18, 0.12, 0.3), b * CFrame.new(i * 0.45, 0.05, 0.22) * CFrame.Angles(0, math.rad(45), 0), deep, "Metal")
		k.ball("CrownJewel", 0.12, b * CFrame.new(i * 0.45, 0.1, 0.35), gems[i + 2], "Glass")
	end
	local sparkles = Instance.new("ParticleEmitter")
	sparkles.Rate = 4
	sparkles.Lifetime = NumberRange.new(0.6, 1.2)
	sparkles.Speed = NumberRange.new(0.3, 0.8)
	sparkles.SpreadAngle = Vector2.new(180, 180)
	sparkles.LightEmission = 0.6
	sparkles.Color = ColorSequence.new(rgb(255, 230, 150))
	sparkles.Parent = k.ball("SparkleSource", 0.05, b * CFrame.new(0, 0.1, -0.8), gold)
end

-- RGB Gamer Shovel: black with RGB strips, a controller grip and WASD keycaps on the blade
CUSTOM.GamerShovel = function(k)
	local black = rgb(30, 30, 38)
	shaft(k, black, "Metal", 0.3)
	local strips = {rgb(230, 90, 200), rgb(80, 200, 230), rgb(110, 225, 130)}
	for i, color in ipairs(strips) do
		local a = math.rad(i * 120)
		k.part("RGBStrip", Vector3.new(0.05, 0.05, 3), CFrame.new(math.cos(a) * 0.15, math.sin(a) * 0.15, 0.1), color, "Neon")
	end
	-- controller-shaped grip with thumbsticks and buttons
	k.blob("Controller", Vector3.new(1.5, 0.4, 0.7), CFrame.new(0, 0, 2.8), rgb(44, 44, 54))
	k.ball("StickL", 0.2, CFrame.new(-0.35, 0.2, 2.8), rgb(120, 122, 132))
	for i, color in ipairs({rgb(110, 225, 130), rgb(230, 90, 110), rgb(80, 160, 240), rgb(240, 200, 80)}) do
		local a = math.rad(i * 90)
		k.ball("Button", 0.11, CFrame.new(0.38 + math.cos(a) * 0.12, 0.2, 2.8 + math.sin(a) * 0.12), color)
	end
	socket(k, black, "Metal")
	local b = k.blade
	spade(k, rgb(40, 40, 52), "Metal", 1.7)
	k.part("EdgeL", Vector3.new(0.06, 0.14, 1.4), b * CFrame.new(-0.95, 0.14, -0.75) * CFrame.Angles(0, 0, math.rad(-25)), strips[1], "Neon")
	k.part("EdgeR", Vector3.new(0.06, 0.14, 1.4), b * CFrame.new(0.95, 0.14, -0.75) * CFrame.Angles(0, 0, math.rad(25)), strips[2], "Neon")
	for _, key in ipairs({Vector3.new(0, 0, -0.55), Vector3.new(-0.34, 0, -0.9), Vector3.new(0, 0, -0.9), Vector3.new(0.34, 0, -0.9)}) do
		k.part("Keycap", Vector3.new(0.28, 0.14, 0.28), b * CFrame.new(key + Vector3.new(0, 0.1, 0)), rgb(236, 236, 244))
	end
end

-- Tectonic Auger: industrial drill with hazard bands, a motor and a spiral auger bit
CUSTOM.TectonicAuger = function(k)
	local steel, hazard, ink = rgb(172, 176, 186), rgb(240, 196, 60), rgb(44, 44, 54)
	shaft(k, rgb(78, 80, 88), "Metal", 0.34)
	for i = 0, 5 do
		k.rodZ("Hazard", 0.18, 0.38, 1.1 - i * 0.18, i % 2 == 0 and hazard or ink)
	end
	tGrip(k, rgb(36, 36, 42), "Fabric", hazard, "SmoothPlastic")
	local motor = k.part("Motor", Vector3.new(0.75, 0.65, 1), CFrame.new(0, 0, -1.35), hazard)
	k.part("MotorVent", Vector3.new(0.5, 0.04, 0.6), CFrame.new(0, 0.34, -1.35), rgb(230, 130, 70), "Neon")
	light(motor, rgb(230, 150, 90), 5)
	k.rodZ("Core", 2.6, 0.26, -2.95, steel, "Metal")
	-- spiral flights: shrinking discs, each turned a bit more
	for i = 0, 7 do
		local d = 1.4 - i * 0.14
		k.part("Flight", Vector3.new(0.1, d, d), CFrame.new(0, 0, -2.1 - i * 0.3) * CFrame.Angles(0, math.rad(90), 0) * CFrame.Angles(math.rad(i * 25), 0, math.rad(12)), steel, "Metal", Enum.PartType.Cylinder)
	end
	k.ball("DrillTip", 0.3, CFrame.new(0, 0, -4.35), hazard)
end

-- Singularity Spade: dark foil blade holding a tiny black hole with a glowing disk
CUSTOM.SingularitySpade = function(k)
	local dark, lilac, chrome = rgb(34, 35, 42), rgb(178, 158, 255), rgb(150, 154, 162)
	shaft(k, dark, "Metal", 0.3)
	for _, z in ipairs({1, 0, -1}) do
		k.rodZ("Ring", 0.12, 0.38, z, lilac)
	end
	dGrip(k, chrome, "Foil", dark, "Fabric")
	socket(k, chrome, "Foil")
	local b = k.blade
	spade(k, rgb(56, 58, 66), "Foil", 1.75, chrome).Reflectance = 0.3
	local hole = b * CFrame.new(0, 0.22, -0.85)
	k.ball("BlackHole", 0.7, hole, rgb(6, 6, 10))
	k.part("AccretionDisk", Vector3.new(0.04, 1.5, 1.5), hole * CFrame.Angles(math.rad(18), 0, math.rad(90)), rgb(220, 140, 100), "Neon", Enum.PartType.Cylinder)
	k.part("InnerDisk", Vector3.new(0.05, 1.05, 1.05), hole * CFrame.Angles(math.rad(18), 0, math.rad(90)), lilac, "Neon", Enum.PartType.Cylinder)
	for i = 0, 2 do
		local a = math.rad(i * 120 + 30)
		k.ball("Orbiter", 0.12, hole * CFrame.new(math.cos(a) * 0.95, 0.1, math.sin(a) * 0.95), lilac, "Neon")
	end
	light(k.ball("HoleGlow", 0.05, hole, dark), rgb(200, 170, 255), 6)
end

---------------------------------------------------------------------
-- BUILD A SHOVEL TOOL
---------------------------------------------------------------------
return function(def)
	local s = STYLES[def.Id] or defaultStyle(def)

	local tool = Instance.new("Tool")
	tool.Name = def.Name
	tool.ToolTip = def.Name
	tool.CanBeDropped = false
	tool.RequiresHandle = true
	tool:SetAttribute("ShovelId", def.Id)

	-- invisible handle the hand holds; everything else is welded to it
	local handle = newPart(tool, "Handle", Vector3.new(0.3, 0.3, 4.4), CFrame.new(), s.Shaft, s.ShaftMat)
	handle.Transparency = 1

	local custom = CUSTOM[def.Id]
	if custom then
		custom(kit(tool), def)
	else
		-- SHAFT with metal collars
		cylinderZ(tool, "Shaft", 4.4, 0.22, 0, s.Shaft, s.ShaftMat)
		cylinderZ(tool, "CollarTop", 0.14, 0.27, 0.95, s.Metal, s.MetalMat)
		cylinderZ(tool, "CollarMid", 0.14, 0.27, -1.0, s.Metal, s.MetalMat)
		cylinderZ(tool, "GripWrap", 0.9, 0.27, 1.45, s.GripColor, s.GripMat)
		if s.Tape then
			cylinderZ(tool, "DuctTape", 0.45, 0.25, -0.2, rgb(150, 150, 155), "Fabric")
		end

		-- accent strips along the shaft (RGB lights, rainbow, circuits...)
		if s.Strips then
			local offsets = {Vector3.new(0, 0.115, 0), Vector3.new(0.115, 0, 0), Vector3.new(0, -0.115, 0), Vector3.new(-0.115, 0, 0)}
			for i, color in ipairs(s.Strips) do
				local o = offsets[(i - 1) % 4 + 1]
				newPart(tool, "Strip", Vector3.new(0.04, 0.04, 2.6), CFrame.new(o + Vector3.new(0, 0, -0.45)), color, "Neon")
			end
		end

		-- HANDLE GRIP at the top
		if s.Grip == "T" then
			newPart(tool, "TBar", Vector3.new(0.95, 0.2, 0.2), CFrame.new(0, 0, 2.3), s.GripColor, s.GripMat, Enum.PartType.Cylinder)
			newPart(tool, "TCapL", Vector3.new(0.08, 0.24, 0.24), CFrame.new(-0.5, 0, 2.3), s.Metal, s.MetalMat, Enum.PartType.Cylinder)
			newPart(tool, "TCapR", Vector3.new(0.08, 0.24, 0.24), CFrame.new(0.5, 0, 2.3), s.Metal, s.MetalMat, Enum.PartType.Cylinder)
		else
			bar(tool, "GripSideL", Vector3.new(0, 0, 2.15), Vector3.new(-0.42, 0, 2.8), 0.15, s.Shaft, s.ShaftMat)
			bar(tool, "GripSideR", Vector3.new(0, 0, 2.15), Vector3.new(0.42, 0, 2.8), 0.15, s.Shaft, s.ShaftMat)
			newPart(tool, "GripBar", Vector3.new(0.95, 0.19, 0.19), CFrame.new(0, 0, 2.82), s.GripColor, s.GripMat, Enum.PartType.Cylinder)
		end

		-- SOCKET where the blade meets the shaft
		cylinderZ(tool, "Socket", 0.8, 0.3, -2.35, s.Metal, s.MetalMat)
		if s.Rivets then
			newPart(tool, "RivetL", Vector3.new(0.09, 0.09, 0.09), CFrame.new(-0.15, 0, -2.35), rgb(200, 200, 205), "Metal", Enum.PartType.Ball)
			newPart(tool, "RivetR", Vector3.new(0.09, 0.09, 0.09), CFrame.new(0.15, 0, -2.35), rgb(200, 200, 205), "Metal", Enum.PartType.Ball)
		end

		-- BLADE (slightly angled like a real spade)
		local bladeCF = CFrame.new(0, -0.05, -2.7) * CFrame.Angles(math.rad(-14), 0, 0)
		local blade = (BLADES[s.Shape] or buildSpade)(tool, s, bladeCF)
		for _, part in ipairs(tool:GetChildren()) do
			if part:IsA("BasePart") and (part.Name:find("Blade") or part.Name:find("Lip")) then
				part.Reflectance = s.Shine or 0
				part.Transparency = math.max(part.Transparency, s.BladeTransparency or 0)
			end
		end

		-- EXTRAS
		if s.Rust then
			local spots = {Vector3.new(-0.3, 0.05, -0.4), Vector3.new(0.35, 0.05, -0.85), Vector3.new(-0.1, 0.05, -1.1), Vector3.new(0.2, 0.05, -0.25)}
			for i, pos in ipairs(spots) do
				newPart(tool, "RustSpot", Vector3.new(0.18 + i * 0.03, 0.02, 0.16), bladeCF * CFrame.new(pos) * CFrame.Angles(0, i, 0), rgb(95, 52, 30), "CorrodedMetal")
			end
		end
		if s.Pixels then
			for i = 0, 3 do
				newPart(tool, "Pixel", Vector3.new(0.22, 0.1, 0.22), bladeCF * CFrame.new(-0.35 + (i % 2) * 0.7, 0.06, -0.35 - math.floor(i / 2) * 0.5), s.Edge or rgb(255, 255, 255), "SmoothPlastic")
			end
		end
		if s.Core then
			ellipsoid(tool, "Core", Vector3.new(0.5, 0.12, 0.7), bladeCF * CFrame.new(0, 0.05, -0.8), s.Core, "Neon")
		end
		if s.Field then
			local field = newPart(tool, "EnergyField", Vector3.new(1.5, 0.3, 2.1), bladeCF * CFrame.new(0, 0, -0.9), s.Field, "ForceField")
			field.Transparency = 0.2
		end
		if s.Rings then
			for i, z in ipairs({-1.4, -1.8}) do
				newPart(tool, "Ring", Vector3.new(0.05, 0.42 + i * 0.05, 0.42 + i * 0.05), CFrame.new(0, 0, z) * ALONG_Z, s.Rings, "Neon", Enum.PartType.Cylinder).Transparency = 0.3
			end
		end
		if s.Glow then
			local light = Instance.new("PointLight")
			light.Color = s.Glow
			light.Range = 8
			light.Brightness = 1.3
			light.Parent = blade
		end
		if s.Sparkles then
			local sparkles = Instance.new("ParticleEmitter")
			sparkles.Rate = 5
			sparkles.Lifetime = NumberRange.new(0.6, 1.2)
			sparkles.Speed = NumberRange.new(0.3, 0.8)
			sparkles.SpreadAngle = Vector2.new(180, 180)
			sparkles.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.12), NumberSequenceKeypoint.new(1, 0)})
			sparkles.LightEmission = 1
			sparkles.Color = ColorSequence.new(s.Sparkles)
			sparkles.Parent = blade
		end

	end

	-- SIZE: shrink the whole shovel evenly
	for _, part in ipairs(tool:GetChildren()) do
		if part:IsA("BasePart") then
			local rotation = part.CFrame.Rotation
			part.Size = part.Size * SCALE
			part.CFrame = CFrame.new(part.Position * SCALE) * rotation
		end
	end
	for _, emitter in ipairs(tool:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.12 * SCALE), NumberSequenceKeypoint.new(1, 0)})
		end
	end

	-- how it sits in the hand (points forward and down)
	tool.Grip = CFrame.new(0, 0, 1.4 * SCALE) * CFrame.Angles(math.rad(50), 0, 0)

	-- weld everything to the handle
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
-- One cartoony 2050 look for every screen in the game: chunky rounded panels with thick
-- outlines, bubbly FredokaOne text with an outline, bouncy buttons, pop-in windows and
-- live 3D shovel icons (ViewportFrames that render the real shovel model).

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIKit = {}

local rgb = Color3.fromRGB
UIKit.Colors = {
	Ink = rgb(38, 34, 84),        -- outlines and dark text
	Panel = rgb(250, 248, 255),   -- window background
	PanelTint = rgb(232, 226, 255),
	Row = rgb(238, 234, 252),
	Violet = rgb(122, 92, 232),
	Lilac = rgb(178, 158, 255),
	Sky = rgb(92, 176, 255),
	Mint = rgb(80, 214, 150),
	Sun = rgb(255, 200, 70),
	Coral = rgb(255, 110, 124),
	Grey = rgb(160, 160, 184),
	White = rgb(255, 255, 255),
	Money = rgb(90, 210, 110),
}
local C = UIKit.Colors
UIKit.Font = Enum.Font.FredokaOne

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

-- soft top-to-bottom shading so flat panels look chunky
function UIKit.shade(parent, amount)
	local g = Instance.new("UIGradient")
	g.Rotation = 90
	g.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1 - (amount or 0.12), 1 - (amount or 0.12), 1 - (amount or 0.1)))
	g.Parent = parent
	return g
end

-- A plain rounded, outlined box. props: Size, Position, AnchorPoint, Color, Radius, Stroke
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
		UIKit.outline(f, props.Stroke or 3)
	end
	if props.Shade ~= false then
		UIKit.shade(f, props.ShadeAmount)
	end
	return f
end

-- Bubbly outlined text. props: Size, Position, AnchorPoint, Color, Align ("Left"/"Center"/"Right"),
-- Stroke (outline thickness, 0 for none), TextSize (fixed size instead of scaled)
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

-- Chunky button that squishes when pressed and grows a bit on hover.
-- props: Size, Position, AnchorPoint, Color, TextColor
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
	UIKit.corner(b, props.Radius or 12)
	UIKit.outline(b, 3)
	UIKit.shade(b, 0.18)
	local label = UIKit.label(b, text, {
		Size = UDim2.new(1, -14, 1, -12), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
		Color = props.TextColor or C.White,
	})
	label.Name = "Label"
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

---------------------------------------------------------------------
-- WINDOW: a big panel with a colored title tab and a round close button
-- returns window, content (frame to put things in), closeButton
---------------------------------------------------------------------
function UIKit.window(gui, title, size, accent)
	local window = UIKit.panel(gui, {
		Size = size, Position = UDim2.fromScale(0.5, 0.52), AnchorPoint = Vector2.new(0.5, 0.5),
		Color = C.Panel, Radius = 22, Stroke = 4,
	})
	window.Visible = false
	local sizeLimit = Instance.new("UISizeConstraint")
	sizeLimit.MaxSize = Vector2.new(size.X.Offset, size.Y.Offset)
	sizeLimit.Parent = window
	local aspect = Instance.new("UIAspectRatioConstraint")
	aspect.AspectRatio = size.X.Offset / size.Y.Offset
	aspect.Parent = window
	window.Size = UDim2.fromScale(0.92, 0.85)

	local tab = UIKit.panel(window, {
		Size = UDim2.new(0.5, 0, 0, 52), Position = UDim2.new(0.5, 0, 0, -20), AnchorPoint = Vector2.new(0.5, 0),
		Color = accent or C.Violet, Radius = 16, Stroke = 4,
	})
	UIKit.label(tab, title, {Size = UDim2.new(1, -20, 1, -12), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 3})

	local close = UIKit.button(window, "X", {
		Size = UDim2.fromOffset(46, 46), Position = UDim2.new(1, 14, 0, -14), AnchorPoint = Vector2.new(1, 0), Color = C.Coral, Radius = 23,
	})
	close.MouseButton1Click:Connect(function()
		window.Visible = false
	end)

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundTransparency = 1
	content.Size = UDim2.new(1, -36, 1, -64)
	content.Position = UDim2.new(0, 18, 0, 46)
	content.Parent = window
	return window, content, close
end

function UIKit.open(window)
	window.Visible = true
	UIKit.pop(window)
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
	UIKit.label(row, name, {Size = UDim2.new(0.26, 0, 1, 0), Align = "Left", Color = C.Ink, Stroke = 0})
	local track = UIKit.panel(row, {Size = UDim2.new(0.46, 0, 0.7, 0), Position = UDim2.new(0.27, 0, 0.15, 0), Color = rgb(222, 218, 240), Radius = 8, Stroke = 2, Shade = false})
	local fill = UIKit.panel(track, {Size = UDim2.new(math.clamp(fraction, 0.04, 1), 0, 1, 0), Color = color, Radius = 8, Stroke = false})
	fill.Name = "Fill"
	UIKit.label(row, valueText, {Size = UDim2.new(0.25, 0, 1, 0), Position = UDim2.new(0.75, 0, 0, 0), Align = "Right", Color = C.Ink, Stroke = 0})
	return row
end

---------------------------------------------------------------------
-- 3D SHOVEL ICON: renders the real shovel model inside a ViewportFrame
---------------------------------------------------------------------
local ShovelModels -- loaded on first use (only needed where icons are drawn)
function UIKit.shovelIcon(parent, def, props)
	props = props or {}
	ShovelModels = ShovelModels or require(ReplicatedStorage:WaitForChild("ShovelModels"))
	local vp = Instance.new("ViewportFrame")
	vp.Size = props.Size or UDim2.fromOffset(80, 80)
	vp.Position = props.Position or UDim2.new()
	vp.AnchorPoint = props.AnchorPoint or Vector2.zero
	vp.BackgroundTransparency = 1
	vp.Ambient = rgb(200, 198, 215)
	vp.LightColor = rgb(255, 250, 240)
	vp.LightDirection = Vector3.new(-1, -1.5, -1)
	vp.Parent = parent

	-- lay the shovel diagonally: blade at the bottom-left, grip at the top-right
	local tool = ShovelModels(def)
	local model = Instance.new("Model")
	local pose = CFrame.Angles(0, math.rad(20), 0) * CFrame.Angles(0, 0, math.rad(135)) * CFrame.Angles(math.rad(90), 0, 0)
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
local SLOGANS = {"DIG DEEPER!", "MEMES 4 SALE", "VISIT THE ABYSS", "RATE MY MUSEUM", "SHOVEL SALE 50% OFF", "NO BRAINROT ZONE"}
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
install(game:GetService("ServerScriptService"), "Architecture", "ModuleScript", [=[
-- Architecture (ModuleScript in ServerScriptService)
-- Shared building kit for the cartoony 2050 look: chunky rounded shapes (discs, capsules,
-- domes, rings, arches, rounded blocks), a bright soft palette (white, lilac, sky, mint,
-- sunshine) and gentle pastel glow trims.
-- ShopBuilder, WorldGate and MuseumStyle all build with this.

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
		base(b, w, rng, accent)
		STYLES[(i - 1) % #STYLES + 1](b, w, h, rng, body, accent, glow)
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
local ShovelModels = require(ReplicatedStorage:WaitForChild("ShovelModels"))
local ShopBuilder = require(script.Parent:WaitForChild("ShopBuilder"))
local WorldGate = require(script.Parent:WaitForChild("WorldGate"))

local terrain = workspace.Terrain

---------------------------------------------------------------------
-- SETTINGS
---------------------------------------------------------------------
local MINIGAME_TIMEOUT = 8
local MINIGAME_LUCK = {Perfect = 3, Good = 1.5, Miss = 1} -- multiplies the shovel's luck
local ANNOUNCE_FROM = ArtifactData.GetRarityIndex("Mythic")
local MAX_REACH = 14 -- how far from your character you can dig
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

local function giveArtifact(player, zone, luck, grade)
	local artifact = ArtifactData.RollForZone(zone, luck)
	local data = PlayerData.Get(player)
	if not artifact or not data then return end

	PlayerData.AddArtifact(player, artifact.Id)
	data.Stats.TotalDigs += 1

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
	})
	if rarityIndex >= ANNOUNCE_FROM then
		announceRemote:FireAllClients(player.DisplayName .. " found a " .. string.upper(artifact.Rarity) .. " " .. artifact.Name .. " in " .. zone.Name .. "!", rarity.Color)
	end
end

local function finishLuckyDig(player, grade)
	local session = sessions[player]
	if not session then return end
	sessions[player] = nil
	giveArtifact(player, session.Zone, session.ShovelLuck * (MINIGAME_LUCK[grade] or 1), grade)
end

local function onFind(player, def, zone)
	if rng:NextNumber() < GameConfig.MinigameChance then
		local session = {Started = os.clock(), ShovelLuck = def.Luck, Zone = zone}
		sessions[player] = session
		minigameRemote:FireClient(player)
		task.delay(MINIGAME_TIMEOUT, function()
			if sessions[player] == session then
				finishLuckyDig(player, "Miss")
			end
		end)
	else
		giveArtifact(player, zone, def.Luck, nil)
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

swingRemote.OnServerEvent:Connect(function(player, target)
	if resetting or sessions[player] then return end
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
		return
	end

	-- Carve the hole and throw dirt. Wide but one block deep, plus the block above so tunnels
	-- are tall enough to walk into. Never carve below the bottom of the shovel's deepest zone.
	local floorY = origin.Y + world.Zones[def.MaxZone].Bottom
	local bottomY = math.max(carveAt.Y - 2, floorY)
	local topY = carveAt.Y + 6
	if topY > bottomY then
		terrain:FillBlock(CFrame.new(carveAt.X, (topY + bottomY) / 2, carveAt.Z),
			Vector3.new(def.DigRadius + 2, topY - bottomY, def.DigRadius + 2), Enum.Material.Air)
	end
	burst(target, zone.Color)

	-- Did we find something?
	if rng:NextNumber() < def.FindChance then
		onFind(player, def, zone)
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

task.spawn(function()
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
end

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
	sessions[player] = nil
	currentWorld[player] = nil
	lastBounceMessage[player] = nil
end)

print("DigManager ready: " .. #enabledWorlds() .. " world(s), 560-stud pits, shovel depth zones active")
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
install(game:GetService("ServerScriptService"), "MapStyle", "Script", [=[
-- MapStyle (Script in ServerScriptService)
-- Gives the whole map the cartoony 2050 look when the server starts:
-- rebuilds the skyline, restyles the dig site, brightens the ground and the sky, and sets
-- calm, clean lighting (soft shadows, very little bloom, glow only on small accents).

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local CityBuilder = require(script.Parent:WaitForChild("CityBuilder"))
local DigSiteStyle = require(script.Parent:WaitForChild("DigSiteStyle"))
local Architecture = require(script.Parent:WaitForChild("Architecture"))

-- Set to false to keep the place's own sky and time of day (the calm lighting still applies)
local SUNNY_SKY = true

---------------------------------------------------------------------
-- GROUND
---------------------------------------------------------------------
for _, part in ipairs(workspace:GetChildren()) do
	if part:IsA("BasePart") and part.Name:find("^Baseplate") then
		part.Material = Enum.Material.SmoothPlastic
		part.Color = Color3.fromRGB(196, 202, 228)
	end
end
local spawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")
if spawnLocation then
	spawnLocation.Material = Enum.Material.SmoothPlastic
	spawnLocation.Color = Color3.fromRGB(178, 158, 255)
end

-- Terrain colors: bright cartoon grass on top, soft stone walls, warm dig layers
local terrain = workspace.Terrain
terrain:SetMaterialColor(Enum.Material.Grass, Color3.fromRGB(112, 204, 108))
terrain:SetMaterialColor(Enum.Material.Slate, Color3.fromRGB(150, 146, 172))
terrain:SetMaterialColor(Enum.Material.Ground, Color3.fromRGB(176, 124, 84))
terrain:SetMaterialColor(Enum.Material.Sandstone, Color3.fromRGB(222, 180, 120))
terrain:SetMaterialColor(Enum.Material.Glacier, Color3.fromRGB(150, 210, 240))
terrain:SetMaterialColor(Enum.Material.Basalt, Color3.fromRGB(70, 64, 96))

---------------------------------------------------------------------
-- CITY + DIG SITE
---------------------------------------------------------------------
local city = workspace:FindFirstChild("City")
if city then
	CityBuilder.build(city)
end
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
		if not (child:IsA("Model") and game:GetService("Players"):GetPlayerFromCharacter(child)) then
			Architecture.calm(child)
		end
	end
end
calmWorld()
task.delay(5, calmWorld)

print("MapStyle: cartoony 2050 skyline, dig site and sky ready")
]=])
install(game:GetService("ServerScriptService"), "MuseumStyle", "ModuleScript", [=[
-- MuseumStyle (ModuleScript in ServerScriptService)
-- Restyles ServerStorage.MuseumTemplate once, on server start, before any museum is cloned:
--   1. Softens the colors into a friendly cartoony palette (pastel glow instead of harsh
--      neon, playful indigo instead of dark navy, cartoon trees instead of glowing glass).
--   2. Adds chunky rounded 2050 architecture to the outside: capsule corner towers with
--      domed caps, a glass bubble dome on the roof, porthole windows, rounded floor bands,
--      a bubble canopy and capsule pillars at the entrance, and floating orb pedestals.
-- Slot, elevator and sign parts keep their names and positions, so nothing that looks
-- them up by name breaks.

local Architecture = require(script.Parent:WaitForChild("Architecture"))
local P = Architecture.Palette

local function near(c, r, g, b)
	return math.abs(c.R * 255 - r) < 12 and math.abs(c.G * 255 - g) < 12 and math.abs(c.B * 255 - b) < 12
end

local function apply(part, finish)
	part.Color = finish.Color
	part.Material = finish.Material
	if finish.Transparency then part.Transparency = finish.Transparency end
	if finish.Reflectance then part.Reflectance = finish.Reflectance end
end

local function hasGui(part)
	return part:FindFirstChildWhichIsA("SurfaceGui") ~= nil
end

---------------------------------------------------------------------
-- 1. PALETTE PASS
---------------------------------------------------------------------
local function restylePart(part)
	local c = part.Color
	local m = part.Material

	if m == Enum.Material.Neon then
		-- keep the hue, make it a soft pastel glow instead of a blinding one
		part.Color = c:Lerp(Color3.new(0.8, 0.8, 0.85), 0.2)
	elseif m == Enum.Material.Glass then
		local name = part.Name
		if name == "Bush" or name == "TreeCrown" or name == "Leaves" then
			-- glowing sci-fi foliage becomes chunky cartoon greenery
			part.Material = Enum.Material.SmoothPlastic
			part.Color = Color3.fromRGB(96, 214, 150)
			part.Transparency = 0
		else
			apply(part, P.Glass)
		end
	elseif m == Enum.Material.Grass then
		part.Material = Enum.Material.SmoothPlastic
		part.Color = Color3.fromRGB(110, 200, 120)
	elseif m == Enum.Material.SmoothPlastic or m == Enum.Material.Plastic then
		if near(c, 238, 240, 245) then
			apply(part, P.White)
		elseif near(c, 222, 226, 234) or near(c, 208, 212, 220) then
			apply(part, P.Cloud)
		elseif near(c, 28, 34, 60) or near(c, 20, 22, 34) or near(c, 40, 32, 66) then
			apply(part, hasGui(part) and P.Ink or P.Navy)
		end
	end
end

local function restyleDescendant(d)
	if d:IsA("BasePart") then
		restylePart(d)
	elseif d:IsA("UIStroke") then
		d.Color = Color3.fromRGB(30, 26, 70)
	end
end

---------------------------------------------------------------------
-- 2. ARCHITECTURE PASS (template coordinates: entrance faces -Z,
--    building spans X -48..48, Z 28..163, Y 0..96, floors every 32)
---------------------------------------------------------------------
local function addArchitecture(template)
	local folder = Instance.new("Folder")
	folder.Name = "Architecture"
	folder.Parent = template
	-- the template's own space: every template part position is measured from here
	local b = Architecture.builder(folder, CFrame.new())

	-- A. Capsule corner towers: round shells, colored bands per floor, domed caps with a bulb
	local bandColors = {"Sky", "Lilac", "Mint"}
	for _, x in ipairs({-48, 48}) do
		for _, z in ipairs({27, 163}) do
			b:disc("TowerShell", 8, 99, CFrame.new(x, 49.5, z), "White")
			b:disc("TowerFoot", 9.6, 1.4, CFrame.new(x, 0.7, z), "Violet")
			for i, y in ipairs({32, 64, 96}) do
				b:disc("TowerBand", 8.8, 1.6, CFrame.new(x, y, z), bandColors[i])
			end
			b:ellipsoid("TowerDome", Vector3.new(8.8, 7, 8.8), CFrame.new(x, 99, z), "Lilac")
			b:bulb("TowerBulb", 1.6, CFrame.new(x, 103.2, z), "GlowSun", 16)
		end
	end

	-- B. Rounded floor bands wrapping the front and both sides
	for i, y in ipairs({32.4, 64.4}) do
		local finish = i == 1 and "Sky" or "Lilac"
		b:rod("FrontBand", 96, 2.2, CFrame.new(0, y, 27.1), finish)
		for _, side in ipairs({-1, 1}) do
			b:rod("SideBand", 134, 2.2, CFrame.new(side * 48.6, y, 95) * CFrame.Angles(0, math.rad(90), 0), finish)
		end
	end

	-- C. Round porthole windows along both side walls, between the existing fins
	for _, side in ipairs({-1, 1}) do
		for z = 47, 143, 16 do
			for _, y in ipairs({16, 48, 80}) do
				b:rod("PortholeRim", 0.7, 9.4, CFrame.new(side * 47.3, y, z), "Lilac")
				b:rod("PortholeGlass", 0.8, 7.6, CFrame.new(side * 47.35, y, z), "Glass")
				b:ball("PortholeShine", 1.4, CFrame.new(side * 47.75, y + 1.9, z - 1.9), "White", {CastShadow = false})
			end
		end
	end

	-- D. Entrance: bubble canopy, capsule pillars, rounded sign backing
	b:ellipsoid("CanopyBubble", Vector3.new(38, 3.4, 13), CFrame.new(0, 25.2, 24.5), "Sky")
	b:ellipsoid("CanopyBubbleTop", Vector3.new(34, 2.2, 10.5), CFrame.new(0, 26.4, 24.5), "White")
	for i = -3, 3 do
		b:bulb("CanopyBulb", 0.9, CFrame.new(i * 5, 23.7, 18.5), i % 2 == 0 and "GlowSun" or "GlowPink", 8)
	end
	for _, side in ipairs({-1, 1}) do
		b:disc("PillarShell", 7, 22.4, CFrame.new(side * 14, 11.2, 27), "Lilac")
		b:ball("PillarTop", 7.2, CFrame.new(side * 14, 22.4, 27), "Lilac")
		b:disc("PillarBand", 7.6, 1.2, CFrame.new(side * 14, 6, 27), "Sun")
		b:disc("PillarBand", 7.6, 1.2, CFrame.new(side * 14, 17, 27), "Sun")
		b:disc("PillarFoot", 8.6, 1.2, CFrame.new(side * 14, 0.6, 27), "Violet")
	end
	b:roundedBlock("EntranceSignBack", Vector3.new(40, 10.6, 0.8), CFrame.new(0, 30, 24.2), 3, "Violet")
	b:roundedBlock("RoofSignBack", Vector3.new(53.5, 12, 1), CFrame.new(0, 103.5, 34.5), 3.5, "Violet")

	-- E. Glass bubble dome on the roof with a floating meme orb inside
	b:disc("DomeDrum", 46, 4, CFrame.new(0, 101, 80), "White")
	b:disc("DomeDrumBand", 47, 1.4, CFrame.new(0, 101.6, 80), "Sky")
	local dome = b:ellipsoid("RoofDome", Vector3.new(44, 30, 44), CFrame.new(0, 103, 80), "Glass")
	dome.Color = Color3.fromRGB(196, 176, 255)
	dome.Transparency = 0.3
	b:ring("RoofDomeRing", CFrame.new(0, 103.2, 80) * CFrame.Angles(math.rad(90), 0, 0), 22.2, 1.4, "Lilac", 40)
	b:ball("MemeOrb", 8, CFrame.new(0, 109, 80), "Coral")
	b:ring("MemeOrbRing", CFrame.new(0, 109, 80) * CFrame.Angles(math.rad(70), 0, math.rad(15)), 6.2, 0.7, "Sun", 24)
	b:disc("DomeCap", 6, 1.2, CFrame.new(0, 118, 80), "Lilac")
	b:bulb("DomeBeacon", 2.4, CFrame.new(0, 119.6, 80), "GlowPink", 30)

	-- F. Floating orb pedestals on the plaza
	for _, side in ipairs({-1, 1}) do
		local cf = CFrame.new(side * 16.5, 0.6, 10)
		local _, h = b:tiers("PlazaPedestal", cf, {
			{8, 0.6, "Violet"},
			{6.4, 0.8, "White"},
			{5, 0.4, "Sky"},
		})
		local orb = cf * CFrame.new(0, h + 3.4, 0)
		b:ball("PlazaOrb", 3.2, orb, side < 0 and "Sun" or "Mint")
		b:ring("PlazaOrbRing", orb * CFrame.Angles(math.rad(75), 0, math.rad(side * 18)), 2.6, 0.35, "Lilac", 18)
		b:disc("PlazaOrbGlow", 3.6, 0.15, cf * CFrame.new(0, h + 0.08, 0), "GlowCyan")
	end
end

---------------------------------------------------------------------
return function(template)
	if template:GetAttribute("StyledCartoon2050") then return end
	for _, d in ipairs(template:GetDescendants()) do
		restyleDescendant(d)
	end
	addArchitecture(template)
	Architecture.calm(template)
	template:SetAttribute("StyledCartoon2050", true)
end
]=])
install(game:GetService("ServerScriptService"), "PlayerData", "ModuleScript", [=[
-- PlayerData (ModuleScript in ServerScriptService)
-- Loads and saves each player's progress, pays income every second,
-- gives offline earnings, and lets other server scripts change the data safely.

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local STORE_NAME = "PlayerData_v1" -- change the version to wipe everyone's data (e.g. before launch)
local AUTOSAVE_SECONDS = 60
local store = DataStoreService:GetDataStore(STORE_NAME)

local PlayerData = {}
local sessions = {} -- [player] = data table

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
	local ok, saved = retry(function()
		return store:GetAsync(key)
	end)
	if not ok then
		-- Never start with empty data if loading failed, or we'd overwrite their real save
		player:Kick("Couldn't load your museum data. Please rejoin!")
		return
	end
	if not player.Parent then return end -- left while loading

	local data = saved or defaultData()
	if saved then
		migrate(saved)
	end
	reconcile(data, defaultData())

	-- Offline earnings
	if not saved then
		print("[LOAD] No save found for " .. player.Name .. ", starting fresh")
	end
	if saved then
		local away = math.max(0, os.time() - (data.LastOnline or os.time()))
		local counted = math.min(away, GameConfig.OfflineCapHours * 3600)
		local earned = math.floor(computeIncome(data) * counted * GameConfig.OfflineMultiplier)
		print("[LOAD] " .. player.Name .. " was away " .. away .. " seconds, income on display: "
			.. ArtifactData.FormatMoney(computeIncome(data)) .. "/s")
		if earned > 0 then
			data.Money += earned
			data.Stats.TotalEarned += earned
			player:SetAttribute("OfflineEarnings", earned)
			print(player.Name .. " earned " .. ArtifactData.FormatMoney(earned) .. " while offline")
		end
	end
	data.LastOnline = os.time()

	sessions[player] = data
	makeLeaderstats(player)
	refresh(player)
	player:SetAttribute("DataLoaded", true)
	print(player.Name .. "'s data loaded. Money: " .. ArtifactData.FormatMoney(data.Money))
end

local function save(player)
	local data = sessions[player]
	if not data then return end
	data.LastOnline = os.time()
	local key = "Player_" .. player.UserId
	local ok = retry(function()
		store:UpdateAsync(key, function()
			return data
		end)
	end)
	if ok then
		print("[SAVE] " .. player.Name .. "'s data saved. Money: " .. ArtifactData.FormatMoney(data.Money))
	else
		warn("Failed to save data for " .. player.Name)
	end
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

Players.PlayerRemoving:Connect(function(player)
	save(player)
	sessions[player] = nil
end)

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

-- Autosave
task.spawn(function()
	while true do
		task.wait(AUTOSAVE_SECONDS)
		for player in pairs(sessions) do
			task.spawn(save, player)
		end
	end
end)

-- Save everyone when the server shuts down
game:BindToClose(function()
	local running = 0
	for player in pairs(sessions) do
		running += 1
		task.spawn(function()
			save(player)
			running -= 1
		end)
	end
	local start = os.clock()
	while running > 0 and os.clock() - start < 25 do
		task.wait(0.1)
	end
end)

return PlayerData
]=])
install(game:GetService("ServerScriptService"), "PlotManager", "Script", [=[
-- PlotManager (Script inside ServerScriptService)
-- Gives every player their own museum on a free plot,
-- puts their name on the sign, and spawns them in front of it.

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local template = ServerStorage:WaitForChild("MuseumTemplate")
-- Give the template the 2050 look once, before any museum is copied from it
require(script.Parent:WaitForChild("MuseumStyle"))(template)
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
local function getSpawnCFrame(plot)
	return plot.CFrame * CFrame.new(0, 3.5, -82) * CFrame.Angles(0, math.pi, 0)
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
		character:PivotTo(getSpawnCFrame(plot))
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
install(game:GetService("ServerScriptService"), "ShopBuilder", "ModuleScript", [=[
-- ShopBuilder (ModuleScript in ServerScriptService)
-- Builds a world's Shovel Shop: a cartoony 2050 pavilion on a round tiered platform,
-- with a flying-saucer roof held up by chunky capsule pillars, a curved back wall,
-- glass display capsules on stepped pedestals (one shovel per depth zone), a floating
-- robot shopkeeper, a big glowing sign with a giant shovel, and a depth meter.
-- DigManager calls this once per world on server start.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local ShovelModels = require(ReplicatedStorage:WaitForChild("ShovelModels"))
local Architecture = require(script.Parent:WaitForChild("Architecture"))

-- Places a copy of a shovel model at `target` (blade down), scaled up
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
	Architecture.sign(sign, "SHOVEL SHOP", "DIG DEEPER, FIND WEIRDER!")
	b:box("SignGlow", Vector3.new(18.4, 0.3, 1.5), CFrame.new(0, 19.35, -6.1), "GlowSun")
	-- a giant cartoon shovel leaning against the sign
	local grip = Vector3.new(8, 26, -4.6)
	local tip = Vector3.new(11.4, 17.2, -4.6)
	local dir = (tip - grip).Unit
	b:pill("GiantHandle", grip, tip - dir * 3.4, 0.9, "Violet")
	b:rod("GiantGrip", 2.4, 0.7, Architecture.alongX(grip, dir:Cross(Vector3.zAxis)), "Sun")
	b:ball("GiantGripEndA", 0.9, CFrame.new(grip + dir:Cross(Vector3.zAxis).Unit * 1.2), "Sun")
	b:ball("GiantGripEndB", 0.9, CFrame.new(grip - dir:Cross(Vector3.zAxis).Unit * 1.2), "Sun")
	local bladeCF = Architecture.alongX(tip - dir * 1.6, dir)
	b:ellipsoid("GiantBlade", Vector3.new(4.4, 3.4, 0.7), bladeCF, "Sun")
	b:ellipsoid("GiantBladeShine", Vector3.new(2.6, 1.4, 0.75), bladeCF * CFrame.new(-0.6, 0.5, 0), "White")
	b:rod("GiantCollar", 0.8, 1.2, Architecture.alongX(tip - dir * 3.5, dir), "Chrome")

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
	prompt.ObjectText = "Shovels"
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
			-- blade down, facing out; raised a little so the blade clears the capsule floor
			displayShovel(shop, def, base * mid * CFrame.new(0, 0.6, 0) * CFrame.Angles(math.rad(-90), 0, math.rad(8)), 1.3)
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
local mini = UIKit.panel(gui, {Size = UDim2.fromOffset(460, 130), Position = UDim2.fromScale(0.5, 0.7), AnchorPoint = Vector2.new(0.5, 0.5), Radius = 22, Stroke = 4})
mini.Visible = false
local miniTab = UIKit.panel(mini, {Size = UDim2.new(0.7, 0, 0, 40), Position = UDim2.new(0.5, 0, 0, -18), AnchorPoint = Vector2.new(0.5, 0), Color = C.Sun, Radius = 14})
UIKit.label(miniTab, "LUCKY DIG!", {Size = UDim2.new(1, -16, 0.8, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 3})
UIKit.label(mini, "Stop in the green for bonus luck!", {Size = UDim2.new(0.9, 0, 0, 22), Position = UDim2.new(0.5, 0, 0, 30), AnchorPoint = Vector2.new(0.5, 0), Color = C.Ink, Stroke = 0})

local bar = UIKit.panel(mini, {Size = UDim2.new(0.9, 0, 0, 32), Position = UDim2.new(0.5, 0, 0, 60), AnchorPoint = Vector2.new(0.5, 0), Color = C.PanelTint, Radius = 16, Stroke = 3, Shade = false})
bar.ClipsDescendants = false

local goodZone = UIKit.panel(bar, {Size = UDim2.new(0.22, 0, 1, 0), Color = GRADE_COLORS.Good, Radius = 12, Stroke = false, Shade = false})

local perfectZone = UIKit.panel(goodZone, {Size = UDim2.new(0.3, 0, 1, 0), Position = UDim2.new(0.5, 0, 0, 0), AnchorPoint = Vector2.new(0.5, 0), Color = GRADE_COLORS.Perfect, Radius = 8, Stroke = false, Shade = false})

local marker = UIKit.panel(bar, {Size = UDim2.new(0, 12, 1.6, 0), Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.White, Radius = 6, Stroke = 3, Shade = false})
marker.ZIndex = 3

UIKit.label(mini, "Click, tap, or press Space", {Size = UDim2.new(0.9, 0, 0, 18), Position = UDim2.new(0.5, 0, 1, -24), AnchorPoint = Vector2.new(0.5, 0), Color = C.Grey, Stroke = 0})
local gradeText = UIKit.label(gui, "", {Size = UDim2.fromOffset(420, 72), Position = UDim2.fromScale(0.5, 0.58), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 4})
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
local popup = UIKit.panel(gui, {Size = UDim2.fromOffset(400, 250), Position = UDim2.fromScale(0.5, 0.42), AnchorPoint = Vector2.new(0.5, 0.5), Radius = 24, Stroke = 5})
popup.Visible = false
local popupStroke = popup:FindFirstChildOfClass("UIStroke")
local popupScale = Instance.new("UIScale")
popupScale.Parent = popup

local foundTab = UIKit.panel(popup, {Size = UDim2.new(0.62, 0, 0, 42), Position = UDim2.new(0.5, 0, 0, -20), AnchorPoint = Vector2.new(0.5, 0), Color = C.Violet, Radius = 14})
local foundLabel = UIKit.label(foundTab, "YOU FOUND", {Size = UDim2.new(1, -16, 0.78, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 3})
local nameLabel = UIKit.label(popup, "", {Size = UDim2.new(0.9, 0, 0, 38), Position = UDim2.new(0.5, 0, 0, 34), AnchorPoint = Vector2.new(0.5, 0), Color = C.Ink, Stroke = 0})
local rarityTag = UIKit.panel(popup, {Size = UDim2.fromOffset(190, 34), Position = UDim2.new(0.5, 0, 0, 78), AnchorPoint = Vector2.new(0.5, 0), Color = C.Lilac, Radius = 17})
local rarityLabel = UIKit.label(rarityTag, "", {Size = UDim2.new(1, -16, 0.8, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 3})
local incomeLabel = UIKit.label(popup, "", {Size = UDim2.new(0.9, 0, 0, 26), Position = UDim2.new(0.5, 0, 0, 120), AnchorPoint = Vector2.new(0.5, 0), Color = C.Money, Stroke = 2})
local descLabel = UIKit.label(popup, "", {Size = UDim2.new(0.86, 0, 0, 48), Position = UDim2.new(0.5, 0, 0, 152), AnchorPoint = Vector2.new(0.5, 0), Color = C.Grey, Stroke = 0, Font = Enum.Font.GothamMedium, TextSize = 15})
UIKit.label(popup, "Added to your inventory", {Size = UDim2.new(0.9, 0, 0, 18), Position = UDim2.new(0.5, 0, 1, -28), AnchorPoint = Vector2.new(0.5, 0), Color = C.Violet, Stroke = 0})

local flash = Instance.new("Frame")
flash.Size = UDim2.fromScale(1, 1)
flash.BackgroundTransparency = 1
flash.BorderSizePixel = 0
flash.ZIndex = 0
flash.Parent = gui

local popupToken = 0
resultRemote.OnClientEvent:Connect(function(info)
	popupToken += 1
	local myToken = popupToken

	nameLabel.Text = info.Name
	rarityLabel.Text = string.upper(info.Rarity)
	rarityTag.BackgroundColor3 = info.Color
	popupStroke.Color = info.Color:Lerp(C.Ink, 0.35)
	incomeLabel.Text = ArtifactData.FormatMoney(info.Income) .. " / sec"
	descLabel.Text = info.Description
	foundLabel.Text = (info.Grade == "Perfect" and "PERFECT DIG!") or "YOU FOUND"

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

	task.delay(big and 6 or 4, function()
		if popupToken == myToken then
			popup.Visible = false
		end
	end)
end)

---------------------------------------------------------------------
-- RARE FIND ANNOUNCEMENTS (whole server)
---------------------------------------------------------------------
local banner = UIKit.panel(gui, {Size = UDim2.fromOffset(660, 56), Position = UDim2.new(0.5, 0, 0, 70), AnchorPoint = Vector2.new(0.5, 0), Radius = 28, Stroke = 4})
banner.Visible = false
local bannerStroke = banner:FindFirstChildOfClass("UIStroke")
local bannerStar = UIKit.panel(banner, {Size = UDim2.fromOffset(46, 46), Position = UDim2.new(0, 6, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Color = C.Sun, Radius = 23})
UIKit.label(bannerStar, "!", {Size = UDim2.fromScale(0.7, 0.7), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 3})
local bannerText = UIKit.label(banner, "", {Size = UDim2.new(1, -80, 0.62, 0), Position = UDim2.new(0, 62, 0.19, 0), Align = "Left", Color = C.Ink, Stroke = 0})

local bannerToken = 0
announceRemote.OnClientEvent:Connect(function(message, color)
	bannerToken += 1
	local myToken = bannerToken
	bannerText.Text = message
	bannerStar.BackgroundColor3 = typeof(color) == "Color3" and color or C.Sun
	bannerStroke.Color = C.Ink
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
local LANES = {
	{Radius = 305, Height = 30,  Speed = 40,  Count = 6, Dir = 1,  Kind = "drone"},  -- low over the ring road
	{Radius = 305, Height = 48,  Speed = 70,  Count = 6, Dir = -1, Kind = "car"},
	{Radius = 305, Height = 64,  Speed = 55,  Count = 3, Dir = 1,  Kind = "bus"},
	{Radius = 410, Height = 90,  Speed = 85,  Count = 7, Dir = 1,  Kind = "car"},    -- between tower rings 1 and 2
	{Radius = 410, Height = 110, Speed = 65,  Count = 3, Dir = -1, Kind = "bus"},
	{Radius = 518, Height = 140, Speed = 95,  Count = 7, Dir = -1, Kind = "car"},    -- between tower rings 2 and 3
	{Radius = 518, Height = 165, Speed = 45,  Count = 5, Dir = 1,  Kind = "drone"},
	{Radius = 628, Height = 200, Speed = 100, Count = 6, Dir = 1,  Kind = "car"},    -- in front of the edge wall
	{Radius = 450, Height = 400, Speed = 25,  Count = 3, Dir = -1, Kind = "blimp"},
	{Radius = 600, Height = 430, Speed = 22,  Count = 2, Dir = 1,  Kind = "blimp"},
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
stats.Position = UDim2.fromOffset(16, 16)
stats.Parent = gui
local statsLayout = Instance.new("UIListLayout")
statsLayout.Padding = UDim.new(0, 8)
statsLayout.Parent = stats

local function pill(color, iconText, iconColor, order)
	local p = UIKit.panel(stats, {Size = UDim2.fromOffset(230, 44), Color = C.Panel, Radius = 22})
	p.LayoutOrder = order
	local icon = UIKit.panel(p, {Size = UDim2.fromOffset(52, 52), Position = UDim2.new(0, -8, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Color = color, Radius = 26})
	UIKit.label(icon, iconText, {Size = UDim2.fromScale(0.7, 0.7), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Color = iconColor or C.White, Stroke = 2})
	local text = UIKit.label(p, "", {Size = UDim2.new(1, -62, 0.7, 0), Position = UDim2.new(0, 54, 0.15, 0), Align = "Left", Color = C.Ink, Stroke = 0})
	return p, text
end

local moneyPill, moneyText = pill(C.Money, "$", C.White, 1)
local _, incomeText = pill(C.Sun, "+", C.White, 2)
local _, worldText = pill(C.Lilac, "W", C.White, 3)

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
	incomeText.Text = ArtifactData.FormatMoney(player:GetAttribute("Income") or 0) .. " / sec"
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
		local key = UIKit.panel(button, {Size = UDim2.fromOffset(26, 26), Position = UDim2.fromOffset(-6, -6), Color = C.Violet, Radius = 13, Stroke = 2})
		UIKit.label(key, tostring(i), {Size = UDim2.fromScale(0.8, 0.8), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 0})
		local hint = UIKit.label(button, "Equip!", {Size = UDim2.new(1.4, 0, 0, 22), Position = UDim2.new(0.5, 0, 0, -30), AnchorPoint = Vector2.new(0.5, 0), Color = C.Sun, Stroke = 2})
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
local hint = UIKit.label(gui, "", {
	Size = UDim2.fromOffset(620, 30), Position = UDim2.new(0.5, 0, 1, -150), AnchorPoint = Vector2.new(0.5, 0),
	Color = C.Sun, Stroke = 3,
})
hint.Visible = false

local hintToken = 0
local function showHint(text, color)
	hintToken += 1
	local myToken = hintToken
	hint.Text = text
	hint.TextColor3 = color or C.Sun
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
local depthBubble = UIKit.panel(depthPanel, {Size = UDim2.fromOffset(92, 40), Position = UDim2.new(0.5, 0, 0, 0), AnchorPoint = Vector2.new(0.5, 0), Color = C.Panel, Radius = 20})
local depthLabel = UIKit.label(depthBubble, "0m", {Size = UDim2.new(1, -16, 0.72, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.Ink, Stroke = 0})

-- the tube, filled with one colored band per zone (thicker zones = taller bands)
local tube = UIKit.panel(depthPanel, {Size = UDim2.fromOffset(30, GAUGE_H), Position = UDim2.new(0.5, 8, 0, 50), AnchorPoint = Vector2.new(0.5, 0), Color = C.PanelTint, Radius = 15, Stroke = 3, Shade = false})
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
local zoneLabel = UIKit.label(zonePill, "", {Size = UDim2.new(1, -12, 0.72, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2})

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
-- SWING + DIG ANIMATION
---------------------------------------------------------------------
local lastSwing = 0

-- One smooth dig motion, driven every frame.
-- Keyframes: {time 0-1, hand up/down, hand forward/back, blade tilt in degrees}
-- Hand offsets are in studs from where the hand normally rests (+up, -forward).
-- Blade: + tips the blade down into the ground.
local DIG_KEYS = {
	{0.00,  0.0,  0.0,   0},  -- resting
	{0.32,  1.3,  0.3, -18},  -- raise the shovel up
	{0.52, -1.3, -0.7,  26},  -- strike down into the dirt
	{0.72, -0.3, -0.4, -16},  -- scoop the dirt up
	{1.00,  0.0,  0.0,   0},  -- back to resting
}
local STRIKE_TIME = 0.52

-- Smooth curve through the keyframes (Catmull-Rom), so the motion never jerks
local function sampleKeys(t, column)
	t = math.clamp(t, 0, 1)
	local i = 1
	while i < #DIG_KEYS - 1 and t > DIG_KEYS[i + 1][1] do
		i += 1
	end
	local k1, k2 = DIG_KEYS[i], DIG_KEYS[i + 1]
	local k0 = DIG_KEYS[math.max(i - 1, 1)]
	local k3 = DIG_KEYS[math.min(i + 2, #DIG_KEYS)]
	local u = (t - k1[1]) / (k2[1] - k1[1])
	local p0, p1, p2, p3 = k0[column], k1[column], k2[column], k3[column]
	local u2, u3 = u * u, u * u * u
	return 0.5 * ((2 * p1) + (-p0 + p2) * u + (2 * p0 - 5 * p1 + 4 * p2 - p3) * u2 + (-p0 + 3 * p1 - 3 * p2 + p3) * u3)
end

local function smoothstep(x)
	x = math.clamp(x, 0, 1)
	return x * x * (3 - 2 * x)
end

-- IKControl moves the hand to a target point and bends the arm naturally
local function getArmIK(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	local upperArm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm")
	local hand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
	if not (humanoid and root and upperArm and hand) then return nil end
	local target = root:FindFirstChild("DigHandTarget")
	if not target then
		target = Instance.new("Attachment")
		target.Name = "DigHandTarget"
		target.Parent = root
	end
	local ik = humanoid:FindFirstChild("DigArmIK")
	if not ik then
		ik = Instance.new("IKControl")
		ik.Name = "DigArmIK"
		ik.Type = Enum.IKControlType.Position
		ik.ChainRoot = upperArm
		ik.EndEffector = hand
		ik.Target = target
		ik.Weight = 0
		ik.SmoothTime = 0 -- follow the path exactly, no lag
		ik.Parent = humanoid
	end
	return ik, target, root, hand
end

local digConn -- the animation currently playing
local restore -- puts the arm and shovel back to rest

local function stopDigAnimation()
	if digConn then
		digConn:Disconnect()
		digConn = nil
	end
	if restore then
		restore()
		restore = nil
	end
end

local function playDigAnimation(tool, baseGrip, duration)
	local character = player.Character
	if not character then return end
	local ik, target, root, hand = getArmIK(character)
	-- remember where the hand rests (only when no swing is running, so it never drifts)
	local restPos
	if ik and not digConn then
		restPos = root.CFrame:PointToObjectSpace(hand.Position)
		target:SetAttribute("RestPos", restPos)
	elseif ik then
		restPos = target:GetAttribute("RestPos") or root.CFrame:PointToObjectSpace(hand.Position)
	end
	stopDigAnimation() -- a new swing smoothly takes over from the old one
	local start = os.clock()

	restore = function()
		tool.Grip = baseGrip
		if ik then ik.Weight = 0 end
	end

	digConn = RunService.RenderStepped:Connect(function()
		local t = (os.clock() - start) / duration
		if t >= 1 or tool.Parent ~= character then
			stopDigAnimation()
			return
		end
		if ik then
			target.Position = restPos + Vector3.new(0, sampleKeys(t, 2), sampleKeys(t, 3))
			-- fade the arm control in and out so it never pops
			ik.Weight = math.min(smoothstep(t / 0.15), smoothstep((1 - t) / 0.2))
		end
		tool.Grip = baseGrip * CFrame.Angles(math.rad(sampleKeys(t, 4)), 0, 0)
	end)
end

-- A small, smooth camera dip when the shovel hits the ground
local function impactDip()
	local start = os.clock()
	local conn
	conn = RunService.RenderStepped:Connect(function()
		local t = (os.clock() - start) / 0.18
		if t >= 1 then
			conn:Disconnect()
			return
		end
		local offset = math.sin(t * math.pi) * 0.12
		camera.CFrame = camera.CFrame * CFrame.new(0, -offset, 0)
	end)
end

local function onToolEquipped(tool)
	local def = GameConfig.GetShovel(tool:GetAttribute("ShovelId")) or GameConfig.Shovels[1]
	local baseGrip = tool.Grip
	equippedDef = def
	depthPanel.Visible = true

	local activatedConn = tool.Activated:Connect(function()
		local now = os.clock()
		if now - lastSwing < def.Cooldown then return end
		lastSwing = now

		local duration = math.clamp(def.Cooldown * 0.95, 0.35, 0.65)
		playDigAnimation(tool, baseGrip, duration)

		-- the dig happens exactly when the shovel hits the ground
		local target = mouse.Hit and mouse.Hit.Position
		task.delay(duration * STRIKE_TIME, function()
			swingRemote:FireServer(target)
			impactDip()
		end)
	end)

	tool.Unequipped:Once(function()
		activatedConn:Disconnect()
		stopDigAnimation()
		tool.Grip = baseGrip
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
local window, content = UIKit.window(gui, "SHOVEL SHOP", UDim2.fromOffset(760, 560), C.Violet)

local moneyTag = UIKit.panel(content, {Size = UDim2.fromOffset(190, 36), Position = UDim2.new(1, 0, 0, 0), AnchorPoint = Vector2.new(1, 0), Color = C.Money, Radius = 18})
local moneyLabel = UIKit.label(moneyTag, "", {Size = UDim2.new(1, -20, 0.8, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2})
local worldLabel = UIKit.label(content, "", {Size = UDim2.new(1, -210, 0, 30), Position = UDim2.fromOffset(4, 3), Align = "Left", Color = C.Violet, Stroke = 0})

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
	worldLabel.Text = world.Name
	local maxFind, maxLuck = maxStat(world, "FindChance"), maxStat(world, "Luck")
	local minCooldown = math.huge
	for _, def in ipairs(world.Shovels) do minCooldown = math.min(minCooldown, def.Cooldown) end

	for i, def in ipairs(world.Shovels) do
		local zone = world.Zones[def.MaxZone]
		local card = UIKit.panel(list, {Size = UDim2.new(1, -6, 0, 128), Color = C.Row, Radius = 18})
		card.LayoutOrder = i
		-- icon on a colored plate (plate color = the deepest zone it reaches)
		local plate = UIKit.panel(card, {Size = UDim2.fromOffset(104, 104), Position = UDim2.new(0, 12, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Color = zone.Color, Radius = 16})
		UIKit.shovelIcon(plate, def, {Size = UDim2.fromScale(1, 1)})
		UIKit.label(card, def.Name, {Size = UDim2.new(0.52, -136, 0, 26), Position = UDim2.fromOffset(128, 10), Align = "Left", Color = C.Ink, Stroke = 0})
		UIKit.label(card, def.Description, {Size = UDim2.new(0.52, -136, 0, 46), Position = UDim2.fromOffset(128, 36), Align = "Left", VAlign = "Top", Color = C.Grey, Stroke = 0, Font = Enum.Font.GothamMedium, TextSize = 12})
		local zoneTag = UIKit.panel(card, {Size = UDim2.fromOffset(190, 26), Position = UDim2.fromOffset(128, 90), Color = zone.Color, Radius = 13, Stroke = 2})
		UIKit.label(zoneTag, "DIGS TO " .. -zone.Bottom .. "m  •  " .. string.upper(zone.Name), {Size = UDim2.new(1, -12, 0.8, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2})

		local statsBox = Instance.new("Frame")
		statsBox.BackgroundTransparency = 1
		statsBox.Size = UDim2.new(0.3, 0, 0, 80)
		statsBox.Position = UDim2.new(0.52, 0, 0, 14)
		statsBox.Parent = card
		UIKit.statBar(statsBox, "Find", def.FindChance / maxFind, math.floor(def.FindChance * 1000 + 0.5) / 10 .. "%", C.Mint, {Size = UDim2.new(1, 0, 0, 20), Position = UDim2.fromOffset(0, 0)})
		UIKit.statBar(statsBox, "Luck", def.Luck / maxLuck, "x" .. def.Luck, C.Sun, {Size = UDim2.new(1, 0, 0, 20), Position = UDim2.fromOffset(0, 26)})
		UIKit.statBar(statsBox, "Speed", minCooldown / def.Cooldown, string.format("%.2fs", def.Cooldown), C.Sky, {Size = UDim2.new(1, 0, 0, 20), Position = UDim2.fromOffset(0, 52)})

		local b = UIKit.button(card, "", {Size = UDim2.new(0.15, 0, 0, 52), Position = UDim2.new(1, -12, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5)})
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
				UIKit.setButton(b, "EQUIPPED", C.Grey)
			elseif table.find(owned, def.Id) then
				UIKit.setButton(b, "EQUIP", C.Sky)
			else
				UIKit.setButton(b, ArtifactData.FormatMoney(def.Price), money >= def.Price and C.Mint or C.Coral)
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
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "WorldClient", "LocalScript", [=[
-- WorldClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The World Map opened at any World Gate: a card per world showing whether it's unlocked,
-- its price, and a button to unlock it or travel there.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

local window, content = UIKit.window(gui, "WORLD MAP", UDim2.fromOffset(640, 540), C.Sky)

local moneyTag = UIKit.panel(content, {Size = UDim2.fromOffset(190, 36), Position = UDim2.new(1, 0, 0, 0), AnchorPoint = Vector2.new(1, 0), Color = C.Money, Radius = 18})
local moneyLabel = UIKit.label(moneyTag, "", {Size = UDim2.new(1, -20, 0.8, 0), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 2})
UIKit.label(content, "Unlock new dig sites with cash!", {Size = UDim2.new(1, -210, 0, 28), Position = UDim2.fromOffset(4, 4), Align = "Left", Color = C.Violet, Stroke = 0})

local listHolder = Instance.new("Frame")
listHolder.BackgroundTransparency = 1
listHolder.Size = UDim2.new(1, 0, 1, -48)
listHolder.Position = UDim2.fromOffset(0, 46)
listHolder.Parent = content
local list = UIKit.list(listHolder, 10)

local PLANET_COLORS = {C.Mint, C.Sun, C.Coral, C.Sky, C.Lilac, C.Violet, C.Money, C.Coral, C.Sky}
local buttons = {} -- [worldId] = button

for _, world in ipairs(GameConfig.Worlds) do
	local card = UIKit.panel(list, {Size = UDim2.new(1, -6, 0, 84), Color = world.Enabled and C.Row or C.PanelTint, Radius = 18})
	card.LayoutOrder = world.Id
	-- little planet badge with the world number
	local planet = UIKit.panel(card, {Size = UDim2.fromOffset(60, 60), Position = UDim2.new(0, 12, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Color = PLANET_COLORS[world.Id] or C.Lilac, Radius = 30})
	UIKit.label(planet, tostring(world.Id), {Size = UDim2.fromScale(0.6, 0.6), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Stroke = 3})
	UIKit.label(card, world.Name, {Size = UDim2.new(0.6, -90, 0, 28), Position = UDim2.fromOffset(86, 12), Align = "Left", Color = C.Ink, Stroke = 0})
	local sub = world.Enabled and (#world.Shovels .. " shovels  •  digs down to " .. -world.Zones[#world.Zones].Bottom .. "m")
		or "Still being excavated... coming soon!"
	UIKit.label(card, sub, {Size = UDim2.new(0.6, -90, 0, 20), Position = UDim2.fromOffset(86, 46), Align = "Left", Color = C.Grey, Stroke = 0})

	local b = UIKit.button(card, "", {Size = UDim2.new(0.3, 0, 0, 52), Position = UDim2.new(1, -14, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5)})
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
			UIKit.setButton(b, "YOU ARE HERE", C.Lilac)
		elseif table.find(unlocked, tostring(world.Id)) then
			UIKit.setButton(b, "TRAVEL", C.Sky)
		else
			UIKit.setButton(b, "UNLOCK " .. ArtifactData.FormatMoney(world.Price), money >= world.Price and C.Mint or C.Coral)
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
]=])
if recording then ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit) end
print("Meme Archaeologist: installed " .. count .. " scripts. Now save the place (Ctrl+S).")
