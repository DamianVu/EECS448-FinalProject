
NewCollisionHandler = class("NewCollisionHandler", {})

--- Default constructor
function NewCollisionHandler:init()
	self.objects = {}
	self.terrain = {}
	self.projectiles = {}
end

-------------------------------------------
-- 		Section: Adding Attributes		 --
-------------------------------------------

--- Add player/enemy objects to the handler
function NewCollisionHandler:addObject(object)
	self.objects[#self.objects + 1] = object
end

--- Add projectiles and other objects to the handler


--- Add terrain objects to the handler
function NewCollisionHandler:addTerrain(object)
	self.terrain[#self.terrain + 1] = object
end

function NewCollisionHandler:addProjectile(object)
	self.projectiles[#self.projectiles + 1] = object
end

-------------------------------------------
-- 		Section: Removing Attributes	 --
-------------------------------------------

--- Remove objects from handler
function NewCollisionHandler:removeObject(id)

end

function NewCollisionHandler:reset()
	self.objects = {}
	self.terrain = {}
	self.projectiles = {}
end

-------------------------------------------
-- 		Section: Update Functions		 --
-------------------------------------------

--- Callback to check for collisions
function NewCollisionHandler:update()
	-- Check for object to object collisions
	collision = 0

	-- Check for object to terrain collisions
	for i = #self.objects, 1, -1 do
		for j = 1, #self.terrain do
			self:checkTerrainCollision(self.objects[i], self.terrain[j])
		end
	end

	-- Check for projectile to terrain collisions
	for i = #self.projectiles, 1, -1 do
		for j = 1, #self.terrain do
			self:checkTerrainCollision(self.projectiles[i], self.terrain[j])
		end
	end

	-- Check for projectile to object collisions
	for i = #self.projectiles, 1, -1 do
		for j = #self.objects, 1, -1 do
			self:checkProjectileCollision(self.projectiles[i], self.objects[j])
		end
	end

	-- Check for object to object collisions
	for i = #self.objects, 1, -1 do
		for j = #self.objects - 1, 1, -1 do
			self:checkObjectCollision(self.objects[j], self.objects[i])
		end
	end
end





-------------------------------------------
-- 		Section: Check Functions		 --
-------------------------------------------
--- Checks for a collision between an object and terrain
function NewCollisionHandler:checkTerrainCollision(object, terrain)

	if not object then return end
	-- Note: Object.x/y is the center of sprite, while terrain is the top left point

	-- There is probably a more optimized way of doing this. For now let's check all 4 cases

	if 	(object.y - (object.height / 2) < terrain.y + terrain.height) and
		(object.y + (object.height / 2) > terrain.y) and
		(object.x - (object.width / 2) < terrain.x + terrain.width) and
		(object.x + (object.width / 2) > terrain.x) then
		self:resolveTerrainCollision(object, terrain)
		collision = collision + 1
	end
end

--- Checks for a collisions between a projectile and an object
function NewCollisionHandler:checkProjectileCollision(projectile, object)
	if not projectile then return end

	if projectile.sourceID == object.id then return end

	if 	(object.y - (object.height / 2) < projectile.y + projectile.height/2) and
		(object.y + (object.height / 2) > projectile.y - projectile.height/2) and
		(object.x - (object.width / 2) < projectile.x + projectile.width/2) and
		(object.x + (object.width / 2) > projectile.x - projectile.width/2) then
		self:resolveProjectileCollision(projectile, object)
		collision = collision + 1
	end
end

function NewCollisionHandler:checkObjectCollision(object1, object2)
	if not object1 or not object2 then return end
	if object1.type == PLAYER and object2.type == PLAYER then return end

	o1ScaleX = object1.scaleX or 1
	o1ScaleY = object1.scaleY or 1
	o2ScaleX = object2.scaleX or 1
	o2ScaleY = object2.scaleY or 1

	if 	object1.y - object1.height/2 < object2.y + object2.height/2 and
		object1.y + object1.height/2 > object2.y - object2.height/2 and
		object1.x - object1.width/2 < object2.x + object2.width/2 and
		object1.x + object1.width/2 > object2.x - object2.width/2 then
		self:resolveObjectCollision(object1, object2)
		collision = collision + 1
	end
end


-------------------------------------------
-- 	   Section: Resolution Functions	 --
-------------------------------------------

--- Resolves a collision between a projectile and terrain
function NewCollisionHandler:resolveTerrainCollision(object, terrain)
	if object.type == PROJECTILE then
		destroyProjectile(object.id)
	else
		self:resolveObjectTerrainCollision(object, terrain)
	end
end

--- Resolves a collision between an object and terrain
function NewCollisionHandler:resolveObjectTerrainCollision(object, terrain)
	local terrainCenterX = terrain.x + (terrain.width/2)
	local terrainCenterY = terrain.y + (terrain.height/2)

	local diffX = object.x - terrainCenterX
	local diffY = object.y - terrainCenterY

	-- In the case of a box, whichever difference is greater is the direction we push out.
	-- For example check this out...
	--[=====[
	if math.abs(diffX) > math.abs(diffY) then
		if diffX < 0 then
			object.x = terrain.x - object.width/2
		else
			object.x = terrain.x + terrain.width + object.width/2
		end
	else
		if diffY < 0 then
			object.y = terrain.y - object.height/2
		else
			object.y = terrain.y + terrain.height + object.height/2
		end
	end
	]=====]--


	-- That worked for single boxes... What if we have a rectangle...
	--[=====[]]
	if object.y > terrain.y + terrain.height then
		object.y = terrain.y + terrain.height + object.height/2
	elseif object.y < terrain.y then
		object.y = terrain.y - object.height/2
	elseif object.x < terrain.x then
		object.x = terrain.x - object.width/2
	elseif object.x > terrain.x + terrain.width and
		object.x = terrain.x + terrain.width + object.width/2
	elseif
	]=====]--

	if object.y > terrain.y + terrain.height and (object.x >= terrain.x and object.x < terrain.x + terrain.width) then
		object.y = terrain.y + terrain.height + object.height/2
	elseif object.y < terrain.y and (object.x >= terrain.x and object.x < terrain.x + terrain.width) then
		object.y = terrain.y - object.height/2
	elseif object.x < terrain.x and (object.y >= terrain.y and object.y < terrain.y + terrain.height) then
		object.x = terrain.x - object.width/2
	elseif object.x > terrain.x + terrain.width and (object.y >= terrain.y and object.y < terrain.y + terrain.height) then
		object.x = terrain.x + terrain.width + object.width/2

		-- That took care of the base cases, time to get the edge cases
	elseif object.y > terrain.y + terrain.height and object.x < terrain.x then
		-- Down to the left
		local dx = object.x - terrain.x
		local dy = object.y - (terrain.y + terrain.height)

		if math.abs(dx) > math.abs(dy) then
			object.x = terrain.x - object.width/2
		else
			object.y = terrain.y + terrain.height + object.height/2
		end
	elseif object.y > terrain.y + terrain.height and object.x >= terrain.x + terrain.width then
		-- Down to the right
		local dx = object.x - (terrain.x + terrain.width)
		local dy = object.y - (terrain.y + terrain.height)

		if math.abs(dx) > math.abs(dy) then
			object.x = terrain.x + terrain.width + object.width/2
		else
			object.y = terrain.y + terrain.height + object.height/2
		end
	elseif object.y < terrain.y and object.x < terrain.x then
		-- Up to the left
		local dx = object.x - terrain.x
		local dy = object.y - terrain.y

		if math.abs(dx) > math.abs(dy) then
			object.x = terrain.x - object.width/2
		else
			object.y = terrain.y - object.height/2
		end
	elseif object.y < terrain.y and object.x >= terrain.x + terrain.width then
		-- Up to the right
		local dx = object.x - (terrain.x + terrain.width)
		local dy = object.y - terrain.y

		if math.abs(dx) > math.abs(dy) then
			object.x = terrain.x + terrain.width + object.width/2
		else
			object.y = terrain.y - object.height/2
		end



		-- ONE LAST EDGE CASE: If player x,y is inside the terrain
	elseif object.x > terrain.x and object.x < terrain.x + terrain.width and object.y > terrain.y and object.y < terrain.y + terrain.height  then



	end
end

--- Resolves a collision between a projectile and an object
function NewCollisionHandler:resolveProjectileCollision(projectile, object)
	object:takeDamage(projectile.damage)
	destroyProjectile(projectile.id)
end

--- Resolves a collision between an object and another object
function NewCollisionHandler:resolveObjectCollision(object1, object2)
	-- Let's assume there is only one player object, thus we don't have to handle player-player collision

	-- Secondly, let's assume enemies don't collide with another FOR NOW

	if object1.type == ENEMY and object2.type == ENEMY then
		-- If enemy to enemy collision
	else
		-- This should be player to enemy

		local eObj
		local pObj

		if object1.type == ENEMY then
			eObj = object1
			pObj = object2
		else
			eObj = object2
			pObj = object1
		end

		local angle = math.atan2(pObj.y - eObj.y, pObj.x - eObj.x)

		if pObj.immune then return end

		pObj:bump(angle, eObj.bumpFactor)
		pObj:takeDamage(eObj.damage)

		-- Calculate difference in position between player and enemy
		local diffX = eObj.x - pObj.x
		local diffY = eObj.y - pObj.y

		local offsetVal = 1 -- Testing different values

		if math.abs(diffX) > math.abs(diffY) then
			if diffX > 0 then
				eObj.x = pObj.x + (pObj.width/2) + (eObj.width/2) + offsetVal
			else
				eObj.x = pObj.x - (pObj.width/2) - (eObj.width/2) - offsetVal
			end
		else
			if diffY > 0 then
				eObj.y = pObj.y + (pObj.height/2) + (eObj.height/2) + offsetVal
			else
				eObj.y = pObj.y - (pObj.height/2) - (eObj.height/2) - offsetVal
			end
		end

		eObj:pause()
	end
end