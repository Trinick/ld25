---
--- audio.lua - AudioCtl object
---
--- Usage:
---     Give the World object an "audio" field set to an AudioCtl.new().
---     Whenever you need to play a sound effect from e.g. an entity,
---     call something like self.world.audio:playSound("skeleton_hit") .
---     If SOUNDNAME does not exist it will just play a placeholder pop
---     sound effect.
---
---     Music coming soon. 

AudioCtl = {}
AudioCtl.__index = AudioCtl

--- Creates a new audio controller. Only one of these is needed.
function AudioCtl.new()
    local inst = {}

    setmetatable(inst, AudioCtl)

    inst.globalvolume = 1.0
    inst.sfxvolumes = {}
    inst.sfx = {}
    inst:loadAllSFX()

    --TODO Music

    return inst
end

--- Load all sound effects (not music) into this object.
function AudioCtl:loadAllSFX()
    self:loadEffect("pop", "sound/pop.wav", 1.0);
end

--- Load a sound effect NAME from location PATH with volume VOL
function AudioCtl:loadEffect(name, path, vol)
    self.sfx[name] = love.audio.newSource(path, "static");
    self.sfxvolumes[name] = vol
end

--- Plays sound effect NAME once. If no such sound is found, plays a default sound
--  effect.
function AudioCtl:playSound(name)
    sound = nil
    volume = 1.0
    for soundname, soundobj in pairs(self.sfx) do
        if soundname == name then
            sound = soundobj
            volume = self.sfxvolumes[soundname]
            break
        end
    end
    if sound == nil then
        sound = self.sfx["pop"]
        volume = self.sfxvolumes["pop"]
    end
    sound:setVolume(self.globalvolume * volume)
    love.audio.rewind(sound)
    love.audio.play(sound)
end

--- Loops the song SONG. Stops any currently playing song. Does nothing if
--- SONG does not actually exist.
function AudioCtl:playSong(song)

end

return AudioCtl