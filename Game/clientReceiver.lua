---
local socket = require "socket"

-- Set up thread-to-thread communication on channel
local rc = love.thread.getChannel("receiver")


while rc:peek() != "disconnect" do
  print("Test")
  -- data = udp:receive()
  -- print(tostring(data))
end
udp:close()
print("Closing receiver thread...")
