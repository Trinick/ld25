Entity = require "entity"

World = {}
World.__index = World

function World.new()
    local inst = {}

    setmetatable(inst, World)

    inst.player = Entity.new(300, 300, 32, 32)
    inst.entities = {inst.player}

    return inst
end

function World:render()
    for i, entity in pairs(self.entities) do
        entity:render()
    end
end

return World
