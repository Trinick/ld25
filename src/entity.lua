Entity = {}
Entity.__index = Entity

function Entity.new(x, y, width, height, world)
    local inst = {}

    setmetatable(inst, Entity)

    inst.className = "entity"
    inst.class = 0x00
    inst.entityClass = classMgr.classes[1]
    inst.x = x
    inst.y = y
    inst.width = width
    inst.height = height
    inst.direction = 0
    inst.canBeControlled = false
    inst.cmds = {}

    table.insert(world.entities, inst)

    return inst
end

function Entity:render()
    local class = self.entityClass

    if class == nil then
        return
    end

    local dirs = {class.down, class.up, class.lr}

    if self.stepFrac > 1 then
        self.step = ((self.step + 1) % 3) + 1
        self.stepFrac = 0
    end

    local direction = self.direction
    local quad

    if self.direction ~= 3 then
        quad = dirs[direction + 1][self.step]
    end

    if self.direction == 3 then
        direction = 2
        quad = dirs[direction + 1][self.step]

        if self.flipped[self.step] ~= true then
            quad:flip(true, false)
            self.flipped[self.step] = true
        end
    elseif self.direction == 2 and self.flipped[self.step] then
        self.flipped[self.step] = false
        quad:flip(true, false)
    end

    love.graphics.drawq(class.tileset, quad, math.floor(self.x), math.floor(self.y), 0, 1, 1, 0, 0)
end

function Entity:collisionCheck(x, y)
	if x > self.x and x < self.x + self.width and y > self.y and y < self.y + self.height then
		return 1
	end
	return 0
end

function Entity:attack()
    for i, entity in pairs(self.world.entities) do
        if entity.class == 0x02 and self.class == 0x01 then
            pass = 1
        elseif entity.class == 0x01 and self.class == 0x02 then
            pass = 1
        end

        if pass == 1 then
            x = self.x - inst.x
            y = self.y - inst.y
            distance = math.sqrt(x^2 + y^2)

            if distance <= self.attackDist then
                minAngle = (3.14159/4) * self.direction - self.attackAngle / 2
                maxAngle = minAngle + self.attackAngle
                angle = Math.atan2(x,y)

                if angle > minAngle and angle < maxAngle then
                    entity.damage(self.attackDamage)
                    --create combat text for hit
                else
                    --create combat text for miss
                end 
            end
        end
    end
end

function Entity:clearCmds()
    self.curCmd = nil
    self.cmds = {}
end
function Entity:popCmd(cmd)
    if self.cmds[1] == cmd then
        self.curCmd = nil
        table.remove(self.cmds, 1)
    end
end
function Entity:pushCmd(cmd)
    table.insert(self.cmds, cmd)
end
function Entity:processCmds()
    if # self.cmds > 0 and self.curCmd == nil then
        self.curCmd = self.cmds[1]
        self.cmds[1](self)
    end
end
function Entity:stop()
end
function Entity:think(dt)
    self:processCmds()
end

function Entity:delete()
    for a, entity in pairs(world.entities) do
        if entity == self then
            table.remove(world.entities, a)
        end
    end

    if self.class == 1 then
        for a, entity in pairs(world.friendlies) do
            if entity == self then
                table.remove(world.friendlies, a)
            end
        end
    end

    if self.class == 2 then
        for a, entity in pairs(world.enemies) do
            if entity == self then
                table.remove(world.enemies, a)
            end
        end
    end

    self = nil
end

return Entity
