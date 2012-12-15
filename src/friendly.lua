Friendly = {}
Friendly.__index = Friendly

function Friendly.new(x, y, width, height, world)
    local inst = {}

    setmetatable(inst, Entity)

    inst.className = "friendly"
    inst.class = 0x01

    inst.x = x
    inst.y = y
    inst.width = width
    inst.height = height
    inst.direction = 0

    inst.moveSpeed = 64

    inst.attackAngle = 0.218165
    inst.attackDist = 16

    inst.health = 100

    return inst
end

return Friendly
