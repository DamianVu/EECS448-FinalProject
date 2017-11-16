
require 'libraries.ext.30log'

LevelHandler = class("LevelHandler", {})

function LevelHandler:init()
	MH = MapHandler()
  self.currentMapIndex = -1
end

function LevelHandler:startGame()
	self:loadLevel(1,1)
end

function LevelHandler:loadLevel(level, startPos)
  self.currentMapIndex = level
	if not startPos then
		startPos = 1
	end
	MH:loadMap(level, startPos)
end



function LevelHandler:update(dt)
  -- Check for ending location
  local endings = RawMaps[self.currentMapIndex].endingLocations
	local transitions = RawMaps[self.currentMapIndex].transitions
  for i = 1, #endings do
    local spanList = player:getSpan()
    if spanList:contains(endings[i]) then
			LH:loadLevel(unpack(transitions[i]))
    end
  end
end
