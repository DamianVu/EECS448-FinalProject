---Singleplayer State
Singleplayer = {}



function Singleplayer:init()
end

function Singleplayer:enter()

	MENUMUSIC:pause()
	WATERMUSIC:play()

	collision = 0

	GH = GameHandler()

	love.graphics.setNewFont(16)

	HUD = HeadsUpDisplay()



	GH:addObject(Player(GH:getNewUID(), nil, CURRENTSPRITE, CHARACTERCOLOR, 1, 50, 96, 96, 48, 48))



	--GH:addObject(Enemy(GH:getNewUID(), nil, {255,0,0}, .5, 5, math.random(96, 300), math.random(96, 300), 32, 32, 15, 2, GH.player))

	GH.LH:loadLevel("beach", 1)

	--GH.DH:start("Starting")
end

function Singleplayer:draw()
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

	if GH.DH.playing then
		GH.DH:draw()
	end

    love.graphics.setColor(255, 255, 255)
    local mx,my = love.mouse.getPosition()
    love.graphics.circle("line", mx, my, 8)

end

function Singleplayer:update(dt)

	GH:update(dt)

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

function Singleplayer:leave()
	WATERMUSIC:stop()
	MENUMUSIC:play()
end




return Singleplayer
