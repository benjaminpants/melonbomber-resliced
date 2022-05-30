map.name = "Frankenstein"
map.description = "Multiple maps get merged into one"

function map:generateMap(grid)
	local grid_c = MapMakerGrid(grid.minx, grid.miny, grid.maxx, grid.maxy)
	local maptype = table.Random(MapTypes)
	maptype:generateMap(grid_c)
	for x = grid.minx, grid.maxx do
		for y = grid.miny, grid.maxy do
			if (y % 10 == 0 and x % 10 == 0) then
				maptype = table.Random(MapTypes)
				grid_c = MapMakerGrid(grid.minx, grid.miny, grid.maxx, grid.maxy)
				maptype:generateMap(grid_c)
			end
			grid:setTile(x,y,grid_c:getTile(x,y))
		end 
	end
end