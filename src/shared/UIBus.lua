-- UIBus (ModuleScript in ReplicatedStorage)
-- Lets one LocalScript ask another to open a window (every LocalScript on a player's screen
-- gets the same copy of this module). For example, the HUD's buttons do UIBus.Fire("Shop")
-- and the pickaxe shop listens with UIBus.On("Shop", function() ... end).
-- Names used: Shop, Museum, Teleport, Rebirth, Settings, Inventory, ToggleSound

local UIBus = {}
local events = {}

local function event(name)
	events[name] = events[name] or Instance.new("BindableEvent")
	return events[name]
end

function UIBus.Fire(name, ...)
	event(name):Fire(...)
end

function UIBus.On(name, callback)
	return event(name).Event:Connect(callback)
end

return UIBus
