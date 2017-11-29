
class = require 'libraries.ext.30log'

MCHModes = {
	[1] = "Moving",
	[2] = "Editing",
	[3] = "Object Manager"
}

MapCreationHandler = class("MapCreationHandler", {
	gridColor = {180,180,180}, 
	paletteSize = 250,
	paletteColor = {80,80,80},
	textColor = {20,211,255},
	objects = {},
	mode = MCHModes[3],
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
	self.mouseOnObjectMenu = false
	self.mouseOnObjectMenuButton = false


	self.objectMenu = {}
	self.objectMenu.borderSize = 40
	self.objectMenu.currentTile = 1
	self.objectMenu.currentTilePage = 1
	self.objectMenu.currentTileset = 1
	self.currentTileset = 1
	self.currentTile = 1
	self.currentTilePage = 1

	canZoom = (self.mode == "Moving")

	self:loadTilesets()
	self:initializeObjectMenuSettings()
end

function MapCreationHandler:loadTilesets()
	local files = love.filesystem.getDirectoryItems("resources/tilesets/")
	for i = 1, #files do
		local filename,_ = files[i]:match("(%a+).(.*)")
		ts = require ("resources.tilesets." .. filename)

		-- We are limiting tilesize to 64 always for this project
		ts.Quads = {}
		local imgw, imgh = ts.image:getDimensions()
		local currentNum = 1
		local breaking = false
		for j = 1, ts.Height do
			for k = 1, ts.Width do
				if currentNum > ts.size then
					breaking = true
					break
				else
					currentNum = currentNum + 1
				end
				-- Quads will go left to right, top to bottom
				ts.Quads[#ts.Quads + 1] = love.graphics.newQuad((k-1) * 64, (j-1) * 64, self.tilesize, self.tilesize, imgw, imgh)
			end
			if breaking then break end
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

	local extraText
	if self.mode == MCHModes[3] then
		extraText = " (Click off the menu to close)"
	else
		extraText = " (Press 'M' to change)"
	end
	love.graphics.print("Mode: " .. self.mode .. extraText, paletteX + 10, paletteY + 40)
	if self.mouseOnPalette then
		love.graphics.print("Mouse On Palette", paletteX + 10, paletteY + 60)
	else
		love.graphics.print("Mouse Position: " .. self.currentTileX .. "," .. self.currentTileY, paletteX + 10, paletteY + 60)
	end

	love.graphics.setColor(255,255,0)
	local objString

	if #self.objects == 0 then
		objString = "PLEASE CREATE AN OBJECT"
	else
		objString = "Object " .. self.currentTile .. ": Collision = " .. tostring(self.objects[self.currentTile].collision)
	end

	love.graphics.print(objString, paletteX + 10, paletteY + 90)

	love.graphics.setColor(150,150,150)
	love.graphics.rectangle("fill", width - 170, height - 60, 150, 38)
	love.graphics.setColor(0,0,225)
	love.graphics.print("Manage Objects", width - 160, height - 50)

	love.graphics.setColor(150,150,150)
	love.graphics.rectangle("fill", width - 170, paletteY + 20, 150, 38)
	love.graphics.setColor(0,0,225)
	love.graphics.print("Save Map", width - 160, paletteY + 30)

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
	local currentObj = ((self.currentTilePage - 1) * tilesPerPage) + 1
	local breaking = false

	love.graphics.setColor(255,255,255,255)
	for i = 1, tsGridHeight do
		for j = 1, tsGridWidth do
			if currentObj > #self.objects then
				breaking = true
				break
			end

			local x = tsGridX + ((j - 1) * 64)
			local y = tsGridY + ((i-1) * 64)
			love.graphics.draw(self.tilesets[self.objects[currentObj].tileset].image, self.tilesets[self.objects[currentObj].tileset].Quads[self.objects[currentObj].tile], x, y)
			currentObj = currentObj + 1
		end
		if breaking then break end
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
		if not self.mouseOnPalette then
			-- Draw above tile if it is a valid position and what pos it is, or draw that it is not valid
			if drawX < 0 or drawY < 0 or #self.objects == 0 then
				love.graphics.setColor(255,0,0)
				love.graphics.rectangle("fill", drawX, drawY, self.tilesize, self.tilesize)
				love.graphics.print("INVALID", drawX, drawY - 20)
				self.mouseOnValidTile = false
			else 
				love.graphics.setColor(255,255,255,100)
				local ts = self.tilesets[self.objects[self.currentTile].tileset]
				love.graphics.draw(ts.image, ts.Quads[self.objects[self.currentTile].tile], drawX, drawY)
				love.graphics.setColor(0,255,0)
				love.graphics.print(self.currentTileX .. "," .. self.currentTileY, drawX + 5, drawY - 20)
				self.mouseOnValidTile = true
			end
		end
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
	local mapTable = love.filesystem.getDirectoryItems("maps")
	data = "Map = {\n\tname = \"test\",\n\tstartingLocations = {"

	data = data .. "\n\t},\n\tgrid = {"

	for i = 1, #self.currentMap.grid do
		data = data .. "\n\t\t{"
		for j = 1, #self.currentMap.grid[i] do
			data = data .. self.currentMap.grid[i][j]
			if j ~= #self.currentMap.grid[i] then data = data .. "," end
		end
		data = data .. "}"
		if i ~= #self.currentMap.grid then data = data .. "," end
	end

	data = data .. "\n\t},\n\ttilesets = {"

	local listNames = self:getCurrentTilesetNames()

	for i = 1, #listNames do
		data = data .. "\n\t\t\"" .. listNames[i] .. "\""
		if i ~= #listNames then data = data .. "," end
	end

	data = data .. "\n\t},\n\tobjects = {"

	for i = 1, #self.objects do
		data = data .. "\n\t\t{" .. self:findCurrentIndex(i) .. ", " .. self.objects[i].tile .. "}"

		if i ~= #self.objects then data = data .. "," end
	end

	data = data .. "\n\t},\n\tterrain = {"

	local terrain = self:generateTerrain()

	for i = 1, #terrain do
		data = data .. "\n\t\t{" .. terrain[i][1] .. ", " ..  terrain[i][2] .. ", " ..  terrain[i][3] .. ", " ..  terrain[i][4] .. "}"
		if i ~= #terrain then data = data .. "," end
	end

	data = data .. "\n\t}\n}"

	data = data .. "\n\nreturn Map"
	love.filesystem.write("maps/map" .. #mapTable + 1 .. ".lua", data)
end

-- love.graphics.rectangle("fill", width - 170, height - 60, 150, 38)
function MapCreationHandler:updateMouseOnPalette()
	local x,y = love.mouse.getPosition()
	local w,h = love.graphics.getDimensions()

	self.mouseOnPalette = y > h - self.paletteSize
	self.mouseOnObjectMenuButton = x > w - 170 and x < w - 20 and y > h - 60 and y < h - 22 
	self.mouseOnSaveButton = x > w - 170 and x < w - 20 and y > h - self.paletteSize + 20 and y < h - self.paletteSize + 58
end

function MapCreationHandler:changeTile(updown)
	local currentTS = self.tilesets[self.currentTileset]
	local tilePages = math.floor((#currentTS.Quads - 1) / 16) + 1
	if updown > 0 then
		if ((self.currentTile - 1) % 16) == 0 then
			if tilePages > 1 then
				if self.currentTilePage == 1 then
					self.currentTilePage = tilePages
					self.currentTile = (tilePages * 16) + (#currentTS.Quads % 16)
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

function MapCreationHandler:changePage(prev)
	if self.mode == MCHModes[1] or self.mode == MCHModes[2] then
		if self:getTilesetSize() <= 16 then return end
		local tilePages = (math.floor((#self.tilesets[self.currentTileset].Quads - 1) / 16) + 1)
		if prev then
			if self.currentTilePage == 1 then
				self.currentTilePage = tilePages
				self.currentTile = (tilePages * 16) + (#self.tilesets[self.currentTileset].Quads % 16)
			else
				self.currentTilePage = self.currentTilePage - 1
				self.currentTile = 16
			end
		else
			self.currentTile = 1
			if self.currentTilePage == tilePages then
				self.currentTilePage = 1
			else
				self.currentTilePage = self.currentTilePage + 1
			end
		end
	elseif self.mode == MCHModes[3] then
		-- Change object page
		local maxPages = math.floor((self.tilesets[self.objectMenu.currentTileset].size - 1) / self.objectMenu.tilesPerPage) + 1

		if prev then
			if self.objectMenu.currentTilePage == 1 then
				self.objectMenu.currentTilePage = maxPages
			else
				self.objectMenu.currentTilePage = self.objectMenu.currentTilePage - 1
			end
		else
			if self.objectMenu.currentTilePage == maxPages then
				self.objectMenu.currentTilePage = 1
			else
				self.objectMenu.currentTilePage = self.objectMenu.currentTilePage + 1
			end
		end

		self.objectMenu.currentTile = 1
	end
end

function MapCreationHandler:changeTileset(prev)
	if self.mode == MCHModes[3] then
		if prev then
			if self.objectMenu.currentTileset == 1 then
				self.objectMenu.currentTileset = #self.tilesets
			else
				self.objectMenu.currentTileset = self.objectMenu.currentTileset - 1
			end
		else
			if self.objectMenu.currentTileset == #self.tilesets then
				self.objectMenu.currentTileset = 1
			else
				self.objectMenu.currentTileset = self.objectMenu.currentTileset + 1
			end
		end
		self.objectMenu.currentTile = 1
		self.objectMenu.currentTilePage = 1
	end
end

function MapCreationHandler:placeTile()
	-- This should trigger only if the mouse is already in a valid spot

	if #self.objects == 0 then return end


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
	for i = 1, #self.currentMap.grid do
		for j = 1, #self.currentMap.grid[i] do
			local objNum = self.currentMap.grid[i][j]
			if objNum ~= -1 then
				local ts = self.tilesets[self.objects[objNum].tileset]
				love.graphics.draw(ts.image, ts.Quads[self.objects[objNum].tile], (j-1)*64, (i-1)*64)
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

function MapCreationHandler:resetObjectMenu()
	self.currentTileset = 1
	self.currentTile = 1
	self.currentTilePage = 1
end

function MapCreationHandler:initializeObjectMenuSettings()
	-- This will draw the frame of the menu
	local w,h = love.graphics.getDimensions()
	h = h - self.paletteSize

	-- Now w,h is essentially the size of the window without the palette
	-- Let's say we want our menu to be a rectangle with the width 2 times its height
	-- The restraining factor is probably going to be the height based on common screen sizes - self.paletteSize

	self.objectMenu.menuHeight = h * .75
	self.objectMenu.menuWidth = self.objectMenu.menuHeight * 2

	local centerx = w/2
	local centery = h/2

	self.objectMenu.drawx = centerx - (self.objectMenu.menuWidth / 2)
	self.objectMenu.drawy = centery - (self.objectMenu.menuHeight / 2)

	-- Col size should be the menu height - (2 * borderSize) all over 64 rounded down


	self.objectMenu.maxRowSize = math.floor(((self.objectMenu.menuWidth - (2 * self.objectMenu.borderSize)) / 2) / 64) -- Max num of tiles per row
	self.objectMenu.maxColSize = math.floor((self.objectMenu.menuHeight - (2 * self.objectMenu.borderSize)) / 64)-- Max num of tiles per col

	self.objectMenu.tilesPerPage = self.objectMenu.maxRowSize * self.objectMenu.maxColSize

	-- We want to center the tilemap vertically as well.
	local offsetTileY = (self.objectMenu.menuHeight - (64 * self.objectMenu.maxColSize)) / 2

	self.objectMenu.tileDrawX = self.objectMenu.drawx + self.objectMenu.borderSize
	self.objectMenu.tileDrawY = self.objectMenu.drawy + offsetTileY

	self.objectMenu.rowLineLength = self.objectMenu.maxRowSize * 64
	self.objectMenu.colLineLength = self.objectMenu.maxColSize * 64

	self.objectMenu.collision = false

	self.objectMenu.createButtonWidth = 100
	self.objectMenu.createButtonHeight = 50
	self.objectMenu.createButtonMargin = 20

	self.objectMenu.cbDrawX = self.objectMenu.drawx + self.objectMenu.menuWidth - self.objectMenu.createButtonWidth - self.objectMenu.createButtonMargin
	self.objectMenu.cbDrawY = self.objectMenu.drawy + self.objectMenu.menuHeight - self.objectMenu.createButtonHeight - self.objectMenu.createButtonMargin
	
	self.objectMenu.colButtonWidth = 120
	self.objectMenu.colButtonHeight = 50
	self.objectMenu.colButtonMargin = 30

	self.objectMenu.colDrawX = self.objectMenu.tileDrawX + 64 * self.objectMenu.maxRowSize + self.objectMenu.colButtonMargin
	self.objectMenu.colDrawY = self.objectMenu.tileDrawY
end

function MapCreationHandler:objectMenuClickAction(x,y)
	-- Check if mouse is in the tileset
	if x > self.objectMenu.tileDrawX and x < self.objectMenu.tileDrawX + self.objectMenu.maxRowSize * 64 and y > self.objectMenu.tileDrawY and y < self.objectMenu.tileDrawY + self.objectMenu.maxColSize * 64 then

		-- So we are in the tileset. Find out how many tiles are in the current page?
		local numTilesOnPage = self.objectMenu.tilesPerPage
		local totalTiles = self.tilesets[self.objectMenu.currentTileset].size

		if self.objectMenu.currentTilePage * self.objectMenu.tilesPerPage > self.tilesets[self.objectMenu.currentTileset].size then
			local a = totalTiles
			local b = self.objectMenu.tilesPerPage

			numTilesOnPage = a - math.floor(a/b) * b
		end

		-- Figure out which tile we have clicked
		local currentTile = 1
		local breaking = false
		for i = 1, self.objectMenu.maxColSize do
			for j = 1, self.objectMenu.maxRowSize do
				if currentTile > numTilesOnPage then
					breaking = true
					break
				end
				if x < self.objectMenu.tileDrawX + j * 64 and y < self.objectMenu.tileDrawY + i * 64 then
					-- We have our tile
					self.objectMenu.currentTile = currentTile
					breaking = true
					break
				end
				currentTile = currentTile + 1
			end
			if breaking then break end
		end
	elseif x > self.objectMenu.colDrawX and x < self.objectMenu.colDrawX + self.objectMenu.colButtonWidth and y > self.objectMenu.colDrawY and y < self.objectMenu.colDrawY + self.objectMenu.colButtonHeight then

		self.objectMenu.collision = not self.objectMenu.collision

	elseif x > self.objectMenu.cbDrawX and x < self.objectMenu.cbDrawX + self.objectMenu.createButtonWidth and y > self.objectMenu.cbDrawY and y < self.objectMenu.cbDrawY + self.objectMenu.createButtonHeight then
		self:createObject()
	end
end

function MapCreationHandler:drawObjectMenu()
	local currentTS = self.tilesets[self.objectMenu.currentTileset]
	
	love.graphics.setColor(200,200,200,255)
	love.graphics.rectangle("fill", self.objectMenu.drawx, self.objectMenu.drawy, self.objectMenu.menuWidth, self.objectMenu.menuHeight)

	love.graphics.setNewFont(20)
	love.graphics.setColor(0,0,255)
	local maxPages = math.floor((currentTS.size + 1) / self.objectMenu.tilesPerPage) + 1
	love.graphics.print("Tileset " .. self.objectMenu.currentTileset .. ": " .. currentTS.name .. " (" .. self.objectMenu.currentTilePage .. "/" .. maxPages .. ")", self.objectMenu.tileDrawX, self.objectMenu.tileDrawY - 22)

	love.graphics.setNewFont(16)
	love.graphics.print("Use '<' and '>' to change pages", self.objectMenu.tileDrawX, self.objectMenu.tileDrawY + (64 * self.objectMenu.maxColSize) + 3)
	love.graphics.print("Use 'n' and 'm' to change tilesets", self.objectMenu.tileDrawX, self.objectMenu.tileDrawY + (64 * self.objectMenu.maxColSize) + 20)
	

	-- Tiles
	local currentTile = ((self.objectMenu.currentTilePage - 1) * self.objectMenu.tilesPerPage) + 1
	local breaking = false

	love.graphics.setColor(255,255,255,255)
	for i = 1, self.objectMenu.maxColSize do
		for j = 1, self.objectMenu.maxRowSize do
			if currentTile > #currentTS.Quads then
				breaking = true
				break
			end
			-- Draw the damn tile

			local x = self.objectMenu.tileDrawX + ((j - 1) * 64)
			local y = self.objectMenu.tileDrawY + ((i - 1) * 64)
			love.graphics.draw(currentTS.image, currentTS.Quads[currentTile], x, y)
			currentTile = currentTile + 1
		end
		if breaking then
			break
		end
	end







	love.graphics.setColor(125,45,0)
	for i = 0, self.objectMenu.maxRowSize do
		local x = self.objectMenu.tileDrawX + (64 * i)
		love.graphics.line(x, self.objectMenu.tileDrawY, x, self.objectMenu.tileDrawY + self.objectMenu.colLineLength)
	end
	for i = 0, self.objectMenu.maxColSize do
		local y = self.objectMenu.tileDrawY + (64 * i)
		love.graphics.line(self.objectMenu.tileDrawX, y, self.objectMenu.tileDrawX + self.objectMenu.rowLineLength, y)
	end


	-- Draw selected tile
	local x,y
	local counter = 1
	breaking = false
	for i = 1, self.objectMenu.maxColSize do
		for j = 1, self.objectMenu.maxRowSize do
			if counter > currentTS.size then
				breaking = true
				break
			end
			if counter == self.objectMenu.currentTile then
				x = j
				y = i
			end
			counter = counter + 1
		end
		if breaking then break end
	end

	love.graphics.setColor(255,255,0)
	love.graphics.rectangle("line", self.objectMenu.tileDrawX + (x-1) * 64, self.objectMenu.tileDrawY + (y-1)*64, 64, 64)

	-- Draw menu buttons

	love.graphics.setColor(160,160,160,255)
	love.graphics.rectangle("fill", self.objectMenu.cbDrawX, self.objectMenu.cbDrawY, self.objectMenu.createButtonWidth, self.objectMenu.createButtonHeight)

	love.graphics.setColor(self.textColor)
	love.graphics.setNewFont(24)
	love.graphics.print("Create", self.objectMenu.cbDrawX + 10, self.objectMenu.cbDrawY + 10)

	-- Draw Settings

	-- Collision Button

	love.graphics.setColor(160,160,160)
	love.graphics.rectangle("fill", self.objectMenu.colDrawX, self.objectMenu.colDrawY, self.objectMenu.colButtonWidth, self.objectMenu.colButtonHeight)

	if self.objectMenu.collision then
		love.graphics.setColor(0,255,0)
	else
		love.graphics.setColor(255,0,0)
	end
	love.graphics.print("Collision", self.objectMenu.colDrawX + 10, self.objectMenu.colDrawY + 10)

end

function MapCreationHandler:updateMouseOnObjectMenu()
	local x,y = love.mouse.getPosition()

	if x >= self.objectMenu.drawx and x <= self.objectMenu.drawx + self.objectMenu.menuWidth and y >= self.objectMenu.drawy and y <= self.objectMenu.drawy + self.objectMenu.menuHeight then
		self.mouseOnObjectMenu = true
	else
		self.mouseOnObjectMenu = false
	end

end

function MapCreationHandler:createObject()
	if self:isUnique(self.objectMenu.currentTileset, self.objectMenu.currentTile, self.objectMenu.collision) then 
		self.objects[#self.objects + 1] = {
			tileset = self.objectMenu.currentTileset,
			tile = self.objectMenu.currentTile,
			collision = self.objectMenu.collision
		}
	end
end

function MapCreationHandler:isUnique(ts, tile, col)
	for i = 1, #self.objects do
		if ts == self.objects[i].tileset and tile == self.objects[i].tile and col == self.objects[i].collision then
			return false
		end
	end
	return true
end

function MapCreationHandler:getCurrentTilesetNames()
	local names = {}
	for i = 1, #self.objects do
		local currentTSName = self.tilesets[self.objects[i].tileset].name
		if not contains(names, currentTSName) then
			names[#names + 1] = currentTSName
		end
	end
	return names
end

function MapCreationHandler:findCurrentIndex(objectIndex)
	local tsNames = self:getCurrentTilesetNames()
	local actualName = self.tilesets[self.objects[objectIndex].tileset].name
	for i = 1, #tsNames do
		if actualName == tsNames[i] then return i end
	end
end

function MapCreationHandler:generateTerrain()
	-- Function will return table of terrain objects
	local terrain = {}

	local tempTable = {}

	local grid = self.currentMap.grid

	local prevCol = false

	local startPoint

	-- Create left to right obstacles

	for i = 1, #grid do
		for j = 1, #grid[i] do
			if grid[i][j] ~= -1 and self.objects[grid[i][j]].collision then
				if not prevCol then
					startPoint = j
				end
				prevCol = true
			else
				if prevCol then
					-- Finalize the terrain object
					tempTable[#tempTable + 1] = {startPoint, i, j - startPoint, 1}
				end

				prevCol = false
			end

			if j == #grid[i] and prevCol then
				-- Finalize terrain object
				tempTable[#tempTable + 1] = {startPoint, i, j - (startPoint - 1), 1}
				prevCol = false
			end
		end
	end

	-- Combine top down obstacles
	local found = true

	while found do
		found = false

		local tempTopDownTable = {}

		local startItem
		local prevItem
		local breaking = false

		for i = 1, #tempTable do
			-- Check if there is matches below it then move on...
			startItem = tempTable[i]
			workingHeight = startItem[4]

			local unmatched = {}

			for j = i + 1, #tempTable do
				if startItem[1] == tempTable[j][1] and startItem[3] == tempTable[j][3] and startItem[2] + workingHeight == tempTable[j][2] then
					found = true
					workingHeight = workingHeight + tempTable[j][4]
				else
					unmatched[#unmatched + 1] = tempTable[j]
				end
			end

			if found then 
				-- Add current working vertical piece and break
				local x, y, w, h = unpack(startItem)
				h = h + workingHeight - 1

				tempTopDownTable[#tempTopDownTable + 1] = {x,y,w,h}

				for k = 1, #unmatched do
					tempTopDownTable[#tempTopDownTable + 1] = unmatched[k]
				end

				breaking = true

			else
				-- Couldnt find any pieces below this one
				tempTopDownTable[#tempTopDownTable + 1] = startItem
			end

			if breaking then
				tempTable = tempTopDownTable
				break
			end
		end
	end

	terrain = tempTable


	return terrain

end

function contains(table, string)
	for i = 1, #table do
		if table[i] == string then return true end
	end
	return false
end
