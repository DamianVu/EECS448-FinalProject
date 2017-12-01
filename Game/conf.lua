--- Configurations.
-- This function contains the configuration for the game
function love.conf(t)
	t.identity = "Wubba"
	t.console = false


	t.window.width = 1600
	t.window.height = 900


	-- Modules: Disable unused to save memory!!!
	t.modules.joystick = false
	t.modules.physics = false


end
