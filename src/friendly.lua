Friendly = {}
Friendly.__index = Friendly

function Friendly.new(x, y, width, height)
	local inst = {}

    setmetatable(inst, Entity)

    inst.class = "friendly"

    inst.x = x
    inst.y = y
    inst.width = width
    inst.height = height

    inst.moveSpeed = 5

    return inst
end

return Friendly