
function BotDirectionToVector(dir)
	if (dir == 0) then
		return Vector(1, 0, 0);
	elseif (dir == 1) then
		return Vector(0, 1, 0);
	elseif (dir == 2) then
		return Vector(-1, 0, 0);
	elseif (dir == 3) then
		return Vector(0, -1, 0);
	end
	return Vector(0,0,0)
end


function BotDirectionToOpposite(dir)
	if (dir == 0) then
		return 2
	elseif (dir == 1) then
		return 3
	elseif (dir == 2) then
		return 0
	elseif (dir == 3) then
		return 1
	end
	return -1
end

function BotGetViableDirections(x,y,no_dir,zone)
	local dirs = {}
	for i=0, 3 do
		if (i ~= no_dir) then
			local dir = BotDirectionToVector(i)
			if GAMEMODE:IsGridPosClear(zone, x + dir.x, y + dir.y, true) then
				table.insert(dirs,i)
			end
		end
	end
	return dirs
end

function GetFirstUnviableDirection(x,y,zone)
	for i=0, 3 do
		if (i ~= no_dir) then
			local dir = BotDirectionToVector(i)
			if not GAMEMODE:IsGridPosClear(zone, x + dir.x, y + dir.y, true) then
				return i
			end
		end
	end
	return 0
end

function BotGetSafeDirections(x,y,no_dir,zone)
	local dirs = {}
	for i=0, 3 do
		if (i ~= no_dir) then
			local dir = BotDirectionToVector(i)
			local is_safe = #BotGetViableDirections(x + dir.x, y + dir.y,no_dir,zone) ~= 0
			if GAMEMODE:IsGridPosClear(zone, x + dir.x, y + dir.y, true) and is_safe then
				table.insert(dirs,i)
			end
		end
	end
	return dirs
end

