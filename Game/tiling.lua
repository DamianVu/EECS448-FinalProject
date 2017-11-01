
class = require 'libraries.ext.30log'					--| Object orientation framework


-- TODO Tile Objects will have all information for a given tile that needs to be realized. Render position, size, collision enable, etc.
--Tile-- Class definition and constructor, new_tile
Tile = class {id, x, y, width, height, collision} -- Will likely need to add parameters
function new_tile(id, x, y, width, height, collision, bumpFactor)
	local tile = Tile()
	tile.id = id							 --|int - integer representation of Tile
	tile.x = x								 --|int - x coordinate of upper-left corner
	tile.y = y								 --|int - y coordinate of upper-left corner
	tile.width = width				 --|int - Tile width
	tile.height = height			 --|int - Tile height
	tile.collision = collision --|bool - collision enabled
	tile.bumpFactor = bumpFactor or 1
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
			local nthTile = new_tile(id, x, y, width, height, map.id_dict[id].collision, map.id_dict[id].bumpFactor)
			map.tiles[rowIndex][columnIndex] = nthTile
		end
	end
	return map
end
-- End --

--Tileset-- Class definition and constructor, new_tileset
Tileset = class {map = {}, img, width, height, tileWidth, tileHeight, startx, starty}
function new_tileset(map, img, width, height, tileWidth, tileHeight, startx, starty)
	local ts = Tileset()
	ts.map = map                        -- map - 2d array of Tile objects
	ts.img = img												-- img - love.graphics.newImage('image/path.png')
	ts.width = width										-- width - width of tileset = img.getWidth()
	ts.height = height									-- height - height of tileset = img.getHeight()
	ts.tileWidth = tileWidth or 64					-- tileWidth - Width of tile in set
	ts.tileHeight = tileHeight or 64				-- tileHeight - Height of tile in set
	ts.startx = startx or 0
	ts.starty = starty or 0
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
		{1,2,2,2,2,2,2,1,1,1,1},
		{1,1,1,2,2,2,2,2,2,2,1},
		{1,2,2,2,2,1,1,1,1,2,1},
		{1,2,2,2,2,2,2,2,2,2,1},
		{1,1,1,1,1,1,1,1,1,1,1}
	}
	test_id_dict = {}								--Tile IDs in the map
	test_id_dict[1] = {collision = true, bumpFactor = 1}		--Properties of each Tile ID. Only have collision for now
	test_id_dict[2] = {collision = false}
	test_id_dict[3] = {collision = true}
	test_id_dict[4] = {collision = false, bumpFactor = 3} 
	test_map = new_map(test_grid, test_id_dict)

	load_tilesets()
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

function getTileAnchorPoint(tilex, tiley)
	-- Return the pixel location in the center of the tile.
	return ((tilex - 1) * ts.tileWidth) + ts.tileWidth/2, ((tiley - 1) * ts.tileHeight) + ts.tileHeight / 2
end

