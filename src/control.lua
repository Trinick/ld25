Control = {}
Control.__index = Control

function Control.new()
    local inst = {}

    setmetatable(inst, Control)

    inst.controlling = {}
    inst.controllingIndex = 1
    inst.moving = false

    return inst
end

function Control:moveCheck(dt)
    for i, entity in pairs(self.controlling) do
        if entity ~= 0 then if entity.class == 0x01 then
            ens = 0
            eew = 0

            local w = love.keyboard.isDown("w")
            local a = love.keyboard.isDown("a")
            local s = love.keyboard.isDown("s")
            local d = love.keyboard.isDown("d")

            if w then
                ens = entity.moveSpeed * -dt
                entity.direction = 1
            end
            if d then
                eew = entity.moveSpeed * dt
                entity.direction = 2
            end
            if s then
                ens = entity.moveSpeed * dt
                entity.direction = 0
            end
            if a then
                eew = entity.moveSpeed * -dt
                entity.direction = 3
            end

            if w or a or s or d then
                self.moving = true
            else
                self.moving = false
            end

            if ens ~= 0 and eew ~= 0 then
                local root2div2 = math.sqrt(2) / 2
                ens = ens * root2div2
                eew = eew * root2div2
            end

            if ens ~= 0 or eew ~= 0 then
                entity.x = entity.x + eew
                entity.y = entity.y + ens
                entity.stepFrac = entity.stepFrac + (dt*4)
            end

            if entity.collision ~= nil then
                entity.collision:move(eew, ens)
            end
        end
        end
    end

    wns = 0
    wew = 0

    if(love.keyboard.isDown("up")) then
        wns = 256 * dt
    end
    if(love.keyboard.isDown("right")) then
        wew = 256 * -dt
    end
    if(love.keyboard.isDown("down")) then
         wns = 256 * -dt
    end
    if(love.keyboard.isDown("left")) then
        wew = 256 * dt
    end

    world.cameraX = world.cameraX + wew
    world.cameraY = world.cameraY + wns
end

function Control:clear()
    self.controlling = {}
    self.controllingIndex = 1
end

function Control:update(dt)
    self:moveCheck(dt)

    if #self.controlling > 0 and self.center then
        local target = self.controlling[self.controllingIndex]

        if target then
            world.cameraX = -target.x - target.width / 2
            world.cameraY = -target.y - target.height / 2
            self.controllingIndex = ((self.controllingIndex + 1) % #self.controlling) + 1
        end
    end
end

function Control:onClick(x, y, button)
    x = x - world.cameraX - love.graphics.getWidth() / 2
    y = y - world.cameraY - love.graphics.getHeight() / 2

    if button == "l" then
        self.controlling = {}

        for i, entity in pairs(world.entities) do
            if entity:collisionCheck(x, y) == 1 then
                table.insert(self.controlling, entity)
            end
        end
    end
end

return Control
