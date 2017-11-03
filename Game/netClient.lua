-- Networking Client Interface

socket = require "socket" -- Lua Socket Library

connected = false
ephemeralPort = -1

-- Connect to server (UDP socket initialization)
function connectToServer(address, port)
  udp = socket.udp()
  udp:setpeername(address, port)
  udp:settimeout(0)
  sendToServer(USERNAME.." join 0 0 255 255 255")
  -- holePunch()
  connected = true
end

-- function holePunch()
--   data = udp:receive()
--   holepunched = false
--   repeat
--     if data then
--         portflag, port, etc = data:match("^(%S*) (%S*) (.*)")
--         if portflag == "port" then
--           ephemeralPort = port
--           holepunched = true
--         end
--         print(tostring(data))
--     end
--   until holepunched
-- end

-- Disconnect from the server (UDP socket closure)
function disconnectFromServer()
  sendToServer(USERNAME.." leave")
  udp:close()
  print("Disconnecting from server...")
  receiverChannel:push("disconnect")
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
