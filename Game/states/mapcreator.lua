---State MapCreator
MapCreator = {}

local checkMouseMovement = false

camera = {x = 400, y = 200, x_vel = 0, y_vel = 0, speed = 2} -- Camera object (will be the focus of the camera translation)

function MapCreator:enter()
	MCH = MapCreationHandler(64)
	gridlines = true
	minZoom = .2
	zoom = 1
	maxZoom = 5
	love.mouse.setVisible(true)
end

function MapCreator:draw()
	x_translate_val = (love.graphics.getWidth() / 2) - camera.x
	y_translate_val = ((love.graphics.getHeight() - MCH.paletteSize) / 2) - camera.y

	love.graphics.push()
	love.graphics.translate(x_translate_val, y_translate_val)
	love.graphics.scale(zoom)

	MCH:drawMap()

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

	if MCH.mode == MCHModes[3] then
		MCH:drawObjectMenu()
	end

end

function MapCreator:update(dt)

	MCH:updateMouseOnPalette()
	if MCH.mode == MCHModes[3] then MCH:updateMouseOnObjectMenu() end

	if MCH.mouseOnObjectMenuButton or checkMouseMovement then
		love.mouse.setCursor(handCursor)
	else
		love.mouse.setCursor(arrowCursor)
	end

	canZoom = MCH.mode == "Moving"


	if not love.keyboard.isDown('up', 'down') then camera.y_vel = 0 end
	if not love.keyboard.isDown('left', 'right') then camera.x_vel = 0 end


	if checkMouseMovement then
		curMouseX, curMouseY = love.mouse.getPosition()
		camera.x = oldCameraX - (curMouseX - oldMouseX)
		camera.y = oldCameraY - (curMouseY - oldMouseY)

	else
		-- Move
		camera.x = math.floor(camera.x + (camera.x_vel * dt))
		camera.y = math.floor(camera.y + (camera.y_vel * dt))
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
	if not checkMouseMovement and MCH.mode ~= MCHModes[3] then
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
			print("right")
		end
		if key == 'r' then
			camera.x = 0
			camera.y = 0
			zoom = 1
		end
		if key == 'm' then MCH:changeMode() end
	end

	if key == ',' then MCH:changePage(true) end
	if key == '.' then MCH:changePage(false) end

	if key == 'n' then MCH:changeTileset(true) end
	if key == 'm' then MCH:changeTileset(false) end

	if key == 'g' then gridlines = not gridlines end

	if key == 'escape' then
		if MCH.mode == MCHModes[3] then
			MCH.mode = MCHModes[1]
		else
			Gamestate.switch(Mainmenu)
		end
	end
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
	elseif MCH.mode == MCHModes[3] then
		if button == 1 and not MCH.mouseOnObjectMenu then
			MCH.mode = MCHModes[1]
			MCH:resetObjectMenu()
		else
			MCH:objectMenuClickAction(x, y)
		end
	end

	if MCH.mouseOnPalette then
		-- Check if clicked on some tile in palette
		local startX = 10
		local startY = (love.graphics.getHeight() - 138)
		if x >= startX and x <= startX + 512 and y >= startY and y <= startY + 128 then
			local ctile = 1
			local done = false
			for i = 1, 2 do
				for j = 1, 8 do
					if ctile > #MCH.objects then break end
						if y < startY + (64*i) and x < startX + (j*64) then
						done = true
						MCH.currentTile = ctile + ((MCH.currentTilePage-1) * 16)
						break
					end
						ctile = ctile + 1
				end
				if done then
					break
				end
			end
		end

		if MCH.mouseOnObjectMenuButton then MCH.mode = MCHModes[3] end

		print("Clicked and mouseonsavebutton = " .. tostring(MCH.mouseOnSaveButton))
		if MCH.mouseOnSaveButton then MCH:saveMap() end
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
	MCH:saveMap()
end

function MapCreator:quit()
	MCH:saveMap()
end

return MapCreator
