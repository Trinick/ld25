Friendly = {}
Friendly.__index = Friendly

function Friendly.new(x, y, width, height)
    local inst = {}

    setmetatable(inst, Entity)

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

    inst.moveSpeed = 64

    inst.attackAngle = 0.218165
    inst.attackDist = 16

    inst.health = 100

    inst.collision = collider:addRectangle(x, y, width, height)
    inst.collision.instance = inst

    return inst
end

return Friendly
