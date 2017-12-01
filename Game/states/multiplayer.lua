--- State online game (module)
-- This state allows us to make network connections and play online
OnlineGame = {}

updateRate = .05 -- How often we should send updates to the server

--- Called only when this module is initialized (in main.lua)
function OnlineGame:init() -- init is only called once

end

--- Called whenever this state has been entered
function OnlineGame:enter() -- enter is called everytime this state occurs
	collision = 0

	GH = GameHandler()

	love.graphics.setNewFont(16)

	HUD = HeadsUpDisplay()

	GH:addObject(Player(USERNAME .. USERID, spriteImg, CHARACTERCOLOR, 1, 10, 96, 96, 32, 32))

	GH.LH:loadLevel("test", 1)

	messageCount = 0
	print("Connecting to server")

	NH = NetworkHandler(GH, SERVER_ADDRESS, SERVER_PORT) -- IP is that of vuhoo.org
	NH:connect()


	updateTimer = 0
end

--- Called on game ticks for drawing operations
function OnlineGame:draw()
	x_translate_val = (love.graphics.getWidth() / 2) - GH.player.x
	y_translate_val = (love.graphics.getHeight() / 2) - GH.player.y

	love.graphics.push()
	love.graphics.translate(x_translate_val, y_translate_val)

	MH:drawMap()

	GH:draw()


	love.graphics.pop()

	love.graphics.setColor(0,255,0)
	love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 60)
	love.graphics.print("Collision: " .. tostring(collision), 10, 80)
	love.graphics.print("Number of projectiles: " .. #GH.projectiles, 10, 100)
	love.graphics.print("Score: " .. GH.player.score, 10, 120)
	love.graphics.print("Time: " .. math.floor(GH.gameTimer), 10, 160)


	HUD:draw()

    love.graphics.setColor(255, 255, 255)
    local mx,my = love.mouse.getPosition()
    love.graphics.circle("line", mx, my, 8)
end

--- Called every game tick
function OnlineGame:update(dt)
	NH:receive()

	GH:update(dt)
end

--- Called when this state has been left
function OnlineGame:leave()
	NH:disconnect()
end

--- Called if the game is exited in this state
function OnlineGame:quit()
	NH:disconnect()
end

--- Event handler binding to listen for keypresses
function OnlineGame:keypressed(key)
	--if key == 'l' then sendToServer(USERNAME.." listplayers") end -- List online players (testing)
	if debugMode and key == 'r' then player.x, player.y = 0, 0 end -- Reset position
	if key == 'n' then noclip = not noclip end
	if key == 'tab' then debugMode = not debugMode end -- Toggle debug mode
	if key == 'escape' then Gamestate.switch(PlayMenu) end
	if key == 'o' then NH:send(GH.player.id .. " start") end
end


return OnlineGame
