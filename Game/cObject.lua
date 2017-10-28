-- Named: cObject for collisionObject

-- This implementation will only be rectangles for now
cObject = {}

-- Initializer
function cObject:new(obj, length, width, x_offset, y_offset)
	obj = obj or {}
	setmetatable(obj, self)

	self.__index = self
	self.length = length or 64
	self.width = width or 64
	self.x_offset = x_offset or 0
	self.y_offset = y_offset or 0

	return obj
end

-- Will return 4 coordinates that the object currently spans. In top-left, top-right, bottom-left, bottom-right order
function cObject:getSpan()
	--return {(self.x + self.xoffset), , , }
end

function cObject:setLocation(x, y)
	self.x = x
	self.y = y
end