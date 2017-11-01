-- Named: cObject for collisionObject
-- Features:
-- Auto scaling of cObject based on chosen sprite dimensions and chosen width/height
defaultSize = 64

class = require 'libraries.ext.30log'

cObject = class("cObject", {x_vel = 0, y_vel = 0, x_vel_counter = 10, y_vel_counter = 10})

-- Initialization
function cObject:init(id, sprite, speed, x, y, width, height, x_offset, y_offset, rotation)
	self.id = id or "player"
	self.sprite = sprite
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

-- Will return 4 coordinates that the object currently spans. In top-left, top-right, bottom-left, bottom-right order
function cObject:getSpan()
	return 	{	
		{(self.x + self.x_offset) - (self.length / 2), (self.y + self.y_offset) - (self.width / 2)},
		{(self.x + self.x_offset) + (self.length / 2), (self.y + self.y_offset) - (self.width / 2)},
		{(self.x + self.x_offset) - (self.length / 2), (self.y + self.y_offset) + (self.width / 2)},
		{(self.x + self.x_offset) + (self.length / 2), (self.y + self.y_offset) + (self.width / 2)}
	}
end

function cObject:drawHitbox()
	local r,g,b,a = love.graphics.getColor() -- Get old color
	love.graphics.setColor(247, 176, 34)
	love.graphics.rectangle("fill", (self.x - (self.x_offset * self.scaleX)), (self.y - (self.y_offset * self.scaleY)), self.width, self.height)
	love.graphics.setColor(r,g,b,a) -- Reset to old color
end

function cObject:draw()
	love.graphics.draw(self.sprite, self.x, self.y, self.rotation, self.scaleX, self.scaleY, self.x_offset, self.y_offset)
end

function cObject:move()
	self.x = self.x + self.x_vel
	self.y = self.y + self.y_vel
end