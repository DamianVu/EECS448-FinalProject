--- Handles loading a level.
require 'libraries.ext.30log'

LevelHandler = class("LevelHandler", {})
-- constructor for level handler.
function LevelHandler:init()
	MH = MapHandler()
  MH:loadAllMaps()
  MH:loadAllTilesets()
  self.currentMapIndex = -1
end

-- Starts game.
function LevelHandler:startGame()
	self:loadLevel(4,1)
end

-- loads level.
function LevelHandler:loadLevel(map, startPos)
  self.currentMap = map
	if not startPos then
		startPos = 1
	end
	MH:loadMap(map, startPos)
end


-- updates level across all users.
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
