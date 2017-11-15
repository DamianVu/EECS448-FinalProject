
Player = class("Player", {x_vel = 0, y_vel = 0})

function Player:init(id, sprite, color, speed, x, y, width, height)
	self.id = id
	self.type = PLAYER
	self.sprite = sprite or spriteImg
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

function Player:move(dt, direction)
	if direction == 1 then
			self.y = self.y - (self.speed * base_speed * dt)
	elseif direction == 2 then
			self.x = self.x + (self.speed * base_speed * dt)
	elseif direction == 3 then
			self.y = self.y + (self.speed * base_speed * dt)
	elseif direction == 4 then
			self.x = self.x - (self.speed * base_speed * dt)
	end
end