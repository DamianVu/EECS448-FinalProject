
class = require 'libraries.ext.30log'					--| Object orientation framework

---------------------------------------------------------
---------				Properties				---------
---------------------------------------------------------

test_id_dict = {}								
test_id_dict[1] = {collision = true, bumpFactor = 0}		
test_id_dict[2] = {collision = false}
test_id_dict[3] = {collision = true, bumpFactor = 0}
test_id_dict[4] = {collision = true, bumpFactor = 5} 

color_dict = {}
color_dict[1] = {255, 0, 0}
color_dict[2] = {0, 255, 0}
color_dict[3] = {255, 255, 0}
color_dict[4] = {255, 0, 0}






---------------------------------------------------------
---------				Classes					---------
---------------------------------------------------------


-- TODO Tile Objects will have all information for a given tile that needs to be realized. Render position, size, collision enable, etc.
--Tile-- Class definition and constructor, new_tile
Tile = class("Tile", {}) -- Will likely need to add parameters
function Tile:init(id, x, y, width, height, collision, bumpFactor)
	self.id = id							 	--|int - integer representation of Tile
	self.x = x								 	--|int - x coordinate of upper-left corner
	self.y = y									--|int - y coordinate of upper-left corner
	self.width = width				 			--|int - Tile width
	self.height = height			 			--|int - Tile height
	self.collision = collision 					--|bool - collision enabled
	self.bumpFactor = bumpFactor or 0			--|num - bumping factor (not too functional yet)
end

--Map-- Class definition and constructor, new_map
Map = class("Map", {})
function Map:init(grid, id_dict)
	self.tiles = {}
	self.id_dict = id_dict

	for rowIndex = 1, #grid do --Fill map with tiles, where id is the number in the grid
		local row = grid[rowIndex]
		self.tiles[rowIndex] = {}
		for columnIndex = 1, #row do
			local id = row[columnIndex]
			local nthTile = Tile(id, x, y, width, height, self.id_dict[id].collision, self.id_dict[id].bumpFactor)
			self.tiles[rowIndex][columnIndex] = nthTile
		end
	end
end
-- End --

--Tileset-- Class definition and constructor, new_tileset
Tileset = class("Tileset", {map = {}})
function Tileset:init(map, img, width, height, tileWidth, tileHeight, startx, starty)
	self.map = map                        				-- map  		|2d array of Tile objects
	self.img = img										-- img  		|love.graphics.newImage('image/path.png')
	self.width = width									-- width  		|width of tileset = img.getWidth()
	self.height = height								-- height  		|height of tileset = img.getHeight()
	self.tileWidth = tileWidth or 64					-- tileWidth  	|Width of tile in set
	self.tileHeight = tileHeight or 64					-- tileHeight 	|Height of tile in set
	self.startx = startx or 0							-- startx 		|starting x position of the tile 	
	self.starty = starty or 0							-- startx		|starting y position of the tile
end
-- End --


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

-- This returns a new, larger CoordinateList containing every tile in the previous AND every adjacent tile attached
-- I don't see why this function would ever be ran if self.unique = false, but we can cross that bridge when the time comes
function CoordinateList:fullSpan()
	local rList = CoordinateList()
	for i = 1, #self.list do
		local x,y = unpack(self.list[i])
		for j = x-1, x+1 do
			for k = y-1, y+1 do
				rList:add({j,k})
			end
		end
	end
	return rList
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




---------------------------------------------------------
---------				Functions				---------
---------------------------------------------------------

