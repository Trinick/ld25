GUI = {}
GUI.__index = GUI

function GUI.new()
    local inst = {}

    setmetatable(inst, GUI)

    inst.state = "Loading..."
    inst.loaded = false
    inst.ready = false
    inst.skull = love.graphics.newImage("art/images/skull.png")

    return inst
end

function GUI:renderLoading()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    local tip = "PROTIP: Having unsafe sex can result in STIs."
    local tipWidth = font:getWidth(tip)

    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.skull, width / 2 - self.skull:getWidth() / 2, height / 2 - self.skull:getHeight() / 2)
    love.graphics.print(tip, width / 2 - tipWidth / 2, height / 2 + self.skull:getHeight() * 7 / 6)

    if not self.loaded then
        love.graphics.print(self.state, 16, height - 32)
    else
        love.graphics.setColor(225, 225, 225)
        love.graphics.print("Press any key to continue", 16, height - 32)
    end
end

function GUI:renderHUD()

end

function GUI:render()
    love.graphics.setFont(font)

    if not self.loaded or not self.ready then
        self:renderLoading()
    else
        self:renderHUD()
    end
end

function GUI:update(dt)
end

return GUI
