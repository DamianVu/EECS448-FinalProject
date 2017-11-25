
NetworkHandler = class("NetworkHandler", {})

function NetworkHandler:init(GH, ip, port)
	self.socket = require "socket"

	self.GH = GH
	self.GH.multiplayer = true
	self.GH.player.multiplayer = true
	self.peers = GH.peers -- This should be a reference

	self.serverIP = ip
	self.serverPort = port

	self.connected = false
	self.verbose_debug = true
end

function NetworkHandler:connect()
	self.udp = socket.udp()
	self.udp:setpeername(self.serverIP, self.serverPort)
	self.udp:settimeout(0)

	-- Initialize player info relevant to server
	local r,g,b = unpack(self.GH.player.color)
	self.messageCount = 0
	playerList = ""

	-- Send join signal
	self:send(self.GH.player.id .. " join " .. self.GH.player.x .. " " .. self.GH.player.y .. " " .. r .. " " .. g .. " " .. b)
	self.connected = true
end

function NetworkHandler:send(packet)
	self.udp:send(packet)
	self.messageCount = self.messageCount + 1
end

function NetworkHandler:disconnect()
	self:send(self.GH.player.id .. " leave")
	self.udp:close()
	self.connected = false
end

function NetworkHandler:addPeer(ent, x, y, r, g, b)
	self.peers[#self.peers + 1] = Peer(ent, {r, g, b}, x, y, 32)
end

function NetworkHandler:locatePeer(ent)
	for i = 1, #self.peers do
		if self.peers[i].id == ent then return i end
	end
end

function NetworkHandler:receive()
	repeat
		-- Read and parse packet
		receivedData, msg = self.udp:receive()
		if receivedData then
			if self.verbose_debug then print(receivedData) end

			-- Grammar definition
			local entity, cmd, parms = tostring(receivedData):match("^(%S*) (%S*) *(.*)")
			if entity ~= self.GH.player.id then -- Broadcast Type Commands
				if cmd == 'join' then -- Broadcast Type
					local px, py, pr, pg, pb = parms:match("(-*%d+.*%d*) (-*%d+.*%d*) (%d+) (%d+) (%d+)")
							self:addPeer(entity, px, py, pr, pg, pb)
				end
				if cmd == 'leave' then -- Broadcast Type
					table.remove(self.peers, self:locatePeer(entity))
				end
				if cmd == 'moveto' then -- Broadcast Type
					local x, y = parms:match("^(%-?[%d.e]*) (%-?[%d.e]*)$")
					local ind = self:locatePeer(entity)
					self.peers[ind].x = x
					self.peers[ind].y = y
				end
			else -- Response Type Commands
				if cmd == 'rejoin' then -- Response Type
					GH.player.x, GH.player.y = parms:match("(-*%d+.*%d*) (-*%d+.*%d*)")
				end
			end
		elseif msg~= 'timeout' then 
			error("Network error: " ..tostring(msg))
		end
	until not receivedData
end



-- Maybe move these functions into their respective objects? *shrugs*

function NetworkHandler:playerMove(id, x, y)
	local packet = id .. " moveto " .. x .. " " .. y
	self:send(packet)
end