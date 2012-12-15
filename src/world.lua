Entity = require "entity"
Friendly = require "friendly"
Enemy = require "enemy"

World = {}
World.__index = World

function World.new()
    local inst = {}

    setmetatable(inst, World)

    inst.player = Friendly.new(300, 300, 32, 32)
    inst.entities = {inst.player}
    inst.renderstring = ""

    return inst
end

function World:render()
    for i, entity in pairs(self.entities) do
        entity:render()
    end
    if self.renderstring ~= "" then
    	love.graphics.printf(self.renderstring, 0, 0, 800)
    end
end

return World
