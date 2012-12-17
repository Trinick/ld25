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
    gui = GUI.new()
    wavectrl = WaveMgr.new()
    collider = HC(100, onCollision, onCollisionStop)
    classMgr = ClassMgrMeta.new()
    world = World.new(math.ceil(math.random() * 123456789))
    control = Control.new()
end

function love.update(dt)
    gui:update(dt)
    wavectrl:update(dt)
    world:update(dt)

    if gui.loaded then
        control:update(dt)
        collider:update(dt)
    end
end

function love.draw()
    if gui.loaded then
        if gui.ready then
            world:render()

            -- Pathfinding Debug --
            love.graphics.setColor(255, 0, 0, 255)
            love.graphics.setLineWidth(2)

            if debugPath == nil then
            elseif debugPath == 0 then
                love.graphics.line(debugObj.cx + world.cameraX + love.graphics.getWidth() / 2, debugObj.cy + world.cameraY + love.graphics.getHeight() / 2, debugPos[1] + world.cameraX + love.graphics.getWidth() / 2, debugPos[2] + world.cameraY + love.graphics.getHeight() / 2)
            elseif # debugPath > 0 then
                for a, id in pairs(debugPath) do
                    if a == 1 then
                        love.graphics.line(debugObj.cx + world.cameraX + love.graphics.getWidth() / 2, debugObj.cy + world.cameraY + love.graphics.getHeight() / 2, world.nodes[id].x + world.cameraX + love.graphics.getWidth() / 2, world.nodes[id].y + world.cameraY + love.graphics.getHeight() / 2)
                    else
                        love.graphics.line(world.nodes[debugPath[a - 1]].x + world.cameraX + love.graphics.getWidth() / 2, world.nodes[debugPath[a - 1]].y + world.cameraY + love.graphics.getHeight() / 2, world.nodes[id].x + world.cameraX + love.graphics.getWidth() / 2, world.nodes[id].y + world.cameraY + love.graphics.getHeight() / 2)
                    end
                end

                love.graphics.line(world.nodes[debugPath[# debugPath]].x + world.cameraX + love.graphics.getWidth() / 2, world.nodes[debugPath[# debugPath]].y + world.cameraY + love.graphics.getHeight() / 2, debugPos[1] + world.cameraX + love.graphics.getWidth() / 2, debugPos[2] + world.cameraY + love.graphics.getHeight() / 2)
                
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
        for i, entity in pairs(control.controlling) do
            entity:attack()
        end
    end
    if button == "rctrl" then
        for i, entity in pairs(control.controlling) do
            entity:spawnEnemy()
        end
    end
    if gui.loaded and not gui.ready then
        gui.ready = true
        wavectrl:start()
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