-- SettingsManager (Script in ServerScriptService)
-- Keeps each player's audio settings in their saved data (ProfileService / DataStore), so
-- music and sound volumes stick between visits. The settings go to the client as the
-- "AudioSettings" attribute (JSON) and come back through the SaveAudioSettings remote.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerData = require(script.Parent:WaitForChild("PlayerData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local saveRemote = remotes:FindFirstChild("SaveAudioSettings") or Instance.new("RemoteEvent")
saveRemote.Name = "SaveAudioSettings"
saveRemote.Parent = remotes

local function publish(player, settings)
	player:SetAttribute("AudioSettings", HttpService:JSONEncode(settings))
end

local function onPlayer(player)
	local data = PlayerData.WaitForData(player)
	if not data or not player.Parent then return end
	-- settings saved before the audio fix were far too loud: start those players on the new defaults
	-- (the version is only ever written here, never by the data template, so old saves don't get it for free)
	if data.Settings.Version ~= GameConfig.AudioSettingsVersion then
		data.Settings = table.clone(GameConfig.DefaultAudio)
		data.Settings.Version = GameConfig.AudioSettingsVersion
	end
	publish(player, data.Settings)
end
Players.PlayerAdded:Connect(onPlayer)
for _, player in ipairs(Players:GetPlayers()) do task.spawn(onPlayer, player) end

saveRemote.OnServerEvent:Connect(function(player, settings)
	local data = PlayerData.Get(player)
	if not data or typeof(settings) ~= "table" then return end
	local function volume(v, fallback)
		return typeof(v) == "number" and v == v and math.clamp(v, 0, 1) or fallback
	end
	data.Settings = {
		MusicVolume = volume(settings.MusicVolume, data.Settings.MusicVolume),
		SfxVolume = volume(settings.SfxVolume, data.Settings.SfxVolume),
		MusicMuted = settings.MusicMuted == true,
		SfxMuted = settings.SfxMuted == true,
		Version = GameConfig.AudioSettingsVersion,
	}
	publish(player, data.Settings)
end)
