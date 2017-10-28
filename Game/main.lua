-- Current functionality is just movement and mouse cursor until we get maps and tiling implemented

require "tiling"

mouse = {}
player = {}

function love.load()
    windowWidth = 1600
    windowHeight = 900

    love.window.setMode(windowWidth, windowHeight, {resizable=false, vsync=false, minwidth=800, minheight=600, borderless=true})
    --love.window.setFullscreen(true, "desktop")

    -- Load tilesets
    load_tilesets()

    -- Make mouse invisible so we can use a custom cursor --
    love.mouse.setVisible(false)

    base_speed = 250


    -- Player initialization - With a 64x64px sprite, this will place it in the center.
    player.x = 0
    player.y = 0
    player.speed = 1 -- (We can scale this number later to have speed modifiers)
    player.img = love.graphics.newImage('images/sprites/player.png')
    -- End Player initialization


    -- Code that will cap FPS at 144
    min_dt = 1/144
    next_time = love.timer.getTime()
    -- End Code that will cap FPS at 144
end

function love.draw()
    -- This stack push begins the code that makes our camera follow our player. Everything that needs to stay in place should be here

    local x_translate_val = (windowWidth / 2) - player.x
    local y_translate_val = (windowHeight / 2) - player.y

    love.graphics.push()
    love.graphics.translate(x_translate_val, y_translate_val)

    draw_tiles() -- from tiling.lua

    -- Draw player --
    love.graphics.draw(player.img, player.x - 32, player.y, 0, 1, 1, 0, 32)

    love.graphics.pop()
    -- This stack pop ends the code for the camera following. Anything that should stay in place on screen should follow this

    -- Draw circle where mouse is --
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle("line", mouse.x, mouse.y, 5) -- "line" is outline, 5 is radius


    -- Text in the top left
    love.graphics.setColor(0, 203, 255)
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
    love.graphics.print("Wubba lubba dub dub!", 10, 30)
    love.graphics.print("Player Location: " .. tostring(math.floor(player.x)) .. "," .. tostring(math.floor(player.y)), 10, 50)
    love.graphics.print("Mouse Screen Location: " .. tostring(math.floor(mouse.x)) .. "," .. tostring(math.floor(mouse.y)), 10, 70)
    love.graphics.print("Mouse Abs Location: " .. tostring(math.floor(mouse.x - x_translate_val)) .. "," .. tostring(math.floor(mouse.y - y_translate_val)), 10, 90)
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


end

function love.keypressed(key)
    if key == 'r' then -- reset position
        player.x = 0
        player.y = 0
    end
end

function love.quit()
  print("Game instance has been closed")
end
