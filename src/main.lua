World = require "world"
Control = require "control"
HC = require "collision"
ClassMgrMeta = require "classes"
GUI = require "gui"

function love.load()
    love.graphics.setBackgroundColor(89, 29, 71)

    tileset = love.graphics.newImage("art/tiles.png")
    tileset:setFilter("nearest", "linear")

    font = love.graphics.newFont("art/fonts/04b03.ttf", 17)
    gui = GUI.new()
    collider = HC(100, onCollision, onCollisionStop)
    classMgr = ClassMgrMeta.new()
    world = World.new(math.ceil(math.random() * 123456789))
    control = Control.new()
end

function love.update(dt)
    gui:update(dt)
    control:update(dt)
    collider:update(dt)
end

function love.draw()
    if gui.loaded and gui.ready then
        world:render()
    end

    gui:render()
end

function love.keypressed(button)
    if gui.loaded and not gui.ready then
        gui.ready = true
    end

    if button == "lctrl" then
        control.center = true
    end
end

function love.keyreleased(button)
    if button == "lctrl" then
        control.center = false
    end
end

function love.mousepressed(x, y, button)
    control:onClick(x, y, button)
end
