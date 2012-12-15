World = require "world"
control = require "control"

function love.load()
    love.graphics.setBackgroundColor(255, 255, 255)

    world = World.new()
    control = Control.new(world);
end

function love.update(dt)
<<<<<<< HEAD
    control:moveCheck(dt)
=======
	control:moveCheck(dt)
>>>>>>> 25a1ec737721afbaf2adfc57712f4f34e8323af6
end

function love.draw()
    world:render()
end

function love.mousepressed(x, y, button)
<<<<<<< HEAD
    control:onClick(x, y, button)
=======
	control:onClick(x, y, button)
>>>>>>> 25a1ec737721afbaf2adfc57712f4f34e8323af6
end