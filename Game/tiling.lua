
Map = {
	{1,1,1,1,1},
	{1,2,2,2,1},
	{1,2,1,2,1},
	{1,2,2,2,1},
	{1,1,1,1,1}
}

function load_tilesets()
	test_set = love.graphics.newImage('images/tilesets/testset.png')

	TileW, TileH = 64, 64
	local tilesetW, tilesetH = test_set:getWidth(), test_set:getHeight()

	StartX = 574
	StartY = 290

	Quads = {
		love.graphics.newQuad(0, 0, TileW, TileH, tilesetW, tilesetH),
		love.graphics.newQuad(64, 0, TileW, TileH, tilesetW, tilesetH),
		love.graphics.newQuad(0, 64, TileW, TileH, tilesetW, tilesetH),
		love.graphics.newQuad(64, 64, TileW, TileH, tilesetW, tilesetH)
	}

end



function draw_tiles()

	for rowIndex = 1, #Map do
		local row = Map[rowIndex]
		for columnIndex = 1, #row do
			local number = row[columnIndex]
			love.graphics.draw(test_set, Quads[number], StartX + ((columnIndex - 1) * TileW), StartY + ((rowIndex - 1) * TileH))
		end
	end

end