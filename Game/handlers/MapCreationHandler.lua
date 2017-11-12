
class = require 'libraries.ext.30log'

MapCreationHandler = class("MapCreationHandler", {
	gridColor = {180,180,180}, 
	paletteSize = 200,
	paletteColor = {80,80,80},
	textColor = {20,211,255},
	mode = "Editing",
	currentMap = {}
	})

function MapCreationHandler:init(tilesize)
	self.tilesize = tilesize or 64
end

function MapCreationHandler:drawGridLines(x, y)
	local width, height = love.graphics.getDimensions()

	local camerax = x / zoom
	local cameray = y / zoom


	width = width / zoom
	height = height / zoom

	local furthestLeft = camerax - (width/2)
	local furthestRight = camerax + (width/2)
	local furthestUp = cameray - (height/2)
	local furthestDown = cameray + (height/2)


	local startx = furthestLeft
	local starty = furthestUp



	local numXtiles = math.floor((width / self.tilesize) / zoom)
	local numYtiles = math.floor(((height) / self.tilesize) / zoom) + 1

	-- I think 10 is overkill for values of zoom > 3.5, but that's okay since max = 5
	if zoom > 1 then
		numXtiles = numXtiles + 10
		numYtiles = numYtiles + 10
	end


	love.graphics.setColor(self.gridColor)

	if furthestLeft % self.tilesize ~= 0 then
		-- Start to the left. This way we will be rendering one gridline off screen to the left. Let's do the same for the right
		startx = furthestLeft - (furthestLeft % self.tilesize)
	end
	if furthestUp % self.tilesize ~= 0 then
		starty = furthestUp - (furthestUp % self.tilesize)
	end

	-- Draw vertical lines
	for i = 0, numXtiles do
		local currentx = startx + (i*64)
		love.graphics.line(currentx, furthestUp, currentx, furthestDown)
	end

	-- Draw horizontal lines
	for i = 0, numYtiles do
		local currenty = starty + (i*64)
		love.graphics.line(furthestLeft, currenty, furthestRight, currenty)
	end
end

function MapCreationHandler:drawGUI()
	local width, height = love.graphics.getDimensions()

	local paletteX = 0
	local paletteY = height - self.paletteSize

	love.graphics.setColor(self.paletteColor)
	love.graphics.rectangle("fill", paletteX, paletteY, width, self.paletteSize)
	love.graphics.setColor(self.textColor)
	love.graphics.setNewFont(25)
	love.graphics.print("Palette", paletteX + 10, paletteY + 10)
	love.graphics.setNewFont(16)
	love.graphics.print("Mode: " .. self.mode, paletteX + 10, paletteY + 40)
end

function MapCreationHandler:drawMouse()
	if self.mode == "Editing" then
		love.mouse.setCursor(arrowCursor)
		local mx, my = love.mouse.getPosition()
		if (my < love.graphics.getHeight() - self.paletteSize) then
			local mouseX = (mx - x_translate_val) / zoom
			local mouseY = (my - y_translate_val) / zoom
			local drawX = mouseX - (mouseX % self.tilesize)
			local drawY = mouseY - (mouseY % self.tilesize)
			love.graphics.setColor(0,255,0)
			love.graphics.rectangle("fill", drawX, drawY, self.tilesize, self.tilesize)
		else
			-- Mouse is in palette
		end
	elseif self.mode == "Moving" then
		love.mouse.setCursor(handCursor)
	end
end

function MapCreationHandler:changeMode(mode)
	if mode then
		self.mode = mode
	else
		if self.mode == "Editing" then
			self.mode = "Moving"
		elseif self.mode == "Moving" then
			self.mode = "Editing"
		end
	end
end

function MapCreationHandler:loadMap(map)

end