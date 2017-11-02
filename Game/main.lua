-- Current functionality is just movement and mouse cursor until we get maps and tiling implemented

require "tiling"
require "libraries.collisionhandler"
require "libraries.cObject"
require "debugging"
require "networktesting"

local socket = require("socket")
local address, port = "104.131.9.165", 5005
local entity
local updateRate = 1

mouse = {}
player = {}

peers = {}

movingObjects = {}

function love.load()
    windowWidth = 1600
    windowHeight = 900

    gameState = 1 -- Moving

    love.window.setMode(windowWidth, windowHeight, {resizable=false, vsync=false, minwidth=800, minheight=600, borderless=false, msaa=2})
    --love.window.setFullscreen(true, "desktop")

    -- Load tileset
    load_tileset()

    -- Make mouse invisible so we can use a custom cursor --
    love.mouse.setVisible(false)


    -- Global Game variables
    base_speed = 250
    debugMode = false
    base_slowdown_counter = 5 -- Game will wait this many game ticks before velocity comes to a halt

    -- Initialize player by calling cObject constructor
    player = cObject(nil, love.graphics.newImage('images/sprites/player.png'), nil, 1, 96, 96, 32, 32)

    movingObjects[#movingObjects + 1] = player

    -- Collision Handler initialization --
    CH = CollisionHandler()
    CH:addObj(player)


    -- Test networking
    prevUpdate = 0
    udp = socket.udp()
    udp:settimeout(0)
    udp:setpeername(address, port)
    math.randomseed(os.time()) 
    entity = tostring(math.random(99999))
    --entity = "Damian"
    local r,g,b = unpack(player.color)
    udp:send(entity .. " 999 " .. player.x .. "," .. player.y .. " " .. r .. "," .. g .. "," .. b)
    messageCount = 0
    lastMessage = ""

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
    -- Code that will cap FPS at 144
    next_time = next_time + min_dt

    -- Get current mouse position and store in object mouse
    mouse.x, mouse.y = love.mouse.getPosition()

    -- Network testing
    prevUpdate = prevUpdate + dt
    if prevUpdate > updateRate then
        local data
        if gameState == 1 then
            local datax = player.x
            local datay = player.y
            data = string.format("%s %d %f,%f", entity, gameState, datax, datay)
        elseif gameState == 2 then
            data = "This is a long string that i'm sending to test the capabilities of udp transmission and I'm not sure if this whole string is even possible to send over udp........"
            gameState = 0
        else
            data = string.format("%s %d fffffffffff", entity, gameState)
        end

        udp:send(data)
        messageCount = messageCount + 1

        prevUpdate = prevUpdate - updateRate
    end

    repeat
        rdata, msg = udp:receive()

        if rdata then

            lastMessage = tostring(rdata)
        elseif msg~= 'timeout' then
            error("Network error: " ..tostring(msg))
        end
    until not rdata


    -- End of network testing

    if player.x_vel ~= 0 or player.y_vel ~= 0 then
        gameState = 1
    else
        gameState = 0
    end

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

    else
        if CH.playerMovementDisableCount < 1 then
            CH.playerMovementDisableCount = 10
            CH.playerMovement = true
        else
            CH.playerMovementDisableCount = CH.playerMovementDisableCount - 1
        end
    end

    CH:checkCollisions() -- This will handle and resolve collisions right before movement.
    for i = 1, #movingObjects do
        movingObjects[i]:move()
    end

end

function love.keypressed(key)
    if key == 'r' then -- reset position
        player.x = 0
        player.y = 0
    end
    if key == 'tab' then
        debugMode = not debugMode
    end
    if key == 'g' then
        gameState = 2
    end
    if debugMode then

    end
end



function love.quit()
  print("Game instance has been closed")
  udp:send(entity .. " -1 QUITTING")
  local r,g,b = unpack(player.color)
  print(r .. "," .. g .. "," .. b)
end
