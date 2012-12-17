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
    self.attackTimeout = 0
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
function Entity:detectEnemies(range)
    local rangeBy2 = range / 2
    local cx = self.cx
    local cy = self.cy
    local minX = cx - rangeBy2
    local minY = cy - rangeBy2
    local maxX = cx + rangeBy2
    local maxY = cy + rangeBy2

    local enemies = boxCheck(minX, minY, maxX, maxY, self.class % 2 + 1)

    local returnSet = {}
    for a, enemy in pairs(enemies) do
        if # raycast(cx, cy, enemy.instance.cx, enemy.instance.cy, nil, true, true) == 0 then
            table.insert(returnSet, enemy)
        end
    end

    function minDist(a, b)
        local acx, acy = a:center()
        local bcx, bcy = b:center()
        return (math.pow(cx - acx, 2) + math.pow(cy - acy, 2)) < (math.pow(cx - bcx, 2) + math.pow(cy - bcy, 2))
    end
    table.sort(returnSet, minDist)

    return returnSet
end

function entityAttack(entity, dt, args)
    local target = args[1]

    if entity.lastAttack == nil then
        entity.lastAttack = 0
    end

    if entity.lastAttack >= entity.entityClass.attackTimeout then
        entity.lastAttack = 0
    end

    if entity.lastAttack == 0 then
        local dist = math.sqrt(math.pow(entity.cx - target.cx, 2) + math.pow(entity.cy - target.cy, 2))
        if dist <= 48 then
            if target.damageblinkend == nil then
                target.damageblinkend = 0.10
                target.oldcolor = target.color
                target.color = {255, 96, 96}
            end
            target.health = target.health - entity.damage
            if target.health < 0 then
                target:delete()
                world.audioMgr:playSound("die")
                if # entity.cmds > 0  then
                    entity:stop()
                    entity:popCmd(entityAttack)
                end
            else
                world.audioMgr:playSound("hit")
            end
        end
    end

    entity.lastAttack = entity.lastAttack + dt
end
function entityMoveTo(entity, dt, args)
    local x = args[1]
    local y = args[2]
    local minDist = args[3]

    local cx, cy = entity.collision:center()
    local dx = x - cx
    local dy = y - cy
    local len = math.sqrt(math.pow(dx, 2) + math.pow(dy, 2))

    if # entity.cmds > 0 and len <= minDist then
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
        local enemies = entity:detectEnemies(320)
        if # enemies > 0 then
            entityMoveTo(entity, dt, {enemies[1].instance.cx, enemies[1].instance.cy, 32})
            entityAttack(entity, dt, {enemies[1].instance})

            if entity.class == 2 then
                entity.movePos = nil
            end

            return
        end

        if entity.class == 1 then
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

        if entity.class == 2 then
            local targetRoom = entity.targetRoom

            local x = 0
            local y = 0

            local dist = 0

            if targetRoom == nil then
                while entity.targetRoom == nil do
                    targetRoom = world.rooms[math.random(1, # world.rooms)]

                    x = (targetRoom.x + targetRoom.radius / 2) * 32
                    y = (targetRoom.y + targetRoom.radius / 2) * 32

                    dist = math.sqrt(math.pow(entity.cx - x, 2) + math.pow(entity.cy - y, 2))

                    if dist > 640 then
                        entity.targetRoom = targetRoom
                    end
                end
            else
                x = (targetRoom.x + targetRoom.radius / 2) * 32
                y = (targetRoom.y + targetRoom.radius / 2) * 32

                dist = math.sqrt(math.pow(entity.cx - x, 2) + math.pow(entity.cy - y, 2))
            end

            if dist <= 32 then
                entity.targetRoom = nil
                entity.movePos = nil
            end

            if entity.movePos == nil and entity.targetRoom ~= nil then
                local path = getPath(entity.cx, entity.cy, x, y, {[entity] = 1})
                if path == nil then
                    entity.targetRoom = nil
                elseif path == 0 then
                    entity.movePos = {x, y}
                elseif # path > 0 then
                    entity.movePos = {world.nodes[path[1]].x, world.nodes[path[1]].y}
                end
            end

            if entity.movePos ~= nil then
                x = entity.movePos[1]
                y = entity.movePos[2]
                dist = math.sqrt(math.pow(entity.cx - x, 2) + math.pow(entity.cy - y, 2))
                if dist < 2 then
                    entity.movePos = nil
                else
                    entityMoveTo(entity, dt, {entity.movePos[1], entity.movePos[2], 2})
                end
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
        control.controlling = nil
    end

    if self.isSelected then
        for a, entity in pairs(control.selectedEntities) do
            if entity == self then
                table.remove(control, a)
                break
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
