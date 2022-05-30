map.name = "Watch Your Step"
map.description = "A map littered with explosives, watch your step!"

function map:generateMap(grid)
	for x = grid.minx, grid.maxx do
		for y = grid.miny, grid.maxy do
			if x % 2 == 0 && y % 2 == 0 then
				grid:setExplosiveBox(x, y)
			else
				local val = math.random(1,8)
				if (val <= 5) then
					grid:setBox(x, y)
				else
					grid:setHardBox(x, y)
				end
			end
		end 
	end

	for i=1, math.Clamp(math.ceil(((grid.maxx + grid.maxy) / 5)),1,999) do
		local x = math.random(grid.minx, grid.maxx)
		local y = math.random(grid.miny, grid.maxy)
		grid:setEmpty(x, y)
	end

	--some extra explosives.
	for i=1, math.Clamp(math.ceil(((grid.maxx + grid.maxy) / 4)),1,999) do
		local x = math.random(grid.minx, grid.maxx)
		local y = math.random(grid.miny, grid.maxy)
		grid:setExplosiveBox(x, y)
	end

	for i=1, math.Clamp(math.ceil(((grid.maxx + grid.maxy) / 4)),1,999) do
		local x = math.random(grid.minx, grid.maxx)
		local y = math.random(grid.miny, grid.maxy)
		grid:setWall(x, y)
	end
end