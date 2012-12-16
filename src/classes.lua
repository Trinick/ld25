ClassMgr = {}
ClassMgr.__index = ClassMgr

function ClassMgr.new()
    local inst = {}

    setmetatable(inst, ClassMgr)

    inst.classes = {}

    inst:initializeClass("spider")
    inst:initializeClass("slime")
    inst:initializeClass("skeleton")
    return inst
end

function ClassMgr:initializeClass(class)
    local tileset = love.graphics.newImage("art/" .. class .. ".png")
    tileset:setFilter("nearest", "linear")

    local inst = {}

    inst.tileset = tileset
    inst.down = {}
    inst.up = {}
    inst.lr = {}

    local list = {inst.down, inst.up, inst.lr}

    table.insert(self.classes, inst)

    local quad

    for y = 0, 2, 1 do
        for x = 0, 2, 1 do
            quad = love.graphics.newQuad(((16 * x) + 8)+(x * 32), 8 + (y * 32), 32, 32, tileset:getWidth(), tileset:getHeight())

            table.insert(list[y + 1], quad)
        end
    end
end

return ClassMgr
