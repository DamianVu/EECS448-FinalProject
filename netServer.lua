-- Networking Server Interface

local socket = require "socket"



local address, port = "*", "25560"
local entity, cmd, parms
local running = true -- Whether server is running. Here, we auto-start


udp = socket.udp()
udp:setsockname("*",25560)
udp:settimeout(0)


-- debugi = 0

print "Beginning data receiver server loop..."
while running do
  data, fromIP, fromPort = udp:receivefrom() -- Receive contents of packet
  if data then
    -- Data has been received from the server
    print("Last received packet: ", tostring(data))



  elseif fromIP ~= 'timeout' then -- Timeout
  	error("Network error: "..tostring(fromIP))
  end

end

print "Thank you."
