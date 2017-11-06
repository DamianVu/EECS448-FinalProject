--- Splash screen state (module)
Splash = {}

local centerX, centerY = love.graphics.getWidth()/2, love.graphics.getHeight()/2

--- Called when state is entered
function Splash:enter()
	self.duration = 5 -- 4 seconds
end

--- Called on every game tick
function Splash:update(dt)
	self.duration = self.duration - dt
	if self.duration < 0 then
		Gamestate.switch(Mainmenu)
	end
end

--- Draws logo to screen
function Splash:draw()
	love.graphics.setColor(255,255,255, 255/(self.duration*self.duration))
	love.graphics.setNewFont(60)
	love.graphics.print("Wubba lubba dub dub", centerX, centerY)
	love.graphics.setNewFont(25)
	love.graphics.print("slang/colloquialism",centerX, centerY + 80)
	love.graphics.setNewFont(18)
	love.graphics.print("1. I am in great pain, please help me.", centerX + 10, centerY + 105)
end

--- Listens for key presses
-- Enters main menu if anything is pressed prior to 5 seconds finishing
function Splash:keypressed(key)
	if key then
		Gamestate.switch(Mainmenu)
	end
end

return Splash
