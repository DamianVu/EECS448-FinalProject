
Singleplayer = {}



uid_counter = 0

function Singleplayer:init()
end

function Singleplayer:enter()
	collision = 0

	terrain = {}
	projectiles = {}
	enemies = {}

	love.graphics.setNewFont(16)

	HUD = HeadsUpDisplay()

	IH = ItemHandler()

	

	player = Player(getNewUID(), spriteImg, CHARACTERCOLOR, 1, 10, 96, 96, 32, 32)



	terrain[1] = Terrain(0, 0, 64 * 11, 64)
	terrain[2] = Terrain(0, 64*9, 64*11, 64)
	terrain[3] = Terrain(0, 64, 64, 64 * 8)
	terrain[4] = Terrain(64 * 10, 64, 64, 64 * 8)
	terrain[5] = Terrain(128, 128, 64, 64)
	terrain[6] = Terrain(6 * 64, 5 * 64, 128, 128)

	enemies[#enemies + 1] = Enemy(getNewUID(), nil, {255,0,0}, .5, 5, 96, 96, 32, 32, 100, 2, player)

	LH = LevelHandler()
	LH:startGame()

	CH = NewCollisionHandler()

	CH:addObject(player)
	for i=1, #enemies do CH:addObject(enemies[i]) end
	for i=1, #terrain do CH:addTerrain(terrain[i]) end
	for i=1, #projectiles do CH:addProjectile(projectiles[i]) end
end

function Singleplayer:draw()
	x_translate_val = (love.graphics.getWidth() / 2) - player.x
	y_translate_val = (love.graphics.getHeight() / 2) - player.y

	love.graphics.push()
	love.graphics.translate(x_translate_val, y_translate_val)

	MH:drawMap()


	for i=#enemies, 1, -1 do enemies[i]:draw() end
	
	for i=#projectiles, 1, -1 do projectiles[i]:draw() end

	player:draw()

	love.graphics.pop()

	love.graphics.setColor(0,255,0)
	love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 60)
	love.graphics.print("Collision: " .. tostring(collision), 10, 80)
	love.graphics.print("Number of projectiles: " .. #projectiles, 10, 100)
	love.graphics.print("Score: " .. player.score, 10, 120)



	HUD:draw()

    love.graphics.setColor(255, 255, 255)
    local mx,my = love.mouse.getPosition()
    love.graphics.circle("line", mx, my, 8)

end

function Singleplayer:update(dt)

	if player:isDead() then Gamestate.switch(GameOver) end

	if player.immune then
		player:updateImmunity(dt)
	end

	LH:update(dt)
	-- Change velocity according to keypresses
	if love.keyboard.isDown('w') then player:move(dt, 1) end
    if love.keyboard.isDown('a') then player:move(dt, 4) end
	if love.keyboard.isDown('s') then player:move(dt, 3) end
	if love.keyboard.isDown('d') then player:move(dt, 2) end

	if not player.movementEnabled then player:move(dt) end

	for i = #enemies, 1, -1 do
		enemies[i]:chase()
		enemies[i]:move(dt)
		if enemies[i].showHealth then
			enemies[i]:updateShowHealth(dt)
		end
	end
	
	for i=#projectiles, 1, -1 do projectiles[i]:move(dt) end

	-- Let player attack
	if not player.attackDelay and love.mouse.isDown(1) then
		local currentWeapon = IH:getItem(player.equipment.weapon)
		local x,y = love.mouse.getPosition()

		fireWeapon(currentWeapon, x, y)
	else
		player:updateAttackDelay(dt)
	end





	CH:update()

	for i = #enemies, 1, -1 do
		if enemies[i]:isDead() then
			destroyEnemy(enemies[i].id)
		end
	end
end

--- Event binding to listen for key presses
function Singleplayer:keypressed(key)
	if key == 'r' then
    	Gamestate.switch(Singleplayer)
	end
	if key == "escape" then
		Gamestate.switch(PlayMenu)
	end
end


function destroyProjectile(id)
	table.remove(CH.projectiles, getObjectPosition(id, CH.projectiles))
	table.remove(projectiles, getObjectPosition(id, projectiles))
end

function destroyEnemy(id)
	table.remove(CH.objects, getObjectPosition(id, CH.objects))
	table.remove(enemies, getObjectPosition(id, enemies))
end

function getObjectPosition(id, table)
	for i=1, #table do
		if table[i].id == id then
			return i
		end
	end
	return -1
end

function getNewUID()
	uid_counter = uid_counter + 1
	return uid_counter
end

function fireWeapon(weapon, mx, my)
	-- Move this to its own handler later?
	if weapon.weaponType == RANGED then
		local relX = mx - x_translate_val
		local relY = my - y_translate_val

		local angle = math.atan2(relY - player.y, relX - player.x)

		print("Angle: " .. angle)


		local spreadAngle = .261799 -- 15 degrees



		if math.fmod(weapon.stats.projectiles, 2) == 0 then
			-- Even num of projectiles

		else
			-- Odd num of projectiles
			local halfProj = math.floor(weapon.stats.projectiles / 2)

			for i = 1, halfProj do
				-- Fire to the left
				local newInd = #projectiles + 1
				projectiles[newInd] = Projectile(getNewUID(), nil, player.x, player.y, 16, 16, 3 * math.cos(angle - (i * spreadAngle)), 3 * math.sin(angle - (i * spreadAngle)), weapon.stats.damage, weapon.stats.speed, player.id)
				CH.projectiles[#CH.projectiles + 1] = projectiles[newInd]

				-- Fire to the right
				newInd = #projectiles + 1
				projectiles[#projectiles + 1] = Projectile(getNewUID(), nil, player.x, player.y, 16, 16, 3 * math.cos(angle + (i * spreadAngle)), 3 * math.sin(angle + (i * spreadAngle)), weapon.stats.damage, weapon.stats.speed, player.id)
				CH.projectiles[#CH.projectiles + 1] = projectiles[newInd]
			end
			-- Fire at mouse
			local ind = #projectiles + 1
			projectiles[ind] = Projectile(getNewUID(), nil, player.x, player.y, 16, 16, 3 * math.cos(angle), 3 * math.sin(angle), weapon.stats.damage, weapon.stats.speed, player.id)
			CH.projectiles[#CH.projectiles + 1] = projectiles[ind]
		end

	

		player:startAttackDelay(weapon.stats.firerate)
	end
end

return Singleplayer
