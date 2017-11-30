--- Lobby Server Interface.

local socket = require "socket"

-- NOTE Server starts at the bottom of this file

-- Connection information
local address, port = "*", "5001" -- LOBBY SERVER PORT
local entity, cmd, parms
local running = true -- Whether server is running. Here, we auto-start

-- Initialize the server socket
udp = socket.udp()
udp:setsockname(address, port)
udp:settimeout(0)

-- Table of connected players
players = {}

-- Table of active game servers
games = {}

--
-- -- Get the index of a player in the connected players list
-- function indexOf(ent)
-- 	for i = 1, #players do
-- 		if players[i].id == ent then return i end
-- 	end
-- 	return -1
-- end

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
      entity, cmd, parms = data:match("^(%S*) (%S*) *(.*)")

      -- Grammar definition
      if cmd == 'fetchlobbies' then -- Bounce the current games back to the new player (replies with #games number of packets)
          print("Responding to "..entity.." with the list of active games...")
					for i=1, #games do reply("lobby "..games[i], fromIP, fromPort) end
      elseif cmd == 'countlobbies' then
					reply("countlobbies "..#games)

      elseif cmd == nil then cmd = nil -- Dummy to avoid displaying nil commands
      else print("Unkown command: '"..tostring(cmd).."' received from "..tostring(entity)) end
	  elseif fromIP ~= 'timeout' then error("Network error: "..tostring(fromIP)) end
	  socket.sleep(0.01)
	end
end



-- Start the server
print "Starting server..."
receiver()
