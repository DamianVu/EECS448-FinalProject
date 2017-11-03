
require 'libraries.ext.30log'

MapHandler = class("MapHandler", {})



function MapHandler:init()
	-- Eventually load maps from xml files???

end

-- Eventually this parameter will tell the game which map to load
function MapHandler:loadMap(map)
	local rawTS = exampleSet1

	-- Generate TileSet class
	local map = Map(rawTS.grid, rawTS.id_dict)
	local img = love.graphics.newImage('images/tilesets/' .. rawTS.img)

	local TS = Tileset(map, img, img:getWidth(), img:getHeight(), 64, 64)
	currentMap = TS
end

-- Each map needs it's own tileset, definitions for those tiles, color for debug mode, and layout

-- This will be an exact copy of the test one in tiling.lua
exampleSet1 = {
	img = "testset.png",
	id_dict = {
		[1] = {collision = true, bumpFactor = 0},
		[2] = {collision = false},
		[3] = {collision = true, bumpFactor = 0},
		[4] = {collision = true, bumpFactor = 5}
	},
	color_dict = {
		[1] = {255, 0, 0},
		[2] = {0, 255, 0},
		[3] = {255, 255, 0},
		[4] = {255, 0, 0}
	},
	grid = {
		{1,1,1,1,1,1,1,1},
		{1,2,2,2,2,2,2,1},
		{1,2,3,3,2,2,2,1},
		{1,2,2,2,2,2,2,1,1,1,1},
		{1,1,1,2,2,2,2,2,2,2,1},
		{1,2,2,2,2,1,1,1,1,2,1},
		{1,2,3,3,3,3,3,3,3,2,2,2,2,2,1},
		{1,2,2,2,2,2,2,2,2,2,1},
		{1,2,2,4,4,4,4,2,2,2,1},
		{1,2,3,3,3,3,3,3,3,2,1},
		{1,1,1,1,1,1,1,1,1,1,1}
	}
}
