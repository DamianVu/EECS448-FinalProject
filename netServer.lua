-- Networking Server Interface

local socket = require "socket"


-- Connection information
local address, port = "*", "5050"
local entity, cmd, parms
local running = true -- Whether server is running. Here, we auto-start

-- Initialize the server
udp = socket.udp()
udp:setsockname(address, port)
udp:settimeout(0)


players = {}


print "Beginning data receiver server loop..."
while running do
  data, fromIP, fromPort = udp:receivefrom() -- Receive contents of packet
  if data then
    -- Data has been received from the server
    print("Received Packet from " .. tostring(fromIP) .. ":" .. tostring(fromPort) .. " ->\n    "  .. tostring(data)) -- (Print Debug)


        -- TODO Determine protocol for messages, and general server connection management. join(), leave(), etc.
        entity, cmd, parms = data:match("^(%S*) (%S*) (.*)")

        -- Handle the various commands
        if cmd == 'join' then
          local lx,ly,lr,lg,lb = parms:match("(-*%d+.*%d*),(-*%d+.*%d*) (%d+),(%d+),(%d+)")
          players[#players+1] = {id=entity, x=lx, y=ly, r=lr, g=lg, b=lb}
        elseif cmd == 'leave' then
          table.remove(players, getIndexOf(entity))
        elseif cmd == 'moveto' then
    			local x, y = parms:match("^(%-?[%d.e]*) (%-?[%d.e]*)$")
          local i = indexOf(ent)
    			players[i].x, players[i].y = x, y
        end


  elseif fromIP ~= 'timeout' then -- Timeout
  	error("Network error: "..tostring(fromIP))
  end


  socket.sleep(0.01)
end

-- Get the index of a player in the connected players list
function indexOf(ent)
	for i = 1, #players do
		if players[i].id == ent then return i end
	end
end

function retrievePlayerList()
  for i=1, #players do
    data = string.format("1 %s %f,%f %d,%d,%d", players[i].id, players[i].x, players[i].y, players[i].r, players[i].g, players[i].b)
    print(data)
    -- udp:sendto(data, fromIP, fromPort)
  end
end
