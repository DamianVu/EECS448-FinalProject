
class = require '30log'					--| Object orientation framework
HC = require './HC'   					--| Collision Detection


-- TODO Tile Objects will have all information for a given tile that needs to be realized. Render position, size, collision enable, etc.
--Tile-- Class definition and constructor, new_tile
Tile = class {id, x, y, width, height, collision} -- Will likely need to add parameters
function new_tile(id, x, y, width, height, collision)
	local tile = Tile()
	tile.id = id							 --|int - integer representation of Tile
	tile.x = x								 --|int - x coordinate of upper-left corner
	tile.y = y								 --|int - y coordinate of upper-left corner
	tile.width = width				 --|int - Tile width
	tile.height = height			 --|int - Tile height
	tile.collision = collision --|bool - collision enabled
	return tile
end
-- End --


--
-- --TileDictionary-- Class definition and constructor, new_TileDictionary
-- -- Specifies the properties of a Tile ID (e.g. disable collision for 2)
-- TileDictionary = class {dict}
-- function new_TileDictionary(dict)
-- 	local td = TileDictionary()
-- 	td.dict = dict
-- end
-- -- End --

--Map-- Class definition and constructor, new_map
Map = class {tiles, id_dict}
function new_map(grid, id_dict)
	local map = Map()
	map.tiles = {}
	map.id_dict = id_dict

	for rowIndex = 1, #grid do --Fill map with tiles, where id is the number in the grid
		local row = grid[rowIndex]
		map.tiles[rowIndex] = {}
		for columnIndex = 1, #row do
			local id = row[columnIndex]
			local nthTile = new_tile(id, x, y, width, height, map.id_dict[id].collision)
			map.tiles[rowIndex][columnIndex] = nthTile
		end
	end
	return map
end
-- End --

--Tileset-- Class definition and constructor, new_tileset
Tileset = class {map = {}, img, width, height, tileWidth, tileHeight}
function new_tileset(map, img, width, height, tileWidth, tileHeight)
	local ts = Tileset()
	ts.map = map                        -- map - 2d array of Tile objects
	ts.img = img												-- img - love.graphics.newImage('image/path.png')
	ts.width = width										-- width - width of tileset = img.getWidth()
	ts.height = height									-- height - height of tileset = img.getHeight()
	ts.tileWidth = tileWidth						-- tileWidth - Width of tile in set
	ts.tileHeight = tileHeight					-- tileHeight - Height of tile in set
	return ts
end
-- End --



-- Load the tileset to be worked on for our game. TODO works with csv format if we added a loadmapfile(file), for example
function load_tileset()

	--Test Map data-- Here is what we need to create a test map for the time being
	test_grid = {
		{1,1,1,1,1,1,1,1},
		{1,2,2,2,2,2,2,1},
		{1,2,3,3,2,2,2,1},
		{1,2,2,2,2,2,2,1},
		{1,1,1,2,2,2,2,1},
		{1,2,2,2,2,1,1,1},
		{1,2,2,2,2,2,2,1},
		{1,1,1,1,1,1,1,1}
	}
	test_id_dict = {1,2,3}								--Tile IDs in the map
	test_id_dict[1] = {collision = true}		--Properties of each Tile ID. Only have collision for now
	test_id_dict[2] = {collision = false}
	test_id_dict[3] = {collision = true}
	test_map = new_map(test_grid, test_id_dict)
end

function load_tilesets()
	test_set = love.graphics.newImage('images/tilesets/testset.png')
	--END--


	-- Create the object for the tileset to be worked with in the rendering stage
	ts = new_tileset(test_map, test_set, test_set:getWidth(), test_set:getHeight(), 64, 64)

	-- Specify tiles of tileset
	-- TODO do this in an indefinite loop? To allow for unspecified tileset dimensions?
	-- TODO Integrate Quads as a property of the tileset
	Quads = {
		love.graphics.newQuad(0, 0, ts.tileWidth, ts.tileHeight, ts.width, ts.height),
		love.graphics.newQuad(64, 0, ts.tileWidth, ts.tileHeight, ts.width, ts.height),
		love.graphics.newQuad(0, 64, ts.tileWidth, ts.tileHeight, ts.width, ts.height),
		love.graphics.newQuad(64, 64, ts.tileWidth, ts.tileHeight, ts.width, ts.height)
	}


