--- creates peers when people join in the game
Peer = class("Peer", {})
-- peer constructor that initialized id, networkID, color, x, y, size, and sprite.
function Peer:init(id, networkID, color, x, y, size, sprite)
	self.id = id
	self.networkID = networkID
	self.type = PEER

	self.sprite = love.graphics.newImage("images/sprites/characters/" .. sprite .. ".png")
	self.color = color
	self.currentColor = self.color
	self.x = x
	self.y = y
	self.width = size
	self.height = size

	local imgW, imgH = self.sprite:getDimensions()

	self.x_offset = imgW / 2
	self.y_offset = imgH / 2

	self.scaleX = self.width / imgW
	self.scaleY = self.height / imgH


	self.score = 0

	self.maxHP = 5
	self.health = self.maxHP

end
-- draws peer to the screen.
function Peer:draw()
	love.graphics.setColor(self.currentColor)
	love.graphics.draw(self.sprite, self.x, self.y, 0, self.scaleX, self.scaleY, self.x_offset, self.y_offset)
end

-- Updates damage level for a given Peer
function Peer:takeDamage(damage)
	self.health = self.health - damage
end

-- Updates whether a Peer is dead
function Peer:isDead()
	return self.health <= 0
end
