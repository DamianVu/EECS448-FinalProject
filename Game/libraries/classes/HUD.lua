
HUD = class("HUD", {})

function HUD:init()
	-- "Default constructor" occurs when we initialize the HUD
end

function HUD:draw()

	self:drawPlayerHP()
end

function HUD:drawPlayerHP()
	local w,h = love.graphics.getDimensions()
	local barSize = w * .3

	local hpFraction = player.health / player.maxHP

	love.graphics.setColor(0,255,0)
	love.graphics.rectangle("fill", 10, 10, barSize * hpFraction, 40)

	love.graphics.setColor(200,200,200)
	love.graphics.rectangle("line", 9, 9, barSize + 2, 42)
	love.graphics.rectangle("line", 10, 10, barSize, 40)
end