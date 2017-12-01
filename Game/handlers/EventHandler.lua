---Handler Event Handler.
EventHandler = class("EventHandler", {})

--Types of enemies
lavaBug = love.graphics.newImage('images/sprites/lava_bug.png')
angryTourist = love.graphics.newImage('images/sprites/angry_tourist.png')
angryGhost = love.graphics.newImage('images/sprites/angry_ghost.png')
slimeMonster = love.graphics.newImage('images/sprites/slime_monster.png')
---EventHandler Constructor.
function EventHandler:init(seed)
	math.randomseed(seed)

	self.timer = 0

	self.updateRate = 1

	self.enemies = {{lavaBug, 1, 2, 2}, {angryTourist, 2, 1, 5}, {angryGhost, .5, 10, 10}, {slimeMonster, .8, 10, 5}}
end
---Eventhandler update.
function EventHandler:update(dt)
	self.timer = self.timer + dt
	if self.timer > self.updateRate then
		self:triggerEvent()
		self.timer = self.timer - self.updateRate
	end
end
---EventHandler TriggerEvent.
function EventHandler:triggerEvent()
	if GH.multiplayer then
		table.sort(GH.connectedIDs)

		if math.random(2) == 1 then
		local radius = 200
			for i = 1, math.random(#GH.connectedIDs) do
				local angle = math.random(100) * math.pi * 2 / 100

				local enemy = self.enemies[math.random(#self.enemies)]

				local chaseObj = self:findByNetworkID(GH.connectedIDs[math.random(#GH.connectedIDs)])

				GH:addObject(Enemy(GH:getNewUID(), enemy[1], {255,255,255}, enemy[2], 1, chaseObj.x + math.cos(angle) * radius, chaseObj.y + math.sin(angle) * radius, 32, 32, enemy[3], enemy[4], chaseObj))
			end
		end
	else
		if math.random(2) == 1 then
			local radius = 200

			for i = 1, math.random(3) do
				local angle = math.random(100) * math.pi * 2 / 100

				local enemy = self.enemies[math.random(#self.enemies)]
				GH:addObject(Enemy(GH:getNewUID(), enemy[1], {255,255,255}, enemy[2], 1, GH.player.x + math.cos(angle) * radius, GH.player.y + math.sin(angle) * radius, 32, 32, enemy[3], enemy[4], GH.player))
			end
		end
	end
end
---EventHandler findByNetworkID.
function EventHandler:findByNetworkID(id)
	if GH.player.networkID == id then return GH.player end
	for i = 1, #GH.peers do
		if GH.peers[i].networkID == id then return GH.peers[i] end
	end
end