function GetClosestDirectionTowardsPointPredict(xpos,ypos,txpos,typos,zone,fear, wander, op_dir) --TODO: SOMETHING IS BROKEN HERE, FIX IT LATER
	local vposx, vposy = xpos, ypos --a "virtual" position, used for predicting the next few turns

	local og_dist = math.floor(math.Distance(xpos,ypos,txpos,typos))

	if (math.Distance(xpos,ypos,txpos,typos) > 3) then
		op_dir = -1
	end
	local viable_dirs = BotGetSafeDirections(vposx,vposy,op_dir,zone)

	if ((#viable_dirs == 0 or math.random(math.ceil(wander * 1.5)) == 1) and not fear) then
		return math.random(0,3) --WE'RE STUCK, HELP!
	end
	if (#viable_dirs == 1) then
		return viable_dirs[1] --straight line.
	end

	local closest_dir = -1
	local closest_dist = 999999999
	if (fear) then
		closest_dist = 0
	end
	for i=1, #viable_dirs do
		local dir = viable_dirs[i]
		local dir_vec = BotDirectionToVector(dir)
		local dist = math.floor(math.Distance(vposx + dir_vec.x,vposy + dir_vec.y,txpos,typos))
		if (vposx + dir_vec.x == txpos and vposy + dir_vec.y == typos and not fear) then
			return dir --we're there!
		end
		for i=1, 1 do --THIS WHOLE THING IS A BIG CLUMP OF SPAGHETTI CODE.
			local a = GetClosestDirectionTowardsPoint(vposx + dir_vec.x,vposy + dir_vec.y,txpos,typos,zone,fear, wander, op_dir)
			local dir_vec_alt = BotDirectionToVector(a)
			if (vposx + dir_vec_alt.x + dir_vec.x == txpos and vposy + dir_vec_alt.y + dir_vec.y == typos and not fear) then
				return dir --we're there!
			end
			dist = math.floor(math.Distance(vposx + dir_vec_alt.x + dir_vec.x,vposy + dir_vec_alt.y + dir_vec.y,txpos,typos))
			vposx, vposy = vposx + dir_vec_alt.x + dir_vec.x, vposy + dir_vec_alt.y + dir_vec.y
		end

		if (not fear) then
			if (dist < closest_dist) then
				closest_dir = dir
				closest_dist = dist
			end
		else
			if (dist > closest_dist) then
				closest_dir = dir
				closest_dist = dist
			end
		end

	end

	if ((closest_dist < og_dist) and fear) then --if moving brings you closer, don't.
		return GetFirstUnviableDirection(xpos,ypos,zone)
	end


	return closest_dir

end


function GetClosestDirectionTowardsPoint(xpos,ypos,txpos,typos,zone,fear, wander, op_dir)

	local viable_dirs = BotGetSafeDirections(xpos,ypos,op_dir,zone)

	local og_dist = math.floor(math.Distance(xpos,ypos,txpos,typos))

	if (#viable_dirs == 0 or (math.random(wander) == 1 and not fear)) then
		return math.random(0,3) --WE'RE STUCK, HELP!
	end
	if (#viable_dirs == 1) then
		if (fear) then --PANIC!!!
			return math.random(0,3)
		end
		return viable_dirs[1] --straight line.
	end
	local closest_dir = -1
	local closest_dist = 999999999
	if (fear) then
		closest_dist = 0
	end
	for i=1, #viable_dirs do
		local dir = viable_dirs[i]
		local dir_vec = BotDirectionToVector(dir)
		local dist = math.floor(math.Distance(xpos + dir_vec.x,ypos + dir_vec.y,txpos,typos))
		if (not fear) then
			if (dist < closest_dist) then
				closest_dir = dir
				closest_dist = dist
			end
		else
			if (dist > closest_dist) then
				closest_dir = dir
				closest_dist = dist
			end
		end

	end

	if ((closest_dist < og_dist) and fear) then --if moving brings you closer, don't.
		return GetFirstUnviableDirection(xpos,ypos,zone)
	end


	return closest_dir



end


function BotChooseRandomViableDirection(x,y,no_dir,zone)
	local viable_dirs = BotGetViableDirections(x,y,no_dir,zone)
	if (#viable_dirs == 0) then
		return no_dir --probably backwards? could cause the bot to just walk into a wall but theres a chance they'll eventually move out of it so just. yeah.
	end
	return table.Random(viable_dirs)
end

function GM:BotMove(ply, cmd)
	local zone, x, y = self:GetGridPosFromEnt(ply)
	if (!ply.BotDefined) then
		ply.BotFireChance = math.random(200,1000)
		ply.BotFire2Chance = math.random(400,900)
		ply.BotWanderChance = math.random(5,25)
		ply.BotMelonFear = math.random(64,80)
		ply.BotCheckoutChance = math.random(20,100)
		ply.NearbyPlayerMultiplier = math.Rand(0.3,2.1)
		ply.PlayerNearbyValue = math.random(128,300)
		ply.BotPickupRange = math.random(80,136)
		ply.BotDefined = true
	end
	if (!ply:Alive()) then
		return --dead bots dont need to do anything. because they are dead.
	end
	if (!ply.BotLastDirection) then
		ply.BotLastDirection = math.random(0,3)
	end
	if (!ply.BotLastTarget or not (IsValid(ply.BotLastTargetEnt) or ply.BotLastTargetEnt == "nil")) then
		ply.BotLastTargetFear = false
		ply.BotLastTargetEnt = "nil" --seperate a target that has no entity("nil") from a target that has an entity(nil)
		if (math.random(1,100) <= ply.BotCheckoutChance or !ply.BotLastTarget) then --some bots may check out things they were previously afraid of, maybe to see if anything changed or just to have a look around
			ply.BotLastTarget = Vector(0,0,-1)
		end
	end
	if (x == ply.BotLastTarget.x and y == ply.BotLastTarget.y) then
		ply.BotLastTargetFear = false
		ply.BotLastTargetEnt = "nil" --seperate a target that has no entity("nil") from a target that has an entity(nil)
		ply.BotLastTarget = Vector(0,0,-1)
	end


	local fire_chance = ply.BotFireChance
	local firec_viable_dir = #BotGetViableDirections(x,y,-1,zone)
	if (firec_viable_dir == 2) then --uh oh, we could trap ourselves if we place a bomb here. (TODO: make a proper hallway detector)
		fire_chance = math.ceil(ply.BotFireChance * 1.65)
	elseif (firec_viable_dir == 1) then --there is only one way out, which is the opposite direction, placing a bomb here is probably safe.
		fire_chance = math.ceil(ply.BotFireChance * 0.65)
	end
	local firec_p = false
	for k, v in pairs(player.GetAll()) do
		if (not firec_p) then
			if (v:GetPos():Distance(ply:GetPos()) <= ply.PlayerNearbyValue and (ply ~= v)) then
				fire_chance = math.ceil(ply.BotFireChance * ply.NearbyPlayerMultiplier)
				firec_p = true
			end
		end
	end
	if (math.random(1,fire_chance) == 1) then
		cmd:SetButtons(IN_ATTACK)
	end

	if (math.random(1,ply.BotFire2Chance) == 1) then
		cmd:SetButtons(IN_ATTACK2)
	end



	for k, v in pairs(ents.FindByClass("mb_melon")) do
		if (v ~= ply.BotLastTargetEnt) then
			if (v:GetPos():Distance(ply:GetPos()) <= ply.BotMelonFear + ((v:GetExplosionLength() / 3) * 36)) then
				local zone, x, y = self:GetGridPosFromEnt(v)
				ply.BotLastTarget = Vector(x,y,0)
				ply.BotLastTargetEnt = v
				ply.BotLastTargetFear = true
				timer.Simple( 5, function() --this has its flaws, but it's a start.
					ply.BotLastTarget = Vector(0,0,-1)
					ply.BotLastTargetEnt = nil
					ply.BotLastTargetFear = false
				end)
			end
		end
	end

	for k, v in pairs(ents.FindByClass("mb_pickup")) do
		if (ply.BotLastTargetEnt == nil) then
			if (v:GetPos():Distance(ply:GetPos()) <= ply.BotPickupRange) then
				local zone, x, y = self:GetGridPosFromEnt(v)
				ply.BotLastTarget = Vector(x,y,0)
				ply.BotLastTargetEnt = v
				ply.BotLastTargetFear = false
			end
		end
	end


	if zone then
		if !ply.BotTarget then
			local add = ply.BotLastAdd
			if (ply.BotLastTarget.z == 0) then
				if ((#BotGetViableDirections(x,y,-1,zone) > 1) and math.random(4) == 1) then --dont always turn hopefully to prevent getting stuck
					add = nil
					ply.BotLastDirection = GetClosestDirectionTowardsPointPredict(x,y,ply.BotLastTarget.x,ply.BotLastTarget.y,zone, ply.BotLastTargetFear, ply.BotWanderChance, BotDirectionToOpposite(ply.BotLastDirection))
				end
			else
				if ((#BotGetViableDirections(x,y,BotDirectionToOpposite(ply.BotLastDirection),zone) > 1) and math.random(8) == 1) then
					add = nil
					ply.BotLastDirection = BotChooseRandomViableDirection(x,y,BotDirectionToOpposite(ply.BotLastDirection),zone)
				end
			end
			if !add then
				if (ply.BotLastDirection ~= -1) then
					local yaw = Angle(0, ply.BotLastDirection * 90, 0)
					add = yaw:Forward()
					add.x = math.Round(add.x)
					add.y = math.Round(add.y)
				else
					add = Vector(0,0,0) --no movement
					ply.BotLastDirection = BotChooseRandomViableDirection(x,y,-1,zone) --dont freeze the script
					return
				end
			end
			if self:IsGridPosClear(zone, x + add.x, y + add.y, true) then
				ply.BotTarget = Vector(x + add.x, y + add.y)
				ply.BotLastAdd = add
			else
				ply.BotLastAdd = nil
				if (ply.BotLastTarget.z == 0) then
					ply.BotLastDirection = GetClosestDirectionTowardsPointPredict(x,y,ply.BotLastTarget.x,ply.BotLastTarget.y,zone, ply.BotLastTargetFear, ply.BotWanderChance, BotDirectionToOpposite(ply.BotLastDirection))
				else
					ply.BotLastDirection = BotChooseRandomViableDirection(x,y,-1,zone)
				end
			end
		end

		if ply.BotTarget then
			local tx, ty = ply.BotTarget.x, ply.BotTarget.y
			local gcenter = (zone:OBBMins() + zone:OBBMaxs()) / 2
			local t = Vector(tx * zone.grid.sqsize, ty * zone.grid.sqsize) + gcenter
			t.z = zone:OBBMins().z

			local look = t - ply:GetPos()
			look.z = 0
			if x == tx && y == ty && look:Length() < zone.grid.sqsize * 0.4 then
				ply.BotTarget = nil
			else
				if look:Length() > zone.grid.sqsize then
					ply.BotTarget = nil
				end
				cmd:SetViewAngles(look:Angle())
				cmd:SetForwardMove(9999)
			end
		end
	end
end