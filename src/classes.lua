ClassMgr = {}
ClassMgr.__index = ClassMgr

function ClassMgr.new()
    local inst = {}

    setmetatable(inst, ClassMgr)

    inst.classes = {}

    inst:initializeClass("spider", "Spider", 64, 64)
    --inst:initializeClass("slime", "Slime")
    inst:initializeClass("skeleton", "Skeleton", 32, 64)
    return inst
end

function ClassMgr:initializeClass(id, name, width, height)
    local tileset = love.graphics.newImage("art/images/" .. id .. ".png")
    local inst = {}

    inst.name = name
    inst.tileset = tileset
    inst.portrait = love.graphics.newImage("art/images/portrait_" .. id .. ".png")
    inst.down = {}
    inst.up = {}
    inst.lr = {}

    local list = {inst.down, inst.up, inst.lr}

    table.insert(self.classes, inst)

    local quad

    for y = 0, 2, 1 do
        for x = 0, 2, 1 do
            quad = love.graphics.newQuad(x * width, y * height, width, height, tileset:getWidth(), tileset:getHeight())

            table.insert(list[y + 1], quad)
        end
    end
end

return ClassMgr
