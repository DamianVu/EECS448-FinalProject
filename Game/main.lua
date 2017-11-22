---Current functionality is just movement and mouse cursor until we get maps and tiling implemented.

class = require 'libraries.ext.30log'

require "GAMECONSTANTS"

require "handlers.CollisionHandler"
require "handlers.MapHandler"
require "handlers.CharacterHandler"
require "handlers.LevelHandler"
require "handlers.NewCollisionHandler"
require "handlers.ItemHandler"

require "libraries.classes.cObject"
require "libraries.classes.CoordinateList"
require "libraries.classes.Map"
require "libraries.classes.Tile"
require "libraries.classes.TileMapping"

require "libraries.classes.objects.Player"
require "libraries.classes.objects.Terrain"
require "libraries.classes.objects.Projectile"
require "libraries.classes.objects.Enemy"

require "libraries.classes.MCTile"
require "libraries.classes.MapObject"
require "libraries.classes.HeadsUpDisplay"

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
GameOver = require "states.gameover"

mouse = {}
movingObjects = {}
player = {}

math.randomseed(os.time())

-- Server connection information (Currently the AWS server info)


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
    Gamestate.switch(Singleplayer)


    -- Physics variables
    base_speed = 250


    arrowCursor = love.mouse.getSystemCursor("arrow")
    handCursor = love.mouse.getSystemCursor("hand")
end

function love.draw()

end

function love.update(dt)

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
