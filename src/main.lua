World = require "world"
Control = require "control"
HC = require "collision"
ClassMgrMeta = require "classes"

function love.load()
    love.graphics.setBackgroundColor(89, 29, 71)

    tileset = love.graphics.newImage("art/tiles.png")
    tileset:setFilter("nearest", "linear")

    collider = HC(100, onCollision, onCollisionStop)
    classMgr = ClassMgrMeta.new()
    world = World.new(math.ceil(math.random() * 123456789))
    control = Control.new()
end

function love.update(dt)
    control:moveCheck(dt)
    collider:update(dt)
end

function love.draw()
    world:render()
end

function love.mousepressed(x, y, button)
    control:onClick(x, y, button)
end
