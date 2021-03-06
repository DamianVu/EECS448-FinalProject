---Class HUD
HeadsUpDisplay = class("HeadsUpDisplay", {})

--- Constructor for the in-game HUD.
function HeadsUpDisplay:init()
	-- "Default constructor" occurs when we initialize the HeadsUpDisplay
end

--- Draws the HUD on screen.
function HeadsUpDisplay:draw()

	self:drawPlayerHP()
	self:drawPlayerWeaponInfo()
end

--- Draws the HP portion of the HUD.
function HeadsUpDisplay:drawPlayerHP()
	local w,h = love.graphics.getDimensions()
	local barSize = w * .3

	local hpFraction = GH.player.health / GH.player.maxHP

	love.graphics.setColor(0,255,0)
	love.graphics.rectangle("fill", 10, 10, barSize * hpFraction, 40)

	love.graphics.setColor(200,200,200)
	love.graphics.rectangle("line", 9, 9, barSize + 2, 42)
	love.graphics.rectangle("line", 10, 10, barSize, 40)
end

--- Draws the weapon info for the selected weapon on the HUD .
function HeadsUpDisplay:drawPlayerWeaponInfo()
	local w,h = love.graphics.getDimensions()

	love.graphics.setColor(255,255,0)
	love.graphics.print("Current Weapon: " .. GH.IH:getItemName(GH.player.equipment.weapon), 10, h - 64)

	local barWidth = 300
	local barHeight = 30

	love.graphics.setColor(0,0,255)
	local drawWidth = barWidth
	if GH.player.attackDelay then
		drawWidth = (GH.player.attackTimer / GH.player.attackTimeout) * barWidth
	end
	love.graphics.rectangle("fill", 11, h - barHeight - 11, drawWidth, barHeight)

	love.graphics.setColor(200,200,200)
	love.graphics.rectangle("line", 11, h - barHeight - 11, barWidth, barHeight)
	love.graphics.rectangle("line", 10, h - barHeight - 12, barWidth + 2, barHeight + 2)
end
