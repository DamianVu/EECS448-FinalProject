-- Networking Server Interface

local socket = require "socket"


-- Connection information
local address, port = "*", "25560"
local entity, cmd, parms
local running = true -- Whether server is running. Here, we auto-start

-- Initialize the server
udp = socket.udp()
udp:setsockname("*",25560)
udp:settimeout(0)


connectedPlayers = {}



print "Beginning data receiver server loop..."
while running do
  data, fromIP, fromPort = udp:receivefrom() -- Receive contents of packet
  if data then
    -- Data has been received from the server
    print("Received Packet from " .. tostring(fromIP) .. ":" .. tostring(fromPort) .. " ->\n    "  .. tostring(data)) -- (Print Debug)


        -- TODO Determine protocol for messages, and general server connection management. join(), leave(), etc.
        entity, cmd, parms = data:match("^(%S*) (%S*) (.*)")

        -- Handle the various commands
        if cmd == 'join' then playerJoinHandle(ent, fromIP, fromPort)
        elseif cmd == 'leave' then playerLeaveHandle(ent, fromIP, fromPort)
        elseif cmd == 'moveto' then
    			local x, y = parms:match("^(%-?[%d.e]*) (%-?[%d.e]*)$")

        end


  elseif fromIP ~= 'timeout' then -- Timeout
  	error("Network error: "..tostring(fromIP))
  end


  socket.sleep(0.01)
end


function playerJoinHandle(ent, fromIP, fromPort)
  table.insert(connectedPlayers, ent)
  connectedPlayers[ent] = {fromIP, fromPort}
end

function playerLeaveHandle(ent, fromIP, fromPort)
  table.remove(connectedPlayers, ent)
end
