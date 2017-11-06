
Debugging = {}

local centerX, centerY = love.graphics.getWidth()/2, love.graphics.getHeight()/2

function Debugging:init()
	characterDir = "characters"

	--success, message = love.filesystem.write("characters/test.dat", "THIS IS A TEST\nThis should be on the second line\nAnd this the third")

	--CharacterHandler:getCharacters()

	--files = love.filesystem.getDirectoryItems(characterDir)
end

function Debugging:load()
	files = love.filesystem.getDirectoryItems(characterDir)
	saveDir = love.filesystem.getSaveDirectory()
end

function Debugging:draw()
	love.graphics.setNewFont(40)
	love.graphics.print("Files: " .. #files, centerX, 40)
	love.graphics.setNewFont(16)
	for ind, file in ipairs(files) do
		love.graphics.print(ind .. " : " .. file, centerX, 80 + (20 * ind))
	end
	love.graphics.print("Char Dir: " .. characterDir, centerX, 500)
	love.graphics.print("Tried to write: " .. tostring(success), centerX, 550)
	love.graphics.print("Does the folder exist?: " .. tostring(love.filesystem.exists("characters")), centerX, 600)

end




return Debugging