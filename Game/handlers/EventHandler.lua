
EventHandler = class("EventHandler", {})

lavaBug = love.graphics.newImage('images/sprites/lava_bug.png')
angryTourist = love.graphics.newImage('images/sprites/angry_tourist.png')
angryGhost = love.graphics.newImage('images/sprites/angry_ghost.png')
slimeMonster = love.graphics.newImage('images/sprites/slime_monster.png')

function EventHandler:init(seed)
	math.randomseed(seed)

	self.timer = 0

	self.updateRate = 1

	self.enemies = {{lavaBug, 1, 2, 2}, {angryTourist, 2, 1, 5}, {angryGhost, .5, 10, 10}, {slimeMonster, .8, 10, 5}}
end

function EventHandler:update(dt)
	self.timer = self.timer + dt
	if self.timer > self.updateRate then
		self:triggerEvent()
		self.timer = self.timer - self.updateRate
	end
end
function EventHandler:triggerEvent()
	if GH.multiplayer then
		table.sort(GH.connectedIDs)

		if math.random(2) == 1 then
			-- Spawn enemy
			local chaseObj = self:findByNetworkID(GH.connectedIDs[math.random(#GH.connectedIDs)])
		end



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

function EventHandler:findByNetworkID(id)
	if GH.player.networkID == id then return GH.player end
	for i = 1, #GH.peers do
		if GH.peers[i].networkID == id then return GH.peers[i] end
	end
end

