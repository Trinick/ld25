Enemy = {}
EnemyMT = {__index = Enemy}
setmetatable(Enemy, {__index = Entity})

function Enemy.new(x, y, width, height, world)
	local inst = {}

    setmetatable(inst, EnemyMT)

    inst.className = "enemy"
    inst.class = 0x02

    inst.x = x
    inst.y = y
    inst.width = width
    inst.height = height
    inst.direction = 0
    inst.canBeControlled = false
    inst.cmds = {}

    inst.moveSpeed = 5

    table.insert(world.entities, inst)
    table.insert(world.friendlies, inst)

    return inst
end

function Enemy:think(dt)
    self:processCmds(dt)
end

return Enemy
