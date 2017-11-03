require 'libraries.ext.30log'

GameStateHandler = class("GameStateHandler", {states = {}})


function GameStateHandler:init()
	self.currentState = 1
	self.states[1] = "Loading"
	self.states[2] = "Menu"
	self.states[3] = "Playing map"

end

function GameStateHandler:getGameState()
	return self.currentState
end

function GameStateHandler:setGameState(state)
	self.currentState = state
end