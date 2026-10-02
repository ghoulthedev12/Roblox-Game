-- ZFightFixer (Script in ServerScriptService)
-- Two parts with a face in exactly the same place (a glow strip lying flush in a road, two
-- tiles overlapping at the same height, a trim flush with a wall) flicker: the renderer can't
-- tell which one is in front, and it changes its mind every frame as the camera moves.
-- This scans the whole map once it's built (and again when a museum or a free plot is
-- added), finds every such pair of block parts and makes the smaller one a few hundredths
-- of a stud bigger on that side, so it always wins. Far too little to see, and it fixes the
-- flicker anywhere, including on things built later.

local GROW = 0.02       -- how far the smaller part's face is pushed out (0.02 to 0.052)
local SAME_PLANE = 0.006 -- faces closer than this flicker
local CELL = 16         -- spatial grid cell size, studs

-- flat colors without a texture don't visibly flicker when they match exactly
local PLAIN = {[Enum.Material.SmoothPlastic] = true, [Enum.Material.Neon] = true, [Enum.Material.Glass] = true}

local SKIP_FOLDERS = {MuseumVisitors = true, AlienPortals = true}

local function usable(part)
	if part.ClassName ~= "Part" or part.Shape ~= Enum.PartType.Block or part.Transparency >= 0.95 then return false end
	if part:FindFirstChildWhichIsA("DataModelMesh") then return false end -- a mesh changes its shape
	local a = part.Parent
	while a and a ~= workspace do
		if SKIP_FOLDERS[a.Name] or a:FindFirstChildOfClass("Humanoid") then return false end
		a = a.Parent
	end
	return true
end

-- the six faces of a block: outward normal, center, and the two in-plane axes with half sizes
local function faces(part)
	local cf, s = part.CFrame, part.Size / 2
	local axes = {
		{cf.RightVector, s.X, "X", cf.UpVector, s.Y, cf.LookVector, s.Z},
		{cf.UpVector, s.Y, "Y", cf.RightVector, s.X, cf.LookVector, s.Z},
		{cf.LookVector, s.Z, "Z", cf.RightVector, s.X, cf.UpVector, s.Y},
	}
	local list = {}
	for _, a in ipairs(axes) do
		for _, sign in ipairs({1, -1}) do
			table.insert(list, {N = a[1] * sign, Sign = sign, Axis = a[3], C = cf.Position + a[1] * sign * a[2], U = a[4], HU = a[5], V = a[6], HV = a[7]})
		end
	end
	return list
end

-- do two parallel faces in the same plane cover some of the same area?
local function overlap(f, g)
	local d = g.C - f.C
	local gu = math.abs(g.U:Dot(f.U)) * g.HU + math.abs(g.V:Dot(f.U)) * g.HV
	local gv = math.abs(g.U:Dot(f.V)) * g.HU + math.abs(g.V:Dot(f.V)) * g.HV
	local cu, cv = d:Dot(f.U), d:Dot(f.V)
	local ou = math.min(f.HU, cu + gu) - math.max(-f.HU, cu - gu)
	local ov = math.min(f.HV, cv + gv) - math.max(-f.HV, cv - gv)
	return ou > 0.05 and ov > 0.05
end

-- pushes one face of a part out by about GROW (resizing it and moving it half that way);
-- the amount varies a little from push to push, so a row of identical parts that all get
-- pushed doesn't end up lined up again
local pushes = 0
local function pushFace(part, face)
	pushes += 1
	local amount = GROW + (pushes % 5) * 0.008
	local grow = Vector3.new(face.Axis == "X" and amount or 0, face.Axis == "Y" and amount or 0, face.Axis == "Z" and amount or 0)
	part.Size += grow
	part.CFrame = part.CFrame + face.N * (amount / 2)
end

