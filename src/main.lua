World = require "world"
control = require "control"

function love.load()
    love.graphics.setBackgroundColor(255, 255, 255)

    world = World.new()
    control = Control.new(world);
end

function love.update(dt)
	control:movecheck(dt)
end

function love.draw()
    world:render()
end

function love.mousepressed(x, y, button)
	control:onclick(x, y, button)
end