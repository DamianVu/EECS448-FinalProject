
EventHandler = class("EventHandler", {})

lavaBug = love.graphics.newImage('images/sprites/lava_bug.png')
angryTourist = love.graphics.newImage('images/sprites/angry_tourist.png')
angryGhost = love.graphics.newImage('images/sprites/angry_ghost.png')

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
		local chaseObj = self:findByNetworkID(GH.connectedIDs[math.random(#GH.connectedIDs)])
		GH:addObject(Enemy(GH:getNewUID(), lavaBug, {255,255,255}, .99, 1, math.random(96,400), math.random(96,400), 32, 32, 5, 1, chaseObj))
	end
	if math.random(2) == 1 then
		local chaseObj = self:findByNetworkID(GH.connectedIDs[math.random(#GH.connectedIDs)])
		GH:addObject(Enemy(GH:getNewUID(), angryTourist, {255,255,255}, .2, 1, math.random(96,400), math.random(96,400), 32, 32, 5, 1, chaseObj))
	end
	if math.random(20) == 1 then
		local chaseObj = self:findByNetworkID(GH.connectedIDs[math.random(#GH.connectedIDs)])
		GH:addObject(Enemy(GH:getNewUID(), angryGhost, {255,255,255}, 1.1, 1, math.random(96,400), math.random(96,400), 32, 32, 5, 1, chaseObj))
	end
end

function EventHandler:findByNetworkID(id)
	if GH.player.networkID == id then return GH.player end
	for i = 1, #GH.peers do
		if GH.peers[i].networkID == id then return GH.peers[i] end
	end
end