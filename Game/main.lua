---Current functionality is just movement and mouse cursor until we get maps and tiling implemented.


require "handlers.CollisionHandler"
require "handlers.MapHandler"
require "handlers.CharacterHandler"
require "handlers.LevelHandler"

require "libraries.classes.cObject"
require "libraries.classes.CoordinateList"
require "libraries.classes.Map"
require "libraries.classes.Tile"
require "libraries.classes.TileMapping"
require "libraries.classes.MCTile"


require "debugging"
require "netClient"

require 'resources.rawmaps' -- Revamp for project 4



Gamestate = require "libraries.ext.gamestate"

SplashScreen = require "states.splashscreen"
Mainmenu = require "states.mainmenu"
Singleplayer = require "states.singleplayer"
Multiplayer = require "states.multiplayer"
Debugging = require "states.debugstate"
CharacterSelection = require "states.characterselection"
PlayMenu = require "states.playgame"
MapCreator = require "states.mapcreator"

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


    love.mouse.setVisible(false)

    -- Set up window
    --windowWidth = 1600
    --windowHeight = 900
    --love.window.setMode(windowWidth, windowHeight, {resizable=false, vsync=false, minwidth=800, minheight=600, borderless=true, msaa=2})

    Gamestate.registerEvents()
    Gamestate.switch(MapCreator)


    -- Physics variables
    base_speed = 250
    base_slowdown_counter = 5 -- Game will wait this many game ticks before velocity comes to a halt


    arrowCursor = love.mouse.getSystemCursor("arrow")
    handCursor = love.mouse.getSystemCursor("hand")

    -- Code that will cap FPS at 144
    min_dt = 1/160
    next_time = love.timer.getTime()
    -- End Code that will cap FPS at 144

end

function love.draw()

    if Gamestate.current() ~= MapCreator then
        love.graphics.setColor(255, 255, 255)
        love.graphics.circle("line", mouse.x, mouse.y, 5)
    end
end

function love.update(dt)
    -- Code that will cap FPS at 144
    next_time = next_time + min_dt

    -- Get current mouse position and store in object mouse
    mouse.x, mouse.y = love.mouse.getPosition()


end

function love.keypressed(key)

end

function love.wheelmoved(x, y)
    if Gamestate.current() == MapCreator then
        if canZoom then
            if y < 0 and zoom <= minZoom then 
                zoom = minZoom
                return
            end
            if y > 0 and zoom >= maxZoom then
                zoom = maxZoom
                return
            end
            zoom = zoom * (1 + (y * .2))
        else
            -- Scroll through tiles
            MCH:changeTile(y)
        end
    end
end


function love.quit()
    print("Game closed")
end
