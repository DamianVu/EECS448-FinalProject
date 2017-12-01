---Class Tilemapping
Map = class("Map", {})
--- Class defn
function Map:init(grid, id_dict)
	self.tiles = {}
	self.id_dict = id_dict

	for rowIndex = 1, #grid do --Fill map with tiles, where id is the number in the grid
		local row = grid[rowIndex]
		self.tiles[rowIndex] = {}
		for columnIndex = 1, #row do
			local id = row[columnIndex]
			local nthTile = Tile(id, x, y, width, height, self.id_dict[id].collision, self.id_dict[id].bumpFactor)
			self.tiles[rowIndex][columnIndex] = nthTile
		end
	end
end
-- End --
