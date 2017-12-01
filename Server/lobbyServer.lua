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

-- Return the index of a game given the name
function locateGame(name)
	for i = 1, #games do
		if games[#games][i] == name then return i
		else return -1 end
	end
end


-- Finds a new port to set up a new game on (will cycle through 5050-5060 range)
function newPort()
	local lastPort

	if #games == 0 then lastPort = 5050
	else lastPort = games[#games][2] end

	if lastPort == 5060 then lastPort = 5050
	else lastPort = lastPort + 1 end

	return lastPort
end

-- Creates a new game upon request by a client. Indexes the new server and spawns the process.
function addGame(name)
	local gamePort = newPort()
	games[#games + 1] = {name.."'s game", gamePort} -- Create entry in game tracker table
	os.execute("python spawnServer.py "..gamePort.." "..name) -- Run server spawn script
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
      entity, cmd, parms = data:match("^(%S*) (%S*) *(.*)")

      -- Grammar definition
      if cmd == 'fetchlobbies' then -- Bounce the current games back to the new player (replies with #games number of packets)
          print("Responding to "..entity.." with the list of active games...")
					for i=1, #games do reply("lobby "..games[i][1], fromIP, fromPort) end
      elseif cmd == 'countlobbies' then
					reply("countlobbies "..#games, fromIP, fromPort)
			elseif cmd == 'newgame' then
					addGame(parms)
					print("Sending connection information (port "..games[#games][2]..") back to creator of new lobby...")
					reply("newconnect "..games[#games][2], fromIP, fromPort)
			elseif cmd == 'select' then
					local gameIndex = tonumber(parms)
					if gameIndex <= #games then reply("newconnect "..games[gameIndex][2], fromIP, fromPort)
					else reply("notfound", fromIP, fromPort) end
      elseif cmd == nil then cmd = nil -- Dummy to avoid displaying nil commands
      else print("Unkown command: '"..tostring(cmd).."' received from "..tostring(entity)) end
	  elseif fromIP ~= 'timeout' then error("Network error: "..tostring(fromIP)) end
	  socket.sleep(0.01)
	end
end

-- Start the server
print "Starting server..."
receiver()
