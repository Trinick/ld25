Entity = {}
Entity.__index = Entity

drawLine = {}

function Entity.new(x, y, class)
    local inst = {}

    setmetatable(inst, Entity)

    inst.className = "entity"
    inst.class = 0x00
    inst.entityClass = classMgr.classes[1]
    inst.cx = x
    inst.cy = y
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

    love.graphics.drawq(class.tileset, quad, math.floor(self.cx + self.entityClass.offsetX), math.floor(self.cy + self.entityClass.offsetY), 0, 1, 1, 0, 0)
end

function Entity:clientCheck(x, y)
    local minX = self.cx + self.entityClass.offsetX
    local minY = self.cy + self.entityClass.offsetY
    local maxX = minX + self.entityClass.width
    local maxY = minY + self.entityClass.height

	if x >= minX and x <= maxX  and y >= minY and y <= maxY then
		return 1
	end
	return 0
end

function Entity:spawnEnemy()
    Enemy.new(self.cx + 50, self.cy, 32, 64, world)
end

function Entity:clearCmds()
    self.curCmd = nil
    self.cmds = {}
end
function Entity:popCmd(cmd)
    if self.cmds[1][1] == cmd then
        self.curCmd = nil
        table.remove(self.cmds, 1)
    end
end
function Entity:pushCmd(cmd, args)
    table.insert(self.cmds, {cmd, args})
end
function Entity:processCmds(dt)
    if # self.cmds > 0 then
        self.curCmd = self.cmds[1]
        self.cmds[1][1](self, dt, self.cmds[1][2])
    end
end
function Entity:stop()
end
function Entity:think(dt)
    self:processCmds(dt)
end

function entityMoveTo(entity, dt, args)
    local x = args[1]
    local y = args[2]
    local minDist = args[3]

    local cx, cy = entity.collision:center()
    local dx = x - cx
    local dy = y - cy
    local len = math.sqrt(math.pow(dx, 2) + math.pow(dy, 2))

    if len <= minDist then
        entity:popCmd(entityMoveTo)
    else
        dx = dx / len
        dy = dy / len

        if math.abs(dy) >= math.abs(dx) then
            if dy >= 0 then
                entity.direction = 0
            else
                entity.direction = 1
            end
        else
            if dx >= 0 then
                entity.direction = 2
            else
                entity.direction = 3
            end
        end

        entity.collision:move(dt * dx * entity.moveSpeed, dt * dy * entity.moveSpeed)
        local cx, cy = entity.collision:center()
        entity.cx = cx
        entity.cy = cy
    end
end

function Entity:delete()
    for a, entity in pairs(world.entities) do
        if entity == self then
            table.remove(world.entities, a)
        end
    end

    if self.collision ~= nil then
        collider:remove(self.collision)
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

    if self.isControlled then
        for a, entity in pairs(control.controlling) do
            if entity == self then
                table.remove(control.controlling, a)
            end
        end
    end

    self = nil
end

function Entity:update(dt)
    if(self.damageblinkend ~= nil) then
        self.damageblinkend = self.damageblinkend - dt
        if self.damageblinkend <= 0 then
            self.color = self.oldcolor
            self.oldcolor = nil
            self.damageblinkend = nil
        end
    end
end

return Entity
