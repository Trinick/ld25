ClassMgr = {}
ClassMgr.__index = ClassMgr

function ClassMgr.new()
    local inst = {}

    setmetatable(inst, ClassMgr)

    inst.classes = {}

    inst:initializeClass("spider", "Spider", 64, 64, 100, 96, 15, 32, 32, -32, -32)
    inst:initializeClass("skeleton", "Skeleton", 32, 64, 200, 48, 10, 32, 32, -16, -32)
    inst:initializeClass("ghost", "Ghost", 32, 64, 150, 80, 10, 32, 32, -16, -32)
    inst:initializeClass("slime", "Slime", 24, 32, 10, 32, 25, 24, 24, -12, -16)

    inst:initializeClass("hero_knight", "HeroKnight", 64, 64, 100, 64, 10, 32, 32, -32, -32)
    inst:initializeClass("hero_templar","HeroTemplar", 64, 64, 200, 48, 15, 32, 32, -32, -32)
    return inst
end

function ClassMgr:initializeClass(id, name, width, height, health, speed, damage, colWidth, colHeight, offsetX, offsetY)
    local tileset = love.graphics.newImage("art/images/" .. id .. ".png")
    local inst = {}

    inst.name = name
    inst.health = health
    inst.moveSpeed = speed
    inst.damage = damage
    inst.width = width
    inst.height = height
    inst.tileset = tileset
    inst.portrait = love.graphics.newImage("art/images/portrait_" .. id .. ".png")
    inst.down = {}
    inst.up = {}
    inst.lr = {}

    inst.colWidth = colWidth
    inst.colHeight = colHeight
    inst.offsetX = offsetX
    inst.offsetY = offsetY

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
