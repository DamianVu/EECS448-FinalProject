
Projectile = class("Projectile", {})

function Projectile:init(id, sprite, x, y, width, height, x_vel, y_vel)
	self.id = id
	self.type = "Projectile"
	self.sprite = sprite or circleImg
	self.width = width
	self.height = height
	self.x = x
	self.y = y
	self.x_vel = x_vel
	self.y_vel = y_vel

	self.color = {math.random(0,255), math.random(0,255), math.random(0,255)}

	local imgW, imgH = self.sprite:getDimensions()
	self.x_offset = imgW / 2
	self.y_offset = imgH / 2
	self.scaleX = self.width / imgW
	self.scaleY = self.height / imgH
end

function Projectile:draw()
	love.graphics.setColor(self.color)
	love.graphics.draw(self.sprite, self.x, self.y, 0, self.scaleX, self.scaleY, self.x_offset, self.y_offset)
end

function Projectile:move()
	self.x = self.x + self.x_vel
	self.y = self.y + self.y_vel
end

function Projectile:isOffScreen()
	return self.x > 5000 or self.x < 0 or self.y < 0 or self.y > 5000
end