-- Current functionality is just movement and mouse cursor until we get maps and tiling implemented


require "netClient"
require "tiling"
require "libraries.collisionhandler"
require "libraries.cObject"
require "debugging"
require "libraries.gamestate"
require "handlers.maphandler"

mouse = {}
player = {}

movingObjects = {}

-- Server connection information (Currently the AWS server info)
--SERVER_ADDRESS, SERVER_PORT = "13.58.15.46", 5050
--USERNAME = "user"
-- sX, sY, sR, sG, sB = 96, 96, 255, 255, 255 TODO


function love.load()


    -- Initialize connection to server
    --connectToServer(SERVER_ADDRESS, SERVER_PORT)

    -- Spawn receiver thread to receive buffer updates from the server
    --spawnReceiver()


    windowWidth = 1600
    windowHeight = 900

    love.window.setMode(windowWidth, windowHeight, {resizable=false, vsync=false, minwidth=800, minheight=600, borderless=true, msaa=2})
    --love.window.setFullscreen(true, "desktop")

    -- Load tileset
    load_tileset()

    -- Make mouse invisible so we can use a custom cursor --
    love.mouse.setVisible(false)

    GS = GameStateHandler()

    MH = MapHandler()

    -- Global Game variables
    base_speed = 250
    debugMode = false
    base_slowdown_counter = 5 -- Game will wait this many game ticks before velocity comes to a halt

    -- Initialize player by calling cObject constructor
    player = cObject(nil, love.graphics.newImage('images/sprites/player.png'), 1, 96, 96, 32, 32)

    movingObjects[#movingObjects + 1] = player

    -- Collision Handler initialization --
    CH = CollisionHandler()
    CH:addObj(player)

    -- Code that will cap FPS at 144
    min_dt = 1/144
    next_time = love.timer.getTime()
    -- End Code that will cap FPS at 144
end

function love.draw()

    -- These values are used to move the camera, and also to get the absolute mouse position relative to the map --
    if CH.playerMovement then
        x_translate_val = (windowWidth / 2) - player.x
        y_translate_val = (windowHeight / 2) - player.y
    end

    -- This stack push begins the code that makes our camera follow our player. Everything that needs to stay in place should be here
    love.graphics.push()
    love.graphics.translate(x_translate_val, y_translate_val)

    draw_tiles() -- from tiling.lua
    if debugMode then
        highlightTiles(player)
    end

    -- Draw player --
    player:draw()
    --love.graphics.circle("fill", player.x, player.y, 2) -- Dot at center of player

    if debugMode then
      player:drawHitbox()
    end

    love.graphics.pop()
    -- This stack pop ends the code for the camera following. Anything that should stay in place on screen should follow this

    -- Draw circle where mouse is --
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle("line", mouse.x, mouse.y, 5) -- "line" is outline, 5 is radius

    -- From debugging.lua
    drawMonitors()
    if debugMode then
        drawDebug()
    end
    drawStateMonitoring()
    -- End Text in the top left
    --love.graphics.circle("fill", windowWidth/2, windowHeight/2, 2)            This code draws a dot in the center of the screen
    -- Code that will cap FPS at 144 --
    local cur_time = love.timer.getTime()
    if next_time <= cur_time then
        next_time = cur_time
        return
    end

    love.timer.sleep(next_time - cur_time)
    -- End Code that will cap FPS at 144 --
end

function love.update(dt)

    --Network debugging

    -- Code that will cap FPS at 144
    next_time = next_time + min_dt

    -- Get current mouse position and store in object mouse
    mouse.x, mouse.y = love.mouse.getPosition()

    if CH.playerMovement then

        if love.keyboard.isDown('d') then
            player.x_vel = player.speed * base_speed * dt
        end
        if love.keyboard.isDown('a') then
            player.x_vel = -player.speed * base_speed * dt
        end
        if love.keyboard.isDown('w') then
            player.y_vel = -player.speed * base_speed * dt
        end
        if love.keyboard.isDown('s') then
            player.y_vel = player.speed * base_speed * dt
        end

        if not (love.keyboard.isDown('d') or love.keyboard.isDown('a')) then
            if (player.x_vel_counter < 1) then
                player.x_vel = 0
            else
                player.x_vel_counter = player.x_vel_counter - 1
            end
        else
            player.x_vel_counter = base_slowdown_counter
        end

        if not (love.keyboard.isDown('w') or love.keyboard.isDown('s')) then
            if (player.y_vel_counter < 1) then
                player.y_vel = 0
            else
                player.y_vel_counter = player.y_vel_counter - 1
            end
        else
            player.y_vel_counter = base_slowdown_counter
        end

        -- Send movement to server
        --[=====[
        if player.y_vel ~= 0 or player.x_vel ~= 0 then
          sendToServer(USERNAME.." moveto "..player.x.." "..player.y)
        end
        ]=====]--

    else
        if CH.playerMovementDisableCount < 1 then
            CH.playerMovementDisableCount = 10
            CH.playerMovement = true
        else
            CH.playerMovementDisableCount = CH.playerMovementDisableCount - 1
        end
    end
    if debugMode then
        CH:checkCollisions() -- This will handle and resolve collisions right before movement.
    end
    for i = 1, #movingObjects do
        movingObjects[i]:move()
    end

end

function love.keypressed(key)

    -- Handle keypresses
    if key == 'r' then player.x, player.y = 0, 0 end -- Reset position
    if key == 'tab' then debugMode = not debugMode end
    --if key == 'l' then sendToServer(USERNAME.." listplayers") end
    if key == 'b' then MH:loadMap(nil) end

end



function love.quit()
  --disconnectFromServer()
  print("Game instance has been closed")
end
