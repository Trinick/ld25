Enemy = {}
Enemy.__index = Enemy

function Enemy.new(x, y, width, height, world)
	local inst = {}

    setmetatable(inst, Entity)

    inst.className = "enemy"
    inst.class = 0x02

    inst.x = x
    inst.y = y
    inst.width = width
    inst.height = height
    inst.direction = 0

    inst.moveSpeed = 5

    return inst
end

return Enemy
