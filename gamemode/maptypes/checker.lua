map.name = "Checkerboard";
map.description = "A checkboard of hard and soft boxes with a few explosives placed randomly"

function map:generateMap(grid)
	local i = 1
	for x = grid.minx, grid.maxx do
		for y = grid.miny, grid.maxy do
			i = i + 1
			if i % 2 == 0 then
				grid:setHardBox(x, y)
			else
				if (math.random(1,5) ~= 1) then
					grid:setBox(x, y)
				else
					grid:setExplosiveBox(x, y)
				end
			end
		end 
	end

	for i=1, math.Clamp(math.ceil(((grid.maxx + grid.maxy) / 4)),1,999) do
		local x = math.random(grid.minx, grid.maxx)
		local y = math.random(grid.miny, grid.maxy)
		grid:setEmpty(x, y)
	end

end