end







-- EVERYTHING IS WORST CASE SCENARIO ON PURPOSE

-- This function will take in an objects x, y coords and its width/height. This will allow us to highlight tiles around it.
function highlightTiles(x, y, width, height) -- Assumption: x, y is in the center of the sprite
	-- We know we're in a tile if our width + x/2 or width - x/2 along with height + y/2 and height -y/2 overlaps with a tile.

	-- Initial testing. This will not utilize width/height yet.

	-- Get the tile that our x,y is currently in. We don't even technically need a tilecount for this, we know that the map starts at 0,0

	temp = {}
	intermediate = {}

	table.insert(temp, {math.floor((x - (width/2)) / 64), math.floor((y - (height/2)) / 64)})
	table.insert(temp, {math.floor((x + (width/2)) / 64), math.floor((y - (height/2)) / 64)})
	table.insert(temp, {math.floor((x - (width/2)) / 64), math.floor((y + (height/2)) / 64)})
	table.insert(temp, {math.floor((x + (width/2)) / 64), math.floor((y + (height/2)) / 64)})

	-- Worst case scenario is all 16 of these inserts

	table.insert(intermediate, {temp[1][1] - 1, temp[1][2] - 1})
	table.insert(intermediate, {temp[1][1] - 1, temp[1][2]})
	table.insert(intermediate, {temp[1][1], temp[1][2] - 1})

	table.insert(intermediate, {temp[2][1] + 1, temp[2][2] - 1})
	table.insert(intermediate, {temp[2][1] + 1, temp[2][2]})
	table.insert(intermediate, {temp[2][1], temp[2][2] - 1})

	table.insert(intermediate, {temp[3][1] - 1, temp[3][2] + 1})
	table.insert(intermediate, {temp[3][1] - 1, temp[3][2]})
	table.insert(intermediate, {temp[3][1], temp[3][2] + 1})

	table.insert(intermediate, {temp[4][1] + 1, temp[4][2] + 1})
	table.insert(intermediate, {temp[4][1] + 1, temp[4][2]})
	table.insert(intermediate, {temp[4][1], temp[4][2] + 1})

	-- Yellow for intermediate tiles, Orange for intermediate collisions
	for i = 1, #intermediate do
		love.graphics.setColor(255, 255, 0)
		love.graphics.rectangle("line", intermediate[i][1] * 64, intermediate[i][2] * 64, 64, 64)
	end

	-- Red for the tile we are currently in
	love.graphics.setColor(255, 0, 0)
	for ind = 1, #temp do
		love.graphics.rectangle("line", temp[ind][1] * 64, temp[ind][2] * 64, 64, 64)
	end



end


function draw_tiles()

	--[=====[
        
	-- This code will center the map on screen
	local y_count = 0
	local finalx = 0

	for ff = 1, #ts.map.tiles do
		y_count = y_count + 1
		local row = ts.map.tiles[ff]
		local x_count = 0
		for ffa = 1, #row do
			x_count = x_count + 1
			if x_count > finalx then
				finalx = x_count
			end
		end
	end
	]=====]--

	local start_x = -(64 * (finalx or 0) / 2)
	local start_y = -(64 * (y_count or 0) / 2)
	-- End of centering map on screen


	-- MAP RENDER FUNCTION: Render ts.map.tiles from tileset onscreen
	for rowIndex = 1, #ts.map.tiles do
		local row = ts.map.tiles[rowIndex]
		for columnIndex = 1, #row do
			local number = row[columnIndex].id
			local x, y = start_x + ((columnIndex - 1) * ts.tileWidth), start_y + ((rowIndex - 1) * ts.tileHeight)
			HC.rectangle(x, y, ts.tileWidth, ts.tileHeight)
			love.graphics.draw(ts.img, Quads[number], x, y) -- Draw Tile
		end
	end


end
