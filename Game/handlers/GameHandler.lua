---Handler GameHandler.
GameHandler = class("GameHandler", {})
---GameHandler contructor.
function GameHandler:init()
	self.terrain = {}
	self.projectiles = {}
	self.enemies = {}
	self.peers = {}
	self.IH = ItemHandler()
	self.CH = NewCollisionHandler()
	self.DH = DialogueHandler()
	self.LH = LevelHandler()
	self.uid_counter = 0
	self.multiplayer = false -- This will only get set to true in NetworkHandler
	self.networkMoveTimer = 0

	self.EH = EventHandler(10)

	self.playerIsMoving = false
	self.playerPrevX = 0
	self.playerPrevY = 0

	self.gameTimer = 0
	self.gameStarted = false

	self.spawnTimer = 0

	self.testSpawn = false

	deathSound = love.audio.newSource("sounds/SOILEDIT.mp3", "static")
	deathSound:setVolume(.25)

	self.enemyDeath = love.audio.newSource("sounds/MonsterDeath.mp3", "static")
	self.enemyDeath:setVolume(.25)

	self.bulletSound = love.audio.newSource("sounds/shootpop.mp3", "static")
	self.bulletSound:setVolume(.3)

	self.connectedIDs = {}
end
---GameHandler add object.
function GameHandler:addObject(obj)
	if obj.type == PLAYER then
		self.CH:addObject(obj)
		self.player = obj
	elseif obj.type == PEER then
		self.CH:addObject(obj)
		self.peers[#self.peers + 1] = obj
	elseif obj.type == ENEMY then
		self.CH:addObject(obj)
		self.enemies[#self.enemies + 1] = obj
	elseif obj.type == PROJECTILE then
		self.CH:addProjectile(obj)
		self.projectiles[#self.projectiles + 1] = obj
	elseif obj.type == TERRAIN then
		self.CH:addTerrain(obj)
		self.terrain[#self.terrain + 1] = obj
	end
end

--- Draw functions.
function GameHandler:draw()
	-- Draw Enemies
	for i=#self.enemies, 1, -1 do self.enemies[i]:draw() end

	-- Draw Projectiles
	for i=#self.projectiles, 1, -1 do self.projectiles[i]:draw() end

	--(Multiplayer) Draw Peers----------
	if self.multiplayer then
		for i=#self.peers, 1, -1 do self.peers[i]:draw() end
	end
	------------------------------------

	-- Draw the Player
	self.player:draw()
end
-- End of draw functions



--- Update functions (primary game dt function).
function GameHandler:update(dt)

	if self.gameStarted or not self.multiplayer then
		self.gameTimer = self.gameTimer + dt
		self.EH:update(dt)
	end


	if self.DH.playing then
		self.DH:update(dt)
	else
		self:updatePlayer(dt)				-- player state * dt
		self:updateEnemies(dt)			-- enemies states * dt
		self:updateProjectiles(dt)  -- projectile states * dt

		self.CH:update() -- collision handler state * dt


		for i = #self.enemies, 1, -1 do
			if self.enemies[i]:isDead() then
				self:destroyEnemy(self.enemies[i].id)
			end
		end

		--self.spawnTimer = self.spawnTimer + dt
		if not self.multiplayer and self.spawnTimer > 5 then
			self:spawnEnemy(self.player)
			self.spawnTimer = self.spawnTimer - 5
		end
	end
end
---GameHandler spawnEnemy.
function GameHandler:spawnEnemy(object)
	self:addObject(Enemy(self:getNewUID(), nil, {255,0,0}, .5, 5, 300, 300, 32, 32, 15, 2, object))
end

---GameHandler updatePeers.
function GameHandler:updatePeers(dt)
	for i=1, #self.peers, 1 do
		if self.peers[i]:isDead() then
			-- TODO Handle a peer death.
		end
	end
end
---GameHandler updatePlayer.
function GameHandler:updatePlayer(dt)

	if self.player:isDead() then

		-- --(Multiplayer) Stream Projectile Spawn-----
		-- if self.multiplayer then
		-- 	NH:playerDeath(self.player.id)
		-- end
		-- --------------------------------------------
		deathSound:play()
		MH:resetPlayer()
		
	end

	if self.player.immune then
		self.player:updateImmunity(dt)
	end
	self.playerIsMoving = false

	if love.keyboard.isDown('w') then
		self.player:move(dt, 1)
		self.playerIsMoving = true
	end
	if love.keyboard.isDown('a') then
		self.player:move(dt, 4)
		self.playerIsMoving = true
	end
	if love.keyboard.isDown('s') then
		self.player:move(dt, 3)
		self.playerIsMoving = true
	  end
	if love.keyboard.isDown('d') then
		self.player:move(dt, 2)
		self.playerIsMoving = true
	end

	if not love.keyboard.isDown('d') and not love.keyboard.isDown('w') and not love.keyboard.isDown('a') and not love.keyboard.isDown('s') then
		self.player.movesound:pause()
		self.player.movesound:rewind()
	end

	if not self.player.movementEnabled then
		self.player:move(dt)
		self.playerIsMoving = true
	end

	--(Multiplayer)  Stream Player Movement--------
	if self.multiplayer then
		if self.playerIsMoving then
			self.networkMoveTimer = self.networkMoveTimer + dt
			if self.networkMoveTimer > UPDATERATE then
				if self.player.x ~= self.playerPrevX and self.player.y ~= self.playerPrevY then
					NH:playerMove(self.player.id, self.player.x, self.player.y)
				else
					self.playerPrevX = self.player.x
					self.playerPrevY = self.player.y
				end
				self.networkMoveTimer = 0
			end
		end
	end
	-----------------------------------------------

	-- Let player attack
	if not self.player.attackDelay and love.mouse.isDown(1) then
		local currentWeapon = self.IH:getItem(self.player.equipment.weapon)
		local x,y = love.mouse.getPosition()

		self:fireWeapon(currentWeapon, x, y)
		self.bulletSound:rewind()
		self.bulletSound:play()
	else
		self.player:updateAttackDelay(dt)
	end
end
---GameHandler updateEnemies.
function GameHandler:updateEnemies(dt)
	for i = #self.enemies, 1, -1 do
		self.enemies[i]:chase()
		self.enemies[i]:move(dt)
		if self.enemies[i].showHealth then
			self.enemies[i]:updateShowHealth(dt)
		end
	end
end
---GameHandler updateProjectiles.
function GameHandler:updateProjectiles(dt)
	for i=#self.projectiles, 1, -1 do self.projectiles[i]:move(dt) end
end

-- End of update functions

-- Creation functions
---GameHandler createProjectile.
function GameHandler:createProjectile(x, y, size, angle, damage, speed, creatorID, time)
	local changeInTime = self.gameTimer - time
	x = x + (changeInTime * math.cos(angle) * speed * base_speed)
	y = y + (changeInTime * math.sin(angle) * speed * base_speed)

	self:addObject(Projectile(self:getNewUID(), nil, x, y, size, size, math.cos(angle), math.sin(angle), damage, speed, creatorID))



	--(Multiplayer) Stream Projectile Spawn-----
	if self.multiplayer and self.player.id == creatorID then
		NH:spawnProjectile(x, y, size, angle, damage, speed, creatorID, time)
	end
	--------------------------------------------
end

-- End of creation functions


-- Helper functions
---GameHandler destroyProjectile.
function GameHandler:destroyProjectile(id)
	table.remove(self.CH.projectiles, self.getObjectPosition(id, self.CH.projectiles))
	table.remove(self.projectiles, self.getObjectPosition(id, self.projectiles))
end

function GameHandler:destroyEnemy(id)
	self.enemyDeath:rewind()
	self.enemyDeath:play()
	table.remove(self.CH.objects, self.getObjectPosition(id, self.CH.objects))
	table.remove(self.enemies, self.getObjectPosition(id, self.enemies))
end
---GameHandler getObjectPosition.
function GameHandler.getObjectPosition(id, table)
	for i=1, #table do
		if table[i].id == id then
			return i
		end
	end
	return -1
end
---GameHandler getNewUID.
function GameHandler:getNewUID()
	self.uid_counter = self.uid_counter + 1
	return self.uid_counter
end
---GameHandler fireWeapon
function GameHandler:fireWeapon(weapon, mx, my)
	-- Move this to its own handler later?
	if weapon.weaponType == RANGED then
		local relX = mx - x_translate_val
		local relY = my - y_translate_val

		local angle = math.atan2(relY - self.player.y, relX - self.player.x)

		local spreadAngle = .261799 *(weapon.stats.spread or 1) -- 15 degrees

		local halfProj = weapon.stats.projectiles / 2

		if math.fmod(weapon.stats.projectiles, 2) == 0 then
			-- Even num of projectiles

			for i = 1, halfProj do
				local leftAngle = angle - (spreadAngle/2) - ((i-1) * spreadAngle)
				local rightAngle = angle + (spreadAngle/2) + ((i-1) * spreadAngle)

				self:createProjectile(self.player.x, self.player.y, 16, leftAngle, weapon.stats.damage, weapon.stats.speed, self.player.id, self.gameTimer)
				self:createProjectile(self.player.x, self.player.y, 16, rightAngle, weapon.stats.damage, weapon.stats.speed, self.player.id, self.gameTimer)
			end
		else
			-- Odd num of projectiles
			halfProj = math.floor(halfProj)

			for i = 1, halfProj do
				local leftAngle = angle - (i * spreadAngle)
				local rightAngle = angle + (i * spreadAngle)

				self:createProjectile(self.player.x, self.player.y, 16, leftAngle, weapon.stats.damage, weapon.stats.speed, self.player.id, self.gameTimer)
				self:createProjectile(self.player.x, self.player.y, 16, rightAngle, weapon.stats.damage, weapon.stats.speed, self.player.id, self.gameTimer)
			end
			-- Fire at mouse
			self:createProjectile(self.player.x, self.player.y, 16, angle, weapon.stats.damage, weapon.stats.speed, self.player.id, self.gameTimer)
		end

		self.player:startAttackDelay(weapon.stats.firerate)
	end
end


-- End of helper functions
