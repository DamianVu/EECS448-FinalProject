---
require 'libraries.ext.30log'

MapHandler = class("MapHandler", {})

--- Called on initialization
function MapHandler:init()
	-- Eventually load maps from xml files.
	-- For project 3 we will load everything manually in the beginning portion of loadMap()
	self.maps = {}
	self.tilesets = {}
end

function MapHandler:loadAllMaps()
	local files = love.filesystem.getDirectoryItems("resources/maps/")
	for i = 1, #files do
		local filename = files[i]:match("(.+).lua")
		if filename ~= nil then
			self.maps[#self.maps + 1] = require ("resources.maps." .. filename)
		end
	end
end

function MapHandler:loadAllTilesets()
	local files = love.filesystem.getDirectoryItems("resources/tilesets/")
	for i = 1, #files do
		local filename,_ = files[i]:match("(%a+).(.*)")
		ts = require ("resources.tilesets." .. filename)

		-- We are limiting tilesize to 64 always for this project
		ts.Quads = {}
		local imgw, imgh = ts.image:getDimensions()
		local currentNum = 1
		local breaking = false
		for j = 1, ts.Height do
			for k = 1, ts.Width do
				if currentNum > ts.size then
					breaking = true
					break
				else
					currentNum = currentNum + 1
				end
				-- Quads will go left to right, top to bottom
				ts.Quads[#ts.Quads + 1] = love.graphics.newQuad((k-1) * 64, (j-1) * 64, 64, 64, imgw, imgh)
			end
			if breaking then break end
		end

		self.tilesets[#self.tilesets + 1] = ts
	end
end

--- Resets player on death
function MapHandler:resetPlayer()
	GH.player.x = ((self.startx - 1) * 64) + 32
	GH.player.y = ((self.starty - 1) * 64) + 32
	GH.player.health = GH.player.maxHP
	GH.player.movementEnabled = true
end

--- Loads map
function MapHandler:loadMap(map, startIndex)

	self.currentMap = self.maps[self:getMapIndex(map)]

	if startIndex == nil then startIndex = 1 end

	local starty, startx = unpack(self.currentMap.startingLocations[startIndex])

	self.starty = starty
	self.startx = startx


	GH.player.x = ((startx - 1) * 64) + 32
	GH.player.y = ((starty - 1) * 64) + 32

	-- Load terrain

	self.currentMapTiles = {}

	for i = 1, #self.currentMap.objects do
		local obj = self.currentMap.objects[i]
		local currentTileset = self:getTilesetIndex(self.currentMap.tilesets[obj[1]])

		self.currentMapTiles[i] = {
			self.tilesets[currentTileset].image,
			self.tilesets[currentTileset].Quads[obj[2]],
		}
	end

	for i = 1, #self.currentMap.terrain do
		local x, y, w, h = unpack(self.currentMap.terrain[i])
		x = (x-1) * 64
		y = (y-1) * 64
		w = w * 64
		h = h * 64
		GH:addObject(Terrain(x, y, w, h))
	end
end

function MapHandler:getMapIndex(mapname)
	for i = 1, #self.maps do
		if self.maps[i].name == mapname then return i end
	end
	return -1
end

function MapHandler:getTilesetIndex(tilesetname)
	for i = 1, #self.tilesets do
		if self.tilesets[i].name == tilesetname then return i end
	end
	return -1
end

--- Each map needs it's own tileset, definitions for those tiles, color for debug mode, and layout.
function MapHandler:drawMap()

	-- Sets color to white with full opacity.
	-- This lets the image be drawn with its original colors
	love.graphics.setColor(255,255,255,255)


	for rowIndex = 1, #self.currentMap.grid do
		local row = self.currentMap.grid[rowIndex]
		for columnIndex = 1, #row do
			local tilenum = row[columnIndex]
			if tilenum ~= -1 then
				local img, quad = unpack(self.currentMapTiles[tilenum])
				local x, y = ((columnIndex - 1) * 64), ((rowIndex - 1) * 64)
				--HC.rectangle(x, y, self.currentMap.tileWidth, self.currentMap.tileHeight)
				love.graphics.draw(img, quad, x, y) -- Draw Tile
			end
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
