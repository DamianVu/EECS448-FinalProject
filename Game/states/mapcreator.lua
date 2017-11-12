
MapCreator = {}

require "handlers.MapCreationHandler"

local checkMouseMovement = false

camera = {x = 400, y = 400, x_vel = 0, y_vel = 0, speed = 2} -- Camera object (will be the focus of the camera translation)

function MapCreator:enter()
	MCH = MapCreationHandler(64)
	MCH:loadTilesets()
	gridlines = true
	minZoom = .2
	zoom = 1
	maxZoom = 5
	love.mouse.setVisible(true)
end

function MapCreator:draw()
	x_translate_val = (love.graphics.getWidth() / 2) - camera.x
	y_translate_val = (love.graphics.getHeight() / 2) - camera.y

	love.graphics.push()
	love.graphics.translate(x_translate_val, y_translate_val)
	love.graphics.scale(zoom)

	MCH:drawMouse()

	if gridlines then MCH:drawGridLines(camera.x, camera.y) end

	-- Draw origin
	love.graphics.setColor(255,0,0)
	love.graphics.circle("fill", 0, 0, 5)

	love.graphics.pop()

	MCH:drawGUI()
	love.graphics.setColor(255,0,0)
	love.graphics.print("Camera-X: " .. camera.x, 10, 30)
	love.graphics.print("Camera-Y: " .. camera.y, 10, 50)

end

function MapCreator:update(dt)

	MCH:updateMouseOnPalette()
	if MCH.mode == "Moving" then
		canZoom = true
	else
		canZoom = false
	end

	
	if not love.keyboard.isDown('up', 'down') then camera.y_vel = 0 end
	if not love.keyboard.isDown('left', 'right') then camera.x_vel = 0 end


	if checkMouseMovement then
		curMouseX, curMouseY = love.mouse.getPosition()
		camera.x = oldCameraX - (curMouseX - oldMouseX)
		camera.y = oldCameraY - (curMouseY - oldMouseY)
	else
		-- Move
		camera.x = math.floor(camera.x + camera.x_vel)
		camera.y = math.floor(camera.y + camera.y_vel)
	end

	if MCH.mode == "Editing" then
		if love.mouse.isDown(1) and MCH.mouseOnValidTile and not MCH.mouseOnPalette then
			MCH:placeTile()
		end
		if love.mouse.isDown(2) and MCH.mouseOnValidTile and not MCH.mouseOnPalette then
			MCH:removeTile()
		end
	end


end

function MapCreator:keypressed(key)
	local zoomSpeed = zoom
	if zoom < 1 then
		zoomSpeed = 1
	end
	if not checkMouseMovement then
		if key == 'up' then 
			camera.y_vel = -camera.speed * 3 * zoomSpeed
		end
		if key == 'left' then 
			camera.x_vel = -camera.speed * 3 * zoomSpeed
		end
		if key == 'down' then 
			camera.y_vel = camera.speed * 3 * zoomSpeed
		end
		if key == 'right' then 
			camera.x_vel = camera.speed * 3 * zoomSpeed
		end
		if key == 'r' then 
			camera.x = 0
			camera.y = 0
			zoom = 1
		end
		if key == 'm' then MCH:changeMode() end
	end

	if key == 'g' then gridlines = not gridlines end
end

function MapCreator:keyreleased(key)

end

function MapCreator:mousepressed(x,y,button,_)
	if MCH.mode == "Editing" then

	elseif MCH.mode == "Moving" then
		if button == 1 and not MCH.mouseOnPalette then
			oldMouseX = x
			oldMouseY = y
			oldCameraX = camera.x
			oldCameraY = camera.y
			checkMouseMovement = true
		end
	end
end

function MapCreator:mousereleased(x,y,button,_)
	if MCH.mode == "Editing" then

	elseif MCH.mode == "Moving" then
		if button == 1 then
			checkMouseMovement = false
		end
	end
end

function MapCreator:leave()
	-- Prompt for save?
end

function MapCreator:quit()

end

return MapCreator