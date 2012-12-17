World = require "world"
Control = require "control"
HC = require "collision"
ClassMgrMeta = require "classes"
GUI = require "gui"
require "navigation"

tips = {
    
}

function love.load()
    love.graphics.setBackgroundColor(89, 29, 71)

    tileset = love.graphics.newImage("art/images/tiles.png")
    font = love.graphics.newFont("art/fonts/04b03.ttf", 17)
    gui = GUI.new()
    collider = HC(100, onCollision, onCollisionStop)
    classMgr = ClassMgrMeta.new()
    world = World.new(math.ceil(math.random() * 123456789))
    control = Control.new()

    world:populate()

    gui:renderMap()
end

function love.update(dt)
    gui:update(dt)
    world:update(dt)
    control:update(dt)
    collider:update(dt)
end

function love.draw()
    if gui.loaded and gui.ready then
        world:render()

        -- Pathfinding Debug --
        love.graphics.setColor(255, 0, 0, 255)
        love.graphics.setLineWidth(2)
        if debugPath == nil then
        elseif debugPath == 0 then
            love.graphics.line(debugObj.x + world.cameraX + love.graphics.getWidth() / 2 + 16, debugObj.y + world.cameraY + love.graphics.getHeight() / 2 + 16, debugPos[1] + world.cameraX + love.graphics.getWidth() / 2, debugPos[2] + world.cameraY + love.graphics.getHeight() / 2)
        elseif # debugPath > 0 then
            for a, id in pairs(debugPath) do
                if a == 1 then
                    love.graphics.line(debugObj.x + world.cameraX + love.graphics.getWidth() / 2 + 16, debugObj.y + world.cameraY + love.graphics.getHeight() / 2 + 16, world.nodes[id].x + world.cameraX + love.graphics.getWidth() / 2, world.nodes[id].y + world.cameraY + love.graphics.getHeight() / 2)
                else
                    love.graphics.line(world.nodes[debugPath[a - 1]].x + world.cameraX + love.graphics.getWidth() / 2, world.nodes[debugPath[a - 1]].y + world.cameraY + love.graphics.getHeight() / 2, world.nodes[id].x + world.cameraX + love.graphics.getWidth() / 2, world.nodes[id].y + world.cameraY + love.graphics.getHeight() / 2)
                end
            end
            love.graphics.line(world.nodes[debugPath[# debugPath]].x + world.cameraX + love.graphics.getWidth() / 2, world.nodes[debugPath[# debugPath]].y + world.cameraY + love.graphics.getHeight() / 2, debugPos[1] + world.cameraX + love.graphics.getWidth() / 2, debugPos[2] + world.cameraY + love.graphics.getHeight() / 2)
            
        end
        love.graphics.setColor(255, 255, 255, 255)
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
    elseif button == "escape" then
        control:clear()
    end
end

function love.mousepressed(x, y, button)
    control:onClick(x, y, button)
end
