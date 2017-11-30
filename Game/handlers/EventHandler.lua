
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
	if math.random(2) == 1 then
		GH:addObject(Enemy(GH:getNewUID(), nil, nil, .5, 1, 96, 96, 32, 32, 5, 1))
	end
end