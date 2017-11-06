--- State main menu (module)
-- This handles all menu operations after the splash screen
Menu = {}

options = {
	{"Play", "Options", "Exit"},
	{"No options yet..."}
}

local centerX, centerY = love.graphics.getWidth()/2, love.graphics.getHeight()/2

-- Called when this state is entered
function Menu:enter()
	self.currentMenu = 1
	self.selection = 1
end

-- Called every game tick (for drawing operations)
function Menu:draw()
	if self.currentMenu == 1 then
		love.graphics.setColor(255,255,255,255)
		love.graphics.setNewFont(30)

		love.graphics.print(options[self.currentMenu][1], centerX - 100, centerY - 100)
		love.graphics.print(options[self.currentMenu][2], centerX - 100, centerY - 50)
		love.graphics.print(options[self.currentMenu][3], centerX - 100, centerY)

		love.graphics.setColor(0,255,230,255)
		love.graphics.print("--->", centerX - 165, centerY - 100 + ((self.selection - 1) * 50) - 2)

	elseif self.currentMenu == 2 then
		love.graphics.setColor(255,255,255,255)
		love.graphics.print("Nothing here yet...", centerX, centerY)
		love.graphics.print("Back", centerX, centerY + 50)

		love.graphics.setColor(0,255,230,255)
		love.graphics.print("--->", centerX - 65, centerY + ((self.selection - 1) * 50) - 2)
	else

	end
end

-- Binds handler for key presses
function Menu:keypressed(key)
	if key == "return" then
		if self.currentMenu == 1 then
			if self.selection == 1 then
				Gamestate.switch(CharacterSelection)
			elseif self.selection == 2 then
				self.currentMenu = 2
				self.selection = 2
			elseif self.selection == 3 then
				love.event.quit()
			end
		elseif self.currentMenu == 2 then
			if self.selection == 2 then
				self.currentMenu = 1
				self.selection = 2
			end
		end
	end

	if key == "escape" then
		if self.currentMenu == 1 then
			love.event.quit()
		elseif self.currentMenu == 2 then
			self.currentMenu = 1
		end
	end

	if self.currentMenu ~= 2 then
	if key == "w" or key == "up" then
		if self.selection == 1 then
			self.selection = #options[self.currentMenu]
		else
			self.selection = self.selection - 1
		end
	end

	if key == "s" or key == "down" then
		if self.selection == #options[self.currentMenu] then
			self.selection = 1
		else
			self.selection = self.selection + 1
		end
	end
	end
end


return Menu
