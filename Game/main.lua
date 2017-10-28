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
    player.x = 702
    player.y = 450
    player.speed = 1 -- (We can scale this number later to have speed modifiers)
    player.img = love.graphics.newImage('images/sprites/player.png')
    -- End Player initialization


    -- Code that will cap FPS at 144
    min_dt = 1/144
    next_time = love.timer.getTime()
    -- End Code that will cap FPS at 144
end

function love.draw()
    love.graphics.push()
    love.graphics.translate((windowWidth / 2) - (player.x + 32), -player.y + (windowHeight / 2))

    draw_tiles()

    -- Draw player
    love.graphics.draw(player.img, player.x, player.y, 0, 1, 1, 0, 32)

    love.graphics.pop()

    -- Draw circle where mouse is --
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle("line", mouse.x, mouse.y, 5) -- "line" is outline, 5 is radius


    -- Text in the top left
    love.graphics.setColor(0, 203, 255)
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
    love.graphics.print("Wubba lubba dub dub!", 10, 30)
    -- End Text in the top left
    love.graphics.circle("fill", 800, 450, 2)
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

function love.quit()
  print("Game instance has been closed")
end
