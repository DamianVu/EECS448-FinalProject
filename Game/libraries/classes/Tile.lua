---Class Tile
Tile = class("Tile", {})
--- Constructor for a Tile.
-- Tile Objects will have all information for a given tile that needs to be realized. Render position, size, collision enable, etc.
function Tile:init(id, x, y, width, height, collision, bumpFactor)
	self.id = id							 	--|int - integer representation of Tile
	self.x = x								 	--|int - x coordinate of upper-left corner
	self.y = y									--|int - y coordinate of upper-left corner
	self.width = width				 			--|int - Tile width
	self.height = height			 			--|int - Tile height
	self.collision = collision 					--|bool - collision enabled
	self.bumpFactor = bumpFactor or 0			--|num - bumping factor (not too functional yet)
end
