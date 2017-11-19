--- State online game (module)
-- This state allows us to make network connections and play online
OnlineGame = {}

updateRate = .05 -- How often we should send updates to the server

--- Called only when this module is initialized (in main.lua)
function OnlineGame:init() -- init is only called once

end

--- Called whenever this state has been entered
function OnlineGame:enter() -- enter is called everytime this state occurs
	peers = {}
	terrain = {}
	projectiles = {}
	enemies = {}

	HUD = HeadsUpDisplay()

	CH = NewCollisionHandler()

	-- Map Handler initialization
	love.graphics.setNewFont(16)
	LH = LevelHandler()
	LH:loadLevel(4,1)

	-- MANUAL TERRAIN OBJECTS!!! THIS WILL CHANGE AFTER MAP FORMAT IS DONE
	terrain[1] = Terrain(0, 0, 64 * 11, 64)
	terrain[2] = Terrain(0, 64*9, 64*11, 64)
	terrain[3] = Terrain(0, 64, 64, 64 * 8)
	terrain[4] = Terrain(64 * 10, 64, 64, 64 * 8)
	terrain[5] = Terrain(128, 128, 64, 64)
	terrain[6] = Terrain(6 * 64, 5 * 64, 128, 128)

	-- Initialize player and register to table of moving objects
	player = Player(USERNAME, spriteImg, CHARACTERCOLOR, 1, 10, 96, 96, 32, 32)

	CH:addObject(player)
	for i=1, #enemies do CH:addObject(enemies[i]) end
	for i=1, #terrain do CH:addTerrain(terrain[i]) end

	messageCount = 0
	connectToServer(SERVER_ADDRESS, SERVER_PORT)


	updateTimer = 0
end

--- Called on game ticks for drawing operations
function OnlineGame:draw()
	x_translate_val = (love.graphics.getWidth() / 2) - player.x
	y_translate_val = (love.graphics.getHeight() / 2) - player.y

	love.graphics.push()
	love.graphics.translate(x_translate_val, y_translate_val)

	MH:drawMap()

	for i = 1, #peers do peers[i]:draw() end

	for i=#enemies, 1, -1 do enemies[i]:draw() end
	
	for i=#projectiles, 1, -1 do projectiles[i]:draw() end

	player:draw()

	love.graphics.pop()

	love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 60)
	love.graphics.print("Collision: " .. tostring(collision), 10, 80)
	love.graphics.print("Number of projectiles: " .. #projectiles, 10, 100)

	HUD:draw()

	love.graphics.setColor(255, 255, 255)
    local mx,my = love.mouse.getPosition()
    love.graphics.circle("line", mx, my, 8)
end

--- Called every game tick
function OnlineGame:update(dt)
	receiver()

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
	end

	for i = #projectiles, 1, -1 do projectiles[i]:move(dt) end

	for i = #enemies, 1, -1 do
		if enemies[i]:isDead() then
			destroyEnemy(enemies[i].id)
		end
	end

	CH:update()

	updateTimer = updateTimer + dt
	if updateTimer > updateRate then 
		sendToServer(USERNAME.." moveto "..player.x.." "..player.y)
		updateTimer = 0
	end
end

--- Called when this state has been left
function OnlineGame:leave()
	disconnectFromServer()
end

--- Called if the game is exited in this state
function OnlineGame:quit()
	disconnectFromServer()
end

--- Event handler binding to listen for keypresses
function OnlineGame:keypressed(key)
	--if key == 'l' then sendToServer(USERNAME.." listplayers") end -- List online players (testing)
	if debugMode and key == 'r' then player.x, player.y = 0, 0 end -- Reset position
	if key == 'n' then noclip = not noclip end
	if key == 'tab' then debugMode = not debugMode end -- Toggle debug mode
	if key == 'escape' then Gamestate.switch(PlayMenu) end
end

function OnlineGame:mousepressed(x, y, button)
	if button == 1 then
		local relX = x - x_translate_val
		local relY = y - y_translate_val

		local angle = math.atan2(relY - player.y, relX - player.x)

		local index = #projectiles + 1

		projectiles[index] = Projectile(getNewUID(), nil, player.x, player.y, 16, 16, 3 * math.cos(angle), 3 * math.sin(angle), 5, 1, player.id)
		CH.projectiles[#CH.projectiles + 1] = projectiles[index]
	end
end


return OnlineGame
