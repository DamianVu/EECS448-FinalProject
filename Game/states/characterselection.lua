
CS = {}

local menus = {
	{"", "Use this character", "Create new character", "Back"}, -- Main screen
	{"Name: ", "Randomize Color", "Create", "Cancel"}
}

local characters

local currentMenu
local currentItem
local currentCharacter

local charColors = {math.random(255), math.random(255), math.random(255)}

local centerX, centerY = love.graphics.getWidth()/2, love.graphics.getHeight()/2

local textInput = false

local badKeys = { -- Lol let's make this a library next time!!!!
	"rshift","lshift", -- Gotta remove these later so we can have capital letters.....
	"kp0","kp1","kp2","kp3","kp4","kp5","kp6","kp7","kp8","kp9","kp.","kp,","kp/","kp*","kp-","kp+","kpenter","kp=",
	"right","left","home","end","pageup","pagedown","insert","tab","clear","return","delete",
	"f1","f2","f3","f4","f5","f6","f7","f8","f9","f10","f11","f12","f13","f14","f15","f16","f17","f18",
	"numlock","scrolllock","rshift","lshift","rctrl","lctrl","ralt","lalt","rgui","lgui","mode",
	"www","mail","calculator","computer","appsearch","apphome","appback","appforward","apprefresh","appbookmarks",
	"pause","help","printscreen","sysreq","menu","application","power","currencyunit","undo"
}

local function isBadKey(key)
	for i = 1, #badKeys do
		if key == badKeys[i] then
			return true
		end
	end
	return false
end

function CS:init()

end

function CS:enter()
	currentMenu = 1
	currentItem = 1
	currentCharacter = 1
	characters = CharHandler:getCharacters()
	sprite = love.graphics.newImage('images/sprites/player.png')
	createName = ""
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
			love.graphics.print("-->", centerX + 170, 40)
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

	elseif currentMenu == 2 then
		local extra = ""
		if textInput then
			extra = "_"
		end
		love.graphics.setColor(charColors)
		love.graphics.draw(sprite, centerX - 100, 200)

		love.graphics.setColor(255,255,255)
		love.graphics.print(menus[currentMenu][1] .. createName .. extra, centerX - 200, 400)
		love.graphics.print(menus[currentMenu][2], centerX - 200, 450)
		love.graphics.print(menus[currentMenu][3], centerX - 200, 500)
		love.graphics.print(menus[currentMenu][4], centerX - 200, 550)
		love.graphics.setColor(0,0,255)
		love.graphics.print("-->", centerX - 275, 400 + ((currentItem - 1) * 50))
	end
end

function CS:update(dt)
	if currentMenu == 2 and currentItem == 1 then
		textInput = true
	else
		textInput = false
	end
end

function CS:keypressed(key)

	if key == 'return' then
		if currentMenu == 1 then
			if currentItem == 2 then
				-- Go to Single/multiplayer select
				if #characters == 0 then
					return
				end
				USERNAME = characters[currentCharacter].name .. tostring(characters[currentCharacter].salt)
				Gamestate.switch(PlayMenu)
			elseif currentItem == 3 then
				-- Create a player
				currentMenu = 2
				currentItem = 1
				createName = ""
			elseif currentItem == 4 then
				-- Go back to main menu
				Gamestate.switch(Mainmenu)
			end
		elseif currentMenu == 2 then
			if currentItem == 2 then
				-- Randomize colors
				charColors = {math.random(255),math.random(255),math.random(255)}
			elseif currentItem == 3 then
				-- Create character
				if createName ~= "" then
					CharHandler:addCharacter(createName, charColors)
					CharHandler:refresh()
					characters = CharHandler:getCharacters()
					currentMenu = 1
					currentItem = 2
					currentCharacter = #characters
				else

				end
			elseif currentItem == 4 then
				currentMenu = 1
				currentItem = 1
			end
		end

		return
	end

	if not textInput then
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
	else
		if isBadKey(key) then
			return
		else
			local typing = true
			if key == 'up' then
				currentItem = #menus[2]
				typing = false
			end
			if key == 'down' then
				currentItem = 2
				typing = false
			end
			if key == 'backspace' then
				if string.len(createName) > 0 then
					createName = string.sub(createName, 1, string.len(createName) - 1)
				end
				typing = false
			end
			if typing then
				createName = createName .. key
			end
		end
	end

end

return CS