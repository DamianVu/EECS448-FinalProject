
require "libraries.ext.30log"

CharacterHandler = class("CharacterHandler", {})

function CharacterHandler:init()
	-- Load users from data folder
	self.characterFiles = love.filesystem.getDirectoryItems("characters")
end

function CharacterHandler:getCharacters()
	local characters = {}

	

	return characters
end