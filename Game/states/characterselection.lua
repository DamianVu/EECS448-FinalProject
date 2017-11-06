
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
end

function CS:draw()
	if currentMenu == 1 then

		love.graphics.setNewFont(40)
		if #characters > 0 then
			love.graphics.print(characters[currentCharacter].name, centerX, 40)
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
			
		end
	end

end

return CS