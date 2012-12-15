Control = {}
Control.__index = Control

function Control.new(world)
	local inst = {}

	setmetatable(inst, World)

	inst.world = world;
	inst.currcontrol = {}

	return inst
end

function Control:check(dt)
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
		entity.x += ns;
		entity.y += ew;
	end
end

function Control:onclick(x, y, button)
	if button == 1 then
		for i, entity in pairs(self.world.entities) do
			if entity.collisionCheck(x, y) && entity.canControl then
				this.currcontrol[1] = entity;
			end
		end
	end
end

return Control