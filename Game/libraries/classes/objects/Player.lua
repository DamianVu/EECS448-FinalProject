
Player = class("Player", {x_vel = 0, y_vel = 0})

function Player:init(id, sprite, color, speed, health, x, y, width, height)
	self.id = id
	self.type = PLAYER
	self.sprite = sprite or spriteImg
	self.color = color or {math.random(0,255), math.random(0,255), math.random(0,255), 255}
	self.currentColor = self.color
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
	self.movementEnabled = true

	self.immune = false
	self.immuneTimer = 2 -- How long the player stays immune after collision
	self.immuneTime = 0

	self.bumpDuration = .15

	self.maxHP = health
	self.health = self.maxHP

	self.attackDelay = false
	self.attackTimer = 0
	self.attackTimeout = 0


	self.inventory = {}
	self.equipment = {weapon = 3}
end

function Player:load(file)

end

function Player:draw()
	love.graphics.setColor(self.currentColor)
	love.graphics.draw(self.sprite, self.x, self.y, self.rotation, self.scaleX, self.scaleY, self.x_offset, self.y_offset)
end

function Player:drawHitbox()
	love.graphics.setColor(255,0,0)
	love.graphics.rectangle("line", self.x - (self.x_offset * self.scaleX), self.y - (self.x_offset * self.scaleY), self.width, self.height)
end

function Player:move(dt, direction)
	if self.movementEnabled then
		if direction == 1 then
			self.y = self.y - (self.speed * base_speed * dt)
		elseif direction == 2 then
			self.x = self.x + (self.speed * base_speed * dt)
		elseif direction == 3 then
			self.y = self.y + (self.speed * base_speed * dt)
		elseif direction == 4 then
			self.x = self.x - (self.speed * base_speed * dt)
		end
	else
		-- Bump should always be for a constant time (say half a second?)
		-- Bump factor should change the distance you bump.
		self.x = self.x + (self.x_vel * self.speed * base_speed * dt * 2) -- 2 so that we bump at 2x our speed?
		self.y = self.y + (self.y_vel * self.speed * base_speed * dt * 2)
		self.bumpTime = self.bumpTime + dt
		if self.bumpTime > self.bumpDuration then self.movementEnabled = true end
	end
end

function Player:updateImmunity(dt)
	self.immuneTime = self.immuneTime + dt
	if self.immuneTime > self.immuneTimer then
		-- No longer immune. Change color back to normal
		self.immune = false
		self.currentColor = self.color
		self.immuneTime = 0
	else
		local r,g,b = unpack(self.currentColor)
		self.currentColor = {r,g,b, 50}
	end
end

function Player:bump(angle, bumpFactor)
	self.angle = angle -- No point in keeping track of it really... Maybe later
	self.x_vel = math.cos(angle)
	self.y_vel = math.sin(angle)
	self.bumpFactor = bumpFactor

	self.bumpTime = 0 -- Resets counter to 0
	self.movementEnabled = false

	self.immmuneTime = 0
	self.immune = true

end

--- Span function.
-- Will return 4 coordinates that the object currently spans. In top-left, top-right, bottom-left, bottom-right order
function Player:getSpan()
	local spanList = CoordinateList()

	local origin, tileWidth, tileHeight = MH:getCurrentMapDimensions()

	local startx,starty = unpack(origin)

	spanList:add({math.floor((self.x - (self.x_offset * self.scaleX) + startx) / tileWidth) + 1, math.floor((self.y - (self.y_offset * self.scaleY) + starty) / tileHeight) + 1})
	spanList:add({math.floor((self.x + (self.x_offset * self.scaleX) + startx) / tileWidth) + 1, math.floor((self.y - (self.y_offset * self.scaleY) + starty) / tileHeight) + 1})
	spanList:add({math.floor((self.x - (self.x_offset * self.scaleX) + startx) / tileWidth) + 1, math.floor((self.y + (self.y_offset * self.scaleY) + starty) / tileHeight) + 1})
	spanList:add({math.floor((self.x + (self.x_offset * self.scaleX) + startx) / tileWidth) + 1, math.floor((self.y + (self.y_offset * self.scaleY) + starty) / tileHeight) + 1})
	return spanList
end

function Player:takeDamage(damage)
	self.health = self.health - damage
end

function Player:isDead()
	return self.health <= 0
end

function Player:updateAttackDelay(dt)
	self.attackTimer = self.attackTimer + dt
	if self.attackTimer > self.attackTimeout then
		self.attackDelay = false
	end
end

function Player:startAttackDelay(time)
	self.attackTimeout = time
	self.attackTimer = 0
	self.attackDelay = true
end