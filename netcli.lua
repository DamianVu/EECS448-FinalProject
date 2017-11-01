-- Networking Client Interface

socket = require "socket" -- Lua Socket Library


-- For managing connection
local address, port = "192.168.0.2", 5050
local lastpacket = "" -- Last received packet

-- UDP socket initialization
udp = socket.udp()
udp:setpeername(address, port)
udp:settimeout(0)


repeat




  print "Sending to server..."
  udp:send("Hello server")


  socket.sleep(0.01)
until false
