function hasPeer(ent)
	for i = 1, #peers do
		if peers[i].id == ent then
			return i
		end
	end
	return -1
end

function addPeer(name, x, y, r, g, b)
	peers[#peers+1] = cObject(name, love.graphics.newImage('images/sprites/player.png'), {r,g,b}, 1, x, y, 32, 32)
end

function updatePeer(pname, px, py, pr, pg, pb)
	if pname ~= entity then
		local loc = hasPeer(pname)
		if loc == -1 then
			addPeer(pname, px, py, pr, pg, pb)
		else
			peers[loc].x = px
			peers[loc].y = py
		end
	end
end