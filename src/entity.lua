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

    local dirs = {class.down, class.up, class.left, class.right}

    if self.stepFrac > 1 then
        self.step = ((self.step + 1) % 3) + 1
        self.stepFrac = 0
    end

    local direction = self.direction
    local quad = dirs[direction + 1][self.step]

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
function Entity:clientBoxCheck(bMinX, bMinY, bMaxX, bMaxY)
    local minX = self.cx + self.entityClass.offsetX
    local minY = self.cy + self.entityClass.offsetY
    local maxX = minX + self.entityClass.width
    local maxY = minY + self.entityClass.height

    if minX < bMaxX and minY < bMaxY and bMinX < maxX and bMinY < maxY then
        return true
    end
    return false
end

function Entity:spawnEnemy()
    Enemy.new(self.cx + 50, self.cy, 32, 64, world)
end

function Entity:clearCmds()
    self.curCmd = nil
    self.cmds = {}
end
function Entity:popCmd(cmd)
    if # self.cmds > 0 then
        if self.cmds[1][1] == cmd then
            self.curCmd = nil
            table.remove(self.cmds, 1)
        end
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
    self.step = 1
    self.stepFrac = 0
    self.isPatrolling = false
    self.patrolPos = nil
    self.waitTime = 0
end
function Entity:think(dt)
    self:processCmds(dt)
end
function Entity:onHitWall()
    if self.isPatrolling and self.patrolPos ~= nil then
        self:stop()
    end
end
function Entity:onHitEntity(entity)
    if self.isPatrolling and self.patrolPos ~= nil then
        self:stop()
    end
end

function entityMoveTo(entity, dt, args)
    local x = args[1]
    local y = args[2]
    local minDist = args[3]

    local cx, cy = entity.collision:center()
    local dx = x - cx
    local dy = y - cy
    local len = math.sqrt(math.pow(dx, 2) + math.pow(dy, 2))

    if #entity.cmds > 0 and len <= minDist then
        entity:stop()
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

        entity.stepFrac = entity.stepFrac + dt * 4

        entity.collision:move(dt * dx * entity.moveSpeed, dt * dy * entity.moveSpeed)
        local cx, cy = entity.collision:center()
        entity.cx = cx
        entity.cy = cy
    end
end
function entityPatrol(entity, dt, args)
    local isPatrolling = args[1]
    entity.isPatrolling = isPatrolling

    if entity.waitTime == nil then
        entity.waitTime = 0
    end

    if isPatrolling then
        if entity.waitTime > 0 then
            entity.waitTime = entity.waitTime - dt
        else
            local x = 0
            local y = 0
            if entity.patrolPos == nil then
                local range = args[2] * math.random()
                while true do
                    local angle = math.random() * math.pi * 2
                    x = range * math.cos(angle) + entity.cx
                    y = range * math.sin(angle) + entity.cy
                    if # raycast(entity.cx, entity.cy, x, y, nil, true, true) == 0 then
                        entity.patrolPos = {x, y}
                        break
                    end
                end
            else
                x = entity.patrolPos[1]
                y = entity.patrolPos[2]
            end

            local minDist = args[3]
            local cx, cy = entity.collision:center()
            local dx = x - cx
            local dy = y - cy
            local len = math.sqrt(math.pow(dx, 2) + math.pow(dy, 2))

            if len <= minDist then
                entity:stop()
                entity.waitTime = args[4] * math.random()
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

                entity.stepFrac = entity.stepFrac + dt * 4
                entity.collision:move(dt * dx * entity.moveSpeed, dt * dy * entity.moveSpeed)
                local cx, cy = entity.collision:center()
                entity.cx = cx
                entity.cy = cy
            end
        end
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
