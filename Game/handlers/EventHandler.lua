
EventHandler = class("EventHandler", {})

function EventHandler:init(seed)
	math.randomseed(seed)

	self.timer = 0

	self.updateRate = 1
end

function EventHandler:update(dt)
	self.timer = self.timer + dt
	if self.timer > self.updateRate then
		self:triggerEvent()
		self.timer = self.timer - self.updateRate
	end
end
function EventHandler:triggerEvent(EVENT)
	if math.random(3) == 1 then
		--for i = 1, math.random(4) do
			GH:addObject(Enemy(GH:getNewUID(), love.graphics.newImage('images/sprites/lava_bug.png'), {255,255,255}, .99, 1, math.random(96,400), math.random(96,400), 32, 32, 5, 1))
		end
	if math.random(2) == 1 then
		GH:addObject(Enemy(GH:getNewUID(), love.graphics.newImage('images/sprites/angry_tourist.png'), {255,255,255}, .2, 1, math.random(96,400), math.random(96,400), 32, 32, 5, 1))
end
if math.random(20) == 1 then
	GH:addObject(Enemy(GH:getNewUID(), love.graphics.newImage('images/sprites/angry_ghost.png'), {255,255,255}, 1.1, 1, math.random(96,400), math.random(96,400), 32, 32, 5, 1))
end
end
