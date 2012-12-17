Enemy = {}
EnemyMT = {__index = Enemy}
setmetatable(Enemy, {__index = Entity})

function Enemy.new(x, y, width, height, world)
    local inst = {}

    setmetatable(inst, EnemyMT)

    inst.className = "enemy"
    inst.class = 0x02
    inst.entityClass = classMgr.classes[3]

    inst.x = x
    inst.y = y
    inst.width = width
    inst.height = height
    inst.direction = 0
    inst.step = 1
    inst.stepFrac = 0
    inst.flipped = {false, false, false}
    inst.canBeControlled = false
    inst.cmds = {}

    inst.moveSpeed = 64

    inst.health = 100

    inst.collision = collider:addRectangle(x, y, width, height)
    inst.collision.instance = inst

    table.insert(world.entities, inst)
    table.insert(world.enemies, inst)

    return inst
end

function Enemy:think(dt)
    self:processCmds(dt)
end

return Enemy
