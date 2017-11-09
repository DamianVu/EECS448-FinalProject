---Current functionality is just movement and mouse cursor until we get maps and tiling implemented.


require "handlers.CollisionHandler"
require "handlers.MapHandler"
require "handlers.CharacterHandler"
require "handlers.LevelHandler"

require "libraries.cObject"
require "debugging"
require "netClient"

Gamestate = require "libraries.ext.gamestate"

SplashScreen = require "states.splashscreen"
Mainmenu = require "states.mainmenu"
Singleplayer = require "states.singleplayer"
Multiplayer = require "states.multiplayer"
Debugging = require "states.debugstate"
CharacterSelection = require "states.characterselection"
PlayMenu = require "states.playgame"

mouse = {}
movingObjects = {}
player = {}

math.randomseed(os.time())

-- Server connection information (Currently the AWS server info)
SERVER_ADDRESS, SERVER_PORT = "13.58.15.46", 5050
USERNAME = "Lane" -- String eventually
updateRate = 0.1


function love.load()

    if not love.filesystem.exists("characters") then
        love.filesystem.createDirectory("characters")
    end

    CharHandler = CharacterHandler()

    -- Set up window
    --windowWidth = 1600
    --windowHeight = 900
    --love.window.setMode(windowWidth, windowHeight, {resizable=false, vsync=false, minwidth=800, minheight=600, borderless=true, msaa=2})

    Gamestate.registerEvents()
    Gamestate.switch(SplashScreen)

    love.mouse.setVisible(false)

    -- Physics variables
    base_speed = 250
    base_slowdown_counter = 5 -- Game will wait this many game ticks before velocity comes to a halt



    -- Code that will cap FPS at 144
    min_dt = 1/160
    next_time = love.timer.getTime()
    -- End Code that will cap FPS at 144

end

function love.draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle("line", mouse.x, mouse.y, 5)
end

function love.update(dt)
    -- Code that will cap FPS at 144
    next_time = next_time + min_dt

    -- Get current mouse position and store in object mouse
    mouse.x, mouse.y = love.mouse.getPosition()


end

function love.keypressed(key)

end


function love.quit()
    print("Game closed")
end
