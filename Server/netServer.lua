--- Networking Server Interface.

local socket = require "socket"

-- NOTE Server starts at the bottom of this file

-- Connection information
local address, port = "*", arg[1]
local entity, cmd, parms
local running = true -- Whether server is running. Here, we auto-start

local gameTimer = -.05 -- Assume that it will take around 50ms to tell players to start their game
local serverName = arg[2]

-- Initialize the server socket
udp = socket.udp()
udp:setsockname(address, port)
udp:settimeout(0)

-- Table of connected players
players = {}

--- Get the index of a player in the connected players list.
function indexOf(ent)
	for i = 1, #players do
		if players[i].id == ent then return i end
	end
	return -1
end

-- Not in use, remains here for potential use in the future.
-- --- Useful, and easy first step for testing
-- function retrievePlayerList()
--
-- end

--- Broadcast function.
-- This broadcast function receives a payload (generally from a connected player)
-- and forwards the packet to all other connected players. It is also used to distribute
-- other information which must be synchronized across the server and all players.
function broadcast(payload)
	local e = payload:match("^(%S*)")
	local p = {} -- For looping through players
	local names = ""

	for i=1, #players do
			p = players[i]
			if e ~= p.id and p.connected then
				udp:sendto(payload, p.ip, p.port)
				names = names .. p.id .. " "
			end
	end
	-- print("Broadcasting to: " .. names) -- Debugging
end

--- Reply to the client sending a command (Semantically convenient helper).
-- This reply function is the counterpart to the broadcast function.
-- The reply function, after a message is received from a connected player,
-- is used to bounce a message back to the player.
function reply(payload, ip, pn) udp:sendto(payload, ip, pn) end

--- Receives incoming packets.
-- This receiver function is a loop at the heart of the server.
-- The Receiver is spawned by the lobby server as an independent process
-- (although the lobby server still has arbitration capabilities) which
-- receives all packets from connected clients, forwards, broadcasts,
-- synchronizes packets across all players connected to the particular instance.
function receiver()
	print("Entering receiver loop...")
	prevTime = 0
	while running do
		currentTime = os.clock()
		dt = currentTime - prevTime
		prevTime = currentTime
	  data, fromIP, fromPort = udp:receivefrom() -- Receive contents of packet
	  if data then

	    -- Data has been received from the server
			print("["..serverName.."] Received from " .. tostring(fromIP) .. ":" .. tostring(fromPort) .. " ->\n    "  .. tostring(data)) -- (Print Debug)

			-- Read packet (Packet grammar: <Entity> <Command> <p1> <p...> <pN> where p1...pN represent N parameters
      entity, cmd, parms = data:match("^(%S*) (%S*) *(.*)")

      -- Grammar definition
      if cmd == 'join' then
					broadcast(data)
          local lx,ly,ls = parms:match("(-*%d+.*%d*) (-*%d+.*%d*) (%S+)")
					local p = indexOf(entity)
					if p == -1 then -- Add player if never joined before
						players[#players+1] = {connected=true, ip=fromIP, port=fromPort, id=entity, x=lx, y=ly, s=ls}
						reply(entity .. " yourid " .. #players, fromIP, fromPort)
					else
						players[p].connected = true
						players[p].ip = fromIP
						players[p].port = fromPort
						reply(entity .. " rejoin " .. players[p].x .. " " .. players[p].y, fromIP, fromPort)

						reply(entity .. " yourid " .. p, fromIP, fromPort)
						print("This is a rejoin in our player table at index " .. p)
					end -- Set player's connected property to true

					broadcast(entity .. " netid " .. indexOf(entity))

					-- Bounce the current players back to the new player
					for i=1, #players do
						local p = players[i]
						if p.id ~= entity and p.connected then
							reply(p.id.." join "..p.x.." "..p.y.." "..p.s, fromIP, fromPort)
							reply(p.id.." netid "..i, fromIP, fromPort)
						end
					end
      elseif cmd == 'leave' then
					broadcast(data)
					print("Player left, attempting to set index " .. indexOf(entity) .. "'s property 'connected' to 'false'")
					players[indexOf(entity)].connected = false
		elseif cmd == 'moveto' then
					broadcast(data)
    			local x, y = parms:match("^(%-?[%d.e]*) (%-?[%d.e]*)$")
          local i = indexOf(entity)
    			players[i].x, players[i].y = x, y
      -- elseif cmd == 'listplayers' then
			elseif cmd == 'spawnprojectile' then broadcast(data)
      elseif cmd == nil then cmd = nil -- Dummy to avoid displaying nil commands

      	elseif cmd == "start" then
      		print("Start command received. Telling each player to begin their game timer")
      		broadcast("server start")

      else print("Unkown command: '"..tostring(cmd).."' received from "..tostring(entity)) end
	  elseif fromIP ~= 'timeout' then error("Network error: "..tostring(fromIP)) end

	  socket.sleep(0.01)
	end
end



-- Start the server
print "Starting server..."
receiver()
