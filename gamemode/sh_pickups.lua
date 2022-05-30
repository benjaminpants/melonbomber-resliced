

GM.Pickups = {}
if GAMEMODE then GAMEMODE.Pickups = GM.Pickups end

local function addPickup(id, ref_name, name, color, model, chance)
	local tab = {}
	tab.id = id
	tab.name = name
	tab.Chance = chance
	tab.ref_name = ref_name
	tab.Chance = CreateConVar("mb_chance_" .. tab.ref_name, tab.Chance, bit.bor(FCVAR_NOTIFY), "The weighted value of " .. tab.name )
	tab.color = color
	tab.model = model;
	(GM or GAMEMODE).Pickups[id] = tab
	return tab
end

local pick = addPickup(1, "speed_up", "Speed Up", Color(0, 150, 255), "models/props_junk/Shoe001a.mdl", 20)
pick.AddScale = 1.3
pick.NoList = true
pick.Description = "Increases your speed"
function pick:OnPickup(ply)
	ply:SetRunningBoots(ply:GetRunningBoots() + 1)
end

local pick = addPickup(2, "power_up", "Power Up", Color(220,50,50), "models/props_junk/gascan001a.mdl", 20)
pick.NoList = true
pick.Description = "Increases your bomb's power"
function pick:OnPickup(ply)
	ply:SetBombPower(ply:GetBombPower() + 1)
end


local pick = addPickup(3, "bomb_up", "Bomb Up", Color(50,255,50), "models/props_junk/watermelon01.mdl", 20)
pick.NoList = true
pick.Description = "Increases your max bombs"
function pick:OnPickup(ply)
	ply:SetMaxBombs(ply:GetMaxBombs() + 1)
end

local pick = addPickup(4, "piercing", "Piercing", Color(0, 70, 220), "models/props_junk/sawblade001a.mdl", 2)
pick.AddScale = 0.6
pick.Description = "Bombs pierce through crates"
function pick:OnPickup(ply)
end

local pick = addPickup(5, "power_bomb", "Power Bomb", Color(155, 20, 80), "models/props_junk/watermelon01.mdl", 2)
pick.ModelMaterial = "models/weapons/v_crowbar/crowbar_cyl"
pick.Description = "A special bomb with max power"
function pick:OnPickup(ply)
end


local pick = addPickup(6, "line_bomb", "Line Bomb", Color(150, 0, 180), "models/props_junk/watermelon01.mdl", 2)
pick.Description = "Place a line of bombs"
function pick:OnPickup(ply)
end
function pick:DrawDecor(ent)
	local ang = Angle(0, CurTime() * 13, 0)
	local part = ent:MakeDecorPart("melon1", "models/props_junk/watermelon01.mdl")
	if IsValid(part) then
		part:SetAngles(ang)
		part:SetPos(ent:GetPos() + Vector(0, 0, 4))
		part:SetModelScale(0.5, 0)
		part:DrawModel()
	end
	local part = ent:MakeDecorPart("melon2", "models/props_junk/watermelon01.mdl")
	if IsValid(part) then
		part:SetAngles(ang)
		part:SetPos(ent:GetPos() + Vector(0, 0, 4) + ang:Forward() * 8)
		part:SetModelScale(0.5, 0)
		part:DrawModel()
	end
	local part = ent:MakeDecorPart("melon3", "models/props_junk/watermelon01.mdl")
	if IsValid(part) then
		part:SetAngles(ang)
		part:SetPos(ent:GetPos() + Vector(0, 0, 4) + ang:Forward() * -8)
		part:SetModelScale(0.5, 0)
		part:DrawModel()
	end
end

local pick = addPickup(7, "remote_control", "Remote control", Color(220, 190, 0), "models/props_rooftop/roof_dish001.mdl", 2)
pick.AddScale = 0.4
pick.ZAdd = 0
pick.Description = "Choose when your bombs explode"
function pick:OnPickup(ply)
end


local pick = addPickup(8, "bomb_kick", "Bomb Kick", Color(250, 100, 0), "models/props_junk/Shoe001a.mdl", 6)
pick.AddScale = 1.3
pick.Description = "Push bombs around"
function pick:OnPickup(ply)
end

function pick:DrawDecor(ent)
	local ang = Angle(0, CurTime() * 13, 0)
	local part = ent:MakeDecorPart("boot", "models/props_junk/Shoe001a.mdl")
	if IsValid(part) then
		part:SetAngles(ang)
		part:SetPos(ent:GetPos() + Vector(0, 0, 8) + ang:Forward() * -6)
		part:SetModelScale(1.2, 0)
		part:DrawModel()
	end
	local part = ent:MakeDecorPart("melon", "models/props_junk/watermelon01.mdl")
	if IsValid(part) then
		part:SetAngles(ang)
		part:SetPos(ent:GetPos() + Vector(0, 0, 6) + ang:Forward() * 4)
		part:SetModelScale(0.6, 0)
		part:SetColor(Color(255, 150, 0))
		part:DrawModel()
	end
end

// remote detonation
// models/props_rooftop/roof_dish001.mdl

local pick = addPickup(9, "item_preserve", "Item Preservation", Color(255, 166, 0), "models/props_junk/TrafficCone001a.mdl", 2)
pick.AddScale = 0.7
pick.Description = "Makes your bombs unable to destroy pickups"
function pick:OnPickup(ply)
end

local pick = addPickup(10, "future_vision", "Future Vision", Color(205, 215, 221), "models/barneyhelmet_faceplate.mdl", 1)
pick.AddScale = 1.3
pick.Description = "See what your bombs will explode"
function pick:OnPickup(ply)
end