
Singleplayer = {}



function Singleplayer:init()
end

function Singleplayer:enter()
	collision = 0

	GH = GameHandler()

	love.graphics.setNewFont(16)

	HUD = HeadsUpDisplay()

	

	GH:addObject(Player(GH:getNewUID(), spriteImg, CHARACTERCOLOR, 1, 10, 96, 96, 32, 32))



	GH:addObject(Enemy(GH:getNewUID(), nil, {255,0,0}, .5, 5, math.random(96, 300), math.random(96, 300), 32, 32, 15, 2, GH.player))

	GH.LH:loadLevel("test", 1)
	
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
	love.graphics.print("Collision: " .. tostring(collision), 10, 80)
	love.graphics.print("Number of projectiles: " .. #GH.projectiles, 10, 100)
	love.graphics.print("Score: " .. GH.player.score, 10, 120)
	love.graphics.print("Time: " .. math.floor(GH.gameTimer), 10, 160)



	HUD:draw()

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




return Singleplayer
