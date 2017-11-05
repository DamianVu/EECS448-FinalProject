
require 'libraries.ext.30log'
require 'resources.rawmaps'

MapHandler = class("MapHandler", {})


function MapHandler:init()
	-- Eventually load maps from xml files.
	-- For project 3 we will load everything manually in the beginning portion of loadMap()
end

-- Eventually this parameter will tell the game which map to load
-- startPoint: If maps have multiple load points, we can select them
function MapHandler:loadMap(map, startIndex)
	-- Revamp for project 4
	local maps = {
		RawMaps.map1,
		RawMaps.map2
	}

	local rawTS = maps[map]
	-- Revamp for project 4 ^^

	if startIndex == nil then startIndex = 1 end

	local starty, startx = unpack(rawTS.startingLocations[startIndex])

	-- Generate TileSet class
	local map = Map(rawTS.grid, rawTS.id_dict)
	local img = love.graphics.newImage('images/tilesets/' .. rawTS.img)

	local TS = Tileset(map, img, img:getWidth(), img:getHeight(), 64, 64)
	currentMap = TS

	local tw = currentMap.tileWidth
	local th = currentMap.tileHeight
	local imgw, imgh = currentMap.img:getDimensions()

	Quads = {
		love.graphics.newQuad(0, 0, tw, th, imgw, imgh),
		love.graphics.newQuad(64, 0, tw, th, imgw, imgh),
		love.graphics.newQuad(0, 64, tw, th, imgw, imgh),
		love.graphics.newQuad(64, 64, tw, th, imgw, imgh)
	}

	player.x = ((startx - 1) * tw) + (tw/2)
	player.y = ((starty - 1) * tw) + (th/2)
end

-- Each map needs it's own tileset, definitions for those tiles, color for debug mode, and layout

