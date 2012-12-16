Entity = require "entity"
Friendly = require "friendly"
Enemy = require "enemy"
LCG = require "lcg"

World = {}
World.__index = World

function World.new(seed)
    local inst = {}

    setmetatable(inst, World)

    local lcg = LCG.new(seed)
    local entities = {}
    local nodes = {}
    local width = 100
    local height = 100
    local tiles = {}

    for x = 1, width do
        for y = 1, height, 1 do
            tiles[x .. "_" .. y] = false
        end
    end

    inst.renderString = ""
    inst.entities = entities
    inst.nodes = nodes
    inst.lcg = lcg
    inst.tiles = tiles
    inst.width = width
    inst.height = height
    inst.tiles = tiles

    local rooms = {}
    local count = 8 + math.floor(lcg:random() * (width + height) / 2)

    gui.state = "Generating..."

    for j = 1, 2, 1 do
        for i = 0, count do
            if j == 1 then
                local x, y, radius, size

                repeat
                    size = 5 + math.floor(lcg:random() * 7)
                    radius = math.floor(size / 2)
                    x = math.floor(lcg:random() * width)
                    y = math.floor(lcg:random() * height)
                until not (x + radius > width or y + radius > height or x - radius < 0 or y - radius < 0)

                room = { x = x, y = y, size = size, radius = radius}

                if i == 0 then
                    inst.player = Friendly.new(x * 32, y * 32, 32, 32)
                    inst.cameraX = -x * 32
                    inst.cameraY = -y * 32

                    table.insert(inst.entities, inst.player)
                end

                local kx = x - radius
                local ky = y - radius

                for k = 0, size do
                    for l = 0, size do
                        inst:setTile(kx + k, ky + l, true)
                    end
                end

                table.insert(rooms, room)
            else
                for k, room in pairs(rooms) do
                    local next = rooms[k + 1]
                    local x = room.x
                    local y = room.y

                    if next then
                        local nextX = next.x
                        local nextY = next.y
                        local nextSize = next.size
                        local nextRadius = next.radius
                        local targets

                        if lcg:random() >= 0.5 then
                            targets = {{
                                x = x,
                                y = nextY,
                                radius = 1
                            }, {
                                x = nextX,
                                y = nextY,
                                radius = nextRadius
                            }}
                        else
                            targets = {{
                                x = nextX,
                                y = y,
                                radius = 1
                            }, {
                                x = nextX,
                                y = nextY,
                                radius = nextRadius
                            }}
                        end

                        repeat
                            target = targets[1]
                            targetX = target.x
                            targetY = target.y
                            targetRadius = target.radius

                            inst:setTile(x, y, true)
                            inst:setTile(x + 1, y, true)
                            inst:setTile(x - 1, y, true)
                            inst:setTile(x, y + 1, true)
                            inst:setTile(x, y - 1, true)
                            inst:setTile(x - 1, y - 1, true)
                            inst:setTile(x + 1, y - 1, true)
                            inst:setTile(x - 1, y + 1, true)
                            inst:setTile(x + 1, y + 1, true)

                            if math.sqrt((targetX - x) ^ 2 + (targetY - y) ^ 2) < targetRadius then
                                table.remove(targets, 1)
                            end

                            local north = math.sqrt((targetX - x) ^ 2 + (targetY - (y + 1)) ^ 2)
                            local south = math.sqrt((targetX - x) ^ 2 + (targetY - (y - 1)) ^ 2)
                            local east = math.sqrt((targetX - (x + 1)) ^ 2 + (targetY - y) ^ 2)
                            local west = math.sqrt((targetX - (x - 1)) ^ 2 + (targetY - y) ^ 2)

                            if north <= west and north <= south and north <= east then
                                y = y + 1
                            elseif south <= west and south <= north and south <= east then
                                y = y - 1
                            elseif east <= west and east <= south and east <= north then
                                x = x + 1
                            elseif west <= east and west <= south and west <= north then
                                x = x - 1
                            end
                        until table.getn(targets) < 1
                    end
                end
            end
        end
    end

    gui.state = "Placing..."

    function tile(x, y)
        return love.graphics.newQuad(x * 32, y * 32, 32, 32, tileset:getWidth(), tileset:getHeight())
    end

    function tileCollision(x, y)
        local box = collider:addRectangle(x * 32, y * 32, 32, 32)

        collider:setPassive(box)
    end

    local tilesetQuads = {
        wall = tile(4, 1),
        wallLeft = tile(4, 0),
        wallRight = tile(4, 2),
        roof = tile(5, 3),
        floor = tile(0, 1)
    }
    local tilesBatch = love.graphics.newSpriteBatch(tileset, width * height)

    for x = 0, width do
        for y = 0, height do
            local curr = not inst:getTile(x, y)
            local north = not inst:getTile(x, y - 1)
            local northEast = not inst:getTile(x + 1, y - 1)
            local northWest = not inst:getTile(x - 1, y - 1)
            local south = not inst:getTile(x, y + 1)
            local southEast = not inst:getTile(x + 1, y + 1)
            local southEastSouth = not inst:getTile(x + 1, y + 2)
            local southWest = not inst:getTile(x - 1, y + 1)
            local southWestSouth = not inst:getTile(x - 1, y + 2)
            local southSouth = not inst:getTile(x, y + 2)
            local southSouthWest = not inst:getTile(x - 1, y + 2)
            local southSouthEast = not inst:getTile(x + 1, y + 2)
            local east = not inst:getTile(x + 1, y)
            local eastEast = not inst:getTile(x + 2, y)
            local west = not inst:getTile(x - 1, y)
            local westWest = not inst:getTile(x - 2, y)

            -- This logic is definitely broken in some places, so fix it where necessary.
            -- WARNING: Trying to understand this logic can cause suicidal thoughts.

            if not curr then
                if (not north and not east and northEast) or
                   (not south and not east and southEast) or
                   (not north and not west and northWest) or
                   (not south and not west and southWest) then
                   table.insert(nodes, {x = x * 32, y = y * 32})
                end

                tilesBatch:addq(tilesetQuads.floor, x * 32, y * 32)
            else
                tileCollision(x, y)

                if not south then
                    tilesBatch:addq(tilesetQuads.wall, x * 32, y * 32)
                elseif (not north or not east or not south or not west) or
                       (not southEast or not southWest or not northEast or not northWest) or
                       (not southSouth or not southSouthEast or not southSouthWest) then
                    tilesBatch:addq(tilesetQuads.roof, x * 32, y * 32)
                end
            end
        end
    end

    gui.state = "Finalizing..."
    gui.loaded = true
    inst.tilesBatch = tilesBatch

    return inst
end

function World:render()
    love.graphics.push()
    love.graphics.translate(math.floor(self.cameraX + love.graphics.getWidth() / 2), math.floor(self.cameraY + love.graphics.getHeight() / 2))
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.tilesBatch)

    for i, entity in pairs(self.entities) do
        entity:render()
    end

    if self.renderString ~= "" then
        love.graphics.printf(self.renderString, 0, 0, 800)
    end

    love.graphics.pop()
end

function World:setTile(x, y, bit)
    self.tiles[x .. "_" .. y] = bit
end

function World:getTile(x, y)
    return self.tiles[x .. "_" .. y]
end

return World
