
Map = {
	{1,1,1,1,1,1,1,1},
	{1,2,2,2,2,2,2,1},
	{1,2,3,3,2,2,2,1},
	{1,2,2,2,2,2,2,1},
	{1,1,1,2,2,2,2,1},
	{1,2,2,2,2,1,1,1},
	{1,2,2,2,2,2,2,1},
	{1,1,1,1,1,1,1,1}
}

function load_tilesets()
	test_set = love.graphics.newImage('images/tilesets/testset.png')

	TileW, TileH = 64, 64
	local tilesetW, tilesetH = test_set:getWidth(), test_set:getHeight()

	Quads = {
		love.graphics.newQuad(0, 0, TileW, TileH, tilesetW, tilesetH), -- Obstacle
		love.graphics.newQuad(64, 0, TileW, TileH, tilesetW, tilesetH), -- Path
		love.graphics.newQuad(0, 64, TileW, TileH, tilesetW, tilesetH), -- Water
		love.graphics.newQuad(64, 64, TileW, TileH, tilesetW, tilesetH)
	}

	--getTileCount()

end

--[=====[
function getTileCount()
	rowCount = 0
	colCount = 0
	for rowInd = 1, #Map do
		local row = Map[rowInd]
		for colInd = 1, #row do

end
]=====]--






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
	]=====]--

	local start_x = -(64 * (finalx or 0) / 2)
	local start_y = -(64 * (y_count or 0) / 2)
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