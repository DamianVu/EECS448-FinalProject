
--- MCTile since Tile is being used for a very specific purpose
MCTile = class("MCTile", {})

--- Constructor for an MCTile
function MCTile:init(tileset, tile)
	self.tileset = tileset
	self.tile = tile
end
