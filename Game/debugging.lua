-- This file will contain Debug message drawing functions along with small functions to aid debugging

-- NOTE: Uses variables from main and netClient

function drawMonitors()
    love.graphics.setColor(0, 203, 255)
    love.graphics.print("Wubba lubba dub dub!", 10, 10)
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 30)
    love.graphics.print("Debug Mode(tab): " .. tostring(debugMode), 10, 50)

    

end

function drawNetworkMonitors()
    -- Network Monitors
    love.graphics.setColor(255, 0, 0)
    love.graphics.print("Messages sent: " .. messageCount, 1450, 10)
    love.graphics.print(playerList, 1450, 30)
    love.graphics.print("Peer table size: " .. #peers, 1450, 50)
    love.graphics.print("Our Ent Name: " .. (USERNAME or ""), 1450, 70)
end

function drawDebug()
    love.graphics.setColor(0, 203, 255)
    love.graphics.print("Player Location: " .. tostring(math.floor(player.x)) .. "," .. tostring(math.floor(player.y)), 10, 70)
    love.graphics.print("Mouse Screen Location: " .. tostring(math.floor(mouse.x)) .. "," .. tostring(math.floor(mouse.y)), 10, 90)
    love.graphics.print("Mouse Abs Location: " .. tostring(math.floor(mouse.x - x_translate_val)) .. "," .. tostring(math.floor(mouse.y - y_translate_val)), 10, 110)
    local cl, al = get_cObjectPositionInfo(player)
    love.graphics.print("Player is positioned in " .. #cl.list .. " tile(s)", 10 , 130)
    love.graphics.print("Player has " .. #al.list .. " adjacent tile(s)", 10, 150)
    local coll, track = CH:getNumberOfPossibleCollisions(1)
    love.graphics.print("Current # of collisions: " .. coll, 10, 170)
    love.graphics.print("We should be tracking " .. track .. " possible collisions", 10, 190)
    love.graphics.print("Noclip mode: " .. tostring(noclip) .. " (press 'n' to toggle)", 10 , 210)
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
