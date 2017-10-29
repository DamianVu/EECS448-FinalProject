
Map = {
	{1,1,1,1,1,1},
	{1,2,2,2,2,1},
	{1,2,3,3,2,1},
	{1,2,2,2,2,1},
	{1,1,1,2,2,1}
}

function load_tilesets()
	test_set = love.graphics.newImage('images/tilesets/testset.png')

	TileW, TileH = 64, 64
	local tilesetW, tilesetH = test_set:getWidth(), test_set:getHeight()

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


	-- Draws map on screen --
	for rowIndex = 1, #Map do
		local row = Map[rowIndex]
		for columnIndex = 1, #row do
			local number = row[columnIndex]
			love.graphics.draw(test_set, Quads[number], start_x + ((columnIndex - 1) * TileW), start_y + ((rowIndex - 1) * TileH))
		end
	end

end