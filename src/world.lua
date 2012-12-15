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

    for x = 1, width, 1 do
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

    local rooms = {}
    local count = 8 + math.floor(lcg:random() * (width + height) / 2)
    local spawnX, spawnY

    for j = 1, 2, 1 do
        for i = 0, count, 1 do
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

                for k = 0, size, 1 do
                    for l = 0, size, 1 do
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

    return inst
end

function World:render()
    for i, entity in pairs(self.entities) do
        entity:render(x, y)
    end

    if self.renderString ~= "" then
    	love.graphics.printf(self.renderString, 0, 0, 800)
    end
end

function World:setTile(x, y, bit)
    self.tiles[x .. "_" .. y]= bit
end

function World:getTile(x, y)
    return self.tiles[x .. "_" .. y]
end

return World
