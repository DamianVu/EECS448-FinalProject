local socket = require "socket"

local udp = socket.udp()

udp:settimeout(0)

udp:setsockname('*', 5005)


local players = {}

function getIndexOf(ent)
	for i = 1, #players do
		if players[i].id == ent then
			return i
		end
	end
end


local data, msg_or_ip, port_or_nil
local entity, s, state, parms

local running = true

print "Starting server..."

while running do

	data, msg_or_ip, port_or_nil = udp:receivefrom()

	if data then
		entity, s, parms = data:match("(.+) (-*%d+) (.*)")
		--print(data)

		state = tonumber(s)

		if state == 999 then
			-- Player joining
			print("Player '" .. entity .. "' is joining")
			print("Their pos+color is " .. parms)
			local lx,ly,lr,lg,lb = parms:match("(-*%d+.*%d*),(-*%d+.*%d*) (%d+),(%d+),(%d+)")
			players[#players+1] = {id=entity, x=lx, y=ly, r=lr, g=lg, b=lb}
		elseif state == -1 then
			-- Player leaving
			print("Player '" .. entity .. "' has left")
			table.remove(players, getIndexOf(entity))
		elseif state == 1 then
			-- Player sending new location
			local x,y = parms:match("(-*%d+.*%d*),(-*%d+.*%d*)")
			local loc = getIndexOf(entity)
			players[loc].x = x
			players[loc].y = y
		end


		udp:sendto("0 Players: " .. #players, msg_or_ip, port_or_nil)
		for i=1, #players do
			data = string.format("1 %s %f,%f %d,%d,%d", players[i].id, players[i].x, players[i].y, players[i].r, players[i].g, players[i].b)
			udp:sendto(data, msg_or_ip, port_or_nil)
		end


	elseif msg_or_ip ~= 'timeout' then
		error("Network error: " .. tostring(msg_or_ip))
	end

	socket.sleep(0.1)
end