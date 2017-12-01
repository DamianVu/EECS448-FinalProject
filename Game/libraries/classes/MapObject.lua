---Class Map Object
MapObject = class("MapObject", {})

function MapObject:init(image, quad, properties)
	self.image = image
	self.quad = quad
	self.properties = properties or {} -- Propreties should be true, or nil (nil evaluates to false anyways)
end
