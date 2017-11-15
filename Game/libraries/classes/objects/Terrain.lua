
Terrain = class("Terrain", {})

function Terrain:init(x, y, width, height)
	self.x = x
	self.y = y
	self.type = TERRAIN
	self.width = width
	self.height = height
end

function Terrain:drawHitbox()
	love.graphics.setColor(255,0,0)
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end