-- Networking Client Interface

socket = require "socket" -- Lua Socket Library

local lastpacket = "" -- Last received packet

-- Connect to server (UDP socket initialization)
function connectToServer(address, port)
  udp = socket.udp()
  udp:setpeername(address, port)
  udp:settimeout(0)
end

-- Disconnect from the server (UDP socket closure)
function disconnectFromServer()
  udp:close()
  print("Disconnecting from server...")
end



function sendToServer(data)
  print "Sending to server..."
  repeat

    -- TODO Determine protocol for messages, and general server connection management. join(), leave(), etc.


    udp:send("Hello server")


    socket.sleep(0.01)
  until false
end
