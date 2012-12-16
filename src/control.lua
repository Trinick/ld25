Control = {}
Control.__index = Control

function Control.new(world)
    local inst = {}

    setmetatable(inst, Control)

    inst.world = world;
    inst.currControl = {}

    inst.worldX = 0
    inst.worldY = 0

    return inst
end

function Control:moveCheck(dt)
    for i, entity in pairs(self.currControl) do
        if entity ~= 0 then if entity.class == 0x01 then
            ens = 0
            eew = 0

            if love.keyboard.isDown("w") then
                ens = entity.moveSpeed * -dt
            end
            if love.keyboard.isDown("d") then
                eew = entity.moveSpeed * dt
            end
            if love.keyboard.isDown("s") then
                ens = entity.moveSpeed * dt
            end
            if love.keyboard.isDown("a") then
                eew = entity.moveSpeed * -dt
            end

            if ens ~= 0 and eew ~= 0 then
                local root2div2 = math.sqrt(2) / 2
                ens = ens * root2div2
                eew = eew * root2div2
            end

            entity.x = entity.x + eew
            entity.y = entity.y + ens

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

    self.world.worldX = self.world.worldX + wew
    self.world.worldY = self.world.worldY + wns
end

function Control:onClick(x, y, button)
    x = x - self.world.worldX
    y = y - self.world.worldY

    if button == "l" then
        self.currControl[1] = 0

        for i, entity in pairs(self.world.entities) do
            if entity:collisionCheck(x, y) == 1 then
                self.currControl[1] = entity
            end
        end
    end
end

return Control
