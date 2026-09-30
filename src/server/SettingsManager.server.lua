-- SettingsManager (Script in ServerScriptService)
-- Keeps each player's audio settings in their saved data (ProfileService / DataStore), so
-- music and sound volumes stick between visits. The settings go to the client as the
-- "AudioSettings" attribute (JSON) and come back through the SaveAudioSettings remote.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerData = require(script.Parent:WaitForChild("PlayerData"))

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local saveRemote = remotes:FindFirstChild("SaveAudioSettings") or Instance.new("RemoteEvent")
saveRemote.Name = "SaveAudioSettings"
saveRemote.Parent = remotes

local function publish(player, settings)
	player:SetAttribute("AudioSettings", HttpService:JSONEncode(settings))
end

local function onPlayer(player)
	local data = PlayerData.WaitForData(player)
	if data and player.Parent then publish(player, data.Settings) end
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
	}
	publish(player, data.Settings)
end)
