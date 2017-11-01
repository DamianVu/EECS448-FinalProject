-- This module will hopefully be able to handle collisions

class = require '30log'

CollisionHandler = class("CollisionHandler", {collisionEntities = {}})

function CollisionHandler:init()

end

function CollisionHandler:addObj(cObj) 
	self.collisionEntities[cObj.id] = cObj
end

function CollisionHandler:reset()
	self.collisionEntities = {}
end

function CollisionHandler:getNumberOfPossibleCollisions(id) -- Object id
	-- This needs nearby other entities (use some pixel amount to quantify nearby)

	-- Also, this needs nearby collidable tiles
	local currentTiles, adjacentTiles = get_cObjectPositionInfo(self.collisionEntities[id])
end