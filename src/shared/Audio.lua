-- Audio (ModuleScript in ReplicatedStorage)
-- One place to play sound effects on a player's screen. Every effect goes through the "SFX"
-- SoundGroup, and music through the "Music" SoundGroup, so the settings window (AudioClient)
-- can set each one's volume or mute it. Audio.play(id, volume, pitch)

local SoundService = game:GetService("SoundService")

local Audio = {}

function Audio.group(name)
	local group = SoundService:FindFirstChild(name)
	if not group then
		group = Instance.new("SoundGroup")
		group.Name = name
		group.Parent = SoundService
	end
	return group
end

function Audio.play(id, volume, pitch)
	if not id or id == "" then return end
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Volume = volume or 0.6
	sound.PlaybackSpeed = pitch or 1
	sound.SoundGroup = Audio.group("SFX")
	sound.Parent = SoundService
	sound:Play()
	sound.Ended:Once(function() sound:Destroy() end)
	task.delay(6, function() if sound.Parent then sound:Destroy() end end)
end

return Audio
