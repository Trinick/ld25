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

    inst.globalSfxVolume = 1.0
    inst.sfxVolumes = {}
    inst.sfx = {}
    inst:loadAllSfx()

    inst.nowPlaying = nil
    inst.globalMusicvolume = 1.0
    inst.musicVolumes = {}
    inst.allMusic = {}
    inst.themes = {}
    inst:loadAllSongs()

    return inst
end

--- Load all sound effects (not music) into this object.
function AudioCtl:loadAllSfx()
    self:loadEffect("pop", "art/sounds/pop.wav", 1.0)
    self:loadEffect("hit", "art/sounds/hitsound.wav", 1.0)
    self:loadEffect("die", "art/sounds/die.wav", 1.0)
end

--- Prepare all music for streaming from disk, but don't play any of it.
function AudioCtl:loadAllSongs()
    self:loadSong("derpy", "easy_dungeon", "art/sounds/derpybgm.ogg", 1.0)
    self:loadSong("quick", "easy_dungeon", "art/sounds/easy_quicksong.ogg", 1.0)
end

--- Load a sound effect NAME from location PATH with volume VOL.
function AudioCtl:loadEffect(name, path, vol)
    self.sfx[name] = love.audio.newSource(path, "static")
    self.sfxVolumes[name] = vol
end

--- Load a song SONGNAME into theme THEME from location PATH with volume VOL.
--  A theme represents a collection of similarly purposed music. For example,
--  all easy dungeons may play songs from the easy_dungeon theme while hard
--  ones play from the hard_dungeon theme.
function AudioCtl:loadSong(songName, theme, path, vol)
    self.allMusic[songName] = love.audio.newSource(path, "stream")
    self.musicVolumes[songName] = vol

    for group, tbl in pairs(self.themes) do
        if group == theme then
            local themeGrp = self.themes[theme]
            themeGrp[#themeGrp + 1] = songName

            return
        end
    end

    self.themes[theme] = {}
    themeGrp = self.themes[theme]
    themeGrp[#themeGrp + 1] = songName
end

--- Sets the global volume multiplier for sound effects to VOL. Must be
--  between 0 and 1 inclusive.
function AudioCtl:setSfxVolume(vol)
    if vol > 1.0 then
        vol = 1.0
    elseif vol < 0 then
        vol = 0
    end

    self.globalSfxVolume = vol
end

--- Sets the global volume multiplier for music to VOL. Must be
--  between 0 and 1 inclusive.
function AudioCtl:setMusicVolume(vol)
    if vol > 1.0 then
        vol = 1.0
    elseif vol < 0 then
        vol = 0
    end

    self.globalMusicVolume = vol
end

--- Plays sound effect NAME once. If no such sound is found, plays a default sound
--  effect.
function AudioCtl:playSound(name)
    sound = nil
    volume = 1.0

    for soundName, soundObj in pairs(self.sfx) do
        if soundName == name then
            sound = soundObj
            volume = self.sfxVolumes[soundName]

            break
        end
    end

    if sound == nil then
        sound = self.sfx["pop"]
        volume = self.sfxVolumes["pop"]
    end

    sound:setVolume(self.globalSfxVolume * volume)
    love.audio.rewind(sound)
    love.audio.play(sound)
end

--- Loops the song SONG. Stops any currently playing song. Does nothing if
--  SONG does not exist.
function AudioCtl:playSong(song)
    sound = nil
    volume = 1.0
    local songObj = self.allMusic[song]
    sound = songObj
    volume = self.musicVolumes[song]    

    if sound == nil then
        return
    end

    self:stopMusic()
    sound:setVolume(self.globalSfxVolume * volume)
    sound:setLooping(true)
    love.audio.rewind(sound)
    love.audio.play(sound)
    self.nowPlaying = sound
end

--- Loops a random song from theme THEME.
function AudioCtl:playFromTheme(theme)
    group = self.themes[theme]

    if group == nil or #group == 0 then
        return
    end

    self:playSong(group[math.random(#group)])
end

--- Pauses BGM.
function AudioCtl:stopMusic()
    if self.nowPlaying ~= nil then
        love.audio.stop(self.nowPlaying)
    end
end

--- Resumes BGM, hopefully.
function AudioCtl:resumeMusic()
    if self.nowPlaying ~= nil then
        love.audio.play(self.nowPlaying)
    end
end

return AudioCtl
