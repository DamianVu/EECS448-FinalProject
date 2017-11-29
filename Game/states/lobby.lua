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

	}
end

--- Called whenever this state is entered
function Lobby:enter()
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
      love.graphics.print(self.options[i][1]..(self.options[i][2] or ""), centerX, centerY + drawY)
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
	self.LOBBY:disconnect()
end

--- Called if the user backs out from the lobby state
function Lobby:quit()

end


function Lobby:setServer(opt, serverIndex)
	if opt == 'new' then
		-- TODO Implement game creation state

	elseif opt == 'join' then

		-- Set the selected lobby
		local selectedServer = self.LOBBY.lobbies[serverIndex]



	end
end


--- Event binding to listen for key presses
function Lobby:keypressed(key)

  -- Selected an option
	if key == "return" then
		if self.selection == #self.options then
				self:setServer('new')
		else
			self:setServer('join', self.selection)
		end
	end

  -- backec out with ESC
	if key == "escape" then
		Gamestate.switch(PlayMenu)
	end

	if key == "s" or key == "down" then
		if self.selection == #self.options[self.currentMenu] then
			self.selection = 1
		else
			self.selection = self.selection + 1
		end
	end

	if key == "w" or key == "up" then
		if self.selection == 1 then
			self.selection = #self.options[self.currentMenu]
		else
			self.selection = self.selection - 1
		end
	end
end





return Lobby
