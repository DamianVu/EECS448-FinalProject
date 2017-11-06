---
require "libraries.ext.30log"

CharacterHandler = class("CharacterHandler", {})

--- Initializes Character Handler.
-- This function initializes the handler for character creation/management.
function CharacterHandler:init()
	-- Load users from character save folder
	self.characterFiles = love.filesystem.getDirectoryItems("characters")
end

--- Refreshes Character Handler.
-- This function refreshes the character handler
function CharacterHandler:refresh()
	self.characterFiles = love.filesystem.getDirectoryItems("characters")
end

--- Gets the characters saved on the machine.
-- This function gets the characters to display in the character handler
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

--- Saves the current character.
-- Saves the current character in the character handler
function CharacterHandler:saveCurrentCharacter()

end

<<<<<<< HEAD
=======
--- Add a character to the character handler
-- Add a character to the character handler
>>>>>>> 216ddce73ef625b046097179b06ca1896154ed5c
function CharacterHandler:addCharacter(name, color)
	local r,g,b = unpack(color)

	local data = name .. "\n" .. tostring(math.random(99999)) .. "\n" .. r .. "," .. g .. "," .. b

	local fname = name:gsub('%W', '')

	if love.filesystem.exists("characters/" .. fname .. ".dat") then
		local created = false
		local i = 1
		repeat
			if love.filesystem.exists("characters/" .. fname .. "(" .. i .. ").dat") then
				i = i + 1
			else
				love.filesystem.write("characters/" .. fname .. "(" .. i .. ").dat", data)
				created = true
			end
		until created
	else
		love.filesystem.write("characters/" .. fname .. ".dat", data)
	end
end
