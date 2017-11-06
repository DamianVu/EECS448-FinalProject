--- State play menu (module)
Play = {}

local centerX, centerY = love.graphics.getWidth()/2, love.graphics.getHeight()/2

--- Called on initialization (in main.lua)
function Play:init()
	self.options = {
		{"Singleplayer", "Multiplayer", "Back to character selection"}
	}
end

--- Called whenever this state is entered
function Play:enter()
	self.currentMenu = 1
	self.selection = 1
end

--- Called on game ticks to draw
function Play:draw()
	if self.currentMenu == 1 then
		love.graphics.setColor(255,255,255,255)
		love.graphics.setNewFont(30)

		love.graphics.print("Playing as: " .. USERNAME, centerX, 50)

		love.graphics.print(self.options[self.currentMenu][1], centerX, centerY)
		love.graphics.print(self.options[self.currentMenu][2], centerX, centerY + 50)
		love.graphics.print(self.options[self.currentMenu][3], centerX, centerY + 100)

		love.graphics.setColor(0,255,230,255)
		love.graphics.print("--->", centerX - 65, centerY + ((self.selection - 1) * 50) - 2)

	end
end

--- Event binding to listen for key presses
function Play:keypressed(key)
	if key == "return" then 
		if self.currentMenu == 1 then
			if self.selection == 1 then
				Gamestate.switch(Singleplayer)
			elseif self.selection == 2 then
				Gamestate.switch(Multiplayer)
			elseif self.selection == 3 then
				Gamestate.switch(CharacterSelection)
			end
		end
	end

	if key == "escape" then
		Gamestate.switch(CharacterSelection)
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


return Play