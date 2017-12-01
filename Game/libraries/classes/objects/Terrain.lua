--- handles terrain.
Terrain = class("Terrain", {})
-- terrain constructor. Initialized x, y, width, and height.
function Terrain:init(x, y, width, height)
	self.x = x
	self.y = y
	self.type = TERRAIN
	self.width = width
	self.height = height
end
-- draws hitbox for terrain.
function Terrain:drawHitbox()
	love.graphics.setColor(255,0,0)
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end