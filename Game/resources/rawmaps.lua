---RawMaps
RawMaps = {
	[1] = {
		startingLocations = {

			{5,5}
		},
		endingLocations = {
			[1] = {10,10}
		},
		transitions = {
			[1] = {2,1}
		},
		img = "testset.png",
		id_dict = {
			[1] = {collision = true, bumpFactor = 0},
			[2] = {collision = false},
			[3] = {collision = true, bumpFactor = 0},
			[4] = {collision = true, bumpFactor = 5}
		},
		color_dict = {
			[1] = {255, 0, 0},
			[2] = {0, 255, 0},
			[3] = {255, 255, 0},
			[4] = {255, 0, 0}
		},
		grid = {
			{1,1,1,1,1,1,1,1},
			{1,2,2,2,2,2,2,1},
			{1,2,3,3,2,2,2,1},
			{1,2,2,2,2,2,2,1,1,1,1},
			{1,1,1,2,2,2,2,2,2,2,1},
			{1,2,2,2,2,1,1,1,1,2,1},
			{1,2,3,3,3,3,3,3,3,2,2,2,2,2,1},
			{1,2,2,2,2,2,2,2,2,2,1},
			{1,2,2,4,4,4,4,2,2,2,1},
			{1,2,3,3,3,3,3,3,3,2,1},
			{1,1,1,1,1,1,1,1,1,1,1}
		}
	},

	[2] = {
		startingLocations = {
			{2,2},
			{11,13}
		},
		endingLocations = {
			[1] = {3,2}
		},
		transitions = {
			[1] = {3,1}
		},
		img = "testset.png",
		id_dict = {
			[1] = {collision = true, bumpFactor = 0},
			[2] = {collision = false},
			[3] = {collision = true, bumpFactor = 0},
			[4] = {collision = true, bumpFactor = 5}
		},
		color_dict = {
			[1] = {255, 0, 0},
			[2] = {0, 255, 0},
			[3] = {255, 255, 0},
			[4] = {255, 0, 0}
		},
		grid = {
			{1,1,1,1,1,1,1,1,1,1,1,1,1,1},
			{1,2,2,2,1,2,2,2,1,1,2,2,2,1},
			{1,2,1,2,1,2,1,2,2,2,2,1,2,1},
			{1,2,1,2,2,2,1,1,1,1,1,1,2,1},
			{1,2,2,2,1,1,1,2,2,2,1,1,2,1},
			{1,2,1,2,2,2,2,2,1,2,2,2,2,1},
			{1,2,3,3,2,1,1,1,1,1,1,1,2,1},
			{1,2,1,1,2,1,1,1,2,1,1,1,1,1},
			{1,2,1,2,2,2,2,2,2,1,2,2,2,1},
			{1,2,1,2,1,2,1,1,2,4,2,1,2,1},
			{1,2,2,2,1,2,2,2,2,2,2,1,2,1},
			{1,1,1,1,1,1,1,1,1,1,1,1,1,1}
		}
	},

	[3] = {
		startingLocations = {
			{10,10},
			{3,3}
		},
	endingLocations = {
		[1] = {3,3}
	},
	transitions = {
		[1] = {1,1}
	},

		img = "testset.png",
		id_dict = {
			[1] = {collision = true, bumpFactor = 0},
			[2] = {collision = false},
			[3] = {collision = true, bumpFactor = 0},
			[4] = {collision = true, bumpFactor = 5}
		},
		color_dict = {
			[1] = {255, 0, 0},
			[2] = {0, 255, 0},
			[3] = {255, 255, 0},
			[4] = {255, 0, 0}
		},
		grid = {
			{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
			{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
			{1,2,2,1,2,3,3,3,3,2,4,1,2,1,1},
			{1,2,1,1,2,3,3,3,3,2,1,1,2,1,1},
			{1,2,2,2,2,3,3,3,3,2,2,2,2,1,1},
			{1,2,1,1,2,3,3,3,3,2,1,1,2,1,1},
			{1,2,2,2,2,3,3,3,3,2,2,2,2,1,1},
			{1,2,2,2,2,3,3,3,3,2,2,2,2,1,1},
			{1,2,1,1,2,3,3,3,3,2,1,1,1,1,1},
			{1,2,1,1,2,3,3,3,3,2,2,2,4,1,1},
			{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
		}
	},
	[4] = {
		startingLocations = {
			{4.5,5}
		},
		endingLocations = {},
		img="testset.png",
		id_dict = {
			[1] = {collision = true, bumpFactor = 0},
			[2] = {collision = false},
			[3] = {collision = true, bumpFactor = 0},
			[4] = {collision = true, bumpFactor = 5}
		},
		color_dict = {
			[1] = {255, 0, 0},
			[2] = {0, 255, 0},
			[3] = {255, 255, 0},
			[4] = {255, 0, 0}
		},
		terrainObjects = {
			-- Terrain obj will have format {start tile x, y, tilesWide, tilesHigh}
			[1] = {1, 1, 11, 1},
			[2] = {1, 2, 1, 8},
			[3] = {11, 2, 1, 8},
			[4] = {1, 10, 11, 1},
			[5] = {3, 3, 1, 1},
			[6] = {7, 6, 2, 2}
		},
		grid = {
			{1,1,1,1,1,1,1,1,1,1,1},
			{1,2,2,2,2,2,2,2,2,2,1},
			{1,2,1,2,2,2,2,2,2,2,1},
			{1,2,2,2,2,2,2,2,2,2,1},
			{1,2,2,2,2,2,2,2,2,2,1},
			{1,2,2,2,2,2,1,1,2,2,1},
			{1,2,2,2,2,2,1,1,2,2,1},
			{1,2,2,2,2,2,2,2,2,2,1},
			{1,2,2,2,2,2,2,2,2,2,1},
			{1,1,1,1,1,1,1,1,1,1,1}
		}
	}
}
