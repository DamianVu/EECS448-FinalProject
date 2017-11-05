-- Networking Server Interface

local socket = require "socket"

-- NOTE Server starts at the bottom of this file

-- Connection information
local address, port = "*", "5050"
local entity, cmd, parms
local running = true -- Whether server is running. Here, we auto-start

-- Initialize the server socket
udp = socket.udp()
udp:setsockname(address, port)
udp:settimeout(0)

-- Table of connected players
players = {}

-- Get the index of a player in the connected players list
function indexOf(ent)
	for i = 1, #players do
		if players[i].id == ent then return i end
	end
	return -1
end

-- Useful, and easy first step for testing
function retrievePlayerList()

end

-- Forward packets to clients
function broadcast(payload, fromPlayer)
	local e = payload:match("^(%S*)")
	for i=1, #players do
			if e ~= players[i].id then udp:sendto(payload, players[i].ip, players[i].port) end
	end
end

-- Reply to the client sending a command (Semantically convenient helper)
function reply(payload, ip, pn) udp:sendto(payload, ip, pn) end

-- Receives incoming packets
function receiver()
	print("Entering receiver loop...")
	while running do
	  data, fromIP, fromPort = udp:receivefrom() -- Receive contents of packet
	  if data then

	    -- Data has been received from the server
	    print("Received Packet from " .. tostring(fromIP) .. ":" .. tostring(fromPort) .. " ->\n    "  .. tostring(data)) -- (Print Debug)

			-- Read packet (Packet grammar: <Entity> <Command> <p1> <p...> <pN> where p1...pN represent N parameters
      entity, cmd, parms = data:match("^(%S*) (%S*) (.*)")

      -- Grammar definition
      if cmd == 'join' then
					broadcast(data, entity)
          local lx,ly,lr,lg,lb = parms:match("(-*%d+.*%d*) (-*%d+.*%d*) (%d+) (%d+) (%d+)")
          players[#players+1] = {ip=fromIP, port=fromPort, id=entity, x=lx, y=ly, r=lr, g=lg, b=lb}

					-- Bounce the current players back to the new player
					for i=1, #players do
						local p = players[i]
						if p.id ~= entity then reply(p.id.." join "..p.x.." "..p.y.." "..p.r.." "..p.g.." "..p.b, fromIP, fromPort) end
					end
      elseif cmd == 'leave' then
					broadcast(data, entity)
					table.remove(players, indexOf(entity))
			elseif cmd == 'moveto' then
					broadcast(data, entity)
    			local x, y = parms:match("^(%-?[%d.e]*) (%-?[%d.e]*)$")
          local i = indexOf(entity)
    			players[i].x, players[i].y = x, y
      -- elseif cmd == 'listplayers' then
      elseif cmd == nil then cmd = nil -- Dummy to avoid displaying nil commands
      else print("Unkown command: '"..tostring(cmd).."' received from "..tostring(entity)) end
	  elseif fromIP ~= 'timeout' then error("Network error: "..tostring(fromIP)) end

	  socket.sleep(0.01)
	end
end



-- Start the server
print "Starting server..."
receiver()