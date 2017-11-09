
require 'libraries.ext.30log'

LevelHandler = class("LevelHandler", {})

function LevelHandler:init()
	MH = MapHandler()
end

function LevelHandler:startGame()
	self:loadLevel(2,2)
end

function LevelHandler:loadLevel(level, startPos)
	if not startPos then
		startPos = 1
	end
	MH:loadMap(level, startPos)
end