World = require "world"

function love.load()
    love.graphics.setBackgroundColor(255, 255, 255)

    world = World.new()
end

function love.update(dt)
end

function love.draw()
    world:render()
end
