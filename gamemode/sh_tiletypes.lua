GM.TileTypes = {}

GM.FindTileTypeByName = function(name)
    for k,v in pairs((GM or GAMEMODE).TileTypes) do
        if v.Name == name then
            return v
        end
    end
    return nil
end

GM.addTile = function(display_name,internal_name, data)
    data.DisplayName = display_name
    data.Name = internal_name
    table.insert((GM or GAMEMODE).TileTypes,data)
    return data

end

if GAMEMODE then 
    GAMEMODE.TileTypes = GM.TileTypes 
    GAMEMODE.FindTileTypeByName = GM.FindTileTypeByName
    GAMEMODE.addTile = GM.addTile
end

--"Box" is the template, any new block parameters should be added to Box.
GM.addTile("Box","box", {
    Material = "models/props/CS_militia/roofbeams03",
    Strength = 1,
    BlockExplosions = false,
    OnVisualsInit = function(ent, extra_data)
        local b = math.random(200, 255)
		ent:SetColor(Color(255, b, b))
    end,
    PostInit = nil,
    OnExplode = nil
})

GM.addTile("Stone","strong_box", {
    Material = "models/props_c17/metalladder002",
    Strength = 3,
    OnExplode = nil,
    OnVisualsInit = nil
})

GM.addTile("TNT","explosive", {
    Material = "models/props_c17/canister02a",
    Strength = 1,
    OnExplode = function(gm, zone, x, y, ent, combiner) --TODO: FIGURE OUT WHY TF GM IS NIL AND FIX IT. UGH.
        ent.HasExploded = true
		gm:CreateExplosion(zone, x, y, 5, ent, combiner)
    end,
    OnVisualsInit = nil
})

GM.addTile("Wall","wall", {
    Material = "models/props_canal/metalwall005b",
    OnVisualsInit = function(ent, extra_data)
        if (extra_data == true) then
            ent:SetMaterial("models/props_c17/metalladder003")
        end
    end,
    Strength = 0,
    BlockExplosions = true,
    OnVisualsInit = nil
})