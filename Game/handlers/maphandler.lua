
require 'libraries.ext.30log'
require 'resources.rawmaps'

MapHandler = class("MapHandler", {})



function MapHandler:init()
	-- Eventually load maps from xml files???
end

-- Eventually this parameter will tell the game which map to load
function MapHandler:loadMap(map)
	local rawTS = RawMaps.map2

	-- Generate TileSet class
	local map = Map(rawTS.grid, rawTS.id_dict)
	local img = love.graphics.newImage('images/tilesets/' .. rawTS.img)

	local TS = Tileset(map, img, img:getWidth(), img:getHeight(), 64, 64)
	currentMap = TS
end

-- Each map needs it's own tileset, definitions for those tiles, color for debug mode, and layout

