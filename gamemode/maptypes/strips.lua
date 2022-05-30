map.name = "Strips"
map.description = "A regular map containing various mineshaft like strips."


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
	local strips_y = {}
	local strips = math.Clamp(math.ceil(((grid.maxx + grid.maxy) / 5)),1,999)
	for i=1, strips do
		table.insert(strips_x,math.random(grid.minx,grid.maxx))
	end
	for i=1, strips do
		table.insert(strips_y,math.random(grid.miny,grid.maxy))
	end
	for x = grid.minx, grid.maxx do
		for y = grid.miny, grid.maxy do
			if ((not array_contains_value(x,strips_x)) and (not array_contains_value(y,strips_y))) then
				if math.random(20) != 1 then
					if math.random(1, 10) == 1 then
						grid:setHardBox(x, y)
					elseif math.random(1, 25) == 1 then
						grid:setExplosiveBox(x, y)
					else
						grid:setBox(x, y)
					end
				end
			end
		end 
	end

	for i=1, math.Clamp(math.ceil(((grid.maxx + grid.maxy) / 3)),1,999) do
		local x = math.random(grid.minx, grid.maxx)
		local y = math.random(grid.miny, grid.maxy)
		grid:setWall(x, y)
	end
end