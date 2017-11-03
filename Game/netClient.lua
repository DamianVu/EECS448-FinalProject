-- Networking Client Interface

socket = require "socket" -- Lua Socket Library

connected = false

-- Connect to server (UDP socket initialization)
function connectToServer(address, port)
  udp = socket.udp()
  udp:setpeername(address, port)
  udp:settimeout(0)
  sendToServer(USERNAME.." join 0 0 255 255 255")
  connected = true
end

-- Disconnect from the server (UDP socket closure)
function disconnectFromServer()
  sendToServer(USERNAME.." leave")
  udp:close()
  print("Disconnecting from server...")
  connected = false
end

-- Spawn the thread to allow receiving of data from server
function spawnReceiver()
  receiverThread = love.thread.newThread("clientReceiver.lua")
  receiverChannel = love.thread.getChannel("receiver")
  receiverChannel:push("Test stack")
  receiverThread:start()
end


-- General method for sending data to server.
function sendToServer(data) udp:send(data) end
