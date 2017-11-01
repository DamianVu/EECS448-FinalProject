-- Current functionality is just movement and mouse cursor until we get maps and tiling implemented

require "tiling"
require "collisionhandler"
require "cObject"

mouse = {}
player = {}

movingObjects = {}

function love.load()
    windowWidth = 1600
    windowHeight = 900

    love.window.setMode(windowWidth, windowHeight, {resizable=false, vsync=false, minwidth=800, minheight=600, borderless=true, msaa=2})
    --love.window.setFullscreen(true, "desktop")

    -- Load tileset
    load_tileset()
    load_tilesets()

    -- Make mouse invisible so we can use a custom cursor --
    love.mouse.setVisible(false)


    -- Collision Handler initialization --
    CH = CollisionHandler()


    -- Global Game variables
    base_speed = 250
    debugMode = false
    base_slowdown_counter = 5 -- Game will wait this many game ticks before velocity comes to a halt


    player = cObject(nil, love.graphics.newImage('images/sprites/player.png'), 1, 96, 96, 32, 32)

    movingObjects[#movingObjects + 1] = player

    CH:addObj(player)

    -- Code that will cap FPS at 144
    min_dt = 1/144
    next_time = love.timer.getTime()
    -- End Code that will cap FPS at 144
end

function love.draw()

    -- These values are used to move the camera, and also to get the absolute mouse position relative to the map --
    x_translate_val = (windowWidth / 2) - player.x
    y_translate_val = (windowHeight / 2) - player.y
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

    --[=====[
    -- Listen for keypresses to move player (if a player holds 'w' and 's', they will be stationary. Same with 'a' and 'd')
    if love.keyboard.isDown('d') then
        player.x = player.x + (player.speed * base_speed * dt)
    end
    if love.keyboard.isDown('a') then
        player.x = player.x - (player.speed * base_speed * dt)
    end
    if love.keyboard.isDown('w') then
        player.y = player.y - (player.speed * base_speed * dt)
    end
    if love.keyboard.isDown('s') then
        player.y = player.y + (player.speed * base_speed * dt)
    end
    ]=====]--

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



    -- This should only update once every dt anyways...
    --player:move()

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
    if debugMode then

    end
end

function drawMonitors()
    love.graphics.setColor(0, 203, 255)
    love.graphics.print("Wubba lubba dub dub!", 10, 10)
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 30)
    love.graphics.print("Debug Mode(tab): " .. tostring(debugMode), 10, 50)
end

function drawDebug()
    love.graphics.setColor(0, 203, 255)
    love.graphics.print("Player Location: " .. tostring(math.floor(player.x)) .. "," .. tostring(math.floor(player.y)), 10, 70)
    love.graphics.print("Mouse Screen Location: " .. tostring(math.floor(mouse.x)) .. "," .. tostring(math.floor(mouse.y)), 10, 90)
    love.graphics.print("Mouse Abs Location: " .. tostring(math.floor(mouse.x - x_translate_val)) .. "," .. tostring(math.floor(mouse.y - y_translate_val)), 10, 110)
    local cl, al = get_cObjectPositionInfo(player)
    love.graphics.print("Player is positioned in " .. cl:size() .. " tile(s)", 10 , 130)
    love.graphics.print("Player has " .. al:size() .. " adjacent tile(s)", 10, 150)
    local coll, track = CH:getNumberOfPossibleCollisions(1)
    love.graphics.print("Current # of collisions: " .. coll, 10, 170)
    love.graphics.print("We should be tracking " .. track .. " possible collisions", 10, 190)
    --love.graphics.print("Current: " .. coordListString(cl.list), 10, 190)
    --love.graphics.print("Adj: " .. coordListString(al.list), 10, 210)
end

function coordListString(list)
    local tempString = ""

    for i=1, #list do
        local x,y = unpack(list[i])
        tempString = tempString .. "(" .. x .. "," .. y .. ")"
    end
    return tempString
end

function love.quit()
  print("Game instance has been closed")
end
