---Class CoordinateList
CoordinateList = class("CoordinateList", {list = {}})

--- Constructor for the CoordinateList object.
function CoordinateList:init(unique)
	self.unique = unique or true
end

--- Adds a coordinate to the CoordinateList.
function CoordinateList:add(coord)
	local x,y = unpack(coord)
	if self.unique then
		if not self:contains(coord) then
			if MH:isValidTile(x,y) then
				self.list[#self.list + 1] = coord
			end
		end
	else
		if MH:isValidTile(x,y) then
			self.list[#self.list + 1] = coord
		end
	end
end

--- Determines whether the CoordinateList object contains a given coordinate.
function CoordinateList:contains(coord)
	local ix, iy = unpack(coord)
	for i = 1, #self.list do
		local cx, cy = unpack(self.list[i])
		if cx == ix and cy == iy then
			return true, i
		end
	end
	return false
end

--- Creates a new CoordinateList that envolpes the old CoordinateList.
-- This returns a new, larger CoordinateList containing every tile in the previous AND every adjacent tile attached
function CoordinateList:fullSpan()
	local rList = CoordinateList()
	for i = 1, #self.list do
		local x,y = unpack(self.list[i])
		for j = x-1, x+1 do
			for k = y-1, y+1 do
				rList:add({j,k})
			end
		end
	end
	return rList
end

--- Returns a subset CoordinateList of a given CoordinateList.
function CoordinateList.subset(outerList, innerList)
	local rList = CoordinateList(true)
	for i = 1, #outerList.list do
		local x,y = unpack(outerList.list[i])
		if not innerList:contains({x,y}) then
			rList:add({x,y})
		end
	end
	return rList
end


-- Everything beyond is used for testing of the CoordinateList structure.

-- Class that contains coordinates
CoordinateList = class("CoordinateList", {list = {}})
function CoordinateList:init(unique)
	self.unique = unique or true
end

function CoordinateList:add(coord)
	local x,y = unpack(coord)
	if self.unique then
		if not self:contains(coord) then
			if MH:isValidTile(x,y) then
				self.list[#self.list + 1] = coord
			end
		end
	else
		if MH:isValidTile(x,y) then
			self.list[#self.list + 1] = coord
		end
	end
end

function CoordinateList:contains(coord)
	local ix, iy = unpack(coord)
	for i = 1, #self.list do
		local cx, cy = unpack(self.list[i])
		if cx == ix and cy == iy then
			return true, i
		end
	end
	return false
end

-- This returns a new, larger CoordinateList containing every tile in the previous AND every adjacent tile attached
--- I don't see why this function would ever be ran if self.unique = false, but we can cross that bridge when the time comes.
function CoordinateList:fullSpan()
	local rList = CoordinateList()
	for i = 1, #self.list do
		local x,y = unpack(self.list[i])
		for j = x-1, x+1 do
			for k = y-1, y+1 do
				rList:add({j,k})
			end
		end
	end
	return rList
end

function CoordinateList.subset(outerList, innerList)
	local rList = CoordinateList(true)
	for i = 1, #outerList.list do
		local x,y = unpack(outerList.list[i])
		if not innerList:contains({x,y}) then
			rList:add({x,y})
		end
	end
	return rList
end
