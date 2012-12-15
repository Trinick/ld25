Control = {}
Control.__index = Control

function Control.new(world)
	local inst = {}

	setmetatable(inst, Control)

	inst.world = world;
	inst.currcontrol = {}

	return inst
end

function Control:movecheck(dt)
	for i, entity in pairs(self.currcontrol) do
		ns = 0
		ew = 0
		if love.keyboard.isDown("w") then
			ns = entity.movespeed * dt * -1;
			self.world.renderstring = "w"
		end
		if love.keyboard.isDown("d") then
			ew = entity.movespeed * dt;
			self.world.renderstring = "d"
		end
		if love.keyboard.isDown("s") then
			ns = entity.movespeed * dt;
			self.world.renderstring = "s"
		end
		if love.keyboard.isDown("a") then
			ew = entity.movespeed * dt * -1;
			self.world.renderstring = "a"
		end
		self.world.renderstring = ns .." " .. ew
		entity.x = entity.x + ew;
		entity.y = entity.y + ns;
	end
end

function Control:onclick(x, y, button)
	if button == "l" then
		for i, entity in pairs(self.world.entities) do
			if entity:collisionCheck(x, y) == 1 then
				self.currcontrol[1] = entity
				self.world.renderstring = 1
			end
		end
	end
end

return Control