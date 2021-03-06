--- defines enemy.
Enemy = class("Enemy", {})
-- Enemy object creator. Handles enemy id, sprite, color, speed, bumpFactor, x, y, width, height, health, damage, and chaseObj.
function Enemy:init(id, sprite, color, speed, bumpFactor, x, y, width, height, health, damage, chaseObj)
	self.id = id
	self.type = ENEMY
	self.bumpFactor = bumpFactor or 1
	self.sprite = sprite or enemyImg
	self.color = color or {255,0,0,255}
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
	self.chaseObj = chaseObj or GH.player
	self.health = health or 10
	self.maxHealth = self.health
	self.damage = damage or 2

	self.showHealth = false
	self.hpBarTimer = 0
	self.hpBarTimeout = 0

	self.paused = false
	self.created = true
	self.createdTime = 0
	self.createTimer = 1.5
	self.defaultPauseDuration = .3 -- Amount of time to pause before attempting to move again
end
-- prints enemy to screen and handles enemy health bar.
function Enemy:draw()
	love.graphics.setColor(self.color)
	love.graphics.draw(self.sprite, self.x, self.y, self.rotation, self.scaleX, self.scaleY, self.x_offset, self.y_offset)

	if self.showHealth then
		local maxBarWidth = self.width - 2
		local barHeight = 5

		love.graphics.setColor(255,0,0) -- red
		local healthBarWidth = maxBarWidth * (self.health / self.maxHealth)
		if healthBarWidth < 1 then healthBarWidth = 1 end
		love.graphics.rectangle("fill", self.x - maxBarWidth/2, self.y - (self.height/2 + barHeight + 4), healthBarWidth, barHeight)
	end
end

-- draws enemy hitbox.
function Enemy:drawHitbox()
	love.graphics.setColor(255,0,0)
	love.graphics.rectangle("line", self.x - (self.x_offset * self.scaleX), self.y - (self.x_offset * self.scaleY), self.width, self.height)
end

-- creates enemy movement.
function Enemy:move(dt)
	if self.paused then
		self.pauseTime = self.pauseTime + dt
		if self.pauseTime > self.pauseDuration then self.paused = false end
	elseif self.created then
		self.createdTime = self.createdTime + dt

		local opacity = self.createdTime / self.createTimer * 255
		if opacity < 75 then
			opacity = 75
		end

		self.color = {255,255,255,opacity}
		if self.createdTime > self.createTimer then
			self.created = false
		end
	else
		self.x = self.x + (self.x_vel * base_speed * dt)
		self.y = self.y + (self.y_vel * base_speed * dt)
	end
end
-- pauses enemy.
function Enemy:pause(newDuration)
	self.pauseDuration = newDuration or self.defaultPauseDuration
	self.pauseTime = 0
	self.paused = true
end

-- handles making the enemy chase the player.
function Enemy:chase()
	local angle = math.atan2(self.chaseObj.y - self.y, self.chaseObj.x - self.x)

	self.x_vel = self.speed * math.cos(angle)
	self.y_vel = self.speed * math.sin(angle)
end
-- handles taking damage when enemy is hit with projectile.
function Enemy:takeDamage(damage)
	self.health = self.health - damage
	self.hpBarTimeout = 2
	self.hpBarTimer = 0
	self.showHealth = true
end
-- handles enemy health bar printing
function Enemy:updateShowHealth(dt)
	self.hpBarTimer = self.hpBarTimer + dt
	if self.hpBarTimer > self.hpBarTimeout then
		self.showHealth = false
	end
end
-- detects if the enemy is dead.
function Enemy:isDead()
	return self.health <= 0
end
