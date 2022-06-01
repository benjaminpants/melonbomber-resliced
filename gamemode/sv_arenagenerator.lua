
ClassGenerator = class()
local Gen = ClassGenerator

function Gen:initialize(grid, mins, maxs, width, height)
	self.containers = {}
	self.walls = {}
	self.crates = {}
	self.grid = grid
	self.mins = mins
	self.maxs = maxs
	self.center = (maxs + mins) / 2
	self.width = math.Round(width)
	self.height = math.Round(height)
end

function Gen:spawnProp(pos, ang, mdl, opts)
	local ent = ents.Create("prop_physics")
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetModel(mdl)
	ent:Spawn()
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		if !opts || !opts.nofreeze then
			phys:EnableMotion(false)
		end
	end
	if !opts || !opts.nomotion then
		-- ent:SetMoveType(MOVETYPE_NONE)
	end
	local skins = ent:SkinCount()
	ent:SetSkin(math.random(skins))
	return ent
end

// 0 is neg y
// 1 is pos x
// 2 is pos y
// 3 is neg x


--TODO: this system is not very flexible

function Gen:CreateBox(x,y, type_name, extra_params)
	local type = GAMEMODE.FindTileTypeByName(type_name) or GAMEMODE.TileTypes[1]

	local angles = Angle(0, 0, 0)

	local size = 20
	local add = self.center + Vector(self.grid.sqsize, 0, 0) * x  + Vector(0, self.grid.sqsize, 0) * y
	local pos = add * 1
	pos.z = self.mins.z

	local ent = self:spawnProp(pos, angles, "models/hunter/blocks/cube075x075x075.mdl")
	ent:SetMaterial(type.Material)
	if (type.OnVisualsInit) then
		type.OnVisualsInit(ent, extra_params)
	end

	local phys = ent:GetPhysicsObject() --does this even do anything???
	if IsValid(phys) then
	end

	pos.z = pos.z - ent:OBBMins().z + math.Rand(0, 0.05) - 4
	ent:SetPos(pos)

	ent.gridX = x
	ent.gridY = y
	if (not type.BlockExplosions) then
		ent.gridType = "box"
	else
		ent.gridType = "wall"
	end
	ent.gridTileType = type_name
	ent.gridWalkable = type.Walkable or true
	ent.gibType = type.GibType or "wood"
	ent.gridBreakable = type.Strength ~= 0
	ent.gridSolid = true
	ent.gridStrength = type.Strength or 1
	ent.gridMaxStrength = type.Strength or 1
	ent.gridExplosive = type.OnExplode ~= nil
	ent.gridSpawnClearable = type.SpawnClearable or true

	self.grid:setSquare(x, y, ent)

	if (type.PostInit) then
		type.PostInit(ent, extra_params)
	end

	return ent

end

function Gen:createWall(x, y, t)
	local angles = Angle(0, 0, 90)

	local size = 20
	local add = self.center + Vector(self.grid.sqsize, 0, 0) * x  + Vector(0, self.grid.sqsize, 0) * y
	local pos = add * 1
	pos.z = self.mins.z

	local ent = self:spawnProp(pos, angles, "models/hunter/blocks/cube075x075x075.mdl")
	if t == 2 then
		ent:SetMaterial("models/props_c17/metalladder003")
	else
		ent:SetMaterial("models/props_canal/metalwall005b")
	end
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
	end

	pos.z = pos.z - ent:OBBMins().z + math.Rand(-0.1, 0.1)
	ent:SetPos(pos)

	ent.gridX = x
	ent.gridY = y
	ent.gridType = "wall"
	ent.gridWalkable = false
	ent.gridSolid = true
	table.insert(self.walls, ent)

	self.grid:setSquare(x, y, ent)
	return ent
end

function Gen:generate()

	local maptype = table.Random(MapTypes)
	if GAMEMODE.MapVoting then
		GAMEMODE.MapVoting = false
		local votes = {}
		for ply, map in pairs(GAMEMODE.MapVotes) do
			if IsValid(ply) && ply:IsPlayer() then
				votes[map] = (votes[map] or 0) + 1
			end
		end

		local maxvotes = 0
		for k, v in pairs(votes) do
			if v > maxvotes then
				maxvotes = v
			end
		end

		local maps = {}
		for k, v in pairs(votes) do
			if v == maxvotes then
				table.insert(maps, k)
			end
		end

		if #maps > 0 then
			maptype = table.Random(maps)
			print("Map " .. maptype.key .. " selected with " .. maxvotes .. " votes")
		end
	end
	print("New map is: " .. (maptype.name or "error"))

	local minx, miny = math.floor(-self.width / 2), math.floor(-self.height / 2)
	local grid = MapMakerGrid(minx, miny, minx + self.width, miny + self.height)
	maptype:generateMap(grid)

	// generate map
	for x = grid.minx, grid.maxx do
		for y = grid.miny, grid.maxy do
			if (grid:getEmpty(x,y)) then
				self:CreateBox(x, y, grid:getTile(x,y))
			end
		end
	end

	// generate walls around map
	for i = -self.grid.sizeLeft - 1, self.grid.sizeRight + 1 do 
		self:CreateBox(i, -self.grid.sizeUp - 1, "wall", true)
		self:CreateBox(i, self.grid.sizeDown + 1, "wall", true)
	end

	for i = -self.grid.sizeUp, self.grid.sizeDown do
		self:CreateBox(-self.grid.sizeLeft - 1, i, "wall", true)
		self:CreateBox(self.grid.sizeRight + 1, i, "wall", true)
	end

end

// capture point
// models/props_combine/combinecrane002.mdl