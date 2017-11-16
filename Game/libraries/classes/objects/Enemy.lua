
Enemy = class("Enemy", {})

function Enemy:init(id, sprite, color, speed, bumpFactor, x, y, width, height, health, chaseObj)
	self.id = id
	self.type = ENEMY
	self.bumpFactor = bumpFactor or 1
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

	self.paused = false
	self.defaultPauseDuration = .3 -- Amount of time to pause before attempting to move again
end

function Enemy:draw()
	love.graphics.setColor(self.color)
	love.graphics.draw(self.sprite, self.x, self.y, self.rotation, self.scaleX, self.scaleY, self.x_offset, self.y_offset)
end

function Enemy:drawHitbox()
	love.graphics.setColor(255,0,0)
	love.graphics.rectangle("line", self.x - (self.x_offset * self.scaleX), self.y - (self.x_offset * self.scaleY), self.width, self.height)
end

function Enemy:move(dt)
	if self.paused then
		self.pauseTime = self.pauseTime + dt
		if self.pauseTime > self.pauseDuration then self.paused = false end
	else
		self.x = self.x + (self.x_vel * base_speed * dt)
		self.y = self.y + (self.y_vel * base_speed * dt)
	end
end

function Enemy:pause(newDuration)
	self.pauseDuration = newDuration or self.defaultPauseDuration
	self.pauseTime = 0
	self.paused = true
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