
CollisionTesting = {}

local terrain = {}
projectiles = {}
enemies = {}

uid_counter = 0

function CollisionTesting:init()
end

function CollisionTesting:enter()
	collision = 0


	projectiles = {}
	enemies = {}

	love.graphics.setNewFont(16)

	spriteImg = love.graphics.newImage('images/sprites/player.png')
	circleImg = love.graphics.newImage('images/sprites/Circle.png')
	enemyImg = love.graphics.newImage('images/sprites/badguy.png')

	player = Player(getNewUID(), spriteImg, {255,255,255}, 1.5, 96, 96, 32, 32)

	terrain[1] = Terrain(0, 0, 64 * 11, 64)
	terrain[2] = Terrain(0, 64*9, 64*11, 64)
	terrain[3] = Terrain(0, 64, 64, 64 * 8)
	terrain[4] = Terrain(64 * 10, 64, 64, 64 * 8)
	terrain[5] = Terrain(128, 128, 64, 64)
	terrain[6] = Terrain(6 * 64, 5 * 64, 128, 128)

	enemies[#enemies + 1] = Enemy(getNewUID(), nil, {255,0,0}, 2, 1, 400, 400, 32, 32, 20, player)

	LH = LevelHandler()
	LH:startGame()

	CH = NewCollisionHandler()

	CH:addObject(player)
	for i=1, #enemies do CH:addObject(enemies[i]) end
	for i=1, #terrain do CH:addTerrain(terrain[i]) end
	for i=1, #projectiles do CH:addProjectile(projectiles[i]) end
end

function CollisionTesting:draw()
	x_translate_val = (love.graphics.getWidth() / 2) - player.x
	y_translate_val = (love.graphics.getHeight() / 2) - player.y

	love.graphics.push()
	love.graphics.translate(x_translate_val, y_translate_val)

	MH:drawMap()
	if debugMode then
		highlightTiles(player)
	end

	player:draw()
	player:drawHitbox()

	for i=#enemies, 1, -1 do enemies[i]:draw() end
	
	for i=#projectiles, 1, -1 do projectiles[i]:draw() end




	love.graphics.pop()


	love.graphics.setColor(255, 255, 255)
	love.graphics.circle("line", mouse.x, mouse.y, 5)

	love.graphics.setColor(0,255,0)
	love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
	love.graphics.print("Collision: " .. tostring(collision), 10, 30)
	love.graphics.print("Number of projectiles: " .. #projectiles, 10, 50)

end

function CollisionTesting:update(dt)
	
	LH:update(dt)
	-- Change velocity according to keypresses
	if love.keyboard.isDown('w') then player:move(dt, 1) end
    if love.keyboard.isDown('a') then player:move(dt, 4) end
	if love.keyboard.isDown('s') then player:move(dt, 3) end
	if love.keyboard.isDown('d') then player:move(dt, 2) end


	for i = #enemies, 1, -1 do
		if enemies[i]:isDead() then
			local eid = enemies[i].id
			table.remove(CH.objects, getObjectPosition(eid, CH.objects))
			table.remove(enemies, getObjectPosition(eid, enemies))
		else
			enemies[i]:chase()
			enemies[i]:move()
		end
	end
	
	for i=#projectiles, 1, -1 do projectiles[i]:move(dt) end

	CH:update()
end

--- Event binding to listen for key presses
function CollisionTesting:keypressed(key)
	if key == 'r' then
    	Gamestate.switch(CollisionTesting)
	end
end

function CollisionTesting:mousepressed(x, y, button)
	if button == 1 then
		local relX = x - x_translate_val
		local relY = y - y_translate_val

		local angle = math.atan2(relY - player.y, relX - player.x)

		local index = #projectiles + 1

		projectiles[index] = Projectile(getNewUID(), nil, player.x, player.y, 16, 16, 3 * math.cos(angle), 3 * math.sin(angle), 5, 1, player.id)
		CH.projectiles[#CH.projectiles + 1] = projectiles[index]
	end
end


function destroyProjectile(id)
	table.remove(CH.projectiles, getObjectPosition(id, CH.projectiles))
	table.remove(projectiles, getObjectPosition(id, projectiles))
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

return CollisionTesting
