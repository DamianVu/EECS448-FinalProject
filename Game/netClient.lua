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


-- General method for sending data to server.
function sendToServer(data) -- data should be in the form of a string


    -- TODO Determine protocol for messages, and general server connection management. join(), leave(), etc.


    -- TODO Here, use regexes to route the data to the proper handler. I propose we use something like "<entity> <cmd> <params>" for message formatting
    udp:send(data)


    -- socket.sleep(0.01) --Socket update frequency
end
