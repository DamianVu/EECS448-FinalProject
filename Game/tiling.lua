

class = 	require '30log'				--| Object orientation framework
HC = require './HC'   --| Collision Detection

-- Map for testing - Map files will look like this
Map = {
	{1,1,1,1,1,1},
	{1,2,2,2,2,1},
	{1,2,2,2,2,1},
	{1,2,2,2,2,1},
	{1,1,1,2,2,1}
}

--Tileset Class
Tileset = class {map = {}, img, width, height, tileWidth = 64, tileHeight = 64}
-- TODO
-- load_tileset will create a tileset from a file that is passed
-- draw_tiles will be passed a tileset and will draw it
-- Make a Tile class for Tile objects
--     -- Tile Objects will have all information for a given tile that needs to be realized. Render position, size, collision enable, etc.

function load_tileset()
	test_set = love.graphics.newImage('images/tilesets/testset.png')
	local tilesetW, tilesetH = test_set:getWidth(), test_set:getHeight()
	TileW, TileH = 64, 64

	--Here we create a tileset object
	test_tileset = Tileset(Map, test_set, tilesetW, tilesetH, TileW, TileH)


	-- Specify tiles of tileset TODO maybe do this in an indefinite loop? To allow for unspecified tileset dimensions?
	Quads = {
		love.graphics.newQuad(0, 0, TileW, TileH, tilesetW, tilesetH),
		love.graphics.newQuad(64, 0, TileW, TileH, tilesetW, tilesetH),
		love.graphics.newQuad(0, 64, TileW, TileH, tilesetW, tilesetH),
		love.graphics.newQuad(64, 64, TileW, TileH, tilesetW, tilesetH)
	}

end



function draw_tiles()

	-- This code will center the map on screen
	local y_count = 0
	local finalx = 0

	for ff = 1, #Map do
		y_count = y_count + 1
		local row = Map[ff]
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


	-- Render Map from tileset onscreen
	for rowIndex = 1, #Map do
		local row = Map[rowIndex]
		for columnIndex = 1, #row do
			local number = row[columnIndex]
			local x, y = start_x + ((columnIndex - 1) * TileW), start_y + ((rowIndex - 1) * TileH)
			HC.rectangle(x, y, TileW, TileH)
			love.graphics.draw(test_set, Quads[number], x, y) -- Draw Tile
		end
	end


end
