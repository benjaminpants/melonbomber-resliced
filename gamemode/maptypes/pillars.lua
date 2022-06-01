map.name = "Pillars"
map.description = "Tall super sturdy pillars with a singular explosive tile as a way of entry."


local function array_contains_value(value,array)
	for i=1, #array do
		if (array[i] == value) then
			return true
		end
	end
	return false
end


function map:generateMap(grid)
	local strips_x = {}
	local strips = math.Clamp(math.ceil(((grid.maxx + grid.maxy) / 5)),1,999)
	for i=1, strips do
		table.insert(strips_x,math.random(grid.minx,grid.maxx))
	end
	for x = grid.minx, grid.maxx do
		for y = grid.miny, grid.maxy do
			if ((not array_contains_value(x,strips_x))) then
				if math.random(4) != 1 then
					if x % 2 != y % 2 && math.random(1, 15) == 1 then
						grid:setHardBox(x, y)
					elseif x % 2 == y % 2 && math.random(1, 15) == 1 then
						grid:setExplosiveBox(x, y)
					else
						grid:setBox(x, y)
					end
				end
			else
				grid:setTileRaw(x,y, "metal_box")
			end
		end 
	end

	for i=1, #strips_x do
		local x = strips_x[i]
		local y = math.random(grid.miny, grid.maxy)
		grid:setExplosiveBox(x, y)
	end
end