---
require 'libraries.ext.30log'

MapHandler = class("MapHandler", {})

--- Called on initialization
function MapHandler:init()
	-- Eventually load maps from xml files.
	-- For project 3 we will load everything manually in the beginning portion of loadMap()
end

--- Loads map
function MapHandler:loadMap(map, startIndex)
	-- Revamp for project 4


	local rawTS = RawMaps[map]
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