function validTile(tilex, tiley)
	return not (tilex < 1 or tiley < 1 or tiley > #ts.map.tiles or tilex > #ts.map.tiles[tiley])
end

color_dict = {}
color_dict[1] = {255, 0, 0}
color_dict[2] = {0, 255, 0}
color_dict[3] = {255, 255, 0}


-- This tilex and tiley corresponds to the location in ts.map.tiles
function highlight(tilex, tiley)
	if not validTile(tilex, tiley) then
		return
	end
	-- Good to go. Let's highlight it based on tile id
	-- Find coordinate
	local width = ts.tileWidth
	local height = ts.tileHeight

    local r,g,b,a = love.graphics.getColor() -- Get old color
	love.graphics.setColor(unpack(color_dict[ts.map.tiles[tiley][tilex].id]))
	love.graphics.rectangle("line", (ts.startx + ((tilex - 1) * width)) + (tilex ~= 1 and 0 or 1), (ts.starty + ((tiley - 1) * height)) + (tiley ~= 1 and 0 or 1), width - 1, height - 1)
	love.graphics.setColor(r,g,b,a) -- Reset to old color
end

-- This function will take in an objects x, y coords and its width/height. This will allow us to highlight tiles around it.
function highlightTiles(cObj) -- Assumption: x, y is in the center of the sprite
	-- We know we're in a tile if our width + x/2 or width - x/2 along with height + y/2 and height -y/2 overlaps with a tile.

	-- Initial testing. This will not utilize width/height yet.

	-- Get the tile that our x,y is currently in. We don't even technically need a tilecount for this, we know that the map starts at 0,0

	local ptiles = {}

	ptiles[1] = {math.floor((cObj.x - (cObj.x_offset * cObj.scaleX) + ts.startx) / ts.tileWidth) + 1, math.floor((cObj.y - (cObj.y_offset * cObj.scaleY) + ts.starty) / ts.tileHeight) + 1}
	ptiles[2] = {math.floor((cObj.x + (cObj.x_offset * cObj.scaleX) + ts.startx) / ts.tileWidth) + 1, math.floor((cObj.y - (cObj.y_offset * cObj.scaleY) + ts.starty) / ts.tileHeight) + 1}
	ptiles[3] = {math.floor((cObj.x - (cObj.x_offset * cObj.scaleX) + ts.startx) / ts.tileWidth) + 1, math.floor((cObj.y + (cObj.y_offset * cObj.scaleY) + ts.starty) / ts.tileHeight) + 1}
	--ptiles[4] = {math.floor((x + (width/2) + ts.startx) / ts.tileWidth) + 1, math.floor((y + (height/2) + ts.starty) / ts.tileHeight) + 1}
	-- Don't need the bottom right vertex of the character

	local targetTiles = {}

	local offsetx = 0
	local offsety = 0
	local currentx, currenty = unpack(ptiles[1])


	if (currentx ~= ptiles[2][1] or currenty ~= ptiles[2][2]) then
		offsetx = 1
	end
	if (currentx ~= ptiles[3][1] or currenty ~= ptiles[3][2]) then
		offsety = 1
	end

	for i = currentx - 1, (currentx + offsetx + 1) do
		for j = currenty - 1, (currenty + offsety + 1) do
			highlight(i,j)
		end
	end

end


-- Class that contains coordinates
CoordinateList = class("CoordinateList", {list = {}})
function CoordinateList:init(unique)
	self.unique = unique or true
end

function CoordinateList:add(coord)
	local x,y = unpack(coord)
	if self.unique then
		if not self:contains(coord) then
			if validTile(x,y) then 
				self.list[#self.list + 1] = coord
			end
		end
	else
		if validTile(x,y) then 
			self.list[#self.list + 1] = coord
		end
	end
end

function CoordinateList:contains(coord)
	local ix, iy = unpack(coord)
	for i = 1, #self.list do
		local cx, cy = unpack(self.list[i])
		if cx == ix and cy == iy then
			return true, i
		end
	end
	return false
end

function CoordinateList:size()
	return #self.list
end

function CoordinateList.subset(outerList, innerList)
	local rList = CoordinateList(true)

	for i = 1, #outerList.list do
		local x,y = unpack(outerList.list[i])
		if not innerList:contains({x,y}) then
			rList:add({x,y})
		end
	end

	return rList
end

function get_cObjectPositionInfo(cObj)
	-- This should return current tiles and adjacent tiles
	-- We know cObj has an x,y, width, height, and offset values

	local x1 = math.floor((cObj.x - (cObj.x_offset * cObj.scaleX) + ts.startx) / ts.tileWidth) + 1
	local y1 = math.floor((cObj.y - (cObj.y_offset * cObj.scaleY) + ts.starty) / ts.tileHeight) + 1
	local x2 = math.floor((cObj.x + (cObj.x_offset * cObj.scaleX) + ts.startx) / ts.tileWidth) + 1
	local y2 = math.floor((cObj.y - (cObj.y_offset * cObj.scaleY) + ts.starty) / ts.tileHeight) + 1
	local x3 = math.floor((cObj.x - (cObj.x_offset * cObj.scaleX) + ts.startx) / ts.tileWidth) + 1
	local y3 = math.floor((cObj.y + (cObj.y_offset * cObj.scaleY) + ts.starty) / ts.tileHeight) + 1
	local x4 = math.floor((cObj.x + (cObj.x_offset * cObj.scaleX) + ts.startx) / ts.tileWidth) + 1
	local y4 = math.floor((cObj.y + (cObj.y_offset * cObj.scaleY) + ts.starty) / ts.tileHeight) + 1

	cList = CoordinateList(true)

	cList:add({x1, y1})
	cList:add({x2, y2})
	cList:add({x3, y3})
	cList:add({x4, y4})

	tList = CoordinateList(true) -- temp list

	for i = 1, #cList.list do
		local x,y = unpack(cList.list[i])
		for j = x-1, x + 1 do
			for k = y-1, y + 1 do
				tList:add({j,k})
			end 
		end
	end

	aList = CoordinateList.subset(tList, cList)

	return cList, aList
end


function draw_tiles()

	local start_x = ts.startx
	local start_y = ts.starty
	-- End of centering map on screen


	-- MAP RENDER FUNCTION: Render ts.map.tiles from tileset onscreen
	for rowIndex = 1, #ts.map.tiles do
		local row = ts.map.tiles[rowIndex]
		for columnIndex = 1, #row do
			local number = row[columnIndex].id
			local x, y = start_x + ((columnIndex - 1) * ts.tileWidth), start_y + ((rowIndex - 1) * ts.tileHeight)
			--HC.rectangle(x, y, ts.tileWidth, ts.tileHeight)
			love.graphics.draw(ts.img, Quads[number], x, y) -- Draw Tile
		end
	end


end
