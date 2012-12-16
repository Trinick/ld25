GUI = {}
GUI.__index = GUI

function GUI.new()
    local inst = {}

    setmetatable(inst, GUI)

    inst.loading = true
    inst.progress = 0
    inst.ready = true

    return inst
end

function GUI:renderLoading()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle(0, 1024 - 50
end

function GUI:renderHUD()
end

function GUI:render()
    if self.loading then
        self:renderLoading()
    else
        self:renderHUD()
    end
end

function GUI:tick(dt)
    if self.loading then
        if inst.progess >= 100 then

    end
end

return GUI
