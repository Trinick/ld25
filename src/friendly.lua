Friendly = {}
FriendlyMT = {__index = Friendly}
setmetatable(Friendly, {__index = Entity})

function Friendly.new(x, y, class)
    local inst = {}

    setmetatable(inst, FriendlyMT)

    inst.className = "friendly"
    inst.class = 0x01
    local entityClass = classMgr.classes[1]
    if type(class) == "string" then
        local classNum = 1
        for i=1, #classMgr.classes, 1 do
            if(classMgr.classes[i].name == class) then
                classNum = i
                break
            end
        end
        entityClass = classMgr.classes[classNum]
    else
        entityClass = classMgr.classes[class]
    end

    local width = entityClass.width
    local height = entityClass.height

    inst.entityClass = entityClass
    inst.x = x
    inst.y = y
    inst.width = width
    inst.height = height
    inst.damage = entityClass.damage
    inst.direction = 0
    inst.step = 1
    inst.stepFrac = 0
    inst.flipped = {false, false, false}
    inst.canBeControlled = true
    inst.isControlled = false
    inst.cmds = {}
    inst.color = {255, 255, 255}

    inst.moveSpeed = entityClass.moveSpeed

    inst.health = entityClass.health

    inst.collision = collider:addRectangle(x, y, width, height)
    inst.collision.instance = inst

    table.insert(world.entities, inst)
    table.insert(world.friendlies, inst)

    return inst
end

function Friendly:attack()
    local ignoreSet = {[self.collision] = 1}
    for i, entity in pairs(world.entities) do
        if entity.className == nil then
            table.insert(ignoreSet, entity)
        elseif entity.className ~= "enemy" then
            table.insert(ignoreSet, entity.collision)
        end
    end
    local startX = self.x + (self.width/2)
    local startY = self.y + (self.height/2)
    local targetX = startX
    local targetY = startY

    if self.direction == 0 then
        targetY = startY + 50
    elseif self.direction == 1 then
        targetY = startY - 50
    elseif self.direction == 2 then
        targetX = startX + 50
    elseif self.direction == 3 then
        targetX = startX - 50
    end

    local retSet = raycast(startX, startY, targetX, targetY, ignoreSet)
    if #retSet == 0 then
        return
    end
    for e, enemy in pairs(retSet) do
        enemy = enemy.instance
        if enemy ~= nil then
            if enemy.className == "enemy" then
                enemy.damageblinkend = 0.10
                enemy.oldcolor = enemy.color
                enemy.color = {255, 96, 96}
                enemy.health = enemy.health - self.damage
                if enemy.health < 0 then
                    enemy:delete()
                    world.soundCtlr.playSound("die")
                else
                    world.soundCtlr.playSound("hit")
                end
            end
        end
    end
end

function Friendly:think(dt)
    self:processCmds(dt)
end

return Friendly
