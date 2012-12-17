Entity = require "entity"
Friendly = require "friendly"
Enemy = require "enemy"
LCG = require "lcg"
AudioCtl = require "audio"

World = {}
World.__index = World

function World.new(seed)
    local inst = {}

    setmetatable(inst, World)

    inst.audioCtlr = AudioCtl.new()
    inst.audioCtlr:playSong("derpy")
    inst.entities = {}
    inst.friendlies = {}
    inst.enemies = {}
    inst.nodes = {}
    inst.lcg = LCG.new(seed)
    inst.tiles = {}
    inst.width = 100
    inst.height = 100
    inst.rooms = {}
    inst.state = nil

    return inst
end

function World:generate()
    if self.state == nil then
        gui.state = "Digging..."
        self.state = "dig"
    elseif self.state == "dig" then
        self:dig()

        gui.state = "Placing..."
        self.state = "place"
    elseif self.state == "place" then
        self:place()

        gui.state = "Finalizing..."
        self.state = "finalize"
    elseif self.state == "finalize" then
        self:finalize()
    end
end

function World:dig()
    local width = self.width
    local height = self.height
    local rooms = self.rooms
    local lcg = self.lcg
    local roomCount = 16 + math.floor(lcg:random() * (width + height) / 2) * 2

    -- Initialize the initial tilemap to all solid
    for x = 1, width do
        for y = 1, height, 1 do
            self.tiles[x .. "_" .. y] = false
        end
    end

    -- Complete two passes, first pass generating room positions
    -- then hollow out hallways

    for j = 1, 2 do
        if j == 1 then
            for i = 0, roomCount do
                local x, y, radius, size

                repeat
                    size = 5 + math.floor(lcg:random() * 7)
                    radius = math.floor(size / 2)
                    x = math.floor(lcg:random() * width)
                    y = math.floor(lcg:random() * height)
                until not (x + radius > width or y + radius > height or x - radius < 0 or y - radius < 0)

                room = { x = x, y = y, size = size, radius = radius}

                local kx = x - radius
                local ky = y - radius

                for k = 0, size do
                    for l = 0, size do
                        self:setTile(kx + k, ky + l, true)
                    end
                end

                table.insert(rooms, room)
            end
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

                    -- Possibly choose

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

                        self:setTile(x, y, true)
                        self:setTile(x + 1, y, true)
                        self:setTile(x - 1, y, true)
                        self:setTile(x, y + 1, true)
                        self:setTile(x, y - 1, true)
                        self:setTile(x - 1, y - 1, true)
                        self:setTile(x + 1, y - 1, true)
                        self:setTile(x - 1, y + 1, true)
                        self:setTile(x + 1, y + 1, true)

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
                    until #targets < 1
                end
            end
        end
    end
end

