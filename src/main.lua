World = require "world"
control = require "control"
HC = require 'hardoncollider'

function on_collision(dt, shape_a, shape_b, mtv_x, mtv_y)
end
function collision_stop(dt, shape_a, shape_b)
end

function love.load()
	Collider = HC(100, on_collision, collision_stop)

    love.graphics.setBackgroundColor(89, 29, 71)

    tileset = love.graphics.newImage("art/tiles.png")
    tileset:setFilter("nearest", "linear")

    world = World.new(1)
    control = Control.new(world)
end

function love.update(dt)
    control:moveCheck(dt)
	Collider:update(dt)
end

function love.draw()
    world:render()
end

function love.mousepressed(x, y, button)
    control:onClick(x, y, button)
end
