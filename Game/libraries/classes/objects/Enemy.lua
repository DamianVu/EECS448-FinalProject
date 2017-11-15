
Enemy = class("Enemy", {})

function Enemy:init(id, sprite, color, speed, x, y, width, height, health, chaseObj)
	self.id = id
	self.type = "Enemy"
	self.sprite = sprite or enemyImg
	self.color = color or {math.random(0,255), math.random(0,255), math.random(0,255)}
	self.speed = speed or 0 -- 0 means stationary
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
	self.chaseObj = chaseObj or player
	self.health = health or 10
end

function Enemy:draw()
	love.graphics.setColor(self.color)
	love.graphics.draw(self.sprite, self.x, self.y, self.rotation, self.scaleX, self.scaleY, self.x_offset, self.y_offset)
end

function Enemy:drawHitbox()
	love.graphics.setColor(255,0,0)
	love.graphics.rectangle("line", self.x - (self.x_offset * self.scaleX), self.y - (self.x_offset * self.scaleY), self.width, self.height)
end

function Enemy:move()
	self.x = self.x + self.x_vel
	self.y = self.y + self.y_vel
end

function Enemy:chase()
	local angle = math.atan2(self.chaseObj.y - self.y, self.chaseObj.x - self.x)

	self.x_vel = self.speed * math.cos(angle)
	self.y_vel = self.speed * math.sin(angle)
end

function Enemy:takeDamage(damage)
	self.health = self.health - damage
end

function Enemy:isDead()
	return self.health <= 0
end