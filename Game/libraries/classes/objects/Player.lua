
Player = class("Player", {x_vel = 0, y_vel = 0, x_vel_slowdown = 10, y_vel_slowdown = 10})

function Player:init(id, sprite, color, speed, x, y, width, height, rotation)
	self.id = id
	self.type = "Player"
	self.sprite = sprite or love.graphics.newImage('images/sprites/player.png')
	self.color = color or {math.random(0,255), math.random(0,255), math.random(0,255)}
	self.speed = speed or 1
	self.x = x
	self.y = y
	self.width = width or 32
	self.height = height or 32
	local imgW, imgH = self.sprite:getDimensions()
	self.x_offset = x_offset or (imgW / 2)
	self.y_offset = y_offset or (imgH / 2)
	self.scaleX = self.width / imgW
	self.scaleY = self.height / imgH
	self.rotation = rotation or 0
end

function Player:draw()
	love.graphics.setColor(self.color)
	love.graphics.draw(self.sprite, self.x, self.y, self.rotation, self.scaleX, self.scaleY, self.x_offset, self.y_offset)
end

function Player:drawHitbox()
	love.graphics.setColor(255,0,0)
	love.graphics.rectangle("line", self.x - (self.x_offset * self.scaleX), self.y - (self.x_offset * self.scaleY), self.width, self.height)
end

function Player:move()
	self.x = self.x + self.x_vel
	self.y = self.y + self.y_vel
end