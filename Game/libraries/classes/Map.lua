
--Tileset-- Class definition and constructor, new_tileset
Tileset = class("Tileset", {map = {}})
--- Tileset Constructor.
function Tileset:init(map, img, width, height, tileWidth, tileHeight, cdict, originx, originy)
	self.map = map                        				-- map  		|2d array of Tile objects
	self.img = img										-- img  		|love.graphics.newImage('image/path.png')
	self.width = width									-- width  		|width of tileset = img.getWidth()
	self.height = height								-- height  		|height of tileset = img.getHeight()
	self.tileWidth = tileWidth or 64					-- tileWidth  	|Width of tile in set
	self.tileHeight = tileHeight or 64					-- tileHeight 	|Height of tile in set
	self.color_dict = cdict
	if originx == nil then originx = 0 end
	if originy == nil then originy = 0 end
	self.origin = {originx,originy}						-- startx 		|starting position to draw map. DEFAULT IS 0,0   -   No reason to use anything else atm
end
-- End --
