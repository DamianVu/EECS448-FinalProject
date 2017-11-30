--- State play menu (module)
Lobby = {}

local centerX, centerY = love.graphics.getWidth()/2, love.graphics.getHeight()/2


--- Called on initialization (in main.lua)
function Lobby:init()

end

--- Called on entrance to lobby menu screen
function Lobby:enter()

  -- Our LobbyHandler, referred to as LOBBY
	self.LOBBY = LobbyHandler(GH, SERVER_ADDRESS, LOBBY_PORT) -- IP is that of vuhoo.org, Port is 5001

  self.options = self.LOBBY.menu
  self.currentMenu = 1
  self.selection = 1

end

--- Called on game ticks to draw
function Lobby:draw()
	if self.currentMenu == 1 then
		love.graphics.setColor(255,255,255,255)
		love.graphics.setNewFont(30)

		love.graphics.print("Playing as: " .. USERNAME, centerX, 50)


    -- Print menu items (lobbies + create new)
    local drawY = 0
    for i = 1, #self.options do
      love.graphics.print(self.options[i], centerX, centerY + drawY)
      drawY = drawY + 50
    end

    -- Selection highlighter
		love.graphics.setColor(0,255,230,255)
		love.graphics.print("--->", centerX - 65, centerY + ((self.selection - 1) * 50) - 2)

	end
end

--- Called every game tick
function Lobby:update(dt)
	self.LOBBY:receive()
end

--- Called when this state has been left
function Lobby:leave()
	print("leaving lobby and disconnecting from lobby server...")
	self.LOBBY:disconnect()
	print("left")
end

--- Called if the user closes the game while in this state
function Lobby:quit()
	self.LOBBY:disconnect()
end

function Lobby:setGame(opt, serverIndex)
	if opt == 'new' then
		print("Creating new game...")
		self.LOBBY:newGame(USERNAME) -- Just sending the username to create a '<username>'s game' name
		print("Game created.")
	elseif opt == 'join' then
		print("Joining...")
		local selectedServer = self.LOBBY.lobbies[serverIndex] 		-- Set the selected lobby
		self.LOBBY:joinGame(selectedServer)
	end
end

--- Event binding to listen for key presses
function Lobby:keypressed(key)

  -- Selected an option
	if key == "return" then
		if self.options[self.selection] == "Create New Game" then
				self:setGame('new')
		else
			self:setGame('join', self.selection)
		end
	end

  -- back out with ESC
	if key == "escape" then
		Gamestate.switch(PlayMenu)
	end

	if key == "s" or key == "down" then
		if self.selection == #self.options then
			self.selection = 1
		else
			self.selection = self.selection + 1
		end
	end

	if key == "w" or key == "up" then
		if self.selection == 1 then
			self.selection = #self.options
		else
			self.selection = self.selection - 1
		end
	end
end





return Lobby
