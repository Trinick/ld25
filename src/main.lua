World = require "world"
Control = require "control"
HC = require "collision"
ClassMgrMeta = require "classes"
GUI = require "gui"
require "navigation"
WaveMgr = require "waves"

tips = {
    "PROTIP: You're not a villain unless your minions die for you.",
    "PROTIP: Having unsafe sex can result in STIs."
}

function love.load()
    love.graphics.setBackgroundColor(89, 29, 71)

    tileset = love.graphics.newImage("art/images/tiles.png")
    font = love.graphics.newFont("art/fonts/04b03.ttf", 17)
    bigFont = love.graphics.newFont("art/fonts/04b03.ttf", 26)
    gui = GUI.new()
    collider = HC(100, onCollision, onCollisionStop)
    classMgr = ClassMgrMeta.new()
    world = World.new(math.ceil(math.random() * 123456789))
    control = Control.new()
end

function love.update(dt)
    gui:update(dt)
    world:update(dt)

    if gui.loaded then
        control:update(dt)
        collider:update(dt)
    end
end

function love.draw()
    if gui.over then
    elseif gui.loaded then
        if gui.ready then
            world:render()
            
            -- Print out selection box
            if control.selectBox.exists then
                love.graphics.setColor(255, 255, 255, 255)
                love.graphics.setLineWidth(2)
                local x0 = world.cameraX + love.graphics.getWidth() / 2
                local y0 = world.cameraY + love.graphics.getHeight() / 2
                local x1 = math.min(control.selectBox.originX, control.selectBox.finalX)
                local y1 = math.min(control.selectBox.originY, control.selectBox.finalY)
                local x2 = math.max(control.selectBox.originX, control.selectBox.finalX)
                local y2 = math.max(control.selectBox.originY, control.selectBox.finalY)
                love.graphics.rectangle("line", x1 + x0, y1 + y0, x2-x1, y2-y1)
            end

            love.graphics.setColor(255, 255, 255, 255)
        end
    else
        world:generate()
    end

    gui:render()
end

function love.keypressed(button)

    if button == " " then
        if control.controlling then
            control.controlling:attack()
        end
    end

    if button == "rctrl" then
        for i, entity in pairs(control.controlling) do
            entity:spawnEnemy()
        end
    end

    if gui.loaded and not gui.ready then
        gui.ready = true
    elseif gui.over then
        gui.ready = false
        gui.loaded = false
        gui.over = false

        world:clear()
        world:populate()
    end

    if button == "lctrl" then
        control.center = true
    end
end

function love.keyreleased(button)
    if button == "lctrl" then
        control.center = false
    elseif button == "escape" then
        control:clear()
    end
end

function love.mousepressed(x, y, button)
    if gui.loaded then
        control:onMouseDown(x, y, button)
    end
end

function love.mousereleased(x, y, button)
    if gui.loaded then
        control:onMouseUp(x, y, button)
    end
end