
class = require 'libraries.ext.30log'

MapCreationHandler = class("MapCreationHandler", {
	gridColor = {180,180,180}, 
	paletteSize = 250,
	paletteColor = {80,80,80},
	textColor = {20,211,255},
	mode = "Moving",
	tilesets = {},
	currentMap = {
		tileCount = 0,
		grid = {}
	}
	})

function MapCreationHandler:init(tilesize)
	self.tilesize = tilesize or 64
	self.currentTileX = 0
	self.currentTileY = 0
	self.mouseOnValidTile = false
	self.mouseOnPalette = false

	self.currentTileset = 1
	self.currentTile = 1
	self.currentTilePage = 1

	canZoom = (self.mode == "Moving")
end

function MapCreationHandler:loadTilesets()
	local files = love.filesystem.getDirectoryItems("resources/tilesets/")
	for i = 1, #files do
		local filename,_ = files[i]:match("(%a+).(.*)")
		ts = require ("resources.tilesets." .. filename)

		-- We are limiting tilesize to 64 always for this project
		ts.Quads = {}
		local imgw, imgh = ts.image:getDimensions()
		for j = 1, ts.tileWidth do
			for k = 1, ts.tileHeight do
				-- Quads will go left to right, top to bottom
				ts.Quads[#ts.Quads + 1] = love.graphics.newQuad((j-1) * 64, (k-1) * 64, self.tilesize, self.tilesize, imgw, imgh)
			end
		end

		self.tilesets[#self.tilesets + 1] = ts
	end
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

	-- Draw palette and extra text
	love.graphics.setColor(self.paletteColor)
	love.graphics.rectangle("fill", paletteX, paletteY, width, self.paletteSize)
	love.graphics.setColor(self.textColor)
	love.graphics.setNewFont(25)
	love.graphics.print("Palette -", paletteX + 10, paletteY + 10)
	love.graphics.setNewFont(16)
	love.graphics.print("(can only place tiles in the positve quadrant for now)", paletteX + 125, paletteY + 15)
	love.graphics.print("Mode: " .. self.mode .. " (Press 'M' to change)", paletteX + 10, paletteY + 40)
	if self.mouseOnPalette then
		love.graphics.print("Mouse On Palette", paletteX + 10, paletteY + 60)
	else
		love.graphics.print("Mouse Position: " .. self.currentTileX .. "," .. self.currentTileY, paletteX + 10, paletteY + 60)
	end

	love.graphics.setColor(255,255,0)
	love.graphics.print("TS: " .. self.tilesets[self.currentTileset].name .. ", Page: " .. self.currentTilePage .. " / " .. (math.floor((#self.tilesets[self.currentTileset].Quads - 1) / 16) + 1), paletteX + 10, paletteY + 90)

	self:drawTilePalette()
end

function MapCreationHandler:drawTilePalette()
		-- Draw current tileset and tiles
	local tsGridX = 10
	local tsGridY = love.graphics.getHeight() - 138

	-- These will change how big the palette of tiles is. Currently 8x2
	local tsGridWidth = 8
	local tsGridHeight = 2
	local tilesPerPage = tsGridWidth * tsGridHeight


	-- Tiles
	local currentTile = ((self.currentTilePage - 1) * tilesPerPage) + 1
	local breaking = false
	local currentTS = self.tilesets[self.currentTileset]

	love.graphics.setColor(255,255,255,255)
	for i = 1, tsGridHeight do
		for j = 1, tsGridWidth do
			if currentTile > #currentTS.Quads then
				breaking = true
				break
			end
			-- Draw the damn tile

			local x = tsGridX + ((j - 1) * 64)
			local y = tsGridY + ((i-1) * 64)
			love.graphics.draw(currentTS.image, currentTS.Quads[currentTile], x, y)
			currentTile = currentTile + 1
		end
		if breaking then
			break
		end
	end

	-- Draw grid
	love.graphics.setColor(53, 38, 25)

	-- Use two for loops to do this...
	for i = 0, tsGridWidth do
		-- Vertical lines
		love.graphics.line(tsGridX + (i*64), tsGridY, tsGridX + (i*64), tsGridY + (64*tsGridHeight))
	end

	for i = 0, tsGridHeight do
		-- Horizontal lines
		love.graphics.line(tsGridX, tsGridY + (i*64), tsGridX + (64 * tsGridWidth), tsGridY + (i*64))
	end

	-- Highlight current tile
	local ct = ((self.currentTile-1) % 16) + 1
	local row = math.floor(ct / 9)
	ct = ((ct - 1) % 8)
	love.graphics.setColor(255,255,0)
	love.graphics.rectangle("line", tsGridX + (ct * 64), tsGridY + (row * 64), 64, 64)
end

function MapCreationHandler:drawMouse()
	local mx, my = love.mouse.getPosition()
	local mouseX = (mx - x_translate_val) / zoom
	local mouseY = (my - y_translate_val) / zoom
	local drawX = mouseX - (mouseX % self.tilesize)
	local drawY = mouseY - (mouseY % self.tilesize)
	self.currentTileX = (drawX / 64) + 1
	self.currentTileY = (drawY / 64) + 1


	if self.mode == "Editing" then
		love.mouse.setCursor(arrowCursor)
		if not self.mouseOnPalette then
			-- Draw above tile if it is a valid position and what pos it is, or draw that it is not valid
			if drawX < 0 or drawY < 0 then
				love.graphics.setColor(255,0,0)
				love.graphics.rectangle("fill", drawX, drawY, self.tilesize, self.tilesize)
				love.graphics.print("INVALID", drawX, drawY - 20)
				self.mouseOnValidTile = false
			else 
				love.graphics.setColor(255,255,255,100)
				local ts = self.tilesets[self.currentTileset]
				love.graphics.draw(ts.image, ts.Quads[self.currentTile], drawX, drawY)
				love.graphics.setColor(0,255,0)
				love.graphics.print(self.currentTileX .. "," .. self.currentTileY, drawX + 5, drawY - 20)
				self.mouseOnValidTile = true
			end
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

function MapCreationHandler:saveMap()

end

function MapCreationHandler:updateMouseOnPalette()
	local _,y = love.mouse.getPosition()
	if y < love.graphics.getHeight() - self.paletteSize then
		self.mouseOnPalette = false
	else
		self.mouseOnPalette = true
	end
end

function MapCreationHandler:changeTile(updown)
	local currentTS = self.tilesets[self.currentTileset]
	local tilePages = math.floor((#currentTS.Quads - 1) / 16) + 1
	if updown > 0 then
		if ((self.currentTile - 1) % 16) == 0 then
			if tilePages > 1 then
				if self.currentTilePage == 1 then
					self.currentTilePage = tilePages
					self.currentTile = ((tilePages - 1) * 16) + (#currentTS.Quads % 16)
				else
					self.currentTilePage = self.currentTilePage - 1
					self.currentTile = self.currentTilePage * 16
				end
			else
				self.currentTile = #currentTS.Quads
			end
		else
			self.currentTile = self.currentTile - 1
		end
	else
		if tilePages > 1 then
			if (self.currentTile - 1) % 16 == 15 then
				if self.currentTilePage == tilePages then
					self.currentTilePage = 1
					self.currentTile = 1
				else
					self.currentTilePage = self.currentTilePage + 1
					self.currentTile = ((self.currentTilePage - 1) * 16) + 1
				end
			else
				if self.currentTile == #currentTS.Quads then
					self.currentTile = 1
				else
					self.currentTile = self.currentTile + 1
				end
			end
		else
			-- Only one page of tiles
			if self.currentTile == #currentTS.Quads then
				self.currentTile = 1
			else
				self.currentTile = self.currentTile + 1
			end
		end
	end
end

function MapCreationHandler:placeTile()
	-- This should trigger only if the mouse is already in a valid spot


	-- First check to see if there is already space on grid
	if #self.currentMap.grid < self.currentTileY then
		-- Fill in missing tables if there are any
		for i = #self.currentMap.grid + 1, self.currentTileY do
			if self.currentMap.grid[i] == nil then
				self.currentMap.grid[i] = {}
			end
		end
	end

	if #self.currentMap.grid[self.currentTileY] < self.currentTileX then
		-- Fill in missing slots in array with constructor
		for i = #self.currentMap.grid[self.currentTileY] + 1, self.currentTileX - 1 do
			if self.currentMap.grid[self.currentTileY][i] == nil then
				self.currentMap.grid[self.currentTileY][i] = -1
			end
		end
	end

	-- Afterwards, place the tile
	self.currentMap.grid[self.currentTileY][self.currentTileX] = self.currentTile
end

function MapCreationHandler:removeTile()
	-- Make sure the tile exists
	if #self.currentMap.grid >= self.currentTileY then
		if #self.currentMap.grid[self.currentTileY] >= self.currentTileX then
			self.currentMap.grid[self.currentTileY][self.currentTileX] = -1
		end
	end
end

function MapCreationHandler:drawMap()
	love.graphics.setColor(255,255,255,255)
	local ts = self.tilesets[self.currentTileset]
	for i = 1, #self.currentMap.grid do
		for j = 1, #self.currentMap.grid[i] do
			if self.currentMap.grid[i][j] ~= -1 then
				love.graphics.draw(ts.image, ts.Quads[self.currentMap.grid[i][j]], (j-1)*64, (i-1)*64)
			end
		end
	end
end

function MapCreationHandler:getTilesetSize() 
	-- TO CLARIFY, THIS FUNCTION PULLS THE NUMBER OF TILES IN THE SET. NOT THE AMOUNT OF TILES ON SCREEN
	return #self.tilesets[self.currentTileset].Quads
end

function MapCreationHandler:getTileCount()
	local ts = self.tilesets[self.currentTileset]
	local count = 0
	for i = 1, #self.currentMap.grid do
		for j = 1, #self.currentMap.grid[i] do
			if self.currentMap.grid[i][j] ~= -1 then
				count = count + 1
			end
		end
	end
	return count
end