-- Load the tileset to be worked on for our game. TODO works with csv format if we added a loadmapfile(file), for example
function load_tileset()
	test_grid = {
		{1,1,1,1,1,1,1,1},
		{1,2,2,2,2,2,2,1},
		{1,2,3,3,2,2,2,1},
		{1,2,2,2,2,2,2,1,1,1,1},
		{1,1,1,2,2,2,2,2,2,2,1},
		{1,2,2,2,2,1,1,1,1,2,1},
		{1,2,2,2,2,2,2,2,2,2,1},
		{1,2,2,2,2,2,2,2,2,2,1},
		{1,2,2,4,4,4,4,2,2,2,1},
		{1,2,2,2,2,2,2,2,2,2,1},
		{1,1,1,1,1,1,1,1,1,1,1}
	}

	test_map = Map(test_grid, test_id_dict)

	test_set = love.graphics.newImage('images/tilesets/testset.png')


	-- Create the object for the tileset to be worked with in the rendering stage
	currentMap = Tileset(test_map, test_set, test_set:getWidth(), test_set:getHeight(), 64, 64)

	-- Specify tiles of tileset
	-- TODO do this in an indefinite loop? To allow for unspecified tileset dimensions?
	-- TODO Integrate Quads as a property of the tileset
	Quads = {
		love.graphics.newQuad(0, 0, currentMap.tileWidth, currentMap.tileHeight, currentMap.img:getDimensions()),
		love.graphics.newQuad(64, 0, currentMap.tileWidth, currentMap.tileHeight, currentMap.img:getDimensions()),
		love.graphics.newQuad(0, 64, currentMap.tileWidth, currentMap.tileHeight, currentMap.img:getDimensions()),
		love.graphics.newQuad(64, 64, currentMap.tileWidth, currentMap.tileHeight, currentMap.img:getDimensions())
	}
end

function getTileAnchorPoint(tilex, tiley)
	-- Return the pixel location in the center of the tile.
	return ((tilex - 1) * currentMap.tileWidth) + currentMap.tileWidth/2, ((tiley - 1) * currentMap.tileHeight) + currentMap.tileHeight / 2
end

function validTile(tilex, tiley)
	return not (tilex < 1 or tiley < 1 or tiley > #currentMap.map.tiles or tilex > #currentMap.map.tiles[tiley])
end

-- This tilex and tiley corresponds to the location in currentMap.map.tiles
function highlight(tilex, tiley)
	if not validTile(tilex, tiley) then
		return
	end
	-- Good to go. Let's highlight it based on tile id
	-- Find coordinate
	local width = currentMap.tileWidth
	local height = currentMap.tileHeight

    local r,g,b,a = love.graphics.getColor() -- Get old color
	love.graphics.setColor(unpack(color_dict[currentMap.map.tiles[tiley][tilex].id]))
	love.graphics.rectangle("line", (currentMap.startx + ((tilex - 1) * width)) + (tilex ~= 1 and 0 or 1), (currentMap.starty + ((tiley - 1) * height)) + (tiley ~= 1 and 0 or 1), width - 1, height - 1)
	love.graphics.setColor(r,g,b,a) -- Reset to old color
end

-- This function will take in an objects x, y coords and its width/height. This will allow us to highlight tiles around it.
function highlightTiles(cObj)
	local spanList = cObj:getSpan():fullSpan()

	for i = 1, #spanList.list do
		local x,y = unpack(spanList.list[i])
		highlight(x,y)
	end
end

function get_cObjectPositionInfo(cObj)
	-- This should return current tiles and adjacent tiles
	-- We know cObj has an x,y, width, height, and offset values

	cList = cObj:getSpan()

	aList = CoordinateList.subset(cList:fullSpan(), cList)

	return cList, aList
end

function draw_tiles()
	local start_x = currentMap.startx
	local start_y = currentMap.starty
	-- End of centering map on screen


	-- MAP RENDER FUNCTION: Render currentMap.map.tiles from tileset onscreen
	love.graphics.setColor(255,255,255,255)
	for rowIndex = 1, #currentMap.map.tiles do
		local row = currentMap.map.tiles[rowIndex]
		for columnIndex = 1, #row do
			local number = row[columnIndex].id
			local x, y = start_x + ((columnIndex - 1) * currentMap.tileWidth), start_y + ((rowIndex - 1) * currentMap.tileHeight)
			--HC.rectangle(x, y, currentMap.tileWidth, currentMap.tileHeight)
			love.graphics.draw(currentMap.img, Quads[number], x, y) -- Draw Tile
		end
	end
end
