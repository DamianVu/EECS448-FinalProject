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
	local collisionList = CoordinateList()
	local adjList = CoordinateList()
	local collisionCount = 0
	local adjCount = 0
	-- Also, this needs nearby collidable tiles
	local currentTiles, adjacentTiles = get_cObjectPositionInfo(self.collisionEntities[id])
	for i = 1, #adjacentTiles.list do
		local x,y = unpack(adjacentTiles.list[i])
		if ts.map.tiles[y][x].collision then
			adjCount = adjCount + 1
			adjList:add({x,y})
		end
	end
	for i = 1, #currentTiles.list do
		local x,y = unpack(currentTiles.list[i])
		if ts.map.tiles[y][x].collision then
			collisionCount = collisionCount + 1
			collisionList:add({x,y})
		end
	end


	return collisionCount, adjCount, collisionList, adjList
end


-- Only checking wall collisions for now!!!!!!
function CollisionHandler:checkCollisions()
	for i = 1, #self.collisionEntities do
		local colCount, adjCount, colList, adjList = self:getNumberOfPossibleCollisions(i)
		if (colCount > 0) then
			for j = 1, #colList.list do
				self:handleTileCollision(i, colList.list[j])
			end
		end
	end
end

-- mId is the object "moving"
-- oId is the object mId is colliding with
function CollisionHandler:handleCollision(mId, oId)
	-- work on this after testing tile collision
end

function CollisionHandler:handleTileCollision(mId, coord)
	local px = self.collisionEntities[mId].x
	local py = self.collisionEntities[mId].y
	local x,y = getTileAnchorPoint(unpack(coord))

	local diffx = px - x
	local diffy = py - y

	-- Let's find out if diffx or diffy dominates first

	local dx = -1
	local dy = -1
	if diffx < 0 then
		dx = -diffx
	else
		dx = diffx
	end
	if diffy < 0 then
		dy = -diffy
	else
		dy = diffy
	end

	if dx - dy > 0 then
		-- X dominates y

	else
		-- Y dominates x

	end

	-- Up

	-- This should be split up into top,right,down,left collision relative to the moving object
	-- So i can find if it is to the right or left, then use the greater difference to find which 'dominates' the other

end

-- For walls, direction can only be one of 4 values, and collisionType = 1
function CollisionHandler:bump(mId, direction, bumpFactor, collisionType) -- Direction should be ?radians? or ?degrees?

end
--[=====[]]
-- IDEAS: I'm keeping this here so I can type random ideas as they come to me.
-- PUZZLE ROOM: Moving objects (tiles essentially) move players. They basically push players by effecting a very small bump factor which will essentially look like it is pushing the player


]=====]--