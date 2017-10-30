-- Named: cObject for collisionObject

-- This implementation will only be rectangles for now
cObject = {}
cObject.__index = cObject

-- Initializer
function cObject:new(x, y, length, width, x_offset, y_offset)
	local obj = {}
	setmetatable(obj, cObject)

	obj.x = x or 0
	obj.y = y or 0
	obj.length = length or 64	-- X-axis size
	obj.width = width or 64	-- Y-axis size
	obj.x_offset = x_offset or 0
	obj.y_offset = y_offset or 0

	return obj
end

-- Will return 4 coordinates that the object currently spans. In top-left, top-right, bottom-left, bottom-right order
function cObject:getSpan()
	return 	{	
		{(self.x + self.x_offset) - (self.length / 2), (self.y + self.y_offset) - (self.width / 2)},
		{(self.x + self.x_offset) + (self.length / 2), (self.y + self.y_offset) - (self.width / 2)},
		{(self.x + self.x_offset) - (self.length / 2), (self.y + self.y_offset) + (self.width / 2)},
		{(self.x + self.x_offset) + (self.length / 2), (self.y + self.y_offset) + (self.width / 2)}
	}
end

function cObject:drawHitbox()
	love.graphics.setColor(247, 176, 34)
	love.graphics.rectangle("line", (self.x + self.x_offset), (self.y + self.y_offset), self.length, self.width)

	--love.graphics.setColor()
end

function cObject:setLocation(x, y)
	self.x = x
	self.y = y
end