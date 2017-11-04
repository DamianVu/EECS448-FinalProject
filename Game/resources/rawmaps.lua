
RawMaps = {
	map1 = {
		startx = 2,
		starty = 2,
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

	map2 = {
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
			{1,2,1,1,2,1,1,1,1,1,1,1,2,1},
			{1,2,1,1,2,1,1,1,2,1,1,1,1,1},
			{1,2,1,2,2,2,2,2,2,1,2,2,2,1},
			{1,2,1,2,1,2,1,1,2,1,2,1,2,1},
			{1,2,2,2,1,2,2,2,2,2,2,1,2,1},
			{1,1,1,1,1,1,1,1,1,1,1,1,1,1}
		}
	}
}