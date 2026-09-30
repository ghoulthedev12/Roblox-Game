-- WorldGimmickManager (Script in ServerScriptService)
-- Attaches each world's gimmicks (see ReplicatedStorage.WorldGimmicks) to that world's folder
-- (workspace.Worlds.WorldN gets a "Gimmick" attribute and a Gimmick folder for its parts),
-- starts its Gimmick_<Module> scripts, and tells them when players enter or leave the world.
--
-- Each Gimmick_<Module> returns a table with:
--   Start(ctx)            once, when the world is built
--   OnEnter(ctx, player)  optional, when a player arrives in the world
--   OnLeave(ctx, player)  optional, when they leave it (or the game)
-- ctx has: World, Container, Folder (for the gimmick's parts), Boosts (DigBoosts),
--   PlayersInWorld(), Announce(text, color), IsHere(player),
--   EventLoop({Every, Duration, Boost, Name, Color, Message, OnStart, OnStop})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local WorldGimmicks = require(ReplicatedStorage:WaitForChild("WorldGimmicks"))
local DigBoosts = require(script.Parent:WaitForChild("DigBoosts"))

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local announceRemote = remotes:WaitForChild("Announcement")

local contexts = {} -- [worldId] = {{Ctx, Module}, ...} (a world can have more than one gimmick)

local function makeContext(world, container, folder)
	local ctx = {World = world, Container = container, Folder = folder, Boosts = DigBoosts}
	function ctx.IsHere(player)
		return player:GetAttribute("CurrentWorld") == world.Id
	end
	function ctx.PlayersInWorld()
		local list = {}
		for _, player in ipairs(Players:GetPlayers()) do
			if ctx.IsHere(player) then table.insert(list, player) end
		end
		return list
	end
	function ctx.Announce(text, color)
		for _, player in ipairs(ctx.PlayersInWorld()) do
			announceRemote:FireClient(player, text, color)
		end
	end
	-- a repeating timed event: a digging boost for everyone in the world while it runs
	function ctx.EventLoop(event)
		task.spawn(function()
			task.wait(event.Every * 0.5)
			while container.Parent do
				if #ctx.PlayersInWorld() > 0 then
					if event.Boost then
						local boost = table.clone(event.Boost)
						boost.Name = event.Name
						DigBoosts.StartWorldEvent(world.Id, boost, event.Duration)
					end
					container:SetAttribute("Event", event.Name)
					ctx.Announce(event.Message, event.Color)
					if event.OnStart then task.spawn(event.OnStart) end
					task.wait(event.Duration)
					container:SetAttribute("Event", "")
					DigBoosts.EndWorldEvent(world.Id)
					if event.OnStop then task.spawn(event.OnStop) end
				end
				task.wait(event.Every)
			end
		end)
	end
	return ctx
end

local function startWorld(world, info)
	local worldsFolder = workspace:WaitForChild("Worlds", 60)
	local container = worldsFolder and worldsFolder:WaitForChild("World" .. world.Id, 60)
	if not container then
		warn("World gimmicks not started for world " .. world.Id)
		return
	end
	container:SetAttribute("Gimmick", table.concat(info.Modules, ","))
	local folder = container:FindFirstChild("Gimmick")
	if folder then folder:Destroy() end
	folder = Instance.new("Folder")
	folder.Name = "Gimmick"
	folder.Parent = container
	contexts[world.Id] = {}
	for _, name in ipairs(info.Modules) do
		local moduleScript = script.Parent:FindFirstChild("Gimmick_" .. name)
		if moduleScript then
			local module = require(moduleScript)
			local ctx = makeContext(world, container, folder)
			table.insert(contexts[world.Id], {Ctx = ctx, Module = module})
			local ok, err = pcall(module.Start, ctx)
			if not ok then warn("World gimmick " .. name .. " failed: " .. tostring(err)) end
		else
			warn("Missing gimmick script Gimmick_" .. name)
		end
	end
end

for worldId, info in pairs(WorldGimmicks) do
	local world = GameConfig.GetWorld(worldId)
	if world and world.Enabled and #info.Modules > 0 then
		task.spawn(startWorld, world, info)
	end
end

local function notify(worldId, hook, player)
	for _, entry in ipairs(worldId and contexts[worldId] or {}) do
		if entry.Module[hook] then task.spawn(entry.Module[hook], entry.Ctx, player) end
	end
end

-- tell the gimmicks when players come and go
local where = {} -- [player] = worldId the gimmicks last saw them in
local function moved(player)
	local now = player:GetAttribute("CurrentWorld")
	local before = where[player]
	if now == before then return end
	where[player] = now
	notify(before, "OnLeave", player)
	notify(now, "OnEnter", player)
end
local function watch(player)
	player:GetAttributeChangedSignal("CurrentWorld"):Connect(function() moved(player) end)
	moved(player)
end
Players.PlayerAdded:Connect(watch)
for _, player in ipairs(Players:GetPlayers()) do watch(player) end
Players.PlayerRemoving:Connect(function(player)
	local before = where[player]
	where[player] = nil
	notify(before, "OnLeave", player)
end)
