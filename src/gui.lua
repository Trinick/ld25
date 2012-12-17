GUI = {}
GUI.__index = GUI

function GUI.new()
    local inst = {}

    setmetatable(inst, GUI)

    inst.state = "Loading..."
    inst.loaded = false
    inst.ready = false
    inst.skull = love.graphics.newImage("art/images/skull.png")
    inst.status = love.graphics.newImage("art/images/status.png")
    inst.map = love.graphics.newImage("art/images/map.png")
    inst.mapCanvas = nil
    inst.tip = nil

    return inst
end

function GUI:renderMap()
    self.mapCanvas = love.graphics.newCanvas(world.width, world.height)
    self.mapCanvas:renderTo(function()
        love.graphics.setColor(0, 0, 0)

        for x = 0, world.width do
            for y = 0, world.height do
                if world:getTile(x, y) then
                    love.graphics.point(x, y)
                end
            end
        end
    end)
end

function GUI:renderLoading()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    if self.tip == nil then
        self.tip = tips[math.ceil(math.random() * #tips)]
    end
    local tip = self.tip
    local tipWidth = font:getWidth(tip)

    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.skull, width / 2 - self.skull:getWidth() / 2, height / 2 - self.skull:getHeight() / 2)
    love.graphics.print(tip, width / 2 - tipWidth / 2, height / 2 + self.skull:getHeight() * 7 / 6)

    if not self.loaded then
        love.graphics.print(self.state, 16, height - 32)
    else
        love.graphics.setColor(225, 225, 225)
        love.graphics.print("Press any key to continue", 16, height - 32)
    end
end

function GUI:renderHUD()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    local target = control.controlling[control.controllingIndex]

    if target then
        local class = target.entityClass
        local y = height - self.status:getHeight()

        love.graphics.draw(self.status, 0, y)
        love.graphics.setColor(255, 26, 26)
        love.graphics.rectangle("fill", 78, y + 48, math.ceil(184 * target.health / target.entityClass.health), 12)
        love.graphics.setColor(255, 255, 255) -- TODO: unhardcode for each portrait instead of just spiders
        love.graphics.draw(class.portrait, 14, y + 30)
        love.graphics.setColor(89, 29, 71)
        love.graphics.print(class.name, 79, y + 28)
        love.graphics.setColor(255, 255, 255)
        love.graphics.print(class.name, 77, y + 27)
    end

    local x = width - self.map:getWidth()

    love.graphics.draw(self.map, x, 0)
    love.graphics.setColor(0, 0, 0)
    love.graphics.draw(self.mapCanvas, x + 56, 36)
    love.graphics.setColor(255, 0, 0)

    for i, entity in pairs(world.enemies) do
        love.graphics.point(math.floor(x + entity.x / 32 + 56), math.floor(entity.y / 32 + 36))
    end
    love.graphics.setColor(0, 255, 0)
    for i, entity in pairs(world.friendlies) do
        love.graphics.point(math.floor(x + entity.x / 32 + 56), math.floor(entity.y / 32 + 36))
    end

    love.graphics.setColor(255, 255, 255)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", math.floor(x + 56 + (-world.cameraX - width / 2) / 32), math.floor((-world.cameraY - height / 2) / 32 + 36), math.floor(width / 32), math.floor(height / 32))
end

function GUI:render()
    love.graphics.push()
    love.graphics.setFont(font)

    if not self.loaded or not self.ready then
        self:renderLoading()
    else
        self:renderHUD()
    end

    love.graphics.pop()
end

function GUI:update(dt)
end

return GUI
