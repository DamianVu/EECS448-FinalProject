
GameOver = {}

function GameOver:enter()
	self.duration = 3
end

function GameOver:update(dt)
	self.duration = self.duration - dt
	if self.duration < 0 then
		Gamestate.switch(PlayMenu)
	end
end

function GameOver:draw()
	local w, h = love.graphics.getDimensions()
	love.graphics.setColor(255,0,0)
	love.graphics.rectangle("fill", 0, 0, w, h)

	love.graphics.setColor(0,0,0)
	love.graphics.setNewFont(40)
	love.graphics.print("Oh dear... You have died!", w/4, 3 * h / 7)
	love.graphics.print("Better luck next time", w/4, 4 * h / 7)
end

return GameOver