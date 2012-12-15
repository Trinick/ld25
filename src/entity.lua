Entity = {}
Entity.__index = Entity

function Entity.new(x, y, width, height)
    local inst = {}

    setmetatable(inst, Entity)

    inst.class = "entity"

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

function Entity:collisionCheck(x, y)
	if x > self.x and x < self.x+self.width and y > self.y and y < self.y+self.height then
		return 1
	end
	return 0
end

function Entity:getClass()
    return self.class
end

return Entity
