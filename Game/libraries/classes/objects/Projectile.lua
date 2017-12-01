--- handles projectiles.
Projectile = class("Projectile", {})
-- projectile constructor. Initializes id, sprite, x, y, width, height, x_vel, y_vel, damage, speed, and sourceID.
function Projectile:init(id, sprite, x, y, width, height, x_vel, y_vel, damage, speed, sourceID)
	self.id = id
	self.type = PROJECTILE
	self.sprite = sprite or circleImg
	self.width = width
	self.height = height
	self.x = x
	self.y = y
	self.x_vel = x_vel
	self.y_vel = y_vel
	self.speed = speed or 1

	self.damage = damage or 1

	self.color = {255,0,0}

	local imgW, imgH = self.sprite:getDimensions()
	self.x_offset = imgW / 2
	self.y_offset = imgH / 2
	self.scaleX = self.width / imgW
	self.scaleY = self.height / imgH

	self.sourceID = sourceID
end
-- draws projectile to screen
function Projectile:draw()
	love.graphics.setColor(self.color)
	love.graphics.draw(self.sprite, self.x, self.y, 0, self.scaleX, self.scaleY, self.x_offset, self.y_offset)
end
-- handles projectile movement
function Projectile:move(dt)
	self.x = self.x + (3 * self.x_vel * self.speed * base_speed * dt)
	self.y = self.y + (3 * self.y_vel * self.speed * base_speed * dt)
end
-- detects if projectile is off the map.
function Projectile:isOffScreen()
	return self.x > 5000 or self.x < 0 or self.y < 0 or self.y > 5000
end