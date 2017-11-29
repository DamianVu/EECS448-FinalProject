
class = require 'libraries.ext.30log'

LobbyHandler = class("LobbyHandler", {})

-- Constructor for the LobbyHandler
function LobbyHandler:init(GH, ip, port)
	self.socket = require "socket"
  self.lobbyIP = ip
	self.lobbyPort = port
	self.verbose_debug = true
	self.count = 0
	self.lobbies = {}
	self.menu = {}
	self.udp = nil
	self.messageCount = 0
	self:connect()
end

-- Connect to the Lobby server
function LobbyHandler:connect()
	self.udp = socket.udp()
	self.udp:setpeername(self.lobbyIP, self.lobbyPort)
	self.udp:settimeout(0)

	print("Successfully connected to lobby. Retrieving server list...")
	self:fetchMenu()
end

-- Close the peer-type connection to the lobby server
function LobbyHandler:disconnect()
	self.udp:close()
end

function LobbyHandler:fetchMenu()
	self:fetchLobbyInfo()

	print("Populating server list...")
	repeat -- Populate the lobbylist, waiting until completion
		self:receive()
	until #self.lobbies == self.count
	print("Populated. "..self.count.." games found.")


	self.menu[#self.menu + 1] = "Create New Game"
	return self.menu
end

function LobbyHandler:fetchLobbyInfo()
	self:send( USERNAME..USERID.." countlobbies") -- Set number of lobbies to wait for
	self:send( USERNAME..USERID.." fetchlobbies") -- Request the lobbies and wait for the list to populate
end

-- Send a packet to the server
function LobbyHandler:send(packet)
	if self.verbose_debug then print("Sending to matchmaking server: "..packet) end
	self.udp:send(packet)
	self.messageCount = self.messageCount + 1
end

-- Receive responses from the lobby server
function LobbyHandler:receive()
	repeat
		-- Read and parse packet
		receivedData, msg = self.udp:receive()
		if receivedData then
			if self.verbose_debug then print(receivedData) end

			-- Grammar definition
			local entity, cmd, parms = tostring(receivedData):match("^(%S*) (%S*) *(.*)")
			if entity ~= USERNAME..USERID then -- Broadcast Type Commands
				-- NO BROADCAST TYPE COMMANDS
			else -- Response Type Commands
				if cmd == 'lobby' then -- Response Type
					self.lobbies[#self.lobbies + 1] = parms:match("^(%S*)")
				elseif cmd == 'countlobbies' then
					self.count = parms:match("^(%d+)")
				end
			end
		elseif msg~= 'timeout' then
			error("Network error: " ..tostring(msg))
		end
	until not receivedData
end

-- LOBBY PROTOCOL --
-- Stages of a request/response for matchmaking information

-- 1 - A request is sent to the lobby server for lobby information

-- 2 - The number of game lobbies is sent back to the client in the form of  '<client> countlobbies'
--------------------
