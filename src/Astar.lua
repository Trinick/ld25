width = 16
height = 16

function tileValid(x, y)
    return x >= 1 and x <= width and y >= 1 and y <= height
end
function tileID(x, y)
    return x + (y - 1) * width
end
function tileData(id)
    return {x = id % width, y = math.floor(id / width) + 1}
end

function dist(aX, aY, bX, bY)
    return math.sqrt(math.pow(aX - bX, 2) + math.pow(aY - bY, 2))
end

function Astar(startX, startY, targetX, targetY)
    local startID = tileID(startX, startY)
    local targetID = tileID(targetX, targetY)
    local openSet = {startID}
    local inOpenSet = {[startID] = 1}
    local inClosedSet = {}
    local cameFrom = {}
    local gScore = {[startID] = 0}
    local fScore = {[startID] = gScore[startID] + dist(startX, startY, targetX, targetY)}

    while # openSet ~= 0 do
        table.sort(openSet)

        current = table.remove(openSet, 1)
        inOpenSet[current] = nil
        inClosedSet[current] = 1

        curData = tileData(current)

        if current == targetID then
            return reconstructPath(cameFrom, current)
        end

        for a=-1,1 do
            for b=-1,1 do
--                if a ~= 0 or b ~= 0 then -- Full Neighbor Check
                if a ~= b and a ~= -b then -- Non-Diagonal Neighbor Check
                    x = curData.x + a
                    y = curData.y + b
                    if tileValid(x, y) then
                        id = tileID(x, y)
                        if inClosedSet[id] == nil then
                            tgScore = gScore[current] + dist(0, 0, a, b)
                            if inOpenSet[id] == nil then
                                cameFrom[id] = current
                                gScore[id] = tgScore
                                fScore[id] = gScore[id] + dist(x, y, targetX, targetY)
                                table.insert(openSet, id)
                                inOpenSet[id] = 1
                            elseif gScore[id] ~= nil then
                                if tgScore < gScore[id] then
                                    cameFrom[id] = current
                                    gScore[id] = tgScore
                                    fScore[id] = gScore[id] + dist(x, y, targetX, targetY)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function reconstructPath(cameFrom, current)
    data = tileData(current)
    print(data.x, data.y, current, cameFrom[current])
    if cameFrom[current] ~= nil then
        asdf = reconstructPath(cameFrom, cameFrom[current])
        table.insert(asdf, current)
        return asdf
    end
    return {current}
end

print(# Astar(1, 1, 3, 5))
