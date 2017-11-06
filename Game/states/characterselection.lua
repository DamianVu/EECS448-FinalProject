
CS = {}

local menus = {
	{"", "Use this character", "Create new character", "Quit"}
}

local characters

local currentMenu
local currentItem
local currentCharacter

local centerX, centerY = love.graphics.getWidth()/2, love.graphics.getHeight()/2

function CS:init()

end

function CS:enter()
	currentMenu = 1
	currentItem = 1
	currentCharacter = 1
	characters = CharHandler:getCharacters()
	sprite = love.graphics.newImage('images/sprites/player.png')
end

function CS:draw()
	if currentMenu == 1 then

		love.graphics.setNewFont(40)
		if #characters > 0 then
			if currentItem == 1 then
				love.graphics.setColor(0,0,255)
			else
				love.graphics.setColor(255,255,255)
			end
			love.graphics.print("<--", centerX - 200, 40)
			love.graphics.print("-->", centerX + 200, 40)
			love.graphics.setColor(characters[currentCharacter].color)
			love.graphics.print(characters[currentCharacter].name, centerX - 80, 40)
			love.graphics.draw(sprite, centerX - 60, 150)
		else
			love.graphics.setColor(255,0,0)
			love.graphics.print("NO CHARACTERS", centerX, 40)
		end

		love.graphics.setColor(255,255,255)
		love.graphics.print(menus[currentMenu][2], centerX - 200, 400)
		love.graphics.print(menus[currentMenu][3], centerX - 200, 450)
		love.graphics.print(menus[currentMenu][4], centerX - 200, 500)

		love.graphics.setColor(0,0,255)
		if currentItem ~= 1 then
			love.graphics.print("-->", centerX - 300, 300 + (50 * currentItem))
		end

	end
end

function CS:keypressed(key)
	if currentMenu == 1 and currentItem == 1 then
		if #characters > 0 then
			if key == 'a' or key == 'left' then
				if currentCharacter == 1 then
					currentCharacter = #characters
				else
					currentCharacter = currentCharacter - 1
				end
			elseif key == 'd' or key == 'right' then
				if currentCharacter == #characters then
					currentCharacter = 1
				else
					currentCharacter = currentCharacter + 1
				end
			end
		end
	end

	if key == 'w' or key == 'up' then
		if currentItem == 1 then
			currentItem = #menus[currentMenu]
		else
			currentItem = currentItem - 1
		end
	end

	if key == 's' or key == 'down' then
		if currentItem == #menus[currentMenu] then
			currentItem = 1
		else
			currentItem = currentItem + 1
		end
	end

end

return CS