Control = {}
Control.__index = Control

function Control.new(world)
    local inst = {}

	setmetatable(inst, Control)

	inst.world = world;
	inst.currControl = {}

    return inst
end

function Control:moveCheck(dt)
    for i, entity in pairs(self.currControl) do
        if entity ~= 0 then
            ns = 0
            ew = 0

            if love.keyboard.isDown("w") then
                ns = entity.moveSpeed * -dt;
            end
            if love.keyboard.isDown("d") then
                ew = entity.moveSpeed * dt;
            end
            if love.keyboard.isDown("s") then
                ns = entity.moveSpeed * dt;
            end
            if love.keyboard.isDown("a") then
                ew = entity.moveSpeed * -dt;
            end

            entity.x = entity.x + ew;
            entity.y = entity.y + ns;
        end
    end
end

function Control:onClick(x, y, button)
    if button == "l" then
        self.currControl[1] = 0
        for i, entity in pairs(self.world.entities) do
            if entity:collisionCheck(x, y) == 1 then
                self.currControl[1] = entity
            end
        end
    end
	for i, entity in pairs(self.currControl) do
		if entity ~= 0 then
			ns = 0
			ew = 0

			if love.keyboard.isDown("w") then
				ns = entity.moveSpeed * dt * -1;
			end
			if love.keyboard.isDown("d") then
				ew = entity.moveSpeed * dt;
			end
			if love.keyboard.isDown("s") then
				ns = entity.moveSpeed * dt;
			end
			if love.keyboard.isDown("a") then
				ew = entity.moveSpeed * dt * -1;
			end

			entity.x = entity.x + ew;
			entity.y = entity.y + ns;
		end
	end
end

function Control:onClick(x, y, button)
	if button == "l" then
		self.currControl[1] = 0

		for i, entity in pairs(self.world.entities) do
			if entity:collisionCheck(x, y) == 1 then
				self.currControl[1] = entity
			end
		end
	end
end

return Control
