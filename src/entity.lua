Entity = {}
Entity.__index = Entity

function Entity.new(x, y, width, height, world)
    local inst = {}

    setmetatable(inst, Entity)

    inst.class = "entity"

    inst.x = x
    inst.y = y
    inst.width = width
    inst.height = height
    inst.direction = 0

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

function Entity:attack()
    for i, entity in pairs(self.world.entities) do
        if entity.class == 0x02 and self.class == 0x01
            pass = 1
        elseif entity.class == 0x01 and self.class == 0x02
            pass = 1
        end
        if pass == 1 then
            x = self.x - inst.x
            y = self.y - inst.y
            distance = math.sqrt(x^2 + y^2)
            if distance <= self.attackDist then
                minangle = (3.14159/4)*self.direction - self.attackAngle/2
                maxangle = minangle + self.attackAngle
                angle = Math.atan2(x,y)
                if angle > minangle and angle < maxangle then
                    entity.damage(self.attackDamage)
                    [[create combat text for hit]]
                else
                    [[create combat text for miss]]
                end 
            end
        end
    end
end

return Entity
