Entity = require "entity"
Friendly = require "friendly"
Enemy = require "enemy"
LCG = require "lcg"

World = {}
World.__index = World

function World.new(seed)
    local inst = {}

    setmetatable(inst, World)

    inst.player = Friendly.new(300, 300, 32, 32)
    inst.entities = {inst.player}
    inst.renderString = ""

    local lcg = LCG.new(seed)
    local player = Entity.new(300, 300, 32, 32)
    local entities = {player}
    local width = 100
    local height = 100
    local tiles = {}

    for x = 1, width do
        for y = 1, height, 1 do
            tiles[x .. "_" .. y] = false
        end
    end

    inst.player = player
    inst.entities = entities
    inst.lcg = lcg
    inst.tiles = tiles
    inst.width = width
    inst.height = height
    inst.tiles = tiles

    local rooms = {}
    local count = 8 + math.floor(lcg:random() * (width + height) / 2)
    local spawnX, spawnY

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
                    spawnX = x
                    spawnY = y
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

    function tile(x, y)
        return love.graphics.newQuad(x * 32, y * 32, 32, 32, tileset:getWidth(), tileset:getHeight())
    end

    local tilesetQuads = {
        roofTop = tile(5, 0),
        roofTopLeft = tile(4, 0),
        roofTopRight = tile(6, 0),
        roofTopLeftInverted = tile(6, 5),
        roofTopRightInverted = tile(4, 5),
        roofLeft = tile(4, 1),
        roofRight = tile(6, 1),
        roofBottom = tile(5, 3),
        roofBottomLeft = tile(4, 3),
        roofBottomRight = tile(6, 3),
        roofBottomLeftInverted = tile(6, 4),
        roofBottomRightInverted = tile(4, 4),
        wallTop = tile(5, 1),
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
            local east = not inst:getTile(x + 1, y)
            local eastEast = not inst:getTile(x + 2, y)
            local west = not inst:getTile(x - 1, y)
            local westWest = not inst:getTile(x - 2, y)

            -- This logic is definitely broken in some places, so fix it where necessary.

            if not curr then
                tilesBatch:addq(tilesetQuads.floor, x * 32, y * 32)
            elseif north and south and west and not east and not southSouth then
                tilesBatch:addq(tilesetQuads.roofBottomLeftInverted, x * 32, y * 32)
            elseif north and south and east and not west and not southSouth then
                tilesBatch:addq(tilesetQuads.roofBottomLeftInverted, x * 32, y * 32)
            elseif north and south and west and not east then
                tilesBatch:addq(tilesetQuads.roofLeft, x * 32, y * 32)
            elseif north and south and east and not west then
                tilesBatch:addq(tilesetQuads.roofRight, x * 32, y * 32)
            elseif north and east and not northEast then
                tilesBatch:addq(tilesetQuads.roofBottomLeft, x * 32, y * 32)
            elseif north and west and not northWest then
                tilesBatch:addq(tilesetQuads.roofBottomRight, x * 32, y * 32)
            elseif south and not north and not west then
                tilesBatch:addq(tilesetQuads.roofTopLeftInverted, x * 32, y * 32)
            elseif south and not north and not east then
                tilesBatch:addq(tilesetQuads.roofTopRightInverted, x * 32, y * 32)
            elseif south and not north then
                tilesBatch:addq(tilesetQuads.roofBottom, x * 32, y * 32)
            elseif (east or not eastEast) and (west or not westWest) and not south then
                tilesBatch:addq(tilesetQuads.wallTop, x * 32, y * 32)
            elseif east and west and south and not southSouth then
                tilesBatch:addq(tilesetQuads.roofTop, x * 32, y * 32)
            elseif west and south and not southEast then
                tilesBatch:addq(tilesetQuads.roofLeft, x * 32, y * 32)
            elseif east and south and southEast and not southEastSouth then
                tilesBatch:addq(tilesetQuads.roofTopLeft, x * 32, y * 32)
            elseif east and south and not southWest then
                tilesBatch:addq(tilesetQuads.roofRight, x * 32, y * 32)
            elseif west and south and southWest and not southWestSouth then
                tilesBatch:addq(tilesetQuads.roofTopRight, x * 32, y * 32)
            end
        end
    end

    inst.tilesBatch = tilesBatch

    return inst
end

function World:render()
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.tilesBatch)

    for i, entity in pairs(self.entities) do
        entity:render(x, y)
    end

    if self.renderString ~= "" then
    	love.graphics.printf(self.renderString, 0, 0, 800)
    end
end

function World:setTile(x, y, bit)
    self.tiles[x .. "_" .. y] = bit
end

function World:getTile(x, y)
    return self.tiles[x .. "_" .. y]
end

return World
