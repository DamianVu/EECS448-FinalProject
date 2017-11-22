
Singleplayer = {}



function Singleplayer:init()
end

function Singleplayer:enter()
	collision = 0

	GH = GameHandler()

	love.graphics.setNewFont(16)

	HUD = HeadsUpDisplay()

	-- Should be generated later.
	GH:addObject(Terrain(0, 0, 64 * 11, 64))
	GH:addObject(Terrain(0, 64*9, 64*11, 64))
	GH:addObject(Terrain(0, 64, 64, 64 * 8))
	GH:addObject(Terrain(64 * 10, 64, 64, 64 * 8))
	GH:addObject(Terrain(128, 128, 64, 64))
	GH:addObject(Terrain(6 * 64, 5 * 64, 128, 128))



	GH:addObject(Player(GH:getNewUID(), spriteImg, CHARACTERCOLOR, 1, 10, 96, 96, 32, 32))

	GH:addObject(Enemy(GH:getNewUID(), nil, {255,0,0}, .5, 5, 96, 96, 32, 32, 100, 2, GH.player))

	GH.LH:startGame()
	
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
