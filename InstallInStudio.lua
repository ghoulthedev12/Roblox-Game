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
		{"D", "BrainrotCoreSample", "Frozen Brainrot Core Sample", "Drilled from 240 studs down. Every layer is a different trend."},
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
	-- Standard 250-stud depth scale shared by every world
	local depths = {{0, 50}, {50, 130}, {130, 200}, {200, 250}}
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
		-- DigRadius = hole size, FindChance = chance per swing to find something,
		-- Luck = rare find multiplier, Cooldown = seconds between swings
		Shovels = {
			{Id = "RustyShovel", Name = "Rusty Shovel", Price = 0, MaxZone = 1,
				DigRadius = 4, FindChance = 0.04, Luck = 1, Cooldown = 0.7,
				Color = Color3.fromRGB(150, 85, 50), Material = "CorrodedMetal",
				Description = "Found in a dumpster in 2049. Still works. Mostly."},
			{Id = "PlasticShovel", Name = "Plastic Beach Shovel", Price = 1000, MaxZone = 2,
				DigRadius = 4.5, FindChance = 0.045, Luck = 1.1, Cooldown = 0.67,
				Color = Color3.fromRGB(255, 200, 40), Material = "SmoothPlastic",
				Description = "Built for sandcastles. Somehow better than rust."},
			{Id = "GardenSpade", Name = "Garden Spade", Price = 7500, MaxZone = 2,
				DigRadius = 5, FindChance = 0.05, Luck = 1.2, Cooldown = 0.64,
				Color = Color3.fromRGB(90, 170, 80), Material = "Metal",
				Description = "Borrowed from a grandma. She wants it back."},
			{Id = "IronShovel", Name = "Iron Shovel", Price = 40000, MaxZone = 2,
				DigRadius = 5.5, FindChance = 0.055, Luck = 1.35, Cooldown = 0.6,
				Color = Color3.fromRGB(175, 180, 190), Material = "Metal",
				Description = "A real tool for a real archaeologist."},
			{Id = "SteelSpade", Name = "Steel Spade", Price = 200000, MaxZone = 3,
				DigRadius = 6, FindChance = 0.06, Luck = 1.5, Cooldown = 0.56,
				Color = Color3.fromRGB(120, 140, 170), Material = "Metal",
				Description = "Sharp enough to cut through ancient comment sections."},
			{Id = "GoldenShovel", Name = "Golden Shovel", Price = 500000, MaxZone = 3,
				DigRadius = 6.5, FindChance = 0.065, Luck = 1.7, Cooldown = 0.53,
				Color = Color3.fromRGB(255, 200, 60), Material = "Metal",
				Description = "Shiny. Heavy. Completely unnecessary. Perfect."},
			{Id = "GamerShovel", Name = "RGB Gamer Shovel", Price = 1000000, MaxZone = 3,
				DigRadius = 7, FindChance = 0.07, Luck = 2, Cooldown = 0.5,
				Color = Color3.fromRGB(255, 60, 200), Material = "Neon",
				Description = "The RGB lights add +200% digging power. Science."},
			{Id = "TectonicAuger", Name = "Tectonic Auger", Price = 10000000, MaxZone = 4,
				DigRadius = 7.5, FindChance = 0.075, Luck = 2.4, Cooldown = 0.47,
				Color = Color3.fromRGB(128, 132, 138), Material = "Foil",
				Description = "Legendary. Rated for bedrock, permafrost and 2049-era server racks."},
			{Id = "SingularitySpade", Name = "Singularity Spade", Price = 50000000, MaxZone = 4,
				DigRadius = 8, FindChance = 0.085, Luck = 3, Cooldown = 0.44,
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
	-- stone ground around the pit (and under it)
	terrain:FillBlock(CFrame.new(origin + Vector3.new(0, -depth / 2, 0)), Vector3.new(200, depth, 200), Enum.Material.Slate)
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
	GlowCyan = {Color = rgb(120, 236, 255), Material = Enum.Material.Neon},
	GlowPink = {Color = rgb(255, 140, 222), Material = Enum.Material.Neon},
	GlowSun  = {Color = rgb(255, 222, 120), Material = Enum.Material.Neon},
	GlowMint = {Color = rgb(120, 255, 205), Material = Enum.Material.Neon},
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
install(game:GetService("ServerScriptService"), "DigManager", "Script", [=[
-- DigManager (Script in ServerScriptService)
-- Real terrain digging with shovels across every world: carves holes in a 250-stud pit,
-- blocks shovels from breaking into zones deeper than they're rated for, finds artifacts
-- by depth zone, Lucky Dig minigame, pit resets, the Shovel Shops and the World Gates.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))
local ShovelModels = require(script.Parent:WaitForChild("ShovelModels"))
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

print("DigManager ready: " .. #enabledWorlds() .. " world(s), 250-stud pits, shovel depth zones active")
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
		part.Color = c:Lerp(Color3.new(1, 1, 1), 0.22)
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
local ShovelModels = require(script.Parent:WaitForChild("ShovelModels"))
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
install(game:GetService("ServerScriptService"), "ShovelModels", "ModuleScript", [=[
-- ShovelModels (ModuleScript in ServerScriptService)
-- Builds a detailed, individually styled model for every shovel.
-- DigManager uses this instead of its old simple shovel builder.

local SCALE = 0.65 -- overall size of the shovels
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
-- UI HELPERS
---------------------------------------------------------------------
local DARK = Color3.fromRGB(18, 20, 32)
local CYAN = Color3.fromRGB(0, 225, 255)
local GRADE_COLORS = {
	Perfect = Color3.fromRGB(90, 255, 120),
	Good = Color3.fromRGB(255, 210, 60),
	Miss = Color3.fromRGB(255, 80, 80),
}

local gui = Instance.new("ScreenGui")
gui.Name = "DigGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 12)
	c.Parent = parent
end

local function stroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness or 2
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function frame(parent, size, position, color, transparency)
	local f = Instance.new("Frame")
	f.Size = size
	f.Position = position
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.BackgroundColor3 = color
	f.BackgroundTransparency = transparency or 0
	f.BorderSizePixel = 0
	f.Parent = parent
	return f
end

local function label(parent, text, size, position, color, font)
	local l = Instance.new("TextLabel")
	l.Size = size
	l.Position = position
	l.AnchorPoint = Vector2.new(0.5, 0.5)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = color
	l.Font = font or Enum.Font.GothamBold
	l.TextScaled = true
	l.TextWrapped = true
	l.Parent = parent
	return l
end

---------------------------------------------------------------------
-- MINIGAME
---------------------------------------------------------------------
local mini = frame(gui, UDim2.new(0, 440, 0, 120), UDim2.new(0.5, 0, 0.74, 0), DARK, 0.15)
mini.Visible = false
corner(mini, 14)
stroke(mini, CYAN, 2)
local miniTitle = label(mini, "HIT THE GLOWING ZONE FOR BONUS LUCK!", UDim2.new(0.9, 0, 0, 22), UDim2.new(0.5, 0, 0, 20), Color3.new(1, 1, 1), Enum.Font.GothamBlack)

local bar = frame(mini, UDim2.new(0.9, 0, 0, 28), UDim2.new(0.5, 0, 0, 58), Color3.fromRGB(45, 48, 62))
corner(bar, 8)
bar.ClipsDescendants = false

local goodZone = Instance.new("Frame")
goodZone.BackgroundColor3 = GRADE_COLORS.Good
goodZone.BorderSizePixel = 0
goodZone.Size = UDim2.new(0.22, 0, 1, 0)
goodZone.Parent = bar
corner(goodZone, 6)

local perfectZone = Instance.new("Frame")
perfectZone.BackgroundColor3 = GRADE_COLORS.Perfect
perfectZone.BorderSizePixel = 0
perfectZone.AnchorPoint = Vector2.new(0.5, 0)
perfectZone.Position = UDim2.new(0.5, 0, 0, 0)
perfectZone.Size = UDim2.new(0.3, 0, 1, 0) -- 30% of the good zone
perfectZone.Parent = goodZone

local marker = Instance.new("Frame")
marker.BackgroundColor3 = Color3.new(1, 1, 1)
marker.BorderSizePixel = 0
marker.AnchorPoint = Vector2.new(0.5, 0.5)
marker.Size = UDim2.new(0, 6, 1.5, 0)
marker.Position = UDim2.new(0, 0, 0.5, 0)
marker.ZIndex = 3
marker.Parent = bar
corner(marker, 3)

local hint = label(mini, "Click, tap, or press Space", UDim2.new(0.9, 0, 0, 18), UDim2.new(0.5, 0, 0, 98), Color3.fromRGB(180, 185, 200), Enum.Font.GothamMedium)
local gradeText = label(gui, "", UDim2.new(0, 400, 0, 70), UDim2.new(0.5, 0, 0.6, 0), Color3.new(1, 1, 1), Enum.Font.GothamBlack)
gradeText.Visible = false
stroke(gradeText, Color3.new(0, 0, 0), 3).ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual

local playing = false
local SPEED = 1.3 -- how fast the marker moves (bar widths per second)

local function showGrade(grade)
	gradeText.Text = string.upper(grade) .. (grade == "Miss" and "" or "!")
	gradeText.TextColor3 = GRADE_COLORS[grade]
	gradeText.Visible = true
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
local popup = frame(gui, UDim2.new(0, 380, 0, 230), UDim2.new(0.5, 0, 0.42, 0), DARK, 0.05)
popup.Visible = false
corner(popup, 16)
local popupStroke = stroke(popup, Color3.new(1, 1, 1), 4)
local popupScale = Instance.new("UIScale")
popupScale.Parent = popup

local foundLabel = label(popup, "YOU FOUND", UDim2.new(0.9, 0, 0, 20), UDim2.new(0.5, 0, 0, 22), Color3.fromRGB(180, 185, 200), Enum.Font.GothamBold)
local nameLabel = label(popup, "", UDim2.new(0.9, 0, 0, 36), UDim2.new(0.5, 0, 0, 56), Color3.new(1, 1, 1), Enum.Font.GothamBlack)
local rarityLabel = label(popup, "", UDim2.new(0.9, 0, 0, 26), UDim2.new(0.5, 0, 0, 90), Color3.new(1, 1, 1), Enum.Font.GothamBlack)
local incomeLabel = label(popup, "", UDim2.new(0.9, 0, 0, 22), UDim2.new(0.5, 0, 0, 120), Color3.fromRGB(90, 255, 120), Enum.Font.GothamBold)
local descLabel = label(popup, "", UDim2.new(0.88, 0, 0, 46), UDim2.new(0.5, 0, 0, 164), Color3.fromRGB(200, 205, 215), Enum.Font.GothamMedium)
descLabel.TextScaled = false
descLabel.TextSize = 15
local footerLabel = label(popup, "Added to your inventory", UDim2.new(0.9, 0, 0, 16), UDim2.new(0.5, 0, 0, 208), Color3.fromRGB(140, 145, 160), Enum.Font.GothamMedium)

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
	rarityLabel.TextColor3 = info.Color
	popupStroke.Color = info.Color
	incomeLabel.Text = ArtifactData.FormatMoney(info.Income) .. " / sec"
	descLabel.Text = info.Description
	foundLabel.Text = (info.Grade == "Perfect" and "PERFECT DIG! YOU FOUND") or "YOU FOUND"

	-- pop-in animation
	popup.Visible = true
	popupScale.Scale = 0.3
	TweenService:Create(popupScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()

	-- big finds (Legendary and up) flash the screen
	local big = info.RarityIndex >= ArtifactData.GetRarityIndex("Legendary")
	if big then
		flash.BackgroundColor3 = info.Color
		flash.BackgroundTransparency = 0.35
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
local banner = frame(gui, UDim2.new(0, 640, 0, 52), UDim2.new(0.5, 0, 0, 90), DARK, 0.1)
banner.Visible = false
corner(banner, 12)
local bannerStroke = stroke(banner, Color3.new(1, 1, 1), 3)
local bannerText = label(banner, "", UDim2.new(0.94, 0, 0.7, 0), UDim2.new(0.5, 0, 0.5, 0), Color3.new(1, 1, 1), Enum.Font.GothamBlack)

local bannerToken = 0
announceRemote.OnClientEvent:Connect(function(message, color)
	bannerToken += 1
	local myToken = bannerToken
	bannerText.Text = "🌟 " .. message
	bannerText.TextColor3 = color
	bannerStroke.Color = color
	banner.Visible = true
	task.delay(6, function()
		if bannerToken == myToken then
			banner.Visible = false
		end
	end)
end)
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "FlyingTraffic", "LocalScript", [=[
-- FlyingTraffic (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Hover cars and cargo ships flying around the city in traffic lanes.
-- Runs only on each player's screen, so it's smooth and doesn't load the server.

local RunService = game:GetService("RunService")

local folder = Instance.new("Folder")
folder.Name = "FlyingTraffic"
folder.Parent = workspace

local rng = Random.new()

-- Traffic lanes: circles around the map, placed between the rings of towers
-- Dir 1 = counter-clockwise, -1 = clockwise
local LANES = {
	{Radius = 305, Height = 48,  Speed = 70,  Count = 6, Dir = 1},   -- above the ring road
	{Radius = 305, Height = 62,  Speed = 60,  Count = 5, Dir = -1},
	{Radius = 410, Height = 90,  Speed = 85,  Count = 7, Dir = 1},   -- between tower rings 1 and 2
	{Radius = 410, Height = 110, Speed = 80,  Count = 5, Dir = -1},
	{Radius = 518, Height = 140, Speed = 95,  Count = 7, Dir = -1},  -- between tower rings 2 and 3
	{Radius = 518, Height = 165, Speed = 90,  Count = 5, Dir = 1},
	{Radius = 628, Height = 200, Speed = 100, Count = 6, Dir = 1},   -- in front of the edge wall
	{Radius = 450, Height = 400, Speed = 40,  Count = 3, Dir = -1, Ships = true},
	{Radius = 600, Height = 430, Speed = 35,  Count = 2, Dir = 1, Ships = true},
}

local CAR_COLORS = {
	Color3.fromRGB(240, 240, 245), Color3.fromRGB(30, 32, 40), Color3.fromRGB(255, 60, 90),
	Color3.fromRGB(0, 170, 255), Color3.fromRGB(255, 200, 60), Color3.fromRGB(150, 90, 255),
}
local GLOW_COLORS = {
	Color3.fromRGB(0, 225, 255), Color3.fromRGB(255, 60, 200), Color3.fromRGB(60, 255, 200), Color3.fromRGB(255, 160, 40),
}

---------------------------------------------------------------------
-- BUILDING VEHICLES (front of every vehicle = -Z)
---------------------------------------------------------------------
local function newPart(model, name, size, cframe, color, material, shape)
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

local function oval(model, name, size, cframe, color, material)
	local p = newPart(model, name, size, cframe, color, material)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = p
	return p
end

local ALONG_Z = CFrame.Angles(0, math.rad(90), 0)

local function buildCar()
	local model = Instance.new("Model")
	model.Name = "HoverCar"
	local color = CAR_COLORS[rng:NextInteger(1, #CAR_COLORS)]
	local glow = GLOW_COLORS[rng:NextInteger(1, #GLOW_COLORS)]

	local body = oval(model, "Body", Vector3.new(4.6, 1.7, 10), CFrame.new(), color)
	body.Reflectance = 0.2
	local cockpit = oval(model, "Cockpit", Vector3.new(3.2, 1.6, 4.6), CFrame.new(0, 0.8, -0.4), Color3.fromRGB(120, 200, 255), Enum.Material.Glass)
	cockpit.Transparency = 0.25
	newPart(model, "Underglow", Vector3.new(3.4, 0.2, 7.2), CFrame.new(0, -0.8, 0), glow, Enum.Material.Neon)
	newPart(model, "Headlights", Vector3.new(2.8, 0.3, 0.3), CFrame.new(0, 0.1, -4.8), Color3.fromRGB(230, 245, 255), Enum.Material.Neon)
	newPart(model, "TailLights", Vector3.new(3.4, 0.3, 0.3), CFrame.new(0, 0.2, 4.85), Color3.fromRGB(255, 40, 60), Enum.Material.Neon)
	for _, side in ipairs({-1, 1}) do
		newPart(model, "Thruster", Vector3.new(1.6, 1, 1), CFrame.new(side * 2.3, -0.1, 3.6) * ALONG_Z, Color3.fromRGB(60, 62, 72), Enum.Material.Metal, Enum.PartType.Cylinder)
		newPart(model, "ThrusterGlow", Vector3.new(0.2, 0.8, 0.8), CFrame.new(side * 2.3, -0.1, 4.45) * ALONG_Z, glow, Enum.Material.Neon, Enum.PartType.Cylinder)
	end
	model.PrimaryPart = body
	return model
end

local function buildShip()
	local model = Instance.new("Model")
	model.Name = "CargoShip"
	local hull = oval(model, "Hull", Vector3.new(14, 7, 38), CFrame.new(), Color3.fromRGB(220, 225, 235))
	hull.Reflectance = 0.15
	oval(model, "Bridge", Vector3.new(7, 3.5, 9), CFrame.new(0, 3.2, -10), Color3.fromRGB(110, 190, 255), Enum.Material.Glass).Transparency = 0.2
	newPart(model, "Wings", Vector3.new(40, 0.8, 10), CFrame.new(0, -0.5, 4), Color3.fromRGB(60, 64, 78), Enum.Material.Metal)
	newPart(model, "Stripe", Vector3.new(14.2, 0.6, 30), CFrame.new(0, 0, 0), Color3.fromRGB(255, 200, 60), Enum.Material.Neon)
	newPart(model, "Container", Vector3.new(9, 6, 14), CFrame.new(0, -5, 4), Color3.fromRGB(255, 120, 40), Enum.Material.DiamondPlate)
	for _, side in ipairs({-1, 1}) do
		newPart(model, "Engine", Vector3.new(8, 4, 4), CFrame.new(side * 16, -0.5, 8) * ALONG_Z, Color3.fromRGB(50, 52, 62), Enum.Material.Metal, Enum.PartType.Cylinder)
		local flame = newPart(model, "EngineGlow", Vector3.new(0.4, 3.4, 3.4), CFrame.new(side * 16, -0.5, 12.2) * ALONG_Z, Color3.fromRGB(0, 225, 255), Enum.Material.Neon, Enum.PartType.Cylinder)
		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(0, 225, 255)
		light.Range = 20
		light.Brightness = 1.5
		light.Parent = flame
		newPart(model, "WingLight", Vector3.new(0.8, 0.8, 0.8), CFrame.new(side * 20, -0.5, 4), side == 1 and Color3.fromRGB(60, 255, 90) or Color3.fromRGB(255, 50, 50), Enum.Material.Neon, Enum.PartType.Ball)
	end
	model.PrimaryPart = hull
	return model
end

---------------------------------------------------------------------
-- SPAWN VEHICLES ON THEIR LANES
---------------------------------------------------------------------
local vehicles = {}
for _, lane in ipairs(LANES) do
	for i = 1, lane.Count do
		local model = lane.Ships and buildShip() or buildCar()
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
		local bob = math.sin(t * 0.9 + v.Phase) * (lane.Ships and 3 or 1.2)
		local position = Vector3.new(math.cos(a) * lane.Radius, lane.Height + v.HeightOffset + bob, math.sin(a) * lane.Radius)
		local forward = Vector3.new(-math.sin(a), 0, math.cos(a)) * lane.Dir
		-- lean slightly into the curve, like a real turning vehicle
		local lean = CFrame.Angles(0, 0, lane.Dir * (lane.Ships and 0.05 or 0.14))
		v.Model:PivotTo(CFrame.lookAt(position, position + forward) * lean)
	end
end)
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "ShovelClient", "LocalScript", [=[
-- ShovelClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Shovel swing + dig animation, depth + zone display, underground light,
-- Return to Surface button, and the Shovel Shop menu (each world's shovels + their depth rating).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
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

local DARK = Color3.fromRGB(18, 20, 32)
local ROW = Color3.fromRGB(32, 35, 50)
local CYAN = Color3.fromRGB(0, 225, 255)
local GOLD = Color3.fromRGB(255, 200, 60)
local GREEN = Color3.fromRGB(70, 200, 110)
local RED = Color3.fromRGB(200, 70, 70)
local GREY = Color3.fromRGB(90, 95, 110)

local gui = Instance.new("ScreenGui")
gui.Name = "ShovelGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 10)
	c.Parent = parent
end

local function stroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness or 2
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function label(parent, text, size, position, color, font, anchor)
	local l = Instance.new("TextLabel")
	l.Size = size
	l.Position = position
	l.AnchorPoint = anchor or Vector2.new(0, 0)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = color
	l.Font = font or Enum.Font.GothamBold
	l.TextScaled = true
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

local function button(parent, text, size, position, color)
	local b = Instance.new("TextButton")
	b.Size = size
	b.Position = position
	b.BackgroundColor3 = color
	b.Text = text
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBlack
	b.TextScaled = true
	b.Parent = parent
	corner(b, 8)
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 8)
	pad.PaddingTop = UDim.new(0, 7)
	pad.PaddingBottom = UDim.new(0, 7)
	pad.Parent = b
	return b
end

---------------------------------------------------------------------
-- HINT MESSAGES
---------------------------------------------------------------------
local hint = label(gui, "", UDim2.new(0, 560, 0, 28), UDim2.new(0.5, 0, 1, -255), Color3.fromRGB(255, 220, 120), Enum.Font.GothamBlack, Vector2.new(0.5, 0))
hint.TextXAlignment = Enum.TextXAlignment.Center
hint.Visible = false
local hintStroke = Instance.new("UIStroke")
hintStroke.Thickness = 2
hintStroke.Parent = hint

local hintToken = 0
local function showHint(text, color)
	hintToken += 1
	local myToken = hintToken
	hint.Text = text
	hint.TextColor3 = color or Color3.fromRGB(255, 220, 120)
	hint.Visible = true
	task.delay(2.5, function()
		if hintToken == myToken then hint.Visible = false end
	end)
end

digMessageRemote.OnClientEvent:Connect(function(message, color)
	if typeof(message) == "string" then
		showHint(message, typeof(color) == "Color3" and color or nil)
	end
end)

---------------------------------------------------------------------
-- DEPTH PANEL + RETURN TO SURFACE + UNDERGROUND LIGHT
---------------------------------------------------------------------
local depthPanel = Instance.new("Frame")
depthPanel.Size = UDim2.new(0, 330, 0, 60)
depthPanel.Position = UDim2.new(0.5, 0, 1, -100)
depthPanel.AnchorPoint = Vector2.new(0.5, 1)
depthPanel.BackgroundColor3 = DARK
depthPanel.BackgroundTransparency = 0.15
depthPanel.Visible = false
depthPanel.Parent = gui
corner(depthPanel, 12)
local depthStroke = stroke(depthPanel, CYAN, 2)

local shovelLabel = label(depthPanel, "", UDim2.new(1, -20, 0, 18), UDim2.new(0, 10, 0, 7), Color3.new(1, 1, 1), Enum.Font.GothamBlack)
local depthLabel = label(depthPanel, "", UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 32), CYAN, Enum.Font.GothamBold)

local surfaceButton = button(gui, "RETURN TO SURFACE", UDim2.new(0, 220, 0, 40), UDim2.new(0.5, -110, 1, -215), Color3.fromRGB(0, 140, 180))
surfaceButton.Visible = false
surfaceButton.MouseButton1Click:Connect(function()
	surfaceRemote:FireServer()
end)

local headlamp -- PointLight on our character when underground
local equippedDef -- the shovel currently in hand

local function currentWorld()
	return GameConfig.GetWorld(player:GetAttribute("CurrentWorld") or 1) or GameConfig.Worlds[1]
end

task.spawn(function()
	while true do
		task.wait(0.2)
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root then
			local world = currentWorld()
			local feetY = root.Position.Y - 3
			local depth = math.max(0, math.floor(world.Origin.Y - feetY + 0.5))
			local offset = root.Position - world.Origin
			local inPit = Vector3.new(offset.X, 0, offset.Z).Magnitude < world.PitRadius + 7

			local zoneIndex, zone = GameConfig.GetZoneAt(world, feetY)
			zone = zone or {Name = "Bedrock", Color = Color3.fromRGB(150, 150, 160)}
			local text = "DEPTH " .. depth .. "m  •  " .. string.upper(zone.Name)
			-- warn when the next zone down is too hard for this shovel
			if equippedDef and zoneIndex and zoneIndex == equippedDef.MaxZone and zoneIndex < #world.Zones then
				local floorDepth = -world.Zones[zoneIndex].Bottom
				if floorDepth - depth <= 12 then
					text ..= "  •  LIMIT " .. floorDepth .. "m"
				end
			end
			depthLabel.Text = text
			depthLabel.TextColor3 = zone.Color
			depthStroke.Color = zone.Color

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
	local world = GameConfig.GetWorld(def.World) or GameConfig.Worlds[1]
	equippedDef = def
	shovelLabel.Text = string.upper(def.Name) .. "  •  " .. math.floor(def.FindChance * 100 + 0.5) .. "% find  •  digs to " .. -world.Zones[def.MaxZone].Bottom .. "m"
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
		depthPanel.Visible = false
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
-- SHOP MENU (the world's shovels + its depth zones)
---------------------------------------------------------------------
local shop = Instance.new("Frame")
shop.Size = UDim2.new(0, 600, 0, 480)
shop.Position = UDim2.new(0.5, 0, 0.5, 0)
shop.AnchorPoint = Vector2.new(0.5, 0.5)
shop.BackgroundColor3 = DARK
shop.BackgroundTransparency = 0.05
shop.Visible = false
shop.Parent = gui
corner(shop, 16)
stroke(shop, GOLD, 3)

label(shop, "SHOVEL SHOP", UDim2.new(0, 300, 0, 34), UDim2.new(0, 20, 0, 14), GOLD, Enum.Font.GothamBlack)
local moneyLabel = label(shop, "", UDim2.new(0, 220, 0, 22), UDim2.new(1, -290, 0, 22), Color3.fromRGB(90, 255, 120), Enum.Font.GothamBold)
moneyLabel.TextXAlignment = Enum.TextXAlignment.Right
local closeButton = button(shop, "X", UDim2.new(0, 36, 0, 36), UDim2.new(1, -50, 0, 14), RED)

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -30, 1, -80)
list.Position = UDim2.new(0, 15, 0, 64)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 6
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.Parent = shop
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

local order = 0
local function header(text)
	order += 1
	local h = label(list, text, UDim2.new(1, -10, 0, 26), UDim2.new(), CYAN, Enum.Font.GothamBlack)
	h.LayoutOrder = order
end

local function makeRow(color, title, stats, description)
	order += 1
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -10, 0, 78)
	row.BackgroundColor3 = ROW
	row.LayoutOrder = order
	row.Parent = list
	corner(row, 10)
	local swatch = Instance.new("Frame")
	swatch.Size = UDim2.new(0, 54, 0, 54)
	swatch.Position = UDim2.new(0, 12, 0.5, 0)
	swatch.AnchorPoint = Vector2.new(0, 0.5)
	swatch.BackgroundColor3 = color
	swatch.Parent = row
	corner(swatch, 10)
	label(row, title, UDim2.new(0, 320, 0, 22), UDim2.new(0, 80, 0, 8), Color3.new(1, 1, 1), Enum.Font.GothamBlack)
	label(row, stats, UDim2.new(0, 320, 0, 17), UDim2.new(0, 80, 0, 32), CYAN, Enum.Font.GothamBold)
	label(row, description, UDim2.new(0, 320, 0, 15), UDim2.new(0, 80, 0, 53), Color3.fromRGB(170, 175, 190), Enum.Font.GothamMedium)
	local b = button(row, "", UDim2.new(0, 130, 0, 42), UDim2.new(1, -142, 0.5, -21), GREEN)
	return b
end

local shovelButtons = {}
local shopWorld = GameConfig.Worlds[1] -- which world's shop is open

local function zoneLabel(world, def)
	local zone = world.Zones[def.MaxZone]
	return "Digs to " .. -zone.Bottom .. "m (" .. zone.Name .. ")"
end

-- Fills the list with one world's shovels
local function buildRows(world)
	for _, child in ipairs(list:GetChildren()) do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end
	shovelButtons = {}
	order = 0
	header(string.upper(world.Name) .. "  •  SHOVELS")
	for _, def in ipairs(world.Shovels) do
		local stats = zoneLabel(world, def) .. "  •  " .. math.floor(def.FindChance * 100 + 0.5) .. "% find  •  Luck x" .. def.Luck
		local b = makeRow(def.Color, def.Name, stats, def.Description)
		shovelButtons[def.Id] = b
		b.MouseButton1Click:Connect(function()
			local owned = string.split(player:GetAttribute("OwnedShovels") or "", ",")
			if table.find(owned, def.Id) then
				equipShovelRemote:FireServer(def.Id)
			else
				buyShovelRemote:FireServer(def.Id)
			end
		end)
	end
	header("DEPTH ZONES")
	for i, zone in ipairs(world.Zones) do
		local first = GameConfig.GetFirstShovelForZone(world, i)
		order += 1
		local line = label(list, string.upper(zone.Name) .. "   " .. -zone.Top .. "-" .. -zone.Bottom .. "m   •   "
			.. table.concat(zone.Rarities, ", ") .. "   •   needs " .. (first and first.Name or "?"),
			UDim2.new(1, -10, 0, 18), UDim2.new(), zone.Color, Enum.Font.GothamBold)
		line.LayoutOrder = order
	end
end

local function refreshShop()
	local money = player:GetAttribute("Money") or 0
	local owned = string.split(player:GetAttribute("OwnedShovels") or "", ",")
	local equipped = player:GetAttribute("EquippedShovel")
	moneyLabel.Text = ArtifactData.FormatMoney(money)

	for _, def in ipairs(shopWorld.Shovels) do
		local b = shovelButtons[def.Id]
		if not b then continue end
		if def.Id == equipped then
			b.Text = "EQUIPPED"
			b.BackgroundColor3 = GREY
		elseif table.find(owned, def.Id) then
			b.Text = "EQUIP"
			b.BackgroundColor3 = Color3.fromRGB(0, 150, 190)
		else
			b.Text = "BUY " .. ArtifactData.FormatMoney(def.Price)
			b.BackgroundColor3 = (money >= def.Price) and GREEN or RED
		end
	end
end

player:GetAttributeChangedSignal("Money"):Connect(function()
	if shop.Visible then refreshShop() end
end)
player:GetAttributeChangedSignal("OwnedShovels"):Connect(refreshShop)
player:GetAttributeChangedSignal("EquippedShovel"):Connect(refreshShop)

local shopScale = Instance.new("UIScale")
shopScale.Parent = shop

openShopRemote.OnClientEvent:Connect(function(worldId)
	shopWorld = GameConfig.GetWorld(worldId) or GameConfig.Worlds[1]
	buildRows(shopWorld)
	refreshShop()
	shop.Visible = true
	shopScale.Scale = 0.6
	TweenService:Create(shopScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
end)

closeButton.MouseButton1Click:Connect(function()
	shop.Visible = false
end)

shopMessageRemote.OnClientEvent:Connect(function(message, success)
	showHint(message, success and Color3.fromRGB(90, 255, 120) or Color3.fromRGB(255, 90, 90))
end)
]=])
install(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "WorldClient", "LocalScript", [=[
-- WorldClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The World Map opened at any World Gate: shows every world, whether it's unlocked,
-- its price, and lets you unlock it or travel there.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local openWorldMapRemote = remotes:WaitForChild("OpenWorldMap")
local buyWorldRemote = remotes:WaitForChild("BuyWorld")
local travelRemote = remotes:WaitForChild("TravelToWorld")

local player = Players.LocalPlayer

-- desaturated 2050 panel colors
local PANEL = Color3.fromRGB(30, 31, 34)
local ROW = Color3.fromRGB(46, 48, 52)
local STEEL = Color3.fromRGB(150, 154, 160)
local TEXT = Color3.fromRGB(222, 218, 210)
local SUBTEXT = Color3.fromRGB(150, 156, 164)
local GO = Color3.fromRGB(86, 120, 98)
local BUY = Color3.fromRGB(150, 122, 70)
local LOCKED = Color3.fromRGB(110, 60, 58)
local IDLE = Color3.fromRGB(70, 72, 78)

local gui = Instance.new("ScreenGui")
gui.Name = "WorldMapGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 6)
	c.Parent = parent
end

local function label(parent, text, size, position, color, font)
	local l = Instance.new("TextLabel")
	l.Size = size
	l.Position = position
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = color
	l.Font = font or Enum.Font.GothamMedium
	l.TextScaled = true
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 560, 0, 470)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = PANEL
frame.Visible = false
frame.Parent = gui
corner(frame, 8)
local frameStroke = Instance.new("UIStroke")
frameStroke.Color = STEEL
frameStroke.Thickness = 1.5
frameStroke.Parent = frame

label(frame, "WORLD MAP", UDim2.new(0, 300, 0, 30), UDim2.new(0, 20, 0, 14), TEXT, Enum.Font.GothamBold)
local moneyLabel = label(frame, "", UDim2.new(0, 200, 0, 20), UDim2.new(1, -270, 0, 20), SUBTEXT)
moneyLabel.TextXAlignment = Enum.TextXAlignment.Right

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 34, 0, 34)
close.Position = UDim2.new(1, -48, 0, 12)
close.BackgroundColor3 = IDLE
close.Text = "X"
close.TextColor3 = TEXT
close.Font = Enum.Font.GothamBold
close.TextScaled = true
close.Parent = frame
corner(close, 6)
close.MouseButton1Click:Connect(function()
	frame.Visible = false
end)

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -30, 1, -70)
list.Position = UDim2.new(0, 15, 0, 58)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 5
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new()
list.Parent = frame
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

local buttons = {} -- [worldId] = button

for _, world in ipairs(GameConfig.Worlds) do
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -8, 0, 58)
	row.BackgroundColor3 = ROW
	row.LayoutOrder = world.Id
	row.Parent = list
	corner(row, 6)
	label(row, world.Id .. ".  " .. string.upper(world.Name), UDim2.new(0, 330, 0, 22), UDim2.new(0, 14, 0, 7), TEXT, Enum.Font.GothamBold)
	local sub = world.Enabled and (#world.Shovels .. " shovels  •  4 depth zones down to " .. -world.Zones[#world.Zones].Bottom .. "m")
		or "Still being excavated. Coming soon."
	label(row, sub, UDim2.new(0, 330, 0, 16), UDim2.new(0, 14, 0, 33), SUBTEXT, Enum.Font.Gotham)

	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 150, 0, 38)
	b.Position = UDim2.new(1, -162, 0.5, -19)
	b.TextColor3 = TEXT
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	b.Parent = row
	corner(b, 6)
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 8)
	pad.Parent = b
	buttons[world.Id] = b

	b.MouseButton1Click:Connect(function()
		local unlocked = table.find(string.split(player:GetAttribute("UnlockedWorlds") or "1", ","), tostring(world.Id))
		if not world.Enabled then
			return
		elseif unlocked then
			if player:GetAttribute("CurrentWorld") ~= world.Id then
				travelRemote:FireServer(world.Id)
				frame.Visible = false
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
			b.Text = "SOON  ·  " .. ArtifactData.FormatMoney(world.Price)
			b.BackgroundColor3 = IDLE
		elseif world.Id == current then
			b.Text = "YOU ARE HERE"
			b.BackgroundColor3 = IDLE
		elseif table.find(unlocked, tostring(world.Id)) then
			b.Text = "TRAVEL"
			b.BackgroundColor3 = GO
		else
			b.Text = "UNLOCK " .. ArtifactData.FormatMoney(world.Price)
			b.BackgroundColor3 = (money >= world.Price) and BUY or LOCKED
		end
	end
end

for _, attribute in ipairs({"Money", "UnlockedWorlds", "CurrentWorld"}) do
	player:GetAttributeChangedSignal(attribute):Connect(function()
		if frame.Visible then refresh() end
	end)
end

local scale = Instance.new("UIScale")
scale.Parent = frame
openWorldMapRemote.OnClientEvent:Connect(function()
	refresh()
	frame.Visible = true
	scale.Scale = 0.85
	TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()
end)
]=])
if recording then ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit) end
print("Meme Archaeologist: installed " .. count .. " scripts. Now save the place (Ctrl+S).")
