World = require "world"
control = require "control"

function love.load()
    love.graphics.setBackgroundColor(89, 29, 71)

    tileset = love.graphics.newImage("art/tiles.png")
    tileset:setFilter("nearest", "linear")

    world = World.new(1)
    control = Control.new(world)
end

function love.update(dt)
    control:moveCheck(dt)
end

function love.draw()
    world:render()
end

function love.mousepressed(x, y, button)
    control:onClick(x, y, button)
end