local function bounds(part)
	local cf, s = part.CFrame, part.Size / 2
	local r, u, l = cf.RightVector, cf.UpVector, cf.LookVector
	local ext = Vector3.new(math.abs(r.X) * s.X + math.abs(u.X) * s.Y + math.abs(l.X) * s.Z,
		math.abs(r.Y) * s.X + math.abs(u.Y) * s.Y + math.abs(l.Y) * s.Z,
		math.abs(r.Z) * s.X + math.abs(u.Z) * s.Y + math.abs(l.Z) * s.Z)
	return cf.Position - ext, cf.Position + ext
end

local function touching(a, b)
	return a[1].X <= b[2].X + 0.01 and b[1].X <= a[2].X + 0.01 and a[1].Y <= b[2].Y + 0.01 and b[1].Y <= a[2].Y + 0.01
		and a[1].Z <= b[2].Z + 0.01 and b[1].Z <= a[2].Z + 0.01
end

local function fixAll()
	local parts, boxes, grid = {}, {}, {}
	local n = 0
	for _, d in ipairs(workspace:GetDescendants()) do
		if d:IsA("BasePart") and usable(d) then
			local lo, hi = bounds(d)
			if (hi - lo).Magnitude < 600 then -- skip huge parts (they'd fill thousands of cells)
				table.insert(parts, d)
				boxes[#parts] = {lo, hi}
				for x = math.floor(lo.X / CELL), math.floor(hi.X / CELL) do
					for z = math.floor(lo.Z / CELL), math.floor(hi.Z / CELL) do
						local key = x * 100003 + z
						local cell = grid[key]
						if not cell then
							cell = {}
							grid[key] = cell
						end
						table.insert(cell, #parts)
					end
				end
			end
		end
		n += 1
		if n % 4000 == 0 then task.wait() end
	end
	local checked, fixed = {}, 0
	local cells = 0
	for _, cell in pairs(grid) do
		for a = 1, #cell do
			for b = a + 1, #cell do
				local i, j = cell[a], cell[b]
				local key = i < j and i * 1000003 + j or j * 1000003 + i
				if not checked[key] and touching(boxes[i], boxes[j]) then
					checked[key] = true
					local p, q = parts[i], parts[j]
					if not (p.Color == q.Color and p.Material == q.Material and PLAIN[p.Material]) then
						-- the smaller part gets pushed out, so details (trims, glows, inlays) win
						local small, big = p, q
						if p.Size.X * p.Size.Y * p.Size.Z > q.Size.X * q.Size.Y * q.Size.Z then small, big = q, p end
						local bigFaces = faces(big)
						for _, f in ipairs(faces(small)) do
							for _, g in ipairs(bigFaces) do
								if f.N:Dot(g.N) > 0.9995 and math.abs((g.C - f.C):Dot(f.N)) < SAME_PLANE and overlap(f, g) then
									pushFace(small, f)
									fixed += 1
									break
								end
							end
						end
					end
				end
			end
		end
		cells += 1
		if cells % 400 == 0 then task.wait() end
	end
	return fixed
end

-- wait for the map: World 1's island (MapStyle) and the other worlds and dig sites
local waited = 0
while not workspace:GetAttribute("MainIslandReady") and waited < 40 do
	waited += task.wait(0.5)
end
task.wait(4)

local running, again = false, false
local function run()
	if running then
		again = true
		return
	end
	running = true
	repeat
		again = false
		-- a few rounds: growing one of two equal parts can line it up with a third one
		local total = 0
		for _ = 1, 5 do
			local ok, result = pcall(fixAll)
			if not ok then
				warn("ZFightFixer: " .. tostring(result))
				break
			end
			total += result
			if result == 0 then break end
		end
		if total > 0 then print("ZFightFixer: fixed " .. total .. " flickering faces") end
	until not again
	running = false
end
run()

-- museums appear when players join; free-plot pads come and go
for _, name in ipairs({"Museums", "FreePlots"}) do
	local folder = workspace:FindFirstChild(name)
	if folder then
		folder.ChildAdded:Connect(function()
			task.wait(2)
			run()
		end)
	end
end
