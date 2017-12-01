
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
	local num = math.random(5)
	print(num)
	if num == 1 then
		--for i = 1, math.random(4) do
		num1 = math.random(#GH.connectedIDs)
		print(num1)
		num2 = math.random(96,400)
		print(num2)
		num3 = math.random(96,400)
		print(num3)

		local chaseObj = self:findByNetworkID(GH.connectedIDs[num1])
		GH:addObject(Enemy(GH:getNewUID(), lavaBug, {255,255,255}, .99, 1, num2, num3, 32, 32, 5, 1, chaseObj))
	end
	if num == 2 then
		--for i = 1, math.random(4) do
		num1 = math.random(#GH.connectedIDs)
		print(num1)
		num2 = math.random(96,400)
		print(num2)
		num3 = math.random(96,400)
		print(num3)

		local chaseObj = self:findByNetworkID(GH.connectedIDs[num1])
		GH:addObject(Enemy(GH:getNewUID(), angryTourist, {255,255,255}, .99, 1, num2, num3, 32, 32, 5, 1, chaseObj))
	end
	if num == 3 then
		--for i = 1, math.random(4) do
		num1 = math.random(#GH.connectedIDs)
		print(num1)
		num2 = math.random(96,400)
		print(num2)
		num3 = math.random(96,400)
		print(num3)

		local chaseObj = self:findByNetworkID(GH.connectedIDs[num1])
		GH:addObject(Enemy(GH:getNewUID(), angryGhost, {255,255,255}, .99, 1, num2, num3, 32, 32, 5, 1, chaseObj))
	end
end

function EventHandler:findByNetworkID(id)
	if GH.player.networkID == id then return GH.player end
	for i = 1, #GH.peers do
		if GH.peers[i].networkID == id then return GH.peers[i] end
	end
end

