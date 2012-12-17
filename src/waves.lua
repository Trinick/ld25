WaveMgr = {}
WaveMgr.__index = WaveMgr

function WaveMgr.new()
	local inst = {}
	
	setmetatable(inst, WaveMgr)

	inst.waveCount = 12
	inst.waveTimeout = 0.5 * 60 --one minute
	inst.currentTime = 0
	inst.currentWave = 0
	inst.timeRunning = 0
	inst.spawnPoints = {}

	return inst
end

function WaveMgr:addSpawnPoint(x, y)
	table.insert(self.spawnPoints, {x, y})
	print("Added SP " .. x .. " " .. y)
end

function WaveMgr:start()
	self.currentTime = 0
	self.currentWave = 1
	self.timeRunning = 1
end

function WaveMgr:pause()
	self.timeRunning = 0
end

function WaveMgr:unpause()
	self.timeRunning = 1
end

function WaveMgr:stop()
	self.currentTime = 0
	self.currentWave = 0
	self.timeRunning = 0
end

function WaveMgr:newWave()
	for i=1,#self.spawnPoints,1 do
		Enemy.new(self.spawnPoints[i][1] * 32 + 16, self.spawnPoints[i][2] * 32 + 16, "HeroKnight")
	end
end

function WaveMgr:update(dt)
	if self.timeRunning == 0 then return end
	self.currentTime = self.currentTime + dt
	if self.currentTime >= self.waveTimeout * (self.currentWave-1) then
		self.currentTime = self.waveTimeout * (self.currentWave-1)
		self.currentWave = self.currentWave + 1
		self:newWave()
	end
end

return WaveMgr