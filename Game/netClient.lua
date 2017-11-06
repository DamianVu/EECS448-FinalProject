-- Networking Client Interface

socket = require "socket" -- Lua Socket Library

verbose_debug = true -- Enable to print packet flow for each client

connected = false

peers = {}

--- Connect to server (Socket initialization).
-- Connects the client to the server upon multiplayer mode
function connectToServer(address, port)

  --UDP socket initialization
  udp = socket.udp()
  udp:setpeername(address, port)
  udp:settimeout(0)

  -- Initialize player info relevant to server
  local r,g,b = unpack(player.color)
  messageCount = 0
  playerList = ""

  -- Send join signal
  sendToServer(USERNAME.." join "..player.x.." "..player.y.." "..r.." "..g.." "..b)
  connected = true

end

-- Disconnect from the server (Socket closure)
function disconnectFromServer()
  sendToServer(USERNAME.." leave")
  udp:close()
  print("Disconnecting from server...")
  connected = false
end

--- Client-side receiver that connects to the server.
-- The receiver loop used by the client to get data from the server
function receiver()
  repeat
      -- Read and parse packet
      receivedData, msg = udp:receive()
      if receivedData then
          if verbose_debug then print(receivedData) end

          -- Grammar definition
          local entity, cmd, parms = tostring(receivedData):match("^(%S*) (%S*) *(.*)")
          if entity ~= USERNAME then -- Broadcast Type Commands
            if cmd == 'join' then -- Broadcast Type
              local px, py, pr, pg, pb = parms:match("(-*%d+.*%d*) (-*%d+.*%d*) (%d+) (%d+) (%d+)")
              addPeer(entity, px, py, pr, pg, pb)
            end
            if cmd == 'leave' then -- Broadcast Type
              table.remove(peers, peerIndex(entity))
              -- playerList = playerList:match("(.*), (%S+)") -- Remove from player list (This pattern only strips last one)
            end
            if cmd == 'moveto' then -- Broadcast Type
                local x, y = parms:match("^(%-?[%d.e]*) (%-?[%d.e]*)$")
                updatePeer(entity, x, y)
            end
          else -- Response Type Commands
            if cmd == 'rejoin' then -- Response Type
              player.x, player.y, player.r, player.g, player.b = parms:match("(-*%d+.*%d*) (-*%d+.*%d*) (%d+) (%d+) (%d+)")
            end
          end
      elseif msg~= 'timeout' then error("Network error: " ..tostring(msg))
      end
  until not receivedData
end

--- Get peer index.
-- Gets the index of a peer in the peer table.
function peerIndex(ent)
	for i = 1, #peers do
		if peers[i].id == ent then return i end
	end
	return -1
end

--- Add a peer to the peer table.
-- Adds a peer to the peer table for a given client
function addPeer(name, x, y, r, g, b)
  print("Adding peer with color ",r,g,b)
	peers[#peers+1] = cObject(name, love.graphics.newImage('images/sprites/player.png'), {r,g,b}, 1, x, y, 32, 32)
  playerList = playerList..", "..name
end

--- Update a peer's information.
-- Updates the data for a peer in the peer table.
function updatePeer(name, x, y, r, g, b)
	if name ~= USERNAME then
		local i = peerIndex(name)
		if i == -1 then addPeer(name, x, y, r, g, b)
		else
      local p = peers[i]
      p.x, p.y, p.r, p.g, p.b = x or p.x, y or p.y, r or p.r, g or p.g, b or p.b
    end
	end
end

--- Send data to the server.
-- Semantically convenient helper for sending data to server.
function sendToServer(data)
  udp:send(data)
  messageCount = messageCount + 1
end
