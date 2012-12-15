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
		if love.keyboard.isDown(w) then
			ns = entity.movespeed * dt;
		end
		if love.keyboard.isDown(d) then
			ew = entity.movespeed * dt;
		end
		if love.keyboard.isDown(s) then
			ns = entity.movespeed * dt * -1;
		end
		if love.keyboard.isDown(a) then
			ew = entity.movespeed * dt * -1;
		end
		entity.x = entity.y + ns;
		entity.y = entity.y + ew;
	end
end

function Control:onclick(x, y, button)
	if button == "l" then
		for i, entity in pairs(self.world.entities) do
			if entity.collisionCheck(x, y) and entity.canControl then
				self.currcontrol[1] = entity
				self.world.renderstring = entity
			end
		end
	end
end

return Control