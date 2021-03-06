--- State Single player (module).
-- This module runs the single player game
SoloGame = {}

switched = false

local movingObj = {}
local projectiles = {}

--- This is called only when the the module has been initialized (in main.lua)
function SoloGame:init() -- init is only called once

end


--- Called whenever this state is entered
function SoloGame:enter() -- enter is called everytime this state occurs
    noclip = false -- if true then no collision should happen.
    debugMode = false
	CH = CollisionHandler()

	love.graphics.setNewFont(16)

    spriteImg = love.graphics.newImage('images/sprites/player.png')
    badImg = love.graphics.newImage('images/sprites/badguy.png')
    -- healthImg = love.graphics.newImage('images/sprites/HealthBar.png')

	player = cObject(USERNAME, spriteImg, nil, 1, 96, 96, 32, 32, 10, 5)
    -- p_health = cObject ("health", healthImg, {255,255,255}, 1, 96, 96, 28, 10)
    badGuy = cObject("badguy", badImg, {255,50,0}, .002, 192, 192, 32, 32)


    LH = LevelHandler()
    LH:startGame()


	CH:addObj(player)
    CH:addObj(badGuy)
    CH:addObj(p_health)
    movingObj[#movingObj + 1] = player
    movingObj[#movingObj + 1] = badGuy





    -- movingObj[#movingObj + 1] = p_health

    HUD = HUD()


end

--- Called on game ticks for drawing operations
function SoloGame:draw()
	if CH.playerMovement then
        x_translate_val = (love.graphics.getWidth() / 2) - player.x
        y_translate_val = (love.graphics.getHeight() / 2) - player.y
    end

    love.graphics.push()
    love.graphics.translate(x_translate_val, y_translate_val)

    MH:drawMap()
    if debugMode then
        highlightTiles(player)
    end

    -- Draw all players
    --player:draw()
    --badGuy:draw()

    for i = 1, #movingObj do movingObj[i]:draw() end
    for i = 1, #projectiles do projectiles[i]:draw() end
  
    -- p_health:draw()

    if debugMode then
      --player:drawHitbox() no need until we update hitboxes
    end

    love.graphics.pop()


    love.graphics.setColor(255, 255, 255)
    love.graphics.circle("line", mouse.x, mouse.y, 5) -- "line" is outline, 5 is radius

    -- Debugging information (from debugging.lua)
    drawMonitors()

    if debugMode then drawDebug() end

    HUD:draw()

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

--- Called every game tick to update game data
function SoloGame:update(dt)
	if CH.playerMovement then

        -- Change velocity according to keypresses
        if love.keyboard.isDown('d') then player.x_vel = player.speed * base_speed * dt end
        if love.keyboard.isDown('a') then player.x_vel = -player.speed * base_speed * dt end
        if love.keyboard.isDown('w') then player.y_vel = -player.speed * base_speed * dt end
        if love.keyboard.isDown('s') then player.y_vel = player.speed * base_speed * dt end

        -- Friction
        if not love.keyboard.isDown('d','a') then
            if (player.x_vel_counter < 1) then player.x_vel = 0
            else player.x_vel_counter = player.x_vel_counter - 1 end
        else player.x_vel_counter = base_slowdown_counter
        end
        if not love.keyboard.isDown('w','s') then
            if (player.y_vel_counter < 1) then player.y_vel = 0
            else player.y_vel_counter = player.y_vel_counter - 1 end
        else player.y_vel_counter = base_slowdown_counter
        end

    else
        if CH.playerMovementDisableCount < 1 then
            CH.playerMovementDisableCount = 10
            CH.playerMovement = true
        else CH.playerMovementDisableCount = CH.playerMovementDisableCount - 1
        end
    end
    LH:update(dt)
    -- Handle collisions
    if not noclip then CH:checkCollisions() end

    badGuy:chase(dt)

    -- Move the moving objects after collisions have been handled
    for i = 1, #movingObj do movingObj[i]:move() end
    for i = 1, #projectiles do projectiles[i]:move() end
    

end

--- Event binding to listen for key presses
function SoloGame:keypressed(key)
-- Handle keypresses
    if debugMode and key == 'r' then player.x, player.y = 0, 0 end -- Reset position
    if key == 'n' then noclip = not noclip end
    if key == 'tab' then debugMode = not debugMode end -- Toggle debug mode
    if key == 'escape' then Gamestate.switch(PlayMenu) end
    if key == 'l' then
        if switched then
            LH:loadLevel(2,2)
        else
            LH:loadLevel(1,1)
        end
        switched = not switched
    end
end

---controls shooting direction
function SoloGame:mousepressed(x, y, button)
    if button == 1 then
        local startX = player.x
        local startY = player.y
        local mouseX = x - x_translate_val
        local mouseY = y - y_translate_val
 
        local angle = math.atan2((mouseY - startY), (mouseX - startX))
 
        
        local pos = #projectiles + 1
        projectiles[pos] = cObject("badguy", badImg, {255, 255, 255}, 1, startX, startY, 16, 16)

        local ProjectileDx = projectiles[pos].speed * math.cos(angle)
        local ProjectileDy = projectiles[pos].speed * math.sin(angle)

        projectiles[pos]:setVel(ProjectileDx,ProjectileDy)
    end
end



return SoloGame
