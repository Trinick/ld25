function love.conf(t)
    t.title = "LD25"
    t.author = "Centhra"
    t.url = "http://github.com/centhra/ld25"
    t.identity = nil
    t.version = "0.8.0"
    t.console = false
    t.release = false
    t.screen.width = 800
    t.screen.height = 760
    t.screen.fullscreen = false
    t.screen.vsync = true
    t.screen.fsaa = 0
    t.modules.joystick = false
end

function love.load()
    love.graphics.setBackgroundColor(255, 255, 255)
end

function love.update(dt)
end

function love.draw()
end
