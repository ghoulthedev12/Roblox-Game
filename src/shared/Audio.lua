-- Audio (ModuleScript in ReplicatedStorage)
-- One place to play sound effects on a player's screen.
--   Audio.sfx("Dig")   plays a sound from GameConfig.Sounds, with:
--     * a pool per sound: at most MaxVoices copies ring at once (the rest are skipped), and
--       the same Sound objects are reused instead of making new ones every time
--     * a rate limit: the same sound can't play again within MinGap seconds (fast digging
--       plays at most ~4 dig sounds a second instead of stacking into noise)
--     * a small random pitch change (Jitter) so repeats sound organic
-- Every effect goes through the "SFX" SoundGroup and music through "Music", so the Settings
-- window (AudioClient) sets each one's volume or mutes it. The SFX group also has a gentle
-- treble cut (softer, less harsh) and a compressor (many sounds at once never get loud).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Audio = {}
local GameConfig -- loaded on first use (GameConfig loads AudioAssets, which is fine either way)

function Audio.group(name)
	local group = SoundService:FindFirstChild(name)
	if not group then
		group = Instance.new("SoundGroup")
		group.Name = name
		group.Parent = SoundService
		if name == "SFX" then
			local eq = Instance.new("EqualizerSoundEffect")
			eq.HighGain = -6 -- take the edge off
			eq.MidGain = -1
			eq.LowGain = 0
			eq.Parent = group
			local comp = Instance.new("CompressorSoundEffect")
			comp.Threshold = -22
			comp.Ratio = 4
			comp.Attack = 0.005
			comp.Release = 0.2
			comp.Parent = group
		end
	end
	return group
end

local pools = {}     -- [name] = {Sound, ...}
local lastPlay = {}  -- [name] = os.clock() of the last play
local rng = Random.new()

local function pool(name, def)
	local list = pools[name]
	if not list then
		list = {}
		for i = 1, def.MaxVoices or 1 do
			local sound = Instance.new("Sound")
			sound.Name = "SFX_" .. name .. i
			sound.SoundId = def.Id
			sound.SoundGroup = Audio.group("SFX")
			sound.Parent = SoundService
			table.insert(list, sound)
		end
		pools[name] = list
	end
	return list
end

-- plays GameConfig.Sounds[name]; pitch multiplies the sound's own (jittered) pitch
function Audio.sfx(name, pitch)
	GameConfig = GameConfig or require(ReplicatedStorage:WaitForChild("GameConfig"))
	local def = GameConfig.Sounds[name]
	if not def or not def.Id or def.Id == "" then return end
	local now = os.clock()
	if now - (lastPlay[name] or 0) < (def.MinGap or 0.05) then return end -- rate limit
	local free
	for _, sound in ipairs(pool(name, def)) do
		if not sound.IsPlaying then
			free = sound
			break
		end
	end
	if not free then return end -- every voice is busy: skip rather than stack
	lastPlay[name] = now
	local jitter = def.Jitter or 0
	free.Volume = def.Mix or 1
	free.PlaybackSpeed = (1 + rng:NextNumber(-jitter, jitter)) * (pitch or 1)
	free.TimePosition = 0
	free:Play()
end

-- a one-off sound by id (kept for anything not in GameConfig.Sounds); quiet by default
function Audio.play(id, volume, pitch)
	if not id or id == "" then return end
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Volume = math.min(volume or 0.2, 1)
	sound.PlaybackSpeed = pitch or 1
	sound.SoundGroup = Audio.group("SFX")
	sound.Parent = SoundService
	sound:Play()
	sound.Ended:Once(function() sound:Destroy() end)
	task.delay(6, function() if sound.Parent then sound:Destroy() end end)
end

return Audio
