WaveMgr = {}
WaveMgr.__index = WaveMgr

function WaveMgr.new(total, spawns)
	local inst = {}

	setmetatable(inst, WaveMgr)

	inst.spawns = spawns
	inst.batch = math.floor(total / #spawns)
	inst.total = total
	inst.dispatched = 0

	return inst
end

function WaveMgr:update(dt)
	if #world.enemies == 0 then
		if self.dispatched >= self.total then
			print("win")
		else
			self.dispatched = self.dispatched + self.batch

			local spawn = self.spawns[math.ceil(world.lcg:random() * #self.spawns)]

			for i = 0, self.batch do
				Enemy.new(spawn.x * 32, spawn.y * 32, "HeroKnight")
			end

			gui:notifyWave(spawn.x, spawn.y)
			print("Dispatched " .. self.dispatched .. "/" .. self.total)
		end
	end

	if #world.friendlies == 0 then
		print("lose")
	end
end

return WaveMgr
