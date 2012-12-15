Entity = {}
Entity.__index = Entity

function Entity.new(x, y, width, height)
    local inst = {}

    setmetatable(inst, Entity)

    inst.x = x
    inst.y = y
    inst.width = width
    inst.height = height

    return inst
end

function Entity:render()
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

return Entity
