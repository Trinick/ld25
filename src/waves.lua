WaveMgr = {}
WaveMgr.__index = WaveMgr

function WaveMgr.new(total, spawns)
	local inst = {}

	setmetatable(inst, WaveMgr)

	inst.spawns = spawns
	inst.batch = math.floor(total / #spawns)
	inst.total = total
	inst.dispatched = 0
	inst.dispatchStep = 0
	inst.dispatching = nil

	return inst
end

function WaveMgr:update(dt)
	local spawn = self.dispatching
	local old = self.dispatchStep

	if spawn then
		self.dispatchStep = self.dispatchStep + dt

		if math.floor(self.dispatchStep) > old then
			local enemy = Enemy.new(spawn.x * 32, spawn.y * 32, "HeroKnight")

			self.dispatched = self.dispatched + 1

			enemy:pushCmd(entityPatrol, {true, 128, 18, 3})
			print("Dispatched " .. self.dispatched .. "/" .. self.total)
		end

		if self.dispatchStep >= self.batch then
			self.dispatching = nil
		end
	else
		if #world.enemies == 0 then
			if self.dispatched >= self.total then
				print("win")
			else
				local spawn = self.spawns[math.ceil(world.lcg:random() * #self.spawns)]

				self.dispatchStep = 0
				self.dispatching = spawn

				gui:notifyWave(spawn.x, spawn.y)
			end
		end

		if #world.friendlies == 0 then
			print("lose")
		end
	end
end

return WaveMgr
