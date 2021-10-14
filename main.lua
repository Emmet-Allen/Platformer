local STI = require("sti")
require("player")

function love.load()
    Map = STI("map/level01.lua", {"box2d"})
    World = love.physics.newWorld(0,0) --Creates physics world (x-velocity, y-velocity i.e. for gravity)
    World:setCallbacks(beginContact, endContact)
    Map:box2d_init(World)
    Map.layers.solid.visible = false --removes collison hi-lite
    -- background = love.graphics.newImage("assets/Background/Blue.png") My background is built within the tile set
    Player:load()
end

function love.update(dt)
    World:update(dt)
    Player:update(dt)
end

function love.draw()
   -- love.graphics.draw(background)  --Have background before Map so its drawn behind
    Map:draw(0,0,2,2)
    love.graphics.push() --Saves current Transformation on Stack
    love.graphics.scale(2,2)
    Player:draw()
    love.graphics.pop() -- Retrives info from stack and returns to state
end

function love.keypressed(key)
    Player:jump(key)
end

function beginContact(a, b, collision)
    Player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
    Player:endContact(a, b, collision)
end
