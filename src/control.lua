Control = {}
Control.__index = Control

function Control.new()
    local inst = {}

    setmetatable(inst, Control)

    inst.currControl = {}

    return inst
end

function Control:moveCheck(dt)
    for i, entity in pairs(self.currControl) do
        if entity ~= 0 then if entity.class == 0x01 then
            ens = 0
            eew = 0

            if love.keyboard.isDown("w") then
                ens = entity.moveSpeed * -dt
                entity.direction = 1
            end
            if love.keyboard.isDown("d") then
                eew = entity.moveSpeed * dt
                entity.direction = 2
            end
            if love.keyboard.isDown("s") then
                ens = entity.moveSpeed * dt
                entity.direction = 0
            end
            if love.keyboard.isDown("a") then
                eew = entity.moveSpeed * -dt
                entity.direction = 3
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

function Control:onClick(x, y, button)
    x = x - world.cameraX - love.graphics.getWidth() / 2
    y = y - world.cameraY - love.graphics.getHeight() / 2
    print(x .. " " .. y)
    if button == "l" then
        self.currControl[1] = 0

        for i, entity in pairs(world.entities) do
            print(entity.x .. " " .. entity.y)
            if entity:collisionCheck(x, y) == 1 then
                self.currControl[1] = entity
            end
        end
    end
end

return Control
