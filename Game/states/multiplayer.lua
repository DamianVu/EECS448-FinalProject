--- State online game (module)
-- This state allows us to make network connections and play online
OnlineGame = {}

updateRate = .05 -- How often we should send updates to the server

--- Called only when this module is initialized (in main.lua)
function OnlineGame:init() -- init is only called once

end

--- Called whenever this state has been entered
function OnlineGame:enter() -- enter is called everytime this state occurs
	MENUMUSIC:pause()
	WATERMUSIC:play()

	collision = 0

	GH = GameHandler()

	love.graphics.setNewFont(16)

	HUD = HeadsUpDisplay()

	GH:addObject(Player(USERNAME .. USERID, nil, love.graphics.newImage("images/sprites/characters/" .. USERSPRITE .. ".png"), CHARACTERCOLOR, 1, 50, 96, 96, 48, 48))

	GH.LH:loadLevel("beach", 1)

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
	love.graphics.print("Score: " .. GH.player.score, 10, 80)


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
	WATERMUSIC:stop()
	MENUMUSIC:play()
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
