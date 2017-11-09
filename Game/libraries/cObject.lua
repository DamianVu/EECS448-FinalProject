---
-- This module defines a collisionObject for us. 
-- It utilizes the 30log library


defaultSize = 64

class = require 'libraries.ext.30log'
cObject = class("cObject", {x_vel = 0, y_vel = 0, x_vel_counter = 10, y_vel_counter = 10})

--- Initialization (default constructor)
function cObject:init(id, sprite, color, speed, x, y, width, height, x_offset, y_offset, rotation)
	self.id = id or "player"
	self.sprite = sprite
	math.randomseed(os.time())
	self.color = color or {math.random(0,255), math.random(0,255), math.random(0,255)}
	self.speed = speed or 1
	self.x = x
	self.y = y
	self.width = width or defaultSize
	self.height = height or defaultSize
	local imgW, imgH = self.sprite:getDimensions()
	self.x_offset = x_offset or (imgW / 2)
	self.y_offset = y_offset or (imgH / 2)
	self.scaleX = self.width / imgW
	self.scaleY = self.height / imgH
	self.rotation = rotation or 0
end

--- Span function.
-- Will return 4 coordinates that the object currently spans. In top-left, top-right, bottom-left, bottom-right order
function cObject:getSpan()
	local spanList = CoordinateList()

	local origin, tileWidth, tileHeight = MH:getCurrentMapDimensions()

	local startx,starty = unpack(origin)

	spanList:add({math.floor((self.x - (self.x_offset * self.scaleX) + startx) / tileWidth) + 1, math.floor((self.y - (self.y_offset * self.scaleY) + starty) / tileHeight) + 1})
	spanList:add({math.floor((self.x + (self.x_offset * self.scaleX) + startx) / tileWidth) + 1, math.floor((self.y - (self.y_offset * self.scaleY) + starty) / tileHeight) + 1})
	spanList:add({math.floor((self.x - (self.x_offset * self.scaleX) + startx) / tileWidth) + 1, math.floor((self.y + (self.y_offset * self.scaleY) + starty) / tileHeight) + 1})
	spanList:add({math.floor((self.x + (self.x_offset * self.scaleX) + startx) / tileWidth) + 1, math.floor((self.y + (self.y_offset * self.scaleY) + starty) / tileHeight) + 1})
	return spanList
end

--- Draws a hitbox for the player
function cObject:drawHitbox()
	local r,g,b,a = love.graphics.getColor() -- Get old color
	love.graphics.setColor(247, 176, 34)
	love.graphics.rectangle("fill", (self.x - (self.x_offset * self.scaleX)), (self.y - (self.y_offset * self.scaleY)), self.width, self.height)
	love.graphics.setColor(r,g,b,a) -- Reset to old color
end

--- Draws player on screen
function cObject:draw()
	love.graphics.setColor(self.color)
	love.graphics.draw(self.sprite, self.x, self.y, self.rotation, self.scaleX, self.scaleY, self.x_offset, self.y_offset)
end

--- Moves player according to their velocity
function cObject:move()
	self.x = self.x + self.x_vel
	self.y = self.y + self.y_vel
end

--- This function should be used for enemies to chase global player
function cObject:chase(dt)
	local diffx = player.x - self.x
	local diffy = player.y - self.y

	

	self.x_vel = diffx * self.speed * base_speed * dt
	self.y_vel = diffy * self.speed * base_speed * dt
end