function World:place()
    function tile(x, y)
        return love.graphics.newQuad(x * 32, y * 32, 32, 32, tileset:getWidth(), tileset:getHeight())
    end

    local nodes = self.nodes
    local width = self.width
    local height = self.height
    local tilesetQuads = {
        wall = tile(4, 1),
        wallLeft = tile(4, 0),
        wallRight = tile(4, 2),
        roof = tile(5, 3),
        floor = tile(0, 1)
    }
    local tilesBatch = love.graphics.newSpriteBatch(tileset, width * self.height)
    local walls = {}

    function setWall(x, y)
        walls[x .. "_" .. y] = true
    end

    function isWall(x, y)
        return walls[x .. "_" .. y] == true
    end

    for x = 0, width do
        for y = 0, height do
            local curr = not self:getTile(x, y)
            local north = not self:getTile(x, y - 1)
            local northEast = not self:getTile(x + 1, y - 1)
            local northWest = not self:getTile(x - 1, y - 1)
            local south = not self:getTile(x, y + 1)
            local southEast = not self:getTile(x + 1, y + 1)
            local southEastSouth = not self:getTile(x + 1, y + 2)
            local southWest = not self:getTile(x - 1, y + 1)
            local southWestSouth = not self:getTile(x - 1, y + 2)
            local southSouth = not self:getTile(x, y + 2)
            local southSouthWest = not self:getTile(x - 1, y + 2)
            local southSouthEast = not self:getTile(x + 1, y + 2)
            local east = not self:getTile(x + 1, y)
            local eastEast = not self:getTile(x + 2, y)
            local west = not self:getTile(x - 1, y)
            local westWest = not self:getTile(x - 2, y)

            -- This logic is definitely broken in some places, so fix it where necessary.
            -- WARNING: Trying to understand this logic can cause suicidal thoughts.

            if not curr then
                if (not north and not east and northEast) or
                   (not south and not east and southEast) or
                   (not north and not west and northWest) or
                   (not south and not west and southWest) then
                   table.insert(nodes, {x = x * 32 + 16, y = y * 32 + 16, neighbors = {}})
                end

                tilesBatch:addq(tilesetQuads.floor, x * 32, y * 32)
            elseif (not south and not north) or (not east and not west) then
                -- Clear 1x walls cause they look shit
                self:setTile(x, y, true)
                tilesBatch:addq(tilesetQuads.floor, x * 32, y * 32)
            else
                setWall(x, y)

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

    -- Wall Rectangle Optimization --
    local rectangles = {}

    for x = 0, width do
        local start_y
        local end_y

        for y = 0, height do
            if isWall(x, y) then
                if not start_y then
                    start_y = y
                end
                end_y = y

                if y == height then
                    local overlaps = {}
                    for _, r in ipairs(rectangles) do
                        if (r.end_x == x - 1)
                          and (start_y <= r.start_y)
                          and (end_y >= r.end_y) then
                            table.insert(overlaps, r)
                        end
                    end
                    table.sort(
                        overlaps,
                        function (a, b)
                            return a.start_y < b.start_y
                        end
                    )

                    for _, r in ipairs(overlaps) do
                        if start_y == r.start_y then
                            r.end_x = r.end_x + 1

                            if end_y == r.end_y then
                                start_y = nil
                                end_y = nil
                            elseif end_y > r.end_y then
                                start_y = r.end_y + 1
                            end
                        end
                    end
                end
            elseif start_y then
                local overlaps = {}
                for _, r in ipairs(rectangles) do
                    if (r.end_x == x - 1)
                      and (start_y <= r.start_y)
                      and (end_y >= r.end_y) then
                        table.insert(overlaps, r)
                    end
                end
                table.sort(
                    overlaps,
                    function (a, b)
                        return a.start_y < b.start_y
                    end
                )

                for _, r in ipairs(overlaps) do
                    if start_y < r.start_y then
                        local new_rect = {
                            start_x = x,
                            start_y = start_y,
                            end_x = x,
                            end_y = r.start_y - 1
                        }
                        table.insert(rectangles, new_rect)
                        start_y = r.start_y
                    end

                    if start_y == r.start_y then
                        r.end_x = r.end_x + 1

                        if end_y == r.end_y then
                            start_y = nil
                            end_y = nil
                        elseif end_y > r.end_y then
                            start_y = r.end_y + 1
                        end
                    end
                end

                if start_y then
                    local new_rect = {
                        start_x = x,
                        start_y = start_y,
                        end_x = x,
                        end_y = end_y
                    }
                    table.insert(rectangles, new_rect)
                    start_y = nil
                    end_y = nil
                end
            end
        end

        if start_y then
            local new_rect = {
                start_x = x,
                start_y = start_y,
                end_x = x,
                end_y = end_y
            }
            table.insert(rectangles, new_rect)
            start_y = nil
            end_y = nil
        end
    end

    -- Creation of Wall Collision Boxes --
    for _, r in ipairs(rectangles) do
        local start_x = r.start_x * 32
        local start_y = r.start_y * 32
        local width = (r.end_x - r.start_x + 1) * 32
        local height = (r.end_y - r.start_y + 1) * 32

        local box = collider:addRectangle(start_x, start_y, width, height)

        collider:setPassive(box)
    end

    self.tilesBatch = tilesBatch
end

function World:finalize()
    -- Neighorhoo Generation for Navigation Nodes --
    local nodes = self.nodes
    local checked = {}

    for a, node in pairs(nodes) do
        checked[a] = {}
    end

    for a, nodeA in pairs(nodes) do
        for b, nodeB in pairs(nodes) do
            if a ~= b and checked[a][b] == nil then
                if # raycast(nodeA.x, nodeA.y, nodeB.x, nodeB.y) == 0 then
                    checked[a][b] = 1
                    checked[b][a] = 1
                    table.insert(nodeA.neighbors, b)
                    table.insert(nodeB.neighbors, a)
                end
            end
        end
    end

    self:populate()

    gui.loaded = true
    gui:renderMap()
end

function World:populate()
    local x = self.rooms[1].x
    local y = self.rooms[1].y
    local debugPlayer = Friendly.new(x * 32, y * 32, 32, 64)
    self.cameraX = -x * 32
    self.cameraY = -y * 32
end

function World:render()
    love.graphics.push()
    love.graphics.translate(math.floor(self.cameraX + love.graphics.getWidth() / 2), math.floor(self.cameraY + love.graphics.getHeight() / 2))
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.tilesBatch)

    -- TODO: optimize
    function isControlled(entity)
        for i, controlled in pairs(control.controlling) do
            if controlled == entity then
                return true
            end
        end

        return false
    end

    for i, entity in pairs(self.entities) do
        if isControlled(entity) then
            love.graphics.setColor(189, 129, 171)
        end

        entity:render()
    end

    love.graphics.pop()
end

function World:setTile(x, y, bit)
    self.tiles[x .. "_" .. y] = bit
end

function World:getTile(x, y)
    return self.tiles[x .. "_" .. y]
end

function World:update(dt)
    for a, entity in pairs(self.entities) do
        entity:think(dt)
    end
end

return World
