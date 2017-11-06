---
Splash = {}

local centerX, centerY = love.graphics.getWidth()/2, love.graphics.getHeight()/2

function Splash:enter()
	self.duration = 5 -- 4 seconds
end

function Splash:update(dt)
	self.duration = self.duration - dt
	if self.duration < 0 then
		Gamestate.switch(Mainmenu)
	end
end

function Splash:draw()
	love.graphics.setColor(255,255,255, 255/(self.duration*self.duration))
	love.graphics.setNewFont(60)
	love.graphics.print("Wubba lubba dub dub", centerX, centerY)
	love.graphics.setNewFont(25)
	love.graphics.print("slang/colloquialism",centerX, centerY + 80)
	love.graphics.setNewFont(18)
	love.graphics.print("1. I am in great pain, please help me.", centerX + 10, centerY + 105)
end

function Splash:keypressed(key)
	if key then
		Gamestate.switch(Mainmenu)
	end
end

return Splash
