-- Networking Client Interface

socket = require "socket" -- Lua Socket Library





-- Connect to server (UDP socket initialization)
function connectToServer(address, port)
  udp = socket.udp()
  udp:setpeername(address, port)
  udp:settimeout(0)

  sendToServer(USERNAME.." join")
end

-- Disconnect from the server (UDP socket closure)
function disconnectFromServer()
  sendToServer(USERNAME.." leave")
  udp:close()
  print("Disconnecting from server...")
end




function retrievePlayerList()


end

-- General method for sending data to server.
function sendToServer(data) udp:send(data) end
