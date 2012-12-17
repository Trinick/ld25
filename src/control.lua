Control = {}
Control.__index = Control

function Control.new()
    local inst = {}

    setmetatable(inst, Control)

    inst.controlling = {}
    inst.controllingIndex = 1
    inst.moving = false
    inst.mouseDown = {}
    inst.selectBox = { exists = false, originX = 0, originY = 0 , finalX = 0, finalY = 0}
    inst.selectedEntities = {}

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
            if s then
                ens = entity.moveSpeed * dt
                entity.direction = 0
            end
            if d then
                eew = entity.moveSpeed * dt
                entity.direction = 2
            end
            if a then
                eew = entity.moveSpeed * -dt
                entity.direction = 3
            end

            if w or a or s or d then
                entity:clearCmds()
                entity:stop()
                self.moving = true
            else
                self.moving = false
            end

            if ens ~= 0 and eew ~= 0 then
                local root2div2 = math.sqrt(2) / 2
                ens = ens * root2div2
                eew = eew * root2div2
            end

            if entity.collision ~= nil then
                entity.collision:move(eew, ens)
                local cx, cy = entity.collision:center() 
                entity.cx = cx
                entity.cy = cy
            end
            if ens ~= 0 or eew ~= 0 then
                entity.cx = entity.cx + eew
                entity.cy = entity.cy + ens
                entity.stepFrac = entity.stepFrac + (dt*4)
            end

            if ens == 0 and eew == 0 then
                entity.stepFrac = 0
                entity.step = 1
            end end
        end
    end

    local wns = 0
    local wew = 0

    local multiplier

    if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
        multiplier = 2
    else
        multiplier = 1
    end

    if(love.keyboard.isDown("up")) then
        wns = 384 * dt * multiplier
    end
    if(love.keyboard.isDown("right")) then
        wew = 384 * -dt * multiplier
    end
    if(love.keyboard.isDown("down")) then
         wns = 384 * -dt * multiplier
    end
    if(love.keyboard.isDown("left")) then
        wew = 384 * dt * multiplier
    end

    world.cameraX = world.cameraX + wew
    world.cameraY = world.cameraY + wns
end

function Control:clear()
    for a, entity in pairs(self.controlling) do
        entity.isControlled = false
    end
    self.controlling = {}
    self.controllingIndex = 1
end

function Control:update(dt)
    if self.mouseDown["l"] then
        local width = love.graphics.getWidth()
        local height = love.graphics.getHeight()
        local mapX = width - gui.map:getWidth() + 56
        local mapY = 36
        local mapWidth = world.width
        local mapHeight = world.height
        local x = love.mouse.getX()
        local y = love.mouse.getY()

        if x > mapX and x < mapX + mapWidth and y > mapY and y < mapY + mapHeight then
            world.cameraX = (x - mapX) * -32
            world.cameraY = (y - mapY) * -32
        end
    end

    self:moveCheck(dt)

    if #self.controlling > 0 and self.center then
        local target = self.controlling[self.controllingIndex]

        if target then
            world.cameraX = -target.cx
            world.cameraY = -target.cy
            self.controllingIndex = ((self.controllingIndex + 1) % #self.controlling) + 1
        end
    end
end

function Control:onMouseUp(x, y, button)
    self.mouseDown[button] = false
    
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    local mapX = width - gui.map:getWidth() + 56
    local mapY = 36
    local mapWidth = world.width
    local mapHeight = world.height

    if x > mapX and x < mapX + mapWidth and y > mapY and y < mapY + mapHeight then
        return
    end

    x = x - world.cameraX - width / 2
    y = y - world.cameraY - height / 2
    
    if button == "l" then
        if self.selectBox.exists == true then
            self.selectedEntities = {}
            self.selectBox.finalX = x
            self.selectBox.finalY = y
            self.selectBox.exists = false
            local x1 = math.min(self.selectBox.originX, self.selectBox.finalX)
            local y1 = math.min(self.selectBox.originY, self.selectBox.finalY)
            local x2 = math.max(self.selectBox.originX, self.selectBox.finalX)
            local y2 = math.max(self.selectBox.originY, self.selectBox.finalY)
            for i, entity in pairs(world.entities) do
                if entity.canBeControlled and entity.cx >= x1 and entity.cx <= x2 and
                    entity.cy >= y1 and entity.cy <= y2 then
                    table.insert(self.selectedEntities, entity)
                end
            end
            
            if #(self.selectedEntities) == 1 then
                local entity = self.selectedEntities[1]
                self.selectedEntities = {}
                table.insert(self.controlling, entity)
                entity:clearCmds()
                entity:stop()
                entity.isControlled = true
            end
        end
    end
end

function Control:onMouseDown(x, y, button)
    self.mouseDown[button] = true

    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    local mapX = width - gui.map:getWidth() + 56
    local mapY = 36
    local mapWidth = world.width
    local mapHeight = world.height

    if x > mapX and x < mapX + mapWidth and y > mapY and y < mapY + mapHeight then
        return
    end

    x = x - world.cameraX - width / 2
    y = y - world.cameraY - height / 2

    if button == "l" then
        self.controlling = {}
        self.selectedEntities = {}
        self.selectBox.exists = true;
        self.selectBox.originX = x;
        self.selectBox.originY = y;
    end

    -- attempted selection movement --
    if button == "r" then
        for i, ent in pairs(self.selectedEntities) do
            ent:clearCmds()
            ent:stop()
            debugObj = ent
            debugPath = getPath(x, y, ent.cx + 16, ent.cy + 16, {[ent.collision] = 1})
            if debugPath == nil then
            elseif debugPath == 0 then
                ent:pushCmd(entityMoveTo, {x, y, 2})
            elseif # debugPath > 0 then
                for a, node in pairs(debugPath) do
                    ent:pushCmd(entityMoveTo, {world.nodes[node].x, world.nodes[node].y, 4})
                end
                ent:pushCmd(entityMoveTo, {x, y, 2})
            end
            debugPos = {x, y}
        end
    end

    -- Pathfinding Debug - took this shit out, here for archive --
    if button == "q" then
        if self.controlling[1] ~= nil then
            if self.controlling[1] ~= 0 then
                if self.controlling[1].cx ~= nil then
                    self.controlling[1]:clearCmds()
                    self.controlling[1]:stop()
                    debugObj = self.controlling[1]
                    debugPath = getPath(x, y, self.controlling[1].cx, self.controlling[1].cy, {[self.controlling[1].collision] = 1})
                    if debugPath == nil then
                    elseif debugPath == 0 then
                        self.controlling[1]:pushCmd(entityMoveTo, {x, y, 2})
                    elseif # debugPath > 0 then
                        for a, node in pairs(debugPath) do
                            self.controlling[1]:pushCmd(entityMoveTo, {world.nodes[node].x, world.nodes[node].y, 2})
                        end
                        self.controlling[1]:pushCmd(entityMoveTo, {x, y, 2})
                    end
                    debugPos = {x, y}
                end
            end
        end
    end
end

return Control
