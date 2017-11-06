
require "libraries.ext.30log"

CharacterHandler = class("CharacterHandler", {})

function CharacterHandler:init()
	-- Load users from character save folder
	self.characterFiles = love.filesystem.getDirectoryItems("characters")
end

function CharacterHandler:getCharacters()
	-- Process each character file
	local characters = {}

	if #self.characterFiles == 0 then
		return {}
	end

	for i=1, #self.characterFiles do
		local char = {}
		local j = 1
		for line in love.filesystem.lines("characters/" .. self.characterFiles[i]) do
			if j == 1 then
				char.name = line
			elseif j == 2 then
				char.salt = line
			elseif j == 3 then
				local r,g,b = line:match("(%d+),(%d+),(%d+)")
				char.color = {tonumber(r),tonumber(g),tonumber(b)}
			end
			j = j + 1
		end
		characters[#characters + 1] = char
	end

	return characters
end

function CharacterHandler:saveCurrentCharacter()

end

function CharacterHandler:addCharacter(name, color)	
	local r,g,b = unpack(color)

end