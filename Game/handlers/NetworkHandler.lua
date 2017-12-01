
NetworkHandler = class("NetworkHandler", {})

-- Constructor for the NetworkHandler
function NetworkHandler:init(GH, ip, port)
	self.socket = require "socket"

	self.GH = GH
	self.GH.multiplayer = true
	self.GH.player.multiplayer = true
	--self.peers = GH.peers -- This should be a reference
	-- That wasn't actually a reference lmao
	self.peers = {}

	self.serverIP = ip
	self.serverPort = port

	self.connected = false
	self.verbose_debug = true
end

-- function NetworkHandler:setPort(p) self.serverPort = p end

-- Connect to the server
function NetworkHandler:connect()
	self.udp = socket.udp()
	self.udp:setpeername(self.serverIP, self.serverPort)
	self.udp:settimeout(0)

	-- Initialize player info relevant to server
	self.messageCount = 0
	playerList = ""



	-- Send join signal
	self:send(self.GH.player.id .. " join " .. self.GH.player.x .. " " .. self.GH.player.y .. " " .. USERSPRITE)
	self.connected = true
end

-- Send a packet to the server
function NetworkHandler:send(packet)
	self.udp:send(packet)
	self.messageCount = self.messageCount + 1
end

-- Disconnect from the server
function NetworkHandler:disconnect()
	self:send(self.GH.player.id .. " leave")
	self.udp:close()
	self.connected = false
end

-- Creates a peer in the peer table
function NetworkHandler:addPeer(ent, x, y, sprite)
	local a = Peer(ent, nil, {255,255,255,255}, x, y, 48, sprite)
	self.peers[#self.peers + 1] = a
	self.GH:addObject(a) -- Add the peer to the GameHandler's objects table
end

-- Used for table lookups in peer table, given a peer entity
function NetworkHandler:locatePeer(ent, table)
	for i = 1, #table do
		if table[i].id == ent then return i end
	end
end

function NetworkHandler:locatePeerNetId(id)
	for i = 1, #GH.connectedIDs do
		if GH.connectedIDs[i] == id then return i end
	end
end

-- Receive packet stream of peers through the server
function NetworkHandler:receive()
	prevTime = 0
	repeat
		-- Read and parse packet
		receivedData, msg = self.udp:receive()
		if receivedData then
			if self.verbose_debug then print(receivedData) end

			-- Grammar definition
			local entity, cmd, parms = tostring(receivedData):match("^(%S*) *(%S*) *(.*)")
			if entity ~= self.GH.player.id then -- Broadcast Type Commands
				if cmd == 'join' then -- Broadcast Type
					local px, py, ps = parms:match("(-*%d+.*%d*) (-*%d+.*%d*) (%S+)")
							self:addPeer(entity, px, py, ps)
				end
				if cmd == 'leave' then -- Broadcast Type
					local peerNetID = GH.peers[self:locatePeer(entity, GH.peers)].networkID
					local peerNetIDLocation = self:locatePeerNetId(peerNetID)
					table.remove(self.peers, self:locatePeer(entity, self.peers))
					table.remove(self.GH.peers, self:locatePeer(entity, self.GH.peers))
					table.remove(GH.connectedIDs, peerNetIDLocation)
				end
				if cmd == 'moveto' then -- Broadcast Type
					local x, y = parms:match("^(%-?[%d.e]*) (%-?[%d.e]*)$")
					local ind = self:locatePeer(entity, self.peers)
					self.peers[ind].x = x
					self.peers[ind].y = y
				end
				if cmd == 'spawnprojectile' then -- Broadcast Type
					local x, y, size, angle, damage, speed, time = parms:match("(-*%d+.*%d*) (-*%d+.*%d*) (-*%d+.*%d*) (-*%d+.*%d*) (-*%d+.*%d*) (-*%d+.*%d*) (%d+.*%d*)")
					self.GH:createProjectile(x, y, size, angle, damage, speed, entity, time)
				end
				if cmd == 'start' then
					self.GH.gameStarted = true
				end
				if cmd == 'netid' then
					GH.peers[self:locatePeer(entity, GH.peers)].networkID = tonumber(parms)
					GH.connectedIDs[#GH.connectedIDs + 1] = tonumber(parms)
				end
			else -- Response Type Commands
				if cmd == 'rejoin' then -- Response Type
					GH.player.x, GH.player.y = parms:match("(-*%d+.*%d*) (-*%d+.*%d*)")
				end
				if cmd == 'yourid' then
					GH.player.networkID = tonumber(parms)
					GH.connectedIDs[#GH.connectedIDs + 1] = tonumber(parms)
				end
			end
		elseif msg~= 'timeout' then
			error("Network error: " ..tostring(msg))
		end
	until not receivedData
end


-- Maybe move these functions into their respective objects? *shrugs*

-- Broadcast update of the player's movement
function NetworkHandler:playerMove(id, x, y)
	self:send(id .. " moveto " .. x .. " " .. y)
end

-- Broadcast a projectile spawn by the player
function NetworkHandler:spawnProjectile(x, y, size, angle, damage, speed, creatorID, time)
	self:send(creatorID.." spawnprojectile "..x.." "..y.." "..size.." "..angle.." "..damage.." "..speed.." "..time)
end

function NetworkHandler:playerDeath(id)
	self:send(id.." died")
end
