

class = require '30log'					--| Object orientation framework
HC = require './HC'   					--| Collision Detection

-- TODO
-- Make a Tile class for Tile objects
--     -- Tile Objects will have all information for a given tile that needs to be realized. Render position, size, collision enable, etc.

-- Begin -- Tileset Class Definition and constructor, new_tileset
Tileset = class {map = {}, img, width, height, tileWidth, tileHeight}

function new_tileset(map, img, width, height, tileWidth, tileHeight)
	local ts = Tileset()
	ts.map = map
	ts.img = img
	ts.width = width
	ts.height = height
	ts.tileWidth = tileWidth
	ts.tileHeight = tileHeight
	return ts
end
-- End -- Tileset Class Definition and constructor


-- Load a tileset called ts, and
function load_tileset()

	-- The test map for our tileset. will be importable from csv file eventually
	Map = {
		{1,1,1,1,1,1},
		{1,2,2,2,2,1},
		{1,2,2,2,2,1},
		{1,2,2,2,2,1},
		{1,1,1,2,2,1}
	}
	test_set = love.graphics.newImage('images/tilesets/testset.png')

	ts = new_tileset(Map, test_set, test_set:getWidth(), test_set:getHeight(), 64, 64) -- Here we create a tileset object as an example.


	-- Specify tiles of tileset TODO maybe do this in an indefinite loop? To allow for unspecified tileset dimensions?
	Quads = {
		love.graphics.newQuad(0, 0, ts.tileWidth, ts.tileHeight, ts.width, ts.height),
		love.graphics.newQuad(64, 0, ts.tileWidth, ts.tileHeight, ts.width, ts.height),
		love.graphics.newQuad(0, 64, ts.tileWidth, ts.tileHeight, ts.width, ts.height),
		love.graphics.newQuad(64, 64, ts.tileWidth, ts.tileHeight, ts.width, ts.height)
	}

end

function draw_tiles()

	-- This code will center the map on screen
	local y_count = 0
	local finalx = 0

	for ff = 1, #ts.map do
		y_count = y_count + 1
		local row = ts.map[ff]
		local x_count = 0
		for ffa = 1, #row do
			x_count = x_count + 1
			if x_count > finalx then
				finalx = x_count
			end
		end
	end

	local start_x = -(64 * finalx / 2)
	local start_y = -(64 * y_count / 2)
	-- End of centering map on screen


	-- Render ts.map from tileset onscreen
	for rowIndex = 1, #ts.map do
		local row = ts.map[rowIndex]
		for columnIndex = 1, #row do
			local number = row[columnIndex]
			local x, y = start_x + ((columnIndex - 1) * ts.tileWidth), start_y + ((rowIndex - 1) * ts.tileHeight)
			HC.rectangle(x, y, ts.tileWidth, ts.tileHeight)
			love.graphics.draw(ts.img, Quads[number], x, y) -- Draw Tile
		end
	end


end
