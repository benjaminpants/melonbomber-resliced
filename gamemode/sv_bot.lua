
--bots are just for funsies, but i can probably make them smarter if i wanted to
function GM:BotMove(ply, cmd)
	local zone, x, y = self:GetGridPosFromEnt(ply)
	if zone then
		if !ply.BotTarget then
			local add = ply.BotLastAdd
			if !add || math.random(0, 5) == 0 then
				local yaw = Angle(0, math.random(0, 3) * 90, 0)
				add = yaw:Forward()
				add.x = math.Round(add.x)
				add.y = math.Round(add.y)
			end
			if self:IsGridPosClear(zone, x + add.x, y + add.y, true) then
				ply.BotTarget = Vector(x + add.x, y + add.y)
				ply.BotLastAdd = add
			else
				ply.BotLastAdd = nil
			end
		end

		if ply.BotTarget then
			if (math.random(1,700) == 1) then
				cmd:SetButtons(IN_ATTACK)
				ply.BotTarget = Vector(ply.BotTarget.x * -2, ply.BotTarget.y * -2) --should make it run away?? maybe??
			end
			if (math.random(1,400) == 1) then
				cmd:SetButtons(IN_ATTACK2)
			end
			for k, v in pairs(ents.FindByClass("mb_melon")) do
				if (v:GetPos():Distance(ply:GetPos()) <= 78) then
					cmd:SetForwardMove(-999) --hope this makes it run away
					return
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
				cmd:SetForwardMove(999)
			end
		end
	end
end