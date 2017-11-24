
NetworkHandler = class("NetworkHandler", {})

function NetworkHandler:init(GH)
	self.socket = require "socket"
	self.peers = GH.peers -- This should be a reference

	self.connected = false
	self.verbose_debug = true
end

function NetworkHandler:connect(address, port)
	self.udp = socket.udp()
	self.udp:setpeername(address, port)
	self.udp:settimeout(0)

	-- Initialize player info relevant to server
	local r,g,b = unpack(player.color)
	self.messageCount = 0
	playerList = ""

	-- Send join signal
	sendToServer(USERNAME.." join "..player.x.." "..player.y.." "..r.." "..g.." "..b)
	connected = true
end

function NetworkHandler:sendToServer(packet)

end