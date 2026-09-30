-- AudioClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Background music and the audio settings.
--   * Music: GameConfig.Music has a track per world; when you travel it crossfades to the
--     new world's track (or GameConfig.Music.Default).
--   * Two SoundGroups: "Music" and "SFX" (every sound effect plays through SFX, see Audio).
--   * SETTINGS window (UIBus "Settings"): a volume slider and a mute button for each group.
--   * The speaker button on the HUD (UIBus "ToggleSound") mutes / unmutes everything at once.
--   Settings are saved in your data (SettingsManager) so they stick between visits.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Audio = require(ReplicatedStorage:WaitForChild("Audio"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local UIBus = require(ReplicatedStorage:WaitForChild("UIBus"))
local UIKit = require(ReplicatedStorage:WaitForChild("UIKit"))
local C = UIKit.Colors
local saveRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SaveAudioSettings")

local player = Players.LocalPlayer
local musicGroup, sfxGroup = Audio.group("Music"), Audio.group("SFX")

local settings = table.clone(GameConfig.DefaultAudio) -- Music 30%, SFX 20% until your saved settings load

local function apply()
	musicGroup.Volume = settings.MusicMuted and 0 or settings.MusicVolume
	sfxGroup.Volume = settings.SfxMuted and 0 or settings.SfxVolume
	player:SetAttribute("SoundMuted", settings.MusicMuted and settings.SfxMuted) -- the HUD speaker icon reads this
end

-- saving is throttled (sliders fire a lot while dragging)
local saveQueued = false
local function save()
	apply()
	if saveQueued then return end
	saveQueued = true
	task.delay(1, function()
		saveQueued = false
		saveRemote:FireServer(settings)
	end)
end

---------------------------------------------------------------------
-- MUSIC: one track per world, crossfading when you travel
---------------------------------------------------------------------
local current -- the Sound playing now
local function trackFor(worldId)
	local id = GameConfig.Music[worldId]
	if not id or id == "" then id = GameConfig.Music.Default end
	return id ~= "" and id or nil
end
local function playMusic(worldId)
	local id = trackFor(worldId)
	if current and current.SoundId == id then return end
	local old = current
	current = nil
	if old then
		TweenService:Create(old, TweenInfo.new(GameConfig.MusicCrossfade), {Volume = 0}):Play()
		task.delay(GameConfig.MusicCrossfade + 0.1, function() old:Destroy() end)
	end
	if not id then return end
	local sound = Instance.new("Sound")
	sound.Name = "BackgroundMusic"
	sound.SoundId = id
	sound.Looped = true
	sound.Volume = 0
	sound.SoundGroup = musicGroup
	sound.Parent = SoundService
	sound:Play()
	TweenService:Create(sound, TweenInfo.new(GameConfig.MusicCrossfade), {Volume = GameConfig.MusicVolume}):Play()
	current = sound
end
player:GetAttributeChangedSignal("CurrentWorld"):Connect(function()
	playMusic(player:GetAttribute("CurrentWorld") or 1)
end)
playMusic(player:GetAttribute("CurrentWorld") or 1)

---------------------------------------------------------------------
-- SETTINGS WINDOW
---------------------------------------------------------------------
local gui = UIKit.screen(player, "SettingsGui", 8)
local window, content = UIKit.window(gui, "SETTINGS", UDim2.fromOffset(460, 330), C.Sky, "⚙️")

-- one row: icon + name, a mute button, and a slider underneath
local function audioRow(y, icon, title, volumeKey, mutedKey)
	UIKit.label(content, icon .. "  " .. title, {Size = UDim2.new(0.6, 0, 0, 30), Position = UDim2.fromOffset(8, y), Align = "Left", Color = C.Ink, Stroke = 0, MaxText = 24})
	local mute = UIKit.button(content, "", {Size = UDim2.fromOffset(120, 38), Position = UDim2.new(1, -8, 0, y - 4), AnchorPoint = Vector2.new(1, 0), Radius = 19, MaxText = 16})
	local track = UIKit.panel(content, {Size = UDim2.new(1, -90, 0, 14), Position = UDim2.fromOffset(8, y + 50), Color = C.PanelTint, Radius = 7, Stroke = 2, StrokeColor = C.Lilac, Shade = false})
	local fill = UIKit.panel(track, {Size = UDim2.fromScale(1, 1), Color = C.Sky, Radius = 7, Stroke = false, Shade = false})
	local knob = UIKit.panel(track, {Size = UDim2.fromOffset(26, 26), Position = UDim2.fromScale(1, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Color = C.White, Radius = 13, Stroke = 3, StrokeColor = C.Sky, Shade = false})
	local percent = UIKit.label(content, "", {Size = UDim2.fromOffset(64, 24), Position = UDim2.new(1, -8, 0, y + 45), AnchorPoint = Vector2.new(1, 0), Color = C.Grey, Stroke = 0, MaxText = 18})
	local function refresh()
		local v = settings[volumeKey]
		fill.Size = UDim2.fromScale(v, 1)
		knob.Position = UDim2.fromScale(v, 0.5)
		percent.Text = math.floor(v * 100 + 0.5) .. "%"
		local muted = settings[mutedKey]
		UIKit.setButton(mute, muted and "🔇 MUTED" or "🔊 ON", muted and C.Coral or C.Mint)
		fill.BackgroundColor3 = muted and C.Grey or C.Sky
	end
	mute.MouseButton1Click:Connect(function()
		settings[mutedKey] = not settings[mutedKey]
		refresh()
		save()
	end)
	-- dragging the slider (mouse or touch)
	local dragging = false
	local function setFrom(x)
		local v = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		settings[volumeKey] = math.floor(v * 100 + 0.5) / 100
		if settings[volumeKey] > 0 then settings[mutedKey] = false end
		refresh()
		save()
	end
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setFrom(input.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			setFrom(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	return refresh
end

local refreshMusic = audioRow(14, "🎵", "Music", "MusicVolume", "MusicMuted")
local refreshSfx = audioRow(118, "🔔", "Sound Effects", "SfxVolume", "SfxMuted")
UIKit.label(content, "Your settings are saved and stick between visits.", {Size = UDim2.new(1, -16, 0, 20), Position = UDim2.new(0.5, 0, 1, -30), AnchorPoint = Vector2.new(0.5, 0),
	Color = C.Grey, Stroke = 0, Font = UIKit.BodyFont, MaxText = 15})

local function refreshAll()
	refreshMusic()
	refreshSfx()
	apply()
end

UIBus.On("Settings", function()
	if window.Visible then
		window.Visible = false
	else
		refreshAll()
		UIKit.open(window)
	end
end)
-- the HUD's speaker button: everything off, or back to how it was
UIBus.On("ToggleSound", function()
	local allMuted = settings.MusicMuted and settings.SfxMuted
	settings.MusicMuted = not allMuted
	settings.SfxMuted = not allMuted
	refreshAll()
	save()
end)

-- load the saved settings
local function load()
	local raw = player:GetAttribute("AudioSettings")
	if typeof(raw) ~= "string" then return end
	local ok, saved = pcall(function() return HttpService:JSONDecode(raw) end)
	if ok and typeof(saved) == "table" then
		for key in pairs(settings) do
			if saved[key] ~= nil and key ~= "Version" then settings[key] = saved[key] end
		end
		refreshAll()
	end
end
player:GetAttributeChangedSignal("AudioSettings"):Connect(function()
	if not saveQueued then load() end
end)
load()
refreshAll()
