
require 'libraries.ext.30log'
require 'resources.rawmaps' -- Revamp for project 4

MapHandler = class("MapHandler", {})

function MapHandler:init()
	-- Eventually load maps from xml files.
	-- For project 3 we will load everything manually in the beginning portion of loadMap()
end

-- Eventually this parameter will tell the game which map to load
--- startPoint: If maps have multiple load points, we can select them.
function MapHandler:loadMap(map, startIndex)
	-- Revamp for project 4
	local maps = {
		RawMaps.map1,
		RawMaps.map2,
		RawMaps.map3
	}

	local rawTS = maps[map]
	-- Revamp for project 4 ^^

	if startIndex == nil then startIndex = 1 end

	local starty, startx = unpack(rawTS.startingLocations[startIndex])

	-- Generate TileSet class
	local map = Map(rawTS.grid, rawTS.id_dict)
	local img = love.graphics.newImage('images/tilesets/' .. rawTS.img)

	self.currentMap = Tileset(map, img, img:getWidth(), img:getHeight(), 64, 64, rawTS.color_dict)

	local tw = self.currentMap.tileWidth
	local th = self.currentMap.tileHeight
	local imgw, imgh = self.currentMap.img:getDimensions()

	Quads = {
		love.graphics.newQuad(0, 0, tw, th, imgw, imgh),
		love.graphics.newQuad(64, 0, tw, th, imgw, imgh),
		love.graphics.newQuad(0, 64, tw, th, imgw, imgh),
		love.graphics.newQuad(64, 64, tw, th, imgw, imgh)
	}

	player.x = ((startx - 1) * tw) + (tw/2)
	player.y = ((starty - 1) * tw) + (th/2)
end

--- Each map needs it's own tileset, definitions for those tiles, color for debug mode, and layout.


function MapHandler:drawMap()
	local start_x, start_y = unpack(self.currentMap.origin)

	-- Sets color to white with full opacity.
	-- This lets the image be drawn with its original colors
	love.graphics.setColor(255,255,255,255)


	for rowIndex = 1, #self.currentMap.map.tiles do
		local row = self.currentMap.map.tiles[rowIndex]
		for columnIndex = 1, #row do
			local number = row[columnIndex].id
			local x, y = start_x + ((columnIndex - 1) * self.currentMap.tileWidth), start_y + ((rowIndex - 1) * self.currentMap.tileHeight)
			--HC.rectangle(x, y, self.currentMap.tileWidth, self.currentMap.tileHeight)
			love.graphics.draw(self.currentMap.img, Quads[number], x, y) -- Draw Tile
		end
	end
end

--- Finally an opportunity to use getters (discovery of private variables).
function MapHandler:getCurrentMapDimensions()
	return self.currentMap.origin, self.currentMap.tileWidth, self.currentMap.tileHeight
end

function MapHandler:getTileInfo(tilex, tiley)
	local currentTile = self.currentMap.map.tiles[tiley][tilex]
	if self:isValidTile(tilex, tiley) then
		return currentTile.collision, currentTile.bumpFactor
	else
		return false
	end
end

function MapHandler:isValidTile(tilex, tiley)
	return not (tilex < 1 or tiley < 1 or tiley > #self.currentMap.map.tiles or tilex > #self.currentMap.map.tiles[tiley])
end




--- TEMPORARY UNTIL I ADD COLOR DICT AND ID DICT INTO TILESET CLASS.
function MapHandler:getTile(tilex, tiley)
	return self.currentMap.map.tiles[tiley][tilex]
end

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
function Tileset:init(map, img, width, height, tileWidth, tileHeight, cdict, originx, originy)
	self.map = map                        				-- map  		|2d array of Tile objects
	self.img = img										-- img  		|love.graphics.newImage('image/path.png')
	self.width = width									-- width  		|width of tileset = img.getWidth()
	self.height = height								-- height  		|height of tileset = img.getHeight()
	self.tileWidth = tileWidth or 64					-- tileWidth  	|Width of tile in set
	self.tileHeight = tileHeight or 64					-- tileHeight 	|Height of tile in set
	self.color_dict = cdict
	if originx == nil then originx = 0 end
	if originy == nil then originy = 0 end
	self.origin = {originx,originy}						-- startx 		|starting position to draw map. DEFAULT IS 0,0   -   No reason to use anything else atm
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
			if MH:isValidTile(x,y) then
				self.list[#self.list + 1] = coord
			end
		end
	else
		if MH:isValidTile(x,y) then
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
--- I don't see why this function would ever be ran if self.unique = false, but we can cross that bridge when the time comes.
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



-- Stuff i moved in to test progress

-- Class that contains coordinates
CoordinateList = class("CoordinateList", {list = {}})
function CoordinateList:init(unique)
	self.unique = unique or true
end

function CoordinateList:add(coord)
	local x,y = unpack(coord)
	if self.unique then
		if not self:contains(coord) then
			if MH:isValidTile(x,y) then
				self.list[#self.list + 1] = coord
			end
		end
	else
		if MH:isValidTile(x,y) then
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
--- I don't see why this function would ever be ran if self.unique = false, but we can cross that bridge when the time comes.
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



function getTileAnchorPoint(tilex, tiley)
	-- Return the pixel location in the center of the tile.
	local _, tileWidth, tileHeight = MH:getCurrentMapDimensions()
	return ((tilex - 1) * tileWidth) + tileWidth/2, ((tiley - 1) * tileHeight) + tileHeight / 2
end

--- This tilex and tiley corresponds to the location in self.currentMap.map.tiles.
function highlight(tilex, tiley)
	if not MH:isValidTile(tilex, tiley) then
		return
	end
	-- Good to go. Let's highlight it based on tile id
	-- Find coordinate

	local origin, tileWidth, tileHeight = MH:getCurrentMapDimensions()
	local startx, starty = unpack(origin)

    local r,g,b,a = love.graphics.getColor() -- Get old color
	love.graphics.setColor(unpack(MH.currentMap.color_dict[MH:getTile(tilex,tiley).id]))
	love.graphics.rectangle("line", (startx + ((tilex - 1) * tileWidth)) + (tilex ~= 1 and 0 or 1), (starty + ((tiley - 1) * tileHeight)) + (tiley ~= 1 and 0 or 1), tileWidth - 1, tileHeight - 1)
	love.graphics.setColor(r,g,b,a) -- Reset to old color
end

--- This function will take in an objects x, y coords and its width/height. This will allow us to highlight tiles around it.
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
