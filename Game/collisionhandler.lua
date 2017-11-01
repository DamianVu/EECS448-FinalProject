-- This module will hopefully be able to handle collisions

class = require '30log'

CollisionHandler = class("CollisionHandler", {collisionEntities = {}})

function CollisionHandler:init()

end

function CollisionHandler:addObj(cObj) 
	self.collisionEntities[#self.collisionEntities+1] = cObj
end

function CollisionHandler:reset()
	-- Take some time to do stuff then finally reset the table altogether


	self.collisionEntities = {} 
end

function CollisionHandler:getNumberOfPossibleCollisions(id) -- Object id
	-- This needs nearby other entities (use some pixel amount to quantify nearby)
	local collisionCount = 0
	local adjCount = 0
	-- Also, this needs nearby collidable tiles
	local currentTiles, adjacentTiles = get_cObjectPositionInfo(self.collisionEntities[id])
	for i = 1, #adjacentTiles.list do
		local x,y = unpack(adjacentTiles.list[i])
		if ts.map.tiles[y][x].collision then
			adjCount = adjCount + 1
		end
	end
	for i = 1, #currentTiles.list do
		local x,y = unpack(currentTiles.list[i])
		if ts.map.tiles[y][x].collision then
			collisionCount = collisionCount + 1
		end
	end


	return collisionCount, adjCount
end

function CollisionHandler:checkCollisions()
	
end