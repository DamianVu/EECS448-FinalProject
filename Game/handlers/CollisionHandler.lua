-- DEPRECATED

--- This module will hopefully be able to handle collisions.
class = require 'libraries.ext.30log'

CollisionHandler = class("CollisionHandler", {collisionEntities = {}})

---this function creates the collision handler.
function CollisionHandler:init()
	self.playerMovement = true
	self.playerMovementDisableCount = 10
end

---This function adds collision to the object that is to be collided with.
function CollisionHandler:addObj(cObj)
	self.collisionEntities[#self.collisionEntities+1] = cObj
end

---This function resets collision things.
function CollisionHandler:reset()
	-- Take some time to do stuff then finally reset the table altogether


	self.collisionEntities = {}
end

---this function counts the number of possible collisions and returns the count of possible collisions, the list of collisions, the list of adjacent things, and the list of possible adjacent thing.
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
		local collision, _ = MH:getTileInfo(x,y)
		if collision then
			adjCount = adjCount + 1
			adjList:add({x,y})
		end
	end
	for i = 1, #currentTiles.list do
		local x,y = unpack(currentTiles.list[i])
		local collision, _ = MH:getTileInfo(x,y)
		if collision then
			collisionCount = collisionCount + 1
			collisionList:add({x,y})
		end
	end


	return collisionCount, adjCount, collisionList, adjList
end


--- this function is only checking wall collisions for now!!!!!!.
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

--- mId is the object "moving".
-- oId is the object mId is colliding with
function CollisionHandler:handleCollision(mId, oId)
	-- work on this after testing tile collision
end

--- this function checks to see it the player is trying to collide with tiles that can't be collided with.
function CollisionHandler:handleTileCollision(mId, coord)
	local px = self.collisionEntities[mId].x
	local py = self.collisionEntities[mId].y
	local cx,cy = unpack(coord)
	local x,y = getTileAnchorPoint(cx,cy)

	-- underscore is a var we wont use
	local _, bumpFactor = MH:getTileInfo(cx,cy)

	local diffx = px - x
	local diffy = py - y

	-- Let's find out if diffx or diffy dominates first

	local direction = -1 -- 1=up, 2=right, 3=down, 4=left

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

	local change = -1

	if dx - dy > 0 then
		-- X dominates y
		if diffx < 0 then
			direction = 2
		else
			direction = 4
		end
		change = dx
	else
		-- Y dominates x
		if diffy < 0 then
			direction = 3
		else
			direction = 1
		end
		change = dy
	end

	change = change - math.floor(change) -- This will probably need to be revised...

	self:bump(mId, direction, bumpFactor, 1, change)

	-- Up

	-- This should be split up into top,right,down,left collision relative to the moving object
	-- So i can find if it is to the right or left, then use the greater difference to find which 'dominates' the other

end

--- For walls, direction can only be one of 4 values, and collisionType = 1.
-- Change is how far we should reset them
function CollisionHandler:bump(mId, direction, bumpFactor, collisionType, change) -- Direction should be ?radians? or ?degrees?
	if self.playerMovement == true then
		local bumpAmt = .5 * bumpFactor

		if collisionType == 1 then
			-- Wall bounce
			if direction == 1 then
				self.collisionEntities[mId].y_vel = bumpAmt
				self.collisionEntities[mId].y = self.collisionEntities[mId].y + change
			elseif direction == 2 then
				self.collisionEntities[mId].x_vel = -(bumpAmt)
				self.collisionEntities[mId].x = self.collisionEntities[mId].x - change
			elseif direction == 3 then
				self.collisionEntities[mId].y_vel = -(bumpAmt)
				self.collisionEntities[mId].y = self.collisionEntities[mId].y - change
			else
				self.collisionEntities[mId].x_vel = bumpAmt
				self.collisionEntities[mId].x = self.collisionEntities[mId].x + change
			end
		else

		end

		if bumpFactor > 0 then
			self.playerMovement = false
			self.playerMovementDisableCount = math.floor(bumpFactor * 2)
		end
	else
		self.collisionEntities[mId].x_vel = 0
		self.collisionEntities[mId].y_vel = 0
	end
end
--[=====[]]
-- IDEAS: I'm keeping this here so I can type random ideas as they come to me.
-- PUZZLE ROOM: Moving objects (tiles essentially) move players. They basically push players by effecting a very small bump factor which will essentially look like it is pushing the player


]=====]--
