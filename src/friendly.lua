Friendly = {}
FriendlyMT = {__index = Friendly}
setmetatable(Friendly, {__index = Entity})

function Friendly.new(x, y, width, height)
    local inst = {}

    setmetatable(inst, FriendlyMT)

    inst.className = "friendly"
    inst.class = 0x01
    inst.entityClass = classMgr.classes[2]

    inst.x = x
    inst.y = y
    inst.width = width
    inst.height = height
    inst.direction = 0
    inst.step = 1
    inst.stepFrac = 0
    inst.flipped = {false, false, false}
    inst.canBeControlled = true
    inst.isControlled = false
    inst.cmds = {}

    inst.moveSpeed = 64

    inst.attackAngle = 0.218165
    inst.attackDist = 16

    inst.health = 100

    inst.collision = collider:addRectangle(x, y, width, height)
    inst.collision.instance = inst

    return inst
end

function Friendly:think(dt)
    self:processCmds()
end

return Friendly
